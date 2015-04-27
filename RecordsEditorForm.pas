unit RecordsEditorForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  FireDAC.Comp.Client, Vcl.DBGrids,
  Data.DB, Bde.DBTables;

type
  TSpecialEdit = class(TEdit)
  public
    FieldNumber: Integer;
  end;

type
  TFieldEditor = record
    EditorEdit: TSpecialEdit;
    EditorLabel: TLabel;
    EditorComboBox: TComboBox;
  end;

type
  TEditorForm = class(TForm)
    procedure FormShow(Sender: TObject);
  private
    FieldEditorsArray: array of TFieldEditor;
    CommitButton: TBitBtn;
    RollbackButton: TBitBtn;
  public
    RecordFields: array of String;
    NativeValues: array of String;
    MainTableIDs: array of Integer;
    Kind: Boolean;
    procedure CommitButtonClick(Sender: TObject);
    function CheckExistense(Query: TFDQuery; DataSource: TDataSource): Boolean;
    procedure ShowReferenceEditor(Sender: TObject);
    function GetId(Tag: Integer; Index: Integer; Text: String): Integer;
  end;

var
  EditorForm: TEditorForm;

implementation

{$R *.dfm}

uses MetaData, ConnectionForm, SQLGenerator, ReferenceEditorForm;

function TEditorForm.CheckExistense(Query: TFDQuery;
  DataSource: TDataSource): Boolean;
var
  i: Integer;
  SQLText: String;
begin
  Result := true;
  for i := 1 to High(TablesMetaData.Tables[Self.Tag].TableFields) do
    if TablesMetaData.Tables[Self.Tag].TableFields[i].References <> Nil then
    begin
      begin
        Query.SQL.Text := Query.SQL.Text + GetJoinWhere(Query.Params.Count,
          Self.Tag, TablesMetaData.Tables[Self.Tag].TableFields[i]
          .References.Table + '.' + TablesMetaData.Tables[Self.Tag].TableFields
          [i].References.Name + ' = ', '');
        Query.Params[Query.Params.Count - 1].Value := RecordFields[i - 1];
      end;
      Query.Active := true;
      if DataSource.DataSet.FieldByName(TablesMetaData.Tables[Self.Tag]
        .TableFields[i].References.Name).AsString = '' then
        Result := false;
    end
    else
    begin
      Query.SQL.Text := GetSelectJoinWhere(0, Self.Tag,
        TablesMetaData.Tables[Self.Tag].TableName + '.' + TablesMetaData.Tables
        [Self.Tag].TableFields[i].FieldName + ' = ', '');
      Query.Params[Query.Params.Count - 1].Value := RecordFields[i - 1];
      Query.Active := true;
      if DataSource.DataSet.FieldByName(TablesMetaData.Tables[Self.Tag]
        .TableFields[i].FieldName).AsString = '' then
        Result := false;
    end;
end;

procedure TEditorForm.CommitButtonClick(Sender: TObject);
var
  Query: TFDQuery;
  DataSource: TDataSource;
  i, j: Integer;
  MaxID, ID: Integer;
  DBGrid: TDBGrid;
  Exists: Boolean;
