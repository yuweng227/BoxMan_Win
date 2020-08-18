unit LurdAction;

interface

uses
  windows, classes, StrUtils, SysUtils, Contnrs, Clipbrd, Math, CRC_32;

type
  TSoltionNode = record        // 主窗口左边栏，答案列表节点
      id      : Integer;           // 在 db 中的 id
      Moves   : Integer;           // 移动步数
      Pushs   : Integer;           // 推动步数
      CRC32   : Integer;           // 答案 CRC
      DateTime: TDateTime;            // 时间戳
  end;
  PTSoltionNode = ^TSoltionNode;

  TStateNode = record         // 主窗口左边栏，状态列表节点
      id           : Integer;      // 在 db 中的 id
      Moves        : Integer;      // 移动步数
      Pushs        : Integer;      // 推动步数
      Moves_BK     : Integer;      // 逆推移动步数
      Pushs_BK     : Integer;      // 逆推推动步数
      CRC32        : Integer;      // 答案 CRC
      CRC32_BK     : Integer;      // 答案 CRC
      Man_X        : Integer;      // 人的位置 -- 列
      Man_Y        : Integer;      // 人的位置 -- 行
      DateTime     : TDateTime;    // 时间戳
  end;
  PTStateNode = ^TStateNode;

const
  MaxLenPath = 200000;       // 路径最大长度限制

  // 四邻常量：左、右、上、下
  dr4 : array[0..3] of Integer = (  0, 0, -1, 1 );
  dc4 : array[0..3] of Integer = ( -1, 1,  0, 0 );
  
var
  UndoList, RedoList, UndoList_BK, RedoList_BK: array[1..MaxLenPath+1] of Char; // 保存正逆推 Undo、Redo 动作的数组
  UnDoPos, ReDoPos, UnDoPos_BK, ReDoPos_BK: Integer;                            // undo、redo 位置指针

  function LurdToClipboard(c, r: Integer): Boolean;        // Lurd 送入剪切板
  function LurdToClipboard2(isBK: Boolean): Boolean;       // 后续动作 Lurd 送入剪切板
  function LoadLurdFromClipboard(isBK: Boolean): boolean;  // 从剪切板加载 Lurd
  function isLurd(str: String): boolean;                   // 判断是否为有效的 Lurd 行
  function isLurd_2(str: String): boolean;                 // 判断是否为有效的 Lurd 行 -- 允许逆推的动作字符
  procedure GetLurd(strLurd: string; isBK: Boolean);       // 从字符串中提取 Lurd 送入 Redo

implementation

uses
  Board;

// 释放 TStrings 的内存
procedure MyStringsFree(var _Strings_: TStrings);
var
  i, len: Integer;
begin
  if Assigned(_Strings_) then begin
     len := _Strings_.Count;
     for i := 0 to len-1 do _Strings_[i] := '';
     _Strings_.Clear;
     _Strings_.Free;
     _Strings_ := nil;
  end;
end;

// 判断是否为有效的 Lurd 行 -- 仅正推动作字符
function isLurd(str: String): boolean;
var
  n, k: Integer;

