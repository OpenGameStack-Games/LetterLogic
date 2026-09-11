# LetterLogic Requirements

## 1. Overview
LetterLogic is a word-guessing game inspired by Wordle, built using the Godot Engine. The unique twist in LetterLogic is that all valid words and secret target words are **5-letter isograms** (words containing no repeating letters).

## 2. Core Gameplay
- **REQ-2.1 - Grid Size:** The game board consists of a 6-row by 5-column grid. Players have a maximum of 6 attempts to guess the 5-letter secret word.
- **REQ-2.2 - Tile Evaluation:** After a valid guess is submitted, each letter tile is evaluated and colored based on its presence in the secret word:
  - **Correct (Green / 🟩):** The letter is in the secret word and in the correct position.
  - **Present (Yellow / 🟨):** The letter is in the secret word but in the wrong position.
  - **Absent (Flat Red / 🟥):** The letter is not in the secret word.
- **REQ-2.3 - Win/Loss Condition:** The game is won if the player guesses the secret word exactly within 6 attempts. The game is lost if the 6th attempt is incorrect.
- **REQ-2.4 - Keyboard State Update:** The on-screen virtual keyboard must update its keys to reflect the best-known state of each letter (Correct > Present > Absent) based on all submitted guesses. Absent keys display in flat red (`#b53b3b`) with white text (`#ffffff`).
- **REQ-2.5 - Active Gameplay Timer:** An active running timer is displayed in the game header directly above the grid during gameplay. The timer starts at `00:00` upon puzzle start, increments dynamically while solving, and stops immediately upon game completion (win or loss). Time is formatted as `MM:SS` (or `HH:MM:SS` if the puzzle duration exceeds 1 hour).
- **REQ-2.6 - App Lifecycle & Overlay Timer Pausing:** The active gameplay timer must automatically pause when the application loses focus, is minimized, or is sent to the background (`NOTIFICATION_APPLICATION_FOCUS_OUT`, `NOTIFICATION_APPLICATION_PAUSED`), and automatically resume when primary focus returns (`NOTIFICATION_APPLICATION_FOCUS_IN`, `NOTIFICATION_APPLICATION_RESUMED`). Furthermore, modal dialogs and full-screen overlays (such as the Statistics Screen or Game Over modal) must pause the timer while visible, resuming only once dismissed if the game remains in progress.

## 3. Input & Validation
- **REQ-3.1 - Isogram Typing Constraint:** While typing a guess, the game must prevent the user from inputting a letter that already exists in the current active row. Keys currently typed in the active row are temporarily disabled and visually styled in dark gray (`#272729`), maintaining clear differentiation from absent letters (flat red / `#b53b3b`).

- **REQ-3.2 - Dictionary Validation:** The game must reject guesses that are not present in the internal dictionary of 5-letter isograms. A rejected guess does not consume an attempt.
- **REQ-3.3 - Length Validation:** The game must reject guesses that are shorter than 5 letters.

## 4. Game Modes
- **REQ-4.1 - Continuous Play:** A sandbox mode where players can play unlimited consecutive games. Secret words are selected randomly from the word bank. The game screen header displays `CONTINUOUS PLAY`.
- **REQ-4.2 - Daily Challenge:** A synchronized daily mode where all players attempt to guess the same deterministic secret word, based on the current UTC date. The game screen header displays `DAILY CHALLENGE • YYYY-MM-DD` reflecting the current UTC date.
- **REQ-4.3 - Daily Lockout:** A player can only complete the Daily Challenge once per UTC day. A countdown timer should indicate when the next challenge unlocks.

## 5. Statistics Tracking
- **REQ-5.1 - Segregated Stats:** The game must track statistics separately for "Continuous Play" and "Daily Challenge" modes.
- **REQ-5.2 - Tracked Metrics:** The game must record total games played, total games won, current win streak, maximum win streak, best solve time (fastest win), average solve time, and a distribution of guess attempts (1 through 6, and losses).
- **REQ-5.3 - Average and Best Solve Time Rules:** Best and Average Solve Times must be tracked and displayed separately per mode on the statistics screen. Average solve time is strictly calculated across won games (losses are excluded from solve time calculations). If no games have been won in a mode, best and average times are displayed as `--:--`.

