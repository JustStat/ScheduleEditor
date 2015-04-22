unit FiltersControl;

interface

uses
  Forms, Vcl.ComCtrls, Vcl.StdCtrls, MetaData, Vcl.Buttons, Vcl.DBGrids,
  FireDAC.Comp.Client, Dialogs, System.WideStrUtils, Vcl.Controls;

type
  TFilter = class(TTabSheet)
    FieldComboBox: TComboBox;
    OperationComboBox: TComboBox;
    ConstEdit: TEdit;
    Decline_ApplyButton: TBitBtn;
    DeleteButton: TButton;
    procedure AcceptFilter(Sender: TObject);
    function GetFilterParams: string;
  public
    Accepted: Boolean;
    SQLQuery: TFDQuery;
  end;

type
  TFilterControl = class
    Filters: array of TFilter;
    FilteredQuery: string;
    procedure AddFilter(PageControl: TPageControl; ATag: Integer; Grid: TDBGrid;
      ASQLQuery: TFDQuery);
    function GetAcceptedCount: Integer;
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
      Anchors := [akTop, akLeft, akRight];
    end;
    Decline_ApplyButton := TBitBtn.Create(Filters[high(Filters)]);
    with Decline_ApplyButton do
    begin
      Parent := Filters[high(Filters)];
      Top := ConstEdit.Top + ConstEdit.Height + 5;
      Left := ConstEdit.Left;
      Width := ConstEdit.Width;
      Kind := bkOk;
      Caption := 'Применить';
      OnClick := AcceptFilter;
      Tag := ATag;
      Anchors := [akTop, akRight];
    end;
    DeleteButton := TButton.Create(Filters[high(Filters)]);
    with DeleteButton do
    begin
      Parent := Filters[high(Filters)];
      Top := FieldComboBox.Top + FieldComboBox.Height + 5;
      Width := FieldComboBox.Width;
      Caption := 'Удалить фильтр';
      OnClick := DeleteFilter;
      Tag := high(Filters);
    end;
    SQLQuery := ASQLQuery;
  end;
end;

procedure TFilterControl.DeleteFilter(Sender: TObject);
var
  Index: Integer;
begin
  Index := (Sender as TButton).Tag;
  Self.Filters[Index].Accepted := true;
  Self.Filters[Index].AcceptFilter(Self.Filters[Index].Decline_ApplyButton);
  Self.Filters[Index].Free;
  Self.Filters[Index] := Self.Filters[high(Filters)];
  Self.Filters[high(Filters)].DeleteButton.Tag := Index;
  SetLength(Self.Filters, Length(Self.Filters) - 1);
end;

function TFilterControl.GetAcceptedCount: Integer;
var
  i: Integer;
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
  FilterQuery: string;
  r: Integer;
begin
  if not Self.Accepted then
  begin
    if ConstEdit.Text = '' then
    begin
      ShowMessage('Введите значение');
      exit;
    end;
    Self.Accepted := true;
    Decline_ApplyButton.Kind := bkCancel;
    Decline_ApplyButton.Caption := 'Отменить';
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
    Decline_ApplyButton.Kind := bkOk;
    Decline_ApplyButton.Caption := 'Применить';
    FieldComboBox.Enabled := true;
    OperationComboBox.Enabled := true;
    ConstEdit.Enabled := true;
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
            FilterQuery := TablesMetaData.Tables[Tag].TableName + '.' +
              FieldName;
          end
          else
          begin
            FilterQuery := References.Table + '.' + References.Name;
          end;
          FilterQuery := FilterQuery + ' ' + OperationComboBox.Items
            [OperationComboBox.ItemIndex];
        end;
        SQLQuery.Active := false;
        SQLQuery.SQL.Text := GetWhere(i, Tag, FilterQuery, SQLQuery.SQL.Text);
        SQLQuery.Prepare;
        if OperationComboBox.Items[OperationComboBox.ItemIndex] = 'Начинается с...'
        then
          SQLQuery.Params[SQLQuery.Params.Count - 1].AsString := ' LIKE' +
            ConstEdit.Text + '%'
        else
          SQLQuery.Params[SQLQuery.Params.Count - 1].AsString := ConstEdit.Text;
      end;
  if MainFiltersController.FilterControllers[Tag].GetAcceptedCount = 0 then
    MainFiltersController.FilterControllers[Tag].FilteredQuery := ''
  else
    MainFiltersController.FilterControllers[Tag].FilteredQuery :=
      SQLQuery.SQL.Text;
  for i := 0 to High(TablesMetaData.Tables[Tag].TableFields) do
    if TablesMetaData.Tables[Tag].TableFields[i].Sorted <> None then
      SQLQuery.SQL.Text := GetOrdered(TablesMetaData.Tables[Tag].TableFields[i]
        .Sorted, Tag, MainFiltersController.FilterControllers[Tag]
        .FilteredQuery, TablesMetaData.Tables[Tag].TableName + '.' +
        TablesMetaData.Tables[Tag].TableFields[i].FieldName);
  SQLQuery.Active := true;
end;

function TFilter.GetFilterParams: string;
begin

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
