unit BrowseLevels;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ComCtrls, ImgList, Math, CommCtrl, Menus, StdCtrls, ExtCtrls, Buttons, LoadMapUnit;

type
  TBrowseForm = class(TForm)
    Panel1: TPanel;
    ColorBox1: TColorBox;
    Label1: TLabel;
    sb_Find: TSpeedButton;
    Image1: TImage;
    ScrollBar1: TScrollBar;
    Panel2: TPanel;
    sb_Delete: TSpeedButton;

    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ColorBox1Click(Sender: TObject);
    procedure ShowInf;
    procedure DrawIcon;
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1DblClick(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);      // 画图标
    procedure isSolved(mapNode: PMapNode);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure sb_FindClick(Sender: TObject);
    procedure sb_DeleteClick(Sender: TObject);            // 检测关卡是否已经有解

  private
    { Private declarations }
  public
    { Public declarations }

    BK_Color: TColor;        // 浏览背景色
    curIndex: Integer;
    isStop: Boolean;         // 强制停止绘制图标

  end;

var
  BrowseForm: TBrowseForm;
  Size_Icon, TopRow, BottomRow, Columns, pageSize: Integer;      // 图标尺寸，顶行图标行, 图标行数, 页大小
  myTitle: string;

implementation

uses
  LoadSkin, inf, MainForm, SQLiteTable3, LogFile;

{$R *.dfm}

procedure TBrowseForm.FormShow(Sender: TObject);
var
  mapNode: PMapNode;
  i, size: Integer;

begin
  size := ColorBox1.Items.Count;
  for i := 0 to size-1 do begin
      if BK_Color = ColorBox1.Colors[i] then ColorBox1.ItemIndex := i
      else ColorBox1.ItemIndex := clWhite;
  end;
  
  if (curIndex < 0) or (curIndex >= MapList.Count) then curIndex := 0;
  Tag := curIndex;

  FormResize(Sender);

  myTitle := '浏览 ~ 关卡总数: ' + IntToStr(MapList.Count);
  
  mapNode := MapList[curIndex];
  Caption := myTitle + ', 当前关卡: ' + IntToStr(Tag+1) + '，尺寸: ' + IntToStr(mapNode.Cols) + '×' + IntToStr(mapNode.Rows) + '，箱子: ' + IntToStr(mapNode.Boxs) + '，目标: ' + IntToStr(mapNode.Goals) + ', 标题: ' + mapNode.Title + ',  作者: ' + mapNode.Author;
  mapNode := nil;
  isStop := True;
end;

procedure TBrowseForm.FormCreate(Sender: TObject);
begin
  BK_Color := clWhite;
  Caption := '浏览';
  Label1.Caption := '背景色: ';
  sb_Find.Caption := '查找剪切板中的关卡';
  sb_Delete.Hint := '删除当前关卡';

  Size_Icon := 150;                    // 图标尺寸
end;

// 检测关卡是否已经有解
procedure TBrowseForm.isSolved(mapNode: PMapNode);
var
  sldb: TSQLiteDatabase;
  sltb: TSQLIteTable;
  sSQL: String;
begin
  sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));
  try
    sSQL := 'select id from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNode.CRC32) + ' and Goals = ' + IntToStr(mapNode.Goals);
    sltb := slDb.GetTable(sSQL);
    try
        mapNode.Solved := (sltb.Count > 0);
    finally
      if Assigned(sltb) then sltb.Free;
      sltb := nil;
    end;
  finally
    if Assigned(sldb) then sldb.Free;
    sldb := nil;
  end;
end;

// 计算无缝墙壁图元
function GetWall(map: TStringList; r, c: Integer): Integer;
var
  len: Integer;
