# Odin Score Keeper

A Flutter mobile app for tracking scores in the Odin card game from Helvetiq.

## Features

- **Quick Player Management**: Add players with a simple dialog
- **Fast Score Entry**: Tap a player to add their round score (0-9 points) with a quick number grid
- **Automatic Score Tracking**: Points are automatically summed for each player
- **Game End Detection**: Game automatically ends when any player exceeds 15 points
- **Winner Highlighting**: The player with the lowest score when the game ends is highlighted as the winner
- **New Game**: Easy reset to start a new game while keeping the same players
- **Everyone on one screen**: Up to 6 players fit a phone screen without scrolling (compact single app bar, cards share the height)
- **Remove a player mid-game**: Long-press a player card and confirm. Their earlier rounds stay in the history as "left the game". At least 2 players must remain. An "Undo" snackbar brings them back; Undo Round can't go back past a removal. On the game-over screen the player is greyed out and dropped from the next game (long-press again to keep them)
- **Statistics** (saved on the device, finished games only; players are matched by name, ignoring case):
  - End-of-game awards: 🧊 Ice Cold, 💥 Disaster Round, 🚀 Comeback, 😬 Close Call
  - Leaderboard (wins, games, win rate), win streaks (🔥 badge during play), records and 😈 nemesis on the Statistics screen (📊 on the start screen, or Stats on the game-over screen)
  - Players who leave early count as DNF: their rounds count for records, but the game doesn't count for their win rate. Ties share the win
  - Export / Import (clipboard) and Reset on the Statistics screen. On the web the stats live in the browser's localStorage, so clearing site data deletes them
- **Change players**: ⋮ menu in the game screen

## How to Use

1. **Add Players**:
   - Tap the + button to add a player
   - Enter their name and tap "Add"
   - Repeat for all players

2. **Record Scores**:
   - Tap on a player's card to add their score for the round
   - Select a number from 0-9
   - The score is automatically added to their total

3. **Game End**:
   - When any player's total exceeds 15 points, the game ends
   - The winner (player with the lowest score) is highlighted with a trophy icon
   - Players with scores over 15 are shown in red

4. **Start New Game**:
   - Tap the "New Game" button or the refresh icon in the app bar
   - All scores are reset to 0, but players remain

## Running the App

### Prerequisites
- Flutter SDK installed (version 3.0.0 or higher)
- Android Studio / Xcode for mobile emulator
- Or a physical device connected

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

Or open in your IDE (VS Code, Android Studio) and run from there.

## Project Structure

```
lib/
  ├── main.dart           # App entry point
  ├── models/
  │   └── player.dart     # Player data model
  ├── stats/
  │   ├── game_record.dart      # Saved finished game
  │   ├── stats_calculator.dart # Awards, leaderboard, streaks, records, nemesis
  │   └── stats_storage.dart    # Persistence + export/import
  └── screens/
      ├── start_screen.dart # Add players
      ├── game_screen.dart  # Main game screen
      └── stats_screen.dart # Statistics
test/                       # Unit tests (stats) and layout tests
```

Run the tests with `flutter test`.

## Game Rules (Odin by Helvetiq)

This app is designed for the Odin card game where:
- Players score points each round (0-9)
- The game ends when someone exceeds 15 points
- The player with the LOWEST total score wins

## License

This is a personal project for score tracking. Odin is a card game by Helvetiq.
