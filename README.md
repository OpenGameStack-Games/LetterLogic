# LetterLogic

<p align="center">
  <img src="game/assets/icons/icon.png" alt="LetterLogic Mascot" width="160" height="160" />
</p>

LetterLogic is a Wordle-inspired word-guessing game built with the [Godot Engine](https://godotengine.org/) (v4.7.2). 

What sets LetterLogic apart is its unique constraint: **all valid guesses and secret words must be 5-letter isograms** (words containing no duplicate letters). This introduces a new layer of deduction and strategy to the familiar core gameplay loop.

## Features
- **Isogram Ruleset:** Every valid 5-letter word in the game's dictionary is an isogram. The on-screen keyboard actively prevents you from typing a letter you've already used in your current guess.
- **Staggered Reveal Animation & Visual Juice:** Submitting a valid guess reveals tile evaluation states sequentially from left to right with an incremental 0.3s delay per tile. Each tile executes a centered scale pop animation without disrupting parent grid layout calculations, delivering tactile, responsive visual feedback.
- **1930s Mascot, Android Adaptive Icons & Monochrome Visual Aesthetic:** Launches with a custom boot splash screen featuring our signature 1930s walking cartoon tile mascot over a matching dark monochrome background (`#121212`), completely free of engine branding or text. Modern Android devices feature native Android Adaptive Icon support with separate foreground and background layers (432x432) for crisp launcher presentation and dynamic masking across all device themes. The main menu proudly displays our signature static walking mascot. High-contrast charcoal buttons, rounded white borders, and sleek panels embrace a vintage black-and-white art style, reserving chromatic color strictly for gameplay evaluation cues so deduction pops with maximum impact.
- **Active Puzzle Timer:** Live running timer during gameplay with automatic app lifecycle pausing (backgrounding/minimizing) to encourage speed-solving and deduction efficiency, prominently displayed alongside your guess count on the Game Over win screen.
- **Continuous Play:** A sandbox mode that allows you to play unlimited rounds with random words.
- **In-Progress Game Persistence & Auto-Save:** Never lose puzzle progress mid-game. Navigating back to the Main Menu, switching apps, or closing the application automatically saves your exact session state—including board tiles, evaluated colors, current typed letters, keyboard states, and elapsed play time. Returning to Continuous Play or Daily Challenge seamlessly restores your board and timer, preventing resets until the puzzle is completed.
- **Daily Challenge & Solved Puzzle Review:** A synchronized daily mode where everyone in the world guesses the same word based on the current UTC date. Puzzles lock out upon completion to preserve stats integrity, with an active live countdown to the next UTC release, while allowing players to safely re-open and review their completed board, solve time, and share their results anytime.
- **Comprehensive Statistics & Connected Tabular UI:** Track your progress separately across Daily and Continuous modes using a seamless 1930s monochrome tabular layout with an opaque full-screen dark background (`#121212`) that completely obscures underlying screens. Features doubled typography (52px title, 32px close button, 32px tabs), an intuitive 3-column multi-row summary layout vertically pairing volume with win rate, peak with active streaks, and best with average times (with enlarged 36px metric values and 18px labels), and expanded 48px-tall guess distribution bars with 24px row indicators and 22px counts. Monitor your total wins, win streak, personal Best Time, Average Solve Time, and guess distributions.
- **Social Sharing:** Easily share your Daily Challenge results with friends—including your completion time (⏱️) and generated emoji grid (🟩🟨🟥)—via the native Android share intent or clipboard.
- **Studio Attributions & Refined Credits Modal:** Dedicated 1930s monochrome Credits screen accessible from the Main Menu, honoring project creators and the open-source community with generous modal margins, expanded vertical row spacing, 50% larger circular badge logos (144x144), and left-aligned text and clickable web icon links for Open Game Stack, Audrain Entertainment, and the GitHub repository.
- **Responsive Android Portrait Layout & Scaled Typography:** Built with Godot's adaptive `MarginContainer` and `AspectRatioContainer` architecture to scale seamlessly across diverse portrait smartphones (16:9, 18:9, 19.5:9, 20:9) and tablets (4:3, 16:10) without clipping or distortion. The Main Game now uses a safe-area-aware vertical flow with an aspect-ratio board slot and a flexible keyboard that keeps a 44px minimum touch-height floor while remaining fully contained on tall portrait screens. Features doubled Main Menu typography (88px title, 36px subtitle) with expanded navigation button targets (120px / 80px heights with 40px / 36px fonts for mode and utility buttons including Stats, How to Play, and Credits), scaled How to Play and Credits modal typography (84px and 64px titles, calibrated body/attributions) with enlarged 80px "Got It" buttons (36px font), scaled Game Over modal typography (56px title, 32px summary message, 32px button text) with doubled-height action buttons (96px) inset from panel edges (64px margins) for comfortable mobile touch ergonomics, enlarged 72px letter tiles, responsive virtual keyboard tap targets with scalable typography for confident typing, doubled center header typography (48px title, 28px mode subtitle, 32px active timer), 36px toast notifications with comfortable outline padding, and an enlarged Statistics modal with an opaque full-screen dark background completely obscuring underlying screens, intuitively paired multi-row summary cards, and expanded distribution graph sizing for effortless readability on mobile displays.

## Project Structure
- `/game` - The root directory for the Godot project containing all scenes, scripts, autoloads, and assets.
  - `/autoloads` - Core singletons handling game logic, stats, daily dates, and the word dictionary.
  - `/scripts` & `/scenes` - UI components (game board, keyboard, main menu).
  - `/tests` - Automated tests verifying the core logic.
- `/documents` - Project documentation, including requirements and manual testing guides.
- `/assets` - Contains the word lists and media assets.

## Getting Started
1. Clone the repository.
2. Open the Godot Editor (v4.7.2 — matches `stack.json`).
3. Import the `game/project.godot` file.
4. Press `F5` to run the project.

## Development & Testing
- Automated tests are located in the `game/tests` folder and can be run from the editor using your preferred Godot testing framework.
- For manual testing guidelines and core requirement mapping, please refer to the documentation in the `/documents` folder.

## License
This project is open-source and available under the [MIT License](LICENSE).
