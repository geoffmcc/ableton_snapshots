$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $PSCommandPath
$launcherPath = Join-Path $scriptDir 'Start-AbletonSnapshots.ps1'
$shortcutName = 'Ableton Live with Snapshots.lnk'
$shortcutPath = Join-Path ([Environment]::GetFolderPath('Desktop')) $shortcutName
$defaultProjectRoot = Join-Path $env:USERPROFILE 'Documents\Ableton Projects'
$envVarName = 'ABLETON_SNAPSHOT_PROJECT_ROOT'

function Get-ConfiguredProjectRoot {
    return [Environment]::GetEnvironmentVariable($envVarName, 'User')
}

function Show-CurrentProjectRoot {
    $configuredRoot = Get-ConfiguredProjectRoot

    if ($configuredRoot) {
        Write-Host "Current project search root: $configuredRoot"
    } else {
        Write-Host "Current project search root: $defaultProjectRoot (built-in default)"
    }
}

function Select-ProjectFolder {
    Add-Type -AssemblyName System.Windows.Forms

    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = 'Choose the Ableton project folder or active year folder to search.'
    $dialog.ShowNewFolderButton = $true

    $currentRoot = Get-ConfiguredProjectRoot
    if ($currentRoot -and (Test-Path -LiteralPath $currentRoot)) {
        $dialog.SelectedPath = $currentRoot
    } elseif (Test-Path -LiteralPath $defaultProjectRoot) {
        $dialog.SelectedPath = $defaultProjectRoot
    }

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $dialog.SelectedPath
    }

    return $null
}

function Set-ProjectRootOption {
    Write-Host ''
    Write-Host 'Choose project folder setup:'
    Write-Host "1. Use default Ableton Projects folder: $defaultProjectRoot"
    Write-Host '2. Choose a specific folder'
    Write-Host '3. Keep current setting'
    Write-Host '4. Clear custom setting and use built-in default'

    while ($true) {
        $choice = Read-Host 'Enter 1, 2, 3, or 4'

        switch ($choice) {
            '1' {
                [Environment]::SetEnvironmentVariable($envVarName, $defaultProjectRoot, 'User')
                Write-Host "Project search root set to: $defaultProjectRoot"
                return
            }
            '2' {
                $selectedFolder = Select-ProjectFolder
                if ($selectedFolder) {
                    [Environment]::SetEnvironmentVariable($envVarName, $selectedFolder, 'User')
                    Write-Host "Project search root set to: $selectedFolder"
                } else {
                    Write-Host 'No folder selected. Keeping current project search root.'
                }
                return
            }
            '3' {
                Write-Host 'Keeping current project search root.'
                return
            }
            '4' {
                [Environment]::SetEnvironmentVariable($envVarName, $null, 'User')
                Write-Host "Custom project search root cleared. The script will use: $defaultProjectRoot"
                return
            }
            default {
                Write-Host 'Please enter 1, 2, 3, or 4.'
            }
        }
    }
}

function New-AbletonSnapshotsShortcut {
    if (!(Test-Path -LiteralPath $launcherPath)) {
        throw "Could not find launcher: $launcherPath"
    }

    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = 'powershell.exe'
    $shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$launcherPath`""
    $shortcut.WorkingDirectory = $scriptDir
    $shortcut.Description = 'Launch Ableton Live with Ableton Snapshots hotkeys'
    $shortcut.Save()

    Write-Host "Created or updated shortcut: $shortcutPath"
}

function Confirm-ShortcutUpdate {
    $answer = Read-Host 'Create/update Desktop shortcut? [Y/n]'
    return ($answer -eq '' -or $answer -match '^(y|yes)$')
}

Write-Host 'Ableton Snapshots Setup'
Write-Host '======================='
Write-Host ''
Show-CurrentProjectRoot
Set-ProjectRootOption

Write-Host ''
if (Confirm-ShortcutUpdate) {
    New-AbletonSnapshotsShortcut
} else {
    Write-Host 'Skipped shortcut creation.'
}

Write-Host ''
Show-CurrentProjectRoot
Write-Host ''
Write-Host 'Setup complete. Launch Ableton using the "Ableton Live with Snapshots" Desktop shortcut.'
