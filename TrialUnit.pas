unit TrialUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, ComCtrls, AppEvnts, PathFinder, Math, StdCtrls, Clipbrd;

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
    pnl_Trun: TPanel;
    bt_Save: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure bt_ExitMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bt_ExitClick(Sender: TObject);
    
    function  GetWall(r, c: Integer): Integer;
    procedure DrawLine(cs: TCanvas; x1, y1: Integer; isLine: boolean);
    procedure DrawMap();
    procedure FormShow(Sender: TObject);
    procedure NewMapSize();
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SetButton();
    procedure bt_GoThroughClick(Sender: TObject);
    procedure LoadDefaultSkin();
    procedure ReDo(Steps: Integer);
    procedure UnDo(Steps: Integer);
    procedure ReDo_BK(Steps: Integer);
    procedure UnDo_BK(Steps: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure bt_OddEvenMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure bt_OddEvenMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure bt_UnDoClick(Sender: TObject);
    procedure bt_ReDoClick(Sender: TObject);
    procedure SetMapTrun();
    procedure pnl_TrunMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure map_ImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    function GetStep(len: Integer): Integer;
    function GetStep2(len: Integer): Integer;
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure bt_SaveClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    
    map_Board: array[0..9999] of Integer;             // 试炼场地图

    isBK: boolean;             // 是否逆推模式
    isGoThrough: boolean;      // 穿越是否开启
    isOddEven: Boolean;        // 是否显示奇偶特效
    curTrun: Integer;          // 关卡旋转序号

    OldBoxPos: Integer;        // 被点击的箱子
    LastSteps: Integer;        // 上次点推前的步数

    mapRows, mapCols, manPos, MapSize, MoveTimes, PushTimes: Integer;

    myPathFinder: TPathFinder;

  end;

const
  minWindowsWidth = 600;                            // 程序窗口最小尺寸限制
  minWindowsHeight = 400;
  
  MapTrun: array[0..7] of string = ('0转', '1转', '2转', '3转', '4转', '5转', '6转', '7转');

var
  TrialForm: TTrialForm;

  IsManAccessibleTips, IsBoxAccessibleTips: Boolean;
  CellSize: Integer;

  // 地图旋转控制数组
  MapDir: array[0..7, 0..6] of Integer = (
    (1, 2, 4, 8, 3, 7, 11),    // 0 转
    (2, 4, 8, 1, 6, 7, 14),    // 1
    (4, 8, 1, 2, 12, 13, 14),  // 2
    (8, 1, 2, 4, 9, 13, 11),   // 3
    (4, 2, 1, 8, 6, 7, 14),    // 4
    (8, 4, 2, 1, 12, 13, 14),  // 5
    (1, 8, 4, 2, 9, 13, 11),   // 6
    (2, 1, 8, 4, 3, 7, 11));   // 7

    ActDir: array[0..7, 0..7] of Char = (                   // 动作 8 方位旋转之 n 转的换算数组
            ('l', 'u', 'r', 'd', 'L', 'U', 'R', 'D'),
            ('d', 'l', 'u', 'r', 'D', 'L', 'U', 'R'),
            ('r', 'd', 'l', 'u', 'R', 'D', 'L', 'U'),
            ('u', 'r', 'd', 'l', 'U', 'R', 'D', 'L'),
            ('r', 'u', 'l', 'd', 'R', 'U', 'L', 'D'),
            ('d', 'r', 'u', 'l', 'D', 'R', 'U', 'L'),
            ('l', 'd', 'r', 'u', 'L', 'D', 'R', 'U'),
            ('u', 'l', 'd', 'r', 'U', 'L', 'D', 'R'));

    xbsChar: array[0..7] of Char = ( '_', '#', '-', '.', '$', '*', '@', '+' );

implementation

uses
  Editor_, LurdAction, LoadSkin, Recog_;

{$R *.dfm}

// 重做一步 -- 正推
procedure TTrialForm.ReDo(Steps: Integer);
var
  ch, ch_: Char;
  pos1, pos2: Integer;

begin
  StatusBar1.Panels[7].Text := '';

  IsBoxAccessibleTips := False;
  IsManAccessibleTips := False;

  while (Steps > 0) and (ReDoPos > 0) and (UnDoPos < MaxLenPath) do begin

    // 人的位置出现异常
    if (ManPos < 0) or (ManPos >= MapSize) or
       (not (map_Board[ManPos] in [ManCell, ManGoalCell])) then begin
       StatusBar1.Panels[7].Text := format('人的位置异常！- [%d, %d]', [ManPos mod mapCols + 1, ManPos div mapCols + 1]);
       Break;
    end;

    ch  := RedoList[ReDoPos];
    ch_ := ch;

    pos1 := -1;
    pos2 := -1;
    case ch of
      'l', 'L':
        begin
          pos1 := ManPos - 1;
          pos2 := ManPos - 2;
          ch := 'l';
        end;
      'r', 'R':
        begin
          pos1 := ManPos + 1;
          pos2 := ManPos + 2;
          ch := 'r';
        end;
      'u', 'U':
        begin
          pos1 := ManPos - mapCols;
          pos2 := ManPos - mapCols * 2;
          ch := 'u';
        end;
      'd', 'D':
        begin
          pos1 := ManPos + mapCols;
          pos2 := ManPos + mapCols * 2;
          ch := 'd';
        end;
    end;

    if (pos1 < 0) or (pos1 >= MapSize) then begin                        // pos1 界外
       StatusBar1.Panels[7].Text := '遇到了错误的动作符号！- ' + ch_;
       Break;
    end;

    // 遇到地板，仅仅移动人即可；若遇到箱子，需要同时移动箱子和人；否则，遇到了错误，直接结束本次的移动
    if (map_Board[pos1] in [ FloorCell, GoalCell]) then begin                   // pos1 是通道

       if map_Board[pos1] = FloorCell then map_Board[pos1] := ManCell
       else map_Board[pos1] := ManGoalCell;

    end else if (map_Board[pos1] in [ BoxCell, BoxGoalCell]) then begin         // pos1 是箱子

      if (pos2 < 0) or (pos2 >= MapSize) then begin                      // pos2 界外
         StatusBar1.Panels[7].Text := '遇到了错误的动作符号！- ' + ch_;
         Break;
      end;

      if (map_Board[pos2] in [ FloorCell, GoalCell]) then begin                 // pos2 是通道

         if map_Board[pos2] = FloorCell then map_Board[pos2] := BoxCell         // 箱子到位
         else map_Board[pos2] := BoxGoalCell;

         if map_Board[pos1] = BoxCell then map_Board[pos1] := ManCell           // 人到位
         else map_Board[pos1] := ManGoalCell;

         ch := Char(Ord(ch) - 32);                                              // 变成大写 -- 推动

         Inc(PushTimes);                                                        // 推动步数
      end else begin                                                            // 错误动作
         StatusBar1.Panels[7].Text := '遇到了错误的动作符号！- ' + ch_;
         Break;
      end;
    end else begin                                                              // 错误动作
       StatusBar1.Panels[7].Text := '遇到了错误的动作符号！- ' + ch_;
       Break;
    end;

    // 到了这里，动作正确，将人移走
    if map_Board[ManPos] = ManCell then map_Board[ManPos] := FloorCell          // 人移走
    else map_Board[ManPos] := GoalCell;

    Inc(MoveTimes);                                                             // 移动步数

    Dec(ReDoPos);
    Inc(UnDoPos);

    UndoList[UnDoPos] := ch;
    ManPos := pos1;                                                             // 人的新位置

    Dec(Steps);
  end;

  StatusBar1.Panels[1].Text := inttostr(MoveTimes);
  StatusBar1.Panels[3].Text := inttostr(PushTimes);
  DrawMap();                               // 更新地图显示
end;

// 撤销一步 -- 正推
procedure TTrialForm.UnDo(Steps: Integer);
var
  ch: Char;
  pos1, pos2: Integer;
begin
  StatusBar1.Panels[7].Text := '';

  IsBoxAccessibleTips := False;
  IsManAccessibleTips := False;

  while (Steps > 0) and (UnDoPos > 0) and (ReDoPos < MaxLenPath) do begin

    // 人的位置出现异常
    if (ManPos < 0) or (ManPos >= MapSize) or
       (not (map_Board[ManPos] in [ManCell, ManGoalCell])) then begin
       StatusBar1.Panels[7].Text := format('人的位置异常！- [%d, %d]', [ManPos mod mapCols + 1, ManPos div mapCols + 1]);
       Break;
    end;
    
    ch := UndoList[UnDoPos];

    pos1 := -1;
    pos2 := -1;
    case ch of
      'l', 'L':
        begin
          pos1 := ManPos - 1;
          pos2 := ManPos + 1;
        end;
      'r', 'R':
        begin
          pos1 := ManPos + 1;
          pos2 := ManPos - 1;
        end;
      'u', 'U':
        begin
          pos1 := ManPos - mapCols;
          pos2 := ManPos + mapCols;
        end;
      'd', 'D':
        begin
          pos1 := ManPos + mapCols;
          pos2 := ManPos - mapCols;
        end;
    end;

    // 检测是否包含箱子的退回
    if ch in ['L', 'R', 'U', 'D'] then
    begin

      if (pos1 < 0) or (pos1 >= MapSize) or                              // 界外，等
         (pos2 < 0) or (pos2 >= MapSize) or
         (not (map_Board[pos1] in [BoxCell, BoxGoalCell])) or
         (not (map_Board[pos2] in [FloorCell, GoalCell])) then begin
         StatusBar1.Panels[7].Text := '遇到了错误的动作符号！- ' + ch;
         Break;
      end;

      if (map_Board[pos1] = BoxCell) then
        map_Board[pos1] := FloorCell
      else
        map_Board[pos1] := GoalCell;

      if (map_Board[ManPos] = ManCell) then
        map_Board[ManPos] := BoxCell
      else
        map_Board[ManPos] := BoxGoalCell;

      // 人的回退
      if map_Board[pos2] = FloorCell then
        map_Board[pos2] := ManCell
      else
        map_Board[pos2] := ManGoalCell;

      Dec(PushTimes);                                                           // 推动步数
    end
    else
    begin
      if (pos2 < 0) or (pos2 >= MapSize) or                              // 界外，等
         (not (map_Board[pos2] in [FloorCell, GoalCell])) then begin
         StatusBar1.Panels[7].Text := '遇到了错误的动作符号！- ' + ch;
         Break;
      end;

      if (map_Board[ManPos] = ManCell) then
        map_Board[ManPos] := FloorCell
      else
        map_Board[ManPos] := GoalCell;

      // 人的回退
      if map_Board[pos2] = FloorCell then
        map_Board[pos2] := ManCell
      else
        map_Board[pos2] := ManGoalCell;
    end;

    Dec(MoveTimes);                                                             // 移动步数

    Dec(UnDoPos);
    inc(ReDoPos);
    RedoList[ReDoPos] := ch;
    ManPos := pos2;                                                             // 人的新位置

    Dec(Steps);

  end;

  StatusBar1.Panels[1].Text := inttostr(MoveTimes);
  StatusBar1.Panels[3].Text := inttostr(PushTimes);
  DrawMap();                               // 更新地图显示
end;

// 重做一步 -- 逆推
procedure TTrialForm.ReDo_BK(Steps: Integer);
var
  ch: Char;
  pos1, pos2: Integer;
  isOK: Boolean;
begin
  StatusBar1.Panels[7].Text := '';

  IsBoxAccessibleTips := False;
  IsManAccessibleTips := False;

  while (Steps > 0) and (ReDoPos > 0) and (UnDoPos < MaxLenPath) do begin

    // 人的位置出现异常
    if (ManPos < 0) or (ManPos >= MapSize) or
       (not (map_Board[ManPos] in [ManCell, ManGoalCell])) then begin
       StatusBar1.Panels[7].Text := format('人的位置异常！- [%d, %d]', [ManPos mod mapCols + 1, ManPos div mapCols + 1]);
       Break;
    end;

    ch := RedoList[ReDoPos];

    pos1 := -1;
    pos2 := -1;
    isOK := False;
    case ch of
      'l', 'L':
        begin
          isOK := (ManPos mod mapCols) > 0;
          pos1 := ManPos - 1;
          pos2 := ManPos + 1;
        end;
      'r', 'R':
        begin
          isOK := (ManPos mod mapCols) < mapCols - 1;
          pos1 := ManPos + 1;
          pos2 := ManPos - 1;
        end;
      'u', 'U':
        begin
          isOK := (ManPos div mapCols) > 0;
          pos1 := ManPos - mapCols;
          pos2 := ManPos + mapCols;
        end;
      'd', 'D':
        begin
          isOK := (ManPos div mapCols) < mapRows - 1;
          pos1 := ManPos + mapCols;
          pos2 := ManPos - mapCols;
        end;
    end;

    if isOK then
    begin
      if ch in [ 'L', 'R', 'U', 'D' ] then
      begin

        if (pos2 < 0) or (pos2 >= MapSize) or                              // 界外，等
           (pos1 < 0) or (pos1 >= MapSize) or
           (not (map_Board[pos2] in [BoxCell, BoxGoalCell])) or
           (not (map_Board[pos1] in [FloorCell, GoalCell]))then begin
           StatusBar1.Panels[7].Text := '遇到了错误的动作符号！- ' + ch;
           Break;
        end;

        if map_Board[pos2] = BoxCell then
          map_Board[pos2] := FloorCell
        else
          map_Board[pos2] := GoalCell;

        if (map_Board[pos1] = FloorCell) then                                // 下一格是地板
          map_Board[pos1] := ManCell
        else
          map_Board[pos1] := ManGoalCell;

        if map_Board[ManPos] = ManCell then
          map_Board[ManPos] := BoxCell
        else
          map_Board[ManPos] := BoxGoalCell;

        Inc(PushTimes);                                                      // 推动步数
      end
      else
      begin

        if (pos1 < 0) or (pos1 >= MapSize) or                            // 界外，等
           (not (map_Board[pos1] in [FloorCell, GoalCell]))then begin
           StatusBar1.Panels[7].Text := '遇到了错误的动作符号！- ' + ch;
           Break;
        end;

        // 人到位
        if (map_Board[pos1] = FloorCell) then                                // 下一格是地板
          map_Board[pos1] := ManCell
        else
          map_Board[pos1] := ManGoalCell;

        if map_Board[ManPos] = ManCell then
          map_Board[ManPos] := FloorCell
        else
          map_Board[ManPos] := GoalCell;
      end;

      Inc(MoveTimes);                                                        // 移动步数

      Dec(ReDoPos);
      Inc(UnDoPos);
      UndoList[UnDoPos] := ch;
      ManPos := pos1;                                                        // 人的新位置

      Dec(Steps);
    end;
  end;

  StatusBar1.Panels[1].Text := inttostr(MoveTimes);
  StatusBar1.Panels[3].Text := inttostr(PushTimes);
  DrawMap();                               // 更新地图显示
end;

// 撤销一步 -- 逆推
procedure TTrialForm.UnDo_BK(Steps: Integer);
var
  ch: Char;
  pos1, pos2: Integer;

begin
  StatusBar1.Panels[7].Text := '';

  IsBoxAccessibleTips := False;
  IsManAccessibleTips := False;

  while (Steps > 0) and (UnDoPos > 0) and (ReDoPos < MaxLenPath) do begin

    // 人的位置出现异常
    if (ManPos < 0) or (ManPos >= MapSize) or
       (not (map_Board[ManPos] in [ManCell, ManGoalCell])) then begin
       StatusBar1.Panels[7].Text := format('人的位置异常！- [%d, %d]', [ManPos mod mapCols + 1, ManPos div mapCols + 1]);
       Break;
    end;

    ch := UndoList[UnDoPos];

    pos1 := -1;
    pos2 := -1;
    case ch of
      'l', 'L':
        begin
          pos1 := ManPos + 1;
          pos2 := ManPos + 2;
        end;
      'r', 'R':
        begin
          pos1 := ManPos - 1;
          pos2 := ManPos - 2;
        end;
      'u', 'U':
        begin
          pos1 := ManPos + mapCols;
          pos2 := ManPos + mapCols * 2;
        end;
      'd', 'D':
        begin
          pos1 := ManPos - mapCols;
          pos2 := ManPos - mapCols * 2;
        end;
    end;

    // 检测是否包含箱子的动作
    if ch in [ 'L', 'R', 'U', 'D' ] then begin

      if (pos2 < 0) or (pos2 >= MapSize) or                              // 界外，等
         (pos1 < 0) or (pos1 >= MapSize) or
         (not (map_Board[pos1] in [BoxCell, BoxGoalCell])) or
         (not (map_Board[pos2] in [FloorCell, GoalCell]))then begin
         StatusBar1.Panels[7].Text := '遇到了错误的动作符号！- ' + ch;
         Break;
      end;

      if map_Board[pos1] = BoxCell then
        map_Board[pos1] := ManCell
      else
        map_Board[pos1] := ManGoalCell;

      if (map_Board[pos2] = FloorCell) then
        map_Board[pos2] := BoxCell
      else
        map_Board[pos2] := BoxGoalCell;

      Dec(PushTimes);                                                        // 推动步数
    end else begin
      if (pos1 < 0) or (pos1 >= MapSize) or                              // 界外，等
         (not (map_Board[pos1] in [FloorCell, GoalCell])) then begin
         StatusBar1.Panels[7].Text := '遇到了错误的动作符号！- ' + ch;
         Break;
      end;
      if (map_Board[pos1] = FloorCell) then
        map_Board[pos1] := ManCell
      else
        map_Board[pos1] := ManGoalCell;
    end;

    // 人的退回
    if (map_Board[ManPos] = ManCell) then
      map_Board[ManPos] := FloorCell
    else
      map_Board[ManPos] := GoalCell;

    Dec(MoveTimes);                                                          // 移动步数

    Dec(UnDoPos);
    Inc(ReDoPos);
    RedoList[ReDoPos] := ch;
    ManPos := pos1;                                                          // 人的新位置

    Dec(Steps);
  end;

  StatusBar1.Panels[1].Text := inttostr(MoveTimes);
  StatusBar1.Panels[3].Text := inttostr(PushTimes);
  DrawMap();                               // 更新地图显示

end;

procedure TTrialForm.FormCreate(Sender: TObject);
begin
  Caption := '正推演练场';
  bt_Exit.Caption := '返回';
  bt_GoThrough.Caption := '穿越';
  bt_OddEven.Caption := '奇偶';
  bt_Save.Caption := '导出（XSB + Lurd）';

  bt_Exit.Hint := '返回编辑【Ctrl + Q】';
  bt_GoThrough.Hint := '穿越开关【G】';
  bt_OddEven.Hint := '奇偶格位【E】';
  bt_Save.Hint := '导出演练场的 XSB + Lurd【Ctrl + C】';
  
  StatusBar1.Panels[0].Text := '移动';
  StatusBar1.Panels[2].Text := '推动';
  StatusBar1.Panels[4].Text := '箱子数';

  isBK        := False;
  isGoThrough := True;
  isOddEven   := False;
  curTrun     := 0;

  MaskPic := TBitmap.Create;      // 选择单元格掩图
  LoadDefaultSkin;

  myPathFinder := TPathFinder.Create;             // 探路者

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

  if (c > 0) and (map_Board[r * mapCols + c - 1] = WallCell) then
    result := result or MapDir[curTrun, 0];  // 左有墙壁
  if (r > 0) and (map_Board[(r - 1) * mapCols + c] = WallCell) then
    result := result or MapDir[curTrun, 1];  // 上有墙壁
  if (c < mapCols - 1) and (map_Board[r * mapCols + c + 1] = WallCell) then
    result := result or MapDir[curTrun, 2];  // 右有墙壁
  if (r < mapRows - 1) and (map_Board[(r + 1) * mapCols + c] = WallCell) then
    result := result or MapDir[curTrun, 3];  // 下有墙壁

  if ((result = MapDir[curTrun, 4]) or (result = MapDir[curTrun, 5]) or (result = MapDir[curTrun, 6]) or (result = 15)) and (c > 0) and (r > 0) and (map_Board[pos - mapCols - 1] = WallCell) then
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
  i, j, i2, j2, k, dx, dy, x1, y1, x2, y2, x3, y3, x4, y4, pos, t1, t2, man_Pos_: integer;
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
      // 0-7, 1-6, 2-5, 3-4, 互为转置
      case (curTrun) of  // 利用 i2, j2 模拟图元素的旋转，这样不管怎么“旋转”，实际上地图始终不变 -- 将地图坐标转换为视觉坐标
      1:
        begin
          j2 := mapRows - 1 - i;
          i2 := j;
        end;
      2:
        begin
          j2 := mapCols - 1 - j;
          i2 := mapRows - 1 - i;
        end;
      3:
        begin
          j2 := i;
          i2 := mapCols - 1 - j;
        end;
      4:
        begin
          j2 := mapCols - 1 - j;
          i2 := i;
        end;
      5:
        begin
          j2 := mapRows - 1 - i;
          i2 := mapCols - 1 - j;
        end;
      6:
        begin
          j2 := j;
          i2 := mapRows - 1 - i;
        end;
      7:
        begin
          j2 := i;
          i2 := j;
        end;
      else
        begin
          j2 := j;
          i2 := i;
        end;
      end;

      pos := i * mapCols + j;    // 地图中，“格子”的真实位置

      x1 := j2 * CellSize;        // x1, y1 是地图元素的绘制坐标 -- 旋转后的
      y1 := i2 * CellSize;

      R := Rect(x1, y1, x1 + CellSize, y1 + CellSize);        // 地图格子的绘制矩形

      map_Image.Canvas.CopyMode := SRCCOPY;
      case map_Board[pos] of
        WallCell:
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
        FloorCell:
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, FloorPic2)
            else map_Image.Canvas.StretchDraw(R, FloorPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isFloorLine);  // 画网格线
          end;
        GoalCell:
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, GoalPic2)
            else map_Image.Canvas.StretchDraw(R, GoalPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isGoalLine);   // 画网格线
          end;
        BoxCell:
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, BoxPic2)
            else map_Image.Canvas.StretchDraw(R, BoxPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isBoxLine);    // 画网格线
          end;
        BoxGoalCell:
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, BoxGoalPic2)
            else map_Image.Canvas.StretchDraw(R, BoxGoalPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isBoxGoalLine); // 画网格线
          end;
        ManCell:
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, ManPic2)
            else map_Image.Canvas.StretchDraw(R, ManPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isManLine);    // 画网格线
          end;
        ManGoalCell:
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, ManGoalPic2)
            else map_Image.Canvas.StretchDraw(R, ManGoalPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isManGoalLine); // 画网格线
          end;
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
end;

