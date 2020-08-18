unit DeadLockDetection;

interface

  function  is_Fang(var map: array of Byte; pos: Integer): boolean;                                                   // “方”型死锁检查
  function  is_Zhi(var map: array of Byte; pos: Integer; var m_Zhi_Dir: array of Integer): boolean;                   // “之”字型死锁检查
  function  isLock_Double_L(var map: array of Byte; pos: Integer; var m_Double_L_Top: array of Integer): boolean;     // “对角”型死锁检测

implementation

uses
  Math;

const
  BT_OUTSIDE           = 0;             // 墙外
  BT_WALL              = 1;             // 墙壁
  BT_FLOOR             = 2;             // 地板
  BT_GOAL              = 3;             // 目标点
  BT_BOX               = 4;             // 箱子
  BT_BOX_ON_GOAL       = 5;             // 目标点上的箱子
  BT_PLAYER            = 6;             // 人
  BT_PLAYER_ON_GOAL    = 7;             // 目标点上的人

var
  // 方向矢量（与地图相关，操作一维地图数组时使用）：左、上、右、下
  diff                : array of Integer;

  m_Zhi_Dir:      array[0..2] of Integer = ( 0, 0, 0 );   // 检测“之”字型死锁时，第一个元素标识是否包括不在目标点上的箱子，后两个元素标识动作方向：1 -- 左，2 -- 右，3 -- 上，4 -- 下
  m_Double_L_Top: array[0..2] of Integer = ( 0, 0, 0 );   // 检测“双 L”型死锁时的两个顶点及是否包含尚未到位的箱子

  Map_Dead            : array of Byte;              // 禁止箱子进入的区域
  dir                 : array of Byte;              // 寻径临时数组
  pt                  : array of Integer;           // 寻径临时数组

  // 地图相关参数
  nRows               : Integer;                    // 行数
  nCols               : Integer;                    // 列数
  nArea               : Integer;                    // 格子总数
  nManPos             : Integer;                    // 人的初始位置
  bNoSolution         : Boolean;                    // 是否无解

// 是否是箱子或墙
function isBoxWall(var map: array of Byte; pos: Integer): Boolean;
begin
    Result := (map[pos] = BT_BOX) or (map[pos] = BT_BOX_ON_GOAL) or (map[pos] = BT_WALL);
end;

// 是否是箱子
function isBox(var map: array of Byte; pos: Integer): Boolean;
begin
    Result := (map[pos] = BT_BOX) or (map[pos] = BT_BOX_ON_GOAL);
end;

// 是否是点位
function isGoal(var map: array of Byte; pos: Integer): Boolean;
begin
    Result := (map[pos] = BT_GOAL) or (map[pos] = BT_BOX_ON_GOAL);
end;

// 是否是人
function isMan(var map: array of Byte; pos: Integer): Boolean;
begin
    Result := (map[pos] = BT_PLAYER) or (map[pos] = BT_PLAYER_ON_GOAL);
end;

// 是否是通道
function isPass(var map: array of Byte; pos: Integer): Boolean;
begin
    Result := (map[pos] = BT_FLOOR) or (map[pos] = BT_GOAL);
end;


// 逆推法计算箱子不可进入的区域 -- 主程序
procedure dead_Zone(var map1, map2, mark: array of Byte);  // 0:允许进入  1:禁止进入
var
  i: Integer;
  // 逆推法计算箱子不可进入的区域 -- 副程序
  procedure dead_Zone_sub(pos: Integer; var map2, mark: array of Byte);
  var
    pos1, pos2, k: Integer;
  begin
      mark[pos] := 0;
      for k := 0 to 3 do begin
          pos1 := pos  + diff[k];
          pos2 := pos1 + diff[k];
          if (mark[pos1] = 1) and (isPass(map2, pos1)) and (isPass(map2, pos2)) then dead_Zone_sub(pos1, map2, mark);  // 如果带上箱子的话
      end;
  end;
