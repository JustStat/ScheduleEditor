unit SQLGenerator;

interface

uses
  MetaData, System.SysUtils;

function GetJoin(ATag: Integer): string;
function GetSelectionJoin(ATag: Integer): string;
function GetJoinWhere(Count: Integer; ATag: Integer; Params: string;
  Query: string): string;
function GetSelectClause(ATag: Integer): string;
function GetSelectJoinWhere(Count: Integer; ATag: Integer; Params: string;
  Query: string): string;
function GetOrdered(State: TSort; ATag: Integer; Filter: string = '';
  FieldName: string = ''): string;
function GetInsert(Tag: Integer; Index: Integer; Count: Integer): string;
function GetUpdate(Tag: Integer; Index: Integer): string;
function SetGenerator(Max: Integer): string;

implementation

function GetJoin(ATag: Integer): String;
var
  I: Integer;
begin
  with TablesMetaData.Tables[ATag] do
  begin
    Result := TableName;
    for I := 0 to High(TableFields) do
      with TableFields[I] do
        if References <> Nil then
        begin
          Result := Result + ' LEFT JOIN ' + References.Table + ' ON ' +
            TableName + '.' + FieldName + ' = ' + References.Table + '.' +
            References.Field;
        end;
  end;
end;

function GetSelectClause(ATag: Integer): string;
var
  I: Integer;
  FromQuery: string;
begin
  Result := 'SELECT ';
  with TablesMetaData.Tables[ATag] do
    for I := 0 to High(TableFields) do
      with TableFields[I] do
      begin
        Result := Result + TableName + '.' + FieldName + ', ';
        if References <> Nil then
          Result := Result + References.Table + '.' + References.Name + ', ';
      end;
  Delete(Result, Length(Result) - 1, 2);
end;

function GetSelectionJoin(ATag: Integer): string;
begin
  Result := GetSelectClause(ATag) + ' FROM ' + GetJoin(ATag);
end;

function GetSelectJoinWhere(Count: Integer; ATag: Integer; Params: string;
  Query: string): string;
begin
  if Count = 0 then
    Result := GetSelectClause(ATag) + ' FROM ' + ' ' + GetJoin(ATag) + ' WHERE '
      + Params + ':' + IntToStr(Count)
  else
    Result := Query + ' AND ' + Params + ':' + IntToStr(Count);
end;

function GetOrdered(State: TSort; ATag: Integer; Filter: string = '';
  FieldName: string = ''): string;
begin
  if Filter = '' then
    Result := GetSelectionJoin(ATag)
  else
    Result := Filter;
  case State of
    TSort(None):
      exit;
    Up:
      Result := Result + ' ORDER BY ' + FieldName;
    Down:
      Result := Result + ' ORDER BY ' + FieldName + ' DESC';
  end;
end;

function GetJoinWhere(Count: Integer; ATag: Integer; Params: string;
  Query: string): string;
begin
  if Count = 0 then
    Result := 'SELECT * FROM ' + ' ' + GetJoin(ATag) + ' WHERE ' + Params + ':'
      + IntToStr(Count)
  else
    Result := Query + ' AND ' + Params + ':' + IntToStr(Count);
end;

function GetInsert(Tag: Integer; Index: Integer; Count: Integer): string;
var
  I: Integer;
begin
  if TablesMetaData.Tables[Tag].TableFields[Index].References = Nil then
  begin
    Result := 'INSERT INTO ' + TablesMetaData.Tables[Tag].TableFields[Index]
      .References.Table + '(' + TablesMetaData.Tables[Tag].TableFields[0]
      .FieldName + ', ' + TablesMetaData.Tables[Tag].TableFields[Index]
      .References.Name + ') VALUES ( GEN_ID(GenNewID, 1)';
    Result := Result + ', :0';
    Result := Result + ');';
  end
  else
  begin
    Result := 'INSERT INTO ' + TablesMetaData.Tables[Tag].TableName +
      ' VALUES ( GEN_ID(GenNewID, 1)';
    for I := 0 to Count do
      Result := Result + ', :' + IntToStr(Index);
    Result := Result + ');';
  end;
end;

function GetUpdate(Tag: Integer; Index: Integer): string;
var
  I: Integer;
begin
  { if TablesMetaData.Tables[Tag].TableFields[Index].References <> Nil then
    begin
    Result :=  'UPDATE ' + TablesMetaData.Tables[Tag].TableFields[Index].References.Table +
    ' SET ' + TablesMetaData.Tables[Tag].TableFields[Index].References.Name +
    ' = :0 WHERE ' + TablesMetaData.Tables[Tag].TableFields[Index]
    .References.Name + ' = :1';
    end
    else
    begin }
  if Index = 0 then
    Result := 'UPDATE ' + TablesMetaData.Tables[Tag].TableName + ' SET ' + TablesMetaData.Tables[Tag].TableFields[Index + 1]
      .FieldName + ' = :' + IntToStr(Index);
  if (Index > 0) and (Index < High(TablesMetaData.Tables[Tag].TableFields)) then
    Result := Result + ', ' + TablesMetaData.Tables[Tag].TableFields[Index  + 1]
      .FieldName + ' = :' + IntToStr(Index);
  if Index = High(TablesMetaData.Tables[Tag].TableFields) then
    Result := ' WHERE ID = :' + IntToStr(Index);
  // end;
end;

function SetGenerator(Max: Integer): string;
begin
  Result := 'SET GENERATOR GenNewID TO ' + IntToStr(Max);
end;

end.
