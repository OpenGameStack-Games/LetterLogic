# LetterLogic Manual Testing Guide

This document outlines the manual test cases used to verify the requirements outlined in `requirements.md`. Testing should be performed both within the Godot Editor and on the target deployment platform (e.g., Android device).

## Test Environment Setup
- **Godot Testing:** Run the game directly from Godot via `F5` (Play Project).
- **Target Platform (Android):** Export an APK via Godot's export menu and install it on an Android device or emulator.

---

## 1. Core Gameplay & Input Constraints

### Test 1.1: Isogram Typing Restriction & Key Disabling
- **Requirement(s):** REQ-3.1
- **Steps:**
  1. Start a Continuous Play game.
  2. Tap the letter 'A' on the on-screen keyboard.
  3. Observe the 'A' key styling on the virtual keyboard.
  4. Attempt to tap the letter 'A' again or press 'A' on the physical keyboard.
- **Expected Result:** The 'A' key on the keyboard is temporarily disabled and styled in dark gray (`#272729`). The second 'A' does not appear in the grid. The game prevents duplicate letters in the current row.

### Test 1.2: Dictionary, Length Validation & Toast Popup Layout
- **Requirement(s):** REQ-3.2, REQ-3.3, REQ-8.9
- **Steps:**
  1. Start a game in either Continuous Play or Daily Challenge mode.
  2. Note the vertical position of the letter grid (`GameBoard`) and the running puzzle timer in the header directly below the game mode label.
  3. Type 4 letters (e.g., "ABCD") and submit. Verify it is rejected (needs 5 letters).
  4. Type 5 letters of an invalid word (e.g., "QWERT") and submit. 
  5. Observe the presentation and fade-in of the "Not in word list" toast popup and verify the letter grid position.
  6. Inspect the toast notification typography and outline container padding:
     - Verify the toast notification font size is prominently enlarged (36px).
     - Verify the text has comfortable horizontal padding (24px) away from the 12px rounded borders of the outline container (`ToastPanel`), ensuring the first and last characters do not crowd or clip against the curved corners.
  7. Wait ~1.8 seconds for the toast notification to fade out and dismiss.
- **Expected Result:** The toast notification appears cleanly in the vertical gap directly between the active puzzle timer and the top row of the letter grid. The toast text renders prominently at 36px font size with generous horizontal padding (24px left/right, 8px top/bottom) inside the rounded outline box. The toast does not obscure or overlap the header, back button, timer, or game board tiles. Because vertical space is persistently reserved for the toast overlay in the layout hierarchy, the letter grid (`GameBoard`) remains completely stationary with zero downward shift or jitter when the toast appears, and zero upward jump when it dismisses. The row does not advance, and the attempt is not consumed. The toast dismisses smoothly via fade out after ~1.8 seconds.

### Test 1.3: Guess Evaluation and Keyboard Colors
- **Requirement(s):** REQ-2.2, REQ-2.4
- **Steps:**
  1. (Godot Editor only) Use the debugger or print statements to determine the current `secret_word`.
  2. Input a valid 5-letter isogram that contains at least one correct letter in the right spot, one correct letter in the wrong spot, and some letters not in the word.
  3. Submit the guess.
- **Expected Result:** The tiles in the grid update to Green (`#538d4e`), Yellow (`#b59f3b`), and Flat Red (`#b53b3b`) correctly. The on-screen keyboard keys update to match the highest state of each guessed letter (Absent keys appear in Flat Red with white text).


### Test 1.4: Win/Loss Conditions
- **Requirement(s):** REQ-2.3
- **Steps:**
  1. Play a game and deliberately submit 6 incorrect valid words.
  2. Verify the loss screen appears showing the correct secret word.
  3. Play another game and submit the exact secret word.
  4. Verify the win screen appears.

### Test 1.5: Active Gameplay Timer & State Freezing
- **Requirement(s):** REQ-2.5
- **Steps:**
  1. Start a game in either Continuous Play or Daily Challenge.
  2. Verify the timer label appears in the header directly above the puzzle grid, starting at `00:00`.
  3. Wait 5-10 seconds and observe that the timer increments accurately in seconds (`MM:SS`).
  4. Solve or lose the puzzle.
