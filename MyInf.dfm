object MyInfForm: TMyInfForm
  Left = 772
  Top = 165
  BorderStyle = bsDialog
  Caption = #25552#31034
  ClientHeight = 75
  ClientWidth = 232
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClick = Timer1Timer
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 232
    Height = 75
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 0
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 24
    Top = 8
  end
end
