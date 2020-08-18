unit LoadMapUnit;    // 关卡文本解析单元

interface

uses
  windows, classes, StrUtils, SysUtils, Clipbrd, Math, CRC_32, SQLiteTable3;

type
  TLoadMapThread = class(TThread)         // 解析并加载全部关卡的后台线程
  protected
    procedure Execute; override;
  public
  end;

type
  TLoadAnsThread = class(TThread)         // 导入答案的后台线程
  protected
    procedure UpdateCaption;
    procedure Execute; override;
  public
  end;

type                  // 关卡节点 -- 关卡集中的各个关卡
  TMapNode = record
    Map_Thin: string;           // 最简关卡 XSB
    Map: TStringList;           // 关卡 XSB
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

function LoadMapsFromTextList(data_Text: TStringList; isAns: Boolean): boolean;                   // 加载关卡 -- 从 TStringList 中，isAns -- 是否加载答案

procedure QuicklyLoadMap(data_Text: TStringList; number: Integer; var curMap: PMapNode);  // 迅速的加载指定序号 number 的关卡

function GetMapNumber(data_Text: TStringList): Integer;              // 取得关卡数

function FindClipbrd(num: Integer): Integer;                         // 在关卡列表中，查找剪切板中的关卡，返回找到的序号，没找到则返回 -1

function MapNormalize(var mapNode: PMapNode): Boolean;               // 地图标准化，包括：简单标准化 -- 保留关卡的墙外造型；精准标准化 -- 不保留关卡的墙外造型，同时计算 CRC 等

function isSolution(mapNode: PMapNode; sol: PChar): Boolean;         // 答案验证

procedure MyStringListFree(var _StringList_: TStringList);           // 释放 TStringList 的内存

procedure MyListClear(var _List_: TList);                            // 清空关卡列表

function GetXSB(mapNpde: PMapNode): string;                          // 取得关卡 XSB

function GetXSB_2(): string;                                        // 取得现场 XSB

procedure XSBToClipboard();                                         // XSB 送入剪切板

procedure XSBToClipboard_2();                                       // 现场 XSB 送入剪切板

procedure Split(src: string; var myList: TStringList);              // 分割字符串

var
  isStopThread: Boolean;                   // 是否终止后台线程
  isStopThread_Ans: Boolean;               // 是否终止后台线程
  ManPos_BK_0: integer;                    // 人的位置 -- 逆推，玩家已经指定的位置
  ManPos_BK_0_2: integer;                  // 人的位置 -- 逆推，解析出来的位置

  sMoves, sPushs: integer;                 // 验证答案时，记录移动数和推动数

  sumSolution: Integer;                    // 成功导入的答案个数

  MapCount: Integer;                       // 已经解析出来的关卡数
  MapList: TList;                          // 关卡列表
  MapArray: array[0..99, 0..99] of Char;   // 标准化用关卡数组
  Mark: array[0..99, 0..99] of Boolean;    // 标准化用标志数组
  curMapNode: PMapNode;                    // 当前关卡节点

  tmp_Board: array[0..9999] of integer;    // 临时地图

  // 标准化用关卡数组
  aMap0: array[0..99, 0..99] of Char;
  aMap1: array[0..99, 0..99] of Char;
  aMap2: array[0..99, 0..99] of Char;
  aMap3: array[0..99, 0..99] of Char;
  aMap4: array[0..99, 0..99] of Char;
  aMap5: array[0..99, 0..99] of Char;
  aMap6: array[0..99, 0..99] of Char;
  aMap7: array[0..99, 0..99] of Char;

  xbsChar: array[0..7] of Char = ( '_', '#', '-', '.', '$', '*', '@', '+' );

implementation

uses
  MainForm, LogFile, OpenFile;

const
  EmptyCell = 0;
  WallCell = 1;
  FloorCell = 2;
  GoalCell = 3;
  BoxCell = 4;
  BoxGoalCell = 5;
  ManCell = 6;
  ManGoalCell = 7;

  // 四邻常量：左、右、上、下
  dr4 : array[0..3] of Integer = (  0, 0, -1, 1 );
  dc4 : array[0..3] of Integer = ( -1, 1,  0, 0 );

var
  pt: array[0..9999] of Integer;        // 在“关卡标准化功能中，用数组替代“队列”

// 释放 TStringList 的内存
procedure MyStringListFree(var _StringList_: TStringList);
begin
  if Assigned(_StringList_) then begin
     _StringList_.Clear;
     _StringList_.Free;
     _StringList_ := nil;
  end;
end;

// 清空关卡列表（TList类型）
procedure MyListClear(var _List_: TList);
var
  i, len: Integer;
begin
  if not Assigned(_List_) then exit;

  if Assigned(_List_) then begin
    len := _List_.Count;
    for i := len-1 downto 0 do begin
        if Assigned(PMapNode(_List_.Items[i])) then begin
           MyStringListFree(PMapNode(_List_.Items[i]).Map);
           Dispose(PMapNode(_List_.Items[i]));
           _List_.Items[i] := nil;
        end;
    end;
    _List_.Clear;
  end;
end;

// 取得子串最后出现的位置
function LastPos(const SubStr, Str: ansistring): Integer;
var
  Idx: Integer;
begin
  Result := 0;
  Idx := StrUtils.PosEx(SubStr, Str);
  if Idx = 0 then Exit;
  while Idx > 0 do begin
    Result := Idx;
    Idx := StrUtils.PosEx(SubStr, Str, Idx + 1);
  end;
end;

// 判断是否为有效的 Lurd 行
function isLurd(str: String; is_BK: Boolean = False): boolean;
var
  n, k: Integer;

