unit MainForm;

//{$D+}

{$DEFINE LASTACT}

//{$DEFINE DEBUG}

//{$IFDEF DEBUG}                                                                          
//   Writeln(myLogFile, '');
//   Flush(myLogFile);
//{$ENDIF}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Forms, Inifiles, Controls,
  Contnrs, Registry, ComCtrls, ExtCtrls, ImgList, StdCtrls, Buttons, Dialogs,
  ShellAPI, Menus, Clipbrd, Math, AppEvnts, StrUtils, LoadMapUnit, Board, SQLiteTable3, PsAPI;

type
  TSetting = record     // ����������Ŀ
    myTop: integer;            // �ϴ��˳�ʱ�����ڵ�λ�ü���С
    myLeft: integer;
    myWidth: integer;
    myHeight: integer;
    bwTop: integer;            // �Ϲؿ�������ڵ�λ�ü���С�ļ���
    bwLeft: integer;
    bwWidth: integer;
    bwHeight: integer;
    bwStyle: integer;          // �ؿ������ʽ
    mySpeed: integer;          // ��ǰ�ƶ��ٶ�
    bwBKColor: integer;        // �ؿ��������ı���ɫ
    MapFileName: string;       // ��ǰ�ؿ����ĵ���
    SkinFileName: string;      // ��ǰƤ���ĵ���
    isGoThrough: boolean;      // ��Խ�Ƿ���
    isIM: boolean;             // ˲���Ƿ���
    isBK: boolean;             // �Ƿ�����ģʽ
    isSameGoal: boolean;       // ����ʱ��ʹ������Ŀ��λ
    isJijing: boolean;         // ����˫��
    isNumber: boolean;         // �Ƿ�����˫����š�����
    isRotate: boolean;         // �Ƿ�������ת���ؿ�
    isXSB_Saved: boolean;      // ���Ӽ��а嵼��� XSB �Ƿ񱣴����
    isLurd_Saved: boolean;     // �ƹؿ��Ķ����Ƿ񱣴����
    isOddEven: Boolean;        // �Ƿ���ʾ��ż��Ч
    isLeftBar: Boolean;        // �Ƿ���ʾ������
    isShowNoVisited: Boolean;  // �Ƿ��ʶδ�����ʹ��ĸ���
    LaterList: TStringList;    // ����ƹ��Ĺؿ���
    SubmitCountry: string;     // �ύ--���һ����
    SubmitName: string;        // �ύ--����       
    SubmitEmail: string;       // �ύ--����
  end;

type                  // ��ǰ��ͼ��Ϣ
  TMapState = record
    CurrentLevel: integer;   // ��ǰ�ؿ����
    ManPosition: integer;    // ���Ƴ�ʼ״̬���˵�λ��
    MapSize: integer;        // ��ͼ�ߴ�
    CellSize: integer;       // ����ͼʱ����ǰ�ĵ�Ԫ��ߴ�
    Recording: Boolean;      // �Ƿ��ڶ���¼��״̬
    Recording_BK: Boolean;   // �Ƿ��ڶ���¼��״̬ -- ����
    StartPos: Integer;       // ����¼�ƵĿ�ʼ��
    StartPos_BK: Integer;    // ����¼�ƵĿ�ʼ�� -- ����
    isFinish: Boolean;       // �Ƿ�õ��𰸣�����ۿ����� - ����سɹ�������ȷ�𰸺󣬴˱�־Ϊ�棬��ʾ���ԡ��ۿ�������
  end;

type
  Tmain = class(TForm)
    map_Image: TImage;
    pl_Main: TPanel;
    pl_Side: TPanel;
    pl_Tools: TPanel;
    PageControl: TPageControl;
    Tab_Solution: TTabSheet;
    Tab_Snapshot: TTabSheet;
    bt_Pre: TSpeedButton;
    bt_Open: TSpeedButton;
    bt_Next: TSpeedButton;
    bt_UnDo: TSpeedButton;
    bt_ReDo: TSpeedButton;
    bt_IM: TSpeedButton;
    bt_BK: TSpeedButton;
    bt_OddEven: TSpeedButton;
    bt_Skin: TSpeedButton;
    List_Solution: TListBox;
    List_State: TListBox;
    bt_GoThrough: TSpeedButton;
    bt_View: TSpeedButton;
    pnl_Trun: TPanel;
    pnl_Speed: TPanel;
    tsList_Inf: TTabSheet;
    mmo_Inf: TMemo;
    dlgSave1: TSaveDialog;
    pmBoardBK: TPopupMenu;
    pmGoal: TMenuItem;
    pmJijing: TMenuItem;
    pmSolution: TPopupMenu;
    so_Lurd: TMenuItem;
    so_XSB_Lurd: TMenuItem;
    so_XSB_Lurd_File: TMenuItem;
    so_XSB_LurdAll: TMenuItem;
    so_XSB_LurdAll_File: TMenuItem;
    so_Delete: TMenuItem;
    so_DeleteAll: TMenuItem;
    pmState: TPopupMenu;
    sa_Lurd: TMenuItem;
    sa_Lurd_BK: TMenuItem;
    sa_XSB_Lurd: TMenuItem;
    sa_XSB_Lurd_File: TMenuItem;
    sa_Delete: TMenuItem;
    sa_DeleteAll: TMenuItem;
    bt_Lately: TSpeedButton;
    pm_Later: TPopupMenu;
    pm_Home: TMenuItem;
    Panel1: TPanel;
    bt_Act: TSpeedButton;
    bt_Save: TSpeedButton;
    N1: TMenuItem;
    N2: TMenuItem;
    XSB1: TMenuItem;
    XSB2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    pm_Up_Bt: TPopupMenu;
    pm_Down_Bt: TPopupMenu;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    pm_UnDo_Bt: TPopupMenu;
    pm_ReDo_Bt: TPopupMenu;
    N14: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    N20: TMenuItem;
    N21: TMenuItem;
    N22: TMenuItem;
    ed_sel_Map: TEdit;
    N23: TMenuItem;
    F91: TMenuItem;
    XSB0: TMenuItem;
    bt_LeftBar: TSpeedButton;
    N24: TMenuItem;
    Lurd1: TMenuItem;
    Lurd2: TMenuItem;
    Lurd3: TMenuItem;
    XSB4: TMenuItem;
    N25: TMenuItem;
    sa_ClraeAll: TMenuItem;
    so_XSBAll_LurdAll1_File: TMenuItem;
    sb_Help: TSpeedButton;
    funMenu: TSpeedButton;
    N26: TMenuItem;
    N27: TMenuItem;
    N28: TMenuItem;
    N29: TMenuItem;
    StatusBar1: TStatusBar;
    OpenDialog1: TOpenDialog;
    ApplicationEvents1: TApplicationEvents;
    Timer1: TTimer;
    Edit1: TEdit;
    pl_Ground: TPanel;
    N30: TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bt_OddEvenMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure bt_OddEvenMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure map_ImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ContentClick(Sender: TObject);              // ����
    procedure Restart(is_BK: Boolean);                    // �ؿ����¿�ʼ
    procedure bt_PreClick(Sender: TObject);               // ��һ��
    procedure bt_NextClick(Sender: TObject);              // ��һ��
    procedure bt_UnDoClick(Sender: TObject);              // UnDo ��ť
    procedure bt_ReDoClick(Sender: TObject);              // ReDo ��ť
    procedure bt_GoThroughClick(Sender: TObject);         // ��Խ����
    procedure bt_IMClick(Sender: TObject);                // ˲�ƿ���
    procedure bt_BKClick(Sender: TObject);                // ����ģʽ
    procedure SetButton();                                // ���ð�ť״̬
    procedure bt_OpenClick(Sender: TObject);              // �򿪹ؿ��ĵ�
    procedure bt_SkinClick(Sender: TObject);              // ѡ��Ƥ��
    function GetCur(x, y: Integer): string;              // ������
    procedure DrawLine(cs: TCanvas; x1, y1: Integer; isLine: boolean);      // ������
    procedure pnl_TrunMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pnl_SpeedMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure bt_ViewClick(Sender: TObject);
    procedure bt_ActClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure List_SolutionDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure List_SolutionMeasureItem(Control: TWinControl; Index: Integer; var Height: Integer);
    procedure pmGoalClick(Sender: TObject);
    procedure pmJijingClick(Sender: TObject);
    procedure List_SolutionDblClick(Sender: TObject);
    procedure List_StateDblClick(Sender: TObject);
    procedure sa_LurdClick(Sender: TObject);
    procedure sa_Lurd_BKClick(Sender: TObject);
    procedure sa_XSB_LurdClick(Sender: TObject);
    procedure sa_XSB_Lurd_FileClick(Sender: TObject);
    procedure sa_DeleteClick(Sender: TObject);
    procedure sa_DeleteAllClick(Sender: TObject);
    procedure sa_ClraeAllClick(Sender: TObject);
    procedure so_LurdClick(Sender: TObject);
    procedure so_XSB_LurdClick(Sender: TObject);
    procedure so_XSB_LurdAllClick(Sender: TObject);
    procedure so_XSB_Lurd_FileClick(Sender: TObject);
    procedure so_XSB_LurdAll_FileClick(Sender: TObject);
    procedure so_XSBAll_LurdAll1_FileClick(Sender: TObject);       // ������ʹ��ĸ���
    procedure so_DeleteClick(Sender: TObject);
    procedure so_DeleteAllClick(Sender: TObject);
    procedure StatusBar1DblClick(Sender: TObject);
    procedure StatusBar1Resize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure bt_LatelyClick(Sender: TObject);
    procedure StatusBar1DrawPanel(StatusBar: TStatusBar;
      Panel: TStatusPanel; const Rt: TRect);
    procedure bt_SaveClick(Sender: TObject);
    procedure pm_HomeClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure map_ImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure map_ImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure map_ImageDblClick(Sender: TObject);
    procedure XSB2Click(Sender: TObject);
    procedure XSB1Click(Sender: TObject);
    procedure ApplicationEvents1Minimize(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure N11Click(Sender: TObject);
    procedure N15Click(Sender: TObject);
    procedure N18Click(Sender: TObject);
    procedure N14Click(Sender: TObject);
    procedure N17Click(Sender: TObject);
    procedure N16Click(Sender: TObject);
    procedure N19Click(Sender: TObject);
    procedure N21Click(Sender: TObject);
    procedure N22Click(Sender: TObject);
    procedure bt_PreMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ed_sel_MapKeyPress(Sender: TObject; var Key: Char);
    procedure ed_sel_MapChange(Sender: TObject);
    procedure F91Click(Sender: TObject);
    procedure XSB0Click(Sender: TObject);
    procedure bt_LeftBarClick(Sender: TObject);
    procedure Lurd1Click(Sender: TObject);
    procedure Lurd2Click(Sender: TObject);
    procedure Lurd3Click(Sender: TObject);
    procedure XSB4Click(Sender: TObject);
    procedure Board_Visited;
    procedure sb_HelpClick(Sender: TObject);
    procedure List_SolutionMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure N29Click(Sender: TObject);
    procedure funMenuClick(Sender: TObject);
    procedure N27Click(Sender: TObject);
    function GetWall(r, c: Integer): Integer;
    procedure Timer1Timer(Sender: TObject);            // ���㻭��ͼʱ��ʹ���ǿ�ǽ��ͼԪ
    function GetProcessMemUse(PID: Cardinal): Double;
    procedure Timer2Timer(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure pl_GroundMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnl_TrunMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure N30Click(Sender: TObject);

  private
    // ��ǰ��ͼ����
    MoveTimes, PushTimes: integer;                    // �������Ʋ���
    MoveTimes_BK, PushTimes_BK: integer;              // �������Ʋ���
    IsManAccessibleTips: boolean;                     // �Ƿ���ʾ�˵����ƿɴ���ʾ
    IsManAccessibleTips_BK: boolean;                  // �Ƿ���ʾ�˵����ƿɴ���ʾ
    IsBoxAccessibleTips: boolean;                     // �Ƿ���ʾ���ӵ����ƿɴ���ʾ
    IsBoxAccessibleTips_BK: boolean;                  // �Ƿ���ʾ���ӵ����ƿɴ���ʾ

    BoxNum_Board: array[0..9999] of integer;          // ���ӱ��
    PosNum_Board: array[0..9999] of integer;          // λ�ñ��
    BoxNum_Board_BK: array[0..9999] of integer;       // ���ӱ�� - ����
    PosNum_Board_BK: array[0..9999] of integer;       // λ�ñ�� - ����
    map_Selected: array[0..9999] of Boolean;          // ѡ�еĵ�Ԫ��
    map_Selected_BK: array[0..9999] of Boolean;       // ѡ�еĵ�Ԫ�� - ����
    map_Board_Visited: array[0..9999] of Boolean;     // ���ʹ��ĸ���
    BoxNumber: integer;                               // ������
    GoalNumber: integer;                              // Ŀ�����
    ManPos: integer;                                  // �˵�λ�� -- ����
    ManPos_BK: integer;                               // �˵�λ�� -- ����
    OldBoxPos: integer;                               // ����������ӵ�λ�� -- ����
    OldBoxPos_BK: integer;                            // ����������ӵ�λ�� -- ����

    LastSteps: Integer;                               // �������һ�ε���ǰ�Ĳ���

    procedure WMDROPFILES(var Msg:TWMDROPFILES);message WM_DROPFILES;   // �϶��ĵ������򴰿�

    function GetStepLine(is_BK: Boolean): Integer;    // �������һ�Ρ�ֱ�ơ�

    // ��ͼ
    function LoadMap(MapIndex: integer): boolean;     // ���عؿ�
    procedure ReadQuicklyMap();                       // �� QuicklyLoadMap() ���ص��ĵ�ͼ��װ����Ϸ����
    procedure InitlizeMap();                          // ��ͼ��ʼ��
    procedure NewMapSize();                           // ���¼����ͼ�ߴ�
    procedure DrawMap();                              // ����ͼ

    // �������ӵ��ƶ�
    function IsComplete(): boolean;                   // �Ƿ���� - ����
    function IsComplete_BK(): boolean;                // �Ƿ���� - ����
    function IsMeets(ch: Char): Boolean;              // �Ƿ��������
    procedure ReDo(Steps: Integer);                   // ����һ�� - ����
    procedure UnDo(Steps: Integer);                   // ����һ�� - ����
    procedure ReDo_BK(Steps: Integer);                // ����һ�� - ����
    procedure UnDo_BK(Steps: Integer);                // ����һ�� - ����
    procedure GameDelay();                            // ��ʱ
    procedure DoAct(n:  Integer);                     // �Զ�ִ�С��Ĵ���������

    // ��ȡ������Ϣ
    procedure LoadSttings();
    procedure SaveSttings();
    procedure ShowStatusBar();                        // ˢ�µײ�״̬��
    procedure SetMapTrun();                           // ���µ�ͼ��ת״̬

    function GetStep(is_BK: Boolean): Integer;        // �������� reDo �����ڵ� -- ÿ��һ������Ϊһ������
    function GetStep2(is_BK: Boolean): Integer;       // �������� unDo �����ڵ� -- ÿ��һ������Ϊһ������
    function SaveXSBToFile(): Boolean;                // ����ؿ� XSB ���ĵ�
    function SaveSolution(n: Integer): Boolean;       // ������
    function SaveState(): Boolean;                    // ����״̬
    function LoadState(): Boolean;                    // ����״̬
    function GetSolution(mapNpde: PMapNode): string;  // ����ָ���ؿ������д�
    function GetStateFromDB(index: Integer; var x: Integer; var y: Integer; var str1: string; var str2: string): Boolean;    // �Ӵ𰸿����һ��״̬
    function GetSolutionFromDB(index: Integer; var str: string): Boolean;                                                    // �Ӵ𰸿����һ����
    procedure MenuItemClick(Sender: TObject);
    function GetCountBox(): string;                   // ������
    procedure getANS(ans_num, level_num: Integer; var str: String);      //���ݴ𰸵���ת��������ؿ�ĳ��ת�Ĵ�

  public
    mySettings: ^TSetting;                            // �������������
    curMap: TMapState;                                // ��ǰ�ĵ�ͼ����
    txtList: TStringList;                             // �ؿ��ĵ��ĸ��������б�
    maxNumber: Integer;                               // ���ؿ����

    map_Board_BK: array[0..9999] of integer;          // ���Ƶ�ͼ
    map_Board: array[0..9999] of integer;             // ���Ƶ�ͼ
    map_Board_OG: array[0..9999] of integer;          // ԭʼ��ͼ
    
    function LoadSolution(): Boolean;                 // ���ش�

  end;

const
  minWindowsWidth = 600;                                           // ���򴰿���С�ߴ�����
  minWindowsHeight = 400;
  
  DelayTimes: array[0..4] of dword = (5, 150, 275, 550, 1000);     // ��Ϸ��ʱ -- �ٶȿ���

  MapTrun: array[0..7] of string = ('0ת', '1ת', '2ת', '3ת', '4ת', '5ת', '6ת', '7ת');
  SpeedInf: array[0..4] of string = ('���', '�Ͽ�', '����', '����', '����');
  
  AppName = 'BoxMan';
  AppVer = ' V2.9';

var
  main: Tmain;

  BoxManDBpath: string;                             // �𰸿�·���ĵ���

  tmpTrun: integer;
  SoltionList: Tlist;     // ���б���
  StateList: Tlist;       // ״̬�б���

  // �������Ʊ���
  isMoving: boolean;      // �Ƿ������ƶ�����
  IsStop: boolean;        // �Ƿ���Ҫֹͣ�ƶ�����
  isNoDelay: Boolean;     // �Ƿ�Ϊ����ʱ���� -- ���ס���β�����붯������״̬ʱʹ��
  isKeyPush: Boolean;     // �Ƿ�Ϊ�ؼ�֡�ƶ� -- �ո�����˸�����Ƶ�

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

  Trun8: array[0..7, 0..7] of Integer = (  // �ؿ�8��λ��ת֮nת��������
    (0, 1, 2, 3, 4, 5, 6, 7),
    (3, 0, 1, 2, 7, 4, 5, 6),
    (2, 3, 0, 1, 6, 7, 4, 5),
    (1, 2, 3, 0, 5, 6, 7, 4),
    (4, 7, 6, 5, 0, 3, 2, 1),
    (5, 4, 7, 6, 1, 0, 3, 2),
    (6, 5, 4, 7, 2, 1, 0, 3),
    (7, 6, 5, 4, 3, 2, 1, 0));

  ActDir: array[0..7, 0..7] of Char = (    // ���� 8 ��λ��ת֮ n ת�Ļ�������
    ('l', 'u', 'r', 'd', 'L', 'U', 'R', 'D'),
    ('d', 'l', 'u', 'r', 'D', 'L', 'U', 'R'),
    ('r', 'd', 'l', 'u', 'R', 'D', 'L', 'U'),
    ('u', 'r', 'd', 'l', 'U', 'R', 'D', 'L'),
    ('r', 'u', 'l', 'd', 'R', 'U', 'L', 'D'),
    ('d', 'r', 'u', 'l', 'D', 'R', 'U', 'L'),
    ('l', 'd', 'r', 'u', 'L', 'D', 'R', 'U'),
    ('u', 'l', 'd', 'r', 'U', 'L', 'D', 'R'));

  function AppHasRun(AppHandle: THandle): Boolean;      // ����Ѿ������򼤻��� -- ֻ����һ��
    
implementation

uses
  DateUtils, LogFile, MyInf, Submit, IDHttp, superobject, ShowSolutionList, OpenFile,
  LoadSkin, PathFinder, LurdAction, BrowseLevels, CRC_32, Actions, MyMessage;

const
  MapFileName = 'yuweng_BoxMan_2019_';
 
type
  
  PShareMem = ^TShareMem;     //�����ڴ�
  TShareMem = record
    AppHandle: THandle;       // �������ľ��
  end;

var
  hMapFile: THandle;
  PSMem: PShareMem;

  gotoLeft, gotoPos, gotoWidth: Integer;                  // ״̬�����ұ�һ������缰���

  LeftTopPos, RightBottomPos: TPoint;                     // ѡ��Ԫ������Ϻ�����λ��
  LeftTopXY, RightBottomXY: TPoint;                       // ��ǰѡ�񽹵������Ϻ�����λ��
  isSelectMod: Boolean;                                   // �Ƿ񴥶���ѡ��ģʽ -- Ctrl + ���������Ԫ��
  isDelSelect: Boolean;                                   // �Ƿ񴥶��˼���ѡ��ģʽ -- Alt + ���������Ԫ��
  isSelecting: Boolean;                                   // �Ƿ�������ѡ��ģʽ -- Ctrl + ����϶�

  DoubleClickPos: TPoint;                                 // ��ǰ˫����λ��

  isCommandLine: Boolean;                                 // �Ƿ�����������������������ʱ���ؿ��ĵ�������¼�� ini

{$R *.DFM}

// �ó���ֻ����һ��
procedure CreateMapFile;
begin
  hMapFile := OpenFileMapping(FILE_MAP_ALL_ACCESS, False, PChar(MapFileName));
  if hMapFile = 0 then
  begin
    hMapFile := CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0,
      SizeOf(TShareMem), MapFileName);
    PSMem := MapViewOfFile(hMapFile, FILE_MAP_WRITE or FILE_MAP_READ, 0, 0, 0);
    if PSMem = nil then
    begin
      CloseHandle(hMapFile);
      Exit;
    end;
    PSMem^.AppHandle := 0;
  end
  else begin
    PSMem := MapViewOfFile(hMapFile, FILE_MAP_WRITE or FILE_MAP_READ, 0, 0, 0);
    if PSMem = nil then
    begin
      CloseHandle(hMapFile);
    end
  end;
end;

// �ó���ֻ����һ��
procedure FreeMapFile;
begin
  UnMapViewOfFile(PSMem);
  CloseHandle(hMapFile);
end;

// �ó���ֻ����һ��
function AppHasRun(AppHandle: THandle): Boolean;
var
  TopWindow: HWnd;
begin
  Result := False;
  if PSMem <> nil then
  begin
    if PSMem^.AppHandle <> 0 then
    begin
      SendMessage(PSMem^.AppHandle, WM_SYSCOMMAND, SC_RESTORE, 0);
      TopWindow := GetLastActivePopup(PSMem^.AppHandle);
      if (TopWindow <> 0) and (TopWindow <> PSMem^.AppHandle) and
        IsWindowVisible(TopWindow) and IsWindowEnabled(TopWindow) then
        SetForegroundWindow(TopWindow);
      Result := True;
    end
    else
      PSMem^.AppHandle := AppHandle;
  end;
end;

//�����ڴ�  
procedure ClearMemory;  
begin  
   if Win32Platform = VER_PLATFORM_WIN32_NT then  
   begin  
      SetProcessWorkingSetSize(GetCurrentProcess, $FFFFFFFF, $FFFFFFFF);  
      Application.ProcessMessages;  
   end;  
end;

// ��ʱ��������ڴ�ռ�����
procedure Tmain.Timer1Timer(Sender: TObject);
begin
  ClearMemory;
  if Timer1.Interval <> 60000 then Timer1.Interval := 60000;
  pl_Tools.Caption := Format('�ڴ�ռ��: %.0n KB ', [GetProcessMemUse(GetCurrentProcessId)]);
end;

// ȡ�ó���ռ�õ��ڴ��С
function Tmain.GetProcessMemUse(PID: Cardinal): Double;
var
  pmc: PPROCESS_MEMORY_COUNTERS; // uses psApi
  ProcHandle: HWND;
  iSize: DWORD;
begin
  Result := 0.0;
  iSize := SizeOf(_PROCESS_MEMORY_COUNTERS);
  GetMem(pmc, iSize);
  try
    pmc^.cb := iSize;
    ProcHandle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, PID); //��PIDȡ�ý��̶���ľ��
    if GetProcessMemoryInfo(ProcHandle, pmc, iSize) then
       Result := (pmc^.WorkingSetSize) / 1024;
  finally
    FreeMem(pmc);
  end;
end;

// ��մ��б���
procedure SoltionListClear(var _List_: TList);
var
  i, len: Integer;
begin
  if not Assigned(_List_) then exit;

  if Assigned(_List_) then begin
    len := _List_.Count;
    for i := len-1 downto 0 do begin
        if Assigned(PTSoltionNode(_List_.Items[i])) then begin
           Dispose(PTSoltionNode(_List_.Items[i]));
           _List_.Items[i] := nil;
        end;
    end;
    _List_.Clear;
  end;
end;

// ���״̬�б���
procedure StateListClear(var _List_: TList);
var
  i, len: Integer;
begin
  if not Assigned(_List_) then exit;

  if Assigned(_List_) then begin
    len := _List_.Count;
    for i := len-1 downto 0 do begin
        if Assigned(PTStateNode(_List_.Items[i])) then begin
           Dispose(PTStateNode(_List_.Items[i]));
           _List_.Items[i] := nil;
        end;
    end;
    _List_.Clear;
  end;
end;

// ����������Ϣ
procedure Tmain.LoadSttings();
var
  IniFile: TIniFile;
  i: Integer;
  s: string;

begin

  IniFile := TIniFile.Create(AppPath + AppName + '.ini');

  try
    mySettings.myTop := IniFile.ReadInteger('Settings', 'Top', 100);            // �ϴ��˳�ʱ�����ڵ�λ�ü���С
    mySettings.myLeft := IniFile.ReadInteger('Settings', 'Left', 100);
    mySettings.myWidth := IniFile.ReadInteger('Settings', 'Width', 800);
    mySettings.myHeight := IniFile.ReadInteger('Settings', 'Height', 600);
    mySettings.bwTop := IniFile.ReadInteger('Settings', 'bwTop', 100);          // �ؿ�������ڵ�λ�ü���С�ļ���
    mySettings.bwLeft := IniFile.ReadInteger('Settings', 'bwLeft', 100);
    mySettings.bwWidth := IniFile.ReadInteger('Settings', 'bwWidth', 800);
    mySettings.bwHeight := IniFile.ReadInteger('Settings', 'bwHeight', 600);
    mySettings.bwStyle := IniFile.ReadInteger('Settings', 'bwStyle', 0);
    mySettings.SubmitCountry := IniFile.ReadString('Settings', 'SubmitCountry', 'CN'); // �ύ--���һ����
    mySettings.SubmitName := IniFile.ReadString('Settings', 'SubmitName', '');         // �ύ--����
    mySettings.SubmitEmail := IniFile.ReadString('Settings', 'SubmitEmail', '');       // �ύ--����
    mySettings.mySpeed := IniFile.ReadInteger('Settings', '�ٶ�', 2);                  // Ĭ���ƶ��ٶ�
    mySettings.bwBKColor := IniFile.ReadInteger('Settings', '�������ɫ', clWhite);    // Ĭ�Ϲؿ�������汳��ɫ
    mySettings.isGoThrough := IniFile.ReadBool('Settings', '��Խ', true);              // ��Խ����
    mySettings.isIM := IniFile.ReadBool('Settings', '˲��', false);                    // ˲�ƿ���
    mySettings.isSameGoal := IniFile.ReadBool('Settings', '����Ŀ��λ', false);        // ����ʱ��ʹ������Ŀ��λ
    mySettings.isLeftBar := IniFile.ReadBool('Settings', '������', true);            // �Ƿ���������
    mySettings.isNumber := IniFile.ReadBool('Settings', '˫�����', true);             // �Ƿ�����˫����š����ܣ�Ĭ�Ͽ���
    mySettings.isRotate := IniFile.ReadBool('Settings', '������ת', false);            // �Ƿ�������ת���ؿ���Ĭ�Ϲر�
    mySettings.SkinFileName := IniFile.ReadString('Settings', 'Ƥ��', '');             // ��ǰƤ���ĵ���
    mySettings.MapFileName := IniFile.ReadString('Settings', '�ؿ��ĵ�', '');          // ��ǰ�ؿ��ĵ���
    curMap.CurrentLevel := IniFile.ReadInteger('Settings', '�ؿ����', 1);             // �ϴ��ƵĹؿ����
    tmpTrun := IniFile.ReadInteger('Settings', '�ؿ���ת', 0);                         // �ϴ��ƵĹؿ���ת

    mySettings.LaterList := TStringList.Create;
    for i := 0 to 9 do begin
        s := IniFile.ReadString('Settings', 'Later_' + IntToStr(i), '');
        if s <> '' then mySettings.LaterList.Add(s);                            // ����ƹ��Ĺؿ���
    end;

    // Ĭ�ϵ�������
    mySettings.isBK := False;                                                   // �Ƿ�����ģʽ
    mySettings.isXSB_Saved := True;                                             // ���Ӽ��а嵼��� XSB �Ƿ񱣴����
    mySettings.isLurd_Saved := True;                                            // �ƹؿ��Ķ����Ƿ񱣴����
    mySettings.isJijing := False;                                               // ����˫��
    mySettings.isOddEven := False;                                              // ��ż��Ч��
    pmGoal.Checked := mySettings.isSameGoal;                                    // ��λ˫��
    N29.Checked := mySettings.isNumber;                                         // ˫�����

    if (mySettings.myWidth < minWindowsWidth) then
      mySettings.myWidth := minWindowsWidth;
    if (mySettings.myHeight < minWindowsHeight) then
      mySettings.myHeight := minWindowsHeight;
    if (mySettings.myWidth > SCREEN.WIDTH) then
      mySettings.myWidth := SCREEN.WIDTH;
    if (mySettings.myHeight > SCREEN.HEIGHT) then
      mySettings.myHeight := SCREEN.HEIGHT;
    if (mySettings.myTop < 0) or (mySettings.myTop > SCREEN.WIDTH) then
      mySettings.myTop := 0;
    if (mySettings.myLeft < 0) or (mySettings.myLeft > SCREEN.HEIGHT) then
      mySettings.myLeft := 0;
    if (mySettings.mySpeed < 0) or (mySettings.mySpeed > 4) then
      mySettings.mySpeed := 2;                                                  // Ĭ���ƶ��ٶ�
    if (tmpTrun < 0) or (tmpTrun > 7) then
      tmpTrun := 0;                                                             // Ĭ�Ϲؿ���ת
  finally
    if Assigned(IniFile) then begin
       IniFile.Free;
    end;
  end;

end;

// ����������Ϣ
procedure Tmain.SaveSttings();
var
  IniFile: TIniFile;
  i, n: Integer;

begin
  IniFile := TIniFile.Create(AppPath + AppName + '.ini');

  try
    IniFile.WriteInteger('Settings', 'Top', Top);                               // �˳�ʱ�����ڵ�λ�ü���С
    IniFile.WriteInteger('Settings', 'Left', Left);
    IniFile.WriteInteger('Settings', 'Width', Width);
    IniFile.WriteInteger('Settings', 'Height', Height);
    IniFile.WriteInteger('Settings', 'bwTop', BrowseForm.Top);                  // �ؿ�������ڵ�λ�ü���С�ļ���
    IniFile.WriteInteger('Settings', 'bwLeft', BrowseForm.Left);
    IniFile.WriteInteger('Settings', 'bwWidth', BrowseForm.Width);
    IniFile.WriteInteger('Settings', 'bwHeight', BrowseForm.Height);
    IniFile.WriteString('Settings', 'SubmitCountry', mySettings.SubmitCountry); // ���һ����
    IniFile.WriteString('Settings', 'SubmitName', mySettings.SubmitName);       // ����
    IniFile.WriteString('Settings', 'SubmitEmail', mySettings.SubmitEmail);     // ����
    IniFile.WriteInteger('Settings', '�ٶ�', mySettings.mySpeed);               // �ƶ��ٶ�
    IniFile.WriteInteger('Settings', '�������ɫ', mySettings.bwBKColor);       // �ؿ�������汳��ɫ
    IniFile.WriteBool('Settings', '��Խ', mySettings.isGoThrough);              // ��Խ����
    IniFile.WriteBool('Settings', '˲��', mySettings.isIM);                     // ˲�ƿ���
    IniFile.WriteBool('Settings', '����Ŀ��λ', mySettings.isSameGoal);         // ����ʱ��ʹ������Ŀ��λ
    IniFile.WriteBool('Settings', '������', mySettings.isLeftBar);            // �Ƿ���������
    IniFile.WriteBool('Settings', '˫�����', mySettings.isNumber);             // �Ƿ�����˫����š�����
    IniFile.WriteBool('Settings', '������ת', mySettings.isRotate);             // �Ƿ�������ת���ؿ���Ĭ�Ϲر�
    IniFile.WriteString('Settings', 'Ƥ��', mySettings.SkinFileName);           // ��ǰƤ���ĵ���
    if not isCommandLine then begin
        IniFile.WriteString('Settings', '�ؿ��ĵ�', mySettings.MapFileName);        // ��ǰ�ؿ��ĵ��� -- ��Ӧ�ؿ��ĵ��������ͬһĿ¼�µ����
        IniFile.WriteInteger('Settings', '�ؿ����', curMap.CurrentLevel);          // ��ǰ�ؿ����
        if (not Assigned(curMapNode)) then
          IniFile.WriteInteger('Settings', '�ؿ���ת', 0)                           // ��ǰ�ؿ���ת
        else
          IniFile.WriteInteger('Settings', '�ؿ���ת', curMapNode.Trun);
    end;

    n := mySettings.LaterList.Count;
    for i := 0 to n-1 do begin
        IniFile.WriteString('Settings', 'Later_' + IntToStr(i), mySettings.LaterList.Strings[i]);    // ����ƹ��Ĺؿ���
    end;

  finally
    if Assigned(IniFile) then begin
       IniFile.Free;
    end;
  end;
end;

// �� QuicklyLoadMap() ���ص��ĵ�ͼ��װ����Ϸ����
procedure Tmain.ReadQuicklyMap();
var
  i, j, CurCell, Rows, Cols: integer;
  s: string;
  Map: TStringList;
  
begin
  if (not Assigned(curMapNode)) or (curMapNode.Cols <= 0) then begin
     MessageBox(handle, '���޴򿪵Ĺؿ���', '����', MB_ICONERROR or MB_OK);
     Exit;
  end;

  Map := TStringList.Create;

  try
    s := '����:'#10'-----'#10 + curMapNode.Title + #10#10#10'����:'#10'-----'#10 + curMapNode.Author + #10#10#10'˵��:'#10'-----'#10 + curMapNode.Comment;
    Map.Clear;
    Split(s, Map);
    mmo_Inf.Lines.Clear;
    mmo_Inf.Lines.Assign(Map);

    Map.Clear;
    Map.Delimiter := #10;
    Map.DelimitedText := curMapNode.Map;
    
    Rows := curMapNode.Rows;
    Cols := curMapNode.Cols;

    curMapNode.Boxs := 0;                                                                     
    curMapNode.Goals := 0;
    for i := 0 to Rows - 1 do begin    // ��ѭ��
      for j := 1 to Cols do begin      // ��ѭ��
        case Map[i][j] of
          '_':
            CurCell := EmptyCell;
          '#':
            CurCell := WallCell;
          '.': begin
            CurCell := GoalCell;
            curMapNode.Goals := curMapNode.Goals+1;
          end;
          '$': begin
            CurCell := BoxCell;
            curMapNode.Boxs := curMapNode.Boxs+1;
          end;
          '*': begin
            curMapNode.Goals := curMapNode.Goals+1;
            curMapNode.Boxs := curMapNode.Boxs+1;
            CurCell := BoxGoalCell;
          end;
          '@':
            CurCell := ManCell;
          '+': begin
            CurCell := ManGoalCell;
            curMapNode.Goals := curMapNode.Goals+1;
          end;
        else
          CurCell := FloorCell;
        end;
        map_Board_OG[i * Cols + j - 1] := CurCell;
      end;
    end;
  finally
    if Assigned(Map) then Map.Free;
  end;

  curMap.MapSize := Cols * Rows;

  PathFinder.Init(curMapNode.Cols, curMapNode.Rows);

  InitlizeMap();

  pnl_Trun.Caption := MapTrun[curMapNode.Trun];
  Caption := AppName + AppVer + ' - ' + ExtractFileName(ChangeFileExt(mySettings.MapFileName, EmptyStr)) + ' ~ [' + inttostr(curMap.CurrentLevel) + '/' + inttostr(maxNumber) + ']';
  Caption := Caption + '���ߴ�: ' + IntToStr(curMapNode.Cols) + '��' + IntToStr(curMapNode.Rows) + '������: ' + IntToStr(curMapNode.Boxs) + '��Ŀ��: ' + IntToStr(curMapNode.Goals);
  ed_sel_Map.Text := IntToStr(curMap.CurrentLevel);

