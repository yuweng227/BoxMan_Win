unit OpenFile;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, FileCtrl;

type
  TMyOpenFile = class(TForm)
    FileListBox1: TFileListBox;
    Panel1: TPanel;
    Panel3: TPanel;
    DriveComboBox1: TDriveComboBox;
    Panel4: TPanel;
    DirectoryListBox1: TDirectoryListBox;
    Panel2: TPanel;
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FileListBox1DblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MyOpenFile: TMyOpenFile;

implementation

{$R *.dfm}

// UtF-8文件读取函数
//function LoadUTFFile(const FileName: string): string;
//var
//  MemStream: TMemoryStream;
//  S, HeaderStr:string;
//
//begin
//  Result:='';
//
//  if not FileExists(FileName) then Exit;
//  MemStream := TMemoryStream.Create;
//  try
//    MemStream.LoadFromFile(FileName);
//
//    SetLength(HeaderStr, 3);
//    MemStream.Read(HeaderStr[1], 3);
//    if HeaderStr = #$EF#$BB#$BF then
//    begin
//      SetLength(S, MemStream.Size - 3);
//      MemStream.Read(S[1], MemStream.Size - 3);
//    end else
//    begin
//      SetLength(S, MemStream.Size);
//      MemStream.Read(S[1], MemStream.Size);
//    end;
//
//    Result := Utf8ToAnsi(S);
//  finally
//    MemStream.Free;
//  end;
//end;

// Unicode文件读取函数
//function LoadUnicodeFile(const FileName: string): string;
//var
//  MemStream: TMemoryStream;
//  FlagStr: String;
//  WStr: WideString;
//
//begin
//  Result := '';
//
//  if not FileExists(FileName) then Exit;
//  MemStream := TMemoryStream.Create;
//  try
//    MemStream.LoadFromFile(FileName);
//
//    SetLength(FlagStr, 2);
//    MemStream.Read(FlagStr[1], 2);
//
//    if FlagStr = #$FF#$FE then
//    begin
//      SetLength(WStr, (MemStream.Size-2) div 2);
//      MemStream.Read(WStr[1], MemStream.Size - 2);
//    end else
//    begin
//      SetLength(WStr, MemStream.Size div 2);
//      MemStream.Read(WStr[1], MemStream.Size);
//    end;
//    
//    Result := AnsiString(WStr);
//  finally
//    MemStream.Free;
//  end;
//end;

procedure TMyOpenFile.FormCreate(Sender: TObject);
begin
  Caption := '打开关卡文档';
  Button1.Caption := '打开(&O)';
  Button2.Caption := '取消';
  CheckBox1.Caption := '若关卡有答案，则同时导入';
end;

procedure TMyOpenFile.FileListBox1DblClick(Sender: TObject);
begin
  Button1.Click;
end;

procedure TMyOpenFile.FormShow(Sender: TObject);
begin
  CheckBox1.Checked := False;
  FileListBox1.Update;
end;

end.
