unit MyInf;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TMyInfForm = class(TForm)
    Timer1: TTimer;
    Panel1: TPanel;

    procedure Timer1Timer(Sender: TObject);

  private
    { Private declarations }

  public
    { Public declarations }

  end;

  procedure ShowMyInfo(info: String; title: string = '提示'; timeout: Integer = 1000);
  
var
  MyInfForm: TMyInfForm;

implementation

{$R *.dfm}


procedure ShowMyInfo(info: String; title: string = '提示'; timeout: Integer = 1000);
Var
  frminfo: TMyInfForm;

begin
  frminfo := TMyInfForm.Create(application);
  frminfo.Caption := title;
  try
    frminfo.Caption := title;
    frminfo.Panel1.Caption := info;
    frminfo.Timer1.Enabled  := false;
    frminfo.Timer1.Interval := timeout;
    frminfo.Timer1.Enabled  := true;
    frminfo.ShowModal;
  finally   
    frminfo.Free;
  end;   
end;

procedure TMyInfForm.Timer1Timer(Sender: TObject);
begin
  ModalResult := mrOK;
end;

end.
