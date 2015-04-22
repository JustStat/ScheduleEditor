unit RecordsEditorForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TEditorForm = class(TForm)
    procedure FormShow(Sender: TObject);
  private
    //
  public
    EditsArray: array of TEdit;
    LabelsArray: array of TLabel;
  end;

var
  EditorForm: TEditorForm;

implementation

{$R *.dfm}

uses MetaData;

procedure TEditorForm.FormShow(Sender: TObject);
var
  i: integer;
  EditLabel: TLabel;
  CurTop: integer;
begin
  CurTop := 0;
  for i := 0 to High(TablesMetaData.Tables[(Sender as TForm).Tag].TableFields) - 1 do
  begin
    SetLength(EditsArray, Length(EditsArray) + 1);
    EditsArray[High(EditsArray)] := TEdit.Create(Self);
    with EditsArray[High(EditsArray)] do
    begin
      Parent := Self;
      Top := CurTop + Height + 5;
      Left := 10;
      Anchors := [akTop, akLeft, akRight];
      CurTop := Top;
    end;
  end;




end;

end.
