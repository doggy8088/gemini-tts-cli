---
name: bump-semver
description: Bump the repository version using SemVer by updating `Directory.Build.props` through the repo script `scripts/bump-version.ps1`. Use when the user asks to bump/increment/set the project version (major/minor/patch/prerelease/release), prepare a release, or check the current centralized .NET version before CI/CD release automation runs.
---

# Bump Semver

Use the repository's version script instead of manually editing project files. The source of truth is `Directory.Build.props`, and release automation reads that version to decide whether to publish a new GitHub release.

## Quick Start

Run from repo root:

```powershell
./scripts/bump-version.ps1 -Part patch
```

## Common Operations

Patch bump:

```powershell
./scripts/bump-version.ps1 -Part patch
```

Minor bump:

```powershell
./scripts/bump-version.ps1 -Part minor
```

Major bump:

```powershell
./scripts/bump-version.ps1 -Part major
```

Start/increment prerelease:

```powershell
./scripts/bump-version.ps1 -Part prerelease
./scripts/bump-version.ps1 -Part prerelease -PrereleaseLabel beta
```

Strip prerelease suffix (make stable release):

```powershell
./scripts/bump-version.ps1 -Part release
```

Set an exact version:

```powershell
./scripts/bump-version.ps1 -SetVersion 1.2.3
./scripts/bump-version.ps1 -SetVersion 1.2.3-rc.1
```

Preview only (no file write):

```powershell
./scripts/bump-version.ps1 -Part patch -DryRun
```

## Workflow

1. Read `Directory.Build.props` and confirm the current `<Version>`.
2. Run `scripts/bump-version.ps1` with the requested SemVer action.
3. Report the old and new version values.
4. If release automation is part of the request, note that `.github/workflows/publish.yml` checks `Directory.Build.props` and only creates a release when the version tag does not already exist.
5. Suggest running `dotnet build GeminiTtsCli.sln` if the user wants post-change verification.

## Notes

- Do not edit `src/gemini-tts-cli.csproj` to change the version; versioning is centralized.
- Use stable SemVer for production releases (for example `1.2.3`).
- Use prerelease identifiers like `-rc.1` or `-beta.2` while testing.
