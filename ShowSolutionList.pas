unit ShowSolutionList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, Buttons, ExtCtrls, StdCtrls;

type
  TShowSolutuionList = class(TForm)
    WebBrowser1: TWebBrowser;
    Panel1: TPanel;
    sb_Pre: TSpeedButton;
    sb_Next: TSpeedButton;
    SpeedButton1: TSpeedButton;
    Edit1: TEdit;
    sb_Go: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sb_PreClick(Sender: TObject);
    procedure sb_NextClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure sb_GoClick(Sender: TObject);
    procedure Edit1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Edit1DblClick(Sender: TObject);
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
  try
    WebBrowser1.Navigate('http://sokoban.cn/solution_table.php');
  except
  end;
end;

procedure TShowSolutuionList.sb_PreClick(Sender: TObject);
begin
  try
    WebBrowser1.GoBack;
  except
  end;
end;

procedure TShowSolutuionList.sb_NextClick(Sender: TObject);
begin
  try
    WebBrowser1.GoForward;
  except
  end;
end;

procedure TShowSolutuionList.SpeedButton1Click(Sender: TObject);
begin
  try
    WebBrowser1.Refresh;
  except
  end;
end;

procedure TShowSolutuionList.FormResize(Sender: TObject);
begin
  Edit1.Width := Panel1.Width - 200;
  if Edit1.Width < 200 then Edit1.Width := 200;
  sb_Go.Left := Edit1.Left + Edit1.Width;
end;

procedure TShowSolutuionList.sb_GoClick(Sender: TObject);
begin
  try
    WebBrowser1.Navigate(Edit1.Text);
  except
  end;
end;

procedure TShowSolutuionList.Edit1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    13: sb_Go.Click;
  end;
end;

procedure TShowSolutuionList.Edit1DblClick(Sender: TObject);
begin
  Edit1.SelectAll;
end;

end.
