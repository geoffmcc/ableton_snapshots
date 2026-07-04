# Ableton Snapshots

Project-folder rollback snapshots for Ableton Live.

Ableton Snapshots is a small Windows helper for making fast, timestamped rollback points while working in Ableton Live.

Use it before risky edits, big arrangement changes, resampling, flattening tracks, sound-design experiments, or anything else you might want to undo cleanly. After saving or collecting the project, press `F8`, write a quick note, and the script copies the current Ableton project into a timestamped `snapshots` folder inside that same project.

If the experiment works, keep going. If it does not, open the copied `.als` file inside the timestamped snapshot folder and you are back at the project state from the moment you pressed `F8`.

Ableton Snapshots is not an instant in-session recall tool. Restoring a snapshot means opening the copied `.als` file from the timestamped snapshot folder.

## Who This Is For

Ableton Snapshots is for producers who want quick project-level rollback points before destructive or messy changes.

It is useful when you are about to resample, flatten tracks, rearrange a project, try a risky sound-design idea, or make changes that may be annoying to undo later.

Unlike an incremental `.als` save, this creates a timestamped copy of the project folder, plus a note, inside that project's own `snapshots` directory.

## Who This Is Not For

This is not an instant mixer, device, or performance snapshot system. It does not switch states inside the currently open Ableton set.

Restoring a snapshot means opening the copied `.als` file from the timestamped snapshot folder.

## What It Does

- Works only while Ableton Live is the active window.
- Press `F8` to snapshot the current project.
- Prompts for a short note describing what you are about to try.
- Detects the active Ableton set from the window title.
- Finds the matching `.als` file under your configured project search root.
- Copies the project folder into `snapshots/YYYY-MM-DD_HH-mm-ss`.
- Writes a `note.txt` file with the timestamp, project name, source path, and your note.
- Skips existing `snapshots` folders so snapshots do not recursively copy themselves.

Each project keeps its own rollback history. You do not end up with one giant central snapshot directory full of unrelated projects.

```text
My Song/
  My Song.als
  Samples/
  snapshots/
    2026-07-04_14-32-10/
    2026-07-04_15-08-44/
    2026-07-04_16-21-03/
```

## Important: Collect All and Save

Ableton Snapshots copies the current project folder. For the most complete rollback point, run **File > Collect All and Save** in Ableton before pressing `F8`, especially after adding new samples, recordings, resampled audio, or external media.

If you have not done that and the snapshot needs those files included, cancel the snapshot, run **Collect All and Save**, then press `F8` again.

If nothing new has been added since the last time you collected and saved, you usually do not need to run **Collect All and Save** again before every snapshot. In that case, make sure the set is saved, then press `F8`.

Ableton Snapshots does not automate **Collect All and Save**. That keeps the tool predictable and avoids brittle menu/dialog automation across Ableton versions and setups.

## Hotkeys

- `F8`: create a snapshot.
- `Shift+F8`: clear the cached project folder.

The hotkeys are active only while Ableton Live is the active window, so `F8` and `Shift+F8` keep their normal behavior elsewhere.

## Requirements

- Windows
- Ableton Live
- AutoHotkey v2
- PowerShell

Ableton Snapshots uses AutoHotkey v2 for the `F8` and `Shift+F8` hotkeys. AutoHotkey v1 is not compatible with this script.

## First-Time Setup

Download or clone this repo, then run the installer once from the project folder:

```powershell
.\Install-AbletonSnapshots.ps1
```

If you are not comfortable with PowerShell, right-click `Install-AbletonSnapshots.ps1` and choose **Run with PowerShell**.

The installer asks where your Ableton projects live and creates or updates a Desktop shortcut named `Ableton Live with Snapshots`.

Use that shortcut instead of launching Ableton directly. The generated shortcut starts Ableton Live and the AutoHotkey snapshot helper together. The helper stays running while Ableton is open, then the launcher stops it after Ableton closes.

The generated shortcut uses the default PowerShell or Windows script icon. If you want it to look like Ableton, right-click the shortcut, choose **Properties**, select **Change Icon**, and pick Ableton Live's icon or any custom icon you prefer.

## Project Search Root

By default, the script searches recursively under:

```text
%USERPROFILE%\Documents\Ableton Projects
```

That default works for simple setups where all Ableton projects live under one folder.

For larger libraries, it is better to point the script at the most specific folder you are actively using. This keeps project detection faster and reduces duplicate matches when different projects or years contain Ableton sets with the same name.

If you organize projects by year, point the search root at the current year:

```text
%USERPROFILE%\Documents\Ableton Projects\2026
```

You do not have to organize by year. You can point Ableton Snapshots at any folder structure that makes sense for your setup, such as:

```text
%USERPROFILE%\Documents\Ableton Projects\Active
D:\Music\Ableton Projects
E:\Sessions\Client Work
```

The installer stores your choice in the user environment variable `ABLETON_SNAPSHOT_PROJECT_ROOT`. You normally do not need to edit that manually.

## Changing The Project Folder Later

You can run `Install-AbletonSnapshots.ps1` again at any time to change where the script looks for Ableton projects.

Use this when a new year starts, you move your Ableton projects to a different drive, you want to focus on a smaller active folder, or you switch between personal projects, client work, and archive folders.

For example, if you organize projects by year:

```text
Documents\Ableton Projects\2026
Documents\Ableton Projects\2027
```

When 2027 starts:

1. Right-click `Install-AbletonSnapshots.ps1`.
2. Choose **Run with PowerShell**.
3. Choose the option to select a specific project folder.
4. Pick `%USERPROFILE%\Documents\Ableton Projects\2027`.
5. Choose yes when asked to create or update the Desktop shortcut.
6. Keep using the same `Ableton Live with Snapshots` shortcut.

The shortcut does not need to change unless you move the Ableton Snapshots tool folder itself. If you do move this folder, run the installer again and choose to update the shortcut.

## Snapshot Layout

Snapshots live inside the project they came from:

```text
My Song/
  My Song.als
  Samples/
  snapshots/
    2026-07-04_14-32-10/
      My Song.als
      Samples/
      note.txt
    2026-07-04_15-08-44/
      My Song.als
      Samples/
      note.txt
```

This keeps each project's rollback points with that project. Snapshots are full copied project states, not diffs.

## Existing AutoHotkey Users

Ableton Snapshots can run alongside your other AutoHotkey scripts. The launcher starts this project's `AbletonSnapshot.ahk` helper and stops only that helper after Ableton closes.

Launching the shortcut again replaces any previous instance of this same helper script, but it does not intentionally close unrelated AutoHotkey scripts.

If you already use `F8` or `Shift+F8` in another AutoHotkey script while working in Ableton, change the hotkey lines near the top of `AbletonSnapshot.ahk`:

```ahk
F8:: {
+F8:: {
```

This project requires AutoHotkey v2. AutoHotkey v1 is not compatible with this script.

## Notes

- Large projects may take time and disk space to copy.
- This is not a replacement for full backups.
- This is a project rollback tool, not an instant in-session mixer or device snapshot system.
- Snapshots copy the project folder as it exists on disk. Use **Collect All and Save** before `F8` when you need external samples copied into the project.
- Project detection depends on the Ableton window title matching an `.als` file under your configured project search root.
- If multiple matching sets are found, the script asks you to select the correct project folder.
- If no matching project is found, the script asks you to select the project folder manually and caches that choice until you clear it or close the helper.

## License

MIT
