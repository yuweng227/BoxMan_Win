unit Actions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin, Clipbrd, Math, ComCtrls;

type
  TActionForm = class(TForm)
    Panel1: TPanel;
    MemoAct: TMemo;
    Button1: TButton;
    Button2: TButton;
    Run_CurPos: TCheckBox;
    Run_CurTru: TCheckBox;
    Rep_Times: TSpinEdit;
    Label1: TLabel;
    Left_Trun: TButton;
    Right_Trun: TButton;
    H_Mirror: TButton;
    V_Mirror: TButton;
    LoadBox: TComboBox;
    SaveBox: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    StatusBar1: TStatusBar;
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Left_TrunClick(Sender: TObject);
    procedure Right_TrunClick(Sender: TObject);
    procedure H_MirrorClick(Sender: TObject);
    procedure V_MirrorClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure LoadBoxSelect(Sender: TObject);
    procedure SaveBoxSelect(Sender: TObject);
    procedure SaveToFile();         // 保存动作到文档
    procedure LoadFromFile();       // 从文档加载动作

  private
    { Private declarations }
  public
    { Public declarations }

    isBK: Boolean;            // 传入参数，是否逆推
    Act: string;              // 解析出的动作字符串
    M_X, M_Y: Integer;        // 解析出的逆推中人的初始位置
    MyPath: string;           // 动作文档存取路径
    ExePath: string;          // 动作文档存取路径

  end;

var
  ActionForm: TActionForm;

implementation

uses
  LurdAction;

{$R *.dfm}

procedure TActionForm.FormActivate(Sender: TObject);
begin
   Button1.SetFocus;
   Tag := 0;
   if LoadBox.ItemIndex < 0 then LoadBox.ItemIndex := 0;
   if SaveBox.ItemIndex < 0 then SaveBox.ItemIndex := 0;
end;

procedure TActionForm.FormShow(Sender: TObject);
begin
  // 视情况，加载剪贴板中的内容
  if (Clipboard.HasFormat(CF_TEXT) or Clipboard.HasFormat(CF_OEMTEXT)) and (MemoAct.Lines.Count = 0) then begin
      MemoAct.Lines.Add(Clipboard.asText);
  end;
end;

procedure TActionForm.Button1Click(Sender: TObject);
var
  i, j, k, len: Integer;
  str: string;
  p: TStrings;

