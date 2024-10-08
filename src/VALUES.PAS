unit values;

interface

uses Classes, SysUtils;

type
  v_type = (vt_str, vt_int, vt_float, vt_flag, vt_ptr, vt_vect,
    vt_frame, vt_unk);
  tcog_type = (ct_unk, ct_ai, ct_cog, ct_key, ct_mat, ct_msg, ct_3do, ct_sec,
    ct_wav, ct_srf, ct_tpl, ct_thg, ct_int, ct_float, ct_vect);
  TAdjType = (at_unk, at_mat, at_cog, at_snd, at_pup, at_spr, at_par, at_3do,
    at_ai, at_tpl, at_frame);
  { ai
    cog
    flex
    float
    int
    keyframe
    material
    message
    model
    sector
    sound
    surface
    template
    thing
    vector }

  TValue = class
    name: string;
    vtype: v_type;
    int: longint;
    float: double;
    s: string;
    Function AsString: String;
    Function Clone: TValue;
    Function Val(const s: string): boolean;
    Procedure Assign(v: TValue);
  end;

  TValues = class(TList)
    Function GetItem(n: integer): TValue;
    Procedure SetItem(n: integer; v: TValue);
    Function IndexOfName(const Name: string): integer;
    Property Items[n: integer]: TValue read GetItem write SetItem; default;
  end;

  TCOGValue = class(TValue)
    cog_type: tcog_type;
    local: boolean;
    desc: String;
    mask: longint;
    obj: TObject;
    Function AsString: String;
    Function AsJedString: String;
    Procedure Assign(cv: TCOGValue);
    Function Val(const s: string): boolean;
    Function JedVal(const s: string): boolean;
    Procedure Resolve;
  end;

  TCOGValues = class(TValues)
    Function GetItem(n: integer): TCOGValue;
    Procedure SetItem(n: integer; v: TCOGValue);
    Property Items[n: integer]: TCOGValue read GetItem write SetItem; default;
  end;

  TTplValue = class(TValue)
    atype: TAdjType;
    Procedure Assign(v: TTplValue); overload;
    Function Clone: TTplValue; overload;
    Procedure GetFrame(var x, y, z, pch, yaw, rol: double);
    Procedure SetFrame(x, y, z, pch, yaw, rol: double);
  end;

  TTPLValues = class(TValues)
    Function GetItem(n: integer): TTplValue;
    Procedure SetItem(n: integer; v: TTplValue);
    Property Items[n: integer]: TTplValue read GetItem write SetItem; default;
  end;

Function GetCogType(const stype: string): tcog_type;
Function GetCogVType(const stype: string): v_type;
Function GetVTypeFromCOGType(vtype: tcog_type): v_type;

Function GetTplVType(const Name: string): v_type;
Function GetTplType(const Name: string): TAdjType;

Procedure S2TPLVal(const s: string; v: TTplValue);
Procedure S2CogVal(const s: string; v: TCOGValue);

Function GetCOGVal(const st: string; v: TCOGValue): boolean;
Function GetJedVal(const st: string; v: TCOGValue): boolean;

Function GetCogTypeName(ct: tcog_type): String;

Procedure InitValues;

implementation

uses Misc_utils, J_Level;

var
  CogTypes, CogVtypes, tplNames, TplVtypes: TStringList;

Function GetCogTypeName(ct: tcog_type): String;
var
  n: integer;
begin
  n := CogTypes.IndexOfObject(TObject(ct));
  if n = -1 then
    result := 'unknown'
  else
    result := CogTypes[n];
end;

Function GetCogType(const stype: string): tcog_type;
var
  n: integer;
begin
  n := CogTypes.IndexOf(stype);
  if n = -1 then
    result := ct_unk
  else
    result := tcog_type(CogTypes.Objects[n]);
end;

Function GetVTypeFromCOGType(vtype: tcog_type): v_type;
begin
  case vtype of
    ct_unk:
      result := vt_unk;
    ct_ai, ct_cog, ct_key, ct_mat, ct_msg, ct_3do, ct_wav, ct_tpl:
      result := vt_str;
    ct_sec, ct_srf, ct_thg:
      result := vt_ptr;
    ct_int:
      result := vt_int;
    ct_float:
      result := vt_float;
    ct_vect:
      result := vt_vect;
  else
    result := vt_unk;
  end;
