unit Recog_;

{$DEFINE TEST}

//{$IFDEF TEST}
//{$ELSE}
//{$ENDIF}

//{$IFDEF TEST}
//   Writeln(myLogFile, '');
//   Flush(myLogFile);
//{$ENDIF}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, jpeg, pngimage, Clipbrd, 
  Dialogs, ExtCtrls, Buttons, ImgList, ExtDlgs, Menus, Math, StdCtrls, Spin, DateUtils,
  ComCtrls;

type
  TIntArr = array[0..1023] of integer;
  TColors = array[0..7] of integer;
  
type
  TRecogForm_ = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    ScrollBox1: TScrollBox;
    sb_Open: TSpeedButton;
    OpenPictureDialog1: TOpenPictureDialog;
    PopupMenu1: TPopupMenu;
    B_Top: TMenuItem;
    B_Left: TMenuItem;
    B_Right: TMenuItem;
    B_Bottom: TMenuItem;
    Image1: TImage;
    Label1: TLabel;
    Map_Left: TSpinEdit;
    SpeedButton3: TSpeedButton;
    Label2: TLabel;
    Map_Right: TSpinEdit;
    SpeedButton1: TSpeedButton;
    Label3: TLabel;
    Map_Top: TSpinEdit;
    SpeedButton4: TSpeedButton;
    Label4: TLabel;
    Map_Bottom: TSpinEdit;
    SpeedButton2: TSpeedButton;
    Label5: TLabel;
    Map_RowHeight: TSpinEdit;
    Label8: TLabel;
    Map_ColWidth: TSpinEdit;
    sb_Copy: TSpeedButton;
    Image2: TImage;
    Panel3: TPanel;
    pl_Wall: TPanel;
    img_Wall: TImage;
    pl_Select: TPanel;
    img_Select: TImage;
    pl_Player: TPanel;
    img_Player: TImage;
    pl_Goal: TPanel;
    img_Goal: TImage;
    pl_Floor: TPanel;
    img_Floor: TImage;
    pl_Box: TPanel;
    img_Box: TImage;
    StatusBar1: TStatusBar;
    sb_UnDo: TSpeedButton;
    sb_Clear: TSpeedButton;
    sb_Return: TSpeedButton;
    sb_Screen: TSpeedButton;
    N1: TMenuItem;
    Image4: TImage;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    pl_BoxGoal: TPanel;
    img_BoxGoal: TImage;
    sb_Scale: TSpeedButton;
    Label7: TLabel;
    TrackBar2: TTrackBar;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    sb_ReDo: TSpeedButton;
    Panel4: TPanel;
    Image3: TImage;
    Panel5: TPanel;
    bt_Skin: TSpeedButton;
    procedure sb_OpenClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure DrawBianJie;
    procedure myDraw;
    procedure B_LeftClick(Sender: TObject);
    procedure B_RightClick(Sender: TObject);
    procedure B_TopClick(Sender: TObject);
    procedure B_BottomClick(Sender: TObject);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Map_LeftChange(Sender: TObject);
    procedure Map_RightChange(Sender: TObject);
    procedure Map_TopChange(Sender: TObject);
    procedure Map_BottomChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Map_RowHeightChange(Sender: TObject);
    procedure Map_ColWidthChange(Sender: TObject);
    procedure sb_CopyClick(Sender: TObject);
    procedure img_WallClick(Sender: TObject);
    procedure img_BoxClick(Sender: TObject);
    procedure img_GoalClick(Sender: TObject);
    procedure img_FloorClick(Sender: TObject);
    procedure img_PlayerClick(Sender: TObject);
    procedure img_SelectClick(Sender: TObject);
    procedure SetSelect;
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);                                  // ��Ԫ��ѡ��򡢸ı������ʽ
    procedure findSubimages;                                                    // ʶ��
    function isSubimage(img1: TBitmap; c, r: Integer): boolean;                 // �������Ƚ�
    function getAverageGrey(img: TBitmap; isYangben: Boolean; var PicColor: TColors;
      var dest: TIntArr): integer;                                              // ��ȡͼƬ��ƽ���Ҷ�ֵ
    function calSimilarity(a, b: TIntArr): double;                              // ͨ����������������ƶ�

    procedure SetTop(Y: Integer);
    procedure SetBottom(Y: Integer);
    procedure SetLeft(X: Integer);
    procedure SetRight(X: Integer);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sb_UnDoClick(Sender: TObject);
    procedure sb_ClearClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sb_ReturnClick(Sender: TObject);
    procedure sb_ScreenClick(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure img_BoxGoalClick(Sender: TObject);
    procedure ScrollBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure img_WallMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure img_BoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure img_BoxGoalMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure img_GoalMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure img_PlayerMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure img_FloorMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure img_SelectMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure CheckBox2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure CheckBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sb_OpenMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sb_ScreenMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sb_CopyMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sb_ClearMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sb_UnDoMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sb_ReturnMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SpeedButton3MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Map_LeftMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Map_RightMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SpeedButton1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Map_TopMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SpeedButton4MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Map_BottomMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SpeedButton2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Map_RowHeightMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure Map_ColWidthMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sb_ScaleClick(Sender: TObject);
    procedure sb_ScaleMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Panel3MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure Label7MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Label9MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure CheckBox3MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure CheckBox4MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure CheckBox5MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SetUnDoReDo(isReDo: Boolean = false);
    procedure SetXSB(str: string);
    procedure sb_ReDoMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sb_ReDoClick(Sender: TObject);
    procedure Image3MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image3Click(Sender: TObject);
    procedure Panel4Click(Sender: TObject);
    procedure bt_SkinClick(Sender: TObject);
    procedure bt_SkinMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ScrollBox1MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ScrollBox1MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
  private 
    { Private declarations }
  public
    { Public declarations }
    procedure MyStringListFree(var _StringList_: TStringList);
  end;

var
  RecogForm_: TRecogForm_;

  mySelect: Integer;                     // ѡ���Ԫ��
  PicRows, PicCols: Integer;             // ��������Ĺؿ��ߴ�

  myScale: Integer;                      // ͼ�����ű���

  pxSize: Integer;                       // ����������

  myMap: array[0..99, 0..99] of Char;

{$IFDEF TEST}
  duMap: array[0..99, 0..99] of Integer;
  clMap: array[0..99, 0..99] of Integer;
{$ENDIF}

  myClickPoint, myMovePoint: TPoint;     // ��갴��ʱ��������ƶ�ʱ��λ��
  rg_ManPos: TPoint;                     // �˵�����

  old_Left, old_Top, old_Right, old_Bottom, old_RowHeight, old_ColWidth, old_Tag: Integer;

  rUnDoList, rReDoList: TStringList;

  procedure LoadSkin_;         // ����

implementation

uses
  LoadSkin, Editor_;

const
  cursorWall_     = 11;
  cursorBox_      = 12;
  cursorBoxGoal_  = 13;
  cursorGoal_     = 14;
  cursorMan_      = 15;
  cursorErase_    = 16;
  cursorSheel_    = 17;

  XSB_Char :array[1..7] of Char = ( '#', '$', '*', '.', '-', '@', '+' );

var
  m_SampleArray0: TIntArr;                             //�����ıȽ�����
  my_Color0, my_Color1: TColors;                       //ͼƬ��ɫ��ֲ�
  my_Grey0, my_Grey1: Integer;                         //ͼƬ�ĻҶ�ֵ

  cur_Rect: TRect;

  mySizeOf, mySizeOf_: Integer;

  //��ʱ����һ�µ�Ԫ��
  myHintChar: Char;           // Shift ��
  myHintPos: TPoint;          // Ctrl ��

  isShiftDown: Boolean;       // �Ƿ� Shift ���������£���ʱ�������ֿ���΢�����ߵ�
  isSheelEnable: Boolean;     // �Ƿ��������΢������

  myStartTime: Int64;         // ��¼���˫��ʹ�õĵ�һ����ʱ���

{$IFDEF TEST}
  tmpPic: TBitmap;
  imgDu: Integer;
  clrDu: Integer;
{$ENDIF}

{$R *.dfm}
{$R MyCursor_.res}

// �ͷ� TStringList ���ڴ�
procedure TRecogForm_.MyStringListFree(var _StringList_: TStringList);
begin
  if Assigned(_StringList_) then begin
     _StringList_.Clear;
     _StringList_.Free;
     _StringList_ := nil;
  end;
end;

// ����
procedure LoadSkin_;
begin
  if LoadSkinForm.ShowModal = mrOK then
  begin
    if not LoadSkinForm.LoadSkin(ExtractFilePath(Application.ExeName) + 'Skins\' +LoadSkinForm.SkinFileName) then
    begin
      LoadSkinForm.LoadDefaultSkin();         // ʹ��Ĭ�ϵļ�Ƥ��
    end;

    RecogForm_.Image4.Canvas.CopyRect(Rect(0, 0, 60, 60), FloorPic.Canvas, Rect(0, 0, FloorPic.Width, FloorPic.Height));
    RecogForm_.Image4.Canvas.CopyRect(Rect(60, 0, 120, 60), GoalPic.Canvas, Rect(0, 0, GoalPic.Width, GoalPic.Height));
    RecogForm_.Image4.Canvas.CopyRect(Rect(120, 0, 180, 60), BoxPic.Canvas, Rect(0, 0, BoxPic.Width, BoxPic.Height));
    RecogForm_.Image4.Canvas.CopyRect(Rect(180, 0, 240, 60), BoxGoalPic.Canvas, Rect(0, 0, BoxGoalPic.Width, BoxGoalPic.Height));
    RecogForm_.Image4.Canvas.CopyRect(Rect(240, 0, 300, 60), ManPic.Canvas, Rect(0, 0, ManPic.Width, ManPic.Height));
    RecogForm_.Image4.Canvas.CopyRect(Rect(300, 0, 360, 60), ManGoalPic.Canvas, Rect(0, 0, ManGoalPic.Width, ManGoalPic.Height));
    RecogForm_.Image4.Canvas.CopyRect(Rect(360, 0, 420, 60), WallPic.Canvas, Rect(0, 0, WallPic.Width, WallPic.Height));

    RecogForm_.img_Goal.Canvas.CopyRect(Rect(0, 0, 60, 60), GoalPic.Canvas, Rect(0, 0, GoalPic.Width, GoalPic.Height));
    RecogForm_.img_Box.Canvas.CopyRect(Rect(0, 0, 60, 60), BoxPic.Canvas, Rect(0, 0, BoxPic.Width, BoxPic.Height));
    RecogForm_.img_BoxGoal.Canvas.CopyRect(Rect(0, 0, 60, 60), BoxGoalPic.Canvas, Rect(0, 0, BoxGoalPic.Width, BoxGoalPic.Height));
    RecogForm_.img_Player.Canvas.CopyRect(Rect(0, 0, 60, 60), ManPic.Canvas, Rect(0, 0, ManPic.Width, ManPic.Height));
    RecogForm_.img_Wall.Canvas.CopyRect(Rect(0, 0, 60, 60), WallPic.Canvas, Rect(0, 0, WallPic.Width, WallPic.Height));

    EditorForm_.img_Floor.Canvas.CopyRect(Rect(0, 0, 60, 60), FloorPic.Canvas, Rect(0, 0, FloorPic.Width, FloorPic.Height));
    EditorForm_.img_Goal.Canvas.CopyRect(Rect(0, 0, 60, 60), GoalPic.Canvas, Rect(0, 0, GoalPic.Width, GoalPic.Height));
    EditorForm_.img_Box.Canvas.CopyRect(Rect(0, 0, 60, 60), BoxPic.Canvas, Rect(0, 0, BoxPic.Width, BoxPic.Height));
    EditorForm_.img_Player.Canvas.CopyRect(Rect(0, 0, 60, 60), ManPic.Canvas, Rect(0, 0, ManPic.Width, ManPic.Height));
    EditorForm_.img_Wall.Canvas.CopyRect(Rect(0, 0, 60, 60), WallPic.Canvas, Rect(0, 0, WallPic.Width, WallPic.Height));
  end;
end;

function GetJavaTime( d: TDateTime ): Int64;
var
  dJavaStart: TDateTime;
begin
  //java���ʱ���Ǵ�1970��1��1��0�㵽��ǰ�ļ��
  dJavaStart := EncodeDateTime( 1970, 1, 1, 0, 0, 0, 0 );
  Result := MilliSecondsBetween( d, dJavaStart );
end;

procedure TRecogForm_.SetTop(Y: Integer);
begin
  if Y <= Map_Bottom.Value then begin
     Map_Top.Value := Y;
     PicRows := (Map_Bottom.Value-Map_Top.Value) div Map_RowHeight.Value;
     if ((Map_Bottom.Value-Map_Top.Value) mod Map_RowHeight.Value) < (Map_RowHeight.Value div 2) then begin
        PicRows := PicRows - 1;
     end;
  end
  else begin
     Map_Top.Value := Map_Bottom.Value;
     Map_Bottom.Value :=  Y;
  end;
  Map_RowHeight.MaxValue := Map_Bottom.Value - Map_Top.Value;
end;

procedure TRecogForm_.SetBottom(Y: Integer);
begin
  if Y >= Map_Top.Value then begin
     Map_Bottom.Value := Y;
     PicRows := (Map_Bottom.Value-Map_Top.Value) div Map_RowHeight.Value;
     if ((Map_Bottom.Value-Map_Top.Value) mod Map_RowHeight.Value) < (Map_RowHeight.Value div 2) then begin
        PicRows := PicRows - 1;
     end;
  end
  else begin
     Map_Bottom.Value := Map_Top.Value;
     Map_Top.Value := Y;
  end;
  Map_RowHeight.MaxValue := Map_Bottom.Value - Map_Top.Value;
end;

procedure TRecogForm_.SetLeft(X: Integer);
begin
  if X <= Map_Right.Value then begin
     Map_Left.Value := X;
     PicCols := (Map_Right.Value-Map_Left.Value) div Map_ColWidth.Value;
     if ((Map_Right.Value-Map_Left.Value) mod Map_ColWidth.Value) < (Map_ColWidth.Value div 2) then begin
        PicCols := PicCols - 1;
     end;
  end
  else begin
     Map_Left.Value := Map_Right.Value;
     Map_Right.Value := X;
  end;
  Map_ColWidth.MaxValue := Map_Right.Value - Map_Left.Value;
end;

procedure TRecogForm_.SetRight(X: Integer);
begin
  if X >= Map_Left.Value then begin
     Map_Right.Value := X;
     PicCols := (Map_Right.Value-Map_Left.Value) div Map_ColWidth.Value;
     if ((Map_Right.Value-Map_Left.Value) mod Map_ColWidth.Value) < (Map_ColWidth.Value div 2) then begin
        PicCols := PicCols - 1;
     end;
  end
  else begin
     Map_Right.Value := Map_Left.Value;
     Map_Left.Value := X;
  end;
  Map_ColWidth.MaxValue := Map_Right.Value - Map_Left.Value;
end;

// ʶ��
procedure TRecogForm_.findSubimages;
var
  img0, img1: TBitmap;   // ����ͼƬ������ͼƬ
  rt0, rt1, rt2: TRect;  // ������ͼƬ���ӡ���ʱ
	ww, hh, r, c, x, y: integer;
begin

	ww := cur_Rect.right - cur_Rect.left - 4;  // ʵ��ȡ���ߴ磬���ܱ߸��ó� 2 ������
	hh := cur_Rect.bottom - cur_Rect.top - 4;  // ʵ��ȡ���ߴ磬���ܱ߸��ó� 2 ������
	img0 := TBitmap.create;
	img1 := TBitmap.create;
	img0.width := ww;
	img0.height := hh;
	img1.width := ww;
	img1.height := hh;
	img0.PixelFormat := pf24bit;
	img1.PixelFormat := pf24bit;
  img0.Canvas.CopyMode := cmSrcCopy;
  img1.Canvas.CopyMode := cmSrcCopy;

  pxSize := ww * hh;

	rt2 := Rect(0, 0, ww, hh);

	rt0 := Rect(cur_Rect.left + 2, cur_Rect.top + 2, cur_Rect.left + 2 + img0.width, cur_Rect.top + 2 + img0.height);  // ������Χ
	img0.Canvas.CopyRect(rt2, Image1.Canvas, rt0);                                                    // ����ͼƬ
	my_Grey0 := getAverageGrey(img0, True, my_Color0, m_SampleArray0);                                // ��ȡ����������ɫ

	// ��"���Ͻ�"��ʼ������ͼ
	y := Map_Top.Value;

	for r := 0 to PicRows do begin
		x := Map_Left.Value;
		for c := 0 to PicCols do begin
      if myMap[r, c] = '-' then begin
              rt1 := Rect(x + 2, y + 2, x + 2 + ww, y + 2 + hh);   // ���ӷ�Χ
              img1.Canvas.CopyRect(rt2, Image1.Canvas, rt1);                                   // ����ͼƬ
              if isSubimage(img1, c, r) then begin
                 case mySelect of
                   1: myMap[r, c] := XSB_Char[1];                                       // ǽ��
                   2: myMap[r, c] := XSB_Char[2];
                   3: myMap[r, c] := XSB_Char[3];
                   4: myMap[r, c] := XSB_Char[4];
                 end;
              end;
{$IFDEF TEST}
    duMap[r, c] := imgDu;
    clMap[r, c] := clrDu;
{$ENDIF}

      end else begin

{$IFDEF TEST}
    rt1 := Rect(x + 2, y + 2, x + 2 + ww, y + 2 + hh);   // ���ӷ�Χ
    img1.Canvas.CopyRect(rt2, Image1.Canvas, rt1);       // ����ͼƬ
    isSubimage(img1, c, r);
    duMap[r, c] := imgDu;
    clMap[r, c] := clrDu;
{$ENDIF}

      end;
			x := x + Map_ColWidth.Value;
		end;
		y := y + Map_RowHeight.Value;
	end;
  LoadSkinForm.MyBMPFree(img0);
  LoadSkinForm.MyBMPFree(img1);
end;

// ����ɫ�������Ƿ����
// ����ɫ�������Ƿ����
function isColorNear(c1, c2: TColors): Boolean;
var
  i, n1, n2, m1, m2: Integer;
begin
  result := True;
  m1 := 0;
  m2 := 0;
  n1 := 0;
  n2 := 0;
  for i := 0 to 7 do begin
    if m1 < c1[i] then begin
       m1 := c1[i];
       n1 := i;
    end;
    if m2 < c2[i] then begin
       m2 := c2[i];
       n2 := i;
    end;
    if n1 <> n2 then begin
       result := False;
       Exit
    end;
  end;
end;

// �������Ƚ�
function TRecogForm_.isSubimage(img1: TBitmap; c, r: Integer): boolean;
var
	m_SampleArray1: TIntArr;   // ���ӵıȽ�����
	v: double;                 // , v_
  flg: boolean;
begin
	my_Grey1 := getAverageGrey(img1, False, my_Color1, m_SampleArray1);                  // ��ȡ�Ƚ�ͼ�������ɫ

	v  := calSimilarity(m_SampleArray0, m_SampleArray1) * 100;
//  v_ := ColorNear(my_Color0, my_Color1) * 100;

{$IFDEF TEST}
  imgDu := Trunc(v);
//  clrDu := Trunc(v_);
{$ENDIF}

  // �Ƚ�������ɫ�����ƶ�

	flg := (Trunc(v) >= TrackBar2.Position) and                                   // ���ƶ�
         ((not CheckBox5.Checked) or (my_Grey0 = my_Grey1)) and                 // ƽ���Ҷ�
         ((not CheckBox4.Checked) or isColorNear(my_Color0, my_Color1));        // ɫ��

  result := flg;
end;

// RGB ��ɫת HSL ��ɫ�������ͶȺ����ȣ�
procedure RGBtoHSL(R, G, B: Integer; var H, S, L: Double);
var
  Delta: Double;
  CMax, CMin: Double;
  Red, Green, Blue, Hue, Sat, Lum: Double;
begin
  Red := R / 255;
  Green := G / 255;
  Blue := B / 255;

  CMax := Max(Red, Max(Green, Blue));
  CMin := Min(Red, Min(Green, Blue));
  Lum := (CMax + CMin) / 2;

  if CMax = CMin then
  begin
    Sat := 0;
    Hue := 0;
  end
  else
  begin
    if Lum < 0.5 then
      Sat := (CMax - CMin) / (CMax + CMin)
    else
      Sat := (CMax - CMin) / (2 - CMax - CMin);

    Delta := CMax - CMin;

    if Red = CMax then
      Hue := (Green - Blue) / Delta
    else if Green = CMax then
      Hue := 2 + (Blue - Red) / Delta
    else
      Hue := 4.0 + (Red - Green) / Delta;

    Hue := Hue / 6;
    if Hue < 0 then
      Hue := Hue + 1;
  end;

  H := (Hue * 360);
  S := (Sat * 100);
  L := (Lum * 100);
end;

// ��ȡͼƬ��ƽ���Ҷ�ֵ
function TRecogForm_.getAverageGrey(img: TBitmap; isYangben: Boolean; var PicColor: TColors; var dest: TIntArr): Integer;
var
  i, j, width, height, size, n: integer;
	red, green, blue, grey, averageColor: integer;
	sumGrey: Int64;
	image: TBitmap;
  R1, R2: TRect;
  psub: PByteArray;
  H, S, L: Double;

{$IFDEF TEST}
  psub_: PByteArray;
{$ENDIF}
begin
  for i := 0 to 7 do PicColor[i] := 0;

	// ת�����Ҷ�ͼ
	width := img.Width;         //��ȡλͼ�Ŀ�
	height := img.Height;       //��ȡλͼ�ĸ�
  size := width * height;
  R1 := Rect(0, 0, width, height);
	sumGrey := 0;

	for i := 0 to height-1 do begin
    psub := img.ScanLine[i];
    for j := 0 to width-1 do begin
			blue  := psub[j*3];
			green := psub[j*3+1];
			red   := psub[j*3+2];

			//����ͼ���ɫ��
      RGBtoHSL(red and $FFFFF8, green and $FFFFF8, blue and $FFFFF8, H, S, L);
      n := Trunc(H);
//			inc(PicColor[n]);

      if (n > 315) or (n < 20) then inc(PicColor[0])
      else if n > 295 then inc(PicColor[7])
      else if n > 270 then inc(PicColor[6])
      else if n > 190 then inc(PicColor[5])
      else if n > 155 then inc(PicColor[4])
      else if n > 75 then inc(PicColor[3])
      else if n > 40 then inc(PicColor[2])
      else inc(PicColor[1]);
      
			grey := Round(red * 0.3 + green * 0.59 + blue * 0.11);
//			grey := Round(red * 0.2126 + green * 0.7152 + blue * 0.0722);             // YASC
			psub[j*3]   := grey;
			psub[j*3+1] := grey;
			psub[j*3+2] := grey;

			sumGrey := sumGrey + grey;
		end;
	end;

  result := Trunc(sumGrey / size) and $FFFFF8;                                  // ƽ���Ҷ�ֵ       

  // ������ 32 * 32
	image := TBitmap.create;
  image.Canvas.CopyMode := cmSrcCopy;
  try
	  image.width := 32;
    image.height := 32;
    size := 32 * 32;
    R2 := Rect(0, 0, 32, 32);
    image.PixelFormat := pf24bit;
    image.Canvas.CopyRect(R2, img.Canvas, R1);

    // ��ȡ�Ҷ�ͼ��ƽ��������ɫֵ
    sumGrey := 0;
    for i := 0 to 31 do begin
      psub := image.ScanLine[i];
      for j := 0 to 31 do begin
        grey := psub[j*3];
        sumGrey := sumGrey + grey;
      end;
    end;
    averageColor := Trunc(sumGrey / size);

    // ��ȡ�Ҷ�ͼ�����رȽ����飨ƽ��ֵ����
    for i := 0 to 31 do begin
      psub := image.ScanLine[i];

{$IFDEF TEST}
  if isYangben then begin
      psub_ := tmpPic.ScanLine[i];
  end;
{$ENDIF}

      for j := 0 to 31 do begin
        grey := psub[j*3];
        if grey > averageColor then dest[i * 32 + j] := 1   
        else dest[i * 32 + j] := 0;

{$IFDEF TEST}
  if isYangben then begin
    if grey > averageColor then begin
        psub_[j*3] := 255;
        psub_[j*3+1] := 255;
        psub_[j*3+2] := 255;
    end else begin
        psub_[j*3] := 0;
        psub_[j*3+1] := 0;
        psub_[j*3+2] := 0;
    end;
  end;
{$ENDIF}

      end;
    end;
  finally
    LoadSkinForm.MyBMPFree(image);
  end;
end;

// ͨ����������������ƶ�
function TRecogForm_.calSimilarity(a, b: TIntArr): Double;
var
  i, hammingDistance, length: integer;
begin
	// ��ȡ��������ͼ��ƽ�����رȽ�����ĺ������루����Խ�����Խ��
	hammingDistance := 0;
	for i := 0 to 1023 do begin
		if b[i] = a[i] then hammingDistance := hammingDistance + 1;
	end;

	// ͨ����������������ƶ�
	length := 32*32;
	result := Sqr(hammingDistance / length);        // ʹ��ָ�����ߵ������ƶȽ��
end;

// ��ʼ����
procedure TRecogForm_.FormActivate(Sender: TObject);
begin
  Image1.Tag := 0;
  mySelect := 0;
  myClickPoint.X := 0;
  myClickPoint.Y := 0;
  myHintPos.X := -1;
  myHintPos.Y := -1;
  Tag := 0;
  isShiftDown := False;
  SetSelect;
  myDraw;
  rUnDoList.Clear;
  rReDoList.Clear;
end;

// ����ͼƬ
procedure TRecogForm_.sb_OpenClick(Sender: TObject);
var
  i, j: Integer;
  tmpBmp: TBitmap;
begin
  if OpenPictureDialog1.Execute then begin
     tmpBmp := TBitmap.Create;
     try
       mySelect := 0;
       SetSelect;
       Image2.Picture.LoadFromFile(OpenPictureDialog1.FileName);
       tmpBmp.Assign(Image2.Picture.Graphic);
       Image2.Picture.Bitmap := tmpBmp;

       myScale := 1;                                // �մ�ͼ��ʱ����������
       Image1.Width  := Image2.Width * myScale;
       Image1.Height := Image2.Height * myScale;
       Image1.Visible := True;

       Map_Left.Value   := 0;
       Map_Top.Value    := 0;
       if (Image1.Width < 200) or (Image1.Height < 200) then begin
         Map_Right.Value  := Image1.Width-1;
         Map_Bottom.Value := Image1.Height-1;
       end else begin
         Map_Right.Value  := Image1.Width-50;
         Map_Bottom.Value := Image1.Height-50;
         Map_Left.Value   := 50;
         Map_Top.Value    := 50;
       end;

       Map_Left.MinValue   := 0;
       Map_Left.MaxValue   := Image1.Width-1;
       Map_Top.MinValue    := 0;
       Map_Top.MaxValue    := Image1.Height-1;
       Map_Right.MinValue  := 0;
       Map_Right.MaxValue  := Image1.Width-1;
       Map_Bottom.MinValue := 0;
       Map_Bottom.MaxValue := Image1.Height-1;

       Map_RowHeight.MaxValue := Map_Bottom.Value - Map_Top.Value;
       Map_ColWidth.MaxValue := Map_Right.Value - Map_Left.Value;
       
       if Map_ColWidth.MaxValue < 50 then Map_ColWidth.Value := Map_ColWidth.MaxValue
       else Map_RowHeight.Value := 50;
       if Map_ColWidth.MaxValue < 50 then Map_ColWidth.Value := Map_ColWidth.MaxValue
       else Map_ColWidth.Value  := 50;

       PicRows := (Map_Bottom.Value-Map_Top.Value) div Map_RowHeight.Value;
       PicCols := (Map_Right.Value-Map_Left.Value) div Map_ColWidth.Value;
       if ((Map_Bottom.Value-Map_Top.Value) mod Map_RowHeight.Value) < (Map_RowHeight.Value div 2) then begin
          PicRows := PicRows - 1;
       end;
       if ((Map_Right.Value-Map_Left.Value) mod Map_ColWidth.Value) < (Map_ColWidth.Value div 2) then begin
         PicCols := PicCols - 1;
       end;
       StatusBar1.Panels[1].Text := IntToStr(PicRows+1);
       StatusBar1.Panels[3].Text := IntToStr(PicCols+1);

       for i := 0 to 99 do begin
         for j := 0 to 99 do begin
             myMap[i, j] := '-';

{$IFDEF TEST}
             duMap[i, j] := 0;
             clMap[i, j] := 0;
{$ENDIF}

         end;
       end;
       rg_ManPos.X := -1;
       rg_ManPos.Y := -1;
       CheckBox1.Checked := False;                    // �Ƿ��ֶ�
       CheckBox2.Checked := False;                    // XSB�ַ�

       myMovePoint.X := -1;
       myMovePoint.Y := -1;
       myHintPos.X := -1;
       myHintPos.Y := -1;

       rUnDoList.Clear;
       rReDoList.Clear;

       myDraw;
     finally
       LoadSkinForm.MyBMPFree(tmpBmp);
     end;
  end;
end;

// ����
procedure TRecogForm_.sb_ScreenClick(Sender: TObject);
var
  i, j: Integer;
  Fullscreen: Tbitmap;
  FullscreenCanvas: TCanvas;
  dc: HDC;
begin

   SendMessage(Application.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
   Application.ProcessMessages;

   Fullscreen := TBitmap.Create;

   try
     //����һ��BITMAP�����ͼ��
     Fullscreen.Width := screen.width;
     Fullscreen.Height := screen.Height;
     DC := GetDC(0); //ȡ����Ļ��DC������0ָ������Ļ
     //����һ��CANVAS����
     FullscreenCanvas := TCanvas.Create;
     try
       FullscreenCanvas.Handle := DC;
       Fullscreen.Canvas.CopyRect(Rect(0, 0, screen.Width, screen.Height),
       fullscreenCanvas, Rect(0, 0, Screen.Width, Screen.Height));
     finally
       //��������Ļ���Ƶ�BITMAP��
       FullscreenCanvas.Free;
       //�ͷ�CANVAS����
       ReleaseDC(0, DC); //�ͷ�DC
     end;

     mySelect := 0;
     SetSelect;

     Image2.Picture.Bitmap := fullscreen;
     image2.Width := fullscreen.Width;
     image2.Height := fullscreen.Height;

     myScale := 1;                                // �մ�ͼ��ʱ����������
     Image1.Width  := Image2.Width;
     Image1.Height := Image2.Height;
     Image1.Visible := True;

     Map_Left.Value   := 0;
     Map_Top.Value    := 0;
     if (Image1.Width < 200) or (Image1.Height < 200) then begin
       Map_Right.Value  := Image1.Width-1;
       Map_Bottom.Value := Image1.Height-1;
     end else begin
       Map_Right.Value  := Image1.Width-50;
       Map_Bottom.Value := Image1.Height-50;
       Map_Left.Value   := 50;
       Map_Top.Value    := 50;
     end;

     Map_Left.MinValue := 0;
     Map_Left.MaxValue := Map_Right.Value-1;
     Map_Top.MinValue := 0;
     Map_Top.MaxValue := Map_Bottom.Value-1;
     Map_Right.MinValue := Map_Left.MinValue+1;
     Map_Right.MaxValue := Image1.Width-1;
     Map_Bottom.MinValue := Map_Top.Value+1;
     Map_Bottom.MaxValue := Image1.Height-1;

     Map_RowHeight.MaxValue := Map_Bottom.Value - Map_Top.Value;
     Map_ColWidth.MaxValue := Map_Right.Value - Map_Left.Value;
     if Map_ColWidth.MaxValue < 50 then Map_ColWidth.Value := Map_ColWidth.MaxValue
     else Map_RowHeight.Value := 50;
     if Map_ColWidth.MaxValue < 50 then Map_ColWidth.Value := Map_ColWidth.MaxValue
     else Map_ColWidth.Value  := 50;
     PicRows := (Map_Bottom.Value-Map_Top.Value) div Map_RowHeight.Value;
     PicCols := (Map_Right.Value-Map_Left.Value) div Map_ColWidth.Value;
     if ((Map_Bottom.Value-Map_Top.Value) mod Map_RowHeight.Value) < (Map_RowHeight.Value div 2) then begin
        PicRows := PicRows - 1;
     end;
     if ((Map_Right.Value-Map_Left.Value) mod Map_ColWidth.Value) < (Map_ColWidth.Value div 2) then begin
        PicCols := PicCols - 1;
     end;
     StatusBar1.Panels[1].Text := IntToStr(PicRows+1);
     StatusBar1.Panels[3].Text := IntToStr(PicCols+1);

     for i := 0 to 99 do begin
       for j := 0 to 99 do begin
           myMap[i, j] := '-';

{$IFDEF TEST}
   duMap[i, j] := 0;
   clMap[i, j] := 0;
{$ENDIF}

       end;
     end;
     rg_ManPos.X := -1;
     rg_ManPos.Y := -1;
     CheckBox1.Checked := False;                    // �Ƿ��ֶ�
     CheckBox2.Checked := False;                    // �Ƿ�XSB�ַ�

     myMovePoint.X := -1;
     myMovePoint.Y := -1;
     myHintPos.X := -1;
     myHintPos.Y := -1;

     rUnDoList.Clear;
     rReDoList.Clear;

     myDraw;
   finally
     LoadSkinForm.MyBMPFree(fullscreen);
   end;

   SendMessage(Application.Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
   Application.ProcessMessages;
end;

// ���ƻ���
procedure TRecogForm_.myDraw;
var
  i, j, x, y, boxs, goals: Integer;
  R1, R2: TRect;

{$IFDEF TEST}
  ww, hh: Integer;
{$ENDIF}  
begin
  if not Image1.Visible then Exit;

  R1 :=  Rect(0, 0, Image1.Width, Image1.Height);
  R2 :=  Rect(0, 0, Image2.Width, Image2.Height);
  Image1.Canvas.CopyRect(R1, Image2.Canvas, R2);

  DrawBianJie;

  Image1.Canvas.Pen.Width := 1;
  for i := 1 to PicRows do begin
    Image1.Canvas.Pen.Color := clBlack;
    Image1.Canvas.MoveTo(Map_Left.Value, Map_Top.Value + i * Map_RowHeight.Value+1);
    Image1.Canvas.LineTo(Map_Right.Value, Map_Top.Value + i * Map_RowHeight.Value+1);
    Image1.Canvas.Pen.Color := clWhite;
    Image1.Canvas.MoveTo(Map_Left.Value, Map_Top.Value + i * Map_RowHeight.Value);
    Image1.Canvas.LineTo(Map_Right.Value, Map_Top.Value + i * Map_RowHeight.Value);
  end;
  for i := 1 to PicCols do begin
    Image1.Canvas.Pen.Color := clBlack;
    Image1.Canvas.MoveTo(Map_Left.Value + i * Map_ColWidth.Value+1, Map_Top.Value);
    Image1.Canvas.LineTo(Map_Left.Value + i * Map_ColWidth.Value+1, Map_Bottom.Value);
    Image1.Canvas.Pen.Color := clWhite;
    Image1.Canvas.MoveTo(Map_Left.Value + i * Map_ColWidth.Value, Map_Top.Value);
    Image1.Canvas.LineTo(Map_Left.Value + i * Map_ColWidth.Value, Map_Bottom.Value);
  end;
  Image1.Canvas.Font.Color := clWhite;
  Image1.Canvas.Font.Style := [];
  boxs := 0;
  goals := 0;
  for i := 0 to PicRows do begin
      for j := 0 to PicCols do begin
          if myMap[i, j] in [ '#', '$', '*', '.', '@', '+' ] then begin
             if (myHintPos.X = j) and (myHintPos.Y = i) then Continue;          // Ctrl ��������һ������

             if myMap[i, j] <> myHintChar then begin                            // Shift ��������ͬ�����
               // ����ʶ�����Ԫ��
               x := j * Map_ColWidth.Value + Map_Left.Value;
               y := i * Map_RowHeight.Value + Map_Top.Value;
               if CheckBox2.Checked then begin
                 Image1.Canvas.Brush.Color := clBlack;
                 Image1.Canvas.Font.Size := 16;
                 if myMap[i, j] = '.' then Image1.Canvas.TextOut(x, y, 'o')
                 else Image1.Canvas.TextOut(x, y, myMap[i, j]);
               end else begin
                 case myMap[i, j] of
                   '.': R1 := Rect(60, 0, 120, 60);
                   '$': R1 := Rect(120, 0, 180, 60);
                   '*': R1 := Rect(180, 0, 240, 60);
                   '@': R1 := Rect(240, 0, 300, 60);
                   '+': R1 := Rect(300, 0, 360, 60);
                   '#': R1 := Rect(360, 0, 420, 60);
                   else R1 := Rect(0, 0, 60, 60);
                 end;
                 R2 := Rect(x, y, x + Map_ColWidth.Value, y + Map_RowHeight.Value);
                 Image1.Canvas.CopyRect(R2, Image4.Canvas, R1);
               end;
             end;
             
             // ͳ�����ӡ�Ŀ�����
             if myMap[i, j] = '$' then inc(boxs)
             else if myMap[i, j] in [ '.', '+' ] then inc(goals)
             else if myMap[i, j] = '*' then begin
               inc(boxs); inc(goals);
             end;
          end;

{$IFDEF TEST}
  if Image3.Visible then begin
     x := j * Map_ColWidth.Value + Map_Left.Value;
     y := i * Map_RowHeight.Value + Map_Top.Value;
     Image1.Canvas.Brush.Style := bsClear;
     Image1.Canvas.Font.Size := 7;
     if duMap[i, j] > 30 then begin
         Image1.Canvas.Font.Color := clWhite;
         Image1.Canvas.TextOut(x+4, y + Map_RowHeight.Value-13, IntToStr(duMap[i, j]));
     end;
//     if clMap[i, j] > 30 then begin
//         Image1.Canvas.Font.Color := clYellow;
//         Image1.Canvas.TextOut(x+4, y + Map_RowHeight.Value-28, IntToStr(clMap[i, j]));
//     end;
   end;
{$ENDIF}

      end;
  end;

{$IFDEF TEST}
// �ڹ���������������
  if (Image3.Visible) and (cur_Rect.left > 0) then begin
    ww := (cur_Rect.right - cur_Rect.left) div myScale - 4;  // ʵ��ȡ���ߴ磬���ܱ߸��ó� 2 ������
    hh := (cur_Rect.bottom - cur_Rect.top) div myScale - 4;  // ʵ��ȡ���ߴ磬���ܱ߸��ó� 2 ������

    R1 := Rect(0, 0, 32, 32);
    R2 := Rect(0, 0, 32, 32);
    Image3.Canvas.CopyRect(R1, tmpPic.Canvas, R2);
    Image3.Canvas.Brush.Color := clWhite;
    Image3.Canvas.FrameRect(R1);

    R1 := Rect(32, 0, 64, 32);
    R2 := Rect(cur_Rect.left div myScale + 2, cur_Rect.top div myScale + 2, cur_Rect.left div myScale + 2 + ww, cur_Rect.top div myScale + 2 + hh);  // ������Χ
    Image3.Canvas.CopyRect(R1, Image2.Canvas, R2);
    Image3.Canvas.FrameRect(R1);
  end;
{$ENDIF}

  StatusBar1.Panels[5].Text := IntToStr(boxs);
  StatusBar1.Panels[7].Text := IntToStr(goals);
end;

// ���߽�
procedure TRecogForm_.DrawBianJie;
var
  R1, R0: TRect;

begin
  R1 := Rect(Map_Left.Value+1, Map_Top.Value+1, Map_Right.Value+1, Map_Bottom.Value+1);
  R0 := Rect(Map_Left.Value,   Map_Top.Value,   Map_Right.Value,   Map_Bottom.Value  );
  Image1.Canvas.Brush.Color := clBlack;
  Image1.Canvas.FrameRect(R1);
  Image1.Canvas.Brush.Color := clWhite;
  Image1.Canvas.FrameRect(R0);
end;

// ������߽�
procedure TRecogForm_.B_LeftClick(Sender: TObject);
begin
  SetLeft(myClickPoint.X);
  myDraw;
end;

// �����ұ߽�
procedure TRecogForm_.B_RightClick(Sender: TObject);
begin
  SetRight(myClickPoint.X);
  myDraw;
end;

// �����ϱ߽�
procedure TRecogForm_.B_TopClick(Sender: TObject);
begin
  SetTop(myClickPoint.Y);
  myDraw;
end;

// �����±߽�
procedure TRecogForm_.B_BottomClick(Sender: TObject);
begin
  SetBottom(myClickPoint.Y);
  myDraw;
end;

// ��갴��
procedure TRecogForm_.Image1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  myClickPoint.X := X;
  myClickPoint.Y := Y;
  
  if  mySelect = 0 then begin
    mySizeOf := 0;
    mySizeOf_ := 0;
    Image1.Cursor := crCross;
    if (Abs(X - Map_Left.Value) < 4) and (Abs(Y - Map_Top.Value) < 4) then begin
       Image1.Cursor := crSizeNWSE;
       mySizeOf := 8;
    end else if (Abs(X - (Map_Left.Value + Map_ColWidth.Value)) < 4) and (Abs(Y - (Map_Top.Value + Map_RowHeight.Value)) < 4) then begin
       Image1.Cursor := crSizeNWSE;  //  crSizeAll
       mySizeOf := 7;
    end else if (Abs(X - Map_Left.Value) < 4) and (Y - Map_Top.Value > 8) and (Map_Bottom.Value - Y > 8) then begin
       Image1.Cursor := crSizeWE;
       mySizeOf := 1;
    end else if (Abs(X - Map_Right.Value) < 4) and (Y - Map_Top.Value > 8) and (Map_Bottom.Value - Y > 8) then begin
       Image1.Cursor := crSizeWE;
       mySizeOf := 2;
    end else if (Abs(Y - Map_Top.Value) < 4) and (X - Map_Left.Value > 8) and (Map_Right.Value - X > 8) then begin
       Image1.Cursor := crSizeNS;
       mySizeOf := 3;
    end else if (Abs(Y - Map_Bottom.Value) < 4) and (X - Map_Left.Value > 8) and (Map_Right.Value - X > 8) then begin
       Image1.Cursor := crSizeNS;
       mySizeOf := 4;
    end else if (Abs(X - (Map_Left.Value + Map_ColWidth.Value)) < 4) and (Y - Map_Top.Value > 8) and (Map_Bottom.Value - Y > 8) then begin
       Image1.Cursor := crSizeWE;
       mySizeOf := 5;
    end else if (Abs(Y - (Map_Top.Value + Map_RowHeight.Value)) < 4) and (X - Map_Left.Value > 8) and (Map_Right.Value - X > 8) then begin
       Image1.Cursor := crSizeNS;
       mySizeOf := 6;
    end;
  end;
end;

// ���̧��
procedure TRecogForm_.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   xx, yy, c, r: Integer;
   myEndTime: Int64;
begin
   if (not Image1.Visible) or (ssShift in Shift) then Exit;

   if mySelect = 0 then begin
      myEndTime := GetJavaTime(Now);
      if Button = mbright then begin                                            // �Ҽ�����
         B_Right.Click;
         B_Bottom.Click;
      end else if (Button = mbleft) and (Abs(myEndTime - myStartTime) < 300) then begin  // ���˫��
         B_Top.Click;
         B_Left.Click;
      end;
      mySizeOf := 0;
      Image1.Cursor := crCross;
      myStartTime := myEndTime;
      Exit;
   end;

   if (x < Map_Left.Value) or (y < Map_Top.Value) or (x >= Map_Right.Value) or (y >= Map_Bottom.Value) then Exit;

   c := (x - Map_Left.Value) div Map_ColWidth.Value;
   r := (y - Map_Top.Value) div Map_RowHeight.Value;

   xx := c * Map_ColWidth.Value + Map_Left.Value;
   yy := r * Map_RowHeight.Value + Map_Top.Value;
   cur_Rect := Rect(xx, yy, xx + Map_ColWidth.Value, yy + Map_RowHeight.Value);

   // ����
   SetUnDoReDo;

   if Button = mbleft then begin
     // ʶ���༭
     if mySelect in [ 1, 2, 3, 4 ] then begin                                   // ǽ�ڡ����ӡ�������Ŀ��㡢Ŀ���
        if CheckBox1.Checked then begin                                         // �ֶ��༭ģʽ
           case mySelect of
             1: begin
                if myMap[r, c] in [ '@', '+' ] then begin
                  rg_ManPos.X := -1;
                  rg_ManPos.Y := -1;
                end;
                if myMap[r, c] = '#' then myMap[r, c] := '-'
                else myMap[r, c] := '#';
             end;
             2: begin
                if myMap[r, c] in [ '@', '+' ] then begin
                  rg_ManPos.X := -1;
                  rg_ManPos.Y := -1;
                end;
                if myMap[r, c] = '$' then myMap[r, c] := '-'
                else myMap[r, c] := '$';
             end;
             3: begin
                if myMap[r, c] in [ '@', '+' ] then begin
                  rg_ManPos.X := -1;
                  rg_ManPos.Y := -1;
                end;
                if myMap[r, c] = '*' then myMap[r, c] := '-'
                else myMap[r, c] := '*';
             end;
             4: begin
                if myMap[r, c] in [ '@', '+' ] then begin
                  rg_ManPos.X := -1;
                  rg_ManPos.Y := -1;
                end;
                if myMap[r, c] = '.' then myMap[r, c] := '-'
                else myMap[r, c] := '.';
             end;
           end;
        end else begin                                                          // ʶ��ģʽ
           if myMap[r, c] = '-' then findSubimages                              // ���������λ���ϻ������š�����ִ��ʶ��
           else myMap[r, c] := XSB_Char[mySelect];                              // ���������λ�����Ѿ����ˡ�ʶ�𡱣���ֱ���޸Ĵ˸���                    
        end;
     end else if mySelect = 5 then begin                                        // �ֹ�Ա��ִ�б༭
        if myMap[r, c] in [ '@', '+' ] then begin
          if myMap[r, c] = '@' then myMap[r, c] := '+'
          else  myMap[r, c] := '@';
        end else begin
          if (rg_ManPos.X >= 0) and (rg_ManPos.Y >= 0) then begin
            if myMap[rg_ManPos.Y, rg_ManPos.X] = '+' then myMap[rg_ManPos.Y, rg_ManPos.X] := '.'
            else myMap[rg_ManPos.Y, rg_ManPos.X] := '-';
          end;
          rg_ManPos.X := c;
          rg_ManPos.Y := r;
          myMap[r, c] := '@';
        end;
     end else if mySelect = 6 then begin                                        // ����
        if myMap[r, c] in [ '@', '+' ] then begin
          rg_ManPos.X := -1;
          rg_ManPos.Y := -1;
        end;
        myMap[r, c] := '-';
     end;                                                                       // �Ҽ� == ɾ��
   end else begin
     if myMap[r, c] in [ '@', '+' ] then begin
        rg_ManPos.X := -1;
        rg_ManPos.Y := -1;
     end;
     myMap[r, c] := '-';
   end;
   myDraw;
end;

// ����϶� -- ��ѡ���
procedure TRecogForm_.Map_LeftChange(Sender: TObject);
begin
  SetLeft(Map_Left.Value);
  PicCols := (Map_Right.Value-Map_Left.Value) div Map_ColWidth.Value;
  if ((Map_Right.Value-Map_Left.Value) mod Map_ColWidth.Value) < (Map_ColWidth.Value div 2) then begin
     PicCols := PicCols - 1;
  end;
  StatusBar1.Panels[1].Text := IntToStr(PicRows+1);
  StatusBar1.Panels[3].Text := IntToStr(PicCols+1);
  myDraw;
end;

procedure TRecogForm_.Map_RightChange(Sender: TObject);
begin
  SetRight(Map_Right.Value);
  PicCols := (Map_Right.Value-Map_Left.Value) div Map_ColWidth.Value;
  if ((Map_Right.Value-Map_Left.Value) mod Map_ColWidth.Value) < (Map_ColWidth.Value div 2) then begin
     PicCols := PicCols - 1;
  end;
  StatusBar1.Panels[1].Text := IntToStr(PicRows+1);
  StatusBar1.Panels[3].Text := IntToStr(PicCols+1);
  myDraw;
end;

procedure TRecogForm_.Map_TopChange(Sender: TObject);
begin
  SetTop(Map_Top.Value);
  PicRows := (Map_Bottom.Value-Map_Top.Value) div Map_RowHeight.Value;
  if ((Map_Bottom.Value-Map_Top.Value) mod Map_RowHeight.Value) < (Map_RowHeight.Value div 2) then begin
     PicRows := PicRows - 1;
  end;
  StatusBar1.Panels[1].Text := IntToStr(PicRows+1);
  StatusBar1.Panels[3].Text := IntToStr(PicCols+1);
  myDraw;
end;

procedure TRecogForm_.Map_BottomChange(Sender: TObject);
begin
  SetBottom(Map_Bottom.Value);
  PicRows := (Map_Bottom.Value-Map_Top.Value) div Map_RowHeight.Value;
  if ((Map_Bottom.Value-Map_Top.Value) mod Map_RowHeight.Value) < (Map_RowHeight.Value div 2) then begin
     PicRows := PicRows - 1;
  end;
  StatusBar1.Panels[1].Text := IntToStr(PicRows+1);
  StatusBar1.Panels[3].Text := IntToStr(PicCols+1);
  myDraw;
end;

procedure TRecogForm_.SpeedButton1Click(Sender: TObject);
begin
  Map_Right.Value := Image1.Width-1;
  StatusBar1.Panels[1].Text := IntToStr(PicRows+1);
  StatusBar1.Panels[3].Text := IntToStr(PicCols+1);
  myDraw;
end;

procedure TRecogForm_.SpeedButton2Click(Sender: TObject);
begin
  Map_Bottom.Value := Image1.Height-1;
  StatusBar1.Panels[1].Text := IntToStr(PicRows+1);
  StatusBar1.Panels[3].Text := IntToStr(PicCols+1);
  myDraw;
end;

procedure TRecogForm_.SpeedButton3Click(Sender: TObject);
begin
  Map_Left.Value := 0;
  StatusBar1.Panels[1].Text := IntToStr(PicRows+1);
  StatusBar1.Panels[3].Text := IntToStr(PicCols+1);
  myDraw;
end;

procedure TRecogForm_.SpeedButton4Click(Sender: TObject);
begin
  Map_Top.Value := 0;
  StatusBar1.Panels[1].Text := IntToStr(PicRows+1);
  StatusBar1.Panels[3].Text := IntToStr(PicCols+1);
  myDraw;
end;

procedure TRecogForm_.FormCreate(Sender: TObject);
begin

{$IFDEF TEST}
  tmpPic := TBitmap.Create;
  tmpPic.PixelFormat := pf24bit;
  tmpPic.Canvas.CopyMode := cmSrcCopy;
  Panel5.Visible := True;
  try
    tmpPic.Width := 32;
    tmpPic.Height := 32;
  except
  end;
{$ELSE}  
  Panel5.Visible := False;
{$ENDIF}

  Panel1.Color := $DBCDBF;
  Panel3.Color := $DBCDBF;
  pl_Wall.Color := $DBCDBF;
  pl_BoxGoal.Color := $DBCDBF;
  pl_Box.Color := $DBCDBF;
  pl_Goal.Color := $DBCDBF;
  pl_Player.Color := $DBCDBF;
  pl_Floor.Color := $DBCDBF;
  pl_Select.Color := $DBCDBF;

  Caption := '�ؿ���ͼʶ��';

  Label1.Caption := '��߽�:';
  Label2.Caption := '�ұ߽�:';
  Label3.Caption := '�ϱ߽�:';
  Label4.Caption := '�±߽�:';
  Label5.Caption := '�и�:';
  Label8.Caption := '�п�:';

  Panel4.Caption := '�����ο�';
  Panel4.Color := $DBCDBF;

  Label7.Caption := '���ƶ�: 60%';

  CheckBox1.Caption := '�ֶ��༭';
  CheckBox2.Caption := 'XSB�ַ�';
  CheckBox4.Caption := 'ɫ��';
  CheckBox5.Caption := 'ƽ���Ҷ�';

  sb_Return.Hint := '����ʶ�𣬷��ر༭��Ctrl + Q��';
  bt_Skin.Hint := '����Ƥ��';
  
  B_Top.Caption    := '�ϱ߽�(&T) - Top';
  B_Bottom.Caption := '�±߽�(&B) - Bottom';
  B_Left.Caption   := '��߽�(&L) - Left';
  B_Right.Caption  := '�ұ߽�(&R) - Right';

  StatusBar1.Panels[0].Text := '����';
  StatusBar1.Panels[2].Text := '����';
  StatusBar1.Panels[4].Text := '������';
  StatusBar1.Panels[6].Text := 'Ŀ����';

  sb_Open.Hint := '�򿪹ؿ���ͼ��Ctrl + O��';
  sb_Screen.Hint := '��ȡ��Ļͼ��Ctrl + K��';      
  sb_Copy.Hint := '���� XSB �����а塾Ctrl + C��';
  sb_UnDo.Hint := '������Ctrl + Z��';
  sb_ReDo.Hint := '������Shift + Z��';
  sb_Clear.Hint := '�����ʶ������';
  sb_Scale.Hint := '����ͼ��';   

  SpeedButton1.Caption := '��';
  SpeedButton2.Caption := '��';
  SpeedButton3.Hint := '�Խ�ͼ������ߡ�Ϊ�ؿ�����߽硿';
  SpeedButton1.Hint := '�Խ�ͼ�����ұߡ�Ϊ�ؿ����ұ߽硿';
  SpeedButton4.Hint := '�Խ�ͼ�����ϱߡ�Ϊ�ؿ����ϱ߽硿';
  SpeedButton2.Hint := '�Խ�ͼ�����±ߡ�Ϊ�ؿ����±߽硿';
  
  img_Wall.Hint := '���롺ǽ�ڡ���ʶ��ģʽ��';
  img_Box.Hint := '���롺���ӡ���ʶ��ģʽ��';
  img_BoxGoal.Hint := '���롺Ŀ��λ���ӡ���ʶ��ģʽ��';
  img_Goal.Hint := '���롺Ŀ��λ����ʶ��ģʽ��';
  img_Player.Hint := '���롺�ֹ�Ա����ʶ��ģʽ��';
  img_Floor.Hint := '�������е�ʶ��';
  img_Select.Hint := '���롰�߿������ģʽ';

  Screen.Cursors[cursorWall_]     := LoadCursor(HInstance, 'CURSOR_WALL_');
  Screen.Cursors[cursorBox_]      := LoadCursor(HInstance, 'CURSOR_BOX_');
  Screen.Cursors[cursorBoxGoal_]  := LoadCursor(HInstance, 'CURSOR_BOXGOAL_');
  Screen.Cursors[cursorGoal_]     := LoadCursor(HInstance, 'CURSOR_GOAL_');
  Screen.Cursors[cursorMan_]      := LoadCursor(HInstance, 'CURSOR_PLAYER_');
  Screen.Cursors[cursorErase_]    := LoadCursor(HInstance, 'CURSOR_ERASE_');
  Screen.Cursors[cursorSheel_]    := LoadCursor(HInstance, 'CURSOR_SHEEL_');     

  rUnDoList := TStringList.Create;
  rReDoList := TStringList.Create;

  Map_RowHeight.Value := 50;
  Map_ColWidth.Value := 50;
  
  rg_ManPos.X := -1;
  rg_ManPos.Y := -1;
  Image1.Visible := False;
  Tag := 0;

  mySizeOf := 0;
  myHintChar := '-';

  myStartTime := GetJavaTime(Now);

  KeyPreview := true;
end;

procedure TRecogForm_.Map_RowHeightChange(Sender: TObject);
begin
   if Map_RowHeight.Value > 0 then begin
     PicRows := (Map_Bottom.Value-Map_Top.Value) div Map_RowHeight.Value;
     if ((Map_Bottom.Value-Map_Top.Value) mod Map_RowHeight.Value) < (Map_RowHeight.Value div 2) then begin
        PicRows := PicRows - 1;
     end;
     StatusBar1.Panels[1].Text := IntToStr(PicRows+1);
     StatusBar1.Panels[3].Text := IntToStr(PicCols+1);
     myDraw;
   end;
end;

procedure TRecogForm_.Map_ColWidthChange(Sender: TObject);
begin
   if Map_ColWidth.Value > 0 then begin
     PicCols := (Map_Right.Value-Map_Left.Value) div Map_ColWidth.Value;
     if ((Map_Right.Value-Map_Left.Value) mod Map_ColWidth.Value) < (Map_ColWidth.Value div 2) then begin
        PicCols := PicCols - 1;
     end;
     StatusBar1.Panels[1].Text := IntToStr(PicRows+1);
     StatusBar1.Panels[3].Text := IntToStr(PicCols+1);
     myDraw;
   end;
end;

function GetXSB(Rows, Cols: Integer): string;
var
  i, j: Integer;
begin
  Result := '';
  for i := 0 to Rows do begin
      for j := 0 to Cols do begin
          Result := Result + myMap[i, j];
      end;
      Result := Result + #10;
  end;
end;

procedure TRecogForm_.sb_CopyClick(Sender: TObject);
begin
  if not Image1.Visible then Exit;
  Clipboard.SetTextBuf(PChar(GetXSB(PicRows, PicCols)));
end;

// ��Ԫ��ѡ��򡢸ı������ʽ
procedure TRecogForm_.SetSelect;
var
  i: Integer;

begin
  for i := 0 to 6 do begin
      case i of
      0: begin
           if mySelect = i then begin
              pl_Select.Color := clRed;
              Image1.Cursor := crCross;
              StatusBar1.Panels[8].Text := '���϶������⣬�������á�L��T��R��B�������塰�������¡��߿򣻡����˫�����ɿ���ָ�������Ͻǡ������Ҽ��������ɿ���ָ�������½ǡ�';
           end
           else pl_Select.Color := clInactiveCaption;
         end;
      1: begin
           if mySelect = i then begin
              pl_Wall.Color := clRed;
              Image1.Cursor := cursorWall_;
              StatusBar1.Panels[8].Text := 'ʶ�� - ǽ��';
           end
           else pl_Wall.Color := clInactiveCaption;
         end;
      2: begin
           if mySelect = i then begin
              pl_Box.Color := clRed;
              Image1.Cursor := cursorBox_;
              StatusBar1.Panels[8].Text := 'ʶ�� - ����';
           end
           else pl_Box.Color := clInactiveCaption;
         end;
      3: begin
           if mySelect = i then begin
              pl_BoxGoal.Color := clRed;
              Image1.Cursor := cursorBoxGoal_;
              StatusBar1.Panels[8].Text := 'ʶ�� - ������Ŀ��λ';
           end
           else pl_BoxGoal.Color := clInactiveCaption;
         end;
      4: begin
           if mySelect = i then begin
              pl_Goal.Color := clRed;
              Image1.Cursor := cursorGoal_;
              StatusBar1.Panels[8].Text := 'ʶ�� - Ŀ���';
           end
           else pl_Goal.Color := clInactiveCaption;
         end;
      5: begin
           if mySelect = i then begin
              pl_Player.Color := clRed;
              Image1.Cursor := cursorMan_;
              StatusBar1.Panels[8].Text := 'ʶ�� - �ֹ�Ա';
           end
           else pl_Player.Color := clInactiveCaption;
         end;
      6: begin
           if mySelect = i then begin
              pl_Floor.Color := clRed;
              Image1.Cursor := cursorErase_;
              StatusBar1.Panels[8].Text := '����ʶ��';
           end
           else pl_Floor.Color := clInactiveCaption;
         end;
      end;
  end;
end;

// ѡ��ǽ��
procedure TRecogForm_.img_WallClick(Sender: TObject);
begin
  mySelect := 1;
  SetSelect;
end;

// ѡ������
procedure TRecogForm_.img_BoxClick(Sender: TObject);
begin
  mySelect := 2;
  SetSelect;
end;

// ѡ��������Ŀ���
procedure TRecogForm_.img_BoxGoalClick(Sender: TObject);
begin
  mySelect := 3;
  SetSelect;
end;

// ѡ��Ŀ���
procedure TRecogForm_.img_GoalClick(Sender: TObject);
begin
  mySelect := 4;
  SetSelect;
end;

// ѡ����
procedure TRecogForm_.img_PlayerClick(Sender: TObject);
begin
  mySelect := 5;
  SetSelect;
end;

// ѡ��ذ�
procedure TRecogForm_.img_FloorClick(Sender: TObject);
begin
  mySelect := 6;
  SetSelect;
end;

procedure TRecogForm_.img_SelectClick(Sender: TObject);
begin
  mySelect := 0;
  SetSelect;
end;

procedure TRecogForm_.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  k: Integer;
begin
  if Image1.Visible then begin
     if isMouseSheel or (not isSheelEnable) then k := 1
     else k := -1;

     if isShiftDown or isSheelEnable then begin
       if mySizeOf_ = 1 then begin
          if Map_Left.Value > 0 then Map_Left.Value := Map_Left.Value+k;
       end else if mySizeOf_ = 2 then begin
          if Map_Right.Value > 0 then Map_Right.Value := Map_Right.Value+k;
       end else if mySizeOf_ = 3 then begin
          if Map_Top.Value > 0 then Map_Top.Value := Map_Top.Value+k;
       end else if mySizeOf_ = 4 then begin
          if Map_Bottom.Value > 0 then Map_Bottom.Value := Map_Bottom.Value+k;
       end else if mySizeOf_ = 6 then begin
          if Map_RowHeight.Value > 10 then Map_RowHeight.Value := Map_RowHeight.Value+k;
       end else if mySizeOf_ = 5 then begin
          if Map_ColWidth.Value > 10 then Map_ColWidth.Value := Map_ColWidth.Value+k;
       end else if mySizeOf_ = 7 then begin
          if Map_ColWidth.Value > 10 then Map_ColWidth.Value := Map_ColWidth.Value+k;
          if Map_RowHeight.Value > 10 then Map_RowHeight.Value := Map_RowHeight.Value+k;
       end else if mySizeOf_ = 8 then begin
          if Map_Left.Value > 0 then Map_Left.Value := Map_Left.Value+k;
          if Map_Top.Value > 0 then Map_Top.Value := Map_Top.Value+k;
       end;
     end else begin
       if Image1.Tag = 1 then begin
          if Map_Left.Value > 0 then Map_Left.Value := Map_Left.Value+k;
       end else if Image1.Tag = 3 then begin
          if Map_Right.Value > 0 then Map_Right.Value := Map_Right.Value+k;
       end else if Image1.Tag = 2 then begin
          if Map_Top.Value > 0 then Map_Top.Value := Map_Top.Value+k;
       end else if Image1.Tag = 4 then begin
          if Map_Bottom.Value > 0 then Map_Bottom.Value := Map_Bottom.Value+k;
       end else if Image1.Tag = 6 then begin
          if Map_RowHeight.Value > 10 then Map_RowHeight.Value := Map_RowHeight.Value+k;
       end else if Image1.Tag = 5 then begin
          if Map_ColWidth.Value > 10 then Map_ColWidth.Value := Map_ColWidth.Value+k;
       end;
     end;
     Handled := True;
  end;
end;

procedure TRecogForm_.FormMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
var
  k: Integer;
begin
  if Image1.Visible then begin
     if isMouseSheel or (not isSheelEnable) then k := -1
     else k := 1;

     if isShiftDown or isSheelEnable then begin
         if mySizeOf_ = 1 then begin
            if Map_Left.Value < Map_Left.MaxValue then Map_Left.Value := Map_Left.Value+k;
         end else if mySizeOf_ = 2 then begin
            if Map_Right.Value < Map_Right.MaxValue then Map_Right.Value := Map_Right.Value+k;
         end else if mySizeOf_ = 3 then begin
            if Map_Top.Value < Map_Top.MaxValue then Map_Top.Value := Map_Top.Value+k;
         end else if mySizeOf_ = 4 then begin
            if Map_Bottom.Value < Map_Bottom.MaxValue then Map_Bottom.Value := Map_Bottom.Value+k;
         end else if mySizeOf_ = 6 then begin
            if Map_RowHeight.Value < Map_Bottom.Value-Map_Top.Value then Map_RowHeight.Value := Map_RowHeight.Value+k;
         end else if mySizeOf_ = 5 then begin
            if Map_ColWidth.Value < Map_Right.Value-Map_Left.Value then Map_ColWidth.Value := Map_ColWidth.Value+k;
         end else if mySizeOf_ = 7 then begin
            if Map_ColWidth.Value < Map_Right.Value-Map_Left.Value then Map_ColWidth.Value := Map_ColWidth.Value+k;
            if Map_RowHeight.Value < Map_Bottom.Value-Map_Top.Value then Map_RowHeight.Value := Map_RowHeight.Value+k;
         end else if mySizeOf_ = 8 then begin
            if Map_Left.Value < Map_Left.MaxValue then Map_Left.Value := Map_Left.Value+k;
            if Map_Top.Value < Map_Top.MaxValue then Map_Top.Value := Map_Top.Value+k;
         end;
     end else begin
         if Image1.Tag = 1 then begin
            if Map_Left.Value < Map_Left.MaxValue then Map_Left.Value := Map_Left.Value+k;
         end else if Image1.Tag = 3 then begin
            if Map_Right.Value < Map_Right.MaxValue then Map_Right.Value := Map_Right.Value+k;
         end else if Image1.Tag = 2 then begin
            if Map_Top.Value < Map_Top.MaxValue then Map_Top.Value := Map_Top.Value+k;
         end else if Image1.Tag = 4 then begin
            if Map_Bottom.Value < Map_Bottom.MaxValue then Map_Bottom.Value := Map_Bottom.Value+k;
         end else if Image1.Tag = 6 then begin
            if Map_RowHeight.Value < Map_Bottom.Value-Map_Top.Value then Map_RowHeight.Value := Map_RowHeight.Value+k;
         end else if Image1.Tag = 5 then begin
            if Map_ColWidth.Value < Map_Right.Value-Map_Left.Value then Map_ColWidth.Value := Map_ColWidth.Value+k;
         end;
     end;
     Handled := True;
  end;
end;

// UnDo
procedure TRecogForm_.sb_UnDoClick(Sender: TObject);
var
  size: Integer;
  s: string;
begin
  size := rUnDoList.Count;
  if size > 0 then begin
     SetUnDoReDo(True);
     s := rUnDoList[size-1];
     SetXSB(s);
     myDraw;
     rUnDoList.Delete(size-1);
  end;
end;

// ReDo
procedure TRecogForm_.sb_ReDoClick(Sender: TObject);
var
  size: Integer;
  s: string;
begin
  size := rReDoList.Count;
  if size > 0 then begin
     SetUnDoReDo;
     s := rReDoList[size-1];
     SetXSB(s);
     myDraw;
     rReDoList.Delete(size-1);
  end;
end;

// ��յ�ͼ
procedure TRecogForm_.sb_ClearClick(Sender: TObject);
var
  i, j: Integer;
begin
  if not Image1.Visible then Exit;

  if MessageBox(Handle, '���������ȫ��ʶ��ȷ����', '����', MB_ICONINFORMATION + MB_OKCANCEL) = idOK then
  begin
     SetUnDoReDo;
     for i := 0 to 99 do begin
       for j := 0 to 99 do begin
           myMap[i, j] := '-';

{$IFDEF TEST}
   duMap[i, j] := 0;
   clMap[i, j] := 0;
{$ENDIF}

       end;
     end;
     myDraw;
  end;
end;

procedure TRecogForm_.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
//  Caption := IntToStr(ord(Key));
  case Key of
    16:                // Shift
     if (ssShift in Shift) and (Image1.Visible) then begin
        isShiftDown := true;
        myHintChar := myMap[(myMovePoint.Y - Map_Top.Value) div Map_RowHeight.Value, (myMovePoint.X - Map_Left.Value) div Map_ColWidth.Value];
        myDraw;
     end else myHintChar := '-';
    17:                // Ctrl
     if (ssCtrl in Shift) and (Image1.Visible) then begin 
        myHintPos.X := (myMovePoint.X - Map_Left.Value) div Map_ColWidth.Value;
        myHintPos.Y := (myMovePoint.Y - Map_Top.Value) div Map_RowHeight.Value;
        myDraw;
     end else myHintChar := '-';
    81:                // Ctrl + Q�� �˳�
      if ssCtrl in Shift then
      begin
        sb_Return.Click;
      end;
    90:                 // Ctrl(Shift) + Z�� UnDo��ReDo
      if ssShift in Shift then begin
        sb_ReDo.Click;
      end else if ssCtrl in Shift then begin
        sb_UnDo.Click;
      end;
    75:                 // ��ȡ��Ļͼ��
      if ssCtrl in Shift then begin
        sb_Screen.Click;
      end;
    79:                 // Ctrl + O�� ��ͼƬ�ĵ�
      if ssCtrl in Shift then begin
        sb_Open.Click;                       
      end;
    67:                // Ctrl + C�� �� XSB �����а帴
      if ssCtrl in Shift then begin
         sb_Copy.Click;
      end;
    76:                                                    // L
      begin
        SetLeft(myMovePoint.X);
        PicCols := (Map_Right.Value-Map_Left.Value) div Map_ColWidth.Value;
        if ((Map_Right.Value-Map_Left.Value) mod Map_ColWidth.Value) < (Map_ColWidth.Value div 2) then begin
           PicCols := PicCols - 1;
        end;
        Map_Left.SetFocus;
        myDraw;
      end;
    84:                                                    // T
      begin
        SetTop(myMovePoint.Y);
        PicRows := (Map_Bottom.Value-Map_Top.Value) div Map_RowHeight.Value;
        if ((Map_Bottom.Value-Map_Top.Value) mod Map_RowHeight.Value) < (Map_RowHeight.Value div 2) then begin
           PicRows := PicRows - 1;
        end;
        Map_Top.SetFocus;
        myDraw;
      end;
   82:                                                     // R
      begin
        SetRight(myMovePoint.X);
        PicCols := (Map_Right.Value-Map_Left.Value) div Map_ColWidth.Value;
        if ((Map_Right.Value-Map_Left.Value) mod Map_ColWidth.Value) < (Map_ColWidth.Value div 2) then begin
           PicCols := PicCols - 1;
        end;
        Map_Right.SetFocus;
        myDraw;
      end;
    66:                                                    // B
      begin
        SetBottom(myMovePoint.Y);
        PicRows := (Map_Bottom.Value-Map_Top.Value) div Map_RowHeight.Value;
        if ((Map_Bottom.Value-Map_Top.Value) mod Map_RowHeight.Value) < (Map_RowHeight.Value div 2) then begin
           PicRows := PicRows - 1;
        end;
        Map_Bottom.SetFocus;
        myDraw;
      end;
    VK_F2:                         // F2������Ƥ��
      bt_Skin.Click;
  end;
end;

procedure TRecogForm_.Image1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  dx, dy: Integer;
begin
  Image1.Tag := 0;
  ScrollBox1.SetFocus;
  dx := X - (Map_Left.Value + Map_ColWidth.Value);
  dy := Y - (Map_Top.Value + Map_RowHeight.Value);
  myMovePoint.X := X;
  myMovePoint.Y := Y;

  if isShiftDown then mySizeOf := 0
  else mySizeOf_ := 0;

  isSheelEnable := False;

  if mySelect = 0 then begin
    StatusBar1.Panels[8].Text := '���ϻ���ֶ������⣬�������á�L��T��R��B�������塰�������¡��߿��ر�ģ������˫�����ɿ���ָ�������Ͻǡ������Ҽ��������ɿ���ָ�������½ǡ�';
    case mySizeOf of
      0: begin
        Image1.Cursor := crCross;
        if (Abs(X - Map_Left.Value) < 4) and (Abs(Y - Map_Top.Value) < 4) then begin
           Image1.Cursor := crSizeNWSE;
           mySizeOf_ := 8;
           isSheelEnable := True;
           StatusBar1.Panels[8].Text := '���϶� / �����֡����������Ͻǡ�';     //  Shift +
        end else if (Abs(X - (Map_Left.Value + Map_ColWidth.Value)) < 4) and (Abs(Y - (Map_Top.Value + Map_RowHeight.Value)) < 4) then begin
           Image1.Cursor := crSizeNWSE;
           mySizeOf_ := 7;
           isSheelEnable := True;
           StatusBar1.Panels[8].Text := '���϶� / �����֡�ͬʱ�������и��п�';   //   Shift +
        end else if (X > Map_Left.Value + 4) and (X < Map_Left.Value + Map_ColWidth.Value - 4) and (Y > Map_Top.Value + 4) and (Y < Map_Top.Value + Map_RowHeight.Value - 4) then begin
           Image1.Cursor := cursorSheel_;
           mySizeOf_ := 7;
           isSheelEnable := True;
           StatusBar1.Panels[8].Text := '�������֡�ͬʱ�������и��п�';     //    Shift +
        end else if (Abs(X - Map_Left.Value) < 4) and (Y - Map_Top.Value > 8) and (Map_Bottom.Value - Y > 8) then begin
           Image1.Cursor := crSizeWE;
           mySizeOf_ := 1;
           isSheelEnable := True;
           StatusBar1.Panels[8].Text := '���϶� / �����֡���������߽硿';   //   Shift +
        end else if (Abs(X - Map_Right.Value) < 4) and (Y - Map_Top.Value > 8) and (Map_Bottom.Value - Y > 8) then begin
           Image1.Cursor := crSizeWE;
           mySizeOf_ := 2;
           isSheelEnable := True;
           StatusBar1.Panels[8].Text := '���϶� / �����֡��������ұ߽硿';  //   Shift +
        end else if (Abs(Y - Map_Top.Value) < 4) and (X - Map_Left.Value > 8) and (Map_Right.Value - X > 8) then begin
           Image1.Cursor := crSizeNS;
           mySizeOf_ := 3;
           isSheelEnable := True;
           StatusBar1.Panels[8].Text := '���϶� / �����֡��������ϱ߽硿';   //  Shift +
        end else if (Abs(Y - Map_Bottom.Value) < 4) and (X - Map_Left.Value > 8) and (Map_Right.Value - X > 8) then begin
           Image1.Cursor := crSizeNS;
           mySizeOf_ := 4;
           isSheelEnable := True;
           StatusBar1.Panels[8].Text := '���϶� / �����֡��������±߽硿';     //       Shift +
        end else if (Abs(X - (Map_Left.Value + Map_ColWidth.Value)) < 4) and (Y - Map_Top.Value > 8) and (Map_Bottom.Value - Y > 8) then begin
           Image1.Cursor := crSizeWE;
           mySizeOf_ := 5;
           isSheelEnable := True;
           StatusBar1.Panels[8].Text := '���϶� / �����֡��������п�';         //        Shift +
        end else if (Abs(Y - (Map_Top.Value + Map_RowHeight.Value)) < 4) and (X - Map_Left.Value > 8) and (Map_Right.Value - X > 8) then begin
           Image1.Cursor := crSizeNS;
           mySizeOf_ := 6;
           isSheelEnable := True;
           StatusBar1.Panels[8].Text := '���϶� / �����֡��������иߡ�';     //    Shift + 
        end;
      end;
      1: begin
        SetLeft(X);
        PicCols := (Map_Right.Value-Map_Left.Value) div Map_ColWidth.Value;
        if ((Map_Right.Value-Map_Left.Value) mod Map_ColWidth.Value) < (Map_ColWidth.Value div 2) then begin
           PicCols := PicCols - 1;
        end;
        myDraw;
        StatusBar1.Panels[8].Text := '�϶���������߽硿';
      end;
      2: begin
        SetRight(X);
        PicCols := (Map_Right.Value-Map_Left.Value) div Map_ColWidth.Value;
        if ((Map_Right.Value-Map_Left.Value) mod Map_ColWidth.Value) < (Map_ColWidth.Value div 2) then begin
           PicCols := PicCols - 1;
        end;
        myDraw;
        StatusBar1.Panels[8].Text := '�϶��������ұ߽硿';
      end;
      3: begin
        SetTop(Y);
        PicRows := (Map_Bottom.Value-Map_Top.Value) div Map_RowHeight.Value;
        if ((Map_Bottom.Value-Map_Top.Value) mod Map_RowHeight.Value) < (Map_RowHeight.Value div 2) then begin
           PicRows := PicRows - 1;
        end;
        myDraw;
        StatusBar1.Panels[8].Text := '�϶��������ϱ߽硿';
      end;
      4: begin
        SetBottom(Y);
        PicRows := (Map_Bottom.Value-Map_Top.Value) div Map_RowHeight.Value;
        if ((Map_Bottom.Value-Map_Top.Value) mod Map_RowHeight.Value) < (Map_RowHeight.Value div 2) then begin
           PicRows := PicRows - 1;
        end;
        myDraw;
        StatusBar1.Panels[8].Text := '�϶��������±߽硿';
      end;
      5: begin
        if (X - Map_Left.Value > 9) and (X < Map_Right.Value) then
            Map_ColWidth.Value := Map_ColWidth.Value+dx;
        PicCols := (Map_Right.Value-Map_Left.Value) div Map_ColWidth.Value;
        if ((Map_Right.Value-Map_Left.Value) mod Map_ColWidth.Value) < (Map_ColWidth.Value div 2) then begin
           PicCols := PicCols - 1;
        end;
        myDraw;
        StatusBar1.Panels[8].Text := '�϶��������п�';
      end;
      6: begin
        if (Y - Map_Top.Value > 9) and (Y < Map_Bottom.Value) then
            Map_RowHeight.Value := Map_RowHeight.Value + dy;
        PicRows := (Map_Bottom.Value-Map_Top.Value) div Map_RowHeight.Value;
        if ((Map_Bottom.Value-Map_Top.Value) mod Map_RowHeight.Value) < (Map_RowHeight.Value div 2) then begin
           PicRows := PicRows - 1;
        end;
        myDraw;
        StatusBar1.Panels[8].Text := '�϶��������иߡ�';
      end;
      7: begin
        if (X - Map_Left.Value > 9) and (X < Map_Right.Value) and (Y - Map_Top.Value > 9) and (Y < Map_Bottom.Value) then begin
            Map_ColWidth.Value := Map_ColWidth.Value+dx;
            Map_RowHeight.Value := Map_RowHeight.Value + dy;
        end;
        PicCols := (Map_Right.Value-Map_Left.Value) div Map_ColWidth.Value;
        PicRows := (Map_Bottom.Value-Map_Top.Value) div Map_RowHeight.Value;
        if ((Map_Right.Value-Map_Left.Value) mod Map_ColWidth.Value) < (Map_ColWidth.Value div 2) then begin
           PicCols := PicCols - 1;
        end;
        if ((Map_Bottom.Value-Map_Top.Value) mod Map_RowHeight.Value) < (Map_RowHeight.Value div 2) then begin
           PicRows := PicRows - 1;
        end;
        myDraw;
        StatusBar1.Panels[8].Text := '�϶�ͬʱ�������и��п�';
      end;
      8: begin
        if (X > 0) and (X < Map_Right.Value) and (Y > 0) and (Y < Map_Bottom.Value) then begin
            Map_Top.Value := Y;
            Map_Left.Value := X;
        end;
        PicCols := (Map_Right.Value-Map_Left.Value) div Map_ColWidth.Value;
        if ((Map_Right.Value-Map_Left.Value) mod Map_ColWidth.Value) < (Map_ColWidth.Value div 2) then begin
           PicCols := PicCols - 1;
        end;
        PicRows := (Map_Bottom.Value-Map_Top.Value) div Map_RowHeight.Value;
        if ((Map_Bottom.Value-Map_Top.Value) mod Map_RowHeight.Value) < (Map_RowHeight.Value div 2) then begin
           PicRows := PicRows - 1;
        end;
        myDraw;
        StatusBar1.Panels[8].Text := '�϶����������Ͻǡ�';
      end;
    end;
  end;
  scrollBox1.SetFocus;
end;

procedure TRecogForm_.sb_ReturnClick(Sender: TObject);
begin
  Close;
end;

// �Ƿ�ʹ��XSB�ַ�
procedure TRecogForm_.CheckBox2Click(Sender: TObject);
begin
  myDraw;
end;

procedure TRecogForm_.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  bt: Integer;
begin
  CanClose := False;
  if Image1.Visible then begin
    bt := MessageBox(Handle, 'Ӧ���µ�ʶ��Ḳ�����еı༭���Ƿ�Ӧ�ã�', '����', MB_ICONWARNING + MB_YESNOCANCEL);
    if bt = idYES then begin
       Tag := 1;
       CanClose := True;
    end else if bt = idNO then begin
       if (old_Left > 0) or (old_Top > 0) or (old_Right > 0) or (old_Bottom > 0) then begin
         Map_Left.Value       := old_Left;
         Map_Top.Value        := old_Top;
         Map_Right.Value      := old_Right;
         Map_Bottom.Value     := old_Bottom;
       end else begin
         if (Image1.Width < 200) or (Image1.Height < 200) then begin
           Map_Left.Value   := 0;
           Map_Top.Value    := 0;
           Map_Right.Value  := Image1.Width-1;
           Map_Bottom.Value := Image1.Height-1;
         end else begin
           Map_Left.Value   := 50;
           Map_Top.Value    := 50;
           Map_Right.Value  := Image1.Width-50;
           Map_Bottom.Value := Image1.Height-50;
         end;
       end;
       Map_RowHeight.Value  := old_RowHeight;
       Map_ColWidth.Value   := old_ColWidth;
       Tag                  := old_Tag;
       CanClose := True;
    end;
  end else CanClose := True;
end;

procedure TRecogForm_.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  isShiftDown := False;
  myHintChar := '-';
  myHintPos.X := -1;
  myHintPos.Y := -1;

  myDraw;
end;

procedure TRecogForm_.ScrollBox1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := '��Ctrl + �ƶ���꡿��������ʱ����ĳ���ӵ�ʶ�𣬡�Shift + �ƶ���꡿��������ʱ����ĳ���ӵ�ͬ��ʶ��';
end;

procedure TRecogForm_.Panel1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := '��Ctrl + �ƶ���꡿��������ʱ����ĳ���ӵ�ʶ�𣬡�Shift + �ƶ���꡿��������ʱ����ĳ���ӵ�ͬ��ʶ��';
end;

procedure TRecogForm_.img_WallMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := img_Wall.Hint + '���������ʶ���༭�����Ҽ���Ϊ����';
end;

procedure TRecogForm_.img_BoxMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := img_Box.Hint + '���������ʶ���༭�����Ҽ���Ϊ����';
end;

procedure TRecogForm_.img_BoxGoalMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := img_BoxGoal.Hint + '���������ʶ���༭�����Ҽ���Ϊ����';
end;

procedure TRecogForm_.img_GoalMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := img_Goal.Hint + '���������ʶ���༭�����Ҽ���Ϊ����';
end;

procedure TRecogForm_.img_PlayerMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := img_Player.Hint + '���������ʶ���༭�����Ҽ���Ϊ����';
end;

procedure TRecogForm_.img_FloorMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := img_Floor.Hint + '�������Ҽ�������';
end;

procedure TRecogForm_.img_SelectMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := '���롰�����߿�ģʽ�������˫�����ɿ���ָ�������Ͻǡ������Ҽ��������ɿ���ָ�������½ǡ�';
end;

procedure TRecogForm_.CheckBox2MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := 'ʹ�� XSB �ַ���ʾʶ�������Ԫ��';
end;

procedure TRecogForm_.CheckBox1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := '���롰�ֶ��༭��ģʽ';
end;

procedure TRecogForm_.sb_OpenMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := sb_Open.Hint;
end;

procedure TRecogForm_.sb_ScreenMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := sb_Screen.Hint;
end;

procedure TRecogForm_.sb_CopyMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := sb_Copy.Hint;
end;

procedure TRecogForm_.sb_ClearMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := sb_Clear.Hint;
end;

procedure TRecogForm_.sb_UnDoMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := sb_UnDo.Hint;
end;

procedure TRecogForm_.sb_ReturnMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := sb_Return.Hint;
end;

procedure TRecogForm_.Map_LeftMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Tag := 1;
  isShiftDown := False;
  Map_Left.SetFocus;
  StatusBar1.Panels[8].Text := '�����΢������߽硿';
end;

procedure TRecogForm_.SpeedButton3MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := SpeedButton3.Hint;
end;

procedure TRecogForm_.Map_RightMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Tag := 3;
  isShiftDown := False;
  Map_Right.SetFocus;
  StatusBar1.Panels[8].Text := '�����΢�����ұ߽硿';
end;

procedure TRecogForm_.SpeedButton1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := SpeedButton1.Hint;
end;

procedure TRecogForm_.Map_TopMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  Image1.Tag := 2;
  isShiftDown := False;
  Map_Top.SetFocus;
  StatusBar1.Panels[8].Text := '�����΢�����ϱ߽硿';
end;

procedure TRecogForm_.SpeedButton4MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := SpeedButton4.Hint;
end;

procedure TRecogForm_.Map_BottomMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Tag := 4;
  isShiftDown := False;
  Map_Bottom.SetFocus;
  StatusBar1.Panels[8].Text := '�����΢�����±߽硿';
end;

procedure TRecogForm_.SpeedButton2MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := SpeedButton2.Hint;
end;

procedure TRecogForm_.Map_RowHeightMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Tag := 6;
  isShiftDown := False;
  Map_RowHeight.SetFocus;
  StatusBar1.Panels[8].Text := '�����΢�����иߡ�';
end;

procedure TRecogForm_.Map_ColWidthMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Tag := 5;
  isShiftDown := False;
  Map_ColWidth.SetFocus;
  StatusBar1.Panels[8].Text := '�����΢�����п�';
end;

procedure TRecogForm_.sb_ScaleMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := sb_Scale.Hint;
end;

procedure TRecogForm_.sb_ScaleClick(Sender: TObject);
begin
  if not Image1.Visible then Exit;

  if myScale = 1 then myScale := 2
  else if myScale = 2 then myScale := 4
  else myScale := 1;
  Image1.Width := Image2.Width * myScale;
  Image1.Height := Image2.Height * myScale;

  Map_Left.MinValue := 0;
  Map_Left.MaxValue := Image1.Width-1;
  Map_Top.MinValue := 0;
  Map_Top.MaxValue := Image1.Height-1;
  Map_Right.MinValue := 0;
  Map_Right.MaxValue := Image1.Width-1;
  Map_Bottom.MinValue := 0;
  Map_Bottom.MaxValue := Image1.Height-1;

  if myScale > 1 then begin
    Map_Right.Value     := Map_Right.Value  * 2;
    Map_Bottom.Value    := Map_Bottom.Value * 2;
    Map_Left.Value      := Map_Left.Value   * 2;
    Map_Top.Value       := Map_Top.Value    * 2;
    Map_RowHeight.Value := Map_RowHeight.Value * 2;
    Map_ColWidth.Value  := Map_ColWidth.Value * 2;
  end else begin
    Map_Left.Value      := Map_Left.Value   div 4;
    Map_Top.Value       := Map_Top.Value    div 4;
    Map_Right.Value     := Map_Right.Value  div 4;
    Map_Bottom.Value    := Map_Bottom.Value div 4;
    Map_RowHeight.Value := Map_RowHeight.Value div 4;
    Map_ColWidth.Value  := Map_ColWidth.Value div 4;
  end;

  myDraw;
end;

procedure TRecogForm_.Panel3MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := '��Ctrl + �ƶ���꡿��������ʱ����ĳ���ӵ�ʶ�𣬡�Shift + �ƶ���꡿��������ʱ����ĳ���ӵ�ͬ��ʶ��';
end;

procedure TRecogForm_.FormDestroy(Sender: TObject);
begin
  MyStringListFree(rUnDoList);
  MyStringListFree(rReDoList);

{$IFDEF TEST}
  LoadSkinForm.MyBMPFree(tmpPic);
{$ENDIF}
end;

procedure TRecogForm_.TrackBar2Change(Sender: TObject);
begin
  Label7.Caption := '���ƶ�: ' + IntToStr(TrackBar2.Position) + '%';
  StatusBar1.Panels[8].Text := '���ƶȣ���ָͼ�������ͷ�������Ƴ̶ȣ�';
end;

procedure TRecogForm_.Label7MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := '���ƶȣ���ָͼ�������ͷ�������Ƴ̶ȣ�';
end;

procedure TRecogForm_.Label9MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := '�Ҷ��ݲָͼ���ƽ���ҶȶԱ�ʱ�������Χ��';
end;

procedure TRecogForm_.CheckBox3MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := '�Ƿ�ȶ����ƶȣ�';
end;

procedure TRecogForm_.CheckBox4MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := 'ɫ���Ƿ����ȶԣ�';
end;

procedure TRecogForm_.CheckBox5MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := '�Ҷ��Ƿ����ȶԣ�';
end;

// Set UnDoReDo
procedure TRecogForm_.SetUnDoReDo(isReDo: Boolean = false);
var
  i, j: Integer;
  str: string;
begin
  str := '';

  for i := 0 to PicRows do begin
      for j := 0 to PicCols do begin
          str := str + myMap[i, j];
      end;
      if i < PicRows then str := str + #10;
  end;

  if isReDo then rReDoList.Add(str)
  else rUnDoList.Add(str);
end;

// Set UnDo��ReDo
procedure TRecogForm_.SetXSB(str: string);
var
  i, j, nRows, nCols: Integer;
  MyXSB: TStringList;
begin
  for i := 0 to 99 do begin
      for j := 0 to 99 do begin
          myMap[i, j] := '-';

{$IFDEF TEST}
   duMap[i, j] := 0;
   clMap[i, j] := 0;
{$ENDIF}

      end;
  end;

  if str = '' then Exit;
  
  MyXSB := TStringList.Create;
  try
      MyXSB.Delimiter := #10;
      MyXSB.DelimitedText := str;
      nRows := MyXSB.Count;
      nCols := Length(MyXSB[0]);
      for i := 0 to nRows-1 do begin
          for j := 1 to nCols do begin
              myMap[i, j-1] := MyXSB[i][j];
              if myMap[i, j-1] in [ '@', '+' ] then begin
                 rg_ManPos.X := j-1;
                 rg_ManPos.Y := i;
              end;
          end;
      end;
  finally
      MyStringListFree(MyXSB);
  end;
end;

procedure TRecogForm_.sb_ReDoMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := sb_ReDo.Hint;
end;

procedure TRecogForm_.Image3MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := '�����ο�';
end;

procedure TRecogForm_.Image3Click(Sender: TObject);
begin
  Image3.Visible := False;
  myDraw;
end;

procedure TRecogForm_.Panel4Click(Sender: TObject);
begin
  Image3.Visible := True;
  myDraw;
end;

procedure TRecogForm_.bt_SkinClick(Sender: TObject);
begin
  Recog_.LoadSkin_;
  myDraw;
end;

procedure TRecogForm_.bt_SkinMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  Image1.Tag := 0;
  StatusBar1.Panels[8].Text := bt_Skin.Hint;
end;

procedure TRecogForm_.ScrollBox1MouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if isShiftDown or isSheelEnable then Exit;

  if ssCtrl in Shift then TScrollBox(Sender).HorzScrollBar.Position := TScrollBox(Sender).HorzScrollBar.Position + 50
  else TScrollBox(Sender).VertScrollBar.Position := TScrollBox(Sender).VertScrollBar.Position + 50;
  Handled := True;
end;

procedure TRecogForm_.ScrollBox1MouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if isShiftDown or isSheelEnable then Exit;
  
  if ssCtrl in Shift then TScrollBox(Sender).HorzScrollBar.Position := TScrollBox(Sender).HorzScrollBar.Position - 50
  else TScrollBox(Sender).VertScrollBar.Position := TScrollBox(Sender).VertScrollBar.Position - 50;
  Handled := True;
end;

end.
