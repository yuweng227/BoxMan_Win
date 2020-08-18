unit PathFinder;

{$DEFINE LASTACT}

interface

uses
  Classes, SysUtils, Contnrs, LurdAction;

const
  EmptyCell        = 0;
  WallCell         = 1;
  FloorCell        = 2;
  GoalCell         = 3;
  BoxCell          = 4;
  BoxGoalCell      = 5;
  ManCell          = 6;
  ManGoalCell      = 7;

var
    ManPath: array[1..MaxLenPath] of Char;              // 保存人移动动作的临时数组
    BoxPath: array[1..MaxLenPath] of Char;              // 保存人推箱子动作的临时数组

type                        // 单项链表
  PBoxManNode = ^BoxManNode;
  BoxManNode = record      // 箱子和人的组合节点，优先队列用节点
      boxPos: Integer;
      manPos: Integer;
      H, G, T, D: Integer;  // 评估值、累计步数、累计转弯次数、父节点方向
      next: PBoxManNode;
  end;

type
  TPathFinder = class
    private
      manMark: array[0..99, 0..99] of Byte;               // 人的可达标志数组，正推：0x01 可达点；0x02 穿越可达点； 0x04 穿越点；逆推：0x10 可达点；0x20 穿越可达点； 0x40 穿越点
      boxMark: array[0..99, 0..99] of Byte;               // 箱子的可达标志数组，正推：0x01 可达点；0x04 穿越点；逆推：0x10 可达点；0x40 穿越点

      function canThrough(isBK: Boolean; r, c, r1, c1, r2, c2, dir: Integer): Boolean;        // 检查 pos1 与 pos 两点是否穿越可达, 点 pos2 是被穿越的箱子，且在穿越时，箱子需要临时移动到 pos
      function getPathForThrough(nRow, nCol, nRow1, nCol1, nRow2, nCol2: Integer; dir: Byte; num: Integer): Integer;  // 计算并返回 nRow1, nCol1 与 nRow, nCol 两点间的穿越路径到 TurnPath，返回路径长度, 点 nRow2, nCol2 是被穿越的箱子，且在穿越时，箱子需要临时移动到 nRow, nCol
      function manTo2b(isBK: Boolean; boxR, boxC, firR, firC, secR, secC: Integer): Boolean;  // 割点法，检查两点是否人可达

    public
      procedure PathFinder(w, h: Integer);                                // 初始化
      procedure setThroughable(f: Boolean);                               // 设置是否允许穿越
      function  isManReachable(pos: Integer): Boolean;                    // 查看“位置”人是否可达
      function  isManReachableByThrough (pos: Integer): Boolean;          // 查看“位置”人是否穿越可达
      function  isBoxOfThrough(pos: Integer): Boolean;                    // 查看“位置”是否穿越点
      function  isManReachable_BK(pos: Integer): Boolean;                 // 查看“位置”人是否可达 -- 逆推
      function  isManReachableByThrough_BK(pos: Integer): Boolean;        // 查看“位置”人是否穿越可达 -- 逆推
      function  isBoxOfThrough_BK(pos: Integer): Boolean;                 // 查看“位置”是否穿越点 -- 逆推
      procedure manReachable(isBK: Boolean; level: array of Integer; manPos: Integer);                      // 计算仓管员的可达范围
      function  manTo(isBK: Boolean; level: array of Integer; manPos, toPos: Integer): Integer;              // 计算人到达 toPos 的路径，保存到 tmpPath，返回路径长度
      function  manTo2(isBK: Boolean; boxR, boxC, firR, firC, secR, secC: Integer): Boolean;   // 常规法，检查两点是否人可达

      procedure FindBlock(level: array of Integer; boxPos: Integer);      // 地图分块
      procedure boxReachable(isBK: Boolean; boxPos, manPos: Integer);     // 计算箱子的可达位置
      function  isBoxReachable(pos: Integer): Boolean;                    // 查看“位置”箱子是否可达
      function  isBoxReachable_BK(pos: Integer): Boolean;                 // 查看“位置”箱子是否可达 -- 逆推
      function  boxTo(isBK: Boolean; boxPos, toPos, manPos: Integer): Integer;  // 计算箱子到达 toPos 的路径，并由 list 带回

  end;

implementation

uses
  LogFile, LoadMapUnit;

const
  lurdChar : array[0..7] of Char = (  'l', 'r', 'u', 'd', 'L', 'R', 'U', 'D' );

  bt : array[0..7] of Byte = ( 0, 2, 1, 3, 4, 6, 5, 7 );      // 对应动作：l u r d L U R D

  mByte : array[0..3] of Byte = ( 1, 2, 4, 8 );      // 便于查找“块”的常量

var
  isThroughable: boolean;                             // 是否允许穿越

  tmpMap: array[0..99, 0..99] of Char;                // 计算穿越时，临时使用
  mapWidth, mapHeight: Integer;                       // 地图尺寸
  tmpBoxPos: Integer;                                 // 临时记录被点击箱子位置，计算割点 CutVertex() 时使用
  deep_Thur: Integer;                                 // 穿越前后的直推次数

  TrunPath: array[1..MaxLenPath] of Char;             // 保存人移动时，穿越路径的临时数组

  mark: array[0..99, 0..99] of Boolean;               // 计算穿越时，临时使用
  pt, pt0, ptBlock: array[0..9999] of Integer;        // 开集；登记块时使用ptBlock，替代“队列”
  
  mark0: array[0..99, 0..99, 0..3] of Boolean;
  cut: array[0..99, 0..99] of Boolean;                // 割点

  children,                                           // 记录当前节点的子树节点方向：1--左，2--右，4--上，8--下，用位运算操作
  parent, parent2 : array[0..99, 0..99] of Smallint;  // 记录“父节点”来“当前节点”的方向：0--上，1--下，2--左，3--右

  depth, b_count: Integer;                            // depth: DFS 深度；b_count: 计数“块 ”，块序号将从 -1递减标注
  depth_tag, low_tag: array[0..99, 0..99] of Integer;
  block: array[0..99, 0..99, 0..4] of Integer;

// 初始化
procedure TPathFinder.PathFinder(w, h: Integer);
begin
   mapWidth  := w;
   mapHeight := h;
end;

// 设置是否允许穿越
procedure TPathFinder.setThroughable(f: Boolean);
begin
   isThroughable := f;
end;

// 人是否可达
function TPathFinder.isManReachable(pos: Integer): Boolean;
begin
   Result := ((manMark[pos div mapWidth, pos mod mapWidth] and $01) > 0);
end;

// 人是否穿越可达
function TPathFinder.isManReachableByThrough(pos: Integer): Boolean;
begin
   Result := ((manMark[pos div mapWidth, pos mod mapWidth] and $02) > 0);
end;

