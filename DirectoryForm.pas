unit DirectoryForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Vcl.Grids, Vcl.DBGrids,
  Vcl.ExtCtrls, Vcl.DBCtrls, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.Menus, SQLGenerator, ConnectionForm, MetaData, FiltersControl,
  Vcl.ComCtrls, Vcl.StdCtrls;

type
  TDirForm = class(TForm)
    DirQuery: TFDQuery;
    DirDataSource: TDataSource;
    DBNavigator1: TDBNavigator;
    DBGrid1: TDBGrid;
    FiltersPageControl: TPageControl;
    MainMenu1: TMainMenu;
    AddFilter: TMenuItem;
    FiltersMenuButton: TMenuItem;
    AcceptAll: TMenuItem;
    DeclineAll: TMenuItem;
    DeleteAll: TMenuItem;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure FormShow(Sender: TObject);
    procedure AddFilterClick(Sender: TObject);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure AcceptAllClick(Sender: TObject);
    procedure DeclineAllClick(Sender: TObject);
    procedure DeleteAllClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FiltersController: TFilterControl;
  public
    function GetRealColumnIndex(Index: integer): integer;
  end;

var
  DirForm: TDirForm;

implementation

{$R *.dfm}

uses RecordsEditorForm;

procedure TDirForm.DBGrid1TitleClick(Column: TColumn);
var
  i: integer;
  s: String;
  r: integer;
  changed: boolean;