procedure TTrialForm.FormShow(Sender: TObject);
var
  i: Integer;
begin
  myPathFinder.isEditor := True;        // 编辑器调用时，不会自动保存动作日志
  myPathFinder.setThroughable(isGoThrough);

  UnDoPos := 0;
  ReDoPos := 0;
  MoveTimes := 0;
  PushTimes := 0;
  MapSize := mapRows * mapCols;

  manPos := -1;
  for i := 0 to MapSize-1 do begin
      if map_Board[i] in [ ManCell, ManGoalCell ] then begin
         manPos := i;
         Break;
      end;
  end;

  SetButton;
  DrawMap;
end;

// 计算地图新的图片显示的尺寸
procedure TTrialForm.NewMapSize();
var
  w, h: integer;
begin
  
  // 计算地图单元格的大小
  if (mapCols > 2) and (mapRows > 2) then
  begin
    if curTrun mod 2 = 0 then
    begin
      w := pl_Ground.Width div mapCols;
      h := pl_Ground.Height div mapRows;
    end
    else
    begin
      h := pl_Ground.Width div mapRows;
      w := pl_Ground.Height div mapCols;
    end;

    if w < h then
      CellSize := w
    else
      CellSize := h;
  end;
  if CellSize > SkinSize then
    CellSize := SkinSize;
  if CellSize < 10 then
    CellSize := 10;

  // 选择单元格掩图
  MaskPic.Width  := CellSize;
  MaskPic.Height := MaskPic.Width;

  // 确定地图的尺寸
  map_Image.Picture := nil;       // 这是必须的，否则，地图不能改变尺寸
  if curTrun mod 2 = 0 then
  begin
    map_Image.Width := mapCols * CellSize;
    map_Image.Height := mapRows * CellSize;
  end
  else
  begin
    map_Image.Height := mapCols * CellSize;
    map_Image.Width := mapRows * CellSize;
  end;
  map_Image.Left := (pl_Ground.Width - map_Image.Width) div 2;
  map_Image.Top := (pl_Ground.Height - map_Image.Height) div 2;