// 箱子是否穿越点
function TPathFinder.isBoxOfThrough(pos: Integer): Boolean;
begin
   Result := ((manMark[pos div mapWidth, pos mod mapWidth] and $04) > 0);
end;

// 人是否可达 -- 逆推
function TPathFinder.isManReachable_BK(pos: Integer): Boolean;
begin
   Result := ((manMark[pos div mapWidth, pos mod mapWidth] and $10) > 0);
end;

// 人是否穿越可达 -- 逆推
function TPathFinder.isManReachableByThrough_BK (pos: Integer): Boolean;
begin
   Result := ((manMark[pos div mapWidth, pos mod mapWidth] and $20) > 0);
end;

// 箱子是否穿越点 -- 逆推
function TPathFinder.isBoxOfThrough_BK(pos: Integer): Boolean;
begin
   Result := ((manMark[pos div mapWidth, pos mod mapWidth] and $40) > 0);
end;

// 箱子是否可达
function TPathFinder.isBoxReachable(pos: Integer): Boolean;
begin
   Result := ((boxMark[pos div mapWidth, pos mod mapWidth] and $01) > 0);
end;

// 箱子是否可达 -- 逆推
function TPathFinder.isBoxReachable_BK(pos: Integer): Boolean;
begin
   Result := ((boxMark[pos div mapWidth, pos mod mapWidth] and $10) > 0);
end;


// 计算仓管员的可达范围，结果保存在 manMark[] 中
// 参数：isBK -- 是否逆推, level -- 地图现场, manPos -- 人的位置
procedure TPathFinder.manReachable(isBK: Boolean; level: array of Integer; manPos: Integer);
var
   curMark: Byte;
   i, j, k, i1, i2, i3, j1, j2, j3, p, tail, r, c: Integer;

begin
   if isBK then curMark := $0F     // 逆推时，保留正推标志
   else curMark := $F0;            // 正推时，保留逆推标志

   // 制作地图副本，以免影响原地图
   for i := 0 to mapHeight-1 do begin
       for j := 0 to mapWidth-1 do begin
          k := i * mapWidth + j;
          if (level[k] = WallCell) or (level[k] = EmptyCell) then tmpMap[i, j] := '#'
          else if (level[k] = BoxCell) or (level[k] = BoxGoalCell) then tmpMap[i, j] := '$'
          else tmpMap[i, j] := '-';

          manMark[i, j] := manMark[i, j] and curMark;
       end;
   end;

   p := 0; tail := 0;
   if isBK then curMark := $10     // 逆推时，保留正推标记
   else curMark := $01;            // 正推时，保留逆推标记
   r := manPos div mapWidth;
   c := manPos mod mapWidth;
   manMark[r, c] := manMark[r, c] or curMark;
   pt[0] := manPos;
   while (p <= tail) do begin
       // 常规（非穿越）排查
       while (p <= tail) do begin
            r := pt[p] div mapWidth;
            c := pt[p] mod mapWidth;
            for k := 0 to 3 do begin
                i1 := r + dr4[k];
                j1 := c + dc4[k];

                if (i1 < 0) or (j1 < 0) or (i1 >= mapHeight) or (j1 >= mapWidth) then continue // 界外
                else if ('-' = tmpMap[i1, j1]) and ((manMark[i1, j1] and curMark) = 0) then begin
                    Inc(tail);
                    pt[tail] := i1 * mapWidth + j1;   // 新的足迹
                    manMark[i1, j1] := manMark[i1, j1] or curMark;      // 可达或穿越可达标记，保留“反向”推的可达标记
                end;
            end;
            Inc(p);
       end;

       // 穿越排查
       if (isThroughable) then begin
          for i := 1 to mapHeight - 2 do begin
              for j := 1 to mapWidth - 2 do begin
                  if ('-' = tmpMap[i, j]) and ((manMark[i, j] and curMark) = 0) then begin
                      for k := 0 to 3 do begin    // 做四个方向的排查
                          deep_Thur := 0;
                          if isBK then begin
                              i1 := i + 3 * dr4[k];
                              j1 := j + 3 * dc4[k];
                              i2 := i + 2 * dr4[k];
                              j2 := j + 2 * dc4[k];
                              i3 := i + dr4[k];
                              j3 := j + dc4[k];

                              if (i1 < 0) or (j1 < 0) or (i1 >= mapHeight) or (j1 >= mapWidth) then continue   // 界外
                              else if ('$' = tmpMap[i3, j3]) and ((manMark[i1, j1] and curMark) > 0) and ((manMark[i2, j2] and curMark) > 0) then begin
                                  tmpMap[i3, j3] := '-';     // 为简化算法和避免干扰，计算穿越时，临时拿掉“被穿越的箱子”，仅仅依据“坐标”定位该箱子
                                  if canThrough(isBK, i2, j2, i1, j1, i3, j3, k) then begin    // 检查穿越时，会有“递归”，所以，暂时拿掉“被穿越的箱子”比较方便
                                      curMark := $30;                                  // 逆推穿越可达标记
                                      manMark[i, j]  := manMark[i, j] or curMark;      // 保留正推标记
                                      manMark[i3, j3] := manMark[i3, j3] or $40;       // 穿越点箱子，保留正推标记
                                      Inc(tail);
                                      pt[tail] := i * mapWidth + j;
                                  end;
                                  tmpMap[i3, j3] := '$';     // 放回“被穿越的箱子”
                              end;
                          end else begin
                              i1 := i + dr4[k];
                              j1 := j + dc4[k];
                              i2 := i - dr4[k];
                              j2 := j - dc4[k];
                              i3 := i - 2 * dr4[k];
                              j3 := j - 2 * dc4[k];

                              if (i3 < 0) or (j3 < 0) or (i3 >= mapHeight) or (j3 >= mapWidth)then continue   // 界外
                              else if ('$' = tmpMap[i2, j2]) and ('-' = tmpMap[i1, j1]) and ((manMark[i3, j3] and curMark) > 0) then begin
                                  tmpMap[i2, j2] := '-';     // 为简化算法和避免干扰，计算穿越时，临时拿掉“被穿越的箱子”，仅仅依据“坐标”定位该箱子
                                  if canThrough(isBK, i, j, i2, j2, i1, j1, k) then begin    // 检查穿越时，会有“递归”，所以，暂时拿掉“被穿越的箱子”比较方便
                                      curMark := $03;                                 // 正推穿越可达标记
                                      manMark[i, j]  := manMark[i, j] or curMark;     // 保留逆推标记
                                      manMark[i2, j2] := manMark[i2, j2] or $04;      // 穿越点箱子，保留逆推标记
                                      Inc(tail);
                                      pt[tail] := i * mapWidth + j;
                                  end;
                                  tmpMap[i2, j2] := '$';     // 放回“被穿越的箱子”
                              end;
                          end;
                      end;  // end k
                  end;
              end;  // end j
          end;  // end i
       end;  // end 穿越排查
   end;
