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
  Caption := '�����';
  Button1.Caption := '�����(&I)';
  Button2.Caption := '����(&C)';
  SpeedButton1.Caption := '�ҵ��ĵ�';
  SpeedButton2.Caption := '����';
end;

procedure TMyOpenFile.FormShow(Sender: TObject);
begin
  isStopThread_Ans := True;
  FileListBox1.Update;
  Label1.Caption := '';
  Caption := '�����';
end;

// ͨ��ע���ȡ�á��ҵ��ĵ����͡����桱�ļ���
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
      
// ��ȡ�����桱�ļ���
function GetDeskeptPath: string;
begin
  Result := GetShellFolders('Desktop'); //��ȡ�������ļ��е�·��
end;
      
// ��ȡ���ҵ��ĵ����ļ���
function GetMyDoumentpath: string;
begin
  Result := GetShellFolders('Personal'); //�ҵ��ĵ�
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
     MessageBox(Handle, '��̨��æ�����Ժ����ԣ�', '��ʾ', MB_ICONINFORMATION  + MB_OK);
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
