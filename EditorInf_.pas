unit EditorInf_;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TEditorInfForm_ = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    procedure Edit1Change(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EditorInfForm_: TEditorInfForm_;

implementation

{$R *.dfm}

procedure TEditorInfForm_.Edit1Change(Sender: TObject);
begin
  EditorInfForm_.Tag := 1;
end;

procedure TEditorInfForm_.Button2Click(Sender: TObject);
begin
  EditorInfForm_.Tag := 0;
end;

procedure TEditorInfForm_.FormCreate(Sender: TObject);
begin
  Caption := '关卡资料';

  Label1.Caption := '标题：';
  Label2.Caption := '作者：';
  Label3.Caption := '说明：';

  Button1.Caption := '确定(&O)';
  Button2.Caption := '取消(&C)';
end;

end.
