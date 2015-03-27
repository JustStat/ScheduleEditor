unit SQLGenerator;

interface

uses
  MetaData;

function GetJoin(ATag: Integer): String;
function GetSelectionJoin(ATag: integer): string;
function GetSelection(ATag: integer): string;

implementation

function GetJoin(ATag: Integer): String;
var
  I: integer;
begin
  with TablesMetaData.Tables[ATag] do begin
    Result := TableName;
    for I := 0 to High(TableFields) do
      with TableFields[I] do
        if Referenses.Visible then begin
          Result := Result + ' INNER JOIN ' + Referenses.Table + ' ON '
                 + TableName + '.' + FieldName + ' = '
                 + Referenses.Table + '.' + Referenses.Field;
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
      with TableFields[I] do begin
        if FieldVisible then
          Result := Result + TableName + '.' + FieldName + ', ';
        if Referenses.Visible then
          Result := Result +  Referenses.Table + '.' + Referenses.Name + ', ';
      end;

  Delete(Result, Length(Result) - 1, 2);
end;

function GetSelectionJoin(ATag: integer): string;
begin
  Result := GetSelection(ATag) + ' FROM ' + GetJoin(ATag);
end;

end.