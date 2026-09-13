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
- **REQ-5.4 - Mode Selector Tabular Navigation:** The mode selector on the Statistics Screen must use a connected tabular layout (`TabContainer`) presenting "Continuous Play" and "Daily Challenge" tabs. Switching tabs immediately updates all summary metrics and the guess distribution without reload delay or UI state corruption.

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
- **REQ-8.4 - Mascot Character & Application Icon:** A signature 1930s rubber-hose cartoon tile mascot in a dynamic walking pose serves as the official desktop and Android launcher application icon (`res://assets/icons/icon.png`, 512x512 PNG). The mascot features expressive pie-eyes, cartoon white gloves 🧤, a bold vintage letter "L" on its face, thick rounded white ink outlines, and a strictly monochrome palette (Ink Black `#121213` ⬛, Dark Charcoal `#1c1c1e` 🖤, and Crisp White `#ffffff` ⬜) preserving chromatic colors exclusively for deduction feedback.
- **REQ-8.5 - Animated Main Menu Mascot:** A dedicated standing mascot asset (`res://assets/icons/mascot_standing.png`, 512x512 PNG) is positioned as the centerpiece on the Main Menu directly above the `LETTERLOGIC` title box (`MascotRect`, centered `pivot_offset` at `Vector2(128, 128)`). Rather than scaling deformation, the mascot continuously plays a subtle, relaxed rocking/swaying rotation idle animation via a looping Godot `Tween` (oscillating rotation between -3.0° and +3.0° with sine easing over a 3.0-second cycle while maintaining `scale = Vector2.ONE`), pausing and cleaning up gracefully when navigating away from the Main Menu.
- **REQ-8.6 - How to Play Modal Specifications:** The How to Play instructions modal (`HowToPlayModal`) displayed from the Main Menu must be enclosed in a responsive `MarginContainer` (24px horizontal, 48px vertical margins) spanning the full viewport, ensuring all instruction content is cleanly visible without clipping while retaining vertical scroll functionality (`scroll_active = true`) for smaller displays or future content additions. All deduction cues and evaluation color indicators within the modal must strictly reflect the traffic-light color scheme (Green `#538d4e` 🟩, Yellow `#b59f3b` 🟨, and Flat Red `#b53b3b` 🟥), and special rules (5-letter isograms, active row key disabling) and game modes (Daily Challenge UTC midnight reset, Continuous Play unlimited sandbox) must be clearly explained.
- **REQ-8.7 - Responsive Android Portrait Layout & Container Hierarchy:** The user interface across all game screens, menus, and modals must dynamically adapt to diverse Android portrait display dimensions and aspect ratios (e.g., standard 16:9, tall 18:9, 19.5:9, 20:9, 21:9 smartphones, and 4:3, 16:10 portrait tablets) without element clipping, text truncation, or letterboxing distortion:
  - **Display Configuration:** Strict portrait orientation lock (`window/handheld/orientation=1`) and adaptive canvas stretch (`stretch/mode="canvas_items"`, `stretch/aspect="expand"`) with a base reference viewport of 720x1280.
  - **Game Board Grid:** Wrapped in a responsive `MarginContainer` safe-area and an `AspectRatioContainer` (5:6 aspect ratio ~0.8333) utilizing `SIZE_EXPAND_FILL`, ensuring tiles expand dynamically to available width while maintaining square tile proportions.
  - **Letter Tile Typography & Sizing:** Letter tile labels (`Label` inside `Tile`) use an enlarged font size of 72px (`theme_override_font_sizes/font_size = 72` and programmatic fallback `FONT_SIZE_DEFAULT = 72`) centered horizontally and vertically, filling expanded responsive tile boxes (approx. 100px–120px+) proportionally with clean padding from the 2px border and 4px corner radii without clipping or overflow across any supported device aspect ratio.
  - **Virtual Keyboard:** Wrapped in responsive margins with horizontal and vertical expansion flags (`SIZE_EXPAND_FILL`), allowing letter keys and weighted control keys (ENTER and ⌫) to scale cleanly across screen widths.
  - **Menus & Overlays:** Main Menu, Game Over Modal, How to Play Modal, and Statistics Screen utilize responsive `MarginContainer` padding with expanding flex containers rather than hardcoded pixel dimensions or rigid `CenterContainer` constraints.
- **REQ-8.8 - 1930s Monochrome Tabular Layout (Statistics Screen):** Mode switching on the Statistics Screen uses a connected `TabContainer` styled to match the 1930s monochrome aesthetic:
  - **Active Tab:** Matches content panel background (`#0e0e10`), 3px solid white borders (`#ffffff`) on top, left, and right, with the bottom border removed (`border_width_bottom = 0`) to merge seamlessly into the statistics content panel below. Top corners feature 12px rounded radii, with square 0px bottom corners.
  - **Inactive Tab:** Dark charcoal fill (`#1c1c1e`), 3px solid white borders (`#ffffff`) on all sides (retaining bottom boundary line separating it from the panel), 12px rounded top corners, and square 0px bottom corners.
  - **Content Panel:** Deep black fill (`#0e0e10`), 3px solid white border (`#ffffff`), and 12px corner radii, aligning cleanly with the active tab header without gaps, misalignments, or missing outlines.
- **REQ-8.9 - Main Game Vertical Hierarchy & Persistent Toast Overlay Space:** The primary gameplay screen (`main_game.tscn`) organizes its visual layout strictly inside a responsive `VBoxContainer` with mathematically constrained top-to-bottom hierarchy:
  1. Title (`LETTERLOGIC`)
  2. Game Mode Label (`DAILY CHALLENGE • YYYY-MM-DD` / `CONTINUOUS PLAY`)
  3. Active Puzzle Timer (`00:00`)
  4. Toast Popup Notification (`ToastOverlay` / `ToastPanel` / `ToastLabel`)
  5. Game Board Grid (`BoardArea` / `GameBoard`)
  6. On-Screen Virtual Keyboard (`KeyboardArea` / `Keyboard`)
  The `ToastOverlay` is integrated natively into the `VBoxContainer` directly between `Header` and `BoardArea` without hardcoded pixel offsets. To prevent UI jitter or vertical shifting of the letter grid (`GameBoard`), vertical space for `ToastOverlay` is persistently reserved in the layout hierarchy (maintaining `visible = true`). When inactive, it is rendered fully transparent (`modulate.a = 0.0`). When activated, it smoothly transitions in via alpha modulation, rendering horizontally centered within the reserved vertical gap between the header timer and letter grid without shifting, obscuring, clipping, or overlapping adjacent UI elements across any screen dimensions or aspect ratios.
- **REQ-8.10 - Header Statistics Button & Monochrome Icon:** The statistics button (`StatsButton`) in the top-right corner of the main game header uses a custom monochrome bar graph icon texture (`res://assets/icons/stats_icon.png`) with an empty text string, replacing the default emoji (`📊`). The icon depicts four solid white vertical bars and a horizontal baseline underline in 100% solid white (`#ffffff` / `Color(1, 1, 1, 1)`) on a transparent background (`rgba(0, 0, 0, 0)`), completely free of black ink outlines or double-outline artifacts to maximize legibility and visual contrast against the dark charcoal button background (`#1c1c1e` normal / `#2c2c30` hover). The icon is centered (`icon_alignment = 1`) and expanded (`expand_icon = true`), scaling cleanly without distortion. To provide optimal touch ergonomics and padding on mobile displays, `StatsButton` and `BackButton` both feature an enlarged minimum size of `Vector2(56, 56)` within a 56px height header (`VBoxContainer/Header`), preserving visual symmetry and alignment across the top navigation bar.
