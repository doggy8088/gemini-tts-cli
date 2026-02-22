param(
    [string]$Version,
    [string]$Configuration = "Release",
    [string]$Runtime = "win-x64",
    [string]$Project = "src/gemini-tts-cli.csproj",
    [string]$PublishDir = "artifacts/windows-installer/app",
    [string]$InstallerOutputDir = "artifacts/windows-installer/out",
    [string]$InnoSetupCompilerPath,
    [switch]$SkipPublish,
    [switch]$SkipCompile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-RepoPath {
    param([string]$Path)

    $fullPath = Join-Path $RepoRoot $Path
    return [System.IO.Path]::GetFullPath($fullPath)
}

function Get-ProjectVersion {
    param([string]$ProjectFile)

    [xml]$xml = Get-Content -Path $ProjectFile
    $versionNode = $xml.Project.PropertyGroup | ForEach-Object { $_.Version } | Where-Object { $_ } | Select-Object -First 1

    if (-not $versionNode) {
        throw "Unable to find <Version> in $ProjectFile"
    }

    return [string]$versionNode
}

function Find-InnoSetupCompiler {
    param([string]$ExplicitPath)

    if ($ExplicitPath) {
        if (Test-Path $ExplicitPath) {
            return (Resolve-Path $ExplicitPath).Path
        }
        throw "Inno Setup compiler not found at path: $ExplicitPath"
    }

    if ($env:ISCC_PATH -and (Test-Path $env:ISCC_PATH)) {
        return (Resolve-Path $env:ISCC_PATH).Path
    }

    $candidates = @(@(
        "$env:ProgramFiles(x86)\Inno Setup 6\ISCC.exe",
        "$env:ProgramFiles\Inno Setup 6\ISCC.exe"
    ) | Where-Object { $_ -and (Test-Path $_) })

    if ($candidates.Count -gt 0) {
        return (Resolve-Path $candidates[0]).Path
    }

    $cmd = Get-Command ISCC.exe -ErrorAction SilentlyContinue
    if ($cmd) {
        return $cmd.Source
    }

    return $null
}

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$ProjectFile = Resolve-RepoPath $Project
$PublishDirFull = Resolve-RepoPath $PublishDir
$InstallerOutDirFull = Resolve-RepoPath $InstallerOutputDir
$InstallerScript = Resolve-RepoPath "installer/windows/gemini-tts-cli.iss"

if (-not (Test-Path $ProjectFile)) {
    throw "Project file not found: $ProjectFile"
}

if (-not (Test-Path $InstallerScript)) {
    throw "Installer script not found: $InstallerScript"
}

if (-not $Version) {
    $Version = Get-ProjectVersion -ProjectFile $ProjectFile
}

Write-Host "Repo root: $RepoRoot"
Write-Host "Version: $Version"
Write-Host "Project: $ProjectFile"
Write-Host "Publish output: $PublishDirFull"
Write-Host "Installer output: $InstallerOutDirFull"

New-Item -ItemType Directory -Force -Path $PublishDirFull | Out-Null
New-Item -ItemType Directory -Force -Path $InstallerOutDirFull | Out-Null

if (-not $SkipPublish) {
    Write-Host "Publishing self-contained Windows binary..."

    dotnet publish $ProjectFile `
        -c $Configuration `
        --nologo `
        --self-contained `
        -r $Runtime `
        -p:PublishSelfContained=true `
        -p:PublishSingleFile=true `
        -p:DebugType=embedded `
        -p:IncludeNativeLibrariesForSelfExtract=true `
        -p:PublishTrimmed=false `
        -p:EnableCompressionInSingleFile=true `
        -p:SuppressTrimAnalysisWarnings=true `
        -o $PublishDirFull

    if ($LASTEXITCODE -ne 0) {
        throw "dotnet publish failed with exit code $LASTEXITCODE"
    }
}

if (-not (Test-Path (Join-Path $PublishDirFull "gemini-tts-cli.exe"))) {
    throw "Published executable not found: $(Join-Path $PublishDirFull 'gemini-tts-cli.exe')"
}

if ($SkipCompile) {
    Write-Host "SkipCompile specified. Published files are ready in: $PublishDirFull"
    return
}

$iscc = Find-InnoSetupCompiler -ExplicitPath $InnoSetupCompilerPath
if (-not $iscc) {
    throw "Inno Setup compiler (ISCC.exe) not found. Install Inno Setup 6 or pass -InnoSetupCompilerPath."
}

Write-Host "Using Inno Setup compiler: $iscc"
Write-Host "Compiling installer..."

& $iscc `
    "/DAppVersion=$Version" `
    "/DSourceDir=$PublishDirFull" `
    "/DRepoRoot=$RepoRoot" `
    "/DOutputDir=$InstallerOutDirFull" `
    $InstallerScript

if ($LASTEXITCODE -ne 0) {
    throw "ISCC.exe failed with exit code $LASTEXITCODE"
}

$installerFiles = Get-ChildItem -Path $InstallerOutDirFull -Filter "*.exe" | Sort-Object LastWriteTime -Descending
if (-not $installerFiles) {
    throw "Installer compilation completed but no .exe was found in $InstallerOutDirFull"
}

Write-Host "Installer created:"
$installerFiles | ForEach-Object { Write-Host " - $($_.FullName)" }
