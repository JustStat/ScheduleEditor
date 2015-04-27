object ConnectionFormWindow: TConnectionFormWindow
  Left = 0
  Top = 0
  Caption = 'ConnectionFormWindow'
  ClientHeight = 213
  ClientWidth = 420
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object MainConnection: TFDConnection
    Params.Strings = (
      'User_Name=sysdba'
      'Password=masterkey'
      'Database=C:\schedule_rus_edition.fdb'
      'CharacterSet=UTF8'
      'DriverID=FB')
    LoginPrompt = False
    Left = 208
    Top = 24
  end
  object MainTransaction: TFDTransaction
    Connection = MainConnection
    Left = 288
    Top = 24
  end
end