begin
    for i := 0 to nArea-1 do begin
        mark[i] := 1;
        if map1[i] = BT_WALL then map2[i] := BT_WALL
        else if isGoal(map1, i) then map2[i] := BT_GOAL
        else map2[i] := BT_FLOOR;
    end;
    for i := nCols + 1 to nArea - nCols - 1 do begin  // 从目标点进行调查
        if (map2[i] = BT_GOAL) and (mark[i] = 1) then dead_Zone_sub(i, map2, mark);
    end;
end;

// 将初态的死锁箱子变成墙壁
procedure set_Dead2Wall(var map: array of Byte);
var
    i: Integer;
begin
    for i := nCols + 1 to nArea - nCols - 2 do begin
        if is_Fang(map, i) then begin                                              // 箱子构成方型死锁
            map[i] := BT_WALL;
            if map[i] = BT_BOX then bNoSolution := true;                           // 初态有死锁的箱子
        end else if is_Zhi(map, i, m_Zhi_Dir) then begin                           // 箱子构成“之字”型死锁
            map[i] := BT_WALL;
            if (not bNoSolution) and (m_Zhi_Dir[0] > 0) then bNoSolution := true;  // 初态有死锁的箱子
        end;
    end;
end;

// 将初态成网的箱子变成墙壁
procedure set_Net2Wall(var map, mark: array of Byte);
var
    k, i: Integer;
    
    function netChesk(pos: Integer; var map, mark: array of Byte): boolean;
    var
        k, p, tail, p1, p2: Integer;
    begin

        for k := 0 to nArea - 1 do mark[k] := 0;
    
        p := 0; tail := 0; pt[0] := pos;       // 初始位置入队列，待查其四邻
        mark[pos] := 1;
        while (p <= tail) do begin
            for k := 0 to 3 do begin
                p1 := pt[P] + diff[k];
                p2 := pt[P] + diff[k] * 2;

                if (map[p1] = BT_WALL) or
                   (p2 < 0) or (p2 >= nArea) or (1 = mark[p2]) or
                   (map[p2] = BT_OUTSIDE) or (map[p2] = BT_WALL) then continue  // 遇墙、界外等
                else if map[p2] = BT_BOX_ON_GOAL then begin                     // 遇到网内的箱子
                    Inc(tail);
                    pt[tail] := p2;
                    mark[p2] := 1;
                end else begin                                                  // 非网
                    Result := false;
                    Exit;
                end;
            end;
            Inc(p);
        end;

        Result := true;
    end;
begin
    for k := nCols + 1 to nArea - nCols - 2 do begin
        if (map[k] = BT_BOX_ON_GOAL) and (netChesk(k, map, mark)) then begin  // 遇到目标点上的箱子，且成网，则把网内的箱子变成墙壁
            for i := k to nArea - nCols - 2 do begin
                if 1 = mark[i] then map[i] := BT_WALL;
            end;
        end;
    end;
end;

// 是否“方型”（包含墙边的双箱并列等）
function is_Fang(var map: array of Byte; pos: Integer): boolean;
var
    p1, p2, p3, p4, p5, p6, p7, p8: Integer;
