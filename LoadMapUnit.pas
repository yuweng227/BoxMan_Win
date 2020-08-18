unit LoadMapUnit;
// 关卡文本解析单元

interface

uses
  windows, classes, StrUtils, SysUtils, Clipbrd, Graphics, Math, CRC_32;

type
  TLoadMapThread = class(TThread)         // 后台加载地图文档线程
  protected
    procedure UpdateCaption;
    procedure Execute; override;
  public
    isRunning: Boolean;
  end;

type                  // 关卡节点 -- 关卡集中的各个关卡
  TMapNode = record
    Map: TStringList;    // 关卡 XSB
    Rows, Cols: integer;        // 关卡尺寸
    Boxs: integer;        // 箱子数
    Goals: integer;        // 目标点数
    Trun: integer;        // 关卡旋转登记
    Title: string;         // 标题
    Author: string;         // 作者
    Comment: string;         // 关卡描述信息
    CRC32: integer;        // CRC32
    CRC_Num: integer;        // 若当前地图为 0 转，最小 CRC 位于第几转？
    Solved: Boolean;        // 是否由答案
    isEligible: Boolean;        // 是否合格的关卡XSB
    Num: integer;        // 关卡序号 -- 仅加载文档最后一个关卡时使用
  end;

  PMapNode = ^TMapNode;              // 关卡节点指针

function GetXSB(): string;                                     // 取得关卡 XSB

procedure XSBToClipboard();                                    // XSB 送入剪切板

function LoadMapsFromText(text: string): boolean;         // 加载关卡 -- 从剪切板或文本字符串

function QuicklyLoadMap(FileName: string; number: Integer): PMapNode;  // 迅速的加载指定文档的第 number 号地图

function MapNormalize(var mapNode: PMapNode): Boolean;         // 地图标准化，包括：简单标准化 -- 保留关卡的墙外造型；精准标准化 -- 不保留关卡的墙外造型，同时计算 CRC 等

function isSolution(mapNode: PMapNode; sol: PChar): Boolean;   // 答案验证

var
  isStopThread: Boolean;                              // 是否终止后台线程
  LoadMapThread: TLoadMapThread;                     // 后台加载地图文档线程
  ManPos_BK_0: integer;                     // 人的位置 -- 逆推，玩家已经指定的位置
  ManPos_BK_0_2: integer;                     // 人的位置 -- 逆推，解析出来的位置

  sMoves, sPushs: integer;                            // 验证答案时，记录移动数和推动数

  MapList: TList;                          // 关卡列表
  MapArray: array[0..99, 0..99] of Char;   // 标准化用关卡数组
  Mark: array[0..99, 0..99] of Boolean;    // 标准化用标志数组
  curMapNode: PMapNode;                   // 当前关卡节点
  SolvedLevel: array[0..30] of Integer;     // 当后台没有加载完关卡时，临时登记加载期间玩家解开的关卡序号

  isOnlyXSB: boolean;                      // 打开关卡文档时，仅解析XSB -- 忽略答案

  tmp_Board: array[0..9999] of integer;   // 临时地图

  // 标准化用关卡数组
  aMap0: array[0..99, 0..99] of Char;
  aMap1: array[0..99, 0..99] of Char;
  aMap2: array[0..99, 0..99] of Char;
  aMap3: array[0..99, 0..99] of Char;
  aMap4: array[0..99, 0..99] of Char;
  aMap5: array[0..99, 0..99] of Char;
  aMap6: array[0..99, 0..99] of Char;
  aMap7: array[0..99, 0..99] of Char;

implementation

uses
  LogFile, OpenFile, BrowseLevels, //
  LurdAction, DateModule, MainForm, LoadSkin;

const
  EmptyCell = 0;
  WallCell = 1;
  FloorCell = 2;
  GoalCell = 3;
  BoxCell = 4;
  BoxGoalCell = 5;
  ManCell = 6;
  ManGoalCell = 7;

// 取得子串最后出现的位置
function LastPos(const SubStr, Str: ansistring): Integer;
var
  Idx: Integer;
begin
  Result := 0;
  Idx := StrUtils.PosEx(SubStr, Str);
  if Idx = 0 then
    Exit;
  while Idx > 0 do
  begin
    Result := Idx;
    Idx := StrUtils.PosEx(SubStr, Str, Idx + 1);
  end;
end;
  
// 判断是否为有效的 XSB 行
function isXSB(str: string): boolean;
var
  n, k: Integer;
