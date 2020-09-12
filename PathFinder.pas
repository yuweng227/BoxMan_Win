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
    ManPath: array[1..MaxLenPath] of Char;              // �������ƶ���������ʱ����
    BoxPath: array[1..MaxLenPath] of Char;              // �����������Ӷ�������ʱ����
    isEditor: Boolean;                                  // ��Ϊ�༭��ģ��Ҳ�õ��ã����༭������ʱ����ʷ��������Ҫ���浽log�ĵ����������ô˱���������

type                        // ��������
  PBoxManNode = ^BoxManNode;
  BoxManNode = record       // ���Ӻ��˵���Ͻڵ㣬���ȶ����ýڵ�
      boxPos: Integer;
      manPos: Integer;
      H, G, T, D: Integer;  // ����ֵ���ۼƲ������ۼ�ת����������ڵ㷽��
      next: PBoxManNode;
  end;

  function canThrough(isBK: Boolean; r, c, r1, c1, r2, c2, dir: Integer): Boolean;        // ��� pos1 �� pos �����Ƿ�Խ�ɴ�, �� pos2 �Ǳ���Խ�����ӣ����ڴ�Խʱ��������Ҫ��ʱ�ƶ��� pos
  function getPathForThrough(nRow, nCol, nRow1, nCol1, nRow2, nCol2: Integer; dir: Byte; num: Integer): Integer;  // ���㲢���� nRow1, nCol1 �� nRow, nCol �����Ĵ�Խ·���� TurnPath������·������, �� nRow2, nCol2 �Ǳ���Խ�����ӣ����ڴ�Խʱ��������Ҫ��ʱ�ƶ��� nRow, nCol
  function manTo2b(isBK: Boolean; boxR, boxC, firR, firC, secR, secC: Integer): Boolean;  // ��㷨����������Ƿ��˿ɴ�������ӿɴ�ʱ����
  function manTo2(isBK: Boolean; boxR, boxC, firR, firC, secR, secC: Integer): Boolean;   // ���淨����������Ƿ��˿ɴ�������ӿɴ�ʱ����

  procedure Init(w, h: Integer);                                      // ��ʼ��
  procedure setThroughable(f: Boolean);                               // �����Ƿ�����Խ
  function  isManReachable(pos: Integer): Boolean;                    // �鿴��λ�á����Ƿ�ɴ�
  function  isManReachableByThrough (pos: Integer): Boolean;          // �鿴��λ�á����Ƿ�Խ�ɴ�
  function  isBoxOfThrough(pos: Integer): Boolean;                    // �鿴��λ�á��Ƿ�Խ��
  function  isManReachable_BK(pos: Integer): Boolean;                 // �鿴��λ�á����Ƿ�ɴ� -- ����
  function  isManReachableByThrough_BK(pos: Integer): Boolean;        // �鿴��λ�á����Ƿ�Խ�ɴ� -- ����
  function  isBoxOfThrough_BK(pos: Integer): Boolean;                 // �鿴��λ�á��Ƿ�Խ�� -- ����
  procedure manReachable(isBK: Boolean; level: array of Integer; manPos: Integer);                      // ����ֹ�Ա�ĿɴﷶΧ
  function  manTo(isBK: Boolean; level: array of Integer; manPos, toPos: Integer): Integer;             // �����˵��� toPos ��·�������浽 tmpPath������·������

  procedure FindBlock(level: array of Integer; boxPos: Integer);      // ��ͼ�ֿ�
  procedure boxReachable(isBK: Boolean; boxPos, manPos: Integer);     // �������ӵĿɴ�λ��
  function  isBoxReachable(pos: Integer): Boolean;                    // �鿴��λ�á������Ƿ�ɴ�
  function  isBoxReachable_BK(pos: Integer): Boolean;                 // �鿴��λ�á������Ƿ�ɴ� -- ����
  function  boxTo(isBK: Boolean; boxPos, toPos, manPos: Integer): Integer;  // �������ӵ��� toPos ��·�������� list ����

implementation

uses
  LogFile, Board;

const
  lurdChar : array[0..7] of Char = (  'l', 'r', 'u', 'd', 'L', 'R', 'U', 'D' );

  bt : array[0..7] of Byte = ( 0, 2, 1, 3, 4, 6, 5, 7 );      // ��Ӧ������l u r d L U R D

  mByte : array[0..3] of Byte = ( 1, 2, 4, 8 );       // ���ڲ��ҡ��顱�ĳ���

var
  isThroughable: boolean;                             // �Ƿ�����Խ

  manMark: array[0..99, 0..99] of Byte;               // �˵Ŀɴ��־���飬���ƣ�0x01 �ɴ�㣻0x02 ��Խ�ɴ�㣻 0x04 ��Խ�㣻���ƣ�0x10 �ɴ�㣻0x20 ��Խ�ɴ�㣻 0x40 ��Խ��
  boxMark: array[0..99, 0..99] of Byte;               // ���ӵĿɴ��־���飬���ƣ�0x01 �ɴ�㣻0x04 ��Խ�㣻���ƣ�0x10 �ɴ�㣻0x40 ��Խ��

  tmpMap: array[0..99, 0..99] of Char;                // ���㴩Խʱ����ʱʹ��
  mapWidth, mapHeight: Integer;                       // ��ͼ�ߴ�
  tmpBoxPos: Integer;                                 // ��ʱ��¼���������λ�ã������� CutVertex() ʱʹ��
  deep_Thur: Integer;                                 // ��Խǰ���ֱ�ƴ���

  TrunPath: array[1..MaxLenPath] of Char;             // �������ƶ�ʱ����Խ·������ʱ����

  mark: array[0..99, 0..99] of Boolean;               // ���㴩Խʱ����ʱʹ��
  pt, pt0, ptBlock: array[0..9999] of Integer;        // �������Ǽǿ�ʱʹ��ptBlock����������С�
  
  mark0: array[0..99, 0..99, 0..3] of Boolean;
  cut: array[0..99, 0..99] of Boolean;                // ���

  children,                                           // ��¼��ǰ�ڵ�������ڵ㷽��1--��2--�ң�4--�ϣ�8--�£���λ�������
  parent, parent2 : array[0..99, 0..99] of Smallint;  // ��¼�����ڵ㡱������ǰ�ڵ㡱�ķ���0--�ϣ�1--�£�2--��3--��

  depth, b_count: Integer;                            // depth: DFS ��ȣ�b_count: �������� ��������Ž��� -1�ݼ���ע
  depth_tag, low_tag: array[0..99, 0..99] of Integer;
  block: array[0..99, 0..99, 0..4] of Integer;

