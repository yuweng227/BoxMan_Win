object LoadSkinForm: TLoadSkinForm
  Left = 251
  Top = 187
  BorderStyle = bsDialog
  Caption = #26356#25442#30382#32932
  ClientHeight = 356
  ClientWidth = 617
  Color = clGradientActiveCaption
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 248
    Top = 24
    Width = 360
    Height = 180
  end
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 65
    Height = 13
    Caption = #30382#32932#21015#34920#65306
  end
  object Label2: TLabel
    Left = 248
    Top = 8
    Width = 39
    Height = 13
    Caption = #39044#35272#65306
  end
  object Label3: TLabel
    Left = 248
    Top = 216
    Width = 361
    Height = 65
    AutoSize = False
    Caption = 
      #35828#26126#65306#30382#32932#21253#21547'8'#26684#20803#26684#65292#20998#19978#19979#20004#34892#65292#27599#34892'4'#26684#65292#20998#21035#20026#65306#22320#26495#12289#20154#12289#31665#23376#12289#22681#22721#21450#30446#26631#28857#12289#20154#22312#30446#26631#28857#12289#31665#23376#22312#30446#26631#28857#12289#22681#22721#25193#23637#12290#20854#20013#22681#22721 +
      #25193#23637#26159#20026#26080#32541#22681#22721#20934#22791#30340#65292#21542#21017#65292#19982#19978#26684#30456#21516#21363#21487#12290#20803#26684#23610#23544#38656#22312#65288'20-200'#65289#20687#32032#20043#38388#12290#22320#26495#26684#24038#19978#35282#20687#32032#30340#39068#33394#20316#20026#32593#26684#32447#30340#39068#33394#12290
    WordWrap = True
  end
  object Label4: TLabel
    Left = 248
    Top = 288
    Width = 8
    Height = 13
    Caption = ' '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Button1: TButton
    Left = 376
    Top = 312
    Width = 75
    Height = 33
    Caption = #21462#28040'(&C)'
    Default = True
    ModalResult = 2
    TabOrder = 0
  end
  object Button2: TButton
    Left = 528
    Top = 312
    Width = 75
    Height = 33
    Caption = #30830#23450'(&O)'
    ModalResult = 1
    TabOrder = 1
  end
  object ListBox1: TListBox
    Left = 0
    Top = 24
    Width = 241
    Height = 329
    Color = clHighlightText
    ImeName = #20013#25991'('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
    ItemHeight = 13
    TabOrder = 2
    OnClick = ListBox1Click
    OnDblClick = ListBox1DblClick
  end
end
