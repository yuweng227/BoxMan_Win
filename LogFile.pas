unit LogFile;

interface
  procedure LogFileInit(ph: string);
  procedure LogFileClose();
  procedure LogFileInit_(ph: string);
  procedure LogFileClose_();

var
  myLogFile, myLogFile_: Textfile;

  AppPath, curSkinFileName: string;      // 皮肤文档名


implementation

// 初始化 Log 文件
procedure LogFileInit(ph: string);
begin
  AssignFile(myLogFile, ph);
  ReWrite(myLogFile);
end;

// 关闭 Log 文件
procedure LogFileClose();
begin
  Closefile(myLogFile);
end;

// 初始化动作 Log 文件
procedure LogFileInit_(ph: string);
begin
  AssignFile(myLogFile_, ph);
  ReWrite(myLogFile_);
end;

// 关闭动作 Log 文件
procedure LogFileClose_();
begin
  Closefile(myLogFile_);
end;

end.