end;

// 计算人到达 toPos 的路径，保存到 tmpPath，返回路径长度
// 参数：isBK -- 是否逆推, level -- 地图现场, manPos -- 仓管员原位置，toPos -- 仓管员目的位置

function TPathFinder.manTo(isBK: Boolean; level: array of Integer; manPos, toPos: Integer): Integer;
var
  i, j, i1, j1, i2, j2, i3, j3, k, p, tail, r, c, t1, t2, t_er, t_ec, len: Integer;
  isFound: Boolean;
  curMark: Byte;
  ch: Char;

begin
   Result := 0;

   if manPos = toPos then exit;
   
   if isBK then curMark := $0F     // 逆推时，保留正推标志
   else curMark := $F0;            // 正推时，保留逆推标志

   len := Length(level);

   // 制作地图副本，以免影响原地图
   for i := 0 to mapHeight-1 do begin
       for j := 0 to mapWidth-1 do begin
          k := i * mapWidth + j;
          if len > 3 then begin   // 在用 BoxTo() 函数计算“箱子”路径中的人的路径时，现场地图不需要重新装填，会用一个长度为 2 的“假地图”
              if (level[k] = WallCell) or (level[k] = EmptyCell) then tmpMap[i, j] := '#'
              else if (level[k] = BoxCell) or (level[k] = BoxGoalCell) then tmpMap[i, j] := '$'
              else tmpMap[i, j] := '-';
          end;
          manMark[i, j] := manMark[i, j] and curMark;
          parent[i, j]  := -1;
          parent2[i, j] := -1;
       end;
   end;

   if isBK then curMark := $10     // 逆推时，保留正推标志
   else curMark := $01;            // 正推时，保留逆推标志

   isFound := False;
   r := manPos div mapWidth;
   c := manPos mod mapWidth;
   manMark[r, c] := manMark[r, c] or curMark;
   pt[0] := manPos;
   p := 0; tail := 0;
   while p <= tail do begin
       // 常规（非穿越）排查
       while p <= tail do begin
           r := pt[p] div mapWidth;
           c := pt[p] mod mapWidth;
           for k := 0 to 3 do begin
              i1 := r + dr4[k];
              j1 := c + dc4[k];

              if (i1 < 0) or (j1 < 0) or (i1 >= mapHeight) or (j1 >= mapWidth) then continue // 界外
              else if ('-' = tmpMap[i1, j1]) and ((manMark[i1, j1] and curMark) = 0) then begin
                  Inc(tail);
                  pt[tail] := i1 * mapWidth + j1;                // 新的足迹
                  manMark[i1, j1] := manMark[i1, j1] or curMark; // 可达或穿越可达标记，保留“反向”推的可达标记
                  parent[i1, j1] := k;                           // 父节点到当前节点的方向
                  if toPos = i1 * mapWidth + j1 then begin       // 到达目标
                     isFound := true;
                     break;
                  end;
              end;
           end;
           if isFound then break;

           Inc(p);
       end;

       if isFound then break;

       // 穿越排查
       if isThroughable then begin
          for i := 1 to mapHeight - 2 do begin
              for j := 1 to mapWidth - 2 do begin
                  if ('-' = tmpMap[i, j]) and ((manMark[i, j] and curMark) = 0) then begin
                      for k := 0 to 3 do begin    // 做四个方向的排查
                          deep_Thur := 1;
                          if isBK then begin
                              i1 := i + 3 * dr4[k];
                              j1 := j + 3 * dc4[k];
                              i2 := i + 2 * dr4[k];
                              j2 := j + 2 * dc4[k];
                              i3 := i + dr4[k];
                              j3 := j + dc4[k];

                              if (i1 < 0) or (j1 < 0) or (i1 >= mapHeight) or (j1 >= mapWidth) then continue   // 界外
                              else if ('$' = tmpMap[i3, j3]) and ((manMark[i1, j1] and curMark) > 0) and ((manMark[i2, j2] and curMark) > 0) then begin    //    and (tmpBoxPos <> i3 * mapWidth + j3)
                                  tmpMap[i3, j3] := '-';     // 为简化算法和避免干扰，计算穿越时，临时拿掉“被穿越的箱子”，仅仅依据“坐标”定位该箱子
                                  if canThrough(isBK, i2, j2, i1, j1, i3, j3, k) then begin    // 检查穿越时，会有“递归”，所以，暂时拿掉“被穿越的箱子”比较方便
                                      manMark[i, j] := manMark[i, j] or curMark;    // 保留正推标记
                                      Inc(tail);
                                      pt[tail] := i * mapWidth + j;
                                      parent[i, j] := 10 * deep_Thur + k;     // 穿越走法（变通的方向）
                                      if i * mapWidth + j = toPos then isFound := true;              // 到达目标
                                  end;
                                  tmpMap[i3, j3] := '$';     // 放回“被穿越的箱子”
                                  if (isFound) then break;
                              end;
                          end else begin
                              i1 := i + dr4[k];
                              j1 := j + dc4[k];
                              i2 := i - dr4[k];
                              j2 := j - dc4[k];
                              i3 := i - 2 * dr4[k];
                              j3 := j - 2 * dc4[k];

                              if (i3 < 0) or (j3 < 0) or (i3 >= mapHeight) or (j3 >= mapWidth)then continue   // 界外
                              else if ('$' = tmpMap[i2, j2]) and ('-' = tmpMap[i1, j1]) and ((manMark[i3, j3] and curMark) > 0) then begin  //   and (tmpBoxPos <> i2 * mapWidth + j2)
                                  tmpMap[i2, j2] := '-';     // 为简化算法和避免干扰，计算穿越时，临时拿掉“被穿越的箱子”，仅仅依据“坐标”定位该箱子
                                  if canThrough(isBK, i, j, i2, j2, i1, j1, k) then begin    // 检查穿越时，会有“递归”，所以，暂时拿掉“被穿越的箱子”比较方便
                                      manMark[i, j] := manMark[i, j] or curMark;     // 保留逆推标记
                                      Inc(tail);
                                      pt[tail] := i * mapWidth + j;
                                      parent[i, j] := 10 * deep_Thur + k;      // 穿越走法（变通的方向）
                                      if i * mapWidth + j = toPos then isFound := true;               // 到达目标
                                  end;
                                  tmpMap[i2, j2] := '$';     // 放回“被穿越的箱子”
                                  if isFound then break;
                                  
                              end;
                          end;
                      end;  // end k

                      if isFound then break;

                  end;
              end;  // end j

              if isFound then break;

          end;  // end i
       end;  // end 穿越排查

       if isFound then break;

   end;

   if isFound then begin  // 拼接路径
      t_er := toPos div mapWidth;
      t_ec := toPos mod mapWidth;
      while t_er * mapWidth + t_ec <> manPos do begin
          if (parent[t_er, t_ec] < 4) then begin
              ch := lurdChar[parent[t_er, t_ec]];                       // 动作字符：lurdLURD

              if Result = MaxLenPath then Exit;

              Inc(Result);
              ManPath[Result] := ch;

              t1 := t_er - dr4[parent[t_er, t_ec]];
              t2 := t_ec - dc4[parent[t_er, t_ec]];
              t_er := t1;
              t_ec := t2;
          end else begin
              if isBK then begin                  // 逆推
                  i1 := t_er + 3 * dr4[parent[t_er, t_ec] mod 10];
                  j1 := t_ec + 3 * dc4[parent[t_er, t_ec] mod 10];
                  i2 := t_er + 2 * dr4[parent[t_er, t_ec] mod 10];
                  j2 := t_ec + 2 * dc4[parent[t_er, t_ec] mod 10];
                  i3 := t_er + dr4[parent[t_er, t_ec] mod 10];
                  j3 := t_ec + dc4[parent[t_er, t_ec] mod 10];

                  tmpMap[i3, j3] := '-';
                  len := getPathForThrough(i2, j2, i1, j1, i3, j3, parent[t_er, t_ec] mod 10, parent[t_er, t_ec] div 10 - 1);
                  tmpMap[i3, j3] := '$';
                  
                  for k := 1 to len do begin
                     if Result = MaxLenPath then Exit;
                     Inc(Result);
                     ManPath[Result] := TrunPath[k];
                  end;

                  t1 := t_er + 2 * dr4[parent[t_er, t_ec] mod 10];
                  t2 := t_ec + 2 * dc4[parent[t_er, t_ec] mod 10];
              end else begin                      // 正推
                  i1 := t_er + dr4[parent[t_er, t_ec] mod 10];
                  j1 := t_ec + dc4[parent[t_er, t_ec] mod 10];
                  i2 := t_er - dr4[parent[t_er, t_ec] mod 10];
                  j2 := t_ec - dc4[parent[t_er, t_ec] mod 10];

                  tmpMap[i2, j2] := '-';
                  len := getPathForThrough(t_er, t_ec, i2, j2, i1, j1, parent[t_er, t_ec] mod 10, parent[t_er, t_ec] div 10 - 1);
                  tmpMap[i2, j2] := '$';

                  for k := 1 to len do begin
                     if Result = MaxLenPath then Exit;
                     Inc(Result);
                     ManPath[Result] := TrunPath[k];
                  end;

                  t1 := t_er - 2 * dr4[parent[t_er, t_ec] mod 10];
                  t2 := t_ec - 2 * dc4[parent[t_er, t_ec] mod 10];
              end;

              t_er := t1;
              t_ec := t2;
          end;
      end;
   end;
