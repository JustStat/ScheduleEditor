unit FiltersControl;

interface

uses
  Forms, Vcl.ComCtrls, Vcl.StdCtrls, MetaData, Vcl.Buttons, Vcl.DBGrids,
  FireDAC.Comp.Client, Dialogs, System.WideStrUtils;

type
  TFilter = class(TTabSheet)
    FieldComboBox: TComboBox;
    OperationComboBox: TComboBox;
    ConstEdit: TEdit;
    Close_ApplyButton: TBitBtn;
    DeleteButton: TButton;
    procedure AcceptFilter(Sender: TObject);
  public
    Accepted: Boolean;
    SQLQuery: TFDQuery;
  end;

type
  TFilterControl = class
    Filters: array of TFilter;
    procedure AddFilter(PageControl: TPageControl; ATag: Integer; Grid: TDBGrid;
      ASQLQuery: TFDQuery);
    function GetAcceptedCount : Integer;
    procedure DeleteFilter(Sender: TObject);
  end;

type
  TMainFiltersControl = class
    FilterControllers: array of TFilterControl;
    procedure AddFiltersControllers;
  end;

var
  MainFiltersController: TMainFiltersControl;

implementation

{ TFilterControl }

uses SQLGenerator;

procedure TFilterControl.AddFilter(PageControl: TPageControl; ATag: Integer;
  Grid: TDBGrid; ASQLQuery: TFDQuery);
var
  i: Integer;
begin
  SetLength(Filters, Length(Filters) + 1);
  Filters[high(Filters)] := TFilter.Create(PageControl);
  Filters[high(Filters)].Tag := ATag;
  Filters[high(Filters)].PageControl := PageControl;
  Filters[high(Filters)].FieldComboBox :=
    TComboBox.Create(Filters[high(Filters)]);
  with Filters[high(Filters)] do
  begin
    with FieldComboBox do
    begin
      Parent := Filters[high(Filters)];
      Style := csDropDownList;
      for i := 0 to Grid.Columns.Count - 1 do
        if Grid.Columns[i].Visible then
          Items.Add(Grid.Columns[i].Title.Caption);
      ItemIndex := 0;
    end;
    OperationComboBox := TComboBox.Create(Filters[high(Filters)]);
    with OperationComboBox do
    begin
      Parent := Filters[high(Filters)];
      Style := csDropDownList;
      Left := FieldComboBox.Width + FieldComboBox.Left + 10;
      Items.Add('>');
      Items.Add('<');
      Items.Add('=');
      Items.Add('<>');
      Items.Add('Начинается с...');
      ItemIndex := 0;
    end;
    ConstEdit := TEdit.Create(Filters[high(Filters)]);
    with ConstEdit do
    begin
      Parent := Filters[high(Filters)];
      Left := OperationComboBox.Left + OperationComboBox.Width + 10;
    end;
    Close_ApplyButton := TBitBtn.Create(Filters[high(Filters)]);
    with Close_ApplyButton do
    begin
      Parent := Filters[high(Filters)];
      Top := ConstEdit.Top + ConstEdit.Height + 5;
      Left := ConstEdit.Left;
      Width := ConstEdit.Width;
      Kind := bkOk;
      Caption := 'Применить';
      OnClick := AcceptFilter;
      Tag := ATag;
    end;
    DeleteButton := TButton.Create(Filters[high(Filters)]);
    with DeleteButton do
    begin
      Parent := Filters[high(Filters)];
      Top := FieldComboBox.Top + FieldCombobox.Height + 5;
      Width := FieldCombobox.Width;
      Caption := 'Удалить фильтр';
      OnClick := DeleteFilter;
      Tag := high(Filters);
    end;
    SQLQuery := ASQLQuery;
  end;
end;

procedure TFilterControl.DeleteFilter(Sender: TObject);
var
  Filter: TFilter;
