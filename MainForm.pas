unit MainForm;

{$D+}

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
  ShellAPI, Menus, Clipbrd, Math, AppEvnts, StrUtils, LoadMapUnit, SQLiteTable3;

type
  TSetting = record     // 程序设置项目
    myTop: integer;            // 上次退出时，窗口的位置及大小
    myLeft: integer;
    myWidth: integer;
    myHeight: integer;
    bwTop: integer;            // 上关卡浏览窗口的位置及大小的记忆
    bwLeft: integer;
    bwWidth: integer;
    bwHeight: integer;
    bwStyle: integer;          // 关卡浏览样式
    mySpeed: integer;          // 当前移动速度
    bwBKColor: integer;        // 关卡浏览界面的背景色
    MapFileName: string;       // 当前关卡集文档名
    SkinFileName: string;      // 当前皮肤文档名
    isGoThrough: boolean;      // 穿越是否开启
    isIM: boolean;             // 瞬移是否开启
    isBK: boolean;             // 是否逆推模式
    isSameGoal: boolean;       // 逆推时，使用正推目标位
    isJijing: boolean;         // 即景目标位
    isXSB_Saved: boolean;      // 当从剪切板导入的 XSB 是否保存过了
    isLurd_Saved: boolean;     // 推关卡的动作是否保存过了
    isOddEven: Boolean;        // 是否显示奇偶特效
    isLeftBar: Boolean;        // 是否显示左侧边栏
    isShowNoVisited: Boolean;  // 是否标识未曾访问过的格子
    LaterList: TStringList;    // 最近推过的关卡集
    SubmitCountry: string;     // 提交--国家或地区
    SubmitName: string;        // 提交--姓名
    SubmitEmail: string;       // 提交--邮箱
  end;

type                  // 当前地图信息
  TMapState = record
    CurrentLevel: integer;   // 当前关卡序号
    ManPosition: integer;    // 正推初始状态，人的位置
    MapSize: integer;        // 地图尺寸
    CellSize: integer;       // 画地图时，当前的单元格尺寸
    Recording: Boolean;      // 是否在动作录制状态
    Recording_BK: Boolean;   // 是否在动作录制状态 -- 逆推
    StartPos: Integer;       // 动作录制的开始点
    StartPos_BK: Integer;    // 动作录制的开始点 -- 逆推
    isFinish: Boolean;       // 是否得到答案，允许观看答案了 - 当解关成功或导入正确答案后，此标志为真，表示可以“观看”答案了
  end;

type
  Tmain = class(TForm)
    pl_Ground: TPanel;
    StatusBar1: TStatusBar;
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
    ApplicationEvents1: TApplicationEvents;
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
    SpeedButton1: TSpeedButton;
    N26: TMenuItem;
    N27: TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bt_OddEvenMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure bt_OddEvenMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure map_ImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ContentClick(Sender: TObject);              // 帮助
    procedure Restart(is_BK: Boolean);                    // 关卡重新开始
    procedure bt_PreClick(Sender: TObject);               // 上一关
    procedure bt_NextClick(Sender: TObject);              // 下一关
    procedure bt_UnDoClick(Sender: TObject);              // UnDo 按钮
    procedure bt_ReDoClick(Sender: TObject);              // ReDo 按钮
    procedure bt_GoThroughClick(Sender: TObject);         // 穿越开关
    procedure bt_IMClick(Sender: TObject);                // 瞬移开关
    procedure bt_BKClick(Sender: TObject);                // 逆推模式
    procedure SetButton();                                // 设置按钮状态
    procedure bt_OpenClick(Sender: TObject);              // 打开关卡文档
    procedure bt_SkinClick(Sender: TObject);              // 选择皮肤
    function GetWall(r, c: Integer): Integer;            // 计算画地图时，使用那块墙壁图元
    function GetCur(x, y: Integer): string;              // 计算标尺
    procedure DrawLine(cs: TCanvas; x1, y1: Integer; isLine: boolean);      // 画格线
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
    procedure so_XSBAll_LurdAll1_FileClick(Sender: TObject);       // 计算访问过的格子
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
    procedure SpeedButton1Click(Sender: TObject);

  private
    // 当前地图参数
    MoveTimes, PushTimes: integer;                    // 正推推移步数
    MoveTimes_BK, PushTimes_BK: integer;              // 逆推推移步数
    IsManAccessibleTips: boolean;                     // 是否显示人的正推可达提示
    IsManAccessibleTips_BK: boolean;                  // 是否显示人的逆推可达提示
    IsBoxAccessibleTips: boolean;                     // 是否显示箱子的正推可达提示
    IsBoxAccessibleTips_BK: boolean;                  // 是否显示箱子的逆推可达提示

    BoxNum_Board: array[0..9999] of integer;          // 箱子编号
    PosNum_Board: array[0..9999] of integer;          // 位置编号
    BoxNum_Board_BK: array[0..9999] of integer;       // 箱子编号 - 逆推
    PosNum_Board_BK: array[0..9999] of integer;       // 位置编号 - 逆推
    map_Selected: array[0..9999] of Boolean;          // 选中的单元格
    map_Selected_BK: array[0..9999] of Boolean;       // 选中的单元格 - 逆推
    map_Board_Visited: array[0..9999] of Boolean;     // 访问过的格子
    BoxNumber: integer;                               // 箱子数
    GoalNumber: integer;                              // 目标点数
    ManPos: integer;                                  // 人的位置 -- 正推
    ManPos_BK: integer;                               // 人的位置 -- 逆推
    OldBoxPos: integer;                               // 被点击的箱子的位置 -- 正推
    OldBoxPos_BK: integer;                            // 被点击的箱子的位置 -- 逆推

    LastSteps: Integer;                               // 正推最后一次点推前的步数

    // 地图
    function LoadMap(MapIndex: integer): boolean;     // 加载关卡
    procedure ReadQuicklyMap();                       // 用 QuicklyLoadMap() 加载到的地图，装填游戏数据
    procedure InitlizeMap();                          // 地图初始化
    procedure NewMapSize();                           // 重新计算地图尺寸
    procedure DrawMap();                              // 画地图

    // 人与箱子的移动
    function IsComplete(): boolean;                   // 是否过关 - 正推
    function IsComplete_BK(): boolean;                // 是否过关 - 逆推
    function IsMeets(ch: Char): Boolean;              // 是否正逆相合
    procedure ReDo(Steps: Integer);                   // 重做一步 - 正推
    procedure UnDo(Steps: Integer);                   // 撤销一步 - 正推
    procedure ReDo_BK(Steps: Integer);                // 重做一步 - 逆推
    procedure UnDo_BK(Steps: Integer);                // 撤销一步 - 逆推
    procedure GameDelay();                            // 延时
    procedure DoAct(n:  Integer);                     // 自动执行“寄存器”动作

    // 存取配置信息
    procedure LoadSttings();
    procedure SaveSttings();
    procedure ShowStatusBar();                        // 刷新底部状态栏
    procedure SetMapTrun();                           // 更新地图旋转状态

    function GetStep(is_BK: Boolean): Integer;        // 解析正推 reDo 动作节点 -- 每推一个箱子为一个动作
    function GetStep2(is_BK: Boolean): Integer;       // 解析正推 unDo 动作节点 -- 每推一个箱子为一个动作
    function SaveXSBToFile(): Boolean;                // 保存关卡 XSB 到文档
    function SaveSolution(n: Integer): Boolean;       // 新增答案
    function SaveState(): Boolean;                    // 保存状态
    function LoadState(): Boolean;                    // 加载状态
    function GetSolution(mapNpde: PMapNode): string;  // 加载指定关卡的所有答案
    function GetStateFromDB(index: Integer; var x: Integer; var y: Integer; var str1: string; var str2: string): Boolean;    // 从答案库加载一条状态
    function GetSolutionFromDB(index: Integer; var str: string): Boolean;                                                    // 从答案库加载一条答案
    procedure MenuItemClick(Sender: TObject);
    function GetCountBox(): string;                   // 数箱子

  public
    mySettings: TSetting;                             // 程序配置项变量
    curMap: TMapState;                                // 当前的地图配置

    map_Board_BK: array[0..9999] of integer;          // 逆推地图
    map_Board: array[0..9999] of integer;             // 正推地图
    map_Board_OG: array[0..9999] of integer;          // 原始地图
    
    function LoadSolution(): Boolean;                 // 加载答案

  end;

const
  minWindowsWidth = 600;                                           // 程序窗口最小尺寸限制
  minWindowsHeight = 400;
  
  DelayTimes: array[0..4] of dword = (5, 150, 275, 550, 1000);     // 游戏延时 -- 速度控制

  MapTrun: array[0..7] of string = ('0转', '1转', '2转', '3转', '4转', '5转', '6转', '7转');
  SpeedInf: array[0..4] of string = ('最快', '较快', '中速', '较慢', '最慢');
  
  AppName = 'BoxMan';
  AppVer = ' V2.1';

var
  main: Tmain;
  
  BoxManDBpath: string;                             // 答案库路径文档名

  tmpTrun: integer;
  SoltionList: Tlist;     // 答案列表项
  StateList: Tlist;       // 状态列表项

  // 动作控制变量
  isMoving: boolean;      // 是否正在移动画面
  IsStop: boolean;        // 是否需要停止移动画面
  isNoDelay: Boolean;     // 是否为无延时动作 -- 至首、至尾，或导入动作、打开状态时使用
  isKeyPush: Boolean;     // 是否为关键帧推动 -- 空格键和退格键控制的

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

implementation

uses
  DateUtils, LogFile, MyInf, Submit, IDHttp, superobject, ShowSolutionList, OpenFile,
  LoadSkin, PathFinder, LurdAction, BrowseLevels, CRC_32, Actions, myTest;

var
  myPathFinder: TPathFinder;

  gotoLeft, gotoPos, gotoWidth: Integer;                  // 状态栏最右边一栏的左界及宽度

  LeftTopPos, RightBottomPos: TPoint;                     // 选择单元格的左上和右下位置
  LeftTopXY, RightBottomXY: TPoint;                       // 当前选择焦点框的左上和右下位置
  isSelectMod: Boolean;                                   // 是否触动了选择模式 -- Ctrl + 左键单击单元格
  isDelSelect: Boolean;                                   // 是否触动了减法选择模式 -- Alt + 左键单击单元格
  isSelecting: Boolean;                                   // 是否正处于选择模式 -- Ctrl + 左键拖动

  DoubleClickPos: TPoint;                                 // 当前双击的位置

  isCommandLine: Boolean;                                 // 是否有启动参数，有启动参数时，关卡文档名不记录到 ini

{$R *.DFM}

// 重置 SolvedLevel 数组
procedure ResetSolvedLevel();
var
  i: Integer;
begin
  for i := 1 to 30 do SolvedLevel[i] := 0;
end;

// 加载配置信息
procedure Tmain.LoadSttings();
var
  IniFile: TIniFile;
  i: Integer;
  s: string;

begin
  
  IniFile := TIniFile.Create(AppPath + AppName + '.ini');

  try
    mySettings.myTop := IniFile.ReadInteger('Settings', 'Top', 100);            // 上次退出时，窗口的位置及大小
    mySettings.myLeft := IniFile.ReadInteger('Settings', 'Left', 100);
    mySettings.myWidth := IniFile.ReadInteger('Settings', 'Width', 800);
    mySettings.myHeight := IniFile.ReadInteger('Settings', 'Height', 600);
    mySettings.bwTop := IniFile.ReadInteger('Settings', 'bwTop', 100);          // 关卡浏览窗口的位置及大小的记忆
    mySettings.bwLeft := IniFile.ReadInteger('Settings', 'bwLeft', 100);
    mySettings.bwWidth := IniFile.ReadInteger('Settings', 'bwWidth', 800);
    mySettings.bwHeight := IniFile.ReadInteger('Settings', 'bwHeight', 600);
    mySettings.bwStyle := IniFile.ReadInteger('Settings', 'bwStyle', 0);
    mySettings.SubmitCountry := IniFile.ReadString('Settings', 'SubmitCountry', 'CN'); // 提交--国家或地区
    mySettings.SubmitName := IniFile.ReadString('Settings', 'SubmitName', '');         // 提交--姓名
    mySettings.SubmitEmail := IniFile.ReadString('Settings', 'SubmitEmail', '');       // 提交--邮箱
    mySettings.mySpeed := IniFile.ReadInteger('Settings', '速度', 2);                  // 默认移动速度
    mySettings.bwBKColor := IniFile.ReadInteger('Settings', '浏览背景色', clWhite);    // 默认关卡浏览界面背景色
    mySettings.isGoThrough := IniFile.ReadBool('Settings', '穿越', true);              // 穿越开关
    mySettings.isIM := IniFile.ReadBool('Settings', '瞬移', false);                    // 瞬移开关
    mySettings.isSameGoal := IniFile.ReadBool('Settings', '正推目标位', false);        // 逆推时，使用正推目标位
    mySettings.isLeftBar := IniFile.ReadBool('Settings', '左侧边栏', true);            // 是否开启左侧边栏
    mySettings.SkinFileName := IniFile.ReadString('Settings', '皮肤', '');             // 当前皮肤文档名
    mySettings.MapFileName := IniFile.ReadString('Settings', '关卡文档', '');          // 当前关卡文档名
    curMap.CurrentLevel := IniFile.ReadInteger('Settings', '关卡序号', 1);             // 上次推的关卡序号
    tmpTrun := IniFile.ReadInteger('Settings', '关卡旋转', 0);                         // 上次推的关卡旋转

    mySettings.LaterList := TStringList.Create;
    for i := 0 to 9 do begin
        s := IniFile.ReadString('Settings', 'Later_' + IntToStr(i), '');
        if s <> '' then mySettings.LaterList.Add(s);                            // 最近推过的关卡集
    end;

    // 默认的设置项
    mySettings.isBK := False;                                                   // 是否逆推模式
    mySettings.isXSB_Saved := True;                                             // 当从剪切板导入的 XSB 是否保存过了
    mySettings.isLurd_Saved := True;                                            // 推关卡的动作是否保存过了
    mySettings.isJijing := False;                                               // 即景目标位
    pmGoal.Checked := mySettings.isSameGoal;                                    // 固定的目标位
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
      mySettings.mySpeed := 2;                                                  // 默认移动速度
    if (tmpTrun < 0) or (tmpTrun > 7) then
      tmpTrun := 0;                                                             // 默认关卡旋转
  finally
    if IniFile <> nil then FreeAndNil(IniFile);
  end;

end;

// 保存配置信息
procedure Tmain.SaveSttings();
var
  IniFile: TIniFile;
  i, n: Integer;

begin
  IniFile := TIniFile.Create(AppPath + AppName + '.ini');

  try
    IniFile.WriteInteger('Settings', 'Top', Top);                               // 退出时，窗口的位置及大小
    IniFile.WriteInteger('Settings', 'Left', Left);
    IniFile.WriteInteger('Settings', 'Width', Width);
    IniFile.WriteInteger('Settings', 'Height', Height);
    IniFile.WriteInteger('Settings', 'bwTop', BrowseForm.Top);                  // 关卡浏览窗口的位置及大小的记忆
    IniFile.WriteInteger('Settings', 'bwLeft', BrowseForm.Left);
    IniFile.WriteInteger('Settings', 'bwWidth', BrowseForm.Width);
    IniFile.WriteInteger('Settings', 'bwHeight', BrowseForm.Height);
    IniFile.WriteString('Settings', 'SubmitCountry', mySettings.SubmitCountry); // 国家或地区
    IniFile.WriteString('Settings', 'SubmitName', mySettings.SubmitName);       // 姓名
    IniFile.WriteString('Settings', 'SubmitEmail', mySettings.SubmitEmail);     // 邮箱
    IniFile.WriteInteger('Settings', '速度', mySettings.mySpeed);               // 移动速度
    IniFile.WriteInteger('Settings', '浏览背景色', mySettings.bwBKColor);       // 关卡浏览界面背景色
    IniFile.WriteBool('Settings', '穿越', mySettings.isGoThrough);              // 穿越开关
    IniFile.WriteBool('Settings', '瞬移', mySettings.isIM);                     // 瞬移开关
    IniFile.WriteBool('Settings', '正推目标位', mySettings.isSameGoal);         // 逆推时，使用正推目标位
    IniFile.WriteBool('Settings', '左侧边栏', mySettings.isLeftBar);            // 是否开启左侧边栏
    IniFile.WriteString('Settings', '皮肤', mySettings.SkinFileName);           // 当前皮肤文档名
    if not isCommandLine then begin
        IniFile.WriteString('Settings', '关卡文档', mySettings.MapFileName);        // 当前关卡文档名 -- 适应关卡文档与程序在同一目录下的情况
        IniFile.WriteInteger('Settings', '关卡序号', curMap.CurrentLevel);          // 当前关卡序号
        if curMapNode = nil then
          IniFile.WriteInteger('Settings', '关卡旋转', 0)                           // 当前关卡旋转
        else
          IniFile.WriteInteger('Settings', '关卡旋转', curMapNode.Trun);
    end;

    n := mySettings.LaterList.Count;
    for i := 0 to n-1 do begin
        IniFile.WriteString('Settings', 'Later_' + IntToStr(i), mySettings.LaterList.Strings[i]);    // 最近推过的关卡集
    end;

  finally
    if IniFile <> nil then FreeAndNil(IniFile);
  end;
end;

// 用 QuicklyLoadMap() 加载到的地图，装填游戏数据
procedure Tmain.ReadQuicklyMap();
var
  i, j, CurCell, Rows, Cols, len: integer;
  ch: Char;
  s: string;
  ss: TStringList;
  
