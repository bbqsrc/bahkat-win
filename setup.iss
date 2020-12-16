#define MyAppName "Divvun Manager"
#define MyAppPublisher "Universitetet i Tromsø - Norges arktiske universitet"
#define MyAppURL "http://divvun.no"
#define MyAppExeName "DivvunManager.exe"

#define DivvunInstallerUuid "{{4CF2F367-82A8-5E60-8334-34619CBA8347}"
#define PahkatServiceUuid "{{6B3A048B-BB81-4865-86CA-61A0DF038CFE}"

[Setup]
AppId={#DivvunInstallerUuid}
AppName={#MyAppName}
AppVersion={#Version}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={commonpf}\Divvun Manager
DisableProgramGroupPage=yes
OutputBaseFilename=install
Compression=lzma
SolidCompression=yes
AppMutex=DivvunInstaller
SignedUninstaller=yes
SignTool=signtool
MinVersion=6.3.9200                 

[CustomMessages]
InstallingDotNetMsg=Installing .NET 5 libraries (this may take a while)...
InstallingPahkatService=Installing Pahkat Service (this may take a while)...

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "armenian"; MessagesFile: "compiler:Languages\Armenian.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "catalan"; MessagesFile: "compiler:Languages\Catalan.isl"
Name: "corsican"; MessagesFile: "compiler:Languages\Corsican.isl"
Name: "czech"; MessagesFile: "compiler:Languages\Czech.isl"
Name: "danish"; MessagesFile: "compiler:Languages\Danish.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "finnish"; MessagesFile: "compiler:Languages\Finnish.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "hebrew"; MessagesFile: "compiler:Languages\Hebrew.isl"
Name: "icelandic"; MessagesFile: "compiler:Languages\Icelandic.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "norwegian"; MessagesFile: "compiler:Languages\Norwegian.isl"
Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "slovenian"; MessagesFile: "compiler:Languages\Slovenian.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "turkish"; MessagesFile: "compiler:Languages\Turkish.isl"
Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "Divvun.Installer\bin\x86\Release\net5.0-windows\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs uninsrestartdelete
Source: "pahkat-service-setup.exe"; DestDir: "{app}"; Flags: deleteafterinstall dontcopy
Source: "dotnet5-webinst.exe"; DestDir: "{app}"; Flags: deleteafterinstall dontcopy

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall runasoriginaluser skipifsilent

[Icons]
Name: "{commonprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}";
Name: "{commonstartup}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Parameters: "-s";
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon;

[Code]
function GetUninstallString: String;
var
  sUnInstPath: String;
  sUnInstPathWow64: String;
  sUnInstallString: String;
begin
  sUnInstPath := 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#StringChange(DivvunInstallerUuid, '{{', '{')}_is1';
  sUnInstPathWow64 := 'Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{#StringChange(DivvunInstallerUuid, '{{', '{')}_is1';
  sUnInstallString := '';
  if not RegQueryStringValue(HKLM, sUnInstPath, 'UninstallString', sUnInstallString) then
    RegQueryStringValue(HKLM, sUnInstPathWow64, 'UninstallString', sUnInstallString);
  Result := sUnInstallString;
end;

function GetPahkatServiceUninstallString: String;
var
  sUnInstPath: String;
  sUnInstPathWow64: String;
  sUnInstallString: String;
begin                                                                        
  sUnInstPath := 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#StringChange(PahkatServiceUuid, '{{', '{')}_is1';
  sUnInstPathWow64 := 'Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{#StringChange(PahkatServiceUuid, '{{', '{')}_is1';
  sUnInstallString := '';
  if not RegQueryStringValue(HKLM, sUnInstPath, 'UninstallString', sUnInstallString) then
    RegQueryStringValue(HKLM, sUnInstPathWow64, 'UninstallString', sUnInstallString);
  Result := sUnInstallString;
end;

function UninstallDivvunInstaller: String;
var
  sUnInstPath: String;
  sUnInstPathWow64: String;
  sUnInstLocation: String;
  majorVersion: Cardinal;    
  iResultCode: Integer;
  sUnInstallString: string;
begin
  sUnInstPath := 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#StringChange(DivvunInstallerUuid, '{{', '{')}_is1';
  sUnInstPathWow64 := 'Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{#StringChange(DivvunInstallerUuid, '{{', '{')}_is1';
  if RegValueExists(HKEY_LOCAL_MACHINE, sUnInstPath, 'MajorVersion') then begin
    RegQueryDWordValue(HKEY_LOCAL_MACHINE, sUnInstPath, 'MajorVersion', majorVersion);
    RegQueryStringValue(HKLM, sUnInstPath, 'InstallLocation', sUnInstLocation);
  end;
  if RegValueExists(HKEY_LOCAL_MACHINE, sUnInstPathWow64, 'MajorVersion') then begin
    RegQueryDWordValue(HKEY_LOCAL_MACHINE, sUnInstPathWow64, 'MajorVersion', majorVersion);
    RegQueryStringValue(HKLM, sUnInstPathWow64, 'InstallLocation', sUnInstLocation);
  end;
  sUnInstallString := GetUninstallString();
  sUnInstallString := RemoveQuotes(sUnInstallString);
  Exec('taskkill', '/F /IM DivvunInstaller.exe', '', SW_HIDE, ewWaitUntilTerminated, iResultCode);
  Exec('taskkill', '/F /IM DivvunManager.exe', '', SW_HIDE, ewWaitUntilTerminated, iResultCode);
  Sleep(250);
  Exec(ExpandConstant(sUnInstallString), '/VERYSILENT /SP- /SUPPRESSMSGBOXES /NORESTART', '', SW_HIDE, ewWaitUntilTerminated, iResultCode);  
  Sleep(250);
  DelTree(sUnInstLocation, True, True, True);
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var                       
  V: Integer;
  uninstString: string;    
  iResultCode: Integer;
begin
  if CurUninstallStep = usUninstall then
  begin
    uninstString := GetPahkatServiceUninstallString();
    if uninstString <> '' then               
      Exec(ExpandConstant(uninstString), '/VERYSILENT /SP- /SUPPRESSMSGBOXES /NORESTART', '', SW_HIDE, ewWaitUntilTerminated, iResultCode);
  end;
end;

function RemoveOldStartMenuItems: String;
var
  sPath: String;
begin
  sPath := ExpandConstant('{commonprograms}') + '\Divvun Installer.lnk';
  DeleteFile(sPath);
  sPath := ExpandConstant('{commonstartup}') + '\Divvun Installer.lnk';
  DeleteFile(sPath);
  sPath := ExpandConstant('{commondesktop}') + '\Divvun Installer.lnk';
  DeleteFile(sPath);
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ResultCode: Integer;
  WasVisible: Boolean;
begin
    // Uninstall Divvun Installer if it exists
    UninstallDivvunInstaller();
    RemoveOldStartMenuItems();
    
    try
      WizardForm.PreparingLabel.Visible := True;

      // Run embedded Pahkat Service installer
      WizardForm.PreparingLabel.Caption := CustomMessage('InstallingPahkatService');
      ExtractTemporaryFile('pahkat-service-setup.exe');
      Exec(ExpandConstant('{tmp}\pahkat-service-setup.exe'), '/VERYSILENT /SP- /SUPPRESSMSGBOXES /NORESTART', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);

      // Run embedded dotnet installer
      WizardForm.PreparingLabel.Caption := CustomMessage('InstallingDotNetMsg');
      ExtractTemporaryFile('dotnet5-webinst.exe');
      Exec(ExpandConstant('{tmp}\dotnet5-webinst.exe'), '-r windowsdesktop -v 5 -a x86', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    finally
      // restore the original visibility state
      WizardForm.PreparingLabel.Visible := WasVisible;
    end;
end;