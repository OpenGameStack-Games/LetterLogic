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

### Test 1.3: Guess Evaluation, Staggered Reveal and Keyboard Colors
- **Requirement(s):** REQ-2.2, REQ-2.4, REQ-8.15
- **Steps:**
  1. (Godot Editor only) Use the debugger or print statements to determine the current `secret_word`.
  2. Input a valid 5-letter isogram that contains at least one correct letter in the right spot, one correct letter in the wrong spot, and some letters not in the word.
  3. Submit the guess.
- **Expected Result:** The tiles in the grid reveal and update to Green (`#538d4e`), Yellow (`#b59f3b`), and Flat Red (`#b53b3b`) sequentially from left to right with a scale pop effect. The on-screen keyboard keys update to match the highest state of each guessed letter (Absent keys appear in Flat Red with white text).


### Test 1.4: Win/Loss Conditions & Game Over Modal
- **Requirement(s):** REQ-2.3, REQ-2.7, REQ-8.16
- **Steps:**
  1. Play a game and deliberately submit 6 incorrect valid words.
  2. Observe the transition upon submitting the 6th guess:
     - Verify the tiles complete their staggered reveal animation across all 5 columns (~1.5 seconds) before the Game Over modal appears.
     - Verify the Game Over modal plays an entrance animation (scaling pop from 0.8x to 1.0x with back-ease overshoot while fading in from 0.0 to 1.0 opacity over 0.3s).
     - Verify the title displays "Game Over" with an enlarged font size of 56px, centered horizontally.
     - Verify the message displays the single line `The word was <secret>` with an enlarged font size of 32px and centered alignment.
     - Verify that elapsed solve time is strictly omitted from the loss modal.
     - Verify the action buttons ("Next Word" / "Share Results" and "Main Menu"):
       - Buttons have their minimum height doubled to 96px (`custom_minimum_size = Vector2(0, 96)`), providing comfortable mobile touch targets.
       - Button text renders in an enlarged 32px font size.
       - Buttons are inset from the modal panel edges with 64px horizontal margins (shortening button width by ~20%), appearing as distinct centered buttons rather than edge-to-edge bars.
       - Buttons maintain 12px vertical separation.
  3. Play another game and observe the active running timer in the header.
  4. Submit the exact secret word to win the puzzle (e.g., on attempt 3).
  5. Observe the transition upon submitting the winning guess:
     - Verify the tiles complete their staggered reveal animation across all 5 columns (~1.5s delay) before the Game Over modal appears.
     - Verify the Game Over modal smoothly pops and fades in with the same entrance animation.
     - Verify the title displays the appropriate attempt-based accolade (e.g., "Impressive!" for 3 attempts) in 56px font size, centered horizontally.
     - Verify the message displays a two-line summary in 32px font size:
       - Line 1: `You found '<secret>' in 3/6 guesses.`
       - Line 2: `Time: MM:SS` (matching the frozen header timer, e.g. `Time: 00:42`).
     - Verify the message text is horizontally centered with word-wrapping enabled, fitting cleanly without clipping or overflowing the modal panel.
     - Verify that modal action buttons ("Next Word" in Continuous Play, or "Share Results" in Daily Challenge, and "Main Menu") render with 96px minimum height, 32px text font, 64px inset margins, and 12px vertical separation, remaining fully accessible without displacement.
- **Expected Result:** On loss, after waiting ~1.5s for the tile reveal animation to complete, the modal pops and fades in displaying "Game Over" (56px) with single-line text revealing the word (32px) and no elapsed time. On win, after waiting ~1.5s for the tile reveal animation to complete, the modal pops and fades in displaying the attempt accolade (56px) and a clean two-line summary (32px) with the secret word, guess count, and formatted elapsed solve time (`Time: MM:SS` or `Time: HH:MM:SS`), rendering centered without clipping. On both win and loss screens, the modal entrance animation scales up smoothly from 0.8x to 1.0x while fading in from 0.0 to 1.0 opacity over 0.3s, and action buttons feature doubled minimum heights (96px), enlarged typography (32px), 64px inset horizontal margins (~20% width reduction), and 12px vertical separation.

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

### Test 1.7: Duplicate Word Submission Prevention
- **Requirement(s):** REQ-3.4
- **Steps:**
  1. Start a game in either Continuous Play or Daily Challenge mode.
  2. Type a valid 5-letter isogram (e.g., "PLANT") and submit the guess.
  3. Verify that the guess is evaluated and displayed on row 1, and the active row advances to row 2.
  4. Type the exact same word again ("PLANT") into row 2 and submit the guess.
  5. Observe the UI response:
     - Verify that a toast notification with the message `"Word already guessed"` appears between the header and the game board.
     - Verify the active row does not advance (remains on row 2).
     - Verify no attempt is consumed and the duplicate letters remain in the current row.
  6. Backspace and enter a different valid word. Submit to verify normal gameplay continues.
- **Expected Result:** Submitting an already-guessed word displays the "Word already guessed" toast notification, rejects the guess without consuming an attempt or advancing the row, and allows the player to modify their input.

### Test 1.8: Staggered Tile Reveal Animation & Scale Pop
- **Requirement(s):** REQ-2.2, REQ-8.15
- **Steps:**
  1. Start a game in Continuous Play or Daily Challenge mode.
  2. Type a valid 5-letter isogram guess (e.g., "CRANE").
  3. Submit the guess by pressing Enter.
  4. Carefully observe the row of tiles during evaluation:
     - Verify that tiles do not reveal their color states all at once.
     - Verify that tiles reveal sequentially from left to right (column 0 through column 4) with a ~0.3-second delay between each tile.
     - Verify that as each tile reveals its color, it performs a subtle scale pop (scaling up to ~1.1x and smoothly returning to 1.0x over ~0.3 seconds).
     - Verify that the scale pop is centered on each tile without shifting the tile's position or causing layout reflow/jitter in the parent game board grid or adjacent rows.
  5. Repeat in the other game mode (Daily Challenge or Continuous Play) to confirm uniform behavior.
- **Expected Result:** Letters in the submitted row reveal their colors sequentially from left to right at 0.3s intervals with an elastic scale pop effect from each tile's center. The grid layout remains completely stable and undisturbed throughout the animation.

### Test 1.9: Game Over Modal Reveal Delay & Entrance Animation
- **Requirement(s):** REQ-2.2, REQ-2.7, REQ-8.16
- **Steps:**
  1. Start a game in Continuous Play mode.
  2. Enter the winning guess and submit it by pressing Enter.
  3. Carefully observe the game board and screen transition upon winning:
     - Verify that the 5 letter tiles in the winning row perform their sequential staggered reveal animation from left to right (totaling ~1.5 seconds).
     - Verify that the Game Over modal does NOT appear immediately when the guess is submitted; it waits for the full tile reveal animation across all 5 columns to complete (~1.5s delay).
     - Verify that immediately following the completion of the tile reveal animation, the Game Over modal becomes visible and performs an entrance animation: smoothly scaling up from 0.8x to 1.0x with an elastic back-ease pop (`TRANS_BACK`, `EASE_OUT` over 0.3s) centered at its midpoint pivot (`pivot_offset = size / 2.0`) while simultaneously fading in from 0.0 to 1.0 alpha opacity.
  4. Start a new puzzle in Continuous Play (or Daily Challenge) and deliberately exhaust all 6 guesses with incorrect valid words.
  5. Carefully observe the game board and screen transition upon losing:
     - Verify that all 5 tiles in the 6th row complete their staggered reveal animation.
     - Verify that the Game Over modal delays appearance until the full tile reveal animation completes (~1.5s delay).
     - Verify that the Game Over modal executes the exact same entrance animation (0.8x to 1.0x scale pop and 0.0 to 1.0 opacity fade-in over 0.3s) on loss.
  6. Confirm that the delay and entrance animation execute identically and reliably in both Continuous Play and Daily Challenge modes.
