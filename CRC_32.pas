unit CRC_32;

interface

uses
  SysUtils, StrUtils;

  function Calcu_CRC_32(const Data: PChar; Rows, Cols: Integer): LongWord;
  function Calcu_CRC_32_2(const Data: PChar; Len: Integer): LongWord;

implementation

Type
  TcrcArrDW = array [0..255] of LongWord;

const
  P_32: LongWord = $EDB88320;
  
var
  crc_tab32: TcrcArrDW;

function Calcu_CRC_32(const Data: PChar; Rows, Cols: Integer): LongWord;
var
  i, j: integer;
  tmp, long_c, crc: longWord;
  aByte: Byte;
  
begin
  crc := $ffffffff;
  for i := 0 to Rows-1 do begin
      for j := 0 to Cols-1 do begin
        aByte := ord(Data[i * 100 + j]);
        long_c := ($000000ff and aByte);
        tmp := crc xor long_c;
        crc := (crc shr 8) xor crc_tab32[tmp and $ff];
      end;
  end;
  result := crc xor $FFFFFFFF;
end;

function Calcu_CRC_32_2(const Data: PChar; Len: Integer): LongWord;
var
  i: integer;
  tmp, long_c, crc: longWord;
  aByte: Byte;

begin
  crc := $ffffffff;
  for i := 0 to Len-1 do begin
      aByte := ord(Data[i]);
      long_c := ($000000ff and aByte);
      tmp := crc xor long_c;
      crc := (crc shr 8) xor crc_tab32[tmp and $ff];
  end;
  result := crc xor $FFFFFFFF;
end;

procedure init_crc32_tab();
var
  i, j: integer;
  crc: longWord;
begin
   for i := 0 to 255 do
   begin
     crc := i;
     for j := 0 to 7 do
     begin
       if (crc and $00000001) = 1 then crc := ( crc shr 1 ) xor P_32
       else  crc := crc shr 1;
     end;
     crc_tab32[i] := crc;
   end;
end;

initialization
  init_crc32_tab();
  
finalization
  //
end.
