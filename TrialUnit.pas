unit TrialUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, ComCtrls, AppEvnts, PathFinder, StdCtrls;

type
  TTrialForm = class(TForm)
    pl_Tools: TPanel;
    bt_UnDo: TSpeedButton;
    bt_ReDo: TSpeedButton;
    bt_OddEven: TSpeedButton;
    bt_GoThrough: TSpeedButton;
    bt_Exit: TSpeedButton;
    pl_Ground: TPanel;
    map_Image: TImage;
    StatusBar1: TStatusBar;
    ApplicationEvents1: TApplicationEvents;
    SpeedButton1: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure bt_ExitMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bt_ExitClick(Sender: TObject);
    
    function  GetWall(r, c: Integer): Integer;
    procedure DrawLine(cs: TCanvas; x1, y1: Integer; isLine: boolean);
    procedure DrawMap();
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    
    map_Board: array[0..9999] of Char;             // 试炼场地图

    isBK: boolean;             // 是否逆推模式
    isGoThrough: boolean;      // 穿越是否开启
    isOddEven: Boolean;        // 是否显示奇偶特效

    mapRows, mapCols, manPos: Integer;

    myPathFinder: TPathFinder;

  end;

const
  minWindowsWidth = 600;                            // 程序窗口最小尺寸限制
  minWindowsHeight = 400;

var
  TrialForm: TTrialForm;

  IsManAccessibleTips, IsBoxAccessibleTips: Boolean;
  CellSize: Integer;

implementation

uses
  LurdAction, LoadSkin;

{$R *.dfm}

procedure TTrialForm.FormCreate(Sender: TObject);
begin
  Caption := '演练场';
  bt_Exit.Caption := '返回';
  bt_GoThrough.Caption := '穿越';
  bt_OddEven.Caption := '奇偶';

  bt_Exit.Hint := '返回编辑: Esc';
  bt_GoThrough.Hint := '穿越开关: G';
  bt_OddEven.Hint := '奇偶格位: E';

  StatusBar1.Panels[0].Text := '移动';
  StatusBar1.Panels[2].Text := '推动';
  StatusBar1.Panels[4].Text := '标尺';

  KeyPreview := true;
end;

procedure TTrialForm.bt_ExitMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  StatusBar1.Panels[7].Text := bt_Exit.Hint;
end;

procedure TTrialForm.bt_ExitClick(Sender: TObject);
begin
  Close;
end;

// 计算无缝墙壁图元
function TTrialForm.GetWall(r, c: Integer): Integer;
var
  pos: Integer;
begin
  result := 0;

  pos := r * mapCols + c;

  if (c > 0) and (map_Board[r * mapCols + c - 1] = '#') then
    result := result or 1;  // 左有墙壁
  if (r > 0) and (map_Board[(r - 1) * mapCols + c] = '#') then
    result := result or 2;  // 上有墙壁
  if (c < mapCols - 1) and (map_Board[r * mapCols + c + 1] = '#') then
    result := result or 4;  // 右有墙壁
  if (r < mapRows - 1) and (map_Board[(r + 1) * mapCols + c] = '#') then
    result := result or 8;  // 下有墙壁

  if ((result = 3) or (result = 7) or (result = 11) or (result = 15)) and (c > 0) and (r > 0) and (map_Board[pos - mapCols - 1] = '#') then
    result := result or 16;  // 需要画墙顶
end;

// 比较图元格第一像素颜色与地板格颜色是否相同，以确定是否画格线
procedure TTrialForm.DrawLine(cs: TCanvas; x1, y1: Integer; isLine: boolean);
begin
  if isLine then
  begin
    cs.Pen.Color := LineColor;
    cs.MoveTo(x1, y1);
    cs.LineTo(x1 + CellSize, y1);
    cs.MoveTo(x1, y1);
    cs.LineTo(x1, y1 + CellSize);
  end;
end;

// 重画地图
procedure TTrialForm.DrawMap();
var
  i, j, k, dx, dy, x1, y1, x2, y2, x3, y3, x4, y4, pos, t1, t2, man_Pos_: integer;
  R, R2: TRect;

