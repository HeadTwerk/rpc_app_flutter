// place to store constants values used in the app

const appTitle = 'Rock Paper Scissors';
const welcomeMessage = 'Have Fun!';
const descriptionMessage =
    'This is a simple Rock Paper Scissors game built with Flutter. Use the drawer to navigate through the app features.';

const gestureOutputMap = {
  'Victory': 'Scissors',
  'Open_Palm': 'Paper',
  'Closed_Fist': 'Rock',
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

// Persistence keys & collection constants for local game stats
const statsCollection = 'game_stats';
const statsDocId = 'rps';
const statsFieldWins = 'wins';
const statsFieldLosses = 'losses';

// UI labels for stats display
const statsTitle = 'Your Stats';
const winsLabel = 'Wins';
const lossesLabel = 'Losses';
