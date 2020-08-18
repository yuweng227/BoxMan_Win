object MyOpenFile: TMyOpenFile
  Left = 388
  Top = 117
  BorderStyle = bsDialog
  Caption = #25171#24320#20851#21345#25991#26723
  ClientHeight = 362
  ClientWidth = 584
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object FileListBox1: TFileListBox
    Left = 201
    Top = 0
    Width = 383
    Height = 321
    Align = alClient
    BevelInner = bvNone
    ItemHeight = 18
    Mask = '*.txt;*.xsb'
    TabOrder = 0
    OnDblClick = FileListBox1DblClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 201
    Height = 321
    Align = alLeft
    BevelOuter = bvLowered
    TabOrder = 1
    object Panel3: TPanel
      Left = 1
      Top = 1
      Width = 199
      Height = 33
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object DriveComboBox1: TDriveComboBox
        Left = 6
        Top = 8
        Width = 185
        Height = 19
        DirList = DirectoryListBox1
        TabOrder = 0
      end
    end
    object Panel4: TPanel
      Left = 1
      Top = 34
      Width = 199
      Height = 286
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object DirectoryListBox1: TDirectoryListBox
        Left = 0
        Top = 0
        Width = 199
        Height = 286
        Align = alClient
        FileList = FileListBox1
        ItemHeight = 18
        TabOrder = 0
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 321
    Width = 584
    Height = 41
    Align = alBottom
    Color = clSkyBlue
    TabOrder = 2
    object Button1: TButton
      Left = 458
      Top = 8
      Width = 91
      Height = 25
      Caption = #25171#24320'(&O)'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object Button2: TButton
      Left = 344
      Top = 8
      Width = 77
      Height = 25
      Caption = #21462#28040
      ModalResult = 2
      TabOrder = 1
    end
    object CheckBox1: TCheckBox
      Left = 24
      Top = 12
      Width = 193
      Height = 17
      Caption = #33509#20851#21345#26377#31572#26696#65292#21017#21516#26102#23548#20837
      TabOrder = 2
    end
  end
end