// ��ʼ��
procedure Init(w, h: Integer);
begin
   mapWidth  := w;
   mapHeight := h;
end;

// �����Ƿ�����Խ
procedure setThroughable(f: Boolean);
begin
   isThroughable := f;
end;

// ���Ƿ�ɴ�
function isManReachable(pos: Integer): Boolean;
begin
   Result := ((manMark[pos div mapWidth, pos mod mapWidth] and $01) > 0);
end;

// ���Ƿ�Խ�ɴ�
function isManReachableByThrough(pos: Integer): Boolean;
begin
   Result := ((manMark[pos div mapWidth, pos mod mapWidth] and $02) > 0);
end;

// �����Ƿ�Խ��
function isBoxOfThrough(pos: Integer): Boolean;
begin
   Result := ((manMark[pos div mapWidth, pos mod mapWidth] and $04) > 0);
end;

// ���Ƿ�ɴ� -- ����
function isManReachable_BK(pos: Integer): Boolean;
begin
   Result := ((manMark[pos div mapWidth, pos mod mapWidth] and $10) > 0);
end;

// ���Ƿ�Խ�ɴ� -- ����
function isManReachableByThrough_BK (pos: Integer): Boolean;
begin
   Result := ((manMark[pos div mapWidth, pos mod mapWidth] and $20) > 0);
end;

// �����Ƿ�Խ�� -- ����
function isBoxOfThrough_BK(pos: Integer): Boolean;
begin
   Result := ((manMark[pos div mapWidth, pos mod mapWidth] and $40) > 0);
end;

// �����Ƿ�ɴ�
function isBoxReachable(pos: Integer): Boolean;
begin
   Result := ((boxMark[pos div mapWidth, pos mod mapWidth] and $01) > 0);
end;

// �����Ƿ�ɴ� -- ����
function isBoxReachable_BK(pos: Integer): Boolean;
begin
   Result := ((boxMark[pos div mapWidth, pos mod mapWidth] and $10) > 0);
end;


// ����ֹ�Ա�ĿɴﷶΧ����������� manMark[] ��
// ������isBK -- �Ƿ�����, level -- ��ͼ�ֳ�, manPos -- �˵�λ��
procedure manReachable(isBK: Boolean; level: array of Integer; manPos: Integer);
var
   curMark: Byte;
   i, j, k, i1, i2, i3, j1, j2, j3, p, tail, r, c: Integer;

begin
   if isBK then curMark := $0F     // ����ʱ���������Ʊ�־
   else curMark := $F0;            // ����ʱ���������Ʊ�־

   // ������ͼ����������Ӱ��ԭ��ͼ
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
   if isBK then curMark := $10     // ����ʱ���������Ʊ��
   else curMark := $01;            // ����ʱ���������Ʊ��
   r := manPos div mapWidth;
   c := manPos mod mapWidth;
   manMark[r, c] := manMark[r, c] or curMark;
   pt[0] := manPos;
   while (p <= tail) do begin
       // ���棨�Ǵ�Խ���Ų�
       while (p <= tail) do begin
            r := pt[p] div mapWidth;
            c := pt[p] mod mapWidth;
            for k := 0 to 3 do begin
                i1 := r + dr4[k];
                j1 := c + dc4[k];

                if (i1 < 0) or (j1 < 0) or (i1 >= mapHeight) or (j1 >= mapWidth) then continue // ����
                else if ('-' = tmpMap[i1, j1]) and ((manMark[i1, j1] and curMark) = 0) then begin
                    Inc(tail);
                    pt[tail] := i1 * mapWidth + j1;   // �µ��㼣
                    manMark[i1, j1] := manMark[i1, j1] or curMark;      // �ɴ��Խ�ɴ��ǣ������������ƵĿɴ���
                end;
            end;
            Inc(p);
       end;

       // ��Խ�Ų�
       if (isThroughable) then begin
          for i := 1 to mapHeight - 2 do begin
              for j := 1 to mapWidth - 2 do begin
                  if ('-' = tmpMap[i, j]) and ((manMark[i, j] and curMark) = 0) then begin
                      for k := 0 to 3 do begin    // ���ĸ�������Ų�
                          deep_Thur := 0;
                          if isBK then begin
                              i1 := i + 3 * dr4[k];
                              j1 := j + 3 * dc4[k];
                              i2 := i + 2 * dr4[k];
                              j2 := j + 2 * dc4[k];
                              i3 := i + dr4[k];
                              j3 := j + dc4[k];

                              if (i1 < 0) or (j1 < 0) or (i1 >= mapHeight) or (j1 >= mapWidth) then continue   // ����
                              else if ('$' = tmpMap[i3, j3]) and ((manMark[i1, j1] and curMark) > 0) and ((manMark[i2, j2] and curMark) > 0) then begin
                                  tmpMap[i3, j3] := '-';     // Ϊ���㷨�ͱ�����ţ����㴩Խʱ����ʱ�õ�������Խ�����ӡ����������ݡ����ꡱ��λ������
                                  if canThrough(isBK, i2, j2, i1, j1, i3, j3, k) then begin    // ��鴩Խʱ�����С��ݹ顱�����ԣ���ʱ�õ�������Խ�����ӡ��ȽϷ���
                                      curMark := $30;                                  // ���ƴ�Խ�ɴ���
                                      manMark[i, j]  := manMark[i, j] or curMark;      // �������Ʊ��
                                      manMark[i3, j3] := manMark[i3, j3] or $40;       // ��Խ�����ӣ��������Ʊ��
                                      Inc(tail);
                                      pt[tail] := i * mapWidth + j;
                                  end;
                                  tmpMap[i3, j3] := '$';     // �Żء�����Խ�����ӡ�
                              end;
                          end else begin
                              i1 := i + dr4[k];
                              j1 := j + dc4[k];
                              i2 := i - dr4[k];
                              j2 := j - dc4[k];
                              i3 := i - 2 * dr4[k];
                              j3 := j - 2 * dc4[k];

                              if (i3 < 0) or (j3 < 0) or (i3 >= mapHeight) or (j3 >= mapWidth)then continue   // ����
                              else if ('$' = tmpMap[i2, j2]) and ('-' = tmpMap[i1, j1]) and ((manMark[i3, j3] and curMark) > 0) then begin
                                  tmpMap[i2, j2] := '-';     // Ϊ���㷨�ͱ�����ţ����㴩Խʱ����ʱ�õ�������Խ�����ӡ����������ݡ����ꡱ��λ������
                                  if canThrough(isBK, i, j, i2, j2, i1, j1, k) then begin    // ��鴩Խʱ�����С��ݹ顱�����ԣ���ʱ�õ�������Խ�����ӡ��ȽϷ���
                                      curMark := $03;                                 // ���ƴ�Խ�ɴ���
                                      manMark[i, j]  := manMark[i, j] or curMark;     // �������Ʊ��
                                      manMark[i2, j2] := manMark[i2, j2] or $04;      // ��Խ�����ӣ��������Ʊ��
                                      Inc(tail);
                                      pt[tail] := i * mapWidth + j;
                                  end;
                                  tmpMap[i2, j2] := '$';     // �Żء�����Խ�����ӡ�
                              end;
                          end;
                      end;  // end k
                  end;
              end;  // end j
          end;  // end i
       end;  // end ��Խ�Ų�
   end;