- **Expected Result:** Upon winning or losing in both Continuous Play and Daily Challenge modes, the game waits ~1.5 seconds for the staggered tile reveal animation to complete across all 5 columns before displaying the Game Over modal. When the modal appears, it plays a coordinated entrance animation (fade in and scale pop with back-ease overshoot from 0.8x to 1.0x over 0.3s) centered around its midpoint.

### Test 1.10: Main Game Portrait Layout, Board Visibility & Keyboard Containment on Android

### Test 1.10b: Representative Portrait Screenshots — Continuous Play & Daily Challenge
- **Requirement(s):** REQ-4.1, REQ-4.2, REQ-8.7
- **Purpose:** Capture visual confirmation that the MainGame portrait-first proportional layout renders correctly across representative phone and tablet portrait sizes for both Continuous Play and Daily Challenge modes.
- **Representative Viewports:** 360x800 (small phone), 412x915 (typical phone), 1080x2400 (tall phone), 1284x2778 (large phone/phablet), 1536x2048 (tablet portrait)
- **Steps:**
  1. Launch the game in the Godot Editor or on a physical device and open the MainGame scene in Continuous Play mode.
  2. For each representative viewport above:
     a. If using the Editor, resize the editor play window to the exact resolution and orientation; if on a device/emulator, set device rotation to portrait and select the matching device profile (or take a screenshot and crop to the resolution for documentation).
     b. Verify the top header (mode label, timer, back/stats buttons) is fully visible and not clipped by cutouts.
     c. Verify the on-screen keyboard shows all keys (three rows), keys remain readable (letters not truncated), and key touch heights remain comfortably clickable.
     d. Verify the BoardArea is centered/fills the middle region and remains visually prominent (at least ~30% of viewport height for the board region).
     e. Verify there is no overlap between BoardArea and KeyboardArea: tiles must never be obscured by keys.
     f. Verify that the bottom area below the keyboard contains only the explicit bottom breathing buffer (a small spacer) and no large blank gap.
     g. Capture a screenshot for each viewport showing the full main screen (header → board → keyboard → bottom buffer).
  3. Repeat steps 1–2 for Daily Challenge mode.
- **Expected Result:** For every representative viewport, the keyboard is readable and usable (no squashed keys), board and keyboard never overlap, board occupies the middle region, only the bottom breathing buffer remains under the keyboard (no large blank region), and screenshots demonstrate consistent layout across Continuous Play and Daily Challenge.

(Continue with the existing Test 1.10 content below.)
- **Requirement(s):** REQ-8.7, REQ-8.9, REQ-8.18
- **Steps:**
  1. Install the APK on a physical Android device or emulator and verify the main game scene in each of these portrait viewports: 360x640 (16:9), 412x915 (19.5:9), 360x800 (20:9), and 768x1024 (4:3).
  2. Start a game in Continuous Play and observe the main game header, toast overlay gap, board, and keyboard.
  3. Confirm the title, mode label, and timer remain stacked above the toast/board/keyboard flow with no overlap or clipping.
  4. Confirm all 6 board rows remain visible, the keyboard starts below the board, and no key row bleeds below the bottom of the viewport.
  5. Trigger a toast notification with an invalid guess and verify the board does not shift when the toast appears or dismisses.
  6. Repeat the same checks in Daily Challenge and verify the layout contract stays identical.
- **Expected Result:** The main game scene keeps a stable vertical flow in every tested portrait viewport, with safe-area-aware top and bottom margins, a visible 6-row board, and a fully contained keyboard that never overlaps the board or bleeds below the viewport. Toasts reserve their own vertical space, and both Continuous Play and Daily Challenge use the same layout contract.

---


## 2. Game Modes

### Test 2.1: Continuous Play Reset
- **Requirement(s):** REQ-4.1
- **Steps:**
  1. Start a Continuous Play game.
  2. Complete the game (win or lose).
  3. Select the option to play again.
- **Expected Result:** The board resets immediately, a new random word is chosen, and the timer resets to `00:00`.

### Test 2.2: Daily Challenge Completion, Menu Lockout, and Summary Screen Re-entry
- **Requirement(s):** REQ-4.2, REQ-4.3, REQ-7.1
- **Steps:**
  1. Start a Daily Challenge game from the Main Menu.
  2. Complete the Daily Challenge (either by winning or by exhausting all 6 guesses).
  3. Note the final elapsed solve time, guess count, board tiles, and keyboard evaluation colors on the Game Over modal.
  4. Return to the Main Menu (via the back button or navigation).
  5. Inspect the Daily Challenge button on the Main Menu:
     - Verify the button text displays:
       `Daily Challenge - Completed\n[Next in: HH:MM:SS]`
     - Verify the countdown timer ticks down every second while preserving the `- Completed` prefix.
     - Verify the two-line text fits comfortably within the button bounds without clipping or overflow.
  6. Click or tap the completed Daily Challenge button on the Main Menu.
  7. Observe the loaded screen:
     - Verify that a new game is NOT started and no new word is picked.
     - Verify that the game screen opens directly into the Game Over summary state.
     - Verify that the `GameBoard` tiles display all previously submitted guesses with their evaluated colors (Green, Yellow, Red).
     - Verify that the virtual `Keyboard` reflects the final evaluation states from the solved puzzle.
     - Verify that the header timer shows the final saved solve time and remains frozen.
     - Verify that `GameOverModal` is open immediately with the saved win/loss message.
     - Verify that the "Share Results" button is visible and the "Next Word" button is hidden.
     - Verify that virtual keyboard clicks and physical keystrokes are completely disabled and ignored.
  8. Return to the Main Menu and open the Statistics Screen:
     - Verify that re-opening and viewing the completed Daily Challenge did not trigger additional games played, increment streaks, or alter recorded solve times.
  9. (Optional) Change the system/device clock past next UTC midnight and verify the Daily Challenge unlocks with a fresh word and the button returns to `Daily Challenge\n[Play Today's Word]`.
- **Expected Result:** After puzzle completion, the player is locked out of playing a new daily session until next UTC midnight. The Main Menu button reflects the `- Completed` status with an active countdown. Clicking the button restores the completed session directly into the Game Over summary screen with the board, keyboard, timer, and modal accurately restored without corrupting player statistics.

### Test 2.3: Mode Header Title Display
- **Requirement(s):** REQ-4.1, REQ-4.2
- **Steps:**
  1. From the Main Menu, tap "Daily Challenge".
  2. Observe the header text above the board.
  3. Return to the Main Menu and tap "Continuous Play".
  4. Observe the header text above the board.
- **Expected Result:** When entering Daily Challenge, the header displays `DAILY CHALLENGE • YYYY-MM-DD` with today's UTC date. When entering Continuous Play, the header displays `CONTINUOUS PLAY`.

