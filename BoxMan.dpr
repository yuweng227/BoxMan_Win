program BoxMan;

uses
  Forms,
  Dialogs,
  SysUtils,
  Registry,
  Windows,
  DateModule in 'DateModule.pas' {DataModule1: TDataModule},
  LoadSkin in 'LoadSkin.pas' {LoadSkinForm},
  MainForm in 'MainForm.pas' {main},
  PathFinder in 'PathFinder.pas',
  LoadMap in 'LoadMap.pas',
  LogFile in 'LogFile.pas',
  LurdAction in 'LurdAction.pas',
  Actions in 'Actions.pas' {ActionForm},
  BrowseLevels in 'BrowseLevels.pas' {BrowseForm},
  inf in 'inf.pas' {InfForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TDataModule1, DataModule1);
  Application.CreateForm(Tmain, main);
  Application.CreateForm(TLoadSkinForm, LoadSkinForm);
  Application.CreateForm(TActionForm, ActionForm);
  Application.CreateForm(TBrowseForm, BrowseForm);
  Application.CreateForm(TInfForm, InfForm);
  Application.Run;

end.
