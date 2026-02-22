#define AppName "Gemini TTS CLI"
#define AppExeName "gemini-tts-cli.exe"
#define AppPublisher "Will 保哥"
#define AppURL "https://github.com/doggy8088/gemini-tts-cli"
#define AppId "{{D1D2F4F9-0B40-41C5-BF5A-AF9F9F7F8E71}"

#ifndef AppVersion
  #define AppVersion "0.0.0-dev"
#endif

#ifndef SourceDir
  #error "Missing /DSourceDir=<published files folder>"
#endif

#ifndef RepoRoot
  #define RepoRoot "..\.."
#endif

#ifndef OutputDir
  #define OutputDir ".\dist"
#endif

[Setup]
AppId={#AppId}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}/releases
VersionInfoVersion={#AppVersion}
VersionInfoProductName={#AppName}
VersionInfoCompany={#AppPublisher}
VersionInfoDescription={#AppName} Windows Installer
DefaultDirName={autopf}\Gemini TTS CLI
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ChangesEnvironment=yes
OutputDir={#OutputDir}
OutputBaseFilename=gemini-tts-cli-{#AppVersion}-win-x64-setup
LicenseFile={#RepoRoot}\LICENSE
InfoAfterFile={#RepoRoot}\installer\windows\InfoAfterInstall.txt
UninstallDisplayIcon={app}\{#AppExeName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "addtopath"; Description: "Add installation folder to the system PATH"; GroupDescription: "Additional tasks:"; Flags: checkedonce

[Files]
Source: "{#SourceDir}\{#AppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\*.dll"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#SourceDir}\*.json"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#SourceDir}\*.pdb"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist
Source: "{#RepoRoot}\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#RepoRoot}\LICENSE"; DestDir: "{app}"; DestName: "LICENSE.txt"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#AppName}\Command Prompt"; Filename: "{cmd}"; Parameters: "/k cd /d ""{app}"""; WorkingDir: "{app}"
Name: "{autoprograms}\{#AppName}\Uninstall {#AppName}"; Filename: "{uninstallexe}"

[Registry]
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; \
    ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}"; \
    Check: WizardIsTaskSelected('addtopath') and NeedsAddPath(ExpandConstant('{app}')); \
    Flags: preservestringtype

[Run]
Filename: "{#AppURL}"; Description: "Open project page"; Flags: postinstall shellexec skipifsilent unchecked

[Code]
const
  EnvRegKey = 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment';

function NormalizePathEntry(Value: string): string;
begin
  Result := RemoveBackslashUnlessRoot(Trim(Value));
end;

function PathEntryEquals(A, B: string): Boolean;
begin
  Result := CompareText(NormalizePathEntry(A), NormalizePathEntry(B)) = 0;
end;

function NextPathToken(var PathValue: string): string;
var
  SeparatorPos: Integer;
begin
  SeparatorPos := Pos(';', PathValue);
  if SeparatorPos > 0 then
  begin
    Result := Copy(PathValue, 1, SeparatorPos - 1);
    Delete(PathValue, 1, SeparatorPos);
  end
  else
  begin
    Result := PathValue;
    PathValue := '';
  end;
end;

function ContainsPathEntry(const PathValue, Dir: string): Boolean;
var
  Remaining: string;
  Item: string;
begin
  Result := False;
  Remaining := PathValue;
  while Remaining <> '' do
  begin
    Item := NextPathToken(Remaining);
    if PathEntryEquals(Item, Dir) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function NeedsAddPath(Dir: string): Boolean;
var
  CurrentPath: string;
begin
  if not RegQueryStringValue(HKLM, EnvRegKey, 'Path', CurrentPath) then
    CurrentPath := '';

  Result := not ContainsPathEntry(CurrentPath, Dir);
end;

procedure RemoveFromSystemPath(Dir: string);
var
  CurrentPath: string;
  Remaining: string;
  Item: string;
  NewPath: string;
begin
  if not RegQueryStringValue(HKLM, EnvRegKey, 'Path', CurrentPath) then
    Exit;

  Remaining := CurrentPath;
  NewPath := '';

  while Remaining <> '' do
  begin
    Item := NextPathToken(Remaining);

    if (Trim(Item) <> '') and (not PathEntryEquals(Item, Dir)) then
    begin
      if NewPath <> '' then
        NewPath := NewPath + ';';
      NewPath := NewPath + Item;
    end;
  end;

  if NewPath <> CurrentPath then
    RegWriteExpandStringValue(HKLM, EnvRegKey, 'Path', NewPath);
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
    RemoveFromSystemPath(ExpandConstant('{app}'));
end;
