object ActionForm: TActionForm
  Left = 249
  Top = 184
  BorderStyle = bsDialog
  Caption = #21160#20316#32534#36753
  ClientHeight = 514
  ClientWidth = 751
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 267
    Top = 425
    Width = 60
    Height = 13
    Caption = #37325#22797#27425#25968#65306
  end
  object Label2: TLabel
    Left = 584
    Top = 424
    Width = 36
    Height = 13
    Caption = #21152#36733#65306
  end
  object Label3: TLabel
    Left = 424
    Top = 424
    Width = 36
    Height = 13
    Caption = #23384#20837#65306
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 751
    Height = 401
    Align = alTop
    BevelOuter = bvSpace
    TabOrder = 0
    object MemoAct: TMemo
      Left = 1
      Top = 1
      Width = 749
      Height = 399
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = #26999#20307
      Font.Style = []
      ImeName = #20013#25991'('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      ParentFont = False
      TabOrder = 0
    end
  end
  object Button1: TButton
    Left = 646
    Top = 462
    Width = 81
    Height = 25
    Cursor = crHandPoint
    Caption = #25191#34892'(&R)'
    Default = True
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 528
    Top = 462
    Width = 87
    Height = 25
    Cursor = crHandPoint
    Caption = #21462#28040'(&C)'
    ModalResult = 2
    TabOrder = 2
  end
  object Run_CurPos: TCheckBox
    Left = 144
    Top = 424
    Width = 110
    Height = 17
    Caption = #20174#24403#21069#28857#25191#34892
    Checked = True
    State = cbChecked
    TabOrder = 3
  end
  object Run_CurTru: TCheckBox
    Left = 16
    Top = 424
    Width = 120
    Height = 17
    Caption = #25353#29616#22330#26059#36716#25191#34892
    TabOrder = 4
  end
  object Rep_Times: TSpinEdit
    Left = 332
    Top = 421
    Width = 63
    Height = 22
    AutoSize = False
    MaxLength = 1
    MaxValue = 10000
    MinValue = 1
    TabOrder = 5
    Value = 1
  end
  object Left_Trun: TButton
    Left = 16
    Top = 462
    Width = 97
    Height = 25
    Cursor = crHandPoint
    Caption = #24038#26059'(&L)'
    TabOrder = 6
    OnClick = Left_TrunClick
  end
  object Right_Trun: TButton
    Left = 138
    Top = 462
    Width = 97
    Height = 25
    Cursor = crHandPoint
    Caption = #21491#26059'(&R)'
    TabOrder = 7
    OnClick = Right_TrunClick
  end
  object H_Mirror: TButton
    Left = 261
    Top = 462
    Width = 97
    Height = 25
    Cursor = crHandPoint
    Caption = #24038#21491#32763#36716'(&H)'
    TabOrder = 8
    OnClick = H_MirrorClick
  end
  object V_Mirror: TButton
    Left = 384
    Top = 462
    Width = 97
    Height = 25
    Cursor = crHandPoint
    Caption = #19978#19979#32763#36716'(&H)'
    TabOrder = 9
    OnClick = V_MirrorClick
  end
  object LoadBox: TComboBox
    Left = 624
    Top = 420
    Width = 105
    Height = 22
    Style = csOwnerDrawFixed
    DropDownCount = 9
    ImeName = #20013#25991'('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
    ItemHeight = 16
    TabOrder = 10
    OnSelect = LoadBoxSelect
    Items.Strings = (
      #21098#20999#26495
      #24050#20570#21160#20316
      #21518#32493#21160#20316
      #23492#23384#22120' 1'
      #23492#23384#22120' 2'
      #23492#23384#22120' 3'
      #23492#23384#22120' 4'
      #25991#26723
      #19978#27425#25191#34892#21069#30340#21160#20316)
  end
  object SaveBox: TComboBox
    Left = 464
    Top = 420
    Width = 105
    Height = 22
    Style = csOwnerDrawFixed
    ImeName = #20013#25991'('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
    ItemHeight = 16
    TabOrder = 11
    OnSelect = SaveBoxSelect
    Items.Strings = (
      #21098#20999#26495
      #23492#23384#22120' 1'
      #23492#23384#22120' 2'
      #23492#23384#22120' 3'
      #23492#23384#22120' 4'
      #25991#26723)
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 495
    Width = 751
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
  object SaveDialog1: TSaveDialog
    Filter = #21160#20316#25991#26723'(*.txt)|*.txt'
    Left = 160
    Top = 24
  end
  object OpenDialog1: TOpenDialog
    Left = 120
    Top = 24
  end
end