### Test 2.4: Daily Challenge UTC Rollover Discards Previous In-Progress Save
- **Requirement(s):** REQ-4.2, REQ-7.3
- **Steps:**
  1. Launch the game and start today's Daily Challenge from the Main Menu.
  2. Enter 1–3 valid guesses (leaving the puzzle unfinished).
  3. Exit to the Main Menu (or close the application).
  4. Artificially advance the device/system clock by +24 hours past the next UTC midnight rollover (or modify system time to Day X+1).
  5. Reopen/return to the application.
  6. Observe the Main Menu Daily Challenge button:
     - Verify it is unlocked and ready for the new day's puzzle (`Daily Challenge\n[Play Today's Word]`).
  7. Tap "Daily Challenge".
  8. Observe the loaded puzzle:
     - Verify that yesterday's in-progress board, guesses, and secret word are NOT restored.
     - Verify that a fresh, empty 6x5 grid is initialized.
     - Verify the header displays the new UTC date (`DAILY CHALLENGE • YYYY-MM-DD`).
     - Verify the timer starts at `00:00`.
     - Verify the keyboard is fully reset (no letters colored or disabled from yesterday).
- **Expected Result:** Upon UTC day rollover, an incomplete Daily Challenge save from a previous day is automatically discarded and cleared. The game initializes a brand-new daily puzzle for the current UTC date with an empty grid, new daily word, and reset timer, rather than restoring yesterday's save state.

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

### Test 3.3: Statistics Screen Connected Tabular Layout, Opaque Background & Mode Switching
- **Requirement(s):** REQ-5.2, REQ-5.4, REQ-8.8
- **Steps:**
  1. Open the Statistics Screen from the Main Menu or Game Over modal.
  2. Observe the full-screen modal background:
     - Verify the background is completely opaque (`#121212` / `Color(0.0705882, 0.0705882, 0.0705882, 1)`, alpha = 1.0).
     - Confirm that all underlying elements (such as the Main Menu mascot, title box, and buttons, or in-game header, active puzzle timer, letter grid, and keyboard) are completely obscured and invisible with zero bleed-through around modal edges.
     - Confirm touches and clicks on the background do not pass through to underlying buttons or controls.
  3. Observe the mode selector tabs ("Continuous Play" and "Daily Challenge").
  4. Verify the active tab styling: deep black fill (`#0e0e10`), 3px solid white borders on top, left, and right, and no bottom border dividing line separating the tab from the statistics content panel.
  5. Verify the inactive tab styling: dark charcoal fill (`#1c1c1e`), 3px solid white border around all sides, clearly separating it from the content panel below.
  6. Verify that the 6 summary cards are arranged cleanly in a 3-column multi-row grid (`GridContainer`, 2 rows of 3 columns) with intuitive vertical column pairings:
     - Top Row: Played (`PlayedCard`), Max Streak (`MaxStreakCard`), Best Time (`BestTimeCard`).
     - Bottom Row: Win % (`WinPctCard`), Current Streak (`StreakCard`), Avg Time (`AvgTimeCard`).
     - Column Pairings: Column 1 pairs volume and win rate (Played / Win %), Column 2 pairs max and current streaks (Max Streak / Current Streak), and Column 3 pairs best and average times (Best Time / Avg Time).
     - Verify metric values (36px) and labels (18px) display sharp, legible typography without crowding.
  7. Verify that Played, Current Streak, and Max Streak summary cards display clean whole numbers without decimal points.
  8. Tap the inactive tab ("Daily Challenge").
  9. Observe the visual transition and data displayed, confirming streak and played values are formatted as integers without decimal points.
  10. Tap "Continuous Play" to switch back.
- **Expected Result:**
  - The Statistics modal presents a solid, 100% opaque dark background (`#121212`) that fully obscures all underlying UI elements and blocks touch/mouse pass-through.
  - The active tab connects seamlessly to the content panel with no bottom border line.
  - The inactive tab maintains a distinct 3px white outline on all sides and dark charcoal background.
  - Tapping between tabs transitions mode data smoothly with no disappearing borders, flickering, or layout shift.
  - All summary cards (Played, Win %, Current Streak, Max Streak, Best Time, Avg Time) and guess distribution rows update immediately to reflect the selected mode.
  - Summary metrics render in an organized 3-column by 2-row layout with intuitive vertical column pairings (Played & Win %, Max Streak & Current Streak, Best Time & Avg Time) and enlarged typography.
  - Played, Current Streak, and Max Streak summary cards consistently display as integers without decimal points across both tabs.

### Test 3.4: In-Progress Game State Saving & Restoration (Menu Back & App Lifecycle)
- **Requirement(s):** REQ-7.2, REQ-7.3
- **Steps:**
  1. Start a Continuous Play game.
  2. Enter two valid guesses (e.g. "BRAIN" and "CLERK") and observe the evaluated tile and keyboard colors.
  3. Type 2 letters of the next guess (e.g. "SH").
  4. Note the elapsed time on the header timer (e.g. `00:35`).
  5. Tap the Back button (`<`) in the top navigation bar to return to the Main Menu.
  6. Tap "Continuous Play" from the Main Menu.
  7. Observe the restored game screen:
     - Verify that a new random puzzle was NOT generated.
     - Verify rows 1 and 2 display "BRAIN" and "CLERK" with their evaluated colors (Green, Yellow, Red).
     - Verify row 3 displays the partially typed letters "SH".
     - Verify the keyboard retains evaluated colors and disables 'S' and 'H' from duplicate typing.
     - Verify the header timer displays `00:35` and resumes incrementing.
     - Verify the GameOverModal remains hidden and the keyboard/board accept input.
  8. Minimize the application, switch to another app, or close the application completely.
  9. Re-launch and refocus the game, then enter Continuous Play.
  10. Verify that the exact puzzle state (guesses, partial letters, keyboard states, timer) is once again intact.
- **Expected Result:** Leaving the game screen via the back button, minimizing the app, or terminating the process preserves the exact in-progress session. Re-entering Continuous Play restores all tiles, keyboard colors, typed letters, and play time without resetting the puzzle.

### Test 3.5: Puzzle Reset Prevention and Save Clearing on Completion
- **Requirement(s):** REQ-7.3
- **Steps:**
  1. Start a Continuous Play puzzle and enter at least one guess.
  2. Repeatedly return to the Main Menu and tap "Continuous Play" several times.
  3. Verify that the puzzle never resets to a new word while in progress.
  4. Complete the puzzle by winning or exhausting all 6 guesses.
  5. On the Game Over modal, tap the Back button (`<`) to return to the Main Menu, or tap "Next Word".
  6. From the Main Menu, tap "Continuous Play".
- **Expected Result:** An in-progress game strictly prevents resets until finished. Completing the puzzle clears the saved session file (`user://save_continuous.json`), allowing a fresh puzzle with an empty grid, new secret word, and reset timer (`00:00`) to begin on subsequent entry.

---

## 4. Social Sharing

### Test 4.1: Native Share Sheet Plugin Integration (Android)
- **Requirement(s):** REQ-6.1, REQ-6.2, REQ-9.4
- **Steps (Android device required):**
  1. Build and install the Android export (`.apk` or `.aab`) with `SharePlugin` enabled on a physical Android device or emulator.
  2. Complete today's Daily Challenge (or re-enter a completed daily challenge from the Main Menu).
  3. On the Game Over modal, tap the "Share" button.
  4. Observe the system response:
     - Verify that the native Android system Share Sheet immediately opens (displaying target sharing apps such as Messages, WhatsApp, Gmail, Discord, etc.) via dynamic instantiation of `Share.gd`.
     - Select an application (such as Messages or WhatsApp).
     - Verify the shared text content contains the complete formatted summary:
       - Header with game name, UTC date, and attempt score (e.g., `LetterLogic 2026-09-15 3/6` or `X/6`).
       - Formatted active solve timer line with emoji (e.g., `⏱️ 01:45`).
       - Correct emoji representation grid for all submitted guesses (🟩🟨🟥).
       - Direct Google Play Store link (`Play now: audrain.games/letterlogic/android`).
     - Verify that the device clipboard also receives the shared text as a convenience copy.
- **Expected Result:** Tapping the "Share" button on Android activates the native Android Share Sheet via the dynamically instantiated `Share.gd` wrapper node without freezing or crashing, allowing seamless sharing to any installed messaging or social application (Messages, WhatsApp, etc.), safely cleaning up the temporary node on a short timer delay while also copying the formatted results to the device clipboard.

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
  Play now: audrain.games/letterlogic/android
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

