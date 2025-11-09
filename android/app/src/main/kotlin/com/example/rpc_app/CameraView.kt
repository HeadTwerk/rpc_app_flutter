package com.example.rpc_app

import android.content.Context
import android.util.Log
import android.view.View
import android.view.ViewGroup
import androidx.camera.core.AspectRatio
import androidx.camera.core.Camera
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888
import androidx.camera.core.Preview
import androidx.camera.core.resolutionselector.AspectRatioStrategy
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.ConstraintSet
import androidx.core.content.ContextCompat
import com.google.mediapipe.tasks.vision.core.RunningMode
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.platform.PlatformView
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import androidx.camera.core.ImageProxy
import android.os.Handler
import android.os.Looper

class CameraView (
    private val context: Context,
    messenger: BinaryMessenger,
    id: Int,
    creationParams: Map<String?, Any?>?,
    private val activity: FlutterActivity
) : PlatformView, GestureRecognizerHelper.GestureRecognizerListener {

    private var constraintLayout = ConstraintLayout(context)
    private var viewFinder = PreviewView(context)
    private var overlayView: OverlayView = OverlayView(context, null)

    private var backgroundExecutor: ExecutorService = Executors.newSingleThreadExecutor()
    private var cameraFacing = CameraSelector.LENS_FACING_FRONT
    private var imageAnalyzer: ImageAnalysis? = null
    private var preview: Preview? = null
    private var camera: Camera? = null
    private var cameraProvider: ProcessCameraProvider? = null

    private lateinit var gestureRecognizerHelper: GestureRecognizerHelper   

    private var delegate: Int = GestureRecognizerHelper.DELEGATE_CPU
    private var minHandDetectionConfidence: Float = GestureRecognizerHelper.DEFAULT_HAND_DETECTION_CONFIDENCE
    private var minHandTrackingConfidence: Float = GestureRecognizerHelper.DEFAULT_HAND_TRACKING_CONFIDENCE
    private var minHandPresenceConfidence: Float = GestureRecognizerHelper.DEFAULT_HAND_PRESENCE_CONFIDENCE

    // EventChannel for sending gesture results to Flutter
    private val eventChannel: EventChannel = EventChannel(messenger, "gesture_recognition_stream_$id")
    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    
    // Flag to prevent processing after disposal
    private var isActive = true

    init {

        val layoutParams = ViewGroup.LayoutParams (
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        constraintLayout.layoutParams = layoutParams
        
        val constraintSet = ConstraintSet()
        constraintSet.clone(constraintLayout)

        viewFinder.id = View.generateViewId()
        viewFinder.implementationMode = PreviewView.ImplementationMode.COMPATIBLE
        constraintLayout.addView(viewFinder)
        constraintSet.constrainWidth(viewFinder.id, ConstraintSet.MATCH_CONSTRAINT)
        constraintSet.constrainHeight(viewFinder.id, ConstraintSet.MATCH_CONSTRAINT)
        constraintSet.connect(
            viewFinder.id,
            ConstraintSet.LEFT,
            ConstraintSet.PARENT_ID,
            ConstraintSet.LEFT
        )
        constraintSet.connect(
            viewFinder.id,
            ConstraintSet.RIGHT,
            ConstraintSet.PARENT_ID,
            ConstraintSet.RIGHT
        )
        constraintSet.connect(
            viewFinder.id,
            ConstraintSet.TOP,
            ConstraintSet.PARENT_ID,
            ConstraintSet.TOP
        )
        constraintSet.connect(
            viewFinder.id,
            ConstraintSet.BOTTOM,
            ConstraintSet.PARENT_ID,
            ConstraintSet.BOTTOM
        )

        overlayView.id = View.generateViewId()
        constraintLayout.addView(overlayView)
        constraintSet.constrainWidth(overlayView.id, ConstraintSet.MATCH_CONSTRAINT)
        constraintSet.constrainHeight(overlayView.id, ConstraintSet.MATCH_CONSTRAINT)
        constraintSet.connect(
            overlayView.id,
            ConstraintSet.LEFT,
            ConstraintSet.PARENT_ID,
            ConstraintSet.LEFT
        )
        constraintSet.connect(
            overlayView.id,
            ConstraintSet.RIGHT,
            ConstraintSet.PARENT_ID,
            ConstraintSet.RIGHT
        )
        constraintSet.connect(
            overlayView.id,
            ConstraintSet.TOP,
            ConstraintSet.PARENT_ID,
            ConstraintSet.TOP
        )
        constraintSet.connect(
            overlayView.id,
            ConstraintSet.BOTTOM,
            ConstraintSet.PARENT_ID,
            ConstraintSet.BOTTOM
        )
        constraintLayout.bringChildToFront(overlayView)
        constraintSet.applyTo(constraintLayout)

        // Set up EventChannel stream handler
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                Log.d("CameraView", "EventChannel listener attached")
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
                Log.d("CameraView", "EventChannel listener cancelled")
            }
        })

        backgroundExecutor.execute {
            gestureRecognizerHelper = GestureRecognizerHelper(
                context = context,
                runningMode = RunningMode.LIVE_STREAM,
                minHandDetectionConfidence = minHandDetectionConfidence,
                minHandTrackingConfidence = minHandTrackingConfidence,
                minHandPresenceConfidence = minHandPresenceConfidence,
                currentDelegate = delegate,
                gestureRecognizerListener = this
            )

            viewFinder.post {
                setupCamera()
            }

        }
    }

    override fun dispose() {
        Log.d("CameraView", "dispose() called - starting cleanup")
        
        // Set flag to stop processing new frames
        isActive = false
        
        // Step 1: Clear the analyzer to stop new frames from being processed
        imageAnalyzer?.clearAnalyzer()
        Log.d("CameraView", "ImageAnalyzer cleared")
        
        // Step 2: Unbind all camera use cases
        cameraProvider?.unbindAll()
        Log.d("CameraView", "Camera use cases unbound")
        
        // Step 3: Wait briefly for any in-flight frames to complete
        Thread.sleep(100)
        
        // Step 4: Clean up gesture recognizer
        if(this::gestureRecognizerHelper.isInitialized) {
            gestureRecognizerHelper.clearGestureRecognizer()
            Log.d("CameraView", "GestureRecognizer cleared")
        }

        // Step 5: Clean up event channel
        eventSink = null
        eventChannel.setStreamHandler(null)
        Log.d("CameraView", "EventChannel cleaned up")

        // Step 6: Shutdown background executor
        backgroundExecutor.shutdown()
        try {
            if (!backgroundExecutor.awaitTermination(500, TimeUnit.MILLISECONDS)) {
                backgroundExecutor.shutdownNow()
                Log.d("CameraView", "BackgroundExecutor forcefully shut down")
            } else {
                Log.d("CameraView", "BackgroundExecutor shut down gracefully")
            }
        } catch (e: InterruptedException) {
            backgroundExecutor.shutdownNow()
            Thread.currentThread().interrupt()
            Log.e("CameraView", "BackgroundExecutor shutdown interrupted", e)
        }
        
        Log.d("CameraView", "dispose() completed successfully")
    }

    private fun setupCamera() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.addListener({
            cameraProvider = cameraProviderFuture.get()
            bindCameraUseCases()
        }, ContextCompat.getMainExecutor(context))
    }

    override fun getView(): View {
        return constraintLayout
    }

    // TEST bindCameraUseCases
    private fun bindCameraUseCases() {

        val aspectRatioStrategy = AspectRatioStrategy(AspectRatio.RATIO_16_9,
            AspectRatioStrategy.FALLBACK_RULE_NONE
        )

        val resolutionSelector = ResolutionSelector.Builder()
            .setAspectRatioStrategy(
                aspectRatioStrategy
            )
            .build()

        // Camera Provider
        val cameraProvider =
            cameraProvider ?: throw IllegalStateException("Camera initialization failed.")

        val cameraSelector = CameraSelector.Builder()
            .requireLensFacing(cameraFacing)
            .build()

        preview = Preview.Builder()
            .setResolutionSelector(resolutionSelector)
            .setTargetRotation(viewFinder.display.rotation)
            .build()

        imageAnalyzer = ImageAnalysis.Builder()
            .setResolutionSelector(resolutionSelector)
            .setTargetRotation(viewFinder.display.rotation)
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
            .setOutputImageFormat(OUTPUT_IMAGE_FORMAT_RGBA_8888)
            .build()

        imageAnalyzer?.setAnalyzer (backgroundExecutor, { imageProxy ->
            recgonizeHand(imageProxy)
        })

   

        cameraProvider.unbindAll()

        try {
            camera = cameraProvider.bindToLifecycle(
                activity,
                cameraSelector,
                preview,
                imageAnalyzer
            )

            preview?.setSurfaceProvider (viewFinder.surfaceProvider)

        } catch (exc: Exception) {
            Log.e("CameraView", "Use case binding failed", exc)
        }
    }

    private fun recgonizeHand(imageProxy: ImageProxy) {
        // Check if we're still active and helper is initialized
        if (!isActive || !this::gestureRecognizerHelper.isInitialized) {
            imageProxy.close()
            return
        }
        
        // Check if gesture recognizer is closed
        if (gestureRecognizerHelper.isClosed()) {
            imageProxy.close()
            return
        }
        
        gestureRecognizerHelper.recognizeLiveStream(
            imageProxy = imageProxy
        )
    }

    override fun onError(error: String, errorCode: Int) {
        Log.e("CameraView", "GestureRecognizer error: $errorCode: $error")
    }

    override fun onResults(
        resultBundle: GestureRecognizerHelper.ResultBundle
    ) {
        Log.d("CameraView", "GestureRecognizer result gesture: ${resultBundle.results.first().gestures()}")
        overlayView.setResults(
            gestureRecognizerResult = resultBundle.results.first(),
            imageHeight = resultBundle.inputImageHeight,
            imageWidth = resultBundle.inputImageWidth,
            runningMode = RunningMode.LIVE_STREAM
        )
        overlayView.invalidate()

        // Send gesture data to Flutter via EventChannel
        val gestures = resultBundle.results.first().gestures()
        if (gestures.isNotEmpty() && gestures[0].isNotEmpty()) {
            val topGesture = gestures[0][0]
            val gestureName = topGesture.categoryName()
            val confidence = topGesture.score()

            // Only send if gesture is not 'None'
            if (gestureName != "None") {
                val gestureData = mapOf(
                    "gestureName" to gestureName,
                    "confidence" to confidence,
                    "timestamp" to System.currentTimeMillis()
                )

                // Send on main thread to avoid threading issues
                mainHandler.post {
                    eventSink?.success(gestureData)
                    Log.d("CameraView", "Sent gesture to Flutter: $gestureName (${confidence})")
                }
            }
        }
    }
}