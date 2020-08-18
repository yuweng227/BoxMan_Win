program BoxManEditor;

uses
  Forms,
  Editor_ in 'Editor_.pas' {EditorForm_},
  EditorInf_ in 'EditorInf_.pas' {EditorInfForm_},
  Recog_ in 'Recog_.pas' {RecogForm_},
  LoadSkin in 'LoadSkin.pas' {LoadSkinForm},
  EditorHelp in 'EditorHelp.pas' {EditorHelpForm};

{$R *.res}

// 避免关闭程序出现“runtime error 216 at xxxxxxx"的错误提示
procedure Halt0;
begin
  Halt;
end;

begin
  Application.Initialize;
  Application.CreateForm(TEditorForm_, EditorForm_);
  Application.CreateForm(TEditorInfForm_, EditorInfForm_);
  Application.CreateForm(TRecogForm_, RecogForm_);
  Application.CreateForm(TLoadSkinForm, LoadSkinForm);
  Application.CreateForm(TEditorHelpForm, EditorHelpForm);
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