### Test 5.3: Static Main Menu Mascot Display
- **Requirement(s):** REQ-8.4, REQ-8.5
- **Steps:**
  1. Launch the game to the Main Menu.
  2. Observe the cartoon mascot situated directly above the `LETTERLOGIC` title box.
  3. Verify the mascot displays classic 1930s rubber-hose cartoon styling in its original dynamic walking pose (`res://assets/icons/icon.png`), with pie-eyes, cartoon white gloves, letter "L" on chest, and rounded white ink outlines in monochrome.
  4. Watch the mascot for several seconds without interacting.
  5. Confirm the mascot remains completely static with zero rotation (`rotation_degrees = 0.0`), uniform scale (`scale = Vector2.ONE`), and no rocking, swaying, scaling, or motion loops.
  6. Navigate to Continuous Play, Daily Challenge, or open the How to Play modal, then return to the Main Menu.
  7. Verify the mascot continues to display statically without unwanted motion or orphaned tweens.
- **Expected Result:** The mascot displays cleanly in its original 1930s walking pose completely static without animation or swaying.

### Test 5.4: Application Launcher Icon & Android Adaptive Icons
- **Requirement(s):** REQ-8.4, REQ-8.17
- **Steps:**
  1. Inspect the desktop window titlebar/taskbar (or export and install APK on an Android device/emulator).
  2. Look at the application launcher icon on the Android home screen or desktop taskbar.
  3. Verify the desktop icon renders crisp and clear at 512x512 resolution without clipping, distortion, or chromatic artifacts.
  4. On Android devices (API 26+), verify that the icon renders adaptively with the mascot foreground centered over the solid dark background layer, conforming cleanly to the system launcher mask (circle, squircle, rounded square).
- **Expected Result:** The 1930s rubber-hose mascot icon is displayed cleanly as the desktop application launcher icon, and renders natively as an adaptive icon on Android without awkward borders or clipping.

### Test 5.5: How to Play Modal Responsive Layout, Calibrated Typography & Enlarged Dismiss Button
- **Requirement(s):** REQ-8.1, REQ-8.3, REQ-8.6
- **Steps:**
  1. Launch the game to the Main Menu.
  2. Tap the "How to Play" button to open the instructions modal (`HowToPlayModal`).
  3. Verify the modal panel container is wrapped in a responsive `MarginContainer` (24px horizontal, 48px vertical margins) spanning the viewport rather than hardcoded fixed pixel offsets, and confirm the modal content sits inside an inner 24px left/right inset so the title, rules text, and dismiss button do not touch the panel border.
  4. Inspect the modal typography and heading hierarchy:
     - **Modal Title (`ModalTitle`):** Verify `HOW TO PLAY` renders prominently in a tripled 84px font size centered at the top of the panel.
     - **Instructional Body Text (`RulesText`):** Verify the regular instructional copy renders in a calibrated 32px font size (`normal_font_size = 32`), filling the modal interior legibly.
     - **Section Headings:** Verify bold section headings (`[b]Guess the secret word in 6 attempts.[/b]`, `[b]Tile Colors:[/b]`, `[b]Modes:[/b]`) render at 32px bold font size (`bold_font_size = 32`).
  5. Inspect the dismiss button ("Got It!", `CloseButton`):
     - Verify the button features an enlarged minimum height of at least 80px (`custom_minimum_size.y >= 80px`), providing a comfortable and ergonomic mobile thumb-tap target, while still retaining visible horizontal padding from the panel border.
     - Verify the button font size is enlarged to at least 36px (`font_size >= 36px`), matching the Main Menu secondary utility buttons.
  6. Verify layout spacing and vertical breathing room:
     - Confirm 20px vertical separation between the title, rules text, and dismiss button (`separation = 20`).
     - Confirm the complete instructional copy fits comfortably within the modal vertical budget on standard 720x1280 portrait resolution without requiring vertical scrolling.
  7. Check the tile color evaluation cues:
     - Correct is displayed as `🟩 GREEN` (`#538d4e`) - "Letter is in the word and in the correct spot."
     - Present is displayed as `🟨 YELLOW` (`#b59f3b`) - "Letter is in the word but wrong spot."
     - Absent is displayed as `🟥 RED` (`#b53b3b`) - "Letter is not in the word." (confirm it is NOT gray `⬛ GRAY` or `#808080`).
  8. Verify the special rule states that words never contain duplicate letters (5-letter isograms) and that keys typed in the current row are temporarily disabled.
  9. Verify game modes (Daily Challenge with UTC midnight reset, Continuous Play unlimited sandbox) are clearly described.
  10. If tested on smaller displays or with enlarged system font scaling, verify the `RichTextLabel` vertical scrollbar engages cleanly (`scroll_active = true`) without content truncation.
  11. Tap "Got It!" and verify the modal dismisses smoothly with standard button interaction feedback and returns focus to the Main Menu.
- **Expected Result:** The modal opens adaptively within responsive margins displaying prominent header typography (84px title), calibrated 32px body/headings fitting without vertical scrolling on 720x1280 screens, and an enlarged 80px "Got It" button (36px font). The title, rules, and dismiss button all preserve visible left/right inset from the panel border, all text is crisp and legible, deduction cues display flat red (`🟥 RED` / `#b53b3b`), fallback scrolling functions smoothly if constrained, and the modal dismisses cleanly.

### Test 5.6: Responsive UI Scaling Across Android Portrait Aspect Ratios
- **Requirement(s):** REQ-8.7
- **Steps:**
  1. Launch the game in the Godot Editor or on an Android device / emulator.
  2. Test or simulate diverse portrait screen resolutions across different device form factors:
     - **16:9 Standard Portrait:** 720x1280 or 1080x1920
     - **Tall Smartphones (19.5:9 / 20:9):** 1080x2340 or 1080x2400
     - **Extra Tall Display (21:9):** 1080x2520
     - **Portrait Tablets (4:3 / 16:10):** 1536x2048, 768x1024, or 1200x1920
     - **Punch-Hole / Notch Android Device:** A physical device or emulator that reports a non-zero top safe area inset (for example a Samsung Galaxy S22 or equivalent display cutout profile).
  3. On each aspect ratio, evaluate the Main Menu:
     - Verify the mascot, title box, and navigation buttons scale dynamically within safe margin padding without crowding screen borders or overflowing.
  4. Enter a game (Continuous Play or Daily Challenge):
     - **Game Board:** Confirm the 5-column by 6-row grid preserves its 5:6 aspect ratio and square tiles via `AspectRatioContainer`, dynamically expanding across the available width while observing safe margins.
      - **Virtual Keyboard:** Confirm that the keyboard grid strictly uses proportional sizing (`size_flags_stretch_ratio`), where all standard letter keys have identical uniform widths (stretch ratio 1.0), action keys (`⌫` on bottom left and `ENTER` on bottom right) are exactly 50% wider (stretch ratio 1.5), and Row 2 side stagger spacers are exactly half a key width (stretch ratio 0.5), scaling seamlessly across display widths without horizontal clipping or pushing adjacent keys off-screen.
     - **Header Bar:** Verify the back button, game mode title, timer label, and statistics button stay neatly aligned across the top row.
  5. Open dialog overlays (How to Play modal, Stats Screen, and Game Over modal):
     - Confirm dialog panels scale responsively within their `MarginContainer` boundaries without overflowing off-screen or truncating buttons.
  6. On the punch-hole / notch device, confirm the Main Menu, Continuous Play header, Daily Challenge header, and Statistics Screen title all remain fully visible below the display cutout with no part of the top heading hidden behind camera hardware.
  7. Repeat the same screens on a flat/no-cutout device or emulator and confirm the original base top spacing remains intact with no extra top padding added.
