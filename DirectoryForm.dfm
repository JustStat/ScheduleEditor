object DirForm: TDirForm
  Left = 0
  Top = 0
  Caption = 'DirForm'
  ClientHeight = 450
  ClientWidth = 452
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    452
    450)
  PixelsPerInch = 96
  TextHeight = 13
  object DBNavigator1: TDBNavigator
    Left = 0
    Top = 79
    Width = 450
    Height = 25
    DataSource = DirDataSource
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 103
    Width = 450
    Height = 346
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = DirDataSource
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnTitleClick = DBGrid1TitleClick
  end
  object FilterPageControl: TPageControl
    Left = 0
    Top = 0
    Width = 450
    Height = 81
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
  end
  object DirQuery: TFDQuery
    Connection = ConnectionFormWindow.MainConnection
    Left = 208
    Top = 104
  end
  object DirDataSource: TDataSource
    DataSet = DirQuery
    Left = 256
    Top = 104
  end
  object MainMenu1: TMainMenu
    Left = 224
    Top = 232
    object N1: TMenuItem
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1092#1080#1083#1100#1090#1088
      OnClick = N1Click
    end
  end
end
