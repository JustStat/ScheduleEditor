unit DirectoryForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Vcl.Grids, Vcl.DBGrids,
  Vcl.ExtCtrls, Vcl.DBCtrls, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.Menus, SQLGenerator;

type
  TDirForm = class(TForm)
    DirQuery: TFDQuery;
    DirDataSource: TDataSource;
    DBNavigator1: TDBNavigator;
    DBGrid1: TDBGrid;
    procedure FormShow(Sender: TObject);
  private
     //
  public
    //
  end;

var
  DirForm: TDirForm;

implementation

{$R *.dfm}

uses ConnectionForm, MetaData;

procedure TDirForm.FormShow(Sender: TObject);
var
  i: Integer;
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
          Visible := References.Visible;
        end;
      end;
  DirQuery.Active := False;
  DirQuery.SQL.Text := GetSelectionJoin((Sender as TForm).Tag);
  DirQuery.Active := True;
end;

end.
