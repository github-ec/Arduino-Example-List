unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Grids, AsyncProcess, Menus, ExtCtrls, ValEdit, fileutil, TreeFilterEdit,
  Process, IniFiles, LCLType, Types;

type
  TDataClass = class(TObject)
  public
    Path : String;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    btSearch: TButton;
    btUpdateTreeView: TButton;
    Button2: TButton;
    Button3: TButton;
    edPathToIDE: TEdit;
    edSearchTree: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    MainMenu1: TMainMenu;
    pmOpenInIde: TMenuItem;
    PageControl1: TPageControl;
    pmTree: TPopupMenu;
    sgLibPath: TStringGrid;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TreeFilterEdit1: TTreeFilterEdit;
    TreeView1: TTreeView;
    procedure btUpdateTreeViewClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure btSearchClick(Sender: TObject);
    procedure edSearchChange(Sender: TObject);
    procedure edSearchTreeChange(Sender: TObject);
    procedure edSearchTreeKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure openIDEClick(Sender: TObject);
    procedure pmOpenInIdeClick(Sender: TObject);
    procedure TreeFilterEdit1Change(Sender: TObject);
    procedure TreeView1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure TreeView1DblClick(Sender: TObject);
  private
    procedure AddToTreeView(subRootName: String; var aList: TStringList);
    procedure LoadFromIniFile;
    procedure RunExternalApp(ExternalApp: string; wOption: TShowWindowOptions);
    procedure SaveToIniFile;
    procedure SearchTreeView;
    procedure startFromTreeView;
    procedure startInIDE(examplePath: String);
    procedure UpdateDirList;
  public
    PathDelimiter: char;
    searchIndex: integer;
    searchNode : TTreeNode;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.LoadFromIniFile;
var
  i, RowCount : Integer;
  IniFile: TIniFile;
  DirName,
  IniName: string;
begin
  IniName := ChangeFileExt(Application.ExeName, '.ini');
  IniFile := TIniFile.Create(IniName);
  sgLibPath.RowCount := IniFile.ReadInteger('PATH','ROWCOUNT',9);
  sgLibPath.ColCount := 3;
  sgLibPath.Cells[1,0] := 'Name';
  sgLibPath.Cells[2,0] := 'Path to Libs';
  sgLibPath.ColWidths[0] := 16;
  sgLibPath.ColWidths[1] := 80;
  sgLibPath.ColWidths[2] := sgLibPath.Width-sgLibPath.ColWidths[0]-sgLibPath.ColWidths[1];
  for i := 1 to sgLibPath.RowCount-1 do begin
       sgLibPath.Cells[0,i] := IntToStr(i);
       DirName := IniFile.ReadString('PATH', 'NAME'+IntToStr(i),'');
       if DirName = '' then DirName := IntToStr(i)+'. Path';
       sgLibPath.Cells[1,i] := DirName;
       sgLibPath.Cells[2,i] := IniFile.ReadString('PATH', 'LIBS'+IntToStr(i),'');
  end;
  edPathToIDE.Text := IniFile.ReadString('PATH', 'IDE', '');
  IniFile.Free;
end;

procedure TForm1.SaveToIniFile;
var
  i : Integer;
  IniFile: TIniFile;
  IniName: string;
begin
  IniName := ChangeFileExt(Application.ExeName, '.ini');
  IniFile := TIniFile.Create(IniName);
  IniFile.WriteInteger('PATH', 'ROWCOUNT', sgLibPath.RowCount);
  for i := 1 to sgLibPath.RowCount-1 do begin
      IniFile.WriteString('PATH', 'NAME'+IntToStr(i),sgLibPath.Cells[1,i]);
      IniFile.WriteString('PATH', 'LIBS'+IntToStr(i),sgLibPath.Cells[2,i]);
  end;
  IniFile.WriteString('PATH', 'IDE', edPathToIDE.Text);
  IniFile.Free;
end;

procedure TForm1.btUpdateTreeViewClick(Sender: TObject);
begin
  UpdateDirList;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  saveToIniFile;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  LoadFromIniFile;
end;

procedure TForm1.SearchTreeView;
var
  done,
  found: boolean;
  t,
  s : String;
  node : TTreeNode;
begin
  found := false;
  done := false;
  s := edSearchTree.Text;
  s := s.toUpper;
  node := NIL;
  TreeView1.BeginUpdate;
  try
    if (searchNode = NIL) then  searchNode := TreeView1.Items.GetFirstNode;
    while (searchNode <> nil) and (not found) do
    begin
      if (searchNode.Level > 0) and (searchNode.Visible) then begin
        t := searchNode.Text;
        t := t.toUpper;
        found := Pos(s,t) > 0;
        if found then node := searchNode;
      end;
      searchNode := searchNode.GetNext;
    end;
  finally
    TreeView1.EndUpdate;
  end;
  if found then
  begin
    TreeView1.Items[0].Collapse(True);
    //TreeView1.Items[0].Expand(False);
    node.expand(true);
    TreeView1.TopItem := node;
    TreeView1.Selected := node;
  end else begin
    ShowMessage('Search Done');
  end;