begin
  result := False;

  n := Length(str);

  if n = 0 then
    exit;

  k := 1;
  // 检查是否是空行 -- 仅有空格和跳格符
  while k <= n do
  begin
    if (str[k] <> #20) and (str[k] <> #8) or (str[k] = '') then
      Break;
    Inc(k);
  end;
  if k > n then
    Exit;

  k := 1;
  while k <= n do
  begin
    if not (str[k] in [' ', '_', '-', '#', '.', '$', '*', '@', '+']) then
      Break;
    Inc(k);
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
  for i := 0 to Rows - 1 do
  begin
    for j := 1 to Cols do
    begin
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

      if ch in ['@', '+'] then
        mpos := i * Cols + j;
    end;
  end;

  if mpos < 0 then
    Exit;
  sPushs := 0;
  sMoves := 0;

  // 答案验证
  len := Length(sol);
  for i := 0 to len - 1 do
  begin
    pos1 := -1;
    pos2 := -1;
    ch := sol[i];
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
    isPush := ch in ['L', 'R', 'U', 'D'];

    if (pos1 < 0) or (pos1 >= size) or (isPush and ((pos1 < 0) or (pos1 >= size))) then
      Exit;             // 界外

    if isPush then
    begin                                                                                 // 无效推动
      if (tmp_Board[pos1] <> BoxCell) and (tmp_Board[pos1] <> BoxGoalCell) or (tmp_Board[pos2] <> FloorCell) and (tmp_Board[pos2] <> GoalCell) then
        Exit;
      if tmp_Board[pos2] = FloorCell then
        tmp_Board[pos2] := BoxCell
      else
        tmp_Board[pos2] := BoxGoalCell;
      if tmp_Board[pos1] = BoxCell then
        tmp_Board[pos1] := ManCell
      else
        tmp_Board[pos1] := ManGoalCell;
      if tmp_Board[mpos] = ManCell then
        tmp_Board[mpos] := FloorCell
      else
        tmp_Board[mpos] := GoalCell;
    end
    else
    begin
      if (tmp_Board[pos1] <> FloorCell) and (tmp_Board[pos1] <> GoalCell) then
        Exit;                    // 无效移动
      if tmp_Board[pos1] = FloorCell then
        tmp_Board[pos1] := ManCell
      else
        tmp_Board[pos1] := ManGoalCell;
      if tmp_Board[mpos] = ManCell then
        tmp_Board[mpos] := FloorCell
      else
        tmp_Board[mpos] := GoalCell;
    end;

    if isPush then
      Inc(sPushs);
    Inc(sMoves);

    mpos := pos1;

    okNum := 0;
    for j := 0 to size - 1 do
    begin
      if (tmp_Board[j] = BoxGoalCell) then
        Inc(okNum);

      if okNum = mapNode.Goals then
      begin                     // 能够解关，为有效答案
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

end;

// 检查是否为有解关卡 -- 剪切板导入时使用
procedure SetSolved(mapNode: PMapNode; var Solitions: TStringList);
var
  i, l, solCRC: Integer;
  is_Solved: Boolean;
begin
  is_Solved := false;
  mapNode.Solved := false;

  // 若解析到了答案，则验证答案并将答案入库
  if Solitions.Count > 0 then
  begin
    l := Solitions.Count;
    for i := l - 1 downto 0 do
    begin
      if isSolution(mapNode, PChar(Solitions[i])) then      // 对答案进行验证
      begin    // 保存到数据库
            // 保存答案到数据库
        try
          DataModule1.ADOQuery1.Close;
          DataModule1.ADOQuery1.SQL.Clear;
          DataModule1.ADOQuery1.SQL.Text := 'select * from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNode.CRC32) + ' and Goals = ' + IntToStr(mapNode.Goals);
          DataModule1.ADOQuery1.Open;
          DataModule1.DataSource1.DataSet := DataModule1.ADOQuery1;

          with DataModule1.DataSource1.DataSet do
          begin
                // 查重
            solCRC := Calcu_CRC_32_2(PChar(Solitions[i]), Length(Solitions[i]));
            First;
            while not Eof do
            begin
              if (FieldByName('Sol_CRC32').AsInteger = solCRC) and (FieldByName('Moves').AsInteger = sMoves) and (FieldByName('Pushs').AsInteger = sPushs) then
                Break;

              Next;
            end;

            // 没有重复答案，则添加到答案库
            if Eof then
            begin
              Append;    // 修改

              FieldByName('XSB_CRC32').AsInteger := mapNode.CRC32;
              FieldByName('XSB_CRC_TrunNum').AsInteger := mapNode.CRC_Num;
              FieldByName('Goals').AsInteger := mapNode.Goals;
              FieldByName('Sol_CRC32').AsInteger := solCRC;
              FieldByName('Moves').AsInteger := sMoves;
              FieldByName('Pushs').AsInteger := sPushs;
              FieldByName('Sol_Text').AsString := Solitions[i];

              Post;    // 提交
            end;
          end;
        except
        end;
      end
      else
      begin
        Solitions.Delete(i);
      end;
    end;
    is_Solved := True;
    Solitions.Clear;
  end;

  if is_Solved then
    mapNode.Solved := is_Solved
  else
  begin
    // 数据库中是否有解
    try
      DataModule1.ADOQuery1.Close;
      DataModule1.ADOQuery1.SQL.Clear;
      DataModule1.ADOQuery1.SQL.Text := 'select id from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNode.CRC32) + ' and Goals = ' + IntToStr(mapNode.Goals);
      DataModule1.ADOQuery1.Open;
      mapNode.Solved := (DataModule1.ADOQuery1.RecordCount > 0);
    except
    end;
  end;
  DataModule1.ADOQuery1.Close;
end;

// 检查是否为有解关卡 -- 后台线程使用
procedure SetSolved_2(mapNode: PMapNode; var Solitions: TStringList);
var
  i, l, solCRC: Integer;
  is_Solved: Boolean;
begin
  is_Solved := false;
  mapNode.Solved := false;

  // 若解析到了答案，则验证答案并将答案入库
  if Solitions.Count > 0 then
  begin
    l := Solitions.Count;
    for i := l - 1 downto 0 do
    begin
      if isSolution(mapNode, PChar(Solitions[i])) then      // 对答案进行验证
      begin    // 保存到数据库
            // 保存答案到数据库
        try
          DataModule1.ADOQuery2.Close;
          DataModule1.ADOQuery2.SQL.Clear;
          DataModule1.ADOQuery2.SQL.Text := 'select * from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNode.CRC32) + ' and Goals = ' + IntToStr(mapNode.Goals);
          DataModule1.ADOQuery2.Open;
          DataModule1.DataSource2.DataSet := DataModule1.ADOQuery2;

          with DataModule1.DataSource2.DataSet do
          begin
                // 查重
            solCRC := Calcu_CRC_32_2(PChar(Solitions[i]), Length(Solitions[i]));
            First;
            while not Eof do
            begin
              if (FieldByName('Sol_CRC32').AsInteger = solCRC) and (FieldByName('Moves').AsInteger = sMoves) and (FieldByName('Pushs').AsInteger = sPushs) then
                Break;

              Next;
            end;

            // 没有重复答案，则添加到答案库
            if Eof then
            begin
              Append;    // 修改

              FieldByName('XSB_CRC32').AsInteger := mapNode.CRC32;
              FieldByName('XSB_CRC_TrunNum').AsInteger := mapNode.CRC_Num;
              FieldByName('Goals').AsInteger := mapNode.Goals;
              FieldByName('Sol_CRC32').AsInteger := solCRC;
              FieldByName('Moves').AsInteger := sMoves;
              FieldByName('Pushs').AsInteger := sPushs;
              FieldByName('Sol_Text').AsString := Solitions[i];

              Post;    // 提交
            end;
          end;
        except
        end;
      end
      else
      begin
        Solitions.Delete(i);
      end;
    end;
    is_Solved := True;
    Solitions.Clear;
  end;

  if is_Solved then
    mapNode.Solved := is_Solved
  else
  begin
    // 数据库中是否有解
    try
      DataModule1.ADOQuery2.Close;
      DataModule1.ADOQuery2.SQL.Clear;
      DataModule1.ADOQuery2.SQL.Text := 'select id from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNode.CRC32) + ' and Goals = ' + IntToStr(mapNode.Goals);
      DataModule1.ADOQuery2.Open;
      mapNode.Solved := (DataModule1.ADOQuery2.RecordCount > 0);
    except
    end;
  end;
  DataModule1.ADOQuery2.Close;
end;


// 迅速的加载指定文档的第 num 号地图
function QuicklyLoadMap(FileName: string; number: Integer): PMapNode;
var
  txtFile: TextFile;
  line, line2: string;
  is_XSB: Boolean;                 // 是否正在解析关卡XSB
  is_Comment: Boolean;             // 是否正在解析关卡说明信息
  num, n: Integer;                 // XSB的解析控制

begin
  try
    AssignFile(txtFile, FileName);
    Reset(txtFile);

    New(Result);
    Result.Map := TStringList.Create;
    Result.Rows := 0;
    Result.Cols := 0;
    Result.Trun := 0;
    Result.Title := '';
    Result.Author := '';
    Result.Comment := '';
    Result.CRC32 := -1;
    Result.CRC_Num := -1;
    Result.Solved := false;
    Result.isEligible := True;      // 默认是合格的关卡 XSB

    is_XSB := False;
    is_Comment := False;
    num := 0;

    while not eof(txtFile) do
    begin

      readln(txtFile, line);        // 读取一行
      line2 := Trim(line);

      if (not is_Comment) and isXSB(line) then
      begin       // 检查是否为 XSB 行
        if not is_XSB then
        begin     // 开始 XSB 块

          if (Result.Rows > 2) or (num = 0) then
            inc(num);     // 遇到的到 num 个 XSB 块

          if num > number then
            Break;

          is_XSB := True;    // 开始关卡 XSB 块
          is_Comment := False;
          Result.Map.Clear;
          Result.Rows := 0;
          Result.Num := num;
        end;

        if num = number then
        begin
          Result.Map.Add(line);      // 各 XSB 行
        end;
        inc(Result.Rows);

      end
      else if (not is_Comment) and (AnsiStartsText('title', line2)) then
      begin   // 匹配 Title，标题
        if num = number then
        begin
          n := Pos(':', line2);
          if n > 0 then
            Result.Title := trim(Copy(line2, n + 1, MaxInt))
          else
            Result.Title := trim(Copy(line2, 6, MaxInt));
        end;

        if is_XSB then
          is_XSB := false;      // 结束关卡SXB的解析
      end
      else if (not is_Comment) and (AnsiStartsText('author', line2)) then
      begin  // 匹配 Author，作者
        if num = number then
        begin
          n := Pos(':', line2);
          if n > 0 then
            Result.Author := trim(Copy(line2, n + 1, MaxInt))
          else
            Result.Author := trim(Copy(line2, 7, MaxInt));
        end;

        if is_XSB then
          is_XSB := false;      // 结束关卡SXB的解析
      end
      else if (AnsiStartsText('comment-end', line2)) or (AnsiStartsText('comment_end', line2)) then
      begin  // 匹配"注释"块结束
        is_Comment := False;
        ;      // 结束"注释"块
      end
      else if (AnsiStartsText('comment', line2)) then
      begin  //匹配"注释"块开始
        if is_XSB then
          is_XSB := false;      // 结束关卡SXB的解析
        n := Pos(':', line2);
        if n > 0 then
          line := trim(Copy(line2, n + 1, MaxInt))
        else
          line := trim(Copy(line2, 8, MaxInt));

        if Length(line) > 0 then
        begin
          if num = number then
            Result.Comment := line;     // 单行"注释"
        end
        else
          is_Comment := True;
        ;                            // 多行"注释"块

        if is_XSB then
          is_XSB := false;      // 结束关卡SXB的解析
      end
      else if is_Comment then
      begin  // "说明"信息
        if num = number then
        begin
          if Length(Result.Comment) > 0 then
            Result.Comment := Result.Comment + #10 + line
          else
            Result.Comment := line;
        end;
      end
      else
      begin
        if is_XSB then
          is_XSB := false;      // 结束关卡SXB块的解析
      end;
    end;

    // 检查最后的节点，若没有 XSB 数据，则将其删除
    if Result.Rows > 2 then
      MapNormalize(Result)
    else
    begin
      Result.Map.Clear;
      Result.Rows := 0;
    end;

    CloseFile(txtFile);                //关闭打开的文件
  except
    Result.Map.Clear;
    Result.Rows := 0;
  end;
end;

// 分割字符串
function Split(src: string): TStringList;
var
  i: integer;
  str: string;
begin
  result := TStringList.Create;

  src := StringReplace(src, #13, #10, [rfReplaceAll]);
  src := StringReplace(src, #10#10, #10, [rfReplaceAll]);

  repeat
    i := pos(#10, src);
    str := copy(src, 1, i - 1);
    if (str = '') and (i > 0) then
    begin
      result.Add('');
      delete(src, 1, 1);
      continue;
    end;
    if i > 0 then
    begin
      result.Add(str);
      delete(src, 1, i);
    end;
  until i <= 0;
  if src <> '' then
    result.Add(src);
end;

// 读取关卡 -- 从剪切板或文本字符串，text = nil 时，自动从剪切板加载
function LoadMapsFromText(text: string): boolean;
var
  line, line2: string;
  is_XSB: Boolean;                 // 是否正在解析关卡XSB
  is_Solution: Boolean;            // 是否答案行
  is_Comment: Boolean;             // 是否正在解析关卡说明信息
  num, n, k: Integer;        // XSB的解析控制
  mapNode: PMapNode;               // 解析出的当前关卡节点指针
  mapSolution: TStringList;        // 关卡答案
  XSB_Text: string;
  data_Text: TStringList;
  tmpList: TList;
begin
  Result := False;

  if text = '' then begin
     // 查询剪贴板中特定格式的数据内容
     if (Clipboard.HasFormat(CF_TEXT) or Clipboard.HasFormat(CF_OEMTEXT)) then begin
        XSB_Text := Clipboard.asText;
        data_Text := Split(XSB_Text);
     end else Exit;
  end else data_Text := Split(text);     // 从字符串加载
  

  MapList.Clear;
  tmpList := TList.Create;
  mapSolution := TStringList.Create;

  NewMapNode(tmpList);                // 先创建一个关卡节点
  is_XSB := False;
  is_Comment := False;
  is_Solution := False;
  mapNode := tmpList.Items[0];    // 指向最新创建的节点
  mapNode.isEligible := True;         // 默认是合格的关卡XSB
  k := 0;

  while k < data_Text.Count do
  begin

    line := data_Text.Strings[k];       // 读取一行
    Inc(k);
    line2 := Trim(line);

    if (not is_Comment) and isXSB(line) then
    begin       // 检查是否为 XSB 行
      if not is_XSB then
      begin     // 开始 XSB 块

        if mapNode.Map.Count > 2 then
        begin   // 前面有解析过的关卡 XSB，则把当前关卡加入关卡集列表
              // 做关卡的标准化，计算CRC等
          if MapNormalize(mapNode) then
          begin
            SetSolved(mapNode, mapSolution);
          end;

          NewMapNode(tmpList);                                  // 创建一个新的关卡节点
          num := tmpList.Count - 1;
          mapNode := tmpList.Items[num];                        // 指向最新创建的节点
          mapNode.isEligible := True;                           // 默认是合格的关卡XSB

        end
        else
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
    else if (not is_Comment) and (AnsiStartsText('title', line2)) then
    begin   // 匹配 Title，标题
      n := Pos(':', line2);
      if n > 0 then
        mapNode.Title := trim(Copy(line2, n + 1, MaxInt))
      else
        mapNode.Title := trim(Copy(line2, 6, MaxInt));

      if is_XSB then
        is_XSB := false;      // 结束关卡SXB的解析
    end
    else if (not is_Comment) and (AnsiStartsText('author', line2)) then
    begin  // 匹配 Author，作者
      n := Pos(':', line2);
      if n > 0 then
        mapNode.Author := trim(Copy(line2, n + 1, MaxInt))
      else
        mapNode.Author := trim(Copy(line2, 7, MaxInt));

      if is_XSB then
        is_XSB := false;      // 结束关卡SXB的解析
    end
    else if (not is_Comment) and (AnsiStartsText('solution', line2)) then
    begin  // 匹配 Solution，答案
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

      if is_XSB then
        is_XSB := false;      // 结束关卡SXB的解析
      is_Solution := true;                 // 开始答案解析
    end
    else if (AnsiStartsText('comment-end', line2)) or (AnsiStartsText('comment_end', line2)) then
    begin  // 匹配"注释"块结束
      is_Comment := False;
      ;  // 结束"注释"块
    end
    else if (AnsiStartsText('comment', line2)) then
    begin  //匹配"注释"块开始
      if is_XSB then
        is_XSB := false;      // 结束关卡SXB的解析

      n := Pos(':', line2);
      if n > 0 then
        line := trim(Copy(line2, n + 1, MaxInt))
      else
        line := trim(Copy(line2, 8, MaxInt));

      if Length(line) > 0 then
        mapNode.Comment := line     // 单行"注释"
      else
        is_Comment := True;
      ;  // 结束"注释"块
    end
    else if is_Comment then
    begin  // "说明"信息
      if Length(mapNode.Comment) > 0 then
        mapNode.Comment := mapNode.Comment + #10 + line
      else
        mapNode.Comment := line;

      if is_XSB then
        is_XSB := false;      // 结束关卡SXB的解析
    end
    else if is_Solution then
    begin  // 答案行
      line2 := StringReplace(line2, #9, '', [rfReplaceAll]);
      line2 := StringReplace(line2, ' ', '', [rfReplaceAll]);
      if isLurd(line2) then
      begin
        n := mapSolution.Count - 1;
        mapSolution[n] := mapSolution[n] + line2;
      end;
    end
    else
    begin
      if is_XSB then
        is_XSB := false;      // 结束关卡SXB块的解析
    end;
  end;

  // 检查最后的节点，若没有 XSB 数据，则将其删除
  num := tmpList.Count - 1;
  mapNode := tmpList.Items[num];
  if mapNode.Map.Count < 3 then
    tmpList.Delete(num)
  else
  begin
    if MapNormalize(mapNode) then
    begin
      SetSolved(mapNode, mapSolution);
    end
    else
      tmpList.Delete(num);
  end;


  if tmpList.Count > 0 then
  begin
    MapList := tmpList;
    tmpList := nil;
    Result := true;
  end;

  FreeAndNil(tmpList);
  FreeAndNil(mapSolution);

end;

// 地图标准化，包括：简单标准化 -- 保留关卡的墙外造型；精准标准化 -- 不保留关卡的墙外造型，同时计算 CRC 等
function MapNormalize(var mapNode: PMapNode): Boolean;
var
  i, j, k, t, mr, mc, Rows, Cols, nLen, nRen, nRows, nCols: Integer;
  ch: Char;
  mr2, mc2, left, top, right, bottom, nBox, nDst, mTop, mLeft, mBottom, mRight: Integer;
  P: TList;
  Pos, F: ^TPoint;
  s1: string;
  key8: array[0..7] of Integer;
begin
  Result := False;

  mr := -1;
  mc := -1;
  nRen := 0;
  Rows := mapNode.Map.Count;
  Cols := 0;
  for i := 0 to Rows - 1 do
  begin
    nLen := Length(mapNode.Map[i]);
    if Cols < nLen then
      Cols := nLen;
  end;

  mapNode.Rows := Rows;
  mapNode.Cols := Cols;

  if (Rows >= 100) or (Cols >= 100) then
  begin
    mapNode.Rows := 100;
    mapNode.Cols := 100;
    mapNode.isEligible := False;        // 不合格的关卡XSB
    Exit;
  end;

  for i := 0 to Rows - 1 do
  begin
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
            Inc(nRen);
            mr := i;
            mc := j;
          end;
      else
        MapArray[i, j] := '-';
      end;

    end;
  end;

  if nRen <> 1 then
  begin  // 仓管员 <> 1
    mapNode.isEligible := False;        // 不合格的关卡XSB
    Exit;
  end;

  for i := 0 to Rows - 1 do
  begin
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

  P := TList.Create;
  New(Pos);
  Pos.x := mc;
  Pos.y := mr;
  P.add(Pos);
  Mark[mr][mc] := true;
  while P.Count > 0 do
  begin // 走完后，Mark[][]为 true 的，为墙内
    F := P.Items[0];
    mr := F.Y;
    mc := F.X;
    P.Delete(0);

    case MapArray[mr, mc] of
      '$':
        begin
          Inc(nBox);
        end;
      '*':
        begin
          Inc(nBox);
          Inc(nDst);
        end;
      '.', '+':
        begin
          Inc(nDst);
        end;
    end;
    for k := 0 to 3 do
    begin   // 仓管员向四个方向走
      mr2 := mr + dr4[k];
      mc2 := mc + dc4[k];
      if (mr2 < 0) or (mr2 >= Rows) or (mc2 < 0) or (mc2 >= Cols) or    // 出界
        (Mark[mr2, mc2]) or (MapArray[mr2, mc2] = '#') then
        continue;  // 已访问或遇到墙
      // 调整四至
      if left > mc2 then
        left := mc2;
      if top > mr2 then
        top := mr2;
      if right < mc2 then
        right := mc2;
      if bottom < mr2 then
        bottom := mr2;

      New(Pos);
      Pos.x := mc2;
      Pos.y := mr2;
      P.add(Pos);
      Mark[mr2][mc2] := true;  //标记为已访问
    end;
  end;
  FreeAndNil(P);

  mapNode.Goals := nDst;

  if (nBox <> nDst) or (nBox < 1) or (nDst < 1) then
  begin  // 可达区域内的箱子与目标点数不正确
    mapNode.isEligible := False;        // 不合格的关卡XSB
    exit;
  end;

  // 标准化后的尺寸（八转）
  nRows := bottom - top + 1 + 2;
  nCols := right - left + 1 + 2;

  // 整理关卡元素
  for i := 0 to Rows - 1 do
  begin
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
  for k := 0 to Rows - 1 do
  begin
    t := 0;
    while (t < Cols) and (MapArray[k, t] = '_') do
      Inc(t);

    if t = Cols then
      Inc(mTop)
    else
      break;
  end;
  for k := Rows - 1 downto mTop + 1 do
  begin
    t := 0;
    while (t < Cols) and (MapArray[k, t] = '_') do
      Inc(t);
    if t = Cols then
      Dec(mBottom)
    else
      break;
  end;
  if mBottom - mTop < 2 then
  begin
    Exit;
  end;

  for k := 0 to Cols - 1 do
  begin
    t := mTop;
    while (t <= mBottom) and (MapArray[t, k] = '_') do
      Inc(t);
    if t > mBottom then
      Inc(mLeft)
    else
      break;
  end;
  for k := Cols - 1 downto mLeft + 1 do
  begin
    t := mTop;
    while (t <= mBottom) and (MapArray[t, k] = '_') do
      Inc(t);
    if t > mBottom then
      Dec(mRight)
    else
      break;
  end;
  if mRight - mLeft < 2 then
  begin
    Exit;
  end;

  // 关卡原貌，已做简单标准化（保留墙外造型）
  mapNode.Map.Clear;
  for i := mTop to mBottom do
  begin
    s1 := '';  // 保持关卡原貌，对墙外造型部分不再清理
    for j := mLeft to mRight do
    begin
      s1 := s1 + MapArray[i, j];
    end;
    mapNode.Map.Add(s1);
  end;
//  mapNode.Rows := mBottom-mTop+1;
//  mapNode.Cols := mRight-mLeft+1;
  mapNode.Rows := mapNode.Map.Count;
  mapNode.Cols := Length(mapNode.Map[0]);

  // 标准化关卡的四周填充 '_'
  for i := 0 to nRows - 1 do
  begin
    for j := 0 to nCols - 1 do
    begin
      if (i = 0) or (j = 0) or (i = nRows - 1) or (j = nCols - 1) then
        aMap0[i, j] := '_';
    end;
  end;

  // 标准化
  for i := 1 to nRows - 2 do
  begin
    for j := 1 to nCols - 2 do
    begin
      if (aMap0[i, j] <> '_') and (aMap0[i, j] <> '#') then
      begin  // 探查内部有效元素的八个方位，是否可以安排墙壁
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

  // 标准化后的八转：关卡先顺时针旋转（得到：0转、1转、2转、3转），4转为0转的左右镜像，4转再顺时针旋转（得到：4转、5转、6转、7转）
  for i := 0 to nRows - 1 do
  begin
    for j := 0 to nCols - 1 do
    begin
      aMap1[j, nRows - 1 - i] := aMap0[i, j];
      aMap2[nRows - 1 - i, nCols - 1 - j] := aMap0[i, j];
      aMap3[nCols - 1 - j, i] := aMap0[i, j];
      aMap4[i, nCols - 1 - j] := aMap0[i, j];
      aMap5[nCols - 1 - j, nRows - 1 - i] := aMap0[i, j];
      aMap6[nRows - 1 - i, j] := aMap0[i, j];
      aMap7[j, i] := aMap0[i, j];
    end;
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


  for i := 1 to 7 do
  begin
    if mapNode.CRC32 > key8[i] then
    begin
      mapNode.CRC32 := key8[i];
      mapNode.CRC_Num := i;
    end;
  end;

  Result := True;
end;

// 取得关卡 XSB
function GetXSB(): string;
var
  i: Integer;
begin
  Result := '';

  if curMapNode.Map.Count > 0 then
  begin
    for i := 0 to curMapNode.Map.Count - 1 do
    begin
      Result := Result + curMapNode.Map.Strings[i] + #10;
    end;
    if Trim(curMapNode.Title) <> '' then
      Result := Result + 'Title: ' + curMapNode.Title + #10;
    if Trim(curMapNode.Author) <> '' then
      Result := Result + 'Author: ' + curMapNode.Author + #10;
    if Trim(curMapNode.Comment) <> '' then
    begin
      Result := Result + 'Comment: ' + curMapNode.Comment + #10;
      Result := Result + 'Comment_end: ' + #10;
    end;
  end;
end;

// XSB 送入剪切板
procedure XSBToClipboard();
begin
  if curMapNode.Map.Count > 0 then
  begin
    Clipboard.SetTextBuf(PChar(GetXSB()));
  end;
end;

// 更新主窗口标题
procedure TLoadMapThread.UpdateCaption;
var
  i: Integer;
  mNode: PMapNode;               // 解析出的当前关卡节点指针

begin
  for i := 0 to MapList.Count do begin
      if SolvedLevel[i] > 0 then begin
         mNode := MapList[SolvedLevel[i]-1];
         mNode.Solved := True;
      end;
      Break;
  end;
  main.Caption := AppName + AppVer + ' - ' + ExtractFileName(ChangeFileExt(main.mySettings.MapFileName, EmptyStr)) + ' ~ [' + inttostr(main.curMap.CurrentLevel) + '/' + inttostr(MapList.Count) + ']';
  main.Caption := main.Caption + '，尺寸: ' + IntToStr(curMapNode.Cols) + '×' + IntToStr(curMapNode.Rows) + '，箱子: ' + IntToStr(curMapNode.Boxs) + '，目标: ' + IntToStr(curMapNode.Goals);

end;

// 在后台线程中加载地图文档
procedure TLoadMapThread.Execute;
var
  FileName: string;
  is_zhouzhuan: Boolean;           // 是否周转关卡库 -- 周转库文档（BoaMan.xsb）在解析时，只能解析前100个关卡，保存关卡到周转库时，会以“追加”方式，添加到文档尾部且不受100个数限制
  txtFile: TextFile;
  line, line2: string;
  is_XSB: Boolean;                 // 是否正在解析关卡XSB
  is_Solution: Boolean;            // 是否答案行
  is_Comment: Boolean;             // 是否正在解析关卡说明信息
  num, n, k, size: Integer;        // XSB的解析控制
  mapNode: PMapNode;               // 解析出的当前关卡节点指针
  mapSolution: TStringList;        // 关卡答案
  tmpMapList: TList;               // 临时关卡列表
  R: TRect;
//  MapIcon: TBitmap;                // 关卡图标

begin
  isRunning := True;
  isStopThread := False;

  MapList.Clear;

  FileName := main.mySettings.MapFileName;
  is_zhouzhuan := AnsiSameText(FileName, 'BoxMan.xsb');    // 是否解析的周转库文档

  if Pos(':', FileName) =0 then FileName := AppPath + FileName;
  if FileExists(FileName) then
  begin

    tmpMapList := TList.Create;             // 关卡列表

    try
      AssignFile(txtFile, FileName);
      Reset(txtFile);

      mapSolution := TStringList.Create;

      NewMapNode(tmpMapList);              // 先创建一个关卡节点
      is_XSB := False;
      is_Comment := False;
      is_Solution := False;
      mapNode := tmpMapList.Items[0];      // 指向最新创建的节点
      mapNode.isEligible := True;          // 默认是合格的关卡XSB

      while not eof(txtFile) and (not isStopThread) do
      begin

        readln(txtFile, line);            // 读取一行      WideToAnsi

        line2 := Trim(line);

        if (not is_Comment) and isXSB(line) then
        begin       // 检查是否为 XSB 行
          if not is_XSB then
          begin       // 开始 XSB 块

            if mapNode.Map.Count > 2 then
            begin   // 前面有解析过的关卡 XSB，则把当前关卡加入关卡集列表
                    // 做关卡的标准化，计算CRC等
              if MapNormalize(mapNode) then
              begin
                SetSolved_2(mapNode, mapSolution);
              end;

              if is_zhouzhuan and (tmpMapList.Count >= 100) then Break;

              NewMapNode(tmpMapList);                      // 创建一个新的关卡节点
              num := tmpMapList.Count - 1;
              mapNode := tmpMapList.Items[num];            // 指向最新创建的节点
              mapNode.isEligible := True;               // 默认是合格的关卡XSB

            end
            else
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
        else if (not is_Comment) and (AnsiStartsText('title', line2)) then
        begin   // 匹配 Title，标题
          n := Pos(':', line2);
          if n > 0 then
            mapNode.Title := trim(Copy(line2, n + 1, MaxInt))
          else
            mapNode.Title := trim(Copy(line2, 6, MaxInt));

          if is_XSB then
            is_XSB := false;      // 结束关卡SXB的解析
        end
        else if (not is_Comment) and (AnsiStartsText('author', line2)) then
        begin  // 匹配 Author，作者
          n := Pos(':', line2);
          if n > 0 then
            mapNode.Author := trim(Copy(line2, n + 1, MaxInt))
          else
            mapNode.Author := trim(Copy(line2, 7, MaxInt));

          if is_XSB then
            is_XSB := false;      // 结束关卡SXB的解析
        end
        else if (not is_Comment) and (AnsiStartsText('solution', line2)) then
        begin  // 匹配 Solution，答案
          is_Solution := not isOnlyXSB;     // 开始答案解析

          if is_Solution then begin
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
          end;
          if is_XSB then
            is_XSB := false;   // 结束关卡SXB的解析
        end
        else if (AnsiStartsText('comment-end', line2)) or (AnsiStartsText('comment_end', line2)) then
        begin  // 匹配"注释"块结束
          is_Comment := False;
          ;  // 结束"注释"块
        end
        else if (AnsiStartsText('comment', line2)) then
        begin  //匹配"注释"块开始
          if is_XSB then
            is_XSB := false;      // 结束关卡SXB的解析
          n := Pos(':', line2);
          if n > 0 then
            line := trim(Copy(line2, n + 1, MaxInt))
          else
            line := trim(Copy(line2, 8, MaxInt));
          if Length(line) > 0 then
            mapNode.Comment := line     // 单行"注释"
          else
            is_Comment := True;
          ;  // 结束"注释"块
        end
        else if is_Comment then
        begin  // "说明"信息
          if Length(mapNode.Comment) > 0 then
            mapNode.Comment := mapNode.Comment + #10 + line
          else
            mapNode.Comment := line;

          if is_XSB then
            is_XSB := false;      // 结束关卡SXB的解析
        end
        else if is_Solution then
        begin  // 答案行
          line2 := StringReplace(line2, #9, '', [rfReplaceAll]);
          line2 := StringReplace(line2, ' ', '', [rfReplaceAll]);
          if isLurd(line2) then
          begin
            n := mapSolution.Count - 1;
            mapSolution[n] := mapSolution[n] + line2;
          end;
        end
        else
        begin
          if is_XSB then
            is_XSB := false;      // 结束关卡SXB块的解析
        end;
      end;

        // 检查最后的节点，若没有 XSB 数据，则将其删除
      num := tmpMapList.Count - 1;
      mapNode := tmpMapList.Items[num];
      if mapNode.Map.Count < 3 then
        tmpMapList.Delete(num)
      else
      begin
        if MapNormalize(mapNode) then
        begin
          SetSolved_2(mapNode, mapSolution);
        end
        else
          tmpMapList.Delete(num);
      end;

    finally
      DataModule1.ADOQuery2.Close;
      CloseFile(txtFile);                //关闭打开的文件
      FreeAndNil(mapSolution);
    end;

    if (not isStopThread) and (tmpMapList.Count > 0) then
    begin         // 不是非正常结束

         // 生成关卡列表项
      BrowseForm.ImageList1.Clear;
      BrowseForm.ListView1.Items.Clear;

//      MapIcon := TBitmap.Create;                // 关卡图标
//      MapIcon.Width := BrowseForm.ImageList1.Width;
//      MapIcon.Height := BrowseForm.ImageList1.Height;
//      MapIcon.Canvas.Brush.Color := BrowseForm.BK_Color;
//      R := Rect(0, 0, MapIcon.Width, MapIcon.Height);
      R := Rect(0, 0, BrowseForm.Map_Icon.Width, BrowseForm.Map_Icon.Height);
      size := tmpMapList.Count;
      try
        for k := 0 to size - 1 do
        begin
          mapNode := tmpMapList[k];

          BrowseForm.ListView1.Items.add;

          if mapNode.Title = '' then
            BrowseForm.ListView1.Items[k].Caption := '【№: ' + IntToStr(k + 1) + '】'
          else
            BrowseForm.ListView1.Items[k].Caption := mapNode.Title;

          BrowseForm.ListView1.Items[k].ImageIndex := -1;       // 先默认没有图标

          // 画图标
//          MapIcon.Canvas.FillRect(R);
//          BrowseForm.DrawIcon(MapIcon.Canvas, mapNode);
//          BrowseForm.ImageList1.Add(MapIcon, nil);
//          BrowseForm.ListView1.Items[k].ImageIndex := BrowseForm.ImageList1.Count-1;

        end;
      finally
        mapNode := nil;
//        FreeAndNil(MapIcon);
      end;

      MapList := tmpMapList;
      tmpMapList := nil;

      synchronize(UpdateCaption);     // 更新主窗口标题
    end;

    FreeAndNil(tmpMapList);

  end;

  isRunning := False;
  isStopThread := True;
end;

end.