- **Expected Result:** The timer starts immediately at `00:00`, counts up in real time, and freezes instantaneously when the game ends in a win or loss.

### Test 1.6: App-Switching & Modal Timer Pause / Resume
- **Requirement(s):** REQ-2.6
- **Steps:**
  1. Start a game and allow the timer to reach ~`00:05`.
  2. Tap the Statistics icon button in the header (solid white bar graph icon) to open the Stats Screen overlay.
  3. Wait 5 seconds.
  4. Close the Stats Screen modal.
  5. Check whether the timer elapsed during the modal.
  6. Minimize the game window or switch to another app / browser window for 5 seconds.
  7. Return focus to the game.
- **Expected Result:** The timer stops advancing while the Stats modal is open and resumes when the modal is closed. Similarly, losing application focus or sending the app to the background pauses the timer, resuming only upon refocusing the active puzzle.

---

## 2. Game Modes

### Test 2.1: Continuous Play Reset
- **Requirement(s):** REQ-4.1
- **Steps:**
  1. Start a Continuous Play game.
  2. Complete the game (win or lose).
  3. Select the option to play again.
- **Expected Result:** The board resets immediately, a new random word is chosen, and the timer resets to `00:00`.

### Test 2.2: Daily Challenge Synchronization & Lockout
- **Requirement(s):** REQ-4.2, REQ-4.3
- **Steps:**
  1. Start a Daily Challenge game.
  2. Note the target word.
  3. Complete the Daily Challenge (win or lose).
  4. Return to the main menu and attempt to play the Daily Challenge again.
  5. (Optional) Change the device date to tomorrow and verify the Daily Challenge unlocks with a new word.
- **Expected Result:** After completion, the player is locked out of the Daily Challenge until the next UTC midnight. The menu shows a countdown timer.

### Test 2.3: Mode Header Title Display
- **Requirement(s):** REQ-4.1, REQ-4.2
- **Steps:**
  1. From the Main Menu, tap "Daily Challenge".
  2. Observe the header text above the board.
  3. Return to the Main Menu and tap "Continuous Play".
  4. Observe the header text above the board.
- **Expected Result:** When entering Daily Challenge, the header displays `DAILY CHALLENGE • YYYY-MM-DD` with today's UTC date. When entering Continuous Play, the header displays `CONTINUOUS PLAY`.

---


## 3. Statistics and Persistence

### Test 3.1: Stats Segregation & Solve Time Tracking
- **Requirement(s):** REQ-5.1, REQ-5.2, REQ-5.3
- **Steps:**
  1. Open the Stats Screen on a fresh profile; confirm Best Time and Avg Time show `--:--`.
  2. Win a Continuous Play game in 40 seconds. Open Stats; confirm Continuous Best Time and Avg Time both show `00:40`.
  3. Win a second Continuous Play game in 20 seconds. Confirm Best Time updates to `00:20` and Avg Time updates to `00:30`.
  4. Play a third Continuous Play game and deliberately lose after 1 minute. Confirm Best Time remains `00:20` and Avg Time remains `00:30` (losses must NOT affect average solve time).
  5. Switch to the Daily Challenge tab in the Stats Screen; confirm Daily stats show `--:--` for Best Time and Avg Time, completely isolated from Continuous Play.

### Test 3.2: Save State & Time Stats Persistence
- **Requirement(s):** REQ-5.2, REQ-7.1
- **Steps:**
  1. Complete games to record valid Best Time and Avg Time statistics.
  2. Complete today's Daily Challenge.
  3. Close the application entirely.
  4. Reopen the application.
  5. Open the Statistics Screen and inspect both "Continuous Play" and "Daily Challenge" tabs.
- **Expected Result:** All summary cards (Played, Win %, Current Streak, Max Streak, Best Time, Avg Time) and guess distributions retain their exact values. Played games, Current Streak, and Max Streak values display strictly as whole integers without decimal points (e.g., `1`, `2`, `0` instead of `1.0`, `2.0`, `0.0`). The Daily Challenge remains locked out with an accurate countdown timer.