begin
  result := 0;

  len := Length(map[r]);
  if (c > 0) and (c - 1 <= len) and (map[r][c - 1] = '#') then
      result := result or 1;    // 左有墙壁

  if (r > 0) then begin
    len := Length(map[r-1]);
    if (c <= len) and (map[r - 1][c] = '#') then
        result := result or 2;  // 上有墙壁
  end;

  len := Length(map[r]);
  if (c < len) and (map[r][c + 1] = '#') then
      result := result or 4;    // 右有墙壁

  if (r < map.Count - 1) then begin
     len := Length(map[r+1]);
     if (c <= len) and (map[r + 1][c] = '#') then
         result := result or 8;// 下有墙壁
  end;

  len := Length(map[r]);
  if ((result = 3) or (result = 7) or (result = 11) or (result = 15)) and (c > 0) and (r > 0) and (c - 1 <= len) and (map[r][c - 1] = '#') then
       result := result or 16; // 需要画墙顶
end;

// 画图标
procedure TBrowseForm.DrawIcon;
var
  i, j, k, t, l, w, row, col, x_Size, y_Size, cell_Size, x, y, Rows, Cols, len, c, str_W: Integer;
  R: TRect;
  ch: Char;
  mapNode: PMapNode;
  str: string;
begin
  Image1.Visible := false;
  isStop := False;
  Image1.Canvas.CopyMode := SRCCOPY;

  with Image1.Canvas do begin
      Brush.Color := BK_Color;                   // 背景色
      Font.Size := 11;
      FillRect(ClientRect);

      c := MapList.Count;                        // 图标总数
      for i := TopRow to BottomRow do begin
          if isStop then Break;
          for j := 0 to Columns-1 do begin
              if isStop then Break;
              k := Columns * i + j;              // 准备开始画的图标 -- 当前图标
              if k >= c then Break;

              mapNode := MapList[k];             // 当前图标
              Rows := mapNode.Map.Count;         // 当前图标的垂直小格子数
              Cols := Length(mapNode.Map[0]);    // 当前图标的水平小格子数

              x_Size := Size_Icon div Cols;    
              y_Size := Size_Icon div Rows;
              cell_Size := Min(x_Size, y_Size);  // 图标中的小格子尺寸

              x := (Size_Icon - cell_Size * Cols) div 2;      // 图标左右和上下的空白尺寸
              y := (Size_Icon - cell_Size * Rows) div 2;

              t := (i - TopRow) * (Size_Icon + 30);           // 各图标的起始位置，垂直间隔 30 像素（此间隔包含序号显示）
              l := j * (Size_Icon + 10);                      // 水平间隔 10 像素

              for row := 0 to Rows-1 do begin
                  if isStop then Break;
                  len := Length(mapNode.Map[row]);
                  for col := 1 to Cols do begin
                      if isStop then Break;
                      R := Rect((col-1) * cell_Size + x + l, row * cell_Size + y + t, col * cell_Size + x + l, (row+1) * cell_Size + y + t);

                      if col > len then ch := '-'
                      else ch := mapNode.Map[row][col];

                      case ch of
                        '#': begin //StretchDraw(R, WallPic);

                            if isSeamless then begin    // 无缝墙壁
                              w := GetWall(mapNode.Map, row, col);
                              case (w and $F) of
                                1:
                                  StretchDraw(R, WallPic_l);     // 仅左
                                2:
                                  StretchDraw(R, WallPic_u);     // 仅上
                                3:
                                  StretchDraw(R, WallPic_lu);    // 左、上
                                4:
                                  StretchDraw(R, WallPic_r);     // 仅右
                                5:
                                  StretchDraw(R, WallPic_lr);    // 左、右
                                6:
                                  StretchDraw(R, WallPic_ru);    // 右、上
                                7:
                                  StretchDraw(R, WallPic_lur);   // 左、上、右
                                8:
                                  StretchDraw(R, WallPic_d);     // 仅下
                                9:
                                  StretchDraw(R, WallPic_ld);    // 左、下
                                10:
                                  StretchDraw(R, WallPic_ud);    // 上、下
                                11:
                                  StretchDraw(R, WallPic_uld);   // 左、上、下
                                12:
                                  StretchDraw(R, WallPic_rd);    // 右、下
                                13:
                                  StretchDraw(R, WallPic_ldr);   // 左、右、下
                                14:
                                  StretchDraw(R, WallPic_urd);   // 上、右、下
                                15:
                                  StretchDraw(R, WallPic_lurd);  // 四方向全有
                                else
                                  StretchDraw(R, WallPic);
                              end;
                            end else begin
                              StretchDraw(R, WallPic);
                            end;
                        end;
                        '-': StretchDraw(R, FloorPic);
                        '.': StretchDraw(R, GoalPic);
                        '$': StretchDraw(R, BoxPic);
                        '*': StretchDraw(R, BoxGoalPic);
                        '@': StretchDraw(R, ManPic);
                        '+': StretchDraw(R, ManGoalPic);
                      end;

                  end;
              end;

              // 不合格的关卡
              if not mapNode.isEligible then begin
                 Pen.Color := $0000ff;
                 Pen.Width := 2;
                 MoveTo(l, t);
                 LineTo(l+Size_Icon, t+Size_Icon);
                 MoveTo(l, t+Size_Icon);
                 LineTo(l+Size_Icon, t);
              end;

              // 图标序号，绿色背景表示已解
              R := Rect(l + 5, t + Size_Icon + 2, l + Size_Icon - 5, t + Size_Icon + 22);
              if (mapNode.isEligible) and (mapNode.Num = 0) then begin
                 isSolved(mapNode);                                   // 检查是否已有答案
                 mapNode.Num := -1;
              end;
              if mapNode.Solved then Brush.Color := clGreen           // 有答案图标的背景色
              else Brush.Color := BK_Color;
              FillRect(R);
              str := IntToStr(Columns * i + j + 1);
              str_W := TextWidth(str);
              TextOut(l + (Size_Icon - str_W) div 2, R.Top + 3, str);

              if Tag = k then begin
                 Pen.Color := clYellow;
                 Pen.Width := 3;
                 MoveTo(l, t);
                 LineTo(l + Size_Icon, t);
                 LineTo(l + Size_Icon, t + Size_Icon + 30);
                 LineTo(l, t + Size_Icon + 30);
                 LineTo(l, t);
                 Pen.Color := clBlack;
                 Pen.Width := 1;
                 MoveTo(l, t);
                 LineTo(l + Size_Icon, t);
                 LineTo(l + Size_Icon, t + Size_Icon + 30);
                 LineTo(l, t + Size_Icon + 30);
                 LineTo(l, t);
              end;
          end;
      end;
  end;

  Image1.Visible := True;
  mapNode := nil;

  isStop := True;