begin
    if isBox(map, pos) then begin
        p1 := pos + diff[0];  // 左
        p2 := pos + diff[1];  // 上
        p3 := pos + diff[2];  // 右
        p4 := pos + diff[3];  // 下
        p5 := pos + diff[0] + diff[1];  // 左上
        p6 := pos + diff[1] + diff[2];  // 上右
        p7 := pos + diff[2] + diff[3];  // 右下
        p8 := pos + diff[3] + diff[0];  // 下左

        if isBoxWall(map, p1) then begin  // 左
            if (isBoxWall(map, p2)) and (isBoxWall(map, p5)) and ((map[pos] = BT_BOX) or (map[p1] = BT_BOX) or (map[p2] = BT_BOX) or (map[p5] = BT_BOX)) then begin  // 上
                Result := true;  // 左上方型
                Exit;
            end;
            if (isBoxWall(map, p4)) and (isBoxWall(map, p8)) and ((map[pos] = BT_BOX) or (map[p1] = BT_BOX) or (map[p4] = BT_BOX) or (map[p8] = BT_BOX)) then begin  // 下
                Result := true;  // 左下方型
                Exit;
            end;
        end else if isBoxWall(map, p3) then begin  // 右
            if (isBoxWall(map, p2)) and (isBoxWall(map, p6)) and ((map[pos] = BT_BOX) or (map[p3] = BT_BOX) or (map[p2] = BT_BOX) or (map[p6] = BT_BOX)) then begin  // 上
                Result := true;  // 右上方型
                Exit;
            end;
            if (isBoxWall(map, p4)) and (isBoxWall(map, p7)) and ((map[pos] = BT_BOX) or (map[p3] = BT_BOX) or (map[p4] = BT_BOX) or (map[p7] = BT_BOX)) then begin  // 下
                Result := true;  // 右下方型
                Exit;
            end;
        end;
    end;
    Result := false;  // 未构成方型
end;