### Test 3.3: Statistics Screen Connected Tabular Layout & Mode Switching
- **Requirement(s):** REQ-5.2, REQ-5.4, REQ-8.8
- **Steps:**
  1. Open the Statistics Screen from the Main Menu or Game Over modal.
  2. Observe the mode selector tabs ("Continuous Play" and "Daily Challenge").
  3. Verify the active tab styling: deep black fill (`#0e0e10`), 3px solid white borders on top, left, and right, and no bottom border dividing line separating the tab from the statistics content panel.
  4. Verify the inactive tab styling: dark charcoal fill (`#1c1c1e`), 3px solid white border around all sides, clearly separating it from the content panel below.
  5. Verify that Played, Current Streak, and Max Streak summary cards display clean whole numbers without decimal points.
  6. Tap the inactive tab ("Daily Challenge").
  7. Observe the visual transition and data displayed, confirming streak and played values are formatted as integers without decimal points.
  8. Tap "Continuous Play" to switch back.
- **Expected Result:**
  - The active tab connects seamlessly to the content panel with no bottom border line.
  - The inactive tab maintains a distinct 3px white outline on all sides and dark charcoal background.
  - Tapping between tabs transitions mode data smoothly with no disappearing borders, flickering, or layout shift.
  - All summary cards (Played, Win %, Current Streak, Max Streak, Best Time, Avg Time) and guess distribution rows update immediately to reflect the selected mode.
  - Played, Current Streak, and Max Streak summary cards consistently display as integers without decimal points across both tabs.

---

## 4. Social Sharing

### Test 4.1: Native Share intent (Android)
- **Requirement(s):** REQ-6.1, REQ-6.2
- **Steps (Android device required):**
  1. Complete a Daily Challenge in win or loss state.
  2. Tap the "Share" button on the game over screen.
- **Expected Result:** The Android native share sheet appears. Pasting the shared text into any recipient app reveals the date and score, followed by the dedicated timer line `⏱️ MM:SS`, the guess emoji grid (🟩🟨🟥), and the Google Play Store link.

### Test 4.2: Clipboard Fallback (Godot PC)
- **Requirement(s):** REQ-6.1, REQ-6.2
- **Steps:**
  1. Run the project in the Godot Editor on a PC.
  2. Complete a Daily Challenge and tap "Share".
  3. Open Notepad and press `Ctrl+V`.
- **Expected Result:** The clipboard contains the full share format including the timer line:
  ```text
  LetterLogic YYYY-MM-DD 3/6
  ⏱️ 01:45

  🟩🟨🟥...
  Play now: https://play.google.com/store/apps/details?id=com.opengamestack.letterlogic
  ```

---

## 5. UI Theme & Visual Styling

### Test 5.1: 1930s Monochrome Button Theme & Interaction States
- **Requirement(s):** REQ-8.1, REQ-8.2
- **Steps:**
  1. Launch the game to the Main Menu.
  2. Observe the styling of all navigation buttons ("Daily Challenge", "Continuous Play", "Statistics", "How to Play").
  3. Verify the buttons have a dark charcoal fill (`#1c1c1e`), crisp 2px white borders (`#ffffff`), 8px rounded corners, and bold white text.
  4. Hover the mouse cursor over each button (or observe initial touch highlight).
  5. Verify the background brightens slightly to `#2c2c30` while maintaining the prominent white border.
  6. Press and hold down a button without releasing.
  7. Verify the background darkens to deep black (`#0e0e10`).
- **Expected Result:** Buttons display high-contrast 1930s monochrome styling with smooth, tactile interaction transitions for normal, hover, and pressed states.

