object Options: TOptions
  Left = 328
  Top = 160
  BorderStyle = bsDialog
  Caption = 'Options'
  ClientHeight = 500
  ClientWidth = 534
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 17
  object Label5: TLabel
    Left = 299
    Top = 35
    Width = 182
    Height = 20
    AutoSize = False
    Caption = '&Jed Knight CD'
  end
  object Label6: TLabel
    Left = 303
    Top = 84
    Width = 178
    Height = 19
    AutoSize = False
    Caption = '&Jedi Knight  Directory'
  end
  object Label7: TLabel
    Left = 31
    Top = 60
    Width = 178
    Height = 19
    AutoSize = False
    Caption = '&Jedi Knight  Directory'
  end
  object Label8: TLabel
    Left = 27
    Top = 11
    Width = 182
    Height = 20
    AutoSize = False
    Caption = '&Jed Knight CD'
  end
  object Pages: TPageControl
    Left = 0
    Top = 0
    Width = 534
    Height = 451
    ActivePage = PPreview
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 528
    ExplicitHeight = 442
    object JK: TTabSheet
      HelpContext = 290
      Caption = 'Game'
      object GBMOTS: TGroupBox
        Left = 3
        Top = 115
        Width = 525
        Height = 81
        Caption = 'Mysteries of the Sith'
        TabOrder = 0
        object Label9: TLabel
          Left = 14
          Top = 27
          Width = 178
          Height = 19
          AutoSize = False
          Caption = 'Install &Directory'
        end
        object MotsDirEdit: TEdit
          Left = 14
          Top = 46
          Width = 419
          Height = 25
          TabOrder = 0
        end
        object BtnBrowseMotsDir: TButton
          Left = 446
          Top = 44
          Width = 75
          Height = 26
          Caption = 'Browse'
          TabOrder = 1
          OnClick = BtnBrowseMotsDirClick
        end
      end
      object GBJKDF2: TGroupBox
        Left = 3
        Top = 23
        Width = 525
        Height = 85
        Caption = 'Dark Forces II'
        TabOrder = 1
        object Label1: TLabel
          Left = 15
          Top = 27
          Width = 178
          Height = 19
          AutoSize = False
          Caption = 'Install &Directory'
        end
        object JkDirEdit: TEdit
          Left = 15
          Top = 46
          Width = 418
          Height = 25
          TabOrder = 0
        end
        object BtnBrowseJkDir: TButton
          Left = 446
          Top = 44
          Width = 75
          Height = 26
          Caption = 'Browse'
          TabOrder = 1
          OnClick = BtnBrowseJkDirClick
        end
      end
      object GBIJIM: TGroupBox
        Left = 3
        Top = 203
        Width = 525
        Height = 81
        Caption = 'Indiana Jones and the Infernal Machine'
        TabOrder = 2
        object Label13: TLabel
          Left = 15
          Top = 27
          Width = 180
          Height = 19
          AutoSize = False
          Caption = 'Install &Directory'
        end
        object Label14: TLabel
          Left = 16
          Top = 82
          Width = 179
          Height = 19
          AutoSize = False
          Caption = 'Exe Path'
          Visible = False
        end
        object IJIMDirEdit: TEdit
          Left = 15
          Top = 46
          Width = 418
          Height = 25
          TabOrder = 0
        end
        object BtnBrowseIJIMExe: TButton
          Left = 405
          Top = 99
          Width = 75
          Height = 26
          Caption = 'Browse'
          TabOrder = 1
          Visible = False
          OnClick = BtnBrowseIJIMExeClick
        end
        object IJIMExeEdit: TEdit
          Left = 16
          Top = 101
          Width = 367
          Height = 25
          TabOrder = 2
          Visible = False
        end
        object BtnBrowseIJIMDir: TButton
          Left = 446
          Top = 45
          Width = 75
          Height = 25
          Caption = 'Browse'
          TabOrder = 3
          OnClick = BtnBrowseIJIMDirClick
        end
      end
    end
    object PPreview: TTabSheet
      HelpContext = 300
      Caption = '3D Preview'
      object Label3: TLabel
        Left = 9
        Top = 77
        Width = 112
        Height = 20
        AutoSize = False
        Caption = 'Direct3D device:'
      end
      object Label4: TLabel
        Left = 265
        Top = 77
        Width = 96
        Height = 20
        AutoSize = False
        Caption = 'Description'
      end
      object LBGamma: TLabel
        Left = 279
        Top = 161
        Width = 96
        Height = 16
        AutoSize = False
        Caption = 'Gamma'
      end
      object LBDevices: TListBox
        Left = 9
        Top = 97
        Width = 240
        Height = 56
        ItemHeight = 17
        TabOrder = 0
        OnClick = LBDevicesClick
      end
      object RGWSize: TRadioGroup
        Left = 19
        Top = 159
        Width = 240
        Height = 145
        Caption = 'Window Size'
        ItemIndex = 0
        Items.Strings = (
          '800x600'
          '1024x768'
          '1280x960'
          '1440x900'
          '1600x1024'
          '1920x1200')
        TabOrder = 1
      end
      object MMDevDesc: TMemo
        Left = 265
        Top = 97
        Width = 248
        Height = 56
        TabOrder = 2
      end
      object CBP3DOnTop: TCheckBox
        Left = 399
        Top = 183
        Width = 108
        Height = 20
        Caption = '&Stays on top'
        TabOrder = 3
      end
      object CBFullLight: TCheckBox
        Left = 279
        Top = 264
        Width = 96
        Height = 20
        Caption = '&Fully Lit'
        TabOrder = 4
      end
      object EBGamma: TEdit
        Left = 279
        Top = 180
        Width = 104
        Height = 25
        TabOrder = 5
        Text = '1'
      end
      object CB3DLayers: TCheckBox
        Left = 279
        Top = 215
        Width = 208
        Height = 20
        Caption = '&Show only visible layers'
        TabOrder = 6
      end
      object CBShowThings: TCheckBox
        Left = 279
        Top = 239
        Width = 208
        Height = 20
        Caption = '&Show things'
        Checked = True
        State = cbChecked
        TabOrder = 7
      end
      object CBColored: TCheckBox
        Left = 279
        Top = 289
        Width = 208
        Height = 20
        Caption = '&Enable colored lighting'
        Checked = True
        State = cbChecked
        TabOrder = 8
      end
      object RGAPI: TRadioGroup
        Left = 149
        Top = 9
        Width = 216
        Height = 66
        Caption = 'Graphics API'
        ItemIndex = 0
        Items.Strings = (
          'Direct3D'
          'OpenGL')
        TabOrder = 9
      end
      object cbPlaySecSnd: TCheckBox
        Left = 279
        Top = 315
        Width = 154
        Height = 18
        Hint = 'Plays sector sound when camera is within sector'
        Caption = 'Play sector sound'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 10
      end
      object CBNoClipSelectionOutline: TCheckBox
        Left = 279
        Top = 339
        Width = 195
        Height = 17
        Caption = 'Don'#39't clip selection outline'
        TabOrder = 11
      end
    end
    object PGEnv: TTabSheet
      HelpContext = 310
      Caption = 'Environment'
      object SColor: TShape
        Left = 213
        Top = 32
        Width = 64
        Height = 65
      end
      object Label11: TLabel
        Left = 64
        Top = 9
        Width = 113
        Height = 16
        AutoSize = False
        Caption = 'Colors'
      end
      object Label12: TLabel
        Left = 213
        Top = 362
        Width = 42
        Height = 20
        AutoSize = False
        Caption = 'Mins'
      end
      object Label15: TLabel
        Left = 213
        Top = 391
        Width = 42
        Height = 20
        AutoSize = False
        Caption = 'Steps'
      end
      object LBColors: TListBox
        Left = 16
        Top = 32
        Width = 190
        Height = 309
        ItemHeight = 17
        TabOrder = 0
        OnClick = LBColorsClick
        OnDblClick = LBColorsDblClick
      end
      object BNEditColor: TButton
        Left = 213
        Top = 103
        Width = 64
        Height = 25
        Caption = '&Edit'
        TabOrder = 1
        OnClick = BNEditColorClick
      end
      object EBSaveInt: TEdit
        Left = 143
        Top = 358
        Width = 50
        Height = 25
        Alignment = taRightJustify
        Enabled = False
        ReadOnly = True
        TabOrder = 2
        Text = '1'
      end
      object CBAutoSave: TCheckBox
        Left = 16
        Top = 362
        Width = 121
        Height = 20
        Caption = '&Autosave every'
        TabOrder = 3
        OnClick = CBAutoSaveClick
      end
      object UDSaveInt: TUpDown
        Left = 193
        Top = 358
        Width = 17
        Height = 25
        Associate = EBSaveInt
        Min = 1
        Max = 60
        Position = 1
        TabOrder = 4
      end
      object CBUndo: TCheckBox
        Left = 16
        Top = 390
        Width = 113
        Height = 20
        Hint = 'Enable undo'
        Caption = 'Undo enabled'
        Checked = True
        ParentShowHint = False
        ShowHint = True
        State = cbChecked
        TabOrder = 5
        OnClick = CBUndoClick
      end
      object EBUndoStackSize: TEdit
        Left = 143
        Top = 389
        Width = 49
        Height = 25
        Hint = 'Max number of undo steps'
        Alignment = taRightJustify
        NumbersOnly = True
        ParentShowHint = False
        ReadOnly = True
        ShowHint = True
        TabOrder = 6
        Text = '1'
      end
      object UDUndoStackSize: TUpDown
        Left = 192
        Top = 389
        Width = 17
        Height = 25
        Hint = 'Number of undo steps available'
        Associate = EBUndoStackSize
        Min = 1
        Max = 1024
        ParentShowHint = False
        Position = 1
        ShowHint = True
        TabOrder = 7
        Thousands = False
      end
      object gbRenderOptions: TGroupBox
        Left = 288
        Top = 24
        Width = 239
        Height = 209
        Caption = 'Render Options'
        TabOrder = 8
        object ebGeoVertSize: TLabeledEdit
          Left = 184
          Top = 144
          Width = 32
          Height = 25
          Hint = 
            'Enter the size of world geometry vertices displayed in the edito' +
            'r.'
          Alignment = taRightJustify
          EditLabel.Width = 167
          EditLabel.Height = 25
          EditLabel.Hint = 
            'Adjust the size of world geometry vertices displayed in the edit' +
            'or.'
          EditLabel.Margins.Left = 8
          EditLabel.Margins.Top = 8
          EditLabel.Margins.Right = 8
          EditLabel.Margins.Bottom = 8
          EditLabel.Caption = 'Geometry vertex display size'
          EditLabel.ParentShowHint = False
          EditLabel.ShowHint = True
          LabelPosition = lpLeft
          LabelSpacing = 5
          NumbersOnly = True
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          Text = '5'
        end
        object cbInvrtCull: TCheckBox
          Left = 9
          Top = 101
          Width = 217
          Height = 18
          Hint = 'Reverses the backface culling render order for world geometry.'
          Caption = 'Inverted backface culling'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
        end
        object CBDbuf: TCheckBox
          Left = 9
          Top = 120
          Width = 217
          Height = 17
          Hint = 'Removes blinking on redraws'
          Caption = 'Double buffered (software mode)'
          Checked = True
          DoubleBuffered = False
          ParentDoubleBuffered = False
          ParentShowHint = False
          ShowHint = True
          State = cbChecked
          TabOrder = 2
        end
        object ebObjVertSize: TLabeledEdit
          Left = 184
          Top = 174
          Width = 32
          Height = 25
          Hint = 'Enter the size of object vertex displayed in the editor.'
          Margins.Left = 5
          Margins.Top = 5
          Margins.Right = 5
          Margins.Bottom = 5
          Alignment = taRightJustify
          EditLabel.Width = 148
          EditLabel.Height = 25
          EditLabel.Hint = 'Adjust the size of object vertex displayed in the editor.'
          EditLabel.Margins.Left = 12
          EditLabel.Margins.Top = 12
          EditLabel.Margins.Right = 12
          EditLabel.Margins.Bottom = 12
          EditLabel.Caption = 'Object vertex display size'
          EditLabel.ParentShowHint = False
          EditLabel.ShowHint = True
          LabelPosition = lpLeft
          LabelSpacing = 25
          NumbersOnly = True
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
          Text = '5'
        end
        object RGWireframe: TRadioGroup
          Left = 11
          Top = 23
          Width = 93
          Height = 73
          Caption = 'Graphics API'
          ItemIndex = 0
          Items.Strings = (
            'Software'
            'OpenGL')
          TabOrder = 4
        end
        object udGeoVertSize: TUpDown
          Left = 216
          Top = 144
          Width = 17
          Height = 25
          Associate = ebGeoVertSize
          Position = 5
          TabOrder = 5
        end
      end
      object udObjVertSize: TUpDown
        Left = 505
        Top = 198
        Width = 17
        Height = 24
        TabOrder = 9
      end
      object gbMapEdit: TGroupBox
        Left = 288
        Top = 239
        Width = 239
        Height = 151
        Caption = 'Map Edit'
        TabOrder = 10
        object ebVertSnapMaxDist: TLabeledEdit
          Left = 181
          Top = 22
          Width = 35
          Height = 25
          Hint = 
            'Enter the maximum distance for vertex snapping (object dragging,' +
            ' cleaving). Smaller values ensure more precise snapping.'
          Alignment = taRightJustify
          EditLabel.Width = 148
          EditLabel.Height = 25
          EditLabel.Hint = 
            'The maximum distance for vertex snapping (object dragging, cleav' +
            'ing).'
          EditLabel.Margins.Left = 8
          EditLabel.Margins.Top = 8
          EditLabel.Margins.Right = 8
          EditLabel.Margins.Bottom = 8
          EditLabel.Caption = 'Max vertex snap distance'
          EditLabel.ParentShowHint = False
          EditLabel.ShowHint = True
          LabelPosition = lpLeft
          LabelSpacing = 20
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          Text = '0.2'
        end
        object RGMapRot: TRadioGroup
          Left = 13
          Top = 57
          Width = 93
          Height = 80
          Caption = 'Map rotation'
          ItemIndex = 0
          Items.Strings = (
            'New Style'
            'Old Style')
          TabOrder = 1
        end
        object gbLockZoom: TGroupBox
          Left = 121
          Top = 57
          Width = 104
          Height = 80
          Caption = 'Lock Zoom'
          TabOrder = 2
          object cbLockZoom: TCheckBox
            Left = 73
            Top = 1
            Width = 98
            Height = 18
            Hint = 'Locks view zoom to min/max values.'
            ParentShowHint = False
            ShowHint = True
            TabOrder = 0
            OnClick = cbLockZoomClick
          end
          object ebZoomMin: TLabeledEdit
            Left = 50
            Top = 21
            Width = 49
            Height = 25
            Hint = 'Min zoom-out value. '
            Alignment = taRightJustify
            EditLabel.Width = 22
            EditLabel.Height = 25
            EditLabel.Hint = 'Min zoom-out value. '
            EditLabel.Margins.Left = 8
            EditLabel.Margins.Top = 8
            EditLabel.Margins.Right = 8
            EditLabel.Margins.Bottom = 8
            EditLabel.Caption = 'Min'
            EditLabel.ParentShowHint = False
            EditLabel.ShowHint = True
            Enabled = False
            LabelPosition = lpLeft
            LabelSpacing = 20
            ParentShowHint = False
            ShowHint = True
            TabOrder = 1
            Text = '1.0'
          end
          object ebZoomMax: TLabeledEdit
            Left = 50
            Top = 51
            Width = 49
            Height = 25
            Hint = 'Max zoom-in value. '
            Alignment = taRightJustify
            EditLabel.Width = 25
            EditLabel.Height = 25
            EditLabel.Hint = 'Max zoom-in value. '
            EditLabel.Margins.Left = 8
            EditLabel.Margins.Top = 8
            EditLabel.Margins.Right = 8
            EditLabel.Margins.Bottom = 8
            EditLabel.Caption = 'Max'
            EditLabel.ParentShowHint = False
            EditLabel.ShowHint = True
            Enabled = False
            LabelPosition = lpLeft
            LabelSpacing = 20
            ParentShowHint = False
            ShowHint = True
            TabOrder = 2
            Text = '5000.0'
          end
        end
      end
    end
    object PToolbar: TTabSheet
      Caption = 'Toolbar'
      TabVisible = False
    end
    object Miscoptions: TTabSheet
      HelpContext = 320
      Caption = 'Misc. Options'
      object ScrollBox1: TScrollBox
        Left = 5
        Top = 15
        Width = 520
        Height = 422
        BorderStyle = bsNone
        Padding.Bottom = 3700
        TabOrder = 0
        object CBThingsOnFloor: TCheckBox
          Left = 16
          Top = 8
          Width = 489
          Height = 20
          Alignment = taLeftJustify
          Caption = 'Put new thing at half height from the grid'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
        end
        object CBMoveFrames: TCheckBox
          Left = 16
          Top = 27
          Width = 489
          Height = 20
          Alignment = taLeftJustify
          Caption = 'Move thing frames when thing moves'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
        end
        object CBGobSmart: TCheckBox
          Left = 16
          Top = 47
          Width = 489
          Height = 20
          Hint = 'Put only used files in a GOB'
          Alignment = taLeftJustify
          Caption = 'Smart GOBbing'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
        end
        object CBCheckOverlaps: TCheckBox
          Left = 16
          Top = 66
          Width = 489
          Height = 20
          Hint = 
            'Slows down consistency check. Overlapping sectors is not afatal ' +
            'error'
          Alignment = taLeftJustify
          Caption = 'Check for overlapping sectors in Consistency Checker'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
        end
        object CBNewLightCalc: TCheckBox
          Left = 16
          Top = 85
          Width = 489
          Height = 20
          Hint = 'Faster, but may produce different result'
          Margins.Left = 7
          Margins.Top = 7
          Margins.Right = 7
          Margins.Bottom = 7
          Alignment = taLeftJustify
          Caption = 'Use new method of lighting calculation'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 4
        end
        object CBConfRevert: TCheckBox
          Left = 16
          Top = 105
          Width = 489
          Height = 20
          Alignment = taLeftJustify
          Caption = 'Confirm revert to saved'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 5
        end
        object CBSaveEditorLights: TCheckBox
          Left = 16
          Top = 124
          Width = 489
          Height = 20
          Hint = 'Adds custom section '#39'Lights'#39' to JKL/NDY file'
          Alignment = taLeftJustify
          Caption = 'Export editor lights  [JKL/NDY]'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 6
        end
        object CBSaveEditorLayers: TCheckBox
          Left = 16
          Top = 143
          Width = 489
          Height = 20
          Hint = 'Adds custom section '#39'Layers'#39' to JKL/NDY file'
          Alignment = taLeftJustify
          Caption = 'Export editor layers [JKL/NDY]'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 7
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 451
    Width = 534
    Height = 49
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 442
    ExplicitWidth = 528
    object SBHelp: TSpeedButton
      Left = 499
      Top = 15
      Width = 30
      Height = 26
      Hint = 'Help'
      Enabled = False
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        0400000000000001000000000000000000001000000010000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        3333333333FFFFF3333333333F797F3333333333F737373FF333333BFB999BFB
        33333337737773773F3333BFBF797FBFB33333733337333373F33BFBFBFBFBFB
        FB3337F33333F33337F33FBFBFB9BFBFBF3337333337F333373FFBFBFBF97BFB
        FBF37F333337FF33337FBFBFBFB99FBFBFB37F3333377FF3337FFBFBFBFB99FB
        FBF37F33333377FF337FBFBF77BF799FBFB37F333FF3377F337FFBFB99FB799B
        FBF373F377F3377F33733FBF997F799FBF3337F377FFF77337F33BFBF99999FB
        FB33373F37777733373333BFBF999FBFB3333373FF77733F7333333BFBFBFBFB
        3333333773FFFF77333333333FBFBF3333333333377777333333}
      NumGlyphs = 2
      ParentShowHint = False
      ShowHint = True
      Visible = False
      OnClick = SBHelpClick
    end
    object BNOK: TButton
      Left = 276
      Top = 11
      Width = 93
      Height = 30
      Caption = '&OK'
      Default = True
      TabOrder = 0
      OnClick = BNOKClick
    end
    object BNCancel: TButton
      Left = 388
      Top = 11
      Width = 93
      Height = 30
      Cancel = True
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object ColorDlg: TColorDialog
    CustomColors.Strings = (
      'ColorA=0'
      'ColorB=FFFFFF'
      'ColorC=FF'
      'ColorD=FF00'
      'ColorE=FF0000'
      'ColorF=FFFF'
      'ColorG=FFFF00'
      'ColorH=FF00FF'
      'ColorI=0'
      'ColorJ=0'
      'ColorK=0'
      'ColorL=0'
      'ColorM=0'
      'ColorN=0'
      'ColorO=0'
      'ColorP=0')
    Left = 704
    Top = 3
  end
end
