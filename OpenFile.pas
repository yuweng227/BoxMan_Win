unit OpenFile;

interface

{$WARN UNIT_PLATFORM OFF}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, LogFile,
  Dialogs, StdCtrls, ExtCtrls, Registry, Buttons, FileCtrl, StrUtils;

type
  TMyOpenFile = class(TForm)
    FileListBox1: TFileListBox;
    Panel2: TPanel;
    Button1: TButton;
    Button2: TButton;
    Panel3: TPanel;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    DriveComboBox1: TDriveComboBox;
    DirectoryListBox1: TDirectoryListBox;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DirectoryListBox1Change(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
  end;

var
  MyOpenFile: TMyOpenFile;

implementation

uses
  LoadMapUnit, MainForm;

{$R *.dfm}

procedure TMyOpenFile.FormCreate(Sender: TObject);
begin
  Caption := '导入答案';
  Button1.Caption := '导入答案(&I)';
  Button2.Caption := '取消(&C)';
  SpeedButton1.Caption := '我的文档';
  SpeedButton2.Caption := '桌面';
end;

procedure TMyOpenFile.FormShow(Sender: TObject);
begin
  isStopThread_Ans := True;
  FileListBox1.Update;
  Label1.Caption := '';
  Caption := '导入答案';
end;

// 通过注册表，取得“我的文档”和“桌面”文件夹
function GetShellFolders(strDir: string): string;
const
  regPath = '\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders';
var
  Reg: TRegistry;
  strFolders: string;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(regPath, false) then begin
      strFolders := Reg.ReadString(strDir);
    end;
  finally
    Reg.Free;
  end;
  result := strFolders;
end;
      
// 获取“桌面”文件夹
function GetDeskeptPath: string;
begin
  Result := GetShellFolders('Desktop'); //是取得桌面文件夹的路径
end;
      
// 获取“我的文档”文件夹
function GetMyDoumentpath: string;
begin
  Result := GetShellFolders('Personal'); //我的文档
end;

procedure TMyOpenFile.DirectoryListBox1Change(Sender: TObject);
begin
  DriveComboBox1.Drive := DirectoryListBox1.Directory[1];
  FileListBox1.Update;
end;

procedure TMyOpenFile.SpeedButton1Click(Sender: TObject);
begin
  DirectoryListBox1.Directory := GetMyDoumentpath;
end;

procedure TMyOpenFile.SpeedButton2Click(Sender: TObject);
begin
  DirectoryListBox1.Directory := GetDeskeptPath;
end;

procedure TMyOpenFile.Button1Click(Sender: TObject);
begin
  if not isStopThread_Ans then begin
     MessageBox(Handle, '后台正忙，请稍后再试！', '提示', MB_ICONINFORMATION  + MB_OK);
  end;
  
  if FileListBox1.FileName <> '' then begin
     Label1.Caption := '';
     TLoadAnsThread.Create(False);
  end;
end;

procedure TMyOpenFile.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TMyOpenFile.FormDeactivate(Sender: TObject);
begin
  Self.WindowState := wsMinimized;
end;

procedure TMyOpenFile.FormClick(Sender: TObject);
begin
  Self.WindowState := wsNormal;
end;

procedure TMyOpenFile.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  isStopThread_Ans := True;
end;

procedure TMyOpenFile.FormDestroy(Sender: TObject);
begin
  isStopThread_Ans := True;
end;

end.
