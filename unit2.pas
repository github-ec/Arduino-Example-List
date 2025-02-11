unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, SynCompletion, SynEdit,
  SynHighlighterCpp;

type

  { TForm2 }

  TForm2 = class(TForm)
    SynCppSyn1: TSynCppSyn;
    SynEdit1: TSynEdit;
  private

  public
    procedure OpenFile(pathToFile: String);

  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

procedure TForm2.OpenFile(pathToFile : String);
  function ExtractInoName : String;
  var
    p : integer;
  begin
    p := pathToFile.LastIndexOf('\');
    if p < 0 then  p := pathToFile.LastIndexOf('/');
    if p > 0 then Result := Copy(pathToFile,p+2)
             else Result := pathToFile;
  end;

begin
 if FileExists(pathToFile) then begin
   SynEdit1.Lines.LoadFromFile(pathToFile);
   Form2.Caption := ExtractInoName;
   Form2.Show;
 end;
end;

end.