begin
  result := False;

  n := Length(str);

  if n = 0 then exit;    
  
  k := 1;
  while k <= n do begin
     if not (str[k] in [ 'l', 'u', 'r', 'd', 'L', 'U', 'R', 'D', ' ', #9 ]) then Break;
     Inc(k);
  end;

  result := k > n;
end;

// 判断是否为有效的 Lurd 行 -- 包含逆推动作字符
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
     Inc(k);
  end;

  result := k > n;
end;
  
// Lurd 送入剪切板
function LurdToClipboard(c, r: Integer): Boolean;
var
  str, str1, str2: string;

begin
   Result := False;

   if (UnDoPos <= 0) and (UnDoPos_BK <= 0) then Exit;

   if UnDoPos    < MaxLenPath then UndoList[UnDoPos+1]       := #0;
   if UnDoPos_BK < MaxLenPath then UndoList_BK[UnDoPos_BK+1] := #0;

   str  := PChar(@UndoList);
   str1 := '[' + IntToStr(c+1) + ', ' + IntToStr(r+1) + ']';
   str2 := PChar(@UndoList_BK);

   if UnDoPos > 0 then begin
      if UnDoPos_BK > 0 then begin
         Clipboard.SetTextBuf(PChar(str+#10+str1+str2));
         Result := true;
      end else begin
         Clipboard.SetTextBuf(PChar(str));
         Result := true;
      end;
   end else begin
      if UnDoPos_BK > 0 then begin
         Clipboard.SetTextBuf(PChar(str1+str2));
         Result := true;
      end;
   end;
end;

// 后续动作 Lurd 送入剪切板
function LurdToClipboard2(isBK: Boolean): Boolean;
var
  str: string;

begin
   Result := False;

   if isBK then begin
      if ReDoPos_BK > 0 then begin
         if ReDoPos_BK < MaxLenPath then RedoList_BK[ReDoPos_BK+1] := #0;
         str := PChar(@RedoList_BK);
         Clipboard.SetTextBuf(PChar(reversestring(str)));
         Result := true;
      end;
   end else begin
      if ReDoPos > 0 then begin
         if ReDoPos < MaxLenPath then RedoList[ReDoPos+1] := #0;
         str := PChar(@RedoList);
         Clipboard.SetTextBuf(PChar(reversestring(str)));
         Result := true;
      end;
   end;
end;

// 从字符串中提取 Lurd
procedure GetLurd(strLurd: string; isBK: Boolean);
var
  i, len: Integer;
  ch: Char;

begin
  len := Length(strLurd);

  if len > MaxLenPath then Exit;

  if isBK then begin     // 送入逆推 redo
     ReDoPos_BK := 0;
     for i := len downto 1 do begin
         ch := strLurd[i];
         if ch in [ 'l', 'u', 'r', 'd', 'L', 'U', 'R', 'D' ] then begin
            inc(ReDoPos_BK);
            RedoList_BK[ReDoPos_BK] := ch;
         end;
     end;
  end else begin         // 送入正推 redo
     ReDoPos := 0;
     for i := len downto 1 do begin
         ch := strLurd[i];
         if ch in [ 'l', 'u', 'r', 'd', 'L', 'U', 'R', 'D' ] then begin
            inc(ReDoPos);
            RedoList[ReDoPos] := ch;
         end;
     end;
  end;
end;

// 从剪切板加载 Lurd
function LoadLurdFromClipboard(isBK: Boolean): Boolean;
var
  i, j, k: Integer;
  str, str2: string;
  p, q: TStrings;

begin
   Result := False;
   
   // 查询剪贴板中特定格式的数据内容
   if (Clipboard.HasFormat(CF_TEXT) or Clipboard.HasFormat(CF_OEMTEXT)) then begin
      str := Clipboard.asText;
   end else Exit;

   q := TStringList.Create;
   q.Delimiter := #10;
   q.CommaText := str;

   k := q.Count;
   i := 0;

   str := '';
   while i < k do begin
     if isLurd_2(q[i]) then begin
        str := str + #10 + q[i];
     end;
     i := i + 1;
   end;

   MyStringsFree(q);

   if isBK then begin             // 逆推
   
      ManPos_BK_0_2 := -1;
      
      i := pos('[', str);
      j := pos(']', str);

      // 若包含了人的初始位置信息
      if (i > 0) and (j > 0) and (j > i) then begin
         str2 := copy(str, i+1, j-i-1);
         delete(str, 1, j);
         p := TStringList.Create;
         p.Delimiter := ',';
         p.CommaText := str2;

         if p.Count = 2 then begin
            try
              j := strToInt(p[0])-1;         // 用家看到的坐标，从[1, 1]开始，程序内部是从[0, 0]开始
              i := strToInt(p[1])-1;
              if (i >= 0) and (j >= 0) and (i < curMapNode.Rows) and (j < curMapNode.Cols) then ManPos_BK_0_2 := i * curMapNode.Cols + j;
            except
            end;
         end;

         MyStringsFree(p);
      end else begin
         k := Max(i, j);

         if k > 0 then delete(str, 1, k);
      end;
      
      GetLurd(str, isBK);
   end else begin                 // 正推
      i := pos('[', str);

      if i > 0 then str := copy(str, 1, i-1);

      GetLurd(str, isBK);
   end;

   Result := true;
end;

end.