end;

Function GetCogVType(const stype: string): v_type;
var
  n: Integer;
begin
  n := CogVtypes.IndexOf(stype);
  if n = -1 then
    result := vt_unk
  else
    result := v_type(CogVtypes.Objects[n]);
end;

Function GetTplVType(const Name: string): v_type;
var
  n: integer;
begin
  n := TplVtypes.IndexOf(name);
  if n = -1 then
    result := vt_str
  else
    result := v_type(TplVtypes.Objects[n]);
end;

Function GetTplType(const Name: string): TAdjType;
var
  n: integer;
begin
  n := tplNames.IndexOf(name);
  if n = -1 then
    result := at_unk
  else
    result := TAdjType(tplNames.Objects[n]);
end;

Function GetCOGVal(const st: string; v: TCOGValue): boolean;
var
  w: string;
  p, pe: Integer;
begin
  result := false;
  p := GetWord(st, 1, w);
  if w = '' then
    exit;
  v.vtype := GetCogVType(w);
  v.cog_type := GetCogType(w);
  p := GetWord(st, p, w);

  pe := Pos('=',  w);
  if pe = 0 then
    v.Name := w
  else
  begin
    v.Name := Copy(w, 1, pe - 1);
    v.Val(Copy(w, pe + 1, length(w)));
  end;

  while p < Length(st) do
  begin
    p := GetWord(st, p, w);
    if w = '' then
      continue;
    if CompareText(w, 'local') = 0 then
      v.local := true;
  end;

end;

Function GetJedVal(const st: string; v: TCOGValue): boolean;
var
  pe, ps: Integer;
  w: string;
begin
  ps := Pos(':', st);
  pe := Pos('=', st);
  v.Name := Copy(st, 1, ps - 1);
  w := Copy(st, ps + 1, pe - ps - 1);
  v.vtype := GetCogVType(w);
  v.cog_type := GetCogType(w);
  v.Val(Copy(st, pe + 1, Length(st)));
end;

Function TCOGValue.AsJedString: String;
begin
  case cog_type of
    ct_srf:
      begin
        if obj = nil then
        begin
          result := '-1';
          exit;
        end;
        With TJKSUrface(obj) do
          result := Format('%d %d', [sector.num, num]);
        exit;
      end;
  end;
  result := AsString;
end;

Function TCOGValue.AsString: String;
begin
  case cog_type of
    ct_srf, ct_sec, ct_thg:
      if obj = nil then
      begin
        result := '-1';
        exit;
      end;
  end;

  case cog_type of
    ct_sec:
      result := IntToStr(TJKSector(obj).num);
    ct_srf:
      with TJKSUrface(obj) do
        result := IntToStr(sector.level.GetGlobalSFN(sector.num,
          sector.surfaces.IndexOf(obj)));
    ct_thg:
      result := IntToStr(TJKThing(obj).num);
  else
    result := Inherited AsString;
  end;
end;

Procedure TCOGValue.Assign(cv: TCOGValue);
begin
  Name := cv.Name;
  cog_type := cv.cog_type;
  vtype := cv.vtype;
  desc  := cv.desc;
  local := cv.local;
end;

Procedure TCOGValue.Resolve;
begin
  case cog_type of
    ct_sec:
      obj := level.GetSectorN(int);
    ct_srf:
      obj := level.GetSurfaceN(int);
    ct_thg:
      obj := level.GetThingN(int);
  else
    exit;
  end;
  if (obj = nil) and (int <> -1) then
    PanMessageFmt(mt_warning, 'Cog parameter resolution failed: no %s num: %d',
      [GetCogTypeName(cog_type), int]);
end;

Function TCOGValue.Val(const s: string): boolean;
var
  d: longint;
begin
  Case cog_type of
    ct_sec, ct_srf, ct_thg:
      result := ValDword(s, int);
  else
    result := Inherited Val(s);
  end;
end;

Function TCOGValue.JedVal(const s: string): boolean;
var
  i, p: integer;
  w: string;