end;

// 窗口 Resize
procedure TTrialForm.FormResize(Sender: TObject);
begin
  NewMapSize;
  DrawMap;
end;

// 设置按钮状态
procedure TTrialForm.SetButton();
begin
  if isGoThrough then
  begin
    bt_GoThrough.Font.Color := clBlack;
    bt_GoThrough.Font.Style := bt_GoThrough.Font.Style + [fsBold];
    bt_GoThrough.Down := True;
  end
  else
  begin
    bt_GoThrough.Font.Color := clGray;
    bt_GoThrough.Font.Style := bt_GoThrough.Font.Style - [fsBold];
    bt_GoThrough.Down := False;
  end;
end;

procedure TTrialForm.FormDestroy(Sender: TObject);
begin
  if myPathFinder <> nil then FreeAndNil(myPathFinder);
  if MaskPic <> nil then FreeAndNil(MaskPic);
end;

// 是否允许穿越
procedure TTrialForm.bt_GoThroughClick(Sender: TObject);
begin
  isGoThrough := not isGoThrough;
  myPathFinder.setThroughable(isGoThrough);
  SetButton;
end;

// 默认皮肤
procedure TTrialForm.LoadDefaultSkin();
begin
  SkinSize   := 60;
  isSeamless := False;
  LineColor  := clInactiveCaptionText;  // 格线颜色
  isFloorLine   := true;            // 地板是否画线
  isGoalLine    := true;            // 目标点是否画线
  isManLine     := true;            // 人是否画线
  isManGoalLine := true;            // 人在目标点是否画线
  isBoxLine     := true;            // 箱子是否画线
  isBoxGoalLine := true;            // 箱子在目标点是否画线

  // 地板
  FloorPic.Width   := SkinSize;
  FloorPic.Height  := SkinSize;
  FloorPic.Canvas.CopyRect(Rect(0, 0, FloorPic.Width, FloorPic.Height), RecogForm_.Image4.Canvas, Rect(0, 0, 60, 60));

  // 目标点
  GoalPic.Width   := SkinSize;
  GoalPic.Height  := SkinSize;
  GoalPic.Canvas.CopyRect(Rect(0, 0, GoalPic.Width, GoalPic.Height), RecogForm_.Image4.Canvas, Rect(60, 0, 120, 60));

  // 玩家
  ManPic.Width   := SkinSize;
  ManPic.Height  := SkinSize;
  ManPic.Canvas.CopyRect(Rect(0, 0, ManPic.Width, ManPic.Height), RecogForm_.Image4.Canvas, Rect(240, 0, 300, 60));

  // 玩家、目标点
  ManGoalPic.Width   := SkinSize;
  ManGoalPic.Height  := SkinSize;
  ManGoalPic.Canvas.CopyRect(Rect(0, 0, ManGoalPic.Width, ManGoalPic.Height), RecogForm_.Image4.Canvas, Rect(300, 0, 360, 60));

  // 箱子
  BoxPic.Width   := SkinSize;
  BoxPic.Height  := SkinSize;
  BoxPic.Canvas.CopyRect(Rect(0, 0, BoxPic.Width, BoxPic.Height), RecogForm_.Image4.Canvas, Rect(120, 0, 180, 60));

  // 箱子、目标点
  BoxGoalPic.Width   := SkinSize;
  BoxGoalPic.Height  := SkinSize;
  BoxGoalPic.Canvas.CopyRect(Rect(0, 0, BoxGoalPic.Width, BoxGoalPic.Height), RecogForm_.Image4.Canvas, Rect(180, 0, 240, 60));

  // 墙壁
  WallPic.Width   := SkinSize;
  WallPic.Height  := SkinSize;
  WallPic.Canvas.CopyRect(Rect(0, 0, WallPic.Width, WallPic.Height), RecogForm_.Image4.Canvas, Rect(360, 0, 420, 60));

  // 高亮图元
  FloorPic2.Width := SkinSize;
  FloorPic2.Height := SkinSize;
  GoalPic2.Width := SkinSize;
  GoalPic2.Height := SkinSize;
  ManPic2.Width := SkinSize;
  ManPic2.Height := SkinSize;
  ManGoalPic2.Width := SkinSize;
  ManGoalPic2.Height := SkinSize;
  BoxPic2.Width := SkinSize;
  BoxPic2.Height := SkinSize;
  BoxGoalPic2.Width := SkinSize;
  BoxGoalPic2.Height := SkinSize;
  LoadSkinForm.BrightnessChange(FloorPic, FloorPic2, -10);
  LoadSkinForm.BrightnessChange(GoalPic, GoalPic2, -10);
  LoadSkinForm.BrightnessChange(ManPic, ManPic2, -10);
  LoadSkinForm.BrightnessChange(ManGoalPic, ManGoalPic2, -10);
  LoadSkinForm.BrightnessChange(BoxPic, BoxPic2, -10);
  LoadSkinForm.BrightnessChange(BoxGoalPic, BoxGoalPic2, -10);

  isSeamless := False;
