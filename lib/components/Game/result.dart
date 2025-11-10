import 'package:flutter/material.dart';
import 'package:rpc_app/constants.dart' as constants;
import 'package:flutter_svg/flutter_svg.dart';

class Result extends StatelessWidget {
  final String playeroOuput;
  final String systemOuput;
  const Result({
    super.key,
    required this.playeroOuput,
    required this.systemOuput,
  });

  String _determineWinner() {
    if (playeroOuput == systemOuput) {
      return constants.resultMessages['draw']!;
    }
    if (constants.winningConditions[playeroOuput] == systemOuput) {
      return constants.resultMessages['win']!;
    }
    return constants.resultMessages['lose']!;
  }

  Color _getResultColor() {
    final winner = _determineWinner();
    if (winner == constants.resultMessages['win']) return Colors.green;
    if (winner == constants.resultMessages['lose']) return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final winner = _determineWinner();
    final resultColor = _getResultColor();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Result text
          Text(
            winner,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: resultColor,
            ),
          ),
          const SizedBox(height: 40),
          // Player and System choices
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Player choice
              Column(
                children: [
                  const Text(
                    'You',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blueAccent, width: 2),
                    ),
                    child: SvgPicture.asset(
                      constants.choiceImages[playeroOuput]!,
                      width: 100,
                      height: 100,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    playeroOuput,
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                ],
              ),
              // VS text
              const Text(
                'VS',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              // System choice
              Column(
                children: [
                  const Text(
                    'Computer',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.redAccent, width: 2),
                    ),
                    child: SvgPicture.asset(
                      constants.choiceImages[systemOuput]!,
                      width: 100,
                      height: 100,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    systemOuput,
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