end;

// �ӹؿ��б��У�����ָ����ŵĵ�ͼ
function Tmain.LoadMap(MapIndex: integer): boolean;
var
  i, j, CurCell, Rows, Cols, len: integer;
  ch: Char;
  s: string;
  Map: TStringList;
  tmpMap: PMapNode;
begin
  result := false;

  if MapIndex < 1 then MapIndex := 1
  else if MapIndex > MapList.Count then MapIndex := MapList.Count;

  tmpMap := MapList.Items[MapIndex - 1];
  if (MapList.Count = 0) or (tmpMap.Rows <= 0) then begin
     tmpMap := nil;
     Exit;
  end;

  curMapNode.Map_Thin := tmpMap.Map_Thin;
  curMapNode.Map := tmpMap.Map;
  curMapNode.Rows := tmpMap.Rows;
  curMapNode.Cols := tmpMap.Cols;
  curMapNode.Boxs := tmpMap.Boxs;
  curMapNode.Goals := tmpMap.Goals;
  curMapNode.Trun := tmpMap.Trun;
  curMapNode.Title := tmpMap.Title;
  curMapNode.Author := tmpMap.Author;
  curMapNode.Comment := tmpMap.Comment;
  curMapNode.CRC32 := tmpMap.CRC32;
  curMapNode.CRC_Num := tmpMap.CRC_Num;
  curMapNode.Solved := tmpMap.Solved;
  curMapNode.isEligible := tmpMap.isEligible;
  curMapNode.Num := tmpMap.Num;
  tmpMap := nil;

  curMap.CurrentLevel := MapIndex;

  Rows := curMapNode.Rows;
  Cols := curMapNode.Cols;

  Map := TStringList.Create;

  try
    s := '����:'#10'-----'#10 + curMapNode.Title + #10#10#10'����:'#10'-----'#10 + curMapNode.Author + #10#10#10'˵��:'#10'-----'#10 + curMapNode.Comment;
    Map.Clear;
    Split(s, Map);
    mmo_Inf.Lines.Clear;
    mmo_Inf.Lines.Assign(Map);

    Map.Clear;
    Map.Delimiter := #10;
    Map.DelimitedText := curMapNode.Map;

    for i := 0 to Rows - 1 do begin    // ��ѭ��
      len := Length(Map[i]);
      for j := 1 to Cols do begin     // ��ѭ��
        if j > len then ch := '-'
        else ch := Map[i][j];
      
        case ch of
          '_':
            CurCell := EmptyCell;
          '#':
            CurCell := WallCell;
          '.':
            CurCell := GoalCell;
          '$':
            CurCell := BoxCell;
          '*':
            CurCell := BoxGoalCell;
          '@':
            CurCell := ManCell;
          '+':
            CurCell := ManGoalCell;
        else
          CurCell := FloorCell;
        end;
        map_Board_OG[i * Cols + j - 1] := CurCell;
      end;
    end;

  finally
    if Assigned(Map) then Map.Free;
  end;

  curMap.MapSize := Cols * Rows;

  PathFinder.Init(curMapNode.Cols, curMapNode.Rows);

  result := true;
end;

// �����ͼ�µ�ͼƬ��ʾ�ĳߴ�
procedure Tmain.NewMapSize();
var
  w, h: integer;
begin
  if (not Assigned(curMapNode)) or (curMapNode.Cols <= 0) then begin
     Exit;
  end;
  
  // �����ͼ��Ԫ��Ĵ�С
  if (curMapNode.Cols > 2) and (curMapNode.Rows > 2) then
  begin
    if curMapNode.Trun mod 2 = 0 then
    begin
      w := pl_Ground.Width div curMapNode.Cols;
      h := pl_Ground.Height div curMapNode.Rows;
    end
    else
    begin
      h := pl_Ground.Width div curMapNode.Rows;
      w := pl_Ground.Height div curMapNode.Cols;
    end;

    if w < h then
      curMap.CellSize := w
    else
      curMap.CellSize := h;
  end;
  if curMap.CellSize > SkinSize then
    curMap.CellSize := SkinSize;
  if curMap.CellSize < 6 then
    curMap.CellSize := 6;

  // ѡ��Ԫ����ͼ
  MaskPic.Width := curMap.CellSize;
  MaskPic.Height := MaskPic.Width;

  // ȷ����ͼ�ĳߴ�
  map_Image.Picture := nil;       // ���Ǳ���ģ����򣬵�ͼ���ܸı�ߴ�
  if curMapNode.Trun mod 2 = 0 then
  begin
    map_Image.Width := curMapNode.Cols * curMap.CellSize;
    map_Image.Height := curMapNode.Rows * curMap.CellSize;
  end
  else
  begin
    map_Image.Height := curMapNode.Cols * curMap.CellSize;
    map_Image.Width := curMapNode.Rows * curMap.CellSize;
  end;
//  if map_Image.Width < pl_Ground.Width then
     map_Image.Left := (pl_Ground.Width - map_Image.Width) div 2;
//  if map_Image.Height < pl_Ground.Height then
     map_Image.Top := (pl_Ground.Height - map_Image.Height) div 2;
   if map_Image.Left < 0 then map_Image.Left := 0;
   if map_Image.Top < 0 then map_Image.Top := 0;
end;

// Ϊ�ոռ��ص��Ĺؿ�����ʼ��
procedure Tmain.InitlizeMap();
var
  i, x, y, len: integer;
  s1, s2: string;
begin
  // ǰ��׼��
  UnDoPos := 0;
  ReDoPos := 0;
  UnDoPos_BK := 0;
  ReDoPos_BK := 0;
  MoveTimes := 0;
  PushTimes := 0;
  MoveTimes_BK := 0;
  PushTimes_BK := 0;
  isMoving := false;           // ����������...
  IsStop  := false;            // �Ƿ�ֹͣ�ƶ�
  isKeyPush := False;
  BoxNumber := 0;
  GoalNumber := 0;
  ManPos_BK := -1;              // �˵�λ�� -- ����
  ManPos_BK_0 := -1;            // �˵�λ�� -- ���� -- ����
  LastSteps := -1;              // �������һ�ε���ǰ�Ĳ���
  IsManAccessibleTips := false;           // �Ƿ���ʾ�˵����ƿɴ���ʾ
  IsManAccessibleTips_BK := false;        // �Ƿ���ʾ�˵����ƿɴ���ʾ
  IsBoxAccessibleTips := false;           // �Ƿ���ʾ���ӵ����ƿɴ���ʾ
  IsBoxAccessibleTips_BK := false;        // �Ƿ���ʾ���ӵ����ƿɴ���ʾ
  mySettings.isLurd_Saved := True;        // �ƹؿ��Ķ����Ƿ񱣴����
  isNoDelay := False;                     // �Ƿ�����ʱִ�ж���
  isSelectMod := False;
  isDelSelect := False;
  curMap.isFinish := True;                // �Ƿ�����ִ�ж�����ʾ
  curMap.Recording := false;              // �Ƿ��ڶ���¼��״̬
  curMapNode.Boxs := 0;
  curMapNode.Goals := 0;

  for i := 0 to curMap.MapSize - 1 do begin
    map_Board[i] := map_Board_OG[i];
    BoxNum_Board[i]    := -1;   // ���ӱ��
    PosNum_Board[i]    := -1;   // λ�ñ��
    BoxNum_Board_BK[i] := -1;   // ���ӱ�� - ����
    PosNum_Board_BK[i] := -1;   // λ�ñ�� - ����
    case map_Board_OG[i] of
      GoalCell:
        begin
          Inc(GoalNumber);
          Inc(curMapNode.Goals);
          map_Board_BK[i] := BoxCell;
        end;
      ManCell:
        begin
          ManPos := i;
          map_Board_BK[i] := FloorCell;
        end;
      ManGoalCell:
        begin
          Inc(GoalNumber);
          Inc(curMapNode.Goals);
          ManPos := i;
          map_Board_BK[i] := BoxCell;
        end;
      BoxCell:
        begin
          Inc(BoxNumber);
          Inc(curMapNode.Boxs);
          map_Board_BK[i] := GoalCell;
        end;
      BoxGoalCell:
        begin
          Inc(BoxNumber);
          Inc(GoalNumber);
          Inc(curMapNode.Boxs);
          Inc(curMapNode.Goals);
          map_Board_BK[i] := BoxGoalCell;
        end;
    else
      begin
        map_Board_BK[i] := map_Board_OG[i];
      end;
    end;
  end;

  curMap.ManPosition := ManPos;              // ��ͼ���˵�ԭʼλ�ã���������״̬ʱ���Դ���ʾ
  mySettings.isJijing := False;              // ����˫��
  pmJijing.Checked := False; 
  mySettings.isBK := False;                  // Ĭ������ģʽ
  mySettings.isShowNoVisited := False;
  OldBoxPos := -1;                           // ����������ӵ�λ�� -- ����
  OldBoxPos_BK := -1;                        // ����������ӵ�λ�� -- ����

  NewMapSize();    // ����ȷ�� Image ��С
  DrawMap();       // ����ͼ
  SetButton();     // ���ð�ť״̬

  LoadState();     // ����״̬
  LoadSolution();  // ���ش�
  curMapNode.Solved := (SoltionList.Count > 0);

  // ���ؿ��Ѿ��⿪�����Զ����ش𰸣�������״̬���棬��ֱ�Ӵ����µ�״̬
  if curMapNode.Solved then begin
    if GetSolutionFromDB(0, s1) then begin

       len := Length(s1);

       if len > 0 then begin
           // ���������Ƶ� RedoList
           ReDoPos := 0;
           for i := len downto 1 do begin
               if ReDoPos = MaxLenPath then Exit;
               inc(ReDoPos);
               RedoList[ReDoPos] := s1[i];
           end;
           curMap.isFinish := True;
       end;
       StatusBar1.Panels[7].Text := '�������룡';
    end;
  end else if StateList.count > 0 then begin
    if GetStateFromDB(0, x, y, s1, s2) then begin

       len := Length(s1);

       // ״̬���� RedoList
       if len > 0 then begin
           ReDoPos := 0;
           for i := len downto 1 do begin
               if ReDoPos = MaxLenPath then Exit;
               inc(ReDoPos);
               RedoList[ReDoPos] := s1[i];
           end;
               
           isNoDelay := True;
           ReDo(len);
           isNoDelay := False;
       end;

       len := Length(s2);

       // ״̬���� RedoList_BK
       if (len > 0) and (x > 0) and (y > 0) then begin

           if ManPos_BK >= 0 then begin
              if map_Board_BK[ManPos_BK] = ManCell then map_Board_BK[ManPos_BK] := FloorCell
              else map_Board_BK[ManPos_BK] := GoalCell;
           end;

           ManPos_BK := (y-1) * curMapNode.Cols + x-1;

           if map_Board_BK[ManPos_BK] = FloorCell then map_Board_BK[ManPos_BK] := ManCell
           else if map_Board_BK[ManPos_BK] = GoalCell then map_Board_BK[ManPos_BK] := ManGoalCell
           else Exit;

           ManPos_BK_0 := ManPos_BK;
               
           ReDoPos_BK := 0;
           for i := len downto 1 do begin
               if ReDoPos_BK = MaxLenPath then Exit;
               inc(ReDoPos_BK);
               RedoList_BK[ReDoPos_BK] := s2[i];
           end;

           isNoDelay := True;
           ReDo_BK(len);
           isNoDelay := False;
       end;
       curMap.isFinish := True;
       StatusBar1.Panels[7].Text := '״̬�����룡';
    end;
  end;

  if mySettings.isXSB_Saved then begin
     Caption := AppName + AppVer + ' - ' + ExtractFileName(ChangeFileExt(mySettings.MapFileName, EmptyStr)) + ' ~ [' + inttostr(curMap.CurrentLevel) + '/' + inttostr(maxNumber) + ']'
  end else begin
     Caption := AppName + AppVer + ' - ���а� ~ [' + inttostr(curMap.CurrentLevel) + '/' + inttostr(maxNumber) + ']';
  end;

  Caption := Caption + '���ߴ�: ' + IntToStr(curMapNode.Cols) + '��' + IntToStr(curMapNode.Rows) + '������: ' + IntToStr(curMapNode.Boxs) + '��Ŀ��: ' + IntToStr(curMapNode.Goals);
  ed_sel_Map.Text := IntToStr(curMap.CurrentLevel);
  
  ShowStatusBar();                                         // ����״̬��
  PathFinder.setThroughable(mySettings.isGoThrough);       // ��Խ����

  ClearMemory;

  if curMapNode.Cols > 0 then
    StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos mod curMapNode.Cols, ManPos div curMapNode.Cols) + ' - [ ' + IntToStr(ManPos mod curMapNode.Cols + 1) + ', ' + IntToStr(ManPos div curMapNode.Cols + 1) + ' ]';       // ���
end;

// �����޷�ǽ��ͼԪ
function Tmain.GetWall(r, c: Integer): Integer;
var
  pos: Integer;
begin
  result := 0;

  pos := r * curMapNode.Cols + c;

  if (c > 0) and (map_Board[r * curMapNode.Cols + c - 1] = WallCell) then
    result := result or MapDir[curMapNode.Trun, 0];  // ����ǽ��
  if (r > 0) and (map_Board[(r - 1) * curMapNode.Cols + c] = WallCell) then
    result := result or MapDir[curMapNode.Trun, 1];  // ����ǽ��
  if (c < curMapNode.Cols - 1) and (map_Board[r * curMapNode.Cols + c + 1] = WallCell) then
    result := result or MapDir[curMapNode.Trun, 2];  // ����ǽ��
  if (r < curMapNode.Rows - 1) and (map_Board[(r + 1) * curMapNode.Cols + c] = WallCell) then
    result := result or MapDir[curMapNode.Trun, 3];  // ����ǽ��

  if ((result = MapDir[curMapNode.Trun, 4]) or (result = MapDir[curMapNode.Trun, 5]) or (result = MapDir[curMapNode.Trun, 6]) or (result = 15)) and (c > 0) and (r > 0) and (map_Board[pos - curMapNode.Cols - 1] = WallCell) then
    result := result or 16;  // ��Ҫ��ǽ��
end;

// ͳ��ѡ���ڵ���������
function Tmain.GetCountBox(): string;
var
  i, boxNum, GoalNum, BoxGoalNum: Integer;

begin
  boxNum := 0; GoalNum := 0; BoxGoalNum := 0;
  for i := 0 to curMap.MapSize-1 do begin
      if mySettings.isBK then begin         // ����
        if map_Selected_BK[i] then begin
           if mySettings.isJijing then begin                 // ����˫��ģʽ
             if map_Board_BK[i] in [ BoxCell, BoxGoalCell ] then boxNum := boxNum+1;
             if map_Board[i] in [ BoxCell, BoxGoalCell ] then GoalNum := GoalNum+1;
             if (map_Board_BK[i] in [ BoxCell, BoxGoalCell ]) and (map_Board[i] in [ BoxCell, BoxGoalCell ]) then BoxGoalNum := BoxGoalNum+1;
           end else if mySettings.isSameGoal then begin      // ��λ˫��ģʽ
             if map_Board_BK[i] in [ BoxCell, BoxGoalCell ] then boxNum := boxNum+1;
             if map_Board[i] in [ GoalCell, ManGoalCell, BoxGoalCell ] then GoalNum := GoalNum+1;
             if (map_Board_BK[i] in [ BoxCell, BoxGoalCell ]) and (map_Board[i] in [ GoalCell, ManGoalCell, BoxGoalCell ]) then BoxGoalNum := BoxGoalNum+1;
           end else begin                                    // ����ģʽ
             if map_Board_BK[i] in [ BoxCell, BoxGoalCell ] then boxNum := boxNum+1;
             if map_Board_BK[i] in [ GoalCell, ManGoalCell, BoxGoalCell ] then GoalNum := GoalNum+1;
             if map_Board_BK[i] = BoxGoalCell then BoxGoalNum := BoxGoalNum+1;
           end;
        end;
      end else begin
        if map_Selected[i] then begin
           if mySettings.isJijing then begin                 // ����˫��ģʽ   
             if map_Board[i] in [ BoxCell, BoxGoalCell ] then boxNum := boxNum+1;
             if map_Board_BK[i] in [ BoxCell, BoxGoalCell ] then GoalNum := GoalNum+1;
             if (map_Board[i] in [ BoxCell, BoxGoalCell ]) and (map_Board_BK[i] in [ BoxCell, BoxGoalCell ]) then BoxGoalNum := BoxGoalNum+1;
           end else begin                                    // ����ģʽ����λ˫��ģʽ
             if map_Board[i] in [ BoxCell, BoxGoalCell ] then boxNum := boxNum+1;
             if map_Board[i] in [ GoalCell, ManGoalCell, BoxGoalCell ] then GoalNum := GoalNum+1;
             if map_Board[i] = BoxGoalCell then BoxGoalNum := BoxGoalNum+1;
           end;
        end;
      end;
  end;

  result := 'ѡ���ڣ������� = ' + IntToStr(boxNum) + '��  Ŀ���� = '  + IntToStr(GoalNum) + '��  ��������� = '  + IntToStr(BoxGoalNum);

end;

// �Ƚ�ͼԪ���һ������ɫ��ذ����ɫ�Ƿ���ͬ����ȷ���Ƿ񻭸���
procedure Tmain.DrawLine(cs: TCanvas; x1, y1: Integer; isLine: boolean);
begin
  if isLine then
  begin
    cs.Pen.Color := LineColor;
    cs.MoveTo(x1, y1);
    cs.LineTo(x1 + curMap.CellSize, y1);
    cs.MoveTo(x1, y1);
    cs.LineTo(x1, y1 + curMap.CellSize);
  end;
end;

// Ϊѡ���ڵĵ�Ԫ�������ɫ����
procedure ColorChange(SrcBmp: TBitmap);
var
  i, j: integer;
  SrcRGB: pRGBTriple;
  
begin
  SrcBmp.PixelFormat   :=   pf24Bit;
  for i := 0 to SrcBmp.Height - 1 do
  begin
    SrcRGB := SrcBmp.ScanLine[i];
    for j := 0 to SrcBmp.Width - 1 do
    begin
      SrcRGB.rgbtRed := Min(255, 38 + (SrcRGB.rgbtRed div 3) * 2);
      SrcRGB.rgbtGreen := Min(255, (SrcRGB.rgbtGreen div 3) * 2);
      SrcRGB.rgbtBlue := Min(255, 38 + (SrcRGB.rgbtBlue div 3) * 2);
      Inc(SrcRGB);
    end;
  end;
end;

// ���Ƶ�ͼ
procedure Tmain.DrawMap();
var
  i, j, k, dx, dy, myCell, x1, y1, x2, y2, x3, y3, x4, y4, pos, t1, t2, i2, j2, man_Pos_: integer;
  R, R2: TRect;
    
begin
  if (not Assigned(curMapNode)) or (curMapNode.Cols <= 0) then begin
     Exit;
  end;

  if mySettings.isBK and (IsManAccessibleTips_BK or IsBoxAccessibleTips_BK) then map_Image.Cursor := crDrag
  else if (not mySettings.isBK) and (IsManAccessibleTips or IsBoxAccessibleTips) then map_Image.Cursor := crDrag
  else map_Image.Cursor := crDefault;

  map_Image.Visible := false;

  for i := 0 to curMapNode.Rows - 1 do
  begin
    for j := 0 to curMapNode.Cols - 1 do
    begin
      // 0-7, 1-6, 2-5, 3-4, ��Ϊת��
      case (curMapNode.Trun) of  // ���� i2, j2 ģ��ͼԪ�ص���ת������������ô����ת����ʵ���ϵ�ͼʼ�ղ��� -- ����ͼ����ת��Ϊ�Ӿ�����
      1:
        begin
          j2 := curMapNode.Rows - 1 - i;
          i2 := j;
        end;
      2:
        begin
          j2 := curMapNode.Cols - 1 - j;
          i2 := curMapNode.Rows - 1 - i;
        end;
      3:
        begin
          j2 := i;
          i2 := curMapNode.Cols - 1 - j;
        end;
      4:
        begin
          j2 := curMapNode.Cols - 1 - j;
          i2 := i;
        end;
      5:
        begin
          j2 := curMapNode.Rows - 1 - i;
          i2 := curMapNode.Cols - 1 - j;
        end;
      6:
        begin
          j2 := j;
          i2 := curMapNode.Rows - 1 - i;
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

      pos := i * curMapNode.Cols + j;    // ��ͼ�У������ӡ�����ʵλ��

      x1 := j2 * curMap.CellSize;        // x1, y1 �ǵ�ͼԪ�صĻ������� -- ��ת���
      y1 := i2 * curMap.CellSize;

      R := Rect(x1, y1, x1 + curMap.CellSize, y1 + curMap.CellSize);        // ��ͼ���ӵĻ��ƾ���

      if mySettings.isBK then
      begin            // ����
        myCell := map_Board_BK[pos];
        if mySettings.isJijing then
        begin  // ����˫��
          case map_Board[pos] of
            BoxCell, BoxGoalCell:
              case myCell of
                FloorCell:
                  myCell := GoalCell;
                BoxCell:
                  myCell := BoxGoalCell;
                ManCell:
                  myCell := ManGoalCell;
              end;
          else
            case myCell of
              GoalCell:
                myCell := FloorCell;
              BoxGoalCell:
                myCell := BoxCell;
              ManGoalCell:
                myCell := ManCell;
            end;
          end;
        end
        else if mySettings.isSameGoal then
        begin  // ��λ˫��
          case map_Board_OG[pos] of
            GoalCell, BoxGoalCell, ManGoalCell:
              case myCell of
                FloorCell:
                  myCell := GoalCell;
                BoxCell:
                  myCell := BoxGoalCell;
                ManCell:
                  myCell := ManGoalCell;
              end;
            FloorCell, BoxCell, ManCell:
              case myCell of
                GoalCell:
                  myCell := FloorCell;
                BoxGoalCell:
                  myCell := BoxCell;
                ManGoalCell:
                  myCell := ManCell;
              end;
          end;
        end;
      end
      else
      begin
        myCell := map_Board[pos];             // ����
        if mySettings.isJijing then
        begin     // ����˫��
          case map_Board_BK[pos] of
            BoxCell, BoxGoalCell:
              case myCell of
                FloorCell:
                  myCell := GoalCell;
                BoxCell:
                  myCell := BoxGoalCell;
                ManCell:
                  myCell := ManGoalCell;
              end;
          else
            case myCell of
              GoalCell:
                myCell := FloorCell;
              BoxGoalCell:
                myCell := BoxCell;
              ManGoalCell:
                myCell := ManCell;
            end;
          end;
        end;
      end;                                                                    

      map_Image.Canvas.CopyMode := SRCCOPY;
      case myCell of
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
              case (curMapNode.Trun) of
                1, 4:
                  begin
                    dx := R.Left + curMap.CellSize div 2;
                    dy := R.Top - curMap.CellSize div 2;
                  end;
                2, 5:
                  begin
                    dx := R.Left + curMap.CellSize div 2;
                    dy := R.Top + curMap.CellSize div 2;
                  end;
                3, 6:
                  begin
                    dx := R.Left - curMap.CellSize div 2;
                    dy := R.Top + curMap.CellSize div 2;
                  end;
              else
                begin
                  dx := R.Left - curMap.CellSize div 2;
                  dy := R.Top - curMap.CellSize div 2;
                end;
              end;
              map_Image.Canvas.StretchDraw(Rect(dx, dy, dx + curMap.CellSize, dy + curMap.CellSize), WallPic_top);
            end;
          end
          else
          begin                 // ��ǽ��
            map_Image.Canvas.StretchDraw(R, WallPic);
          end;
        FloorCell:
          begin
            if mySettings.isOddEven and ((i2 + j2) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, FloorPic2)
            else map_Image.Canvas.StretchDraw(R, FloorPic);
            if not mySettings.isOddEven then DrawLine(map_Image.Canvas, x1, y1, isFloorLine);  // ��������
          end;
        GoalCell:
          begin
            if mySettings.isOddEven and ((i2 + j2) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, GoalPic2)
            else map_Image.Canvas.StretchDraw(R, GoalPic);
            if not mySettings.isOddEven then DrawLine(map_Image.Canvas, x1, y1, isGoalLine);   // ��������
          end;
        BoxCell:
          begin
            if mySettings.isOddEven and ((i2 + j2) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, BoxPic2)
            else map_Image.Canvas.StretchDraw(R, BoxPic);
            if not mySettings.isOddEven then DrawLine(map_Image.Canvas, x1, y1, isBoxLine);    // ��������
          end;
        BoxGoalCell:
          begin
            if mySettings.isOddEven and ((i2 + j2) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, BoxGoalPic2)
            else map_Image.Canvas.StretchDraw(R, BoxGoalPic);
            if not mySettings.isOddEven then DrawLine(map_Image.Canvas, x1, y1, isBoxGoalLine); // ��������
          end;
        ManCell:
          begin
            if mySettings.isOddEven and ((i2 + j2) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, ManPic2)
            else map_Image.Canvas.StretchDraw(R, ManPic);
            if not mySettings.isOddEven then DrawLine(map_Image.Canvas, x1, y1, isManLine);    // ��������
          end;
        ManGoalCell:
          begin
            if mySettings.isOddEven and ((i2 + j2) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, ManGoalPic2)
            else map_Image.Canvas.StretchDraw(R, ManGoalPic);
            if not mySettings.isOddEven then DrawLine(map_Image.Canvas, x1, y1, isManGoalLine); // ��������
          end;
      else
        if mySettings.isBK then
           map_Image.Canvas.Brush.Color := clBlack
        else
           map_Image.Canvas.Brush.Color := clInactiveCaptionText;

        map_Image.Canvas.FillRect(R);
      end;

      // �Ƿ�����ģʽ��
      if mySettings.isBK then
      begin

        map_Image.Canvas.Brush.Style := bsClear;
        map_Image.Canvas.Font.Name := '΢���ź�';
        map_Image.Canvas.Font.Size := 16;
        map_Image.Canvas.Font.Color := clWhite;
        map_Image.Canvas.Font.Style := [];
        if mySettings.isJijing then
           map_Image.Canvas.TextOut(0, 0, '����ģʽ - ����˫��')
        else
           map_Image.Canvas.TextOut(0, 0, '����ģʽ');

        // ���ӱ��
        if mySettings.isNumber then begin
          if (myCell in [ BoxCell, BoxGoalCell ]) and (BoxNum_Board_BK[pos] >= 0) then begin
              map_Image.Canvas.Font.Color := clBlack;
              map_Image.Canvas.Brush.Style := bsClear;
              map_Image.Canvas.Font.Size := Round(curMap.CellSize / 2.5);
              map_Image.Canvas.Font.Style := [fsBold];
              map_Image.Canvas.TextOut(R.Left + curMap.CellSize div 3, R.Top + curMap.CellSize div 5, IntToStr(BoxNum_Board_BK[pos]));
          end else if (myCell in [ FloorCell, GoalCell, ManCell, ManGoalCell ]) and (PosNum_Board_BK[pos] >= 0) then begin    // ͨ��λ��
              map_Image.Canvas.Font.Color := clWhite;
              map_Image.Canvas.Brush.Style := bsClear;
              map_Image.Canvas.Font.Size := Round(curMap.CellSize / 2.5);
              map_Image.Canvas.Font.Style := [fsBold];
              map_Image.Canvas.TextOut(R.Left + curMap.CellSize div 3, R.Top + curMap.CellSize div 5, chr(PosNum_Board_BK[pos]+64));
          end;
        end;

        // �����У���ʾ���������е�λ�ã�������Ϻ�����Ҫ�ص���λ�ã����ԣ���ʾ�����Ա�ο�
        if mySettings.isJijing then man_Pos_ := ManPos
        else man_Pos_ := curMap.ManPosition;

        if (man_Pos_ = i * curMapNode.Cols + j) then
        begin
          map_Image.Canvas.Brush.Color := clRed;  // clFuchsia

          dx := curMap.CellSize div 5;

          for k := 1 to 2 do
          begin
            R2 := Rect(x1 + dx * k, y1 + dx * k, x1 + curMap.CellSize - dx * k, y1 + curMap.CellSize - dx * k);
            map_Image.Canvas.DrawFocusRect(R2);
          end;
        end;

        if IsManAccessibleTips_BK then
        begin   // ��ʾ�˵Ŀɴ���ʾ
          t1 := curMap.CellSize div 6;
          if t1 < 4 then t1 := 4;
          t2 := t1 - 1;
          if PathFinder.isManReachableByThrough_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.FillRect(Rect(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1));
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.FillRect(Rect(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2));
          end
          else if PathFinder.isManReachable_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2);
          end
          else if PathFinder.isBoxOfThrough_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2);
          end;
        end;
        if IsBoxAccessibleTips_BK then
        begin   // ��ʾ���ӵĿɴ���ʾ
          t1 := curMap.CellSize div 6;
          if t1 < 4 then t1 := 4;
          t2 := t1 - 1;
          if PathFinder.isBoxReachable_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2);
          end;
        end;
      end
      else                                                                      // ����
      begin
        // ��ʶ��δ���ʵĸ���
        if mySettings.isShowNoVisited and (not map_Board_Visited[pos]) and (map_Board[pos] in [ FloorCell, GoalCell, BoxCell, BoxGoalCell, ManCell, ManGoalCell ]) then begin
           map_Image.Canvas.Pen.Color := clWhite;
           map_Image.Canvas.Pen.Width := 2;
           map_Image.Canvas.MoveTo(R.Left+5, R.Top+5);
           map_Image.Canvas.LineTo(R.Right-5, R.Bottom-5);
           map_Image.Canvas.MoveTo(R.Right-5, R.Top+5);
           map_Image.Canvas.LineTo(R.Left+5, R.Bottom-5);
        end;

        if mySettings.isJijing then
        begin    // ����˫��
          map_Image.Canvas.Brush.Style := bsClear;
          map_Image.Canvas.Font.Name := '΢���ź�';
          map_Image.Canvas.Font.Size := 16;
          map_Image.Canvas.Font.Color := clWhite;
          map_Image.Canvas.Font.Style := [];
          map_Image.Canvas.TextOut(0, 0, '����˫��');
        end;

        // ���ӱ��
        if mySettings.isNumber then begin
          if (myCell in [ BoxCell, BoxGoalCell ]) and (BoxNum_Board[pos] >= 0) then begin
              map_Image.Canvas.Brush.Style := bsClear;
              map_Image.Canvas.Font.Color := clBlack;
              map_Image.Canvas.Font.Size := Round(curMap.CellSize / 2.5);
              map_Image.Canvas.Font.Style := [fsBold];
              map_Image.Canvas.TextOut(R.Left + curMap.CellSize div 3, R.Top + curMap.CellSize div 5, IntToStr(BoxNum_Board[pos]));
          end else if (myCell in [ FloorCell, GoalCell, ManCell, ManGoalCell ]) and (PosNum_Board[pos] >= 0) then begin  // ͨ��λ��
              map_Image.Canvas.Brush.Style := bsClear;
              map_Image.Canvas.Font.Color := clWhite;
              map_Image.Canvas.Font.Size := Round(curMap.CellSize / 2.5);
              map_Image.Canvas.Font.Style := [fsBold];
              map_Image.Canvas.TextOut(R.Left + curMap.CellSize div 3, R.Top + curMap.CellSize div 5, chr(PosNum_Board[pos]+64));
          end;
        end;

        if mySettings.isJijing then begin
          if (ManPos_BK = i * curMapNode.Cols + j) then
          begin
            map_Image.Canvas.Brush.Color := clRed;  // clFuchsia

            dx := curMap.CellSize div 5;

            for k := 1 to 2 do
            begin
              R2 := Rect(x1 + dx * k, y1 + dx * k, x1 + curMap.CellSize - dx * k, y1 + curMap.CellSize - dx * k);
              map_Image.Canvas.DrawFocusRect(R2);
            end;
          end;
        end;

        if IsManAccessibleTips then
        begin   // ��ʾ�˵Ŀɴ���ʾ
          t1 := curMap.CellSize div 6;
          if t1 < 4 then t1 := 4;
          t2 := t1 - 1;
          if PathFinder.isManReachableByThrough(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.FillRect(Rect(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1));
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.FillRect(Rect(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2));
          end
          else if PathFinder.isManReachable(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2);
          end
          else if PathFinder.isBoxOfThrough(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2);
          end;
        end;
        if IsBoxAccessibleTips then
        begin   // ��ʾ���ӵĿɴ���ʾ
          t1 := curMap.CellSize div 6;
          if t1 < 4 then t1 := 4;
          t2 := t1 - 1;
          if PathFinder.isBoxReachable(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2);
          end;
        end;
      end;
    end;
  end;

  // �Ƿ񲻺ϸ�Ĺؿ� XSB
  if curMapNode.isEligible then begin
     if mySettings.isBK then begin
        if curMap.Recording_BK then begin
           map_Image.Canvas.Brush.Style := bsClear;
           map_Image.Canvas.Font.Name := '΢���ź�';
           map_Image.Canvas.Font.Size := 16;
           map_Image.Canvas.Font.Color := clWhite;
           map_Image.Canvas.Font.Style := [];
           map_Image.Canvas.TextOut(map_Image.Width-130, 0, '����¼����...');
           map_Image.Canvas.TextOut(map_Image.Width-130, 25, '��ʼ�㣺' + IntToStr(curMap.StartPos_BK));
        end;
     end else begin
        if curMap.Recording then begin
           map_Image.Canvas.Brush.Style := bsClear;
           map_Image.Canvas.Font.Name := '΢���ź�';
           map_Image.Canvas.Font.Size := 16;
           map_Image.Canvas.Font.Color := clWhite;
           map_Image.Canvas.Font.Style := [];
           map_Image.Canvas.TextOut(map_Image.Width-130, 0, '����¼����...');
           map_Image.Canvas.TextOut(map_Image.Width-130, 25, '��ʼ�㣺' + IntToStr(curMap.StartPos));
        end;
     end;

  end else begin      // ���ϸ�
    map_Image.Canvas.Brush.Style := bsClear;
    map_Image.Canvas.Font.Name := '΢���ź�';
    map_Image.Canvas.Font.Size := 16;
    map_Image.Canvas.Font.Color := clWhite;
    map_Image.Canvas.Font.Style := [];
    map_Image.Canvas.TextOut(map_Image.Width-130, 0, '���ϸ�Ĺؿ�');
//    Caption := IntToStr(map_Image.Left) + ', ' + IntToStr(map_Image.Top);
  end;

  if isSelectMod then begin
     // ͻ����ѡ�еĵ�Ԫ��
     R2 := Rect(0, 0, curMap.CellSize, curMap.CellSize);
     map_Image.Canvas.Pen.Color := $00FF66;   // �߿��ߵ���ɫ
     map_Image.Canvas.Pen.Width := 3;

//     map_Image.Canvas.CopyMode := PATPAINT;
     for i := 0 to curMapNode.Rows - 1 do
     begin
       for j := 0 to curMapNode.Cols - 1 do
       begin
         pos := i * curMapNode.Cols + j;    // ��ͼ�У������ӡ�����ʵλ��

       if (mySettings.isBK and map_Selected_BK[pos]) or (not mySettings.isBK and map_Selected[pos]) then begin
            // 0-7, 1-6, 2-5, 3-4, ��Ϊת��
            case (curMapNode.Trun) of  // ���� i2, j2 ģ��ͼԪ�ص���ת������������ô����ת����ʵ���ϵ�ͼʼ�ղ��� -- ����ͼ����ת��Ϊ�Ӿ�����
            1:
              begin
                j2 := curMapNode.Rows - 1 - i;
                i2 := j;
                x1 := j2 * curMap.CellSize + curMap.CellSize;        // x1, y1, x2, y2 Ϊ�߿��ߵ��ĸ�����
                y1 := i2 * curMap.CellSize;
                x2 := x1;
                y2 := y1 + curMap.CellSize;
                x3 := x1 - curMap.CellSize;
                y3 := y1 + curMap.CellSize;
                x4 := x1 - curMap.CellSize;
                y4 := y1;
              end;
            2:
              begin
                j2 := curMapNode.Cols - 1 - j;
                i2 := curMapNode.Rows - 1 - i;
                x1 := j2 * curMap.CellSize + curMap.CellSize;        // x1, y1, x2, y2 Ϊ�߿��ߵ��ĸ�����
                y1 := i2 * curMap.CellSize + curMap.CellSize;
                x2 := x1 - curMap.CellSize;
                y2 := y1;
                x3 := x1 - curMap.CellSize;
                y3 := y1 - curMap.CellSize;
                x4 := x1;
                y4 := y1 - curMap.CellSize;
              end;
            3:
              begin
                j2 := i;
                i2 := curMapNode.Cols - 1 - j;
                x1 := j2 * curMap.CellSize;                          // x1, y1, x2, y2 Ϊ�߿��ߵ��ĸ�����
                y1 := i2 * curMap.CellSize + curMap.CellSize;
                x2 := x1;
                y2 := y1 - curMap.CellSize;
                x3 := x1 + curMap.CellSize;
                y3 := y1 - curMap.CellSize;
                x4 := x1 + curMap.CellSize;
                y4 := y1;
              end;
            4:
              begin
                j2 := curMapNode.Cols - 1 - j;
                i2 := i;
                x1 := j2 * curMap.CellSize + curMap.CellSize;        // x1, y1, x2, y2 Ϊ�߿��ߵ��ĸ�����
                y1 := i2 * curMap.CellSize;
                x2 := x1 - curMap.CellSize;
                y2 := y1;
                x3 := x1 - curMap.CellSize;
                y3 := y1 + curMap.CellSize;
                x4 := x1;
                y4 := y1 + curMap.CellSize;
              end;
            5:
              begin
                j2 := curMapNode.Rows - 1 - i;
                i2 := curMapNode.Cols - 1 - j;
                x1 := j2 * curMap.CellSize + curMap.CellSize;        // x1, y1, x2, y2 Ϊ�߿��ߵ��ĸ�����
                y1 := i2 * curMap.CellSize + curMap.CellSize;
                x2 := x1;
                y2 := y1 - curMap.CellSize;
                x3 := x1 - curMap.CellSize;
                y3 := y1 - curMap.CellSize;
                x4 := x1 - curMap.CellSize;
                y4 := y1;
             end;
            6:
              begin
                j2 := j;
                i2 := curMapNode.Rows - 1 - i;
                x1 := j2 * curMap.CellSize;                         // x1, y1, x2, y2 Ϊ�߿��ߵ��ĸ�����
                y1 := i2 * curMap.CellSize + curMap.CellSize;
                x2 := x1 + curMap.CellSize;
                y2 := y1;
                x3 := x1 + curMap.CellSize;
                y3 := y1 - curMap.CellSize;
                x4 := x1;
                y4 := y1 - curMap.CellSize;
              end;
            7:
              begin
                j2 := i;
                i2 := j;
                x1 := j2 * curMap.CellSize;                        // x1, y1, x2, y2 Ϊ�߿��ߵ��ĸ�����
                y1 := i2 * curMap.CellSize;
                x2 := x1;
                y2 := y1 + curMap.CellSize;
                x3 := x1 + curMap.CellSize;
                y3 := y1 + curMap.CellSize;
                x4 := x1 + curMap.CellSize;
                y4 := y1;
              end;
            else
              begin
                j2 := j;
                i2 := i;
                x1 := j2 * curMap.CellSize;                       // x1, y1, x2, y2 Ϊ�߿��ߵ��ĸ�����
                y1 := i2 * curMap.CellSize;
                x2 := x1 + curMap.CellSize;
                y2 := y1;
                x3 := x1 + curMap.CellSize;
                y3 := y1 + curMap.CellSize;
                x4 := x1;
                y4 := y1 + curMap.CellSize;
              end;
            end;
            
            R := Rect(j2 * curMap.CellSize, i2 * curMap.CellSize, (j2+1) * curMap.CellSize, (i2+1) * curMap.CellSize);        // ��ͼ���ӵĻ��ƾ���
            MaskPic.Canvas.CopyRect(R2, map_Image.Canvas, R);
            ColorChange(MaskPic);
            map_Image.Canvas.CopyRect(R, MaskPic.Canvas, R2);

            // ���ϸ���ѡ���ڣ����ϱ���
            if (i = 0) or (mySettings.isBK and not map_Selected_BK[pos-curMapNode.Cols]) or (not mySettings.isBK and not map_Selected[pos-curMapNode.Cols]) then begin
                map_Image.Canvas.MoveTo(x1, y1);
                map_Image.Canvas.LineTo(x2, y2);
            end;
            // ���¸���ѡ���ڣ����±���
            if (i+1 = curMapNode.Rows) or (mySettings.isBK and not map_Selected_BK[pos+curMapNode.Cols]) or (not mySettings.isBK and not map_Selected[pos+curMapNode.Cols]) then begin
                map_Image.Canvas.MoveTo(x4, y4);
                map_Image.Canvas.LineTo(x3, y3);
            end;
            // �������ѡ���ڣ��������
            if (j = 0) or (mySettings.isBK and not map_Selected_BK[pos-1]) or (not mySettings.isBK and not map_Selected[pos-1]) then begin
                map_Image.Canvas.MoveTo(x1, y1);
                map_Image.Canvas.LineTo(x4, y4);
            end;
            // ���Ҹ���ѡ���ڣ����ұ���
            if (j+1 = curMapNode.Cols) or (mySettings.isBK and not map_Selected_BK[pos+1]) or (not mySettings.isBK and not map_Selected[pos+1]) then begin
                map_Image.Canvas.MoveTo(x2, y2);
                map_Image.Canvas.LineTo(x3, y3);
            end;
         end;
       end;
     end;

     map_Image.Canvas.CopyMode := SRCCOPY;

     // ��ʾ��ǰѡ�񽹵��
     if isSelecting then begin
        j := Min(LeftTopXY.X, RightBottomXY.X);
        i := Min(LeftTopXY.Y, RightBottomXY.Y);
        j2 := Max(LeftTopXY.X, RightBottomXY.X);
        i2 := Max(LeftTopXY.Y, RightBottomXY.Y);
        
        R2 := Rect(j * curMap.CellSize, i * curMap.CellSize, (j2+1) * curMap.CellSize, (i2+1) * curMap.CellSize);
        map_Image.Canvas.Brush.Color := clWhite;
        map_Image.Canvas.FrameRect(R2);
     end;
     
     StatusBar1.Panels[7].Text := GetCountBox();
  end;

  map_Image.Visible := true;
  
  ShowStatusBar();
end;

procedure Tmain.FormCreate(Sender: TObject);
var
  sldb: TSQLiteDatabase;
  sSQL: String;
begin

{$IFDEF DEBUG}
   LogFileInit('BoxMan.log');
{$ENDIF}

{$IFDEF LASTACT}
   LogFileInit_('Motions.log');
{$ENDIF}

  DragAcceptFiles(Handle,True);            // �϶��ĵ������򴰿�

  bt_LeftBar.Hint      := '��ʾ������������: ��H��';

  bt_GoThrough.Caption := '��Խ';
  bt_IM.Caption        := '˲��';
  bt_BK.Caption        := '����';
  bt_OddEven.Caption   := '��ż';
  bt_Skin.Caption      := '����';
  bt_Act.Caption       := '�����༭';
  bt_Save.Caption      := '�����ֳ�';
  pnl_Trun.Caption     := '0ת';

  bt_Open.Hint         := '���ĵ�: ��Ctrl + O��';
  bt_Lately.Hint       := '����򿪵��ĵ�';
  bt_Pre.Hint          := '��һ��: ��PgUp��';
  bt_Next.Hint         := '��һ��: ��PgDn��';
  bt_UnDo.Hint         := '����: ��Z��';
  bt_ReDo.Hint         := '����: ��X��';
  bt_View.Hint         := 'ѡ��ؿ�: ��F3��';
  bt_GoThrough.Hint    := '��Խ����: ��G��';
  bt_IM.Hint           := '˲�ƿ���: ��I��';
  bt_BK.Hint           := '����ģʽ: ��B��';
  bt_OddEven.Hint      := '��ż��λ: ��E��';
  bt_Skin.Hint         := '����Ƥ��: ��F2��';
  bt_Act.Hint          := '�����༭: ��F4��';
  bt_Save.Hint         := '�����ֳ����ؿ�δ�浵ʱ��ͬʱ����ؿ���: ��Ctrl + S��';
  pnl_Trun.Hint        := '��ת�ؿ�: ��*��/��0ת�����α任��������������Ҽ���������Ctri + ��������ҷ�ת��Ctri + �Ҽ���0ת��Shift + ��������·�ת��Shift + �Ҽ���0ת��';
  pnl_Speed.Hint       := '�ı���Ϸ�ٶ�: ��+��-������������';
  sb_Help.Hint         := '��������F1��';
  funMenu.Hint         := '��������:��Alt��';

  StatusBar1.Panels[0].Text := '�ƶ�';
  StatusBar1.Panels[2].Text := '�ƶ�';
  StatusBar1.Panels[4].Text := '���';

  PageControl.Pages[0].Caption := '��';
  PageControl.Pages[1].Caption := '״̬';
  PageControl.Pages[2].Caption := '����';

  pmSolution.Items[0].Caption := '�鿴�ύ�б�';
  pmSolution.Items[1].Caption := '�ύ������';
  pmSolution.Items[2].Caption := '-';
  pmSolution.Items[3].Caption := 'Lurd �����а�';
  pmSolution.Items[4].Caption := 'XSB + Lurd �����а�';
  pmSolution.Items[5].Caption := 'XSB + Lurd ���ĵ�';
  pmSolution.Items[6].Caption := 'XSB + Lurd_All �����а�';
  pmSolution.Items[7].Caption := 'XSB + Lurd_All ���ĵ�';
  pmSolution.Items[8].Caption := 'XSB_All + Lurd_All ���ĵ�';
  pmSolution.Items[9].Caption := '-';
  pmSolution.Items[10].Caption := 'ɾ��';
  pmSolution.Items[11].Caption := 'ɾ��ȫ��';
  pmSolution.Items[12].Caption := '-';
  pmSolution.Items[13].Caption := '�����';

  pmState.Items[0].Caption := '���� Lurd �����а�';
  pmState.Items[1].Caption := '���� Lurd �����а�';
  pmState.Items[2].Caption := 'XSB + Lurd �����а�';
  pmState.Items[3].Caption := 'XSB + Lurd ���ĵ�';
  pmState.Items[4].Caption := '-';
  pmState.Items[5].Caption := 'ɾ��';
  pmState.Items[6].Caption := 'ɾ��ȫ��';

  pmBoardBK.Items[0].Caption := '��λ˫��   ��Ctrl + G��';
  pmBoardBK.Items[1].Caption := '����˫��   ��Ctrl + J��';
  pmBoardBK.Items[2].Caption := '-';
  pmBoardBK.Items[3].Caption := '˫�����   ��Ctrl + N��';
  pmBoardBK.Items[4].Caption := '������ת   ��Ctrl + R��';
  pmBoardBK.Items[5].Caption := '-';
  pmBoardBK.Items[6].Caption := '����ؿ���XSB�� �� ���а�                            ��Ctrl + V��';
  pmBoardBK.Items[7].Caption := '�����ؿ�������������XSB + Lurd�� �� ���а�  ��Ctrl + C��';
  pmBoardBK.Items[8].Caption := '�����ֳ���XSB�� �� ���а�                            ��Ctrl + Alt + C��';
  pmBoardBK.Items[9].Caption := '������ת�� ����BoxMan.xsb��                       ��Ctrl + K��';
  pmBoardBK.Items[10].Caption := '-';
  pmBoardBK.Items[11].Caption := '���붯����Lurd�� �� ���а� - ������        ��Ctrl + L��';
  pmBoardBK.Items[12].Caption := '��������������Lurd�� �� ���а� - ������  ��Ctrl + M��';
  pmBoardBK.Items[13].Caption := '��������������Lurd�� �� ���а�              ��Ctrl + Alt + M��';
  pmBoardBK.Items[14].Caption := '-';
  pmBoardBK.Items[15].Caption  := '���¿�ʼ   ��Esc��';
  pmBoardBK.Items[16].Caption  := '-';
  pmBoardBK.Items[17].Caption  := '¼�ƶ���   ��F9��';
  pmBoardBK.Items[18].Caption := '-';
  pmBoardBK.Items[19].Caption := '������ʾ/��ͣ   ��Home��';
  pmBoardBK.Items[20].Caption := '������ʾ/��ͣ   ��End��';

  pm_Up_Bt.Items[0].Caption := '��һ��              ��PgUp��';
  pm_Up_Bt.Items[1].Caption := '��һ��              ��Ctrl + PgUp��';
  pm_Up_Bt.Items[2].Caption := '��һδ��ؿ�        ��Alt + PgUp��';

  pm_Down_Bt.Items[0].Caption := '��һ��            ��PgDn��';
  pm_Down_Bt.Items[1].Caption := '���һ��          ��Ctrl + PgDn��';
  pm_Down_Bt.Items[2].Caption := '��һδ��ؿ�      ��Alt + PgDn��';

  pm_UnDo_Bt.Items[0].Caption := '��������      ��A��';
  pm_UnDo_Bt.Items[1].Caption := '����          ��Z/�˸��/���֡�';
  pm_UnDo_Bt.Items[2].Caption := '�ؿ�ʼ        ��Ctrl + Home��';

  pm_ReDo_Bt.Items[0].Caption := '��������      ��S��';
  pm_ReDo_Bt.Items[1].Caption := '����          ��X/�ո��/�س���/���֡�';
  pm_ReDo_Bt.Items[2].Caption := '����β        ��Ctrl + End��';


  // һЩ��ԭʼ��Ĭ������
  New(mySettings);
  
  mySettings.myTop := 100;      // �ϴ��˳�ʱ�����ڵ�λ�ü���С
  mySettings.myLeft := 100;
  mySettings.myWidth := 800;
  mySettings.myHeight := 600;
  mySettings.bwTop := 100;      // �ؿ�������ڵ�λ�ü���С�ļ���
  mySettings.bwLeft := 100;
  mySettings.bwWidth := 800;
  mySettings.bwHeight := 600;
  mySettings.mySpeed := 2;        // Ĭ���ƶ��ٶ�
  mySettings.isGoThrough := true; // ��Խ����

  isSelectMod := false;           // �Ƿ񴥶���ѡ��ģʽ -- Ctrl + ���������Ԫ��
  isSelecting := false;           // �Ƿ�������ѡ��ģʽ -- Ctrl + ����϶�

  MaskPic := TBitmap.Create;      // ѡ��Ԫ����ͼ

  DoubleClickPos.X := -1;         // ˫����ͼλ�ó�ʼ��ֵ
  DoubleClickPos.Y := -1;

  AppPath := ExtractFilePath(Application.ExeName);      //GetCurrentDir + '\';   //
  BoxManDBpath := AppPath + 'BoxMan.db';

  sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));

  // ���𰸿��״̬���Ƿ���ڣ��������򴴽�֮
  try
    try
      if not sldb.TableExists('Tab_Solution') then begin
        sSQL := 'CREATE TABLE Tab_Solution ( ' +
                '[ID] INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                '[XSB_CRC32] INTEGER NOT NULL DEFAULT 0, ' +
                '[XSB_CRC_TrunNum] INTEGER NOT NULL DEFAULT 0, ' +
                '[Goals] INTEGER NOT NULL DEFAULT 0, ' +
                '[Sol_CRC32] INTEGER NOT NULL DEFAULT 0, ' +
                '[Moves] INTEGER NOT NULL DEFAULT 0, ' +
                '[Pushs] INTEGER NOT NULL DEFAULT 0, ' +
                '[Sol_Text] TEXT NOT NULL DEFAULT "", ' +
                '[XSB_Text] TEXT NOT NULL DEFAULT "", ' +
                '[Sol_DateTime] TEXT NOT NULL DEFAULT "" )';

        sldb.execsql(sSQL);

        sldb.execsql('CREATE INDEX sol_Index ON Tab_Solution(XSB_CRC32, Goals, Sol_CRC32);');

      end;