end;

// �����˵��� toPos ��·�������浽 tmpPath������·������
// ������isBK -- �Ƿ�����, level -- ��ͼ�ֳ�, manPos -- �ֹ�Աԭλ�ã�toPos -- �ֹ�ԱĿ��λ��

function manTo(isBK: Boolean; level: array of Integer; manPos, toPos: Integer): Integer;
var
  i, j, i1, j1, i2, j2, i3, j3, k, p, tail, r, c, t1, t2, t_er, t_ec, len: Integer;
  isFound: Boolean;
  curMark: Byte;
  ch: Char;

begin
   Result := 0;

   if manPos = toPos then exit;
   
   if isBK then curMark := $0F     // ����ʱ���������Ʊ�־
   else curMark := $F0;            // ����ʱ���������Ʊ�־

   len := Length(level);

   // ������ͼ����������Ӱ��ԭ��ͼ
   for i := 0 to mapHeight-1 do begin
       for j := 0 to mapWidth-1 do begin
          k := i * mapWidth + j;
          if len > 3 then begin   // ���� BoxTo() �������㡰���ӡ�·���е��˵�·��ʱ���ֳ���ͼ����Ҫ����װ�����һ������Ϊ 2 �ġ��ٵ�ͼ��
              if (level[k] = WallCell) or (level[k] = EmptyCell) then tmpMap[i, j] := '#'
              else if (level[k] = BoxCell) or (level[k] = BoxGoalCell) then tmpMap[i, j] := '$'
              else tmpMap[i, j] := '-';
          end;
          manMark[i, j] := manMark[i, j] and curMark;
          parent[i, j]  := -1;
          parent2[i, j] := -1;
       end;
   end;

   if isBK then curMark := $10     // ����ʱ���������Ʊ�־
   else curMark := $01;            // ����ʱ���������Ʊ�־

   isFound := False;
   r := manPos div mapWidth;
   c := manPos mod mapWidth;
   manMark[r, c] := manMark[r, c] or curMark;
   pt[0] := manPos;
   p := 0; tail := 0;
   while p <= tail do begin
       // ���棨�Ǵ�Խ���Ų�
       while p <= tail do begin
           r := pt[p] div mapWidth;
           c := pt[p] mod mapWidth;
           for k := 0 to 3 do begin
              i1 := r + dr4[k];
              j1 := c + dc4[k];

              if (i1 < 0) or (j1 < 0) or (i1 >= mapHeight) or (j1 >= mapWidth) then continue // ����
              else if ('-' = tmpMap[i1, j1]) and ((manMark[i1, j1] and curMark) = 0) then begin
                  Inc(tail);
                  pt[tail] := i1 * mapWidth + j1;                // �µ��㼣
                  manMark[i1, j1] := manMark[i1, j1] or curMark; // �ɴ��Խ�ɴ��ǣ������������ƵĿɴ���
                  parent[i1, j1] := k;                           // ���ڵ㵽��ǰ�ڵ�ķ���
                  if toPos = i1 * mapWidth + j1 then begin       // ����Ŀ��
                     isFound := true;
                     break;
                  end;
              end;
           end;
           if isFound then break;

           Inc(p);
       end;

       if isFound then break;

       // ��Խ�Ų�
       if isThroughable then begin
          for i := 1 to mapHeight - 2 do begin
              for j := 1 to mapWidth - 2 do begin
                  if ('-' = tmpMap[i, j]) and ((manMark[i, j] and curMark) = 0) then begin
                      for k := 0 to 3 do begin    // ���ĸ�������Ų�
                          deep_Thur := 1;
                          if isBK then begin
                              i1 := i + 3 * dr4[k];
                              j1 := j + 3 * dc4[k];
                              i2 := i + 2 * dr4[k];
                              j2 := j + 2 * dc4[k];
                              i3 := i + dr4[k];
                              j3 := j + dc4[k];

                              if (i1 < 0) or (j1 < 0) or (i1 >= mapHeight) or (j1 >= mapWidth) then continue   // ����
                              else if ('$' = tmpMap[i3, j3]) and ((manMark[i1, j1] and curMark) > 0) and ((manMark[i2, j2] and curMark) > 0) then begin    //    and (tmpBoxPos <> i3 * mapWidth + j3)
                                  tmpMap[i3, j3] := '-';     // Ϊ���㷨�ͱ�����ţ����㴩Խʱ����ʱ�õ�������Խ�����ӡ����������ݡ����ꡱ��λ������
                                  if canThrough(isBK, i2, j2, i1, j1, i3, j3, k) then begin    // ��鴩Խʱ�����С��ݹ顱�����ԣ���ʱ�õ�������Խ�����ӡ��ȽϷ���
                                      manMark[i, j] := manMark[i, j] or curMark;    // �������Ʊ��
                                      Inc(tail);
                                      pt[tail] := i * mapWidth + j;
                                      parent[i, j] := 10 * deep_Thur + k;     // ��Խ�߷�����ͨ�ķ���
                                      if i * mapWidth + j = toPos then isFound := true;              // ����Ŀ��
                                  end;
                                  tmpMap[i3, j3] := '$';     // �Żء�����Խ�����ӡ�
                                  if (isFound) then break;
                              end;
                          end else begin
                              i1 := i + dr4[k];
                              j1 := j + dc4[k];
                              i2 := i - dr4[k];
                              j2 := j - dc4[k];
                              i3 := i - 2 * dr4[k];
                              j3 := j - 2 * dc4[k];

                              if (i3 < 0) or (j3 < 0) or (i3 >= mapHeight) or (j3 >= mapWidth)then continue   // ����
                              else if ('$' = tmpMap[i2, j2]) and ('-' = tmpMap[i1, j1]) and ((manMark[i3, j3] and curMark) > 0) then begin  //   and (tmpBoxPos <> i2 * mapWidth + j2)
                                  tmpMap[i2, j2] := '-';     // Ϊ���㷨�ͱ�����ţ����㴩Խʱ����ʱ�õ�������Խ�����ӡ����������ݡ����ꡱ��λ������
                                  if canThrough(isBK, i, j, i2, j2, i1, j1, k) then begin    // ��鴩Խʱ�����С��ݹ顱�����ԣ���ʱ�õ�������Խ�����ӡ��ȽϷ���
                                      manMark[i, j] := manMark[i, j] or curMark;     // �������Ʊ��
                                      Inc(tail);
                                      pt[tail] := i * mapWidth + j;
                                      parent[i, j] := 10 * deep_Thur + k;      // ��Խ�߷�����ͨ�ķ���
                                      if i * mapWidth + j = toPos then isFound := true;               // ����Ŀ��
                                  end;
                                  tmpMap[i2, j2] := '$';     // �Żء�����Խ�����ӡ�
                                  if isFound then break;
                                  
                              end;
                          end;
                      end;  // end k

                      if isFound then break;

                  end;
              end;  // end j

              if isFound then break;

          end;  // end i
       end;  // end ��Խ�Ų�

       if isFound then break;

   end;

   if isFound then begin  // ƴ��·��
      t_er := toPos div mapWidth;
      t_ec := toPos mod mapWidth;
      while t_er * mapWidth + t_ec <> manPos do begin
          if (parent[t_er, t_ec] < 4) then begin
              ch := lurdChar[parent[t_er, t_ec]];                       // �����ַ���lurdLURD

              if Result = MaxLenPath then Exit;

              Inc(Result);
              ManPath[Result] := ch;

              t1 := t_er - dr4[parent[t_er, t_ec]];
              t2 := t_ec - dc4[parent[t_er, t_ec]];
              t_er := t1;
              t_ec := t2;
          end else begin
              if isBK then begin                  // ����
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
              end else begin                      // ����
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

