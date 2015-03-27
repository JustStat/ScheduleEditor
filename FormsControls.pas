unit FormsControls;

interface

uses
  Vcl.ComCtrls, Vcl.DBCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB, Vcl.Forms,
  Vcl.Controls, FireDAC.Comp.Client, rImprovedComps, MetaData, Vcl.Menus,
  DirectoryForm;

type
  TFormsController = class
  public
    FormsArray: array of TDirForm;
    Constructor Create;
  end;

implementation

constructor TFormsController.Create;
begin
  SetLength(FormsArray, MetaData.TablesMetaData.TablesCount);
end;
end.
