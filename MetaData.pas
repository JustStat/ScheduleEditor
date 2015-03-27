unit MetaData;

interface

type
  TReferenses = record
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
    Referenses: TReferenses;
    FieldVisible: Boolean;
  end;

type
  TTable = class
    TableName: String;
    TableCaption: String;
    TableFields: array of TField;
    function GetFieldsCount(ATag: Integer): Integer;
    procedure AddField(AFieldName, AFieldCaption: String; AFieldWidth: Integer;
      AFieldVisible: Boolean; ARefTable: String = ''; ARefField: String = '';
      ARefName: String = ''; ARefCaption: String = ''; ARefWidth: Integer = 0;
      ARefVisible: Boolean = False);
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

procedure TTable.AddField(AFieldName, AFieldCaption: String;
  AFieldWidth: Integer; AFieldVisible: Boolean; ARefTable: String = '';
  ARefField: String = ''; ARefName: String = ''; ARefCaption: String = ''; ARefWidth: Integer = 0;
  ARefVisible: Boolean = False);
begin
  SetLength(TableFields, Length(TableFields) + 1);
  TableFields[high(TableFields)] := TField.Create;
  with TableFields[High(TableFields)] do
  begin
    FieldName := AFieldName;
    FieldCaption := AFieldCaption;
    FieldWidth := AFieldWidth;
    FieldVisible := AFieldVisible;
    Referenses.Table := ARefTable;
    Referenses.Field := ARefField;
    Referenses.Name := ARefName;
    Referenses.Caption := ARefCaption;
    Referenses.Width := ARefWidth;
    Referenses.Visible := ARefVisible;
  end;
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

initialization

TablesMetaData := TMData.Create;

with TablesMetaData do
begin
  with AddTable('AUDITORIES', '���������') do
  begin
    AddField('AUD_ID', 'ID', 50, False);
    AddField('AUD_TYPE_ID', '���', 50, True);
    AddField('AUD_CAPTION', '�����', 100, True);
  end;
  with AddTable('DISCIPLINES', '����������') do
  begin
    AddField('DIS_ID', 'ID', 50, False);
    AddField('DIS_CAPTION', '����������', 200, True);
  end;
  with AddTable('DISCIPLINE_PROFESSOR', '������������� - ����������') do
  begin
    AddField('PROF_ID', 'ID �������������', 100, False, 'PROFESSORS', 'PROF_ID',
      'PROF_NAME', '��� �������������', 200, True);
    AddField('DIS_ID', 'ID ����������', 100, False, 'DISCIPLINES', 'DIS_ID',
      'DIS_CAPTION', '����������', 200, True);
  end;
  with AddTable('GROUP_DISCIPLINE', '������ - ����������') do
  begin
    AddField('GROUP_ID', 'ID ������', 100, False, 'GROUPS', 'GROUP_ID',
      'GROUP_NUMBER', '������', 100, True);
    AddField('DISCIPLINE_ID', 'ID ����������', 100, False, 'DISCIPLINES',
      'DIS_ID', 'DIS_CAPTION', '����������', 200, True);
  end;
  with AddTable('LESSON_TYPES', '���� �������') do
  begin
    AddField('LES_TYPE_ID', 'ID', 50, False);
    AddField('LES_TYPE_CAPTION', '��� �������', 200, True);
  end;
  with AddTable('PROFESSORS', '�������������') do
  begin
    AddField('PROF_ID', 'ID', 50, False);
    AddField('PROF_NAME', '���', 200, True);
  end;
  with AddTable('SCHEDULE', '����������') do
  begin
    AddField('ID', 'ID', 50, False);
    AddField('GROUP_ID', 'ID ������', 100, False, 'GROUPS', 'GROUP_ID',
      'GROUP_NUMBER', '������', 100, True);
    AddField('LES_TYPE_ID', 'ID ���� �������', 100, False, 'LESSON_TYPES',
      'LES_TYPE_ID', 'LES_TYPE_CAPTION', '��� �������', 200, False);
    AddField('DIS_ID', 'ID ����������', 100, False, 'DISCIPLINES', 'DIS_ID',
      'DIS_CAPTION', '����������', 200, True);
    AddField('TIME_ID', 'ID ����', 100, False, 'TIMES', 'TIME_ID', 'TIME_CAPTION' ,'�����',
      100, True);
    AddField('AUD_ID', 'ID ���������', 100, False, 'AUDITORIES', 'AUD_ID', 'AUD_CAPTION',
      '���������', 100, True);
    AddField('PROF_ID', 'ID �������������', 100, False, 'PROFESSORS', 'PROF_ID', 'PROF_NAME',
      '��� �������������', 200, True);
    AddField('WEEKDAY_ID', 'ID ���', 100, False, 'WEEKDAYS', 'WEEKDAY_ID', 'WEEKDAY_CAPTION',
      '���� ������', 100, True);
  end;
  with AddTable('TIMES', '�����') do
  begin
    AddField('TIME_ID', 'ID', 50, False);
    AddField('TIME_CAPTION', '����', 100, True);
    AddField('TIME_START_TIME', '������ ����', 100, True);
    AddField('TIME_END_TIME', '����� ����', 100, True);
  end;
  with AddTable('WEEKDAYS', '��� ������') do
  begin
    AddField('WEEKDAY_ID', 'ID', 50, False);
    AddField('WEEKDAY_CAPTION', '����', 100, True);
    AddField('WEEKDAY_NUMBER', '�����', 50, True);
  end;
  with AddTable('GROUPS', '������') do
  begin
    AddField('GROUP_ID', 'ID', 50, False);
    AddField('GROUP_NUMBER', '�����', 100, True);
    AddField('GROUP_NAME', '��������', 200, True);
  end;
end;

end.
