unit MetaData;

interface

uses
  System.Classes, FireDAC.Comp.Client, Data.DB;

type
  TReference = class
    Table: String;
    TableTag: Integer;
    Field: String;
    Name: String;
    Caption: String;
    Width: Integer;
  end;

type
  TSort = (None, Up, Down);

type
  TField = class
    FieldName: String;
    FieldCaption: String;
    FieldWidth: Integer;
    References: TReference;
    FieldVisible: Boolean;
    Sorted: TSort;
    procedure AddReferense(ARefTable: String = ''; ARefField: String = '';
      ARefName: String = ''; ARefCaption: String = ''; ARefWidth: Integer = 0;
      ARefTableTag: Integer = -1);
  end;

type
  TTable = class
    TableName: String;
    TableCaption: String;
    TableFields: array of TField;
    function GetFieldsCount(ATag: Integer): Integer;
    function AddField(AFieldName, AFieldCaption: String; AFieldWidth: Integer;
      AFieldVisible: Boolean; ASorted: TSort = None): TField;
    function GetDataList(Index: Integer): TStringList;
  end;

type
  TMData = class
  public
    Tables: array of TTable;
    function GetTablesCount: Integer;
    property TablesCount: Integer read GetTablesCount;
    function AddTable(ATableName, ATableCaption: string): TTable;
  end;

var
  TablesMetaData: TMData;

implementation

{ TMData }

uses SQLGenerator, ConnectionForm;

function TTable.AddField(AFieldName, AFieldCaption: String;
  AFieldWidth: Integer; AFieldVisible: Boolean; ASorted: TSort = None): TField;
begin
  SetLength(TableFields, Length(TableFields) + 1);
  TableFields[high(TableFields)] := TField.Create;
  with TableFields[High(TableFields)] do
  begin
    FieldName := AFieldName;
    FieldCaption := AFieldCaption;
    FieldWidth := AFieldWidth;
    FieldVisible := AFieldVisible;
    Sorted := ASorted;
  end;
  Result := TableFields[high(TableFields)];
end;

function TMData.AddTable(ATableName, ATableCaption: string): TTable;
begin
  SetLength(Tables, Length(Tables) + 1);
  Tables[High(Tables)] := TTable.Create;
  with Tables[High(Tables)] do
  begin
    TableName := ATableName;
    TableCaption := ATableCaption;
  end;
  Result := Tables[High(Tables)];
end;

function TMData.GetTablesCount: Integer;
begin
  Result := Length(TablesMetaData.Tables);
end;

{ TTable }

function TTable.GetDataList(Index: Integer): TStringList;
var
  Query: TFDQuery;
  DataSource: TDataSource;
begin
  Result := TStringList.Create;
  Query := TFDQuery.Create(Nil);
  Query.Connection := ConnectionFormWindow.MainConnection;
  DataSource := TDataSource.Create(Nil);
  DataSource.DataSet := Query;
  Query.Active := false;
  if Self.TableFields[Index].References = Nil then
    Query.SQL.Text := 'SELECT ' + Self.TableFields[Index].FieldName + ' FROM ' +
      Self.TableName
  else
    Query.SQL.Text := 'SELECT ' + Self.TableFields[Index].References.Name +
      ' FROM ' + Self.TableFields[Index].References.Table;
  Query.Active := true;
  while not Query.Eof do
  begin
    Result.Append(String(Query.Fields.Fields[0].Value));
    Query.Next;
  end;
end;

function TTable.GetFieldsCount(ATag: Integer): Integer;
begin
  Result := Length(TablesMetaData.Tables[ATag].TableFields)
end;

{ TField }

procedure TField.AddReferense(ARefTable: String = ''; ARefField: String = '';
      ARefName: String = ''; ARefCaption: String = ''; ARefWidth: Integer = 0;
      ARefTableTag: Integer = -1);
begin
  References := TReference.Create;
  References.Table := ARefTable;
  References.Field := ARefField;
  References.Name := ARefName;
  References.Caption := ARefCaption;
  References.Width := ARefWidth;
  References.TableTag := ARefTableTag;
end;

initialization

TablesMetaData := TMData.Create;