//      try
//        sldb.execsql('DROP INDEX sol_Index');
//      except
//      end;
//      sldb.execsql('CREATE INDEX sol_Index ON Tab_Solution(XSB_CRC32, Goals, Sol_CRC32);');
    except
    end;

    try
      if not sldb.TableExists('Tab_State') then begin
        sSQL := 'CREATE TABLE Tab_State ( ' +
                '[ID] INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                '[XSB_CRC32] INTEGER NOT NULL DEFAULT 0, ' +
                '[XSB_CRC_TrunNum] INTEGER NOT NULL DEFAULT 0, ' +
                '[Goals] INTEGER NOT NULL DEFAULT 0, ' +
                '[Act_CRC32] INTEGER NOT NULL DEFAULT 0, ' +
                '[Act_CRC32_BK] INTEGER NOT NULL DEFAULT 0, ' +
                '[Moves] INTEGER NOT NULL DEFAULT 0, ' +
                '[Pushs] INTEGER NOT NULL DEFAULT 0, ' +
                '[Moves_BK] INTEGER NOT NULL DEFAULT 0, ' +
                '[Pushs_BK] INTEGER NOT NULL DEFAULT 0, ' +
                '[Man_X] INTEGER NOT NULL DEFAULT 0, ' +
                '[Man_Y] INTEGER NOT NULL DEFAULT 0, ' +
                '[Act_Text] TEXT NOT NULL DEFAULT "", ' +
                '[Act_Text_BK] TEXT NOT NULL DEFAULT "", ' +
                '[Act_DateTime] TEXT NOT NULL DEFAULT "" )';

        sldb.execsql(sSQL);
      end;
      try
        sldb.execsql('DROP INDEX act_Index');
      except
      end;
      sldb.execsql('CREATE INDEX act_Index ON Tab_State(XSB_CRC32, XSB_CRC_TrunNum, Goals)');
    except

    end;
  finally
    sldb.Free;
  end;

  // ���򴰿���С�ߴ�����
  Constraints.MinHeight := minWindowsHeight;
  Constraints.MinWidth := minWindowsWidth;

  // undo��redo ָ���ʼ��
  UnDoPos := 0;
  ReDoPos := 0;
  UnDoPos_BK := 0;
  ReDoPos_BK := 0;

  LoadSttings();                     // ����������

  N30.Checked := mySettings.isRotate;

  // ������������
  isCommandLine := false;
  if paramcount >= 1 then begin
     isCommandLine := True;
     try
       mySettings.MapFileName := paramstr(1);             // �ؿ��ĵ���
       if paramcount > 1 then
          curMap.CurrentLevel := StrToInt(paramstr(2))    // �ؿ����
       else
          curMap.CurrentLevel := 1;
     except
       curMap.CurrentLevel := 1;
     end;
  end;

  Caption := AppName + AppVer;

  curSkinFileName := mySettings.SkinFileName;      // ��ǰƤ��
  LoadSkinForm := TLoadSkinForm.Create(Application);
  BrowseForm := TBrowseForm.Create(Application);

  // �ָ��ϴ��˳�ʱ�����ڵ�λ�ü���С
  Top := mySettings.myTop;
  Left := mySettings.myLeft;
  Width := mySettings.myWidth;
  Height := mySettings.myHeight;

  MapList := TList.Create;                        // ��ͼ�б�
  SoltionList := TList.Create;                    // ���б�
  StateList := TList.Create;                      // ״̬�б�

  New(curMapNode);

  txtList := TStringList.Create;     // ׼������ؿ��ĵ��ĸ���
       
  curMapNode.Cols := 0;              // ����û�е�ͼʱ���ֱ�����

  // ���ñȽ����ķ�ʽ�����ϴεĹؿ�
  if FileExists(mySettings.MapFileName) then begin

     txtList.loadfromfile(mySettings.MapFileName);

     QuicklyLoadMap(txtList, curMap.CurrentLevel, curMapNode);      // ���ټ����ϴεĹؿ�

     maxNumber := GetMapNumber(txtList);                            // ȡ�����ؿ����

     if curMapNode.Rows > 2 then begin

        mySettings.isXSB_Saved := True;
        ReadQuicklyMap();
        curMapNode.Trun := tmpTrun;
        pnl_Trun.Caption := MapTrun[curMapNode.Trun];

        TLoadMapThread.Create(false);                                       // ������̨�̣߳����ص�ͼ

     end else StatusBar1.Panels[7].Text := '�����ϴε� ' + IntToStr(curMap.CurrentLevel) + ' �Źؿ�ʱ���������� - ' + mySettings.MapFileName;
  end;
        
  SetButton();             // ���ð�ť״̬
  pnl_Speed.Caption := SpeedInf[mySettings.mySpeed];

  KeyPreview := true;
  Edit1.Left := -16;
end;

// ���ð�ť״̬
procedure Tmain.SetButton();
begin
  if mySettings.isGoThrough then
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

  if mySettings.isIM then
  begin
    bt_IM.Font.Color := clBlack;
    bt_IM.Font.Style := bt_IM.Font.Style + [fsBold];
    bt_IM.Down := True;
  end
  else
  begin
    bt_IM.Font.Color := clGray;
    bt_IM.Font.Style := bt_IM.Font.Style - [fsBold];
    bt_IM.Down := False;
  end;

//  StatusBar1.Panels[7].Text := '';
  if mySettings.isBK then
  begin
    pl_Ground.Color := clBlack;
    bt_BK.Font.Color := clBlack;
    bt_BK.Font.Style := bt_BK.Font.Style + [fsBold];
    bt_BK.Down := True;
    if ManPos_BK < 0 then
    begin
      StatusBar1.Panels[7].Text := '����ָ�����˵Ŀ�ʼλ�á�������';
    end;
  end
  else
  begin
    pl_Ground.Color := clInactiveCaptionText;
    bt_BK.Font.Color := clGray;
    bt_BK.Font.Style := bt_BK.Font.Style - [fsBold];
    bt_BK.Down := False;
  end;
end;

// �رճ���
procedure Tmain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ReDoPos := 0;
  ReDoPos_BK := 0;

  SaveSttings();               // ����������

  application.terminate;

{$IFDEF LASTACT}
   LogFileClose_();
{$ENDIF}

{$IFDEF DEBUG}
   LogFileClose();
{$ENDIF}

end;

// �Ƿ���� -- ����
function Tmain.IsComplete(): Boolean;
var
  i, size: integer;

begin
  result := true;

  size := curMap.MapSize;
  for i := 0 to size-1 do
  begin
    if (map_Board[i] = BoxCell) or (map_Board[i] = GoalCell) then
    begin
      result := false;
      Exit;
    end;
  end;
end;

// �Ƿ���� -- ����
function Tmain.IsComplete_BK(): Boolean;
var
  i, size: integer;

begin
  result := true;

  size := curMap.MapSize;
  for i := 0 to size-1 do begin
    if (map_Board_BK[i] = BoxCell) or (map_Board_BK[i] = GoalCell) then
    begin
      result := false;
      Exit;
    end;
  end;
  if (curMap.ManPosition <> ManPos_BK) then begin
    PathFinder.manReachable(true, map_Board_BK, ManPos_BK);
    result := (PathFinder.isManReachable_BK(curMap.ManPosition) or PathFinder.isManReachableByThrough_BK(curMap.ManPosition));
  end;
end;

// �Ƿ��������
function Tmain.IsMeets(ch: Char): Boolean;
var
  i, len, n: integer;
  flg: Boolean;

begin
  Result := False;
  flg := True;

  if (MoveTimes < 1) or (MoveTimes_BK < 1) or (ch in [ 'l', 'r', 'u', 'd' ]) then
    Exit;        // û�����ƻ����ƶ���ʱ������������

  len := curMap.MapSize;
  for i := 0 to len-1 do
  begin
    if (map_Board[i] in [ BoxCell, BoxGoalCell ]) and (not (map_Board_BK[i] in [ BoxCell, BoxGoalCell ])) then
    begin
      Exit;
    end;
  end;

  if (ManPos <> ManPos_BK) then
  begin
    PathFinder.manReachable(true, map_Board_BK, ManPos_BK);
    flg := (PathFinder.isManReachable_BK(ManPos) or PathFinder.isManReachableByThrough_BK(ManPos));
//    flg := myPathFinder.manTo2(false, -1, -1, ManPos div curMapNode.Cols, ManPos mod curMapNode.Cols, ManPos_BK div curMapNode.Cols, ManPos_BK mod curMapNode.Cols);
  end;

  if flg then begin
    Result := True;
     
//     if isBK then bt_BK.Click;    // �л������ƽ���

    // �������ƴ��У�ǰ�����õĿ��ƶ���
    n := 1;
    while n <= UnDoPos_BK do begin
      if UndoList_BK[n] in [ 'L', 'R', 'U', 'D' ] then Break;
      inc(n);
    end;

    ReDoPos := 0;
    for i := n to UnDoPos_BK do
    begin
      if ReDoPos = MaxLenPath then Exit;

      Inc(ReDoPos);
      case UndoList_BK[i] of
        'l':
          RedoList[ReDoPos] := 'r';
        'r':
          RedoList[ReDoPos] := 'l';
        'u':
          RedoList[ReDoPos] := 'd';
        'd':
          RedoList[ReDoPos] := 'u';
        'L':
          RedoList[ReDoPos] := 'R';
        'R':
          RedoList[ReDoPos] := 'L';
        'U':
          RedoList[ReDoPos] := 'D';
        'D':
          RedoList[ReDoPos] := 'U';
      end

    end;

    len := PathFinder.manTo(false, map_Board, ManPos, ManPos_BK);
    for i := 1 to len do
    begin
      if ReDoPos = MaxLenPath then
        Exit;
      Inc(ReDoPos);
      RedoList[ReDoPos] := ManPath[i];
    end;
  end;
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

// ȡ��¼�ƵĶ���
function GetRecording(isBK: Boolean; pos: Integer): string;
begin
   Result := '';

   if isBK then begin
      if UnDoPos_BK >= pos then begin
         if UnDoPos_BK < MaxLenPath then UndoList_BK[UnDoPos_BK+1] := #0;
         Result := Copy(StrPas(@UndoList_BK), Pos, UnDoPos_BK-pos+1);
      end else main.StatusBar1.Panels[7].Text := '��֧��¼�ơ���ʼ�㡱����Ķ�����';
   end else begin
      if UnDoPos >= pos then begin
         if UnDoPos < MaxLenPath then UndoList[UnDoPos+1] := #0;
         Result := Copy(StrPas(@UndoList), Pos, UnDoPos-pos+1);
      end else main.StatusBar1.Panels[7].Text := '��֧��¼�ơ���ʼ�㡱����Ķ�����';
   end;
end;

// �Զ�ִ�С��Ĵ���������
procedure Tmain.DoAct(n:  Integer);
var
  err: Boolean;
  M_X, M_Y: Integer;        // ���������������˵ĳ�ʼλ��
  i, j, k, len: Integer;
  str, Act: string;
  p: TStrings;
  ch: Char;

begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then Exit;
  err := True;
  ActionForm.MemoAct.Lines.Clear;
  case n of
  1:
     try
        ActionForm.MemoAct.Lines.LoadFromFile(AppPath + '\temp\reg1.txt');
        StatusBar1.Panels[7].Text := '���ء��Ĵ��� 1�������ɹ���';
        err := false;
     except
        StatusBar1.Panels[7].Text := '���ء��Ĵ��� 1��ʧ�ܣ�';
     end;
  2:
     try
        ActionForm.MemoAct.Lines.LoadFromFile(AppPath + '\temp\reg2.txt');
        StatusBar1.Panels[7].Text := '���ء��Ĵ��� 2�������ɹ���';
        err := false;
     except
        StatusBar1.Panels[7].Text := '���ء��Ĵ��� 2��ʧ�ܣ�';
     end;
  3:
     try
        ActionForm.MemoAct.Lines.LoadFromFile(AppPath + '\temp\reg3.txt');
        StatusBar1.Panels[7].Text := '���ء��Ĵ��� 3�������ɹ���';
        err := false;
     except
        StatusBar1.Panels[7].Text := '���ء��Ĵ��� 3��ʧ�ܣ�';
     end;
  4:
     try
        ActionForm.MemoAct.Lines.LoadFromFile(AppPath + '\temp\reg4.txt');
        StatusBar1.Panels[7].Text := '���ء��Ĵ��� 4�������ɹ���';
        err := false;
     except
        StatusBar1.Panels[7].Text := '���ء��Ĵ��� 4��ʧ�ܣ�';
     end;
  5:    // ¼�ƶ���
     begin
        if mySettings.isBK then begin      // ����
           if curMap.Recording_BK then begin   // ��¼�ƵĶ�������ġ��Ĵ�����
              curMap.Recording_BK := False;
              DrawMap();
              Act := GetRecording(mySettings.isBK, curMap.StartPos_BK);
              if Length(Act) > 0 then begin
                 ActionForm.MemoAct.Lines.Clear;
                 ActionForm.MemoAct.Lines.Text := Act;
                 bt_Act.Click;
              end;
           end else begin    // ����¼��ģʽ
              if ManPos_BK < 0 then StatusBar1.Panels[7].Text := '����ָ���˵Ŀ�ʼλ��'
              else begin
                 curMap.Recording_BK := True;
                 curMap.StartPos_BK := UndoPos_BK+1;
                 DrawMap();
              end;
           end;
        end else begin                     // ����
           if curMap.Recording then begin   // ��¼�ƵĶ�������ġ��Ĵ�����
              curMap.Recording := False;
              DrawMap();
              Act := GetRecording(mySettings.isBK, curMap.StartPos);
              if Length(Act) > 0 then begin
                 ActionForm.MemoAct.Lines.Clear;
                 ActionForm.MemoAct.Lines.Text := Act;
                 bt_Act.Click;
              end;
           end else begin    // ����¼��ģʽ
              curMap.Recording := True;
              curMap.StartPos := UndoPos+1;
              DrawMap();
           end;
        end;
        Exit;
     end;
  end;

  // ���ص��˶���
  if not err then begin
      len := ActionForm.MemoAct.Lines.Count;

      Act := '';
      for i := 0 to len-1 do begin
          str := StringReplace(ActionForm.MemoAct.Lines[i], #9, '', [rfReplaceAll]);
          str := StringReplace(str, ' ', '', [rfReplaceAll]);
          if (Length(str) > 0) and (not isLurd_2(str)) then begin
             Act := '';
             StatusBar1.Panels[7].Text := '������Ч�Ķ����ַ���';
             Exit;
          end;
          Act := Act + str;
      end;

      // ���������ַ���
      M_X := -1;
      M_Y := -1;
      if mySettings.isBK then begin             // ����
          i := pos('[', str);
          j := pos(']', str);
          if (i > 0) and (j > 0) and (j > i) then begin
             str := copy(str, i+1, j-i-1);
             delete(str, 1, j);
             p := TStringList.Create;

             try
               p.CommaText := str;

               if p.Count = 2 then begin
                  try
                    M_X := strToInt(p[0])-1;
                    M_Y := strToInt(p[1])-1;
                  except
                    M_X := -1;
                    M_Y := -1;
                  end;
               end;
             finally
               if Assigned(p) then begin
                  p.Free;
               end;
             end;
          end else begin
             k := Max(i, j);

             if k > 0 then delete(Act, 1, k);
          end;
      end else begin               // ����
          i := pos('[', str);

          if i > 0 then Act := copy(Act, 1, i-1);
      end;

      // ִ�ж��� - ���ֳ���ת����ǰ�㣬ִ��һ��
      // ��Ϊ����ģʽ���ȼ��һ���˵�λ�����
      if mySettings.isBK then begin
         if ManPos_BK < 0 then begin
            if (M_X < 0) or (M_Y < 0) or (M_X >= curMapNode.Cols) or (M_Y >= curMapNode.Rows) or
               (not (map_Board_BK[M_Y * curMapNode.Cols + M_X] in [ FloorCell, GoalCell ])) then begin
               StatusBar1.Panels[7].Text := '�˵ĳ�ʼλ�ò���ȷ��';
               Exit;
            end;

            // ��ȥ����λ���ϵ���
            for i := 0 to 9999 do begin
               if map_Board_BK[i] = ManCell then map_Board_BK[i] := FloorCell
               else if map_Board_BK[i] = ManGoalCell then map_Board_BK[i] := GoalCell;
            end;

            // ��λ�÷����� 
            ManPos_BK := M_Y * curMapNode.Cols + M_X;
            ManPos_BK_0 := ManPos_BK;
            if map_Board_BK[ManPos_BK] = FloorCell then map_Board_BK[ManPos_BK] := ManCell
            else map_Board_BK[ManPos_BK] := ManGoalCell;
         end;
      end;

      // ���������Ķ�������redo������
      GetLurd(Act, mySettings.isBK);

      // ���ֳ���תת�� redo �еĶ���
      if mySettings.isBK then begin
         for i := 1 to ReDoPos_BK do begin
             ch := RedoList_BK[i];
             case ch of
               'l': ch := ActDir[curMapNode.Trun, 0];
               'u': ch := ActDir[curMapNode.Trun, 1];
               'r': ch := ActDir[curMapNode.Trun, 2];
               'd': ch := ActDir[curMapNode.Trun, 3];
               'L': ch := ActDir[curMapNode.Trun, 4];
               'U': ch := ActDir[curMapNode.Trun, 5];
               'R': ch := ActDir[curMapNode.Trun, 6];
               'D': ch := ActDir[curMapNode.Trun, 7];
             end;
             RedoList_BK[i] := ch;
         end;
      end else begin
         for i := 1 to ReDoPos do begin
             ch := RedoList[i];
             case ch of
               'l': ch := ActDir[curMapNode.Trun, 0];
               'u': ch := ActDir[curMapNode.Trun, 1];
               'r': ch := ActDir[curMapNode.Trun, 2];
               'd': ch := ActDir[curMapNode.Trun, 3];
               'L': ch := ActDir[curMapNode.Trun, 4];
               'U': ch := ActDir[curMapNode.Trun, 5];
               'R': ch := ActDir[curMapNode.Trun, 6];
               'D': ch := ActDir[curMapNode.Trun, 7];
             end;
             RedoList[i] := ch;
         end;
      end;

      // ִ��һ��
      if mySettings.isBK then begin
         ReDo_BK(ReDoPos_BK);
      end else begin
         ReDo(ReDoPos);
      end;

  end;

end;

// ���̰���
procedure Tmain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  frame_w: Integer;
begin
//  Caption := IntToStr(Key);
//  StatusBar1.Panels[7].Text := IntToStr(Key);
  if ed_sel_Map.Focused then begin
     if (Key >= 48) and (Key <= 97) then begin
        Exit;
     end;
  end;
  if (not ((ssShift in Shift) or (ssCtrl in Shift))) then begin
     if (GetKeyState(VK_MENU)<0) then begin
        frame_w := (Width - ClientWidth) div 2;
        pmBoardBK.Popup(Left + funMenu.Left + frame_w + 12, Top + Height - ClientHeight - frame_w + 12);
     end;
  end;
  case Key of
    VK_LEFT:
      begin
        if isMoving then IsStop := True
        else IsStop := False;


        if mySettings.isBK and (ManPos_BK < 0) then Exit;
        
        if mySettings.isBK then
        begin
          ReDoPos_BK := 1;
          if ssCtrl in Shift then
            RedoList_BK[ReDoPos_BK] := getTrun_Act(curMapNode.Trun, 'L')
          else
            RedoList_BK[ReDoPos_BK] := getTrun_Act(curMapNode.Trun, 'l');
          ReDo_BK(ReDoPos_BK)
        end
        else
        begin
          ReDoPos := 1;
          RedoList[ReDoPos] := getTrun_Act(curMapNode.Trun, 'l');
          ReDo(ReDoPos);
        end;
        curMap.isFinish := False;
      end;
    VK_RIGHT:
      begin
        if isMoving then IsStop := True
        else IsStop := False;

        if mySettings.isBK and (ManPos_BK < 0) then
          Exit;
        if mySettings.isBK then
        begin
          ReDoPos_BK := 1;
          if ssCtrl in Shift then
            RedoList_BK[ReDoPos_BK] := getTrun_Act(curMapNode.Trun, 'R')
          else
            RedoList_BK[ReDoPos_BK] := getTrun_Act(curMapNode.Trun, 'r');
          ReDo_BK(ReDoPos_BK)
        end
        else
        begin
          ReDoPos := 1;
          RedoList[ReDoPos] := getTrun_Act(curMapNode.Trun, 'r');
          ReDo(ReDoPos);
        end;
        curMap.isFinish := False;
      end;
    VK_UP:
      begin
        if isMoving then IsStop := True
        else IsStop := False;

        if mySettings.isBK and (ManPos_BK < 0) then
          Exit;
        if mySettings.isBK then
        begin
          ReDoPos_BK := 1;
          if ssCtrl in Shift then
            RedoList_BK[ReDoPos_BK] := getTrun_Act(curMapNode.Trun, 'U')
          else
            RedoList_BK[ReDoPos_BK] := getTrun_Act(curMapNode.Trun, 'u');
          ReDo_BK(ReDoPos_BK)
        end
        else
        begin
          ReDoPos := 1;
          RedoList[ReDoPos] := getTrun_Act(curMapNode.Trun, 'u');
          ReDo(ReDoPos);
        end;
        curMap.isFinish := False;
      end;
    VK_DOWN:
      begin
        if isMoving then IsStop := True
        else IsStop := False;

        if mySettings.isBK and (ManPos_BK < 0) then
          Exit;
        if mySettings.isBK then
        begin
          ReDoPos_BK := 1;
          if ssCtrl in Shift then
            RedoList_BK[ReDoPos_BK] := getTrun_Act(curMapNode.Trun, 'D')
          else
            RedoList_BK[ReDoPos_BK] := getTrun_Act(curMapNode.Trun, 'd');
          ReDo_BK(ReDoPos_BK)
        end
        else
        begin
          ReDoPos := 1;
          RedoList[ReDoPos] := getTrun_Act(curMapNode.Trun, 'd');
          ReDo(ReDoPos);
        end;
        curMap.isFinish := False;
      end;
    VK_F1:                         // F1������
      begin
        ShellExecute(Application.handle, nil, PChar(AppPath + 'BoxManHelp.txt'), nil, nil, SW_SHOWNORMAL);
        ContentClick(Self);
      end;
    VK_F2:                         // F2������Ƥ��
      bt_Skin.Click;
    VK_F3:                         // F3������ؿ�
      bt_View.Click;
    VK_F4:                         // F4�������༭
      bt_Act.Click;
    69:                            // E�� ��ż��Ч��
      if not mySettings.isOddEven then
         bt_OddEvenMouseDown(Self, mbLeft, [], -1, -1);
  end;
  Edit1.SetFocus;  // һ�������ؼ����������뽹���õ�
  Key := 0;
end;

// ����̧��
procedure Tmain.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if ed_sel_Map.Focused then begin
     if (Key >= 48) and (Key <= 97) then begin
        Exit;
     end;
  end;
  case Key of
    69:
      bt_OddEvenMouseUp(Self, mbLeft, [], -1, -1);       // E�� ��ż��Ч��
    VK_F5:                         // F5���Զ����ز�ִ�С��Ĵ��� 1���еĶ���
      DoAct(1);
    VK_F6:                         // F6���Զ����ز�ִ�С��Ĵ��� 1���еĶ���
      DoAct(2);
    VK_F7:                         // F7���Զ����ز�ִ�С��Ĵ��� 3���еĶ���
      DoAct(3);
    VK_F8:                         // F8���Զ����ز�ִ�С��Ĵ��� 4���еĶ���
      DoAct(4);
    VK_F9:                         // F9����ʼ��ֹͣ¼�ƶ���
      DoAct(5);
    VK_PRIOR:               // Page Up����  ��һ��
      begin
        if (ssShift in Shift) or (ssCtrl in Shift) then begin
            N8.Click;
        end else if ssAlt in Shift then begin
            N9.Click;
        end else bt_Pre.Click;
      end;
    VK_NEXT:                // Page Domw������һ��
      begin
        if (ssShift in Shift) or (ssCtrl in Shift) then begin
            N10.Click;
        end else if ssAlt in Shift then begin
            N11.Click;
        end else bt_Next.Click;
    end;
    VK_HOME:    // Home
      begin
        if isMoving then IsStop := True
        else begin
          IsStop := False;

          if (ssCtrl in Shift) then begin     // ���ף�Ctrl + Home -- �ؿ�ʼ
             N16.Click;
          end else begin                      // �����ף�Home  -- ������ʾ
             N21.Click;
          end;
        end;
      end;
    VK_END:    // End
      begin
        if isMoving then IsStop := True
        else begin
          IsStop := False;

          if (ssCtrl in Shift) then begin     // ��β��Ctrl + End -- ֱ�ӽ���
             N19.Click;
          end else begin                      // ����β ��End  -- ������ʾ
             N22.Click;
          end;
        end;
      end;
    27:                         // ESC���ؿ�ʼ
      begin
        if isMoving then IsStop := True
        else begin
           IsStop := false;
           pm_Home.Click;
        end;
      end;
    8:                          // �˸����Undo
      begin
        if isMoving then IsStop := True
        else begin
           IsStop := false;
           bt_UnDo.Click;
        end;
      end;
    32, 13:                         // �ո��/�س�����Redo
      begin
        if isMoving then IsStop := True
        else if (ssCtrl in Shift) or (ssAlt in Shift) or (ssShift in Shift) then begin
        end else begin
           IsStop := false;
           bt_ReDo.Click;
        end;
      end;
    83:                // Ctrl + S
      if ssCtrl in Shift then begin
        bt_Save.Click;
      end else begin
        if isMoving then IsStop := True
        else begin    // S������һ��
           IsStop := false;
           N17.Click;
        end;
      end;
    90:                    // z������
      begin
        if isMoving then IsStop := True
        else begin
           IsStop := false;
           bt_UnDo.Click;
        end;
      end;
    88:                    // x������
      begin
        if isMoving then IsStop := True
        else begin
           IsStop := false;
           bt_ReDo.Click;
        end;
      end;
    65:                     // a������һ��
      begin
        if isMoving then IsStop := True
        else begin
           IsStop := false;
           N14.Click;
        end;
      end;
    75:                // Ctrl + K��������Ĺؿ������뵽�ؿ���ת��
      if ssCtrl in Shift then begin
        XSB0.Click;
      end;
    81:                // Ctrl + Q�� �˳�
      if ssCtrl in Shift then begin
         Close();
      end;
    71:                // Ctrl + G�� ��λ˫��
      if ssCtrl in Shift then begin
         pmGoal.Click;
      end else begin
        bt_GoThrough.Click;
      end;
    74:                // Ctrl + J�� ����˫��
      if ssCtrl in Shift then begin
         pmJijing.Click;
      end;
    76:                // Ctrl + L�� �Ӽ��а���� Lurd
      if ssCtrl in Shift then begin
         Lurd1.Click;
      end;
    77:                // Ctrl + M�� Lurd ������а�; Ctrl + Alt + N�� �������� Lurd ������а�
      if ssCtrl in Shift then begin
         if ssAlt in Shift then Lurd3.Click
         else Lurd2.Click;
      end;
    67:                 // Ctrl + C�� XSB ������а�
      if ssCtrl in Shift then
      begin
        if ssAlt in Shift then XSB4.Click       // �ֳ�
        else XSB2.Click;                        // ԭʼ xsb
      end;
    86:                // Ctrl + V�� �Ӽ��а���� XSB
      if (ssCtrl in Shift) then begin
         XSB1.Click;
      end;
    79:                         // Ctrl + o���򿪹ؿ��ĵ�
      begin
        if isMoving then IsStop := True
        else IsStop := False;

        bt_Open.Click;
      end;
    78:                         // Ctrl + n��˫�����
      N29.Click;
    106, 56:                    // �� 0 ת
      begin
        curMapNode.Trun := 0;
        SetMapTrun;
      end;
    111, 191:                   // ��ת�ؿ�
      begin
        if curMapNode.Trun < 7 then
          inc(curMapNode.Trun)
        else
          curMapNode.Trun := 0; 
        SetMapTrun;
      end;
    72:                         // H����ʾ�����ز����
      begin
        bt_LeftBar.Click;
      end;
    73:                         // I��˲��
      begin
        bt_IM.Click;
      end;
    66:                         // B������ģʽ
      begin
        bt_BK.Click;
      end;
    109, 188, 189:              // -������
      begin
        if mySettings.mySpeed < 4 then
          Inc(mySettings.mySpeed);
        pnl_Speed.Caption := SpeedInf[mySettings.mySpeed];
      end;
    107, 187, 190:              // +������
      begin                      
        if mySettings.mySpeed > 0 then
          Dec(mySettings.mySpeed);
        pnl_Speed.Caption := SpeedInf[mySettings.mySpeed];
      end;
  end;
  Key := 0;
end;

// �ؿ����¿�ʼ
procedure Tmain.Restart(is_BK: Boolean);
begin
    isNoDelay := True;
    if is_BK then begin
       UnDo_BK(UnDoPos_BK);
    end else begin
       UnDo(UnDoPos);
    end;
    isNoDelay := false;
end;

// �������ڴ�С
procedure Tmain.FormResize(Sender: TObject);
begin
  NewMapSize();
  DrawMap();        // ����ͼ
end;

// ˢ��״̬�� - �ƶ������ƶ���
procedure Tmain.ShowStatusBar();
begin
  if mySettings.isBK then
  begin
    StatusBar1.Panels[1].Text := inttostr(MoveTimes_BK);
    StatusBar1.Panels[2].Text := '����';
    StatusBar1.Panels[3].Text := inttostr(PushTimes_BK);
  end
  else
  begin
    StatusBar1.Panels[1].Text := inttostr(MoveTimes);
    StatusBar1.Panels[2].Text := '�ƶ�';
    StatusBar1.Panels[3].Text := inttostr(PushTimes);
  end;
//  StatusBar1.Panels[7].Text := ' ';
end;

// ������
function Tmain.GetCur(x, y: Integer): string;
var
  k: Integer;
begin

  k := x div 26 + 64;

  if (k > 64) then
    Result := chr(k);

  Result := chr(x mod 26 + 65) + IntToStr(y + 1);
end;

// ������ʹ��ĸ���
procedure Tmain.Board_Visited;
var
  i, p, p1: Integer;
  act: Char;
   
begin
  for i := 0 to curMap.MapSize-1 do
      map_Board_Visited[i] := False;

  p := curMap.ManPosition;
  map_Board_Visited[p] := True;
  
  for i := 1 to UnDoPos do begin
      act := UndoList[i];
      case act of
        'l': begin
           p := p-1;
           map_Board_Visited[p] := True;
        end;
        'r': begin
           p := p+1;
           map_Board_Visited[p] := True;
        end;
        'u': begin
           p := p - curMapNode.Cols;
           map_Board_Visited[p] := True;
        end;
        'd': begin
           p := p + curMapNode.Cols;
           map_Board_Visited[p] := True;
        end;
        'L': begin
           p := p-1;
           p1 := p-1;
           map_Board_Visited[p] := True;
           map_Board_Visited[p1] := True;
        end;
        'R': begin
           p := p+1;
           p1 := p+1;
           map_Board_Visited[p] := True;
           map_Board_Visited[p1] := True;
        end;
        'U': begin
           p := p - curMapNode.Cols;
           p1 := p - curMapNode.Cols;
           map_Board_Visited[p] := True;
           map_Board_Visited[p1] := True;
        end;
        'D': begin
           p := p + curMapNode.Cols;
           p1 := p + curMapNode.Cols;
           map_Board_Visited[p] := True;
           map_Board_Visited[p1] := True;
        end;
      end;
  end;
  
  
end;

// ��ͼ��˫�� -- ���ӱ��
procedure Tmain.map_ImageDblClick(Sender: TObject);
var
  pos, myCell, i, j: Integer;
  
begin
  // �������ͼԪλ��
  pos := DoubleClickPos.y * curMapNode.Cols + DoubleClickPos.x;
  if mySettings.isBK then begin   // ����
    myCell := map_Board_BK[pos];
    if myCell in [ BoxCell, BoxGoalCell ] then begin                       // ˫����������
       if BoxNum_Board_BK[pos] > 0 then begin
          BoxNum_Board_BK[pos] := -1;
          Exit;
       end;
       BoxNum_Board_BK[pos] := -1;
    end else if myCell in [ FloorCell, GoalCell, ManCell, ManGoalCell ] then begin  // ˫������ͨ��
       if PosNum_Board_BK[pos] > 0 then begin
          PosNum_Board_BK[pos] := -1;
          Exit;
       end;
       PosNum_Board_BK[pos] := -1;
    end else Exit;                                                        // ˫����������
  end else begin                  // ����
    myCell := map_Board[pos];
    if myCell in [ BoxCell, BoxGoalCell ] then begin                       // ˫����������
       if mySettings.isNumber then begin
         if BoxNum_Board[pos] > 0 then begin
            BoxNum_Board[pos] := -1;
            Exit;
         end;
         BoxNum_Board[pos] := -1;
       end;
    end else if myCell in [ FloorCell, GoalCell, ManCell, ManGoalCell ] then begin  // ˫������ͨ��
       if mySettings.isNumber then begin
         if PosNum_Board[pos] > 0 then begin
            PosNum_Board[pos] := -1;
            Exit;
         end;
         PosNum_Board[pos] := -1;
       end;
    end else if myCell = WallCell then begin  // ˫������ǽ��
       if mySettings.isShowNoVisited then mySettings.isShowNoVisited := False
       else begin
         Board_Visited;
         mySettings.isShowNoVisited := True;
       end;
    end else Exit;
  end;

  if mySettings.isNumber then begin
    if myCell in [ BoxCell, BoxGoalCell ] then begin                      // ˫����������
       i := 1;
       while i <= 9 do begin
           j := 0;
           while j < curMap.MapSize do begin
               if mySettings.isBK then begin    // ����
                  if BoxNum_Board_BK[j] = i then Break;
               end else begin                   // ����
                  if BoxNum_Board[j] = i then Break;
               end;
               inc(j);
           end;
           if j = curMap.MapSize then Break;
           inc(i);
       end;
       if i <= 9 then begin
          if mySettings.isBK then BoxNum_Board_BK[pos] := i     // ����
          else BoxNum_Board[pos] := i;                          // ����
       end;
    end else begin
       i := 1;                                                            // ˫������ͨ��
       while i <= 26 do begin
           j := 0;
           while j < curMap.MapSize do begin
               if mySettings.isBK then begin    // ����
                  if PosNum_Board_BK[j] = i then Break;
               end else begin                   // ����
                  if PosNum_Board[j] = i then Break;
               end;
               inc(j);
           end;
           if j = curMap.MapSize then Break;
           inc(i);
       end;
       if i <= 26 then begin
          if mySettings.isBK then PosNum_Board_BK[pos] := i     // ����
          else PosNum_Board[pos] := i;                          // ����
       end;
    end;
  end;
end;

// �������һ�Ρ�ֱ�ơ�
function Tmain.GetStepLine(is_BK: Boolean): Integer;
var
  k, len: Integer;
  mAct1, mAct2: Char;
begin
  if is_BK then
    len := UnDoPos_BK
  else
    len := UnDoPos;

  mAct1 := #0;
  k := len;
  while k > 0 do begin

    if is_BK then
      mAct1 := UndoList_BK[k]
    else
      mAct1 := UndoList[k];

    k := k-1;

    if mAct1 in ['L', 'U', 'R', 'D'] then Break;
  end;
  while k > 0 do begin

    if is_BK then
      mAct2 := UndoList_BK[k]
    else
      mAct2 := UndoList[k];

    if (mAct2 in ['l', 'u', 'r', 'd']) or (mAct2 <> mAct1) then Break;

    k := k-1;
  end;

  result := len - k;
end;

// ��ͼ�ϵ���
procedure Tmain.map_ImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  MapClickPos: TPoint;
  myCell, pos, x2, y2, k: Integer;
begin
  if (not Assigned(curMapNode)) or (curMap.CellSize = 0) or (not curMapNode.isEligible) then Exit;

  IsStop := true;

  x2 := X div curMap.CellSize;
  y2 := Y div curMap.CellSize;

  if curMapNode.Trun mod 2 = 0 then begin
     LeftTopXY.X := x2;
     LeftTopXY.Y := y2;
     RightBottomXY.X := x2;
     RightBottomXY.Y := y2;
  end else begin
     LeftTopXY.X := y2;
     LeftTopXY.Y := x2;
     RightBottomXY.X := y2;
     RightBottomXY.Y := x2;
  end;

  LeftTopXY.X := x2;
  LeftTopXY.Y := y2;
  RightBottomXY.X := x2;
  RightBottomXY.Y := y2;

  case curMapNode.Trun of // �ѵ����λ�ã�ת����ͼ����ʵ���� -- ���Ӿ�����ת��Ϊ��ͼ����
    1:
      begin
        MapClickPos.X := y2;
        MapClickPos.Y := curMapNode.Rows - 1 - x2;
      end;
    2:
      begin
        MapClickPos.X := curMapNode.Cols - 1 - x2;
        MapClickPos.Y := curMapNode.Rows - 1 - y2;
      end;
    3:
      begin
        MapClickPos.X := curMapNode.Cols - 1 - y2;
        MapClickPos.Y := x2;
      end;
    4:
      begin
        MapClickPos.X := curMapNode.Cols - 1 - x2;
        MapClickPos.Y := y2;
      end;
    5:
      begin
        MapClickPos.X := curMapNode.Cols - 1 - y2;
        MapClickPos.Y := curMapNode.Rows - 1 - x2;
      end;
    6:
      begin
        MapClickPos.X := x2;
        MapClickPos.Y := curMapNode.Rows - 1 - y2;
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

  StatusBar1.Panels[5].Text := ' ' + GetCur(x2, y2) + ' - [ ' + IntToStr(x2 + 1) + ', ' + IntToStr(y2 + 1) + ' ]';       // ���

  // �������ͼԪλ��
  DoubleClickPos.X := MapClickPos.x;      // Ϊ˫����¼λ��
  DoubleClickPos.Y := MapClickPos.y;
  pos := MapClickPos.y * curMapNode.Cols + MapClickPos.x;
  if mySettings.isBK then
    myCell := map_Board_BK[pos]
  else
    myCell := map_Board[pos];

  case Button of
    mbleft:             // ���� -- ָ���
      if ssAlt in Shift then begin     // ����   Alt �� -- ѡ��Ԫ���� -- ������ѡ���У���ȥһ����ѡ��
         if isSelectMod then begin
            isDelSelect := True;
            isSelecting := True;            // �����˵�Ԫ��ѡ��ģʽ -- �϶���ʼ
            
            LeftTopPos.X := MapClickPos.x;
            LeftTopPos.Y := MapClickPos.y;
            RightBottomPos.X := MapClickPos.x;
            RightBottomPos.Y := MapClickPos.y;

            DrawMap();
            
         end;
      end else if ssCtrl in Shift then begin     // ����   Ctrl �� -- ѡ��Ԫ����
         if not isSelectMod then begin  // �״δ���ѡ��ģʽ -- �����ѡ�еĵ�Ԫ��
            for k := 0 to curMap.MapSize-1 do begin
                if mySettings.isBK then map_Selected_BK[k] := False
                else map_Selected[k] := False;
            end;
         end;
         isDelSelect := False;
         isSelectMod := True;            // �����˵�Ԫ��ѡ��ģʽ -- ������
         isSelecting := True;            // �����˵�Ԫ��ѡ��ģʽ -- �϶���ʼ
         LeftTopPos.X := MapClickPos.x;
         LeftTopPos.Y := MapClickPos.y;
         RightBottomPos.X := MapClickPos.x;
         RightBottomPos.Y := MapClickPos.y;

         DrawMap();
         
//         Caption := '[' + IntToStr(LeftTopPos.X) + ', ' + IntToStr(LeftTopPos.Y) + '] -- [' + IntToStr(RightBottomPos.X) + ', ' + IntToStr(RightBottomPos.Y) + ']';
      end else begin                    // û�а� Ctrl �� -- �����Ӷ���
        isSelecting := False;           // ȡ����Ԫ��ѡ��ģʽ -- ������
        isSelectMod := False;           // ȡ����Ԫ��ѡ��ģʽ -- ������
        case myCell of
          FloorCell, GoalCell:
            begin            // �����ذ�
              if mySettings.isBK then
              begin                                            // ����
                if IsBoxAccessibleTips_BK then
                begin                      // �����ӿɴ���ʾʱ
                         // �ӵ��λ���Ƿ�ɴ����
                  if not PathFinder.isBoxReachable_BK(pos) then
                    IsBoxAccessibleTips_BK := False
                  else
                  begin
                    IsBoxAccessibleTips_BK := False;
                    ReDoPos_BK := PathFinder.boxTo(mySettings.isBK, OldBoxPos_BK, pos, ManPos_BK);
                    if ReDoPos_BK > 0 then
                    begin
                      for k := 1 to ReDoPos_BK do
                        RedoList_BK[k] := BoxPath[ReDoPos_BK - k + 1];
                      mySettings.isLurd_Saved := False;             // �����µĶ���
                      curMap.isFinish := False;
                      IsStop := false;
                      ReDo_BK(ReDoPos_BK);
                    end;
                  end;
                end
                else
                begin
                  if (ManPos_BK < 0) or (PushTimes_BK <= 0) then
                  begin                      // �����У������˵Ķ�λ
                    IsManAccessibleTips_BK := False;
                    IsBoxAccessibleTips_BK := False;
                    ReDoPos_BK := 0;
                    UnDoPos_BK := 0;
                    if ManPos_BK >= 0 then
                    begin
                      if map_Board_BK[ManPos_BK] = ManCell then
                        map_Board_BK[ManPos_BK] := FloorCell
                      else
                        map_Board_BK[ManPos_BK] := GoalCell;
                    end;
                    ManPos_BK := MapClickPos.y * curMapNode.Cols + MapClickPos.x;
                    ManPos_BK_0 := ManPos_BK;
                    if map_Board_BK[ManPos_BK] = FloorCell then
                      map_Board_BK[ManPos_BK] := ManCell
                    else
                      map_Board_BK[ManPos_BK] := ManGoalCell;

                    StatusBar1.Panels[7].Text := '';
                  end
                  else
                  begin
                    IsManAccessibleTips_BK := False;
                    IsBoxAccessibleTips_BK := False;
                    ReDoPos_BK := PathFinder.manTo(mySettings.isBK, map_Board_BK, ManPos_BK, pos);   // �����˿ɴ�
                    if ReDoPos_BK > 0 then
                    begin
                      for k := 1 to ReDoPos_BK do
                        RedoList_BK[k] := ManPath[k];
                      IsStop := false;
                      ReDo_BK(ReDoPos_BK);
                    end;
                  end;
                end;
              end
              else
              begin                                                // ����
                if IsBoxAccessibleTips then
                begin                          // �����ӿɴ���ʾʱ
                  // �ӵ��λ���Ƿ�ɴ����
                  if not PathFinder.isBoxReachable(pos) then
                    IsBoxAccessibleTips := False
                  else
                  begin
                    IsBoxAccessibleTips := False;

                    ReDoPos := PathFinder.boxTo(mySettings.isBK, OldBoxPos, pos, ManPos);
                    if ReDoPos > 0 then
                    begin
                      for k := 1 to ReDoPos do
                        RedoList[k] := BoxPath[ReDoPos - k + 1];
                      LastSteps := UnDoPos;              // �������һ�ε���ǰ�Ĳ���
                      mySettings.isLurd_Saved := False;             // �����µĶ���
                      curMap.isFinish := False;
                      IsStop := false;
                      ReDo(ReDoPos);
                    end;
                  end;
                end
                else
                begin
                  IsManAccessibleTips := False;
                  IsBoxAccessibleTips := False;
                  ReDoPos := PathFinder.manTo(mySettings.isBK, map_Board, ManPos, pos);               // �����˿ɴ�
                  if ReDoPos > 0 then
                  begin
                    LastSteps := UnDoPos;              // �������һ�ε���ǰ�Ĳ���
                    for k := 1 to ReDoPos do
                      RedoList[k] := ManPath[k];
                    IsStop := false;
                    ReDo(ReDoPos);
                  end;
                end;
              end;
            end;
          ManCell, ManGoalCell:
            begin           // ������
              if mySettings.isBK then
              begin                                            // ����
                if IsBoxAccessibleTips_BK and PathFinder.isBoxReachable_BK(ManPos_BK) then
                begin  // �����ӿɴ���ʾʱ
                  IsBoxAccessibleTips_BK := False;
                  ReDoPos_BK := PathFinder.boxTo(mySettings.isBK, OldBoxPos_BK, pos, ManPos_BK);
                  if ReDoPos_BK > 0 then
                  begin
                    for k := 1 to ReDoPos_BK do
                      RedoList_BK[k] := BoxPath[ReDoPos_BK - k + 1];
                    mySettings.isLurd_Saved := False;             // �����µĶ���
                    curMap.isFinish := False;
                    IsStop := false;
                    ReDo_BK(ReDoPos_BK);
                  end;
                end
                else if IsManAccessibleTips_BK then
                  IsManAccessibleTips_BK := False  // ����ʾ�˵Ŀɴ���ʾʱ���ֵ������
                else
                begin
                  PathFinder.manReachable(mySettings.isBK, map_Board_BK, ManPos_BK);            // �����˿ɴ�
                  IsManAccessibleTips_BK := True;
                  IsBoxAccessibleTips_BK := False;
                end;
              end
              else
              begin                                                // ����
                if IsBoxAccessibleTips and PathFinder.isBoxReachable(ManPos) then
                begin   // �����ӿɴ���ʾʱ
                  IsBoxAccessibleTips := False;

                  ReDoPos := PathFinder.boxTo(mySettings.isBK, OldBoxPos, pos, ManPos);
                  if ReDoPos > 0 then
                  begin
                    for k := 1 to ReDoPos do
                      RedoList[k] := BoxPath[ReDoPos - k + 1];
                    LastSteps := UnDoPos;              // �������һ�ε���ǰ�Ĳ���
                    mySettings.isLurd_Saved := False;             // �����µĶ���
                    curMap.isFinish := False;
                    IsStop := false;
                    ReDo(ReDoPos);
                  end;
                end
                else if IsManAccessibleTips then
                  IsManAccessibleTips := False        // ����ʾ�˵Ŀɴ���ʾʱ���ֵ������
                else
                begin
                  PathFinder.manReachable(mySettings.isBK, map_Board, ManPos);                  // �����˿ɴ�
                  IsManAccessibleTips := True;
                  IsBoxAccessibleTips := False;
                end;
              end;
            end;
          BoxCell, BoxGoalCell:
            begin           // ��������
              if mySettings.isBK then
              begin                                            // ����
                if ManPos_BK < 0 then
                begin
                  IsStop := false;
                  DrawMap();
                  Exit;
                end
                else
                begin
                  if IsBoxAccessibleTips_BK and (OldBoxPos_BK = pos) then
                    IsBoxAccessibleTips_BK := False
                  else
                  begin
                    IsBoxAccessibleTips_BK := True;
                    IsManAccessibleTips_BK := False;
                    PathFinder.FindBlock(map_Board_BK, pos);                       // ���ݱ���������ӣ�������
                    PathFinder.boxReachable(mySettings.isBK, pos, ManPos_BK);                 // �������ӿɴ�
                    OldBoxPos_BK := pos;
                  end;
                end;
              end
              else
              begin                                                // ����
                if IsBoxAccessibleTips and (OldBoxPos = pos) then
                  IsBoxAccessibleTips := False
                else
                begin
                  IsBoxAccessibleTips := True;
                  IsManAccessibleTips := False;
                  PathFinder.FindBlock(map_Board, pos);                              // ���ݱ���������ӣ�������
                  PathFinder.boxReachable(mySettings.isBK, pos, ManPos);                        // �������ӿɴ�
                  OldBoxPos := pos;
                end;
              end;
            end;
        else
          begin                            // ȡ���ɴ���ʾ
            if mySettings.isBK then
            begin
              IsManAccessibleTips_BK := False;
              IsBoxAccessibleTips_BK := False;
            end
            else
            begin
              IsManAccessibleTips := False;
              IsBoxAccessibleTips := False;
            end;
          end;
        end;
      end;
    mbright:
      begin    // �һ� -- ָ�Ҽ�������һ��ֱ��
         if isMoving then IsStop := True
         else IsStop := False;

         if mySettings.isBK then UnDo_BK(GetStepLine(True))
         else UnDo(GetStepLine(False));
      end;
  end;

  DrawMap();
end;

// ����ڵ�ͼ���ƶ�
procedure Tmain.map_ImageMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  x2, y2: Integer;

begin
  if (not Assigned(curMapNode)) or (curMap.CellSize = 0) or (not curMapNode.isEligible) then Exit;

  x2 := X div curMap.CellSize;
  y2 := Y div curMap.CellSize;

  if curMapNode.Cols > 0 then
    StatusBar1.Panels[5].Text := ' ' + GetCur(x2, y2) + ' - [ ' + IntToStr(x2 + 1) + ', ' + IntToStr(y2 + 1) + ' ]';       // ���

  if isSelecting then begin

      if curMapNode.Trun mod 2 = 0 then begin
         RightBottomXY.X := Min(Max(x2, 0), curMapNode.Cols - 1);
         RightBottomXY.Y := Min(Max(y2, 0), curMapNode.Rows - 1);
      end else begin
         RightBottomXY.X := Min(Max(x2, 0), curMapNode.Rows - 1);
         RightBottomXY.Y := Min(Max(y2, 0), curMapNode.Cols - 1);
      end;

      DrawMap();
  end;
end;

// ��굯��
procedure Tmain.map_ImageMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  MapClickPos: TPoint;
  x2, y2, i, j, i1, j1, i2, j2: Integer;

begin
  Edit1.SetFocus;  // һ�������ؼ����������뽹���õ�

  if (not curMapNode.isEligible) then begin
     Msg.Left := Left + ((Width - Msg.Width + pl_Side.Width) div 2);
     Msg.Top :=  Top + ((Height - Msg.Height) div 2);
     Msg.Show;
  end;
  if (not Assigned(curMapNode)) or (curMap.CellSize = 0) or (not curMapNode.isEligible) then Exit;

  if isDelSelect then begin
     if not (ssAlt in Shift) then begin
        isSelecting := False;           // ȡ����Ԫ��ѡ��ģʽ -- ������
        isDelSelect := False;
        DrawMap();
        Exit;
     end;
  end;

  if isSelecting and (Button = mbleft) then begin
      x2 := X div curMap.CellSize;
      y2 := Y div curMap.CellSize;

      if curMapNode.Trun mod 2 = 0 then begin
         RightBottomXY.X := Min(Max(x2, 0), curMapNode.Cols - 1);
         RightBottomXY.Y := Min(Max(y2, 0), curMapNode.Rows - 1);
      end else begin
         RightBottomXY.X := Min(Max(x2, 0), curMapNode.Rows - 1);
         RightBottomXY.Y := Min(Max(y2, 0), curMapNode.Cols - 1);
      end;
      
      case curMapNode.Trun of // �ѵ����λ�ã�ת����ͼ����ʵ���� -- ���Ӿ�����ת��Ϊ��ͼ����
        1:
          begin
            MapClickPos.X := y2;
            MapClickPos.Y := curMapNode.Rows - 1 - x2;
          end;
        2:
          begin
            MapClickPos.X := curMapNode.Cols - 1 - x2;
            MapClickPos.Y := curMapNode.Rows - 1 - y2;
          end;
        3:
          begin
            MapClickPos.X := curMapNode.Cols - 1 - y2;
            MapClickPos.Y := x2;
          end;
        4:
          begin
            MapClickPos.X := curMapNode.Cols - 1 - x2;
            MapClickPos.Y := y2;
          end;
        5:
          begin
            MapClickPos.X := curMapNode.Cols - 1 - y2;
            MapClickPos.Y := curMapNode.Rows - 1 - x2;
          end;
        6:
          begin
            MapClickPos.X := x2;
            MapClickPos.Y := curMapNode.Rows - 1 - y2;
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

      isSelecting := False;           // ȡ����Ԫ��ѡ��ģʽ -- ������     
      RightBottomPos.X := MapClickPos.x;
      RightBottomPos.Y := MapClickPos.y;

      j1 := Max(0, Min(LeftTopPos.X, RightBottomPos.X));
      i1 := Max(0, Min(LeftTopPos.Y, RightBottomPos.Y));
      j2 := Min(curMapNode.Cols-1, Max(LeftTopPos.X, RightBottomPos.X));
      i2 := Min(curMapNode.Rows-1, Max(LeftTopPos.Y, RightBottomPos.Y));
      for i := i1 to i2 do begin
          for j := j1 to j2 do begin
              if mySettings.isBK then begin
//                if map_Board_BK[i * curMapNode.Cols + j] in [ FloorCell, GoalCell, BoxCell, BoxGoalCell, ManCell, ManGoalCell ] then
                 if isDelSelect then map_Selected_BK[i * curMapNode.Cols + j] := False
                 else map_Selected_BK[i * curMapNode.Cols + j] := True;
              end else begin
//                if map_Board[i * curMapNode.Cols + j] in [ FloorCell, GoalCell, BoxCell, BoxGoalCell, ManCell, ManGoalCell ] then
                 if isDelSelect then map_Selected[i * curMapNode.Cols + j] := False
                 else map_Selected[i * curMapNode.Cols + j] := True;
              end;
          end;
      end;

      DrawMap();
  end;
end;

// ��Ϸ��ʱ
procedure Tmain.GameDelay();
var
  CurTime: dword;
  ch1, ch2: Char;
  
begin
  if isNoDelay then Exit;       // ��Ϊ����ʱ�ƶ���ֱ�ӷ���

  if isKeyPush then begin       // ��Ϊ��ʾ��������ֱ�Ʒ�ʽ˲����ʾ����
    if mySettings.isIM then begin
       try
         if mySettings.isBK then begin
            if (UnDoPos_BK <= 0) or (UnDoPos_BK > MaxLenPath) then ch1 := '~'
            else ch1 := UndoList_BK[UnDoPos_BK];
            if (ReDoPos_BK <= 0) or (ReDoPos_BK > MaxLenPath) then ch2 := '~'
            else ch2 := RedoList_BK[ReDoPos_BK];
         end else begin
            if (UnDoPos <= 0) or (UnDoPos > MaxLenPath) then ch1 := '~'
            else ch1 := UndoList[UnDoPos];
            if (ReDoPos <= 0) or (ReDoPos > MaxLenPath) then ch2 := '~'
            else ch2 := RedoList[ReDoPos];
         end;
         if ch1 = '' then ch1 := '~';
         if ch2 = '' then ch2 := '~';
         if (ch1 in [ 'l', 'r', 'u' ,'d' ]) and (ch2 in [ 'l', 'r', 'u' ,'d'] ) or
            (ch1 in [ 'L', 'R', 'U' ,'D' ]) and (ch1 = ch2)then Exit;

         DrawMap();             // ˢ�µ�ͼ����
       except
       end;
    end;
    StatusBar1.Repaint;
  end else begin              // ���涯����������Ƿ�˲���������Ƿ�ִ����ʱ����
    if mySettings.isIM then
      exit;                   // ˲�ƴ�ʱ
  end;

  CurTime := GetTickCount;    // ��ʱ

  while (GetTickCount - CurTime) < DelayTimes[mySettings.mySpeed] do begin
     if IsStop then Break;
     Application.ProcessMessages;
  end;
end;

procedure Tmain.ContentClick(Sender: TObject);
begin   // ����
//  Application.HelpFile := ChangeFileExt(Application.ExeName, '.HLP');
//  Application.HelpCommand(HELP_FINDER, 0);
end;

// ����״̬
function Tmain.SaveState(): Boolean;
var
  sldb: TSQLiteDatabase;
  sSQL: String;
  i, ActCRC, ActCRC_BK, x, y, size: Integer;
  actNode: ^TStateNode;
  act, act_BK: string;
begin
  Result := False;

  if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then Exit;

  // û���ƶ�����ʱ���������洦��
  if (PushTimes = 0) and (PushTimes_BK = 0) then Exit;

  if MoveTimes > 0 then
    ActCRC := Calcu_CRC_32_2(@UndoList, MoveTimes)
  else
    ActCRC := -1;

  if MoveTimes_BK > 0 then
    ActCRC_BK := Calcu_CRC_32_2(@UndoList_BK, MoveTimes_BK)
  else
    ActCRC_BK := -1;

  if ManPos_BK_0 < 0 then
  begin
    x := -1;
    y := -1;
  end
  else
  begin
    x := ManPos_BK_0 mod curMapNode.Cols;
    y := ManPos_BK_0 div curMapNode.Cols;
  end;

  // ����
  i := 0;
  size := StateList.Count;
  while i < size do
  begin
    actNode := StateList[i];
    if (actNode.CRC32 = ActCRC) and (actNode.Moves = MoveTimes) and (actNode.Pushs = PushTimes) and
       ((ManPos_BK_0 < 0) or (actNode.CRC32_BK = ActCRC_BK) and (actNode.Moves_BK = MoveTimes_BK) and (actNode.Pushs_BK = PushTimes_BK) and (actNode.Man_X = x+1) and (actNode.Man_Y = y+1)) then
      Break;
    inc(i);
  end;
  actNode := nil;

  if i = size then
  begin           // ���ظ�
    if UnDoPos < MaxLenPath then
      UndoList[UnDoPos + 1] := #0;
    act := PChar(@UndoList);

    if UnDoPos_BK < MaxLenPath then
      UndoList_BK[UnDoPos_BK + 1] := #0;
    act_BK := PChar(@UndoList_BK);

    New(actNode);
    actNode.id := -1;
    actNode.DateTime := Now;
    actNode.Moves := MoveTimes;
    actNode.Pushs := PushTimes;
    actNode.CRC32 := ActCRC;
    actNode.Moves_BK := MoveTimes_BK;
    actNode.Pushs_BK := PushTimes_BK;
    actNode.CRC32_BK := ActCRC_BK;

    if (x < 0) or (y < 0) then begin
      actNode.Man_X := -1;
      actNode.Man_Y := -1;
    end else begin
      actNode.Man_X := x+1;
      actNode.Man_Y := y+1;
    end;

    sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));

    try
      try
        if sldb.TableExists('Tab_State') then begin
           sldb.BeginTransaction;

           sSQL := 'INSERT INTO Tab_State (XSB_CRC32, XSB_CRC_TrunNum, Goals, Act_CRC32, Act_CRC32_BK, Moves, Pushs, Moves_BK, Pushs_BK, Man_X, Man_Y, Act_Text, Act_Text_BK, Act_DateTime) ' +
                   'VALUES (' +
                   IntToStr(curMapNode.CRC32) + ',' +
                   IntToStr(curMapNode.CRC_Num) + ',' +
                   IntToStr(curMapNode.Goals) + ',' +
                   IntToStr(actNode.CRC32) + ',' +
                   IntToStr(actNode.CRC32_BK) + ',' +
                   IntToStr(actNode.Moves) + ',' +
                   IntToStr(actNode.Pushs) + ',' +
                   IntToStr(actNode.Moves_BK) + ',' +
                   IntToStr(actNode.Pushs_BK) + ',' +
                   IntToStr(actNode.Man_X) + ',' +
                   IntToStr(actNode.Man_Y) + ', ''' +
                   act + ''', ''' +
                   act_BK + ''', ''' +
                   FormatDateTime(' yyyy-mm-dd hh:nn', actNode.DateTime) + ''' );';

           sldb.ExecSQL(sSQL);

           sldb.Commit;

           actNode.id := sldb.GetLastInsertRowID;

           if actNode.id > 0 then begin

              StateList.Insert(0, actNode);

              // ��ǰ״̬���뵽�б����ǰ��
              List_State.Items.Insert(0, IntToStr(actNode.Pushs) + '/' + IntToStr(actNode.Moves) + #10 + ' [' + IntToStr(actNode.Man_X) + ',' + IntToStr(actNode.Man_Y) + ']' + IntToStr(actNode.Pushs_BK) + '/' + IntToStr(actNode.Moves_BK) + #10 + FormatDateTime(' yyyy-mm-dd hh:nn', actNode.DateTime));

              StatusBar1.Panels[7].Text := '״̬�ѱ��棡';
           end;
        end;
      finally
        sldb.free;
        actNode := nil;
      end;
    except
        MessageBox(handle, '״̬�����' + #10 + '״̬δ�ܱ��棡', '����', MB_ICONERROR or MB_OK);
        Exit;
    end;

  end else begin        // ���ظ�

    // ����״̬�б���Ŀ�Ĵ��� -- ��ǰ״̬�ᵽ��ǰ��
    if i > 0 then begin
      actNode := StateList.Items[i];
      actNode.DateTime := Now;
      StateList.Move(i, 0);
      List_State.Items.Move(i, 0);
      List_State.Items[0] := IntToStr(actNode.Pushs) + '/' + IntToStr(actNode.Moves) + #10 + ' [' + IntToStr(actNode.Man_X) + ',' + IntToStr(actNode.Man_Y) + ']' + IntToStr(actNode.Pushs_BK) + '/' + IntToStr(actNode.Moves_BK) + #10 + FormatDateTime(' yyyy-mm-dd hh:nn', actNode.DateTime);

      sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));

      try
        try
          if sldb.TableExists('Tab_State') then begin
            sldb.BeginTransaction;
            sldb.ExecSQL('UPDATE Tab_State set Act_DateTime = ''' + FormatDateTime(' yyyy-mm-dd hh:nn', actNode.DateTime) + ''' WHERE ID = ' + inttostr(actNode.id));
            sldb.Commit;
          end;
          StatusBar1.Panels[7].Text := '״̬���ظ����ѵ����洢����';
        Finally
          sldb.free;
          actNode := nil;
        end;
      except
        MessageBox(handle, '״̬�����' + #10 + 'δ����ȷ����״̬�Ĵ洢����', '����', MB_ICONERROR or MB_OK);
        Exit;
      end;
    end else StatusBar1.Panels[7].Text := '״̬���б��棡';;
  end;

  PageControl.ActivePageIndex := 1;
  List_State.Selected[0] := True;
  if pl_Side.Visible then List_State.SetFocus;
  mySettings.isLurd_Saved := True;
  Result := True;
end;

// ����ϵͳ�е�����ʱ���ַ�����ת��Ϊ������ʱ�䡱
function MyStrToDate(str: string; SysFrset: TFormatSettings): TDateTime;
var
  s: string;
begin
  s := Copy(str, 1, 4) + '-' + Copy(str, 6, 2) + '-' + Copy(str, 9, 8) + ':00.000';

  Result := StrToDateTime(s, SysFrset);
end;

// ����״̬
function Tmain.LoadState(): Boolean;
var
  sldb: TSQLiteDatabase;
  sltb: TSQLIteTable;
  sSQL: String;
  actNode: ^TStateNode;
  myDateTime: string;
  SysFrset: TFormatSettings;
begin
  Result := False;

  if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then Exit;

  StateListClear(StateList);
  List_State.Clear;

  try
    sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));
    try

      sSQL := 'select * from Tab_State where XSB_CRC32 = ' + IntToStr(curMapNode.CRC32) + ' and XSB_CRC_TrunNum = ' + IntToStr(curMapNode.CRC_Num) + ' and Goals = ' + IntToStr(curMapNode.Goals) + ' order by Act_DateTime desc';

      sltb := slDb.GetTable(sSQL);

      // ��鵱ǰϵͳ�����ڷָ���
      GetLocaleFormatSettings(GetUserDefaultLCID, SysFrset);

      try
         // ����״̬
        if sltb.Count > 0 then begin
          SysFrset.ShortDateFormat:='yyyy-MM-dd';
          SysFrset.DateSeparator:='-';
          SysFrset.LongTimeFormat:='hh:mm:ss.zzz';
          sltb.MoveFirst;
          while not sltb.EOF do begin
            New(actNode);
            actNode.id := sltb.FieldAsInteger(sltb.FieldIndex['ID']);
            myDateTime := sltb.FieldAsString(sltb.FieldIndex['Act_DateTime']);
            actNode.DateTime := MyStrToDate(Trim(myDateTime), SysFrset);
            actNode.Moves := sltb.FieldAsInteger(sltb.FieldIndex['Moves']);
            actNode.Pushs := sltb.FieldAsInteger(sltb.FieldIndex['Pushs']);
            actNode.CRC32 := sltb.FieldAsInteger(sltb.FieldIndex['Act_CRC32']);
            actNode.Moves_BK := sltb.FieldAsInteger(sltb.FieldIndex['Moves_BK']);
            actNode.Pushs_BK := sltb.FieldAsInteger(sltb.FieldIndex['Pushs_BK']);
            actNode.CRC32_BK := sltb.FieldAsInteger(sltb.FieldIndex['Act_CRC32_BK']);
            actNode.Man_X := sltb.FieldAsInteger(sltb.FieldIndex['Man_X']);
            actNode.Man_Y := sltb.FieldAsInteger(sltb.FieldIndex['Man_Y']);

            StateList.Add(actNode);    
            List_State.Items.Add(IntToStr(actNode.Pushs) + '/' + IntToStr(actNode.Moves) + #10 + ' [' + IntToStr(actNode.Man_X) + ',' + IntToStr(actNode.Man_Y) + ']' + IntToStr(actNode.Pushs_BK) + '/' + IntToStr(actNode.Moves_BK) + #10 + FormatDateTime(' yyyy-mm-dd hh:nn', actNode.DateTime));

            actNode := nil;
            sltb.Next;
          end;
        end;
      finally
        sltb.Free;
      end;
    Finally
      actNode := nil;
      sldb.free;
    end;
  except
    StatusBar1.Panels[7].Text := '״̬������ؿ���״̬δ����ȷ���أ�';
    Exit;
  end;

  Result := True;
end;

// �����𰸣�����𰸿� - n=1�����ƹ��أ�n=2��������ϻ����ƹ���
function Tmain.SaveSolution(n: Integer): Boolean;
var
  sldb: TSQLiteDatabase;
  sSQL: String;
  sol: string;
  i, size, solCRC, k, m, p: Integer;
  solNode: ^TSoltionNode;

begin
  Result := False;
  curMapNode.Solved := True;

  if MapList.Count > 0 then begin
     PMapNode(MapList[curMap.CurrentLevel-1])^.Solved := True;
  end;

  // ����� CRC
  if n = 1 then begin      // ���ƹ���
     solCRC := Calcu_CRC_32_2(@UndoList, MoveTimes);
     m := MoveTimes;
     p := PushTimes;
  end else begin           // ������ϻ����ƹ���
     // ������ϻ����ƹ���ʱ�����Ѿ��������� undolist��redolist��
     // ����һ�� ManPath ��������صļ���
     for i := 1 to UnDoPos do begin
         ManPath[i] := UndoList[i];
     end;
     k := UnDoPos;
     for i := ReDoPos downto 1 do begin
         inc(k);
         ManPath[k] := RedoList[i];
     end;
     if k < MaxLenPath then ManPath[k+1] := #0;
     solCRC := Calcu_CRC_32_2(@ManPath, k);
     m := k;
     p := PushTimes;
     for i := 1 to ReDoPos do begin
         if RedoList[i] in [ 'L', 'R', 'U', 'D' ] then Inc(p);
     end;
  end;

  // ����
  i := 0;
  size := SoltionList.Count;
  while i < size do
  begin
    solNode := SoltionList[i];
    if (solNode.CRC32 = solCRC) and (solNode.Moves = m) and (solNode.Pushs = p) then
      Break;
    inc(i);
  end;
  solNode := nil;

  // ���ظ�������𰸿�
  if i = size then
  begin
    if n = 1 then begin      // ���ƹ���
       if UnDoPos < MaxLenPath then UndoList[UnDoPos + 1] := #0;
       sol := PChar(@UndoList);
    end else begin           // ���ƹ��ػ��������
       sol := PChar(@ManPath);
    end;
    New(solNode);
    solNode.id := -1;
    solNode.DateTime := Now;
    solNode.Moves := m;
    solNode.Pushs := p;
    solNode.CRC32 := solCRC;

    sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));

    // ���浽���ݿ�
    try
      try
        if sldb.TableExists('Tab_Solution') then begin
           sldb.BeginTransaction;

           sSQL := 'INSERT INTO Tab_Solution (XSB_CRC32, XSB_CRC_TrunNum, Goals, Sol_CRC32, Moves, Pushs, Sol_Text, XSB_Text, Sol_DateTime) ' +
                   'VALUES (' +
                   IntToStr(curMapNode.CRC32) + ', ' +
                   IntToStr(curMapNode.CRC_Num) + ', ' +
                   IntToStr(curMapNode.Goals) + ', ' +
                   IntToStr(solNode.CRC32) + ', ' +
                   IntToStr(solNode.Moves) + ', ' +
                   IntToStr(solNode.Pushs) + ', ''' +
                   sol + ''', ''' +
                   curMapNode.Map_Thin + ''', ''' +
                   FormatDateTime(' yyyy-mm-dd hh:nn', solNode.DateTime) + ''');';
                   
           sldb.ExecSQL(sSQL);

           sldb.Commit;

           solNode.id := sldb.GetLastInsertRowID;

           if solNode.id > 0 then begin
              SoltionList.Add(solNode);
              List_Solution.Items.Add(IntToStr(p) + '/' + IntToStr(m) + #10 + FormatDateTime(' yyyy-mm-dd hh:nn', solNode.DateTime));
           end;
        end;
      Finally
        sldb.Free;
        solNode := nil;
      end;
    except
      MessageBox(handle, '�𰸿����' + #10 + '��δ�ܱ��棡', '����', MB_ICONERROR or MB_OK);
      exit;
    end;

    Result := True;
  end;

  mySettings.isLurd_Saved := True;
  PageControl.ActivePageIndex := 0;
  if i < size then List_Solution.Selected[i] := True
  else List_Solution.Selected[List_Solution.Count - 1] := True;
  if pl_Side.Visible then List_Solution.SetFocus;
end;

//���ݴ𰸵���ת��������ؿ�ĳ��ת�Ĵ�
procedure Tmain.getANS(ans_num, level_num: Integer; var str: String);
var
  len, k: Integer;
begin
  if (ans_num = level_num) then Exit;

  len := Length(str);
  for k := 1 to len do begin
    case str[k] of
      'l':
        str[k] := ActDir[ Trun8[ans_num, level_num], 0 ];
      'u':
        str[k] := ActDir[ Trun8[ans_num, level_num], 1 ];
      'r':
        str[k] := ActDir[ Trun8[ans_num, level_num], 2 ];
      'd':
        str[k] := ActDir[ Trun8[ans_num, level_num], 3 ];
      'L':
        str[k] := ActDir[ Trun8[ans_num, level_num], 4 ];
      'U':
        str[k] := ActDir[ Trun8[ans_num, level_num], 5 ];
      'R':
        str[k] := ActDir[ Trun8[ans_num, level_num], 6 ];
      'D':
        str[k] := ActDir[ Trun8[ans_num, level_num], 7 ];
    end;
  end;
end;

// ���ش�
function Tmain.LoadSolution(): Boolean;
var
  sldb: TSQLiteDatabase;
  sltb: TSQLIteTable;
  sSQL: String;
  solNode: ^TSoltionNode;
  str, xsbStr, myDateTime: string;
  SysFrset: TFormatSettings;
  t: Integer;
begin
  Result := False;
  if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then Exit;

  SoltionListClear(SoltionList);
  List_Solution.Clear;

  sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));

  // ���ش�
  try
    // ��鵱ǰϵͳ�����ڷָ���
    GetLocaleFormatSettings(GetUserDefaultLCID, SysFrset);
    try
      sSQL := 'select * from Tab_Solution where XSB_CRC32 = ' + IntToStr(curMapNode.CRC32) + ' and Goals = ' + IntToStr(curMapNode.Goals) + ' order by Moves, Pushs';

      sltb := slDb.GetTable(sSQL);

      try
        if sltb.Count > 0 then begin
          SysFrset.ShortDateFormat:='yyyy-MM-dd';
          SysFrset.DateSeparator:='-';
          SysFrset.LongTimeFormat:='hh:mm:ss.zzz';
           // ��ȡ��
          sltb.MoveFirst;
          while not sltb.EOF do begin
            New(solNode);
            solNode.id := sltb.FieldAsInteger(sltb.FieldIndex['ID']);
            myDateTime := sltb.FieldAsString(sltb.FieldIndex['Sol_DateTime']);
            solNode.DateTime := MyStrToDate(Trim(myDateTime), SysFrset);
            solNode.Moves := sltb.FieldAsInteger(sltb.FieldIndex['Moves']);
            solNode.Pushs := sltb.FieldAsInteger(sltb.FieldIndex['Pushs']);
            solNode.CRC32 := sltb.FieldAsInteger(sltb.FieldIndex['Sol_CRC32']);
            str           := sltb.FieldAsString(sltb.FieldIndex['Sol_Text']);
            xsbStr        := sltb.FieldAsString(sltb.FieldIndex['XSB_Text']);
            t             := sltb.FieldAsInteger(sltb.FieldIndex['XSB_CRC_TrunNum']);
            // ����֤
            getANS(t, curMapNode.CRC_Num, str);    // �𰸰��ؿ���ת����ת��
            if isSolution(curMapNode, PChar(str)) then begin
               SoltionList.Add(solNode);
               List_Solution.Items.Add(IntToStr(solNode.Pushs) + '/' + IntToStr(solNode.Moves) + #10 + FormatDateTime(' yyyy-mm-dd hh:nn', solNode.DateTime));
               if xsbStr = '' then begin        // Ϊ�ɰ�𰸲��� XSB_Text
                  sldb.BeginTransaction;
                  sldb.ExecSQL('UPDATE Tab_Solution set XSB_Text = ''' + curMapNode.Map_Thin + ''' WHERE ID = ' + inttostr(solNode.id));
                  sldb.Commit;
               end;
            end;

            solNode := nil;
            sltb.Next;
          end;
        end;
      finally
        sltb.Free;
      end;
    finally
      sldb.Free;
      solNode := nil;
    end;
  except
    StatusBar1.Panels[7].Text := '�𰸿�����ؿ���δ����ȷ���أ�';
    Exit;
  end;

  Result := True;
end;

// ����ָ���ؿ������д�
function Tmain.GetSolution(mapNpde: PMapNode): string;
var
  sldb: TSQLiteDatabase;
  sltb: TSQLIteTable;
  sSQL: String;
  str, Sol_DateTime: string;
  Sol_Moves, Sol_Pushs, t: Integer;

begin
  Result := '';

  sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));
  
  try
    try
      sSQL := 'select * from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNpde.CRC32) + ' and Goals = ' + IntToStr(mapNpde.Goals);

      sltb := slDb.GetTable(sSQL);

      try
        if sltb.Count > 0 then begin
           // ��ȡ��
          sltb.MoveFirst;
          while not sltb.EOF do begin
            Sol_DateTime := sltb.FieldAsString(sltb.FieldIndex['Sol_DateTime']);
            Sol_Moves := sltb.FieldAsInteger(sltb.FieldIndex['Moves']);
            Sol_Pushs := sltb.FieldAsInteger(sltb.FieldIndex['Pushs']);
            str       := sltb.FieldAsString(sltb.FieldIndex['Sol_Text']);
            t         := sltb.FieldAsInteger(sltb.FieldIndex['XSB_CRC_TrunNum']);
            
            // ����֤
            getANS(t, mapNpde.CRC_Num, str);    // �𰸰��ؿ���ת����ת��
            if isSolution(mapNpde, PChar(str)) then begin
               Result := Result + 'Solution (Moves: ' + inttostr(Sol_Moves) + ', Pushs: '+ inttostr(Sol_Pushs) + ', DateTime: ' + Sol_DateTime + '): ' + str + #10;
            end;

            sltb.Next;
          end;
        end;
      finally
        sltb.Free;
      end;
    finally
      sldb.Free;
    end;
  except
    StatusBar1.Panels[7].Text := '�𰸿�����ؿ��Ĵ𰸲�����ȷ���أ�';
    Exit;
  end;
end;

// ����һ�� -- ����
procedure Tmain.ReDo(Steps: Integer);
var
  ch, ch_: Char;
  pos1, pos2: Integer;
  isMeet, IsCompleted: Boolean;
{$IFDEF LASTACT}
  act: string;
{$ENDIF}

begin
  if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then Exit;

  StatusBar1.Panels[7].Text := '';

  isSelectMod := False;
  isMoving := True;                                                             // �ƶ���...

  mySettings.isShowNoVisited := False;                                                           
  IsBoxAccessibleTips := False;
  IsManAccessibleTips := False;
  StatusBar1.Panels[7].Text := '';

  isMeet := False;
  IsCompleted := False;

  try
    while (not IsStop) and (Steps > 0) and (ReDoPos > 0) and (UnDoPos < MaxLenPath) do begin

      // �˵�λ�ó����쳣
      if (ManPos < 0) or (ManPos >= curMap.MapSize) or
         (not (map_Board[ManPos] in [ManCell, ManGoalCell])) then begin
         StatusBar1.Panels[7].Text := format('�˵�λ���쳣��- [%d, %d]', [ManPos mod curMapNode.Cols + 1, ManPos div curMapNode.Cols + 1]);
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
            pos1 := ManPos - curMapNode.Cols;
            pos2 := ManPos - curMapNode.Cols * 2;
            ch := 'u';
          end;
        'd', 'D':
          begin
            pos1 := ManPos + curMapNode.Cols;
            pos2 := ManPos + curMapNode.Cols * 2;
            ch := 'd';
          end;
      end;

      if (pos1 < 0) or (pos1 >= curMap.MapSize) then begin                        // pos1 ����
         StatusBar1.Panels[7].Text := '�����˴���Ķ������ţ�- ' + ch_;
         Break;
      end;

      // �����ذ壬�����ƶ��˼��ɣ����������ӣ���Ҫͬʱ�ƶ����Ӻ��ˣ����������˴���ֱ�ӽ������ε��ƶ�
      if (map_Board[pos1] in [ FloorCell, GoalCell]) then begin                   // pos1 ��ͨ��

         if map_Board[pos1] = FloorCell then map_Board[pos1] := ManCell
         else map_Board[pos1] := ManGoalCell;

      end else if (map_Board[pos1] in [ BoxCell, BoxGoalCell]) then begin         // pos1 ������

        if (pos2 < 0) or (pos2 >= curMap.MapSize) then begin                      // pos2 ����
           StatusBar1.Panels[7].Text := '�����˴���Ķ������ţ�- ' + ch_;
           Break;
        end;

        if (map_Board[pos2] in [ FloorCell, GoalCell]) then begin                 // pos2 ��ͨ��

           if map_Board[pos2] = FloorCell then map_Board[pos2] := BoxCell         // ���ӵ�λ
           else map_Board[pos2] := BoxGoalCell;

           if map_Board[pos1] = BoxCell then map_Board[pos1] := ManCell           // �˵�λ
           else map_Board[pos1] := ManGoalCell;

           ch := Char(Ord(ch) - 32);                                              // ��ɴ�д -- �ƶ�
           BoxNum_Board[pos2] := BoxNum_Board[pos1];                              // �����ӱ��
           BoxNum_Board[pos1] := -1;                                              // ԭ���ӱ��

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

      if (not mySettings.isIM) and (not isNoDelay) then DrawMap();                // ���µ�ͼ��ʾ

      ShowStatusBar();
      StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos mod curMapNode.Cols, ManPos div curMapNode.Cols) + ' - [ ' + IntToStr((ManPos mod curMapNode.Cols) + 1) + ', ' + IntToStr((ManPos div curMapNode.Cols) + 1) + ' ]';       // ���

      Dec(Steps);
      if Steps > 0 then GameDelay();                                              // ��ʱ

      if (not curMap.isFinish) and (ch in [ 'L', 'R', 'U', 'D' ]) and (PushTimes > 0)then begin
        if IsComplete() then                                      // ��سɹ�
        begin
          IsCompleted := True;
          Break;
        end
        else if IsMeets(ch) then
        begin                                                                     // �������
          isMeet := True;
          Break;
        end;
      end;

    end;

    if mySettings.isIM or isNoDelay then DrawMap();                               // ���µ�ͼ��ʾ

    StatusBar1.Repaint;

    if IsCompleted then begin
      ReDoPos := 0;

      // �Զ�����һ�´�
      SaveSolution(1);                                                            // ���ƹ���

      mySettings.isLurd_Saved := True;

      curMap.isFinish := True;
      ShowMyInfo('���ƹ��أ�', '��ϲ');

    end else if isMeet then begin
      // �Զ�����һ�´�
      SaveSolution(2);
      curMap.isFinish := True;                                                    // �������
      ShowMyInfo('������ϣ�', '��ϲ');
    end;
  except
{$IFDEF LASTACT}
   Writeln(myLogFile_, '');
   Writeln(myLogFile_, 'ReDo Error: ');
   Write(myLogFile_, DateTimeToStr(Now));
   Writeln(myLogFile_, '');
   if UnDoPos > 0 then begin
      if UnDoPos < MaxLenPath then UndoList[UnDoPos+1] := #0;
      act := PChar(@UndoList);
      Writeln(myLogFile_, act);
   end;
   Flush(myLogFile_);
{$ENDIF}
  end;
  IsStop    := false;
  isNoDelay := false;                                                           // �Ƿ�Ϊ����ʱ���� -- ���ס���β������
  isKeyPush := false;                                                           // �Ƿ�������ʾ�� -- �ո�����˸�����Ƶ�
  isMoving  := False;
end;

// ����һ�� -- ����
procedure Tmain.UnDo(Steps: Integer);
var
  ch: Char;
  pos1, pos2: Integer;
{$IFDEF LASTACT}
  act: string;
{$ENDIF}
begin
  if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then Exit;

  StatusBar1.Panels[7].Text := '';

  isSelectMod := False;
  isMoving := True;                                                             // �ƶ���...

  mySettings.isShowNoVisited := False;
  IsBoxAccessibleTips := False;
  IsManAccessibleTips := False;
  StatusBar1.Panels[7].Text := '';

  try
    while (not IsStop) and (Steps > 0) and (UnDoPos > 0) and (ReDoPos < MaxLenPath) do begin

      // �˵�λ�ó����쳣
      if (ManPos < 0) or (ManPos >= curMap.MapSize) or
         (not (map_Board[ManPos] in [ManCell, ManGoalCell])) then begin
         StatusBar1.Panels[7].Text := format('�˵�λ���쳣��- [%d, %d]', [ManPos mod curMapNode.Cols + 1, ManPos div curMapNode.Cols + 1]);
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
            pos1 := ManPos - curMapNode.Cols;
            pos2 := ManPos + curMapNode.Cols;
          end;
        'd', 'D':
          begin
            pos1 := ManPos + curMapNode.Cols;
            pos2 := ManPos - curMapNode.Cols;
          end;
      end;

      // ����Ƿ�������ӵ��˻�
      if ch in ['L', 'R', 'U', 'D'] then
      begin

        if (pos1 < 0) or (pos1 >= curMap.MapSize) or                              // ���⣬��
           (pos2 < 0) or (pos2 >= curMap.MapSize) or
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

        BoxNum_Board[ManPos] := BoxNum_Board[pos1];                               // �����ӱ��
        BoxNum_Board[pos1] := -1;                                                 // ԭ���ӱ��

        Dec(PushTimes);                                                           // �ƶ�����
      end
      else
      begin
        if (pos2 < 0) or (pos2 >= curMap.MapSize) or                              // ���⣬��
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

      if (not mySettings.isIM) and (not isNoDelay) then DrawMap();                // ���µ�ͼ��ʾ
      ShowStatusBar();
      StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos mod curMapNode.Cols, ManPos div curMapNode.Cols) + ' - [ ' + IntToStr((ManPos mod curMapNode.Cols) + 1) + ', ' + IntToStr((ManPos div curMapNode.Cols) + 1) + ' ]';       // ���

      Dec(Steps);
      if Steps > 0 then GameDelay();                                              // ��ʱ

    end;

    if mySettings.isIM or isNoDelay then DrawMap();                               // ���µ�ͼ��ʾ

    StatusBar1.Repaint;
  except
{$IFDEF LASTACT}
   Writeln(myLogFile_, '');
   Writeln(myLogFile_, 'UnDo Error: ');
   Write(myLogFile_, DateTimeToStr(Now));
   Writeln(myLogFile_, '');
   if UnDoPos > 0 then begin
      if UnDoPos < MaxLenPath then UndoList[UnDoPos+1] := #0;
      act := PChar(@UndoList);
      Writeln(myLogFile_, act);
   end;
   Flush(myLogFile_);
{$ENDIF}
  end;
  IsStop    := false;
  isNoDelay := false;                                                           // �Ƿ�Ϊ����ʱ���� -- ���ס���β������
  isKeyPush := false;                                                           // �Ƿ�������ʾ�� -- �ո�����˸�����Ƶ�
  isMoving  := False;
end;

// ����һ�� -- ����
procedure Tmain.ReDo_BK(Steps: Integer);
var
  ch: Char;
  i, len, pos1, pos2, n: Integer;
  isOK, isMeet, IsCompleted: Boolean;
{$IFDEF LASTACT}
  act: string;
{$ENDIF}

begin
  if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then Exit;

  StatusBar1.Panels[7].Text := '';
  
  isSelectMod := False;
  isMoving := True;
                                                                                // �ƶ���...
  IsBoxAccessibleTips_BK := False;
  IsManAccessibleTips_BK := False;

  isMeet := False;
  IsCompleted := False;

  try
    while (not IsStop) and (Steps > 0) and (ReDoPos_BK > 0) and (UnDoPos_BK < MaxLenPath) do begin

      // �˵�λ�ó����쳣
      if (ManPos_BK < 0) or (ManPos_BK >= curMap.MapSize) or
         (not (map_Board_BK[ManPos_BK] in [ManCell, ManGoalCell])) then begin
         StatusBar1.Panels[7].Text := format('�˵�λ���쳣��- [%d, %d]', [ManPos_BK mod curMapNode.Cols + 1, ManPos_BK div curMapNode.Cols + 1]);
         Break;
      end;

      ch := RedoList_BK[ReDoPos_BK];

      pos1 := -1;
      pos2 := -1;
      isOK := False;
      case ch of
        'l', 'L':
          begin
            isOK := (ManPos_BK mod curMapNode.Cols) > 0;
            pos1 := ManPos_BK - 1;
            pos2 := ManPos_BK + 1;
          end;
        'r', 'R':
          begin
            isOK := (ManPos_BK mod curMapNode.Cols) < curMapNode.Cols - 1;
            pos1 := ManPos_BK + 1;
            pos2 := ManPos_BK - 1;
          end;
        'u', 'U':
          begin
            isOK := (ManPos_BK div curMapNode.Cols) > 0;
            pos1 := ManPos_BK - curMapNode.Cols;
            pos2 := ManPos_BK + curMapNode.Cols;
          end;
        'd', 'D':
          begin
            isOK := (ManPos_BK div curMapNode.Cols) < curMapNode.Rows - 1;
            pos1 := ManPos_BK + curMapNode.Cols;
            pos2 := ManPos_BK - curMapNode.Cols;
          end;
      end;

      if isOK then
      begin
        if ch in [ 'L', 'R', 'U', 'D' ] then
        begin

          if (pos2 < 0) or (pos2 >= curMap.MapSize) or                              // ���⣬��
             (pos1 < 0) or (pos1 >= curMap.MapSize) or
             (not (map_Board_BK[pos2] in [BoxCell, BoxGoalCell])) or
             (not (map_Board_BK[pos1] in [FloorCell, GoalCell]))then begin
             StatusBar1.Panels[7].Text := '�����˴���Ķ������ţ�- ' + ch;
             Break;
          end;

          if map_Board_BK[pos2] = BoxCell then
            map_Board_BK[pos2] := FloorCell
          else
            map_Board_BK[pos2] := GoalCell;

          if (map_Board_BK[pos1] = FloorCell) then                                // ��һ���ǵذ�
            map_Board_BK[pos1] := ManCell
          else
            map_Board_BK[pos1] := ManGoalCell;

          if map_Board_BK[ManPos_BK] = ManCell then
            map_Board_BK[ManPos_BK] := BoxCell
          else
            map_Board_BK[ManPos_BK] := BoxGoalCell;

          BoxNum_Board_BK[ManPos_BK] := BoxNum_Board_BK[pos2];                    // �����ӱ��
          BoxNum_Board_BK[pos2] := -1;                                            // ԭ���ӱ��

          Inc(PushTimes_BK);                                                      // �ƶ�����
        end
        else
        begin

          if (pos1 < 0) or (pos1 >= curMap.MapSize) or                            // ���⣬��
             (not (map_Board_BK[pos1] in [FloorCell, GoalCell]))then begin
             StatusBar1.Panels[7].Text := '�����˴���Ķ������ţ�- ' + ch;
             Break;
          end;

          // �˵�λ
          if (map_Board_BK[pos1] = FloorCell) then                                // ��һ���ǵذ�
            map_Board_BK[pos1] := ManCell          
          else
            map_Board_BK[pos1] := ManGoalCell;

          if map_Board_BK[ManPos_BK] = ManCell then
            map_Board_BK[ManPos_BK] := FloorCell
          else
            map_Board_BK[ManPos_BK] := GoalCell;
        end;

        Inc(MoveTimes_BK);                                                        // �ƶ�����

        Dec(ReDoPos_BK);
        Inc(UnDoPos_BK);
        UndoList_BK[UnDoPos_BK] := ch;
        ManPos_BK := pos1;                                                        // �˵���λ��

        if (not mySettings.isIM) and (not isNoDelay) then DrawMap();              // ���µ�ͼ��ʾ
        ShowStatusBar();
        StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos_BK mod curMapNode.Cols, ManPos_BK div curMapNode.Cols) + ' - [ ' + IntToStr((ManPos_BK mod curMapNode.Cols) + 1) + ', ' + IntToStr((ManPos_BK div curMapNode.Cols) + 1) + ' ]';       // ���

        Dec(Steps);
        if Steps > 0 then GameDelay();                                            // ��ʱ

        if (not curMap.isFinish) and (ch in [ 'L', 'R', 'U', 'D' ]) and (PushTimes_BK > 0)then begin
          if IsComplete_BK() then begin                                           // ���ƹ���
            IsCompleted := True;                             
            Break;
          end else if IsMeets(ch) then begin                                      // �������
            isMeet := True;
            Break;
          end;
        end;
      end;
    end;

    StatusBar1.Repaint;

    if mySettings.isIM or isNoDelay then DrawMap();                               // ���µ�ͼ��ʾ

    if IsCompleted then begin                                                     // ���ƹ��أ���ת�浽����

      Restart(false);                                                             // ���Ƶ�ͼ��λ
      ReDoPos := 0;

      len := PathFinder.manTo(false, map_Board, ManPos, ManPos_BK);             // ȡ���˵ġ���ϡ�·��

      // ��������ת���ƴ�ʱ�����һ�ƺ������õĿ��ƶ���
      n := 1;
      while n <= UnDoPos_BK do begin
        if UndoList_BK[n] in [ 'L', 'R', 'U', 'D' ] then Break;
        inc(n);
      end;

      // ������undolist_bk�еĶ�����ת�������Ƶ�resolist��
      if len + UnDoPos_BK - n <= MaxLenPath then begin                                                          // �����ƴ�ת��������
        ReDoPos := 0;
        for i := n to UnDoPos_BK do begin
          Inc(ReDoPos);
          case UndoList_BK[i] of
            'l':
              RedoList[ReDoPos] := 'r';
            'r':
              RedoList[ReDoPos] := 'l';
            'u':
              RedoList[ReDoPos] := 'd';
            'd':
              RedoList[ReDoPos] := 'u';
            'L':
              RedoList[ReDoPos] := 'R';
            'R':
              RedoList[ReDoPos] := 'L';
            'U':
              RedoList[ReDoPos] := 'D';
            'D':
              RedoList[ReDoPos] := 'U';
          end
        end;
        // �����˵ġ���ϡ�����
        for i := 1 to len do begin
            Inc(ReDoPos);
            RedoList[ReDoPos] := ManPath[i];
        end;
        // �Զ�����һ�´�
        SaveSolution(2);
        curMap.isFinish := True;
        ShowMyInfo('���ƹ��أ�', '��ϲ');
      end else begin
        SaveState();                                                            // ����ؿ� XSB ���ĵ���״̬�����ݿ�
        ShowMyInfo('���ƹ��أ�' + #10 + '��𰸹���������״̬��ʽ���棡', '��ϲ');
      end;
    end else if isMeet then begin                                                 // �������
      // �Զ�����һ�´�
      SaveSolution(2);
      curMap.isFinish := True;
      ShowMyInfo('������ϣ�', '��ϲ');
    end;
  except
{$IFDEF LASTACT}
   Writeln(myLogFile_, '');
   Writeln(myLogFile_, 'ReDo_BK Error: ');
   Write(myLogFile_, DateTimeToStr(Now));
   Writeln(myLogFile_, '');
   if UnDoPos > 0 then begin
      if UnDoPos < MaxLenPath then UndoList[UnDoPos+1] := #0;
      act := PChar(@UndoList);
      Writeln(myLogFile_, act);
   end;
   Flush(myLogFile_);
{$ENDIF}
  end;
  
  IsStop    := false;
  isNoDelay := false;                                                           // �Ƿ�Ϊ����ʱ���� -- ���ס���β������
  isKeyPush := false;                                                           // �Ƿ�������ʾ�� -- �ո�����˸�����Ƶ�
  isMoving  := False;
end;

// ����һ�� -- ����
procedure Tmain.UnDo_BK(Steps: Integer);
var
  ch: Char;
  pos1, pos2: Integer;
{$IFDEF LASTACT}
  act: string;
{$ENDIF}

begin
  if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then Exit;

  StatusBar1.Panels[7].Text := '';

  isSelectMod := False;
  isMoving := True;                                                             // �ƶ���...
                                                        
  IsBoxAccessibleTips_BK := False;
  IsManAccessibleTips_BK := False;

  try
    while (not IsStop) and (Steps > 0) and (UnDoPos_BK > 0) and (ReDoPos_BK < MaxLenPath) do begin

      // �˵�λ�ó����쳣
      if (ManPos_BK < 0) or (ManPos_BK >= curMap.MapSize) or
         (not (map_Board_BK[ManPos_BK] in [ManCell, ManGoalCell])) then begin
         StatusBar1.Panels[7].Text := format('�˵�λ���쳣��- [%d, %d]', [ManPos_BK mod curMapNode.Cols + 1, ManPos_BK div curMapNode.Cols + 1]);
         Break;
      end;

      ch := UndoList_BK[UnDoPos_BK];

      pos1 := -1;
      pos2 := -1;
      case ch of
        'l', 'L':
          begin
            pos1 := ManPos_BK + 1;
            pos2 := ManPos_BK + 2;
          end;
        'r', 'R':
          begin
            pos1 := ManPos_BK - 1;
            pos2 := ManPos_BK - 2;
          end;
        'u', 'U':
          begin
            pos1 := ManPos_BK + curMapNode.Cols;
            pos2 := ManPos_BK + curMapNode.Cols * 2;
          end;
        'd', 'D':
          begin
            pos1 := ManPos_BK - curMapNode.Cols;
            pos2 := ManPos_BK - curMapNode.Cols * 2;
          end;
      end;

      // ����Ƿ�������ӵĶ���
      if ch in [ 'L', 'R', 'U', 'D' ] then begin

        if (pos2 < 0) or (pos2 >= curMap.MapSize) or                              // ���⣬��
           (pos1 < 0) or (pos1 >= curMap.MapSize) or
           (not (map_Board_BK[pos1] in [BoxCell, BoxGoalCell])) or
           (not (map_Board_BK[pos2] in [FloorCell, GoalCell]))then begin
           StatusBar1.Panels[7].Text := '�����˴���Ķ������ţ�- ' + ch;
           Break;
        end;

        if map_Board_BK[pos1] = BoxCell then
          map_Board_BK[pos1] := ManCell
        else
          map_Board_BK[pos1] := ManGoalCell;

        if (map_Board_BK[pos2] = FloorCell) then
          map_Board_BK[pos2] := BoxCell
        else
          map_Board_BK[pos2] := BoxGoalCell;

        BoxNum_Board_BK[pos2] := BoxNum_Board_BK[pos1];                           // �����ӱ��
        BoxNum_Board_BK[pos1] := -1;                                              // ԭ���ӱ��

        Dec(PushTimes_BK);                                                        // �ƶ�����
      end else begin
        if (pos1 < 0) or (pos1 >= curMap.MapSize) or                              // ���⣬��
           (not (map_Board_BK[pos1] in [FloorCell, GoalCell])) then begin
           StatusBar1.Panels[7].Text := '�����˴���Ķ������ţ�- ' + ch;
           Break;
        end;
        if (map_Board_BK[pos1] = FloorCell) then
          map_Board_BK[pos1] := ManCell
        else
          map_Board_BK[pos1] := ManGoalCell;
      end;

      // �˵��˻�
      if (map_Board_BK[ManPos_BK] = ManCell) then
        map_Board_BK[ManPos_BK] := FloorCell
      else
        map_Board_BK[ManPos_BK] := GoalCell;

      Dec(MoveTimes_BK);                                                          // �ƶ�����

      Dec(UnDoPos_BK);
      Inc(ReDoPos_BK);
      RedoList_BK[ReDoPos_BK] := ch;
      ManPos_BK := pos1;                                                          // �˵���λ��

      if (not mySettings.isIM) and (not isNoDelay) then DrawMap();                // ���µ�ͼ��ʾ
      ShowStatusBar();
      StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos_BK mod curMapNode.Cols, ManPos_BK div curMapNode.Cols) + ' - [ ' + IntToStr((ManPos_BK mod curMapNode.Cols) + 1) + ', ' + IntToStr((ManPos_BK div curMapNode.Cols) + 1) + ' ]';       // ���

      Dec(Steps);
      if Steps > 0 then GameDelay();                                              // ��ʱ

    end;

    StatusBar1.Repaint;

    if mySettings.isIM or isNoDelay then DrawMap();                               // ���µ�ͼ��ʾ
  except
{$IFDEF LASTACT}
   Writeln(myLogFile_, '');
   Writeln(myLogFile_, 'UnDo_BK Error: ');
   Write(myLogFile_, DateTimeToStr(Now));
   Writeln(myLogFile_, '');
   if UnDoPos > 0 then begin
      if UnDoPos < MaxLenPath then UndoList[UnDoPos+1] := #0;
      act := PChar(@UndoList);
      Writeln(myLogFile_, act);
   end;
   Flush(myLogFile_);
{$ENDIF}
  end;
  
  IsStop    := false;
  isNoDelay := false;                                                           // �Ƿ�Ϊ����ʱ���� -- ���ס���β������
  isKeyPush := false;                                                           // �Ƿ�������ʾ�� -- �ո�����˸�����Ƶ�
  isMoving  := False;
end;

// ��һ��
procedure Tmain.bt_PreClick(Sender: TObject);
var
  bt: LongWord;
  tmpMapNode : PMapNode;        // �ؿ��ڵ�

begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (not Assigned(curMapNode)) then begin      //  or (not curMapNode.isEligible)
     StatusBar1.Panels[7].Text := '���޴򿪵Ĺؿ���';
     Exit;
  end;

  ed_sel_Map.SetFocus;
  
  if curMap.CurrentLevel > 1 then
  begin
    if not mySettings.isLurd_Saved then
    begin    // ���µĶ�����δ����
      bt := MessageBox(Handle, '�ոյ��ƶ���δ���棬�Ƿ񱣴棿', '����', MB_ICONWARNING + MB_YESNOCANCEL);
      if bt = idyes then begin
         SaveState();          // ����״̬�����ݿ�
      end else if bt = idno then begin
         mySettings.isLurd_Saved := True;
         StatusBar1.Panels[7].Text := '������������';
      end else exit;
    end;

    if MapList.Count > 0 then begin
      Dec(curMap.CurrentLevel);
      if LoadMap(curMap.CurrentLevel) then
      begin
        InitlizeMap();
        SetMapTrun();
      end;
    end else begin
      New(tmpMapNode);
      try
        QuicklyLoadMap(txtList, curMap.CurrentLevel-1, tmpMapNode);
        if tmpMapNode.Rows > 2 then begin
           curMap.CurrentLevel := curMap.CurrentLevel-1;

           curMapNode.Map_Thin := tmpMapNode.Map_Thin;
           curMapNode.Map := tmpMapNode.Map;
           curMapNode.Rows := tmpMapNode.Rows;
           curMapNode.Cols := tmpMapNode.Cols;
           curMapNode.Boxs := tmpMapNode.Boxs;
           curMapNode.Goals := tmpMapNode.Goals;
           curMapNode.Trun := tmpMapNode.Trun;
           curMapNode.Title := tmpMapNode.Title;
           curMapNode.Author := tmpMapNode.Author;
           curMapNode.Comment := tmpMapNode.Comment;
           curMapNode.CRC32 := tmpMapNode.CRC32;
           curMapNode.CRC_Num := tmpMapNode.CRC_Num;
           curMapNode.Solved := tmpMapNode.Solved;
           curMapNode.isEligible := tmpMapNode.isEligible;
           curMapNode.Num := tmpMapNode.Num;
           
           ReadQuicklyMap();
        end;
      finally
        if Assigned(tmpMapNode) then begin
           MyMapNodeFree(PMapNode(tmpMapNode));
        end;
      end;
    end;
  end
  else
    StatusBar1.Panels[7].Text := 'ǰ��û����!';
end;

// ��һ��
procedure Tmain.bt_NextClick(Sender: TObject);
var
  bt: LongWord;
  tmpMapNode : PMapNode;        // �ؿ��ڵ�
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (not Assigned(curMapNode)) then begin     //   or (not curMapNode.isEligible)
     StatusBar1.Panels[7].Text := '���޴򿪵Ĺؿ���';
     Exit;
  end;

  ed_sel_Map.SetFocus;
  
  if not mySettings.isLurd_Saved then
  begin    // ���µĶ�����δ����
    bt := MessageBox(Handle, '�ոյ��ƶ���δ���棬�Ƿ񱣴棿', '����', MB_ICONWARNING + MB_YESNOCANCEL);
    if bt = idyes then begin
       SaveState();          // ����״̬�����ݿ�
    end else if bt = idno then begin
       mySettings.isLurd_Saved := True;
       StatusBar1.Panels[7].Text := '������������';
    end else exit;
  end;

  if MapList.Count > 0 then begin
    if curMap.CurrentLevel < MapList.Count then begin
      Inc(curMap.CurrentLevel);
      if LoadMap(curMap.CurrentLevel) then
      begin
        InitlizeMap();
        SetMapTrun();
      end;
    end else StatusBar1.Panels[7].Text := '����û����...';
  end else begin
    New(tmpMapNode);
    try
       if curMap.CurrentLevel < maxNumber then begin
         QuicklyLoadMap(txtList, curMap.CurrentLevel+1, tmpMapNode);
         if tmpMapNode.Rows > 2 then begin
            curMap.CurrentLevel := curMap.CurrentLevel+1;
            curMapNode.Map_Thin := tmpMapNode.Map_Thin;
            curMapNode.Map := tmpMapNode.Map;
            curMapNode.Rows := tmpMapNode.Rows;
            curMapNode.Cols := tmpMapNode.Cols;
            curMapNode.Boxs := tmpMapNode.Boxs;
            curMapNode.Goals := tmpMapNode.Goals;
            curMapNode.Trun := tmpMapNode.Trun;
            curMapNode.Title := tmpMapNode.Title;
            curMapNode.Author := tmpMapNode.Author;
            curMapNode.Comment := tmpMapNode.Comment;
            curMapNode.CRC32 := tmpMapNode.CRC32;
            curMapNode.CRC_Num := tmpMapNode.CRC_Num;
            curMapNode.Solved := tmpMapNode.Solved;
            curMapNode.isEligible := tmpMapNode.isEligible;
            curMapNode.Num := tmpMapNode.Num;
            ReadQuicklyMap();
         end;
       end else StatusBar1.Panels[7].Text := '����û����...';
    finally
      if Assigned(tmpMapNode) then begin
         Dispose(PMapNode(tmpMapNode));
         tmpMapNode := nil;
      end;
    end;
  end;
end;

// UnDo ��ť
procedure Tmain.bt_UnDoClick(Sender: TObject);
begin
  N15.Click;
end;

// ReDo��ť
procedure Tmain.bt_ReDoClick(Sender: TObject);
begin
  N18.Click;
end;

// ��Խ����
procedure Tmain.bt_GoThroughClick(Sender: TObject);
begin
  mySettings.isGoThrough := not mySettings.isGoThrough;
  PathFinder.setThroughable(mySettings.isGoThrough);
  SetButton();             // ���ð�ť״̬
end;

// ˲�ƿ���
procedure Tmain.bt_IMClick(Sender: TObject);
begin
  mySettings.isIM := not mySettings.isIM;
  SetButton();             // ���ð�ť״̬
end;

// ����ģʽ����
procedure Tmain.bt_BKClick(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;
  
  mySettings.isShowNoVisited := False;                                                           
  StatusBar1.Panels[7].Text := '';
  mySettings.isBK := not mySettings.isBK;
  DrawMap();
  SetButton();             // ���ð�ť״̬
  if Assigned(curMapNode) and (curMapNode.Cols > 0) then
  begin
    if mySettings.isBK then
    begin
      if ManPos_BK < 0 then
        StatusBar1.Panels[5].Text := ' '
      else
        StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos_BK mod curMapNode.Cols, ManPos_BK div curMapNode.Cols) + ' - [ ' + IntToStr(ManPos_BK mod curMapNode.Cols + 1) + ', ' + IntToStr(ManPos_BK div curMapNode.Cols + 1) + ' ]'       // ���
    end
    else
      StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos mod curMapNode.Cols, ManPos div curMapNode.Cols) + ' - [ ' + IntToStr(ManPos mod curMapNode.Cols + 1) + ', ' + IntToStr(ManPos div curMapNode.Cols + 1) + ' ]';       // ���
  end;
end;

// ���عؿ��ĵ��Ի���
procedure Tmain.bt_OpenClick(Sender: TObject);
var
  bt: LongWord;
  i, size, n: Integer;
  fn: string;

begin
  if isMoving then IsStop := True
  else IsStop := False;

  // ǿ�Ƽ��ص�ͼ�ĵ��ĺ�̨�߳�
  isStopThread := True;

  if not mySettings.isXSB_Saved then
  begin    // ���µĶ�����δ����
    bt := MessageBox(Handle, '��ǰ�ؿ���δ���棬�Ƿ񱣴棿', '����', MB_ICONWARNING + MB_YESNOCANCEL);
    if bt = idyes then
    begin
      SaveXSBToFile();
    end
    else if bt = idno then
    begin
    end
    else
      Exit;
  end;

  if not mySettings.isLurd_Saved then
  begin    // ���µĶ�����δ����
    bt := MessageBox(Handle, '�ոյ��ƶ���δ���棬�Ƿ񱣴棿', '����', MB_ICONWARNING + MB_YESNOCANCEL);
    if bt = idyes then begin
       SaveState();          // ����״̬�����ݿ�
    end else if bt = idno then begin
       mySettings.isLurd_Saved := True;
       StatusBar1.Panels[7].Text := '������������';
    end else exit;
  end;

  try
    if AnsiSameText(mySettings.MapFileName, 'BoxMan.xsb') and (mySettings.LaterList.Count > 0) then
       fn := mySettings.LaterList[0]
    else
       fn := mySettings.MapFileName;

    if Pos(':', fn) = 0 then fn := AppPath + fn;

    if (ExtractFilePath(fn) <> '') then
        OpenDialog1.InitialDir := ExtractFilePath(fn)
    else
        OpenDialog1.InitialDir := AppPath;
  except
    OpenDialog1.InitialDir := AppPath;
  end;

  OpenDialog1.FileName := '';

  if OpenDialog1.Execute then begin

    if AnsiSameText(AppPath + mySettings.MapFileName, OpenDialog1.FileName) then Exit;     // ��ǰ�ĵ�������Ҫ���´�

    if OpenDialog1.FileName <> '' then begin

       txtList.Clear;
       txtList.loadfromfile(OpenDialog1.FileName);
       QuicklyLoadMap(txtList, 1, curMapNode);                        // �����ĵ�ʱ�ȿ��ٴ򿪵�һ���ؿ��������ĵ�̫��ʱ������üҵȴ�����
       maxNumber := GetMapNumber(txtList);                            // ȡ�����ؿ����

       if Assigned(curMapNode) and (curMapNode.Rows > 2) then begin

          curMap.CurrentLevel := 1;
          mySettings.MapFileName := OpenDialog1.FileName;

          n := Pos(AppPath, mySettings.MapFileName);
          if n > 0 then Delete(mySettings.MapFileName, 1, Length(AppPath));

          ReadQuicklyMap();

          mySettings.isXSB_Saved := True;
          // ��ǿ��ֹͣ��̨�̣߳��ٴ����µĺ�̨�̣߳����ص�ͼ
          isStopThread := True;
          TLoadMapThread.Create(False);

          if not AnsiSameText(mySettings.MapFileName, 'BoxMan.xsb') then begin
            mySettings.LaterList.Insert(0, mySettings.MapFileName);
            size := mySettings.LaterList.Count;
            i := 1;
            while i < size do begin
              if AnsiSameText(mySettings.LaterList[i], mySettings.MapFileName) then begin
                 mySettings.LaterList.Delete(i);
                 Break;
              end else inc(i);
            end;
            if mySettings.LaterList.Count > 10 then mySettings.LaterList.Delete(10);
          end;

          StatusBar1.Panels[7].Text := '';
       end else StatusBar1.Panels[7].Text := '��Ч�Ĺؿ��ĵ� - ' + OpenDialog1.FileName;
    end;
  end;
end;

// ����Ƥ���Ի���
procedure Tmain.bt_SkinClick(Sender: TObject);
begin
  if LoadSkinForm.ShowModal = mrOK then
  begin
    mySettings.SkinFileName := LoadSkinForm.SkinFileName;
    if not LoadSkinForm.LoadSkin(AppPath + 'Skins\' + mySettings.SkinFileName) then
    begin
      LoadSkinForm.LoadDefaultSkin();         // ʹ��Ĭ�ϵļ�Ƥ��
    end;
    DrawMap();
  end;
end;

// ��ʾ��ż��Ч
procedure Tmain.bt_OddEvenMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  mySettings.isOddEven := true;
  DrawMap();
end;

// �ر���ż��Ч
procedure Tmain.bt_OddEvenMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  mySettings.isOddEven := false;
  DrawMap();
end;

// ���������Ƿ��ڴ�
procedure Tmain.FormDestroy(Sender: TObject);
begin
  isStopThread := True;
  isStopThread_Ans := True;

  if Assigned(mySettings.LaterList) then begin
     mySettings.MapFileName := '';
     mySettings.SkinFileName := '';
     mySettings.SubmitCountry := '';
     mySettings.SubmitName := '';
     mySettings.SubmitEmail := '';
     MyStringListFree(mySettings.LaterList);
     mySettings.LaterList.Free;
     Dispose(mySettings);     
  end;

  if Assigned(MaskPic) then begin                         // ѡ��Ԫ����ͼ
     MaskPic.Free;
  end;

  SoltionListClear(SoltionList);                          // ���б�
  if Assigned(SoltionList) then SoltionList.Free;

  StateListClear(StateList);                              // ״̬�б�
  if Assigned(StateList) then StateList.Free;

  MyStringListFree(txtList);                              // �ؿ��ĵ��Ļ���

  MyListClear(MapList);                                   // ��ͼ�б�
  if Assigned(MapList) then MapList.Free;

  if Assigned(curMapNode) then begin
     Dispose(PMapNode(curMapNode));
  end;

end;

// �������� reDo �����ڵ� -- ÿ��һ������Ϊһ������
function Tmain.GetStep(is_BK: Boolean): Integer;
var
  i, j, k, n, len: Integer;
  mAct: Char;
  boxRC: array[0..1] of Integer;
  flg: Boolean;
begin
  if is_BK then
    len := UnDoPos_BK
  else
    len := ReDoPos;

  if GoalNumber = 1 then
  begin
    result := len;
    exit;
  end;

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

    if is_BK then
      mAct := UndoList_BK[k]
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
function Tmain.GetStep2(is_BK: Boolean): Integer;
var
  i, j, k, n, len: Integer;
  mAct: Char;
  boxRC: array[0..1] of Integer;
  flg: Boolean;
begin
  if is_BK then
    len := ReDoPos_BK
  else
    len := UnDoPos;

  if GoalNumber = 1 then
  begin
    result := len;
    exit;
  end;

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

    if is_BK then
      mAct := RedoList_BK[k]
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

// ���Ƶ�ͼ��ת�İ�ť
procedure Tmain.pnl_TrunMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then Exit;

    if mySettings.isRotate then begin
        case Button of
          mbleft:
            begin     // ���� -- ָ���
              if curMapNode.Trun < 7 then
                inc(curMapNode.Trun)
              else
                curMapNode.Trun := 0;    // �� 0 ת
            end;
          mbright:
            begin    // �һ� -- ָ�Ҽ�
              if curMapNode.Trun > 0 then
                dec(curMapNode.Trun)
              else
                curMapNode.Trun := 7;    // �� 0 ת
            end;
        end;
    end else begin
        if ssShift in Shift then begin              // ���·�ת
           case Button of
              mbleft: begin
                  case curMapNode.Trun of
                     0:   curMapNode.Trun := 6;
                     1:   curMapNode.Trun := 5;
                     2:   curMapNode.Trun := 4;
                     3:   curMapNode.Trun := 7;
                     4:   curMapNode.Trun := 2;
                     5:   curMapNode.Trun := 1;
                     6:   curMapNode.Trun := 0;
                     else curMapNode.Trun := 3;
                  end;
                end;
              mbright: begin
                  curMapNode.Trun := 0;
                end;
           end;
        end else if ssCtrl in Shift then begin      // ���ҷ�ת
           case Button of
              mbleft: begin
                  case curMapNode.Trun of
                     0:   curMapNode.Trun := 4;
                     1:   curMapNode.Trun := 7;
                     2:   curMapNode.Trun := 6;
                     3:   curMapNode.Trun := 5;
                     4:   curMapNode.Trun := 0;
                     5:   curMapNode.Trun := 3;
                     6:   curMapNode.Trun := 2;
                     else curMapNode.Trun := 1;
                  end;
                end;
              mbright: begin
                  curMapNode.Trun := 0;
                end;
           end;
        end else begin                              // ����������
            case Button of
              mbleft:
                begin     // ���� -- ָ���
                  case curMapNode.Trun of
                     0:   curMapNode.Trun := 3;
                     1:   curMapNode.Trun := 0;
                     2:   curMapNode.Trun := 1;
                     3:   curMapNode.Trun := 2;
                     4:   curMapNode.Trun := 7;
                     5:   curMapNode.Trun := 4;
                     6:   curMapNode.Trun := 5;
                     else curMapNode.Trun := 6;
                  end;
                end;
              mbright:
                begin    // �һ� -- ָ�Ҽ�
                  case curMapNode.Trun of
                     0:   curMapNode.Trun := 1;
                     1:   curMapNode.Trun := 2;
                     2:   curMapNode.Trun := 3;
                     3:   curMapNode.Trun := 0;
                     4:   curMapNode.Trun := 5;
                     5:   curMapNode.Trun := 6;
                     6:   curMapNode.Trun := 7;
                     else curMapNode.Trun := 4;
                  end;
                end;
            end;
        end;
    end;

    SetMapTrun();
end;

// ������ת�Ż��Ƶ�ͼ
procedure Tmain.SetMapTrun();
begin
  pnl_Trun.Caption := MapTrun[curMapNode.Trun];
  NewMapSize();
  DrawMap();       // ����ͼ
  case curMapNode.Trun of
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

// ������Ϸ�ٶȵİ�ť
procedure Tmain.pnl_SpeedMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  case Button of
    mbleft:
      begin     // ���� -- ָ���
        if mySettings.mySpeed > 0 then
          dec(mySettings.mySpeed)
        else mySettings.mySpeed := 4;
      end;
    mbright:
      begin    // �һ� -- ָ�Ҽ�
        if mySettings.mySpeed < 4 then
          inc(mySettings.mySpeed)
        else mySettings.mySpeed := 0;
      end;
  end;
  pnl_Speed.Caption := SpeedInf[mySettings.mySpeed];
end;

// ����ؿ� XSB ���ĵ�
function Tmain.SaveXSBToFile(): Boolean;
var
  myXSBFile: Textfile;
  myFileName, myExtName: string;
  i, size, n: Integer;
  mapNode: PMapNode;               // �ؿ��ڵ�

begin
  Result := False;
  StatusBar1.Panels[7].Text := '';

  if (ExtractFilePath(mySettings.MapFileName) <> '') then
    dlgSave1.InitialDir := ExtractFilePath(mySettings.MapFileName)
  else
    dlgSave1.InitialDir := AppPath;

  dlgSave1.FileName := '';
  if dlgSave1.Execute then
  begin
    myFileName := dlgSave1.FileName;

    myExtName := ExtractFileExt(myFileName);

    if (myExtName = '') or (myExtName = '.') then
      myFileName := changefileext(myFileName, '.xsb');

    if not FileExists(myFileName) or (MessageBox(Handle, PChar(myFileName + #10 + ' �ĵ��Ѿ����ڣ���д����'), '����', MB_ICONWARNING + MB_OKCANCEL) = idOK) then begin

      AssignFile(myXSBFile, myFileName);
      if AnsiSameText(myFileName, AppPath + 'BoxMan.xsb') and FileExists(myFileName) then Append(myXSBFile)   // ��ת�ؿ��⣬��׷�ӷ�ʽ����
      else ReWrite(myXSBFile);

      try
        for i := 0 to MapList.Count - 1 do
        begin
          mapNode := MapList.Items[i];

          Writeln(myXSBFile, GetXSB(mapNode));

//          Writeln(myXSBFile, '');
//          Writeln(myXSBFile, mapNode.Map);
//
//          if Trim(mapNode.Title) <> '' then
//            Writeln(myXSBFile, 'Title: ' + mapNode.Title);
//          if Trim(mapNode.Author) <> '' then
//            Writeln(myXSBFile, 'Author: ' + mapNode.Author);
//          if Trim(mapNode.Comment) <> '' then
//          begin
//            Writeln(myXSBFile, 'Comment: ');
//            Writeln(myXSBFile, mapNode.Comment);
//            Writeln(myXSBFile, 'Comment_end: ');
//          end;
        end;
      finally
        Closefile(myXSBFile);
      end;
    end;

    mySettings.MapFileName := myFileName;
    n := Pos(AppPath, mySettings.MapFileName);
    if n > 0 then Delete(mySettings.MapFileName, 1, Length(AppPath));

    mySettings.isXSB_Saved := True;            // ���Ӽ��а嵼��� XSB �Ƿ񱣴����

    if not AnsiSameText(mySettings.MapFileName, 'BoxMan.xsb') then begin
       mySettings.LaterList.Insert(0, mySettings.MapFileName);
       size := mySettings.LaterList.Count;
       i := 1;
       while i < size do begin
          if AnsiSameText(mySettings.LaterList[i], mySettings.MapFileName) then begin
             mySettings.LaterList.Delete(i);
             break;
          end else inc(i);
       end;
       if mySettings.LaterList.Count > 10 then mySettings.LaterList.Delete(10);
    end;

    Caption := AppName + AppVer + ' - ' + ExtractFileName(ChangeFileExt(mySettings.MapFileName, EmptyStr)) + ' ~ [' + inttostr(curMap.CurrentLevel) + '/' + inttostr(maxNumber) + ']';
    Result := True;
  end;
end;

// ��ѡ�ؽ���
procedure Tmain.bt_ViewClick(Sender: TObject);
begin
  if MapList.Count = 0 then begin
     StatusBar1.Panels[7].Text := '��̨��æ�����Ժ����ԣ�';
     Exit;
  end;

  if isMoving then IsStop := True
  else IsStop := False;

  BrowseForm.sb_Delete.Visible := AnsiSameText(mySettings.MapFileName, 'BoxMan.xsb');      // ��ת���ĵ�����ɾ���ؿ�

  BrowseForm.curIndex := curMap.CurrentLevel-1;        // ����ʱѡ��� item
  BrowseForm.BK_Color := mySettings.bwBKColor;
  BrowseForm.ShowModal;
  mySettings.bwBKColor := BrowseForm.BK_Color;
  if BrowseForm.curIndex < 0 then Exit;

  curMap.CurrentLevel := BrowseForm.curIndex + 1;
  if LoadMap(curMap.CurrentLevel) then begin
    InitlizeMap();
    SetMapTrun();
  end;

end;

// �����༭��ť
procedure Tmain.bt_ActClick(Sender: TObject);
var
  i, RepTimes, n: Integer;
  ch: Char;

begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then begin
     MessageBox(handle, '���޴򿪵Ĺؿ���ؿ����ϸ�', '����', MB_ICONERROR or MB_OK);
     Exit;
  end;

  // �������� -- �Ƿ����ơ�Ĭ��·��
  ActionForm.isBK := mySettings.isBK;
  if (ExtractFilePath(mySettings.MapFileName) <> '') then
    ActionForm.MyPath := ExtractFilePath(mySettings.MapFileName)
  else
    ActionForm.MyPath := AppPath;
    
  ActionForm.ExePath := AppPath;
  if ManPos_BK_0 < 0 then begin
    Act_ManPos_BK.X := -1;
    Act_ManPos_BK.Y := -1;
  end else begin
    Act_ManPos_BK.X := (ManPos_BK_0 mod curMapNode.Cols)+1;
    Act_ManPos_BK.Y := (ManPos_BK_0 div curMapNode.Cols)+1;
  end;

  ActionForm.ShowModal;

  if ActionForm.Tag = 1 then begin

     curMap.isFinish := False;
  
     RepTimes := ActionForm.Rep_Times.Value;          // �ظ�����

     // ����ʱ����Ҫ�����˵ĳ�ʼλ��
     if ActionForm.Run_CurPos.Checked then begin  // �ӵ�ǰ��ִ��
        if mySettings.isBK then begin
           if ManPos_BK < 0 then begin
              if (ActionForm.M_X < 0) or (ActionForm.M_Y < 0) or (ActionForm.M_X >= curMapNode.Cols) or (ActionForm.M_Y >= curMapNode.Rows) or
                 (not (map_Board_BK[ActionForm.M_Y * curMapNode.Cols + ActionForm.M_X] in [ FloorCell, GoalCell ])) then begin
                 MessageBox(handle, '�˵ĳ�ʼλ�ò���ȷ��', '����', MB_ICONERROR or MB_OK);
                 Exit;
              end;

              // ��λ�÷����� 
              ManPos_BK := ActionForm.M_Y * curMapNode.Cols + ActionForm.M_X;
              ManPos_BK_0 := ManPos_BK;
              if map_Board_BK[ManPos_BK] = FloorCell then map_Board_BK[ManPos_BK] := ManCell
              else map_Board_BK[ManPos_BK] := ManGoalCell;
           end;
        end;
     end else begin
        Restart(mySettings.isBK);
        if mySettings.isBK then begin
        
           if (ActionForm.M_X < 0) or (ActionForm.M_Y < 0) or (ActionForm.M_X >= curMapNode.Cols) or (ActionForm.M_Y >= curMapNode.Rows) or
              (not (map_Board_BK[ActionForm.M_Y * curMapNode.Cols + ActionForm.M_X] in [ FloorCell, GoalCell, ManCell, ManGoalCell ])) then begin

              if ManPos_BK < 0 then begin
                 MessageBox(handle, '�˵ĳ�ʼλ�ò���ȷ��', '����', MB_ICONERROR or MB_OK);
                 Exit;
              end;
           end;

           // ���ص��˵�λ����ȷ��������ԭ�����˵�λ��
           if ManPos_BK >= 0 then begin
              if map_Board_BK[ManPos_BK] = ManCell then map_Board_BK[ManPos_BK] := FloorCell
              else map_Board_BK[ManPos_BK] := GoalCell;
           end;

           // ��λ�÷�����
           ManPos_BK := ActionForm.M_Y * curMapNode.Cols + ActionForm.M_X;
           ManPos_BK_0 := ManPos_BK;
           if map_Board_BK[ManPos_BK] = FloorCell then map_Board_BK[ManPos_BK] := ManCell
           else map_Board_BK[ManPos_BK] := ManGoalCell;
        end;
     end;

     GetLurd(ActionForm.Act, mySettings.isBK);

     // ���ֳ���תת�� redo �еĶ���
     if ActionForm.Run_CurTru.Checked then begin
        if mySettings.isBK then begin
           for i := 1 to ReDoPos_BK do begin
               ch := RedoList_BK[i];
               case ch of
                 'l': ch := ActDir[curMapNode.Trun, 0];
                 'u': ch := ActDir[curMapNode.Trun, 1];
                 'r': ch := ActDir[curMapNode.Trun, 2];
                 'd': ch := ActDir[curMapNode.Trun, 3];
                 'L': ch := ActDir[curMapNode.Trun, 4];
                 'U': ch := ActDir[curMapNode.Trun, 5];
                 'R': ch := ActDir[curMapNode.Trun, 6];
                 'D': ch := ActDir[curMapNode.Trun, 7];
               end;
               RedoList_BK[i] := ch;
           end;
        end else begin
           for i := 1 to ReDoPos do begin
               ch := RedoList[i];
               case ch of
                 'l': ch := ActDir[curMapNode.Trun, 0];
                 'u': ch := ActDir[curMapNode.Trun, 1];
                 'r': ch := ActDir[curMapNode.Trun, 2];
                 'd': ch := ActDir[curMapNode.Trun, 3];
                 'L': ch := ActDir[curMapNode.Trun, 4];
                 'U': ch := ActDir[curMapNode.Trun, 5];
                 'R': ch := ActDir[curMapNode.Trun, 6];
                 'D': ch := ActDir[curMapNode.Trun, 7];
               end;
               RedoList[i] := ch;
           end;
        end;
     end;

     if mySettings.isBK then begin
        n := ReDoPos_BK;
     end else begin
        n := ReDoPos;
     end;
     // ִ�д���
     for i := 1 to RepTimes do begin
         if mySettings.isBK then begin
            ReDoPos_BK := n;
            ReDo_BK(ReDoPos_BK);
         end else begin
            ReDoPos := n;
            ReDo(ReDoPos);
         end;
     end;
     if mySettings.isBK then begin
        ReDoPos_BK := 0;
     end else begin
        ReDoPos := 0;
     end;
  end;
end;

// �ر���Ϸʱ������Ƿ�����Ҫ��������ݣ��Ա��������
procedure Tmain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  bt: LongWord;
begin
  if isMoving then begin
     IsStop := True;
     CanClose := False;
     Exit;
  end;

  isStopThread := True;
  isStopThread_Ans := True;
  CanClose := True;

  if not mySettings.isXSB_Saved then
  begin    // ���µ�XSB��δ����
    bt := MessageBox(Handle, '��ǰ�ؿ���δ���棬�Ƿ񱣴棿', '����', MB_ICONWARNING + MB_YESNOCANCEL);
    if bt = idyes then
    begin
      SaveXSBToFile();
    end
    else if bt = idno then
    begin
      mySettings.isXSB_Saved := True;
    end
    else
      CanClose := False;
  end;

  if CanClose and (not mySettings.isLurd_Saved) then
  begin    // ���µĶ�����δ����
    bt := MessageBox(Handle, '�ոյ��ƶ���δ���棬�Ƿ񱣴棿', '����', MB_ICONWARNING + MB_YESNOCANCEL);
    if bt = idyes then
    begin
      mySettings.isLurd_Saved := True;
      SaveState();          // ����״̬�����ݿ�
    end
    else if bt = idno then
    begin
      mySettings.isLurd_Saved := True;
    end
    else
      CanClose := False;
  end;
end;

// �����������������Ĵ��б�
procedure Tmain.List_SolutionDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  lpstr: PChar;
  c: integer;
begin
  with Control as TListBox do
  begin
    Canvas.FillRect(Rect);
    c := length(items[Index]);
    lpstr := PChar(Items[Index]);
    drawtext(Canvas.Handle, lpstr, c, Rect, DT_WORDBREAK);
  end;
end;

// �����������������Ĵ��б�
procedure Tmain.List_SolutionMeasureItem(Control: TWinControl; Index: Integer; var Height: Integer);
var
  lpstr: PChar;
  c, h: integer;
  tc: TRect;
begin

  with Control as TListBox do
  begin
    c := length(items[Index]);
    lpstr := PChar(Items[Index]);
    tc := clientrect;
    h := drawtext(Canvas.Handle, lpstr, c, tc, DT_CALCRECT or DT_WORDBREAK);
  end;

  Height := h + 4;
end;

// ����Ŀ��λ�л�
procedure Tmain.pmGoalClick(Sender: TObject);
begin
  isSelectMod := False;
  mySettings.isSameGoal := not mySettings.isSameGoal;
  if mySettings.isSameGoal then
    pmGoal.Checked := True
  else
    pmGoal.Checked := False;
  DrawMap();                                  // ���µ�ͼ��ʾ
  ShowStatusBar();
end;

// ����˫���л���ť
procedure Tmain.pmJijingClick(Sender: TObject);
begin
  isSelectMod := False;

  mySettings.isJijing := not mySettings.isJijing;
  if mySettings.isJijing then
    pmJijing.Checked := True
  else
    pmJijing.Checked := False;

  DrawMap();                                  // ���µ�ͼ��ʾ
  ShowStatusBar();
end;

// ��������������״̬�б� -- ˫�� -- ���ش�
procedure Tmain.List_SolutionDblClick(Sender: TObject);
var
  s: string;
  i, len: Integer;

begin
    StatusBar1.Panels[7].Text := '';
    StatusBar1.Repaint;

    if isMoving then IsStop := True
    else IsStop := False;

    if not mySettings.isLurd_Saved then
    begin    // ���µĶ�����δ����
      i := MessageBox(Handle, '�ոյ��ƶ���δ���棬�Ƿ񱣴棿', '����', MB_ICONWARNING + MB_YESNOCANCEL);
      if i = idyes then begin
         SaveState();          // ����״̬�����ݿ�
         PageControl.ActivePageIndex := 0;
      end else if i = idno then begin
         mySettings.isLurd_Saved := True;
         StatusBar1.Panels[7].Text := '������������';
      end else exit;
    end;

    if GetSolutionFromDB(List_Solution.ItemIndex, s) then begin

       len := Length(s);
       
       if len > 0 then begin
           Restart(False);

           // ���������Ƶ� RedoList
           ReDoPos := 0;
           for i := len downto 1 do begin
               if ReDoPos = MaxLenPath then Exit;
               inc(ReDoPos);
               RedoList[ReDoPos] := s[i];
           end;
           curMap.isFinish := True;
       end;
       StatusBar1.Panels[7].Text := '�������룡';
       StatusBar1.Repaint;
    end;
end;

// ��������������״̬�б� -- ˫�� -- ����״̬
procedure Tmain.List_StateDblClick(Sender: TObject);
var
  s1, s2: string;
  i, len, x, y, id, n: Integer;
  actNode: ^TStateNode;

begin
    StatusBar1.Panels[7].Text := '';
    StatusBar1.Repaint;

    if isMoving then IsStop := True
    else IsStop := False;

    n := List_State.ItemIndex;

    if not mySettings.isLurd_Saved then
    begin    // ���µĶ�����δ����
      i := MessageBox(Handle, '�ոյ��ƶ���δ���棬�Ƿ񱣴棿', '����', MB_ICONWARNING + MB_YESNOCANCEL);
      if i = idyes then begin
         actNode := StateList[n];
         id := actNode.id;
         SaveState();          // ����״̬�����ݿ�
         len := StateList.Count;
         for x := 0 to len-1 do begin
             actNode := StateList[x];
             if id = actNode.id then begin
                n := x;
                List_State.Selected[n] := True;
             end;
         end;
      end else if i = idno then begin
         mySettings.isLurd_Saved := True;
         StatusBar1.Panels[7].Text := '������������';
      end else exit;
    end;

    if GetStateFromDB(n, x, y, s1, s2) then begin
  
       Restart(False);                 // �ؿ���λ
       Restart(True);                  // �ؿ���λ

       len := Length(s1);

       // ״̬���� RedoList
       if len > 0 then begin
           ReDoPos := 0;
           for i := len downto 1 do begin
               if ReDoPos = MaxLenPath then Exit;
               inc(ReDoPos);
               RedoList[ReDoPos] := s1[i];
           end;
               
           isNoDelay := True;
           ReDo(len);
           isNoDelay := False;
       end;

       len := Length(s2);

       // ״̬���� RedoList_BK
       if (len > 0) and (x > 0) and (y > 0) and (x <= curMapNode.Cols) and ( y <= curMapNode.Rows) then begin

           if ManPos_BK >= 0 then begin
              if map_Board_BK[ManPos_BK] = ManCell then map_Board_BK[ManPos_BK] := FloorCell
              else if map_Board_BK[ManPos_BK] = ManGoalCell then map_Board_BK[ManPos_BK] := GoalCell
              else begin
                StatusBar1.Panels[7].Text := '�ؿ��ֳ�������������';
                Exit;
              end;
           end;

           ManPos_BK := (y-1) * curMapNode.Cols + x-1;

           if map_Board_BK[ManPos_BK] = FloorCell then map_Board_BK[ManPos_BK] := ManCell
           else if map_Board_BK[ManPos_BK] = GoalCell then map_Board_BK[ManPos_BK] := ManGoalCell
           else begin
             StatusBar1.Panels[7].Text := '״̬���ݲ���ȷ��';
             Exit;
           end;

           ManPos_BK_0 := ManPos_BK;
               
           ReDoPos_BK := 0;
           for i := len downto 1 do begin
               if ReDoPos_BK = MaxLenPath then Exit;
               inc(ReDoPos_BK);
               RedoList_BK[ReDoPos_BK] := s2[i];
           end;

           isNoDelay := True;
           ReDo_BK(len);
           isNoDelay := False;
       end;
       curMap.isFinish := True;
       StatusBar1.Panels[7].Text := '״̬�����룡';
       StatusBar1.Repaint;
    end;
end;

// ��״̬���ȡһ��״̬
function Tmain.GetStateFromDB(index: Integer; var x: Integer; var y: Integer; var str1: string; var str2: string): Boolean;
var
  sldb: TSQLiteDatabase;
  sltb: TSQLIteTable;
  sSQL: String;
  actNode: ^TStateNode;
  
begin
  Result := False;

  if index < 0 then Exit;

  actNode := StateList[index];

  sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));

  try
    sSQL := 'select Act_Text, Act_Text_BK, Man_X, Man_Y from Tab_State where id = ' + IntToStr(actNode.id);
    sltb := slDb.GetTable(sSQL);

    try
      if sltb.Count > 0 then begin
        sltb.MoveFirst;
        while not sltb.EOF do begin
           str1 := sltb.FieldAsString(sltb.FieldIndex['Act_Text']);      // ��ȡ״̬
           str2 := sltb.FieldAsString(sltb.FieldIndex['Act_Text_BK']);
           x    := sltb.FieldAsInteger(sltb.FieldIndex['Man_X']);
           y    := sltb.FieldAsInteger(sltb.FieldIndex['Man_Y']);

           sltb.Next;
        end;
      end;
    finally
      sltb.Free;
      sldb.Free;
      actNode := nil;
    end;
  except
    StatusBar1.Panels[7].Text := '״̬�����״̬δ����ȷ���أ�';
  end;

  Result := True;
end;

// �Ӵ𰸿��ȡһ����
function Tmain.GetSolutionFromDB(index: Integer; var str: string): Boolean;
var
  sldb: TSQLiteDatabase;
  sltb: TSQLIteTable;
  sSQL: String;
  solNode: ^TSoltionNode;
  t: Integer;
begin
    Result := False;

    if index < 0 then Exit;

    sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));

    try
      try
        solNode := SoltionList[index];

        sSQL := 'select Sol_Text, XSB_CRC_TrunNum from Tab_Solution where id = ' + IntToStr(solNode.id);

        sltb := slDb.GetTable(sSQL);
        
        try
           if sltb.Count > 0 then begin
             sltb.MoveFirst;
             str := sltb.FieldAsString(sltb.FieldIndex['Sol_Text']);         // ��ȡ��
             t := sltb.FieldAsInteger(sltb.FieldIndex['XSB_CRC_TrunNum']);   // �𰸵���ת
             getANS(t, curMapNode.CRC_Num, str);                             // �𰸰��ؿ���ת����ת��
           end;
        Finally
           sltb.Free;
        end;
      finally
        sldb.Free;
        solNode := nil;
      end;
    except
      StatusBar1.Panels[7].Text := '�𰸿������δ����ȷ���أ�';
    end;

    Result := True;
end;

// ״̬ -- ���� Lurd �����а�
procedure Tmain.sa_LurdClick(Sender: TObject);
var
  s1, s2: string;
  len, x, y: Integer;
  
begin
   if GetStateFromDB(List_State.ItemIndex, x, y, s1, s2) then begin
      len := Length(s1);
      if len > 0 then begin
         Clipboard.SetTextBuf(PChar(s1));
         StatusBar1.Panels[7].Text := '���� Lurd �����а壡';
      end else StatusBar1.Panels[7].Text := '�������� Lurd ʧ�ܣ�';
   end;
end;

// ״̬ -- ���� Lurd �����а�
procedure Tmain.sa_Lurd_BKClick(Sender: TObject);
var
  s1, s2: string;
  len, x, y: Integer;

begin
   if GetStateFromDB(List_State.ItemIndex, x, y, s1, s2) then begin
      len := Length(s2);
      if (len > 0) and (x > 0) and (y > 0) then begin
         Clipboard.SetTextBuf(PChar('[' + IntToStr(x) + ', ' + IntToStr(y) + ']' + s2));
         StatusBar1.Panels[7].Text := '���� Lurd �����а壡';
      end else StatusBar1.Panels[7].Text := '�������� Lurd ʧ�ܣ�';
   end;
end;

// ״̬ -- XSB + Lurd �����а�
procedure Tmain.sa_XSB_LurdClick(Sender: TObject);
var
  s, s1, s2: string;
  len, x, y: Integer;

begin
   if GetStateFromDB(List_State.ItemIndex, x, y, s1, s2) then begin
      s := GetXSB(curMapNode);
      
      len := Length(s1);
      if len > 0 then s := s + s1;

      len := Length(s2);
      if (len > 0) and (x > 0) and (y > 0) then Clipboard.SetTextBuf(PChar(s+#10+'[' + IntToStr(x) + ', ' + IntToStr(y) + ']' + s2))
      else Clipboard.SetTextBuf(PChar(s));

      StatusBar1.Panels[7].Text := 'XSB + Lurd �����а壡';
   end;
end;

// ״̬ -- XSB + Lurd ���ĵ�
procedure Tmain.sa_XSB_Lurd_FileClick(Sender: TObject);
var
  myXSBFile: Textfile;
  myFileName, myExtName, s1, s2: string;
  x, y, len: Integer;

begin
  dlgSave1.InitialDir := AppPath;
  dlgSave1.FileName := '';

  if dlgSave1.Execute then begin
    myFileName := dlgSave1.FileName;

    myExtName := ExtractFileExt(myFileName);

    if (myExtName = '') or (myExtName = '.') then
      myFileName := changefileext(myFileName, '.txt');

    if not FileExists(myFileName) or (MessageBox(Handle, PChar(myFileName + #10 + ' �ĵ��Ѿ����ڣ���д����'), '����', MB_ICONWARNING + MB_OKCANCEL) = idOK) then begin
      AssignFile(myXSBFile, myFileName);
      ReWrite(myXSBFile);

      try
        Write(myXSBFile, GetXSB(curMapNode));

        if GetStateFromDB(List_State.ItemIndex, x, y, s1, s2) then begin

          len := Length(s1);
          if len > 0 then Write(myXSBFile, s1 + #10);

          len := Length(s2);
          if (len > 0) and (x > 0) and (y > 0) then Write(myXSBFile, PChar('[' + IntToStr(x) + ', ' + IntToStr(y) + ']' + s2 + #10));

          StatusBar1.Panels[7].Text := 'XSB + Lurd ���ĵ���';
        end;
      finally
        Closefile(myXSBFile);
      end;
    end;
  end;
end;

// ״̬ -- ɾ��һ��
procedure Tmain.sa_DeleteClick(Sender: TObject);
var
  sldb: TSQLiteDatabase;
  sSQL: String;
  actNode: ^TStateNode;

begin
  if List_State.ItemIndex < 0 then Exit;

  if MessageBox(Handle, 'ɾ��ѡ�е�״̬��ȷ����', '����', MB_ICONWARNING + MB_OKCANCEL) <> idOK then Exit;

  sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));

  try
  
    actNode := StateList[List_State.ItemIndex];

    sSQL := 'delete from Tab_State where id = ' + IntToStr(actNode.id);

    try
      sldb.BeginTransaction;
      sldb.ExecSQL(sSQL);
      sldb.Commit;

      StateList.Delete(List_State.ItemIndex);
      List_State.Items.Delete(List_State.ItemIndex);
    finally
      sldb.Free;
      actNode := nil;
    end;
  except
    MessageBox(handle, '״̬�����' + #10 + 'δ����ȷɾ��״̬��', '����', MB_ICONERROR or MB_OK);
  end;
end;

// ״̬ -- ɾ��ȫ��
procedure Tmain.sa_DeleteAllClick(Sender: TObject);
var
  sldb: TSQLiteDatabase;
  sSQL: String;
  i, len: Integer;
  actNode: ^TStateNode;
  s: string;
  
begin
  if MessageBox(Handle, 'ɾ��ȫ����״̬��ȷ����', '����', MB_ICONWARNING + MB_OKCANCEL) <> idOK then Exit;

  len := List_State.Count;

  sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));

  try
    for i := 0 to len-1 do begin
        actNode := StateList[i];
        if i = 0 then s := IntToStr(actNode.id)
        else s := s + ', ' + IntToStr(actNode.id);
    end;
    
    sSQL := 'delete from Tab_State where id in (' + s + ')';

    try
      sldb.BeginTransaction;
      sldb.ExecSQL(sSQL);
      sldb.Commit;

      StateListClear(StateList);
      List_State.Clear;
    finally
      sldb.Free;
      actNode := nil;
    end;
  except
    MessageBox(handle, '״̬�����' + #10 + 'δ����ȷɾ��״̬��', '����', MB_ICONERROR or MB_OK);
  end;
end;

// ����״̬ -- �Ǳ��ؿ���ȫ��״̬
procedure Tmain.sa_ClraeAllClick(Sender: TObject);
var
  sldb: TSQLiteDatabase;
  sSQL: String;
  i, len: Integer;
  actNode: ^TStateNode;
  s: string;
  
begin
  if MessageBox(Handle, '����Ǳ��ؿ���ȫ��״̬��ȷ����', '����', MB_ICONWARNING  + MB_OKCANCEL) <> idOK then Exit;

  len := List_State.Count;

  sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));

  try
    for i := 0 to len-1 do begin
        actNode := StateList[i];
        if i = 0 then s := IntToStr(actNode.id)
        else s := s + ', ' + IntToStr(actNode.id);
    end;

    sSQL := 'delete from Tab_State where not id in (' + s + ')';

    try
      sldb.BeginTransaction;
      sldb.ExecSQL(sSQL);
      sldb.Commit;
    finally
      sldb.Free;
      actNode := nil;
    end;
  except
    MessageBox(handle, '״̬�����' + #10 + 'δ����ȷ����״̬��', '����', MB_ICONERROR or MB_OK);
  end;
end;

// �� -- Lurd �����а�
procedure Tmain.so_LurdClick(Sender: TObject);
var
  s1: string;
  len: Integer;

begin
   if GetSolutionFromDB(List_Solution.ItemIndex, s1) then begin
      len := Length(s1);
      if len > 0 then begin
         Clipboard.SetTextBuf(PChar(s1));
         StatusBar1.Panels[7].Text := 'Lurd �����а壡';
      end else StatusBar1.Panels[7].Text := '���� Lurd ʧ�ܣ�';
   end;
end;

// �� -- XSB + Lurd �����а�
procedure Tmain.so_XSB_LurdClick(Sender: TObject);
var
  s, s1: string;
  len: Integer;
  solNode: ^TSoltionNode;

begin
   if GetSolutionFromDB(List_Solution.ItemIndex, s1) then begin
      s := GetXSB(curMapNode);

      len := Length(s1);
      if len > 0 then begin
         solNode := SoltionList.items[List_Solution.ItemIndex];
         Clipboard.SetTextBuf(PChar(s + 'Solution (Moves: ' + IntToStr(solNode.Moves) + ', Pushs: ' + IntToStr(solNode.Pushs) + '): ' + s1 + #10));
         StatusBar1.Panels[7].Text := 'XSB + Lurd �����а壡';
         solNode := nil;
      end else StatusBar1.Panels[7].Text := 'XSB + Lurd �����а�ʧ�ܣ�';
   end;
end;

// �� -- XSB + Lurd_All �����а�
procedure Tmain.so_XSB_LurdAllClick(Sender: TObject);
var
  s, s1, ss: string;
  i, len, len0: Integer;
  solNode: ^TSoltionNode;

begin
   s := GetXSB(curMapNode);
   ss := '';

   len0 := List_Solution.Count;
   for i := 0 to len0-1 do begin
       if GetSolutionFromDB(i, s1) then begin
          len := Length(s1);
          if len > 0 then begin
             solNode := SoltionList.items[i];
             ss := ss + 'Solution (Moves: ' + IntToStr(solNode.Moves) + ', Pushs: ' + IntToStr(solNode.Pushs) + '): ' + s1 + #10;
          end;
       end;
   end;

   Clipboard.SetTextBuf(PChar(s + ss));
   StatusBar1.Panels[7].Text := 'XSB + Lurd_All �����а壡';
   solNode := nil;
end;

// �� -- XSB + Lurd ���ĵ�
procedure Tmain.so_XSB_Lurd_FileClick(Sender: TObject);
var
  myXSBFile: Textfile;
  myFileName, myExtName, s1: string;
  len: Integer;
  solNode: ^TSoltionNode;

begin
  dlgSave1.InitialDir := AppPath;
  dlgSave1.FileName := '';

  if dlgSave1.Execute then begin
    myFileName := dlgSave1.FileName;

    myExtName := ExtractFileExt(myFileName);

    if (myExtName = '') or (myExtName = '.') then
        myFileName := changefileext(myFileName, '.txt');

    if not FileExists(myFileName) or (MessageBox(Handle, PChar(myFileName + #10 + ' �ĵ��Ѿ����ڣ���д����'), '����', MB_ICONWARNING + MB_OKCANCEL) = idOK) then begin
      if GetSolutionFromDB(List_Solution.ItemIndex, s1) then begin

        len := Length(s1);

        if len > 0 then begin
           AssignFile(myXSBFile, myFileName);
           ReWrite(myXSBFile);

           Write(myXSBFile, GetXSB(curMapNode));

           solNode := SoltionList.items[List_Solution.ItemIndex];
           Write(myXSBFile, 'Solution (Moves: ' + IntToStr(solNode.Moves) + ', Pushs: ' + IntToStr(solNode.Pushs) + '): ' + s1 + #10);
           StatusBar1.Panels[7].Text := 'XSB + Lurd ���ĵ���';
           Closefile(myXSBFile);
           solNode := nil;
        end else StatusBar1.Panels[7].Text := '���� XSB + Lurd ���ĵ�ʧ�ܣ�';
      end;
    end;
  end;
end;

// ������ǰ�ؿ��������д�
procedure Tmain.so_XSB_LurdAll_FileClick(Sender: TObject);
var
  myXSBFile: Textfile;
  myFileName, myExtName, s1: string;
  i, len, len0: Integer;
  solNode: ^TSoltionNode;

begin
  dlgSave1.InitialDir := AppPath;
  dlgSave1.FileName := '';

  if dlgSave1.Execute then begin
    myFileName := dlgSave1.FileName;

    myExtName := ExtractFileExt(myFileName);

    if (myExtName = '') or (myExtName = '.') then
       myFileName := changefileext(myFileName, '.txt');

    if not FileExists(myFileName) or (MessageBox(Handle, PChar(myFileName + #10 + ' �ĵ��Ѿ����ڣ���д����'), '����', MB_ICONWARNING + MB_OKCANCEL) = idOK) then begin

      AssignFile(myXSBFile, myFileName);
      ReWrite(myXSBFile);

      try
        Write(myXSBFile, GetXSB(curMapNode));

        len0 := List_Solution.Count;
        for i := 0 to len0-1 do begin
           s1 := '';
           if GetSolutionFromDB(i, s1) then begin
              len := Length(s1);
              if len > 0 then begin
                 solNode := SoltionList.items[i];
                 Writeln(myXSBFile, 'Solution (Moves: ' + IntToStr(solNode.Moves) + ', Pushs: ' + IntToStr(solNode.Pushs) + '): ' + s1 + #10);
              end;
           end;
        end;

        solNode := nil;
        StatusBar1.Panels[7].Text := 'XSB + Lurd_All ���ĵ���';
      finally
        Closefile(myXSBFile);
      end;
    end;
  end;
end;

// ����ȫ���ؿ������
procedure Tmain.so_XSBAll_LurdAll1_FileClick(Sender: TObject);
var
  myXSBFile: Textfile;
  myFileName, myExtName, str: string;
  size, n: Integer;
  solNode: ^TSoltionNode;
  mapNode: PMapNode;

begin
  if MapList.Count = 0 then begin
     StatusBar1.Panels[7].Text := '���ڽ����ؿ��ĵ������Ժ����ԣ�';
     Exit;
  end;

  dlgSave1.InitialDir := AppPath;
  dlgSave1.FileName := '';

  if dlgSave1.Execute then begin
    myFileName := dlgSave1.FileName;

    myExtName := ExtractFileExt(myFileName);

    if (myExtName = '') or (myExtName = '.') then
       myFileName := changefileext(myFileName, '.txt');

    if not FileExists(myFileName) or (MessageBox(Handle, PChar(myFileName + #10 + ' �ĵ��Ѿ����ڣ���д����'), '����', MB_ICONWARNING + MB_OKCANCEL) = idOK) then begin

      AssignFile(myXSBFile, myFileName);
      ReWrite(myXSBFile);

      try
        size := MapList.Count;
        for n := 0 to size-1 do begin
            StatusBar1.Panels[7].Text := '������' + IntToStr(n+1) + '/' + IntToStr(size);
            mapNode := MapList[n];
            Write(myXSBFile, GetXSB(mapNode));

            str := GetSolution(mapNode);
            str := StringReplace(str, #10, #13#10, [rfReplaceAll]);
            Write(myXSBFile, str);
        end;

        solNode := nil;
        StatusBar1.Panels[7].Text := '����ȫ���ؿ����𰸣�';
      finally
        Closefile(myXSBFile);
      end;
    end;
  end;
end;

// �� -- ɾ��һ��
procedure Tmain.so_DeleteClick(Sender: TObject);
var
  sldb: TSQLiteDatabase;
  sSQL: String;
  solNode: ^TSoltionNode;

begin
  if List_Solution.ItemIndex < 0 then Exit;

  if not isStopThread then begin
     MessageBox(Handle, '��̨��æ�����Ժ����ԣ�', '��ʾ', MB_ICONINFORMATION  + MB_OK);
     Exit;
  end;

  if MessageBox(Handle, 'ɾ��ѡ�еĴ𰸣�ȷ����', '����', MB_ICONWARNING + MB_OKCANCEL) <> idOK then Exit;

  sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));

  try

    solNode := SoltionList[List_Solution.ItemIndex];

    try
      sSQL := 'delete from Tab_Solution where id = ' + IntToStr(solNode.id);

      sldb.BeginTransaction;
      sldb.ExecSQL(sSQL);
      sldb.Commit;

      SoltionList.Delete(List_Solution.ItemIndex);
      List_Solution.Items.Delete(List_Solution.ItemIndex);
    finally
      sldb.Free;
      solNode := nil;
    end;
  except
    MessageBox(handle, '�𰸿����' + #10 + 'δ����ȷɾ���𰸣�', '����', MB_ICONERROR or MB_OK);
  end;
  curMapNode.Solved := SoltionList.Count > 0;
end;

// �� -- ɾ��ȫ��
procedure Tmain.so_DeleteAllClick(Sender: TObject);
var
  sldb: TSQLiteDatabase;
  sSQL: String;
  i, len: Integer;
  solNode: ^TSoltionNode;
  s: string;
  
begin
  if not isStopThread then begin
     MessageBox(Handle, '��̨��æ�����Ժ����ԣ�', '��ʾ', MB_ICONINFORMATION  + MB_OK);
     Exit;
  end;

  if MessageBox(Handle, 'ɾ��ȫ���Ĵ𰸣�ȷ����', '����', MB_ICONWARNING + MB_OKCANCEL) <> idOK then Exit;

  len := List_Solution.Count;

  sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));

  try
    for i := 0 to len-1 do begin
        solNode := SoltionList[i];
        if i = 0 then s := IntToStr(solNode.id)
        else s := s + ', ' + IntToStr(solNode.id);
    end;

    sSQL := 'delete from Tab_Solution where id in (' + s + ')';

    try
      sldb.BeginTransaction;
      sldb.ExecSQL(sSQL);
      sldb.Commit;

      SoltionListClear(SoltionList);
      List_Solution.Clear;
    finally
      sldb.Free;
      solNode := nil;
    end;
  except
    MessageBox(handle, '�𰸿����' + #10 + 'δ����ȷɾ���𰸣�', '����', MB_ICONERROR or MB_OK);
  end;
  curMapNode.Solved := False;
end;

// ˫��״̬�����ұߵ�һ�� -- �������ȵĿ��ٶ�λ
procedure Tmain.StatusBar1DblClick(Sender: TObject);
var
  mpt: TPoint;
  len: Integer;
  per: Double;

begin
  if isMoving then IsStop := True
  else IsStop := False;

  mpt := Mouse.CursorPos;
  mpt := StatusBar1.ScreenToClient(mpt);

  isNoDelay := True;
  if mpt.x <= gotoLeft then begin
     if mySettings.isBK then UnDo_BK(UnDoPos_BK)
     else UnDo(UnDoPos);
  end else if mpt.x >= gotoLeft + gotoWidth then begin
     if mySettings.isBK then ReDo_BK(ReDoPos_BK)
     else ReDo(ReDoPos);
  end else begin
     per := (mpt.x - gotoLeft) / gotoWidth;        // goto ��λ��
     if mySettings.isBK then begin
        len := UnDoPos_BK + ReDoPos_BK;
        gotoPos := Trunc(len * per);
        if gotoPos < UnDoPos_BK then UnDo_BK(UnDoPos_BK-gotoPos)
        else if gotoPos > UnDoPos_BK then ReDo_BK(gotoPos-UnDoPos_BK);
     end else begin
        len := UnDoPos + ReDoPos;
        gotoPos := Trunc(len * per);
        if gotoPos < UnDoPos then UnDo(UnDoPos-gotoPos)
        else if gotoPos > UnDoPos then ReDo(gotoPos-UnDoPos);
     end;
  end;

  isNoDelay := False;
end;

// ״̬�� - ��Ϣ������
procedure Tmain.StatusBar1DrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rt: TRect);
var
  pos, len: Integer;
  per: Double;
  R1, R0: TRect;

begin
  if Panel.Index = 7 then begin
     per := 0.0;
     
     if mySettings.isBK then begin
        len := UnDoPos_BK + ReDoPos_BK;
        if len > 0 then per := UnDoPos_BK / len;
     end else begin
        len := UnDoPos + ReDoPos;
        if len > 0 then per := UnDoPos / len;
     end;

     if len > 0 then begin
         pos := Trunc(gotoWidth * per);
         R0 := Rect(gotoLeft, Rt.Top, gotoWidth + gotoLeft, Rt.Bottom);
         R1 := Rect(gotoLeft, Rt.Top, pos + gotoLeft, Rt.Bottom);
         StatusBar.Canvas.Brush.Color := clMoneyGreen;        // ��ɫ
         StatusBar.Canvas.FillRect(R0);
         StatusBar.Canvas.Brush.Color := clTeal;              // ��ɫ
         StatusBar.Canvas.FillRect(R1);
     end;

     if mySettings.isBK and (UnDoPos_BK > 0) or (not mySettings.isBK) and (UnDoPos > 0) then begin
        StatusBar.Canvas.Brush.Color := clTeal;               // ��ɫ
     end else begin
        StatusBar.Canvas.Brush.Color := clMoneyGreen;         // ��ɫ
     end;
     StatusBar.Canvas.Font.Color  := clBlack;                 // ������ɫ
     StatusBar.Canvas.TextOut(Rt.Left, Rt.Top, Panel.Text);
  end;
end;

// ״̬���ߴ����
procedure Tmain.StatusBar1Resize(Sender: TObject);
var
  j: integer;
  
begin
  gotoLeft := 0;
  for j := 0 to StatusBar1.Panels.Count - 2 do begin
      gotoLeft := gotoLeft + StatusBar1.Panels[j].Width;
  end;

  gotoLeft := gotoLeft;
  gotoWidth := StatusBar1.Width - gotoLeft - 20;
end;

// ��������ʾʱ��һЩ����
procedure Tmain.FormShow(Sender: TObject);
begin
  // �ؿ�������ڵ�λ�ü���С
  BrowseForm.Top := mySettings.bwTop;
  BrowseForm.Left := mySettings.bwLeft;
  BrowseForm.Width := mySettings.bwWidth;
  BrowseForm.Height := mySettings.bwHeight;

  // ������
  if mySettings.isLeftBar then begin
     pl_Side.Visible := True;
     bt_LeftBar.Caption := '<';
  end else begin
     pl_Side.Visible := False;
     bt_LeftBar.Caption := '>';
  end;
  NewMapSize();
  DrawMap();        // ����ͼ
  Edit1.SetFocus;
end;

// ��ȷ��ʱ
procedure Delay(msecs: dword);
var
  FirstTickCount: dword;
  
begin
  FirstTickCount := GetTickCount;
  while GetTickCount-FirstTickCount < msecs do Application.ProcessMessages;
end;

// ������ -- ���ƽ���
procedure Tmain.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if isMoving then IsStop := True
  else N15.Click;          // z������
  Handled := True;
  Delay(10);
end;

// ������ -- ���ƽ���
procedure Tmain.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if isMoving then IsStop := True
  else N18.Click;          // x������
  Handled := True;
  Delay(10);
end;

// GET ���� -- ��Ӧ�ӱ�����վ���ر����ؿ���XSB�� API
function MyGetMatch: string;
var
  IdHttp : TIdHTTP;
  Url : string;                   // �����ַ
  ResponseStream : TStringStream; // ������Ϣ
  ResponseStr : string;
  
begin
  // ����IDHTTP�ؼ�
  IdHttp := TIdHTTP.Create(nil);

  // TStringStream�������ڱ�����Ӧ��Ϣ
  ResponseStream := TStringStream.Create('');

  try
    // �����ַ
    Url := 'http://sokoban.ws/api/competition/';
    try
      IdHttp.Get(Url, ResponseStream);
    except
//      on e : Exception do
//      begin
//        ShowMessage(e.Message);
//      end;
    end;

    // ��ȡ��ҳ���ص���Ϣ
    ResponseStr := ResponseStream.DataString;

    // ��ҳ�еĴ�������ʱ����Ҫ����UTF8����
    ResponseStr := UTF8Decode(ResponseStr);

  finally
    IdHttp.Free;
    ResponseStream.Free;
  end;

  Result := ResponseStr;
end;

// ��Ӧ����򿪵Ĺؿ����ĵ��˵���ĵ����¼�
procedure Tmain.MenuItemClick(Sender: TObject);
var
  fn: string;
  i, size, n: Integer;
  // ���� Json
  jRet, jLevel: ISuperObject;
  strBegin, strEnd, strLevel, level, author, title, str: string;
  id: integer;

begin
   if not mySettings.isXSB_Saved then
   begin    // ���µ�XSB��δ����
      i := MessageBox(Handle, '��ǰ�ؿ���δ���棬�Ƿ񱣴棿', '����', MB_ICONWARNING + MB_YESNOCANCEL);
      if i = idyes then begin
        SaveXSBToFile();
      end else if i = idno then begin
        mySettings.isXSB_Saved := False;
      end else Exit;
   end;

   if not mySettings.isLurd_Saved then
   begin    // ���µĶ�����δ����
      i := MessageBox(Handle, '�ոյ��ƶ���δ���棬�Ƿ񱣴棿', '����', MB_ICONWARNING + MB_YESNOCANCEL);
      if i = idyes then begin
        mySettings.isLurd_Saved := True;
        SaveState();          // ����״̬�����ݿ�
      end else if i = idno then begin
        mySettings.isLurd_Saved := True;
        StatusBar1.Panels[7].Text := '������������';
      end else exit;
   end;

  fn := TmenuItem(sender).caption;
  if fn = '��ȡ�����ؿ�' then begin

     jRet := SO(MyGetMatch);
     if (jRet.O['id'] <> nil) then begin
        str := #10;
        
        id := jRet.O['id'].AsInteger;

        strBegin := jRet.O['begin'].AsString;
        strEnd := jRet.O['end'].AsString;

        if (jRet.O['main'] <> nil) then begin
            strLevel := jRet.O['main'].AsString;

            if not AnsiSameText(strLevel, 'null') then begin
               jLevel := SO(strLevel);
               title := jLevel.O['title'].AsString;
               author := jLevel.O['author'].AsString;
               level := jLevel.O['level'].AsString;
               level := StringReplace(level, '|', #10, [rfReplaceAll]);
               str := str + level + #10 + 'Title: ' + title + #10 + 'Author' + author + #10#10;
            end;
        end;
      
        if (jRet.O['extra'] <> nil) then begin
            strLevel := jRet.O['extra'].AsString;

            if not AnsiSameText(strLevel, 'null') then begin
               jLevel := SO(strLevel);
               title := jLevel.O['title'].AsString;
               author := jLevel.O['author'].AsString;
               level := jLevel.O['level'].AsString;
               level := StringReplace(level, '|', #10, [rfReplaceAll]);
               str := str + level + #10 + 'Title: ' + title + #10 + 'Author' + author + #10;
            end;
        end;

        if (jRet.O['extra2'] <> nil) then begin
            strLevel := jRet.O['extra2'].AsString;

            if not AnsiSameText(strLevel, 'null') then begin
               jLevel := SO(strLevel);
               title := jLevel.O['title'].AsString;
               author := jLevel.O['author'].AsString;
               level := jLevel.O['level'].AsString;
               level := StringReplace(level, '|', #10, [rfReplaceAll]);
               str := str + level + #10 + 'Title: ' + title + #10 + 'Author' + author + #10;
            end;
        end;

        txtList.Clear;
        Split(str, txtList);

        if LoadMapsFromTextList(txtList, False) then begin               // ���ر��� XSB
          if MapList.Count > 0 then begin   // ����������Ч�ؿ����Զ��򿪵�һ���ؿ�
            maxNumber := MapList.Count;
            mySettings.MapFileName := '';
            if LoadMap(1) then begin
              curMapNode.Trun := 0;    // Ĭ�Ϲؿ��� 0 ת
              SetMapTrun();
              InitlizeMap();
              mySettings.isXSB_Saved := False;              // ���Ӽ��а嵼��� XSB �Ƿ񱣴����
              mySettings.isLurd_Saved := True;              // �ƹؿ��Ķ����Ƿ񱣴����
              Caption := AppName + AppVer + ' - �����ؿ� ~ [' + inttostr(curMap.CurrentLevel) + '/' + inttostr(maxNumber) + ']';
              StatusBar1.Panels[7].Text := '��' + inttostr(id) + '�ڱ�����' + strBegin + ' �� ' + strEnd;
            end;
          end;
        end
        else StatusBar1.Panels[7].Text := '��ȡ�����ؿ�ʧ�ܣ�';

     end else StatusBar1.Panels[7].Text := 'û����ȡ�������ؿ���';
  end
  else begin

    if fn = '�ؿ���ת��(BoxMan.xsb)' then fn := 'BoxMan.xsb'
    else if AnsiSameText(fn, AppPath + mySettings.MapFileName) then Exit;

    if Pos(':', fn) = 0 then fn := AppPath + fn;

    if FileExists(fn) then begin
      txtList.Clear;
      txtList.loadfromfile(fn);
      QuicklyLoadMap(txtList, 1, curMapNode);       // ���ٴ򿪵�һ����ͼ
      maxNumber := GetMapNumber(txtList);                            // ȡ�����ؿ����

      if curMapNode.Rows > 2 then begin

          mySettings.MapFileName := fn;
          n := Pos(AppPath, mySettings.MapFileName);
          if n > 0 then Delete(mySettings.MapFileName, 1, Length(AppPath));
          curMap.CurrentLevel := 1;

          if not AnsiSameText(mySettings.MapFileName, 'BoxMan.xsb') then begin
             // ��������򿪵��ĵ���˳��
             size := mySettings.LaterList.Count;
             i := 0;
             while i < size do begin
                if AnsiSameText(mySettings.MapFileName, mySettings.LaterList[i]) then Break;
                Inc(i);
             end;
             if i < size then mySettings.LaterList.Move(i, 0)
             else mySettings.LaterList.Insert(0, mySettings.MapFileName);
          end;

          mySettings.isXSB_Saved := True;
          ReadQuicklyMap();

          // ��ǿ��ֹͣ��̨�̣߳��ٴ����µĺ�̨�̣߳����ص�ͼ
          isStopThread := True;
          TLoadMapThread.Create(False);

          StatusBar1.Panels[7].Text := '';
      end else StatusBar1.Panels[7].Text := '��Ч�Ĺؿ��ĵ� - ' + fn;
    end else StatusBar1.Panels[7].Text := '���ĵ��Ѷ�ʧ - ' + fn;
  end;
end;

// ����򿪵Ĺؿ����ĵ� -- �Զ����ɲ˵���
procedure Tmain.bt_LatelyClick(Sender: TObject);
var
  i, size: Integer;
  ItemL1: TMenuItem;

begin
  if isMoving then IsStop := True
  else IsStop := False;

  // ǿ��ֹͣ���ص�ͼ�ĵ��ĺ�̨�߳�
  isStopThread := True;

  size := mySettings.LaterList.Count;
  pm_Later.Items.Clear;

  if size > 0 then begin
     for i := 0 to size-1 do begin
        ItemL1 := TMenuItem.Create(Nil);
        ItemL1.Caption := mySettings.LaterList[i];
        ItemL1.OnClick := MenuItemClick;
        pm_Later.Items.Add(ItemL1);
     end;
  end;
  ItemL1 := TMenuItem.Create(Nil);
  ItemL1.Caption := '-';
  pm_Later.Items.Add(ItemL1);
  ItemL1 := TMenuItem.Create(Nil);
  ItemL1.Caption := '�ؿ���ת��(BoxMan.xsb)';
  ItemL1.OnClick := MenuItemClick;
  pm_Later.Items.Add(ItemL1);
  ItemL1 := TMenuItem.Create(Nil);
  ItemL1.Caption := '��ȡ�����ؿ�';
  ItemL1.OnClick := MenuItemClick;
  pm_Later.Items.Add(ItemL1);

  pm_Later.Popup(mouse.CursorPos.X,mouse.CursorPos.y);
//  SetCursorPos(Left + 60, Top + 55);
//  mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
//  mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
end;

// ����״̬��ť
procedure Tmain.bt_SaveClick(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  isKeyPush := False;
  
  if mySettings.isXSB_Saved then begin
    SaveState();                                   // ����״̬�����ݿ�
  end else begin
    if SaveXSBToFile() then SaveState();           // ����ؿ� XSB ���ĵ���״̬�����ݿ�
  end;
end;

// ��Ϸ�ؿ�ʼ
procedure Tmain.pm_HomeClick(Sender: TObject);
begin
  N16.Click;
end;

// �ύ�𰸵�������վ
procedure Tmain.N1Click(Sender: TObject);
var
   len: Integer;

begin
   if GetSolutionFromDB(List_Solution.ItemIndex, MySubmit.SubmitLurd) then begin   // �ύ--Lurd
      len := Length(MySubmit.SubmitLurd);
      if len > 0 then begin
          MySubmit.SubmitCountry := mySettings.SubmitCountry;       // �ύ--���һ����
          MySubmit.SubmitName    := mySettings.SubmitName;          // �ύ--����
          MySubmit.SubmitEmail   := mySettings.SubmitEmail;         // �ύ--����
          if MySubmit.ShowModal = mrOK then begin
             mySettings.SubmitCountry := MySubmit.SubmitCountry;       // �ύ--���һ����
             mySettings.SubmitName    := MySubmit.SubmitName;          // �ύ--����
             mySettings.SubmitEmail   := MySubmit.SubmitEmail;         // �ύ--����
             StatusBar1.Panels[7].Text := MySubmit.Caption;            // �ύ���
          end;
      end else StatusBar1.Panels[7].Text := '���ش�ʧ�ܣ�';
   end else StatusBar1.Panels[7].Text := '����ѡ����Ҫ�ύ�Ĵ𰸣�';
end;

// ��ʾ������վ -- ���б�
procedure Tmain.N2Click(Sender: TObject);
begin
  ShowSolutuionList.Show;
//  ShellExecute(handle,nil,pchar('http://sokoban.cn/solution_table.php'),nil,nil,SW_shownormal);
end;

// ���� xsb �ֳ� -- ���а�
procedure Tmain.XSB4Click(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  StatusBar1.Panels[7].Text := '';
  
  if (not Assigned(curMapNode)) then Exit;

  XSBToClipboard_2();
  StatusBar1.Panels[7].Text := '�ֳ� XSB ��������а壡';
end;

// �����ؿ�xsb���������� -- ���а�
procedure Tmain.XSB2Click(Sender: TObject);
var
  str: string;
  r, c: Integer;
  
begin
  if isMoving then IsStop := True
  else IsStop := False;

  StatusBar1.Panels[7].Text := '';

  if (not Assigned(curMapNode)) then Exit;

  // �ؿ� XSB
  str := GetXSB(curMapNode);

  // ���ƶ���
  if UnDoPos > 0 then begin
     if UnDoPos < MaxLenPath then UndoList[UnDoPos+1] := #0;
     str := str + PChar(@UndoList) + #10;
  end;

  // ���ƶ���
  if (ManPos_BK >= 0) and (UnDoPos_BK > 0) then begin
    c := ManPos_BK_0 mod curMapNode.Cols + 1;
    r := ManPos_BK_0 div curMapNode.Cols + 1;

    if UnDoPos_BK < MaxLenPath then UndoList_BK[UnDoPos_BK+1] := #0;
    str := str + '[' + IntToStr(c) + ', ' + IntToStr(r) + ']' + PChar(@UndoList_BK) + #10;
  end;

  // ������а�
  Clipboard.SetTextBuf(PChar(str));

  StatusBar1.Panels[7].Text := '�ؿ�����������(XSB + Lurd)��������а壡';
end;

// ����ؿ� xsb -- ���а�
procedure Tmain.XSB1Click(Sender: TObject);
var
  i: Integer;
  XSB_Text: string;
begin
  if isMoving then IsStop := True
  else IsStop := False;

  StatusBar1.Panels[7].Text := '';
  if not mySettings.isXSB_Saved then
  begin    // ���µ�XSB��δ����
    i := MessageBox(Handle, '��ǰ�ؿ���δ���棬�Ƿ񱣴棿', '����', MB_ICONWARNING + MB_YESNOCANCEL);
    if i = idyes then begin
      SaveXSBToFile();
    end else if i = idno then begin
      mySettings.isXSB_Saved := False;
    end else Exit;
  end;

  if not mySettings.isLurd_Saved then
  begin    // ���µĶ�����δ����
    i := MessageBox(Handle, '�ոյ��ƶ���δ���棬�Ƿ񱣴棿', '����', MB_ICONWARNING + MB_YESNOCANCEL);
    if i = idyes then begin
      mySettings.isLurd_Saved := True;
      SaveState();          // ����״̬�����ݿ�
    end else if i = idno then begin
      mySettings.isLurd_Saved := True;
      StatusBar1.Panels[7].Text := 'δ�����¶�����';
    end else exit;
  end;

  // ���а嵼�� XSB��������
  if (Clipboard.HasFormat(CF_TEXT) or Clipboard.HasFormat(CF_OEMTEXT)) then begin
      XSB_Text := Clipboard.asText;
      txtList.Clear;
      Split(XSB_Text, txtList);
  end else Exit;

  if LoadMapsFromTextList(txtList, True) then begin
    if MapList.Count > 0 then begin   // ����������Ч�ؿ����Զ��򿪵�һ���ؿ�
      maxNumber := MapList.Count;
      mySettings.MapFileName := '';
      if LoadMap(1) then begin
        InitlizeMap();
        curMapNode.Trun := 0;    // Ĭ�Ϲؿ��� 0 ת
        SetMapTrun();
        mySettings.isXSB_Saved := False;              // ���Ӽ��а嵼��� XSB �Ƿ񱣴����
        mySettings.isLurd_Saved := True;              // �ƹؿ��Ķ����Ƿ񱣴����
        Caption := AppName + AppVer + ' - ���а� ~ [' + inttostr(curMap.CurrentLevel) + '/' + inttostr(maxNumber) + ']';
        StatusBar1.Panels[7].Text := '�Ӽ��а���عؿ� XSB �ɹ���';
      end;
    end;
  end
  else StatusBar1.Panels[7].Text := '���ؼ��а��еĹؿ� XSB ʧ�ܣ�';
end;

// ������С����ʧȥ�����ʱ��ֹͣ����
procedure Tmain.ApplicationEvents1Minimize(Sender: TObject);
begin
  if isMoving then IsStop := True;
end;

// ���һ��
procedure Tmain.N10Click(Sender: TObject);
var
  n: Integer;
  tmpMapNode : PMapNode;        // �ؿ��ڵ�
  
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (not Assigned(curMapNode)) or (MapList.Count <= 0) then begin      //  or (not curMapNode.isEligible)
     StatusBar1.Panels[7].Text := '���޴򿪵Ĺؿ���';
     Exit;
  end;

  if not mySettings.isLurd_Saved then
  begin    // ���µĶ�����δ����
    n := MessageBox(Handle, '�ոյ��ƶ���δ���棬�Ƿ񱣴棿', '����', MB_ICONWARNING + MB_YESNOCANCEL);
    if n = idyes then begin
       SaveState();          // ����״̬�����ݿ�
    end else if n = idno then begin
       mySettings.isLurd_Saved := True;
       StatusBar1.Panels[7].Text := '������������';
    end else exit;
  end;

  tmpMapNode := nil;
  if MapList.Count > 0 then begin
     if curMap.CurrentLevel < MapList.Count then begin
        curMap.CurrentLevel := MapList.Count;
        if LoadMap(curMap.CurrentLevel) then
        begin
          InitlizeMap();
          SetMapTrun();
        end;
     end else StatusBar1.Panels[7].Text := '����û����!';
  end else begin
    if maxNumber > curMap.CurrentLevel then begin
       New(tmpMapNode);
       try
         QuicklyLoadMap(txtList, maxNumber, tmpMapNode);
         curMap.CurrentLevel := maxNumber;
         curMapNode.Map_Thin := tmpMapNode.Map_Thin;
         curMapNode.Map := tmpMapNode.Map;
         curMapNode.Rows := tmpMapNode.Rows;
         curMapNode.Cols := tmpMapNode.Cols;
         curMapNode.Boxs := tmpMapNode.Boxs;
         curMapNode.Goals := tmpMapNode.Goals;
         curMapNode.Trun := tmpMapNode.Trun;
         curMapNode.Title := tmpMapNode.Title;
         curMapNode.Author := tmpMapNode.Author;
         curMapNode.Comment := tmpMapNode.Comment;
         curMapNode.CRC32 := tmpMapNode.CRC32;
         curMapNode.CRC_Num := tmpMapNode.CRC_Num;
         curMapNode.Solved := tmpMapNode.Solved;
         curMapNode.isEligible := tmpMapNode.isEligible;
         curMapNode.Num := tmpMapNode.Num;
         ReadQuicklyMap();
       finally
          if Assigned(tmpMapNode) then begin
             Dispose(PMapNode(tmpMapNode));
             tmpMapNode := nil;
          end;
       end;
    end else StatusBar1.Panels[7].Text := '����û����!';
  end;
end;

// ��һ��
procedure Tmain.N8Click(Sender: TObject);
var
  bt: Integer;
  tmpMapNode : PMapNode;        // �ؿ��ڵ�

begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (not Assigned(curMapNode)) or (MapList.Count <= 0) then begin      //  or (not curMapNode.isEligible)
     StatusBar1.Panels[7].Text := '���޴򿪵Ĺؿ���';
     Exit;
  end;

  if curMap.CurrentLevel > 1 then
  begin
    if not mySettings.isLurd_Saved then
    begin    // ���µĶ�����δ����
      bt := MessageBox(Handle, '�ոյ��ƶ���δ���棬�Ƿ񱣴棿', '����', MB_ICONWARNING + MB_YESNOCANCEL);
      if bt = idyes then begin
         SaveState();          // ����״̬�����ݿ�
      end else if bt = idno then begin
         mySettings.isLurd_Saved := True;
         StatusBar1.Panels[7].Text := '������������';
      end else exit;
    end;

    if MapList.Count > 0 then begin
      curMap.CurrentLevel := 1;
      if LoadMap(curMap.CurrentLevel) then
      begin
        InitlizeMap();
        SetMapTrun();
      end;
    end else Begin
      New(tmpMapNode);
      try
        QuicklyLoadMap(txtList, 1, tmpMapNode);
        if tmpMapNode.Rows > 2 then begin
           curMap.CurrentLevel := 1;
           curMapNode.Map_Thin := tmpMapNode.Map_Thin;
           curMapNode.Map := tmpMapNode.Map;
           curMapNode.Rows := tmpMapNode.Rows;
           curMapNode.Cols := tmpMapNode.Cols;
           curMapNode.Boxs := tmpMapNode.Boxs;
           curMapNode.Goals := tmpMapNode.Goals;
           curMapNode.Trun := tmpMapNode.Trun;
           curMapNode.Title := tmpMapNode.Title;
           curMapNode.Author := tmpMapNode.Author;
           curMapNode.Comment := tmpMapNode.Comment;
           curMapNode.CRC32 := tmpMapNode.CRC32;
           curMapNode.CRC_Num := tmpMapNode.CRC_Num;
           curMapNode.Solved := tmpMapNode.Solved;
           curMapNode.isEligible := tmpMapNode.isEligible;
           curMapNode.Num := tmpMapNode.Num;
           ReadQuicklyMap();
        end;
      finally
        if Assigned(tmpMapNode) then begin
           Dispose(PMapNode(tmpMapNode));
           tmpMapNode := nil;
        end;
      end;
    end;
  end
  else StatusBar1.Panels[7].Text := 'ǰ��û����!';
end;

// ��һ��δ��ؿ�
procedure Tmain.N9Click(Sender: TObject);
var
  i: Integer;
  mNode: PMapNode;
  s: string;

begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (not Assigned(curMapNode)) or (MapList.Count <= 0) then begin  //  or (not curMapNode.isEligible)
     StatusBar1.Panels[7].Text := '���޴򿪵Ĺؿ���';
     Exit;
  end;

  s := 'ǰ��û���ҵ�δ��ؿ�!';
  if curMap.CurrentLevel > 1 then
  begin
    i := curMap.CurrentLevel;
    while i > 1 do
    begin
      Dec(i);
      mNode := MapList.Items[i - 1];
      if not mNode.Solved then
        Break;
    end;

    if (i > 0) and (not mNode.Solved) then
    begin
      if LoadMap(i) then
      begin
        InitlizeMap();
        SetMapTrun();
      end;
      s := '��һ��δ��ؿ���';
    end;
  end;
  StatusBar1.Panels[7].Text := s;

end;

// ��һ��δ��ؿ�
procedure Tmain.N11Click(Sender: TObject);
var
  i: Integer;
  mNode: PMapNode;
  s: string;
  
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (not Assigned(curMapNode)) or (MapList.Count <= 0) then begin     // or (not curMapNode.isEligible) 
     StatusBar1.Panels[7].Text := '���޴򿪵Ĺؿ���';
     Exit;
  end;

  s := '����û���ҵ�δ��ؿ�!';
  if curMap.CurrentLevel < MapList.Count then
  begin
    i := curMap.CurrentLevel;
    while i < MapList.Count do
    begin
      inc(i);
      mNode := MapList.Items[i - 1];
      if not mNode.Solved then
        Break;
    end;

    if (i <= MapList.Count) and (not mNode.Solved) then
    begin
      if LoadMap(i) then
      begin
        InitlizeMap();
        SetMapTrun();
      end;
      s := '��һ��δ��ؿ���';
    end;
  end;
  StatusBar1.Panels[7].Text := s;
end;

// ������ť���Ҽ��˵� -- ����
procedure Tmain.N15Click(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then Exit;
  
  if mySettings.isBK then
  begin
    UnDo_BK(GetStep(mySettings.isBK));
  end
  else
  begin
    if (LastSteps < 0) or (LastSteps > UnDoPos) then
      UnDo(GetStep2(mySettings.isBK))
    else
      UnDo(UnDoPos - LastSteps);
    LastSteps := -1;              // �������һ�ε���ǰ�Ĳ���
  end;
end;

// ������ť���Ҽ��˵� -- ����
procedure Tmain.N18Click(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then Exit;
  
  if mySettings.isBK then
    ReDo_BK(GetStep2(mySettings.isBK))
  else
    ReDo(GetStep(mySettings.isBK));
end;

// ������ť���Ҽ��˵� -- ��������
procedure Tmain.N14Click(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then Exit;
  
  if mySettings.isBK then UnDo_BK(1)
  else UnDo(1);
end;

// ������ť���Ҽ��˵� -- ��������
procedure Tmain.N17Click(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then Exit;

  if mySettings.isBK then ReDo_BK(1)
  else ReDo(1);
end;

// ������ť���Ҽ��˵� -- ������
procedure Tmain.N16Click(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then Exit;
  
  isNoDelay := True;
  if mySettings.isBK then UnDo_BK(UnDoPos_BK)
  else UnDo(UnDoPos);
  isNoDelay := false;
  StatusBar1.Panels[7].Text := '�����ף�';
end;

// ������ť���Ҽ��˵� -- ����β
procedure Tmain.N19Click(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then Exit;
  
  isNoDelay := True;
  if mySettings.isBK then ReDo_BK(ReDoPos_BK)
  else ReDo(ReDoPos);
  isNoDelay := false;
  StatusBar1.Panels[7].Text := '����β��';
end;

// ����β -- ���๦�ܰ�ť
procedure Tmain.N21Click(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then Exit;

  isKeyPush := True;
  if mySettings.isBK then begin
    UnDo_BK(UnDoPos_BK);
  end else begin
    UnDo(UnDoPos);
  end;
end;

// ������ -- ���๦�ܰ�ť
procedure Tmain.N22Click(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then Exit;

  isKeyPush := True;
  if mySettings.isBK then begin
    ReDo_BK(ReDoPos_BK);
  end else begin
    ReDo(ReDoPos);
  end;
end;

// ��һ����ť -- ��갴��
procedure Tmain.bt_PreMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if isMoving then IsStop := True;
end;

// �����ڶ����Ĺؿ��������� -- ��������������ַ�
procedure Tmain.ed_sel_MapKeyPress(Sender: TObject; var Key: Char);
begin
   // ������������/С����/�˸��
   if not (Key in ['0'..'9']) then Key := #0;
   ed_sel_Map.Tag := 1;
end;

// �����ڶ����Ĺؿ��������� -- ������� -- ���ٴ򿪸���ŵĹؿ���ͼ
procedure Tmain.ed_sel_MapChange(Sender: TObject);
var
 edt: TEdit;
 str: string;
 n, bt: integer;
 tmpMapNode : PMapNode;        // �ؿ��ڵ�
 
begin
   // �ų��Ǽ�������� OnChange �¼�
   if ed_sel_Map.Tag = 0 then Exit;
   ed_sel_Map.Tag := 0;
   
   // ��ȡ��ǰ�ı�����
   edt := TEdit(Sender);
   str := edt.Text;

   try
      n := StrToInt(str);
   except
      StatusBar1.Panels[7].Text := '��Ч�Ĺؿ���ţ�';
      Exit;
   end;

   if n > 0 then begin
      if not mySettings.isLurd_Saved then
      begin    // ���µĶ�����δ����
        bt := MessageBox(Handle, '�ոյ��ƶ���δ���棬�Ƿ񱣴棿', '����', MB_ICONWARNING + MB_YESNOCANCEL);
        if bt = idyes then begin
           SaveState();          // ����״̬�����ݿ�
        end else if bt = idno then begin
           mySettings.isLurd_Saved := True;
           StatusBar1.Panels[7].Text := '������������';
        end else exit;
      end;
      try
         if MapList.Count = 0 then begin
            // ���ٴ�ָ���ĵ�ͼ
            New(tmpMapNode);
            try
              if n > maxNumber then n := maxNumber;     // ����������ִ��ڹؿ���ʱ���Զ���������Ǹ��ؿ�

              QuicklyLoadMap(txtList, n, tmpMapNode);
              if tmpMapNode.Rows > 2 then begin

                 curMapNode.Map_Thin := tmpMapNode.Map_Thin;
                 curMapNode.Map := tmpMapNode.Map;
                 curMapNode.Rows := tmpMapNode.Rows;
                 curMapNode.Cols := tmpMapNode.Cols;
                 curMapNode.Boxs := tmpMapNode.Boxs;
                 curMapNode.Goals := tmpMapNode.Goals;
                 curMapNode.Trun := tmpMapNode.Trun;
                 curMapNode.Title := tmpMapNode.Title;
                 curMapNode.Author := tmpMapNode.Author;
                 curMapNode.Comment := tmpMapNode.Comment;
                 curMapNode.CRC32 := tmpMapNode.CRC32;
                 curMapNode.CRC_Num := tmpMapNode.CRC_Num;
                 curMapNode.Solved := tmpMapNode.Solved;
                 curMapNode.isEligible := tmpMapNode.isEligible;
                 curMapNode.Num := tmpMapNode.Num;
                 curMap.CurrentLevel := n;

                 mySettings.isXSB_Saved := True;
                 ReadQuicklyMap();

                 Caption := AppName + AppVer + ' - ' + ExtractFileName(ChangeFileExt(mySettings.MapFileName, EmptyStr)) + ' ~ [' + inttostr(curMap.CurrentLevel) + '/' + inttostr(maxNumber) + ']';

                 StatusBar1.Panels[7].Text := '';
              end;
            finally
              if Assigned(tmpMapNode) then begin
                 Dispose(PMapNode(tmpMapNode));
                 tmpMapNode := nil;
              end;
            end;
         end else begin
            if (n > 0) and (n <= MapList.Count) then
            begin
              curMap.CurrentLevel := n;
              if LoadMap(curMap.CurrentLevel) then
              begin
                InitlizeMap();
                SetMapTrun();
              end;
            end;
         end;
      except
         StatusBar1.Panels[7].Text := 'û�ҵ�ָ���Ĺؿ���';
      end;
   end;
end;

// ¼�ƶ���
procedure Tmain.F91Click(Sender: TObject);
begin
  DoAct(5);
end;

// ���ոյ���Ĺؿ������뵽�ؿ���ת�� -- ��Ӧ��Ctrl + K�����
procedure Tmain.XSB0Click(Sender: TObject);
var
  myXSBFile, myBakFile: Textfile;
  i: Integer;
  mapNode: PMapNode;               // �ؿ��ڵ�
  line: string;

begin

  StatusBar1.Panels[7].Text := '';

  if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then Exit;

  if mySettings.MapFileName = '' then begin
    if MessageBox(Handle, PChar('���ոյ����' + inttostr(MapList.Count) + '���ؿ������뵽�ؿ���ת�⣬' + #10 + 'ȷ����'), '����', MB_ICONINFORMATION + MB_OKCANCEL) <> idOK then Exit;

    mySettings.MapFileName := 'BoxMan.xsb';

    AssignFile(myXSBFile, AppPath + mySettings.MapFileName);

    // ����
    if FileExists(AppPath + mySettings.MapFileName) then CopyFile(PChar(AppPath + mySettings.MapFileName), PChar(AppPath + 'BoxMan.xsb.bak'), False);   // ���浽��ת�ؿ���

    Rewrite(myXSBFile);                                                 // ����

    try
      // ��д���µ�����
      for i := 0 to MapList.Count - 1 do
      begin
        mapNode := MapList.Items[i];

        Writeln(myXSBFile, GetXSB(mapNode));

//        Writeln(myXSBFile, '');
//        Writeln(myXSBFile, mapNode.Map);
//
//        if Trim(mapNode.Title) <> '' then
//          Writeln(myXSBFile, 'Title: ' + mapNode.Title);
//        if Trim(mapNode.Author) <> '' then
//          Writeln(myXSBFile, 'Author: ' + mapNode.Author);
//        if Trim(mapNode.Comment) <> '' then
//        begin
//          Writeln(myXSBFile, 'Comment: ');
//          Writeln(myXSBFile, mapNode.Comment);
//          Writeln(myXSBFile, 'Comment_end: ');
//        end;
      end;

      // �ٰѱ��ݵ�����׷�ӽ���
      if FileExists(AppPath + 'BoxMan.xsb.bak') then begin
         AssignFile(myBakFile, AppPath + 'BoxMan.xsb.bak');
         Reset(myBakFile);
         try
           Writeln(myXSBFile, '');
           while not eof(myBakFile) do begin
              readln(myBakFile, line);        // ��ȡһ��
              Writeln(myXSBFile, line);
           end;
         finally
           Closefile(myBakFile);
         end;
      end;
    finally
      Closefile(myXSBFile);
    end;

    mySettings.isXSB_Saved := True;            // ���Ӽ��а嵼��� XSB �Ƿ񱣴����

    // ��ǿ��ֹͣ��̨�̣߳��ٴ����µĺ�̨�̣߳����ص�ͼ
    isStopThread := True;
    txtList.Clear;
    txtList.loadfromfile('BoxMan.xsb');
    TLoadMapThread.Create(False);
    maxNumber := GetMapNumber(txtList);                            // ȡ�����ؿ����

    StatusBar1.Panels[7].Text := '����ؿ���ת�⡣';
    Caption := AppName + AppVer + ' - ' + ExtractFileName(ChangeFileExt(mySettings.MapFileName, EmptyStr)) + ' ~ [' + inttostr(curMap.CurrentLevel) + '/' + inttostr(maxNumber) + ']';
  end;
end;

// �����ڵ�����������ʾ/���ء���ť
procedure Tmain.bt_LeftBarClick(Sender: TObject);
begin
  mySettings.isLeftBar := not mySettings.isLeftBar;

  if mySettings.isLeftBar then begin
     pl_Side.Visible := True;
     bt_LeftBar.Caption := '<';
  end else begin
     pl_Side.Visible := False;
     bt_LeftBar.Caption := '>';
  end;
  NewMapSize();
  DrawMap();        // ����ͼ
end;

// ����lurd - ���а�
procedure Tmain.Lurd1Click(Sender: TObject);
var
  i, myCell: Integer;
  
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then Exit;

  if LoadLurdFromClipboard(mySettings.isBK) then begin
    StatusBar1.Panels[7].Text := '�Ӽ��а���� Lurd��';
    if mySettings.isBK and (ManPos_BK_0_2 >= 0) then begin   // �����˵�λ��
      myCell := map_Board_OG[ManPos_BK_0_2];
      if (myCell = FloorCell) or (myCell = BoxCell) or (myCell = ManCell) then begin
        for i := 0 to curMap.MapSize - 1 do begin
          if map_Board_OG[i] = BoxCell then
            map_Board_BK[i] := GoalCell
          else if map_Board_OG[i] = GoalCell then
            map_Board_BK[i] := BoxCell
          else if map_Board_OG[i] = ManCell then
            map_Board_BK[i] := FloorCell
          else if map_Board_OG[i] = ManGoalCell then
            map_Board_BK[i] := BoxCell
          else
            map_Board_BK[i] := map_Board_OG[i];
        end;
        ManPos_BK_0 := ManPos_BK_0_2;
        ManPos_BK := ManPos_BK_0_2;
        if map_Board_BK[ManPos_BK] = FloorCell then
          map_Board_BK[ManPos_BK] := ManCell
        else if map_Board_BK[ManPos_BK] = GoalCell then
          map_Board_BK[ManPos_BK] := ManGoalCell
        else begin
          ManPos_BK_0_2 := -1;
          ManPos_BK_0 := -1;
          ManPos_BK := -1;
        end;
        UnDoPos_BK := 0;
        MoveTimes_BK := 0;
        PushTimes_BK := 0;
        LastSteps := -1;                           // �������һ�ε���ǰ�Ĳ���
        IsManAccessibleTips_BK := false;           // �Ƿ���ʾ�˵����ƿɴ���ʾ
        IsBoxAccessibleTips_BK := false;           // �Ƿ���ʾ���ӵ����ƿɴ���ʾ
        DrawMap();         // ����ͼ
        SetButton();       // ���ð�ť״̬
        ShowStatusBar();   // ����״̬��
        StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos_BK mod curMapNode.Cols, ManPos_BK div curMapNode.Cols) + ' - [ ' + IntToStr(ManPos_BK mod curMapNode.Cols + 1) + ', ' + IntToStr(ManPos_BK div curMapNode.Cols + 1) + ' ]';       // ���
      end;
    end;
    curMap.isFinish := False;
    if mySettings.isBK then begin
      if ManPos_BK >= 0 then ReDo_BK(ReDoPos_BK);
    end else ReDo(ReDoPos);
  end;
end;

procedure Tmain.Lurd2Click(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then Exit;

  if LurdToClipboard(ManPos_BK_0 mod curMapNode.Cols, ManPos_BK_0 div curMapNode.Cols) then
     StatusBar1.Panels[7].Text := '�������� Lurd ������а壡';
end;

procedure Tmain.Lurd3Click(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (not Assigned(curMapNode)) or (not curMapNode.isEligible) then Exit;

  if LurdToClipboard2(mySettings.isBK) then
     StatusBar1.Panels[7].Text := '�������� Lurd ������а壡';
end;

// ����
procedure Tmain.sb_HelpClick(Sender: TObject);
begin
  ShellExecute(Application.handle, nil, PChar(AppPath + 'BoxManHelp.txt'), nil, nil, SW_SHOWNORMAL);
  ContentClick(Self);
end;

// ���������Ҽ�ʱѡ����Ŀ
procedure Tmain.List_SolutionMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  APoint: TPoint;
  Index: Integer;
  List: TListBox;
begin
  List := TListBox(Sender);

  if Button = mbRight then begin
    APoint.x := X;
    APoint.y := Y;
    Index := List.ItemAtPos(APoint, True);
    List.ItemIndex := Index;
  end;
end;

// �Ƿ�˫����š�����ѡ��
procedure Tmain.N29Click(Sender: TObject);
begin
  isSelectMod := False;

  mySettings.isNumber := not mySettings.isNumber;
  if mySettings.isNumber then
    N29.Checked := True
  else
    N29.Checked := False;

  DrawMap();                                  // ���µ�ͼ��ʾ
  ShowStatusBar();

end;

// �����ڶ��������ࡱ���ܲ˵���ť
procedure Tmain.funMenuClick(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  pmBoardBK.Popup(mouse.CursorPos.X,mouse.CursorPos.y);
end;

// ��ק�ؿ��ĵ������򴰿�ʱ���Զ���
procedure Tmain.WMDROPFILES(var Msg: TWMDROPFILES);
var
  DropFileName: string;
  DropCount: integer;
  i: integer;

  bt: LongWord;
  size, n: Integer;
    
begin
  inherited;
  SetLength(DropFileName, MAX_PATH);
  DropCount := DragQueryFile(Msg.Drop, $FFFFFFFF, nil, 0);
  for i := 0 to DropCount-1 do
  begin
    DragQueryFile(Msg.Drop, i, PChar(DropFileName), MAX_PATH);
  end;
  DragFinish(Msg.Drop);

  n := Pos(#0, DropFileName);
  if n > 0 then DropFileName := LeftStr(DropFileName, n-1);

  if isMoving then IsStop := True
  else IsStop := False;

  // ǿ�Ƽ��ص�ͼ�ĵ��ĺ�̨�߳�
  isStopThread := True;

  if not mySettings.isXSB_Saved then
  begin    // ���µĶ�����δ����
    bt := MessageBox(Handle, '��ǰ�ؿ���δ���棬�Ƿ񱣴棿', '����', MB_ICONWARNING + MB_YESNOCANCEL);
    if bt = idyes then
    begin
      SaveXSBToFile();
    end
    else if bt = idno then
    begin
    end
    else
      Exit;
  end;

  if not mySettings.isLurd_Saved then
  begin    // ���µĶ�����δ����
    bt := MessageBox(Handle, '�ոյ��ƶ���δ���棬�Ƿ񱣴棿', '����', MB_ICONWARNING + MB_YESNOCANCEL);
    if bt = idyes then begin
       SaveState();          // ����״̬�����ݿ�
    end else if bt = idno then begin
       mySettings.isLurd_Saved := True;
       StatusBar1.Panels[7].Text := '������������';
    end else exit;
  end;

  if AnsiSameText(AppPath + mySettings.MapFileName, DropFileName) then Exit;     // ��ǰ�ĵ�������Ҫ���´�

  txtList.Clear;
  txtList.LoadFromFile(DropFileName);
  QuicklyLoadMap(txtList, 1, curMapNode);
  maxNumber := GetMapNumber(txtList);                            // ȡ�����ؿ����

  if (Assigned(curMapNode)) and (curMapNode.Rows  > 2) then begin
      curMap.CurrentLevel := 1;
      mySettings.MapFileName := DropFileName;

      n := Pos(AppPath, mySettings.MapFileName);
      if n > 0 then Delete(mySettings.MapFileName, 1, Length(AppPath));

      ReadQuicklyMap();

      mySettings.isXSB_Saved := True;

      // ��ǿ��ֹͣ��̨�����̣߳��ٴ����µĺ�̨�̣߳����ص�ͼ
      isStopThread := True;
      TLoadMapThread.Create(False);

      if not AnsiSameText(mySettings.MapFileName, 'BoxMan.xsb') then begin
        mySettings.LaterList.Insert(0, mySettings.MapFileName);
        size := mySettings.LaterList.Count;
        i := 1;
        while i < size do begin
          if AnsiSameText(mySettings.LaterList[i], mySettings.MapFileName) then begin
             mySettings.LaterList.Delete(i);
             Break;
          end else inc(i);
        end;
        if mySettings.LaterList.Count > 10 then mySettings.LaterList.Delete(10);
      end;

      StatusBar1.Panels[7].Text := '';
  end else StatusBar1.Panels[7].Text := '��Ч�Ĺؿ��ĵ� - ' + DropFileName;
end;

// ������߳� -- ���ں�̨����
procedure Tmain.N27Click(Sender: TObject);
var
  curFileName: string;
begin
  if isMoving then IsStop := True
  else IsStop := False;

  curFileName := mySettings.MapFileName;

  try
    if Pos(':', curFileName) = 0 then curFileName := AppPath + curFileName;

    if (ExtractFilePath(curFileName) <> '') then
        MyOpenFile.DirectoryListBox1.Directory := ExtractFilePath(curFileName)
    else
        MyOpenFile.DirectoryListBox1.Directory := AppPath;

    MyOpenFile.DriveComboBox1.Drive := MyOpenFile.DirectoryListBox1.Directory[1];
  except
    MyOpenFile.DirectoryListBox1.Directory := AppPath;
    MyOpenFile.DriveComboBox1.Drive := MyOpenFile.DirectoryListBox1.Directory[1];
  end;

  MyOpenFile.FileListBox1.FileName := '';

  MyOpenFile.Show;
  MyOpenFile.WindowState := wsNormal;
end;

// ��ʱ������ձ������ͷŵ��ڴ�
procedure Tmain.Timer2Timer(Sender: TObject);
begin
end;

// �������ڶ����Ĺؿ���ű༭����֧�֡��˸����
procedure Tmain.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = 8 then Key := #0;
end;

// �ó���ֻ����һ�ε�һЩ����
procedure Tmain.pl_GroundMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Edit1.SetFocus;  // һ�������ؼ����������뽹���õ�
end;

procedure Tmain.pnl_TrunMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  StatusBar1.Panels[7].Text := pnl_Trun.Hint;
end;

// �Ƿ�������ת�ؿ�
procedure Tmain.N30Click(Sender: TObject);
begin
  isSelectMod := False;

  mySettings.isRotate := not mySettings.isRotate;
  if mySettings.isRotate then
    N30.Checked := True
  else
    N30.Checked := False;

  DrawMap();                                  // ���µ�ͼ��ʾ
  ShowStatusBar();
end;

initialization
  CreateMapFile;

finalization
  FreeMapFile;

end.