end;

procedure TTrialForm.map_ImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  MapClickPos: TPoint;
  pos, x2, y2, k: Integer;
begin
  if CellSize = 0 then Exit;

  x2 := X div CellSize;
  y2 := Y div CellSize;

  case curTrun of // 把点击的位置，转换地图的真实坐标 -- 将视觉坐标转换为地图坐标
    1:
      begin
        MapClickPos.X := y2;
        MapClickPos.Y := mapRows - 1 - x2;
      end;
    2:
      begin
        MapClickPos.X := mapCols - 1 - x2;
        MapClickPos.Y := mapRows - 1 - y2;
      end;
    3:
      begin
        MapClickPos.X := mapCols - 1 - y2;
        MapClickPos.Y := x2;
      end;
    4:
      begin
        MapClickPos.X := mapCols - 1 - x2;
        MapClickPos.Y := y2;
      end;
    5:
      begin
        MapClickPos.X := mapCols - 1 - y2;
        MapClickPos.Y := mapRows - 1 - x2;
      end;
    6:
      begin
        MapClickPos.X := x2;
        MapClickPos.Y := mapRows - 1 - y2;
      end;
    7:
      begin
        MapClickPos.X := y2;
        MapClickPos.Y := x2;
      end;
  else
      begin
        MapClickPos.X := x2;
        MapClickPos.Y := y2;
      end;
  end;

  // 被点击的图元位置
  pos := MapClickPos.y * mapCols + MapClickPos.x;

  case Button of
    mbleft:             // 单击 -- 指左键
      case map_Board[pos] of
        FloorCell, GoalCell:
          begin            // 单击地板
              if IsBoxAccessibleTips then begin                          // 有箱子可达提示时
                // 视点击位置是否可达而定
                if(isBK and (not myPathFinder.isBoxReachable_BK(pos))) or ((not isBK) and (not myPathFinder.isBoxReachable(pos))) then
                   IsBoxAccessibleTips := False
                else begin
                  IsBoxAccessibleTips := False;

                  ReDoPos := myPathFinder.boxTo(isBK, OldBoxPos, pos, ManPos);
                  if ReDoPos > 0 then begin
                    for k := 1 to ReDoPos do
                      RedoList[k] := BoxPath[ReDoPos - k + 1];
                    LastSteps := UnDoPos;              // 点推前的步数
                    if isBK then ReDo_BK(ReDoPos)
                    else ReDo(ReDoPos);
                  end;
                end;
              end else begin
                if isBK and (ManPos < 0) then Exit;

                IsManAccessibleTips := False;
                IsBoxAccessibleTips := False;
                ReDoPos := myPathFinder.manTo(isBK, map_Board, ManPos, pos);               // 计算人可达
                if ReDoPos > 0 then begin
                  LastSteps := UnDoPos;              // 点推前的步数
                  for k := 1 to ReDoPos do
                    RedoList[k] := ManPath[k];
                    if isBK then ReDo_BK(ReDoPos)
                    else ReDo(ReDoPos);
                end;
              end;
          end;
        ManCell, ManGoalCell:
          begin           // 单击人
              if IsBoxAccessibleTips and ((isBK and myPathFinder.isBoxReachable_BK(ManPos)) or ((not isBK) and myPathFinder.isBoxReachable(ManPos))) then begin   // 有箱子可达提示时
                IsBoxAccessibleTips := False;

                ReDoPos := myPathFinder.boxTo(isBK, OldBoxPos, pos, ManPos);
                if ReDoPos > 0 then begin
                  for k := 1 to ReDoPos do
                    RedoList[k] := BoxPath[ReDoPos - k + 1];
                  LastSteps := UnDoPos;              // 点推前的步数
                  if isBK then ReDo_BK(ReDoPos)
                  else ReDo(ReDoPos);
                end;
              end else if IsManAccessibleTips then
                IsManAccessibleTips := False        // 在显示人的可达提示时，又点击了人
              else begin
                myPathFinder.manReachable(isBK, map_Board, ManPos);                       // 计算人可达
                IsManAccessibleTips := True;
                IsBoxAccessibleTips := False;
              end;
          end;
        BoxCell, BoxGoalCell:
          begin           // 单击箱子
              if IsBoxAccessibleTips and (OldBoxPos = pos) then
                IsBoxAccessibleTips := False
              else
              begin
                if isBK and (ManPos < 0) then Exit;
                
                IsBoxAccessibleTips := True;
                IsManAccessibleTips := False;
                myPathFinder.FindBlock(map_Board, pos);                              // 根据被点击的箱子，计算割点
                myPathFinder.boxReachable(isBK, pos, ManPos);                        // 计算箱子可达
                OldBoxPos := pos;
              end;
          end;
      else
          begin                            // 取消可达提示
              IsManAccessibleTips := False;
              IsBoxAccessibleTips := False;
          end;
      end;
    mbright:
      begin    // 右击 -- 指右键

      end;
  end;

  DrawMap();