begin

  // 鼠标样式
  if IsManAccessibleTips or IsBoxAccessibleTips then map_Image.Cursor := crDrag
  else map_Image.Cursor := crDefault;

  map_Image.Visible := false;

  for i := 0 to mapRows - 1 do
  begin
    for j := 0 to mapCols - 1 do
    begin
      pos := i * mapCols + j;    // 地图中，“格子”的真实位置

      x1 := j * CellSize;        // x1, y1 是地图元素的绘制坐标 -- 旋转后的
      y1 := i * CellSize;

      R := Rect(x1, y1, x1 + CellSize, y1 + CellSize);        // 地图格子的绘制矩形

      map_Image.Canvas.CopyMode := SRCCOPY;
      case map_Board[pos] of
        '#':
          if isSeamless then
          begin    // 无缝墙壁
            k := GetWall(i, j);
            case (k and $F) of
              1:
                map_Image.Canvas.StretchDraw(R, WallPic_l);     // 仅左
              2:
                map_Image.Canvas.StretchDraw(R, WallPic_u);     // 仅上
              3:
                map_Image.Canvas.StretchDraw(R, WallPic_lu);    // 左、上
              4:
                map_Image.Canvas.StretchDraw(R, WallPic_r);     // 仅右
              5:
                map_Image.Canvas.StretchDraw(R, WallPic_lr);    // 左、右
              6:
                map_Image.Canvas.StretchDraw(R, WallPic_ru);    // 右、上
              7:
                map_Image.Canvas.StretchDraw(R, WallPic_lur);   // 左、上、右
              8:
                map_Image.Canvas.StretchDraw(R, WallPic_d);     // 仅下
              9:
                map_Image.Canvas.StretchDraw(R, WallPic_ld);    // 左、下
              10:
                map_Image.Canvas.StretchDraw(R, WallPic_ud);    // 上、下
              11:
                map_Image.Canvas.StretchDraw(R, WallPic_uld);   // 左、上、下
              12:
                map_Image.Canvas.StretchDraw(R, WallPic_rd);    // 右、下
              13:
                map_Image.Canvas.StretchDraw(R, WallPic_ldr);   // 左、右、下
              14:
                map_Image.Canvas.StretchDraw(R, WallPic_urd);   // 上、右、下
              15:
                map_Image.Canvas.StretchDraw(R, WallPic_lurd);  // 四方向全有
            else
              map_Image.Canvas.StretchDraw(R, WallPic);
            end;
            if k > 15 then
            begin     // 需要画上墙的顶部 -- “连体四块”墙壁
              dx := R.Left - CellSize div 2;
              dy := R.Top - CellSize div 2;
              map_Image.Canvas.StretchDraw(Rect(dx, dy, dx + CellSize, dy + CellSize), WallPic_top);
            end;
          end
          else
          begin                 // 简单墙壁
            map_Image.Canvas.StretchDraw(R, WallPic);
          end;
        '-':
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, FloorPic2)
            else map_Image.Canvas.StretchDraw(R, FloorPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isFloorLine);  // 画网格线
          end;
        '.':
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, GoalPic2)
            else map_Image.Canvas.StretchDraw(R, GoalPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isGoalLine);   // 画网格线
          end;
        '$':
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, BoxPic2)
            else map_Image.Canvas.StretchDraw(R, BoxPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isBoxLine);    // 画网格线
          end;
        '*':
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, BoxGoalPic2)
            else map_Image.Canvas.StretchDraw(R, BoxGoalPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isBoxGoalLine); // 画网格线
          end;
        '@':
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, ManPic2)
            else map_Image.Canvas.StretchDraw(R, ManPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isManLine);    // 画网格线
          end;
        '+':
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, ManGoalPic2)
            else map_Image.Canvas.StretchDraw(R, ManGoalPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isManGoalLine); // 画网格线
          end;
      else
        if isBK then
           map_Image.Canvas.Brush.Color := clBlack
        else
           map_Image.Canvas.Brush.Color := clInactiveCaptionText;
          
        map_Image.Canvas.FillRect(R);
      end;

      // 是否“逆推模式”
      if isBK then
      begin

        if IsManAccessibleTips then
        begin   // 显示人的可达提示
          t1 := CellSize div 6;
          if t1 < 4 then t1 := 4;
          t2 := t1 - 1;
          if myPathFinder.isManReachableByThrough_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.FillRect(Rect(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1));
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.FillRect(Rect(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2));
          end
          else if myPathFinder.isManReachable_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2);
          end
          else if myPathFinder.isBoxOfThrough_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2);
          end;
        end;
        if IsBoxAccessibleTips then
        begin   // 显示箱子的可达提示
          t1 := CellSize div 6;
          if t1 < 4 then t1 := 4;
          t2 := t1 - 1;
          if myPathFinder.isBoxReachable_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2);
          end;
        end;
      end
      else                                                                      // 正推
      begin
        if IsManAccessibleTips then
        begin   // 显示人的可达提示
          t1 := CellSize div 6;
          if t1 < 4 then t1 := 4;
          t2 := t1 - 1;
          if myPathFinder.isManReachableByThrough(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.FillRect(Rect(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1));
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.FillRect(Rect(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2));
          end
          else if myPathFinder.isManReachable(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2);
          end
          else if myPathFinder.isBoxOfThrough(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2);
          end;
        end;
        if IsBoxAccessibleTips then
        begin   // 显示箱子的可达提示
          t1 := CellSize div 6;
          if t1 < 4 then t1 := 4;
          t2 := t1 - 1;
          if myPathFinder.isBoxReachable(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2);
          end;
        end;
      end;
    end;
  end;

  map_Image.Visible := true;

//  ShowStatusBar();
end;

procedure TTrialForm.FormShow(Sender: TObject);
begin
  DrawMap;
end;

procedure TTrialForm.SpeedButton1Click(Sender: TObject);
begin
  DrawMap;
end;

end.