end;

procedure TBrowseForm.FormResize(Sender: TObject);
var
  n: Integer;
begin
  isStop := True;
  
  if Width  < 600 then Width  := 600;
  if Height < 400 then Height := 400;

  // 确定界面尺寸
  Image1.Picture := nil;
  Image1.Width  := Panel2.Width;
  Image1.Height := Panel2.Height;

  Columns := Floor(Image1.Width div (Size_Icon + 10));            // 每行图标数（水平间隔 10 像素）
  TopRow := Tag div Columns;                                      // 顶行
  BottomRow := TopRow + Image1.Height div Columns - 1;            // 底行

  ScrollBar1.PageSize := 0;
  ScrollBar1.LargeChange := 1;
  ScrollBar1.Min := 0;
  n := Ceil(MapList.Count div Columns);

  if n > 1 then ScrollBar1.Max := n
  else ScrollBar1.Max := 0;

  pageSize := Floor(Image1.Height div (Size_Icon + 30)) - 1;      // 垂直间隔 30 像素
  if pageSize < 0 then pageSize := 0;
  ScrollBar1.PageSize := pageSize;
  ScrollBar1.LargeChange := pageSize;
  ScrollBar1.Position := TopRow;

  DrawIcon;
end;

// 关卡详细资料
procedure TBrowseForm.ColorBox1Click(Sender: TObject);
begin
  BK_Color := ColorBox1.Colors[ColorBox1.ItemIndex];
  DrawIcon;