end;

// 检查 r1, c1 与 r2,c2 两点是否可达, 被穿越的箱子已被临时移动到 r, c
function TPathFinder.canThrough(isBK: Boolean; r, c, r1, c1, r2, c2, dir: Integer): Boolean;
var
  i1, i2, j1, j2, k, p, tail: Integer;

begin

    for i1 := 0 to mapHeight-1 do begin
        for j1 := 0 to mapWidth-1 do begin
            mark[i1][j1] := false;
        end;
    end;

    // 排查可达点的四邻（用循环取代递归）
    p := 0; tail := 0;
    mark[r1, c1] := true;
    pt0[0] := r1 * mapWidth + c1;
    while (p <= tail) do begin
        i2 := pt0[p] div mapWidth;
        j2 := pt0[p] mod mapWidth;
        for k := 0 to 3 do begin
            i1 := i2 + dr4[k];
            j1 := j2 + dc4[k];

            if (i1 < 0) or (j1 < 0) or (i1 >= mapHeight) or (j1 >= mapWidth) or ((i1 = r) and (j1 = c)) then continue  // 界外，或遇到穿越点箱子被临时推到的位置
            else if ((i1 = r2) and (j1 = c2)) then begin Result := True; Exit; end  // 穿越可达
            else if ('-' = tmpMap[i1, j1]) and (not mark[i1, j1]) then begin
                Inc(tail);
                pt0[tail] := i1 * mapWidth + j1;                // 新的足迹
                mark[i1, j1] := true;
            end;
        end;
        inc(p);
    end;

    if isBK then begin
       i1 := r1 + dr4[dir];
       j1 := c1 + dc4[dir];
    end else begin
       i1 := r2 + dr4[dir];
       j1 := c2 + dc4[dir];
    end;

    if (i1 < 0) or (j1 < 0) or (i1 >= mapHeight) or (j1 >= mapWidth) or (tmpMap[i1, j1] <> '-') then begin canThrough := False; Exit; end  // 界外
    else begin
        Inc(deep_Thur);
        
        // 再前进一步检查是否能够穿越
        if isBK then Result := canThrough(isBK, r1, c1, i1, j1, r, c, dir)
        else Result := canThrough(isBK, r2, c2, r, c, i1, j1, dir);
    end;
end;

// 计算并返回 nRow1, nCol1 与 nRow, nCol 两点间的穿越路径到 TurnPath，返回路径长度, , 点 nRow2, nCol2 是被穿越的箱子，且在穿越时，箱子需要临时移动到 nRow, nCol
function TPathFinder.getPathForThrough(nRow, nCol, nRow1, nCol1, nRow2, nCol2: Integer; dir: Byte; num: Integer): Integer;
var
  i, j, k, i1, j1, t1, t2, t_er, t_ec, p, tail, r, c: Integer;
  isFound: Boolean;
  ch: Char;
  
