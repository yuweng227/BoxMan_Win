unit Actions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, StrUtils,
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
    procedure SaveToFile();         // ���涯�����ĵ�
    procedure LoadFromFile();
    procedure Button3Click(Sender: TObject);       // ���ĵ����ض���

  private
    { Private declarations }
  public
    { Public declarations }

    isBK: Boolean;            // ����������Ƿ�����
    Act: string;              // �������Ķ����ַ���
    M_X, M_Y: Integer;        // ���������������˵ĳ�ʼλ��
    MyPath: string;           // �����ĵ���ȡ·��
    ExePath: string;          // �����ĵ���ȡ·��

  end;

var
  ActionForm: TActionForm;

  Act_ManPos_BK: TPoint;   // �����˵�����

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
  // ����������ؼ������е�����
  if (Clipboard.HasFormat(CF_TEXT) or Clipboard.HasFormat(CF_OEMTEXT)) and (MemoAct.Lines.Count = 0) then begin
      MemoAct.Lines.Add(Clipboard.asText);
  end;
end;

procedure TActionForm.Button1Click(Sender: TObject);
var
  i, j, k, len: Integer;
  f: Boolean;
  str: string;
  p: TStrings;
  MyTextFile: TextFile; 

begin
  // ���浱ǰ��֮ǰ�Ķ������Ա�����ڡ�ʱʹ��
  if isBK and (UnDoPos_BK < MaxLenPath) then begin
     UndoList_BK[UnDoPos_BK+1] := #0;
     str  := PChar(@UndoList_BK);
  end else if (not isBK) and (UnDoPos < MaxLenPath) then begin
     UndoList[UnDoPos+1] := #0;
     str  := PChar(@UndoList);
  end else str := '';

  if str <> '' then begin
     if not DirectoryExists(ExePath+'temp') then ForceDirectories(ExePath+'temp');
     AssignFile(MyTextFile, ExePath + '\temp\reg0.txt');
     Rewrite(MyTextFile);
     try
       Writeln(MyTextFile, str);
       Flush(MyTextFile);
     finally
      CloseFile(MyTextFile);
     end;
  end;

  // ����Ϊ��ִ�С�����
  len := MemoAct.Lines.Count;

  Act := '';
  f := False;  // �Ƿ�ʼ��Lurd����
  for i := 0 to len-1 do begin
      str := StringReplace(ActionForm.MemoAct.Lines[i], #9, '', [rfReplaceAll]);
      str := StringReplace(str, ' ', '', [rfReplaceAll]);
      str := StringReplace(str, #10, '', [rfReplaceAll]);
      str := StringReplace(str, #13, '', [rfReplaceAll]);

      if Length(str) <= 0 then Continue;         // ��������
      
      if (not f) and (not isLurd_2(str)) then Continue
      else f := True;
      
      if not isLurd_2(str) then begin
         Act := '';
         MessageBox(handle, '��������Ч�Ķ����ַ������鲢��������ִ�У�', '����', MB_ICONERROR or MB_OK);
         Exit;
      end;
      Act := Act + MemoAct.Lines[i];
  end;

  // ���������ַ���
  M_X := -1;
  M_Y := -1;
  if isBK then begin             // ����
      i := pos('[', Act);
      j := pos(']', Act);
      if (i > 0) and (j > 0) and (j > i) then begin
         str := copy(Act, i+1, j-i-1);
         delete(Act, 1, j);
         p := TStringList.Create;
         try
           p.CommaText := str;

           if p.Count = 2 then begin
              try
                M_X := strToInt(p[0])-1;
                M_Y := strToInt(p[1])-1;
              except
                M_X := -1;
                M_Y := -1;
              end;
           end;
         finally
           if Assigned(p) then begin
              p.Free;
              p := nil;
           end;
         end;
      end else begin
         k := Max(i, j);

         if k > 0 then delete(Act, 1, k);
      end;
  end else begin               // ����
      i := pos('[', str);

      if i > 0 then Act := copy(Act, 1, i-1);
  end;
  
  Tag := 1;
  Close();
end;

// ��������
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

// ��������
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

// �������ҷ�ת
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

// �������·�ת
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
          MemoAct.SelectAll;                              // ȫѡ
      end;
  end;
end;

procedure TActionForm.FormCreate(Sender: TObject);
begin
  Caption := '�����༭';
  Run_CurTru.Caption := '���ֳ���תִ��';
  Run_CurPos.Caption := '�ӵ�ǰ��ִ��';
  Label1.Caption := '�ظ�������';
  Label2.Caption := '���أ�';
  Label3.Caption := '���룺';
  Left_Trun.Caption := '����(&L)';
  Right_Trun.Caption := '����(&R)';
  H_Mirror.Caption := '���ҷ�ת(&H)';
  V_Mirror.Caption := '���·�ת(&V)';
  Button1.Caption := 'ִ��(&E)';
  Button2.Caption := 'ȡ��(&C)';
  LoadBox.Items.Text := '���а�'#13#10'��������'#13#10'��������'#13#10'�Ĵ��� 1'#13#10'�Ĵ��� 2'#13#10'�Ĵ��� 3'#13#10'�Ĵ��� 4'#13#10'�ĵ�'#13#10'�ϴ�ִ��ǰ�Ķ���';
  SaveBox.Items.Text := '���а�'#13#10'�Ĵ��� 1'#13#10'�Ĵ��� 2'#13#10'�Ĵ��� 3'#13#10'�Ĵ��� 4'#13#10'�ĵ�';

  KeyPreview := true;
end;

// ���涯�����ĵ�
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

     if not FileExists(myFileName) or (MessageBox(Handle, PChar(myFileName + #10 + ' �ĵ��Ѿ����ڣ���д����'), '����', MB_ICONWARNING + MB_OKCANCEL) = idOK) then begin
        try
          MemoAct.Lines.SaveToFile(myFileName);
          StatusBar1.Panels[0].Text := '�ĵ� ' + myFileName + '����ɹ���';
        except
          StatusBar1.Panels[0].Text := 'д��' + myFileName + '���ĵ�ʱ��������';
        end;
     end;
     
  end;
end;

// ���ĵ����ض���
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
       StatusBar1.Panels[0].Text := '���ء�' + myFileName + '��ʱ��������';
     end;
  end;
end;

// ѡ���ˡ����ء��б���
procedure TActionForm.LoadBoxSelect(Sender: TObject);
var
  str: string;

begin
  StatusBar1.Panels[0].Text := '';
  MemoAct.Lines.Clear;
  case LoadBox.ItemIndex of
    0:                              // ���а�
      begin
        // ����������ؼ������е�����
        if (Clipboard.HasFormat(CF_TEXT) or Clipboard.HasFormat(CF_OEMTEXT)) and (MemoAct.Lines.Count = 0) then begin
            MemoAct.Lines.Add(Clipboard.asText);
        end;
      end;
    1:                              // ��������
     begin
        if isBK and (UnDoPos_BK < MaxLenPath) and (Act_ManPos_BK.X > 0) and (Act_ManPos_BK.Y > 0) then begin
           UndoList_BK[UnDoPos_BK+1] := #0;
           str  := '[' + IntToStr(Act_ManPos_BK.X) + ', ' + IntToStr(Act_ManPos_BK.Y) + ']' + PChar(@UndoList_BK);
        end else if (not isBK) and (UnDoPos < MaxLenPath) then begin
           UndoList[UnDoPos+1] := #0;
           str  := PChar(@UndoList);
        end else str := '';

        MemoAct.Lines.Add(str);
      end;
    2:                              // ��������
      begin
        if isBK and (ReDoPos_BK < MaxLenPath) then begin
           RedoList_BK[ReDoPos_BK+1] := #0;
           str  := PChar(@RedoList_BK);
        end else if (not isBK) and (ReDoPos < MaxLenPath) then begin
           RedoList[ReDoPos+1] := #0;
           str  := PChar(@RedoList);
        end else str := '';

        MemoAct.Lines.Add(reversestring(str));
      end;
    3:
      try
         MemoAct.Lines.LoadFromFile(ExePath + '\temp\reg1.txt');
         StatusBar1.Panels[0].Text := '���Ĵ��� 1�����سɹ���';
      except
         StatusBar1.Panels[0].Text := '���Ĵ��� 1������ʧ�ܣ�';
      end;
    4:
      try
         MemoAct.Lines.LoadFromFile(ExePath + '\temp\reg2.txt');
         StatusBar1.Panels[0].Text := '���Ĵ��� 2�����سɹ���';
      except
         StatusBar1.Panels[0].Text := '���Ĵ��� 2������ʧ�ܣ�';
      end;
    5:
      try
         MemoAct.Lines.LoadFromFile(ExePath + '\temp\reg3.txt');
         StatusBar1.Panels[0].Text := '���Ĵ��� 3�����سɹ���';
      except
         StatusBar1.Panels[0].Text := '���Ĵ��� 3������ʧ�ܣ�';
      end;
    6:
      try
         MemoAct.Lines.LoadFromFile(ExePath + '\temp\reg4.txt');
         StatusBar1.Panels[0].Text := '���Ĵ��� 4�����سɹ���';
      except
         StatusBar1.Panels[0].Text := '���Ĵ��� 4������ʧ�ܣ�';
      end;
    7:                              // �ĵ�
      LoadFromFile();
    8:
      try
         MemoAct.Lines.LoadFromFile(ExePath + '\temp\reg0.txt');
//         Run_CurPos.Checked := false;
         StatusBar1.Panels[0].Text := '�ɹ����ص��ϴ�ִ��ǰ�Ķ�����';
      except
         StatusBar1.Panels[0].Text := '�����ϴ�ǰ�Ķ���ʧ�ܣ�';
      end;

  end;
end;

// ѡ���ˡ����롱�б���
procedure TActionForm.SaveBoxSelect(Sender: TObject);
begin
  StatusBar1.Panels[0].Text := '';
  case SaveBox.ItemIndex of
  0:                              // ���а�
      begin
        Clipboard.SetTextBuf(PChar(MemoAct.Lines.Text));
        StatusBar1.Panels[0].Text := '�Ѵ�����а壡';
      end;
  1:
    try
       if not DirectoryExists(ExePath+'temp') then ForceDirectories(ExePath+'temp');
       MemoAct.Lines.SaveToFile(ExePath + '\temp\reg1.txt');
       StatusBar1.Panels[0].Text := '�Ѵ��롾�Ĵ��� 1���������׽��水��F5�����ټ��ز�ִ�У�- ����ǰ��ת���ӵ�ǰ�㣬ִ��һ�Ρ�';
    except
       StatusBar1.Panels[0].Text := '���롾�Ĵ��� 1��ʧ�ܣ�';
    end;
  2:
    try
       if not DirectoryExists(ExePath+'temp') then ForceDirectories(ExePath+'temp');
       MemoAct.Lines.SaveToFile(ExePath + '\temp\reg2.txt');
       StatusBar1.Panels[0].Text := '�Ѵ��롾�Ĵ��� 2���������׽��水��F6�����ټ��ز�ִ�У�- ����ǰ��ת���ӵ�ǰ�㣬ִ��һ�Ρ�';
    except
       StatusBar1.Panels[0].Text := '���롾�Ĵ��� 2��ʧ�ܣ�';
    end;
  3:
    try
       if not DirectoryExists(ExePath+'temp') then ForceDirectories(ExePath+'temp');
       MemoAct.Lines.SaveToFile(ExePath + '\temp\reg3.txt');
       StatusBar1.Panels[0].Text := '�Ѵ��롾�Ĵ��� 3���������׽��水��F7�����ټ��ز�ִ�У�- ����ǰ��ת���ӵ�ǰ�㣬ִ��һ�Ρ�';
    except
       StatusBar1.Panels[0].Text := '���롾�Ĵ��� 3��ʧ�ܣ�';
    end;
  4:
    try
       if not DirectoryExists(ExePath+'temp') then ForceDirectories(ExePath+'temp');
       MemoAct.Lines.SaveToFile(ExePath + '\temp\reg4.txt');
       StatusBar1.Panels[0].Text := '�Ѵ��롾�Ĵ��� 4���������׽��水��F8�����ټ��ز�ִ�У�- ����ǰ��ת���ӵ�ǰ�㣬ִ��һ�Ρ�';
    except
       StatusBar1.Panels[0].Text := '���롾�Ĵ��� 4��ʧ�ܣ�';
    end;
  5:                              // �ĵ�
    SaveToFile();
  end;
end;

procedure TActionForm.Button3Click(Sender: TObject);
begin
  try
     MemoAct.Lines.LoadFromFile(ExePath + '\temp\reg0.txt');
     Run_CurPos.Checked := false;
     StatusBar1.Panels[0].Text := '�ɹ����ص��ϴ�ִ��ǰ�Ķ�����';
  except
     StatusBar1.Panels[0].Text := '�����ϴ�ǰ�Ķ���ʧ�ܣ�';
  end;
end;

end.
