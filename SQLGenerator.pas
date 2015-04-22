unit SQLGenerator;

interface

uses
  MetaData, System.SysUtils;

function GetJoin(ATag: Integer): string;
function GetSelectionJoin(ATag: Integer): string;
function GetSelectClause(ATag: Integer): string;
function GetWhere(Count: Integer; ATag: Integer; Params: string; Query: string): string;
function GetOrdered(State: TSort; ATag: Integer; Filter: string = ''; FieldName: string = ''): string;

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
          Result := Result + ' INNER JOIN ' + References.Table + ' ON ' +
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
        if FieldVisible then
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

function GetWhere(Count: Integer; ATag: Integer; Params: string; Query: string): string;
begin
  if Count = 0 then
    Result := GetSelectClause(ATag) + ' FROM ' + ' ' + GetJoin(ATag) + ' WHERE ' +
      Params + ':' + IntToStr(Count)
  else
    Result := Query + ' AND ' + Params + ':' + IntToStr(Count);
end;

function GetOrdered(State: TSort; ATag: Integer; Filter: string = ''; FieldName: string = ''): string;
begin
  if Filter = '' then
    Result := GetSelectionJoin(ATag)
  else
    Result := Filter;
  case State of
    TSort(None): exit;
    Up: Result := Result + ' ORDER BY ' + FieldName;
    Down: Result := Result + ' ORDER BY ' + FieldName + ' DESC';
  end;
end;


end.
