object DirForm: TDirForm
  Left = 0
  Top = 0
  Caption = 'DirForm'
  ClientHeight = 407
  ClientWidth = 493
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnPaint = FormPaint
  OnShow = FormShow
  DesignSize = (
    493
    407)
  PixelsPerInch = 96
  TextHeight = 13
  object DBNavigator1: TDBNavigator
    Left = 8
    Top = 8
    Width = 480
    Height = 25
    DataSource = DirDataSource
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object DBGrid1: TDBGrid
    Left = 8
    Top = 39
    Width = 477
    Height = 298
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = DirDataSource
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnCellClick = DBGrid1CellClick
    OnDblClick = DBGrid1DblClick
    OnTitleClick = DBGrid1TitleClick
  end
  object FiltersPageControl: TPageControl
    Left = 5
    Top = 8
    Width = 480
    Height = 81
    TabOrder = 2
    Visible = False
  end
  object Panel1: TPanel
    Left = 8
    Top = 343
    Width = 477
    Height = 60
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 3
    DesignSize = (
      477
      60)
    object EditRecordButton: TButton
      Left = 16
      Top = 16
      Width = 123
      Height = 25
      Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100
      TabOrder = 0
      Visible = False
      OnClick = EditRecordButtonClick
    end
    object DeleteRecordButton: TButton
      Left = 145
      Top = 16
      Width = 123
      Height = 25
      Caption = #1059#1076#1072#1083#1080#1090#1100
      TabOrder = 1
      Visible = False
      OnClick = DeleteRecordButtonClick
    end
    object AddRecordButton: TButton
      Left = 336
      Top = 16
      Width = 123
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 2
      OnClick = AddRecordButtonClick
    end
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
    object FiltersMenuButton: TMenuItem
      Caption = #1060#1080#1083#1100#1090#1088#1099
      object AddFilter: TMenuItem
        Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1092#1080#1083#1100#1090#1088
        ShortCut = 49222
        OnClick = AddFilterClick
      end
      object AcceptAll: TMenuItem
        Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100' '#1074#1089#1077
        ShortCut = 49217
        OnClick = AcceptAllClick
      end
      object DeclineAll: TMenuItem
        Caption = #1054#1090#1084#1077#1085#1080#1090#1100' '#1074#1089#1077
        ShortCut = 49221
        OnClick = DeclineAllClick
      end
      object DeleteAll: TMenuItem
        Caption = #1059#1076#1072#1083#1080#1090#1100' '#1074#1089#1077
        ShortCut = 49220
        OnClick = DeleteAllClick
      end
    end
  end
end
