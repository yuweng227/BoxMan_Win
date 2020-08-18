object EditorInfForm_: TEditorInfForm_
  Left = 355
  Top = 80
  BorderStyle = bsDialog
  Caption = #20851#21345#36164#26009
  ClientHeight = 415
  ClientWidth = 612
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = #24494#36719#38597#40657
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 20
  object Label1: TLabel
    Left = 24
    Top = 16
    Width = 45
    Height = 20
    Caption = #26631#39064#65306
  end
  object Label2: TLabel
    Left = 24
    Top = 56
    Width = 45
    Height = 20
    Caption = #20316#32773#65306
  end
  object Label3: TLabel
    Left = 24
    Top = 96
    Width = 45
    Height = 20
    Caption = #35828#26126#65306
  end
  object Edit1: TEdit
    Left = 88
    Top = 16
    Width = 497
    Height = 28
    ImeName = #20013#25991'('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
    TabOrder = 0
    OnChange = Edit1Change
  end
  object Edit2: TEdit
    Left = 88
    Top = 56
    Width = 497
    Height = 28
    ImeName = #20013#25991'('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
    TabOrder = 1
    OnChange = Edit1Change
  end
  object Memo1: TMemo
    Left = 24
    Top = 128
    Width = 569
    Height = 233
    ImeName = #20013#25991'('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
    TabOrder = 2
    OnChange = Edit1Change
  end
  object Button1: TButton
    Left = 480
    Top = 376
    Width = 91
    Height = 25
    Caption = #30830#23450'(&O)'
    ModalResult = 1
    TabOrder = 3
  end
  object Button2: TButton
    Left = 360
    Top = 376
    Width = 91
    Height = 25
    Caption = #21462#28040'(&C)'
    ModalResult = 2
    TabOrder = 4
    OnClick = Button2Click
  end
end
