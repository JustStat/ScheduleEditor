unit SQLGenerator;

interface

uses
  MetaData;

function GetJoin(ATag: Integer): String;
function GetSelectionJoin(ATag: integer): string;
function GetSelection(ATag: integer): string;
function GetWhere(ATag: Integer; Params: string): string;

implementation

function GetJoin(ATag: Integer): String;
var
  I: integer;
begin
  with TablesMetaData.Tables[ATag] do
  begin
    Result := TableName;
    for I := 0 to High(TableFields) do
      with TableFields[I] do
        if References <> Nil then
        begin
          Result := Result + ' INNER JOIN ' + References.Table + ' ON '
                 + TableName + '.' + FieldName + ' = '
                 + References.Table + '.' + References.Field;
        end;
  end;
end;

function GetSelection(ATag: integer): string;
var
  I: integer;
  FromQuery: string;
begin
  Result := 'SELECT ';
  with TablesMetaData.Tables[ATag] do
    for I := 0 to High(TableFields) do
      with TableFields[I] do
      begin
       if FieldVisible then
          Result := Result + TableName + '.' + FieldName + ', ';
        if References <>  Nil then
          Result := Result +  References.Table + '.' + References.Name + ', ';
      end;
  Delete(Result, Length(Result) - 1, 2);
end;

function GetSelectionJoin(ATag: integer): string;
begin
  Result := GetSelection(ATag) + ' FROM ' + GetJoin(ATag);
end;

function GetWhere(ATag: Integer; Params: string): string;
begin
  Result := GetSelection(ATag) + ' FROM ' + ' ' + GetJoin(ATag) + ' WHERE ' + Params;
  Delete(Result, Length(Result) - 4, 5);
end;

end.