begin
    Result := 0;
    
    for i := 0 to mapHeight do begin
        for j := 0 to mapWidth do begin
            parent2[i, j] := -1;
            mark[i, j] := false;
        end;
    end;

    p := 0; tail := 0;
    isFound := false;

    // 根据直推次数，调整计算位置
    nRow1 := nRow1 + dr4[dir] * num;
    nCol1 := nCol1 + dc4[dir] * num;
    nRow2 := nRow2 + dr4[dir] * num;
    nCol2 := nCol2 + dc4[dir] * num;
    nRow  := nRow  + dr4[dir] * num;
    nCol  := nCol  + dc4[dir] * num;

    mark[nRow1, nCol1] := true;
    pt0[0] := nRow1 * mapWidth + nCol1;
    while p <= tail do begin
        r := pt0[p] div mapWidth;
        c := pt0[p] mod mapWidth;
        for k := 0 to 3 do begin
            i1 := r + dr4[k];
            j1 := c + dc4[k];
            if (i1 < 0) or (j1 < 0) or (i1 >= mapHeight) or (j1 >= mapWidth) or ((i1 = nRow) and (j1 = nCol)) then begin  // 界外，或遇到箱子临时位置
                continue;
            end else if (nRow2 = i1) and (nCol2 = j1) then begin  // 到达目标
                Inc(tail);
                pt0[tail] := i1 * mapWidth + j1;            // 新的足迹
                parent2[i1, j1] := k;          // 父节点到当前节点的方向
                isFound := true;
                break;
            end else if ('-' = tmpMap[i1, j1]) and (not mark[i1, j1]) then begin
                Inc(tail);
                pt0[tail] := i1 * mapWidth + j1;            // 新的足迹
                mark[i1, j1] := true;
                parent2[i1, j1] := k;          // 父节点到当前节点的方向
            end;
        end;
        if isFound then  break;
        Inc(p);
    end;

    // 拼接穿越路径 -- 逆序
    // 穿越中，路径“两端”的推动（出于效率及简化算法考虑，仅支持直推穿越）
    if isFound then begin

        t_er := nRow2; t_ec := nCol2;
        
        ch := lurdChar[parent2[t_er, t_ec]];         // 动作字符：lurdLURD
        
        case dir of
            0: ch := lurdChar[5];
            1: ch := lurdChar[4];
            2: ch := lurdChar[7];
            3: ch := lurdChar[6];
        end;
        
        // 箱子推回原位
        for k := 0 to num do begin
            Inc(Result);
            TrunPath[Result] := ch;
        end;
        
        // 穿越中，人的移动
        while (t_er <> nRow1) or (t_ec <> nCol1) do begin
            Inc(Result);
            TrunPath[Result] := lurdChar[parent2[t_er, t_ec]];   // 动作字符：lurdLURD

            t1 := t_er - dr4[parent2[t_er, t_ec]];
            t2 := t_ec - dc4[parent2[t_er, t_ec]];
            t_er := t1;
            t_ec := t2;
        end;

        // 箱子推至可穿越位置
        for k := 0 to num do begin
            Inc(Result);
            TrunPath[Result] := lurdChar[dir + 4];
        end;
    end;
end;


//参数：level -- 地图现场，boxPos -- 被点击的箱子
procedure TPathFinder.FindBlock(level: array of Integer; boxPos: Integer);
const
   dir: array[0..3] of Byte = ( 1, 0, 3, 2 );      // 换算父节点方向用

var
    boxR, boxC: Integer;
    i, j, k: Integer;

    // 循环法为“块”内的节点做标识
    procedure BlockrSign(r, c: Integer);
    var
      rr, cc, p, tail, k: Integer;

    begin
        // 将坐标用一个 int 存储
        ptBlock[0] := r * mapWidth + c;

        p := 0; tail := 0;
        while p <= tail do begin
            rr := ptBlock[p] div mapWidth;
            cc := ptBlock[p] mod mapWidth;
            inc(block[rr, cc, 0]);
            block[rr, cc, block[rr, cc, 0]] := b_count;

            for k := 0 to 3 do begin
                if (children[rr, cc] and mByte[k]) > 0 then begin
                    Inc(tail);
                    ptBlock[tail] := (rr + dr4[k]) * mapWidth + cc + dc4[k];
                end
            end;
            Inc(p);
        end;
    end;

    // 计算“割点”、“块”，从目标箱子位置 row, col 开始
    // mark 与 FindBlock() 中的复位相关联，记录箱子可达点
    procedure CutVertex(row, col: Integer);
    var
       i: Integer;

    begin
        mark[row, col] := true;                        // 已访问标记

        Inc(depth);
        depth_tag[row, col] := depth;
        low_tag[row, col]   := depth;                  // 标记 low 点

        for i := 0 to 3 do begin    
            if mark[row + dr4[i], col + dc4[i]] then begin   // 节点被访问过
                // 若非父节点, 那么标记其为“返祖边”
                if (parent[row, col] <> i) and (depth_tag[row + dr4[i], col + dc4[i]] < low_tag[row, col]) then
                    low_tag[row, col] := depth_tag[row + dr4[i], col + dc4[i]];
            end else if (tmpMap[row + dr4[i], col + dc4[i]] = '-') then begin      // 新的子节点
                parent[row + dr4[i], col + dc4[i]] := dir[i];                      // 标示父节点的动作方向
                children[row, col] := children[row, col] or mByte[i];              // 增加子树

                CutVertex(row + dr4[i], col + dc4[i]);

                if low_tag[row + dr4[i], col + dc4[i]] < low_tag[row, col] then begin   // 若子节点的 low 值小于其父节点的 low 值
                    low_tag[row, col] := low_tag[row + dr4[i]][col + dc4[i]];           // 重置其父节点的 low 值
                end else if low_tag[row + dr4[i], col + dc4[i]] >= depth_tag[row, col] then begin // 若子节点的 low 值大于其父节点的 low 值，则父节点为“割点”
                    if tmpBoxPos <> row * mapWidth +  col then begin
                        if not cut[row, col] then cut[row, col] := true;
                        // 标记“块”
                        Inc(block[i, j, 0]);
                        block[i, j, block[i, j, 0]] := b_count;        // 标记割点自身

                        BlockrSign((row + dr4[i]), col + dc4[i]);      // 标记此割点的子树
                        Dec(b_count);                                  // 块号减一
                        children[row, col] := children[row, col] and (not mByte[i]);  // 移除此“割点”及其子树
                    end;
                end;
            end;
        end;

        Dec(depth);
    end;

begin
    tmpBoxPos := boxPos;            // CutVertex()使用，被点击的箱子

    depth := 0;
    b_count := -1;                  // 块号有从 -1 递减来标示

    // 制作地图副本，以免影响原地图
    for i := 0 to mapHeight-1 do begin
        for j := 0 to mapWidth-1 do begin
            k := i * mapWidth + j;
            if (level[k] = WallCell) or (level[k] = EmptyCell) then tmpMap[i, j] := '#'
            else if (level[k] = BoxCell) or (level[k] = BoxGoalCell) then tmpMap[i, j] := '$'
            else tmpMap[i, j] := '-';

            mark[i, j]      := false;
            cut[i, j]       := false;
            parent[i, j]    := -1;
            children[i, j]  := 0;
            depth_tag[i, j] := 0;
            low_tag[i, j]   := 0;
            block[i, j, 0] := 0;
        end;
    end;

    boxR := boxPos div mapWidth;
    boxC := boxPos mod mapWidth;
    tmpMap[boxR, boxC] := '-';    // 计算割点时，暂时拿掉被点击的箱子
    CutVertex(boxR, boxC);        // 递归计算割点

    // 检查 DFS 的根节点
    j := 0;                       // 计数根节点的子树
    for k := 0 to 3 do begin
        if (children[boxR, boxC] and mByte[k]) > 0 then begin
            Inc(j);
            Inc(block[boxR, boxC, 0]);
            block[boxR, boxC, block[boxR, boxC, 0]] := b_count;

            BlockrSign(boxR + dr4[k], boxC + dc4[k]);
            Dec(b_count);
        end;
    end;
    
    if j >= 2 then begin          // 若根节点有两个以上的子树, 则根节点也是“割点”
        cut[boxR, boxC] := true;
    end;