- **Expected Result:** All UI elements dynamically scale and maintain proportional sizing across phones and tablets, avoiding letterbox bars, clipping, or overlapping controls. Devices with display cutouts keep all top headers fully visible, while flat-screen devices preserve the original design spacing without unnecessary extra padding.

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

### Test 5.11: Main Game Flow Layout, Virtual Keyboard Tap Targets, Typography, and Control Key Sizing
- **Requirement(s):** REQ-8.7
- **Steps:**
  1. Launch the game in either Continuous Play or Daily Challenge mode on an Android device or emulator in portrait orientation.
  2. On a physical Android device (specifically a Samsung Galaxy S22 or other compact portrait phone) or matching display cutout profile (1080x2340), verify the top header remains fully visible without being obscured by the camera cutout.
  3. Inspect the game board and keyboard layout: confirm that the board fills the middle of the screen and the keyboard stays anchored at the bottom with 70px bottom breathing room padding (`margin_bottom = 70`). Verify there is **strictly zero overlap** between the game board tiles and the keyboard under any circumstance.
  4. Repeat the layout check across varied screen aspect ratios (16:9, 19.5:9, 20:9, and tablet 4:3 / 16:10 profiles) to confirm the board and keyboard maintain clean separation without collision.
  5. On tablets or wider portrait profiles, confirm the board expands to absorb the extra vertical space while the keyboard retains its bottom buffer and compact footprint.
  6. Observe the on-screen virtual keyboard at the bottom of the screen.
  7. Verify the vertical height of the keys is calibrated to 99px (`KEY_MIN_HEIGHT = 99.0`), providing a comfortable tap target while preventing container overflow on shorter mobile screens.
  8. Verify the keyboard grid strictly enforces proportional key widths via `size_flags_stretch_ratio`: all standard letter keys have uniform width with ratio 1.0, action keys (`ENTER` and `⌫`) have ratio 1.5, and Row 2 side stagger spacers have ratio 0.5 without hardcoded X pixel minimums.
  9. Verify standard letter keys ("A"–"Z") display letters prominently with an enlarged font size (~44px) that proportionally fills the 99px key while maintaining clean margin padding.
  10. Verify the Delete key ("⌫") is positioned on the bottom left and its icon is scaled up to match the enlarged font size of standard letter keys.
  11. Verify the Enter key ("ENTER") is positioned on the bottom right and its text scales responsively within the updated 22–32px font size range (`FONT_SIZE_ENTER_MIN = 22`, `FONT_SIZE_ENTER_MAX = 32`), with a 4px horizontal content margin (`content_margin_left = 4`, `content_margin_right = 4`) enforced on all keyboard keys so the full word fits neatly and legibly inside the widened 1.5x key boundary with visible breathing room and no horizontal clipping or pushing adjacent keys off-screen.
  12. Type letters and submit a guess to trigger state changes (Correct, Present, Absent, row disabled).
  13. Verify that the enlarged and constrained font sizes and proportional key width ratios are preserved across all visual key states and interaction feedback (hover, pressed).
- **Expected Result:** The Main Game screen uses a unified flow layout with visible header safe-area breathing room, a board that fills the middle, and a flexible keyboard that remains separated at the bottom without overlap on physical Android devices (including the Samsung Galaxy S22) as well as tablet profiles. The virtual keyboard uses proportional sizing (`size_flags_stretch_ratio`: 1.0 letters, 1.5 action keys, 0.5 Row 2 spacers) providing mathematically uniform letter widths. Keyboard keys provide calibrated 99px vertical tap targets and enforce 4px horizontal content margins. Delete is positioned on the bottom left and Enter on the bottom right. Standard letters and the Delete icon render prominently (~44px font size), the Enter text fits cleanly and legibly in an updated 22–32px font size range, and all typography sizing is strictly maintained across varied screen widths and state changes without layout clipping or board overlap.

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

### Test 5.13: Custom Boot Splash Screen Display
- **Requirement(s):** REQ-8.1, REQ-8.4, REQ-8.13
- **Steps:**
  1. Launch the LetterLogic application from a cold start (desktop or Android device/emulator).
  2. Observe the initial boot splash screen prior to the Main Menu loading.
  3. Verify that the splash screen displays the signature 1930s walking cartoon tile mascot icon (`res://assets/icons/icon.png`) centered on the screen.
  4. Verify that the default Godot Engine logo and branding do not appear on startup.
  5. Verify that no text, titles, subtitles, version numbers, or taglines are rendered on the splash screen (only the mascot image).
  6. Verify that the background color behind the mascot icon is deep charcoal/black (`#121212`), matching the monochrome game theme and clear color.
  7. Observe the transition from the boot splash screen to the Main Menu (`res://scenes/main_menu.tscn`).
  8. Confirm there is no white flicker, flash of unstyled color, or abrupt palette jump during the transition.
- **Expected Result:** The game launches with the custom walking mascot icon centered over a `#121212` dark monochrome background, completely free of text or default Godot branding, and transitions seamlessly into the Main Menu.

### Test 5.14: Statistics Screen Opaque Background, Enlarged Typography, Reordered Multi-Row Metrics Layout & Distribution Graph Sizing
- **Requirement(s):** REQ-5.2, REQ-5.4, REQ-8.1, REQ-8.7, REQ-8.8
- **Steps:**
  1. Launch the game and open the Statistics Screen (either via the Main Menu "Statistics" button or the in-game header `StatsButton` during Continuous Play or Daily Challenge).
  2. Inspect the full-screen backdrop:
     - Verify the modal background is 100% opaque (`#121212` / `Color(0.0705882, 0.0705882, 0.0705882, 1)`, alpha = 1.0) spanning the entire reference viewport.
     - Confirm that underlying interface elements (such as the mascot and menu buttons on the Main Menu, or the active timer, letter grid tiles, and virtual keyboard in gameplay) are completely obscured and invisible behind the modal with zero bleed-through.
     - Verify touches or clicks on the backdrop do not interact with underlying controls.
  3. Inspect the modal header and navigation controls:
     - **Title (`Title`):** Verify `STATISTICS` renders in doubled 52px typography centered prominently at the top.
     - **Close Button (`CloseButton`):** Verify the `✕` close button renders with doubled 32px font size and expanded dimensions (`60x60`), providing a comfortable mobile tap target.
     - **Mode Tabs (`ModeTabs`):** Verify tab titles ("Continuous Play", "Daily Challenge") render in doubled 32px font size with generous 20px horizontal and 12px vertical content padding, without text clipping or touching border edges.
  4. Inspect the summary statistics layout, card ordering, and typography:
     - Verify the 6 summary cards are arranged in a 3-column multi-row grid (`GridContainer`, 2 rows of 3 columns) ordered into intuitive vertical metric pairings:
       - **Top Row (Overall Milestones & Peak Achievements):** Played (`PlayedCard`), Max Streak (`MaxStreakCard`), and Best Time (`BestTimeCard`).
       - **Bottom Row (Rates, Active Status & Averages):** Win % (`WinPctCard`), Current Streak (`StreakCard`), and Avg Time (`AvgTimeCard`).
       - **Column 1:** Played (top) and Win % (bottom).
       - **Column 2:** Max Streak (top) and Current Streak (bottom).
       - **Column 3:** Best Time (top) and Avg Time (bottom).
     - Verify metric values render at an enlarged 36px font size.
     - Verify metric category labels render at an enlarged 18px font size.
     - Verify Played, Current Streak, and Max Streak values display as clean integers with no floating-point decimal points.
  5. Inspect the Guess Distribution section:
     - **Heading (`DistHeading`):** Verify `GUESS DISTRIBUTION` renders at an enlarged 24px font size.
     - **Row Heights:** Verify each distribution row ("1".."6", "X") is vertically expanded with a minimum height of 48px (`Vector2(0, 48)`).
     - **Row Indicators:** Verify row indicator labels ("1".."6", "X") render at 24px font size with comfortable 36px container width (`Vector2(36, 0)`).
     - **Bar Labels:** Verify count labels inside the bar panels render at 22px font size with right alignment.
     - **Bar Panel Styling:** Verify distribution bar panels feature 6px rounded corners (`corner_radius = 6`) and scale proportionally with 8px vertical separation.
  6. Switch between "Continuous Play" and "Daily Challenge" tabs:
     - Verify mode transitions preserve the reordered multi-row grid layout and vertical metric pairings identically across both tabs.
     - Verify all values and distribution bars update instantaneously without layout jumping or text clipping.
  7. Tap the `✕` close button and verify the modal dismisses smoothly.
