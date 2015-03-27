program FBAccess;

uses
  Vcl.Forms,
  FBAccses in 'FBAccses.pas' {Form1},
  FormsControls in 'FormsControls.pas',
  MetaData in 'MetaData.pas',
  ConnectionForm in 'ConnectionForm.pas' {ConnectionFormWindow},
  DirectoryForm in 'DirectoryForm.pas' {DirForm},
  SQLGenerator in 'SQLGenerator.pas',
  AboutForm in 'AboutForm.pas' {AboutWinodw};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TConnectionFormWindow, ConnectionFormWindow);
  Application.CreateForm(TDirForm, DirForm);
  Application.CreateForm(TAboutWinodw, AboutWinodw);
  Application.Run;
end.
