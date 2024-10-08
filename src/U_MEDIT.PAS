unit U_Medit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, GlobalVars, FieldEdit, ComCtrls, J_Level, ExtCtrls, FileCtrl;

type

  TJKRec = class
    lnum, cdnum, levnum: integer;
    ltype: string;
    fname: string;
    lpow, dpow: integer;
    gotoA, gotoB: integer;
    comment: string;
    Function GetListStr: String;
  end;

  TCOGStrings = class
    keys: TStringList;
    strings: TStringList;
    Constructor Create;
    Procedure AddString(const key, str: string);
    Function GetString(const key: string): String;
    procedure DeleteString(const key: string);
    Destructor Destroy; override;
    Procedure LoadFromFile(const name: string);
    Procedure SaveToFile(const name: string);
  end;

  TEpisodeEdit = class(TForm)
    EBLnum: TEdit;
    EBCDNum: TEdit;
    EBLevNum: TEdit;
    CBType: TComboBox;
    EBFname: TEdit;
    BNFname: TButton;
    EBGotoA: TEdit;
    EBGotoB: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    MMLevText: TMemo;
    Label12: TLabel;
    EBLevName: TEdit;
    Label13: TLabel;
    CBGameType: TComboBox;
    EBEpName: TEdit;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    BNStrings: TButton;
    Button1: TButton;
    CBLPow: TComboBox;
    CBDPow: TComboBox;
    BNUpdate: TButton;
    BNDelete: TButton;
    BNAdd: TButton;
    BNSave: TButton;
    BNCancel: TButton;
    Panel1: TPanel;
    LVSeqs: TListView;
    procedure BNStringsClick(Sender: TObject);
    procedure SeqsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BNAddClick(Sender: TObject);
    procedure BNDeleteClick(Sender: TObject);
    procedure BNFnameClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure LVSeqsClick(Sender: TObject);
    procedure LVSeqsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure BNUpdateClick(Sender: TObject);
    procedure LVSeqsChanging(Sender: TObject; Item: TListItem;
      Change: TItemChange; var AllowChange: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure BNSaveClick(Sender: TObject);
    procedure BNCancelClick(Sender: TObject);
  private
    AskSave: Boolean;
    { Episode.JK vars }
    episode_name: string;
    game_type: integer;
    recs: TList;
    cstrings: TCOGStrings;
    { Private declarations }
    vGtype, vlPow, vdPow, vLine, vCD, vLev, vFname, vLevName, vLType, vGotoA,
      vGotoB: TValInput;

    Procedure LoadEpJK(const name: string);
    Procedure SaveEpJK(const name: string);
    Procedure CreateNewEpisode;
    Procedure RefreshEditor;
    Procedure CommitSeq(n: integer);
  public
    { Public declarations }
    Procedure EditEpisode;
    Procedure InitVars;
    Procedure FreeVars;
  end;

var
  EpisodeEdit: TEpisodeEdit;

implementation

uses Files, FileOperations, misc_utils, Jed_Main, u_StrEdit, ResourcePicker,
  u_coggen, U_CogForm;

{$R *.DFM}

Constructor TCOGStrings.Create;
begin
  keys := TStringList.Create;
  keys.sorted := true;
  strings := TStringList.Create;
end;

Destructor TCOGStrings.Destroy;
begin
  keys.Free;
  strings.Free;
end;

Procedure TCOGStrings.AddString(const key, str: string);
var
  i: integer;
begin
  if key = '' then
    exit;
  i := keys.IndexOf(key);
  if i <> -1 then
    strings[i] := str
  else
  begin
    i := keys.Add(UpperCase(key));
    strings.Insert(i, str);
  end;
end;

Function TCOGStrings.GetString(const key: string): String;
var
  i: integer;
begin
  i := keys.IndexOf(key);
  if i = -1 then
    result := ''
  else
    result := strings[i];
end;

procedure TCOGStrings.DeleteString(const key: string);
var
  i: integer;
begin
  i := keys.IndexOf(key);
  if i = -1 then
    exit;
  keys.Delete(i);
  strings.Delete(i);
end;

Procedure TCOGStrings.LoadFromFile(const name: string);
var
  t: TTextFile;
  s, w, key, str: string;
  p, i, j, n: integer;
  psq: pchar;
begin

  if name = '' then
    exit;

  Try
    t := TTextFile.CreateRead(OpenFileRead(name, 0));
  except
    on Exception do
      exit;
  end;

  Try
    keys.clear;
    strings.clear;
    t.Readln(s);
    SScanf(s, 'MSGS %d', [@n]);
    for i := 0 to n - 1 do
    begin
      Repeat
        t.Readln(s);
        RemoveComment(s);
        p := getWord(s, 1, w);
        if (CompareText(w, 'END') = 0) or t.eof then
          exit;
      until w <> '';

      if w = '"' then
      begin
        psq := StrScan(pchar(s) + p, '"');
        if psq = nil then
          p := Length(s) + 1
        else
          p := psq - @s[1] + 2;
      end;

      key := Copy(s, 1, p);

      For j := Length(key) downto 1 do
        if key[j] = '"' then
          Delete(key, j, 1);

      key := Trim(key);

      p := getWord(s, p, w);
      str := Trim(Copy(s, p, Length(s)));

      For j := Length(str) downto 1 do
        if str[j] = '"' then
          Delete(str, j, 1);

      AddString(key, str);

    end;
  finally
    t.Fclose;
  end;
end;

Procedure TCOGStrings.SaveToFile(const name: string);
var
  i: integer;
  t: TextFile;
begin
  if keys.count = 0 then
  begin
    DeleteFile(name);
    exit;
  end;

  ForceDirectories(ExtractFilePath(name));
  try
    Assign(t, name);
    Rewrite(t);
  except
    on Exception do
    begin
      PanMessage(mt_Error, 'Couln''t create ' + name);
      exit;
    end;
  end;

  Writeln(t, Format('MSGS %d', [keys.count]));
  Writeln(t);
  Writeln(t, '#  "<key>"     <unused number>   "<string>"');
  Writeln(t);
  for i := 0 to keys.count - 1 do
  begin
    Writeln(t, '"', keys[i], '" 0 "', strings[i], '"');
  end;
  Writeln(t);
  Writeln(t, 'END');
  Close(t);
end;

Procedure TEpisodeEdit.InitVars;
begin
  recs := TList.Create;
  cstrings := TCOGStrings.Create;
end;

Procedure TEpisodeEdit.FreeVars;
var
  i: integer;
begin
  for i := 0 to recs.count - 1 do
    TJKRec(recs[i]).Free;
  recs.Free;
  cstrings.Free;
  recs := nil;
  cstrings := nil;
end;

Procedure TEpisodeEdit.RefreshEditor;
var
  i: integer;
  li: TListItem;
begin
  EBEpName.Text := episode_name;
  vGtype.SetAsInt(game_type);
  LVSeqs.Items.clear;
  For i := 0 to recs.count - 1 do
    With TJKRec(recs[i]) do
    begin
      li := LVSeqs.Items.Add;
      li.Caption := IntToStr(lnum) + ':';
      li.SubItems.Add(fname);
      li.SubItems.Add(IntToStr(levnum));
      li.SubItems.Add(IntToStr(gotoA));
      li.SubItems.Add(IntToStr(gotoB));
    end;
end;

Procedure TEpisodeEdit.EditEpisode;
begin
  if projectDir = '' then
  begin
    PanMessage(mt_Error, 'Save level first');
    exit;
  end;

  InitVars;
  cstrings.LoadFromFile(FindProjDirFile('cogstrings.uni'));
  LoadEpJK(projectDir + 'episode.jk');
  RefreshEditor;
  LVSeqs.ItemFocused := LVSeqs.Items[0];
  LVSeqs.Selected := LVSeqs.Items[0];

  if ShowModal = mrOK then
  begin
    episode_name := EBEpName.Text;
    game_type := vGtype.AsInt;
    SaveEpJK(projectDir + 'episode.jk');
    DeleteFile(projectDir + 'cogstrings.uni');
    cstrings.SaveToFile(projectDir + 'misc\cogstrings.uni');
  end;
  FreeVars;

end;

Procedure TEpisodeEdit.LoadEpJK(const name: string);
var
  t: TTextFile;
  s: string;

  Procedure ReadS(var s: string);
  begin
    Repeat
      t.Readln(s);
      RemoveComment(s);
      s := Trim(s);
    until (s <> '') or t.eof;
  end;

var
  i, nseqs: integer;
  jkr: TJKRec;
begin
  try
    t := TTextFile.CreateRead(OpenFileRead(name, 0));
  except
    on Exception do
    begin
      CreateNewEpisode;
      exit;
    end;
  end;

  try
    ReadS(s);
    SetLength(s, Length(s) - 1);
    Delete(s, 1, 1);
    episode_name := s;
    ReadS(s);
    SScanf(s, 'TYPE %d', [@game_type]);

    ReadS(s);
    SScanf(s, 'SEQ %d', [@nseqs]);

    for i := 0 to nseqs - 1 do
    begin
      jkr := TJKRec.Create;
      ReadS(s);
      { # <line> <cd>  <level>  <type>   <file>         <lightpow>  <darkpow>   <gotoA>  <gotoB> }

      With jkr do
        SScanf(s, '%d %d %d %s %s %d %d %d %d', [@lnum, @cdnum, @levnum, @ltype,
          @fname, @lpow, @dpow, @gotoA, @gotoB]);
      recs.Add(jkr);
    end;

  finally
    t.Fclose;
  end;

end;

Procedure TEpisodeEdit.CreateNewEpisode;
var
  jkr: TJKRec;
begin
  jkr := TJKRec.Create;
  With jkr do
  begin
    lnum := 10;
    cdnum := 0;
    levnum := 1;
    ltype := 'LEVEL';
    fname := ChangeFileExt(ExtractName(JedMain.LevelFile), '.jkl');
    lpow := 0;
    dpow := 0;
    gotoA := -1;
    gotoB := -1;
  end;
  recs.Add(jkr);
end;

Procedure TEpisodeEdit.SaveEpJK(const name: string);
var
  t: TextFile;

  Procedure WriteFmt(const fmt: string; vs: array of const);
  begin
    Writeln(t, Format(fmt, vs));
  end;

var
  i: integer;
begin
  AssignFile(t, name);
  Rewrite(t);
  WriteFmt('"%s"', [episode_name]);
  Writeln(t);
  WriteFmt('TYPE %d', [game_type]);
  Writeln(t);
  WriteFmt('SEQ %d', [recs.count]);
  Writeln(t);
  Writeln(t,
    '# <line> <cd>  <level>  <type>   <file>         <lightpow>  <darkpow>   <gotoA>  <gotoB>');
  Writeln(t);
  for i := 0 to recs.count - 1 do
    With TJKRec(recs[i]) do
    begin
      WriteFmt('%d:'#9'%d'#9'%d'#9'%s'#9'%s'#9'%d'#9'%d'#9'%d'#9'%d',
        [lnum, cdnum, levnum, ltype, fname, lpow, dpow, gotoA, gotoB]);
    end;
  Writeln(t);
  Writeln(t, 'end');
  CloseFile(t);
end;

procedure TEpisodeEdit.BNStringsClick(Sender: TObject);
begin
  StrEdit.EditStrings(cstrings);
end;

Function TJKRec.GetListStr: String;
begin
  result := Format('%d: %-32s %d %d', [lnum, fname, gotoA, gotoB]);
end;

procedure TEpisodeEdit.SeqsClick(Sender: TObject);
var
  i: integer;
  jkr: TJKRec;
  f: string;
begin
  if LVSeqs.ItemFocused = nil then
    exit;
  i := LVSeqs.ItemFocused.Index;
  jkr := TJKRec(recs[i]);
  With jkr do
  begin
    vLine.SetAsInt(lnum);
    vCD.SetAsInt(cdnum);
    vLev.SetAsInt(levnum);
    vGotoA.SetAsInt(gotoA);
    vGotoB.SetAsInt(gotoB);
    vlPow.SetAsInt(lpow);
    vdPow.SetAsInt(dpow);
    CBType.Text := ltype;
    EBFname.Text := fname;

    f := ChangeFileExt(fname, '');
    EBLevName.Text := cstrings.GetString(f);

    MMLevText.Lines.Text := cstrings.GetString(f + '_TEXT_00') + #13#10 +
      cstrings.GetString(f + '_TEXT_01');

  end;
end;

procedure TEpisodeEdit.FormCreate(Sender: TObject);
begin
  vLine := TValInput.Create(EBLnum);
  vCD := TValInput.Create(EBCDNum);
  vLev := TValInput.Create(EBLevNum);
  vGotoA := TValInput.Create(EBGotoA);
  vGotoB := TValInput.Create(EBGotoB);
  vlPow := TValInput.CreateFromCB(CBLPow);
  vdPow := TValInput.CreateFromCB(CBDPow);
  vGtype := TValInput.CreateFromCB(CBGameType);
  ClientHeight := BNCancel.Top + BNCancel.Height + EBGotoA.Left;
  ClientWidth := MMLevText.Left + MMLevText.width + EBGotoA.Left;
end;

procedure TEpisodeEdit.BNAddClick(Sender: TObject);
var
  i: integer;
  jkr, jkr1: TJKRec;
  li: TListItem;
begin
  if LVSeqs.ItemFocused = nil then
    exit;
  i := LVSeqs.ItemFocused.Index;

  jkr1 := TJKRec(recs[i]);

  jkr := TJKRec.Create;

  With jkr do
  begin
    lnum := jkr1.lnum + 1;
    cdnum := 0;
    levnum := jkr1.levnum + 1;
    ltype := 'LEVEL';
    fname := ChangeFileExt(ExtractName(JedMain.LevelFile), '.jkl');
    lpow := 0;
    dpow := 0;
    gotoA := -1;
    gotoB := -1;
  end;

  recs.Insert(i + 1, jkr);
  With jkr do
  begin
    li := LVSeqs.Items.Insert(i + 1);
    li.Caption := IntToStr(lnum) + ':';
    li.SubItems.Add(fname);
    li.SubItems.Add(IntToStr(levnum));
    li.SubItems.Add(IntToStr(gotoA));
    li.SubItems.Add(IntToStr(gotoB));
  end;
  LVSeqs.Selected := li;
  LVSeqs.ItemFocused := li;
end;

procedure TEpisodeEdit.BNDeleteClick(Sender: TObject);
var
  i: integer;
begin
  if LVSeqs.ItemFocused = nil then
    exit;
  i := LVSeqs.ItemFocused.Index;
  if recs.count <= 1 then
  begin
    MsgBox('Only one left!', 'Episode Editor', mb_ok);
    exit;
  end;
  TJKRec(recs[i]).Free;
  recs.Delete(i);
  LVSeqs.Items.Delete(i);
  if i > 0 then
  begin
    LVSeqs.ItemFocused := LVSeqs.Items[i - 1];
    LVSeqs.Selected := LVSeqs.Items[i - 1];
  end;
end;

procedure TEpisodeEdit.BNFnameClick(Sender: TObject);
var
  ext: string;
begin
  EBFname.Text := ResPicker.PickEpSeq(EBFname.Text);
  ext := UpperCase(ExtractFileExt(EBFname.Text));
  if ext = '.JKL' then
    CBType.Text := 'LEVEL'
  else if (ext = '.SMK') or (ext = '.SAN') then
    CBType.Text := 'CUT';
end;

procedure TEpisodeEdit.Button1Click(Sender: TObject);
var
  jkr: TJKRec;
  s: string;
  i: integer;
  cg: TCog;
begin
  if LVSeqs.ItemFocused = nil then
    exit;
  i := LVSeqs.ItemFocused.Index;
  jkr := TJKRec(recs[i]);
  if CompareText(jkr.ltype, 'LEVEL') <> 0 then
  begin
    MsgBox('Select a level first', 'Episode editor', mb_ok);
    exit;
  end;

  CogGen.cstrs := cstrings;
  CogGen.GoalBase := jkr.levnum * 1000;
  s := ChangeFileExt(jkr.fname, '_start.cog');
  if not CogGen.GenerateCOG(projectDir + s) then
    exit;
  if CompareText(jkr.fname, ExtractFileName(JedMain.ShortJKLName)) <> 0 then
    exit;
  for i := 0 to Level.Cogs.count - 1 do
  begin
    cg := Level.Cogs[i];
    if CompareText(cg.name, s) = 0 then
      exit;
  end;
  cg := TCog.Create;
  cg.name := s;
  Level.Cogs.Add(cg);
  CogForm.RefreshList;
end;

procedure TEpisodeEdit.LVSeqsClick(Sender: TObject);
var
  pt: TPoint;
  li: TListItem;
begin
  GetCursorPos(pt);
  pt := LVSeqs.ScreenToClient(pt);
  pt.x := LVSeqs.Columns[0].width div 2;
  li := LVSeqs.GetItemAt(pt.x, pt.Y);
  if li <> nil then
  begin
    LVSeqs.ItemFocused := li;
    LVSeqs.Selected := li;
  end;
end;

procedure TEpisodeEdit.LVSeqsChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  i: integer;
  jkr: TJKRec;
  f: string;
begin
  if recs = nil then
    exit;
  if Change <> ctState then
    exit;
  if not Item.Focused then
    exit;
  i := Item.Index;
  if i >= recs.count then
    exit;
  jkr := TJKRec(recs[i]);
  With jkr do
  begin
    vLine.SetAsInt(lnum);
    vCD.SetAsInt(cdnum);
    vLev.SetAsInt(levnum);
    vGotoA.SetAsInt(gotoA);
    vGotoB.SetAsInt(gotoB);
    vlPow.SetAsInt(lpow);
    vdPow.SetAsInt(dpow);
    CBType.Text := ltype;
    EBFname.Text := fname;

    f := ChangeFileExt(fname, '');
    EBLevName.Text := cstrings.GetString(f);

    MMLevText.Lines.Text := cstrings.GetString(f + '_TEXT_00') + #13#10 +
      cstrings.GetString(f + '_TEXT_01');

  end;
end;

Procedure TEpisodeEdit.CommitSeq(n: integer);
var
  i: integer;
  jkr: TJKRec;
  f, s1, s2: string;
  li: TListItem;

begin
  jkr := TJKRec(recs[n]);
  With jkr do
  begin
    lnum := vLine.AsInt;
    cdnum := vCD.AsInt;
    levnum := vLev.AsInt;
    gotoA := vGotoA.AsInt;
    gotoB := vGotoB.AsInt;
    lpow := vlPow.AsInt;
    dpow := vdPow.AsInt;
    ltype := CBType.Text;
    fname := EBFname.Text;

    f := ChangeFileExt(fname, '');

    cstrings.AddString(f, EBLevName.Text);

    s1 := MMLevText.Lines[0];
    s2 := MMLevText.Lines.Text;
    s2 := Copy(s2, Length(s1) + 1, Length(s2));

    Repeat
      i := Pos(#13#10, s2);
      if i <> 0 then
      begin
        Delete(s2, i, 1);
        s2[i] := ' ';
      end;
    until i = 0;

    cstrings.AddString(f + '_TEXT_00', s1);
    cstrings.AddString(f + '_TEXT_01', s2);
  end;

  li := LVSeqs.Items[n];
  li.SubItems.clear;

  With jkr do
  begin
    li.Caption := IntToStr(lnum) + ':';
    li.SubItems.Add(fname);
    li.SubItems.Add(IntToStr(levnum));
    li.SubItems.Add(IntToStr(gotoA));
    li.SubItems.Add(IntToStr(gotoB));
  end;

end;

procedure TEpisodeEdit.BNUpdateClick(Sender: TObject);
var
  i: integer;
begin
  if recs = nil then
    exit;
  if LVSeqs.Selected = nil then
    exit;
  i := LVSeqs.Selected.Index;
  CommitSeq(i);
end;

procedure TEpisodeEdit.LVSeqsChanging(Sender: TObject; Item: TListItem;
  Change: TItemChange; var AllowChange: Boolean);
var
  i: integer;
begin
  AllowChange := true;
  if Change <> ctState then
    exit;
end;

procedure TEpisodeEdit.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := true;
  if not AskSave then
    exit;
  case MsgBox('Save Episode?', 'Episode Editor', MB_YESNOCANCEL) of
    ID_YES:
      ModalResult := mrOK;
    ID_NO:
      ModalResult := mrCancel;
    ID_Cancel:
      CanClose := false;
  end;
end;

procedure TEpisodeEdit.FormShow(Sender: TObject);
begin
  AskSave := true;
end;

procedure TEpisodeEdit.BNSaveClick(Sender: TObject);
begin
  AskSave := false;
  ModalResult := mrOK;
  Hide;
end;

procedure TEpisodeEdit.BNCancelClick(Sender: TObject);
begin
  AskSave := false;
  ModalResult := mrCancel;
  Hide;
end;

end.