### Test 5.2: Modal & Dialog Theme Consistency
- **Requirement(s):** REQ-8.1, REQ-8.3
- **Steps:**
  1. From the Main Menu, tap "How to Play" to open the instructions modal.
  2. Observe the modal panel container and action button ("Got It!").
  3. Close the modal, start a Continuous Play game, and complete the puzzle (win or lose).
  4. Observe the Game Over modal panel container and action buttons ("Next Word", "Main Menu", "Share").
  5. Verify panel containers feature deep black fill with 3px solid white borders and 12px rounded corners.
  6. Verify all action buttons adhere strictly to the 1930s monochrome button styling and interaction states.
  7. Verify that no chromatic colors appear on buttons or panels—chromatic colors remain strictly reserved for the letter evaluation tiles (🟩, 🟨, 🟥).
- **Expected Result:** All modals, panels, and buttons across the entire application exhibit uniform 1930s monochrome styling inherited from the centralized project GUI theme.

### Test 5.3: Main Menu Mascot & Swaying Rotation Animation
- **Requirement(s):** REQ-8.4, REQ-8.5
- **Steps:**
  1. Launch the game to the Main Menu.
  2. Observe the cartoon mascot situated directly above the `LETTERLOGIC` title box.
  3. Verify the mascot displays classic 1930s rubber-hose cartoon styling: anthropomorphic tile standing upright facing the camera directly in a neutral idle stance, with pie-eyes, cartoon white gloves, letter "L" on chest, and rounded white ink outlines in monochrome (`res://assets/icons/mascot_standing.png`).
  4. Watch the mascot for several seconds without interacting.
  5. Verify the mascot plays a smooth, continuous subtle rocking/swaying rotation loop (gently swaying between -3.0° and +3.0° over a 3.0-second cycle) centered evenly on its pivot (`Vector2(128, 128)`) while maintaining fixed scale (`Vector2.ONE`) without scaling deformation, jitter, or translational drift.
  6. Navigate to Continuous Play, Daily Challenge, or open the How to Play modal, then return to the Main Menu.
  7. Verify the swaying animation resumes smoothly upon returning without stutter or memory leaks.
- **Expected Result:** The mascot displays a standing neutral pose and animates smoothly with subtle rocking/swaying rotation and clean scene transitions.

### Test 5.4: Application Launcher Icon
- **Requirement(s):** REQ-8.4
- **Steps:**
  1. Inspect the desktop window titlebar/taskbar (or export and install APK on an Android device/emulator).
  2. Look at the application launcher icon on the Android home screen or desktop taskbar.
  3. Verify the icon renders crisp and clear at 512x512 resolution without clipping, distortion, or chromatic artifacts.
- **Expected Result:** The 1930s rubber-hose mascot icon is displayed cleanly as the application launcher icon.

### Test 5.5: How to Play Modal Responsive Layout & Red Absent Tile Color Copy
- **Requirement(s):** REQ-8.1, REQ-8.3, REQ-8.6
- **Steps:**
  1. Launch the game to the Main Menu.
  2. Tap the "How to Play" button to open the instructions modal.
  3. Verify the modal panel container is wrapped in a responsive `MarginContainer` (24px horizontal, 48px vertical margins) spanning the viewport rather than hardcoded fixed pixel offsets.
  4. Verify that all instructions and text content fit comfortably within the modal without requiring vertical scrolling at the standard 720x1280 portrait resolution.
  5. Check the tile color evaluation cues:
     - Correct is displayed as `🟩 GREEN` (`#538d4e`) - "Letter is in the word and in the correct spot."
     - Present is displayed as `🟨 YELLOW` (`#b59f3b`) - "Letter is in the word but wrong spot."
     - Absent is displayed as `🟥 RED` (`#b53b3b`) - "Letter is not in the word." (confirm it is NOT gray `⬛ GRAY` or `#808080`).
  6. Verify the special rule states that words never contain duplicate letters (5-letter isograms) and that keys typed in the current row are temporarily disabled.
  7. Verify game modes (Daily Challenge with UTC midnight reset, Continuous Play unlimited sandbox) are clearly described.
  8. If tested on smaller displays or with enlarged system font scaling, verify the `RichTextLabel` vertical scrollbar engages cleanly (`scroll_active = true`).
  9. Tap "Got It!" and verify the modal dismisses smoothly and returns focus to the Main Menu.
