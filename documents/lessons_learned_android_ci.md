# Lessons Learned: Godot 4 Headless Android Export on GitHub Actions

Exporting a Godot 4 Android App Bundle (.aab) headlessly via GitHub Actions contains several undocumented edge cases and bugs. This document serves as a record of the issues encountered and the necessary workarounds to successfully build and sign an Android release.

## 1. The Godot 4.3 \.tres\ Parser is Extremely Strict
Godot's \editor_settings-4.3.tres\ requires a very specific syntax. If you dynamically generate this file in a bash script to inject the \\\ and \\\ environment variables, you **must** include a completely blank line between the \[gd_resource]\ header and the \[resource]\ block.

**Bug:** If the blank line is missing, the Godot Resource Parser will silently fail to parse the file and completely ignore your injected SDK paths.
**Fix:** Ensure a blank line exists before \[resource]\ in any manually generated \.tres\ files.

## 2. Editor Settings Are Aggressively Wiped During Headless Asset Import
When Godot runs a headless command like \godot --editor --quit\ to import assets, it forcibly saves the editor settings upon exiting. If the Android export templates aren't fully configured or active in memory during this step, Godot may overwrite \editor_settings-4.3.tres\ and purge the Android SDK paths.
**Fix:** Always generate or modify the \editor_settings-4.3.tres\ file *after* running the initial headless asset import step, right before the actual export command.

## 3. Blank Configuration Errors
When Godot 4 fails an export configuration check (e.g., missing a keystore or missing ETC2 compression), it is supposed to output the reason. However, due to a bug in the \has_valid_export_configuration()\ C++ function in Godot 4.3, some error flags are set without appending the actual error text.
**Bug:** You will receive the generic error \ERROR: Cannot export project with preset "Android" due to configuration errors:\ followed by absolute silence.
**Fix:** Ensure all prerequisites below are met, as Godot will not explicitly tell you which one failed.

## 4. ETC2/ASTC Texture Compression is Strictly Required
When building through the Godot Editor GUI, the editor will display a large red warning if you try to export to Android without enabling ETC2/ASTC texture compression. Headless export does not give this warning; it simply fails with a blank configuration error (see #3).
**Fix:** Ensure the following is in your \project.godot\ file:
\\\ini
[rendering]
textures/vram_compression/import_etc2_astc=true
\\\

## 5. Export Presets Require Keystore Paths Even for Unsigned Builds
When exporting an Android App Bundle using Gradle, Godot requires the \export_presets.cfg\ to contain a valid keystore path in the \keystore/release\ property. Even if you have \package/signed=false\ or plan to sign the app later using GitHub Actions, Godot will refuse to export if this path is empty or points to a non-existent file. Furthermore, Godot strictly expects paths in \export_presets.cfg\ to be relative to the Godot project root (e.g., \es://\).
**Fix:** Generate a dummy keystore inside the Godot project directory and point \export_presets.cfg\ to it (\es://debug.keystore\). You can then strip and re-sign the resulting unsigned \.aab\ using a dedicated GitHub Action later in the pipeline.

## 6. The Hidden \.build_version\ File in Gradle Templates
When you click "Install Android Build Template" in the Godot GUI, Godot extracts the \ndroid_source.zip\ into the \ndroid/build/\ directory. Crucially, it also creates a hidden file named \.build_version\ in the parent directory (\ndroid/\). This file contains the exact engine version string (e.g., \4.3.stable\). 
If you commit the extracted template to Git and this hidden file is lost or missing, Godot's headless export will fail with: \Trying to build from a gradle built template, but no version info for it exists.\
**Fix:** Manually create \ndroid/.build_version\ and ensure it contains the exact Godot version string (e.g., \4.3.stable\).

## 7. Windows Strips Executable Permissions from \gradlew\
If the Android build template is extracted and committed to Git from a Windows machine, the \gradlew\ (Gradle Wrapper) script will lose its Linux executable permissions. When GitHub Actions (running on Ubuntu) attempts to invoke Gradle, it will fail with \Permission denied\.
**Fix:** Add a step in the GitHub workflow to restore the permissions before exporting: \chmod +x game/android/build/gradlew\.


## 8. Android 16 KB Memory Page Size Support
Google Play requires apps targeting Android 15+ to support 16 KB memory page sizes. Apps that are not recompiled to support this will fail to load or crash on 16 KB page-size devices.
**Fix:** Godot 4.3 natively compiles its shared libraries with 16 KB alignment. However, older Android Gradle Plugin (AGP) versions (like 8.2) package uncompressed native libraries with a 4 KB zip alignment, causing Google Play to reject the build. Upgrading the Android Gradle Plugin to `8.5.2` (and Gradle to `8.7`) forces AGP to 16 KB zip-align uncompressed shared libraries correctly.

## 9. Native Debug Symbols and Obfuscation Mapping
Google Play Console flags warnings if native symbols and obfuscation mapping files are not uploaded with the Android App Bundle.
**Fix:** In `game/export_presets.cfg`, enable `gradle_build/export_debug_symbols=true`. When exporting with Gradle, Godot outputs `*-native-debug-symbols.zip` in the root export directory and Gradle produces `mapping.txt` at `game/android/build/outputs/mapping/release/mapping.txt`. Include these paths in the artifact upload step in `.github/workflows/android_release.yml`.