begin
  Self.Filters[(Sender as TButton).Tag].Accepted := true;
  Self.Filters[(Sender as TButton).Tag].AcceptFilter(Self.Filters[(Sender as TButton).Tag].Close_ApplyButton);
  Self.Filters[(Sender as TButton).Tag].Free;
  Filter := Self.Filters[high(filters)];
  Self.Filters[(Sender as TButton).Tag] := Filter;
  SetLength(Self.Filters, Length(Self.Filters) - 1);

end;

function TFilterControl.GetAcceptedCount: Integer;
var
  i: integer;
begin
  Result := 0;
  for i := 0 to High(Self.Filters) do
  if Self.Filters[i].Accepted then
    Inc(Result);
end;

{ TFilter }

procedure TFilter.AcceptFilter(Sender: TObject);
var
  i: Integer;
  FilterQuery: String;
  Test: Boolean;
begin
  if not Self.Accepted then
  begin
    if ConstEdit.Text = '' then
      exit;
    Self.Accepted := true;
    Close_ApplyButton.Kind := bkCancel;
    Close_ApplyButton.Caption := 'Отменить';
    Caption := FieldComboBox.Items[FieldComboBox.ItemIndex] + ' ' +
      OperationComboBox.Items[OperationComboBox.ItemIndex] + ' ' +
      ConstEdit.Text;
    FieldComboBox.Enabled := false;
    OperationComboBox.Enabled := false;
    ConstEdit.Enabled := false;

  end
  else
  begin
    Self.Accepted := false;
    Close_ApplyButton.Kind := bkOk;
    Close_ApplyButton.Caption := 'Применить';
    FieldComboBox.Enabled := true;
    OperationComboBox.Enabled := true;
    ConstEdit.Enabled := true;
  end;
  if MainFiltersController.FilterControllers[Tag].GetAcceptedCount = 0 then
    begin
      SQLQuery.Active := False;
      SQLQuery.SQL.Text := GetSelectionJoin((Sender as TBitBtn).Tag);
      SQLQuery.Active := True;
      exit;
    end;
  for i := 0 to High(MainFiltersController.FilterControllers[Tag].Filters) do
    if MainFiltersController.FilterControllers[Tag].Filters[i].Accepted then
      with MainFiltersController.FilterControllers[Tag].Filters[i] do
      begin
        with TablesMetaData.Tables[Tag].TableFields
          [FieldComboBox.ItemIndex + 1] do
        begin
          if References = Nil then
          begin
            FilterQuery := FilterQuery + ' CAST(' + TablesMetaData.Tables[Tag].TableName +
              '.' + FieldName + ' AS VARCHAR(100))';
          end
          else
          begin
            FilterQuery := FilterQuery + ' CAST(' + References.Table + '.' +
              References.Name + ' AS VARCHAR(100))';
          end;
        end;
        if OperationComboBox.Items[OperationComboBox.ItemIndex] = 'Начинается с...' then
        FilterQuery := FilterQuery + ' LIKE' + ' ' + #39 + ConstEdit.Text + '%' + #39
          + ' AND '
         else
        FilterQuery := FilterQuery + ' ' + OperationComboBox.Items
          [OperationComboBox.ItemIndex] + ' ' + #39 + ConstEdit.Text + #39
          + ' AND ';
      end;
  SQLQuery.Active := false;
  SQLQuery.SQL.Text := GetWhere(Tag, FilterQuery);
  SQLQuery.Active := true;
end;

{ TMainFiltersControl }

procedure TMainFiltersControl.AddFiltersControllers;
var
  i: Integer;
begin
  for i := 0 to High(TablesMetaData.Tables) do
  begin
    SetLength(FilterControllers, Length(FilterControllers) + 1);
    FilterControllers[i] := TFilterControl.Create;
  end;

end;

initialization

MainFiltersController := TMainFiltersControl.Create;
MainFiltersController.AddFiltersControllers;

end.
