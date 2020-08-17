unit inf;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TInfForm = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
  end;

var
  InfForm: TInfForm;

implementation

{$R *.dfm}

procedure TInfForm.FormCreate(Sender: TObject);
begin
  Caption := 'ÏêÏ¸';
end;

end.