begin
  result := false;
  case cog_type of
    ct_srf:
      begin
        p := GetWord(s, 1, w);
        result := ValInt(w, i);
        if not result then
          exit;
        if i < 0 then
        begin
          obj := nil;
          exit;
        end;

        GetWord(s, p, w);
        result := ValInt(w, p);
        if not result then
          exit;
        try
          obj := level.sectors[i].surfaces[p];
        except
          On Exception do
            result := false;
        end;
      end;
    ct_sec, ct_thg:
      begin
        result := ValInt(s, i);
        if not result then
          exit;
        if i < 0 then
        begin
          obj := nil;
          exit;
        end;
        case cog_type of
          ct_sec:
            begin
              if i < level.sectors.Count then
                obj := level.sectors[i]
              else
                result := false;
            end;
          ct_thg:
            begin
              if i < level.things.Count then
                obj := level.things[i]
              else
                result := false;
            end;
        end;
      end;
  else
    result := Val(s);
  end;
end;

Procedure TTplValue.Assign(v: TTplValue);
begin
  Inherited Assign(v);
  atype := v.atype;
end;

Function TTplValue.Clone: TTplValue;
begin
  Result := TTplValue.Create;
  Result.Assign(self);
end;

Procedure TTplValue.GetFrame(var x, y, z, pch, yaw, rol: double);
var
  vs: string;
  i: integer;
begin
  x := 0;
  y := 0;
  z := 0;
  pch := 0;
  yaw := 0;
  rol := 0;
  vs := s;
  for i := 1 to length(vs) do
    if vs[i] in ['/', ':', '(', ')'] then
      vs[i] := ' ';
  SScanf(vs, '%f %f %f %f %f %f', [@x, @y, @z, @pch, @yaw, @rol]);
end;

Procedure TTplValue.SetFrame(x, y, z, pch, yaw, rol: double);
begin
  if CompareText(name, 'frame') <> 0 then
    exit;
  s := Sprintf('(%1.6f/%1.6f/%1.6f:%1.6f/%1.6f/%1.6f)', [x, y, z, pch, yaw, rol]);
end;

Function TValue.AsString: String;
begin
  case vtype of
    vt_str, vt_unk:
      result := s;
    vt_vect, vt_frame:
      result := s;
    vt_int, vt_ptr:
      result := IntToStr(int);
    vt_float:
      result := FloatToStr(float, TFormatSettings.Invariant);
    vt_flag:
      result := Format('0x%x', [int]);
  else
    result := '';
  end;
end;

Function TValue.Clone: TValue;
begin
  Result := TValue.Create;
  Result.Assign(self);
end;

Function TValue.Val(const s: string): boolean;
begin
  result := true;
  case vtype of
    vt_str, vt_unk:
      self.s := s;
    vt_vect, vt_frame:
      self.s := s;
    vt_int, vt_ptr:
      result := ValDword(s, int);
    vt_float:
      result := ValDouble(s, float);
    vt_flag:
      result := ValHex(s, int);
  else
    result := false;
  end;
end;

Procedure TValue.Assign;
begin
  Name := v.Name;
  vtype := v.vtype;
  int := v.int;
  float := v.float;
  s := v.s;
end;

Function TValues.GetItem(n: integer): TValue;
begin
  if (n < 0) or (n >= Count) then
    raise EListError.CreateFmt('Value Index is out of bounds: %d', [n]);
  result := TValue(List[n]);
end;

Procedure TValues.SetItem(n: integer; v: TValue);
begin
  if (n < 0) or (n >= Count) then
    raise EListError.CreateFmt('Value Index is out of bounds: %d', [n]);
  List[n] := v;
end;

Function TValues.IndexOfName(const Name: string): integer;
var
  i: integer;
begin
  result := -1;
  for i := 0 to Count - 1 do
  begin
    if CompareText(name, Items[i].Name) <> 0 then
      continue;
    result := i;
    break;
  end;
end;

Function TCOGValues.GetItem(n: integer): TCOGValue;
begin
  if (n < 0) or (n >= Count) then
    raise EListError.CreateFmt('Value Index is out of bounds: %d', [n]);
  result := TCOGValue(List[n]);
end;

Procedure TCOGValues.SetItem(n: integer; v: TCOGValue);
begin
  if (n < 0) or (n >= Count) then
    raise EListError.CreateFmt('Value Index is out of bounds: %d', [n]);
  List[n] := v;
end;

