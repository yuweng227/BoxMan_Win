object Msg: TMsg
  Left = 192
  Top = 130
  BorderStyle = bsNone
  Caption = 'Msg'
  ClientHeight = 42
  ClientWidth = 237
  Color = clYellow
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 237
    Height = 42
    Align = alClient
    BevelOuter = bvNone
    Caption = #19981#21512#26684#30340#20851#21345
    Color = clYellow
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = #23435#20307
    Font.Style = [fsBold]
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 0
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 500
    OnTimer = Timer1Timer
    Left = 200
    Top = 8
  end
end