end;

// 对于键盘的上下左右按键，根据关卡的当前旋转状态转换动作字符
function getTrun_Act(n: Integer; act: Char): Char;
begin
  Result := ' ';
  case act of
     'l': Result := ActDir[n, 0];
     'u': Result := ActDir[n, 1];
     'r': Result := ActDir[n, 2];
     'd': Result := ActDir[n, 3];
     'L': Result := ActDir[n, 4];
     'U': Result := ActDir[n, 5];
     'R': Result := ActDir[n, 6];
     'D': Result := ActDir[n, 7];
  end;
end;

procedure TTrialForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_LEFT:
      begin
          ReDoPos := 1;
          if ssCtrl in Shift then
            RedoList[ReDoPos] := getTrun_Act(curTrun, 'L')
          else
            RedoList[ReDoPos] := getTrun_Act(curTrun, 'l');
          if isBK then ReDo_BK(ReDoPos)
          else ReDo(ReDoPos);
      end;
    VK_RIGHT:
      begin
          ReDoPos := 1;
          if ssCtrl in Shift then
            RedoList[ReDoPos] := getTrun_Act(curTrun, 'R')
          else
            RedoList[ReDoPos] := getTrun_Act(curTrun, 'r');
          if isBK then ReDo_BK(ReDoPos)
          else ReDo(ReDoPos);
      end;
    VK_UP:
      begin
          ReDoPos := 1;
          if ssCtrl in Shift then
            RedoList[ReDoPos] := getTrun_Act(curTrun, 'U')
          else
            RedoList[ReDoPos] := getTrun_Act(curTrun, 'u');
          if isBK then ReDo_BK(ReDoPos)
          else ReDo(ReDoPos);
      end;
    VK_DOWN:
      begin
          ReDoPos := 1;
          if ssCtrl in Shift then
            RedoList[ReDoPos] := getTrun_Act(curTrun, 'D')
          else
            RedoList[ReDoPos] := getTrun_Act(curTrun, 'd');
          if isBK then ReDo_BK(ReDoPos)
          else ReDo(ReDoPos);
      end;
    69:                            // E， 奇偶格效果
      if not isOddEven then
         bt_OddEvenMouseDown(Self, mbLeft, [], -1, -1);
  end;