begin
  for i := 0 to DBGrid1.Columns.Count - 1 do
  begin
    if DBGrid1.Columns[i].Title.Font.Style = [fsBold] then
    begin
      r := GetRealColumnIndex(Column.Index);
      if TablesMetaData.Tables[Tag].TableFields[r]
        .References <> Nil then
      DBGrid1.Columns[i].Title.Caption := TablesMetaData.Tables[Tag].TableFields[r]
        .References.Caption
        else
      DBGrid1.Columns[i].Title.Caption := TablesMetaData.Tables[Tag].TableFields[r]
        .FieldCaption;
      DBGrid1.Columns[i].Title.Font.Style := [];
    end;
  end;

  r := GetRealColumnIndex(Column.Index);

  case TablesMetaData.Tables[Tag].TableFields[r].Sorted of
    None:
      begin
        DirQuery.SQL.Text := GetOrdered(TSort(1), Tag,
          FiltersController.FilteredQuery, Column.FieldName);
        TablesMetaData.Tables[Tag].TableFields[r].Sorted := Up;
        if TablesMetaData.Tables[Tag].TableFields[r].References <> Nil then
          Column.Title.Caption := TablesMetaData.Tables[Tag].TableFields[r]
            .References.Caption + ' ↑ '
        else
          Column.Title.Caption := TablesMetaData.Tables[Tag].TableFields[r]
            .FieldCaption + ' ↑ ';
        DBGrid1.Columns[Column.Index].Title.Font.Style := [fsBold];
      end;
    Up:
      begin
        DirQuery.SQL.Text := GetOrdered(TSort(2), Tag,
          FiltersController.FilteredQuery, Column.FieldName);
        TablesMetaData.Tables[Tag].TableFields[r].Sorted := Down;
        if TablesMetaData.Tables[Tag].TableFields[r].References <> Nil then
          Column.Title.Caption := TablesMetaData.Tables[Tag].TableFields[r]
            .References.Caption + ' ↓ '
        else
          Column.Title.Caption := TablesMetaData.Tables[Tag].TableFields[r]
            .FieldCaption + ' ↓ ';
          DBGrid1.Columns[Column.Index].Title.Font.Style := [fsBold];
      end;
    Down:
      begin
        DirQuery.SQL.Text := GetOrdered(TSort(0), Tag,
          FiltersController.FilteredQuery, Column.FieldName);
        TablesMetaData.Tables[Tag].TableFields[r].Sorted := None;
        if TablesMetaData.Tables[Tag].TableFields[r].References <> Nil then
          Column.Title.Caption := TablesMetaData.Tables[Tag].TableFields[r]
            .References.Caption
        else
          Column.Title.Caption := TablesMetaData.Tables[Tag].TableFields[r]
            .FieldCaption;
        DBGrid1.Columns[Column.Index].Title.Font.Style := [];
      end
  end;
  DirQuery.Active := true;

  { if Column.Title.Font.Style = [fsBold] then
    begin
    s := Column.Title.Caption;
    if Pos(' ↓ ', s) <> 0 then
    begin
    Delete(s, Pos(' ↓ ', s), 3);
    Column.Title.Caption := s;
    Column.Title.Caption := Column.Title.Caption + ' ↑ ';
    DirQuery.Active := false;
    if Pos('DESC', DirQuery.SQL.Text) = 0 then
    DirQuery.SQL.Text := DirQuery.SQL.Text + 'DESC';
    DirQuery.Active := true;
    exit;
    end
    else
    begin
    Delete(s, Pos(' ↑ ', s), 3);
    Column.Title.Font.Style := [];
    Column.Title.Caption := s;
    DirQuery.Active := false;
    if (Pos(' ORDER BY ', DirQuery.SQL.Text) <> 0) then
    begin
    s := DirQuery.SQL.Text;
    Delete(s, Pos(' ORDER BY ', DirQuery.SQL.Text), Length(s));
    DirQuery.SQL.Text := s;
    end
    else
    DirQuery.SQL.Text := GetSelectionJoin(Self.Tag);
    DirQuery.Active := true;
    exit;
    end;
    end
    else
    begin
    s := Column.Title.Caption;
    Column.Title.Caption := Column.Title.Caption + ' ↓ ';
    s := DirQuery.SQL.Text;
    DirQuery.Active := false;
    DirQuery.SQL.Text := s;
    DirQuery.Active := true;
    end;

    for i := 0 to DBGrid1.Columns.Count - 1 do
    begin
    if DBGrid1.Columns[i].Title.Font.Style = [fsBold] then
    begin
    s := DBGrid1.Columns[i].Title.Caption;
    Delete(s, Length(s) - 1, Length(s));
    DBGrid1.Columns[i].Title.Caption := s;
    s := DirQuery.SQL.Text;
    Delete(s, Pos(' ORDER BY ', DirQuery.SQL.Text),
    Length(DirQuery.SQL.Text) - 1);
    DirQuery.Active := false;
    DirQuery.SQL.Text := s;
    DirQuery.Active := false;
    DBGrid1.Columns[i].Title.Font.Style := [];
    end;
    end;
    Column.Title.Font.Style := [fsBold];

    DirQuery.Active := false;
    if Column.FieldName = 'WEEKDAY_CAPTION' then
    DirQuery.SQL.Text := DirQuery.SQL.Text + ' ORDER BY SCHEDULE.WEEKDAY_ID'
    else
    DirQuery.SQL.Text := DirQuery.SQL.Text + ' ORDER BY ' + Column.FieldName;
    DirQuery.Active := true; }
end;

procedure TDirForm.FormPaint(Sender: TObject);
var
  i: integer;
begin
  if (FiltersPageControl.PageCount = 0) and FiltersPageControl.Visible then
  begin
    FiltersPageControl.Visible := false;
    Self.Height := Self.Height - FiltersPageControl.Height;
    for i := 0 to Self.ComponentCount - 1 do
    begin
      if Self.Components[i] is TDBNavigator then
        (Self.Components[i] as TDBNavigator).Top :=
          (Self.Components[i] as TDBNavigator).Top - FiltersPageControl.Height;
      if Self.Components[i] is TDBGrid then
        (Self.Components[i] as TDBGrid).Top := (Self.Components[i] as TDBGrid)
          .Top - FiltersPageControl.Height;
      if Self.Components[i] is TPanel then
         (Self.Components[i] as TPanel).Top := (Self.Components[i] as TPanel)
          .Top - FiltersPageControl.Height;
    end;
  end;
