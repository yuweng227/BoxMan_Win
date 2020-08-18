unit BrowseLevels;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ComCtrls, ImgList, Math, CommCtrl, Menus, StdCtrls, ExtCtrls, Buttons, LoadMapUnit;

  
type
  TBrowseForm = class(TForm)
    ListView1: TListView;
    PopupMenu1: TPopupMenu;
    B1: TMenuItem;
    Panel1: TPanel;
    ColorBox1: TColorBox;
    Label1: TLabel;
    SpeedButton1: TSpeedButton;
    I1: TMenuItem;
    ImageList1: TImageList;        // 背景色

    procedure ListView1DblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListView1AdvancedCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage;
      var DefaultDraw: Boolean);
    procedure ListView1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure B1Click(Sender: TObject);
    procedure ColorBox1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure I1Click(Sender: TObject);
    procedure DrawIcon(cv: TCanvas; mapNode: PMapNode);    // 画图标

  private
    { Private declarations }

  public
    { Public declarations }

    Map_Icon: TBitmap;       // 关卡图标
    BK_Color: TColor;        // 浏览背景色
    curIndex: Integer;
    
  end;

var
  BrowseForm: TBrowseForm;
  Size_Icon, Solved_Count: Integer;      // 图标尺寸，有解关卡数
  myTitle: string;

implementation

uses
  LoadSkin, inf, MainForm, DateModule;

{$R *.dfm}

procedure TBrowseForm.ListView1DblClick(Sender: TObject);
begin
  if ListView1.ItemIndex >= 0 then begin
     Tag := 0;
     Close;
  end else Caption := myTitle;
end;

procedure TBrowseForm.FormShow(Sender: TObject);
var
  i: integer;
  mapNode: PMapNode;
  
begin
  ListView1.Color := BK_Color;

  Solved_Count := 0;
  for i := 0 to MapList.Count-1 do begin   // 添加 item
    mapNode := MapList[i];
    if mapNode.Solved then inc(Solved_Count);
  end;

  if (curIndex < 0) or (curIndex >= MapList.Count) then curIndex := 0;

  if ListView1.Items.Count > 0 then begin
    ListView1.ItemIndex := curIndex;
    ListView1.Items[curIndex].MakeVisible(True);
  end;

  myTitle := '浏览 [完成率: ' + IntToStr(Solved_Count) + '/' + IntToStr(MapList.Count) + ']';
  if ListView1.ItemIndex < 0 then Caption := myTitle
  else Caption := myTitle + ' - ' + '【№: ' + IntToStr(ListView1.ItemIndex+1) + '】' + mapNode.Title + ',  作者: ' + mapNode.Author;
end;

procedure TBrowseForm.FormCreate(Sender: TObject);
begin
  BK_Color := clWhite;
  Caption := '浏览';
  Label1.Caption := '选择背景颜色: ';
  PopupMenu1.Items[0].Caption := '背景色(&B)';
  PopupMenu1.Items[1].Caption := '详细(&I)...';

  ListView1.DoubleBuffered := true;    // 启用双缓存，防止闪屏，但感觉没啥用

  Size_Icon := 150;                    // 图标尺寸

  Map_Icon := TBitmap.Create;
  Map_Icon.Width := ImageList1.Width;
  Map_Icon.Height := ImageList1.Height;

  SendMessage(ListView1.Handle, LVM_SETICONSPACING, 0, MakeLong(Size_Icon + 10, Size_Icon + 20)); // 设定icon的间距

end;

// 画图标
procedure TBrowseForm.DrawIcon(cv: TCanvas; mapNode: PMapNode);
var
  i, j, x_Size, y_Size, cell_Size, x, y, Rows, Cols, len: Integer;
  R: TRect;
  ch: Char;

begin
  Rows := mapNode.Map.Count;
  Cols := Length(mapNode.Map[0]);

  x_Size := Size_Icon div Cols;
  y_Size := Size_Icon div Rows;
  cell_Size := Min(x_Size, y_Size);
  x := (Size_Icon - cell_Size * Cols) div 2;
  y := (Size_Icon - cell_Size * Rows) div 2;

  for i := 0 to Rows-1 do begin
      len := Length(mapNode.Map[i]);
      for j := 1 to Cols do begin
          R := Rect((j-1) * cell_Size + x, i * cell_Size + y, j * cell_Size + x, (i+1) * cell_Size + y);
          
          if j > len then ch := '-'
          else ch := mapNode.Map[i][j];

          case ch of
            '#': cv.StretchDraw(R, WallPic);
            '-': cv.StretchDraw(R, FloorPic);
            '.': cv.StretchDraw(R, GoalPic);
            '$': cv.StretchDraw(R, BoxPic);
            '*': cv.StretchDraw(R, BoxGoalPic);
            '@': cv.StretchDraw(R, ManPic);
            '+': cv.StretchDraw(R, ManGoalPic);
          end;
      end;
  end;

  // 不合格的关卡
  if not mapNode.isEligible then begin
     cv.Pen.Color := $0000ff;
     cv.Pen.Width := 2;
     cv.MoveTo(0, 0);
     cv.LineTo(Size_Icon, Size_Icon);
     cv.MoveTo(0, Size_Icon);
     cv.LineTo(Size_Icon, 0);
  end;