//是否构成“之字”型，m_Zhi_Dir：第一个元素标识是否包括不在目标点上的箱子，后两个元素标识动作方向：1 -- 左，2 -- 右，3 -- 上，4 -- 下
function is_Zhi(var map: array of Byte; pos: Integer; var m_Zhi_Dir: array of Integer): boolean;
    // “之”字型死锁检查 -- 副函数
    function is_Zhi_8(var map: array of Byte; pos: Integer; var m_Zhi_Dir: array of Integer): boolean;
    var
        d, p0, p1: Integer;
        flg: Boolean;

            // 识别"之字"型时，使用此检查，因“方型”块已不可动，与“墙”同等看待
        function is_Fang2(var map: array of Byte; p1, p0: Integer): boolean;
        var
            p1_R, p1_C, p0_R, p0_C, p2, p3, p4, p5, p6, dir: Integer;
        begin
            p1_R := p1 div nCols;
            p1_C := p1 mod nCols;
            p0_R := p0 div nCols;
            p0_C := p0 mod nCols;

            if p1_R = p0_R then begin  // 箱子与比对点同行
                dir := IfThen(p1_C > p0_C, 1, 0);
                p2 := p1 + diff[dir * 2];            // 同行
                p3 := p1 + diff[1];                  // 上
                p4 := p1 + diff[3];                  // 下
                p5 := p1 + diff[1] + diff[dir * 2];  // 上之同行
                p6 := p1 + diff[3] + diff[dir * 2];  // 下之同行
            end else begin             //箱子与比对点同列
                dir := IfThen(p1_R > p0_R, 1, 0);
                p2 := p1 + diff[1 + dir * 2];            // 同列
                p3 := p1 + diff[0];                      // 左
                p4 := p1 + diff[2];                      // 右
                p5 := p1 + diff[0] + diff[1 + dir * 2];  // 左之同列
                p6 := p1 + diff[2] + diff[1 + dir * 2];  // 右之同列
            end;
            if (isBoxWall(map, p1)) and (isBoxWall(map, p2)) then begin
                if (isBoxWall(map, p3)) and (isBoxWall(map, p5) or isBoxWall(map, p4)) and (isBoxWall(map, p6)) then begin // 成方
                    Result :=  true;
                    Exit;
                end;
            end;
            Result :=  false;
        end;

    begin
        d   := m_Zhi_Dir[2];  // 第二动的方向
        p0  := pos;
        p1  := pos;
        flg := false;  // 之字前半部分是否成型

        case m_Zhi_Dir[1] of  // 第一动的方向
        1:  // 第一动：左
                if d = 4 then begin  // 第二动：下
                    while (isBox(map, p1)) do begin  // 先做左下检查
                        if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                        if (d = 4) then begin  // 左
                            d  := 0;
                            p1 := p1 + diff[0];
                        end else begin       // 下
                            d  := 4;
                            p1 := p1 + diff[3];
                        end;
                        if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // 遇“墙或方”
                            flg := true;  // 前半部分之字成型
                            break;
                        end;
                        p0 := p1;
                    end;
                    if flg then begin  // 前半部分之字成型，则检查后半部分
                        d  := m_Zhi_Dir[2];
                        p0 := pos;
                        p1 := pos;
                        while (isBox(map, p1)) do begin  // 再做上右检查
                            if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                            if d = 4 then begin  // 上
                                d  := 0;
                                p1 := p1 + diff[1];
                            end else begin       // 右
                                d  := 4;
                                p1 := p1 + diff[2];
                            end;
                            if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // 遇“墙或方”
                                Result := true;  // 后半部分之字成型
                                Exit;
                            end;
                            p0 := p1;
                        end;
                    end;
                end else begin  // 第二动：上
                    while (isBox(map, p1)) do begin  // 先做左上检查
                        if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                        if d <> 4 then begin  // 左
                            d  := 4;
                            p1 := p1 + diff[0];
                        end else begin       // 上
                            d  := 0;
                            p1 := p1 + diff[1];
                        end;
                        if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // 遇“墙或方”
                            flg := true;  // 前半部分之字成型
                            break;
                        end;
                        p0 := p1;
                    end;
                    if flg then begin  // 前半部分之字成型，则检查后半部分
                        d  := m_Zhi_Dir[2];
                        p0 := pos;
                        p1 := pos;
                        while (isBox(map, p1)) do begin  // 再做下右检查
                            if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                            if d <> 4 then begin  // 下
                                d  := 4;
                                p1 := p1 + diff[3];
                            end else begin       // 右
                                d  := 0;
                                p1 := p1 + diff[2];
                            end;
                            if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // 遇“墙或方”
                                Result := true;  // 后半部分之字成型
                                Exit;
                            end;
                            p0 := p1;
                        end;
                    end;
                end;
        2:  // 第一动：右
                if d = 4 then begin  // 第二动：下
                    while (isBox(map, p1)) do begin  // 先做右下检查
                        if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                        if d = 4 then begin  // 右
                            d  := 0;
                            p1 := p1 + diff[2];
                        end else begin       // 下
                            d  := 4;
                            p1 := p1 + diff[3];
                        end;
                        if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // 遇“墙或方”
                            flg := true;  // 前半部分之字成型
                            break;
                        end;
                        p0 := p1;
                    end;
                    if flg then begin  // 前半部分之字成型，则检查后半部分
                        d  := m_Zhi_Dir[2];
                        p0 := pos;
                        p1 := pos;

                        while (isBox(map, p1)) do begin  // 再做上左检查
                            if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                            if d = 4 then begin  // 上
                                d  := 0;
                                p1 := p1 + diff[1];
                            end else begin       // 左
                                d  := 4;
                                p1 := p1 + diff[0];
                            end;
                            if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // 遇“墙或方”
                                Result := true;  // 后半部分之字成型
                                Exit;
                            end;
                            p0 := p1;
                        end;
                    end;
                end else begin  // 第二动：上
                    while (isBox(map, p1)) do begin  // 先做右上检查
                        if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                        if d <> 4 then begin  // 右
                            d  := 4;
                            p1 := p1 + diff[2];
                        end else begin       // 上
                            d  := 0;
                            p1 := p1 + diff[1];
                        end;
                        if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // 遇“墙或方”
                            flg := true;  // 前半部分之字成型
                            break;
                        end;
                        p0 := p1;
                    end;
                    if flg then begin  // 前半部分之字成型，则检查后半部分
                        d  := m_Zhi_Dir[2];
                        p0 := pos;
                        p1 := pos;

                        while (isBox(map, p1)) do begin  // 再做下左检查
                            if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                            if d <> 4 then begin  // 下
                                d  := 4;
                                p1 := p1 + diff[3];
                            end else begin       // 左
                                d  := 0;
                                p1 := p1 + diff[0];
                            end;
                            if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // 遇“墙或方”
                                Result := true;  // 后半部分之字成型
                                Exit;
                            end;
                            p0 := p1;
                        end;
                    end;
                end;
        3:  // 第一动：上
                if d = 2 then begin  // 第二动：右
                    while (isBox(map, p1)) do begin  // 先做上右检查
                        if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                        if d = 2 then begin  // 上
                            d  := 0;
                            p1 := p1 + diff[1];
                        end else begin       // 右
                            d  := 2;
                            p1 := p1 + diff[2];
                        end;
                        if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // 遇“墙或方”
                            flg := true;  // 前半部分之字成型
                            break;
                        end;
                        p0 := p1;
                    end;
                    if flg then begin  // 前半部分之字成型，则检查后半部分
                        d  := m_Zhi_Dir[2];
                        p0 := pos;
                        p1 := pos;

                        while (isBox(map, p1)) do begin  // 先做左下检查
                            if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                            if d = 2 then begin  // 左
                                d  := 0;
                                p1 := p1 + diff[0];
                            end else begin       // 下
                                d  := 2;
                                p1 := p1 + diff[3];
                            end;
                            if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // 遇“墙或方”
                                Result := true;  // 后半部分之字成型
                                Exit;
                            end;
                            p0 := p1;
                        end;
                    end;
                end else begin  // 第二动：左
                    while (isBox(map, p1)) do begin  // 先做上左检查
                        if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                        if d <> 2 then begin  // 上
                            d  := 2;
                            p1 := p1 + diff[1];
                        end else begin       // 左
                            d  := 0;
                            p1 := p1 + diff[0];
                        end;
                        if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin // 遇“墙或方”
                            flg := true;  // 前半部分之字成型
                            break;
                        end;
                        p0 := p1;
                    end;
                    if flg then begin  // 前半部分之字成型，则检查后半部分
                        d  := m_Zhi_Dir[2];
                        p0 := pos;
                        p1 := pos;

                        while (isBox(map, p1)) do begin  // 再做右下检查
                            if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                            if d <> 2 then begin  // 右
                                d  := 2;
                                p1 := p1 + diff[2];
                            end else begin       // 下
                                d  := 0;
                                p1 := p1 + diff[3];
                            end;
                            if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // 遇“墙或方”
                                Result := true;  // 后半部分之字成型
                                Exit;
                            end;
                            p0 := p1;
                        end;
                    end;
                end;
        4:  // 第一动：下
                if d = 2 then begin  // 第二动：右
                    while (isBox(map, p1)) do begin  // 先做下右检查
                        if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                        if d = 2 then begin  // 下
                            d  := 0;
                            p1 := p1 + diff[3];
                        end else begin       // 右
                            d  := 2;
                            p1 := p1 + diff[2];
                        end;
                        if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // 遇“墙或方”
                            flg := true;  // 前半部分之字成型
                            break;
                        end;
                        p0 := p1;
                    end;
                    if flg then begin  // 前半部分之字成型，则检查后半部分
                        d  := m_Zhi_Dir[2];
                        p0 := pos;
                        p1 := pos;

                        while (isBox(map, p1)) do begin  // 先做左上检查
                            if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                            if d = 2 then begin  // 左
                                d  := 0;
                                p1 := p1 + diff[0];
                            end else begin       // 上
                                d  := 2;
                                p1 := p1 + diff[1];
                            end;
                            if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // 遇“墙或方”
                                Result := true;  // 后半部分之字成型
                                Exit;
                            end;
                            p0 := p1;
                        end;
                    end;
                end else begin  // 第二动：左
                    while (isBox(map, p1)) do begin  // 先做下左检查
                        if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                        if d <> 2 then begin  // 下
                            d  := 2;
                            p1 := p1 + diff[3];
                        end else begin       // 左
                            d  := 0;
                            p1 := p1 + diff[0];
                        end;
                        if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // 遇“墙或方”
                            flg := true;  // 前半部分之字成型
                            break;
                        end;
                        p0 := p1;
                    end;
                    if flg then begin  // 前半部分之字成型，则检查后半部分
                        d  := m_Zhi_Dir[2];
                        p0 := pos;
                        p1 := pos;

                        while (isBox(map, p1)) do begin  // 再做右上检查
                            if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                            if d <> 2 then begin  // 右
                                d  := 2;
                                p1 := p1 + diff[2];
                            end else begin       // 上
                                d  := 0;
                                p1 := p1 + diff[1];
                            end;
                            if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // 遇“墙或方”
                                Result := true;  // 后半部分之字成型
                                Exit;
                            end;
                            p0 := p1;
                        end;
                    end;
                end;
        end;
        m_Zhi_Dir[0] := 0;
        Result := false;  //所检查的之字没有成型或没有死锁
    end;