// ��� r1, c1 �� r2,c2 �����Ƿ�ɴ�, ����Խ�������ѱ���ʱ�ƶ��� r, c
function canThrough(isBK: Boolean; r, c, r1, c1, r2, c2, dir: Integer): Boolean;
var
  i1, i2, j1, j2, k, p, tail: Integer;

begin

    for i1 := 0 to mapHeight-1 do begin
        for j1 := 0 to mapWidth-1 do begin
            mark[i1][j1] := false;
        end;
    end;

    // �Ų�ɴ������ڣ���ѭ��ȡ���ݹ飩
    p := 0; tail := 0;
    mark[r1, c1] := true;
    pt0[0] := r1 * mapWidth + c1;
    while (p <= tail) do begin
        i2 := pt0[p] div mapWidth;
        j2 := pt0[p] mod mapWidth;
        for k := 0 to 3 do begin
            i1 := i2 + dr4[k];
            j1 := j2 + dc4[k];

            if (i1 < 0) or (j1 < 0) or (i1 >= mapHeight) or (j1 >= mapWidth) or ((i1 = r) and (j1 = c)) then continue  // ���⣬��������Խ�����ӱ���ʱ�Ƶ���λ��
            else if ((i1 = r2) and (j1 = c2)) then begin Result := True; Exit; end  // ��Խ�ɴ�
            else if ('-' = tmpMap[i1, j1]) and (not mark[i1, j1]) then begin
                Inc(tail);
                pt0[tail] := i1 * mapWidth + j1;                // �µ��㼣
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

    if (i1 < 0) or (j1 < 0) or (i1 >= mapHeight) or (j1 >= mapWidth) or (tmpMap[i1, j1] <> '-') then begin canThrough := False; Exit; end  // ����
    else begin
        Inc(deep_Thur);
        
        // ��ǰ��һ������Ƿ��ܹ���Խ
        if isBK then Result := canThrough(isBK, r1, c1, i1, j1, r, c, dir)
        else Result := canThrough(isBK, r2, c2, r, c, i1, j1, dir);
    end;
end;

