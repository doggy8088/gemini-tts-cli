param(
    [ValidateSet("major", "minor", "patch", "prerelease", "release")]
    [string]$Part = "patch",
    [string]$SetVersion,
    [string]$PrereleaseLabel = "rc",
    [string]$VersionFile = "Directory.Build.props",
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SemVerPattern = '^(?<major>0|[1-9]\d*)\.(?<minor>0|[1-9]\d*)\.(?<patch>0|[1-9]\d*)(?:-(?<prerelease>[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+(?<build>[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$'

function Resolve-RepoVersionFile {
    param([string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    return [System.IO.Path]::GetFullPath((Join-Path $repoRoot $Path))
}

function Parse-SemVer {
    param([string]$Version)

    $m = [regex]::Match($Version, $SemVerPattern)
    if (-not $m.Success) {
        throw "Invalid SemVer: '$Version'"
    }

    [pscustomobject]@{
        Major = [int]$m.Groups["major"].Value
        Minor = [int]$m.Groups["minor"].Value
        Patch = [int]$m.Groups["patch"].Value
        Prerelease = if ($m.Groups["prerelease"].Success) { $m.Groups["prerelease"].Value } else { $null }
        Build = if ($m.Groups["build"].Success) { $m.Groups["build"].Value } else { $null }
    }
}

function Get-VersionFromProps {
    param([string]$Path)

    [xml]$xml = Get-Content -Path $Path
    $node = $xml.Project.PropertyGroup | ForEach-Object { $_.Version } | Where-Object { $_ } | Select-Object -First 1
    if (-not $node) {
        throw "Unable to find <Version> in $Path"
    }

    return [string]$node
}

function Set-VersionInProps {
    param(
        [string]$Path,
        [string]$NewVersion
    )

    $content = Get-Content -Path $Path -Raw
    $updated = [regex]::Replace($content, '<Version>\s*[^<]+\s*</Version>', "<Version>$NewVersion</Version>", 1)

    if ($updated -eq $content) {
        throw "Failed to update <Version> in $Path"
    }

    Set-Content -Path $Path -Value $updated -NoNewline
}

function Get-NextPrerelease {
    param(
        [string]$CurrentPrerelease,
        [string]$DefaultLabel
    )

    if (-not $CurrentPrerelease) {
        return "$DefaultLabel.1"
    }

    $parts = $CurrentPrerelease.Split('.')
    $lastIndex = $parts.Length - 1
    $last = $parts[$lastIndex]

    if ($last -match '^\d+$') {
        $parts[$lastIndex] = ([int]$last + 1).ToString()
        return ($parts -join '.')
    }

    return "$CurrentPrerelease.1"
}

function Format-SemVer {
    param(
        [int]$Major,
        [int]$Minor,
        [int]$Patch,
        [string]$Prerelease
    )

    $v = "$Major.$Minor.$Patch"
    if ($Prerelease) {
        $v += "-$Prerelease"
    }
    return $v
}

$resolvedVersionFile = Resolve-RepoVersionFile -Path $VersionFile
if (-not (Test-Path $resolvedVersionFile)) {
    throw "Version file not found: $resolvedVersionFile"
}

$currentVersion = Get-VersionFromProps -Path $resolvedVersionFile
$null = Parse-SemVer -Version $currentVersion

if ($SetVersion) {
    $null = Parse-SemVer -Version $SetVersion
    $nextVersion = $SetVersion
}
else {
    $parsed = Parse-SemVer -Version $currentVersion

    switch ($Part) {
        "major" {
            $nextVersion = Format-SemVer -Major ($parsed.Major + 1) -Minor 0 -Patch 0 -Prerelease $null
        }
        "minor" {
            $nextVersion = Format-SemVer -Major $parsed.Major -Minor ($parsed.Minor + 1) -Patch 0 -Prerelease $null
        }
        "patch" {
            $nextVersion = Format-SemVer -Major $parsed.Major -Minor $parsed.Minor -Patch ($parsed.Patch + 1) -Prerelease $null
        }
        "prerelease" {
            $nextPrerelease = Get-NextPrerelease -CurrentPrerelease $parsed.Prerelease -DefaultLabel $PrereleaseLabel
            $nextVersion = Format-SemVer -Major $parsed.Major -Minor $parsed.Minor -Patch $parsed.Patch -Prerelease $nextPrerelease
        }
        "release" {
            $nextVersion = Format-SemVer -Major $parsed.Major -Minor $parsed.Minor -Patch $parsed.Patch -Prerelease $null
        }
        default {
            throw "Unsupported bump part: $Part"
        }
    }
}

if ($nextVersion -eq $currentVersion) {
    Write-Host "Version unchanged: $currentVersion"
    exit 0
}

if ($DryRun) {
    Write-Host "[DryRun] $currentVersion -> $nextVersion"
    exit 0
}

Set-VersionInProps -Path $resolvedVersionFile -NewVersion $nextVersion

Write-Host "Updated version: $currentVersion -> $nextVersion"
Write-Host "File: $resolvedVersionFile"