end;

// 计算箱子的可达位置
procedure TPathFinder.boxReachable(isBK: Boolean; boxPos, manPos: Integer);
var
    i, j, k, r, c, newR, newC, mToR, mToC, box_R, box_C, man_R, man_C, Q_Pos, Q_Size, F, Box_F, Man_F: Integer;
    curMark: Byte;
    Q: array[0..9999] of Integer;

begin
    if isBK then curMark := $0F     // 逆推时，保留正推标志         
    else curMark := $F0;            // 正推时，保留逆推标志

    //各标志数组初始化
    for i := 0 to mapHeight-1 do begin
        for j := 0 to mapWidth-1 do begin
            boxMark[i][j]  := boxMark[i][j] and curMark;  // 是否可达
            mark0[i][j][0] := false;                      // 新节点的四方向（反向）是否已推
            mark0[i][j][1] := false;
            mark0[i][j][2] := false;
            mark0[i][j][3] := false;
        end;
    end;

    if isBK then curMark := $10     // 逆推时，保留正推标志
    else curMark := $01;            // 正推时，保留逆推标志

    // 初始位置检测
    F        := (boxPos shl 16) or manPos;
    Q_Pos    := 0;
    Q_Size   := 1;
    Q[Q_Pos] := F;

    boxMark[boxPos div mapWidth, boxPos mod mapWidth] := boxMark[boxPos div mapWidth, boxPos mod mapWidth] or curMark;  // 被点箱子

    while (Q_Size < 10000) and (Q_Pos < Q_Size) do begin
        F := Q[Q_Pos];    // 出队列
        inc(Q_Pos);
        Box_F := F shr 16;
        Man_F := F and $FFFF;

        box_R := Box_F div mapWidth;
        box_C := Box_F mod mapWidth;
        man_R := Man_F div mapWidth;
        man_C := Man_F mod mapWidth;

        for k := 0 to 3 do begin  // 检查f的四邻
            if mark0[box_R, box_C, k] then continue;  // 该节点的此方向（反）已推

            newR := box_R + dr4[k];  // 箱子新位置     
            newC := box_C + dc4[k];
            if isBK then begin         // 逆推
                mToR := newR;                             // 箱子至新位置，人需到的位置
                mToC := newC;

                // 界外，不计算
                r := newR + dr4[k];
                c := newC + dc4[k];
                if (r < 0) or (c < 0) or (r >= mapHeight) or (c >= mapWidth) or
                   (mToR < 0) or (mToC < 0) or (mToR >= mapHeight) or (mToC >= mapWidth) or
                   ('-' <> tmpMap[r, c]) or ('-' <> tmpMap[mToR, mToC]) then continue;
            end else begin
                mToR := box_R - dr4[k];                 // 箱子至新位置，人需到的位置
                mToC := box_C - dc4[k];

                // 界外，不计算
                if (newR < 0) or (newC < 0) or (newR >= mapHeight) or (newC >= mapWidth) or
                   (mToR < 0) or (mToC < 0) or (mToR >= mapHeight) or (mToC >= mapWidth) or
                   ('-' <> tmpMap[newR, newC]) or ('-' <> tmpMap[mToR, mToC]) then continue;
            end;
            if manTo2b(isBK, box_R, box_C, man_R, man_C, mToR, mToC) then begin                  // 人能否过来
                // 新可达点入列待查
                if isBK then F := ((newR * mapWidth + newC) shl 16) or ((newR + dr4[k]) * mapWidth + newC + dc4[k])
                else F := ((newR * mapWidth + newC) shl 16) or (box_R * mapWidth + box_C);
                Q[Q_Size] := F;
                inc(Q_Size);
                boxMark[newR, newC] := boxMark[newR, newC] or curMark;                           // 新的可达点
                mark0[box_R, box_C, k] := true;                                                  // 该节点的此方向（反）已推
            end;
        end;
    end;
end;

// 查看两点 firR, firC 和 secR, setC 是否人可达；boxR, boxC 为被点击的箱子的位置，其 boxR < 0 时，则不查看它
function TPathFinder.manTo2b(isBK: Boolean; boxR, boxC, firR, firC, secR, secC: Integer): Boolean;
var
    i, j: Integer;

begin
    if (firR = secR ) and (firC = secC) then begin Result := true; Exit; end;

    //点2 不是空地
    if (secR < 0) or (secC < 0) or (secR >= mapHeight) or (secC >= mapWidth) or ('-' <> tmpMap[secR, secC]) then begin Result := false; Exit; end;

    Result := False;

    if (not cut[boxR, boxC]) and (block[firR, firC, block[firR, firC, 0]] > 0) then begin
        Result := true;
        Exit;   // 被点击的箱子不在割点上
    end else begin
        for i := 1 to block[firR, firC, block[firR, firC, 0]] do begin  //两点在同一块内，必定可达
            for j := 1 to block[secR, secC, block[secR, secC, 0]] do begin
                if ( block[firR, firC, i] = block[secR, secC, j]) then begin
                   Result := true;
                   Exit;
                end;
            end;
        end;

        // 当割点法不可达时，做穿越检查
        if isThroughable or (tmpMap[boxR, boxC] = '-') then begin
            tmpMap[boxR, boxC] := '$';
            Result := manTo2(isBK, boxR, boxC, firR, firC, secR, secC);
            tmpMap[boxR, boxC] := '-';
        end;
    end;
end;

// 查看人是否可以从第一点 firR， firC 到达第二点 secR， setC
function TPathFinder.manTo2(isBK: Boolean; boxR, boxC, firR, firC, secR, secC: Integer): Boolean;
var
  i, j, k, i1, i2, i3, j1, j2, j3, p, tail, r, c: Integer;
  curMark: Byte;
  
begin
    Result := true;

    if (firR = secR) and (firC = secC) then Exit;

    if isBK then curMark := $0F     // 逆推时，保留正推标志
    else curMark := $F0;            // 正推时，保留逆推标志

    for i := 0 to mapHeight-1 do begin
        for j := 0 to mapWidth-1 do begin
