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

### Test 1.2: Dictionary and Length Validation
- **Requirement(s):** REQ-3.2, REQ-3.3
- **Steps:**
  1. Start a game.
  2. Type 4 letters (e.g., "ABCD") and submit. Verify it is rejected (needs 5 letters).
  3. Type 5 letters of an invalid word (e.g., "QWERT") and submit. 
- **Expected Result:** The game shows an "invalid word" or "not in word list" notification. The row does not advance, and the attempt is not consumed.

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
  2. Tap the Statistics icon button in the header to open the Stats Screen overlay.
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
- **Requirement(s):** REQ-7.1
- **Steps:**
  1. Complete games to record valid Best Time and Avg Time statistics.
  2. Complete today's Daily Challenge.
  3. Close the application entirely.
  4. Reopen the application.
- **Expected Result:** All summary cards (Played, Win %, Current Streak, Max Streak, Best Time, Avg Time) and guess distributions retain their exact values. The Daily Challenge remains locked out with an accurate countdown timer.

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

