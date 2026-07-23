<#
.SYNOPSIS
    Install every "skill" (sub-directory containing SKILL.md) under this folder
    into one or more AI agents' skills directories via Windows directory
    junctions (no admin rights required; Junction is NTFS-native).

.PARAMETER Agent
    Target agent. One of: workbuddy (default), trae, trae-cn, claude, codex, all.

.PARAMETER Dest
    Custom destination directory. Overrides -Agent when provided.

.PARAMETER Uninstall
    Remove junctions under the destination(s) that point back to this folder.
    Only the link is deleted; the source is never touched.

.PARAMETER Skill
    Process only a single skill (directory name). Default: all skills.

.PARAMETER DryRun
    Print what would happen without making any changes.

.PARAMETER LogFile
    Optional. Append a machine-readable operation log to this file.

.PARAMETER Force
    Re-create a junction even if one already exists at the target path
    (useful when the existing link points to a stale/old source location).

.EXAMPLE
    .\install-skills.windows.bat                 # install to WorkBuddy (default)
    .\install-skills.windows.bat -Agent claude   # install to Claude Code only
    .\install-skills.windows.bat -Agent all      # WorkBuddy + Trae + Trae-CN + Claude Code + Codex
    .\install-skills.windows.bat -Agent trae-cn  # install to Trae (CN) only
    .\install-skills.windows.bat -Skill java-coding-standard
    .\install-skills.windows.bat -Agent all -DryRun
    .\install-skills.windows.bat -Agent trae-cn -Uninstall
#>