- **Expected Result:** The modal opens adaptively within responsive margins with all text fully legible without scrolling at standard resolution, displays flat red (`🟥 RED` / `#b53b3b`) for absent tiles, and dismisses cleanly.

### Test 5.6: Responsive UI Scaling Across Android Portrait Aspect Ratios
- **Requirement(s):** REQ-8.7
- **Steps:**
  1. Launch the game in the Godot Editor or on an Android device / emulator.
  2. Test or simulate diverse portrait screen resolutions across different device form factors:
     - **16:9 Standard Portrait:** 720x1280 or 1080x1920
     - **Tall Smartphones (19.5:9 / 20:9):** 1080x2340 or 1080x2400
     - **Extra Tall Display (21:9):** 1080x2520
     - **Portrait Tablets (4:3 / 16:10):** 1536x2048, 768x1024, or 1200x1920
  3. On each aspect ratio, evaluate the Main Menu:
     - Verify the mascot, title box, and navigation buttons scale dynamically within safe margin padding without crowding screen borders or overflowing.
  4. Enter a game (Continuous Play or Daily Challenge):
     - **Game Board:** Confirm the 5-column by 6-row grid preserves its 5:6 aspect ratio and square tiles via `AspectRatioContainer`, dynamically expanding across the available width while observing safe margins.
     - **Virtual Keyboard:** Confirm letter keys stretch dynamically across the display width (`SIZE_EXPAND_FILL`), and control keys (`ENTER` and `⌫`) maintain weighted proportion (~1.4x-1.5x) without text clipping or overlapping adjacent keys.
     - **Header Bar:** Verify the back button, game mode title, timer label, and statistics button stay neatly aligned across the top row.
  5. Open dialog overlays (How to Play modal, Stats Screen, and Game Over modal):
     - Confirm dialog panels scale responsively within their `MarginContainer` boundaries without overflowing off-screen or truncating buttons.
- **Expected Result:** All UI elements dynamically scale and maintain proportional sizing across phones and tablets, avoiding letterbox bars, clipping, or overlapping controls.

### Test 5.7: Header Statistics Button & Solid White Monochrome Bar Graph Icon
- **Requirement(s):** REQ-8.1, REQ-8.2, REQ-8.10
- **Steps:**
  1. Start a game in either Continuous Play or Daily Challenge mode.
  2. Observe the statistics button located in the top-right corner of the header (`StatsButton`).
  3. Verify that the button does NOT display a colorful unicode emoji (`📊`).
  4. Verify that the button displays the custom monochrome bar graph icon texture (`res://assets/icons/stats_icon.png`) centered (`icon_alignment = 1`) and scaled cleanly (`expand_icon = true`).
  5. Inspect the visual composition and contrast of the icon:
     - The icon depicts four solid white (`#ffffff`) vertical bars and a solid white horizontal baseline underline.
     - The icon background is 100% transparent with no black outlines, dark strokes, or double-outline artifacts.
     - In both Continuous Play and Daily Challenge headers, the solid white bars and underline stand out with sharp, crisp contrast against the dark charcoal button background (`#1c1c1e` normal / `#2c2c30` hover).
  6. Inspect the button touch target size and visual symmetry with the Back button on the opposite side (both buttons have 56x56 minimum dimensions in a 56px height header).
  7. Tap the statistics button to verify it responds smoothly with standard 1930s theme button interaction states (hover/pressed) and opens the Stats Screen modal.
  8. Verify the behavior is identical in both Continuous Play and Daily Challenge modes.
- **Expected Result:** The header statistics button displays a crisp, solid white four-bar and underline graph icon without black outlines, contrasts sharply against the dark button background, matches the back button in sizing and vertical alignment, and reliably opens the Statistics modal.

