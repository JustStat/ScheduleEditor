unit AboutForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TAboutWinodw = class(TForm)
    AboutLabelLine1: TLabel;
    AboutLabelLine2: TLabel;
    AboutLabelLine3: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutWinodw: TAboutWinodw;

implementation

{$R *.dfm}

end.
