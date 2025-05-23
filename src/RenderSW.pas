unit RenderSW;

interface

{ This unit contains a Software implementation
  of TRenderer class }

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  GlobalVars, Geometry, Render, StdCtrls, misc_utils;

Const
  lTblSize = 128;

Type
  TSFTRenderer = class(TRenderer)
    wnd: HWND;
    // hdc:HDC;
    Dc: TCanvas;
    { mode:TRenderStyle; }
    docull: boolean;
    cull_front: boolean;
    mx: TMat3x3s;
    rmx: TMat3x3s; { Reverse matrix }
    cdx, cdy, cdz: single;

    bm: TBitmap;
    wcx, wcy: integer;
    wx1, wy1, wx2, wy2: single;
    halfpsize, psizeodd: integer;

    px1, px2, py1, py2: single; { Picking line }
    { Picking vars }
    pkX1, pkY1, pkZ1, pkX2, pkY2, pkZ2: double; { picking line }
    pkv: TVector;
    pdist, pdist2: double;

    curx, cury: single; { MoveTo/LineTo vars }

    Procedure Initialize; override;
    Procedure BeginScene; override;
    Procedure SetViewPort(x, y, w, h: integer); override;
    { Procedure SetRenderStyle(rstyle:TRenderStyle);override; }
    Procedure SetColor(what, r, g, b: byte); override;
    Procedure EndScene; override;

    Function GetPointSize: double; override;
    Procedure SetPointSize(size: double); override;
    Procedure SetCulling(how: integer); override;
    Procedure DrawPolygon(p: TPolygon); override;
    Procedure DrawPolygons(ps: TPolygons); override;
    Procedure DrawPolygonsAt(ps: TPolygons;
      dx, dy, dz, pch, yaw, rol: double); override;
    Procedure DrawLine(v1, v2: TVertex); overload; override;
    Procedure DrawLine(p1, p2: TVector); overload; override;
    Procedure DrawLine(p, direction: TVector; length: double); overload; override;
    Procedure DrawLineAt(x1, y1, z1, x2, y2, z2: double); overload; override;
    Procedure DrawLineAt(x, y, z: double; direction: TVector; length: double); overload; override;
    Procedure DrawVertex(x, y, Z: double); override;
    Procedure DrawCircle(cx, cy, cz, rad: double); override;
    Procedure DrawVertices(vxs: TVertices); override;
    Destructor Destroy; override;

    Procedure BeginPick(x, y: integer); override;
    Procedure EndPick; override;
    Procedure PickPolygon(p: TPolygon; id: integer); override;
    Procedure PickPolygons(ps: TPolygons; id: integer); override;
    Procedure PickPolygonsAt(ps: TPolygons; x, y, z, pitch, yaw, roll: double; id: integer); override;
    Procedure PickLine(v1, v2: TVertex; id: integer); override;
    Procedure PickVertex(x, y, Z: double; id: integer); override;

    Function GetCameraAt(scX, scY: integer; var x, y, z: double): boolean; override;
    Function GetXYZonPlaneAt(scX, scY: integer; pnormal: TVector;
      pX, pY, pZ: double; var x, y, Z: double): boolean; override;
    Function GetGridAt(scX, scY: integer; var x, y, Z: double)
      : boolean; override;

    Function GetCameraForward: TVector; override; // returns camera forward vector
    Function GetCameraUp: TVector; override; // returns camera up vector
    Function GetCameraRight: TVector; override;

    Procedure ProjectPoint(x, y, Z: double; Var WinX, WinY: integer); override;
    Procedure UnProjectPoint(WinX, WinY: double; WinZ: double;
      var x, y, Z: double); override;
    Function HandleWMQueryPal: integer; override;
    Function HandleWMChangePal: integer; override;
    Function IsPolygonFacing(p: TPolygon): boolean; override;
  Private
    Procedure SetCamera;
    Procedure SetRenderMatrix;
    { Procedure SetPickMatrix(x,y:integer); }
    Procedure RenderPoly(p: TPolygon);
    Procedure RenderLine(v1, v2: TVertex);
    Function IsPolyPicked(p: TPolygon): boolean;
    Procedure MoveTo(x, y: single); { Does clipping }
    Procedure LineTo(x, y: single);
  end;