### Test 5.8: Letter Grid Tile Font Sizing and Padding Across Aspect Ratios
- **Requirement(s):** REQ-8.7
- **Steps:**
  1. Launch the game in either Continuous Play or Daily Challenge mode.
  2. Observe the letter tiles across the game grid.
  3. Type letters across the active row (e.g., "PLANT").
  4. Verify that each letter renders in an enlarged font size (72px) that proportionally fills the responsive tile box (~100px–120px+).
  5. Verify that each letter is horizontally and vertically centered within the tile.
  6. Verify that letters maintain clean padding and margin clearance from the tile's 2px border and 4px rounded corners without clipping, touching edges, or truncating across different screen resolutions (16:9, 19.5:9, 20:9 smartphones and 4:3, 16:10 tablets).
  7. Submit the guess and verify that evaluation colors (Green, Yellow, Flat Red) and state transitions preserve the font size and centering.
  8. Reset or start a new game and verify font sizing is consistently applied to newly typed letters.
- **Expected Result:** Letters render prominently at 72px font size, fill the tile interior proportionally with balanced padding, remain centered, and never touch tile borders or clip corners.

### Test 5.9: Header Back Button Arrowhead & Navigation
- **Requirement(s):** REQ-8.1, REQ-8.2, REQ-8.11
- **Steps:**
  1. Start a game in either Continuous Play or Daily Challenge mode.
  2. Observe the back navigation button located in the top-left corner of the header (`BackButton`).
  3. Verify that the button does NOT display the legacy thin arrow with an elongated tail (`←`).
  4. Verify that the button displays a bold, clean left-pointing arrowhead character (`<`).
  5. Inspect the glyph appearance and contrast:
     - Rendered in crisp solid white (`#ffffff` / `Color(1, 1, 1, 1)`).
     - Scaled up font size of 32px filling the button bounds prominently with balanced margins.
     - Stands out with sharp, high contrast against the dark charcoal button background (`#1c1c1e` normal / `#2c2c30` hover).
  6. Inspect touch target size and visual symmetry with `StatsButton` on the opposite side (both buttons have `Vector2(56, 56)` minimum dimensions in the 56px height header).
  7. Tap the back button to verify it responds smoothly with standard 1930s button interaction states (hover/pressed) and returns cleanly to the Main Menu (`res://scenes/main_menu.tscn`).
  8. Repeat the test across both Continuous Play and Daily Challenge modes.
- **Expected Result:** The header back button displays a bold, solid white `<` arrowhead without a thin tail line, balances visually with `StatsButton` in 56x56 dimensions, contrasts sharply against the dark button background, and smoothly navigates back to the Main Menu from both game modes.

### Test 5.10: Center Header Typography Scaling & Toast Padding
- **Requirement(s):** REQ-8.9
- **Steps:**
  1. Start a game in Continuous Play mode.
  2. Inspect the center header typography layout above the letter grid:
     - **Game Title (`TitleLabel`):** Verify "LETTERLOGIC" renders in a bold, prominent 48px font size.
     - **Mode Subtitle (`ModeLabel`):** Verify "CONTINUOUS PLAY" renders in a clearly readable 28px font size with muted gray color (`#a6a6a6`).
     - **Active Timer (`TimerLabel`):** Verify the running timer renders legibly at 32px font size with light gray color (`#cccccc`).
  3. Verify that the doubled center header typography integrates cleanly with the top navigation bar without vertical clipping or visual distortion of `BackButton` and `StatsButton` (both 56x56).
  4. Trigger a toast message (e.g., submit an invalid 5-letter word or 4-letter guess).
  5. Verify the toast notification text renders at 36px font size with comfortable 24px horizontal breathing room from the 12px rounded outline corners.
  6. Tap the back button (`<`) to return to the Main Menu.
  7. Launch Daily Challenge mode.
  8. Inspect the center header typography:
     - Verify "LETTERLOGIC" title is 48px.
     - Verify "DAILY CHALLENGE • YYYY-MM-DD" subtitle is 28px and reflects today's UTC date.
     - Verify active timer is 32px.
  9. Trigger a toast message in Daily Challenge mode and confirm identical 36px typography and 24px horizontal padding.