begin
  SetLength(RecordFields, 0);
  Exists := true;
  for i := 0 to High(Self.FieldEditorsArray) do
  begin
    SetLength(RecordFields, Length(RecordFields) + 1);
    if FieldEditorsArray[i].EditorEdit.Text = '' then
      RecordFields[High(RecordFields)] := FieldEditorsArray[i]
        .EditorComboBox.Text
    else
      RecordFields[High(RecordFields)] := FieldEditorsArray[i].EditorEdit.Text;
  end;
  Query := TFDQuery.Create(Self);
  Query.Connection := ConnectionFormWindow.MainConnection;
  DataSource := TDataSource.Create(Self);
  DataSource.DataSet := Query;
  DBGrid := TDBGrid.Create(Self);
  DBGrid.DataSource := DataSource;
  Query.Active := false;
  Query.SQL.Text := 'SELECT Max(ID) FROM ' + TablesMetaData.Tables
    [(Sender as TBitBtn).Tag].TableName;
  Query.Active := true;
  MaxID := DBGrid.Fields[0].Value;
  Query.Active := false;
  Query.SQL.Text := SetGenerator(MaxID);
  Query.ExecSQL;
  Query.Active := false;
  Query.SQL.Text := '';
  Exists := CheckExistense(Query, DataSource);
  { if Exists then
    ShowMessage('Данная запись уже существует')
    else
    case (Sender as TBitBtn).Kind of
    bkOk:
    begin
    Query.SQL.Text := GetInsert(Tag, i, High(RecordFields));
    Query.Params[0].Value := RecordFields[i - 1];
    Query.ExecSQL;
    end
    else
    begin
    SetLength(MainTableIDs, Length(MainTableIDs) + 1);
    MainTableIDs[High(MainTableIDs)] := DataSource.DataSet.FieldByName
    ('ID').AsInteger;
    end;
    end;
    bkYes:
    if not Exists then
    begin
    Query.Active := false;
    Query.SQL.Text := GetInsert(Tag, i, High(RecordFields));
    Query.Params[0].Value := RecordFields[i - 1];
    Query.ExecSQL;
    end;
    end; }
  // else
  begin
    Exists := CheckExistense(Query, DataSource);
    // if not Exists then
    case (Sender as TBitBtn).Kind of
      bkOk:
        begin
          if not Exists then
          begin
            Query.Active := false;
            Query.SQL.Text := GetInsert((Sender as TBitBtn).Tag, i,
              High(RecordFields));
            for j := 0 to Query.Params.Count - 1 do
              if Length(MainTableIDs) = 0 then
                Query.Params[j].Value := RecordFields[j]
              else
                Query.Params[j].Value := MainTableIDs[j];
            if i = High(TablesMetaData.Tables[(Sender as TBitBtn).Tag]
              .TableFields) then
              Query.ExecSQL;
          end
          else
          begin
            ShowMessage('Такая запись уже существует!');
            if Length(MainTableIDs) = 0 then
            begin
              SetLength(Self.MainTableIDs, Length(Self.MainTableIDs) + 1);
              MainTableIDs[High(MainTableIDs)] := DataSource.DataSet.FieldByName
                ('ID').AsInteger;
            end;
          end;
        end;
      bkYes:
        begin
          if not Exists then
          begin
            Query.Active := false;
            Query.SQL.Text := '';
            for i := 1 to High(TablesMetaData.Tables[Self.Tag].TableFields) do
            begin
              if Length(MainTableIDs) = 0 then
              Query.SQL.Text := GetSelectJoinWhere(Query.Params.Count, Self.Tag,
                TablesMetaData.Tables[Self.Tag].TableName + '.' +
                TablesMetaData.Tables[Self.Tag].TableFields[i].FieldName +
                ' = ', Query.SQL.Text)
                else
               Query.SQL.Text := GetSelectJoinWhere(Query.Params.Count, Self.Tag,
                TablesMetaData.Tables[Self.Tag].TableFields[i].References.Table + '.' +
                TablesMetaData.Tables[Self.Tag].TableFields[i].References.Name +
                ' = ', Query.SQL.Text);
              Query.Params[Query.Params.Count - 1].Value := NativeValues[i - 1]
            end;
            Query.Active := true;
            ID := DBGrid.Fields[0].Value;
            Query.Active := false;
            for j := 0 to High(TablesMetaData.Tables[Tag].TableFields) - 1 do
            begin
              Query.SQL.Text := GetUpdate((Sender as TBitBtn).Tag, j);
              if Length(MainTableIDs) = 0 then
                Query.Params[Query.Params.Count - 1].Value := RecordFields[j]
              else
                Query.Params[Query.Params.Count - 1].Value := MainTableIDs[j];
            end;
            Query.SQL.Text := Query.SQL.Text +
              GetUpdate((Sender as TBitBtn).Tag, j);
            Query.Params[Query.Params.Count - 1].Value := ID;
            Query.ExecSQL;
          end
          else
            ShowMessage('Такая запись уже существует!');
        end;
    end;
  end;
  { if Length(MainTableIDs) <> 0 then
    begin
    Query.Active := false;
    Query.SQL.Text := 'INSERT INTO ' + TablesMetaData.Tables[Self.Tag].TableName
    + '(' + TablesMetaData.Tables[Self.Tag].TableFields[0].FieldName;
    for i := 1 to High(TablesMetaData.Tables[Self.Tag].TableFields) do
    Query.SQL.Text := Query.SQL.Text + ', ' + TablesMetaData.Tables[Self.Tag]
    .TableFields[i].FieldName;
    Query.SQL.Text := Query.SQL.Text + ') VALUES ( GEN_ID(GenNewID, 1)';
    for i := 0 to High(MainTableIDs) do
    Query.SQL.Text := Query.SQL.Text + ', :' + IntToStr(i);
    Query.SQL.Text := Query.SQL.Text + ');';
    for i := 0 to Query.Params.Count - 1 do
    Query.Params[i].Value := MainTableIDs[i];
    Query.ExecSQL;
    end; }
  Self.Close;
end;

procedure TEditorForm.FormShow(Sender: TObject);
var
  i, j, k: Integer;
  CurTop: Integer;
  ItemList: TStringList;
