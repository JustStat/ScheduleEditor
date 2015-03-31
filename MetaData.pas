unit MetaData;

interface

type
  TReference = class
    Table: String;
    Field: String;
    Name: String;
    Caption: String;
    Width: Integer;
    Visible: Boolean;
  end;

type
  TField = class
    FieldName: String;
    FieldCaption: String;
    FieldWidth: Integer;
    References: TReference;
    FieldVisible: Boolean;
    procedure AddReferense(ARefTable: String = ''; ARefField: String = '';
      ARefName: String = ''; ARefCaption: String = ''; ARefWidth: Integer = 0;
      ARefVisible: Boolean = False);
  end;

type
  TTable = class
    TableName: String;
    TableCaption: String;
    TableFields: array of TField;
    function GetFieldsCount(ATag: Integer): Integer;
    function AddField(AFieldName, AFieldCaption: String; AFieldWidth: Integer;
      AFieldVisible: Boolean): TField;
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

function TTable.AddField(AFieldName, AFieldCaption: String;
  AFieldWidth: Integer; AFieldVisible: Boolean): TField;
begin
  SetLength(TableFields, Length(TableFields) + 1);
  TableFields[high(TableFields)] := TField.Create;
  with TableFields[High(TableFields)] do
  begin
    FieldName := AFieldName;
    FieldCaption := AFieldCaption;
    FieldWidth := AFieldWidth;
    FieldVisible := AFieldVisible;
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

function TTable.GetFieldsCount(ATag: Integer): Integer;
begin
  Result := Length(TablesMetaData.Tables[ATag].TableFields)
end;

{ TField }

procedure TField.AddReferense(ARefTable, ARefField, ARefName,
  ARefCaption: String; ARefWidth: Integer; ARefVisible: Boolean);
begin
  References := TReference.Create;
  References.Table := ARefTable;
  References.Field := ARefField;
  References.Name := ARefName;
  References.Caption := ARefCaption;
  References.Width := ARefWidth;
  References.Visible := ARefVisible;
end;

initialization

TablesMetaData := TMData.Create;

with TablesMetaData do
begin
  with AddTable('AUDITORIES', 'Аудитории') do
  begin
    AddField('AUD_ID', 'ID', 50, False);
    AddField('AUD_TYPE_ID', 'Тип', 50, True);
    AddField('AUD_CAPTION', 'Номер', 100, True);
  end;
  with AddTable('DISCIPLINES', 'Дисциплины') do
  begin
    AddField('DIS_ID', 'ID', 50, False);
    AddField('DIS_CAPTION', 'Дисциплина', 200, True);
  end;
  with AddTable('DISCIPLINE_PROFESSOR', 'Преподаватели - Дисциплины') do
  begin
     AddField('PROF_ID', 'ID Преподавателя', 100, False).
      AddReferense('PROFESSORS', 'PROF_ID', 'PROF_NAME',
        'ФИО Перподавателя', 200, True);
     AddField('DIS_ID', 'ID Дисциплины', 100, False).
      AddReferense('DISCIPLINES', 'DIS_ID', 'DIS_CAPTION', 'Дисциплина',
        200, True);
  end;
  with AddTable('GROUP_DISCIPLINE', 'Группы - Дисциплины') do
  begin
     AddField('GROUP_ID', 'ID Группы', 100, False).
      AddReferense('GROUPS', 'GROUP_ID', 'GROUP_NUMBER', 'Группа',
        100, True);
    AddField('DISCIPLINE_ID', 'ID Дисциплины', 100, False).
      AddReferense('DISCIPLINES', 'DIS_ID', 'DIS_CAPTION', 'Дисциплина',
        200, True);
  end;

  with AddTable('LESSON_TYPES', 'Типы Занятий') do
  begin
    AddField('LES_TYPE_ID', 'ID', 50, False);
    AddField('LES_TYPE_CAPTION', 'Тип занятия', 200, True);
  end;

  with AddTable('PROFESSORS', 'Преподаватели') do
  begin
    AddField('PROF_ID', 'ID', 50, False);
    AddField('PROF_NAME', 'ФИО', 200, True);
  end;

  with AddTable('SCHEDULE', 'Расписание') do
  begin
    AddField('ID', 'ID', 50, False);
    AddField('GROUP_ID', 'ID Группы', 100, False).
      AddReferense('GROUPS', 'GROUP_ID', 'GROUP_NUMBER', 'Группа', 100, True);
    AddField('LES_TYPE_ID', 'ID Типа Занятия', 100, False).
        AddReferense('LESSON_TYPES',
      'LES_TYPE_ID', 'LES_TYPE_CAPTION', 'Тип Занятия', 200, False);
    AddField('DIS_ID', 'ID Дисциплины', 100, False).
        AddReferense('DISCIPLINES', 'DIS_ID',
      'DIS_CAPTION', 'Дисциплина', 200, True);
    AddField('TIME_ID', 'ID Пары', 100, False).
        AddReferense('TIMES', 'TIME_ID',
      'TIME_CAPTION', 'Время', 100, True);
   AddField('AUD_ID', 'ID Аудитории', 100, False).
        AddReferense( 'AUDITORIES', 'AUD_ID',
      'AUD_CAPTION', 'Аудитория', 100, True);
   AddField('PROF_ID', 'ID Преподавателя', 100, False).
        AddReferense( 'PROFESSORS', 'PROF_ID',
      'PROF_NAME', 'ФИО Преподавателя', 200, True);
   AddField('WEEKDAY_ID', 'ID Дня', 100, False).
        AddReferense('WEEKDAYS', 'WEEKDAY_ID',
      'WEEKDAY_CAPTION', 'День Недели', 100, True);
  end;
  with AddTable('TIMES', 'Время') do
  begin
    AddField('TIME_ID', 'ID', 50, False);
    AddField('TIME_CAPTION', 'Пара', 100, True);
    AddField('TIME_START_TIME', 'Начало Пары', 100, True);
    AddField('TIME_END_TIME', 'Конец Пары', 100, True);
  end;
  with AddTable('WEEKDAYS', 'Дни Недели') do
  begin
    AddField('WEEKDAY_ID', 'ID', 50, False);
    AddField('WEEKDAY_CAPTION', 'День', 100, True);
    AddField('WEEKDAY_NUMBER', 'Номер', 50, True);
  end;
  with AddTable('GROUPS', 'Группы') do
  begin
    AddField('GROUP_ID', 'ID', 50, False);
    AddField('GROUP_NUMBER', 'Номер', 100, True);
    AddField('GROUP_NAME', 'Название', 200, True);
  end;
end;

end.