//            if (level[i][j] == '-' || level[i][j] == '.' || level[i][j] == '@' || level[i][j] == '+') then tmpLevel[i][j] = '-'
//            else if (level[i][j] == '*') then tmpLevel[i][j] = '$'
//            else tmpLevel[i][j] = level[i][j];
            manMark[i, j] := manMark[i, j] and curMark;
        end;
    end;

    if isBK then curMark := $10     // 逆推时，保留正推标志
    else curMark := $01;            // 正推时，保留逆推标志

    pt[0] := firR * mapWidth + firC;
    manMark[firR, firC] := manMark[firR, firC] or curMark;
    p := 0; tail := 0;
    while p <= tail do begin         // 常规排查
        while p <= tail do begin
            r := pt[p] div mapWidth;
            c := pt[p] mod mapWidth;
            for k := 0 to 3 do begin
                i1 := r + dr4[k];
                j1 := c + dc4[k];
                if (i1 < 0) or (j1 < 0) or (i1 >= mapHeight) or (j1 >= mapWidth) then continue  // 界外
                else if ('-' = tmpMap[i1, j1]) and ((manMark[i1, j1] and curMark) = 0) then begin
                    Inc(tail);
                    pt[tail] := i1 * mapWidth + j1;            // 新的足迹
                    manMark[i1, j1] := manMark[i1, j1] or curMark;

                    if (secR = i1) and (secC = j1) then Exit;  // 到达目标
                end;
            end;
            Inc(p);
        end;
                                 
        // 穿越排查
        if isThroughable then begin     
            for i := 1 to mapHeight-2 do begin
                for j := 1 to mapWidth-2 do begin
                    if ('-' = tmpMap[i, j]) and ((manMark[i, j] and curMark) = 0) then begin
                        for k := 0 to 3 do begin
                            i1 := i - dr4[k];
                            j1 := j - dc4[k];
                            if (boxR >= 0) and (i1 = boxR) and (j1 = boxC) then begin
                                continue;               // 很重要，点击的箱子不可作为穿越点
                            end;
                            deep_Thur := 0;
                            if isBK then begin  // 逆推
                                i1 := i + 3 * dr4[k];
                                j1 := j + 3 * dc4[k];
                                i2 := i + 2 * dr4[k];
                                j2 := j + 2 * dc4[k];
                                i3 := i + dr4[k];
                                j3 := j + dc4[k];
                                if (i1 < 0) or (j1 < 0) or (i1 >= mapHeight) or (j1 >= mapWidth) or
                                   (i2 < 0) or (j2 < 0) or (i2 >= mapHeight) or (j2 >= mapWidth) or
                                   (i3 < 0) or (j3 < 0) or (i3 >= mapHeight) or (j3 >= mapWidth) then continue  // 界外
                                else if ('$' = tmpMap[i3, j3]) and ((manMark[i1, j1] and curMark) > 0) and ((manMark[i2, j2] and curMark) > 0) then begin
                                    tmpMap[i3, j3] := '-';
                                    if canThrough(isBK, i2, j2, i1, j1, i3, j3, k) then begin
                                        manMark[i, j] := manMark[i, j] or curMark;
                                        Inc(tail);
                                        pt[tail] := i * mapWidth + j;

                                        if (i = secR) and (j = secC) then begin  // 到达目标
                                            tmpMap[i3, j3] := '$';
                                            Exit;
                                        end;
                                    end;
                                    tmpMap[i3, j3] := '$';
                                end;
                            end else begin  // 正推
                                i1 := i + dr4[k];
                                j1 := j + dc4[k];
                                i2 := i - dr4[k];
                                j2 := j - dc4[k];
                                i3 := i - 2 * dr4[k];
                                j3 := j - 2 * dc4[k];
                                if (i1 < 0) or (j1 < 0) or (i1 >= mapHeight) or (j1 >= mapWidth) or
                                   (i2 < 0) or (j2 < 0) or (i2 >= mapHeight) or (j2 >= mapWidth) or
                                   (i3 < 0) or (j3 < 0) or (i3 >= mapHeight) or (j3 >= mapWidth) then continue  // 界外
                                else if ('$' = tmpMap[i2, j2]) and ('-' = tmpMap[i1, j1]) and ((manMark[i3, j3] and curMark) > 0) then begin
                                    tmpMap[i2, j2] := '-';
                                    if canThrough(isBK, i, j, i2, j2, i1, j1, k) then begin
                                        manMark[i, j] := manMark[i, j] or curMark;
                                        Inc(tail);
                                        pt[tail] := i * mapWidth + j;

                                        if (i = secR) and (j = secC) then begin  // 到达目标
                                            tmpMap[i2, j2] := '$';
                                            Exit;
                                        end;
                                    end;
                                    tmpMap[i2, j2] := '$';
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
    
    Result := false;
end;

// 计算箱子从 boxPos 到达 toPos 的最短路径
function TPathFinder.boxTo(isBK: Boolean; boxPos, toPos, manPos: Integer): Integer;
var
  i, j, k, boxR, boxC, toR, toC, manR, manC, newR, newC, mFromR, mFromC, mToR, mToC, r, c, box_R, box_C, man_R, man_C, H, G, T, DD, TT, GG, len, size: Integer;
  isFound: Boolean;
  PQ_Head, PQ: PBoxManNode;
  list1, list2: array[0..49999] of Integer;
  size1, size2, Node: Integer;
  Node_box_R, Node_box_C, Node_dir, Node_dir2: Integer;
  mDir, mDir0: ShortInt;
  tmpMap2: array[0..1] of Integer;
  ch: Char;

{$IFDEF LASTACT}
  act: string;
{$ENDIF}

  // 以此模拟优先队列
  procedure AddNode2(bpos, mpos, H, G, T, k: Integer; var myList: PBoxManNode);
  var
     x, y, z: PBoxManNode;
  begin
      New(x);
      x.boxPos := bpos;
      x.manPos := mpos;
      x.H := H;
      x.G := G;
      x.T := T;
      x.D := k;
      x.next := myList;
      myList := x;

      z := nil;
      while x.next <> nil do begin
          y := x.next;
          
          if x.T < y.T then begin             // 先比较转弯数
             Break;
          end else if x.T = y.T then begin
             if x.H < y.H then begin          // 再比较评估值
                Break;
             end else if x.H = y.H then begin
                if x.G < y.G then begin       // 最后比较推动消耗（步数）
                   Break;
                end;
             end;
          end;

          x.next := y.next;
          y.next := x;
          
          if z = nil then myList := y
          else z.next := y;

          z := y;
      end;
      x := nil;
      y := nil;
      z := nil;
  end;

begin
    Result := 0;

    if (boxPos = toPos) then Exit;

