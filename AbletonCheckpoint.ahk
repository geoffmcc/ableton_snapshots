#Requires AutoHotkey v2.0
#SingleInstance Force

global lastProjectPath := ""
global PROJECT_SEARCH_ROOT := GetProjectSearchRoot()

#HotIf IsAbletonActive()

; Change these hotkeys if F8 conflicts with your existing Ableton shortcuts.
+F8:: {
    global lastProjectPath
    lastProjectPath := ""
    TrayTip "Ableton Checkpoint", "Cached project cleared", 2
}

F8:: {
    path := GetProjectPath()

    if (path = "" || !DirExist(path)) {
        MsgBox "Select a project folder first."
        return
    }

    SplitPath(path,,,,, &projectName)

    timestamp := FormatTime(, "yyyy-MM-dd_HH-mm-ss")
    noteResult := InputBox(
        "Describe this checkpoint:`n`nFor the most complete rollback point, run Ableton's File > Collect All and Save before pressing F8, especially after adding new samples, recordings, resampled audio, or external media.`n`nIf you have not done that and this checkpoint needs those files included, press Cancel now, run Collect All and Save in Ableton, then press F8 again.`n`nIf nothing new has been added since the last collect/save, you usually do not need to collect all again.",
        "Ableton Checkpoint Note",
        "w560 h300"
    )

    if (noteResult.Result = "Cancel")
        return

    checkpointRoot := path "\checkpoints"
    checkpointPath := checkpointRoot "\" timestamp

    DirCreate(checkpointRoot)
    DirCreate(checkpointPath)

    SaveCheckpointNote(checkpointPath, timestamp, projectName, path, noteResult.Value)

    Loop Files path "\*", "FD" {
        if InStr(A_LoopFileFullPath, "\checkpoints")
            continue

        CopyItem(A_LoopFileFullPath, checkpointPath "\" A_LoopFileName)
    }

    TrayTip "Checkpoint Saved", timestamp, 2
}

#HotIf

IsAbletonActive() {
    try {
        processName := WinGetProcessName("A")
    } catch {
        return false
    }

    return InStr(processName, "Ableton Live")
}

GetProjectSearchRoot() {
    configuredRoot := EnvGet("ABLETON_CHECKPOINT_PROJECT_ROOT")

    if (configuredRoot != "")
        return configuredRoot

    return EnvGet("USERPROFILE") "\Documents\Ableton Projects"
}

GetProjectPath() {
    global lastProjectPath

    detectedPath := DetectAbletonProjectPath()

    if (detectedPath != "") {
        lastProjectPath := detectedPath
        return detectedPath
    }

    if (lastProjectPath != "" && DirExist(lastProjectPath))
        return lastProjectPath

    path := DirSelect(, 3, "Select Ableton Project Folder")

    if (path != "")
        lastProjectPath := path

    return path
}

DetectAbletonProjectPath() {
    global PROJECT_SEARCH_ROOT

    if (!DirExist(PROJECT_SEARCH_ROOT))
        return ""

    title := WinGetTitle("A")
    setName := GetAbletonSetNameFromTitle(title)

    if (setName = "")
        return ""

    matches := []
    Loop Files PROJECT_SEARCH_ROOT "\*.als", "FR" {
        if InStr(StrLower(A_LoopFileFullPath), "\checkpoints\")
            continue

        SplitPath(A_LoopFileName,,,, &nameNoExt)
        if (StrLower(nameNoExt) = StrLower(setName)) {
            SplitPath(A_LoopFileFullPath,, &folder)
            matches.Push(folder)
        }
    }

    if (matches.Length = 1)
        return matches[1]

    if (matches.Length > 1) {
        message := "Multiple Ableton sets named '" setName "' were found:`n`n"
        for , folder in matches
            message .= folder "`n"
        message .= "`nSelect the correct project folder."
        MsgBox message
    }

    return ""
}

GetAbletonSetNameFromTitle(title) {
    if (!InStr(title, "Ableton Live"))
        return ""

    title := RegExReplace(title, "\s+-\s+Ableton Live.*$", "")
    title := RegExReplace(title, "\s+\[.*?\]$", "")
    title := RegExReplace(title, "\*$", "")
    title := Trim(title)

    if (title = "" || title = "Untitled")
        return ""

    return title
}

SaveCheckpointNote(checkpointPath, timestamp, projectName, projectPath, note) {
    noteText := "Checkpoint: " timestamp "`n"
        . "Project: " projectName "`n"
        . "Path: " projectPath "`n`n"
        . "Note:`n"
        . note "`n"

    FileAppend(noteText, checkpointPath "\note.txt", "UTF-8")
}

CopyItem(src, dest) {
    if DirExist(src)
        DirCopy(src, dest, true)
    else
        FileCopy(src, dest)
}
