$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $PSCommandPath
$checkpointScript = Join-Path $scriptDir 'AbletonCheckpoint.ahk'

function Get-AbletonPath {
    $shortcutPath = 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Ableton Live 12 Suite.lnk'

    if (Test-Path -LiteralPath $shortcutPath) {
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)

        if ($shortcut.TargetPath -and (Test-Path -LiteralPath $shortcut.TargetPath)) {
            return $shortcut.TargetPath
        }
    }

    $matches = Get-ChildItem -LiteralPath 'C:\ProgramData\Ableton' -Filter 'Ableton Live *.exe' -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -like '*\Live *\Program\Ableton Live *.exe' } |
        Sort-Object FullName -Descending

    if ($matches) {
        return $matches[0].FullName
    }

    throw 'Could not find Ableton Live. Expected it under C:\ProgramData\Ableton\Live *\Program\.'
}

function Get-AutoHotkeyPath {
    $commands = @('AutoHotkey64.exe', 'AutoHotkey.exe', 'AutoHotkey32.exe')

    foreach ($command in $commands) {
        $resolved = Get-Command $command -ErrorAction SilentlyContinue

        if ($resolved) {
            return $resolved.Source
        }
    }

    $knownPaths = @(
        'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe',
        'C:\Program Files\AutoHotkey\AutoHotkey64.exe',
        'C:\Program Files\AutoHotkey\AutoHotkey.exe',
        'C:\Program Files (x86)\AutoHotkey\AutoHotkey.exe'
    )

    foreach ($path in $knownPaths) {
        if (Test-Path -LiteralPath $path) {
            return $path
        }
    }

    throw 'Could not find AutoHotkey. Install AutoHotkey v2 or add it to PATH.'
}

if (!(Test-Path -LiteralPath $checkpointScript)) {
    throw "Could not find checkpoint script: $checkpointScript"
}

$abletonPath = Get-AbletonPath
$autoHotkeyPath = Get-AutoHotkeyPath
$ahkProcess = $null

try {
    $abletonProcess = Start-Process -FilePath $abletonPath -PassThru
    $ahkProcess = Start-Process -FilePath $autoHotkeyPath -ArgumentList @($checkpointScript) -PassThru

    Wait-Process -Id $abletonProcess.Id

    while (Get-Process | Where-Object { $_.ProcessName -like 'Ableton Live*' }) {
        Start-Sleep -Seconds 3
    }
} finally {
    if ($ahkProcess -and !(Get-Process -Id $ahkProcess.Id -ErrorAction SilentlyContinue).HasExited) {
        Stop-Process -Id $ahkProcess.Id -ErrorAction SilentlyContinue
    }
}
