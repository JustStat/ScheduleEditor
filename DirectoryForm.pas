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
  Vcl.ComCtrls;

type
  TDirForm = class(TForm)
    DirQuery: TFDQuery;
    DirDataSource: TDataSource;
    DBNavigator1: TDBNavigator;
    DBGrid1: TDBGrid;
    FilterPageControl: TPageControl;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure DBGrid1TitleClick(Column: TColumn);
  private
    FiltersController: TFilterControl;
  public
    //
  end;

var
  DirForm: TDirForm;

implementation

{$R *.dfm}

procedure TDirForm.DBGrid1TitleClick(Column: TColumn);
var
  i: integer;
  s: String;
begin
  for i := 0 to DBGrid1.Columns.Count - 1 do
  begin
    if DBGrid1.Columns[i].Title.Font.Style = [fsBold] then
    begin
      DBGrid1.Columns[i].Title.Font.Style := [];
      s := DirQuery.SQL.Text;
      Delete(s, Pos(' ORDER BY ', DirQuery.SQL.Text),
        Length(DirQuery.SQL.Text) - 1);
      DirQuery.Active := false;
      DirQuery.SQL.Text := s;
      DirQuery.Active := false;
    end;
  end;

  Column.Title.Font.Style := [fsBold];
  DirQuery.Active := false;
  if Column.FieldName = 'WEEKDAY_CAPTION' then
    DirQuery.SQL.Text := DirQuery.SQL.Text + ' ORDER BY SCHEDULE.WEEKDAY_ID'
  else
  DirQuery.SQL.Text := DirQuery.SQL.Text + ' ORDER BY ' + Column.FieldName;
  DirQuery.Active := true;
end;

procedure TDirForm.FormShow(Sender: TObject);
var
  i: integer;
  CurrentIndex: integer;
begin
  Self.Caption := TablesMetaData.Tables[(Sender as TForm).Tag].TableCaption;
  CurrentIndex := 0;
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

procedure TDirForm.N1Click(Sender: TObject);
begin
  FiltersController.AddFilter(FilterPageControl, Self.Tag, DBGrid1, DirQuery);
end;

end.