implementation

uses Jed_Main, Lev_utils, math;

procedure DisableFPUExceptions;
var
  FPUControlWord: WORD;
  asm
    FSTCW   FPUControlWord ;
    OR      FPUControlWord, $4 + $1 ; { Divide by zero + invalid operation }
    FLDCW   FPUControlWord ;
end;

Procedure TSFTRenderer.BeginScene;
var
  pen: Hpen;
begin
  With bgnd_clr do
    SetColor(CL_BACKGROUND, r, g, b);

  // pen:=CreatePen(PS_SOLID,1,RGB(

  Dc.pen.Mode := pmCopy;
  Dc.Brush.Style := bsSolid;

  DisableFPUExceptions;
  SetRenderMatrix;
  Dc.Rectangle(0, 0, vpw, vph);
end;

{ Procedure TSFTRenderer.SetRenderStyle;
  begin
  Case rstyle of
  DRAW_WIREFRAME: begin
  end;
  DRAW_FLAT_POLYS:;
  DRAW_TEXTURED: ;
  DRAW_VERTICES: ;
  end;
  R_Style:=rstyle;
  end; }

Procedure TSFTRenderer.EndScene;
var
  Dch: HDC;
begin
  if bm <> nil then
  begin
    Dch := GetDC(hViewer);
    Windows.BitBlt(Dch, 0, 0, bm.width, bm.height, bm.canvas.handle, 0,
      0, SRCCOPY);
    // Viewer.Canvas.Draw(0,0,bm);
    ReleaseDC(hViewer, Dch);
  end;
end;

Procedure TSFTRenderer.SetCamera;
{ var xscale,yscale,zscale:double; }
var
  v: record x, y, Z: single end;
begin
  { CreateRotMatrixs(mx,-pch,-yaw,-rol); }
  { mx[0,0]:=xv.dx; mx[1,0]:=xv.dy; mx[0,2]:=xv.dz;
    mx[0,1]:=yv.dx; mx[1,1]:=yv.dy; mx[1,2]:=yv.dz;
    mx[0,2]:=zv.dx; mx[1,2]:=zv.dy; mx[2,2]:=zv.dz; }

  { mx[0,0]:=-xv.dx; mx[1,0]:=-yv.dx; mx[0,2]:=-zv.dx;
    mx[0,1]:=-xv.dy; mx[1,1]:=-yv.dy; mx[1,2]:=-zv.dy;
    mx[0,2]:=-xv.dz; mx[1,2]:=-yv.dz; mx[2,2]:=-zv.dz; }

  mx[0, 0] := xv.dx;
  mx[1, 0] := -yv.dx;
  mx[2, 0] := -zv.dx;
  mx[0, 1] := xv.dy;
  mx[1, 1] := -yv.dy;
  mx[2, 1] := -zv.dy;
  mx[0, 2] := xv.dz;
  mx[1, 2] := -yv.dz;
  mx[2, 2] := -zv.dz;

  rmx[0, 0] := mx[0, 0];
  rmx[0, 1] := mx[1, 0];
  rmx[0, 2] := mx[2, 0];
  rmx[1, 0] := mx[0, 1];
  rmx[1, 1] := mx[1, 1];
  rmx[1, 2] := mx[2, 1];
  rmx[2, 0] := mx[0, 2];
  rmx[2, 1] := mx[1, 2];
  rmx[2, 2] := mx[2, 2];

end;

Procedure TSFTRenderer.SetRenderMatrix;
var
  dpx, dpy: single;
begin
  SetCamera;
  { dpx:=vpw/(ppunit*scale);
    dpy:=vph/vpw*dpx;

    dpx:=vpw/ppunit*scale;
    dpy:=vph/vpw*dpx; }