begin
  CurTop := 0;
  for i := 0 to High(TablesMetaData.Tables[(Sender as TForm).Tag]
    .TableFields) - 1 do
  begin
    SetLength(FieldEditorsArray, Length(FieldEditorsArray) + 1);
    FieldEditorsArray[High(FieldEditorsArray)].EditorLabel :=
      TLabel.Create(Self);
    with FieldEditorsArray[High(FieldEditorsArray)].EditorLabel do
    begin
      Parent := Self;
      Top := CurTop + Height + 10;
      Left := 10;
      Anchors := [akTop, akLeft];
      if TablesMetaData.Tables[(Sender as TForm).Tag].TableFields[i + 1]
        .References = Nil then
        Caption := TablesMetaData.Tables[(Sender as TForm).Tag].TableFields
          [i + 1].FieldCaption
      else
        Caption := TablesMetaData.Tables[(Sender as TForm).Tag].TableFields
          [i + 1].References.Caption;
    end;
    if TablesMetaData.Tables[(Sender as TForm).Tag].TableFields[1].References <> nil
    then
    begin
      FieldEditorsArray[High(FieldEditorsArray)].EditorEdit :=
        TSpecialEdit.Create(Self);
      FieldEditorsArray[High(FieldEditorsArray)].EditorEdit.Tag :=
        TablesMetaData.Tables[(Sender as TForm).Tag].TableFields[i + 1]
        .References.TableTag;
      with FieldEditorsArray[High(FieldEditorsArray)].EditorEdit do
      begin
        Parent := Self;
        Top := FieldEditorsArray[High(FieldEditorsArray)].EditorLabel.Top;
        Left := 120;
        Width := Self.Width - Width - 30;
        Anchors := [akTop, akLeft, akRight];
        CurTop := Top;
        FieldNumber := i;
        if Length(NativeValues) <> 0 then
          Text := NativeValues[i];
        ReadOnly := true;
        OnClick := ShowReferenceEditor;
      end;
      SetLength(Self.MainTableIDs, Length(Self.MainTableIDs) + 1);
      MainTableIDs[i] := GetId(TablesMetaData.Tables[(Sender as TForm).Tag]
        .TableFields[i + 1].References.TableTag, 1,
        FieldEditorsArray[High(FieldEditorsArray)].EditorEdit.Text);
    end
    else
    begin
      FieldEditorsArray[High(FieldEditorsArray)].EditorComboBox :=
        TComboBox.Create(Self);
      with FieldEditorsArray[High(FieldEditorsArray)].EditorComboBox do
      begin
        Parent := Self;
        Top := FieldEditorsArray[High(FieldEditorsArray)].EditorLabel.Top;
        Left := 120;
        Width := Self.Width - Width - 30;
        Anchors := [akTop, akLeft, akRight];
        CurTop := Top;
        Tag := i;
        Items.Add('');
        ItemList := TablesMetaData.Tables[(Sender as TForm).Tag].GetDataList(1);
        for j := 0 to ItemList.Count - 1 do
          Items.Add(ItemList[j]);
        if Length(NativeValues) <> 0 then
          for k := 0 to Items.Count - 1 do
            if Items[k] = NativeValues[i] then
              ItemIndex := k;
      end;
      break;
    end;
  end;
  RollbackButton := TBitBtn.Create(Self);
  with RollbackButton do
  begin
    Parent := Self;
    Left := 10;
    Width := Round(Self.Width / 2) - 30;
    Top := CurTop + 30;
    Kind := bkCancel;
    Caption := 'Отменить';
  end;
  CommitButton := TBitBtn.Create(Self);
  with CommitButton do
  begin
    Parent := Self;
    Width := RollbackButton.Width;
    Left := RollbackButton.Left + RollbackButton.Width + 20;
    Top := RollbackButton.Top;
    if Self.Kind then
      Kind := bkOk
    else
      Kind := bkYes;
    Caption := 'Применить';
    OnClick := CommitButtonClick;
    Tag := Self.Tag;
  end;
  Self.Height := RollbackButton.Top + RollbackButton.Height * 3;
end;

function TEditorForm.GetId(Tag: Integer; Index: Integer; Text: String): Integer;
var
  Query: TFDQuery;
  DataSource: TDataSource;
  Grid: TDBGrid;
begin
  Query := TFDQuery.Create(Self);
  Query.Connection := ConnectionFormWindow.MainConnection;
  DataSource := TDataSource.Create(Self);
  DataSource.DataSet := Query;
  Grid := TDBGrid.Create(Self);
  Grid.DataSource := DataSource;
  Query.Active := false;
  Query.SQL.Text := 'SELECT * FROM ' + TablesMetaData.Tables[Tag].TableName +
    ' WHERE ' + TablesMetaData.Tables[Tag].TableFields[Index].FieldName
    + ' = :0';
  Query.Params[0].Value := Text;
  Query.Active := true;
  Result := Grid.Fields[0].AsInteger;
end;

procedure TEditorForm.ShowReferenceEditor(Sender: TObject);
var
  Form: TEditorForm;
  i, j: Integer;
  Test: Integer;
  TransQuery: TFDQuery;
  TransSource: TDataSource;
begin
  Form := TEditorForm.Create(Application);
  Form.Tag := (Sender as TEdit).Tag;
  Form.Kind := true;
  SetLength(Form.NativeValues, Length(Form.NativeValues) + 1);
  Form.NativeValues[High(Form.NativeValues)] := (Sender as TEdit).Text;
  Form.ShowModal;
  Self.MainTableIDs[(Sender as TSpecialEdit).FieldNumber] :=
    Form.MainTableIDs[0];
  (Sender as TEdit).Text := Form.FieldEditorsArray[0].EditorComboBox.Text;
end;

end.
