unit Board;

interface

type
  TMapNode = record             // 关卡节点 -- 关卡集中的各个关卡
    Map_Thin: string;           // 最简关卡 XSB
    Map: string;                // 关卡 XSB
    Rows, Cols: integer;        // 关卡尺寸
    Boxs: integer;              // 箱子数
    Goals: integer;             // 目标数
    Trun: integer;              // 关卡旋转登记
    Title: string;              // 标题
    Author: string;             // 作者
    Comment: string;            // 关卡描述信息
    CRC32: integer;             // CRC32
    CRC_Num: integer;           // 若当前地图为 0 转，最小 CRC 位于第几转？
    Solved: Boolean;            // 是否由答案
    isEligible: Boolean;        // 是否合格的关卡XSB
    Num: integer;               // 关卡序号 -- 仅加载文档最后一个关卡时使用
  end;
  PMapNode = ^TMapNode;         // 关卡节点指针

var
  curMapNode: PMapNode;    // 当前关卡节点

  Map_Thin: string;        // 最简关卡 XSB
  Map: string;             // 关卡 XSB
  Title: string;           // 标题
  Author: string;          // 作者
  Comment: string;         // 关卡描述信息
  Rows, Cols: integer;     // 关卡尺寸
  Boxs, Goals: integer;    // 箱子数，目标数
  Trun: integer;           // 关卡旋转登记
  CRC32: integer;          // CRC32
  CRC_Num: integer;        // 若当前地图为 0 转，最小 CRC 位于第几转？
  Solved: Boolean;         // 是否由答案
  isEligible: Boolean;     // 是否合格的关卡XSB

  CurrentLevel: integer;   // 当前关卡序号
  ManPosition: integer;    // 正推初始状态，人的位置
  MapSize: integer;        // 地图尺寸
  CellSize: integer;       // 画地图时，当前的单元格尺寸
  Recording: Boolean;      // 是否在动作录制状态
  Recording_BK: Boolean;   // 是否在动作录制状态 -- 逆推
  StartPos: Integer;       // 动作录制的开始点
  StartPos_BK: Integer;    // 动作录制的开始点 -- 逆推
  isFinish: Boolean;       // 是否得到答案，允许观看答案了 - 当解关成功或导入正确答案后，此标志为真，表示可以“观看”答案了

  ManPos_BK_0: integer;    // 人的位置 -- 逆推，玩家已经指定的位置
  ManPos_BK_0_2: integer;  // 人的位置 -- 逆推，解析出来的位置

implementation

end.
