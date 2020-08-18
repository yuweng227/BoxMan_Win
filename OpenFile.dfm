object MyOpenFile: TMyOpenFile
  Left = 759
  Top = 158
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = #23548#20837#31572#26696
  ClientHeight = 362
  ClientWidth = 584
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClick = FormClick
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel3: TPanel
    Left = 0
    Top = 32
    Width = 584
    Height = 289
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object FileListBox1: TFileListBox
      Left = 217
      Top = 0
      Width = 367
      Height = 289
      Align = alClient
      BevelInner = bvNone
      ImeName = #20013#25991'('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      ItemHeight = 18
      Mask = '*.txt;*.xsb'
      TabOrder = 0
    end
    object DirectoryListBox1: TDirectoryListBox
      Left = 0
      Top = 0
      Width = 217
      Height = 289
      Align = alLeft
      FileList = FileListBox1
      ImeName = #20013#25991'('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      ItemHeight = 18
      TabOrder = 1
      OnChange = DirectoryListBox1Change
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 584
    Height = 32
    Align = alTop
    BevelOuter = bvLowered
    Color = clInactiveCaption
    TabOrder = 1
    object SpeedButton1: TSpeedButton
      Left = 176
      Top = 5
      Width = 81
      Height = 22
      Caption = #25105#30340#25991#26723
      OnClick = SpeedButton1Click
    end
    object SpeedButton2: TSpeedButton
      Left = 280
      Top = 5
      Width = 81
      Height = 22
      Caption = #26700#38754
      OnClick = SpeedButton2Click
    end
    object DriveComboBox1: TDriveComboBox
      Left = 6
      Top = 4
      Width = 147
      Height = 22
      DirList = DirectoryListBox1
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = #23435#20307
      Font.Style = []
      ImeName = #20013#25991'('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      ParentFont = False
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 321
    Width = 584
    Height = 41
    Align = alBottom
    Color = clInactiveCaption
    TabOrder = 2
    object Label1: TLabel
      Left = 16
      Top = 16
      Width = 297
      Height = 13
      AutoSize = False
    end
    object Button1: TButton
      Left = 440
      Top = 8
      Width = 125
      Height = 25
      Caption = #23548#20837#31572#26696'(&I)'
      Default = True
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 328
      Top = 8
      Width = 89
      Height = 25
      Caption = #21462#28040'(&C)'
      TabOrder = 1
      OnClick = Button2Click
    end
  end
end