end;

procedure TBrowseForm.ShowInf;
var
  mapNode: PMapNode;
  k, n: Integer;
begin

  if (Tag >= 0) and (Tag < MapList.Count) then begin
      mapNode := MapList[Tag];

     n := Length(mapNode.Comment);
     if n = 0 then exit;
     k := 1;
     // 检查是否是空行 -- 仅有空格和跳格符
     while k <= n do begin
       if (mapNode.Comment[k] <> #20) and (mapNode.Comment[k] <> #9) and (mapNode.Comment[k] <> #10) or (mapNode.Comment[k] = '') then Break;
       k := k+1;
     end;
     if k > n then Exit;

     InfForm.Memo1.Lines.Clear;
     InfForm.Memo1.Lines.Add(mapNode.Comment);
     mapNode := nil;
     InfForm.Show;
  end;
end;

procedure Delay(msecs: dword);
var
  FirstTickCount: dword;

begin
  FirstTickCount := GetTickCount;
  while GetTickCount-FirstTickCount < msecs do Application.ProcessMessages;
end;

procedure TBrowseForm.FormMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  isStop := True;
  Delay(10);
  ScrollBar1.Position := ScrollBar1.Position + 1;
  TopRow := ScrollBar1.Position;
  BottomRow := TopRow + Ceil(Image1.Height div Columns) - 1;          // 底行
  DrawIcon;
  Handled := True;
end;

procedure TBrowseForm.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  isStop := True;
  Delay(10);
  ScrollBar1.Position := ScrollBar1.Position - 1;
  TopRow := ScrollBar1.Position;
  BottomRow := TopRow + Ceil(Image1.Height div Columns) - 1;          // 底行
  DrawIcon;
  Handled := True;
end;

procedure TBrowseForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_HOME:                // Home
      begin
        isStop := True;
        TopRow := TopRow - pageSize;
        if TopRow < 0 then TopRow := 0;
        ScrollBar1.Position := TopRow;
        BottomRow := TopRow + Ceil(Image1.Height div Columns) - 1;          // 底行
        DrawIcon;
      end;
    VK_END:                 // End
      begin
        isStop := True;
        BottomRow := ScrollBar1.Max;                                        // 底行
        TopRow := TopRow - pageSize;
        if TopRow < 0 then TopRow := 0;
        ScrollBar1.Position := TopRow;
        DrawIcon;
      end;
   end;
end;

procedure TBrowseForm.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  mapNode: PMapNode;
  row, col: Integer;
begin
  isStop := True;

  row := Floor(y div (Size_Icon + 30));
  col := Floor(x div (Size_Icon + 10));

  Tag := Columns * (row + TopRow) + col;       // 被点击的图标

  if (Tag < 0) or (Tag >= MapList.Count) then Exit;

  mapNode := MapList[Tag];

  Caption := myTitle + ', 当前关卡: ' + IntToStr(Tag+1) + '，尺寸: ' + IntToStr(mapNode.Cols) + '×' + IntToStr(mapNode.Rows) + '，箱子: ' + IntToStr(mapNode.Boxs) + '，目标: ' + IntToStr(mapNode.Goals) + ', 标题: ' + mapNode.Title + ',  作者: ' + mapNode.Author;
  //  Caption := Caption + ', R=' + IntToStr(mapNode.CRC_Num);

  DrawIcon;

  if Button = mbRight then begin            // 单击 -- 指右键
     InfForm.Left := Left + x;
     InfForm.Top  := Top + y;

     if Screen.Width < InfForm.Left + InfForm.Width then InfForm.Left := Screen.Width - InfForm.Width;
     if Screen.Height < InfForm.Top + InfForm.Height then InfForm.Top := Screen.Height - InfForm.Height;

     ShowInf;
  end;
  
  mapNode := nil;
end;

procedure TBrowseForm.Image1DblClick(Sender: TObject);
begin
  if Tag >= 0 then begin
     curIndex := Tag;
     Close;
  end else Caption := myTitle;

end;

procedure TBrowseForm.ScrollBar1Change(Sender: TObject);
begin
  isStop := True;
  TopRow := ScrollBar1.Position;
  BottomRow := TopRow + Ceil(Image1.Height div Columns) - 1;          // 底行
  DrawIcon;
end;

procedure TBrowseForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  isStop := True;
end;

procedure TBrowseForm.sb_FindClick(Sender: TObject);
var
  i: Integer;
begin
  i := FindClipbrd(Tag);

  if i < 0 then begin
     MessageBox(Handle, PChar(IntToStr(Tag+1) + ' 号关卡之后，没有找到剪切板中的关卡！'), '提醒', MB_ICONWARNING  + MB_OK);
  end else begin
     Tag := i;
     DrawIcon;
     FormResize(Sender);
     MessageBox(Handle, PChar('找到 ' + IntToStr(Tag+1) + ' 号关卡！'), '好消息', MB_ICONINFORMATION  + MB_OK);
  end;
end;

procedure TBrowseForm.sb_DeleteClick(Sender: TObject);
var
  myXSBFile: Textfile;
  i, j: Integer;
  mapNode: PMapNode;               // 关卡节点
  isOK: Boolean;
begin
  if MessageBox(Handle, PChar('删除 ' + IntToStr(Tag+1) + ' 号关卡，确定吗？'), '确定', MB_ICONQUESTION + MB_OKCANCEL) = idOK then begin
    AssignFile(myXSBFile, AppPath + main.mySettings.MapFileName);

    // 备份
    if FileExists(AppPath + main.mySettings.MapFileName) then CopyFile(PChar(AppPath + main.mySettings.MapFileName), PChar(AppPath + 'BoxMan.xsb.bak'), False);   // 备份周转关卡库

    Rewrite(myXSBFile);                                                 // 创建
    isOK := False;

    try
      // 先写入新的内容
      for i := 0 to MapList.Count - 1 do begin
        if Tag = i then Continue;   // 跳过当前关卡即可

        mapNode := MapList.Items[i];

        Writeln(myXSBFile, '');
        for j := 0 to mapNode.Map.Count - 1 do begin
          Writeln(myXSBFile, mapNode.Map[j]);
        end;
        if Trim(mapNode.Title) <> '' then
          Writeln(myXSBFile, 'Title: ' + mapNode.Title);
        if Trim(mapNode.Author) <> '' then
          Writeln(myXSBFile, 'Author: ' + mapNode.Author);
        if Trim(mapNode.Comment) <> '' then begin
          Writeln(myXSBFile, 'Comment: ');
          Writeln(myXSBFile, mapNode.Comment);
          Writeln(myXSBFile, 'Comment_end: ');
          Writeln(myXSBFile, '');
          Writeln(myXSBFile, '');
        end;
      end;
      isOK := True;
    finally
      Closefile(myXSBFile);
      if isOK then begin
        mapNode := MapList.Items[Tag];
        MapList.Delete(Tag);
        if Assigned(mapNode.Map) then begin
           mapNode.Map.Clear;
           mapNode.Map.Free;
        end;
        Dispose(mapNode);
        main.maxNumber := MapList.Count;
        if Tag >= main.maxNumber then begin
           Tag := main.maxNumber-1;
           curIndex := Tag;
        end;

        myTitle := '浏览 ~ 关卡总数: ' + IntToStr(MapList.Count);
        mapNode := MapList[Tag];
        Caption := myTitle + ', 当前关卡: ' + IntToStr(Tag+1) + '，尺寸: ' + IntToStr(mapNode.Cols) + '×' + IntToStr(mapNode.Rows) + '，箱子: ' + IntToStr(mapNode.Boxs) + '，目标: ' + IntToStr(mapNode.Goals) + ', 标题: ' + mapNode.Title + ',  作者: ' + mapNode.Author;
      end;
      mapNode := nil;
      FormResize(Sender);
    end;
  end;
end;

end.