- **Expected Result:** The Statistics Screen presents a 100% opaque dark backdrop (`#121212`) completely obscuring any underlying menu or gameplay elements with zero bleed-through, doubled header and tab typography (52px title, 32px close button / 60x60, 32px tabs), a balanced 3-column by 2-row summary metrics grid with intuitive column pairings (Played & Win %, Max Streak & Current Streak, Best Time & Avg Time) using 36px values and 18px labels, and vertically expanded 48px distribution rows with 24px indicators and 22px bar counts. All elements remain legible and proportionate across standard and tall Android portrait aspect ratios.

### Test 5.15: Main Menu Credits Button, Compact Row Attributions, Circular Logos & Web Icon Links
- **Requirement(s):** REQ-8.1, REQ-8.3, REQ-8.12, REQ-8.14
- **Steps:**
  1. Launch the game and navigate to the Main Menu (`res://scenes/main_menu.tscn`).
  2. Inspect the Main Menu navigation buttons:
     - Verify that a `Credits` button (`CreditsButton`) is positioned directly below `How to Play`.
     - Verify that `CreditsButton` renders with `text = "Credits"`, 36px font size, and custom minimum height of 80px, maintaining uniform styling with `StatsButton` and `HowToPlayButton`.
     - Confirm that the addition of `CreditsButton` maintains the vertical centering and safe margins of the menu layout without overflowing or clipping on standard (720x1280) and tall portrait mobile screens.
  3. Tap the `Credits` button:
     - Verify that `CreditsModal` becomes visible, presenting a dark full-screen overlay (`Color(0, 0, 0, 0.8)`) with a centered vintage-styled container panel.
     - Verify the modal title `CREDITS` is centered at the top in calibrated 64px typography.
     - Verify the expanded modal padding around the panel (64px left/right, 96px top/bottom safe margins).
     - Verify that on a standard 720x1280 mobile portrait screen, all modal elements (title, all three attribution rows, and the dismiss button) fit cleanly without requiring scrolling (while the scroll container remains intact as a safeguard).
  4. Inspect the studio attributions and circular logo badges:
     - Verify each entry is structured as a compact horizontal row (`HBoxContainer`, 16px separation) with expanded 48px vertical spacing between rows, featuring the 50% enlarged logo on the left and a left-aligned text/link column on the right:
       - **Open Game Stack:** Verify the regenerated circular badge logo (`OpenGameStackMonoChrome.png`) renders cleanly at 144x144 with aspect ratio preserved, accompanied by the left-aligned label `"Developed by Open Game Stack"` (24px font) and left-aligned interactive web icon button (`WebIconBtn`, 48x48).
       - **Audrain Entertainment:** Verify the Audrain circular badge logo (`AudrainEntertainment.png`) renders cleanly at 144x144 with aspect ratio preserved, accompanied by the left-aligned label `"Published by Audrain Entertainment"` (24px font) and left-aligned interactive web icon button (`WebIconBtn`, 48x48).
       - **GitHub Open Source:** Verify the regenerated GitHub circular badge logo (`github_icon.png`) renders cleanly at 144x144 with aspect ratio preserved, accompanied by the left-aligned label `"LetterLogic is an open-source game hosted on GitHub"` (24px font) and left-aligned interactive web icon button (`WebIconBtn`, 48x48).
     - Verify that both the attribution text and web icon button are left-justified in the right column.
     - Verify that no raw URL text strings (`https://...`) are visible on the labels or buttons.
  5. Test interactive web icon links:
     - Tap each web icon button (`WebIconBtn`) and verify that each triggers the system browser via `OS.shell_open()` to the respective destination:
       - Open Game Stack: `https://opengamestack.org/`
       - Audrain Entertainment: `https://audrain.games/`
       - GitHub Repository: `https://github.com/OpenGameStack-Games/LetterLogic`
  6. Test modal dismissal:
     - Inspect the dismiss button at the bottom of the modal, verifying `text = "Got It!"`, 36px font size, and 80px minimum height.
     - Tap the `"Got It!"` button and verify that `CreditsModal` closes and the Main Menu is fully interactive again.
- **Expected Result:** The Main Menu features an ergonomically sized Credits button (36px font, 80px height). Tapping it opens a vintage monochrome Credits modal displaying the 64px title, generous 64px/96px window margins, 48px vertical spacing between rows, three compact horizontal attribution rows with uniform 144x144 circular badge logos, 24px attribution labels, left-aligned 48x48 interactive web icon buttons without visible URL strings, fitting entirely within a 720x1280 mobile portrait viewport without scrolling, and an 80px "Got It!" dismiss button that closes the modal cleanly.

### Test 5.16: Game Over Modal Typography Scaling, Doubled Button Height & Inset Action Buttons Layout
- **Requirement(s):** REQ-2.7, REQ-8.1, REQ-8.2, REQ-8.7, REQ-8.16
- **Steps:**
  1. Launch the game in Continuous Play mode.
  2. Complete the puzzle by winning (guess the secret word).
  3. Inspect the Game Over modal visual presentation and layout hierarchy:
     - **Modal Title (`TitleLabel`):** Verify the title (e.g., "Splendid!", "Magnificent!") is rendered at an enlarged 56px font size, centered horizontally.
     - **Summary Message (`MessageLabel`):** Verify the win summary text renders at an enlarged 32px font size, centered horizontally with word wrapping enabled, fitting cleanly without text truncation or clipping.
     - **Button Inset Container (`ButtonMargin`):** Verify that the action buttons container is inset from the left and right edges of the modal panel with 64px horizontal margins (`margin_left = 64`, `margin_right = 64`), shortening button width by ~20% so they present as distinct, centered button components rather than edge-to-edge full-width bars.
     - **Action Buttons (`NextWordButton`, `MenuButton`):**
       - Verify each button has a doubled minimum height of 96px (`custom_minimum_size = Vector2(0, 96)`), providing comfortable, ergonomic touch targets on mobile portrait displays.
       - Verify button text typography is enlarged to 32px (`font_size = 32`).
       - Verify 12px vertical separation between adjacent buttons.
       - Verify buttons exhibit 1930s monochrome styling (dark charcoal fill `#1c1c1e`, 2px solid white border, rounded corners, white text) with smooth hover/pressed state transitions.
  4. Tap "Next Word" to begin a new round.
  5. Deliberately exhaust all 6 attempts to trigger a loss.
  6. Inspect the loss modal:
     - Verify the title "Game Over" renders at 56px font size.
     - Verify the single-line message `The word was <secret>` renders at 32px font size.
     - Verify action buttons maintain 96px minimum height, 32px text font size, 64px horizontal inset margins, and 12px vertical separation.
  7. Start a Daily Challenge game, complete it, and verify that "Share Results" (visible) and "Main Menu" buttons both reflect the doubled 96px height, 32px text font, and 64px inset margins.
