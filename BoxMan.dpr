program BoxMan;

uses
  Forms,
  Dialogs,
  SysUtils,
  Registry,
  Windows,
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
  OpenFile in 'OpenFile.pas' {MyOpenFile},
  Board in 'Board.pas',
  MyMessage in 'MyMessage.pas' {Msg};

{$R *.RES}

// 避免关闭程序出现“runtime error 216 at xxxxxxx"的错误提示
procedure Halt0;
begin
  Halt;
end;

begin
   if not AppHasRun(Application.Handle) then begin
      Application.Initialize;
      Application.CreateForm(Tmain, main);
  Application.CreateForm(TActionForm, ActionForm);
  Application.CreateForm(TInfForm, InfForm);
  Application.CreateForm(TMySubmit, MySubmit);
  Application.CreateForm(TShowSolutuionList, ShowSolutuionList);
  Application.CreateForm(TMyOpenFile, MyOpenFile);
  Application.CreateForm(TMsg, Msg);
  end;

   Application.Run;

   // 避免关闭程序出现“runtime error 216 at xxxxxxx"的错误提示
   asm
      xor edx, edx
      push ebp
      push OFFSET @@safecode
      push dword ptr fs:[edx]
      mov fs:[edx],esp

      call Halt0
      jmp @@exit;

      @@safecode:
      call Halt0;

      @@exit:
   end;
end.