begin
    if isBox(map, pos) then begin  //本位是箱子
        //1、先右 - 后下（同时包括：上 -- 左）
        m_Zhi_Dir[0] := 0;
        m_Zhi_Dir[1] := 2;
        m_Zhi_Dir[2] := 4;
        if is_Zhi_8(map, pos, m_Zhi_Dir) then begin
           Result := true;
           Exit;
        end;
        //2、先下 - 后右（同时包括：上 -- 左）
        m_Zhi_Dir[0] := 0;
        m_Zhi_Dir[1] := 4;
        m_Zhi_Dir[2] := 2;
        if is_Zhi_8(map, pos, m_Zhi_Dir) then begin
           Result := true;
           Exit;
        end;
        //3、先左 - 后下（同时包括：上 -- 右）
        m_Zhi_Dir[0] := 0;
        m_Zhi_Dir[1] := 1;
        m_Zhi_Dir[2] := 4;
        if is_Zhi_8(map, pos, m_Zhi_Dir) then begin
           Result := true;
           Exit;
        end;
        //4、先下 - 后左（同时包括：上 -- 右）
        m_Zhi_Dir[0] := 0;
        m_Zhi_Dir[1] := 4;
        m_Zhi_Dir[2] := 1;
        if is_Zhi_8(map, pos, m_Zhi_Dir) then begin
           Result := true;
           Exit;
        end;
        //5、先右 - 后上（同时包括：下 -- 左）
        m_Zhi_Dir[0] := 0;
        m_Zhi_Dir[1] := 2;
        m_Zhi_Dir[2] := 3;
        if is_Zhi_8(map, pos, m_Zhi_Dir) then begin
           Result := true;
           Exit;
        end;
        //6、先上 - 后右（同时包括：下 -- 左）
        m_Zhi_Dir[0] := 0;
        m_Zhi_Dir[1] := 3;
        m_Zhi_Dir[2] := 2;
        if is_Zhi_8(map, pos, m_Zhi_Dir) then begin
           Result := true;
           Exit;
        end;
        //7、先上 - 后左（同时包括：下 -- 右）
        m_Zhi_Dir[0] := 0;
        m_Zhi_Dir[1] := 3;
        m_Zhi_Dir[2] := 1;
        if is_Zhi_8(map, pos, m_Zhi_Dir) then begin
           Result := true;
           Exit;
        end;
        //8、先左 - 后上（同时包括：下 -- 右）
        m_Zhi_Dir[0] := 0;
        m_Zhi_Dir[1] := 1;
        m_Zhi_Dir[2] := 3;
        if is_Zhi_8(map, pos, m_Zhi_Dir) then begin
           Result := true;
           Exit;
        end;
    end;
    Result := false;