begin
  result := False;

  n := Length(str);

  if n = 0 then exit;    
  
  k := 1;
  while k <= n do begin
     if not (str[k] in [ 'l', 'u', 'r', 'd', 'L', 'U', 'R', 'D', ' ', #9 ]) then Break;
     k := k+1;
  end;

  result := k > n;
end;

// 判断是否为有效的 Lurd 行
function isLurd_2(str: String): boolean;
var
  n, k: Integer;

begin
  result := False;

  n := Length(str);

  if n = 0 then exit;    
  
  k := 1;
  while k <= n do begin
     if not (str[k] in [ 'l', 'u', 'r', 'd', 'L', 'U', 'R', 'D', ',', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ' ', '[', ']', ' ', #9 ]) then Break;
     k := k+1;
  end;

  result := k > n;
end;

// 判断是否为有效的 XSB 行
function isXSB(str: string): boolean;
var
  n, k: Integer;
begin
  result := False;

  n := Length(str);

  if n = 0 then exit;

  k := 1;
  // 检查是否是空行 -- 仅有空格和跳格符
  while k <= n do begin
    if (str[k] <> #20) and (str[k] <> #9) or (str[k] = '') then Break;
    k := k+1;
  end;
  if k > n then Exit;

  k := 1;
  while k <= n do begin
    if not (str[k] in [ #9, ' ', '_', '-', '#', '.', '$', '*', '@', '+']) then Break;
    k := k+1;
  end;

  result := k > n;
end;

// 答案验证
function isSolution(mapNode: PMapNode; sol: PChar): Boolean;
var
  i, j, len, mpos, pos1, pos2, okNum, size, Rows, Cols: Integer;
  isPush: Boolean;
  ch: Char;
begin
  Result := False;

  // 临时地图复位
  mpos := -1;
  Rows := mapNode.Rows;
  Cols := mapNode.Cols;
  size := Rows * Cols;
  for i := 0 to Rows - 1 do begin
    for j := 1 to Cols do begin
      ch := mapNode.Map[i][j];
      case ch of
        '#':
          tmp_Board[i * Cols + j] := WallCell;
        '-':
          tmp_Board[i * Cols + j] := FloorCell;
        '.':
          tmp_Board[i * Cols + j] := GoalCell;
        '$':
          tmp_Board[i * Cols + j] := BoxCell;
        '*':
          tmp_Board[i * Cols + j] := BoxGoalCell;
        '@':
          tmp_Board[i * Cols + j] := ManCell;
        '+':
          tmp_Board[i * Cols + j] := ManGoalCell;
      else
        tmp_Board[i * Cols + j] := EmptyCell;
      end;

      if ch in ['@', '+'] then mpos := i * Cols + j;
    end;
  end;

  if mpos < 0 then Exit;
  
  sPushs := 0;
  sMoves := 0;

  // 答案验证
  len := Length(sol);
  for i := 0 to len - 1 do begin
    pos1 := -1;
    pos2 := -1;
    ch := sol[i];
    // 按关卡旋转变换动作字符
//    case ch of
//       'l': ch := ActDir[mapNode.Trun, 0];
//       'u': ch := ActDir[mapNode.Trun, 1];
//       'r': ch := ActDir[mapNode.Trun, 2];
//       'd': ch := ActDir[mapNode.Trun, 3];
//       'L': ch := ActDir[mapNode.Trun, 4];
//       'U': ch := ActDir[mapNode.Trun, 5];
//       'R': ch := ActDir[mapNode.Trun, 6];
//       'D': ch := ActDir[mapNode.Trun, 7];
//    end;
    case ch of
      'l', 'L':
        begin
          pos1 := mpos - 1;
          pos2 := mpos - 2;
        end;
      'r', 'R':
        begin
          pos1 := mpos + 1;
          pos2 := mpos + 2;
        end;
      'u', 'U':
        begin
          pos1 := mpos - mapNode.Cols;
          pos2 := mpos - mapNode.Cols * 2;
        end;
      'd', 'D':
        begin
          pos1 := mpos + mapNode.Cols;
          pos2 := mpos + mapNode.Cols * 2;
        end;
    end;

    if (pos1 < 0) or (pos1 >= size) then   // pos1 界外
       Exit;

    isPush := False;
    if tmp_Board[pos1] = FloorCell then begin
       tmp_Board[pos1] := ManCell;
    end else if tmp_Board[pos1] = GoalCell then begin
       tmp_Board[pos1] := ManGoalCell;
    end else if tmp_Board[pos1] = BoxCell then begin
       if (pos2 < 0) or (pos2 >= size) then // pos2 界外
          Exit;

       if tmp_Board[pos2] = FloorCell then begin
          tmp_Board[pos2] := BoxCell;
       end else if tmp_Board[pos2] = GoalCell then begin
          tmp_Board[pos2] := BoxGoalCell;
       end else Exit;                       // 错误

       tmp_Board[pos1] := ManCell;

       isPush := True;
    end else if tmp_Board[pos1] = BoxGoalCell then begin
       if (pos2 < 0) or (pos2 >= size) then // pos2 界外
          Exit;
          
       if tmp_Board[pos2] = FloorCell then begin
          tmp_Board[pos2] := BoxCell;
       end else if tmp_Board[pos2] = GoalCell then begin
          tmp_Board[pos2] := BoxGoalCell;
       end else Exit;                       // 错误

       tmp_Board[pos1] := ManGoalCell;

       isPush := True;
    end else Exit;;                        // 错误

    if tmp_Board[mpos] = ManCell then
      tmp_Board[mpos] := FloorCell
    else
      tmp_Board[mpos] := GoalCell;

    if isPush then sPushs := sPushs+1;
    sMoves := sMoves+1;

    mpos := pos1;

    okNum := 0;
    for j := 0 to size - 1 do begin
      if (tmp_Board[j] = BoxGoalCell) then
        okNum := okNum+1;

      if okNum = mapNode.Boxs then begin                     // 能够解关，为有效答案
        Result := True;
        Exit;
      end;
    end;
  end;

  Result := False;
end;

// 创建新的关卡节点
procedure NewMapNode(var mpList: TList);
var
  mapNode: PMapNode;               // 关卡节点
begin
  New(mapNode);
  mapNode.Map := TStringList.Create;

  mapNode.Map_Thin := '';
  mapNode.Rows := 0;
  mapNode.Cols := 0;
  mapNode.Trun := 0;
  mapNode.Title := '';
  mapNode.Author := '';
  mapNode.Comment := '';
  mapNode.CRC32 := -1;
  mapNode.CRC_Num := -1;
  mapNode.Solved := false;

  mpList.Add(mapNode);          // 加入关卡集列表
  mapNode := nil;
end;

// 原始 XSB 送入剪切板
procedure XSBToClipboard();
begin
  if Assigned(curMapNode) and (curMapNode.Map.Count > 0) then
  begin
    Clipboard.SetTextBuf(PChar(GetXSB(curMapNode)));
  end;
end;

// 现场 XSB 送入剪切板
procedure XSBToClipboard_2();
begin
  if Assigned(curMapNode) and (curMapNode.Map.Count > 0) then
  begin
    Clipboard.SetTextBuf(PChar(GetXSB_2()));
  end;
end;

// 导入时，若发现答案，则导入答案库
procedure SetSolved(mapNode: PMapNode; var Solitions: TStringList);
var
  sldb: TSQLiteDatabase;
  sltb: TSQLIteTable;
  sSQL: String;
  i, l, solCRC: Integer;
  is_Solved: Boolean;
begin
  is_Solved := false;
  mapNode.Solved := false;

  sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));

  try
    if sldb.TableExists('Tab_Solution') then begin
      // 若解析到了答案，则验证答案并将答案入库
      if Solitions.Count > 0 then begin
        l := Solitions.Count;
        for i := l - 1 downto 0 do begin
          if isSolution(mapNode, PChar(Solitions[i])) then begin       // 对答案进行验证
            // 保存答案到数据库
            sSQL := 'select * from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNode.CRC32) + ' and Goals = ' + IntToStr(mapNode.Boxs);
            sltb := slDb.GetTable(sSQL);

            try
              solCRC := Calcu_CRC_32_2(PChar(Solitions[i]), Length(Solitions[i]));
              sltb.MoveFirst;
              while not sltb.EOF do begin
                if (sltb.FieldAsInteger(sltb.FieldIndex['Sol_CRC32']) = solCRC) and (sltb.FieldAsInteger(sltb.FieldIndex['Moves']) = sMoves) and (sltb.FieldAsInteger(sltb.FieldIndex['Pushs']) = sPushs) then
                  Break;
                    
                sltb.Next;
              end;

              // 没有重复答案，则添加到答案库
              if sltb.EOF then begin
                 sldb.BeginTransaction;

                 sSQL := 'INSERT INTO Tab_Solution (XSB_CRC32, XSB_CRC_TrunNum, Goals, Sol_CRC32, Moves, Pushs, Sol_Text, XSB_Text, Sol_DateTime) ' +
                         'VALUES (' +
                         IntToStr(mapNode.CRC32) + ', ' +
                         IntToStr(mapNode.CRC_Num) + ', ' +
                         IntToStr(mapNode.Boxs) + ', ' +
                         IntToStr(solCRC) + ', ' +
                         IntToStr(sMoves) + ', ' +
                         IntToStr(sPushs) + ', ''' +
                         Solitions[i] + ''', ''' +
                         mapNode.Map_Thin + ''', ''' +
                         FormatDateTime(' yyyy-mm-dd hh:nn', now) + ''');';

                 sldb.ExecSQL(sSQL);

                 sldb.Commit;
                 sumSolution := sumSolution + 1;           // 成功导入的答案个数
              end;
            finally
              sltb.free;
            end;
          end else begin
            Solitions.Delete(i);
          end;
        end;
        is_Solved := True;
        Solitions.Clear;
      end;

      if is_Solved then mapNode.Solved := is_Solved
      else begin
        // 数据库中是否有解
        sSQL := 'select id from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNode.CRC32) + ' and Goals = ' + IntToStr(mapNode.Boxs);
        sltb := slDb.GetTable(sSQL);
        try
          mapNode.Solved := sltb.Count > 0;
        finally
          sltb.Free;
        end;
      end;
    end;
  finally
    sldb.free;
  end;
end;

// 导入答案入答案库
procedure SetSolved_2(mapNode: PMapNode; var Solitions: TStringList);
var
  sldb: TSQLiteDatabase;
  sltb: TSQLIteTable;
  sSQL: String;
  i, l, solCRC: Integer;
  is_Solved: Boolean;
begin
  is_Solved := false;
  mapNode.Solved := false;

  sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));

  try
    if sldb.TableExists('Tab_Solution') then begin
      // 若解析到了答案，则验证答案并将答案入库
      if Solitions.Count > 0 then begin
        l := Solitions.Count;
        for i := l - 1 downto 0 do begin
          if isSolution(mapNode, PChar(Solitions[i])) then begin       // 对答案进行验证
            // 保存答案到数据库
            sSQL := 'select * from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNode.CRC32) + ' and Goals = ' + IntToStr(mapNode.Boxs);
            sltb := slDb.GetTable(sSQL);

            try
              solCRC := Calcu_CRC_32_2(PChar(Solitions[i]), Length(Solitions[i]));
              sltb.MoveFirst;
              while not sltb.EOF do begin
                if (sltb.FieldAsInteger(sltb.FieldIndex['Sol_CRC32']) = solCRC) and (sltb.FieldAsInteger(sltb.FieldIndex['Moves']) = sMoves) and (sltb.FieldAsInteger(sltb.FieldIndex['Pushs']) = sPushs) then
                  Break;
                    
                sltb.Next;
              end;

              // 没有重复答案，则添加到答案库
              if sltb.EOF then begin
                 sldb.BeginTransaction;

                 sSQL := 'INSERT INTO Tab_Solution (XSB_CRC32, XSB_CRC_TrunNum, Goals, Sol_CRC32, Moves, Pushs, Sol_Text, XSB_Text, Sol_DateTime) ' +
                         'VALUES (' +
                         IntToStr(mapNode.CRC32) + ', ' +
                         IntToStr(mapNode.CRC_Num) + ', ' +
                         IntToStr(mapNode.Boxs) + ', ' +
                         IntToStr(solCRC) + ', ' +
                         IntToStr(sMoves) + ', ' +
                         IntToStr(sPushs) + ', ''' +
                         Solitions[i] + ''', ''' +
                         mapNode.Map_Thin + ''', ''' +
                         FormatDateTime(' yyyy-mm-dd hh:nn', now) + ''');';

                 sldb.ExecSQL(sSQL);

                 sldb.Commit;
                 sumSolution := sumSolution + 1;           // 成功导入的答案个数
              end;
            finally
              sltb.free;
            end;
          end else begin
            Solitions.Delete(i);
          end;
        end;
        is_Solved := True;
        Solitions.Clear;
      end;

      if is_Solved then mapNode.Solved := is_Solved
      else begin
        // 数据库中是否有解
        sSQL := 'select id from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNode.CRC32) + ' and Goals = ' + IntToStr(mapNode.Boxs);
        sltb := slDb.GetTable(sSQL);
        try
          mapNode.Solved := sltb.Count > 0;
        finally
          sltb.Free;
        end;
      end;
    end;
  finally
    sldb.free;
  end;
end;

// 迅速加载指定序号的关卡
procedure QuicklyLoadMap(data_Text: TStringList; number: Integer; var curMap: PMapNode);
var
  line, line2: string;
  is_XSB: Boolean;                 // 是否正在解析关卡XSB
  is_Comment: Boolean;             // 是否正在解析关卡说明信息
  n, k, len, num: Integer;         // XSB的解析控制
begin
  curMap.Map := TStringList.Create;

  try
    curMap.Map_Thin := '';
    curMap.Rows := 0;
    curMap.Cols := 0;
    curMap.Trun := 0;
    curMap.Title := '';
    curMap.Author := '';
    curMap.Comment := '';
    curMap.CRC32 := -1;
    curMap.CRC_Num := -1;
    curMap.Solved := false;
    curMap.isEligible := True;      // 默认是合格的关卡 XSB
    curMap.Num := 0;

    is_XSB := False;
    is_Comment := False;

    len := data_Text.Count;
    k := 0;
    num := 0;
    while (k < len) do begin
      line  := data_Text.Strings[k];
      line2 := Trim(line);
      k := k+1;

      if (not is_Comment) and isXSB(line) then begin       // 检查是否为 XSB 行
        if not is_XSB then begin     // 开始 XSB 块

          if (curMap.Rows > 2) or (num = 0) then
             num := num+1;     // 遇到的第 num 个 XSB 块

          if num > number then  Break;

          is_XSB := True;    // 开始关卡 XSB 块
          is_Comment := False;
          curMap.Map.Clear;
          curMap.Rows := 0;
          curMap.Num := num;
        end;

        if num = number then begin
           curMap.Map.Add(line);      // 各 XSB 行
        end;
        curMap.Rows := curMap.Rows+1;

      end
      else if (not is_Comment) and (AnsiStartsText('title', line2)) and (curMap.Title = '') then begin   // 匹配 Title，标题
        if num = number then begin
           n := Pos(':', line2);
           if n > 0 then
              curMap.Title := trim(Copy(line2, n + 1, MaxInt))
           else
              curMap.Title := trim(Copy(line2, 6, MaxInt));
        end;

        if is_XSB then is_XSB := false;      // 结束关卡SXB的解析
      end
      else if (not is_Comment) and (AnsiStartsText('author', line2)) and (curMap.Author = '') then begin  // 匹配 Author，作者
        if num = number then begin
           n := Pos(':', line2);
           if n > 0 then
             curMap.Author := trim(Copy(line2, n + 1, MaxInt))
           else
             curMap.Author := trim(Copy(line2, 7, MaxInt));
        end;

        if is_XSB then is_XSB := false;      // 结束关卡SXB的解析
      end
      else if (AnsiStartsText('comment-end', line2)) or (AnsiStartsText('comment_end', line2)) then begin  // 匹配"注释"块结束
        is_Comment := False;   // 结束"注释"块
      end
      else if AnsiStartsText('comment', line2) and (curMap.Comment = '') then begin  //匹配"注释"块开始
        if is_XSB then is_XSB := false;      // 结束关卡SXB的解析
        n := Pos(':', line2);
        if n > 0 then
          line := trim(Copy(line2, n + 1, MaxInt))
        else
          line := trim(Copy(line2, 8, MaxInt));

        if Length(line) > 0 then begin
          if num = number then
            curMap.Comment := line;     // 单行"注释"
        end
        else
          is_Comment := True;          // 多行"注释"块
      end
      else if is_Comment then begin  // "说明"信息
        if num = number then begin
          if Length(curMap.Comment) > 0 then
            curMap.Comment := curMap.Comment + #10 + line
          else
            curMap.Comment := line;
        end;
      end
      else begin
        if is_XSB then is_XSB := false;      // 结束关卡SXB块的解析
      end;
    end;

    // 检查最后的节点，若没有 XSB 数据，则将其删除
    if (curMap.Rows > 2) then begin
       MapNormalize(curMap);
    end else begin
      curMap.Map.Clear;
      curMap.Rows := 0;
    end;
  except
    curMap.Map.Clear;
    curMap.Rows := 0;
  end;
end;

// 取得包含的关卡总数
function GetMapNumber(data_Text: TStringList): Integer;
var
  line, line2: string;
  is_XSB: Boolean;                 // 是否正在解析关卡XSB
  is_Comment: Boolean;             // 是否正在解析关卡说明信息
  n, k, len, Rows: Integer;        // XSB的解析控制
begin
  Result := 0;

  Rows := 0;

  try

    is_XSB := False;
    is_Comment := False;

    len := data_Text.Count;
    k := 0;
    while (k < len) do begin
      line  := data_Text.Strings[k];
      line2 := Trim(line);
      k := k+1;

      if (not is_Comment) and isXSB(line) then begin       // 检查是否为 XSB 行
        if not is_XSB then begin     // 开始 XSB 块

          if (Rows > 2) or (Result = 0) then
             Result := Result+1;     // 遇到的第 num 个 XSB 块

          if Result >= MaxInt then begin
             Break;
          end;

          is_XSB := True;    // 开始关卡 XSB 块
          is_Comment := False;
          Rows := 0;
        end;

        Rows := Rows+1;

      end
      else if (AnsiStartsText('comment-end', line2)) or (AnsiStartsText('comment_end', line2)) then begin  // 匹配"注释"块结束
        is_Comment := False;   // 结束"注释"块
      end
      else if AnsiStartsText('comment', line2) then begin  //匹配"注释"块开始
        if is_XSB then is_XSB := false;      // 结束关卡SXB的解析
        n := Pos(':', line2);
        if n > 0 then
          line := trim(Copy(line2, n + 1, MaxInt))
        else
          line := trim(Copy(line2, 8, MaxInt));

        if Length(line) <= 0 then is_Comment := True;          // 多行"注释"块
      end
      else if is_Comment then begin  // "说明"信息
      end
      else begin
        if is_XSB then is_XSB := false;      // 结束关卡SXB块的解析
      end;
    end;

  finally
    // 检查最后的节点，若没有 XSB 数据，则将其删除
    if (Rows < 3) then begin
       Result := Result - 1;
    end;
  end;
end;

// 分割字符串
procedure Split(src: string; var myList: TStringList);
var
  i: integer;
  str: string;
begin
  src := StringReplace(src, #13, #10, [rfReplaceAll]);
//  i := 1;
//  while i > 0 do begin
     src := StringReplace(src, #10#10, #10, [rfReplaceAll]);
//     i := pos(#10#10, src);
//  end;

  repeat
    i := pos(#10, src);
    str := copy(src, 1, i - 1);
    if (str = '') and (i > 0) then
    begin
      myList.Add('');
      delete(src, 1, 1);
      continue;
    end;
    if i > 0 then
    begin
      myList.Add(str);
      delete(src, 1, i);
    end;
  until i <= 0;
  if src <> '' then
    myList.Add(src);
end;

// 解析 TStringList 中的关卡信息
function LoadMapsFromTextList(data_Text: TStringList; isAns: Boolean): boolean;
var
  line, line2: string;
  is_XSB: Boolean;                 // 是否正在解析关卡XSB
  is_Solution: Boolean;            // 是否答案行
  is_Comment: Boolean;             // 是否正在解析关卡说明信息
  num, n, k, len: Integer;              // XSB的解析控制
  mapNode: PMapNode;               // 解析出的当前关卡节点指针
  mapSolution: TStringList;        // 关卡答案
  tmpList: TList;
begin
  Result := False;

  if (not Assigned(data_Text)) or (data_Text.Count <= 0) then Exit;

  MyListClear(MapList);
  tmpList := TList.Create;                    // 临时关卡列表

  try
    mapSolution := TStringList.Create;

    try

      NewMapNode(tmpList);                // 先创建一个关卡节点
      mapNode := tmpList.Items[0];        // 指向最新创建的节点
      mapNode.isEligible := True;         // 默认是合格的关卡XSB
      is_XSB := False;
      is_Comment := False;
      is_Solution := False;

      sumSolution := 0;
      k := 0;
      len := data_Text.Count;
      while k < len do begin

        line := data_Text.Strings[k];     // 读取一行
        k := k+1;
        line2 := Trim(line);

        if (not is_Comment) and isXSB(line) then begin       // 检查是否为 XSB 行
          if not is_XSB then begin     // 开始 XSB 块

            if mapNode.Map.Count > 2 then begin   // 前面有解析过的关卡 XSB，则把当前关卡加入关卡集列表
              // 做关卡的标准化，计算CRC等
              if MapNormalize(mapNode) then begin
                 if isAns then SetSolved(mapNode, mapSolution);
              end;

              NewMapNode(tmpList);                                  // 创建一个新的关卡节点
              num := tmpList.Count - 1;
              mapNode := tmpList.Items[num];                        // 指向最新创建的节点
              mapNode.isEligible := True;                           // 默认是合格的关卡XSB
            end
            else mapNode.Map.Clear;

            is_XSB := True;    // 开始关卡 XSB 块
            is_Comment := False;
            is_Solution := False;
            mapNode.Rows := 0;
            mapNode.Cols := 0;
            mapNode.Title := '';
            mapNode.Author := '';
            mapNode.Comment := '';
          end;

          mapNode.Map.Add(line);    // 各 XSB 行

        end
        else if (not is_Comment) and (AnsiStartsText('title', line2)) and (mapNode.Title = '') then begin   // 匹配 Title，标题
          n := Pos(':', line2);
          if n > 0 then
            mapNode.Title := trim(Copy(line2, n + 1, MaxInt))
          else
            mapNode.Title := trim(Copy(line2, 6, MaxInt));

          if is_XSB then is_XSB := false;      // 结束关卡SXB的解析
        end
        else if (not is_Comment) and (AnsiStartsText('author', line2)) and (mapNode.Author = '') then begin  // 匹配 Author，作者
          n := Pos(':', line2);
          if n > 0 then
            mapNode.Author := trim(Copy(line2, n + 1, MaxInt))
          else
            mapNode.Author := trim(Copy(line2, 7, MaxInt));

          if is_XSB then is_XSB := false;      // 结束关卡SXB的解析
        end
        else if (not is_Comment) and (isAns) and (AnsiStartsText('solution', line2)) then begin  // 匹配 Solution，答案
          n := LastPos(':', line2);
          if n = 0 then
            n := Pos(')', line2);

          if n > 0 then
            line := trim(Copy(line2, n + 1, MaxInt))
          else
            line := trim(Copy(line2, 9, MaxInt));

          if Length(line) > 0 then
            mapSolution.Add(line)
          else
            mapSolution.Add('');

          if is_XSB then is_XSB := false;      // 结束关卡SXB的解析
          is_Solution := true;                 // 开始答案解析
        end
        else if (AnsiStartsText('comment-end', line2)) or (AnsiStartsText('comment_end', line2)) then begin  // 匹配"注释"块结束
          is_Comment := False;   // 结束"注释"块
        end
        else if AnsiStartsText('comment', line2) and (mapNode.Comment = '') then begin  //匹配"注释"块开始
          if is_XSB then is_XSB := false;      // 结束关卡SXB的解析

          n := Pos(':', line2);
          if n > 0 then
            line := trim(Copy(line2, n + 1, MaxInt))
          else
            line := trim(Copy(line2, 8, MaxInt));

          if Length(line) > 0 then
            mapNode.Comment := line     // 单行"注释"
          else
            is_Comment := True;         // 开始"注释"块
        end
        else if is_Comment then begin  // "说明"信息
          if Length(mapNode.Comment) > 0 then
            mapNode.Comment := mapNode.Comment + #10 + line
          else
            mapNode.Comment := line;
        end
        else if is_Solution then begin  // 答案行
          line2 := StringReplace(line2, #9, '', [rfReplaceAll]);
          line2 := StringReplace(line2, ' ', '', [rfReplaceAll]);
          if isLurd(line2) then begin
             n := mapSolution.Count - 1;
             mapSolution[n] := mapSolution[n] + line2;
          end;
        end
        else begin
          if is_XSB then is_XSB := false;      // 结束关卡SXB块的解析
        end;
      end;

      Result := True;
    finally
      // 检查最后的节点，若没有 XSB 数据，则将其删除
      num := tmpList.Count - 1;
      if num >= 0 then begin
         mapNode := tmpList.Items[num];
         if mapNode.Map.Count < 3 then begin
            MyStringListFree(mapNode.Map);
            tmpList.Delete(num);
            Dispose(mapNode);
         end else begin
           if MapNormalize(mapNode) then begin
              if isAns then SetSolved(mapNode, mapSolution);
           end;
         end;
      end else if Assigned(mapNode) then begin
         if mapNode.Map.Count > 0 then begin
            MyStringListFree(mapNode.Map);
         end;
         Dispose(mapNode);
      end;
      mapNode := nil;

      MyStringListFree(mapSolution);
    end;
  finally
    if Assigned(tmpList) then begin
       if tmpList.Count > 0 then begin
          MapList := tmpList;
       end else begin
          MyListClear(tmpList);
       end;
       tmpList := nil;
    end;
  end;
end;

// 从 TStringList 中导入答案
//procedure TLoadMapThread2.Execute;

// 地图标准化，包括：简单标准化 -- 保留关卡的墙外造型；精准标准化 -- 不保留关卡的墙外造型，同时计算 CRC 等
function MapNormalize(var mapNode: PMapNode): Boolean;
var
  i, j, k, t, mr, mc, Rows, Cols, nLen, nRen, nRows, nCols, p, tail, pos: Integer;
  ch: Char;
  mr2, mc2, left, top, right, bottom, nBox, nDst, mTop, mLeft, mBottom, mRight: Integer;
  s1: string;
  key8: array[0..7] of Integer;
begin
  Result := False;

  mr := -1;
  mc := -1;
  nRen := 0;
  Rows := mapNode.Map.Count;
  Cols := 0;
  for i := 0 to Rows - 1 do begin
    nLen := Length(mapNode.Map[i]);
    if Cols < nLen then
      Cols := nLen;
  end;

  mapNode.Rows := Rows;
  mapNode.Cols := Cols;

  if (Rows >= 100) or (Cols >= 100) then begin
    mapNode.Rows := 100;
    mapNode.Cols := 100;
    mapNode.isEligible := False;        // 不合格的关卡XSB
    Exit;
  end;

  for i := 0 to Rows - 1 do begin
    nLen := Length(mapNode.Map[i]);
    for j := 0 to Cols - 1 do
    begin
      if j < nLen then
        ch := mapNode.Map[i][j + 1]
      else
        ch := '-';

      case (ch) of
        '#', '.', '$', '*':
          begin
            MapArray[i, j] := ch;
          end;
        '@', '+':
          begin
            MapArray[i, j] := ch;
            nRen := nRen+1;
            mr := i;
            mc := j;
          end;
      else
        MapArray[i, j] := '-';
      end;

    end;
  end;

  if nRen <> 1 then begin  // 仓管员 <> 1
    mapNode.isEligible := False;        // 不合格的关卡XSB
    Exit;
  end;

  for i := 0 to Rows - 1 do begin
    for j := 0 to Cols - 1 do
    begin
      Mark[i][j] := false;
    end;
  end;

  left := mc;
  top := mr;
  right := mc;
  bottom := mr;
  nBox := 0;
  nDst := 0;

  p := 0; tail := 0;
  pos := (mc shl 16) or mr;
  pt[0] := pos;
  Mark[mr][mc] := true;
  while p <= tail do begin // 走完后，Mark[][]为 true 的，为墙内
    mr := pt[p] and $00FF;
    mc := pt[p] shr 16;

    case MapArray[mr, mc] of
      '$':
        begin
          nBox := nBox+1;
        end;
      '*':
        begin
          nBox := nBox+1;
          nDst := nDst+1;
        end;
      '.', '+':
        begin
          nDst := nDst+1;
        end;
    end;
    for k := 0 to 3 do begin   // 仓管员向四个方向走
      mr2 := mr + dr4[k];
      mc2 := mc + dc4[k];
      if (mr2 < 0) or (mr2 >= Rows) or (mc2 < 0) or (mc2 >= Cols) or    // 出界
         (Mark[mr2, mc2]) or (MapArray[mr2, mc2] = '#') then            // 已访问或遇到墙
          continue;

      // 调整四至
      if left > mc2 then
        left := mc2;
      if top > mr2 then
        top := mr2;
      if right < mc2 then
        right := mc2;
      if bottom < mr2 then
        bottom := mr2;

      Mark[mr2][mc2] := true;  //标记为已访问
      pos := (mc2 shl 16) or mr2;
      tail := tail+1;
      pt[tail] := pos;
    end;
    p := p+1;
  end;

  mapNode.Boxs  := nBox;
  mapNode.Goals := nDst;

  if (nBox <> nDst) or (nBox < 1) or (nDst < 1) then begin  // 可达区域内的箱子与目标点数不正确
    mapNode.isEligible := False;        // 不合格的关卡XSB
    exit;
  end;

  // 标准化后的尺寸（八转）
  nRows := bottom - top + 1 + 2;
  nCols := right - left + 1 + 2;

  // 整理关卡元素
  for i := 0 to Rows - 1 do begin
    for j := 0 to Cols - 1 do
    begin
      ch := MapArray[i, j];
      if (Mark[i, j]) then
      begin  // 墙内
        if not (ch in ['-', '.', '$', '*', '@', '+']) then
        begin  //无效元素
          ch := '-';
          MapArray[i, j] := ch;
        end;
      end
      else
      begin  // 墙外造型
        if (ch = '*') or (ch = '$') then
        begin
          ch := '#';
          MapArray[i, j] := ch;
        end
        else if not (ch in ['#', '_']) then
        begin  // 无效元素
          ch := '_';
          MapArray[i, j] := ch;
        end;
      end;
      if (i >= top) and (i <= bottom) and (j >= left) and (j <= right) then
      begin  // “四至”范围内
        if Mark[i, j] then
          aMap0[i - top + 1, j - left + 1] := ch  // 标准化关卡的有效元素（暂时空出四周）
        else
          aMap0[i - top + 1, j - left + 1] := '_';
      end;
    end;
  end;

  // 关卡最小化
  mTop := 0;
  mLeft := 0;
  mBottom := Rows - 1;
  mRight := Cols - 1;
  for k := 0 to Rows - 1 do begin
    t := 0;
    while (t < Cols) and (MapArray[k, t] = '_') do
      t := t+1;

    if t = Cols then
      mTop := mTop+1
    else
      break;
  end;
  for k := Rows - 1 downto mTop + 1 do begin
    t := 0;
    while (t < Cols) and (MapArray[k, t] = '_') do
      t := t+1;
    if t = Cols then
      mBottom := mBottom-1
    else
      break;
  end;
  if mBottom - mTop < 2 then Exit;

  for k := 0 to Cols - 1 do begin
    t := mTop;
    while (t <= mBottom) and (MapArray[t, k] = '_') do
      t := t+1;
    if t > mBottom then
      mLeft := mLeft+1
    else
      break;
  end;
  for k := Cols - 1 downto mLeft + 1 do begin
    t := mTop;
    while (t <= mBottom) and (MapArray[t, k] = '_') do
      t := t+1;
    if t > mBottom then
      mRight := mRight-1
    else
      break;
  end;
  if mRight - mLeft < 2 then Exit;

  // 关卡原貌，已做简单标准化（保留墙外造型）
  mapNode.Map.Clear;
  for i := mTop to mBottom do begin
    s1 := '';  // 保持关卡原貌，对墙外造型部分不再清理
    for j := mLeft to mRight do
    begin
      s1 := s1 + MapArray[i, j];
    end;
    mapNode.Map.Add(s1);
  end;
  mapNode.Rows := mapNode.Map.Count;
  mapNode.Cols := Length(mapNode.Map[0]);

  // 标准化关卡的四周填充 '_'
  for i := 0 to nRows - 1 do begin
    for j := 0 to nCols - 1 do begin
      if (i = 0) or (j = 0) or (i = nRows - 1) or (j = nCols - 1) then
        aMap0[i, j] := '_';
    end;
  end;

  // 标准化
  for i := 1 to nRows - 2 do begin
    for j := 1 to nCols - 2 do begin
      if (aMap0[i, j] <> '_') and (aMap0[i, j] <> '#') then begin  // 探查内部有效元素的八个方位，是否可以安排墙壁
        if (aMap0[i - 1, j] = '_') then
          aMap0[i - 1, j] := '#';
        if (aMap0[i + 1, j] = '_') then
          aMap0[i + 1, j] := '#';
        if (aMap0[i, j - 1] = '_') then
          aMap0[i, j - 1] := '#';
        if (aMap0[i, j + 1] = '_') then
          aMap0[i, j + 1] := '#';
        if (aMap0[i + 1, j - 1] = '_') then
          aMap0[i + 1, j - 1] := '#';
        if (aMap0[i + 1, j + 1] = '_') then
          aMap0[i + 1, j + 1] := '#';
        if (aMap0[i - 1, j - 1] = '_') then
          aMap0[i - 1, j - 1] := '#';
        if (aMap0[i - 1, j + 1] = '_') then
          aMap0[i - 1, j + 1] := '#';
      end;
    end;
  end;

  mapNode.Map_Thin := '';

  // 标准化后的八转：关卡先顺时针旋转（得到：0转、1转、2转、3转），4转为0转的左右镜像，4转再顺时针旋转（得到：4转、5转、6转、7转）
  for i := 0 to nRows - 1 do begin
    for j := 0 to nCols - 1 do begin
      mapNode.Map_Thin := mapNode.Map_Thin + aMap0[i, j];
      aMap1[j, nRows - 1 - i] := aMap0[i, j];
      aMap2[nRows - 1 - i, nCols - 1 - j] := aMap0[i, j];
      aMap3[nCols - 1 - j, i] := aMap0[i, j];
      aMap4[i, nCols - 1 - j] := aMap0[i, j];
      aMap5[nCols - 1 - j, nRows - 1 - i] := aMap0[i, j];
      aMap6[nRows - 1 - i, j] := aMap0[i, j];
      aMap7[j, i] := aMap0[i, j];
    end;
    if i < nRows - 1 then mapNode.Map_Thin := mapNode.Map_Thin + #10;
  end;

  // 测试
//  Writeln(myLogFile, '333');
//  for j := 0 to mapNode.Map.Count-1 do begin
//    Writeln(myLogFile, mapNode.Map[j]);
//  end;
//  Writeln(myLogFile, Inttostr(mapNode.Rows));
//  Writeln(myLogFile, Inttostr(mapNode.Cols));
//  Writeln(myLogFile, '');
//  Writeln(myLogFile, '444');
//  for i := 0 to nRows-1 do begin
//    for j := 0 to nCols-1 do begin
//      Write(myLogFile, aMap0[i, j]);
//    end;
//    Write(myLogFile, #10);
//  end;

  // 第几转的 CRC 最小
  key8[1] := Calcu_CRC_32(@aMap1, nCols, nRows);
  key8[2] := Calcu_CRC_32(@aMap2, nRows, nCols);
  key8[3] := Calcu_CRC_32(@aMap3, nCols, nRows);
  key8[4] := Calcu_CRC_32(@aMap4, nRows, nCols);
  key8[5] := Calcu_CRC_32(@aMap5, nCols, nRows);
  key8[6] := Calcu_CRC_32(@aMap6, nRows, nCols);
  key8[7] := Calcu_CRC_32(@aMap7, nCols, nRows);
  mapNode.CRC32 := Calcu_CRC_32(@aMap0, nRows, nCols);        // 精准标准化后的关卡 -- 没有墙外造型
  mapNode.CRC_Num := 0;

  // 测试
//  Writeln(myLogFile, '======================');
//  Writeln(myLogFile, inttostr(mapNode.CRC32));
//  Writeln(myLogFile, inttostr(key8[1]));
//  Writeln(myLogFile, inttostr(key8[2]));
//  Writeln(myLogFile, inttostr(key8[3]));
//  Writeln(myLogFile, inttostr(key8[4]));
//  Writeln(myLogFile, inttostr(key8[5]));
//  Writeln(myLogFile, inttostr(key8[6]));
//  Writeln(myLogFile, inttostr(key8[7]));


  for i := 1 to 7 do begin
    if mapNode.CRC32 > key8[i] then
    begin
      mapNode.CRC32 := key8[i];
      mapNode.CRC_Num := i;
    end;
  end;

  mapNode.Num := 0;       // 该属性仅在关卡预览时，标识是否做过“有解”检测
  
  Result := True;
end;

// 取得关卡 XSB
function GetXSB(mapNpde: PMapNode): string;
var
  i: Integer;
begin
  Result := #10;

  if mapNpde.Map.Count > 0 then begin
    for i := 0 to mapNpde.Map.Count - 1 do begin
      Result := Result + mapNpde.Map.Strings[i] + #10;
    end;
    if Trim(mapNpde.Title) <> '' then
      Result := Result + 'Title: ' + mapNpde.Title + #10;
    if Trim(mapNpde.Author) <> '' then
      Result := Result + 'Author: ' + mapNpde.Author + #10;
    if Trim(mapNpde.Comment) <> '' then begin
      Result := Result + 'Comment: ' + mapNpde.Comment + #10;
      Result := Result + 'Comment_end: ' + #10;
    end;
    Result := Result + #10;
  end;
end;

// 取得现场 XSB
function GetXSB_2(): string;
var
  i, j, myCell, pos: Integer;

begin
  Result := #10;

  if (not Assigned(curMapNode)) then Exit;

  if curMapNode.Map.Count > 0 then begin
    for i := 0 to curMapNode.Rows - 1 do begin
      for j := 0 to curMapNode.Cols - 1 do begin
        pos := i * curMapNode.Cols + j;
        if main.mySettings.isBK then begin                // 逆推
           if main.mySettings.isJijing then begin              // 即景目标位
              if main.map_Board[pos] in [BoxCell, BoxGoalCell] then begin
                 if main.map_Board_BK[pos] = BoxCell then myCell := BoxGoalCell
                 else if main.map_Board_BK[pos] = ManCell then myCell := ManGoalCell
                 else if main.map_Board_BK[pos] = FloorCell then myCell := GoalCell
                 else myCell := main.map_Board_BK[pos];
              end else begin
                 if main.map_Board_BK[pos] = BoxGoalCell then myCell := BoxCell
                 else if main.map_Board_BK[pos] = ManGoalCell then myCell := ManCell
                 else if main.map_Board_BK[pos] = GoalCell then myCell := FloorCell
                 else myCell := main.map_Board_BK[pos];
              end;
           end else if main.mySettings.isSameGoal then begin   // 固定目标位
              if main.map_Board_OG[pos] in [GoalCell, BoxGoalCell, ManGoalCell] then begin
                 if main.map_Board_BK[pos] = BoxCell then myCell := BoxGoalCell
                 else if main.map_Board_BK[pos] = ManCell then myCell := ManGoalCell
                 else if main.map_Board_BK[pos] = FloorCell then myCell := GoalCell
                 else myCell := main.map_Board_BK[pos];
              end else begin
                 if main.map_Board_BK[pos] = BoxGoalCell then myCell := BoxCell
                 else if main.map_Board_BK[pos] = ManGoalCell then myCell := ManCell
                 else if main.map_Board_BK[pos] = GoalCell then myCell := FloorCell
                 else myCell := main.map_Board_BK[pos];
              end;
           end else begin
              myCell := main.map_Board_BK[pos];
           end;
        end else begin
           if main.mySettings.isJijing then begin              // 即景目标位
              if main.map_Board_BK[pos] in [BoxGoalCell, BoxCell] then begin
                 if main.map_Board[pos] = BoxCell then myCell := BoxGoalCell
                 else if main.map_Board[pos] = ManCell then myCell := ManGoalCell
                 else if main.map_Board[pos] = FloorCell then myCell := GoalCell
                 else myCell := main.map_Board[pos];
              end else begin
                 if main.map_Board[pos] = BoxGoalCell then myCell := BoxCell
                 else if main.map_Board[pos] = ManGoalCell then myCell := ManCell
                 else if main.map_Board[pos] = GoalCell then myCell := FloorCell
                 else myCell := main.map_Board[pos];
              end;
           end else begin
              myCell := main.map_Board[pos];
           end;
        end;
        Result := Result + xbsChar[myCell];
      end;
      Result := Result + #10;
    end;
  end;
end;

// 在后台线程中加载地图文档
procedure TLoadMapThread.Execute;
var
  FileName: string;
  line, line2: string;
  is_XSB: Boolean;                 // 是否正在解析关卡XSB
  is_Comment: Boolean;             // 是否正在解析关卡说明信息
  num, n, k: Integer;              // XSB的解析控制
  mapNode: PMapNode;               // 解析出的当前关卡节点指针
  mapSolution: TStringList;        // 关卡答案
  tmpMapList: TList;               // 临时关卡列表
  txtLines: Integer;

begin
  FreeOnTerminate := True;

  main.bt_View.Enabled := False;
  
  isStopThread := False;

  MyListClear(MapList);

  FileName := main.mySettings.MapFileName;

  if Pos(':', FileName) = 0 then FileName := AppPath + FileName;
  if FileExists(FileName) then begin

    MapCount := 1;
    
    tmpMapList := TList.Create;             // 关卡列表

    try
      txtLines := main.txtList.Count;         // 文本行数

      mapSolution := TStringList.Create;

      try
        NewMapNode(tmpMapList);              // 先创建一个关卡节点
        mapNode := tmpMapList.Items[0];      // 指向最新创建的节点
        mapNode.isEligible := True;          // 默认是合格的关卡XSB
        is_XSB := False;
        is_Comment := False;

        k := 0;
        while (k < txtLines) and (not isStopThread) do begin
          line  := main.txtList.Strings[k];
          line2 := Trim(line);

          if (not is_Comment) and isXSB(line) then begin       // 检查是否为 XSB 行
            if not is_XSB then begin       // 开始 XSB 块

              if mapNode.Map.Count > 2 then begin   // 前面有解析过的关卡 XSB，则把当前关卡加入关卡集列表

                MapCount := MapCount + 1;

                MapNormalize(mapNode);         // 做关卡的标准化，计算CRC等

                NewMapNode(tmpMapList);                      // 创建一个新的关卡节点
                num := tmpMapList.Count - 1;
                mapNode := tmpMapList.Items[num];            // 指向最新创建的节点
                mapNode.isEligible := True;               // 默认是合格的关卡XSB

              end else mapNode.Map.Clear;

              is_XSB := True;    // 开始关卡 XSB 块
              is_Comment := False;
              mapNode.Rows := 0;
              mapNode.Cols := 0;
              mapNode.Title := '';
              mapNode.Author := '';
              mapNode.Comment := '';
            end;

            mapNode.Map.Add(line);    // 各 XSB 行

          end
          else if (not is_Comment) and (AnsiStartsText('title', line2)) and (mapNode.Title = '') then begin   // 匹配 Title，标题
            n := Pos(':', line2);
            if n > 0 then
              mapNode.Title := trim(Copy(line2, n + 1, MaxInt))
            else
              mapNode.Title := trim(Copy(line2, 6, MaxInt));

            if is_XSB then is_XSB := false;      // 结束关卡SXB的解析
          end
          else if (not is_Comment) and (AnsiStartsText('author', line2)) and (mapNode.Author = '') then begin  // 匹配 Author，作者
            n := Pos(':', line2);
            if n > 0 then
              mapNode.Author := trim(Copy(line2, n + 1, MaxInt))
            else
              mapNode.Author := trim(Copy(line2, 7, MaxInt));

            if is_XSB then is_XSB := false;      // 结束关卡SXB的解析
          end
          else if (AnsiStartsText('comment-end', line2)) or (AnsiStartsText('comment_end', line2)) then begin  // 匹配"注释"块结束
            is_Comment := False; // 结束"注释"块
          end
          else if AnsiStartsText('comment', line2) and (mapNode.Comment = '') then begin  //匹配"注释"块开始
            if is_XSB then is_XSB := false;      // 结束关卡SXB的解析
            n := Pos(':', line2);
            if n > 0 then
              line := trim(Copy(line2, n + 1, MaxInt))
            else
              line := trim(Copy(line2, 8, MaxInt));
            if Length(line) > 0 then
              mapNode.Comment := line     // 单行"注释"
            else
              is_Comment := True;     // 开始"注释"块
          end
          else if is_Comment then begin  // "说明"信息
            if Length(mapNode.Comment) > 0 then
              mapNode.Comment := mapNode.Comment + #10 + line
            else
              mapNode.Comment := line;
          end
          else begin
            if is_XSB then is_XSB := false;      // 结束关卡SXB块的解析
          end;
          k := k+1;
        end;

      finally
        // 检查最后的节点，若没有 XSB 数据，则将其删除
        num := tmpMapList.Count - 1;
        if num >= 0 then begin
           mapNode := tmpMapList.Items[num];
           if mapNode.Map.Count < 3 then begin
              MyStringListFree(mapNode.Map);
              tmpMapList.Delete(num);
              Dispose(mapNode);
           end else begin
             MapNormalize(mapNode);
           end;
        end else if Assigned(mapNode) then begin
           if mapNode.Map.Count > 0 then begin
              MyStringListFree(mapNode.Map);
           end;
           Dispose(mapNode);
        end;
        mapNode := nil;

        MyStringListFree(mapSolution);
      end;
    finally
      if Assigned(tmpMapList) then begin
         if tmpMapList.Count > 0 then begin
            MapList := tmpMapList;
         end else begin
            MyListClear(tmpMapList);
         end;
         tmpMapList := nil;
      end;
    end;
  end;
  
  isStopThread := True;
  main.bt_View.Enabled := True;
end;

// 更新主窗口标题
procedure TLoadAnsThread.UpdateCaption;
begin
  try
    MyOpenFile.Label1.Caption := '共导入答案 ' + IntToStr(sumSolution) + ' 个';
  except
  end;
end;

// 导入答案的后台线程
procedure TLoadAnsThread.Execute;
var
  line, line2: string;
  is_XSB: Boolean;                 // 是否正在解析关卡XSB
  is_Solution: Boolean;            // 是否答案行
  is_Comment: Boolean;             // 是否正在解析关卡说明信息
  num, n, k: Integer;              // XSB的解析控制
  mapNode: PMapNode;               // 解析出的当前关卡节点指针
  mapSolution: TStringList;        // 关卡答案
  data_Text: TStringList;          // 文本行
begin
  FreeOnTerminate := True;

  isStopThread_Ans := False;
  
  data_Text := TStringList.Create;          // 文本行

  try

    data_Text.LoadFromFile(MyOpenFile.FileListBox1.FileName);    // 文本行

    mapSolution := TStringList.Create;      // 答案缓存

    try

      New(mapNode);                         // 关卡节点

      try
        // 节点默认值
        mapNode.Map_Thin := '';
        mapNode.Rows := 0;
        mapNode.Cols := 0;
        mapNode.Trun := 0;
        mapNode.Title := '';
        mapNode.Author := '';
        mapNode.Comment := '';
        mapNode.CRC32 := -1;
        mapNode.CRC_Num := -1;
        mapNode.Solved := false;
        mapNode.isEligible := True;

        mapNode.Map := TStringList.Create;    // 地图行
      
        try
          is_XSB := False;
          is_Comment := False;
          is_Solution := False;


          num := 0;
          sumSolution := 0;
          k := 0;
          while (k < data_Text.Count) and (not isStopThread_Ans) do begin

            line := data_Text.Strings[k];     // 读取一行
            k := k+1;
            line2 := Trim(line);

            if (not is_Comment) and isXSB(line) then begin       // 检查是否为 XSB 行
              if not is_XSB then begin     // 开始 XSB 块

                if mapNode.Map.Count > 2 then begin   // 前面有解析过的关卡 XSB，则把当前关卡加入关卡集列表

                  MyOpenFile.Caption := '导入答案 ~ 关卡：' + IntToStr(num);

                  // 做关卡的标准化，计算CRC等
                  if MapNormalize(mapNode) then begin
                     num := num + 1;
                     SetSolved_2(mapNode, mapSolution);
                  end;
                end;

                mapNode.Map.Clear;

                is_XSB := True;    // 开始关卡 XSB 块
                is_Comment := False;
                is_Solution := False;
                mapNode.Rows := 0;
                mapNode.Cols := 0;
                mapNode.Title := '';
                mapNode.Author := '';
                mapNode.Comment := '';
              end;

              mapNode.Map.Add(line);    // 各 XSB 行

            end
            else if (not is_Comment) and (AnsiStartsText('solution', line2)) then begin  // 匹配 Solution，答案
              n := LastPos(':', line2);
              if n = 0 then
                n := Pos(')', line2);

              if n > 0 then
                line := trim(Copy(line2, n + 1, MaxInt))
              else
                line := trim(Copy(line2, 9, MaxInt));

              if Length(line) > 0 then
                mapSolution.Add(line)
              else
                mapSolution.Add('');

              if is_XSB then is_XSB := false;      // 结束关卡SXB的解析
              is_Solution := true;                 // 开始答案解析
            end
            else if (AnsiStartsText('comment-end', line2)) or (AnsiStartsText('comment_end', line2)) then begin  // 匹配"注释"块结束
              is_Comment := False;   // 结束"注释"块
            end
            else if AnsiStartsText('comment', line2) and (mapNode.Comment = '') then begin  //匹配"注释"块开始
              if is_XSB then is_XSB := false;      // 结束关卡SXB的解析

              n := Pos(':', line2);
              if n > 0 then
                line := trim(Copy(line2, n + 1, MaxInt))
              else
                line := trim(Copy(line2, 8, MaxInt));

              if Length(line) <= 0 then is_Comment := True;         // 开始"注释"块
            end
            else if is_Solution then begin  // 答案行
              line2 := StringReplace(line2, #9, '', [rfReplaceAll]);
              line2 := StringReplace(line2, ' ', '', [rfReplaceAll]);
              if isLurd(line2) then begin
                 n := mapSolution.Count - 1;
                 mapSolution[n] := mapSolution[n] + line2;
              end;
            end
            else if is_Comment then begin  // "说明"信息
            end
            else begin
              if is_XSB then is_XSB := false;      // 结束关卡SXB块的解析
            end;
          end;
        finally
          if (mapNode.Map.Count > 2) and (not isStopThread_Ans) then begin
            if MapNormalize(mapNode) then begin
               SetSolved_2(mapNode, mapSolution);
            end;
          end;
          MyStringListFree(mapNode.Map);
        end;
      finally
        Dispose(mapNode);
        mapNode := nil;
      end;
    finally
      MyStringListFree(mapSolution);
    end;
  finally
    MyStringListFree(data_Text);
  end;

  synchronize(UpdateCaption);     // 更新主窗口提示
  isStopThread_Ans := True;
end;

function FindClipbrd(num: Integer): Integer;                                       // 在关卡列表中，查找剪切板中的关卡，返回找到的序号，没找到则返回 -1
var
  mapNode: PMapNode;
  str: string;
  i, len: Integer;
begin
  Result := -1;

  len := MapList.Count;
  if len = 0 then Exit;

  New(mapNode);

  try
    mapNode.Map := TStringList.Create;
    try
      mapNode.Map_Thin := '';
      mapNode.Rows := 0;
      mapNode.Cols := 0;
      mapNode.Trun := 0;
      mapNode.Title := '';
      mapNode.Author := '';
      mapNode.Comment := '';
      mapNode.CRC32 := -1;
      mapNode.CRC_Num := -1;
      mapNode.Solved := false;

      // 剪切板导入 XSB
      if (Clipboard.HasFormat(CF_TEXT) or Clipboard.HasFormat(CF_OEMTEXT)) then begin
          str := Clipboard.asText;
          Split(str, mapNode.Map);

          if MapNormalize(mapNode) then begin
             for i := num+1 to len-1 do begin
                 if mapNode.CRC32 = PMapNode(MapList[i])^.CRC32 then begin
                    Result := i;
                    Break;
                 end;
             end;
          end;
      end;
    finally
      MyStringListFree(mapNode.Map);
    end;
  finally
    if Assigned(mapNode) then begin
       Dispose(mapNode);
       mapNode := nil;
    end;
  end;

end;
end.