end;

procedure TBrowseForm.ListView1AdvancedCustomDrawItem(
  Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  Stage: TCustomDrawStage; var DefaultDraw: Boolean);
var
  mapNode: PMapNode;
  R: TRect;

begin
  mapNode := MapList[Item.index];
  if mapNode.Solved then Sender.Canvas.Brush.Color := $009600;

  // 如还没有画好图标
  if Item.ImageIndex < 0 then begin
     Map_Icon.Canvas.Brush.Color := BK_Color;
     Map_Icon.Canvas.FillRect(Rect(0, 0, Size_Icon, Size_Icon));
     DrawIcon(Map_Icon.Canvas, mapNode);
     R := Item.DisplayRect(drBounds);
     ListView1.Canvas.Draw(r.Left + 8, r.top, Map_Icon);
     ImageList1.Add(Map_Icon, nil);
     Item.ImageIndex := ImageList1.Count-1;
  end;
end;

procedure TBrowseForm.ListView1Click(Sender: TObject);
var
  mapNode: PMapNode;
  i, j: Integer;
  
begin
  if ListView1.ItemIndex < 0 then Caption := myTitle
  else begin
     mapNode := MapList[ListView1.ItemIndex];
     mapNode.Boxs := 0;
     mapNode.Goals := 0;
     for i := 0 to mapNode.Rows-1 do begin
         for j := 1 to mapNode.Cols do begin
             if mapNode.Map[i][j] in ['$', '*'] then Inc(mapNode.Boxs);
             if mapNode.Map[i][j] in ['.', '*', '+'] then Inc(mapNode.Goals);
         end;
     end;
     Caption := myTitle + ' - ' + '【№: ' + IntToStr(ListView1.ItemIndex+1) + '，尺寸: ' + IntToStr(mapNode.Cols) + '×' + IntToStr(mapNode.Rows) + '，箱子: ' + IntToStr(mapNode.Boxs) + '，目标: ' + IntToStr(mapNode.Goals) + '】' + mapNode.Title + ',  作者: ' + mapNode.Author;      // 得到对应数据的前地址
  end;
end;

procedure TBrowseForm.FormResize(Sender: TObject);
begin
  ListView1.Repaint;
end;

// 关卡详细资料
procedure TBrowseForm.B1Click(Sender: TObject);
var
  i, size: Integer;

begin
  Panel1.Visible := True;
  size := ColorBox1.Items.Count;
  for i := 0 to size-1 do begin
      if BK_Color = ColorBox1.Colors[i] then ColorBox1.ItemIndex := i
      else
      ColorBox1.ItemIndex := clWhite;
  end;
end;

procedure TBrowseForm.ColorBox1Click(Sender: TObject);
begin
  BK_Color := ColorBox1.Colors[ColorBox1.ItemIndex];
  Panel1.Visible := false;
  ListView1.Color := BK_Color;
end;

procedure TBrowseForm.SpeedButton1Click(Sender: TObject);
begin
  Panel1.Visible := false;
end;

procedure TBrowseForm.I1Click(Sender: TObject);
var
  mapNode: PMapNode;
  i, size: Integer;

begin
   if (ListView1.ItemIndex >= 0) and (not Panel1.Visible) then begin
      mapNode := MapList[ListView1.ItemIndex];
      InfForm.Memo1.Lines.Clear;
      size := mapNode.Map.Count;
      for i :=0 to size-1 do begin
          InfForm.Memo1.Lines.Add(mapNode.Map[i]);
      end;
      InfForm.Memo1.Lines.Add('Title: ' + mapNode.Title);
      InfForm.Memo1.Lines.Add('Author: ' + mapNode.Author);
      if Trim(mapNode.Comment) <> '' then begin
         InfForm.Memo1.Lines.Add('Comment: ');
         InfForm.Memo1.Lines.Add(mapNode.Comment);
         InfForm.Memo1.Lines.Add('Comment_End: ');
      end;
      InfForm.ShowModal;
   end;
end;

end.