end;

// 是否构成“双 L”型（上下连在一起成型）死锁
function isLock_Double_L(var map: array of Byte; pos: Integer; var m_Double_L_Top: array of Integer): boolean;

    //某方向“双 L”是否成型：m_Row、m_Col -- 中间空地坐标；dR、dC -- 控制检查方向；isSecond -- 是否在找第二个顶点
    function is_Double_L(var map: array of Byte; pos, dR, dC: Integer; var m_Double_L_Top: array of Integer; isSecond: Boolean): boolean;
    begin
        while (true) do begin
            //此方向发现顶点，此方向“双 L”成型
            if (isBoxWall(map, pos)) and (isBoxWall(map, pos - dC)) then begin
                if (isSecond) then begin  //记录第二个顶点的坐标
                    m_Double_L_Top[2] := pos;
                end else begin  //记录第一个顶点的坐标
                    m_Double_L_Top[1] := pos;
                end;
                Result := true;  //此方向“双 L”成型
                Exit;
            end;

            //连续为“双 L”的中间部分，则继续找
            if (isBoxWall(map, pos + diff[0])) and (isBoxWall(map, pos + diff[2])) then begin
                //改变中间空地坐标
                pos := pos + dR * nCols + dC;
                continue;
            end;

            break;  //否则，此方向“双 L”没有成型
        end;

        Result :=  false;  //此方向“双 L”没有成型
    end;

    // 是否“双 L”型死锁（中间目标点多于 2 个的时候，情况比较复杂，暂以“不死锁”看待，少于 2 个目标点时，是否均涵盖，待验）
    function is_Double_L_Locked(var map: array of Byte; var m_Double_L_Top: array of Integer): boolean;
    var
        pos, dR, dC, n: Integer;                         
        flg: array[0..5] of Boolean;
        f: Boolean;
    begin
        // 通过换算，使设计算法时，都用“左上--右下”方向思考（即：mTop_Bottom[1] 当成左顶点，mTop_Bottom[2] 当成右下顶点）
        dR := 1; dC := 1;
        if (m_Double_L_Top[1] div nCols > m_Double_L_Top[2] div nCols) then dR := -1;
        if (m_Double_L_Top[1] mod nCols > m_Double_L_Top[2] mod nCols) then dC := -1;

        // 两顶点的 6 个箱子是否在目标点
        flg[0] := (map[m_Double_L_Top[1]             ] = BT_BOX);       //顶
        flg[1] := (map[m_Double_L_Top[1] + dC        ] = BT_BOX);       //顶右
        flg[2] := (map[m_Double_L_Top[1] + dR * nCols] = BT_BOX);       //中间左
        flg[3] := (map[m_Double_L_Top[2] - dR * nCols] = BT_BOX);       //中间右
        flg[4] := (map[m_Double_L_Top[2] - dC        ] = BT_BOX);       //底左
        flg[5] := (map[m_Double_L_Top[2]             ] = BT_BOX);       //底

        // 遍历中间的部分，记录有没有未归位的箱子以及中间的空地有几个目标点
        f := (flg[0]) or (flg[1]) or (flg[2]) or (flg[3]) or (flg[4]) or (flg[5]);
        n := 0;
        // 第一个中间空地的坐标
        pos := m_Double_L_Top[1] + dR * nCols + dC;
        while (true) do begin
            if (not f) and ((map[pos - dC] = BT_BOX) or (map[pos + dC] = BT_BOX)) then f := true;  // 两侧有不在目标点的箱子

            if map[pos] = BT_GOAL then Inc(n);  // 中间是目标点

            pos := pos + dR * nCols + dC;
            if pos = m_Double_L_Top[2] then break;  // 到达第二个顶点
        end;

        m_Double_L_Top[0] := n;  // 第一个元素记录包含的不在目标点上的箱子个数

        if n = 0 then begin  // 没有目标点，若再包含没有归位的箱子，必定构成“方型”死锁
            if f then begin
               Result := true;
               Exit;
            end;
        end else if n = 1 then begin  // 一个目标点不足以拆开两端，两个顶中同时包含未归位的箱子时，必定构成“方型”死锁
            if ((flg[0]) or (flg[1]) or (flg[2])) and ((flg[3]) or (flg[4]) or (flg[5])) then begin
               Result := true;
               Exit;
            end;
        end;
        Result :=  false;
    end;

