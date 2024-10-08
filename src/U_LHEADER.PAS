unit U_lheader;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, FieldEdit, J_Level, misc_utils, GlobalVars;

type
  TLHEdit = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    EBGravity: TEdit;
    EBSkyZ: TEdit;
    Label3: TLabel;
    Label2: TLabel;
    EBHorDist: TEdit;
    Label4: TLabel;
    EBHorPPRev: TEdit;
    EBMip1: TEdit;
    EBMip2: TEdit;
    EBMip3: TEdit;
    EBMip4: TEdit;
    EBLOD1: TEdit;
    EBLOD2: TEdit;
    EBLOD3: TEdit;
    EBLOD4: TEdit;
    Label6: TLabel;
    EBGouraud: TEdit;
    Label7: TLabel;
    EBPerspective: TEdit;
    Label8: TLabel;
    EBSkyOffsX: TEdit;
    EBSkyOffsY: TEdit;
    Label9: TLabel;
    EBHorSkyY: TEdit;
    EBHorSkyX: TEdit;
    Label10: TLabel;
    EBCMP: TEdit;
    Label11: TLabel;
    BNOK: TButton;
    Button1: TButton;
    BNCmp: TButton;
    EBPPU: TEdit;
    Label12: TLabel;
    CBFog: TCheckBox;
    ColorDialog1: TColorDialog;
    EBFogColor: TEdit;
    EBFogStart: TEdit;
    EBFogEnd: TEdit;
    gbFog: TGroupBox;
    gbMMDistances: TGroupBox;
    sFogColor: TShape;
    gbCeilingSky: TGroupBox;
    Label5: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    gbHorizonSky: TGroupBox;
    Label16: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BNCmpClick(Sender: TObject);
    procedure CBFogClick(Sender: TObject);
    procedure BNFogColorClick(Sender: TObject);
    procedure sFogColorMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure EBFogColorClick(Sender: TObject);
  private
    { Private declarations }
    vGrav, vSkyZ, vSkyX, vSkyY, vHorDist, vPar, vHorX, vHorY, vMM1, vMM2, vMM3,
      vMM4, vLOD1, vLOD2, vLOD3, vLOD4, vGouraud, vPerp, vCMP, vPPu, vFogColor,
      vFogStart, vFogEnd: TValInput;

    Procedure EnableFog(enable: Boolean);
    Procedure InitProjectMode;
  public
    { Public declarations }
    Function EditHeader: boolean;
  end;

var
  LHEdit: TLHEdit;

implementation

uses ResourcePicker;

{$R *.DFM}

procedure TLHEdit.FormCreate(Sender: TObject);
begin
  vGrav := TValInput.Create(EBGravity);
  vSkyZ := TValInput.Create(EBSkyZ);
  vSkyX := TValInput.Create(EBSkyOffsX);
  vSkyY := TValInput.Create(EBSkyOffsY);
  vHorDist := TValInput.Create(EBHorDist);
  vPar := TValInput.Create(EBHorPPRev);
  vHorX := TValInput.Create(EBHorSkyX);
  vHorY := TValInput.Create(EBHorSkyY);
  vMM1 := TValInput.Create(EBMip1);
  vMM2 := TValInput.Create(EBMip2);
  vMM3 := TValInput.Create(EBMip3);
  vMM4 := TValInput.Create(EBMip4);
  vLOD1 := TValInput.Create(EBLOD1);
  vLOD2 := TValInput.Create(EBLOD2);
  vLOD3 := TValInput.Create(EBLOD3);
  vLOD4 := TValInput.Create(EBLOD4);
  vGouraud := TValInput.Create(EBGouraud);
  vPerp := TValInput.Create(EBPerspective);
  vCMP := TValInput.Create(EBCMP);
  vPPu := TValInput.Create(EBPPU);
  vFogColor := TValInput.Create(EBFogColor);
  vFogStart := TValInput.Create(EBFogStart);
  vFogEnd := TValInput.Create(EBFogEnd);
end;

procedure TLHEdit.BNCmpClick(Sender: TObject);
begin
  vCMP.SetAsString(ResPicker.PickCMP(vCMP.s));
end;

procedure TLHEdit.BNFogColorClick(Sender: TObject);
var f: TColor;
  c: TColorF;
begin
  ValColor(vFogColor.s, c);
  ColorDialog1.Color := RGB(
    Round(c.r * 255),
    Round(c.g * 255),
    Round(c.b * 255)
  );
  if ColorDialog1.Execute(self.Handle) then
    begin
      f := ColorDialog1.Color;
      if f = -1 then  f :=0;       
      c := MakeColor(
        GetRValue(f) / 255,
        GetGValue(f) / 255,
        GetBValue(f) / 255,
        c.a
      );
      vFogColor.SetAsString(ColorToStr(c, true));
    end;
end;

procedure TLHEdit.CBFogClick(Sender: TObject);
begin
  EnableFog(CBFog.Checked);
end;

