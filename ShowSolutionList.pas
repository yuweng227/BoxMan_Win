unit ShowSolutionList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw;

type
  TShowSolutuionList = class(TForm)
    WebBrowser1: TWebBrowser;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ShowSolutuionList: TShowSolutuionList;

implementation

{$R *.dfm}

procedure TShowSolutuionList.FormCreate(Sender: TObject);
begin
  Caption := '比赛答案提交列表';
end;

procedure TShowSolutuionList.FormShow(Sender: TObject);
begin
  WebBrowser1.Navigate('http://sokoban.cn/solution_table.php');
end;

end.