// ���㲢���� nRow1, nCol1 �� nRow, nCol �����Ĵ�Խ·���� TurnPath������·������, , �� nRow2, nCol2 �Ǳ���Խ�����ӣ����ڴ�Խʱ��������Ҫ��ʱ�ƶ��� nRow, nCol
function getPathForThrough(nRow, nCol, nRow1, nCol1, nRow2, nCol2: Integer; dir: Byte; num: Integer): Integer;
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

    // ����ֱ�ƴ�������������λ��
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
            if (i1 < 0) or (j1 < 0) or (i1 >= mapHeight) or (j1 >= mapWidth) or ((i1 = nRow) and (j1 = nCol)) then begin  // ���⣬������������ʱλ��
                continue;
            end else if (nRow2 = i1) and (nCol2 = j1) then begin  // ����Ŀ��
                Inc(tail);
                pt0[tail] := i1 * mapWidth + j1;            // �µ��㼣
                parent2[i1, j1] := k;          // ���ڵ㵽��ǰ�ڵ�ķ���
                isFound := true;
                break;
            end else if ('-' = tmpMap[i1, j1]) and (not mark[i1, j1]) then begin
                Inc(tail);
                pt0[tail] := i1 * mapWidth + j1;            // �µ��㼣
                mark[i1, j1] := true;
                parent2[i1, j1] := k;          // ���ڵ㵽��ǰ�ڵ�ķ���
            end;
        end;
        if isFound then  break;
        Inc(p);
    end;

    // ƴ�Ӵ�Խ·�� -- ����
    // ��Խ�У�·�������ˡ����ƶ�������Ч�ʼ����㷨���ǣ���֧��ֱ�ƴ�Խ��
    if isFound then begin

        t_er := nRow2; t_ec := nCol2;
        
        ch := lurdChar[parent2[t_er, t_ec]];         // �����ַ���lurdLURD
        
        case dir of
            0: ch := lurdChar[5];
            1: ch := lurdChar[4];
            2: ch := lurdChar[7];
            3: ch := lurdChar[6];
        end;
        
        // �����ƻ�ԭλ
        for k := 0 to num do begin
            Inc(Result);
            TrunPath[Result] := ch;
        end;
        
        // ��Խ�У��˵��ƶ�
        while (t_er <> nRow1) or (t_ec <> nCol1) do begin
            Inc(Result);
            TrunPath[Result] := lurdChar[parent2[t_er, t_ec]];   // �����ַ���lurdLURD

            t1 := t_er - dr4[parent2[t_er, t_ec]];
            t2 := t_ec - dc4[parent2[t_er, t_ec]];
            t_er := t1;
            t_ec := t2;
        end;

        // ���������ɴ�Խλ��
        for k := 0 to num do begin
            Inc(Result);
            TrunPath[Result] := lurdChar[dir + 4];
        end;
    end;
end;


//������level -- ��ͼ�ֳ���boxPos -- �����������
procedure FindBlock(level: array of Integer; boxPos: Integer);
const
   dir: array[0..3] of Byte = ( 1, 0, 3, 2 );      // ���㸸�ڵ㷽����

var
    boxR, boxC: Integer;
    i, j, k: Integer;

    // ѭ����Ϊ���顱�ڵĽڵ�����ʶ
    procedure BlockrSign(r, c: Integer);
    var
      rr, cc, p, tail, k: Integer;

    begin
        // ��������һ�� int �洢
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

    // ���㡰��㡱�����顱����Ŀ������λ�� row, col ��ʼ
    // mark �� FindBlock() �еĸ�λ���������¼���ӿɴ��
    procedure CutVertex(row, col: Integer);
    var
       i: Integer;

    begin
        mark[row, col] := true;                        // �ѷ��ʱ��

        Inc(depth);
        depth_tag[row, col] := depth;
        low_tag[row, col]   := depth;                  // ��� low ��

        for i := 0 to 3 do begin    
            if mark[row + dr4[i], col + dc4[i]] then begin   // �ڵ㱻���ʹ�
                // ���Ǹ��ڵ�, ��ô�����Ϊ������ߡ�
                if (parent[row, col] <> i) and (depth_tag[row + dr4[i], col + dc4[i]] < low_tag[row, col]) then
                    low_tag[row, col] := depth_tag[row + dr4[i], col + dc4[i]];
            end else if (tmpMap[row + dr4[i], col + dc4[i]] = '-') then begin      // �µ��ӽڵ�
                parent[row + dr4[i], col + dc4[i]] := dir[i];                      // ��ʾ���ڵ�Ķ�������
                children[row, col] := children[row, col] or mByte[i];              // ��������

                CutVertex(row + dr4[i], col + dc4[i]);

                if low_tag[row + dr4[i], col + dc4[i]] < low_tag[row, col] then begin   // ���ӽڵ�� low ֵС���丸�ڵ�� low ֵ
                    low_tag[row, col] := low_tag[row + dr4[i]][col + dc4[i]];           // �����丸�ڵ�� low ֵ
                end else if low_tag[row + dr4[i], col + dc4[i]] >= depth_tag[row, col] then begin // ���ӽڵ�� low ֵ�����丸�ڵ�� low ֵ���򸸽ڵ�Ϊ����㡱
                    if tmpBoxPos <> row * mapWidth +  col then begin
                        if not cut[row, col] then cut[row, col] := true;
                        // ��ǡ��顱
                        Inc(block[i, j, 0]);
                        block[i, j, block[i, j, 0]] := b_count;        // ��Ǹ������

                        BlockrSign((row + dr4[i]), col + dc4[i]);      // ��Ǵ˸�������
                        Dec(b_count);                                  // ��ż�һ
                        children[row, col] := children[row, col] and (not mByte[i]);  // �Ƴ��ˡ���㡱��������
                    end;
                end;
            end;
        end;

        Dec(depth);
    end;

begin
    tmpBoxPos := boxPos;            // CutVertex()ʹ�ã������������

    depth := 0;
    b_count := -1;                  // ����д� -1 �ݼ�����ʾ

    // ������ͼ����������Ӱ��ԭ��ͼ
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
    tmpMap[boxR, boxC] := '-';    // ������ʱ����ʱ�õ������������
    CutVertex(boxR, boxC);        // �ݹ������

    // ��� DFS �ĸ��ڵ�
    j := 0;                       // �������ڵ������
    for k := 0 to 3 do begin
        if (children[boxR, boxC] and mByte[k]) > 0 then begin
            Inc(j);
            Inc(block[boxR, boxC, 0]);
            block[boxR, boxC, block[boxR, boxC, 0]] := b_count;

            BlockrSign(boxR + dr4[k], boxC + dc4[k]);
            Dec(b_count);
        end;
    end;
    
    if j >= 2 then begin          // �����ڵ����������ϵ�����, ����ڵ�Ҳ�ǡ���㡱
        cut[boxR, boxC] := true;
    end;