- **Expected Result:** The Game Over modal on both win and loss screens (in Continuous Play and Daily Challenge) displays enlarged, legible typography (56px title, 32px message, 32px button text) and doubled-height action buttons (96px) inset with 64px horizontal margins (~20% width reduction) and 12px separation, providing comfortable mobile touch ergonomics and presenting as centered button controls rather than edge-to-edge bars.
 
### Test 5.17: Android Adaptive Launcher Icon Verification
- **Requirement(s):** REQ-8.4, REQ-8.17
- **Steps:**
  1. Export an Android APK or AAB build using the configured Android export preset (`game/export_presets.cfg`).
  2. Install the build on a physical Android device or emulator running Android 8.0 (API 26) or higher.
  3. Inspect the LetterLogic launcher icon on the home screen and app drawer across different launcher mask styles (e.g. circle, rounded square, squircle, teardrop).
  4. Verify the mascot foreground (`res://assets/icons/icon_foreground.png`, 432x432) remains centered and within the safe zone (~66% inner circle), avoiding edge clipping.
  5. Verify the background layer (`res://assets/icons/icon_background.png`, 432x432) seamlessly fills the outer mask shape with the dark monochrome background color (`#121213`).
  6. (Optional) Touch and drag the icon or trigger launcher parallax motions to verify that the foreground and background layers animate smoothly with native depth.
- **Expected Result:** The application launcher icon adapts dynamically to the Android system mask shape, presenting the mascot centered with sharp contrast against the solid background with zero distorted borders or clipped art.

### Test 5.18: Game Board Vertical Space Utilization & Full Keyboard Visibility on Android
- **Requirement(s):** REQ-8.7, REQ-8.9
- **Steps:**
  1. Launch the game on a physical Android device (e.g., Samsung Galaxy S22 or compact portrait smartphone) or simulate a short aspect ratio portrait window in the Godot Editor.
  2. Start a puzzle in Continuous Play or Daily Challenge mode.
  3. Inspect the vertical layout of the main game screen:
     - **Game Board:** Verify that the `GameBoard` grid expands to fill the available vertical space in `BoardArea` between the header/toast and keyboard without leaving an empty dark gap above the tiles. Verify the 5:6 aspect ratio is preserved and tiles remain square.
     - **Keyboard Visibility:** Verify that all three keyboard rows are completely visible on screen without clipping or cutoff at the bottom:
        - Row 1: `Q W E R T Y U I O P`
        - Row 2: `A S D F G H J K L`
        - Row 3: `⌫  Z X C V B N M  ENTER`
     - **Bottom Margin:** Confirm the 24px bottom margin provides clean spacing above the system navigation bar or screen bottom without truncating row 3 keys.
     - **Non-Overlap:** Confirm that the header, board area, and keyboard wrapper remain strictly sequential in the vertical layout hierarchy without overlapping or crowding each other during typing and gameplay.
  4. Test on a wider portrait tablet screen (4:3 or 16:10) and confirm the board expands proportionally and all three keyboard rows remain fully visible.
- **Expected Result:** On physical Android devices and simulated portrait aspect ratios, the game board grid fills the vertical space between the header and keyboard without leaving an empty dark gap, all three rows of the virtual keyboard are fully visible without bottom clipping, and the entire layout remains unclipped and non-overlapping.

### Test 5.19: How to Play Modal Dynamic Shrink-to-Fit Text Scaling & Non-Scrolling Presentation
- **Requirement(s):** REQ-8.6
- **Steps:**
  1. Launch the application to the Main Menu (`res://scenes/main_menu.tscn`).
  2. Tap the "How to Play" button (`HowToPlayButton`) to open the instructions modal (`HowToPlayModal`).
  3. Inspect the modal visual presentation on a standard 720x1280 viewport:
     - Verify the title "HOW TO PLAY" displays at 84px font size.
     - Verify the body text (`RulesText`) displays at the base 32px font size (`normal_font_size = 32`, `bold_font_size = 32`).
     - Verify the "Got It!" button displays at 36px font size with 80px minimum height.
     - Verify all instructional text, color indicators, and bullet points fit cleanly within the modal panel.
  4. Test scrolling behavior:
     - Attempt to scroll the text vertically by dragging or using the mouse wheel / touch gestures over `RulesText`.
     - Confirm that vertical scrolling is completely disabled (`scroll_active = false`) and no scrollbar appears.
  5. Test dynamic text scaling on a compact portrait display or reduced window height (e.g. Samsung Galaxy S22 or compact Android smartphone, or by resizing the game window vertically in windowed mode):
     - Resize the window to a shorter height or run on a compact portrait device.
     - Reopen or observe the How to Play modal.
     - Verify that `RulesText` dynamically decreases its font size (stepping down both normal and bold sizes proportionally towards the 14px safety floor) so the entire rules text fits within the available vertical container height.
     - Confirm that no text is clipped, truncated, or pushed behind the "Got It!" button.
  6. Tap "Got It!" to dismiss the modal and confirm return to the Main Menu.
- **Expected Result:** The How to Play modal body text dynamically scales its font size down on compact or shorter portrait displays to fit the available vertical budget without text truncation or clipping. Vertical scrolling is completely disabled (`scroll_active = false`), eliminating the need to scroll to read the complete rules, while preserving the fixed title, button sizing, and 24px inner margins.

### Test 5.20: Android Non-Immersive Mode & Display Cutout / Safe Area Verification
- **Requirement(s):** REQ-8.18
- **Steps:**
  1. Export an Android APK or AAB using the configured Android export preset (`game/export_presets.cfg`) where Immersive Mode is disabled (`screen/immersive_mode=false`).
  2. Install and launch the build on a physical Android device or emulator featuring a camera notch or punch-hole display cutout (e.g., Google Pixel or Samsung Galaxy device) and system navigation bar / gesture navigation.
  3. Verify that Android Immersive Mode is disabled:
     - The Android system status bar (clock, battery, notification icons) remains visible at the top of the screen.
     - The Android system navigation bar (or 3-button / gesture bar) remains visible at the bottom of the screen.
     - The system bars are not hidden or overlaid in full-screen mode.
  4. Inspect the visual layout across all screens (Main Menu, Continuous Play, Daily Challenge, Statistics modal, How to Play modal, and Credits modal):
     - Confirm that the top UI elements (header, title, mascot, navigation back button, statistics button) start cleanly below the system status bar and any hardware cutout or notch area without clipping or collision.
     - Confirm that bottom UI elements (virtual keyboard, action buttons, modal dismiss buttons) remain comfortably positioned above the navigation bar or gesture insets.
     - Confirm that all screens compress smoothly to the reduced vertical viewport height without overlapping or clipping elements.
- **Expected Result:** The Android status bar and navigation bar remain visible at all times during application usage (Immersive Mode off). Safe area insets are properly recognized by Godot, ensuring the UI starts below hardware display cutouts and above system navigation bars with zero element collision or overlap across all screens.