end;

procedure TTrialForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    69:
      bt_OddEvenMouseUp(Self, mbLeft, [], -1, -1);       // E， 奇偶格效果
    VK_HOME:    // Home，至首
      begin
        if isBK then UnDo_BK(UnDoPos)
        else UnDo(UnDoPos);
        StatusBar1.Panels[7].Text := '已至首！';
      end;
    VK_END:    // End，至尾
      begin
        if isBK then ReDo_BK(ReDoPos)
        else ReDo(ReDoPos);
        StatusBar1.Panels[7].Text := '已至尾！';
      end;
    90:                    // z，撤销
      begin
        bt_UnDo.Click;
      end;
    88:                    // x，重做
      begin
        bt_ReDo.Click;
      end;
    83:                    // S，重做一步
      begin
        if isBK then ReDo_BK(1)
        else ReDo(1);
      end;
    65:                     // a，撤销一步
      begin
        if isBK then UnDo_BK(1)
        else UnDo(1);
      end;
    81:                // Ctrl + Q， 退出
      if ssCtrl in Shift then begin
         Close();
      end;
    71:                // G， 穿越
      bt_GoThrough.Click;
    76:                // Ctrl + L， 从剪切板加载 Lurd
      if ssCtrl in Shift then begin
         if LoadLurdFromClipboard(isBK) then begin
            if isBK then ReDo_BK(ReDoPos)
            else ReDo(ReDoPos);
         end;
      end;
    77:                // Ctrl + M， Lurd 送入剪切板
      if ssCtrl in Shift then begin
         if LurdToClipboard(ManPos mod mapCols, ManPos div mapCols) then
            StatusBar1.Panels[7].Text := '动作 Lurd 送入剪切板！';
      end;
    67:                 // Ctrl + C， XSB 送入剪切板
      if ssCtrl in Shift then begin
        bt_Save.Click;
      end;
    106, 56:                    // 第 0 转
      begin
        curTrun := 0;
        SetMapTrun;
      end;
    111, 191:                   // 旋转关卡
      begin
        if curTrun < 7 then
          inc(curTrun)
        else
          curTrun := 0; 
        SetMapTrun;
      end;
    27:                         // ESC，重开始
      begin
        if isBK then UnDo_BK(UnDoPos)
        else UnDo(UnDoPos);
        StatusBar1.Panels[7].Text := '已至首！';
      end;
  end;
