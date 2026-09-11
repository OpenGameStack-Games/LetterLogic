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

---

## 2. Game Modes

### Test 2.1: Continuous Play Reset
- **Requirement(s):** REQ-4.1
- **Steps:**
  1. Start a Continuous Play game.
  2. Complete the game (win or lose).
  3. Select the option to play again.
- **Expected Result:** The board resets immediately, and a new random word is chosen.

### Test 2.2: Daily Challenge Synchronization & Lockout
- **Requirement(s):** REQ-4.2, REQ-4.3
- **Steps:**
  1. Start a Daily Challenge game.
  2. Note the target word.
  3. Complete the Daily Challenge (win or lose).
  4. Return to the main menu and attempt to play the Daily Challenge again.
  5. (Optional) Change the device date to tomorrow and verify the Daily Challenge unlocks with a new word.
- **Expected Result:** After completion, the player is locked out of the Daily Challenge until the next UTC midnight. The menu shows a countdown timer.

---

## 3. Statistics and Persistence

### Test 3.1: Stats Segregation and Tracking
- **Requirement(s):** REQ-5.1, REQ-5.2
- **Steps:**
  1. Play and win a Continuous mode game. Check the stats screen; Continuous wins should increment by 1.
  2. Play and lose a Daily mode game. Check the stats screen; Daily losses should increment by 1, while Continuous stats remain unchanged.

### Test 3.2: Save State Persistence
- **Requirement(s):** REQ-7.1
- **Steps:**
  1. Complete a few games to generate stats.
  2. Complete today's Daily Challenge.
  3. Close the application entirely.
  4. Reopen the application.
- **Expected Result:** The stats screen retains the previous session's metrics. The Daily Challenge remains locked out with an accurate countdown timer.

---

## 4. Social Sharing

### Test 4.1: Native Share intent (Android)
- **Requirement(s):** REQ-6.1, REQ-6.2
- **Steps (Android device required):**
  1. Complete a Daily Challenge.
  2. Tap the "Share" button on the results screen.
- **Expected Result:** The Android native share sheet appears. Selecting a destination (e.g., Messages, Keep Notes) pastes a formatted string containing the date, score (e.g., 3/6), emoji grid (🟩🟨🟥), and the Google Play Store link.

### Test 4.2: Clipboard Fallback (Godot PC)
- **Requirement(s):** REQ-6.2
- **Steps:**
  1. Run the project in the Godot Editor on a PC.
  2. Complete a Daily Challenge and tap "Share".
  3. Open Notepad and press `Ctrl+V`.
- **Expected Result:** The same formatted share string with the emoji grid (🟩🟨🟥) is pasted from the clipboard.