## 6. Sharing
- **REQ-6.1 - Result Generation:** Upon completing a Daily Challenge, the game must generate a shareable text block containing the header (game title, UTC date, score/attempts), a dedicated timer line with the stopwatch emoji (`⏱️ MM:SS` or `⏱️ HH:MM:SS`), an emoji grid representing the game board, and a link to the game on the Google Play Store.
- **REQ-6.2 - Clipboard/Native Share:** The generated text must be copied to the system clipboard and, on Android, trigger the native share intent.

## 7. Saving and Data Persistence
- **REQ-7.1 - Persistence:** The game must save player statistics and daily challenge records locally to the device so they persist between sessions.

## 8. User Interface & Visual Design
- **REQ-8.1 - 1930s Monochrome UI Aesthetic:** Menus, modals, and UI containers follow a 1930s vintage monochrome animation visual language using high-contrast black, charcoal, and crisp white outlines. Chromatic color is strictly reserved for gameplay deduction evaluation cues (Green `#538d4e` 🟩, Yellow `#b59f3b` 🟨, and Flat Red `#b53b3b` 🟥).
- **REQ-8.2 - Button Styling & Interaction States:** Standard buttons throughout the application must feature:
  - **Normal State:** Dark charcoal fill (`#1c1c1e`), 2px solid white border (`#ffffff`), 8px rounded corners, and crisp white text (`#ffffff`).
  - **Hover/Focused State:** Brightened charcoal fill (`#2c2c30`) with a 2px solid white border.
  - **Pressed State:** Deep black fill (`#0e0e10`) with a 2px solid white border for tactile feedback.
- **REQ-8.3 - Centralized UI Theme System:** Project UI styling must be managed via a centralized Godot theme resource (`res://assets/theme/letter_logic_theme.tres`) configured as the project-wide custom GUI theme. Panel containers feature a deep black fill (`#0e0e10`), 3px solid white border (`#ffffff`), and 12px corner radii, ensuring consistent presentation across all menus, dialogs, and modals.
- **REQ-8.4 - Mascot Character & Application Icon:** A signature 1930s rubber-hose cartoon tile mascot serves as the official desktop and Android launcher application icon (`res://assets/icons/icon.png`, 512x512 PNG). The mascot features expressive pie-eyes, cartoon white gloves 🧤, a bold vintage letter "L" on its face, thick rounded white ink outlines, and a strictly monochrome palette (Ink Black `#121213` ⬛, Dark Charcoal `#1c1c1e` 🖤, and Crisp White `#ffffff` ⬜) preserving chromatic colors exclusively for deduction feedback.
- **REQ-8.5 - Animated Main Menu Mascot:** The mascot is positioned as the centerpiece on the Main Menu directly above the `LETTERLOGIC` title box. The mascot continuously plays a smooth rubber-hose "breathing" animation via a looping Godot `Tween` (gentle squash-and-stretch cycle oscillating scale between 0.97 and 1.03 with a centered pivot and sine easing over 2.0 seconds), pausing and cleaning up gracefully when navigating away from the Main Menu.
- **REQ-8.6 - How to Play Modal Specifications:** The How to Play instructions modal (`HowToPlayModal`) displayed from the Main Menu must feature a container height of at least 600px (`custom_minimum_size = Vector2(460, 600)`) centered on the viewport (`offset_top = -300.0`, `offset_bottom = 300.0`, `offset_left = -230.0`, `offset_right = 230.0`), ensuring all instruction content is visible without scrolling at the standard 720x1280 portrait resolution while retaining vertical scroll functionality (`scroll_active = true`) for smaller displays or future content additions. All deduction cues and evaluation color indicators within the modal must strictly reflect the traffic-light color scheme (Green `#538d4e` 🟩, Yellow `#b59f3b` 🟨, and Flat Red `#b53b3b` 🟥), and special rules (5-letter isograms, active row key disabling) and game modes (Daily Challenge UTC midnight reset, Continuous Play unlimited sandbox) must be clearly explained.

