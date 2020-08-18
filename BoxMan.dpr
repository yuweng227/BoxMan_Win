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
  LoadMapUnit in 'LoadMapUnit.pas',
  LogFile in 'LogFile.pas',
  LurdAction in 'LurdAction.pas',
  Actions in 'Actions.pas' {ActionForm},
  BrowseLevels in 'BrowseLevels.pas' {BrowseForm},
  inf in 'inf.pas' {InfForm},
  Submit in 'Submit.pas' {MySubmit},
  ShowSolutionList in 'ShowSolutionList.pas' {ShowSolutuionList},
  OpenFile in 'OpenFile.pas' {MyOpenFile};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TDataModule1, DataModule1);
  Application.CreateForm(Tmain, main);
  //  Application.CreateForm(TLoadSkinForm, LoadSkinForm);
  Application.CreateForm(TActionForm, ActionForm);
  Application.CreateForm(TInfForm, InfForm);
  Application.CreateForm(TMySubmit, MySubmit);
  Application.CreateForm(TShowSolutuionList, ShowSolutuionList);
  Application.CreateForm(TMyOpenFile, MyOpenFile);
//  Application.CreateForm(TBrowseForm, BrowseForm);
  Application.Run;

end.
