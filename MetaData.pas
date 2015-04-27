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
  with AddTable('AUDITORIES', '���������') do
  begin
    AddField('ID', 'ID', 50, false);
    AddField('AUD_CAPTION', '�����', 100, true);
  end;
  with AddTable('DISCIPLINES', '����������') do
  begin
    AddField('ID', 'ID', 50, false);
    AddField('DIS_CAPTION', '����������', 200, true);
  end;
  with AddTable('DISCIPLINE_PROFESSOR', '������������� - ����������') do
  begin
    AddField('ID', 'ID', 50, false);
    AddField('PROF_ID', 'ID �������������', 100, false)
      .AddReferense('PROFESSORS', 'ID', 'PROF_NAME',
      '��� �������������', 200, 5);
    AddField('DIS_ID', 'ID ����������', 100, false).AddReferense('DISCIPLINES',
      'ID', 'DIS_CAPTION', '����������', 200, 1);
  end;
  with AddTable('GROUP_DISCIPLINE', '������ - ����������') do
  begin
    AddField('ID', 'ID', 50, false);
    AddField('GROUP_ID', 'ID ������', 100, false).AddReferense('GROUPS', 'ID',
      'GROUP_NUMBER', '������', 100, 9);
    AddField('DISCIPLINE_ID', 'ID ����������', 100, false)
      .AddReferense('DISCIPLINES', 'ID', 'DIS_CAPTION', '����������', 200, 1);
  end;

  with AddTable('LESSON_TYPES', '���� �������') do
  begin
    AddField('ID', 'ID', 50, false);
    AddField('LES_TYPE_CAPTION', '��� �������', 200, true);
  end;

  with AddTable('PROFESSORS', '�������������') do
  begin
    AddField('ID', 'ID', 50, false);
    AddField('PROF_NAME', '���', 200, true);
  end;

  with AddTable('SCHEDULE', '����������') do
  begin
    AddField('ID', 'ID', 50, false);
    AddField('GROUP_ID', 'ID ������', 100, false).AddReferense('GROUPS', 'ID',
      'GROUP_NUMBER', '������', 100, 9);
    AddField('LES_TYPE_ID', 'ID ���� �������', 100, false)
      .AddReferense('LESSON_TYPES', 'ID', 'LES_TYPE_CAPTION',
      '��� �������', 200, 4);
    AddField('DIS_ID', 'ID ����������', 100, false).AddReferense('DISCIPLINES',
      'ID', 'DIS_CAPTION', '����������', 200, 1);
    AddField('TIME_ID', 'ID ����', 100, false).AddReferense('TIMES', 'ID',
      'TIME_CAPTION', '�����', 100, 7);
    AddField('AUD_ID', 'ID ���������', 100, false).AddReferense('AUDITORIES',
      'ID', 'AUD_CAPTION', '���������', 100, 0);
    AddField('PROF_ID', 'ID �������������', 100, false)
      .AddReferense('PROFESSORS', 'ID', 'PROF_NAME', '��� �������������', 200, 5);
    AddField('WEEKDAY_ID', 'ID ���', 100, false).AddReferense('WEEKDAYS', 'ID',
      'WEEKDAY_CAPTION', '���� ������', 100, 8);
  end;
  with AddTable('TIMES', '�����') do
  begin
    AddField('ID', 'ID', 50, false);
    AddField('TIME_CAPTION', '����', 100, true);
    AddField('TIME_START_TIME', '������ ����', 100, true);
    AddField('TIME_END_TIME', '����� ����', 100, true);
  end;
  with AddTable('WEEKDAYS', '��� ������') do
  begin
    AddField('ID', 'ID', 50, false);
    AddField('WEEKDAY_CAPTION', '����', 100, true);
    AddField('WEEKDAY_NUMBER', '�����', 50, true);
  end;
  with AddTable('GROUPS', '������') do
  begin
    AddField('ID', 'ID', 50, false);
    AddField('GROUP_NUMBER', '�����', 100, true);
    //AddField('GROUP_NAME', '��������', 200, true);
  end;
end;

end.
