object ReferenceEditorWindow: TReferenceEditorWindow
  Left = 0
  Top = 0
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1079#1072#1087#1080#1089#1080
  ClientHeight = 110
  ClientWidth = 354
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object CaptionLabel: TLabel
    Left = 24
    Top = 32
    Width = 62
    Height = 13
    Caption = 'CaptionLabel'
  end
  object CancelButton: TBitBtn
    Left = 24
    Top = 64
    Width = 129
    Height = 25
    Caption = 'CancelButton'
    TabOrder = 0
  end
  object ApplyButton: TBitBtn
    Left = 186
    Top = 64
    Width = 145
    Height = 25
    Caption = 'BitBtn1'
    TabOrder = 1
    OnClick = ApplyButtonClick
  end
  object EditorComboBox: TComboBox
    Left = 186
    Top = 29
    Width = 145
    Height = 21
    TabOrder = 2
  end
end
