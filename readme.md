# Odin Score Keeper

A Flutter app for tracking scores of card games. Pick the game on the start screen:

- **Odin** (Helvetiq): round-by-round scores, lowest total wins. Details below.
- **Forest Shuffle**: scored once at the end. Each player takes a photo of their forest; a card detector finds the cards and the app calculates the points. Wrong or missing cards can be fixed by hand, and the cards in the cave are counted with a +/- stepper. Highest total wins (ties share the win). The game is saved after every change, and statistics are kept per game.

### Forest Shuffle card detection

The detector and the scoring rules come from [ForestDetector](https://github.com/NINI1988/ForestDetector) (MIT), which uses the card rules of [glaures/forestshuffle](https://github.com/glaures/forestshuffle) (Apache 2.0). Both were translated to Dart in `lib/games/forest_shuffle/engine/` (see `THIRD_PARTY_NOTICES.md` there). The YOLO model (`assets/models/forest_shuffle_cards.onnx`, 38 MB) runs on the device with [flutter_onnxruntime](https://pub.dev/packages/flutter_onnxruntime). On the web, ONNX Runtime Web (CPU-only build) is loaded from jsDelivr in `web/index.html` and called directly through `dart:js_interop` (`detector/onnx_model_web.dart`), because the plugin's web implementation copies tensors element by element, which made iPhone browsers kill the tab. iOS needs iOS 16 or later.

The model's metadata states it is licensed AGPL-3.0, because it was trained with Ultralytics.

## Odin features

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
- **Crash-safe**: The current game (players, scores, round, undo history) is saved after every change and resumed when the app is reopened. Going back to setup ("New players") discards it

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

## Deploying to Netlify

The app is deployed as a Flutter web build. [netlify.toml](netlify.toml) publishes `build/web` and rewrites all routes to `index.html`. Netlify's build servers don't have Flutter installed, so build locally and upload the result.

### One-time setup

```bash
npm install -g netlify-cli
netlify login
netlify init   # or `netlify link` if the site already exists
```

### Deploy

```bash
flutter build web --release
netlify deploy --dir=build/web            # draft deploy, gives a preview URL
netlify deploy --dir=build/web --prod     # production
```

Without the CLI, you can also drag the `build/web` folder onto the site's **Deploys** page at app.netlify.com.

Note: stats are stored in the browser's localStorage per domain, so a new Netlify URL starts with empty stats.

## Project Structure

```
lib/
  ├── main.dart           # App entry point
  ├── games/
  │   ├── game_type.dart  # The games (id, name, lowest/highest wins)
  │   ├── games.dart      # Game type -> screens and records
  │   ├── odin/           # Odin game screen, saved state, awards, records
  │   └── forest_shuffle/ # Forest Shuffle screens, detector, scoring engine
  ├── models/
  │   └── player.dart     # Player data model
  ├── stats/
  │   ├── game_record.dart      # Saved finished game
  │   ├── stats_calculator.dart # Awards, leaderboard, streaks, records, nemesis
  │   └── stats_storage.dart    # Persistence + export/import
  └── screens/
      ├── start_screen.dart # Pick the game, add players
      └── stats_screen.dart # Statistics per game
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
