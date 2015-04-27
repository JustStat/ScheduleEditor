unit ReferenceEditorForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons;

type
  TReferenceEditorWindow = class(TForm)
    CaptionLabel: TLabel;
    CancelButton: TBitBtn;
    ApplyButton: TBitBtn;
    EditorComboBox: TComboBox;
    procedure ApplyButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ReferenceEditorWindow: TReferenceEditorWindow;

implementation

{$R *.dfm}

uses ConnectionForm;

procedure TReferenceEditorWindow.ApplyButtonClick(Sender: TObject);
begin
{SetLength(RecordFields, 0);
  Exists := true;
  for i := 0 to High(Self.FieldEditorsArray) do
  begin
    SetLength(RecordFields, Length(RecordFields) + 1);
    RecordFields[High(RecordFields)] := FieldEditorsArray[i]
      .EditorEdit.Text;
  end;
  Query := TFDQuery.Create(Self);
  Query.Connection := ConnectionFormWindow.MainConnection;
  DataSource := TDataSource.Create(Self);
  DataSource.DataSet := Query;
  DBGrid := TDBGrid.Create(Self);
  DBGrid.DataSource := DataSource;
  Query.Active := false;
  Query.SQL.Text := 'SELECT Max(ID) FROM ' + TablesMetaData.Tables[Tag]
    .TableName;
  Query.Active := true;
  MaxID := DBGrid.Fields[0].Value;
  Query.Active := false;
  Query.SQL.Text := SetGenerator(MaxID);
  Query.ExecSQL;
  Query.Active := false;
  Query.SQL.Text := '';
  Exists := CheckExistense(Query, DataSource); }
end;

end.