// 调试功能，当程序崩溃时，BoxMan.log 文档中，会记录之前的动作，避免造成太大的损失    
{$IFDEF LASTACT}
//   ReWrite(myLogFile_);
   Writeln(myLogFile_, '');
   Writeln(myLogFile_, DateTimeToStr(Now));
   if UnDoPos > 0 then begin
      if UnDoPos < MaxLenPath then UndoList[UnDoPos+1] := #0;
      act := PChar(@UndoList);
      Writeln(myLogFile_, act);
      Flush(myLogFile_);
   end;
   if UnDoPos_BK > 0 then begin
      man_R := ManPos_BK_0 div mapWidth+1;
      man_C := ManPos_BK_0 mod mapWidth+1;
      if UnDoPos_BK < MaxLenPath then UndoList_BK[UnDoPos_BK+1] := #0;
      act := '[' + inttostr(man_R) + ', ' + inttostr(man_C) + ']' + PChar(@UndoList_BK);
      Writeln(myLogFile_, act);
      Flush(myLogFile_);
   end;
{$ENDIF}

    for i := 0 to mapHeight-1 do begin
        for j := 0 to mapWidth-1 do begin
            mark0[i][j][0] := false;            // 节点的四方向（反向）是否已推
            mark0[i][j][1] := false;
            mark0[i][j][2] := false;
            mark0[i][j][3] := false;
        end;
    end;

    isFound := false;                           // 是否找到了有路径

    boxR := boxPos div mapWidth;
    boxC := boxPos mod mapWidth;
    toR  := toPos  div mapWidth;
    toC  := toPos  mod mapWidth;
    manR := manPos div mapWidth;
    manC := manPos mod mapWidth;

    New(PQ);
    PQ.boxPos := boxPos;                         // 初始位置入队列，待查其四邻
    PQ.manPos := manPos;
    PQ.H := abs(boxR - toR) + abs(boxC - toC);
    PQ.G := 0;
    PQ.T := -1;
    PQ.D := -1;
    PQ.next := nil;

    size1 := 0;
    size2 := 0;

    while not isFound and (PQ <> nil) do begin
        PQ_Head := PQ;
        PQ := PQ.next;
        box_R := PQ_Head.boxPos div mapWidth;
        box_C := PQ_Head.boxPos mod mapWidth;
        man_R := PQ_Head.manPos div mapWidth;
        man_C := PQ_Head.manPos mod mapWidth;
        DD := PQ_Head.D;
        TT := PQ_Head.T;
        GG := PQ_Head.G;
        Dispose(PQ_Head);
        PQ_Head := nil;

        for k := 0 to 3 do begin         // 检查f的四邻
            if mark0[box_R, box_C, k] then continue;  // 该节点的此方向（反）已推

            newR := box_R + dr4[k];      // 箱子新位置
            newC := box_C + dc4[k];
            if isBK then begin           // 逆推
                mToR := newR;            // 箱子至新位置，人需到的位置
                mToC := newC;
                r := newR + dr4[k];
                c := newC + dc4[k];
                if (r < 0) or (c < 0) or (r >= mapHeight) or (c >= mapWidth) or
                   (mToR < 0) or (mToC < 0) or (mToR >= mapHeight) or (mToC >= mapWidth) or
                   ('-' <> tmpMap[r, c]) or ('-' <> tmpMap[mToR, mToC]) then continue;
            end else begin
                mToR := box_R - dr4[k];  // 箱子至新位置，人需到的位置
                mToC := box_C - dc4[k];
                if (newR < 0) or (newC < 0) or (newR >= mapHeight) or (newC >= mapWidth) or
                   (mToR < 0) or (mToC < 0) or (mToR >= mapHeight) or (mToC >= mapWidth) or
                   ('-' <> tmpMap[newR, newC]) or ('-' <> tmpMap[mToR, mToC]) then continue;
            end;
            if manTo2b(isBK, box_R, box_C, man_R, man_C, mToR, mToC) then begin   // 人能否过来
                mark0[box_R, box_C, k] := true;          // 该节点的此方向（反）已推

                H := abs(newR - toR) + abs(newC - toC);  // 评估值，尽量向目标点靠拢
                if (DD = k) then T := TT                // 转弯累计值，以此作为优先队列中节点比较的主力
                else T := TT + 1;
                G := GG + 1;

                if isBK then AddNode2(newR * mapWidth + newC, (newR + dr4[k]) * mapWidth + newC + dc4[k], H, G, T, k, PQ)
                else AddNode2(newR * mapWidth + newC, box_R * mapWidth + box_C, H, G, T, k, PQ);

                list1[size1] := (DD shl 24) or (k shl 16) or (newC shl 8) or newR;  // k - 父节点，DD - 父节点的父节点
                Inc(size1);

                if (newR = toR) and (newC = toC) then begin     // 到达目标点
                    isFound := true;
                    break;
                end;
            end;
        end;
    end;

    if (isFound) then begin  // 找到了路径

        mToR  := toR;        // 箱子目标
        mToC  := toC;

        mDir0 := -1;

        while size1 > 0 do begin  // 取得纯箱子移动的路径送入 list2
            Dec(size1);
            Node := list1[size1];

            Node_box_R :=  Node and $FF;
            Node_box_C := (Node shr 8 ) and $FF;
            Node_dir   := (Node shr 16) and $FF;
            Node_dir2  := (Node shr 24) and $FF;

            if (Node_box_R <> mToR) or (Node_box_C <> mToC) or (mDir0 >= 0) and (mDir0 <> Node_dir) then continue;

            list2[size2] := Node;
            Inc(size2);

            mToR  := Node_box_R - dr4[Node_dir];
            mToC  := Node_box_C - dc4[Node_dir];

            mDir0 := Node_dir2;               // 父节点的父节点
        end;

        mDir0 := -1;
        
        // 箱子和人推动前的位置
        newR   := boxR;
        newC   := boxC;
        mFromR := manR;
        mFromC := manC;

        while size2 > 0 do begin         // 加入人移动的路径
            Dec(size2);
            mDir := (list2[size2] shr 16) and $FF;
            if isBK then begin                 // 逆推
                mToR := newR + dr4[mDir];
                mToC := newC + dc4[mDir];
            end else begin
                mToR := newR - dr4[mDir];
                mToC := newC - dc4[mDir];
            end;

            if (mDir = mDir0) then begin       // 箱子移动方向没有改变
                if Result = MaxLenPath then Exit;
                ch := lurdChar[mDir + 4];
                Inc(Result);
                BoxPath[Result] := ch;
            end else begin                     // 箱子改变了移动方向
                tmpMap[newR, newC] := '$';

                len := manTo(isBK, tmpMap2, mFromR * mapWidth + mFromC, mToR * mapWidth + mToC);  // 计算人移位路径
                
                tmpMap[newR, newC] := '-';

                for k := len downto 1 do begin
                    if Result = MaxLenPath then Exit;
                    Inc(Result);
                    BoxPath[Result] := ManPath[k];
                end;

                ch := lurdChar[mDir + 4];

                if Result = MaxLenPath then Exit;
                Inc(Result);
                BoxPath[Result] := ch;

                mDir0 := mDir;
            end;
            if isBK then begin               // 逆推
                newR   := mToR;              // 箱子进一位（人在箱子前面）
                newC   := mToC;
                mFromR := newR + dr4[mDir];  // 人进一位（人在箱子前面）
                mFromC := newC + dc4[mDir];
            end else begin
                mFromR := newR;              // 人到箱子的位置（人在箱子后面）
                mFromC := newC;
                newR   := newR + dr4[mDir];  // 箱子进一位
                newC   := newC + dc4[mDir];
            end;
        end;
    end;
end;

end.