end;

// �������ӵĿɴ�λ��
procedure boxReachable(isBK: Boolean; boxPos, manPos: Integer);
const
  MAX_Size = 3000;

var
    i, j, k, r, c, newR, newC, mToR, mToC, box_R, box_C, man_R, man_C, Q_Pos, Q_Pos2, F, Box_F, Man_F: Integer;
    curMark: Byte;
    Q: array[0..MAX_Size] of Integer;

begin
    if isBK then curMark := $0F     // ����ʱ���������Ʊ�־         
    else curMark := $F0;            // ����ʱ���������Ʊ�־

    //����־�����ʼ��
    for i := 0 to mapHeight-1 do begin
        for j := 0 to mapWidth-1 do begin
            boxMark[i][j]  := boxMark[i][j] and curMark;  // �Ƿ�ɴ�
            mark0[i][j][0] := false;                      // �½ڵ���ķ��򣨷����Ƿ�����
            mark0[i][j][1] := false;
            mark0[i][j][2] := false;
            mark0[i][j][3] := false;
        end;
    end;

    if isBK then curMark := $10     // ����ʱ���������Ʊ�־
    else curMark := $01;            // ����ʱ���������Ʊ�־

    // ��ʼλ�ü��
    F        := (boxPos shl 16) or manPos;
    Q_Pos    := 0;
    Q_Pos2   := 1;
    Q[Q_Pos] := F;

    boxMark[boxPos div mapWidth, boxPos mod mapWidth] := boxMark[boxPos div mapWidth, boxPos mod mapWidth] or curMark;  // ��������

    while (Q_Pos <> Q_Pos2) do begin
        F := Q[Q_Pos];    // ������
        Q_Pos := Q_Pos + 1;
        if Q_Pos > MAX_Size then Q_Pos := 0;

        Box_F := F shr 16;
        Man_F := F and $FFFF;

        box_R := Box_F div mapWidth;
        box_C := Box_F mod mapWidth;
        man_R := Man_F div mapWidth;
        man_C := Man_F mod mapWidth;

        for k := 0 to 3 do begin  // ���f������
            if mark0[box_R, box_C, k] then continue;  // �ýڵ�Ĵ˷��򣨷�������

            newR := box_R + dr4[k];  // ������λ��     
            newC := box_C + dc4[k];
            if isBK then begin         // ����
                mToR := newR;                             // ��������λ�ã����赽��λ��
                mToC := newC;

                // ���⣬������
                r := newR + dr4[k];
                c := newC + dc4[k];
                if (r < 0) or (c < 0) or (r >= mapHeight) or (c >= mapWidth) or
                   (mToR < 0) or (mToC < 0) or (mToR >= mapHeight) or (mToC >= mapWidth) or
                   ('-' <> tmpMap[r, c]) or ('-' <> tmpMap[mToR, mToC]) then continue;
            end else begin
                mToR := box_R - dr4[k];                 // ��������λ�ã����赽��λ��
                mToC := box_C - dc4[k];

                // ���⣬������
                if (newR < 0) or (newC < 0) or (newR >= mapHeight) or (newC >= mapWidth) or
                   (mToR < 0) or (mToC < 0) or (mToR >= mapHeight) or (mToC >= mapWidth) or
                   ('-' <> tmpMap[newR, newC]) or ('-' <> tmpMap[mToR, mToC]) then continue;
            end;
            if manTo2b(isBK, box_R, box_C, man_R, man_C, mToR, mToC) then begin                  // ���ܷ����
                // �¿ɴ�����д���
                if isBK then F := ((newR * mapWidth + newC) shl 16) or ((newR + dr4[k]) * mapWidth + newC + dc4[k])
                else F := ((newR * mapWidth + newC) shl 16) or (box_R * mapWidth + box_C);
                Q[Q_Pos2] := F;
                Q_Pos2 := Q_Pos2 + 1;
                if Q_Pos2 > MAX_Size then begin
                   Q_Pos2 := 0;

//{$IFDEF LASTACT}
//if not isEditor then begin
//   Writeln(myLogFile_, '');
//   Writeln(myLogFile_, DateTimeToStr(Now) + '*********** ' + inttostr(Q_Pos));      // �����ã��鿴����ʹ�����
//   Flush(myLogFile_);
//end;
//{$ENDIF}

                end;
                boxMark[newR, newC] := boxMark[newR, newC] or curMark;                           // �µĿɴ��
                mark0[box_R, box_C, k] := true;                                                  // �ýڵ�Ĵ˷��򣨷�������
            end;
        end;
    end;
end;

// �鿴���� firR, firC �� secR, setC �Ƿ��˿ɴboxR, boxC Ϊ����������ӵ�λ�ã��� boxR < 0 ʱ���򲻲鿴��
function manTo2b(isBK: Boolean; boxR, boxC, firR, firC, secR, secC: Integer): Boolean;
var
    i, j: Integer;

begin
    if (firR = secR ) and (firC = secC) then begin Result := true; Exit; end;

    //��2 ���ǿյ�
    if (secR < 0) or (secC < 0) or (secR >= mapHeight) or (secC >= mapWidth) or ('-' <> tmpMap[secR, secC]) then begin Result := false; Exit; end;

    Result := False;

    if (not cut[boxR, boxC]) and (block[firR, firC, block[firR, firC, 0]] > 0) then begin
        Result := true;
        Exit;   // ����������Ӳ��ڸ����
    end else begin
        for i := 1 to block[firR, firC, block[firR, firC, 0]] do begin  //������ͬһ���ڣ��ض��ɴ�
            for j := 1 to block[secR, secC, block[secR, secC, 0]] do begin
                if ( block[firR, firC, i] = block[secR, secC, j]) then begin
                   Result := true;
                   Exit;
                end;
            end;
        end;

        // ����㷨���ɴ�ʱ������Խ���
        if isThroughable or (tmpMap[boxR, boxC] = '-') then begin
            tmpMap[boxR, boxC] := '$';
            Result := manTo2(isBK, boxR, boxC, firR, firC, secR, secC);
            tmpMap[boxR, boxC] := '-';
        end;
    end;