end;

procedure TDirForm.FormShow(Sender: TObject);
var
  i: integer;
begin
  Self.Caption := TablesMetaData.Tables[(Sender as TForm).Tag].TableCaption;
  with TablesMetaData.Tables[(Sender as TForm).Tag] do
    for i := 0 to High(TableFields) do
      with TableFields[i] do
      begin
        with DBGrid1.Columns.Add do
        begin
          FieldName := TablesMetaData.Tables[(Sender as TForm).Tag].TableFields
            [i].FieldName;
          Title.Caption := FieldCaption;
          Width := FieldWidth;
          Visible := FieldVisible;
        end;
        if References <> Nil then
          with DBGrid1.Columns.Add do
          begin
            FieldName := References.Name;
            Title.Caption := References.Caption;
            Width := References.Width;
          end;
      end;
  DirQuery.Active := false;
  DirQuery.SQL.Text := GetSelectionJoin((Sender as TForm).Tag);
  DirQuery.Active := true;
  FiltersController := MainFiltersController.FilterControllers[Tag];
end;

function TDirForm.GetRealColumnIndex(Index: integer): integer;
var
  r: integer;
  i: integer;
begin
  r := 0;
  DirQuery.Active := false;
  for i := 0 to DBGrid1.Columns.Count - 1 do
    if DBGrid1.Columns[i].Visible then
    begin
      Inc(r);
      if TablesMetaData.Tables[Tag]
        .TableFields[r].References <> Nil then
      begin
      if DBGrid1.Columns[Index].FieldName = TablesMetaData.Tables[Tag]
        .TableFields[r].References.Name then
        break;
      end
      else
        if DBGrid1.Columns[Index].FieldName = TablesMetaData.Tables[Tag]
        .TableFields[r].FieldName then
        break
    end;
  Result := r;
end;

procedure TDirForm.AddFilterClick(Sender: TObject);
var
  i: integer;
begin
  FiltersController.AddFilter(FiltersPageControl, Self.Tag, DBGrid1, DirQuery);
  FiltersPageControl.ActivePageIndex := FiltersPageControl.PageCount - 1;
  if not FiltersPageControl.Visible then
  begin
    FiltersPageControl.Visible := true;
    Self.Height := Self.Height + FiltersPageControl.Height;
    for i := 0 to Self.ComponentCount - 1 do
    begin
      if Self.Components[i] is TDBNavigator then
        (Self.Components[i] as TDBNavigator).Top :=
          (Self.Components[i] as TDBNavigator).Top + FiltersPageControl.Height;
      if Self.Components[i] is TDBGrid then
        (Self.Components[i] as TDBGrid).Top := (Self.Components[i] as TDBGrid)
          .Top + FiltersPageControl.Height;
    end;
  end;
end;

procedure TDirForm.Button1Click(Sender: TObject);
var
Form : TEditorForm;
begin
  Form := TEditorForm.Create(Application);
  Form.Tag := Self.Tag;
  Form.ShowModal;
end;

procedure TDirForm.AcceptAllClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to High(MainFiltersController.FilterControllers[Tag].Filters) do
  begin
    MainFiltersController.FilterControllers[Tag].Filters[i].Accepted := false;
    with MainFiltersController.FilterControllers[Tag].Filters[i] do
      AcceptFilter(Decline_ApplyButton);
  end;

end;

procedure TDirForm.DeclineAllClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to High(MainFiltersController.FilterControllers[Tag].Filters) do
  begin
    MainFiltersController.FilterControllers[Tag].Filters[i].Accepted := true;
    with MainFiltersController.FilterControllers[Tag].Filters[i] do
      AcceptFilter(Decline_ApplyButton);
  end;
end;

procedure TDirForm.DeleteAllClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to High(MainFiltersController.FilterControllers[Tag].Filters) do
    MainFiltersController.FilterControllers[Tag].Filters[i].Free;
  SetLength(MainFiltersController.FilterControllers[Tag].Filters, 0);
end;

end.
