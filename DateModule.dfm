object DataModule1: TDataModule1
  OldCreateOrder = False
  Left = 440
  Top = 121
  Height = 227
  Width = 381
  object ADOConnection1: TADOConnection
    ConnectionString = 
      'Provider=Microsoft.Jet.OLEDB.4.0;User ID=Admin;Data Source=BoxMa' +
      'n.dat;Mode=Share Deny None;Persist Security Info=False;Jet OLEDB' +
      ':System database="";Jet OLEDB:Registry Path="";Jet OLEDB:Databas' +
      'e Password=boxman2019;Jet OLEDB:Engine Type=5;Jet OLEDB:Database' +
      ' Locking Mode=0;Jet OLEDB:Global Partial Bulk Ops=2;Jet OLEDB:Gl' +
      'obal Bulk Transactions=1;Jet OLEDB:New Database Password="";Jet ' +
      'OLEDB:Create System Database=False;Jet OLEDB:Encrypt Database=Fa' +
      'lse;Jet OLEDB:Don'#39't Copy Locale on Compact=False;Jet OLEDB:Compa' +
      'ct Without Replica Repair=False;Jet OLEDB:SFP=False'
    Provider = 'Microsoft.Jet.OLEDB.4.0'
    Left = 71
    Top = 9
  end
  object ADOQuery1: TADOQuery
    Connection = ADOConnection1
    Parameters = <>
    Left = 135
    Top = 9
  end
  object DataSource1: TDataSource
    DataSet = ADOQuery1
    Left = 23
    Top = 9
  end
end