end;

// �鿴���Ƿ���Դӵ�һ�� firR�� firC ����ڶ��� secR�� setC
function manTo2(isBK: Boolean; boxR, boxC, firR, firC, secR, secC: Integer): Boolean;
var
  i, j, k, i1, i2, i3, j1, j2, j3, p, tail, r, c: Integer;
  curMark: Byte;
  
begin
    Result := true;

    if (firR = secR) and (firC = secC) then Exit;

    if isBK then curMark := $0F     // ����ʱ���������Ʊ�־
    else curMark := $F0;            // ����ʱ���������Ʊ�־

    for i := 0 to mapHeight-1 do begin
        for j := 0 to mapWidth-1 do begin
//            if (level[i][j] == '-' || level[i][j] == '.' || level[i][j] == '@' || level[i][j] == '+') then tmpLevel[i][j] = '-'
//            else if (level[i][j] == '*') then tmpLevel[i][j] = '$'
//            else tmpLevel[i][j] = level[i][j];
            manMark[i, j] := manMark[i, j] and curMark;
        end;
    end;

    if isBK then curMark := $10     // ����ʱ���������Ʊ�־
    else curMark := $01;            // ����ʱ���������Ʊ�־

    pt[0] := firR * mapWidth + firC;
    manMark[firR, firC] := manMark[firR, firC] or curMark;
    p := 0; tail := 0;
    while p <= tail do begin         // �����Ų�
        while p <= tail do begin
            r := pt[p] div mapWidth;
            c := pt[p] mod mapWidth;
            for k := 0 to 3 do begin
                i1 := r + dr4[k];
                j1 := c + dc4[k];
                if (i1 < 0) or (j1 < 0) or (i1 >= mapHeight) or (j1 >= mapWidth) then continue  // ����
                else if ('-' = tmpMap[i1, j1]) and ((manMark[i1, j1] and curMark) = 0) then begin
                    Inc(tail);
                    pt[tail] := i1 * mapWidth + j1;            // �µ��㼣
                    manMark[i1, j1] := manMark[i1, j1] or curMark;

                    if (secR = i1) and (secC = j1) then Exit;  // ����Ŀ��
                end;
            end;
            Inc(p);
        end;
                                 
        // ��Խ�Ų�
        if isThroughable then begin     
            for i := 1 to mapHeight-2 do begin
                for j := 1 to mapWidth-2 do begin
                    if ('-' = tmpMap[i, j]) and ((manMark[i, j] and curMark) = 0) then begin
                        for k := 0 to 3 do begin
                            i1 := i - dr4[k];
                            j1 := j - dc4[k];
                            if (boxR >= 0) and (i1 = boxR) and (j1 = boxC) then begin
                                continue;               // ����Ҫ����������Ӳ�����Ϊ��Խ��
                            end;
                            deep_Thur := 0;
                            if isBK then begin  // ����
                                i1 := i + 3 * dr4[k];
                                j1 := j + 3 * dc4[k];
                                i2 := i + 2 * dr4[k];
                                j2 := j + 2 * dc4[k];
                                i3 := i + dr4[k];
                                j3 := j + dc4[k];
                                if (i1 < 0) or (j1 < 0) or (i1 >= mapHeight) or (j1 >= mapWidth) or
                                   (i2 < 0) or (j2 < 0) or (i2 >= mapHeight) or (j2 >= mapWidth) or
                                   (i3 < 0) or (j3 < 0) or (i3 >= mapHeight) or (j3 >= mapWidth) then continue  // ����
                                else if ('$' = tmpMap[i3, j3]) and ((manMark[i1, j1] and curMark) > 0) and ((manMark[i2, j2] and curMark) > 0) then begin
                                    tmpMap[i3, j3] := '-';
                                    if canThrough(isBK, i2, j2, i1, j1, i3, j3, k) then begin
                                        manMark[i, j] := manMark[i, j] or curMark;
                                        Inc(tail);
                                        pt[tail] := i * mapWidth + j;

                                        if (i = secR) and (j = secC) then begin  // ����Ŀ��
                                            tmpMap[i3, j3] := '$';
                                            Exit;
                                        end;
                                    end;
                                    tmpMap[i3, j3] := '$';
                                end;
                            end else begin  // ����
                                i1 := i + dr4[k];
                                j1 := j + dc4[k];
                                i2 := i - dr4[k];
                                j2 := j - dc4[k];
                                i3 := i - 2 * dr4[k];
                                j3 := j - 2 * dc4[k];
                                if (i1 < 0) or (j1 < 0) or (i1 >= mapHeight) or (j1 >= mapWidth) or
                                   (i2 < 0) or (j2 < 0) or (i2 >= mapHeight) or (j2 >= mapWidth) or
                                   (i3 < 0) or (j3 < 0) or (i3 >= mapHeight) or (j3 >= mapWidth) then continue  // ����
                                else if ('$' = tmpMap[i2, j2]) and ('-' = tmpMap[i1, j1]) and ((manMark[i3, j3] and curMark) > 0) then begin
                                    tmpMap[i2, j2] := '-';
                                    if canThrough(isBK, i, j, i2, j2, i1, j1, k) then begin
                                        manMark[i, j] := manMark[i, j] or curMark;
                                        Inc(tail);
                                        pt[tail] := i * mapWidth + j;

                                        if (i = secR) and (j = secC) then begin  // ����Ŀ��
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

