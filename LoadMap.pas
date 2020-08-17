unit LoadMap;
// 关卡文本解析单元

interface

uses
  windows, classes, StrUtils, SysUtils, Clipbrd, CRC_32;
  
type                  // 关卡节点 -- 关卡集中的各个关卡
  TMapNode = record
    Map                  :TStringList;    // 关卡 XSB
    Rows, Cols           :integer;        // 关卡尺寸
    Goals                :integer;        // 目标点数
    Trun                 :integer;        // 关卡旋转登记
    Title                :string;         // 标题
    Author               :string;         // 作者
    Comment              :string;         // 关卡描述信息
    CRC32                :integer;        // CRC32
    CRC_Num              :integer;        // 第几转的CRC最小？
    Solved               :Boolean;        // 是否由答案
  end;
  PMapNode    =   ^TMapNode;              // 关卡节点指针

  function GetXSB(): string;                                     // 取得关卡 XSB
  procedure XSBToClipboard();                                    // XSB 送入剪切板
  function LoadMapsFromClipboard(): boolean;                     // 加载关卡 -- 剪切板
  function LoadMaps(FileName: string): boolean;                  // 加载关卡 -- 文档
  function MapNormalize(var mapNode: PMapNode): Boolean;         // 地图标准化，包括：简单标准化 -- 保留关卡的墙外造型；精准标准化 -- 不保留关卡的墙外造型，同时计算 CRC 等
  function isSolution(mapNode: PMapNode; sol: PChar): Boolean;   // 答案验证

var
  ManPos_BK_0           :integer;                     // 人的位置 -- 逆推，玩家已经指定的位置
  ManPos_BK_0_2         :integer;                     // 人的位置 -- 逆推，解析出来的位置

  sMoves, sPushs: integer;                            // 验证答案时，记录移动数和推动数

  MapList: TList;                          // 关卡集
  MapArray: array[0..99, 0..99] of Char;   // 标准化用关卡数组     
  Mark: array[0..99, 0..99] of Boolean;    // 标准化用标志数组
  curMapNode : PMapNode;                   // 当前关卡节点

  tmp_Board : array[0..9999] of integer;   // 临时地图
  
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
  LogFile,    // 测试
  LurdAction, DateModule;

const
  EmptyCell        = 0;
  WallCell         = 1;
  FloorCell        = 2;
  GoalCell         = 3;
  BoxCell          = 4;
  BoxGoalCell      = 5;
  ManCell          = 6;
  ManGoalCell      = 7;

// 判断是否为有效的 XSB 行
function isXSB(str: String): boolean;
var
  n, k: Integer;

