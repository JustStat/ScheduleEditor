unit FBAccses;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FireDAC.Phys.FB, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Grids,
  Vcl.DBGrids, FireDAC.VCLUI.Wait, FireDAC.VCLUI.ConnEdit, FireDAC.Comp.UI,
  Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.Menus, SynEditHighlighter, SynHighlighterSQL, SynEdit, SynMemo,
  Vcl.ImgList, Vcl.Buttons, rImprovedComps, IBX.IBCustomDataSet, IBX.IBTable,
  FormsControls, MetaData;

type
  TMainForm = class(TForm)
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    MainMenu: TMainMenu;
    mmFile: TMenuItem;
    ImageList: TImageList;
    MainStatusBar: TStatusBar;
    mmDictionaryButton: TMenuItem;
    mmAboutButton: TMenuItem;
    mmExitButton: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mmAboutButtonClick(Sender: TObject);
    procedure mmExitButtonClick(Sender: TObject);
  private
    MainFormsController: TFormsController;
    procedure mmDictButtonClick(Sender: TObject);
  public
    function mmCreateMenuItem(Tag: Integer): TMenuItem;
    procedure DirFormClose(Sender: TObject; var Action: TCloseAction);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses AboutForm, ConnectionForm, DirectoryForm;

function TMainForm.mmCreateMenuItem(Tag: Integer): TMenuItem;
var
  MenuItem: TMenuItem;
begin
  MenuItem := TMenuItem.Create(Self);
  MenuItem.Caption := TablesMetaData.Tables[Tag].TableCaption;
  MenuItem.Tag := Tag;
  MenuItem.OnClick := mmDictButtonClick;
  Result := MenuItem;
end;

procedure TMainForm.mmDictButtonClick(Sender: TObject);
var
  DirForm: TDirForm;
  ATag: Integer;
begin
  ATag := (Sender as TMenuItem).Tag;
  if not(Sender as TMenuItem).Checked then
  begin
    DirForm := TDirForm.Create(Application);
    DirForm.Tag := ATag;
    DirForm.OnClose := DirFormClose;
    DirForm.Show;
    MainFormsController.FormsArray[ATag] := DirForm;
    (Sender as TMenuItem).Checked := True;
  end
  else
    MainFormsController.FormsArray[ATag].SetFocus;
end;

procedure TMainForm.mmExitButtonClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TMainForm.mmAboutButtonClick(Sender: TObject);
begin
  AboutForm.AboutWinodw.ShowModal;
end;

procedure TMainForm.DirFormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  mmDictionaryButton.Items[(Sender as TForm).Tag].Checked := False;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to High(TablesMetaData.Tables) do
  begin
    mmDictionaryButton.Add(MainForm.mmCreateMenuItem(i));
  end;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  MainFormsController := TFormsController.Create;
end;

end.