//  dpx := ppunit /  1/(3* dpiScale) ;
    dpx :=  ppunit * dpiScale;
  //dpy := vph / vpw * dpx;

  ScaleMatrixs(mx, dpx, dpx, dpx);

  { dpx:=1/(16*scale);

    ScaleMatrixs(rmx,dpx,dpx,dpx); }

  cdx := { dpx*- } CamX;
  cdy := { dpx*- } CamY;
  cdz := { dpx*- } CamZ;
end;

{ Procedure TSFTRenderer.SetPickMatrix(x,y:integer);
  var dpx,dpy:single;
  begin
  SetCamera;
  dpx:=vpw/(ppunit*scale);
  dpy:=vph/vpw*dpx;
  ScaleMatrixs(mx,dpx,dpy,dpx);

  end; }

Procedure TSFTRenderer.Initialize;
var
  r: TRect;
begin
  wnd := hViewer;
  vpx := 0;
  vpy := 0;
  if WF_DoubleBuf then { create double buffer }
  begin
    bm := TBitmap.Create;
    Dc := bm.canvas;
  end
  else
  begin
    Dc := TCanvas.Create;
    Dc.handle := GetDC(hViewer); { Viewer.Canvas; } end;

  GetClientRect(hViewer, r);
  SetViewPort(r.right, r.top, r.right - r.left, r.bottom - r.top);

  // SetViewPort(0,0,Viewer.ClientWidth,Viewer.ClientHeight);

  { bm:=TBitMap.Create;
    bm.width:=vpw;
    bm.height:=vph; }

  { Dc:=bm.Canvas; }
  Dc.Brush.Color := 0;
end;

Procedure TSFTRenderer.SetViewPort(x, y, w, h: integer);
begin
  Inherited SetViewPort(x, y, w, h);
  wcx := w div 2;
  wcy := h div 2;
  wx1 := -w / 2;
  wx2 := w / 2;
  wy1 := -h / 2;
  wy2 := h / 2;
  if bm <> nil then
  begin
    bm.width := w;
    bm.height := h;
  end;
end;

Function TSFTRenderer.IsPolygonFacing(p: TPolygon): boolean;
var
  dx, dy, dz: single;
begin
  dx := p.normal.dx;
  dy := p.normal.dy;
  dz := p.normal.dz;
  MultVM3s(mx, dx, dy, dz);
  { Smult dx,dy,dz on 0,-1,0
    Basically - check dy }

  Result := dz < 0;
end;

Procedure TSFTRenderer.DrawPolygon(p: TPolygon);
begin
  if docull and (IsPolygonFacing(p) <> cull_front) then
    exit;
  RenderPoly(p);
end;

Procedure TSFTRenderer.DrawPolygonsAt(ps: TPolygons;
  dx, dy, dz, pch, yaw, rol: double);
var
  i, j, n: integer;
  rmx: TMat3x3s;
  vx, vy, vz: single;
  shx, shy, shz: single;
  p: TPolygon;
  x0, y0: single;
  v: TVertex;
begin
  CreateRotMatrixs(rmx, pch, yaw, rol);
  for j := 0 to ps.count - 1 do
  begin
    p := ps[j];
    for i := 0 to p.Vertices.count - 1 do
    begin
      v := p.Vertices[i];

      vx := v.x;
      vy := v.y;
      vz := v.Z;
      MultVM3s(rmx, vx, vy, vz);
      vx := vx + cdx + dx;
      vy := vy + cdy + dy;
      vz := vz + cdz + dz;

      { vx:=vx+dx; vy:=vy+dy; vz:=vz+dz; }
      MultVM3s(mx, vx, vy, vz);
      { vx:=vx;
        vy:=vy;
        vz:=vz; }

      if i = 0 then
      begin
        MoveTo(vx, vy);
        x0 := vx;
        y0 := vy;
      end
      else
        LineTo(vx, vy);
      LineTo(vx, vy);
    end;
    if p.Vertices.count > 0 then
      LineTo(x0, y0);

  end;