### Test 5.21: Proportional Virtual Keyboard Grid Layout & Stretch Ratio Verification
- **Requirement(s):** REQ-8.7
- **Steps:**
  1. Launch a game in Continuous Play or Daily Challenge mode.
  2. Inspect the virtual keyboard layout at the bottom of the screen:
     - **Uniform Letter Widths:** Verify that all standard letter keys across Row 1 (Q–P), Row 2 (A–L), and Row 3 (Z–M) have mathematically uniform widths (`size_flags_stretch_ratio = 1.0`), so characters like 'W' and 'I' occupy the exact same key width.
     - **Action Key Widths:** Verify that the `⌫` (Delete/Backspace) and `ENTER` keys on Row 3 are exactly 50% wider than standard letter keys (`size_flags_stretch_ratio = 1.5`).
     - **Row 2 Centering & Stagger:** Verify that Row 2 is centered under Row 1, with the `LeftStaggerSpacer` and `RightStaggerSpacer` creating an inset of exactly half a standard key width (`size_flags_stretch_ratio = 0.5`).
     - **Vertical Column Alignment:** Verify that keys in Row 3 align properly with Row 2 (e.g., Z directly under S, X directly under D).
     - **X-Axis Flexibility:** Verify keys and spacers do not enforce rigid X-axis minimum pixel constraints (`custom_minimum_size.x = 0.0`), allowing Godot's proportional flex container to govern key sizing.
  3. Test across various viewport aspect ratios:
     - **Extremely Narrow Display (e.g. 9:21 / 1080x2520):** Confirm key widths scale down uniformly without overlapping, label clipping, or container overflow.
     - **Standard Portrait Display (9:16 / 720x1280):** Confirm clean Wordle-style proportion and comfortable touch targets.
     - **Ultra-Wide / Tablet Portrait Display (4:3 or 16:10):** Confirm key widths expand proportionally and uniform letter widths and 1.5x action key proportions are preserved.
- **Expected Result:** The virtual keyboard strictly utilizes proportional sizing (`size_flags_stretch_ratio`) without hardcoded X-axis pixel minimums. All standard letter keys are uniformly sized (1.0), action keys are 1.5x standard width (1.5), Row 2 is centered with 0.5x spacers on each side, and the grid adapts cleanly across extremely narrow and wide viewport aspect ratios without distortion or clipping.

---

## 6. Build, CI/CD & Platform Packaging

### Test 6.1: Android 16 KB Page Alignment & Google Play Release Verification
- **Requirement(s):** REQ-9.1
- **Steps:**
  1. Export an Android App Bundle (`.aab`) using the Godot Android export preset (`game/export_presets.cfg`) or trigger the automated GitHub Actions CI release workflow (`.github/workflows/android_release.yml`). Prefer using the CI workflow because it performs post-export validation automatically.
  2. Confirm the project is using Godot Android templates with an updated `.build_version` (e.g., `game/android/.build_version` contains `4.7.2.stable`) and that the Android Gradle Plugin / Gradle wrapper are compatible with that template (the branch updates use AGP `8.6.1` and Gradle `8.11.1`).
  3. Locally (or in CI) validate the signed AAB and its generated APKs using the included validator and Bundletool:
     - Run the ELF/PT_LOAD check on the signed AAB (replace `LetterLogic.aab` with the produced file):
       ```bash
       python scripts/validate_android_16kb.py LetterLogic.aab
       ```
       This reports ELF PT_LOAD alignments for native libraries inside the AAB. 64-bit ABIs (`arm64-v8a`, `x86_64`) must have PT_LOAD alignments of `16384` (16 KiB).
     - Build APKs from the signed AAB with Bundletool and validate the generated APK payloads strictly:
       ```bash
       java -jar bundletool-all-<version>.jar build-apks --bundle=LetterLogic.aab --output=LetterLogic.apks --mode=universal
       python scripts/validate_android_16kb.py --strict-zip LetterLogic.apks
       unzip -q -o LetterLogic.apks -d apks_extracted
       zipalign -c -P 16 -v 4 apks_extracted/*.apk
       ```
       The `--strict-zip` check ensures native libraries are stored (not compressed) and are data-aligned to 16 KiB inside generated APKs; `zipalign -c -P 16` verifies alignment at the APK level.
  4. Optionally, upload the signed `.aab` to the Google Play Console (Internal Testing or Closed Testing) and inspect the Play Console upload validation report for any 16 KB page-size warnings.
- **Expected Result:** The local/CI validation reports no ELF or ZIP alignment errors (ELF PT_LOAD alignments for 64-bit ABIs are 16384, and the strict ZIP checks pass). The AAB uploads to the Play Console without any "does not support 16 KB memory page sizes" warnings and is accepted for Android 15+ devices.

### Test 6.2: Android Native Debug Symbols & Obfuscation Mapping Packaging
- **Requirement(s):** REQ-9.2
- **Steps:**
  1. Trigger or execute the Android release workflow (`.github/workflows/android_release.yml`) or run a local Gradle export with `gradle_build/export_debug_symbols=true`.
  2. Verify that the build output generates `LetterLogic-Android-native-debug-symbols.zip` (or matching glob `*-native-debug-symbols.zip`) in the Godot project root / export destination.
  3. Verify that Gradle outputs `mapping.txt` in `game/android/build/outputs/mapping/release/mapping.txt`.
  4. Verify that the GitHub Actions artifact `LetterLogic-Android` contains the `.aab`, `*-native-debug-symbols.zip`, and `mapping.txt`.
  5. (Optional) Upload the bundle and its corresponding native debug symbols and mapping file to Google Play Console App Bundle Explorer.
- **Expected Result:** Google Play Console accepts the debug symbols and mapping file without throwing missing native debug symbols or missing obfuscation file warnings.

### Test 6.3: Android Runtime Dictionary Packaging & Startup Validation
- **Requirement(s):** REQ-9.3
- **Steps:**
  1. Export an Android APK or AAB using the configured Android export preset (`game/export_presets.cfg`) with the runtime dictionary include filter enabled.
  2. Install the build on an Android device or emulator and launch either Continuous Play or Daily Challenge from a cold start.
  3. Verify the startup log reports a non-empty dictionary load, such as `WordBank: Loaded <n> unique 5-letter isograms.`, and that no `push_error(...)` message reports an empty or missing word list.
  4. Enter the reference words `ADORE` and `THANK` during gameplay.
- **Expected Result:** The Android build loads a non-empty runtime dictionary on startup, both reference words are accepted as valid guesses, and the game no longer rejects every guess with a "word not in list" outcome.

### Test 6.4: Web Export Preset & Itch.io CI/CD Deployment Verification
- **Requirement(s):** REQ-9.5, REQ-9.6, REQ-9.7
- **Steps:**
  1. Verify the GitHub repository secrets are properly configured in the repository settings:
     - `BUTLER_API_KEY`: Butler API key generated from itch.io developer settings.
     - `ITCH_USERNAME`: Account name on itch.io.
     - `ITCH_GAME`: Project identifier/slug on itch.io (e.g., `letterlogic`).
  2. Navigate to GitHub Actions and trigger the **Web Export & Itch.io Deploy** workflow (`web_release.yml`) via manual workflow dispatch (`workflow_dispatch`), or push a release tag matching `v*`.
  3. Monitor the workflow execution:
     - Confirm that source checkout, Godot installation, asset import, and headless test suite execution pass with zero errors.
     - Confirm that Godot exports the Web build headlessly to `game/export/web/index.html`.
     - Confirm that the `LetterLogic-Web` workflow artifact is uploaded and downloadable.
     - Confirm that Butler publishes the package to itch.io under channel `html`.
  4. Once deployment succeeds, open the game URL on itch.io or test an embedded `iframe` (e.g., on GitHub Pages `audrain.games/letterlogic`).
  5. Inspect browser developer tools (Console and Network tabs):
     - Confirm that the web game loads and initializes smoothly.
     - Confirm that no `SharedArrayBuffer` or Cross-Origin Isolation (COOP/COEP) header errors are thrown.
     - Confirm the game can be played in both Continuous Play and Daily Challenge modes in the browser.
- **Expected Result:** The GitHub Actions workflow successfully compiles the single-threaded HTML5/WebAssembly build, uploads the artifact, and publishes the package to itch.io via Butler. The web build loads and runs cleanly in standard desktop and mobile browsers and within embedded iframes without requiring Cross-Origin Isolation headers.
