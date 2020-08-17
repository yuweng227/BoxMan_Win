unit BrowseLevels;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ComCtrls, ImgList, Math, CommCtrl, Menus, StdCtrls, ExtCtrls, Buttons;

type
  TBrowseForm = class(TForm)
    ListView1: TListView;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    B1: TMenuItem;
    Panel1: TPanel;
    ColorBox1: TColorBox;
    Label1: TLabel;
    SpeedButton1: TSpeedButton;
    I1: TMenuItem;        // 背景色

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

  private
    { Private declarations }

  public
    { Public declarations }

    Map_Icon: TBitmap;       // 关卡图标
    BK_Color: TColor;        // 浏览背景色
    
  end;

var
  BrowseForm: TBrowseForm;
  Size_Icon, Solved_Count: Integer;      // 图标尺寸，有解关卡数
  myTitle: string;

implementation

uses
  LoadSkin, LoadMap, inf;

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
  ListView1.Items.Clear;
  try
    ListView1.Color := BK_Color;
  except
  end;

  Solved_Count := 0;
  for i := 0 to MapList.Count-1 do begin   // 添加空 item
      ListView1.Items.add;
      mapNode := MapList[i];
      if mapNode.Solved then inc(Solved_Count);
  end;
  myTitle := '浏览 [完成: ' + IntToStr(Solved_Count) + '/' + IntToStr(MapList.Count) + ']';
  Caption := myTitle;
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
procedure DrawIcon(cv: TCanvas; mapNode: PMapNode);
var
  i, j, x_Size, y_Size, cell_Size, x, y: Integer;
  R: TRect;

begin
  x_Size := Size_Icon div mapNode.Cols;
  y_Size := Size_Icon div mapNode.Rows;
  cell_Size := Min(x_Size, y_Size);
  x := (Size_Icon - cell_Size * mapNode.Cols) div 2;
  y := (Size_Icon - cell_Size * mapNode.Rows) div 2;

  for i := 0 to mapNode.Rows-1 do begin
      for j := 1 to mapNode.Cols do begin
          R := Rect((j-1) * cell_Size + x, i * cell_Size + y, j * cell_Size + x, (i+1) * cell_Size + y);
          case mapNode.Map[i][j] of
              '#': begin
                   cv.StretchDraw(R, WallPic);
              end;
              '-': begin
                   cv.StretchDraw(R, FloorPic);
              end;
              '.': begin
                   cv.StretchDraw(R, GoalPic);
              end;
              '$': begin
                   cv.StretchDraw(R, BoxPic);
              end;
              '*': begin
                   cv.StretchDraw(R, BoxGoalPic);
              end;
              '@': begin
                   cv.StretchDraw(R, ManPic);
              end;
              '+': begin
                   cv.StretchDraw(R, ManGoalPic);
              end;
          end;
      end;
  end;
end;

procedure TBrowseForm.ListView1AdvancedCustomDrawItem(
  Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  Stage: TCustomDrawStage; var DefaultDraw: Boolean);
var
  R: TRect;    // R 为文字覆盖的范围
  s: string;
  mapNode: PMapNode;

begin
  mapNode := MapList[Item.index];
  R := Item.DisplayRect(drBounds);

  // 关卡序号
  if mapNode.Title = '' then s := '【№' + IntToStr(Item.index+1) + '】'
  else s := mapNode.Title;

  with ListView1.Canvas do begin
    // 画图标
    Map_Icon.Canvas.Brush.Color := BrowseForm.BK_Color;
    Map_Icon.Canvas.FillRect(Rect(0, 0, Size_Icon, Size_Icon));
    DrawIcon(Map_Icon.Canvas, mapNode);

    // 缩略图的左下角加上关卡序号
//    Map_Icon.Canvas.Font.Size := 10;
    Map_Icon.Canvas.Font.Color := clBlue;
    Map_Icon.Canvas.TextOut(0, Size_Icon-15, '№' + IntToStr(Item.index+1));

    // 画焦点框
    if cdsSelected in State then begin
       Map_Icon.Canvas.DrawFocusRect(Rect(0, 0, Size_Icon, Size_Icon));
    end;
    Draw(r.Left + 8, r.top, Map_Icon);


    // 画标题
    r.top := r.top + Size_Icon;
    r.Bottom := r.Bottom;
    r.left := r.left;
    r.right := r.right;
    SetBkMode(Handle, TRANSPARENT);                // 设定文字为透明
    if mapNode.Solved then begin                   
       Sender.Canvas.Brush.Color := $009500;       // 绿色标识已解关卡
    end else begin
       Sender.Canvas.Brush.Color := BrowseForm.BK_Color;
    end;
    FillRect(r);
    DrawText(Handle, PChar(s), Length(s), r, DT_WORDBREAK or DT_CENTER);
  end;
  
  with Sender.Canvas do
    if Assigned(Font.OnChange) then Font.OnChange(Font);

end;

procedure TBrowseForm.ListView1Click(Sender: TObject);
var
  mapNode: PMapNode;
  
begin
  if ListView1.ItemIndex >= 0 then begin
     mapNode := MapList[ListView1.ItemIndex];
     Caption := myTitle + ' - ' + mapNode.Title + ',  作者: ' + mapNode.Author;      // 得到对应数据的前地址
  end else Caption := myTitle;;
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