with TablesMetaData do
begin
  with AddTable('AUDITORIES', 'Аудитории') do
  begin
    AddField('ID', 'ID', 50, false);
    AddField('AUD_CAPTION', 'Номер', 100, true);
  end;
  with AddTable('DISCIPLINES', 'Дисциплины') do
  begin
    AddField('ID', 'ID', 50, false);
    AddField('DIS_CAPTION', 'Дисциплина', 200, true);
  end;
  with AddTable('DISCIPLINE_PROFESSOR', 'Преподаватели - Дисциплины') do
  begin
    AddField('ID', 'ID', 50, false);
    AddField('PROF_ID', 'ID Преподавателя', 100, false)
      .AddReferense('PROFESSORS', 'ID', 'PROF_NAME',
      'ФИО Перподавателя', 200, 5);
    AddField('DIS_ID', 'ID Дисциплины', 100, false).AddReferense('DISCIPLINES',
      'ID', 'DIS_CAPTION', 'Дисциплина', 200, 1);
  end;
  with AddTable('GROUP_DISCIPLINE', 'Группы - Дисциплины') do
  begin
    AddField('ID', 'ID', 50, false);
    AddField('GROUP_ID', 'ID Группы', 100, false).AddReferense('GROUPS', 'ID',
      'GROUP_NUMBER', 'Группа', 100, 9);
    AddField('DISCIPLINE_ID', 'ID Дисциплины', 100, false)
      .AddReferense('DISCIPLINES', 'ID', 'DIS_CAPTION', 'Дисциплина', 200, 1);
  end;

  with AddTable('LESSON_TYPES', 'Типы Занятий') do
  begin
    AddField('ID', 'ID', 50, false);
    AddField('LES_TYPE_CAPTION', 'Тип занятия', 200, true);
  end;

  with AddTable('PROFESSORS', 'Преподаватели') do
  begin
    AddField('ID', 'ID', 50, false);
    AddField('PROF_NAME', 'ФИО', 200, true);
  end;

  with AddTable('SCHEDULE', 'Расписание') do
  begin
    AddField('ID', 'ID', 50, false);
    AddField('GROUP_ID', 'ID Группы', 100, false).AddReferense('GROUPS', 'ID',
      'GROUP_NUMBER', 'Группа', 100, 9);
    AddField('LES_TYPE_ID', 'ID Типа Занятия', 100, false)
      .AddReferense('LESSON_TYPES', 'ID', 'LES_TYPE_CAPTION',
      'Тип Занятия', 200, 4);
    AddField('DIS_ID', 'ID Дисциплины', 100, false).AddReferense('DISCIPLINES',
      'ID', 'DIS_CAPTION', 'Дисциплина', 200, 1);
    AddField('TIME_ID', 'ID Пары', 100, false).AddReferense('TIMES', 'ID',
      'TIME_CAPTION', 'Время', 100, 7);
    AddField('AUD_ID', 'ID Аудитории', 100, false).AddReferense('AUDITORIES',
      'ID', 'AUD_CAPTION', 'Аудитория', 100, 0);
    AddField('PROF_ID', 'ID Преподавателя', 100, false)
      .AddReferense('PROFESSORS', 'ID', 'PROF_NAME', 'ФИО Преподавателя', 200, 5);
    AddField('WEEKDAY_ID', 'ID Дня', 100, false).AddReferense('WEEKDAYS', 'ID',
      'WEEKDAY_CAPTION', 'День Недели', 100, 8);
  end;
  with AddTable('TIMES', 'Время') do
  begin
    AddField('ID', 'ID', 50, false);
    AddField('TIME_CAPTION', 'Пара', 100, true);
    AddField('TIME_START_TIME', 'Начало Пары', 100, true);
    AddField('TIME_END_TIME', 'Конец Пары', 100, true);
  end;
  with AddTable('WEEKDAYS', 'Дни Недели') do
  begin
    AddField('ID', 'ID', 50, false);
    AddField('WEEKDAY_CAPTION', 'День', 100, true);
    AddField('WEEKDAY_NUMBER', 'Номер', 50, true);
  end;
  with AddTable('GROUPS', 'Группы') do
  begin
    AddField('ID', 'ID', 50, false);
    AddField('GROUP_NUMBER', 'Номер', 100, true);
    //AddField('GROUP_NAME', 'Название', 200, true);
  end;
end;

end.