Function TTPLValues.GetItem(n: integer): TTplValue;
begin
  if (n < 0) or (n >= Count) then
    raise EListError.CreateFmt('Value Index is out of bounds: %d', [n]);
  result := TTplValue(List[n]);
end;

Procedure TTPLValues.SetItem(n: integer; v: TTplValue);
begin
  if (n < 0) or (n >= Count) then
    raise EListError.CreateFmt('Value Index is out of bounds: %d', [n]);
  List[n] := v;
end;

Procedure S2TPLVal(const s: string; v: TTplValue);
var
  p: integer;
begin
  p := Pos('=', s);
  v.Name := Copy(s, 1, p - 1);
  v.vtype := GetTplVType(v.Name);
  v.atype := GetTplType(v.Name);

  var vs := Copy(s, p + 1, length(s));
  if not v.Val(vs) then
    begin
      PanMessageFmt(mt_warning,'Template parameter ''%s'' has invalid value: %s', [v.Name, vs]);
      // TODO: should assign string?
    end;
end;

Procedure S2CogVal(const s: string; v: TCOGValue);
var
  p: integer;
begin
  p := Pos('=', s);
  v.Name := Copy(s, 1, p - 1);
  v.vtype := vt_str;
  v.s := Copy(s, p + 1, length(s));
end;

Procedure InitValues;
begin
  CogTypes := TStringList.Create;
  CogTypes.Sorted := true;
  with CogTypes Do
  begin
    AddObject('ai', TObject(ct_ai));
    AddObject('cog', TObject(ct_cog));
    AddObject('keyframe', TObject(ct_key));
    AddObject('material', TObject(ct_mat));
    AddObject('message', TObject(ct_msg));
    AddObject('model', TObject(ct_3do));
    AddObject('sector', TObject(ct_sec));
    AddObject('sound', TObject(ct_wav));
    AddObject('surface', TObject(ct_srf));
    AddObject('template', TObject(ct_tpl));
    AddObject('thing', TObject(ct_thg));
    AddObject('int', TObject(ct_int));
    AddObject('float', TObject(ct_float));
    AddObject('flex', TObject(ct_float));
    AddObject('vector', TObject(ct_vect));
  end;

  CogVtypes := TStringList.Create;
  CogVtypes.Sorted := true;
  with CogVtypes do
  begin
    AddObject('flex', TObject(vt_float));
    AddObject('float', TObject(vt_float));
    AddObject('vector', TObject(vt_vect));
    AddObject('int', TObject(vt_int));

    AddObject('ai', TObject(vt_str));
    AddObject('cog', TObject(vt_int));
    AddObject('keyframe', TObject(vt_str));
    AddObject('material', TObject(vt_str));
    AddObject('message', TObject(vt_str));
    AddObject('model', TObject(vt_str));
    AddObject('sector', TObject(vt_ptr));
    AddObject('sound', TObject(vt_str));
    AddObject('surface', TObject(vt_ptr));
    AddObject('template', TObject(vt_str));
    AddObject('thing', TObject(vt_ptr));
  end;

  tplNames := TStringList.Create;
  tplNames.Sorted := true;
  with tplNames do
  begin
    AddObject('material', TObject(at_mat));
    AddObject('cog', TObject(at_cog));
    AddObject('soundclass', TObject(at_snd));
    AddObject('puppet', TObject(at_pup));
    AddObject('sprite', TObject(at_spr));
    AddObject('particle', TObject(at_par));
    AddObject('model3d', TObject(at_3do));
    AddObject('aiclass', TObject(at_ai));

    AddObject('creatething', TObject(at_tpl));
    AddObject('explode', TObject(at_tpl));
    AddObject('fleshhit', TObject(at_tpl));
    AddObject('weapon', TObject(at_tpl));
    AddObject('weapon2', TObject(at_tpl));
    AddObject('debris', TObject(at_tpl));
    AddObject('trailthing', TObject(at_tpl));
    AddObject('frame', TObject(at_frame));
  end;

  TplVtypes := TStringList.Create;
  TplVtypes.Sorted := true;
  with TplVtypes do
  begin
    AddObject('frame', TObject(vt_frame));
    AddObject('thingflags', TObject(vt_flag));
  end;
end;

Initialization

Finalization

begin
  CogTypes.Free;
  CogVtypes.Free;
  tplNames.Free;
end;

end.