[CmdletBinding()]
param(
    [string]$Agent = 'workbuddy',
    [string]$Dest = '',
    [string]$Skill = '',
    [switch]$Uninstall,
    [switch]$DryRun,
    [switch]$Force,
    [string]$LogFile = '',
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

# This script's folder = source skills root (resolved wherever it is called from)
$srcRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Use [ordered] so the agent list order is stable across runs / in help output.
$agents = [ordered]@{
    workbuddy = @(Join-Path $env:USERPROFILE ".workbuddy\skills")
    trae      = @(Join-Path $env:USERPROFILE ".trae\skills")
    'trae-cn' = @(Join-Path $env:USERPROFILE ".trae-cn\skills")
    claude    = @(Join-Path $env:USERPROFILE ".claude\skills")
    codex     = @(
        Join-Path $env:USERPROFILE ".agents\skills"
        Join-Path $env:USERPROFILE ".codex\skills"
    )
}

# ---------------------------------------------------------------------------
# Counters for the final summary.
# ---------------------------------------------------------------------------
$script:stats = [ordered]@{
    Installed   = 0
    Recreated   = 0
    Skipped     = 0
    Stale       = 0
    Uninstalled = 0
    Failed      = 0
}

function Write-LogFile([string]$Message) {
    if ($LogFile -ne '') {
        $stamp = (Get-Date).ToString('s')
        Add-Content -Path $LogFile -Value "[$stamp] $Message"
    }
}

if ($Help) {
    $lines = @(
        "",
        "install-skills.windows.ps1",
        "============================",
        "Install every skill (sub-dir with SKILL.md) in this folder into one or",
        "more AI agents' skills dirs via Windows directory junctions (no admin).",
        "",
        "USAGE",
        "  .\install-skills.windows.bat                # WorkBuddy (default)",
        "  .\install-skills.windows.ps1 -Agent <name> # specific agent",
        "  .\install-skills.windows.ps1 -Agent all     # all known agents",
        "  .\install-skills.windows.ps1 -Dest <path>   # custom destination",
        "  ... -Uninstall                              # remove links",
        "  ... -Skill <name>                           # single skill only",
        "  ... -DryRun                                 # preview only",
        "  ... -Force                                  # rebuild stale links",
        "  ... -LogFile <path>                         # append operation log",
        "",
        "PARAMETERS",
        "  -Agent <name>   One of: $($agents.Keys -join ', '), or 'all'",
        "  -Dest <path>    Custom destination (overrides -Agent)",
        "  -Skill <name>   Process only this skill (default: all)",
        "  -Uninstall      Remove junctions pointing back to this folder",
        "  -DryRun         Print what would happen, change nothing",
        "  -Force          Re-create links that exist but point elsewhere",
        "  -LogFile <path> Append a machine-readable log to this file",
        "  -Help           Show this help",
        "",
        "KNOWN AGENT PATHS (Windows)"
    )
    foreach ($kv in $agents.GetEnumerator()) {
        $p = if ($kv.Value -is [array]) { $kv.Value -join ' ; ' } else { $kv.Value }
        $lines += ("  {0,-9} -> {1}" -f $kv.Key, $p)
    }
    $lines += @(
        "",
        "EXAMPLES",
        "  .\install-skills.windows.bat -Agent claude",
        "  .\install-skills.windows.bat -Agent all",
        "  .\install-skills.windows.bat -Skill java-coding-standard",
        "  .\install-skills.windows.bat -Agent all -DryRun",
        "  .\install-skills.windows.bat -Agent trae-cn -Uninstall",
        ""
    )
    Write-Host ($lines -join "`n") -ForegroundColor Cyan
    exit 0
}

function Test-ReparsePoint([string]$Path) {
    try {
        $item = Get-Item $Path -Force
        return ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
    } catch { return $false }
}

# IMPORTANT: never use Remove-Item to delete a directory junction.
# Some PowerShell versions follow the link and recursively delete the REAL
# source files. We use [System.IO.Directory]::Delete(path, recursive:false)
# which operates on the reparse point itself.
function Remove-Junction([string]$Path) {
    [System.IO.Directory]::Delete($Path, $false)
}

# Resolve the list of destination directories
$dests = @()
if ($Dest -ne '') {
    $dests += $Dest
} elseif ($Agent -eq 'all') {
    $dests = @($agents.Values | ForEach-Object { $_ })
} elseif ($agents.Contains($Agent)) {
    $dests += @($agents[$Agent])
} else {
    Write-Error "Unknown agent '$Agent'. Known: $($agents.Keys -join ', '); or use -Dest <path>."
    exit 1
}

# Filter source skill directories, optionally to a single skill via -Skill.
$sourceSkillDirs = @(
    foreach ($dir in Get-ChildItem -Path $srcRoot -Directory) {
        $skillMd = Join-Path $dir.FullName "SKILL.md"
        if (-not (Test-Path $skillMd)) { continue }
        if ($Skill -ne '' -and $dir.Name -ne $Skill) { continue }
        $dir
    }
)

if ($sourceSkillDirs.Count -eq 0) {
    if ($Skill -ne '') {
        Write-Warning "No skill named '$Skill' (with SKILL.md) found under $srcRoot"
    } else {
        Write-Warning "No skills (sub-dirs with SKILL.md) found under $srcRoot"
    }
    exit 0
}

if ($DryRun) {
    Write-Host "== DRY RUN (nothing will change) ==" -ForegroundColor Yellow
}

foreach ($destRoot in $dests) {
    Write-Host "`n== $destRoot ==" -ForegroundColor Magenta

    if ($Uninstall) {
        if (-not (Test-Path $destRoot)) { continue }

        foreach ($item in Get-ChildItem -Path $destRoot) {
            if (-not (Test-ReparsePoint $item.FullName)) { continue }

            # For -Skill filter, only consider matching name.
            if ($Skill -ne '' -and $item.Name -ne $Skill) { continue }

            $target = (Get-Item $item.FullName).Target
            if (-not $target) { continue }
            if (-not $target.StartsWith($srcRoot, [System.StringComparison]::OrdinalIgnoreCase)) { continue }

            if ($DryRun) {
                Write-Host "  [dry-run] Would remove: $($item.Name) -> $target" -ForegroundColor Yellow
                $script:stats.Uninstalled++
                continue
            }

            try {
                Remove-Junction $item.FullName
                Write-Host "  Removed: $($item.Name)" -ForegroundColor Green
                Write-LogFile "UNINSTALL $($item.FullName) -> $target"
                $script:stats.Uninstalled++
            } catch {
                Write-Error "Failed to remove $($item.Name): $_"
                $script:stats.Failed++
            }
        }
        continue
    }

    # --- Install branch ---
    if (-not (Test-Path $destRoot)) {
        if ($DryRun) {
            Write-Host "  [dry-run] Would create dir: $destRoot" -ForegroundColor Yellow
        } else {
            New-Item -ItemType Directory -Path $destRoot | Out-Null
            Write-Host "  Created dir: $destRoot" -ForegroundColor Cyan
        }
    }

    foreach ($dir in $sourceSkillDirs) {
        $link = Join-Path $destRoot $dir.Name

        # Detect an existing entry without following the reparse point.
        # NOTE on broken links: a junction whose target no longer exists is
        # invisible to PowerShell 5.1 / .NET (Get-Item, Test-Path all return
        # $null/false). Such broken links cannot be detected here and will be
        # transparently overwritten by New-Item below, which is the desired
        # outcome (a broken link is repaired). The stale-detection below only
        # triggers when the existing junction points to a *real but different*
        # path (e.g. old repo location that still exists after a move).
        $existing = $null
        try { $existing = Get-Item $link -Force -ErrorAction SilentlyContinue } catch { }
        $isReparse = $existing -and (($existing.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0)

        if ($existing) {
            if ($isReparse) {
                $existingTarget = $existing.Target
                if ($existingTarget -and $existingTarget -eq $dir.FullName) {
                    Write-Host "  Skip (already linked): $($dir.Name)" -ForegroundColor Yellow
                    Write-LogFile "SKIP_OK $($link) -> $existingTarget"
                    $script:stats.Skipped++
                } elseif ($Force -and -not $DryRun) {
                    try {
                        Remove-Junction $link
                        New-Item -ItemType Junction -Path $link -Target $dir.FullName | Out-Null
                        Write-Host "  Recreated (was stale): $($dir.Name) -> $($dir.FullName)" -ForegroundColor Green
                        Write-LogFile "RECREATE $($link) old=$existingTarget new=$($dir.FullName)"
                        $script:stats.Recreated++
                    } catch {
                        Write-Error "Failed to rebuild $($dir.Name): $_"
                        $script:stats.Failed++
                    }
                } elseif ($Force -and $DryRun) {
                    Write-Host "  [dry-run] Would rebuild stale link: $($dir.Name) (was: $existingTarget)" -ForegroundColor Yellow
                    $script:stats.Recreated++
                } else {
                    Write-Warning "  Stale link: $($dir.Name) -> $existingTarget (expected $($dir.FullName)). Re-run with -Force to rebuild."
                    Write-LogFile "STALE $($link) actual=$existingTarget expected=$($dir.FullName)"
                    $script:stats.Stale++
                }
            } else {
                Write-Warning "  Skip (exists, not a link, avoid overwrite): $link"
                $script:stats.Skipped++
            }
            continue
        }

        if ($DryRun) {
            Write-Host "  [dry-run] Would install: $($dir.Name) -> $($dir.FullName)" -ForegroundColor Yellow
            $script:stats.Installed++
            continue
        }

        try {
            New-Item -ItemType Junction -Path $link -Target $dir.FullName | Out-Null
            # Post-install self-check: link must be readable.
            $probe = Join-Path $link "SKILL.md"
            if (-not (Test-Path $probe)) {
                Write-Warning "  Installed but SKILL.md not readable via link: $($dir.Name)"
                Write-LogFile "INSTALL_BROKEN $($link)"
                $script:stats.Failed++
                continue
            }
            Write-Host "  Installed: $($dir.Name) -> $($dir.FullName)" -ForegroundColor Green
            Write-LogFile "INSTALL $($link) -> $($dir.FullName)"
            $script:stats.Installed++
        } catch {
            Write-Error "Failed to install $($dir.Name): $_"
            $script:stats.Failed++
        }
    }
}

# ---------------------------------------------------------------------------
# Final summary
# ---------------------------------------------------------------------------
$mode = if ($DryRun) { '[DRY RUN] ' } else { '' }
$action = if ($Uninstall) { 'Uninstall' } else { 'Install' }
Write-Host ""
Write-Host "== $($mode)Summary ==" -ForegroundColor Cyan
Write-Host ("  Action        : {0}" -f $action) -ForegroundColor Cyan
Write-Host ("  Agent/Dest    : {0}" -f ($dests -join '; ')) -ForegroundColor Cyan
if ($Skill) { Write-Host ("  Skill filter  : {0}" -f $Skill) -ForegroundColor Cyan }
if ($LogFile) { Write-Host ("  Log file      : {0}" -f $LogFile) -ForegroundColor Cyan }
Write-Host ("  Installed     : {0}" -f $script:stats.Installed) -ForegroundColor Cyan
Write-Host ("  Recreated     : {0}" -f $script:stats.Recreated) -ForegroundColor Cyan
Write-Host ("  Skipped       : {0}" -f $script:stats.Skipped) -ForegroundColor Cyan
Write-Host ("  Stale links   : {0}" -f $script:stats.Stale) -ForegroundColor Cyan
Write-Host ("  Uninstalled   : {0}" -f $script:stats.Uninstalled) -ForegroundColor Cyan
Write-Host ("  Failed        : {0}" -f $script:stats.Failed) -ForegroundColor Cyan
Write-LogFile "SUMMARY $($mode)$action installed=$($script:stats.Installed) recreated=$($script:stats.Recreated) skipped=$($script:stats.Skipped) stale=$($script:stats.Stale) uninstalled=$($script:stats.Uninstalled) failed=$($script:stats.Failed)"

if ($script:stats.Failed -gt 0) { exit 2 }
Write-Host "`nDone." -ForegroundColor Cyan
