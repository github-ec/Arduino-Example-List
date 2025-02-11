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
    Path: string;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    btSearch: TButton;
    btUpdateTreeView: TButton;
    btSave: TButton;
    btReload: TButton;
    edPathToIDE: TEdit;
    edSearchTree: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    pmOpenInViewer: TMenuItem;
    pmOpenInIDE: TMenuItem;
    pmOpen: TMenuItem;
    PageControl: TPageControl;
    pmTreeView: TPopupMenu;
    sgLibPath: TStringGrid;
    tsParameters: TTabSheet;
    tsTreeView: TTabSheet;
    TreeFilterEdit: TTreeFilterEdit;
    TreeView: TTreeView;
    procedure btUpdateTreeViewClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure btReloadClick(Sender: TObject);
    procedure btSearchClick(Sender: TObject);
    procedure edSearchChange(Sender: TObject);
    procedure edSearchTreeChange(Sender: TObject);
    procedure edSearchTreeKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure pmOpenInIdeClick(Sender: TObject);
    procedure pmOpenInViewerClick(Sender: TObject);
    procedure TreeFilterEditChange(Sender: TObject);
    procedure TreeViewContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: boolean);
  private
    procedure AddToTreeView(subRootName: string; var aList: TStringList);
    procedure LoadFromIniFile;
    procedure OpenInViewer;
    procedure RunExternalApp(ExternalApp: string; wOption: TShowWindowOptions);
    procedure SaveToIniFile;
    procedure SearchTreeView;
    procedure openInIDE;
    procedure startInIDE(examplePath: string);
    procedure UpdateDirList;
  public
    PathDelimiter: char;
    searchIndex: integer;
    searchNode: TTreeNode;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

uses unit2;

const
  cCaption = 'Arduino Library Examples V1.3';
  searchUpper = 'Examples';
  searchLower = 'examples';

procedure TForm1.LoadFromIniFile;
var
  i, RowCount: integer;
  IniFile: TIniFile;
  DirName, IniName: string;
begin
  IniName := ChangeFileExt(Application.ExeName, '.ini');
  IniFile := TIniFile.Create(IniName);
  sgLibPath.RowCount := IniFile.ReadInteger('PATH', 'ROWCOUNT', 9);
  sgLibPath.ColCount := 3;
  sgLibPath.Cells[1, 0] := 'Name';
  sgLibPath.Cells[2, 0] := 'Path to Libs';
  sgLibPath.ColWidths[0] := 16;
  sgLibPath.ColWidths[1] := 80;
  sgLibPath.ColWidths[2] := sgLibPath.Width - sgLibPath.ColWidths[0] -
    sgLibPath.ColWidths[1];
  for i := 1 to sgLibPath.RowCount - 1 do
  begin
    sgLibPath.Cells[0, i] := IntToStr(i);
    DirName := IniFile.ReadString('PATH', 'NAME' + IntToStr(i), '');
    if DirName = '' then DirName := IntToStr(i) + '. Path';
    sgLibPath.Cells[1, i] := DirName;
    sgLibPath.Cells[2, i] := IniFile.ReadString('PATH', 'LIBS' + IntToStr(i), '');
  end;
  edPathToIDE.Text := IniFile.ReadString('PATH', 'IDE', '');
  IniFile.Free;
end;

procedure TForm1.SaveToIniFile;
var
  i: integer;
  IniFile: TIniFile;
  IniName: string;
begin
  IniName := ChangeFileExt(Application.ExeName, '.ini');
  IniFile := TIniFile.Create(IniName);
  IniFile.WriteInteger('PATH', 'ROWCOUNT', sgLibPath.RowCount);
  for i := 1 to sgLibPath.RowCount - 1 do
  begin
    IniFile.WriteString('PATH', 'NAME' + IntToStr(i), sgLibPath.Cells[1, i]);
    IniFile.WriteString('PATH', 'LIBS' + IntToStr(i), sgLibPath.Cells[2, i]);
  end;
  IniFile.WriteString('PATH', 'IDE', edPathToIDE.Text);
  IniFile.Free;
end;

procedure TForm1.btUpdateTreeViewClick(Sender: TObject);
begin
  UpdateDirList;
end;

procedure TForm1.btSaveClick(Sender: TObject);
begin
  saveToIniFile;
end;

procedure TForm1.btReloadClick(Sender: TObject);
begin
  LoadFromIniFile;
end;

procedure TForm1.SearchTreeView;
var
  done, found: boolean;
  t, s: string;
  node: TTreeNode;
