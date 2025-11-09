// place to store constants values used in the app

const appTitle = 'Rock Paper Scissors';
const welcomeMessage = 'Have Fun!';
const descriptionMessage =
    'This is a simple Rock Paper Scissors game built with Flutter. Use the drawer to navigate through the app features.';

const gestureOutputMap = {
  'Victory': 'Scissors',
  'Open_Palm': 'Paper',
  'Closed_Fist': 'Rock',
  'Pointing_Up': 'Rock',
};

const systemChoices = ['Rock', 'Paper', 'Scissors'];

const winningConditions = {
  'Rock': 'Scissors', // Rock crushes Scissors
  'Paper': 'Rock', // Paper covers Rock
  'Scissors': 'Paper', // Scissors cut Paper
};

const choiceImages = {
  'Rock': 'lib/assets/stone.svg',
  'Paper': 'lib/assets/paper.svg',
  'Scissors': 'lib/assets/scissors1.svg',
};

const resultMessages = {
  'win': 'You Win!',
  'lose': 'You Lose!',
  'draw': 'Draw!',
};