begin
  if (curMapNode = nil) or (curMapNode.Cols <= 0) then begin
     MessageBox(handle, '尚无打开的关卡！', '错误', MB_ICONERROR or MB_OK);
     Exit;
  end;

  Rows := curMapNode.Map.Count;

  if Rows = 0 then Exit;          // 空地图
  
  Cols := Length(curMapNode.Map[0]);

  curMapNode.Boxs := 0;
  curMapNode.Goals := 0;
  for i := 0 to Rows - 1 do
  begin    // 行循环
    len := Length(curMapNode.Map[i]);
    for j := 1 to Cols do
    begin    // 列循环
      if j > len then ch := '-'
      else ch := curMapNode.Map[i][j];
      
      case ch of
        '_':
          CurCell := EmptyCell;
        '#':
          CurCell := WallCell;
        '.': begin
          CurCell := GoalCell;
          Inc(curMapNode.Goals);
        end;
        '$': begin
          CurCell := BoxCell;
          Inc(curMapNode.Boxs);
        end;
        '*': begin
          Inc(curMapNode.Goals);
          Inc(curMapNode.Boxs);
          CurCell := BoxGoalCell;
        end;
        '@':
          CurCell := ManCell;
        '+': begin
          CurCell := ManGoalCell;
          Inc(curMapNode.Goals);
        end;
      else
        CurCell := FloorCell;
      end;
      map_Board_OG[i * curMapNode.Cols + j - 1] := CurCell;
    end;
  end;

  curMap.MapSize := curMapNode.Cols * curMapNode.Rows;
  mmo_Inf.Lines.Clear;
  mmo_Inf.Lines.Add('标题:');
  mmo_Inf.Lines.Add('-----');
  mmo_Inf.Lines.Add(curMapNode.Title);
  mmo_Inf.Lines.Add('');
  mmo_Inf.Lines.Add('');
  mmo_Inf.Lines.Add('作者:');
  mmo_Inf.Lines.Add('-----');
  mmo_Inf.Lines.Add(curMapNode.Author);

  s := StringReplace(curMapNode.Comment, #10, '', [rfReplaceAll]);
  s := StringReplace(s, #13, '', [rfReplaceAll]);
  s := StringReplace(s, #9, '', [rfReplaceAll]);
  if Trim(s) <> '' then begin
     mmo_Inf.Lines.Add('');
     mmo_Inf.Lines.Add('');
     mmo_Inf.Lines.Add('说明:');
     mmo_Inf.Lines.Add('-----');
     ss := TStringList.Create;
     try
        ss.Delimiter := #10;
        ss.DelimitedText := curMapNode.Comment;
        for I:= 0 to ss.Count-1 do
        begin
          mmo_Inf.Lines.Add(ss.Strings[I]);
        end;
     finally
        if ss <> nil then FreeAndNil(ss);
     end;
  end;

  myPathFinder.PathFinder(curMapNode.Cols, curMapNode.Rows);

  InitlizeMap();

  pnl_Trun.Caption := MapTrun[curMapNode.Trun];
  Caption := AppName + AppVer + ' - ' + ExtractFileName(ChangeFileExt(mySettings.MapFileName, EmptyStr)) + ' ~ [' + inttostr(curMap.CurrentLevel) + '/???]';
  Caption := Caption + '，尺寸: ' + IntToStr(curMapNode.Cols) + '×' + IntToStr(curMapNode.Rows) + '，箱子: ' + IntToStr(curMapNode.Boxs) + '，目标: ' + IntToStr(curMapNode.Goals);
  ed_sel_Map.Text := IntToStr(curMap.CurrentLevel);

end;

// 读取关卡文档，并加载指定序号的地图
function Tmain.LoadMap(MapIndex: integer): boolean;
var
  i, j, CurCell, Rows, Cols, len: integer;
  ch: Char;
  s: string;
  ss: TStringList;
  tmpMapNode: PMapNode;               // 关卡节点指针

begin
  result := false;

  if MapIndex < 1 then MapIndex := 1
  else if MapIndex > MapList.Count then MapIndex := MapList.Count;

  tmpMapNode := MapList.Items[MapIndex - 1];

  if (MapList.Count = 0) or (tmpMapNode.Rows <= 0) then
    Exit;

  tmpMapNode := nil;
  curMapNode := MapList.Items[MapIndex - 1];
  curMap.CurrentLevel := MapIndex;

  Rows := curMapNode.Map.Count;
  Cols := Length(curMapNode.Map[0]);

  for i := 0 to Rows - 1 do
  begin    // 行循环
    len := Length(curMapNode.Map[i]);
    for j := 1 to Cols do
    begin    // 列循环
      if j > len then ch := '-'
      else ch := curMapNode.Map[i][j];
      
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
      map_Board_OG[i * curMapNode.Cols + j - 1] := CurCell;
    end;
  end;

  curMap.MapSize := curMapNode.Cols * curMapNode.Rows;

  mmo_Inf.Lines.Clear;
  mmo_Inf.Lines.Add('标题:');
  mmo_Inf.Lines.Add('-----');
  mmo_Inf.Lines.Add(curMapNode.Title);
  mmo_Inf.Lines.Add('');
  mmo_Inf.Lines.Add('');
  mmo_Inf.Lines.Add('作者:');
  mmo_Inf.Lines.Add('-----');
  mmo_Inf.Lines.Add(curMapNode.Author);
  
  s := StringReplace(curMapNode.Comment, #10, '', [rfReplaceAll]);
  s := StringReplace(s, #13, '', [rfReplaceAll]);
  s := StringReplace(s, #9, '', [rfReplaceAll]);
  if Trim(s) <> '' then begin
     mmo_Inf.Lines.Add('');
     mmo_Inf.Lines.Add('');
     mmo_Inf.Lines.Add('说明:');
     mmo_Inf.Lines.Add('-----');
     ss := TStringList.Create;
     try
        ss.Delimiter := #10;
        ss.DelimitedText := curMapNode.Comment;
        for I:= 0 to ss.Count-1 do
        begin
          mmo_Inf.Lines.Add(ss.Strings[I]);
        end;
     finally
        if ss <> nil then FreeAndNil(ss);
     end;
  end;
  myPathFinder.PathFinder(curMapNode.Cols, curMapNode.Rows);

  result := true;
end;

// 计算地图新的图片显示的尺寸
procedure Tmain.NewMapSize();
var
  w, h: integer;
begin
  if (curMapNode = nil) or (curMapNode.Cols <= 0) then begin
     Exit;
  end;
  
  // 计算地图单元格的大小
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
  if curMap.CellSize < 10 then
    curMap.CellSize := 10;

  // 选择单元格掩图
  MaskPic.Width := curMap.CellSize;
  MaskPic.Height := MaskPic.Width;

  // 确定地图的尺寸
  map_Image.Picture := nil;       // 这是必须的，否则，地图不能改变尺寸
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
  map_Image.Left := (pl_Ground.Width - map_Image.Width) div 2;
  map_Image.Top := (pl_Ground.Height - map_Image.Height) div 2;
end;

// 关卡初始化
procedure Tmain.InitlizeMap();
var
  i, x, y, len: integer;
  s1, s2: string;
begin
  // 前期准备
  UnDoPos := 0;
  ReDoPos := 0;
  UnDoPos_BK := 0;
  ReDoPos_BK := 0;
  MoveTimes := 0;
  PushTimes := 0;
  MoveTimes_BK := 0;
  PushTimes_BK := 0;
  isMoving := false;           // 正在推移中...
  IsStop  := false;            // 是否停止移动
  isKeyPush := False;
  BoxNumber := 0;
  GoalNumber := 0;
  ManPos_BK := -1;              // 人的位置 -- 逆推
  ManPos_BK_0 := -1;            // 人的位置 -- 逆推 -- 备份
  LastSteps := -1;              // 正推最后一次点推前的步数
  IsManAccessibleTips := false;           // 是否显示人的正推可达提示
  IsManAccessibleTips_BK := false;        // 是否显示人的逆推可达提示
  IsBoxAccessibleTips := false;           // 是否显示箱子的正推可达提示
  IsBoxAccessibleTips_BK := false;        // 是否显示箱子的逆推可达提示
  mySettings.isLurd_Saved := True;        // 推关卡的动作是否保存过了
  isNoDelay := False;                     // 是否无延时执行动作
  isSelectMod := False;
  isDelSelect := False;
  curMap.isFinish := True;                // 是否正在执行动作演示
  curMap.Recording := false;              // 是否在动作录制状态
  curMapNode.Boxs := 0;
  curMapNode.Goals := 0;

  for i := 0 to curMap.MapSize - 1 do begin
    map_Board[i] := map_Board_OG[i];
    BoxNum_Board[i]    := -1;   // 箱子编号
    PosNum_Board[i]    := -1;   // 位置编号
    BoxNum_Board_BK[i] := -1;   // 箱子编号 - 逆推
    PosNum_Board_BK[i] := -1;   // 位置编号 - 逆推
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

  curMap.ManPosition := ManPos;              // 地图中人的原始位置，将在逆推状态时，以此提示
  mySettings.isJijing := False;              // 即景目标位
  pmJijing.Checked := False; 
  mySettings.isBK := False;                  // 默认正推模式
  mySettings.isShowNoVisited := False;
  OldBoxPos := -1;                           // 被点击的箱子的位置 -- 正推
  OldBoxPos_BK := -1;                        // 被点击的箱子的位置 -- 逆推

  NewMapSize();    // 重新确定 Image 大小
  DrawMap();       // 画地图
  SetButton();     // 设置按钮状态

  LoadState();     // 加载状态
  LoadSolution();  // 加载答案
  curMapNode.Solved := (SoltionList.Count > 0);

  // 若关卡已经解开，则自动加载答案，否则，有状态保存，则直接打开最新的状态
  if curMapNode.Solved then begin
    if GetSolutionFromDB(0, s1) then begin

       len := Length(s1);

       if len > 0 then begin
           // 答案送入正推的 RedoList
           ReDoPos := 0;
           for i := len downto 1 do begin
               if ReDoPos = MaxLenPath then Exit;
               inc(ReDoPos);
               RedoList[ReDoPos] := s1[i];
           end;
           curMap.isFinish := True;
       end;
       StatusBar1.Panels[7].Text := '答案已载入！';
    end;
  end else if StateList.count > 0 then begin
    if GetStateFromDB(0, x, y, s1, s2) then begin

       len := Length(s1);

       // 状态送入 RedoList
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

       // 状态送入 RedoList_BK
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
       StatusBar1.Panels[7].Text := '状态已载入！';
    end;
  end;

  if mySettings.isXSB_Saved then begin
    if MapList.Count = 0 then
       Caption := AppName + AppVer + ' - ' + ExtractFileName(ChangeFileExt(mySettings.MapFileName, EmptyStr)) + ' ~ [' + inttostr(curMap.CurrentLevel) + '/' + '???]'
    else
       Caption := AppName + AppVer + ' - ' + ExtractFileName(ChangeFileExt(mySettings.MapFileName, EmptyStr)) + ' ~ [' + inttostr(curMap.CurrentLevel) + '/' + inttostr(MapList.Count) + ']'
  end else begin
    Caption := AppName + AppVer + ' - 剪切板 ~ [' + inttostr(curMap.CurrentLevel) + '/' + inttostr(MapList.Count) + ']';
  end;

  Caption := Caption + '，尺寸: ' + IntToStr(curMapNode.Cols) + '×' + IntToStr(curMapNode.Rows) + '，箱子: ' + IntToStr(curMapNode.Boxs) + '，目标: ' + IntToStr(curMapNode.Goals);
  ed_sel_Map.Text := IntToStr(curMap.CurrentLevel);
  
  ShowStatusBar();                                         // 底行状态栏
  myPathFinder.setThroughable(mySettings.isGoThrough);     // 穿越开关

  if curMapNode.Cols > 0 then
    StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos mod curMapNode.Cols, ManPos div curMapNode.Cols) + ' - [ ' + IntToStr(ManPos mod curMapNode.Cols + 1) + ', ' + IntToStr(ManPos div curMapNode.Cols + 1) + ' ]';       // 标尺
end;

// 计算无缝墙壁图元
function Tmain.GetWall(r, c: Integer): Integer;
var
  pos: Integer;
begin
  result := 0;

  pos := r * curMapNode.Cols + c;

  if (c > 0) and (map_Board[r * curMapNode.Cols + c - 1] = WallCell) then
    result := result or MapDir[curMapNode.Trun, 0];  // 左有墙壁
  if (r > 0) and (map_Board[(r - 1) * curMapNode.Cols + c] = WallCell) then
    result := result or MapDir[curMapNode.Trun, 1];  // 上有墙壁
  if (c < curMapNode.Cols - 1) and (map_Board[r * curMapNode.Cols + c + 1] = WallCell) then
    result := result or MapDir[curMapNode.Trun, 2];  // 右有墙壁
  if (r < curMapNode.Rows - 1) and (map_Board[(r + 1) * curMapNode.Cols + c] = WallCell) then
    result := result or MapDir[curMapNode.Trun, 3];  // 下有墙壁

  if ((result = MapDir[curMapNode.Trun, 4]) or (result = MapDir[curMapNode.Trun, 5]) or (result = MapDir[curMapNode.Trun, 6]) or (result = 15)) and (c > 0) and (r > 0) and (map_Board[pos - curMapNode.Cols - 1] = WallCell) then
    result := result or 16;  // 需要画墙顶
end;

// 统计选区内的箱子数等
function Tmain.GetCountBox(): string;
var
  i, boxNum, GoalNum, BoxGoalNum: Integer;

begin
  boxNum := 0; GoalNum := 0; BoxGoalNum := 0;
  for i := 0 to curMap.MapSize-1 do begin
      if mySettings.isBK then begin         // 逆推
        if map_Selected_BK[i] then begin
           if map_Board_BK[i] = BoxCell then inc(boxNum)
           else if map_Board_BK[i] in [ GoalCell, ManGoalCell ] then inc(GoalNum)
           else if map_Board_BK[i] = BoxGoalCell then inc(BoxGoalNum);
        end;
      end else begin
        if map_Selected[i] then begin
           if map_Board[i] = BoxCell then inc(boxNum)
           else if map_Board[i] in [ GoalCell, ManGoalCell ] then inc(GoalNum)
           else if map_Board[i] = BoxGoalCell then inc(BoxGoalNum);
        end;
      end;
  end;

  result := '选区内：箱子数 = ' + IntToStr(boxNum + BoxGoalNum) + '；  目标数 = '  + IntToStr(GoalNum + BoxGoalNum) + '；  其中完成数 = '  + IntToStr(BoxGoalNum);

end;

// 比较图元格第一像素颜色与地板格颜色是否相同，以确定是否画格线
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

// 为选区内的单元格加上紫色遮罩
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

// 重画地图
procedure Tmain.DrawMap();
var
  i, j, k, dx, dy, myCell, x1, y1, x2, y2, x3, y3, x4, y4, pos, t1, t2, i2, j2, man_Pos_: integer;
  R, R2: TRect;
    
begin
  if (curMapNode = nil) or (curMapNode.Cols <= 0) then begin
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
      // 0-7, 1-6, 2-5, 3-4, 互为转置
      case (curMapNode.Trun) of  // 利用 i2, j2 模拟图元素的旋转，这样不管怎么“旋转”，实际上地图始终不变 -- 将地图坐标转换为视觉坐标
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

      pos := i * curMapNode.Cols + j;    // 地图中，“格子”的真实位置

      x1 := j2 * curMap.CellSize;        // x1, y1 是地图元素的绘制坐标 -- 旋转后的
      y1 := i2 * curMap.CellSize;

      R := Rect(x1, y1, x1 + curMap.CellSize, y1 + curMap.CellSize);        // 地图格子的绘制矩形

      if mySettings.isBK then
      begin            // 逆推
        myCell := map_Board_BK[pos];
        if mySettings.isJijing then
        begin  // 即景目标位
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
        begin  // 固定的目标位
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
        myCell := map_Board[pos];             // 正推
        if mySettings.isJijing then
        begin     // 即景目标位
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
          begin                 // 简单墙壁
            map_Image.Canvas.StretchDraw(R, WallPic);
          end;
        FloorCell:
          begin
            if mySettings.isOddEven and ((i2 + j2) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, FloorPic2)
            else map_Image.Canvas.StretchDraw(R, FloorPic);
            if not mySettings.isOddEven then DrawLine(map_Image.Canvas, x1, y1, isFloorLine);  // 画网格线
          end;
        GoalCell:
          begin
            if mySettings.isOddEven and ((i2 + j2) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, GoalPic2)
            else map_Image.Canvas.StretchDraw(R, GoalPic);
            if not mySettings.isOddEven then DrawLine(map_Image.Canvas, x1, y1, isGoalLine);   // 画网格线
          end;
        BoxCell:
          begin
            if mySettings.isOddEven and ((i2 + j2) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, BoxPic2)
            else map_Image.Canvas.StretchDraw(R, BoxPic);
            if not mySettings.isOddEven then DrawLine(map_Image.Canvas, x1, y1, isBoxLine);    // 画网格线
          end;
        BoxGoalCell:
          begin
            if mySettings.isOddEven and ((i2 + j2) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, BoxGoalPic2)
            else map_Image.Canvas.StretchDraw(R, BoxGoalPic);
            if not mySettings.isOddEven then DrawLine(map_Image.Canvas, x1, y1, isBoxGoalLine); // 画网格线
          end;
        ManCell:
          begin
            if mySettings.isOddEven and ((i2 + j2) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, ManPic2)
            else map_Image.Canvas.StretchDraw(R, ManPic);
            if not mySettings.isOddEven then DrawLine(map_Image.Canvas, x1, y1, isManLine);    // 画网格线
          end;
        ManGoalCell:
          begin
            if mySettings.isOddEven and ((i2 + j2) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, ManGoalPic2)
            else map_Image.Canvas.StretchDraw(R, ManGoalPic);
            if not mySettings.isOddEven then DrawLine(map_Image.Canvas, x1, y1, isManGoalLine); // 画网格线
          end;
      else
        if mySettings.isBK then
           map_Image.Canvas.Brush.Color := clBlack
        else
           map_Image.Canvas.Brush.Color := clInactiveCaptionText;
          
        map_Image.Canvas.FillRect(R);
      end;

      // 是否“逆推模式”
      if mySettings.isBK then
      begin
        map_Image.Canvas.Brush.Style := bsClear;
        map_Image.Canvas.Font.Name := '微软雅黑';
        map_Image.Canvas.Font.Size := 16;
        map_Image.Canvas.Font.Color := clWhite;
        map_Image.Canvas.Font.Style := [];
        if mySettings.isJijing then
           map_Image.Canvas.TextOut(0, 0, '逆推模式 - 即景')
        else
           map_Image.Canvas.TextOut(0, 0, '逆推模式');

        // 箱子编号
        if (myCell in [ BoxCell, BoxGoalCell ]) and (BoxNum_Board_BK[pos] >= 0) then begin
            map_Image.Canvas.Font.Color := clBlack;
            map_Image.Canvas.Brush.Style := bsClear;
            map_Image.Canvas.Font.Size := Round(curMap.CellSize / 2.5);
            map_Image.Canvas.Font.Style := [fsBold];
            map_Image.Canvas.TextOut(R.Left + curMap.CellSize div 3, R.Top + curMap.CellSize div 5, IntToStr(BoxNum_Board_BK[pos]));
        end else if (myCell in [ FloorCell, GoalCell, ManCell, ManGoalCell ]) and (PosNum_Board_BK[pos] >= 0) then begin    // 通道位置
            map_Image.Canvas.Font.Color := clWhite;
            map_Image.Canvas.Brush.Style := bsClear;
            map_Image.Canvas.Font.Size := Round(curMap.CellSize / 2.5);
            map_Image.Canvas.Font.Style := [fsBold];
            map_Image.Canvas.TextOut(R.Left + curMap.CellSize div 3, R.Top + curMap.CellSize div 5, chr(PosNum_Board_BK[pos]+64));
        end;

        // 逆推中，显示人在正推中的位置，正逆相合后，人需要回到此位置，所以，提示出来以便参考
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
        begin   // 显示人的可达提示
          t1 := curMap.CellSize div 6;
          if t1 < 4 then t1 := 4;
          t2 := t1 - 1;
          if myPathFinder.isManReachableByThrough_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.FillRect(Rect(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1));
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.FillRect(Rect(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2));
          end
          else if myPathFinder.isManReachable_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2);
          end
          else if myPathFinder.isBoxOfThrough_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2);
          end;
        end;
        if IsBoxAccessibleTips_BK then
        begin   // 显示箱子的可达提示
          t1 := curMap.CellSize div 6;
          if t1 < 4 then t1 := 4;
          t2 := t1 - 1;
          if myPathFinder.isBoxReachable_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2);
          end;
        end;
      end
      else                                                                      // 正推
      begin
        // 标识出未访问的格子
        if mySettings.isShowNoVisited and (not map_Board_Visited[pos]) and (map_Board[pos] in [ FloorCell, GoalCell, BoxCell, BoxGoalCell, ManCell, ManGoalCell ]) then begin
           map_Image.Canvas.Pen.Color := clWhite;
           map_Image.Canvas.Pen.Width := 2;
           map_Image.Canvas.MoveTo(R.Left+5, R.Top+5);
           map_Image.Canvas.LineTo(R.Right-5, R.Bottom-5);
           map_Image.Canvas.MoveTo(R.Right-5, R.Top+5);
           map_Image.Canvas.LineTo(R.Left+5, R.Bottom-5);
        end;

        if mySettings.isJijing then
        begin    // 即景
          map_Image.Canvas.Brush.Style := bsClear;
          map_Image.Canvas.Font.Name := '微软雅黑';
          map_Image.Canvas.Font.Size := 16;
          map_Image.Canvas.Font.Color := clWhite;
          map_Image.Canvas.Font.Style := [];
          map_Image.Canvas.TextOut(0, 0, '即景');
        end;

        // 箱子编号
        if (myCell in [ BoxCell, BoxGoalCell ]) and (BoxNum_Board[pos] >= 0) then begin
            map_Image.Canvas.Brush.Style := bsClear;
            map_Image.Canvas.Font.Color := clBlack;
            map_Image.Canvas.Font.Size := Round(curMap.CellSize / 2.5);
            map_Image.Canvas.Font.Style := [fsBold];
            map_Image.Canvas.TextOut(R.Left + curMap.CellSize div 3, R.Top + curMap.CellSize div 5, IntToStr(BoxNum_Board[pos]));
        end else if (myCell in [ FloorCell, GoalCell, ManCell, ManGoalCell ]) and (PosNum_Board[pos] >= 0) then begin  // 通道位置
            map_Image.Canvas.Brush.Style := bsClear;
            map_Image.Canvas.Font.Color := clWhite;
            map_Image.Canvas.Font.Size := Round(curMap.CellSize / 2.5);
            map_Image.Canvas.Font.Style := [fsBold];
            map_Image.Canvas.TextOut(R.Left + curMap.CellSize div 3, R.Top + curMap.CellSize div 5, chr(PosNum_Board[pos]+64));
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
        begin   // 显示人的可达提示
          t1 := curMap.CellSize div 6;
          if t1 < 4 then t1 := 4;
          t2 := t1 - 1;
          if myPathFinder.isManReachableByThrough(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.FillRect(Rect(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1));
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.FillRect(Rect(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2));
          end
          else if myPathFinder.isManReachable(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2);
          end
          else if myPathFinder.isBoxOfThrough(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2);
          end;
        end;
        if IsBoxAccessibleTips then
        begin   // 显示箱子的可达提示
          t1 := curMap.CellSize div 6;
          if t1 < 4 then t1 := 4;
          t2 := t1 - 1;
          if myPathFinder.isBoxReachable(pos) then
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

  // 是否不合格的关卡 XSB
  if curMapNode.isEligible then begin
     if mySettings.isBK then begin
        if curMap.Recording_BK then begin
           map_Image.Canvas.Brush.Style := bsClear;
           map_Image.Canvas.Font.Name := '微软雅黑';
           map_Image.Canvas.Font.Size := 16;
           map_Image.Canvas.Font.Color := clWhite;
           map_Image.Canvas.Font.Style := [];
           map_Image.Canvas.TextOut(map_Image.Width-130, 0, '动作录制中...');
           map_Image.Canvas.TextOut(map_Image.Width-130, 25, '开始点：' + IntToStr(curMap.StartPos_BK));
        end;
     end else begin
        if curMap.Recording then begin
           map_Image.Canvas.Brush.Style := bsClear;
           map_Image.Canvas.Font.Name := '微软雅黑';
           map_Image.Canvas.Font.Size := 16;
           map_Image.Canvas.Font.Color := clWhite;
           map_Image.Canvas.Font.Style := [];
           map_Image.Canvas.TextOut(map_Image.Width-130, 0, '动作录制中...');
           map_Image.Canvas.TextOut(map_Image.Width-130, 25, '开始点：' + IntToStr(curMap.StartPos));
        end;
     end;

  end else begin      // 不合格
    map_Image.Canvas.Brush.Style := bsClear;
    map_Image.Canvas.Font.Name := '微软雅黑';
    map_Image.Canvas.Font.Size := 16;
    map_Image.Canvas.Font.Color := clWhite;
    map_Image.Canvas.Font.Style := [];
    map_Image.Canvas.TextOut(map_Image.Width-130, 0, '不合格的关卡');
  end;

  if isSelectMod then begin
     // 突出被选中的单元格
     R2 := Rect(0, 0, curMap.CellSize, curMap.CellSize);
     map_Image.Canvas.Pen.Color := $00FF66;   // 边框线的颜色
     map_Image.Canvas.Pen.Width := 3;

//     map_Image.Canvas.CopyMode := PATPAINT;
     for i := 0 to curMapNode.Rows - 1 do
     begin
       for j := 0 to curMapNode.Cols - 1 do
       begin
         pos := i * curMapNode.Cols + j;    // 地图中，“格子”的真实位置

       if (mySettings.isBK and map_Selected_BK[pos]) or (not mySettings.isBK and map_Selected[pos]) then begin
            // 0-7, 1-6, 2-5, 3-4, 互为转置
            case (curMapNode.Trun) of  // 利用 i2, j2 模拟图元素的旋转，这样不管怎么“旋转”，实际上地图始终不变 -- 将地图坐标转换为视觉坐标
            1:
              begin
                j2 := curMapNode.Rows - 1 - i;
                i2 := j;
                x1 := j2 * curMap.CellSize + curMap.CellSize;        // x1, y1, x2, y2 为边框线的四个坐标
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
                x1 := j2 * curMap.CellSize + curMap.CellSize;        // x1, y1, x2, y2 为边框线的四个坐标
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
                x1 := j2 * curMap.CellSize;                          // x1, y1, x2, y2 为边框线的四个坐标
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
                x1 := j2 * curMap.CellSize + curMap.CellSize;        // x1, y1, x2, y2 为边框线的四个坐标
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
                x1 := j2 * curMap.CellSize + curMap.CellSize;        // x1, y1, x2, y2 为边框线的四个坐标
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
                x1 := j2 * curMap.CellSize;                         // x1, y1, x2, y2 为边框线的四个坐标
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
                x1 := j2 * curMap.CellSize;                        // x1, y1, x2, y2 为边框线的四个坐标
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
                x1 := j2 * curMap.CellSize;                       // x1, y1, x2, y2 为边框线的四个坐标
                y1 := i2 * curMap.CellSize;
                x2 := x1 + curMap.CellSize;
                y2 := y1;
                x3 := x1 + curMap.CellSize;
                y3 := y1 + curMap.CellSize;
                x4 := x1;
                y4 := y1 + curMap.CellSize;
              end;
            end;
            
            R := Rect(j2 * curMap.CellSize, i2 * curMap.CellSize, (j2+1) * curMap.CellSize, (i2+1) * curMap.CellSize);        // 地图格子的绘制矩形
            MaskPic.Canvas.CopyRect(R2, map_Image.Canvas, R);
            ColorChange(MaskPic);
            map_Image.Canvas.CopyRect(R, MaskPic.Canvas, R2);

            // 若上格不在选区内，画上边线
            if (i = 0) or (mySettings.isBK and not map_Selected_BK[pos-curMapNode.Cols]) or (not mySettings.isBK and not map_Selected[pos-curMapNode.Cols]) then begin
                map_Image.Canvas.MoveTo(x1, y1);
                map_Image.Canvas.LineTo(x2, y2);
            end;
            // 若下格不在选区内，画下边线
            if (i+1 = curMapNode.Rows) or (mySettings.isBK and not map_Selected_BK[pos+curMapNode.Cols]) or (not mySettings.isBK and not map_Selected[pos+curMapNode.Cols]) then begin
                map_Image.Canvas.MoveTo(x4, y4);
                map_Image.Canvas.LineTo(x3, y3);
            end;
            // 若左格不在选区内，画左边线
            if (j = 0) or (mySettings.isBK and not map_Selected_BK[pos-1]) or (not mySettings.isBK and not map_Selected[pos-1]) then begin
                map_Image.Canvas.MoveTo(x1, y1);
                map_Image.Canvas.LineTo(x4, y4);
            end;
            // 若右格不在选区内，画右边线
            if (j+1 = curMapNode.Cols) or (mySettings.isBK and not map_Selected_BK[pos+1]) or (not mySettings.isBK and not map_Selected[pos+1]) then begin
                map_Image.Canvas.MoveTo(x2, y2);
                map_Image.Canvas.LineTo(x3, y3);
            end;
         end;
       end;
     end;

     map_Image.Canvas.CopyMode := SRCCOPY;

     // 显示当前选择焦点框
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

  bt_LeftBar.Hint      := '显示或隐藏左侧边栏: 【H】';

  bt_GoThrough.Caption := '穿越';
  bt_IM.Caption        := '瞬移';
  bt_BK.Caption        := '逆推';
  bt_OddEven.Caption   := '奇偶';
  bt_Skin.Caption      := '换肤';
  bt_Act.Caption       := '动作编辑';
  bt_Save.Caption      := '保存现场';
  pnl_Trun.Caption     := '0转';

  bt_Open.Hint         := '打开文档: 【Ctrl + O】';
  bt_Lately.Hint       := '最近打开的文档';
  bt_Pre.Hint          := '上一关: 【PgUp】';
  bt_Next.Hint         := '下一关: 【PgDn】';
  bt_UnDo.Hint         := '撤销: 【Z】';
  bt_ReDo.Hint         := '重做: 【X】';
  bt_View.Hint         := '选择关卡: 【F3】';
  bt_GoThrough.Hint    := '穿越开关: 【G】';
  bt_IM.Hint           := '瞬移开关: 【I】';
  bt_BK.Hint           := '逆推模式: 【B】';
  bt_OddEven.Hint      := '奇偶格位: 【E】';
  bt_Skin.Hint         := '更换皮肤: 【F2】';
  bt_Act.Hint          := '动作编辑: 【F4】';
  bt_Save.Hint         := '保存现场（关卡未存档时，同时保存关卡）: 【Ctrl + S】';
  pnl_Trun.Hint        := '旋转关卡: 【*、/、左右鼠标键】';
  pnl_Speed.Hint       := '改变游戏速度: 【+、-、左右鼠标键】';
  sb_Help.Hint         := '帮助：【F1】';

  StatusBar1.Panels[0].Text := '移动';
  StatusBar1.Panels[2].Text := '推动';
  StatusBar1.Panels[4].Text := '标尺';

  PageControl.Pages[0].Caption := '答案';
  PageControl.Pages[1].Caption := '状态';
  PageControl.Pages[2].Caption := '资料';

  pmSolution.Items[0].Caption := '查看提交列表';
  pmSolution.Items[1].Caption := '提交比赛答案';
  pmSolution.Items[2].Caption := '-';
  pmSolution.Items[3].Caption := 'Lurd 到剪切板';
  pmSolution.Items[4].Caption := 'XSB + Lurd 到剪切板';
  pmSolution.Items[5].Caption := 'XSB + Lurd 到文档';
  pmSolution.Items[6].Caption := 'XSB + Lurd_All 到剪切板';
  pmSolution.Items[7].Caption := 'XSB + Lurd_All 到文档';
  pmSolution.Items[8].Caption := 'XSB_All + Lurd_All 到文档';
  pmSolution.Items[9].Caption := '-';
  pmSolution.Items[10].Caption := '删除';
  pmSolution.Items[11].Caption := '删除全部';
  pmSolution.Items[12].Caption := '-';
  pmSolution.Items[13].Caption := '导入答案';


  pmState.Items[0].Caption := '正推 Lurd 到剪切板';
  pmState.Items[1].Caption := '逆推 Lurd 到剪切板';
  pmState.Items[2].Caption := 'XSB + Lurd 到剪切板';
  pmState.Items[3].Caption := 'XSB + Lurd 到文档';
  pmState.Items[4].Caption := '-';
  pmState.Items[5].Caption := '删除';
  pmState.Items[6].Caption := '删除全部';

  pmBoardBK.Items[0].Caption := '固定的目标位   【Ctrl + G】';
  pmBoardBK.Items[1].Caption := '即景目标位      【Ctrl + J】';
  pmBoardBK.Items[2].Caption := '-';
  pmBoardBK.Items[3].Caption := '导入关卡（XSB） ← 剪切板                            【Ctrl + V】';
  pmBoardBK.Items[4].Caption := '导出关卡和已做动作（XSB + Lurd） → 剪切板  【Ctrl + C】';
  pmBoardBK.Items[5].Caption := '导出现场（XSB） → 剪切板                            【Ctrl + Alt + C】';
  pmBoardBK.Items[6].Caption := '存入周转库 →（BoxMan.xsb）                       【Ctrl + K】';
  pmBoardBK.Items[7].Caption := '-';
  pmBoardBK.Items[8].Caption := '导入动作（Lurd） ← 剪切板 - 正逆推        【Ctrl + L】';
  pmBoardBK.Items[9].Caption := '导出已做动作（Lurd） → 剪切板 - 正逆推  【Ctrl + M】';
  pmBoardBK.Items[10].Caption := '导出后续动作（Lurd） → 剪切板              【Ctrl + Alt + M】';
  pmBoardBK.Items[11].Caption := '-';
  pmBoardBK.Items[12].Caption  := '重新开始   【Esc】';
  pmBoardBK.Items[13].Caption  := '-';
  pmBoardBK.Items[14].Caption  := '录制动作   【F9】';
  pmBoardBK.Items[15].Caption := '-';
  pmBoardBK.Items[16].Caption := '退至首   【退格键】';
  pmBoardBK.Items[17].Caption := '进至尾   【空格键】';

  pm_Up_Bt.Items[0].Caption := '上一关              【PgUp】';
  pm_Up_Bt.Items[1].Caption := '第一关              【Ctrl + PgUp】';
  pm_Up_Bt.Items[2].Caption := '上一未解关卡        【Alt + PgUp】';

  pm_Down_Bt.Items[0].Caption := '下一关            【PgDn】';
  pm_Down_Bt.Items[1].Caption := '最后一关          【Ctrl + PgDn】';
  pm_Down_Bt.Items[2].Caption := '下一未解关卡      【Alt + PgDn】';

  pm_UnDo_Bt.Items[0].Caption := '撤销单步      【A】';
  pm_UnDo_Bt.Items[1].Caption := '撤销          【Z】';
  pm_UnDo_Bt.Items[2].Caption := '退至首          【Home】';

  pm_ReDo_Bt.Items[0].Caption := '重做单步      【S】';
  pm_ReDo_Bt.Items[1].Caption := '重做          【X】';
  pm_ReDo_Bt.Items[2].Caption := '进至尾          【End】';


  // 一些最原始的默认设置
  mySettings.myTop := 100;      // 上次退出时，窗口的位置及大小
  mySettings.myLeft := 100;
  mySettings.myWidth := 800;
  mySettings.myHeight := 600;
  mySettings.bwTop := 100;      // 关卡浏览窗口的位置及大小的记忆
  mySettings.bwLeft := 100;
  mySettings.bwWidth := 800;
  mySettings.bwHeight := 600;
  mySettings.mySpeed := 2;        // 默认移动速度
  mySettings.isGoThrough := true;    // 穿越开关

  isSelectMod := false;           // 是否触动了选择模式 -- Ctrl + 左键单击单元格
  isSelecting := false;           // 是否正处于选择模式 -- Ctrl + 左键拖动

  MaskPic := TBitmap.Create;      // 选择单元格掩图

  DoubleClickPos.X := -1;         // 双击地图位置初始化值
  DoubleClickPos.Y := -1;

  AppPath := ExtractFilePath(Application.ExeName);      //GetCurrentDir + '\';   //
  BoxManDBpath := AppPath + 'BoxMan.db';

  sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));

  // 检查答案库和状态库是否存在，不存在则创建之
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

  // 程序窗口最小尺寸限制
  Constraints.MinHeight := minWindowsHeight;
  Constraints.MinWidth := minWindowsWidth;

  // undo、redo 指针初始化
  UnDoPos := 0;
  ReDoPos := 0;
  UnDoPos_BK := 0;
  ReDoPos_BK := 0;

  LoadSttings();    // 加载设置项
  isOnlyXSB := True;          // LoadMap 中的变量，控制在加载文档关卡时，是否同时导入答案

  // 接收启动参数
  isCommandLine := false;
  if paramcount >= 1 then begin
     isCommandLine := True;
     try
       mySettings.MapFileName := paramstr(1);             // 关卡文档名
       if paramcount > 1 then
          curMap.CurrentLevel := StrToInt(paramstr(2))    // 关卡序号
       else
          curMap.CurrentLevel := 1;
     except
       curMap.CurrentLevel := 1;
     end;
  end;

  Caption := AppName + AppVer;

  curSkinFileName := mySettings.SkinFileName;      // 当前皮肤
  LoadSkinForm := TLoadSkinForm.Create(Application);
  BrowseForm := TBrowseForm.Create(Application);

  // 恢复上次退出时，窗口的位置及大小
  Top := mySettings.myTop;
  Left := mySettings.myLeft;
  Width := mySettings.myWidth;
  Height := mySettings.myHeight;

  myPathFinder := TPathFinder.Create;             // 探路者

  MapList := TList.Create;                        // 地图列表
  SoltionList := TList.Create;                    // 答案列表
  StateList := TList.Create;                      // 状态列表

  curMapNode := nil;

  // 创建后台线程，加载地图
  LoadMapThread := TLoadMapThread.Create(true);
  LoadMapThread.isRunning := False;

  // 先用比较轻便的方式，打开上次的关卡
  if FileExists(mySettings.MapFileName) then begin
     curMapNode := QuicklyLoadMap(mySettings.MapFileName, curMap.CurrentLevel);

     if curMapNode.Map.Count > 2 then begin

        mySettings.isXSB_Saved := True;
        ReadQuicklyMap();
        curMapNode.Trun := tmpTrun;
        pnl_Trun.Caption := MapTrun[curMapNode.Trun];

        ResetSolvedLevel();

        // 运行后台线程，加载地图
        LoadMapThread.Resume;

     end else StatusBar1.Panels[7].Text := '加载上次的 ' + IntToStr(curMap.CurrentLevel) + ' 号关卡时，遇到错误 - ' + mySettings.MapFileName;
  end;                          

  SetButton();             // 设置按钮状态
  pnl_Speed.Caption := SpeedInf[mySettings.mySpeed];

  KeyPreview := true;

end;

// 设置按钮状态
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
      StatusBar1.Panels[7].Text := '请先指定“人的开始位置”！！！';
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

// 关闭程序
procedure Tmain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // 加载地图文档的后台线程
  if LoadMapThread.isRunning then begin
     LoadMapThread.Suspend;
  end;

  ReDoPos := 0;
  ReDoPos_BK := 0;

  SaveSttings();               // 保存设置项

  application.terminate;

{$IFDEF LASTACT}
   LogFileClose_();
{$ENDIF}

{$IFDEF DEBUG}
   LogFileClose();
{$ENDIF}

end;

// 是否过关 -- 正推
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

// 是否过关 -- 逆推
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
    myPathFinder.manReachable(true, map_Board_BK, ManPos_BK);
    result := (myPathFinder.isManReachable_BK(curMap.ManPosition) or myPathFinder.isManReachableByThrough_BK(curMap.ManPosition));
  end;
end;

// 是否正逆相合
function Tmain.IsMeets(ch: Char): Boolean;
var
  i, len, n: integer;
  flg: Boolean;

begin
  Result := False;
  flg := True;

  if (MoveTimes < 1) or (MoveTimes_BK < 1) or (ch in [ 'l', 'r', 'u', 'd' ]) then
    Exit;        // 没有正推或逆推动作时，不做此项检查

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
    myPathFinder.manReachable(true, map_Board_BK, ManPos_BK);
    flg := (myPathFinder.isManReachable_BK(ManPos) or myPathFinder.isManReachableByThrough_BK(ManPos));
//    flg := myPathFinder.manTo2(false, -1, -1, ManPos div curMapNode.Cols, ManPos mod curMapNode.Cols, ManPos_BK div curMapNode.Cols, ManPos_BK mod curMapNode.Cols);
  end;

  if flg then begin
    Result := True;
     
//     if isBK then bt_BK.Click;    // 切换到正推界面

    // 跳过逆推答案中，前面无用的空移动作
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

    len := myPathFinder.manTo(false, map_Board, ManPos, ManPos_BK);
    for i := 1 to len do
    begin
      if ReDoPos = MaxLenPath then
        Exit;
      Inc(ReDoPos);
      RedoList[ReDoPos] := ManPath[i];
    end;
  end;
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

// 取得录制的动作
function GetRecording(isBK: Boolean; pos: Integer): string;
begin
   Result := '';

   if isBK then begin
      if UnDoPos_BK >= pos then begin
         if UnDoPos_BK < MaxLenPath then UndoList_BK[UnDoPos_BK+1] := #0;
         Result := Copy(StrPas(@UndoList_BK), Pos, UnDoPos_BK-pos+1);
      end else main.StatusBar1.Panels[7].Text := '仅支持录制“开始点”后面的动作！';
   end else begin
      if UnDoPos >= pos then begin
         if UnDoPos < MaxLenPath then UndoList[UnDoPos+1] := #0;
         Result := Copy(StrPas(@UndoList), Pos, UnDoPos-pos+1);
      end else main.StatusBar1.Panels[7].Text := '仅支持录制“开始点”后面的动作！';
   end;
end;

// 自动执行“寄存器”动作
procedure Tmain.DoAct(n:  Integer);
var
  err: Boolean;
  M_X, M_Y: Integer;        // 解析出的逆推中人的初始位置
  i, j, k, len: Integer;
  str, Act: string;
  p: TStrings;
  ch: Char;

begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;
  err := True;
  ActionForm.MemoAct.Lines.Clear;
  case n of
  1:
     try
        ActionForm.MemoAct.Lines.LoadFromFile(AppPath + '\temp\reg1.txt');
        StatusBar1.Panels[7].Text := '加载【寄存器 1】动作成功！';
        err := false;
     except
        StatusBar1.Panels[7].Text := '加载【寄存器 1】失败！';
     end;
  2:
     try
        ActionForm.MemoAct.Lines.LoadFromFile(AppPath + '\temp\reg2.txt');
        StatusBar1.Panels[7].Text := '加载【寄存器 2】动作成功！';
        err := false;
     except
        StatusBar1.Panels[7].Text := '加载【寄存器 2】失败！';
     end;
  3:
     try
        ActionForm.MemoAct.Lines.LoadFromFile(AppPath + '\temp\reg3.txt');
        StatusBar1.Panels[7].Text := '加载【寄存器 3】动作成功！';
        err := false;
     except
        StatusBar1.Panels[7].Text := '加载【寄存器 3】失败！';
     end;
  4:
     try
        ActionForm.MemoAct.Lines.LoadFromFile(AppPath + '\temp\reg4.txt');
        StatusBar1.Panels[7].Text := '加载【寄存器 4】动作成功！';
        err := false;
     except
        StatusBar1.Panels[7].Text := '加载【寄存器 4】失败！';
     end;
  5:    // 录制动作
     begin
        if mySettings.isBK then begin      // 逆推
           if curMap.Recording_BK then begin   // 将录制的动作保存的“寄存器”
              curMap.Recording_BK := False;
              DrawMap();
              Act := GetRecording(mySettings.isBK, curMap.StartPos_BK);
              if Length(Act) > 0 then begin
                 ActionForm.MemoAct.Lines.Clear;
                 ActionForm.MemoAct.Lines.Text := Act;
                 bt_Act.Click;
              end;
           end else begin    // 启动录制模式
              if ManPos_BK < 0 then StatusBar1.Panels[7].Text := '请先指定人的开始位置'
              else begin
                 curMap.Recording_BK := True;
                 curMap.StartPos_BK := UndoPos_BK+1;
                 DrawMap();
              end;
           end;
        end else begin                     // 正推
           if curMap.Recording then begin   // 将录制的动作保存的“寄存器”
              curMap.Recording := False;
              DrawMap();
              Act := GetRecording(mySettings.isBK, curMap.StartPos);
              if Length(Act) > 0 then begin
                 ActionForm.MemoAct.Lines.Clear;
                 ActionForm.MemoAct.Lines.Text := Act;
                 bt_Act.Click;
              end;
           end else begin    // 启动录制模式
              curMap.Recording := True;
              curMap.StartPos := UndoPos+1;
              DrawMap();
           end;
        end;
        Exit;
     end;
  end;

  // 加载到了动作
  if not err then begin
      len := ActionForm.MemoAct.Lines.Count;

      Act := '';
      for i := 0 to len-1 do begin
          str := StringReplace(ActionForm.MemoAct.Lines[i], #9, '', [rfReplaceAll]);
          str := StringReplace(str, ' ', '', [rfReplaceAll]);
          if (Length(str) > 0) and (not isLurd_2(str)) then begin
             Act := '';
             StatusBar1.Panels[7].Text := '遇到无效的动作字符！';
             Exit;
          end;
          Act := Act + str;
      end;

      // 解析动作字符串
      M_X := -1;
      M_Y := -1;
      if mySettings.isBK then begin             // 逆推
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
               if p <> nil then FreeAndNil(p);
             end;
          end else begin
             k := Max(i, j);

             if k > 0 then delete(Act, 1, k);
          end;
      end else begin               // 正推
          i := pos('[', str);

          if i > 0 then Act := copy(Act, 1, i-1);
      end;

      // 执行动作 - 按现场旋转，当前点，执行一次
      // 若为逆推模式，先检查一下人的位置情况
      if mySettings.isBK then begin
         if ManPos_BK < 0 then begin
            if (M_X < 0) or (M_Y < 0) or (M_X >= curMapNode.Cols) or (M_Y >= curMapNode.Rows) or
               (not (map_Board_BK[M_Y * curMapNode.Cols + M_X] in [ FloorCell, GoalCell ])) then begin
               StatusBar1.Panels[7].Text := '人的初始位置不正确！';
               Exit;
            end;

            // 先去掉老位置上的人
            for i := 0 to 9999 do begin
               if map_Board_BK[i] = ManCell then map_Board_BK[i] := FloorCell
               else if map_Board_BK[i] = ManGoalCell then map_Board_BK[i] := GoalCell;
            end;

            // 新位置放上人 
            ManPos_BK := M_Y * curMapNode.Cols + M_X;
            ManPos_BK_0 := ManPos_BK;
            if map_Board_BK[ManPos_BK] = FloorCell then map_Board_BK[ManPos_BK] := ManCell
            else map_Board_BK[ManPos_BK] := ManGoalCell;
         end;
      end;

      // 将解析到的动作送人redo队列中
      GetLurd(Act, mySettings.isBK);

      // 按现场旋转转换 redo 中的动作
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

      // 执行一次
      if mySettings.isBK then begin
         ReDo_BK(ReDoPos_BK);
      end else begin
         ReDo(ReDoPos);
      end;

  end;

end;

// 键盘按下
procedure Tmain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_PRIOR:               // Page Up键，  上一关
      begin
        if isMoving then IsStop := True
        else IsStop := False;

        pl_Ground.SetFocus;
      end;
    VK_NEXT:                // Page Domw键，下一关
      begin
        if isMoving then IsStop := True
        else IsStop := False;

        pl_Ground.SetFocus;
    end;
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
    VK_F1:                         // F1，帮助
      begin
        ShellExecute(Application.handle, nil, PChar(AppPath + 'BoxManHelp.txt'), nil, nil, SW_SHOWNORMAL);
        ContentClick(Self);
      end;
    VK_F2:                         // F2，更换皮肤
      bt_Skin.Click;
    VK_F3:                         // F3，浏览关卡
      bt_View.Click;
    VK_F4:                         // F4，动作编辑
      bt_Act.Click;
    69:                            // E， 奇偶格效果
      if not mySettings.isOddEven then
         bt_OddEvenMouseDown(Self, mbLeft, [], -1, -1);
  end;
end;

// 键盘抬起
procedure Tmain.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    69:
      bt_OddEvenMouseUp(Self, mbLeft, [], -1, -1);       // E， 奇偶格效果
    VK_F5:                         // F5，自动加载并执行“寄存器 1”中的动作
      DoAct(1);
    VK_F6:                         // F6，自动加载并执行“寄存器 1”中的动作
      DoAct(2);
    VK_F7:                         // F7，自动加载并执行“寄存器 3”中的动作
      DoAct(3);
    VK_F8:                         // F8，自动加载并执行“寄存器 4”中的动作
      DoAct(4);
    VK_F9:                         // F9，开始或停止录制动作
      DoAct(5);
    VK_PRIOR:               // Page Up键，  上一关
      begin
        if (ssShift in Shift) or (ssCtrl in Shift) then begin
            N8.Click;
        end else if ssAlt in Shift then begin
            N9.Click;
        end else bt_Pre.Click;
      end;
    VK_NEXT:                // Page Domw键，下一关
      begin
        if (ssShift in Shift) or (ssCtrl in Shift) then begin
            N10.Click;
        end else if ssAlt in Shift then begin
            N11.Click;
        end else bt_Next.Click;
    end;
    VK_HOME:    // Home，至首
      begin
        if isMoving then IsStop := True
        else IsStop := False;

        N16.Click;
      end;
    VK_END:    // End，至尾
      begin
        if isMoving then IsStop := True
        else IsStop := False;

        N19.Click;
      end;
    83:                // Ctrl + S
      if ssCtrl in Shift then begin
        bt_Save.Click;
      end else begin
        if isMoving then IsStop := True
        else begin    // S，重做一步
           IsStop := false;
           N17.Click;
        end;
      end;
    90:                    // z，撤销
      begin
        if isMoving then IsStop := True
        else begin
           IsStop := false;
           bt_UnDo.Click;
        end;
      end;
    88:                    // x，重做
      begin
        if isMoving then IsStop := True
        else begin
           IsStop := false;
           bt_ReDo.Click;
        end;
      end;
    65:                     // a，撤销一步
      begin
        if isMoving then IsStop := True
        else begin
           IsStop := false;
           N14.Click;
        end;
      end;
    75:                // Ctrl + K，将导入的关卡，加入到关卡周转库
      if ssCtrl in Shift then begin
        XSB0.Click;
      end;
    81:                // Ctrl + Q， 退出
      if ssCtrl in Shift then begin
         Close();
      end;
    71:                // Ctrl + G， 固定的目标位
      if ssCtrl in Shift then begin
         pmGoal.Click;
      end;
    74:                // Ctrl + J， 即景目标位
      if ssCtrl in Shift then begin
         pmJijing.Click;
      end;
    76:                // Ctrl + L， 从剪切板加载 Lurd
      if ssCtrl in Shift then begin
         Lurd1.Click;
      end;
    77:                // Ctrl + M， Lurd 送入剪切板; Ctrl + Alt + N， 后续动作 Lurd 送入剪切板
      if ssCtrl in Shift then begin
         if ssAlt in Shift then Lurd3.Click
         else Lurd2.Click;
      end;
    67:                 // Ctrl + C， XSB 送入剪切板
      if ssCtrl in Shift then
      begin
        if ssAlt in Shift then XSB4.Click       // 现场
        else XSB2.Click;                        // 原始 xsb
      end;
    86:                // Ctrl + V， 从剪切板加载 XSB
      if (ssCtrl in Shift) then begin
         XSB1.Click;
      end;
    79:                         // Ctrl + o，打开关卡文档
      begin
        if isMoving then IsStop := True
        else IsStop := False;

        bt_Open.Click;
      end;
    106, 56:                    // 第 0 转
      begin
        curMapNode.Trun := 0;
        SetMapTrun;
      end;
    111, 191:                   // 旋转关卡
      begin
        if curMapNode.Trun < 7 then
          inc(curMapNode.Trun)
        else
          curMapNode.Trun := 0; 
        SetMapTrun;
      end;
    72:                         // H，显示或隐藏侧边栏
      begin
        bt_LeftBar.Click;
      end;
    73:                         // I，瞬移
      begin
        bt_IM.Click;
      end;
    66:                         // B，逆推模式
      begin
        bt_BK.Click;
      end;
    109, 188, 189:              // -，减速
      begin                     
        if mySettings.mySpeed < 4 then
          Inc(mySettings.mySpeed);
        pnl_Speed.Caption := SpeedInf[mySettings.mySpeed];
      end;
    107, 187, 190:              // +，增速
      begin                      
        if mySettings.mySpeed > 0 then
          Dec(mySettings.mySpeed);
        pnl_Speed.Caption := SpeedInf[mySettings.mySpeed];
      end;
    27:                         // ESC，重开始
      begin
        if isMoving then IsStop := True
        else begin
           IsStop := false;
           pm_Home.Click;
        end;
      end;
    8:                          // 退格键，反向演示
      begin
        if isMoving then IsStop := True
        else begin
           IsStop := false;
           N21.Click;
        end;
      end;
    32:                         // 空格键，正向演示
      begin
        if isMoving then IsStop := True
        else begin
           IsStop := false;
           N22.Click;
        end;
      end;
  end;
end;

// 关卡重新开始
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

// 调整窗口大小
procedure Tmain.FormResize(Sender: TObject);
begin
  NewMapSize();
  DrawMap();        // 画地图
end;

// 刷新状态栏 - 推动数、移动数
procedure Tmain.ShowStatusBar();
begin
  if mySettings.isBK then
  begin
    StatusBar1.Panels[1].Text := inttostr(MoveTimes_BK);
    StatusBar1.Panels[2].Text := '拉动';
    StatusBar1.Panels[3].Text := inttostr(PushTimes_BK);
  end
  else
  begin
    StatusBar1.Panels[1].Text := inttostr(MoveTimes);
    StatusBar1.Panels[2].Text := '推动';
    StatusBar1.Panels[3].Text := inttostr(PushTimes);
  end;
//  StatusBar1.Panels[7].Text := ' ';
end;

// 计算标尺
function Tmain.GetCur(x, y: Integer): string;
var
  k: Integer;
begin

  k := x div 26 + 64;

  if (k > 64) then
    Result := chr(k);

  Result := chr(x mod 26 + 65) + IntToStr(y + 1);
end;

// 计算访问过的格子
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

// 地图上双击 -- 箱子编号
procedure Tmain.map_ImageDblClick(Sender: TObject);
var
  pos, myCell, i, j: Integer;
  
begin
  // 被点击的图元位置
  pos := DoubleClickPos.y * curMapNode.Cols + DoubleClickPos.x;
  if mySettings.isBK then begin   // 逆推
    myCell := map_Board_BK[pos];
    if myCell in [ BoxCell, BoxGoalCell ] then begin                       // 双击的是箱子
       if BoxNum_Board_BK[pos] > 0 then begin
          BoxNum_Board_BK[pos] := -1;
          Exit;
       end;
       BoxNum_Board_BK[pos] := -1;
    end else if myCell in [ FloorCell, GoalCell, ManCell, ManGoalCell ] then begin  // 双击的是通道
       if PosNum_Board_BK[pos] > 0 then begin
          PosNum_Board_BK[pos] := -1;
          Exit;
       end;
       PosNum_Board_BK[pos] := -1;
    end else Exit;                                                        // 双击的是其它
  end else begin                  // 正推
    myCell := map_Board[pos];
    if myCell in [ BoxCell, BoxGoalCell ] then begin                       // 双击的是箱子
       if BoxNum_Board[pos] > 0 then begin
          BoxNum_Board[pos] := -1;
          Exit;
       end;
       BoxNum_Board[pos] := -1;
    end else if myCell in [ FloorCell, GoalCell, ManCell, ManGoalCell ] then begin  // 双击的是通道
       if PosNum_Board[pos] > 0 then begin
          PosNum_Board[pos] := -1;
          Exit;
       end;
       PosNum_Board[pos] := -1;
    end else if myCell = WallCell then begin  // 双击的是墙壁
       if mySettings.isShowNoVisited then mySettings.isShowNoVisited := False
       else begin
         Board_Visited;
         mySettings.isShowNoVisited := True;
       end;
    end else Exit;
  end;

  if myCell in [ BoxCell, BoxGoalCell ] then begin                      // 双击的是箱子
     i := 1;
     while i <= 9 do begin
         j := 0;
         while j < curMap.MapSize do begin
             if mySettings.isBK then begin    // 逆推
                if BoxNum_Board_BK[j] = i then Break;
             end else begin                   // 正推
                if BoxNum_Board[j] = i then Break;
             end;
             inc(j);
         end;
         if j = curMap.MapSize then Break;
         inc(i);
     end;
     if i <= 9 then begin
        if mySettings.isBK then BoxNum_Board_BK[pos] := i     // 逆推
        else BoxNum_Board[pos] := i;                          // 正推
     end;
  end else begin
     i := 1;                                                            // 双击的是通道
     while i <= 26 do begin
         j := 0;
         while j < curMap.MapSize do begin
             if mySettings.isBK then begin    // 逆推
                if PosNum_Board_BK[j] = i then Break;
             end else begin                   // 正推
                if PosNum_Board[j] = i then Break;
             end;
             inc(j);
         end;
         if j = curMap.MapSize then Break;
         inc(i);
     end;
     if i <= 26 then begin
        if mySettings.isBK then PosNum_Board_BK[pos] := i     // 逆推
        else PosNum_Board[pos] := i;                          // 正推
     end;
  end;
end;

// 地图上单击
procedure Tmain.map_ImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  MapClickPos: TPoint;
  myCell, pos, x2, y2, k: Integer;
begin
  if (curMapNode = nil) or (curMap.CellSize = 0) then Exit;
  
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

  case curMapNode.Trun of // 把点击的位置，转换地图的真实坐标 -- 将视觉坐标转换为地图坐标
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

  StatusBar1.Panels[5].Text := ' ' + GetCur(x2, y2) + ' - [ ' + IntToStr(x2 + 1) + ', ' + IntToStr(y2 + 1) + ' ]';       // 标尺

  // 被点击的图元位置
  DoubleClickPos.X := MapClickPos.x;      // 为双击记录位置
  DoubleClickPos.Y := MapClickPos.y;
  pos := MapClickPos.y * curMapNode.Cols + MapClickPos.x;
  if mySettings.isBK then
    myCell := map_Board_BK[pos]
  else
    myCell := map_Board[pos];

  case Button of
    mbleft:             // 单击 -- 指左键
      if ssAlt in Shift then begin     // 按了   Alt 键 -- 选择单元格动作 -- 从现有选区中，减去一部分选区
         if isSelectMod then begin
            isDelSelect := True;
            isSelecting := True;            // 触动了单元格选择模式 -- 拖动开始
            
            LeftTopPos.X := MapClickPos.x;
            LeftTopPos.Y := MapClickPos.y;
            RightBottomPos.X := MapClickPos.x;
            RightBottomPos.Y := MapClickPos.y;

            DrawMap();
            
         end;
      end else if ssCtrl in Shift then begin     // 按了   Ctrl 键 -- 选择单元格动作
         if not isSelectMod then begin  // 首次触动选择模式 -- 先清空选中的单元格
            for k := 0 to curMap.MapSize-1 do begin
                if mySettings.isBK then map_Selected_BK[k] := False
                else map_Selected[k] := False;
            end;
         end;
         isDelSelect := False;
         isSelectMod := True;            // 触动了单元格选择模式 -- 数箱子
         isSelecting := True;            // 触动了单元格选择模式 -- 拖动开始
         LeftTopPos.X := MapClickPos.x;
         LeftTopPos.Y := MapClickPos.y;
         RightBottomPos.X := MapClickPos.x;
         RightBottomPos.Y := MapClickPos.y;

         DrawMap();
         
//         Caption := '[' + IntToStr(LeftTopPos.X) + ', ' + IntToStr(LeftTopPos.Y) + '] -- [' + IntToStr(RightBottomPos.X) + ', ' + IntToStr(RightBottomPos.Y) + ']';
      end else begin                    // 没有按 Ctrl 键 -- 推箱子动作
        isSelecting := False;           // 取消单元格选择模式 -- 数箱子
        isSelectMod := False;           // 取消单元格选择模式 -- 数箱子
        case myCell of
          FloorCell, GoalCell:
            begin            // 单击地板
              if mySettings.isBK then
              begin                                            // 逆推
                if IsBoxAccessibleTips_BK then
                begin                      // 有箱子可达提示时
                         // 视点击位置是否可达而定
                  if not myPathFinder.isBoxReachable_BK(pos) then
                    IsBoxAccessibleTips_BK := False
                  else
                  begin
                    IsBoxAccessibleTips_BK := False;
                    ReDoPos_BK := myPathFinder.boxTo(mySettings.isBK, OldBoxPos_BK, pos, ManPos_BK);
                    if ReDoPos_BK > 0 then
                    begin
                      for k := 1 to ReDoPos_BK do
                        RedoList_BK[k] := BoxPath[ReDoPos_BK - k + 1];
                      mySettings.isLurd_Saved := False;             // 有了新的动作
                      curMap.isFinish := False;
                      IsStop := false;
                      ReDo_BK(ReDoPos_BK);
                    end;
                  end;
                end
                else
                begin
                  if (ManPos_BK < 0) or (PushTimes_BK <= 0) then
                  begin                      // 逆推中，调整人的定位
                    IsManAccessibleTips_BK := False;
                    IsBoxAccessibleTips_BK := False;
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
                  end
                  else
                  begin
                    IsManAccessibleTips_BK := False;
                    IsBoxAccessibleTips_BK := False;
                    ReDoPos_BK := myPathFinder.manTo(mySettings.isBK, map_Board_BK, ManPos_BK, pos);   // 计算人可达
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
              begin                                                // 正推
                if IsBoxAccessibleTips then
                begin                          // 有箱子可达提示时
                  // 视点击位置是否可达而定
                  if not myPathFinder.isBoxReachable(pos) then
                    IsBoxAccessibleTips := False
                  else
                  begin
                    IsBoxAccessibleTips := False;

                    ReDoPos := myPathFinder.boxTo(mySettings.isBK, OldBoxPos, pos, ManPos);
                    if ReDoPos > 0 then
                    begin
                      for k := 1 to ReDoPos do
                        RedoList[k] := BoxPath[ReDoPos - k + 1];
                      LastSteps := UnDoPos;              // 正推最后一次点推前的步数
                      mySettings.isLurd_Saved := False;             // 有了新的动作
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
                  ReDoPos := myPathFinder.manTo(mySettings.isBK, map_Board, ManPos, pos);               // 计算人可达
                  if ReDoPos > 0 then
                  begin
                    LastSteps := UnDoPos;              // 正推最后一次点推前的步数
                    for k := 1 to ReDoPos do
                      RedoList[k] := ManPath[k];
                    IsStop := false;
                    ReDo(ReDoPos);
                  end;
                end;
              end;
            end;
          ManCell, ManGoalCell:
            begin           // 单击人
              if mySettings.isBK then
              begin                                            // 逆推
                if IsBoxAccessibleTips_BK and myPathFinder.isBoxReachable_BK(ManPos_BK) then
                begin  // 有箱子可达提示时
                  IsBoxAccessibleTips_BK := False;
                  ReDoPos_BK := myPathFinder.boxTo(mySettings.isBK, OldBoxPos_BK, pos, ManPos_BK);
                  if ReDoPos_BK > 0 then
                  begin
                    for k := 1 to ReDoPos_BK do
                      RedoList_BK[k] := BoxPath[ReDoPos_BK - k + 1];
                    mySettings.isLurd_Saved := False;             // 有了新的动作
                    curMap.isFinish := False;
                    IsStop := false;
                    ReDo_BK(ReDoPos_BK);
                  end;
                end
                else if IsManAccessibleTips_BK then
                  IsManAccessibleTips_BK := False  // 在显示人的可达提示时，又点击了人
                else
                begin
                  myPathFinder.manReachable(mySettings.isBK, map_Board_BK, ManPos_BK);            // 计算人可达
                  IsManAccessibleTips_BK := True;
                  IsBoxAccessibleTips_BK := False;
                end;
              end
              else
              begin                                                // 正推
                if IsBoxAccessibleTips and myPathFinder.isBoxReachable(ManPos) then
                begin   // 有箱子可达提示时
                  IsBoxAccessibleTips := False;

                  ReDoPos := myPathFinder.boxTo(mySettings.isBK, OldBoxPos, pos, ManPos);
                  if ReDoPos > 0 then
                  begin
                    for k := 1 to ReDoPos do
                      RedoList[k] := BoxPath[ReDoPos - k + 1];
                    LastSteps := UnDoPos;              // 正推最后一次点推前的步数
                    mySettings.isLurd_Saved := False;             // 有了新的动作
                    curMap.isFinish := False;
                    IsStop := false;
                    ReDo(ReDoPos);
                  end;
                end
                else if IsManAccessibleTips then
                  IsManAccessibleTips := False        // 在显示人的可达提示时，又点击了人
                else
                begin
                  myPathFinder.manReachable(mySettings.isBK, map_Board, ManPos);                  // 计算人可达
                  IsManAccessibleTips := True;
                  IsBoxAccessibleTips := False;
                end;
              end;
            end;
          BoxCell, BoxGoalCell:
            begin           // 单击箱子
              if mySettings.isBK then
              begin                                            // 逆推
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
                    myPathFinder.FindBlock(map_Board_BK, pos);                       // 根据被点击的箱子，计算割点
                    myPathFinder.boxReachable(mySettings.isBK, pos, ManPos_BK);                 // 计算箱子可达
                    OldBoxPos_BK := pos;
                  end;
                end;
              end
              else
              begin                                                // 正推
                if IsBoxAccessibleTips and (OldBoxPos = pos) then
                  IsBoxAccessibleTips := False
                else
                begin
                  IsBoxAccessibleTips := True;
                  IsManAccessibleTips := False;
                  myPathFinder.FindBlock(map_Board, pos);                              // 根据被点击的箱子，计算割点
                  myPathFinder.boxReachable(mySettings.isBK, pos, ManPos);                        // 计算箱子可达
                  OldBoxPos := pos;
                end;
              end;
            end;
        else
          begin                            // 取消可达提示
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
      begin    // 右击 -- 指右键

      end;
  end;

  DrawMap();
end;

procedure Tmain.map_ImageMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  x2, y2: Integer;

begin
  if (curMapNode = nil) or (curMap.CellSize = 0) then Exit;

  x2 := X div curMap.CellSize;
  y2 := Y div curMap.CellSize;

  if curMapNode.Cols > 0 then
    StatusBar1.Panels[5].Text := ' ' + GetCur(x2, y2) + ' - [ ' + IntToStr(x2 + 1) + ', ' + IntToStr(y2 + 1) + ' ]';       // 标尺

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

procedure Tmain.map_ImageMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  MapClickPos: TPoint;
  x2, y2, i, j, i1, j1, i2, j2: Integer;

begin
  if (curMapNode = nil) or (curMap.CellSize = 0) then Exit;

  if isDelSelect then begin
     if not (ssAlt in Shift) then begin
        isSelecting := False;           // 取消单元格选择模式 -- 数箱子
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
      
      case curMapNode.Trun of // 把点击的位置，转换地图的真实坐标 -- 将视觉坐标转换为地图坐标
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

      isSelecting := False;           // 取消单元格选择模式 -- 数箱子     
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

// 游戏延时
procedure Tmain.GameDelay();
var
  CurTime: dword;
  ch1, ch2: Char;
  
begin
  if isNoDelay then Exit;      // 若为无延时移动，直接返回

  if isKeyPush then begin       // 若为演示动画，则按直推方式瞬移显示动画
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

         DrawMap();             // 刷新地图画面
       except
       end;
    end;
    StatusBar1.Repaint;
  end else begin              // 常规动画，仅检查是否瞬移来觉得是否执行延时操作
    if mySettings.isIM then
      exit;                   // 瞬移打开时
  end;

  CurTime := GetTickCount;    // 延时

  while (GetTickCount - CurTime) < DelayTimes[mySettings.mySpeed] do begin
     if IsStop then Break;
     Application.ProcessMessages;
  end;
end;

procedure Tmain.ContentClick(Sender: TObject);
begin   // 帮助
//  Application.HelpFile := ChangeFileExt(Application.ExeName, '.HLP');
//  Application.HelpCommand(HELP_FINDER, 0);
end;

// 保存状态
function Tmain.SaveState(): Boolean;
var
  sldb: TSQLiteDatabase;
  sSQL: String;
  i, ActCRC, ActCRC_BK, x, y, size: Integer;
  actNode: ^TStateNode;
  act, act_BK: string;
begin
  Result := False;

  if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;

  if (PushTimes = 0) and (PushTimes_BK = 0) then
    Exit;

  // 没有推动动作时，不做保存处理
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

  // 查重
  i := 0;
  size := StateList.Count;
  while i < size do
  begin
    actNode := StateList[i];
    if (actNode.CRC32 = ActCRC) and (actNode.Moves = MoveTimes) and (actNode.Pushs = PushTimes) and
       (actNode.CRC32_BK = ActCRC_BK) and (actNode.Moves_BK = MoveTimes_BK) and (actNode.Pushs_BK = PushTimes_BK) and (actNode.Man_X = x+1) and (actNode.Man_Y = y+1) then
      Break;
    inc(i);
  end;
  actNode := nil;

  if i = size then
  begin           // 无重复
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

              // 当前状态插入到列表的最前面
              List_State.Items.Insert(0, IntToStr(actNode.Pushs) + '/' + IntToStr(actNode.Moves) + #10 + ' [' + IntToStr(actNode.Man_X) + ',' + IntToStr(actNode.Man_Y) + ']' + IntToStr(actNode.Pushs_BK) + '/' + IntToStr(actNode.Moves_BK) + #10 + FormatDateTime(' yyyy-mm-dd hh:nn', actNode.DateTime));

              StatusBar1.Panels[7].Text := '状态已保存！';
           end;
        end;
      finally
        sldb.free;
        actNode := nil;
      end;
    except
        MessageBox(handle, '状态库出错，' + #10 + '状态未能保存！', '错误', MB_ICONERROR or MB_OK);
        Exit;
    end;

  end else begin        // 有重复

    // 调整状态列表条目的次序 -- 当前状态提到最前面
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
          StatusBar1.Panels[7].Text := '状态有重复，已调整存储次序！';
        Finally
          sldb.free;
          actNode := nil;
        end;
      except
        MessageBox(handle, '状态库出错，' + #10 + '未能正确调整状态的存储次序！', '错误', MB_ICONERROR or MB_OK);
        Exit;
      end;
    end else StatusBar1.Panels[7].Text := '状态已有保存！';;
  end;

  PageControl.ActivePageIndex := 1;
  List_State.Selected[0] := True;
  if pl_Side.Visible then List_State.SetFocus;
  mySettings.isLurd_Saved := True;
  Result := True;
end;

// 将本系统中的日期时间字符串，转换为“日期时间”
function MyStrToDate(str: string; SysFrset: TFormatSettings): TDateTime;
var
  s: string;
begin
  s := Copy(str, 1, 4) + '-' + Copy(str, 6, 2) + '-' + Copy(str, 9, 8) + ':00.000';

  Result := StrToDateTime(s, SysFrset);
end;

// 加载状态
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

  if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;

//  StateList.Clear;
  MyListClear(StateList);
  List_State.Clear;

  try
    sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));
    try

      sSQL := 'select * from Tab_State where XSB_CRC32 = ' + IntToStr(curMapNode.CRC32) + ' and XSB_CRC_TrunNum = ' + IntToStr(curMapNode.CRC_Num) + ' and Goals = ' + IntToStr(curMapNode.Goals) + ' order by Act_DateTime desc';

      sltb := slDb.GetTable(sSQL);

      // 检查当前系统的日期分隔符
      GetLocaleFormatSettings(GetUserDefaultLCID, SysFrset);

      try
         // 加载状态
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
    StatusBar1.Panels[7].Text := '状态库出错，关卡的状态未能正确加载！';
    Exit;
  end;

  Result := True;
end;

// 新增答案 - n=1，正推过关；n=2，正逆相合或逆推过关
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

  if MapList.Count = 0 then begin
     for i := 0 to 30 do begin
        if SolvedLevel[i] = 0 then begin
           SolvedLevel[i] := curMap.CurrentLevel;
           Break;
        end;
     end;
  end;

  // 计算答案 CRC
  if n = 1 then begin      // 正推过关
     solCRC := Calcu_CRC_32_2(@UndoList, MoveTimes);
     m := MoveTimes;
     p := PushTimes;
  end else begin           // 正逆相合或逆推过关
     // 正逆相合或逆推过关时，答案已经到了正推 undolist和redolist中
     // 借用一下 ManPath 数组做相关的计算
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

  // 查重
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

  // 无重复，存入答案库
  if i = size then
  begin
    if n = 1 then begin      // 正推过关
       if UnDoPos < MaxLenPath then UndoList[UnDoPos + 1] := #0;
       sol := PChar(@UndoList);
    end else begin           // 逆推过关或正逆相合
       sol := PChar(@ManPath);
    end;
    New(solNode);
    solNode.id := -1;
    solNode.DateTime := Now;
    solNode.Moves := m;
    solNode.Pushs := p;
    solNode.CRC32 := solCRC;

    sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));

    // 保存到数据库
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
      MessageBox(handle, '答案库出错，' + #10 + '答案未能保存！', '错误', MB_ICONERROR or MB_OK);
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

// 加载答案
function Tmain.LoadSolution(): Boolean;
var
  sldb: TSQLiteDatabase;
  sltb: TSQLIteTable;
  sSQL: String;
  solNode: ^TSoltionNode;
  str, xsbStr, myDateTime: string;
  SysFrset: TFormatSettings;
begin
  Result := False;
  if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;

  MyListClear(SoltionList);
  List_Solution.Clear;

  sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));

  // 加载答案
  try
    // 检查当前系统的日期分隔符
    GetLocaleFormatSettings(GetUserDefaultLCID, SysFrset);
    try
      sSQL := 'select * from Tab_Solution where XSB_CRC32 = ' + IntToStr(curMapNode.CRC32) + ' and Goals = ' + IntToStr(curMapNode.Goals) + ' order by Moves, Pushs';

      sltb := slDb.GetTable(sSQL);

      try
        if sltb.Count > 0 then begin
          SysFrset.ShortDateFormat:='yyyy-MM-dd';
          SysFrset.DateSeparator:='-';
          SysFrset.LongTimeFormat:='hh:mm:ss.zzz';
           // 读取答案
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
            // 答案验证
            if isSolution(curMapNode, PChar(str)) then begin
               SoltionList.Add(solNode);
               List_Solution.Items.Add(IntToStr(solNode.Pushs) + '/' + IntToStr(solNode.Moves) + #10 + FormatDateTime(' yyyy-mm-dd hh:nn', solNode.DateTime));
               if xsbStr = '' then begin        // 为旧版答案补上 XSB_Text
                  sldb.BeginTransaction;
                  sldb.ExecSQL('UPDATE Tab_Solution set XSB_Text = ''' + curMapNode.Map_Thin + ''' WHERE ID = ' + inttostr(solNode.id));
                  sldb.Commit;
               end;
            end;

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
    StatusBar1.Panels[7].Text := '答案库出错，关卡答案未能正确加载！';
    Exit;
  end;

  Result := True;
end;

// 加载指定关卡的所有答案
function Tmain.GetSolution(mapNpde: PMapNode): string;
var
  sldb: TSQLiteDatabase;
  sltb: TSQLIteTable;
  sSQL: String;
  str, Sol_DateTime: string;
  Sol_Moves, Sol_Pushs: Integer;

begin
  Result := '';

  sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));
  
  try
    try
      sSQL := 'select * from Tab_Solution where XSB_CRC32 = ' + IntToStr(curMapNode.CRC32) + ' and Goals = ' + IntToStr(curMapNode.Goals);

      sltb := slDb.GetTable(sSQL);

      try
        if sltb.Count > 0 then begin
           // 读取答案
          sltb.MoveFirst;
          while not sltb.EOF do begin
            Sol_DateTime := sltb.FieldAsString(sltb.FieldIndex['Sol_DateTime']);
            Sol_Moves := sltb.FieldAsInteger(sltb.FieldIndex['Moves']);
            Sol_Pushs := sltb.FieldAsInteger(sltb.FieldIndex['Pushs']);
            str           := sltb.FieldAsString(sltb.FieldIndex['Sol_Text']);

            // 答案验证
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
    StatusBar1.Panels[7].Text := '答案库出错，关卡的答案不能正确加载！';
    Exit;
  end;
end;

// 重做一步 -- 正推
procedure Tmain.ReDo(Steps: Integer);
var
  ch, ch_: Char;
  pos1, pos2: Integer;
  isMeet, IsCompleted: Boolean;
{$IFDEF LASTACT}
  act: string;
{$ENDIF}

begin
  if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;

  StatusBar1.Panels[7].Text := '';

  isSelectMod := False;
  isMoving := True;                                                             // 移动中...

  mySettings.isShowNoVisited := False;                                                           
  IsBoxAccessibleTips := False;
  IsManAccessibleTips := False;
  StatusBar1.Panels[7].Text := '';

  isMeet := False;
  IsCompleted := False;

  try
    while (not IsStop) and (Steps > 0) and (ReDoPos > 0) and (UnDoPos < MaxLenPath) do begin

      // 人的位置出现异常
      if (ManPos < 0) or (ManPos >= curMap.MapSize) or
         (not (map_Board[ManPos] in [ManCell, ManGoalCell])) then begin
         StatusBar1.Panels[7].Text := format('人的位置异常！- [%d, %d]', [ManPos mod curMapNode.Cols + 1, ManPos div curMapNode.Cols + 1]);
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

      if (pos1 < 0) or (pos1 >= curMap.MapSize) then begin                        // pos1 界外
         StatusBar1.Panels[7].Text := '遇到了错误的动作符号！- ' + ch_;
         Break;
      end;

      // 遇到地板，仅仅移动人即可；若遇到箱子，需要同时移动箱子和人；否则，遇到了错误，直接结束本次的移动
      if (map_Board[pos1] in [ FloorCell, GoalCell]) then begin                   // pos1 是通道

         if map_Board[pos1] = FloorCell then map_Board[pos1] := ManCell
         else map_Board[pos1] := ManGoalCell;

      end else if (map_Board[pos1] in [ BoxCell, BoxGoalCell]) then begin         // pos1 是箱子

        if (pos2 < 0) or (pos2 >= curMap.MapSize) then begin                      // pos2 界外
           StatusBar1.Panels[7].Text := '遇到了错误的动作符号！- ' + ch_;
           Break;
        end;

        if (map_Board[pos2] in [ FloorCell, GoalCell]) then begin                 // pos2 是通道

           if map_Board[pos2] = FloorCell then map_Board[pos2] := BoxCell         // 箱子到位
           else map_Board[pos2] := BoxGoalCell;

           if map_Board[pos1] = BoxCell then map_Board[pos1] := ManCell           // 人到位
           else map_Board[pos1] := ManGoalCell;

           ch := Char(Ord(ch) - 32);                                              // 变成大写 -- 推动
           BoxNum_Board[pos2] := BoxNum_Board[pos1];                              // 新箱子编号
           BoxNum_Board[pos1] := -1;                                              // 原箱子编号

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

      if (not mySettings.isIM) and (not isNoDelay) then DrawMap();                // 更新地图显示

      ShowStatusBar();
      StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos mod curMapNode.Cols, ManPos div curMapNode.Cols) + ' - [ ' + IntToStr((ManPos mod curMapNode.Cols) + 1) + ', ' + IntToStr((ManPos div curMapNode.Cols) + 1) + ' ]';       // 标尺

      Dec(Steps);
      if Steps > 0 then GameDelay();                                              // 延时

      if (not curMap.isFinish) and (ch in [ 'L', 'R', 'U', 'D' ]) and (PushTimes > 0)then begin
        if IsComplete() then                                      // 解关成功
        begin
          IsCompleted := True;
          Break;
        end
        else if IsMeets(ch) then
        begin                                                                     // 正逆相合
          isMeet := True;
          Break;
        end;
      end;

    end;

    if mySettings.isIM or isNoDelay then DrawMap();                               // 更新地图显示

    StatusBar1.Repaint;

    if IsCompleted then begin
      ReDoPos := 0;

      // 自动保存一下答案
      SaveSolution(1);                                                            // 正推过关

      mySettings.isLurd_Saved := True;

      curMap.isFinish := True;
      ShowMyInfo('正推过关！', '恭喜');

    end else if isMeet then begin
      // 自动保存一下答案
      SaveSolution(2);
      curMap.isFinish := True;                                                    // 正逆相合
      ShowMyInfo('正逆相合！', '恭喜');
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
  isNoDelay := false;                                                           // 是否为无延时动作 -- 至首、至尾功能用
  isKeyPush := false;                                                           // 是否正在演示中 -- 空格键和退格键控制的
  isMoving  := False;
end;

// 撤销一步 -- 正推
procedure Tmain.UnDo(Steps: Integer);
var
  ch: Char;
  pos1, pos2: Integer;
{$IFDEF LASTACT}
  act: string;
{$ENDIF}
begin
  if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;

  StatusBar1.Panels[7].Text := '';

  isSelectMod := False;
  isMoving := True;                                                             // 移动中...

  mySettings.isShowNoVisited := False;
  IsBoxAccessibleTips := False;
  IsManAccessibleTips := False;
  StatusBar1.Panels[7].Text := '';

  try
    while (not IsStop) and (Steps > 0) and (UnDoPos > 0) and (ReDoPos < MaxLenPath) do begin

      // 人的位置出现异常
      if (ManPos < 0) or (ManPos >= curMap.MapSize) or
         (not (map_Board[ManPos] in [ManCell, ManGoalCell])) then begin
         StatusBar1.Panels[7].Text := format('人的位置异常！- [%d, %d]', [ManPos mod curMapNode.Cols + 1, ManPos div curMapNode.Cols + 1]);
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

      // 检测是否包含箱子的退回
      if ch in ['L', 'R', 'U', 'D'] then
      begin

        if (pos1 < 0) or (pos1 >= curMap.MapSize) or                              // 界外，等
           (pos2 < 0) or (pos2 >= curMap.MapSize) or
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

        BoxNum_Board[ManPos] := BoxNum_Board[pos1];                               // 新箱子编号
        BoxNum_Board[pos1] := -1;                                                 // 原箱子编号

        Dec(PushTimes);                                                           // 推动步数
      end
      else
      begin
        if (pos2 < 0) or (pos2 >= curMap.MapSize) or                              // 界外，等
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

      if (not mySettings.isIM) and (not isNoDelay) then DrawMap();                // 更新地图显示
      ShowStatusBar();
      StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos mod curMapNode.Cols, ManPos div curMapNode.Cols) + ' - [ ' + IntToStr((ManPos mod curMapNode.Cols) + 1) + ', ' + IntToStr((ManPos div curMapNode.Cols) + 1) + ' ]';       // 标尺

      Dec(Steps);
      if Steps > 0 then GameDelay();                                              // 延时

    end;

    if mySettings.isIM or isNoDelay then DrawMap();                               // 更新地图显示

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
  isNoDelay := false;                                                           // 是否为无延时动作 -- 至首、至尾功能用
  isKeyPush := false;                                                           // 是否正在演示中 -- 空格键和退格键控制的
  isMoving  := False;
end;

// 重做一步 -- 逆推
procedure Tmain.ReDo_BK(Steps: Integer);
var
  ch: Char;
  i, len, pos1, pos2, n: Integer;
  isOK, isMeet, IsCompleted: Boolean;
{$IFDEF LASTACT}
  act: string;
{$ENDIF}

begin
  if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;

  StatusBar1.Panels[7].Text := '';
  
  isSelectMod := False;
  isMoving := True;
                                                                                // 移动中...
  IsBoxAccessibleTips_BK := False;
  IsManAccessibleTips_BK := False;

  isMeet := False;
  IsCompleted := False;

  try
    while (not IsStop) and (Steps > 0) and (ReDoPos_BK > 0) and (UnDoPos_BK < MaxLenPath) do begin

      // 人的位置出现异常
      if (ManPos_BK < 0) or (ManPos_BK >= curMap.MapSize) or
         (not (map_Board_BK[ManPos_BK] in [ManCell, ManGoalCell])) then begin
         StatusBar1.Panels[7].Text := format('人的位置异常！- [%d, %d]', [ManPos_BK mod curMapNode.Cols + 1, ManPos_BK div curMapNode.Cols + 1]);
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

          if (pos2 < 0) or (pos2 >= curMap.MapSize) or                              // 界外，等
             (pos1 < 0) or (pos1 >= curMap.MapSize) or
             (not (map_Board_BK[pos2] in [BoxCell, BoxGoalCell])) or
             (not (map_Board_BK[pos1] in [FloorCell, GoalCell]))then begin
             StatusBar1.Panels[7].Text := '遇到了错误的动作符号！- ' + ch;
             Break;
          end;

          if map_Board_BK[pos2] = BoxCell then
            map_Board_BK[pos2] := FloorCell
          else
            map_Board_BK[pos2] := GoalCell;

          if (map_Board_BK[pos1] = FloorCell) then                                // 下一格是地板
            map_Board_BK[pos1] := ManCell
          else
            map_Board_BK[pos1] := ManGoalCell;

          if map_Board_BK[ManPos_BK] = ManCell then
            map_Board_BK[ManPos_BK] := BoxCell
          else
            map_Board_BK[ManPos_BK] := BoxGoalCell;

          BoxNum_Board_BK[ManPos_BK] := BoxNum_Board_BK[pos2];                    // 新箱子编号
          BoxNum_Board_BK[pos2] := -1;                                            // 原箱子编号

          Inc(PushTimes_BK);                                                      // 推动步数
        end
        else
        begin

          if (pos1 < 0) or (pos1 >= curMap.MapSize) or                            // 界外，等
             (not (map_Board_BK[pos1] in [FloorCell, GoalCell]))then begin
             StatusBar1.Panels[7].Text := '遇到了错误的动作符号！- ' + ch;
             Break;
          end;

          // 人到位
          if (map_Board_BK[pos1] = FloorCell) then                                // 下一格是地板
            map_Board_BK[pos1] := ManCell          
          else
            map_Board_BK[pos1] := ManGoalCell;

          if map_Board_BK[ManPos_BK] = ManCell then
            map_Board_BK[ManPos_BK] := FloorCell
          else
            map_Board_BK[ManPos_BK] := GoalCell;
        end;

        Inc(MoveTimes_BK);                                                        // 移动步数

        Dec(ReDoPos_BK);
        Inc(UnDoPos_BK);
        UndoList_BK[UnDoPos_BK] := ch;
        ManPos_BK := pos1;                                                        // 人的新位置

        if (not mySettings.isIM) and (not isNoDelay) then DrawMap();              // 更新地图显示
        ShowStatusBar();
        StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos_BK mod curMapNode.Cols, ManPos_BK div curMapNode.Cols) + ' - [ ' + IntToStr((ManPos_BK mod curMapNode.Cols) + 1) + ', ' + IntToStr((ManPos_BK div curMapNode.Cols) + 1) + ' ]';       // 标尺

        Dec(Steps);
        if Steps > 0 then GameDelay();                                            // 延时

        if (not curMap.isFinish) and (ch in [ 'L', 'R', 'U', 'D' ]) and (PushTimes_BK > 0)then begin
          if IsComplete_BK() then begin                                           // 逆推过关
            IsCompleted := True;                             
            Break;
          end else if IsMeets(ch) then begin                                      // 正逆相合
            isMeet := True;
            Break;
          end;
        end;
      end;
    end;

    StatusBar1.Repaint;

    if mySettings.isIM or isNoDelay then DrawMap();                               // 更新地图显示

    if IsCompleted then begin                                                     // 逆推过关，答案转存到正推

      Restart(false);                                                             // 正推地图复位
      ReDoPos := 0;

      len := myPathFinder.manTo(false, map_Board, ManPos, ManPos_BK);             // 取得人的“相合”路径

      // 跳过逆推转正推答案时，最后一推后面无用的空移动作
      n := 1;
      while n <= UnDoPos_BK do begin
        if UndoList_BK[n] in [ 'L', 'R', 'U', 'D' ] then Break;
        inc(n);
      end;

      // 把逆推undolist_bk中的动作，转送入正推的resolist中
      if len + UnDoPos_BK - n <= MaxLenPath then begin                                                          // 将逆推答案转送正推中
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
        // 补足人的“相合”动作
        for i := 1 to len do begin
            Inc(ReDoPos);
            RedoList[ReDoPos] := ManPath[i];
        end;
        // 自动保存一下答案
        SaveSolution(2);
        curMap.isFinish := True;
        ShowMyInfo('逆推过关！', '恭喜');
      end else begin
        SaveState();                                                            // 保存关卡 XSB 到文档，状态到数据库
        ShowMyInfo('逆推过关！' + #10 + '因答案过长，仅以状态方式保存！', '恭喜');
      end;
    end else if isMeet then begin                                                 // 正逆相合
      // 自动保存一下答案
      SaveSolution(2);
      curMap.isFinish := True;
      ShowMyInfo('正逆相合！', '恭喜');
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
  isNoDelay := false;                                                           // 是否为无延时动作 -- 至首、至尾功能用
  isKeyPush := false;                                                           // 是否正在演示中 -- 空格键和退格键控制的
  isMoving  := False;
end;

// 撤销一步 -- 逆推
procedure Tmain.UnDo_BK(Steps: Integer);
var
  ch: Char;
  pos1, pos2: Integer;
{$IFDEF LASTACT}
  act: string;
{$ENDIF}

begin
  if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;

  StatusBar1.Panels[7].Text := '';

  isSelectMod := False;
  isMoving := True;                                                             // 移动中...
                                                        
  IsBoxAccessibleTips_BK := False;
  IsManAccessibleTips_BK := False;

  try
    while (not IsStop) and (Steps > 0) and (UnDoPos_BK > 0) and (ReDoPos_BK < MaxLenPath) do begin

      // 人的位置出现异常
      if (ManPos_BK < 0) or (ManPos_BK >= curMap.MapSize) or
         (not (map_Board_BK[ManPos_BK] in [ManCell, ManGoalCell])) then begin
         StatusBar1.Panels[7].Text := format('人的位置异常！- [%d, %d]', [ManPos_BK mod curMapNode.Cols + 1, ManPos_BK div curMapNode.Cols + 1]);
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

      // 检测是否包含箱子的动作
      if ch in [ 'L', 'R', 'U', 'D' ] then begin

        if (pos2 < 0) or (pos2 >= curMap.MapSize) or                              // 界外，等
           (pos1 < 0) or (pos1 >= curMap.MapSize) or
           (not (map_Board_BK[pos1] in [BoxCell, BoxGoalCell])) or
           (not (map_Board_BK[pos2] in [FloorCell, GoalCell]))then begin
           StatusBar1.Panels[7].Text := '遇到了错误的动作符号！- ' + ch;
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

        BoxNum_Board_BK[pos2] := BoxNum_Board_BK[pos1];                           // 新箱子编号
        BoxNum_Board_BK[pos1] := -1;                                              // 原箱子编号

        Dec(PushTimes_BK);                                                        // 推动步数
      end else begin
        if (pos1 < 0) or (pos1 >= curMap.MapSize) or                              // 界外，等
           (not (map_Board_BK[pos1] in [FloorCell, GoalCell])) then begin
           StatusBar1.Panels[7].Text := '遇到了错误的动作符号！- ' + ch;
           Break;
        end;
        if (map_Board_BK[pos1] = FloorCell) then
          map_Board_BK[pos1] := ManCell
        else
          map_Board_BK[pos1] := ManGoalCell;
      end;

      // 人的退回
      if (map_Board_BK[ManPos_BK] = ManCell) then
        map_Board_BK[ManPos_BK] := FloorCell
      else
        map_Board_BK[ManPos_BK] := GoalCell;

      Dec(MoveTimes_BK);                                                          // 移动步数

      Dec(UnDoPos_BK);
      Inc(ReDoPos_BK);
      RedoList_BK[ReDoPos_BK] := ch;
      ManPos_BK := pos1;                                                          // 人的新位置

      if (not mySettings.isIM) and (not isNoDelay) then DrawMap();                // 更新地图显示
      ShowStatusBar();
      StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos_BK mod curMapNode.Cols, ManPos_BK div curMapNode.Cols) + ' - [ ' + IntToStr((ManPos_BK mod curMapNode.Cols) + 1) + ', ' + IntToStr((ManPos_BK div curMapNode.Cols) + 1) + ' ]';       // 标尺

      Dec(Steps);
      if Steps > 0 then GameDelay();                                              // 延时

    end;

    StatusBar1.Repaint;

    if mySettings.isIM or isNoDelay then DrawMap();                               // 更新地图显示
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
  isNoDelay := false;                                                           // 是否为无延时动作 -- 至首、至尾功能用
  isKeyPush := false;                                                           // 是否正在演示中 -- 空格键和退格键控制的
  isMoving  := False;
end;

// 上一关
procedure Tmain.bt_PreClick(Sender: TObject);
var
  bt: LongWord;
  tmpMapNode : PMapNode;        // 关卡节点

begin
  if isMoving then IsStop := True
  else IsStop := False;

  if MapList.Count = 0 then begin
     StatusBar1.Panels[7].Text := '尚无打开的关卡！';
     Exit;
  end;

  pl_Ground.SetFocus;
  
  if curMap.CurrentLevel > 1 then
  begin
    if not mySettings.isLurd_Saved then
    begin    // 有新的动作尚未保存
      bt := MessageBox(Handle, '刚刚的推动尚未保存，是否保存？', '警告', MB_ICONWARNING + MB_YESNOCANCEL);
      if bt = idyes then begin
         SaveState();          // 保存状态到数据库
      end else if bt = idno then begin
         mySettings.isLurd_Saved := True;
         StatusBar1.Panels[7].Text := '动作已舍弃！';
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
      try
        tmpMapNode := QuicklyLoadMap(mySettings.MapFileName, curMap.CurrentLevel-1);
        if tmpMapNode.Map.Count > 2 then begin
           curMap.CurrentLevel := curMap.CurrentLevel-1;
           curMapNode := tmpMapNode;
           ReadQuicklyMap();
        end;
      except
      end;
      tmpMapNode := nil;
    end;
  end
  else
    StatusBar1.Panels[7].Text := '前面没有了!';
end;

// 下一关
procedure Tmain.bt_NextClick(Sender: TObject);
var
  bt: LongWord;
  tmpMapNode : PMapNode;        // 关卡节点
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if MapList.Count = 0 then begin
     StatusBar1.Panels[7].Text := '尚无打开的关卡！';
     Exit;
  end;

  pl_Ground.SetFocus;
  
  if not mySettings.isLurd_Saved then
  begin    // 有新的动作尚未保存
    bt := MessageBox(Handle, '刚刚的推动尚未保存，是否保存？', '警告', MB_ICONWARNING + MB_YESNOCANCEL);
    if bt = idyes then begin
       SaveState();          // 保存状态到数据库
    end else if bt = idno then begin
       mySettings.isLurd_Saved := True;
       StatusBar1.Panels[7].Text := '动作已舍弃！';
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
    end else StatusBar1.Panels[7].Text := '后面没有了...';
  end else begin
    try
       tmpMapNode := QuicklyLoadMap(mySettings.MapFileName, curMap.CurrentLevel+1);
       if tmpMapNode.Map.Count > 2 then begin
          curMap.CurrentLevel := curMap.CurrentLevel+1;
          curMapNode := tmpMapNode;
          ReadQuicklyMap();
       end else StatusBar1.Panels[7].Text := '后面没有了...';
    except
    end;
    tmpMapNode := nil;
  end;
end;

// UnDo 按钮
procedure Tmain.bt_UnDoClick(Sender: TObject);
begin
//  if isMoving then IsStop := True
//  else IsStop := False;

  N15.Click;
end;

// ReDo按钮
procedure Tmain.bt_ReDoClick(Sender: TObject);
begin
//  if isMoving then IsStop := True
//  else IsStop := False;

  N18.Click;
end;

// 穿越开关
procedure Tmain.bt_GoThroughClick(Sender: TObject);
begin
  mySettings.isGoThrough := not mySettings.isGoThrough;
  myPathFinder.setThroughable(mySettings.isGoThrough);
  SetButton();             // 设置按钮状态
end;

// 瞬移开关
procedure Tmain.bt_IMClick(Sender: TObject);
begin
  mySettings.isIM := not mySettings.isIM;
  SetButton();             // 设置按钮状态
end;

// 逆推模式开关
procedure Tmain.bt_BKClick(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;
  
  mySettings.isShowNoVisited := False;                                                           
  StatusBar1.Panels[7].Text := '';
  mySettings.isBK := not mySettings.isBK;
  DrawMap();
  SetButton();             // 设置按钮状态
  if (curMapNode <> nil) and (curMapNode.Cols > 0) then
  begin
    if mySettings.isBK then
    begin
      if ManPos_BK < 0 then
        StatusBar1.Panels[5].Text := ' '
      else
        StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos_BK mod curMapNode.Cols, ManPos_BK div curMapNode.Cols) + ' - [ ' + IntToStr(ManPos_BK mod curMapNode.Cols + 1) + ', ' + IntToStr(ManPos_BK div curMapNode.Cols + 1) + ' ]'       // 标尺
    end
    else
      StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos mod curMapNode.Cols, ManPos div curMapNode.Cols) + ' - [ ' + IntToStr(ManPos mod curMapNode.Cols + 1) + ', ' + IntToStr(ManPos div curMapNode.Cols + 1) + ' ]';       // 标尺
  end;
end;

// 加载关卡文档对话框
procedure Tmain.bt_OpenClick(Sender: TObject);
var
  bt: LongWord;
  i, size, n: Integer;
  fn: string;

begin
  if isMoving then IsStop := True
  else IsStop := False;

  // 加载地图文档的后台线程
  if LoadMapThread.isRunning then begin
     isStopThread := True;
  end;

  if not mySettings.isXSB_Saved then
  begin    // 有新的动作尚未保存
    bt := MessageBox(Handle, '当前关卡尚未保存，是否保存？', '警告', MB_ICONWARNING + MB_YESNOCANCEL);
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
  begin    // 有新的动作尚未保存
    bt := MessageBox(Handle, '刚刚的推动尚未保存，是否保存？', '警告', MB_ICONWARNING + MB_YESNOCANCEL);
    if bt = idyes then begin
       SaveState();          // 保存状态到数据库
    end else if bt = idno then begin
       mySettings.isLurd_Saved := True;
       StatusBar1.Panels[7].Text := '动作已舍弃！';
    end else exit;
  end;

  try

    if AnsiSameText(mySettings.MapFileName, 'BoxMan.xsb') and (mySettings.LaterList.Count > 0) then
       fn := mySettings.LaterList[0]
    else
       fn := mySettings.MapFileName;

    if Pos(':', fn) = 0 then fn := AppPath + fn;

    if (ExtractFilePath(fn) <> '') then
        MyOpenFile.DirectoryListBox1.Directory := ExtractFilePath(fn)
    else
        MyOpenFile.DirectoryListBox1.Directory := AppPath;
        
    MyOpenFile.DriveComboBox1.Drive := MyOpenFile.DirectoryListBox1.Directory[1];
  except
    MyOpenFile.DirectoryListBox1.Directory := AppPath;
    MyOpenFile.DriveComboBox1.Drive := MyOpenFile.DirectoryListBox1.Directory[1];
  end;

  MyOpenFile.FileListBox1.FileName := '';

  MyOpenFile.CheckBox1.Checked := False;    // 加载文档关卡时，是否同时导入答案

//  if OpenDialog1.Execute then begin
//  
//  end;

  if MyOpenFile.ShowModal = mrOk then begin

    if AnsiSameText(AppPath + mySettings.MapFileName, MyOpenFile.FileListBox1.FileName) then Exit;     // 当前文档，不需要重新打开

    isOnlyXSB := not MyOpenFile.CheckBox1.Checked;   // 控制在加载文档关卡时，是否同时导入答案

    if MyOpenFile.FileListBox1.FileName <> '' then begin

       curMapNode := QuicklyLoadMap(MyOpenFile.FileListBox1.FileName, 1);

       if (curMapNode <> nil) and (curMapNode.Map.Count  > 2) then begin

          curMap.CurrentLevel := 1;
          mySettings.MapFileName := MyOpenFile.FileListBox1.FileName;

          n := Pos(AppPath, mySettings.MapFileName);
          if n > 0 then Delete(mySettings.MapFileName, 1, Length(AppPath));

          ReadQuicklyMap();

          ResetSolvedLevel();
          mySettings.isXSB_Saved := True;
          // 创建后台线程，加载地图
          while LoadMapThread.isRunning do begin
             if not isStopThread then isStopThread := True;
          end;
          if LoadMapThread <> nil then FreeAndNil(LoadMapThread);
          LoadMapThread := TLoadMapThread.Create(False);

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
       end else StatusBar1.Panels[7].Text := '无效的关卡文档 - ' + MyOpenFile.FileListBox1.FileName;
    end;
  end;
end;

// 更换皮肤对话框
procedure Tmain.bt_SkinClick(Sender: TObject);
begin
  if LoadSkinForm.ShowModal = mrOK then
  begin
    mySettings.SkinFileName := LoadSkinForm.SkinFileName;
    if not LoadSkinForm.LoadSkin(AppPath + 'Skins\' + mySettings.SkinFileName) then
    begin
      LoadSkinForm.LoadDefaultSkin();         // 使用默认的简单皮肤
    end;
    DrawMap();
  end;
end;

// 显示奇偶特效
procedure Tmain.bt_OddEvenMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  mySettings.isOddEven := true;
  DrawMap();
end;

// 关闭奇偶特效
procedure Tmain.bt_OddEvenMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  mySettings.isOddEven := false;
  DrawMap();
end;

procedure Tmain.FormDestroy(Sender: TObject);
begin
  if myPathFinder <> nil then FreeAndNil(myPathFinder);
  if LoadMapThread <> nil then FreeAndNil(LoadMapThread);
  if mySettings.LaterList <> nil then FreeAndNil(mySettings.LaterList);

  if BrowseForm.Map_Icon <> nil then FreeAndNil(BrowseForm.Map_Icon);

  if MapList <> nil then begin                          // 地图列表
     MyListClear(MapList);
     FreeAndNil(MapList);         
  end;
  if SoltionList <> nil then begin                      // 答案列表
     MyListClear(SoltionList);
     FreeAndNil(SoltionList);
  end;
  if StateList <> nil then begin                        // 状态列表
     MyListClear(StateList);
     FreeAndNil(StateList);
  end;

  if MaskPic <> nil then FreeAndNil(MaskPic);         // 选择单元格掩图

end;

// 解析正推 reDo 动作节点 -- 每推一个箱子为一个动作
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

    // 寻找动作节点
  n := 0;  // 应该停在第几个动作上
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

    // 寻找动作节点
  n := 0;  // 应该停在第几个动作上
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

procedure Tmain.pnl_TrunMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;
    
    case Button of
      mbleft:
        begin     // 单击 -- 指左键
          if curMapNode.Trun < 7 then
            inc(curMapNode.Trun)
          else
            curMapNode.Trun := 0;    // 第 0 转
        end;
      mbright:
        begin    // 右击 -- 指右键
          if curMapNode.Trun > 0 then
            dec(curMapNode.Trun)
          else
            curMapNode.Trun := 7;    // 第 0 转
        end;
    end;
    SetMapTrun();
    curMapNode.Trun := curMapNode.Trun;
end;

procedure Tmain.SetMapTrun();
begin
  pnl_Trun.Caption := MapTrun[curMapNode.Trun];
  NewMapSize();
  DrawMap();       // 画地图
  case curMapNode.Trun of
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

procedure Tmain.pnl_SpeedMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  case Button of
    mbleft:
      begin     // 单击 -- 指左键
        if mySettings.mySpeed > 0 then
          dec(mySettings.mySpeed)
        else mySettings.mySpeed := 4;
      end;
    mbright:
      begin    // 右击 -- 指右键
        if mySettings.mySpeed < 4 then
          inc(mySettings.mySpeed)
        else mySettings.mySpeed := 0;
      end;
  end;
  pnl_Speed.Caption := SpeedInf[mySettings.mySpeed];
end;

// 保存关卡 XSB 到文档
function Tmain.SaveXSBToFile(): Boolean;
var
  myXSBFile: Textfile;
  myFileName, myExtName: string;
  i, j, size, n: Integer;
  mapNode: PMapNode;               // 关卡节点

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

    if not FileExists(myFileName) or (MessageBox(Handle, PChar(myFileName + #10 + ' 文档已经存在，覆写它吗？'), '警告', MB_ICONWARNING + MB_OKCANCEL) = idOK) then begin

      AssignFile(myXSBFile, myFileName);
      if AnsiSameText(myFileName, AppPath + 'BoxMan.xsb') and FileExists(myFileName) then Append(myXSBFile)   // 周转关卡库，以追加方式保存
      else ReWrite(myXSBFile);

      try
        for i := 0 to MapList.Count - 1 do
        begin
          mapNode := MapList.Items[i];

          Writeln(myXSBFile, '');
          for j := 0 to mapNode.Map.Count - 1 do
          begin
            Writeln(myXSBFile, mapNode.Map[j]);
          end;
          if Trim(mapNode.Title) <> '' then
            Writeln(myXSBFile, 'Title: ' + mapNode.Title);
          if Trim(mapNode.Author) <> '' then
            Writeln(myXSBFile, 'Author: ' + mapNode.Author);
          if Trim(mapNode.Comment) <> '' then
          begin
            Writeln(myXSBFile, 'Comment: ');
            Writeln(myXSBFile, mapNode.Comment);
            Writeln(myXSBFile, 'Comment_end: ');
          end;
        end;
      finally
        Closefile(myXSBFile);
      end;
    end;

    mySettings.MapFileName := myFileName;
    n := Pos(AppPath, mySettings.MapFileName);
    if n > 0 then Delete(mySettings.MapFileName, 1, Length(AppPath));

    mySettings.isXSB_Saved := True;            // 当从剪切板导入的 XSB 是否保存过了

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

    Caption := AppName + AppVer + ' - ' + ExtractFileName(ChangeFileExt(mySettings.MapFileName, EmptyStr)) + ' ~ [' + inttostr(curMap.CurrentLevel) + '/' + inttostr(MapList.Count) + ']';
    Result := True;
  end;
end;

// 打开选关界面
procedure Tmain.bt_ViewClick(Sender: TObject);
begin
  if MapList.Count = 0 then begin
     StatusBar1.Panels[7].Text := '关卡文档正在解析中...';
     Exit;
  end;

  if isMoving then IsStop := True
  else IsStop := False;

  BrowseForm.Tag := -1;        // 双击 item 时，赋值为 0
  BrowseForm.BK_Color := mySettings.bwBKColor;
  BrowseForm.curIndex := curMap.CurrentLevel-1;
  BrowseForm.ShowModal;
  mySettings.bwBKColor := BrowseForm.BK_Color;
  if BrowseForm.Tag < 0 then Exit;

  curMap.CurrentLevel := BrowseForm.ListView1.ItemIndex + 1;
  if LoadMap(curMap.CurrentLevel) then begin
    InitlizeMap();
    SetMapTrun();
  end;

end;

procedure Tmain.bt_ActClick(Sender: TObject);
var
  i, RepTimes, n: Integer;
  ch: Char;

begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (curMapNode = nil) or (curMapNode.Cols <= 0) then begin
     MessageBox(handle, '尚无打开的关卡！', '错误', MB_ICONERROR or MB_OK);
     Exit;
  end;

  // 参数传递 -- 是否逆推、默认路径
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
  
     RepTimes := ActionForm.Rep_Times.Value;          // 重复次数

     // 逆推时，需要处理人的初始位置
     if ActionForm.Run_CurPos.Checked then begin  // 从当前点执行
        if mySettings.isBK then begin
           if ManPos_BK < 0 then begin
              if (ActionForm.M_X < 0) or (ActionForm.M_Y < 0) or (ActionForm.M_X >= curMapNode.Cols) or (ActionForm.M_Y >= curMapNode.Rows) or
                 (not (map_Board_BK[ActionForm.M_Y * curMapNode.Cols + ActionForm.M_X] in [ FloorCell, GoalCell ])) then begin
                 MessageBox(handle, '人的初始位置不正确！', '错误', MB_ICONERROR or MB_OK);
                 Exit;
              end;

              // 新位置放上人 
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
                 MessageBox(handle, '人的初始位置不正确！', '错误', MB_ICONERROR or MB_OK);
                 Exit;
              end;
           end;

           // 加载的人的位置正确，先清理原来的人的位置
           if ManPos_BK >= 0 then begin
              if map_Board_BK[ManPos_BK] = ManCell then map_Board_BK[ManPos_BK] := FloorCell
              else map_Board_BK[ManPos_BK] := GoalCell;
           end;

           // 新位置放上人
           ManPos_BK := ActionForm.M_Y * curMapNode.Cols + ActionForm.M_X;
           ManPos_BK_0 := ManPos_BK;
           if map_Board_BK[ManPos_BK] = FloorCell then map_Board_BK[ManPos_BK] := ManCell
           else map_Board_BK[ManPos_BK] := ManGoalCell;
        end;
     end;

     GetLurd(ActionForm.Act, mySettings.isBK);

     // 按现场旋转转换 redo 中的动作
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
     // 执行次数
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

procedure Tmain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  bt: LongWord;
begin
  if isMoving then begin
     IsStop := True;
     CanClose := False;
     Exit;
  end;

  CanClose := True;

  if not mySettings.isXSB_Saved then
  begin    // 有新的XSB尚未保存
    bt := MessageBox(Handle, '当前关卡尚未保存，是否保存？', '警告', MB_ICONWARNING + MB_YESNOCANCEL);
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
  begin    // 有新的动作尚未保存
    bt := MessageBox(Handle, '刚刚的推动尚未保存，是否保存？', '警告', MB_ICONWARNING + MB_YESNOCANCEL);
    if bt = idyes then
    begin
      mySettings.isLurd_Saved := True;
      SaveState();          // 保存状态到数据库
    end
    else if bt = idno then
    begin
      mySettings.isLurd_Saved := True;
    end
    else
      CanClose := False;
  end;
end;

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

// 正推目标位切换
procedure Tmain.pmGoalClick(Sender: TObject);
begin
  isSelectMod := False;
  mySettings.isSameGoal := not mySettings.isSameGoal;
  if mySettings.isSameGoal then
    pmGoal.Checked := True
  else
    pmGoal.Checked := False;
  DrawMap();                                  // 更新地图显示
  ShowStatusBar();
end;

// 即景目标位切换
procedure Tmain.pmJijingClick(Sender: TObject);
begin
  isSelectMod := False;

  mySettings.isJijing := not mySettings.isJijing;
  if mySettings.isJijing then
    pmJijing.Checked := True
  else
    pmJijing.Checked := False;

  DrawMap();                                  // 更新地图显示
  ShowStatusBar();
end;

// 双击答案列表加载答案
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
    begin    // 有新的动作尚未保存
      i := MessageBox(Handle, '刚刚的推动尚未保存，是否保存？', '警告', MB_ICONWARNING + MB_YESNOCANCEL);
      if i = idyes then begin
         SaveState();          // 保存状态到数据库
         PageControl.ActivePageIndex := 0;
      end else if i = idno then begin
         mySettings.isLurd_Saved := True;
         StatusBar1.Panels[7].Text := '动作已舍弃！';
      end else exit;
    end;

    if GetSolutionFromDB(List_Solution.ItemIndex, s) then begin

       len := Length(s);

       if len > 0 then begin
           Restart(False);

           // 答案送入正推的 RedoList
           ReDoPos := 0;
           for i := len downto 1 do begin
               if ReDoPos = MaxLenPath then Exit;
               inc(ReDoPos);
               RedoList[ReDoPos] := s[i];
           end;
           curMap.isFinish := True;
       end;
       StatusBar1.Panels[7].Text := '答案已载入！';
       StatusBar1.Repaint;
    end;
end;

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
    begin    // 有新的动作尚未保存
      i := MessageBox(Handle, '刚刚的推动尚未保存，是否保存？', '警告', MB_ICONWARNING + MB_YESNOCANCEL);
      if i = idyes then begin
         actNode := StateList[n];
         id := actNode.id;
         SaveState();          // 保存状态到数据库
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
         StatusBar1.Panels[7].Text := '动作已舍弃！';
      end else exit;
    end;

    if GetStateFromDB(n, x, y, s1, s2) then begin
  
       Restart(False);                 // 关卡复位
       Restart(True);                  // 关卡复位

       len := Length(s1);

       // 状态送入 RedoList
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

       // 状态送入 RedoList_BK
       if (len > 0) and (x > 0) and (y > 0) and (x <= curMapNode.Cols) and ( y <= curMapNode.Rows) then begin

           if ManPos_BK >= 0 then begin
              if map_Board_BK[ManPos_BK] = ManCell then map_Board_BK[ManPos_BK] := FloorCell
              else if map_Board_BK[ManPos_BK] = ManGoalCell then map_Board_BK[ManPos_BK] := GoalCell
              else begin
                StatusBar1.Panels[7].Text := '关卡现场数据遇到错误！';
                Exit;
              end;
           end;

           ManPos_BK := (y-1) * curMapNode.Cols + x-1;

           if map_Board_BK[ManPos_BK] = FloorCell then map_Board_BK[ManPos_BK] := ManCell
           else if map_Board_BK[ManPos_BK] = GoalCell then map_Board_BK[ManPos_BK] := ManGoalCell
           else begin
             StatusBar1.Panels[7].Text := '状态数据不正确！';
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
       StatusBar1.Panels[7].Text := '状态已载入！';
       StatusBar1.Repaint;
    end;
end;

// 加载一条状态
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
           str1 := sltb.FieldAsString(sltb.FieldIndex['Act_Text']);      // 读取状态
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
    StatusBar1.Panels[7].Text := '状态库出错，状态未能正确加载！';
  end;

  Result := True;
end;

// 从答案库加载一条答案
function Tmain.GetSolutionFromDB(index: Integer; var str: string): Boolean;
var
  sldb: TSQLiteDatabase;
  sltb: TSQLIteTable;
  sSQL: String;
  solNode: ^TSoltionNode;

begin
    Result := False;

    if index < 0 then Exit;

    sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));

    try
      try
        solNode := SoltionList[index];

        sSQL := 'select Sol_Text from Tab_Solution where id = ' + IntToStr(solNode.id);

        sltb := slDb.GetTable(sSQL);
        
        try
           if sltb.Count > 0 then begin
             sltb.MoveFirst;
             str := sltb.FieldAsString(sltb.FieldIndex['Sol_Text']);     // 读取答案
           end;
        Finally
           sltb.Free;
        end;
      finally
        sldb.Free;
        solNode := nil;
      end;
    except
      StatusBar1.Panels[7].Text := '答案库出错，答案未能正确加载！';
    end;

    Result := True;
end;

// 状态 -- 正推 Lurd 到剪切板
procedure Tmain.sa_LurdClick(Sender: TObject);
var
  s1, s2: string;
  len, x, y: Integer;
  
begin
   if GetStateFromDB(List_State.ItemIndex, x, y, s1, s2) then begin
      len := Length(s1);
      if len > 0 then begin
         Clipboard.SetTextBuf(PChar(s1));
         StatusBar1.Panels[7].Text := '正推 Lurd 到剪切板！';
      end else StatusBar1.Panels[7].Text := '加载正推 Lurd 失败！';
   end;
end;

// 状态 -- 逆推 Lurd 到剪切板
procedure Tmain.sa_Lurd_BKClick(Sender: TObject);
var
  s1, s2: string;
  len, x, y: Integer;

begin
   if GetStateFromDB(List_State.ItemIndex, x, y, s1, s2) then begin
      len := Length(s2);
      if (len > 0) and (x > 0) and (y > 0) then begin
         Clipboard.SetTextBuf(PChar('[' + IntToStr(x) + ', ' + IntToStr(y) + ']' + s2));
         StatusBar1.Panels[7].Text := '逆推 Lurd 到剪切板！';
      end else StatusBar1.Panels[7].Text := '加载逆推 Lurd 失败！';
   end;
end;

// 状态 -- XSB + Lurd 到剪切板
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

      StatusBar1.Panels[7].Text := 'XSB + Lurd 到剪切板！';
   end;
end;

// 状态 -- XSB + Lurd 到文档
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

    if not FileExists(myFileName) or (MessageBox(Handle, PChar(myFileName + #10 + ' 文档已经存在，覆写它吗？'), '警告', MB_ICONWARNING + MB_OKCANCEL) = idOK) then begin
      AssignFile(myXSBFile, myFileName);
      ReWrite(myXSBFile);

      try
        Write(myXSBFile, GetXSB(curMapNode));

        if GetStateFromDB(List_State.ItemIndex, x, y, s1, s2) then begin

          len := Length(s1);
          if len > 0 then Write(myXSBFile, s1 + #10);

          len := Length(s2);
          if (len > 0) and (x > 0) and (y > 0) then Write(myXSBFile, PChar('[' + IntToStr(x) + ', ' + IntToStr(y) + ']' + s2 + #10));

          StatusBar1.Panels[7].Text := 'XSB + Lurd 到文档！';
        end;
      finally
        Closefile(myXSBFile);
      end;
    end;
  end;
end;

// 状态 -- 删除一条
procedure Tmain.sa_DeleteClick(Sender: TObject);
var
  sldb: TSQLiteDatabase;
  sSQL: String;
  actNode: ^TStateNode;

begin
  if List_State.ItemIndex < 0 then Exit;

  if MessageBox(Handle, '删除选中的状态，确定吗？', '警告', MB_ICONWARNING + MB_OKCANCEL) <> idOK then Exit;

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
    MessageBox(handle, '状态库出错，' + #10 + '未能正确删除状态！', '错误', MB_ICONERROR or MB_OK);
  end;
end;

// 状态 -- 删除全部
procedure Tmain.sa_DeleteAllClick(Sender: TObject);
var
  sldb: TSQLiteDatabase;
  sSQL: String;
  i, len: Integer;
  actNode: ^TStateNode;
  s: string;
  
begin
  if MessageBox(Handle, '删除全部的状态，确定吗？', '警告', MB_ICONWARNING + MB_OKCANCEL) <> idOK then Exit;

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

//      StateList.Clear;
      MyListClear(StateList);
      List_State.Clear;
    finally
      sldb.Free;
      actNode := nil;
    end;
  except
    MessageBox(handle, '状态库出错，' + #10 + '未能正确删除状态！', '错误', MB_ICONERROR or MB_OK);
  end;
end;

// 清理状态 -- 非本关卡的全部状态
procedure Tmain.sa_ClraeAllClick(Sender: TObject);
var
  sldb: TSQLiteDatabase;
  sSQL: String;
  i, len: Integer;
  actNode: ^TStateNode;
  s: string;
  
begin
  if MessageBox(Handle, '清理非本关卡的全部状态，确定吗？', '警告', MB_ICONWARNING + MB_OKCANCEL) <> idOK then Exit;

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
    MessageBox(handle, '状态库出错，' + #10 + '未能正确清理状态！', '错误', MB_ICONERROR or MB_OK);
  end;
end;

// 答案 -- Lurd 到剪切板
procedure Tmain.so_LurdClick(Sender: TObject);
var
  s1: string;
  len: Integer;

begin
   if GetSolutionFromDB(List_Solution.ItemIndex, s1) then begin
      len := Length(s1);
      if len > 0 then begin
         Clipboard.SetTextBuf(PChar(s1));
         StatusBar1.Panels[7].Text := 'Lurd 到剪切板！';
      end else StatusBar1.Panels[7].Text := '加载 Lurd 失败！';
   end;
end;

// 答案 -- XSB + Lurd 到剪切板
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
         StatusBar1.Panels[7].Text := 'XSB + Lurd 到剪切板！';
         solNode := nil;
      end else StatusBar1.Panels[7].Text := 'XSB + Lurd 到剪切板失败！';
   end;
end;

// 答案 -- XSB + Lurd_All 到剪切板
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
   StatusBar1.Panels[7].Text := 'XSB + Lurd_All 到剪切板！';
   solNode := nil;
end;

// 答案 -- XSB + Lurd 到文档
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

    if not FileExists(myFileName) or (MessageBox(Handle, PChar(myFileName + #10 + ' 文档已经存在，覆写它吗？'), '警告', MB_ICONWARNING + MB_OKCANCEL) = idOK) then begin
      if GetSolutionFromDB(List_Solution.ItemIndex, s1) then begin

        len := Length(s1);

        if len > 0 then begin
           AssignFile(myXSBFile, myFileName);
           ReWrite(myXSBFile);

           Write(myXSBFile, GetXSB(curMapNode));

           solNode := SoltionList.items[List_Solution.ItemIndex];
           Write(myXSBFile, 'Solution (Moves: ' + IntToStr(solNode.Moves) + ', Pushs: ' + IntToStr(solNode.Pushs) + '): ' + s1 + #10);
           StatusBar1.Panels[7].Text := 'XSB + Lurd 到文档！';
           Closefile(myXSBFile);
           solNode := nil;
        end else StatusBar1.Panels[7].Text := '保存 XSB + Lurd 到文档失败！';
      end;
    end;
  end;
end;

// 导出当前关卡及其所有答案
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

    if not FileExists(myFileName) or (MessageBox(Handle, PChar(myFileName + #10 + ' 文档已经存在，覆写它吗？'), '警告', MB_ICONWARNING + MB_OKCANCEL) = idOK) then begin

      AssignFile(myXSBFile, myFileName);
      ReWrite(myXSBFile);

      try
        Write(myXSBFile, GetXSB(curMapNode));

        len0 := List_Solution.Count;
        for i := 0 to len0-1 do begin
           if GetSolutionFromDB(i, s1) then begin
              len := Length(s1);
              if len > 0 then begin
                 solNode := SoltionList.items[i];
                 Write(myXSBFile, 'Solution (Moves: ' + IntToStr(solNode.Moves) + ', Pushs: ' + IntToStr(solNode.Pushs) + '): ' + s1 + #10);
              end;
           end;
        end;

        solNode := nil;
        StatusBar1.Panels[7].Text := 'XSB + Lurd_All 到文档！';
      finally
        Closefile(myXSBFile);
      end;
    end;
  end;
end;

// 导出全部关卡及其答案
procedure Tmain.so_XSBAll_LurdAll1_FileClick(Sender: TObject);
var
  myXSBFile: Textfile;
  myFileName, myExtName, str: string;
  size, n: Integer;
  solNode: ^TSoltionNode;
  mapNode: PMapNode;

begin
  if MapList.Count = 0 then begin
     StatusBar1.Panels[7].Text := '正在解析关卡文档，请稍后再试！';
     Exit;
  end;

  dlgSave1.InitialDir := AppPath;
  dlgSave1.FileName := '';

  if dlgSave1.Execute then begin
    myFileName := dlgSave1.FileName;

    myExtName := ExtractFileExt(myFileName);

    if (myExtName = '') or (myExtName = '.') then
       myFileName := changefileext(myFileName, '.txt');

    if not FileExists(myFileName) or (MessageBox(Handle, PChar(myFileName + #10 + ' 文档已经存在，覆写它吗？'), '警告', MB_ICONWARNING + MB_OKCANCEL) = idOK) then begin

      AssignFile(myXSBFile, myFileName);
      ReWrite(myXSBFile);

      try
        size := MapList.Count;
        for n := 0 to size-1 do begin
            StatusBar1.Panels[7].Text := '导出：' + IntToStr(n+1) + '/' + IntToStr(size);
            mapNode := MapList[n];
            Write(myXSBFile, GetXSB(mapNode));

            str := GetSolution(mapNode);
            Write(myXSBFile, str);
        end;

        solNode := nil;
        StatusBar1.Panels[7].Text := '导出全部关卡及答案！';
      finally
        Closefile(myXSBFile);
      end;
    end;
  end;
end;

// 答案 -- 删除一条
procedure Tmain.so_DeleteClick(Sender: TObject);
var
  sldb: TSQLiteDatabase;
  sSQL: String;
  solNode: ^TSoltionNode;

begin
  if List_Solution.ItemIndex < 0 then Exit;

  if MessageBox(Handle, '删除选中的答案，确定吗？', '警告', MB_ICONWARNING + MB_OKCANCEL) <> idOK then Exit;

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
    MessageBox(handle, '答案库出错，' + #10 + '未能正确删除答案！', '错误', MB_ICONERROR or MB_OK);
  end;
  curMapNode.Solved := SoltionList.Count > 0;
end;

// 答案 -- 删除全部
procedure Tmain.so_DeleteAllClick(Sender: TObject);
var
  sldb: TSQLiteDatabase;
  sSQL: String;
  i, len: Integer;
  solNode: ^TSoltionNode;
  s: string;
  
begin

  if MessageBox(Handle, '删除全部的答案，确定吗？', '警告', MB_ICONWARNING + MB_OKCANCEL) <> idOK then Exit;

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

//      SoltionList.Clear;
      MyListClear(SoltionList);
      List_Solution.Clear;
    finally
      sldb.Free;
      solNode := nil;
    end;
  except
    MessageBox(handle, '答案库出错，' + #10 + '未能正确删除答案！', '错误', MB_ICONERROR or MB_OK);
  end;
  curMapNode.Solved := False;
end;

// 双击状态栏最右边的一栏 -- 动作进度
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
     per := (mpt.x - gotoLeft) / gotoWidth;        // goto 的位置
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

// 状态栏 - 信息栏控制
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
         StatusBar.Canvas.Brush.Color := clMoneyGreen;        // 底色
         StatusBar.Canvas.FillRect(R0);
         StatusBar.Canvas.Brush.Color := clTeal;              // 底色
         StatusBar.Canvas.FillRect(R1);
     end;

     if mySettings.isBK and (UnDoPos_BK > 0) or (not mySettings.isBK) and (UnDoPos > 0) then begin
        StatusBar.Canvas.Brush.Color := clTeal;               // 底色
     end else begin
        StatusBar.Canvas.Brush.Color := clMoneyGreen;         // 底色
     end;
     StatusBar.Canvas.Font.Color  := clBlack;                 // 字体颜色
     StatusBar.Canvas.TextOut(Rt.Left, Rt.Top, Panel.Text);
  end;
end;

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

procedure Tmain.FormShow(Sender: TObject);
begin
  // 关卡浏览窗口的位置及大小
  BrowseForm.Top := mySettings.bwTop;
  BrowseForm.Left := mySettings.bwLeft;
  BrowseForm.Width := mySettings.bwWidth;
  BrowseForm.Height := mySettings.bwHeight;

  // 左侧边栏
  if mySettings.isLeftBar then begin
     pl_Side.Visible := True;
     bt_LeftBar.Caption := '<';
  end else begin
     pl_Side.Visible := False;
     bt_LeftBar.Caption := '>';
  end;
  NewMapSize();
  DrawMap();        // 画地图
  pl_Ground.SetFocus;
end;

procedure Delay(msecs: dword);
var
  FirstTickCount: dword;
  
begin
  FirstTickCount := GetTickCount;
  while GetTickCount-FirstTickCount < msecs do Application.ProcessMessages;
end;

procedure Tmain.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if isMoving then IsStop := True
  else N15.Click;          // z，撤销
  Handled := True;
  Delay(10);
end;

procedure Tmain.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if isMoving then IsStop := True
  else N18.Click;          // x，重做
  Handled := True;
  Delay(10);
end;

// GET 请求
function MyGetMatch: string;
var
  IdHttp : TIdHTTP;
  Url : string;                   // 请求地址
  ResponseStream : TStringStream; // 返回信息
  ResponseStr : string;
  
begin
  // 创建IDHTTP控件
  IdHttp := TIdHTTP.Create(nil);

  // TStringStream对象用于保存响应信息
  ResponseStream := TStringStream.Create('');

  try
    // 请求地址
    Url := 'http://sokoban.ws/api/competition/';
    try
      IdHttp.Get(Url, ResponseStream);
    except
//      on e : Exception do
//      begin
//        ShowMessage(e.Message);
//      end;
    end;

    // 获取网页返回的信息
    ResponseStr := ResponseStream.DataString;

    // 网页中的存在中文时，需要进行UTF8解码
    ResponseStr := UTF8Decode(ResponseStr);

  finally
    IdHttp.Free;
    ResponseStream.Free;
  end;

  Result := ResponseStr;
end;

// 相应最近打开的关卡集文档菜单项的单击事件
procedure Tmain.MenuItemClick(Sender: TObject);
var
  fn: string;
  i, size, n: Integer;
  // 解析 Json
  jRet, jLevel: ISuperObject;
  strBegin, strEnd, strLevel, level, author, title, str: string;
  id: integer;

begin
   if not mySettings.isXSB_Saved then
   begin    // 有新的XSB尚未保存
      i := MessageBox(Handle, '当前关卡尚未保存，是否保存？', '警告', MB_ICONWARNING + MB_YESNOCANCEL);
      if i = idyes then begin
        SaveXSBToFile();
      end else if i = idno then begin
        mySettings.isXSB_Saved := False;
      end else Exit;
   end;

   if not mySettings.isLurd_Saved then
   begin    // 有新的动作尚未保存
      i := MessageBox(Handle, '刚刚的推动尚未保存，是否保存？', '警告', MB_ICONWARNING + MB_YESNOCANCEL);
      if i = idyes then begin
        mySettings.isLurd_Saved := True;
        SaveState();          // 保存状态到数据库
      end else if i = idno then begin
        mySettings.isLurd_Saved := True;
        StatusBar1.Panels[7].Text := '动作已舍弃！';
      end else exit;
   end;

  fn := TmenuItem(sender).caption;
  if fn = '提取比赛关卡' then begin

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

        if LoadMapsFromText(str) then begin               // 从字符串文本导入 XSB
          if MapList.Count > 0 then begin   // 解析到了有效关卡，自动打开第一个关卡
            mySettings.MapFileName := '';
            if LoadMap(1) then begin
              curMapNode.Trun := 0;    // 默认关卡第 0 转
              SetMapTrun();
              InitlizeMap();
              mySettings.isXSB_Saved := False;              // 当从剪切板导入的 XSB 是否保存过了
              mySettings.isLurd_Saved := True;              // 推关卡的动作是否保存过了
              Caption := AppName + AppVer + ' - 比赛关卡 ~ [' + inttostr(curMap.CurrentLevel) + '/' + inttostr(MapList.Count) + ']';
              StatusBar1.Panels[7].Text := '第' + inttostr(id) + '期比赛，' + strBegin + ' 至 ' + strEnd;
            end;
          end;
        end
        else StatusBar1.Panels[7].Text := '提取比赛关卡失败！';

     end else StatusBar1.Panels[7].Text := '没有提取到比赛关卡！';
  end
  else begin

    if fn = '关卡周转库(BoxMan.xsb)' then fn := 'BoxMan.xsb'
    else if AnsiSameText(fn, AppPath + mySettings.MapFileName) then Exit;

    if Pos(':', fn) = 0 then fn := AppPath + fn;

    if FileExists(fn) then begin

      // 快速打开第一个地图
      curMapNode := QuicklyLoadMap(fn, 1);

      if curMapNode.Map.Count > 2 then begin

          mySettings.MapFileName := fn;
          n := Pos(AppPath, mySettings.MapFileName);
          if n > 0 then Delete(mySettings.MapFileName, 1, Length(AppPath));
          curMap.CurrentLevel := 1;

          if not AnsiSameText(mySettings.MapFileName, 'BoxMan.xsb') then begin
             // 调整最近打开的文档的顺序
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

          isOnlyXSB := True;   // 控制在加载文档关卡时，是否同时导入答案
          
          ResetSolvedLevel();
          // 创建后台线程，加载地图
          while LoadMapThread.isRunning do begin
             if not isStopThread then isStopThread := True;
          end;
          if LoadMapThread <> nil then FreeAndNil(LoadMapThread);
          LoadMapThread := TLoadMapThread.Create(False);

          StatusBar1.Panels[7].Text := '';
      end else StatusBar1.Panels[7].Text := '无效的关卡文档 - ' + fn;
    end else StatusBar1.Panels[7].Text := '该文档已丢失 - ' + fn;
  end;
end;

// 最近打开的关卡集文档 -- 自动生成菜单项
procedure Tmain.bt_LatelyClick(Sender: TObject);
var
  i, size: Integer;
  ItemL1: TMenuItem;

begin
  if isMoving then IsStop := True
  else IsStop := False;

  // 加载地图文档的后台线程
  if LoadMapThread.isRunning then begin
     isStopThread := True;
  end;

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
  ItemL1.Caption := '关卡周转库(BoxMan.xsb)';
  ItemL1.OnClick := MenuItemClick;
  pm_Later.Items.Add(ItemL1);
  ItemL1 := TMenuItem.Create(Nil);
  ItemL1.Caption := '提取比赛关卡';
  ItemL1.OnClick := MenuItemClick;
  pm_Later.Items.Add(ItemL1);

  pm_Later.Popup(mouse.CursorPos.X,mouse.CursorPos.y);
//  SetCursorPos(Left + 60, Top + 55);
//  mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
//  mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
end;

procedure Tmain.bt_SaveClick(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  isKeyPush := False;
  
  if mySettings.isXSB_Saved then begin
    SaveState();                                   // 保存状态到数据库
  end else begin
    if SaveXSBToFile() then SaveState();           // 保存关卡 XSB 到文档，状态到数据库
  end;
end;

procedure Tmain.pm_HomeClick(Sender: TObject);
begin
  N16.Click;
end;

procedure Tmain.N1Click(Sender: TObject);
var
   len: Integer;

begin
   if GetSolutionFromDB(List_Solution.ItemIndex, MySubmit.SubmitLurd) then begin   // 提交--Lurd
      len := Length(MySubmit.SubmitLurd);
      if len > 0 then begin
          MySubmit.SubmitCountry := mySettings.SubmitCountry;       // 提交--国家或地区
          MySubmit.SubmitName    := mySettings.SubmitName;          // 提交--姓名
          MySubmit.SubmitEmail   := mySettings.SubmitEmail;         // 提交--邮箱
          if MySubmit.ShowModal = mrOK then begin
             mySettings.SubmitCountry := MySubmit.SubmitCountry;       // 提交--国家或地区
             mySettings.SubmitName    := MySubmit.SubmitName;          // 提交--姓名
             mySettings.SubmitEmail   := MySubmit.SubmitEmail;         // 提交--邮箱
             StatusBar1.Panels[7].Text := MySubmit.Caption;            // 提交结果
          end;
      end else StatusBar1.Panels[7].Text := '加载答案失败！';
   end else StatusBar1.Panels[7].Text := '请先选择需要提交的答案！';
end;

procedure Tmain.N2Click(Sender: TObject);
begin
  ShowSolutuionList.Show;
//  ShellExecute(handle,nil,pchar('http://sokoban.cn/solution_table.php'),nil,nil,SW_shownormal);
end;

// 导出 xsb 现场 -- 剪切板
procedure Tmain.XSB4Click(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  StatusBar1.Panels[7].Text := '';
  
  if curMapNode = nil then Exit;

  XSBToClipboard_2();
  StatusBar1.Panels[7].Text := '现场 XSB 已送入剪切板！';
end;

// 导出关卡xsb和已做动作 -- 剪切板
procedure Tmain.XSB2Click(Sender: TObject);
var
  str: string;
  r, c: Integer;
  
begin
  if isMoving then IsStop := True
  else IsStop := False;

  StatusBar1.Panels[7].Text := '';

  if curMapNode = nil then Exit;

  // 关卡 XSB
  str := GetXSB(curMapNode);

  // 正推动作
  if UnDoPos > 0 then begin
     if UnDoPos < MaxLenPath then UndoList[UnDoPos+1] := #0;
     str := str + PChar(@UndoList) + #10;
  end;

  // 逆推动作
  if (ManPos_BK >= 0) and (UnDoPos_BK > 0) then begin
    c := ManPos_BK mod curMapNode.Cols + 1;
    r := ManPos_BK div curMapNode.Cols + 1;

    if UnDoPos_BK < MaxLenPath then UndoList_BK[UnDoPos_BK+1] := #0;
    str := str + '[' + IntToStr(c) + ', ' + IntToStr(r) + ']' + PChar(@UndoList_BK) + #10;
  end;

  // 送入剪切板
  Clipboard.SetTextBuf(PChar(str));

  StatusBar1.Panels[7].Text := '关卡和已做动作(XSB + Lurd)已送入剪切板！';
end;

// 导入关卡 xsb -- 剪切板
procedure Tmain.XSB1Click(Sender: TObject);
var
  i: Integer;
  
begin
  if isMoving then IsStop := True
  else IsStop := False;

  StatusBar1.Panels[7].Text := '';
  if not mySettings.isXSB_Saved then
  begin    // 有新的XSB尚未保存
    i := MessageBox(Handle, '当前关卡尚未保存，是否保存？', '警告', MB_ICONWARNING + MB_YESNOCANCEL);
    if i = idyes then begin
      SaveXSBToFile();
    end else if i = idno then begin
      mySettings.isXSB_Saved := False;
    end else Exit;
  end;

  if not mySettings.isLurd_Saved then
  begin    // 有新的动作尚未保存
    i := MessageBox(Handle, '刚刚的推动尚未保存，是否保存？', '警告', MB_ICONWARNING + MB_YESNOCANCEL);
    if i = idyes then begin
      mySettings.isLurd_Saved := True;
      SaveState();          // 保存状态到数据库
    end else if i = idno then begin
      mySettings.isLurd_Saved := True;
      StatusBar1.Panels[7].Text := '未保存新动作！';
    end else exit;
  end;

  if LoadMapsFromText('') then begin               // 剪切板导入 XSB
    if MapList.Count > 0 then begin   // 解析到了有效关卡，自动打开第一个关卡
      mySettings.MapFileName := '';
      if LoadMap(1) then begin
//          DataModule1.ADOQuery2.Close;
        InitlizeMap();
        curMapNode.Trun := 0;    // 默认关卡第 0 转
        SetMapTrun();
        mySettings.isXSB_Saved := False;              // 当从剪切板导入的 XSB 是否保存过了
        mySettings.isLurd_Saved := True;              // 推关卡的动作是否保存过了
        Caption := AppName + AppVer + ' - 剪切板 ~ [' + inttostr(curMap.CurrentLevel) + '/' + inttostr(MapList.Count) + ']';
        StatusBar1.Panels[7].Text := '从剪切板加载关卡 XSB 成功！';
      end;
    end;
  end
  else StatusBar1.Panels[7].Text := '加载剪切板中的关卡 XSB 失败！';
end;

// 窗口最小化和失去焦点的时候，停止动画
procedure Tmain.ApplicationEvents1Minimize(Sender: TObject);
begin
  if isMoving then IsStop := True;
end;

// 最后一关
procedure Tmain.N10Click(Sender: TObject);
var
  n: Integer;
  tmpMapNode : PMapNode;        // 关卡节点
  
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if not mySettings.isLurd_Saved then
  begin    // 有新的动作尚未保存
    n := MessageBox(Handle, '刚刚的推动尚未保存，是否保存？', '警告', MB_ICONWARNING + MB_YESNOCANCEL);
    if n = idyes then begin
       SaveState();          // 保存状态到数据库
    end else if n = idno then begin
       mySettings.isLurd_Saved := True;
       StatusBar1.Panels[7].Text := '动作已舍弃！';
    end else exit;
  end;

  if MapList.Count > 0 then begin
     if curMap.CurrentLevel < MapList.Count then begin
        curMap.CurrentLevel := MapList.Count;
        if LoadMap(curMap.CurrentLevel) then
        begin
          InitlizeMap();
          SetMapTrun();
        end;
     end else StatusBar1.Panels[7].Text := '后面没有了!';
  end else begin
    // 侦查文档最后一个关卡的序号，超过9999个关卡的，仅仅取其第9999个关卡
    tmpMapNode := QuicklyLoadMap(mySettings.MapFileName, 10000);     // 取得最后一个关卡的序号
    if tmpMapNode.Map.Count = 0 then n := tmpMapNode.Num
    else n := 9999;

    if n > curMap.CurrentLevel then begin
       tmpMapNode := QuicklyLoadMap(mySettings.MapFileName, n);
       curMap.CurrentLevel := n;
       curMapNode := tmpMapNode;
       ReadQuicklyMap();
    end else StatusBar1.Panels[7].Text := '后面没有了!';
  end;
  tmpMapNode := nil;
end;

// 第一关
procedure Tmain.N8Click(Sender: TObject);
var
  bt: Integer;
  tmpMapNode : PMapNode;        // 关卡节点

begin
  if isMoving then IsStop := True
  else IsStop := False;

  if curMap.CurrentLevel > 1 then
  begin
    if not mySettings.isLurd_Saved then
    begin    // 有新的动作尚未保存
      bt := MessageBox(Handle, '刚刚的推动尚未保存，是否保存？', '警告', MB_ICONWARNING + MB_YESNOCANCEL);
      if bt = idyes then begin
         SaveState();          // 保存状态到数据库
      end else if bt = idno then begin
         mySettings.isLurd_Saved := True;
         StatusBar1.Panels[7].Text := '动作已舍弃！';
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
      try
        tmpMapNode := QuicklyLoadMap(mySettings.MapFileName, 1);
        if tmpMapNode.Map.Count > 2 then begin
           curMap.CurrentLevel := 1;
           curMapNode := tmpMapNode;
           ReadQuicklyMap();
        end;
      except
      end;
      tmpMapNode := nil;
    end;
  end
  else StatusBar1.Panels[7].Text := '前面没有了!';
end;

// 上一关未解关卡
procedure Tmain.N9Click(Sender: TObject);
var
  i: Integer;
  mNode: PMapNode;
  s: string;

begin
  if isMoving then IsStop := True
  else IsStop := False;

  if MapList.Count = 0 then begin
     StatusBar1.Panels[7].Text := '关卡文档正在解析中...';
     Exit;
  end;
  
  s := '前面没有找到未解关卡!';
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
      s := '上一关未解关卡！';
    end;
  end;
  StatusBar1.Panels[7].Text := s;

end;

// 下一关未解关卡
procedure Tmain.N11Click(Sender: TObject);
var
  i: Integer;
  mNode: PMapNode;
  s: string;
  
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if MapList.Count = 0 then begin
     StatusBar1.Panels[7].Text := '关卡文档正在解析中...';
     Exit;
  end;

  s := '后面没有找到未解关卡!';
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
      s := '下一关未解关卡！';
    end;
  end;
  StatusBar1.Panels[7].Text := s;
end;

// 按钮上右键按下时，停止动画
procedure Tmain.N15Click(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;
  
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
    LastSteps := -1;              // 正推最后一次点推前的步数
  end;
end;

procedure Tmain.N18Click(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;
  
  if mySettings.isBK then
    ReDo_BK(GetStep2(mySettings.isBK))
  else
    ReDo(GetStep(mySettings.isBK));
end;

procedure Tmain.N14Click(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;
  
  if mySettings.isBK then UnDo_BK(1)
  else UnDo(1);
end;

procedure Tmain.N17Click(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;
  
  if mySettings.isBK then ReDo_BK(1)
  else ReDo(1);
end;

procedure Tmain.N16Click(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;
  
  isNoDelay := True;
  if mySettings.isBK then UnDo_BK(UnDoPos_BK)
  else UnDo(UnDoPos);
  isNoDelay := false;
  StatusBar1.Panels[7].Text := '已至首！';
end;

procedure Tmain.N19Click(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;
  
  isNoDelay := True;
  if mySettings.isBK then ReDo_BK(ReDoPos_BK)
  else ReDo(ReDoPos);
  isNoDelay := false;
  StatusBar1.Panels[7].Text := '已至尾！';
end;

procedure Tmain.N21Click(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;

  isKeyPush := True;
  if mySettings.isBK then begin
    UnDo_BK(UnDoPos_BK);
  end else begin
    UnDo(UnDoPos);
  end;
end;

procedure Tmain.N22Click(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;

  isKeyPush := True;
  if mySettings.isBK then begin
    ReDo_BK(ReDoPos_BK);
  end else begin
    ReDo(ReDoPos);
  end;
end;

procedure Tmain.bt_PreMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if isMoving then IsStop := True;
end;

procedure Tmain.ed_sel_MapKeyPress(Sender: TObject; var Key: Char);
begin
   // 限制输入数字/小数点/退格键
   if not (Key in [#8, #13, '0'..'9']) then Key := #0;
   ed_sel_Map.Tag := 1;
end;

procedure Tmain.ed_sel_MapChange(Sender: TObject);
var
 edt: TEdit;
 str: string;
 n, bt: integer;
 tmpMapNode : PMapNode;        // 关卡节点
 
begin
   // 排除非键盘输入的 OnChange 事件
   if ed_sel_Map.Tag = 0 then Exit;
   ed_sel_Map.Tag := 0;
   
   // 获取当前文本内容
   edt := TEdit(Sender);
   str := edt.Text;

   try
      n := StrToInt(str);
   except
      StatusBar1.Panels[7].Text := '无效的关卡序号！';
      Exit;
   end;

   if n > 0 then begin
      if not mySettings.isLurd_Saved then
      begin    // 有新的动作尚未保存
        bt := MessageBox(Handle, '刚刚的推动尚未保存，是否保存？', '警告', MB_ICONWARNING + MB_YESNOCANCEL);
        if bt = idyes then begin
           SaveState();          // 保存状态到数据库
        end else if bt = idno then begin
           mySettings.isLurd_Saved := True;
           StatusBar1.Panels[7].Text := '动作已舍弃！';
        end else exit;
      end;
      try
         if MapList.Count = 0 then begin
            // 快速打开指定的地图
            tmpMapNode := QuicklyLoadMap(mySettings.MapFileName, n);
            if tmpMapNode.Map.Count > 2 then begin

               curMapNode := tmpMapNode;
               curMap.CurrentLevel := n;

               mySettings.isXSB_Saved := True;
               ReadQuicklyMap();

               Caption := AppName + AppVer + ' - ' + ExtractFileName(ChangeFileExt(mySettings.MapFileName, EmptyStr)) + ' ~ [' + inttostr(curMap.CurrentLevel) + '/???]';

               StatusBar1.Panels[7].Text := '';
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
         StatusBar1.Panels[7].Text := '没找到指定的关卡！';
      end;
   end;
end;

// 录制动作
procedure Tmain.F91Click(Sender: TObject);
begin
  DoAct(5);
end;

procedure Tmain.XSB0Click(Sender: TObject);
var
  myXSBFile, myBakFile: Textfile;
  i, j: Integer;
  mapNode: PMapNode;               // 关卡节点
  line: string;

begin

  StatusBar1.Panels[7].Text := '';

  if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;

  if mySettings.MapFileName = '' then begin
    if MessageBox(Handle, PChar('将刚刚导入的' + inttostr(MapList.Count) + '个关卡，加入到关卡周转库，' + #10 + '确定吗？'), '提醒', MB_ICONINFORMATION + MB_OKCANCEL) <> idOK then Exit;

    mySettings.MapFileName := 'BoxMan.xsb';

    AssignFile(myXSBFile, AppPath + mySettings.MapFileName);

    // 备份
    if FileExists(AppPath + mySettings.MapFileName) then CopyFile(PChar(AppPath + mySettings.MapFileName), PChar(AppPath + 'BoxMan.xsb.bak'), False);   // 周转关卡库，以追加方式保存

    Rewrite(myXSBFile);                                                 // 创建

    try
      // 先写入新的内容
      for i := 0 to MapList.Count - 1 do
      begin
        mapNode := MapList.Items[i];

        Writeln(myXSBFile, '');
        for j := 0 to mapNode.Map.Count - 1 do
        begin
          Writeln(myXSBFile, mapNode.Map[j]);
        end;
        if Trim(mapNode.Title) <> '' then
          Writeln(myXSBFile, 'Title: ' + mapNode.Title);
        if Trim(mapNode.Author) <> '' then
          Writeln(myXSBFile, 'Author: ' + mapNode.Author);
        if Trim(mapNode.Comment) <> '' then
        begin
          Writeln(myXSBFile, 'Comment: ');
          Writeln(myXSBFile, mapNode.Comment);
          Writeln(myXSBFile, 'Comment_end: ');
        end;
      end;

      // 再把备份的内容追加进来
      if FileExists(AppPath + 'BoxMan.xsb.bak') then begin
         AssignFile(myBakFile, AppPath + 'BoxMan.xsb.bak');
         Reset(myBakFile);
         try
           Writeln(myXSBFile, '');
           while not eof(myBakFile) do begin
              readln(myBakFile, line);        // 读取一行
              Writeln(myXSBFile, line);
           end;
         finally
           Closefile(myBakFile);
         end;
      end;
    finally
      Closefile(myXSBFile);
    end;

    mySettings.isXSB_Saved := True;            // 当从剪切板导入的 XSB 是否保存过了

    StatusBar1.Panels[7].Text := '已入关卡周转库，重新打开“关卡周转库”可查看全部关卡。';
    Caption := AppName + AppVer + ' - ' + ExtractFileName(ChangeFileExt(mySettings.MapFileName, EmptyStr)) + ' ~ [' + inttostr(curMap.CurrentLevel) + '/' + inttostr(MapList.Count) + ']';
  end;
end;

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
  DrawMap();        // 画地图
end;

// 导入lurd - 剪切板
procedure Tmain.Lurd1Click(Sender: TObject);
var
  i, myCell: Integer;
  
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;

  if LoadLurdFromClipboard(mySettings.isBK) then begin
    StatusBar1.Panels[7].Text := '从剪切板加载 Lurd！';
    if mySettings.isBK and (ManPos_BK_0_2 >= 0) then begin   // 处理人的位置
      myCell := map_Board_OG[ManPos_BK_0_2];
      if (myCell = FloorCell) or (myCell = BoxCell) then begin
        for i := 0 to curMap.MapSize - 1 do begin
          if map_Board_OG[i] = BoxCell then
            map_Board_BK[i] := GoalCell
          else if map_Board_OG[i] = GoalCell then
            map_Board_BK[i] := BoxCell
          else if map_Board_OG[i] = ManCell then
            map_Board_BK[i] := FloorCell
          else if map_Board_OG[i] = ManGoalCell then
            map_Board_BK[i] := GoalCell
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
        LastSteps := -1;                           // 正推最后一次点推前的步数
        IsManAccessibleTips_BK := false;           // 是否显示人的逆推可达提示
        IsBoxAccessibleTips_BK := false;           // 是否显示箱子的逆推可达提示
        DrawMap();         // 画地图
        SetButton();       // 设置按钮状态
        ShowStatusBar();   // 底行状态栏
        StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos_BK mod curMapNode.Cols, ManPos_BK div curMapNode.Cols) + ' - [ ' + IntToStr(ManPos_BK mod curMapNode.Cols + 1) + ', ' + IntToStr(ManPos_BK div curMapNode.Cols + 1) + ' ]';       // 标尺
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

  if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;

  if LurdToClipboard(ManPos_BK_0 mod curMapNode.Cols, ManPos_BK_0 div curMapNode.Cols) then
     StatusBar1.Panels[7].Text := '已做动作 Lurd 送入剪切板！';
end;

procedure Tmain.Lurd3Click(Sender: TObject);
begin
  if isMoving then IsStop := True
  else IsStop := False;

  if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;

  if LurdToClipboard2(mySettings.isBK) then
     StatusBar1.Panels[7].Text := '后续动作 Lurd 送入剪切板！';
end;

// 帮助
procedure Tmain.sb_HelpClick(Sender: TObject);
begin
  ShellExecute(Application.handle, nil, PChar(AppPath + 'BoxManHelp.txt'), nil, nil, SW_SHOWNORMAL);
  ContentClick(Self);
end;

// 左侧边栏，右键时选择条目
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

procedure Tmain.SpeedButton1Click(Sender: TObject);
var
  i: Integer;
  mapNode: PMapNode;
begin
  if MapList.Count = 0 then Exit;

  for i := 0 to MapList.Count-1 do begin
      mapNode := MapList[i];
      if mapNode.Solved then begin
         TestForm.Memo1.Lines.Add(mapNode.Map_Thin);
         TestForm.Memo1.Lines.Add('');
      end;
  end;
  TestForm.Show;
end;

end.