begin
  found := False;
  done := False;
  s := edSearchTree.Text;
  s := s.toUpper;
  node := nil;
  TreeView.BeginUpdate;
  try
    if (searchNode = nil) then  searchNode := TreeView.Items.GetFirstNode;
    while (searchNode <> nil) and (not found) do
    begin
      if (searchNode.Level > 0) and (searchNode.Visible) then
      begin
        t := searchNode.Text;
        t := t.toUpper;
        found := Pos(s, t) > 0;
        if found then node := searchNode;
      end;
      searchNode := searchNode.GetNext;
    end;
  finally
    TreeView.EndUpdate;
  end;
  if found then
  begin
    TreeView.Items[0].Collapse(True);
    //TreeView.Items[0].Expand(False);
    node.expand(True);
    TreeView.TopItem := node;
    TreeView.Selected := node;
  end
  else
  begin
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
  searchNode := nil;
end;

procedure TForm1.edSearchTreeKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if Key = VK_RETURN then searchTreeView;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Form1.Caption := cCaption;
  PathDelimiter := '\';
  LoadFromIniFile;
  searchIndex := 0;
  searchNode := nil;
  UpDateDirList;
end;

procedure TForm1.openInViewer;
var
  Path: string;
  node: TTreeNode;
begin
  node := TreeView.Selected;
  if node.Data = nil then
    exit
  else
    Form2.OpenFile(TDataClass(node.Data).Path);
end;

procedure TForm1.startInIDE(examplePath: string);
var
  idePath: string;
begin
  idePath := edPathToIDE.Text;
  examplePath := examplePath;
  if FileExists(idePath) then
    RunExternalApp(idePath + ' ' + examplePath, swoShow)
  else
    ShowMessage('Cannot find ' + idePath);
end;

procedure TForm1.pmOpenInIdeClick(Sender: TObject);
begin
  openInIDE;
end;

procedure TForm1.pmOpenInViewerClick(Sender: TObject);
begin
  openInViewer;
end;

procedure TForm1.TreeFilterEditChange(Sender: TObject);
begin
  //Panel1.Visible := (TreeFilterEdit.Filter = '');
end;

procedure TForm1.TreeViewContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: boolean);
var
  node: TTreeNode;
begin
  node := TreeView.GetNodeAt(MousePos.X, MousePos.Y);
  if not Assigned(node) then Abort;
  Handled := (node.Data = nil);
end;

procedure TForm1.openInIDE;
var
  Path: string;
  node: TTreeNode;
begin
  node := TreeView.Selected;
  if node.Data = nil then
    exit
  else
    startInIDE(TDataClass(node.Data).Path);
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
  DirName, LibDir: string;
  List: TStringList;
  Count, i: integer;

  function getPathDelimiter(var aPath: string): char;
  begin
    if (Pos('/', aPath) > 0) then Result := '/'
    else
      Result := '\';
  end;

begin
  TreeView.Items.Clear;
  TreeView.Items.Add(nil, 'Library Examples');
  TreeView.ShowRoot := True;
  Count := 1;
  for i := 1 to sgLibPath.RowCount - 1 do
  begin
    DirName := sgLibPath.Cells[1, i];
    LibDir := sgLibPath.Cells[2, i];
    PathDelimiter := getPathDelimiter(LibDir);
    if DirectoryExists(LibDir) then
    begin
      List := TStringList.Create;
      FindAllFiles(List, LibDir, '*.ino', True);
      try
        List.Sort;
        AddToTreeView(DirName, List);
        Inc(Count);
      finally
        List.Free;
      end;
    end;
  end;
end;

procedure TForm1.AddToTreeView(subRootName: string; var aList: TStringList);
var
  index, i, j: integer;
  node, startNode, rootNode, subRootNode: TTreeNode;
  List: TStringList;
  s: string;
  Data: TDataClass;

  function containsExamplePath(aPath: string): boolean;
  begin
    Result := (Pos(PathDelimiter + searchLower + PathDelimiter, aPath) > 0) or
      (Pos(PathDelimiter + searchUpper + PathDelimiter, aPath) > 0);
  end;

begin
  List := TStringList.Create;
  List.Delimiter := PathDelimiter;
  try
    rootNode := TreeView.Items[0];
    subRootNode := rootNode.FindNode(subRootName);
    if (subRootNode = nil) then
      subRootNode := TreeView.Items.AddChild(rootNode, subRootName);
    TreeView.BeginUpdate;
    for i := 1 to aList.Count - 1 do
    begin
      if containsExamplePath(aList[i]) then
      begin
        List.DelimitedText := aList[i];
        index := List.IndexOf(searchLower);
        if (index < 0) then index := List.IndexOf(searchUpper);
        startNode := subRootNode;
        for j := index - 1 to List.Count - 2 do
        begin
          if (j <> index) then
          begin
            node := startNode.FindNode(List[j]);
            if node = nil then
            begin
              node := TreeView.Items.AddChild(startNode, List[j]);
              node.Data := nil;
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
    TreeView.EndUpdate;
    List.Free;
  end;
end;

end.