end;

Procedure TSFTRenderer.DrawPolygons(ps: TPolygons);
var
  i: integer;
begin
  for i := 0 to ps.count - 1 do
    DrawPolygon(ps[i]);
end;

{ Procedure TSFTRenderer.DrawPolygons(ps:TPolygons);
  var vx,vy,vz:single;
  i,j:integer;
  v:TVertex;
  x0,y0,x,y:integer;
  p:TPolygon;
  begin
  fillchar(lineTbl,sizeof(lineTbl),0);

  for j:=0 to ps.count-1 do
  begin
  p:=ps[j];

  for i:=0 to p.Vertices.count-1 do
  begin
  v:=p.vertices[i];
  vx:=v.x; vy:=v.y; vz:=v.z;
  MultVM3s(mx,vx,vy,vz);
  vx:=CamX+vx;
  vy:=CamY+vy;
  vz:=CamZ+vz;
  x:=wcx+round(vx);
  y:=wcy+Round(vy);
  if i=0 then begin DC.MoveTo(x,y); x0:=x; y0:=y; end
  else DC.LineTo(x,y);
  DC.LineTo(x,y);
  end;
  if p.Vertices.count>0 then DC.LineTo(x0,y0);
  end;

  end; for j:=

  end; }

Procedure TSFTRenderer.RenderPoly(p: TPolygon);
var
  vx, vy, vz: single;
  i: integer;
  v: TVertex;
  x0, y0: single;
begin
  for i := 0 to p.Vertices.count - 1 do
  begin
    v := p.Vertices[i];
    vx := cdx + v.x;
    vy := cdy + v.y;
    vz := cdz + v.Z;
    MultVM3s(mx, vx, vy, vz);

    { vx:=cdx+vx;
      vy:=cdy+vy;
      vz:=cdz+vz; }

    { Project }

    { if vz<1 then continue;
      x:=wcx+round(vx/vz);
      y:=wcy+Round(vy/vz); }

    if i = 0 then
    begin
      MoveTo(vx, vy);
      x0 := vx;
      y0 := vy;
    end
    else
      LineTo(vx, vy);
    LineTo(vx, vy);
  end;
  if p.Vertices.count > 0 then
    LineTo(x0, y0);
end;

Procedure TSFTRenderer.DrawCircle(cx, cy, cz, rad: double);
var
  vx, vy, vz: single;
  vx1, vy1, vz1: single;
  pX, pY: integer;
  rint: integer;
begin
  vx := cdx + cx;
  vy := cdy + cy;
  vz := cdz + cz;
  MultVM3s(mx, vx, vy, vz);
  { Project }
  pX := wcx + round(vx);
  pY := wcy + round(vy);

  vx1 := rad;
  vy1 := 0;
  vz1 := 0;
  MultVM3s(mx, vx1, vy1, vz1);

  rint := round(sqrt(sqr(vx1) + sqr(vy1) + sqr(vz1)));

  Dc.Brush.Style := bsClear;
  Dc.Ellipse(pX - rint, pY - rint, pX + rint, pY + rint);
  Dc.Brush.Style := bsSolid;
end;

Procedure TSFTRenderer.DrawVertex(x, y, Z: double);
var
  vx, vy, vz: single;
  pX, pY: integer;
begin
  vx := cdx + x;
  vy := cdy + y;
  vz := cdz + Z;
  MultVM3s(mx, vx, vy, vz);
  { vx:=vx;
    vy:=vy;
    vz:=vz; }
  { Project }
  pX := wcx + round(vx);
  pY := wcy + round(vy);

  { if vz<1 then exit;
    px:=wcx+round(vx/vz);
    py:=wcy+Round(vy/vz); }

  if halfpsize = 0 then
    Dc.Pixels[pX, pY] := Dc.pen.Color
  else
    Dc.Ellipse(pX - halfpsize, pY - halfpsize, pX + halfpsize + psizeodd,
      pY + halfpsize + psizeodd);
