unit Submit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IDHttp;

type
  TMySubmit = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    ComboBox1: TComboBox;
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    SubmitCountry, SubmitName, SubmitEmail, SubmitLurd: string;

  end;
  

var
  MySubmit: TMySubmit;


implementation

{$R *.dfm}

procedure TMySubmit.FormCreate(Sender: TObject);
begin
  Caption := '提交比赛答案';
  Label1.Caption := '国家/地区:';
  Label2.Caption := '姓名:';
  Button1.Caption := '取消(&C)';
  Button2.Caption := '确定(&O)';
  ComboBox1.Items[1] := '中国';
  SubmitLurd := '';
end;

procedure TMySubmit.FormShow(Sender: TObject);
var
  i, size: Integer;

begin
  size := ListBox1.Items.Count;

  for i := 0 to size-1 do begin
      if SubmitCountry = ListBox1.Items[i] then begin
         ComboBox1.ItemIndex := i;
         Break;
      end;
  end;
  if ComboBox1.ItemIndex < 0 then ComboBox1.ItemIndex := 1;
  Edit1.Text := SubmitName;
  Edit2.Text := SubmitEmail;
end;

// Post 请求
function MyPost: string;
var
  IdHttp : TIdHTTP;
  Url : string;                   // 请求地址
  ResponseStream : TStringStream; // 返回信息
  ResponseStr : string;
  RequestList : TStringList;      // 请求信息
//  RequestStream : TStringStream;

begin
  // 创建IDHTTP控件
  IdHttp := TIdHTTP.Create(nil);

  // TStringStream对象用于保存响应信息
  ResponseStream := TStringStream.Create('');

//  RequestStream := TStringStream.Create('');
  RequestList := TStringList.Create;

  try
    Url := 'http://sokoban.cn/submit_result.php';
    
    try
      // 以列表的方式提交参数
      RequestList.Add('nickname=' + MySubmit.SubmitName);
      RequestList.Add('country=' + MySubmit.SubmitCountry);
      RequestList.Add('email=' + MySubmit.SubmitEmail);
      RequestList.Add('lurd=' + MySubmit.SubmitLurd);
      IdHttp.Post(Url, RequestList, ResponseStream);

      // 以流的方式提交参数
//      RequestStream.WriteString('nickname=' + MySubmit.SubmitName);
//      RequestStream.WriteString('country=' + MySubmit.SubmitCountry);
//      RequestStream.WriteString('email=' + MySubmit.SubmitEmail);
//      RequestStream.WriteString('lurd=' + MySubmit.SubmitLurd);
//      IdHttp.Post(Url, RequestStream, ResponseStream);

    except
//      on e : Exception do
//      begin
//        ShowMessage(e.Message);
//      end;
    end;

    // 获取网页返回的信息
    ResponseStr := ResponseStream.DataString;
    
    // 网页中的存在中文时，需要进行UTF8解码
//    ResponseStr := UTF8Decode(ResponseStr);
  finally
    if IdHttp <> nil then FreeAndNil(IdHttp);
    if RequestList <> nil then FreeAndNil(RequestList);
    if ResponseStream <> nil then FreeAndNil(ResponseStream);
  end;

  Result := ResponseStr;
end;

procedure TMySubmit.Button2Click(Sender: TObject);
var
  inf: string;
begin
  SubmitName  := Edit1.Text;
  SubmitEmail := Edit2.Text;

  inf := AnsiLowerCase(MyPost);

  if Pos('correct (for ', inf) > 0 then Caption := '提交成功！'
  else if Pos('not correct', inf) > 0 then Caption := '答案不正确！'
  else if Pos('competition has ended', inf) > 0 then Caption := '比赛已过期，请关注下一期！'
  else if Pos('not begin yet', inf) > 0 then Caption := '比赛尚未开始，请耐心等待！'
  else if Pos('name cannot be empty', inf) > 0 then Caption := '姓名不能空着！'
  else Caption := '未知情况！'
end;

procedure TMySubmit.ComboBox1Change(Sender: TObject);
begin
  SubmitCountry := ListBox1.Items[ComboBox1.ItemIndex];
end;

end.