procedure TLHEdit.EBFogColorClick(Sender: TObject);
begin
  var c := vFogColor.AsColor;
  ColorDialog1.Color := EncodeBGR(c);
  if ColorDialog1.Execute(self.Handle) then
    begin
      var f := ColorDialog1.Color;
      if f = -1 then  f := 0;
      c := DecodeBGR(f, c.a);
      vFogColor.SetAsString(ColorToStr(c, true));
      sFogColor.Brush.Color := f;
    end;
end;

Function TLHEdit.EditHeader: boolean;
begin
  Result := false;
  with level.header do
  begin

    vGrav.SetAsFloat(gravity);

    vSkyZ.SetAsFloat(ceilingSky.height);
    vSkyX.SetAsFloat(ceilingSky.offset.X);
    vSkyY.SetAsFloat(ceilingSky.offset.Y);

    vHorDist.SetAsFloat(horizonSky.distance);
    vPar.SetAsFloat(horizonSky.pixelsPerRev);
    vHorX.SetAsFloat(horizonSky.offset.X);
    vHorY.SetAsFloat(horizonSky.offset.Y);

    vMM1.SetAsFloat(mipmapDistances[1]);
    vMM2.SetAsFloat(mipmapDistances[2]);
    vMM3.SetAsFloat(mipmapDistances[3]);
    vMM4.SetAsFloat(mipmapDistances[4]);

    vLOD1.SetAsFloat(lodDistances[1]);
    vLOD2.SetAsFloat(lodDistances[2]);
    vLOD3.SetAsFloat(lodDistances[3]);
    vLOD4.SetAsFloat(lodDistances[4]);

    vGouraud.SetAsFloat(gouraudDistance);
    vPerp.SetAsFloat(perspectiveDistance);
    vPPu.SetAsFloat(level.ppunit);
    vCMP.SetAsString(level.masterCMP);

    vFogColor.SetAsString(ColorToStr(fog.color, true));
    vFogStart.SetAsFloat(fog.fogStart);
    vFogEnd.SetAsFloat(fog.fogEnd);

    // Init GUI components and  show window
    InitProjectMode();
    EnableFog(fog.enabled);
    if ShowModal <> MrOK then
      exit;

    // Copy values from GUI components back to level header
    gravity := vGrav.AsFloat;

    ceilingSky.height   := vSkyZ.AsFloat;
    ceilingSky.offset.X := vSkyX.AsFloat;
    ceilingSky.offset.Y := vSkyY.AsFloat;

    horizonSky.distance := vHorDist.AsFloat;
    horizonSky.PixelsPerRev := vPar.AsFloat;
    horizonSky.offset.x := vHorX.AsFloat;
    horizonSky.offset.y := vHorY.AsFloat;

    mipmapDistances[1] := vMM1.AsFloat;
    mipmapDistances[2] := vMM2.AsFloat;
    mipmapDistances[3] := vMM3.AsFloat;
    mipmapDistances[4] := vMM4.AsFloat;

    lodDistances[1] := vLOD1.AsFloat;
    lodDistances[2] := vLOD2.AsFloat;
    lodDistances[3] := vLOD3.AsFloat;
    lodDistances[4] := vLOD4.AsFloat;

    gouraudDistance := vGouraud.AsFloat;
    perspectiveDistance := vPerp.AsFloat;
    level.ppunit := vPPu.AsFloat;

    Result := CompareText(level.masterCMP, vCMP.s) <> 0;
    level.masterCMP := vCMP.s;

    fog.enabled := CBFog.Checked;
    if not ValColor(vFogColor.s, fog.color) and fog.enabled then
       MsgBox('The fog color was not set because the color value is invalid', 'Warning', MB_OK);
    fog.fogStart := vFogStart.AsFloat;
    fog.fogEnd := vFogEnd.AsFloat;

    Result := True;
  end;
end;

Procedure TLHEdit.EnableFog(enable: Boolean);
begin
  CBFog.Checked      := enable;
  EBFogColor.Enabled := enable;
  sFogColor.visible  := enable;
  EBFogStart.Enabled := enable;
  EBFogEnd.Enabled   := enable;
end;

Procedure TLHEdit.InitProjectMode;
begin
  if CurrentProject = TProjectType.IJIM then
    begin
      gbMMDistances.Visible := False;
      Label8.Visible        := false;
      EBGouraud.Visible     := false;
      Label7.Visible        := false;
      EBPerspective.Visible := false;
      Label11.Visible       := false;
      EBCMP.Visible         := false;
      BNCmp.Visible         := false;
      Label12.Visible       := false;
      EBPPU.Visible         := false;
      GBFog.Visible         := true;
      sFogColor.Brush.Color := EncodeBGR(vFogColor.AsColor);
    end
  else
    begin
      gbMMDistances.Visible := True;
      Label8.Visible        := true;
      EBGouraud.Visible     := true;
      Label7.Visible        := true;
      EBPerspective.Visible := true;
      Label11.Visible       := true;
      EBCMP.Visible         := true;
      BNCmp.Visible         := true;
      Label12.Visible       := true;
      EBPPU.Visible         := true;
      gbFog.Visible         := false;
    end;
end;

procedure TLHEdit.sFogColorMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button <> mbLeft then
    exit;
  EBFogColorClick(nil);
end;

end.