end;

Procedure TSFTRenderer.DrawVertices(vxs: TVertices);
var
  i: integer;
  vx, vy, vz: single;
  pX, pY: integer;
begin
  for i := 0 to vxs.count - 1 do
    With vxs[i] do
    begin
      vx := cdx + x;
      vy := cdy + y;
      vz := cdz + Z;
      MultVM3s(mx, vx, vy, vz);
      { vx:=vx;
        vy:=vy;
        vz:=vz; }
      { Project }
      pX := wcx + round(vx);
      pY := wcy + round(vy);

      { if vz<1 then exit;
        px:=wcx+round(vx/vz);
        py:=wcy+Round(vy/vz); }

      if halfpsize = 0 then
        Dc.Pixels[pX, pY] := Dc.pen.Color
      else
        Dc.Rectangle(pX - halfpsize, pY - halfpsize, pX + halfpsize + psizeodd,
          pY + halfpsize + psizeodd);
    end;
end;

Procedure TSFTRenderer.RenderLine(v1, v2: TVertex);
begin
end;

Procedure TSFTRenderer.DrawLine(v1, v2: TVertex);
//var
  //vx, vy, vz: single;
begin
   DrawLineAt(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
//  vx := cdx + v1.x;
//  vy := cdy + v1.y;
//  vz := cdz + v1.Z;
//  MultVM3s(mx, vx, vy, vz);
//  { vx:=vx;
//    vy:=vy;
//    vz:=vz; }
//
//  { Project }
//  { if vz<1 then exit;
//    px:=wcx+round(vx/vz);
//    py:=wcy+Round(vy/vz); }
//
//  MoveTo(vx, vy);
//  vx := cdx + v2.x;
//  vy := cdy + v2.y;
//  vz := cdz + v2.Z;
//  MultVM3s(mx, vx, vy, vz);
//  { vx:=vx;
//    vy:=vy;
//    vz:=vz; }
//
//  { Project }
//  { px:=wcx+round(vx);
//    py:=wcy+Round(vy); }
//  { if vz<1 then exit;
//    px:=wcx+round(vx/vz);
//    py:=wcy+Round(vy/vz); }
//
//  LineTo(vx, vy);
end;

Procedure TSFTRenderer.DrawLine(p1, p2: TVector);
begin
  DrawLineAt(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z);
end;

Procedure TSFTRenderer.DrawLine(p, direction: TVector; length: double);
begin
  DrawLineAt(p.x, p.y, p.z, direction, length);
end;

Procedure TSFTRenderer.DrawLineAt(x1, y1, z1, x2, y2, z2: double);
  var
  vx, vy, vz: single;
begin
  vx := cdx + x1;
  vy := cdy + y1;
  vz := cdz + z1;
  MultVM3s(mx, vx, vy, vz);
  { vx:=vx;
    vy:=vy;
    vz:=vz; }

  { Project }
  { if vz<1 then exit;
    px:=wcx+round(vx/vz);
    py:=wcy+Round(vy/vz); }

  MoveTo(vx, vy);
  vx := cdx + x2;
  vy := cdy + y2;
  vz := cdz + z2;
  MultVM3s(mx, vx, vy, vz);
  { vx:=vx;
    vy:=vy;
    vz:=vz; }

  { Project }
  { px:=wcx+round(vx);
    py:=wcy+Round(vy); }
  { if vz<1 then exit;
    px:=wcx+round(vx/vz);
    py:=wcy+Round(vy/vz); }

  LineTo(vx, vy);
end;

Procedure TSFTRenderer.DrawLineAt(x, y, z: double; direction: TVector; length: double);
begin
  DrawLineAt(x, y, z, x + direction.x * length, y + direction.y * length, z + direction.z * length);
end;

Destructor TSFTRenderer.Destroy;
begin
  bm.Free;
  Inherited Destroy;
end;

Procedure TSFTRenderer.BeginPick(x, y: integer);
var
  ax, ay, az: double;
begin
  DisableFPUExceptions;
  SetRenderMatrix;
  Selected.Clear;
  UnProjectPoint(x, y, 0, pkX1, pkY1, pkZ1);
  UnProjectPoint(x, y, 1, pkX2, pkY2, pkZ2);

  pkv.SetCoords(pkX2 - pkX1, pkY2 - pkY1, pkZ2 - pkZ1);
  pkv.Normalize; //Normalize(pkv);

  UnProjectPoint(x + 2, y + 2, 0, ax, ay, az);
  pdist2 := sqr(ax - pkX1) + sqr(ay - pkY1) + sqr(az - pkZ1);
  pdist := sqrt(pdist2);
end;

Procedure TSFTRenderer.EndPick;
begin

end;

Function TSFTRenderer.IsPolyPicked(p: TPolygon): boolean;
var
  i: integer;
  en: TVector; { edge normal }
  v1, v2: TVertex;
  d: double;
  ix, iy, iz: double;
begin
  Result := false;
  if p.Vertices.count < 2 then
    exit;
  With p.Vertices[0] do
    if not PlaneLineXnNew(p.normal, x, y, Z, pkX1, pkY1, pkZ1, pkX2, pkY2, pkZ2,
      ix, iy, iz) then
      exit;

  for i := 0 to p.vertices.count - 1 do
  begin
    v1 := p.Vertices[i];
    v2 := p.Vertices[p.NextVX(i)];
    en := p.normal.Cross(v2.x - v1.x, v2.y - v1.y, v2.z - v1.z);
//    VMult(p.normal.dx, p.normal.dy, p.normal.dz, v2.x - v1.x, v2.y - v1.y,
//      v2.Z - v1.Z, en.dx, en.dy, en.dz);
    if en.Normalize = 0 then
      continue;
    if en.Dot(ix - v1.x, iy - v1.y, iz - v1.z) < -pdist then {SMult(en.dx, en.dy, en.dz, ix - v1.x, iy - v1.y, iz - v1.Z)}
      exit;
  end;
  Result := true;
end;

Procedure TSFTRenderer.PickPolygon(p: TPolygon; id: integer);
begin
  if IsPolyPicked(p) then
    Selected.Add(id);
end;

Procedure TSFTRenderer.PickPolygons(ps: TPolygons; id: integer);
var
  i: integer;
begin
  for i := 0 to ps.count - 1 do
    if IsPolyPicked(ps[i]) then
    begin
      Selected.Add(id);
      exit;
    end;
end;

Procedure TSFTRenderer.PickPolygonsAt(ps: TPolygons; x, y, z, pitch, yaw, roll: double; id: integer);
begin
    // TODO: implement
end;

Procedure TSFTRenderer.PickLine(v1, v2: TVertex; id: integer);
var
  ax, ay, az, d, px1, py1, pz1, px2, py2, pz2: double;
  ev: TVector;
begin
  { project edge on camera plane. Picking line becomes a point - PK }

  d := VectorDot3(v1.x - pkX1, v1.y - pkY1, v1.Z - pkZ1, pkv.dx, pkv.dy, pkv.dz); //SMult
  px1 := v1.x - d * pkv.dx;
  py1 := v1.y - d * pkv.dy;
  pz1 := v1.Z - d * pkv.dz;

  d := VectorDot3(v2.x - pkX1, v2.y - pkY1, v2.Z - pkZ1, pkv.dx, pkv.dy, pkv.dz);
  px2 := v2.x - d * pkv.dx;
  py2 := v2.y - d * pkv.dy;
  pz2 := v2.Z - d * pkv.dz;

  // if p1 and p2 are very close, don't select
  if sqr(px2 - px1) + sqr(py2 - py1) + sqr(pz2 - pz1) < 1E-8 then
    exit;

  // Check that point PK is within the line
  if VectorDot3(pkX1 - px1, pkY1 - py1, pkZ1 - pz1, px2 - px1, py2 - py1, pz2 - pz1) < 0 then  //SMult
    exit;
  if VectorDot3(pkX1 - px2, pkY1 - py2, pkZ1 - pz2, px1 - px2, py1 - py2, pz1 - pz2) < 0 then
    exit;

  { Find the distance from line to point }
  VectorCross3(px2 - px1, py2 - py1, pz2 - pz1, pkv.dx, pkv.dy, pkv.dz, ev.dx,
    ev.dy, ev.dz); //VMult

  ev.Normalize;
  //Normalize(ev);

  if Abs(ev.Dot(pkX1 - px1, pkY1 - py1, pkZ1 - pz1)) < pdist then //abs(SMult(ev.dx, ev.dy, ev.dz, pkX1 - px1, pkY1 - py1, pkZ1 - pz1))
    Selected.Add(id);

end;

Procedure TSFTRenderer.PickVertex(x, y, Z: double; id: integer);
var
  d2: double;
  ax, ay, az: double;
begin
  ax := x - pkX1;
  ay := y - pkY1;
  az := Z - pkZ1;
  d2 := sqr(ax) + sqr(ay) + sqr(az) -
    sqr(VectorDot3(ax, ay, az, pkv.dx, pkv.dy, pkv.dz));  //SMult
  if pdist2 >= d2 then
    Selected.Add(id);
end;

Function TSFTRenderer.GetCameraAt(scX, scY: integer; var x, y, z: double): boolean;
begin
  Result := GetXYZonPlaneAt(scX, scY, zv, -CamX, -CamY, -CamZ, x, y, z);
end;

Function TSFTRenderer.GetXYZonPlaneAt(scX, scY: integer; pnormal: TVector;
  pX, pY, pZ: double; var x, y, Z: double): boolean;
var
  ax1, ay1, az1, ax2, ay2, az2: double;
  d: double;
begin
  SetRenderMatrix;
  ax1 := -1;
  ax2 := 1;
  ay1 := -1;
  ay2 := 1;
  az1 := -1;
  az2 := 1;

  UnProjectPoint(scX, scY, 0, ax1, ay1, az1);
  UnProjectPoint(scX, scY, 1, ax2, ay2, az2);

  { gluUnProject(scX,vp[3]-scY,0,mmx,pmx,vp,ax1,az1,ay1);
    gluUnProject(scX,vp[3]-scY,1,mmx,pmx,vp,ax2,az2,ay2); }

  With pnormal do
    d := dx * pX + dy * pY + dz * pZ;

  Result := PlaneLineXn(pnormal, d, ax1, ay1, az1, ax2, ay2, az2, x, y, Z);
  Result := Result and (abs(x) < xrange) and (abs(y) < Yrange) and
    (abs(Z) < ZRange);
  if not Result then
    exit;
  x := JKRound(x);
  y := JKRound(y);
  Z := JKRound(Z);
end;

Function TSFTRenderer.GetGridAt(scX, scY: integer; var x, y, Z: double)
  : boolean;
begin
  Result := GetXYZonPlaneAt(scX, scY, gnormal, GridX, GridY, GridZ, x, y, Z);
  if Result then
  begin
    x := JKRound(x);
    y := JKRound(y);
    Z := JKRound(Z);
  end;
end;

Function TSFTRenderer.GetCameraForward: TVector;
begin
  Result := zv;
end;

Function TSFTRenderer.GetCameraUp: TVector;
begin
  Result := yv;
end;

Function TSFTRenderer.GetCameraRight: TVector;
begin
  Result := xv;
end;

Procedure TSFTRenderer.UnProjectPoint(WinX, WinY: double; WinZ: double;
  var x, y, Z: double);
var
  vx, vy, vz: single;
begin
  SetRenderMatrix;
  vx := WinX - wcx;
  vy := WinY - wcy;
  vz := WinZ * 1000;

  MultVM3s(rmx, vx, vy, vz);
  x := (vx / ppunit / DpiScale) - cdx;
  y := (vy / ppunit / DpiScale) - cdy;
  Z := (vz / ppunit / DpiScale) - cdz;
end;

Procedure TSFTRenderer.ProjectPoint(x, y, Z: double; Var WinX, WinY: integer);
var
  vx, vy, vz: single;
begin
  SetRenderMatrix;
  vx := cdx + x;
  vy := cdy + y;
  vz := cdz + Z;
  MultVM3s(mx, vx, vy, vz);

  { Project }

  WinX := wcx + round(vx);
  WinY := wcy + round(vy);
end;

Function TSFTRenderer.GetPointSize: double;
begin
  Result := halfpsize * 2;
end;

Procedure TSFTRenderer.SetPointSize(size: double);
begin
  halfpsize := round(size / 2);
  psizeodd := round(size) mod 2;
end;

Function TSFTRenderer.HandleWMQueryPal: integer;
begin
  Result := 0;
end;

Function TSFTRenderer.HandleWMChangePal: integer;
begin
  Result := 0;
end;

Procedure TSFTRenderer.SetCulling(how: integer);
begin
  docull := how <> R_CULLNONE;
  cull_front := how = R_CULLFRONT;
end;

Procedure TSFTRenderer.SetColor(what, r, g, b: byte);
begin
  Inherited SetColor(what, r, g, b);
  case what of
    CL_BACKGROUND:
      Dc.Brush.Color := RGB(r, g, b);
    else // front & back
      begin
        Dc.pen.Color := RGB(r, g, b);
        Dc.Brush.Color := RGB(r, g, b);
      end;
  end;
end;

Procedure TSFTRenderer.MoveTo(x, y: single); { Does clipping }
begin
  curx := x;
  cury := y;
end;

Procedure TSFTRenderer.LineTo(x, y: single);
var
  pb1, pb2: boolean;
  xn, yn: single;
  x1, y1, x2, y2: single;
begin
  x1 := curx;
  y1 := cury;
  x2 := x;
  y2 := y;

  curx := x;
  cury := y;

  { left side }
  pb1 := x1 >= wx1;
  pb2 := x2 >= wx1;

  if not(pb1 or pb2) then
    exit;
  if pb1 <> pb2 then
  begin
    yn := y1 + (wx1 - x1) * (y2 - y1) / (x2 - x1);
    if pb1 then
    begin
      x2 := wx1;
      y2 := yn;
    end
    else
    begin
      x1 := wx1;
      y1 := yn
    end;
  end;

  { right side }
  pb1 := x1 <= wx2;
  pb2 := x2 <= wx2;

  if not(pb1 or pb2) then
    exit;
  if pb1 <> pb2 then
  begin
    yn := y1 + (wx2 - x1) * (y2 - y1) / (x2 - x1);
    if pb1 then
    begin
      x2 := wx2;
      y2 := yn;
    end
    else
    begin
      x1 := wx2;
      y1 := yn
    end;
  end;

  { top side }
  pb1 := y1 >= wy1;
  pb2 := y2 >= wy1;

  if not(pb1 or pb2) then
    exit;
  if pb1 <> pb2 then
  begin
    xn := x1 + (wy1 - y1) * (x2 - x1) / (y2 - y1);
    if pb1 then
    begin
      y2 := wy1;
      x2 := xn;
    end
    else
    begin
      y1 := wy1;
      x1 := xn
    end;
  end;

  { bottom side }
  pb1 := y1 <= wy2;
  pb2 := y2 <= wy2;

  if not(pb1 or pb2) then
    exit;
  if pb1 <> pb2 then
  begin
    xn := x1 + (wy2 - y1) * (x2 - x1) / (y2 - y1);
    if pb1 then
    begin
      y2 := wy2;
      x2 := xn;
    end
    else
    begin
      y1 := wy2;
      x1 := xn
    end;
  end;

  Dc.MoveTo(wcx + round(x1), wcy + round(y1));
  Dc.LineTo(wcx + round(x2), wcy + round(y2));

end;

end.
