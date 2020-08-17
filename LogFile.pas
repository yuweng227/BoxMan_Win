unit LogFile;

interface
  procedure LogFileInit(ph: string);
  procedure LogFileClose();

var
  myLogFile: Textfile;

  AppPath, curSkinFileName: string;      // 皮肤文档名


implementation

// 初始化 Log 文件
procedure LogFileInit(ph: string);
begin
  AssignFile(myLogFile, ph + 'BoxMan.log');
  ReWrite(myLogFile);
end;

// 关闭 Log 文件
procedure LogFileClose();
begin
  Closefile(myLogFile);
end;

end.
