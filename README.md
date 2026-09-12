# LetterLogic

<p align="center">
  <img src="game/assets/icons/icon.png" alt="LetterLogic Mascot" width="160" height="160" />
</p>

LetterLogic is a Wordle-inspired word-guessing game built with the [Godot Engine](https://godotengine.org/) (4.x). 

What sets LetterLogic apart is its unique constraint: **all valid guesses and secret words must be 5-letter isograms** (words containing no duplicate letters). This introduces a new layer of deduction and strategy to the familiar core gameplay loop.

## Features
- **Isogram Ruleset:** Every valid 5-letter word in the game's dictionary is an isogram. The on-screen keyboard actively prevents you from typing a letter you've already used in your current guess.
- **1930s Mascot & Monochrome Visual Aesthetic:** Featuring an expressive 1930s rubber-hose cartoon tile mascot with a subtle rocking sway animation on the main menu! High-contrast charcoal buttons, rounded white borders, and sleek panels embrace a vintage black-and-white art style, reserving chromatic color strictly for gameplay evaluation cues so deduction pops with maximum impact.
- **Active Puzzle Timer:** Live running timer during gameplay with automatic app lifecycle pausing (backgrounding/minimizing) to encourage speed-solving and deduction efficiency.
- **Continuous Play:** A sandbox mode that allows you to play unlimited rounds with random words.
- **Daily Challenge:** A synchronized daily mode where everyone in the world guesses the same word based on the current UTC date.
- **Comprehensive Statistics & Connected Tabular UI:** Track your progress separately across Daily and Continuous modes using a seamless 1930s monochrome tabular layout. Monitor your total wins, win streak, personal Best Time, Average Solve Time, and guess distributions.
- **Social Sharing:** Easily share your Daily Challenge results with friends—including your completion time (⏱️) and generated emoji grid (🟩🟨🟥)—via the native Android share intent or clipboard.
- **Responsive Android Portrait Layout:** Built with Godot's adaptive `MarginContainer` and `AspectRatioContainer` architecture to scale seamlessly across diverse portrait smartphones (16:9, 18:9, 19.5:9, 20:9) and tablets (4:3, 16:10) without clipping or distortion, featuring enlarged 72px letter typography that proportionally fills expanded responsive tiles.

## Project Structure
- `/game` - The root directory for the Godot project containing all scenes, scripts, autoloads, and assets.
  - `/autoloads` - Core singletons handling game logic, stats, daily dates, and the word dictionary.
  - `/scripts` & `/scenes` - UI components (game board, keyboard, main menu).
  - `/tests` - Automated tests verifying the core logic.
- `/documents` - Project documentation, including requirements and manual testing guides.
- `/assets` - Contains the word lists and media assets.

## Getting Started
1. Clone the repository.
2. Open the Godot Editor (version 4.x recommended based on `stack.json`).
3. Import the `game/project.godot` file.
4. Press `F5` to run the project.

## Development & Testing
- Automated tests are located in the `game/tests` folder and can be run from the editor using your preferred Godot testing framework.
- For manual testing guidelines and core requirement mapping, please refer to the documentation in the `/documents` folder.

## License
This project is open-source and available under the [MIT License](LICENSE).