begin
  len := MemoAct.Lines.Count;

  Act := '';
  for i := 0 to len-1 do begin
      str := StringReplace(ActionForm.MemoAct.Lines[i], #9, '', [rfReplaceAll]);
      str := StringReplace(str, ' ', '', [rfReplaceAll]);
      if (Length(str) > 0) and (not isLurd_2(str)) then begin
         Act := '';
         MessageBox(handle, '包含了无效的动作字符，请检查并修正后再执行！', '错误', MB_ICONERROR or MB_OK);
         Exit;
      end;
      Act := Act + MemoAct.Lines[i];
  end;

  // 解析动作字符串
  M_X := -1;
  M_Y := -1;
  if isBK then begin             // 逆推
      i := pos('[', str);
      j := pos(']', str);
      if (i > 0) and (j > 0) and (j > i) then begin
         str := copy(str, i+1, j-i-1);
         delete(str, 1, j);
         p := TStringList.Create;
         p.CommaText := str;

         if p.Count = 2 then begin
            try
              M_X := strToInt(p[0]);
              M_Y := strToInt(p[1]);
            except
              M_X := -1;
              M_Y := -1;
            end;
         end;

         FreeAndNil(p);
      end else begin
         k := Max(i, j);

         if k > 0 then delete(Act, 1, k);
      end;
  end else begin               // 正推
      i := pos('[', str);

      if i > 0 then Act := copy(Act, 1, i-1);
  end;
  
  Tag := 1;
  Close();
end;

// 动作左旋
procedure TActionForm.Left_TrunClick(Sender: TObject);
var
  i, j, len, size: Integer;
  ch: Char;
  pch: PChar;

begin
  size := MemoAct.Lines.Count;
  for i := 0 to size-1 do begin
      len := Length(MemoAct.Lines[i]);
      pch := PChar(MemoAct.Lines[i]);
      for j := 0 to len-1 do begin
          ch := pch[j];
          case ch of
            'l': ch := 'd';
            'u': ch := 'l';
            'r': ch := 'u';
            'd': ch := 'r';
            'L': ch := 'D';
            'U': ch := 'L';
            'R': ch := 'U';
            'D': ch := 'R';
          end;
          pch[j] := ch;
      end;
      MemoAct.Lines[i] := pch;
  end;
end;

// 动作右旋
procedure TActionForm.Right_TrunClick(Sender: TObject);
var
  i, j, len, size: Integer;
  ch: Char;
  pch: PChar;

begin
  size := MemoAct.Lines.Count;
  for i := 0 to size-1 do begin
      len := Length(MemoAct.Lines[i]);
      pch := PChar(MemoAct.Lines[i]);
      for j := 0 to len-1 do begin
          ch := pch[j];
          case ch of
            'l': ch := 'u';
            'u': ch := 'r';
            'r': ch := 'd';
            'd': ch := 'l';
            'L': ch := 'U';
            'U': ch := 'R';
            'R': ch := 'D';
            'D': ch := 'L';
          end;
          pch[j] := ch;
      end;
      MemoAct.Lines[i] := pch;
  end;
end;

// 动作左右翻转
procedure TActionForm.H_MirrorClick(Sender: TObject);
var
  i, j, len, size: Integer;
  ch: Char;
  pch: PChar;

begin
  size := MemoAct.Lines.Count;
  for i := 0 to size-1 do begin
      len := Length(MemoAct.Lines[i]);
      pch := PChar(MemoAct.Lines[i]);
      for j := 0 to len-1 do begin
          ch := pch[j];
          case ch of
            'l': ch := 'r';
            'u': ch := 'u';
            'r': ch := 'l';
            'd': ch := 'd';
            'L': ch := 'R';
            'U': ch := 'U';
            'R': ch := 'L';
            'D': ch := 'D';
          end;
          pch[j] := ch;
      end;
      MemoAct.Lines[i] := pch;
  end;
end;

// 动作上下翻转
procedure TActionForm.V_MirrorClick(Sender: TObject);
var
  i, j, len, size: Integer;
  ch: Char;
  pch: PChar;

begin
  size := MemoAct.Lines.Count;
  for i := 0 to size-1 do begin
      len := Length(MemoAct.Lines[i]);
      pch := PChar(MemoAct.Lines[i]);
      for j := 0 to len-1 do begin
          ch := pch[j];
          case ch of
            'l': ch := 'l';
            'u': ch := 'd';
            'r': ch := 'r';
            'd': ch := 'u';
            'L': ch := 'L';
            'U': ch := 'D';
            'R': ch := 'R';
            'D': ch := 'U';
          end;
          pch[j] := ch;
      end;
      MemoAct.Lines[i] := pch;
  end;
end;

procedure TActionForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    97, 65: if Shift = [ssCtrl] then begin                // Ctrl + A
          MemoAct.SetFocus;
          MemoAct.SelectAll;                              // 全选
      end;
  end;
end;

procedure TActionForm.FormCreate(Sender: TObject);
begin
  Caption := '动作编辑';
  Run_CurTru.Caption := '按现场旋转执行';
  Run_CurPos.Caption := '从当前点执行';
  Label1.Caption := '重复次数：';
  Label2.Caption := '加载：';
  Label3.Caption := '存入：';
  Left_Trun.Caption := '左旋(&L)';
  Right_Trun.Caption := '右旋(&R)';
  H_Mirror.Caption := '左右翻转(&H)';
  V_Mirror.Caption := '上下翻转(&H)';
  Button1.Caption := '执行(&R)';
  Button2.Caption := '取消(&C)';
  LoadBox.Items.Text := '剪切板'#13#10'已做动作'#13#10'后续动作'#13#10'寄存器 1'#13#10'寄存器 2'#13#10'寄存器 3'#13#10'寄存器 4'#13#10'文档';
  SaveBox.Items.Text := '剪切板'#13#10'寄存器 1'#13#10'寄存器 2'#13#10'寄存器 3'#13#10'寄存器 4'#13#10'文档';

  KeyPreview := true;
end;

// 保存动作到文档
procedure TActionForm.SaveToFile();
var
  myFileName, myExtName: string;
  
begin
  SaveDialog1.InitialDir := MyPath;
  SaveDialog1.FileName := '';
  if SaveDialog1.Execute then begin
     myFileName := SaveDialog1.FileName;

     myExtName := ExtractFileExt(myFileName);

     if (myExtName = '') or (myExtName = '.') then
        myFileName := changefileext(myFileName, '.txt');

     try
       MemoAct.Lines.SaveToFile(myFileName);
     except
       StatusBar1.Panels[0].Text := '写【' + myFileName + '】文档时遇到错误！';
     end;
  end;
end;

// 从文档加载动作
procedure TActionForm.LoadFromFile();
var
  myFileName, myExtName: string;
  
begin
  OpenDialog1.InitialDir := MyPath;
  OpenDialog1.FileName := '';
  if OpenDialog1.Execute then begin
     myFileName := OpenDialog1.FileName;

     myExtName := ExtractFileExt(myFileName);

     try
       MemoAct.Lines.LoadFromFile(myFileName);
     except
       StatusBar1.Panels[0].Text := '加载【' + myFileName + '】时遇到错误！';
     end;
  end;
end;

// 选择了“加载”列表项
procedure TActionForm.LoadBoxSelect(Sender: TObject);
var
  str: string;

begin
  StatusBar1.Panels[0].Text := '';
  MemoAct.Lines.Clear;
  case LoadBox.ItemIndex of
    0:                              // 剪切板
      begin
        // 视情况，加载剪贴板中的内容
        if (Clipboard.HasFormat(CF_TEXT) or Clipboard.HasFormat(CF_OEMTEXT)) and (MemoAct.Lines.Count = 0) then begin
            MemoAct.Lines.Add(Clipboard.asText);
        end;
      end;
    1:                              // 已做动作
      begin
        if isBK and (UnDoPos_BK < MaxLenPath) then begin
           UndoList_BK[UnDoPos_BK+1] := #0;
           str  := PChar(@UndoList_BK);
        end else if (not isBK) and (UnDoPos < MaxLenPath) then begin
           UndoList[UnDoPos+1] := #0;
           str  := PChar(@UndoList);
        end else str := '';

        MemoAct.Lines.Add(str);
      end;
    2:                              // 后续动作
      begin
        if isBK and (ReDoPos_BK < MaxLenPath) then begin
           RedoList_BK[ReDoPos_BK+1] := #0;
           str  := PChar(@RedoList_BK);
        end else if (not isBK) and (ReDoPos < MaxLenPath) then begin
           RedoList[ReDoPos+1] := #0;
           str  := PChar(@RedoList);
        end else str := '';

        MemoAct.Lines.Add(str);
      end;
    3:
      try
         MemoAct.Lines.LoadFromFile(ExePath + '\temp\reg1.txt');
         StatusBar1.Panels[0].Text := '【寄存器 1】加载成功！';
      except
         StatusBar1.Panels[0].Text := '【寄存器 1】加载失败！';
      end;
    4:
      try
         MemoAct.Lines.LoadFromFile(ExePath + '\temp\reg2.txt');
         StatusBar1.Panels[0].Text := '【寄存器 2】加载成功！';
      except
         StatusBar1.Panels[0].Text := '【寄存器 2】加载失败！';
      end;
    5:
      try
         MemoAct.Lines.LoadFromFile(ExePath + '\temp\reg3.txt');
         StatusBar1.Panels[0].Text := '【寄存器 3】加载成功！';
      except
         StatusBar1.Panels[0].Text := '【寄存器 3】加载失败！';
      end;
    6:
      try
         MemoAct.Lines.LoadFromFile(ExePath + '\temp\reg4.txt');
         StatusBar1.Panels[0].Text := '【寄存器 4】加载成功！';
      except
         StatusBar1.Panels[0].Text := '【寄存器 4】加载失败！';
      end;
    7:                              // 文档
      LoadFromFile();
  end;
end;

// 选择了“存入”列表项
procedure TActionForm.SaveBoxSelect(Sender: TObject);
begin
  StatusBar1.Panels[0].Text := '';
  case SaveBox.ItemIndex of
  0:                              // 剪切板
      begin
        Clipboard.SetTextBuf(PChar(MemoAct.Lines.Text));
      end;
  1:
    try
       if not DirectoryExists(ExePath+'temp') then ForceDirectories(ExePath+'temp');
       MemoAct.Lines.SaveToFile(ExePath + '\temp\reg1.txt');
       StatusBar1.Panels[0].Text := '已存入【寄存器 1】，可在首界面按【F5】快速加载并执行！- 按当前旋转，从当前点，执行一次。';
    except
       StatusBar1.Panels[0].Text := '存入【寄存器 1】失败！';
    end;
  2:
    try
       if not DirectoryExists(ExePath+'temp') then ForceDirectories(ExePath+'temp');
       MemoAct.Lines.SaveToFile(ExePath + '\temp\reg2.txt');
       StatusBar1.Panels[0].Text := '已存入【寄存器 2】，可在首界面按【F6】快速加载并执行！- 按当前旋转，从当前点，执行一次。';
    except
       StatusBar1.Panels[0].Text := '存入【寄存器 2】失败！';
    end;
  3:
    try
       if not DirectoryExists(ExePath+'temp') then ForceDirectories(ExePath+'temp');
       MemoAct.Lines.SaveToFile(ExePath + '\temp\reg3.txt');
       StatusBar1.Panels[0].Text := '已存入【寄存器 3】，可在首界面按【F7】快速加载并执行！- 按当前旋转，从当前点，执行一次。';
    except
       StatusBar1.Panels[0].Text := '存入【寄存器 3】失败！';
    end;
  4:
    try
       if not DirectoryExists(ExePath+'temp') then ForceDirectories(ExePath+'temp');
       MemoAct.Lines.SaveToFile(ExePath + '\temp\reg4.txt');
       StatusBar1.Panels[0].Text := '已存入【寄存器 4】，可在首界面按【F8】快速加载并执行！- 按当前旋转，从当前点，执行一次。';
    except
       StatusBar1.Panels[0].Text := '存入【寄存器 4】失败！';
    end;
  5:                              // 文档
    SaveToFile();
  end;
end;

end.