end;

// 显示奇偶特效
procedure TTrialForm.bt_OddEvenMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  isOddEven := true;
  DrawMap();
end;

// 关闭奇偶特效
procedure TTrialForm.bt_OddEvenMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  isOddEven := false;
  DrawMap();
end;

procedure TTrialForm.bt_UnDoClick(Sender: TObject);
begin
  if isBK then
  begin
    UnDo_BK(GetStep(UnDoPos));
  end
  else
  begin
    if (LastSteps < 0) or (LastSteps > UnDoPos) then
      UnDo(GetStep2(UnDoPos))
    else
      UnDo(UnDoPos - LastSteps);
    LastSteps := -1;              // 正推最后一次点推前的步数
  end;
end;

procedure TTrialForm.bt_ReDoClick(Sender: TObject);
begin
  if isBK then
    ReDo_BK(GetStep2(ReDoPos))
  else
    ReDo(GetStep(ReDoPos));
end;

procedure TTrialForm.SetMapTrun();
begin
  pnl_Trun.Caption := MapTrun[curTrun];
  NewMapSize();
  DrawMap();       // 画地图
  case curTrun of
  0: StatusBar1.Panels[7].Text := '0转 = 关卡的原始旋转状态。';
  1: StatusBar1.Panels[7].Text := '1转 = 关卡的顺时针旋转90度';
  2: StatusBar1.Panels[7].Text := '2转 = 关卡的顺时针旋转180度';
  3: StatusBar1.Panels[7].Text := '3转 = 关卡的顺时针旋转270度（逆时针旋转90度）';
  4: StatusBar1.Panels[7].Text := '4转 = 关卡的左右翻转';
  5: StatusBar1.Panels[7].Text := '5转 = 关卡的上下翻转后，逆时针旋转90度（关卡的左右翻转后，顺时针旋转90度）';
  6: StatusBar1.Panels[7].Text := '6转 = 关卡的上下翻转（关卡的左右翻转后，顺时针旋转180度）';
  7: StatusBar1.Panels[7].Text := '7转 = 关卡的转置，即行列互换（关卡的左右翻转后，顺时针旋转270度，或逆时针旋转90度）';
  end;
end;

procedure TTrialForm.pnl_TrunMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    case Button of
      mbleft:
        begin     // 单击 -- 指左键
          if curTrun < 7 then
            inc(curTrun)
          else
            curTrun := 0;    // 第 0 转
        end;
      mbright:
        begin    // 右击 -- 指右键
          if curTrun > 0 then
            dec(curTrun)
          else
            curTrun := 7;    // 第 0 转
        end;
    end;
    SetMapTrun();
end;

procedure TTrialForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  IsBoxAccessibleTips := False;
  IsManAccessibleTips := False;
end;

// 解析正推 reDo 动作节点 -- 每推一个箱子为一个动作
function TTrialForm.GetStep(len: Integer): Integer;
var
  i, j, k, n: Integer;
  mAct: Char;
  boxRC: array[0..1] of Integer;
  flg: Boolean;