begin
  result := False;

  n := Length(str);

  if n = 0 then exit;
  
  k := 1;
  // 检查是否是空行 -- 仅有空格和跳格符
  while k <= n do begin
     if (str[k] <> #20) and (str[k] <> #8) or (str[k] = '') then Break;
     Inc(k);
  end;
  if k > n then Exit;

  k := 1;
  while k <= n do begin
     if not (str[k] in [ ' ', '_', '-', '#', '.', '$', '*', '@', '+' ]) then Break;
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
  for i := 0 to Rows-1 do begin
      for j := 1 to Cols do begin
          ch := mapNode.Map[i][j];
          case ch of
              '#': tmp_Board[i * Cols + j] := WallCell;
              '-': tmp_Board[i * Cols + j] := FloorCell;
              '.': tmp_Board[i * Cols + j] := GoalCell;
              '$': tmp_Board[i * Cols + j] := BoxCell;
              '*': tmp_Board[i * Cols + j] := BoxGoalCell;
              '@': tmp_Board[i * Cols + j] := ManCell;
              '+': tmp_Board[i * Cols + j] := ManGoalCell;
              else tmp_Board[i * Cols + j] := EmptyCell;
          end;
          
          if ch in [ '@', '+' ] then mpos := i * Cols + j;
      end;
  end;

  if mpos < 0 then Exit;
  sPushs := 0;
  sMoves := 0;

  // 答案验证
  len := Length(sol);
  for i := 0 to len-1 do begin
      pos1 := -1;
      pos2 := -1;
      ch := sol[i];
      case ch of
         'l', 'L': begin
            pos1 := mpos - 1;
            pos2 := mpos - 2;
         end;
         'r', 'R': begin
            pos1 := mpos + 1;
            pos2 := mpos + 2;
         end;
         'u', 'U': begin
            pos1 := mpos - mapNode.Cols;
            pos2 := mpos - mapNode.Cols * 2;
         end;
         'd', 'D': begin
            pos1 := mpos + mapNode.Cols;
            pos2 := mpos + mapNode.Cols * 2;
         end;
      end;
      isPush := ch in [ 'L', 'R', 'U', 'D' ];

      if (pos1 < 0) or (pos1 >= size) or (isPush and ((pos1 < 0) or (pos1 >= size))) then Exit;             // 界外

      if isPush then begin                                                                                 // 无效推动
         if (tmp_Board[pos1] <> BoxCell) and (tmp_Board[pos1] <> BoxGoalCell) or (tmp_Board[pos2] <> FloorCell) and (tmp_Board[pos2] <> GoalCell) then Exit;
         if tmp_Board[pos2] = FloorCell then tmp_Board[pos2] := BoxCell
         else tmp_Board[pos2] := BoxGoalCell;
         if tmp_Board[pos1] = BoxCell then tmp_Board[pos1] := ManCell
         else tmp_Board[pos1] := ManGoalCell;
         if tmp_Board[mpos] = ManCell then tmp_Board[mpos] := FloorCell
         else tmp_Board[mpos] := GoalCell;
      end else begin
         if (tmp_Board[pos1] <> FloorCell) and (tmp_Board[pos1] <> GoalCell) then Exit;                    // 无效移动
         if tmp_Board[pos1] = FloorCell then tmp_Board[pos1] := ManCell
         else tmp_Board[pos1] := ManGoalCell;
         if tmp_Board[mpos] = ManCell then tmp_Board[mpos] := FloorCell
         else tmp_Board[mpos] := GoalCell;
      end;

      if isPush then Inc(sPushs);
      Inc(sMoves);
      
      mpos := pos1;
      
      okNum := 0;
      for j := 0 to size - 1 do begin
          if (tmp_Board[j] = BoxGoalCell) then Inc(okNum);

          if okNum = mapNode.Goals then begin                     // 能够解关，为有效答案
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
  mapNode.Map     := TStringList.Create;
  mapNode.Rows    := 0;
  mapNode.Cols    := 0;
  mapNode.Trun    := 0;
  mapNode.Title   := '';
  mapNode.Author  := '';
  mapNode.Comment := '';
  mapNode.CRC32   := -1;
  mapNode.CRC_Num := -1;
  mapNode.Solved  := false;

  mpList.Add(mapNode);          // 加入关卡集列表

end;

// 检查是否为有解关卡
procedure SetSolved(mapNode: PMapNode; var Solitions: TStringList);
var
  i, l: Integer;
  is_Solved: Boolean;
  
begin
  is_Solved := false;
  mapNode.Solved := false;

  // 若解析到了答案，则验证答案并将答案入库
  if Solitions.Count > 0 then begin
     l := Solitions.Count;
     for i := l-1 downto 0 do begin
         if isSolution(mapNode, PChar(Solitions[i])) then begin    // 保存到数据库
            // 保存答案到数据库
            try
              DataModule1.ADOQuery1.Close;
              DataModule1.ADOQuery1.SQL.Clear;
              DataModule1.ADOQuery1.SQL.Text := 'select * from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNode.CRC32) + ' and Goals = ' + IntToStr(mapNode.Goals);
              DataModule1.ADOQuery1.Open;
              DataModule1.DataSource1.DataSet := DataModule1.ADOQuery1;

              with DataModule1.ADOQuery1 do begin

                Append;    // 修改

                FieldByName('XSB_CRC32').AsInteger := mapNode.CRC32;
                FieldByName('XSB_CRC_TrunNum').AsInteger := mapNode.CRC_Num;
                FieldByName('Goals').AsInteger := mapNode.Goals;
                FieldByName('Sol_CRC32').AsInteger := Calcu_CRC_32_2(PChar(Solitions[i]), Length(Solitions[i]));
                FieldByName('Moves').AsInteger := sMoves;
                FieldByName('Pushs').AsInteger := sPushs;
                FieldByName('Sol_Text').AsString := Solitions[i];

                Post;    // 提交

              end;
            except
            end;
            DataModule1.ADOQuery1.Close;
         end else begin
            Solitions.Delete(i);
         end;
     end;
     is_Solved := (Solitions.Count > 0);
     Solitions.Clear;
  end;

  if is_Solved then mapNode.Solved := is_Solved
  else begin
      // 数据库中是否有解
      try
        DataModule1.ADOQuery1.Close;
        DataModule1.ADOQuery1.SQL.Clear;
        DataModule1.ADOQuery1.SQL.Text := 'select id from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNode.CRC32) + ' and Goals = ' + IntToStr(mapNode.Goals);
        DataModule1.ADOQuery1.Open;
        mapNode.Solved := (DataModule1.ADOQuery1.RecordCount > 0);
      except
      end;
      DataModule1.ADOQuery1.Close;
  end;
end;

// 读取关卡文档
function LoadMaps(FileName: string): boolean;
var
  txtFile: TextFile;
  line, line2: String;
  is_XSB: Boolean;                 // 是否正在解析关卡XSB
  is_Solution: Boolean;            // 是否答案行
  is_Comment: Boolean;             // 是否正在解析关卡说明信息
  num, l, n: Integer;              // XSB的解析控制
  mapNode: PMapNode;               // 解析出的当前关卡节点指针
  mapSolution: TStringList;        // 关卡答案
  tmpList: TList;

begin
  Result := False;

  try
    AssignFile(txtFile, FileName);
    Reset(txtFile);

    tmpList     := TList.Create;
    mapSolution := TStringList.Create;

    NewMapNode(tmpList);             // 先创建一个关卡节点
    is_XSB      := False;
    is_Comment  := False;
    is_Solution := False;
    mapNode := tmpList.Items[0];     // 指向最新创建的节点

    while not eof(txtFile) do begin

       readln(txtFile, line);        // 读取一行
       line2 := Trim(line);

       if (not is_Comment) and isXSB(line) then begin       // 检查是否为 XSB 行
          if not is_XSB then begin     // 开始 XSB 块
        
             if mapNode.Map.Count > 2 then begin   // 前面有解析过的关卡 XSB，则把当前关卡加入关卡集列表

                // 做关卡的标准化，计算CRC等
                if MapNormalize(mapNode) then begin

                    SetSolved(mapNode, mapSolution);

                    NewMapNode(tmpList);                      // 创建一个新的关卡节点
                    num     := tmpList.Count-1;
                    mapNode := tmpList.Items[num];            // 指向最新创建的节点
                end else begin
                    mapNode.Map.Clear;
                end;
             end;

             is_XSB      := True;    // 开始关卡 XSB 块
             is_Comment  := False;
             mapNode.Rows    := 0;
             mapNode.Cols    := 0;
             mapNode.Title   := '';
             mapNode.Author  := '';
             mapNode.Comment := '';
          end;

          mapNode.Map.Add(line);    // 各 XSB 行

       end else
       if (not is_Comment) and (AnsiStartsText('title', line2)) then begin   // 匹配 Title，标题
          l := Length(line2);
          n := Pos(':', line2);
          if n > 0 then mapNode.Title := trim(RightStr(line2, l-n))
          else          mapNode.Title := trim(RightStr(line2, l-5));
        
          if is_XSB then is_XSB := false;      // 结束关卡SXB的解析
       end else
       if (not is_Comment) and (AnsiStartsText('author', line2)) then begin  // 匹配 Author，作者
          l := Length(line2);
          n := Pos(':', line2);
          if n > 0 then mapNode.Author := trim(RightStr(line2, l-n))
          else          mapNode.Author := trim(RightStr(line2, l-6));

          if is_XSB then is_XSB := false;      // 结束关卡SXB的解析
       end else
       if (not is_Comment) and (AnsiStartsText('solution', line2)) then begin  // 匹配 Solution，答案
          l := Length(line2);
          n := Pos(':', line2);
          if n = 0 then n := Pos(')', line2);
        
          if n > 0 then line := trim(RightStr(line2, l-n))
          else          line := trim(RightStr(line2, l-8));

          if Length(line) > 0 then mapSolution.Add(line)
          else                     mapSolution.Add('');

          if is_XSB then is_XSB := false;      // 结束关卡SXB的解析
          is_Solution := true;                 // 开始答案解析
       end else
       if (AnsiStartsText('comment-end', line2)) or (AnsiStartsText('comment_end', line2)) then begin  // 匹配"注释"块结束
          is_Comment := False;;  // 结束"注释"块
       end else
       if (AnsiStartsText('comment', line2)) then begin  //匹配"注释"块开始
          if is_XSB then is_XSB := false;      // 结束关卡SXB的解析
        
          l := Length(line2);
          n := Pos(':', line2);
          if n > 0 then line := trim(RightStr(line2, l-n))
          else          line := trim(RightStr(line2, l-7));

          if Length(line) > 0 then mapNode.Comment := line     // 单行"注释"
          else is_Comment := True;;  // 结束"注释"块
       end else
       if is_Comment then begin  // "说明"信息
          if Length(mapNode.Comment) > 0 then mapNode.Comment := mapNode.Comment + #10 + line
          else                                mapNode.Comment := line;
        
          if is_XSB then is_XSB := false;      // 结束关卡SXB的解析
       end else
       if is_Solution then begin  // 答案行
          if isLurd(line2) then begin
             n := mapSolution.Count-1;
             mapSolution[n] := mapSolution[n] + line2;
          end;
       end else begin
          if is_XSB then is_XSB := false;      // 结束关卡SXB块的解析
       end;
    end;

    // 检查最后的节点，若没有 XSB 数据，则将其删除
    num     := tmpList.Count-1;
    mapNode := tmpList.Items[num];
    if mapNode.Map.Count < 3 then tmpList.Delete(num)
    else begin
       if MapNormalize(mapNode) then begin
          SetSolved(mapNode, mapSolution);
       end else tmpList.Delete(num);
    end;

    CloseFile(txtFile);                //关闭打开的文件
    FreeAndNil(mapSolution);

    if tmpList.Count > 0 then begin
       MapList := tmpList;
       Result := true;
    end;
  except
  end;
end;

// 分割字符串
function Split(src: string): TStringList;
var
  i : integer;
  str : string;

begin
  result := TStringList.Create;

  src := StringReplace (src, #13, #10, [rfReplaceAll]);
  src := StringReplace (src, #10#10, #10, [rfReplaceAll]);

  repeat
    i := pos(#10, src);
    str := copy(src, 1, i-1);
    if (str = '') and (i > 0) then begin
      result.Add('');
      delete(src, 1, 1);
      continue;
    end;
    if i > 0 then begin
      result.Add(str);
      delete(src, 1, i);
    end;
  until i <= 0;
  if src <> '' then result.Add(src);
end;

// 读取关卡 -- 剪切板
function LoadMapsFromClipboard(): boolean;
var
  line, line2: String;
  is_XSB: Boolean;                 // 是否正在解析关卡XSB
  is_Solution: Boolean;            // 是否答案行
  is_Comment: Boolean;             // 是否正在解析关卡说明信息
  num, l, n, k, i: Integer;        // XSB的解析控制
  mapNode: PMapNode;               // 解析出的当前关卡节点指针
  mapSolution: TStringList;        // 关卡答案
  XSB_Text: string;
  data_Text: TStringList;
  tmpList: TList;
  is_Solved: Boolean;              // 是否真答案

begin
  Result := False;

  // 查询剪贴板中特定格式的数据内容
  if (Clipboard.HasFormat(CF_TEXT) or Clipboard.HasFormat(CF_OEMTEXT)) then begin
      XSB_Text  := Clipboard.asText;
      data_Text := Split(XSB_Text);
  end else Exit;

  tmpList     := TList.Create;
  mapSolution := TStringList.Create;

  NewMapNode(tmpList);                // 先创建一个关卡节点
  is_XSB      := False;
  is_Comment  := False;
  is_Solution := False;
  mapNode     := tmpList.Items[0];    // 指向最新创建的节点
  k := 0;

  while k < data_Text.Count do begin

     line := data_Text.Strings[k];       // 读取一行
     Inc(k);
     line2 := Trim(line);

     if (not is_Comment) and isXSB(line) then begin       // 检查是否为 XSB 行
        if not is_XSB then begin     // 开始 XSB 块
        
           if mapNode.Map.Count > 2 then begin   // 前面有解析过的关卡 XSB，则把当前关卡加入关卡集列表

              // 做关卡的标准化，计算CRC等
              if MapNormalize(mapNode) then begin

                  SetSolved(mapNode, mapSolution);
                  
                  NewMapNode(tmpList);                                  // 创建一个新的关卡节点
                  num     := tmpList.Count-1;
                  mapNode := tmpList.Items[num];                        // 指向最新创建的节点

              end else begin
                  mapNode.Map.Clear;
              end;
           end;

           is_XSB      := True;    // 开始关卡 XSB 块
           is_Comment  := False;
           mapNode.Rows    := 0;
           mapNode.Cols    := 0;
           mapNode.Title   := '';
           mapNode.Author  := '';
           mapNode.Comment := '';
        end;

        mapNode.Map.Add(line);    // 各 XSB 行

     end else
     if (not is_Comment) and (AnsiStartsText('title', line2)) then begin   // 匹配 Title，标题
        l := Length(line2);
        n := Pos(':', line2);
        if n > 0 then mapNode.Title := trim(RightStr(line2, l-n))
        else          mapNode.Title := trim(RightStr(line2, l-5));
        
        if is_XSB then is_XSB := false;      // 结束关卡SXB的解析
     end else
     if (not is_Comment) and (AnsiStartsText('author', line2)) then begin  // 匹配 Author，作者
        l := Length(line2);
        n := Pos(':', line2);
        if n > 0 then mapNode.Author := trim(RightStr(line2, l-n))
        else          mapNode.Author := trim(RightStr(line2, l-6));

        if is_XSB then is_XSB := false;      // 结束关卡SXB的解析
     end else
     if (not is_Comment) and (AnsiStartsText('solution', line2)) then begin  // 匹配 Solution，答案
        l := Length(line2);
        n := Pos(':', line2);
        if n = 0 then n := Pos(')', line2);
        
        if n > 0 then line := trim(RightStr(line2, l-n))
        else          line := trim(RightStr(line2, l-8));

        if Length(line) > 0 then mapSolution.Add(line)
        else                     mapSolution.Add('');

        if is_XSB then is_XSB := false;      // 结束关卡SXB的解析
        is_Solution := true;                 // 开始答案解析
     end else
     if (AnsiStartsText('comment-end', line2)) or (AnsiStartsText('comment_end', line2)) then begin  // 匹配"注释"块结束
        is_Comment := False;;  // 结束"注释"块
     end else
     if (AnsiStartsText('comment', line2)) then begin  //匹配"注释"块开始
        if is_XSB then is_XSB := false;      // 结束关卡SXB的解析
        
        l := Length(line2);
        n := Pos(':', line2);
        if n > 0 then line := trim(RightStr(line2, l-n))
        else          line := trim(RightStr(line2, l-7));

        if Length(line) > 0 then mapNode.Comment := line     // 单行"注释"
        else is_Comment := True;;  // 结束"注释"块
     end else
     if is_Comment then begin  // "说明"信息
        if Length(mapNode.Comment) > 0 then mapNode.Comment := mapNode.Comment + #10 + line
        else                                mapNode.Comment := line;
        
        if is_XSB then is_XSB := false;      // 结束关卡SXB的解析
     end else
     if is_Solution then begin  // 答案行
        if isLurd(line2) then begin
           n := mapSolution.Count-1;
           mapSolution[n] := mapSolution[n] + line2;
        end;
     end else begin
        if is_XSB then is_XSB := false;      // 结束关卡SXB块的解析
     end;
  end;

  // 检查最后的节点，若没有 XSB 数据，则将其删除
  num     := tmpList.Count-1;
  mapNode := tmpList.Items[num];
  if mapNode.Map.Count < 3 then tmpList.Delete(num)
  else begin
     if MapNormalize(mapNode) then begin
        SetSolved(mapNode, mapSolution);
     end else tmpList.Delete(num);
  end;

  FreeAndNil(mapSolution);

  if tmpList.Count > 0 then begin
     MapList := tmpList;
     Result := true;
  end;

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

  mr := -1; mc := -1;
  nRen := 0;
  Rows := mapNode.Map.Count;
  Cols := 0;
  for i := 0 to Rows-1 do begin
      nLen := Length(mapNode.Map[i]);
      if Cols < nLen then Cols := nLen;
  end;

  if (Rows >= 100) or (Cols >= 100) then Exit;

  for i := 0 to Rows-1 do begin
    nLen := Length(mapNode.Map[i]);
    for j := 0 to Cols-1 do begin
      if j < nLen then ch := mapNode.Map[i][j+1]
      else             ch := '-';

      case (ch) of
        '#', '.', '$', '*': begin
           MapArray[i, j] := ch;
        end;
        '@', '+': begin
          MapArray[i, j] := ch;
          Inc(nRen);
          mr := i;
          mc := j;
        end;
        else MapArray[i, j] := '-';
      end;
      
    end;
  end;

  if nRen <> 1 then begin  // 仓管员 <> 1
     Exit;
  end;

  for i := 0 to Rows-1 do begin
    for j := 0 to Cols-1 do begin
      Mark[i][j] := false;
    end;
  end;

  left := mc; top := mr; right := mc; bottom := mr; nBox := 0; nDst := 0;

  P := TList.Create;
  New(Pos);
  Pos.x := mc;
  Pos.y := mr;
  P.add(Pos);
  Mark[mr][mc] := true;
  while P.Count > 0 do begin // 走完后，Mark[][]为 true 的，为墙内
    F := P.Items[0];
    mr := F.Y;
    mc := F.X;
    P.Delete(0);
    
    case MapArray[mr, mc] of
      '$': begin
        Inc(nBox);
      end;
      '*': begin
        Inc(nBox);
        Inc(nDst);
      end;
      '.', '+': begin
        Inc(nDst);
      end;
    end;
    for k := 0 to 3 do begin   // 仓管员向四个方向走
      mr2 := mr + dr4[k];
      mc2 := mc + dc4[k];
      if (mr2 < 0) or (mr2 >= Rows) or (mc2 < 0) or (mc2 >= Cols) or    // 出界
         (Mark[mr2, mc2]) or (MapArray[mr2, mc2] = '#') then continue;  // 已访问或遇到墙

      // 调整四至
      if left   > mc2 then left   := mc2;
      if top    > mr2 then top    := mr2;
      if right  < mc2 then right  := mc2;
      if bottom < mr2 then bottom := mr2;

      New(Pos);
      Pos.x := mc2;
      Pos.y := mr2;
      P.add(Pos);
      Mark[mr2][mc2] := true;  //标记为已访问
    end;
  end;
  FreeAndNil(P);

  if (nBox <> nDst) or (nBox < 1) or (nDst < 1) then begin  // 可达区域内的箱子与目标点数不正确
     exit;
  end;

  mapNode.Goals := nDst;

  // 标准化后的尺寸（八转）
  nRows := bottom-top+1+2;
  nCols := right-left+1+2;

  // 整理关卡元素
  for i := 0 to Rows-1 do begin
    for j := 0 to Cols-1 do begin
      ch := MapArray[i, j];
      if (Mark[i, j]) then begin  // 墙内
        if not (ch in [ '-', '.', '$', '*', '@', '+' ]) then begin  //无效元素
          ch := '-';
          MapArray[i, j] := ch;
        end;
      end else begin  // 墙外造型
        if (ch = '*') or (ch = '$') then begin
          ch := '#';
          MapArray[i, j] := ch;
        end else if not (ch in [ '#', '_' ]) then begin  // 无效元素
          ch := '_';
          MapArray[i, j] := ch;
        end;
      end;
      if (i >= top) and (i <= bottom) and (j >= left) and (j <= right) then begin  // “四至”范围内
        if Mark[i, j] then aMap0[i-top+1, j-left+1] := ch  // 标准化关卡的有效元素（暂时空出四周）
        else               aMap0[i-top+1, j-left+1] := '_';
      end;
    end;
  end;

  // 关卡最小化
  mTop := 0; mLeft := 0; mBottom := Rows-1; mRight := Cols-1;
  for k := 0 to Rows-1 do begin
    t := 0;
    while (t < Cols) and (MapArray[k, t] = '_') do Inc(t);

    if t = Cols then Inc(mTop)
    else break;
  end;
  for k := Rows-1 downto mTop+1 do begin
    t := 0;
    while (t < Cols) and (MapArray[k, t] = '_') do Inc(t);
    if t = Cols then Dec(mBottom)
    else break;
  end;
  if mBottom - mTop < 2 then begin
     Exit;
  end;

  for k := 0 to Cols-1 do begin
    t := mTop;
    while (t <= mBottom) and (MapArray[t, k] = '_') do Inc(t);
    if t > mBottom then Inc(mLeft)
    else break;
  end;
  for k := Cols-1 downto mLeft+1 do begin
    t := mTop;
    while (t <= mBottom) and (MapArray[t, k] = '_') do Inc(t);
    if t > mBottom then Dec(mRight)
    else break;
  end;
  if mRight - mLeft < 2 then begin
     Exit;
  end;

  // 关卡原貌，已做简单标准化（保留墙外造型）
  mapNode.Map.Clear;  
  for i := mTop to mBottom do begin
    s1 := '';  // 保持关卡原貌，对墙外造型部分不再清理
    for j := mLeft to mRight do begin
      s1 := s1 + MapArray[i, j];
    end;
    mapNode.Map.Add(s1);
  end;
//  mapNode.Rows := mBottom-mTop+1;
//  mapNode.Cols := mRight-mLeft+1;
  mapNode.Rows := mapNode.Map.Count;
  mapNode.Cols := Length(mapNode.Map[0]);

  // 标准化关卡的四周填充 '_'
  for i := 0 to nRows-1 do begin
    for j := 0 to nCols-1 do begin
      if (i = 0) or (j = 0) or (i = nRows-1) or (j = nCols-1) then aMap0[i, j] := '_';
    end;
  end;

  // 标准化
  for i := 1 to nRows-2 do begin
    for j := 1 to nCols-2 do begin
      if (aMap0[i, j] <> '_') and (aMap0[i, j] <> '#') then begin  // 探查内部有效元素的八个方位，是否可以安排墙壁
        if (aMap0[i-1, j] = '_') then aMap0[i-1, j] := '#';
        if (aMap0[i+1, j] = '_') then aMap0[i+1, j] := '#';
        if (aMap0[i, j-1] = '_') then aMap0[i, j-1] := '#';
        if (aMap0[i, j+1] = '_') then aMap0[i, j+1] := '#';
        if (aMap0[i+1, j-1] = '_') then aMap0[i+1, j-1] := '#';
        if (aMap0[i+1, j+1] = '_') then aMap0[i+1, j+1] := '#';
        if (aMap0[i-1, j-1] = '_') then aMap0[i-1, j-1] := '#';
        if (aMap0[i-1, j+1] = '_') then aMap0[i-1, j+1] := '#';
      end;
    end;
  end;

  // 标准化后的八转：关卡先顺时针旋转（得到：0转、1转、2转、3转），4转为0转的左右镜像，4转再顺时针旋转（得到：4转、5转、6转、7转）
  for i := 0 to nRows-1 do begin
    for j := 0 to nCols-1 do begin
      aMap1[j, nRows-1-i] := aMap0[i, j];
      aMap2[nRows-1-i, nCols-1-j] := aMap0[i, j];
      aMap3[nCols-1-j, i] := aMap0[i, j];
      aMap4[i, nCols-1-j] := aMap0[i, j];
      aMap5[nCols-1-j, nRows-1-i] := aMap0[i, j];
      aMap6[nRows-1-i, j] := aMap0[i, j];
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
  mapNode.CRC32   := Calcu_CRC_32(@aMap0, nRows, nCols);        // 精准标准化后的关卡 -- 没有墙外造型
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
    if mapNode.CRC32 > key8[i] then begin
      mapNode.CRC32   := key8[i];
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

   if curMapNode.Map.Count > 0 then begin
      for i := 0 to curMapNode.Map.Count-1 do begin
          Result := Result + curMapNode.Map.Strings[i] + #10;
      end;
      if Trim(curMapNode.Title) <> '' then Result := Result + 'Title: ' + curMapNode.Title + #10;
      if Trim(curMapNode.Author) <> '' then Result := Result + 'Author: ' + curMapNode.Author + #10;
      if Trim(curMapNode.Comment) <> '' then begin
         Result := Result + 'Comment: ' + curMapNode.Comment + #10;
         Result := Result + 'Comment_end: ' + #10;
      end;
   end;
end;

// XSB 送入剪切板
procedure XSBToClipboard();
begin
   if curMapNode.Map.Count > 0 then begin
      Clipboard.SetTextBuf(PChar(GetXSB()));
   end;
end;


end.