- **Expected Result:** Both Continuous Play and Daily Challenge headers display doubled, highly legible center typography (Title: 48px, Subtitle: 28px, Timer: 32px) and toast alerts (36px with 24px horizontal padding) without vertical clipping or misaligning adjacent navigation controls.

### Test 5.11: Virtual Keyboard Tap Targets, Typography, and Control Key Sizing
- **Requirement(s):** REQ-8.7
- **Steps:**
  1. Launch the game in either Continuous Play or Daily Challenge mode on an Android device or emulator (portrait orientation).
  2. Observe the on-screen virtual keyboard at the bottom of the screen.
  3. Verify the vertical height of the keys is enlarged (~77px), providing a taller, more comfortable tap target compared to the default Godot button height.
  4. Verify standard letter keys ("A"–"Z") display letters prominently with an enlarged font size (~44px) that proportionally fills the taller key while maintaining clean margin padding.
  5. Verify the Delete key ("⌫") icon is scaled up to match the enlarged font size of standard letter keys.
  6. Verify the Enter key ("ENTER") text is constrained to an optimal size (~20px) so the full word fits neatly inside the key boundary without horizontal clipping or pushing adjacent keys off-screen.
  7. Type letters and submit a guess to trigger state changes (Correct, Present, Absent, row disabled).
  8. Verify that the enlarged and constrained font sizes are preserved across all visual key states and interaction feedback (hover, pressed).
- **Expected Result:** Keyboard keys provide enlarged (~77px) vertical tap targets. Standard letters and the Delete icon render prominently (~44px font size), the Enter text fits cleanly (~20px font size), and all typography sizing is strictly maintained across varied screen widths and state changes without layout clipping.

### Test 5.12: Main Menu Typography, Navigation Button Dimensions & Responsive Touch Targets
- **Requirement(s):** REQ-8.1, REQ-8.2, REQ-8.7, REQ-8.12
- **Steps:**
  1. Launch the application to the Main Menu (`res://scenes/main_menu.tscn`).
  2. Inspect the Main Menu title and tagline typography:
     - **Title (`TitleLabel`):** Verify `LETTERLOGIC` renders in an enlarged, bold 88px font size centered above the navigation stack.
     - **Subtitle (`SubtitleLabel`):** Verify `The 5-Letter Isogram Word Game` renders in a clear 36px font size with `#b3b3b3` color and clean 12px vertical separation from the title.
  3. Inspect the primary mode navigation buttons:
     - **Daily Challenge (`DailyButton`):** Verify the button displays at an expanded minimum height of 120px with doubled 40px typography. Ensure the two lines of text (e.g., `Daily Challenge\n[Play Today's Word]` or active countdown `Daily Challenge\n[Next in: HH:MM:SS]`) fit comfortably without vertical clipping, truncation, or crowding against borders and corner radii.
     - **Continuous Play (`ContinuousButton`):** Verify the button displays at 120px minimum height with doubled 40px typography and two lines of text (`Continuous Play\n[Unlimited Practice]`).
  4. Inspect the secondary utility buttons:
     - **Statistics (`StatsButton`):** Verify the button displays at an expanded minimum height of 80px with doubled 36px typography.
     - **How to Play (`HowToPlayButton`):** Verify the button displays at an expanded minimum height of 80px with doubled 36px typography.
  5. Inspect vertical spacing and layout breathing room:
     - Verify 20px vertical separation between navigation buttons.
     - Verify the vertical container hierarchy (`VBox`) remains centered and balanced within safe margins across standard (720x1280) and tall portrait aspect ratios (18:9, 19.5:9, 20:9, 21:9) without overlapping the mascot or overflowing the display viewport.
  6. Tap each button to confirm touch responsiveness, tactile interaction states, and seamless navigation.
- **Expected Result:** The Main Menu presents doubled typography (88px title, 36px subtitle, 40px mode buttons, 36px utility buttons) and expanded button minimum heights (120px for mode buttons, 80px for utility buttons), providing ergonomic tap targets, no text clipping or crowding, and balanced vertical centering across all portrait aspect ratios.