begin
  i := 0;
  j := 0;

  boxRC[0] := 1000;
  boxRC[1] := 1000;

    // 寻找动作节点
  n := 0;  // 应该停在第几个动作上
  flg := false;

  k := len;
  while k > 0 do
  begin

    if isBK then
      mAct := UndoList[k]
    else
      mAct := RedoList[k];

    Dec(k);

    case (mAct) of
      'l':
        Dec(j);      // 左移
      'u':
        Dec(i);      // 上移
      'r':
        Inc(j);      // 右移
      'd':
        Inc(i);      // 下移
      'L':
        begin        // 左推
          Dec(j);

          if (boxRC[0] <> i) or (boxRC[1] <> j) then
          begin
            if flg then
              break;   // 第二个箱子
            flg := true;         // 第一个箱子
          end;
          n := k;                  // 第一个箱子的最后位置

          boxRC[0] := i;
          boxRC[1] := j - 1;
        end;
      'U':
        begin        // 上推
          Dec(i);

          if (boxRC[0] <> i) or (boxRC[1] <> j) then
          begin
            if flg then
              break;   // 第二个箱子
            flg := true;         // 第一个箱子
          end;
          n := k;                  // 第一个箱子的最后位置

          boxRC[0] := i - 1;
          boxRC[1] := j;
        end;
      'R':
        begin        // 右推
          Inc(j);

          if (boxRC[0] <> i) or (boxRC[1] <> j) then
          begin
            if flg then
              break;   // 第二个箱子
            flg := true;         // 第一个箱子
          end;
          n := k;                  // 第一个箱子的最后位置

          boxRC[0] := i;
          boxRC[1] := j + 1;
        end;
      'D':
        begin        // 下推
          Inc(i);

          if (boxRC[0] <> i) or (boxRC[1] <> j) then
          begin
            if flg then
              break;   // 第二个箱子
            flg := true;         // 第一个箱子
          end;
          n := k;                  // 第一个箱子的最后位置

          boxRC[0] := i + 1;
          boxRC[1] := j;
        end;
    end;
  end;
  if flg then
    result := len - n  // 最后一个动作不是推，但前面有推的动作时
  else
    result := len;  // 剩余的全部动作
end;

// 解析正推 unDo 动作节点 -- 每推一个箱子为一个动作
function TTrialForm.GetStep2(len: Integer): Integer;
var
  i, j, k, n: Integer;
  mAct: Char;
  boxRC: array[0..1] of Integer;
  flg: Boolean;
begin
  i := 0;
  j := 0;

  boxRC[0] := 1000;
  boxRC[1] := 1000;

    // 寻找动作节点
  n := 0;  // 应该停在第几个动作上
  flg := false;

  k := len;
  while k > 0 do
  begin

    if isBK then
      mAct := RedoList[k]
    else
      mAct := UndoList[k];

    Dec(k);

    case (mAct) of
      'l':
        Dec(j);      // 左移
      'u':
        Dec(i);      // 上移
      'r':
        Inc(j);      // 右移
      'd':
        Inc(i);      // 下移
      'L':
        begin        // 左推
          if (boxRC[0] <> i) or (boxRC[1] <> j + 1) then
          begin
            if flg then
              break;   // 第二个箱子
            flg := true;         // 第一个箱子
          end;
          n := k;                  // 第一个箱子的最后位置
          boxRC[0] := i;
          boxRC[1] := j;
          Dec(j);
        end;
      'U':
        begin        // 上推
          if (boxRC[0] <> i + 1) or (boxRC[1] <> j) then
          begin
            if flg then
              break;   // 第二个箱子
            flg := true;         // 第一个箱子
          end;
          n := k;                  // 第一个箱子的最后位置
          boxRC[0] := i;
          boxRC[1] := j;
          Dec(i);
        end;
      'R':
        begin        // 右推
          if (boxRC[0] <> i) or (boxRC[1] <> j - 1) then
          begin
            if flg then
              break;   // 第二个箱子
            flg := true;         // 第一个箱子
          end;
          n := k;                  // 第一个箱子的最后位置
          boxRC[0] := i;
          boxRC[1] := j;
          Inc(j);
        end;
      'D':
        begin        // 下推
          if (boxRC[0] <> i - 1) or (boxRC[1] <> j) then
          begin
            if flg then
              break;   // 第二个箱子
            flg := true;         // 第一个箱子
          end;
          n := k;                  // 第一个箱子的最后位置
          boxRC[0] := i;
          boxRC[1] := j;
          Inc(i);
        end;
    end;
  end;
  if flg then
    result := len - n  // 最后一个动作不是推，但前面有推的动作时
  else
    result := len;
end;

procedure Delay(msecs: dword);
var
  FirstTickCount: dword;
begin
  FirstTickCount := GetTickCount;
  while GetTickCount-FirstTickCount < msecs do Application.ProcessMessages;
end;

procedure TTrialForm.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  bt_ReDo.Click;          // x，重做
  Handled := True;
  Delay(10);
end;

procedure TTrialForm.FormMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  bt_UnDo.Click;          // z，撤销
  Handled := True;
  Delay(10);
end;

procedure TTrialForm.bt_SaveClick(Sender: TObject);
var
  str: string;
  r, c: Integer;
begin
  StatusBar1.Panels[7].Text := '';

  // 关卡 XSB
  str := EditorForm_.GetXSB;

  if isBK then begin    // 逆推演练时，记录人的初始位置
    c := manPos mod mapCols + 1;
    r := manPos div mapCols + 1;

    str := #10 + '; SXB 为关卡逆推初态' + #10 + str + '[' + IntToStr(c) + ', ' + IntToStr(r) + ']';
  end;
  
  if UnDoPos > 0 then begin
     if UnDoPos < MaxLenPath then UndoList[UnDoPos+1] := #0;
     str := str + PChar(@UndoList) + #10;
  end;
  
  // 送入剪切板
  Clipboard.SetTextBuf(PChar(str));

  StatusBar1.Panels[7].Text := 'XSB + Lurd 已送入剪切板！';
end;

end.