// �������Ӵ� boxPos ���� toPos �����·��
function boxTo(isBK: Boolean; boxPos, toPos, manPos: Integer): Integer;
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

  // �Դ�ģ�����ȶ���
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
          
          if x.T < y.T then begin             // �ȱȽ�ת����
             Break;
          end else if x.T = y.T then begin
             if x.H < y.H then begin          // �ٱȽ�����ֵ
                Break;
             end else if x.H = y.H then begin
                if x.G < y.G then begin       // ���Ƚ��ƶ����ģ�������
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

// ���Թ��ܣ����������ʱ��BoxMan.log �ĵ��У����¼֮ǰ�Ķ������������̫�����ʧ    
{$IFDEF LASTACT}
if not isEditor then begin
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
end;
{$ENDIF}

    for i := 0 to mapHeight-1 do begin
        for j := 0 to mapWidth-1 do begin
            mark0[i][j][0] := false;            // �ڵ���ķ��򣨷����Ƿ�����
            mark0[i][j][1] := false;
            mark0[i][j][2] := false;
            mark0[i][j][3] := false;
        end;
    end;

    isFound := false;                           // �Ƿ��ҵ�����·��

    boxR := boxPos div mapWidth;
    boxC := boxPos mod mapWidth;
    toR  := toPos  div mapWidth;
    toC  := toPos  mod mapWidth;
    manR := manPos div mapWidth;
    manC := manPos mod mapWidth;

    New(PQ);
    PQ.boxPos := boxPos;                         // ��ʼλ������У�����������
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
        PQ_Head.next := nil;
        Dispose(PBoxManNode(PQ_Head));
        PQ_Head := nil;

        for k := 0 to 3 do begin         // ���f������
            if mark0[box_R, box_C, k] then continue;  // �ýڵ�Ĵ˷��򣨷�������

            newR := box_R + dr4[k];      // ������λ��
            newC := box_C + dc4[k];
            if isBK then begin           // ����
                mToR := newR;            // ��������λ�ã����赽��λ��
                mToC := newC;
                r := newR + dr4[k];
                c := newC + dc4[k];
                if (r < 0) or (c < 0) or (r >= mapHeight) or (c >= mapWidth) or
                   (mToR < 0) or (mToC < 0) or (mToR >= mapHeight) or (mToC >= mapWidth) or
                   ('-' <> tmpMap[r, c]) or ('-' <> tmpMap[mToR, mToC]) then continue;
            end else begin
                mToR := box_R - dr4[k];  // ��������λ�ã����赽��λ��
                mToC := box_C - dc4[k];
                if (newR < 0) or (newC < 0) or (newR >= mapHeight) or (newC >= mapWidth) or
                   (mToR < 0) or (mToC < 0) or (mToR >= mapHeight) or (mToC >= mapWidth) or
                   ('-' <> tmpMap[newR, newC]) or ('-' <> tmpMap[mToR, mToC]) then continue;
            end;
            if manTo2b(isBK, box_R, box_C, man_R, man_C, mToR, mToC) then begin   // ���ܷ����
                mark0[box_R, box_C, k] := true;          // �ýڵ�Ĵ˷��򣨷�������

                H := abs(newR - toR) + abs(newC - toC);  // ����ֵ��������Ŀ��㿿£
                if (DD = k) then T := TT                // ת���ۼ�ֵ���Դ���Ϊ���ȶ����нڵ�Ƚϵ�����
                else T := TT + 1;
                G := GG + 1;

                if isBK then AddNode2(newR * mapWidth + newC, (newR + dr4[k]) * mapWidth + newC + dc4[k], H, G, T, k, PQ)
                else AddNode2(newR * mapWidth + newC, box_R * mapWidth + box_C, H, G, T, k, PQ);

                list1[size1] := (DD shl 24) or (k shl 16) or (newC shl 8) or newR;  // k - ���ڵ㣬DD - ���ڵ�ĸ��ڵ�
                Inc(size1);

                if (newR = toR) and (newC = toC) then begin     // ����Ŀ���
                    isFound := true;
                    break;
                end;
            end;
        end;
    end;

    while PQ <> nil do begin
        PQ_Head := PQ;
        PQ := PQ.next;
        PQ_Head.next := nil;
        Dispose(PBoxManNode(PQ_Head));
        PQ_Head := nil;
    end;

    if (isFound) then begin  // �ҵ���·��

        mToR  := toR;        // ����Ŀ��
        mToC  := toC;

        mDir0 := -1;

        while size1 > 0 do begin  // ȡ�ô������ƶ���·������ list2
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

            mDir0 := Node_dir2;               // ���ڵ�ĸ��ڵ�
        end;

        mDir0 := -1;
        
        // ���Ӻ����ƶ�ǰ��λ��
        newR   := boxR;
        newC   := boxC;
        mFromR := manR;
        mFromC := manC;

        while size2 > 0 do begin         // �������ƶ���·��
            Dec(size2);
            mDir := (list2[size2] shr 16) and $FF;
            if isBK then begin                 // ����
                mToR := newR + dr4[mDir];
                mToC := newC + dc4[mDir];
            end else begin
                mToR := newR - dr4[mDir];
                mToC := newC - dc4[mDir];
            end;

            if (mDir = mDir0) then begin       // �����ƶ�����û�иı�
                if Result = MaxLenPath then Exit;
                ch := lurdChar[mDir + 4];
                Inc(Result);
                BoxPath[Result] := ch;
            end else begin                     // ���Ӹı����ƶ�����
                tmpMap[newR, newC] := '$';

                len := manTo(isBK, tmpMap2, mFromR * mapWidth + mFromC, mToR * mapWidth + mToC);  // ��������λ·��
                
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
            if isBK then begin               // ����
                newR   := mToR;              // ���ӽ�һλ����������ǰ�棩
                newC   := mToC;
                mFromR := newR + dr4[mDir];  // �˽�һλ����������ǰ�棩
                mFromC := newC + dc4[mDir];
            end else begin
                mFromR := newR;              // �˵����ӵ�λ�ã��������Ӻ��棩
                mFromC := newC;
                newR   := newR + dr4[mDir];  // ���ӽ�һλ
                newC   := newC + dc4[mDir];
            end;
        end;
    end;
end;

end.