end;

procedure TForm1.btSearchClick(Sender: TObject);
begin
  searchTreeView;
end;

procedure TForm1.edSearchChange(Sender: TObject);
begin
  SearchIndex := 0;
end;

procedure TForm1.edSearchTreeChange(Sender: TObject);
begin
  searchNode := NIL;
end;

procedure TForm1.edSearchTreeKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then searchTreeView;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  PathDelimiter := '\';
  LoadFromIniFile;
  searchIndex := 0;
  searchNode := NIL;
  UpDateDirList;
end;

procedure TForm1.startInIDE(examplePath : String);
var
  idePath : String;
begin
  idePath     := edPathToIDE.Text;
  examplePath := examplePath;
  if FileExists(idePath) then
     RunExternalApp(idePath+' '+examplePath, swoShow)
  else
    ShowMessage('Cannot find '+idePath);
end;

procedure TForm1.openIDEClick(Sender: TObject);
begin
  startFromTreeView;
end;

procedure TForm1.pmOpenInIdeClick(Sender: TObject);
begin
  startFromTreeView;
end;

procedure TForm1.TreeFilterEdit1Change(Sender: TObject);
begin
   //Panel1.Visible := (TreeFilterEdit1.Filter = '');
end;

procedure TForm1.TreeView1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  node : TTreeNode;
begin
  node := TreeView1.GetNodeAt(MousePos.X, MousePos.Y);
  if not Assigned (node) then Abort;
  Handled := (node.Data = NIL);
end;

procedure TForm1.startFromTreeView;
var
  Path : String;
  node : TTreeNode;
begin
  node := TreeView1.Selected;
  if node.Data = NIL then
    exit
  else
    startInIDE(TDataClass(node.Data).Path);
end;

procedure TForm1.TreeView1DblClick(Sender: TObject);
begin
  startFromTreeView;
end;

procedure TForm1.RunExternalApp(ExternalApp: string; wOption: TShowWindowOptions);
var
  aProcess: TAsyncProcess;
begin
  aProcess := TAsyncProcess.Create(self);
  aProcess.CommandLine := ExternalApp;
  aProcess.ShowWindow := wOption;
  aProcess.Options := aProcess.Options - [poUsePipes] - [poWaitOnExit];
  aProcess.Execute;
  aProcess.Free;
end;


procedure TForm1.UpdateDirList;
var
  DirName,
  LibDir : String;
  List: TStringList;
  count,
  i : integer;

  function getPathDelimiter(var aPath : String) : Char;
  begin
    if (Pos('/',aPath) > 0) then Result := '/'
                            else Result := '\';
  end;

begin
  TreeView1.Items.Clear;
  TreeView1.Items.Add(nil, 'Library Examples');
  TreeView1.ShowRoot := True;
  count := 1;
  for i := 1 to sgLibPath.RowCount-1 do begin
    DirName := sgLibPath.Cells[1,i];
    LibDir  := sgLibPath.Cells[2,i];
    PathDelimiter := getPathDelimiter(LibDir);
    if DirectoryExists(LibDir) then begin
      List := TStringList.Create;
      FindAllFiles(List, LibDir, '*.ino', True);
      try
        List.Sort;
        AddToTreeView(DirName, List);
        inc(count);
      finally
        List.Free;
      end;
    end;
  end;
end;

procedure TForm1.AddToTreeView(subRootName : String; var aList : TStringList);
var
  index, i, j: integer;
  node, startNode, rootNode, subRootNode: TTreeNode;
  List: TStringList;
  s, searchString: string;
  Data: TDataClass;
begin
  List := TStringList.Create;
  List.Delimiter := PathDelimiter;
  try
    rootNode := TreeView1.Items[0];
    subRootNode := rootNode.FindNode(subRootName);
    if (subRootNode = NIL) then
        subRootNode := TreeView1.Items.AddChild(rootNode,subRootName);
    TreeView1.BeginUpdate;
    SearchString := 'examples';
    for i := 1 to aList.Count - 1 do
    begin
      if Pos(PathDelimiter+SearchString+PathDelimiter, aList[i]) > 0 then
      begin
        List.DelimitedText := aList[i];
        index := List.IndexOf(SearchString);
        startNode := subRootNode;
        for j := index - 1 to List.Count - 2 do
        begin
          if (j <> index) then
          begin
            node := startNode.FindNode(List[j]);
            if node = nil then
            begin
              node := TreeView1.Items.AddChild(startNode, List[j]);
              node.Data := NIL;
              if j = List.Count - 2 then
              begin
                node.Data := TDataClass.Create;
                TDataClass(node.Data).Path := aList[i];
              end;
            end;
            startNode := node;
          end;
        end;
      end;
    end;
  finally
    TreeView1.EndUpdate;
    List.Free;
  end;
end;

end.