begin
    if isBox(map, pos) then begin  // 本位是箱子
        // 右侧是箱子或墙，本行为一个顶点
        if isBoxWall(map, pos + diff[2]) then begin
            //检查右侧方向
            //作为第一个顶点
            m_Double_L_Top[1] := pos;
            if (isPass(map, pos + diff[2] + diff[3])) and (is_Double_L(map, pos + diff[2] + diff[3], 1, 1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) or  // 右下，成锁
               (isPass(map, pos + diff[2] + diff[1])) and (is_Double_L(map, pos + diff[2] + diff[1], -1, 1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) then begin  // 右上，成锁
                Result := true;
                Exit;
            end;
            //检查左侧方向
            //作为第一个顶点
            m_Double_L_Top[1] := pos + diff[2];
            if (isPass(map, pos + diff[1])) and (is_Double_L(map, pos + diff[1], -1, -1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) or  //左上，成锁
               (isPass(map, pos + diff[3])) and (is_Double_L(map, pos + diff[3], 1, -1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) then begin  //左下，成锁
                Result := true;
                Exit;
            end;
        end;

        //左侧是箱子或墙，本行为一个顶点
        if isBoxWall(map, pos + diff[0]) then begin
            //检查左侧方向
            //作为第一个顶点
            m_Double_L_Top[1] := pos;
            if (isPass(map, pos + diff[0] + diff[1])) and (is_Double_L(map, pos + diff[0] + diff[1], -1, -1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) or  //左上，成锁
               (isPass(map, pos + diff[0] + diff[3])) and (is_Double_L(map, pos + diff[0] + diff[3], 1, -1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) then begin  //左下，成锁
                Result := true;
                Exit;
            end;
            //检查右侧方向
            //作为第一个顶点
            m_Double_L_Top[1] := pos + diff[0];
            if (isPass(map, pos + diff[1])) and (is_Double_L(map, pos + diff[1], -1, 1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) or  //右上，成锁
               (isPass(map, pos + diff[3])) and (is_Double_L(map, pos + diff[3], 1, 1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) then begin  //右下，成锁
                Result := true;
                Exit;
            end;
        end;

        //右侧是 空地（目标点） + 箱子或墙
        if (isPass(map, pos + diff[2])) and (isBoxWall(map, pos + diff[2] * 2)) then begin
            if (is_Double_L(map, pos + diff[2], -1, -1, m_Double_L_Top, false)) and (is_Double_L(map, pos + diff[2], 1, 1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) then begin  //左上、右下
                Result := true;
                Exit;
            end;
            if (is_Double_L(map, pos + diff[2], -1, 1, m_Double_L_Top, false)) and (is_Double_L(map, pos + diff[2], 1, -1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) then begin  //右上、左下
                Result := true;
                Exit;
            end;
        end;

        //左侧是 空地（目标点） + 箱子或墙
        if (isPass(map, pos + diff[0])) and (isBoxWall(map,pos + diff[0] * 2)) then begin
            if (is_Double_L(map, pos + diff[0], -1, -1, m_Double_L_Top, false)) and (is_Double_L(map, pos + diff[0], 1, 1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) then begin  //左上、右下
                Result := true;
                Exit;
            end;
            if (is_Double_L(map, pos + diff[0], -1, 1, m_Double_L_Top, false)) and (is_Double_L(map, pos + diff[0], 1, -1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) then begin  //右上、左下
                Result := true;
                Exit;
            end;
        end;
    end;
    Result := false;
end;

end.
