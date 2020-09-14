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
    
    map_Board: array[0..9999] of Integer;             // ��������ͼ

    isBK: boolean;             // �Ƿ�����ģʽ
    isGoThrough: boolean;      // ��Խ�Ƿ���
    isOddEven: Boolean;        // �Ƿ���ʾ��ż��Ч
    curTrun: Integer;          // �ؿ���ת���

    OldBoxPos: Integer;        // �����������
    LastSteps: Integer;        // �ϴε���ǰ�Ĳ���

    mapRows, mapCols, manPos, MapSize, MoveTimes, PushTimes: Integer;

  end;

const
  minWindowsWidth = 600;                            // ���򴰿���С�ߴ�����
  minWindowsHeight = 400;
  
  MapTrun: array[0..7] of string = ('0ת', '1ת', '2ת', '3ת', '4ת', '5ת', '6ת', '7ת');

var
  TrialForm: TTrialForm;

  IsManAccessibleTips, IsBoxAccessibleTips: Boolean;
  CellSize: Integer;

  // ��ͼ��ת��������
  MapDir: array[0..7, 0..6] of Integer = (
    (1, 2, 4, 8, 3, 7, 11),    // 0 ת
    (2, 4, 8, 1, 6, 7, 14),    // 1
    (4, 8, 1, 2, 12, 13, 14),  // 2
    (8, 1, 2, 4, 9, 13, 11),   // 3
    (4, 2, 1, 8, 6, 7, 14),    // 4
    (8, 4, 2, 1, 12, 13, 14),  // 5
    (1, 8, 4, 2, 9, 13, 11),   // 6
    (2, 1, 8, 4, 3, 7, 11));   // 7

    ActDir: array[0..7, 0..7] of Char = (                   // ���� 8 ��λ��ת֮ n ת�Ļ�������
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

// ����һ�� -- ����
procedure TTrialForm.ReDo(Steps: Integer);
var
  ch, ch_: Char;
  pos1, pos2: Integer;

begin
  StatusBar1.Panels[7].Text := '';

  IsBoxAccessibleTips := False;
  IsManAccessibleTips := False;

  while (Steps > 0) and (ReDoPos > 0) and (UnDoPos < MaxLenPath) do begin

    // �˵�λ�ó����쳣
    if (ManPos < 0) or (ManPos >= MapSize) or
       (not (map_Board[ManPos] in [ManCell, ManGoalCell])) then begin
       StatusBar1.Panels[7].Text := format('�˵�λ���쳣��- [%d, %d]', [ManPos mod mapCols + 1, ManPos div mapCols + 1]);
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

    if (pos1 < 0) or (pos1 >= MapSize) then begin                        // pos1 ����
       StatusBar1.Panels[7].Text := '�����˴���Ķ������ţ�- ' + ch_;
       Break;
    end;

    // �����ذ壬�����ƶ��˼��ɣ����������ӣ���Ҫͬʱ�ƶ����Ӻ��ˣ����������˴���ֱ�ӽ������ε��ƶ�
    if (map_Board[pos1] in [ FloorCell, GoalCell]) then begin                   // pos1 ��ͨ��

       if map_Board[pos1] = FloorCell then map_Board[pos1] := ManCell
       else map_Board[pos1] := ManGoalCell;

    end else if (map_Board[pos1] in [ BoxCell, BoxGoalCell]) then begin         // pos1 ������

      if (pos2 < 0) or (pos2 >= MapSize) then begin                      // pos2 ����
         StatusBar1.Panels[7].Text := '�����˴���Ķ������ţ�- ' + ch_;
         Break;
      end;

      if (map_Board[pos2] in [ FloorCell, GoalCell]) then begin                 // pos2 ��ͨ��

         if map_Board[pos2] = FloorCell then map_Board[pos2] := BoxCell         // ���ӵ�λ
         else map_Board[pos2] := BoxGoalCell;

         if map_Board[pos1] = BoxCell then map_Board[pos1] := ManCell           // �˵�λ
         else map_Board[pos1] := ManGoalCell;

         ch := Char(Ord(ch) - 32);                                              // ��ɴ�д -- �ƶ�

         Inc(PushTimes);                                                        // �ƶ�����
      end else begin                                                            // ������
         StatusBar1.Panels[7].Text := '�����˴���Ķ������ţ�- ' + ch_;
         Break;
      end;
    end else begin                                                              // ������
       StatusBar1.Panels[7].Text := '�����˴���Ķ������ţ�- ' + ch_;
       Break;
    end;

    // �������������ȷ����������
    if map_Board[ManPos] = ManCell then map_Board[ManPos] := FloorCell          // ������
    else map_Board[ManPos] := GoalCell;

    Inc(MoveTimes);                                                             // �ƶ�����

    Dec(ReDoPos);
    Inc(UnDoPos);

    UndoList[UnDoPos] := ch;
    ManPos := pos1;                                                             // �˵���λ��

    Dec(Steps);
  end;

  StatusBar1.Panels[1].Text := inttostr(MoveTimes);
  StatusBar1.Panels[3].Text := inttostr(PushTimes);
  DrawMap();                               // ���µ�ͼ��ʾ
end;

// ����һ�� -- ����
procedure TTrialForm.UnDo(Steps: Integer);
var
  ch: Char;
  pos1, pos2: Integer;
begin
  StatusBar1.Panels[7].Text := '';

  IsBoxAccessibleTips := False;
  IsManAccessibleTips := False;

  while (Steps > 0) and (UnDoPos > 0) and (ReDoPos < MaxLenPath) do begin

    // �˵�λ�ó����쳣
    if (ManPos < 0) or (ManPos >= MapSize) or
       (not (map_Board[ManPos] in [ManCell, ManGoalCell])) then begin
       StatusBar1.Panels[7].Text := format('�˵�λ���쳣��- [%d, %d]', [ManPos mod mapCols + 1, ManPos div mapCols + 1]);
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

    // ����Ƿ�������ӵ��˻�
    if ch in ['L', 'R', 'U', 'D'] then
    begin

      if (pos1 < 0) or (pos1 >= MapSize) or                              // ���⣬��
         (pos2 < 0) or (pos2 >= MapSize) or
         (not (map_Board[pos1] in [BoxCell, BoxGoalCell])) or
         (not (map_Board[pos2] in [FloorCell, GoalCell])) then begin
         StatusBar1.Panels[7].Text := '�����˴���Ķ������ţ�- ' + ch;
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

      // �˵Ļ���
      if map_Board[pos2] = FloorCell then
        map_Board[pos2] := ManCell
      else
        map_Board[pos2] := ManGoalCell;

      Dec(PushTimes);                                                           // �ƶ�����
    end
    else
    begin
      if (pos2 < 0) or (pos2 >= MapSize) or                              // ���⣬��
         (not (map_Board[pos2] in [FloorCell, GoalCell])) then begin
         StatusBar1.Panels[7].Text := '�����˴���Ķ������ţ�- ' + ch;
         Break;
      end;

      if (map_Board[ManPos] = ManCell) then
        map_Board[ManPos] := FloorCell
      else
        map_Board[ManPos] := GoalCell;

      // �˵Ļ���
      if map_Board[pos2] = FloorCell then
        map_Board[pos2] := ManCell
      else
        map_Board[pos2] := ManGoalCell;
    end;

    Dec(MoveTimes);                                                             // �ƶ�����

    Dec(UnDoPos);
    inc(ReDoPos);
    RedoList[ReDoPos] := ch;
    ManPos := pos2;                                                             // �˵���λ��

    Dec(Steps);

  end;

  StatusBar1.Panels[1].Text := inttostr(MoveTimes);
  StatusBar1.Panels[3].Text := inttostr(PushTimes);
  DrawMap();                               // ���µ�ͼ��ʾ
end;

// ����һ�� -- ����
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

    // �˵�λ�ó����쳣
    if (ManPos < 0) or (ManPos >= MapSize) or
       (not (map_Board[ManPos] in [ManCell, ManGoalCell])) then begin
       StatusBar1.Panels[7].Text := format('�˵�λ���쳣��- [%d, %d]', [ManPos mod mapCols + 1, ManPos div mapCols + 1]);
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

        if (pos2 < 0) or (pos2 >= MapSize) or                              // ���⣬��
           (pos1 < 0) or (pos1 >= MapSize) or
           (not (map_Board[pos2] in [BoxCell, BoxGoalCell])) or
           (not (map_Board[pos1] in [FloorCell, GoalCell]))then begin
           StatusBar1.Panels[7].Text := '�����˴���Ķ������ţ�- ' + ch;
           Break;
        end;

        if map_Board[pos2] = BoxCell then
          map_Board[pos2] := FloorCell
        else
          map_Board[pos2] := GoalCell;

        if (map_Board[pos1] = FloorCell) then                                // ��һ���ǵذ�
          map_Board[pos1] := ManCell
        else
          map_Board[pos1] := ManGoalCell;

        if map_Board[ManPos] = ManCell then
          map_Board[ManPos] := BoxCell
        else
          map_Board[ManPos] := BoxGoalCell;

        Inc(PushTimes);                                                      // �ƶ�����
      end
      else
      begin

        if (pos1 < 0) or (pos1 >= MapSize) or                            // ���⣬��
           (not (map_Board[pos1] in [FloorCell, GoalCell]))then begin
           StatusBar1.Panels[7].Text := '�����˴���Ķ������ţ�- ' + ch;
           Break;
        end;

        // �˵�λ
        if (map_Board[pos1] = FloorCell) then                                // ��һ���ǵذ�
          map_Board[pos1] := ManCell
        else
          map_Board[pos1] := ManGoalCell;

        if map_Board[ManPos] = ManCell then
          map_Board[ManPos] := FloorCell
        else
          map_Board[ManPos] := GoalCell;
      end;

      Inc(MoveTimes);                                                        // �ƶ�����

      Dec(ReDoPos);
      Inc(UnDoPos);
      UndoList[UnDoPos] := ch;
      ManPos := pos1;                                                        // �˵���λ��

      Dec(Steps);
    end;
  end;

  StatusBar1.Panels[1].Text := inttostr(MoveTimes);
  StatusBar1.Panels[3].Text := inttostr(PushTimes);
  DrawMap();                               // ���µ�ͼ��ʾ
end;

// ����һ�� -- ����
procedure TTrialForm.UnDo_BK(Steps: Integer);
var
  ch: Char;
  pos1, pos2: Integer;

begin
  StatusBar1.Panels[7].Text := '';

  IsBoxAccessibleTips := False;
  IsManAccessibleTips := False;

  while (Steps > 0) and (UnDoPos > 0) and (ReDoPos < MaxLenPath) do begin

    // �˵�λ�ó����쳣
    if (ManPos < 0) or (ManPos >= MapSize) or
       (not (map_Board[ManPos] in [ManCell, ManGoalCell])) then begin
       StatusBar1.Panels[7].Text := format('�˵�λ���쳣��- [%d, %d]', [ManPos mod mapCols + 1, ManPos div mapCols + 1]);
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

    // ����Ƿ�������ӵĶ���
    if ch in [ 'L', 'R', 'U', 'D' ] then begin

      if (pos2 < 0) or (pos2 >= MapSize) or                              // ���⣬��
         (pos1 < 0) or (pos1 >= MapSize) or
         (not (map_Board[pos1] in [BoxCell, BoxGoalCell])) or
         (not (map_Board[pos2] in [FloorCell, GoalCell]))then begin
         StatusBar1.Panels[7].Text := '�����˴���Ķ������ţ�- ' + ch;
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

      Dec(PushTimes);                                                        // �ƶ�����
    end else begin
      if (pos1 < 0) or (pos1 >= MapSize) or                              // ���⣬��
         (not (map_Board[pos1] in [FloorCell, GoalCell])) then begin
         StatusBar1.Panels[7].Text := '�����˴���Ķ������ţ�- ' + ch;
         Break;
      end;
      if (map_Board[pos1] = FloorCell) then
        map_Board[pos1] := ManCell
      else
        map_Board[pos1] := ManGoalCell;
    end;

    // �˵��˻�
    if (map_Board[ManPos] = ManCell) then
      map_Board[ManPos] := FloorCell
    else
      map_Board[ManPos] := GoalCell;

    Dec(MoveTimes);                                                          // �ƶ�����

    Dec(UnDoPos);
    Inc(ReDoPos);
    RedoList[ReDoPos] := ch;
    ManPos := pos1;                                                          // �˵���λ��

    Dec(Steps);
  end;

  StatusBar1.Panels[1].Text := inttostr(MoveTimes);
  StatusBar1.Panels[3].Text := inttostr(PushTimes);
  DrawMap();                               // ���µ�ͼ��ʾ

end;

procedure TTrialForm.FormCreate(Sender: TObject);
begin
  Caption := '����������';
  bt_Exit.Caption := '����';
  bt_GoThrough.Caption := '��Խ';
  bt_OddEven.Caption := '��ż';
  bt_Save.Caption := '������XSB + Lurd��';

  bt_Exit.Hint := '���ر༭��Ctrl + Q��';
  bt_GoThrough.Hint := '��Խ���ء�G��';
  bt_OddEven.Hint := '��ż��λ��E��';
  bt_Save.Hint := '������������ XSB + Lurd��Ctrl + C��';
  bt_UnDo.Hint := '������Z/�˸��/���֡�';
  bt_ReDo.Hint := '������X/�ո��/�س���/���֡�';

  StatusBar1.Panels[0].Text := '�ƶ�';
  StatusBar1.Panels[2].Text := '�ƶ�';
  StatusBar1.Panels[4].Text := '������';

  isBK        := False;
  isGoThrough := True;
  isOddEven   := False;
  curTrun     := 0;

  MaskPic := TBitmap.Create;      // ѡ��Ԫ����ͼ
  LoadDefaultSkin;

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

// �����޷�ǽ��ͼԪ
function TTrialForm.GetWall(r, c: Integer): Integer;
var
  pos: Integer;
begin
  result := 0;

  pos := r * mapCols + c;

  if (c > 0) and (map_Board[r * mapCols + c - 1] = WallCell) then
    result := result or MapDir[curTrun, 0];  // ����ǽ��
  if (r > 0) and (map_Board[(r - 1) * mapCols + c] = WallCell) then
    result := result or MapDir[curTrun, 1];  // ����ǽ��
  if (c < mapCols - 1) and (map_Board[r * mapCols + c + 1] = WallCell) then
    result := result or MapDir[curTrun, 2];  // ����ǽ��
  if (r < mapRows - 1) and (map_Board[(r + 1) * mapCols + c] = WallCell) then
    result := result or MapDir[curTrun, 3];  // ����ǽ��

  if ((result = MapDir[curTrun, 4]) or (result = MapDir[curTrun, 5]) or (result = MapDir[curTrun, 6]) or (result = 15)) and (c > 0) and (r > 0) and (map_Board[pos - mapCols - 1] = WallCell) then
    result := result or 16;  // ��Ҫ��ǽ��
end;

// �Ƚ�ͼԪ���һ������ɫ��ذ����ɫ�Ƿ���ͬ����ȷ���Ƿ񻭸���
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

// �ػ���ͼ
procedure TTrialForm.DrawMap();
var
  i, j, i2, j2, k, dx, dy, x1, y1, x2, y2, x3, y3, x4, y4, pos, t1, t2, man_Pos_: integer;
  R, R2: TRect;

begin

  // �����ʽ
  if IsManAccessibleTips or IsBoxAccessibleTips then map_Image.Cursor := crDrag
  else map_Image.Cursor := crDefault;

  map_Image.Visible := false;

  for i := 0 to mapRows - 1 do
  begin
    for j := 0 to mapCols - 1 do
    begin
      // 0-7, 1-6, 2-5, 3-4, ��Ϊת��
      case (curTrun) of  // ���� i2, j2 ģ��ͼԪ�ص���ת������������ô����ת����ʵ���ϵ�ͼʼ�ղ��� -- ����ͼ����ת��Ϊ�Ӿ�����
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

      pos := i * mapCols + j;    // ��ͼ�У������ӡ�����ʵλ��

      x1 := j2 * CellSize;        // x1, y1 �ǵ�ͼԪ�صĻ������� -- ��ת���
      y1 := i2 * CellSize;

      R := Rect(x1, y1, x1 + CellSize, y1 + CellSize);        // ��ͼ���ӵĻ��ƾ���

      map_Image.Canvas.CopyMode := SRCCOPY;
      case map_Board[pos] of
        WallCell:
          if isSeamless then
          begin    // �޷�ǽ��
            k := GetWall(i, j);
            case (k and $F) of
              1:
                map_Image.Canvas.StretchDraw(R, WallPic_l);     // ����
              2:
                map_Image.Canvas.StretchDraw(R, WallPic_u);     // ����
              3:
                map_Image.Canvas.StretchDraw(R, WallPic_lu);    // ����
              4:
                map_Image.Canvas.StretchDraw(R, WallPic_r);     // ����
              5:
                map_Image.Canvas.StretchDraw(R, WallPic_lr);    // ����
              6:
                map_Image.Canvas.StretchDraw(R, WallPic_ru);    // �ҡ���
              7:
                map_Image.Canvas.StretchDraw(R, WallPic_lur);   // ���ϡ���
              8:
                map_Image.Canvas.StretchDraw(R, WallPic_d);     // ����
              9:
                map_Image.Canvas.StretchDraw(R, WallPic_ld);    // ����
              10:
                map_Image.Canvas.StretchDraw(R, WallPic_ud);    // �ϡ���
              11:
                map_Image.Canvas.StretchDraw(R, WallPic_uld);   // ���ϡ���
              12:
                map_Image.Canvas.StretchDraw(R, WallPic_rd);    // �ҡ���
              13:
                map_Image.Canvas.StretchDraw(R, WallPic_ldr);   // ���ҡ���
              14:
                map_Image.Canvas.StretchDraw(R, WallPic_urd);   // �ϡ��ҡ���
              15:
                map_Image.Canvas.StretchDraw(R, WallPic_lurd);  // �ķ���ȫ��
            else
              map_Image.Canvas.StretchDraw(R, WallPic);
            end;
            if k > 15 then
            begin     // ��Ҫ����ǽ�Ķ��� -- �������Ŀ顱ǽ��
              dx := R.Left - CellSize div 2;
              dy := R.Top - CellSize div 2;
              map_Image.Canvas.StretchDraw(Rect(dx, dy, dx + CellSize, dy + CellSize), WallPic_top);
            end;
          end
          else
          begin                 // ��ǽ��
            map_Image.Canvas.StretchDraw(R, WallPic);
          end;
        FloorCell:
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, FloorPic2)
            else map_Image.Canvas.StretchDraw(R, FloorPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isFloorLine);  // ��������
          end;
        GoalCell:
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, GoalPic2)
            else map_Image.Canvas.StretchDraw(R, GoalPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isGoalLine);   // ��������
          end;
        BoxCell:
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, BoxPic2)
            else map_Image.Canvas.StretchDraw(R, BoxPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isBoxLine);    // ��������
          end;
        BoxGoalCell:
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, BoxGoalPic2)
            else map_Image.Canvas.StretchDraw(R, BoxGoalPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isBoxGoalLine); // ��������
          end;
        ManCell:
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, ManPic2)
            else map_Image.Canvas.StretchDraw(R, ManPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isManLine);    // ��������
          end;
        ManGoalCell:
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, ManGoalPic2)
            else map_Image.Canvas.StretchDraw(R, ManGoalPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isManGoalLine); // ��������
          end;
      else
        map_Image.Canvas.Brush.Color := clInactiveCaptionText;
        map_Image.Canvas.FillRect(R);
      end;

      // �Ƿ�����ģʽ��
      if isBK then
      begin

        if IsManAccessibleTips then
        begin   // ��ʾ�˵Ŀɴ���ʾ
          t1 := CellSize div 6;
          if t1 < 4 then t1 := 4;
          t2 := t1 - 1;
          if PathFinder.isManReachableByThrough_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.FillRect(Rect(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1));
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.FillRect(Rect(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2));
          end
          else if PathFinder.isManReachable_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2);
          end
          else if PathFinder.isBoxOfThrough_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2);
          end;
        end;
        if IsBoxAccessibleTips then
        begin   // ��ʾ���ӵĿɴ���ʾ
          t1 := CellSize div 6;
          if t1 < 4 then t1 := 4;
          t2 := t1 - 1;
          if PathFinder.isBoxReachable_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2);
          end;
        end;
      end
      else                                                                      // ����
      begin
        if IsManAccessibleTips then
        begin   // ��ʾ�˵Ŀɴ���ʾ
          t1 := CellSize div 6;
          if t1 < 4 then t1 := 4;
          t2 := t1 - 1;
          if PathFinder.isManReachableByThrough(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.FillRect(Rect(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1));
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.FillRect(Rect(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2));
          end
          else if PathFinder.isManReachable(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2);
          end
          else if PathFinder.isBoxOfThrough(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2);
          end;
        end;
        if IsBoxAccessibleTips then
        begin   // ��ʾ���ӵĿɴ���ʾ
          t1 := CellSize div 6;
          if t1 < 4 then t1 := 4;
          t2 := t1 - 1;
          if PathFinder.isBoxReachable(pos) then
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
//  PathFinder.isEditor := True;        // �༭������ʱ�������Զ����涯����־
  PathFinder.setThroughable(isGoThrough);

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
  NewMapSize;
  DrawMap;
end;

// �����ͼ�µ�ͼƬ��ʾ�ĳߴ�
procedure TTrialForm.NewMapSize();
var
  w, h: integer;
begin
  
  // �����ͼ��Ԫ��Ĵ�С
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

  // ѡ��Ԫ����ͼ
  MaskPic.Width  := CellSize;
  MaskPic.Height := MaskPic.Width;

  // ȷ����ͼ�ĳߴ�
  map_Image.Picture := nil;       // ���Ǳ���ģ����򣬵�ͼ���ܸı�ߴ�
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

// ���� Resize
procedure TTrialForm.FormResize(Sender: TObject);
begin
  NewMapSize;
  DrawMap;
end;

// ���ð�ť״̬
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
  LoadSkinForm.MyBMPFree(MaskPic);
end;

// �Ƿ�����Խ
procedure TTrialForm.bt_GoThroughClick(Sender: TObject);
begin
  isGoThrough := not isGoThrough;
  PathFinder.setThroughable(isGoThrough);
  SetButton;
end;

// Ĭ��Ƥ��
procedure TTrialForm.LoadDefaultSkin();
begin
  SkinSize   := 60;
  isSeamless := False;
  LineColor  := clInactiveCaptionText;  // ������ɫ
  isFloorLine   := true;            // �ذ��Ƿ���
  isGoalLine    := true;            // Ŀ����Ƿ���
  isManLine     := true;            // ���Ƿ���
  isManGoalLine := true;            // ����Ŀ����Ƿ���
  isBoxLine     := true;            // �����Ƿ���
  isBoxGoalLine := true;            // ������Ŀ����Ƿ���

  // �ذ�
  FloorPic.Width   := SkinSize;
  FloorPic.Height  := SkinSize;
  FloorPic.Canvas.CopyRect(Rect(0, 0, FloorPic.Width, FloorPic.Height), RecogForm_.Image4.Canvas, Rect(0, 0, 60, 60));

  // Ŀ���
  GoalPic.Width   := SkinSize;
  GoalPic.Height  := SkinSize;
  GoalPic.Canvas.CopyRect(Rect(0, 0, GoalPic.Width, GoalPic.Height), RecogForm_.Image4.Canvas, Rect(60, 0, 120, 60));

  // ���
  ManPic.Width   := SkinSize;
  ManPic.Height  := SkinSize;
  ManPic.Canvas.CopyRect(Rect(0, 0, ManPic.Width, ManPic.Height), RecogForm_.Image4.Canvas, Rect(240, 0, 300, 60));

  // ��ҡ�Ŀ���
  ManGoalPic.Width   := SkinSize;
  ManGoalPic.Height  := SkinSize;
  ManGoalPic.Canvas.CopyRect(Rect(0, 0, ManGoalPic.Width, ManGoalPic.Height), RecogForm_.Image4.Canvas, Rect(300, 0, 360, 60));

  // ����
  BoxPic.Width   := SkinSize;
  BoxPic.Height  := SkinSize;
  BoxPic.Canvas.CopyRect(Rect(0, 0, BoxPic.Width, BoxPic.Height), RecogForm_.Image4.Canvas, Rect(120, 0, 180, 60));

  // ���ӡ�Ŀ���
  BoxGoalPic.Width   := SkinSize;
  BoxGoalPic.Height  := SkinSize;
  BoxGoalPic.Canvas.CopyRect(Rect(0, 0, BoxGoalPic.Width, BoxGoalPic.Height), RecogForm_.Image4.Canvas, Rect(180, 0, 240, 60));

  // ǽ��
  WallPic.Width   := SkinSize;
  WallPic.Height  := SkinSize;
  WallPic.Canvas.CopyRect(Rect(0, 0, WallPic.Width, WallPic.Height), RecogForm_.Image4.Canvas, Rect(360, 0, 420, 60));

  // ����ͼԪ
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

  case curTrun of // �ѵ����λ�ã�ת����ͼ����ʵ���� -- ���Ӿ�����ת��Ϊ��ͼ����
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

  // �������ͼԪλ��
  pos := MapClickPos.y * mapCols + MapClickPos.x;

  case Button of
    mbleft:             // ���� -- ָ���
      case map_Board[pos] of
        FloorCell, GoalCell:
          begin            // �����ذ�
              if IsBoxAccessibleTips then begin                          // �����ӿɴ���ʾʱ
                // �ӵ��λ���Ƿ�ɴ����
                if(isBK and (not PathFinder.isBoxReachable_BK(pos))) or ((not isBK) and (not PathFinder.isBoxReachable(pos))) then
                   IsBoxAccessibleTips := False
                else begin
                  IsBoxAccessibleTips := False;

                  ReDoPos := PathFinder.boxTo(isBK, OldBoxPos, pos, ManPos);
                  if ReDoPos > 0 then begin
                    for k := 1 to ReDoPos do
                      RedoList[k] := BoxPath[ReDoPos - k + 1];
                    LastSteps := UnDoPos;              // ����ǰ�Ĳ���
                    if isBK then ReDo_BK(ReDoPos)
                    else ReDo(ReDoPos);
                  end;
                end;
              end else begin
                if isBK and (ManPos < 0) then Exit;

                IsManAccessibleTips := False;
                IsBoxAccessibleTips := False;
                ReDoPos := PathFinder.manTo(isBK, map_Board, ManPos, pos);               // �����˿ɴ�
                if ReDoPos > 0 then begin
                  LastSteps := UnDoPos;              // ����ǰ�Ĳ���
                  for k := 1 to ReDoPos do
                    RedoList[k] := ManPath[k];
                    if isBK then ReDo_BK(ReDoPos)
                    else ReDo(ReDoPos);
                end;
              end;
          end;
        ManCell, ManGoalCell:
          begin           // ������
              if IsBoxAccessibleTips and ((isBK and PathFinder.isBoxReachable_BK(ManPos)) or ((not isBK) and PathFinder.isBoxReachable(ManPos))) then begin   // �����ӿɴ���ʾʱ
                IsBoxAccessibleTips := False;

                ReDoPos := PathFinder.boxTo(isBK, OldBoxPos, pos, ManPos);
                if ReDoPos > 0 then begin
                  for k := 1 to ReDoPos do
                    RedoList[k] := BoxPath[ReDoPos - k + 1];
                  LastSteps := UnDoPos;              // ����ǰ�Ĳ���
                  if isBK then ReDo_BK(ReDoPos)
                  else ReDo(ReDoPos);
                end;
              end else if IsManAccessibleTips then
                IsManAccessibleTips := False        // ����ʾ�˵Ŀɴ���ʾʱ���ֵ������
              else begin
                PathFinder.manReachable(isBK, map_Board, ManPos);                       // �����˿ɴ�
                IsManAccessibleTips := True;
                IsBoxAccessibleTips := False;
              end;
          end;
        BoxCell, BoxGoalCell:
          begin           // ��������
              if IsBoxAccessibleTips and (OldBoxPos = pos) then
                IsBoxAccessibleTips := False
              else
              begin
                if isBK and (ManPos < 0) then Exit;
                
                IsBoxAccessibleTips := True;
                IsManAccessibleTips := False;
                PathFinder.FindBlock(map_Board, pos);                              // ���ݱ���������ӣ�������
                PathFinder.boxReachable(isBK, pos, ManPos);                        // �������ӿɴ�
                OldBoxPos := pos;
              end;
          end;
      else
          begin                            // ȡ���ɴ���ʾ
              IsManAccessibleTips := False;
              IsBoxAccessibleTips := False;
          end;
      end;
    mbright:
      begin    // �һ� -- ָ�Ҽ�

      end;
  end;

  DrawMap();
end;

// ���ڼ��̵��������Ұ��������ݹؿ��ĵ�ǰ��ת״̬ת�������ַ�
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
    69:                            // E�� ��ż��Ч��
      if not isOddEven then
         bt_OddEvenMouseDown(Self, mbLeft, [], -1, -1);
  end;
end;

procedure TTrialForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    69:
      bt_OddEvenMouseUp(Self, mbLeft, [], -1, -1);       // E�� ��ż��Ч��
    VK_HOME:    // Home������
      begin
        if isBK then UnDo_BK(UnDoPos)
        else UnDo(UnDoPos);
        StatusBar1.Panels[7].Text := '�����ף�';
      end;
    VK_END:    // End����β
      begin
        if isBK then ReDo_BK(ReDoPos)
        else ReDo(ReDoPos);
        StatusBar1.Panels[7].Text := '����β��';
      end;
    90:                    // z������
      begin
        bt_UnDo.Click;
      end;
    88:                    // x������
      begin
        bt_ReDo.Click;
      end;
    83:                    // S������һ��
      begin
        if isBK then ReDo_BK(1)
        else ReDo(1);
      end;
    65:                     // a������һ��
      begin
        if isBK then UnDo_BK(1)
        else UnDo(1);
      end;
    81:                // Ctrl + Q�� �˳�
      if ssCtrl in Shift then begin
         Close();
      end;
    71:                // G�� ��Խ
      bt_GoThrough.Click;
    76:                // Ctrl + L�� �Ӽ��а���� Lurd
      if ssCtrl in Shift then begin
         if LoadLurdFromClipboard(isBK) then begin
            if isBK then ReDo_BK(ReDoPos)
            else ReDo(ReDoPos);
         end;
      end;
    77:                // Ctrl + M�� Lurd ������а�
      if ssCtrl in Shift then begin
         if LurdToClipboard(ManPos mod mapCols, ManPos div mapCols) then
            StatusBar1.Panels[7].Text := '���� Lurd ������а壡';
      end;
    67:                 // Ctrl + C�� XSB ������а�
      if ssCtrl in Shift then begin
        bt_Save.Click;
      end;
    106, 56:                    // �� 0 ת
      begin
        curTrun := 0;
        SetMapTrun;
      end;
    111, 191:                   // ��ת�ؿ�
      begin
        if curTrun < 7 then
          inc(curTrun)
        else
          curTrun := 0; 
        SetMapTrun;
      end;
    27:                         // ESC���ؿ�ʼ
      begin
        if isBK then UnDo_BK(UnDoPos)
        else UnDo(UnDoPos);
        StatusBar1.Panels[7].Text := '�����ף�';
      end;
    8:                          // �˸����Undo
      begin
        bt_UnDo.Click;
      end;
    32, 13:                         // �ո��/�س�����Redo
      begin
        if (ssCtrl in Shift) or (ssAlt in Shift) or (ssShift in Shift) then begin
        end else begin
           bt_ReDo.Click;
        end;
      end;
  end;
end;

// ��ʾ��ż��Ч
procedure TTrialForm.bt_OddEvenMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  isOddEven := true;
  DrawMap();
end;

// �ر���ż��Ч
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
    LastSteps := -1;              // �������һ�ε���ǰ�Ĳ���
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
  DrawMap();       // ����ͼ
  case curTrun of
  0: StatusBar1.Panels[7].Text := '0ת = �ؿ���ԭʼ��ת״̬��';
  1: StatusBar1.Panels[7].Text := '1ת = �ؿ���˳ʱ����ת90��';
  2: StatusBar1.Panels[7].Text := '2ת = �ؿ���˳ʱ����ת180��';
  3: StatusBar1.Panels[7].Text := '3ת = �ؿ���˳ʱ����ת270�ȣ���ʱ����ת90�ȣ�';
  4: StatusBar1.Panels[7].Text := '4ת = �ؿ������ҷ�ת';
  5: StatusBar1.Panels[7].Text := '5ת = �ؿ������·�ת����ʱ����ת90�ȣ��ؿ������ҷ�ת��˳ʱ����ת90�ȣ�';
  6: StatusBar1.Panels[7].Text := '6ת = �ؿ������·�ת���ؿ������ҷ�ת��˳ʱ����ת180�ȣ�';
  7: StatusBar1.Panels[7].Text := '7ת = �ؿ���ת�ã������л������ؿ������ҷ�ת��˳ʱ����ת270�ȣ�����ʱ����ת90�ȣ�';
  end;
end;

procedure TTrialForm.pnl_TrunMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    case Button of
      mbleft:
        begin     // ���� -- ָ���
          if curTrun < 7 then
            inc(curTrun)
          else
            curTrun := 0;    // �� 0 ת
        end;
      mbright:
        begin    // �һ� -- ָ�Ҽ�
          if curTrun > 0 then
            dec(curTrun)
          else
            curTrun := 7;    // �� 0 ת
        end;
    end;
    SetMapTrun();
end;

procedure TTrialForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  IsBoxAccessibleTips := False;
  IsManAccessibleTips := False;
end;

// �������� reDo �����ڵ� -- ÿ��һ������Ϊһ������
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

    // Ѱ�Ҷ����ڵ�
  n := 0;  // Ӧ��ͣ�ڵڼ���������
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
        Dec(j);      // ����
      'u':
        Dec(i);      // ����
      'r':
        Inc(j);      // ����
      'd':
        Inc(i);      // ����
      'L':
        begin        // ����
          Dec(j);

          if (boxRC[0] <> i) or (boxRC[1] <> j) then
          begin
            if flg then
              break;   // �ڶ�������
            flg := true;         // ��һ������
          end;
          n := k;                  // ��һ�����ӵ����λ��

          boxRC[0] := i;
          boxRC[1] := j - 1;
        end;
      'U':
        begin        // ����
          Dec(i);

          if (boxRC[0] <> i) or (boxRC[1] <> j) then
          begin
            if flg then
              break;   // �ڶ�������
            flg := true;         // ��һ������
          end;
          n := k;                  // ��һ�����ӵ����λ��

          boxRC[0] := i - 1;
          boxRC[1] := j;
        end;
      'R':
        begin        // ����
          Inc(j);

          if (boxRC[0] <> i) or (boxRC[1] <> j) then
          begin
            if flg then
              break;   // �ڶ�������
            flg := true;         // ��һ������
          end;
          n := k;                  // ��һ�����ӵ����λ��

          boxRC[0] := i;
          boxRC[1] := j + 1;
        end;
      'D':
        begin        // ����
          Inc(i);

          if (boxRC[0] <> i) or (boxRC[1] <> j) then
          begin
            if flg then
              break;   // �ڶ�������
            flg := true;         // ��һ������
          end;
          n := k;                  // ��һ�����ӵ����λ��

          boxRC[0] := i + 1;
          boxRC[1] := j;
        end;
    end;
  end;
  if flg then
    result := len - n  // ���һ�����������ƣ���ǰ�����ƵĶ���ʱ
  else
    result := len;  // ʣ���ȫ������
end;

// �������� unDo �����ڵ� -- ÿ��һ������Ϊһ������
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

    // Ѱ�Ҷ����ڵ�
  n := 0;  // Ӧ��ͣ�ڵڼ���������
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
        Dec(j);      // ����
      'u':
        Dec(i);      // ����
      'r':
        Inc(j);      // ����
      'd':
        Inc(i);      // ����
      'L':
        begin        // ����
          if (boxRC[0] <> i) or (boxRC[1] <> j + 1) then
          begin
            if flg then
              break;   // �ڶ�������
            flg := true;         // ��һ������
          end;
          n := k;                  // ��һ�����ӵ����λ��
          boxRC[0] := i;
          boxRC[1] := j;
          Dec(j);
        end;
      'U':
        begin        // ����
          if (boxRC[0] <> i + 1) or (boxRC[1] <> j) then
          begin
            if flg then
              break;   // �ڶ�������
            flg := true;         // ��һ������
          end;
          n := k;                  // ��һ�����ӵ����λ��
          boxRC[0] := i;
          boxRC[1] := j;
          Dec(i);
        end;
      'R':
        begin        // ����
          if (boxRC[0] <> i) or (boxRC[1] <> j - 1) then
          begin
            if flg then
              break;   // �ڶ�������
            flg := true;         // ��һ������
          end;
          n := k;                  // ��һ�����ӵ����λ��
          boxRC[0] := i;
          boxRC[1] := j;
          Inc(j);
        end;
      'D':
        begin        // ����
          if (boxRC[0] <> i - 1) or (boxRC[1] <> j) then
          begin
            if flg then
              break;   // �ڶ�������
            flg := true;         // ��һ������
          end;
          n := k;                  // ��һ�����ӵ����λ��
          boxRC[0] := i;
          boxRC[1] := j;
          Inc(i);
        end;
    end;
  end;
  if flg then
    result := len - n  // ���һ�����������ƣ���ǰ�����ƵĶ���ʱ
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
  bt_ReDo.Click;          // x������
  Handled := True;
  Delay(10);
end;

procedure TTrialForm.FormMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  bt_UnDo.Click;          // z������
  Handled := True;
  Delay(10);
end;

procedure TTrialForm.bt_SaveClick(Sender: TObject);
var
  str: string;
  r, c: Integer;
begin
  StatusBar1.Panels[7].Text := '';

  // �ؿ� XSB
  str := EditorForm_.GetXSB;

  if isBK then begin    // ��������ʱ����¼�˵ĳ�ʼλ��
    c := manPos mod mapCols + 1;
    r := manPos div mapCols + 1;

    str := #10 + '; SXB Ϊ�ؿ����Ƴ�̬' + #10 + str + '[' + IntToStr(c) + ', ' + IntToStr(r) + ']';
  end;
  
  if UnDoPos > 0 then begin
     if UnDoPos < MaxLenPath then UndoList[UnDoPos+1] := #0;
     str := str + #10 + PChar(@UndoList) + #10;
  end;
  
  // ������а�
  Clipboard.SetTextBuf(PChar(str));

  StatusBar1.Panels[7].Text := 'XSB + Lurd ��������а壡';
end;

end.
