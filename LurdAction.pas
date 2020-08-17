unit LurdAction;

interface

uses
  windows, classes, StrUtils, SysUtils, Contnrs, Clipbrd, Math, CRC_32;

type
  TSoltionNode = record        // ���б��ڵ�
      id      : Integer;           // �� db �е� id
      Moves   : Integer;           // �ƶ�����
      Pushs   : Integer;           // �ƶ�����
      CRC32   : Integer;           // �� CRC
      DateTime: TDateTime;         // ʱ���
  end;

type
  TStateNode = record         // ״̬�б��ڵ�
      id           : Integer;      // �� db �е� id
      Moves        : Integer;      // �ƶ�����
      Pushs        : Integer;      // �ƶ�����
      Moves_BK     : Integer;      // �����ƶ�����
      Pushs_BK     : Integer;      // �����ƶ�����
      CRC32        : Integer;      // �� CRC
      CRC32_BK     : Integer;      // �� CRC
      Man_X        : Integer;      // �˵�λ�� -- ��
      Man_Y        : Integer;      // �˵�λ�� -- ��
      DateTime     : TDateTime;    // ʱ���
  end;

const
  MaxLenPath = 200000;       // ·����󳤶�����

  // ���ڳ��������ҡ��ϡ���
  dr4 : array[0..3] of Integer = (  0, 0, -1, 1 );
  dc4 : array[0..3] of Integer = ( -1, 1,  0, 0 );
  
var
  UndoList, RedoList, UndoList_BK, RedoList_BK: array[1..MaxLenPath] of Char;   // ���������� Undo��Redo ����������
  UnDoPos, ReDoPos, UnDoPos_BK, ReDoPos_BK: Integer;                            // undo��redo λ��ָ��

  function LurdToClipboard(c, r: Integer): Boolean;        // Lurd ������а�
  function LoadLurdFromClipboard(isBK: Boolean): boolean;  // �Ӽ��а���� Lurd
  function isLurd(str: String): boolean;                   // �ж��Ƿ�Ϊ��Ч�� Lurd ��
  function isLurd_2(str: String): boolean;                 // �ж��Ƿ�Ϊ��Ч�� Lurd �� -- �������ƵĶ����ַ�
  procedure GetLurd(strLurd: string; isBK: Boolean);       // ���ַ�������ȡ Lurd ���� Redo

implementation

uses
  LoadMap;


// �ж��Ƿ�Ϊ��Ч�� Lurd ��
function isLurd(str: String): boolean;
var
  n, k: Integer;

begin
  result := False;

  n := Length(str);

  if n = 0 then exit;    
  
  k := 1;
  while k <= n do begin
     if not (str[k] in [ 'l', 'u', 'r', 'd', 'L', 'U', 'R', 'D', ' ' ]) then Break;
     Inc(k);
  end;

  result := k > n;
end;

// �ж��Ƿ�Ϊ��Ч�� Lurd ��
function isLurd_2(str: String): boolean;
var
  n, k: Integer;

begin
  result := False;

  n := Length(str);

  if n = 0 then exit;    
  
  k := 1;
  while k <= n do begin
     if not (str[k] in [ 'l', 'u', 'r', 'd', 'L', 'U', 'R', 'D', ',', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ' ', '[', ']' ]) then Break;
     Inc(k);
  end;

  result := k > n;
end;
  
// Lurd ������а�
function LurdToClipboard(c, r: Integer): Boolean;
var
  str, str1, str2: string;

begin
   Result := False;

   if UnDoPos    < MaxLenPath then UndoList[UnDoPos+1]       := #0;
   if UnDoPos_BK < MaxLenPath then UndoList_BK[UnDoPos_BK+1] := #0;

   str  := PChar(@UndoList);
   str1 := '[' + IntToStr(c) + ', ' + IntToStr(r) + ']';
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

// ���ַ�������ȡ Lurd
procedure GetLurd(strLurd: string; isBK: Boolean);
var
  i, len: Integer;
  ch: Char;

begin
  len := Length(strLurd);

  if len > MaxLenPath then Exit;

  if isBK then begin     // �������� redo
     ReDoPos_BK := 0;
     for i := len downto 1 do begin
         ch := strLurd[i];
         if ch in [ 'l', 'u', 'r', 'd', 'L', 'U', 'R', 'D' ] then begin
            inc(ReDoPos_BK);
            RedoList_BK[ReDoPos_BK] := ch;
         end;
     end;
  end else begin         // �������� redo
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

// �Ӽ��а���� Lurd
function LoadLurdFromClipboard(isBK: Boolean): Boolean;
var
  i, j, k: Integer;
  str, str2: string;
  p: TStrings;

begin
   Result := False;
   
   // ��ѯ���������ض���ʽ����������
   if (Clipboard.HasFormat(CF_TEXT) or Clipboard.HasFormat(CF_OEMTEXT)) then begin
      str := Clipboard.asText;
   end else Exit;

   if isBK then begin             // ����
   
      ManPos_BK_0_2 := -1;
      
      i := pos('[', str);
      j := pos(']', str);

      // ���������˵ĳ�ʼλ����Ϣ
      if (i > 0) and (j > 0) and (j > i) then begin
         str2 := copy(str, i+1, j-i-1);
         delete(str, 1, j);
         p := TStringList.Create;
         p.CommaText := str2;

         if p.Count = 2 then begin
            try
              j := strToInt(p[0]);
              i := strToInt(p[1]);
              if not ((i < 0) or (j < 0) or (i >= curMapNode.Rows) or (j >= curMapNode.Cols)) then ManPos_BK_0_2 := i * curMapNode.Cols + j;
            except
            end;
         end;

         FreeAndNil(p);
      end else begin
         k := Max(i, j);

         if k > 0 then delete(str, 1, k);
      end;
      
      GetLurd(str, isBK);
   end else begin                 // ����
      i := pos('[', str);

      if i > 0 then str := copy(str, 1, i-1);

      GetLurd(str, isBK);
   end;

   Result := true;
end;

end.