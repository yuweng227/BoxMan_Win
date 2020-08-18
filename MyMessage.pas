unit MyMessage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TMsg = class(TForm)
    Panel1: TPanel;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Msg: TMsg;

implementation

{$R *.dfm}

procedure TMsg.FormCreate(Sender: TObject);
begin
  Panel1.Caption := '不合格的关卡';
end;

procedure TMsg.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  Close;
end;

procedure TMsg.FormShow(Sender: TObject);
begin
  Timer1.Enabled := True;
end;

end.
