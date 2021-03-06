unit JvSpriteEngine;

interface

uses
  Windows, Messages,vcl.Graphics, vcl.Controls, vcl.Forms, system.Classes, system.SysUtils,
  ThreadTimer, Generics.Collections ,Generics.Defaults;

Type

  JvAnimDirection = ( dirForward, dirBackward );

  TRGB = packed record
    b: byte;
    g: byte;
    r: byte;
  end;
  RGBROW = array[0..Maxint div 16] of TRGB;
  PRGB = ^TRGB;
  PRGBROW = ^RGBROW;

type
  TJvTheater = class;
  TJvSprite = class;


  TJvTheaterEvent = procedure( Sender: TObject; VirtualBitmap: TBitmap ) of object;
  TCollisionEvent = procedure( Sender: TObject; Sprite1, Sprite2: TJvSprite ) of object;

  TJvSpriteEvent = procedure( Sender: TObject; ASprite: TJvSprite ) of object;
  TJvSpriteEventDstReached = procedure of object;

  TJvSpriteMouseEvent = procedure( Sender: TObject; lstSprite: TObjectList<TJvSprite>; Button: TMouseButton; Shift: TShiftState  ) of object;
  TJvSpriteMouseMoveEvent = procedure( Sender: TObject; lstSprite: TObjectList<TJvSprite>; Shift: TShiftState) of object;

  TJvSpriteLabel = class (Tobject)
  private
  protected
  public
    Transparent: boolean;
    lX : Integer;
    lY : Integer;
    lFont: TFont;
    lText : String;
    lpenMode: TPenMode;
    lVisible: Boolean;
    lBackColor: TColor;
    itag: integer;
    stag: string;
    LifeSpan: Integer;
    Dead: boolean;
  constructor create (x,y: integer; FontName: string; FontColor, BackColor: TColor; atext: string;aPenMode: TPenMode; visible: boolean);
  destructor Destroy;override;
  end;

  TJvTheater = class(TCustomControl)
  private

    iCollisionDelay: Integer;
    fCollisionDelay: Integer;
    fBackColor: TColor;

    fVirtualBitmap: TBitmap;
    fVirtualWidth: integer;
    fVirtualheight: integer;

    FActive: boolean;

    // mouse
    FOnMouseUp: TMouseEvent;
    FOnMouseDown: TMouseEvent;
    FOnMouseMove: TMouseMoveEvent;
    FOnSpriteMouseMove: TJvSpriteMouseMoveEvent;
    FOnSpriteMouseDown: TJvSpriteMouseEvent;
    FOnSpriteMouseUp: TJvSpriteMouseEvent;

    // Thread
    FAnimationInterval: integer;
    FShowPerformance: boolean;
    nPerformanceEnd: DWORD;
    nFrames, nShowFrames: integer;

    // various
    FBeforeSpriteRender: TJvTheaterEvent;
    FAfterSpriteRender: TJvTheaterEvent;
    FBeforeRender: TJvTheaterEvent;
    FAfterRender: TJvTheaterEvent;

     // Engine
    lstSprites: TObjectList<TJvSprite>;
    lstNewSprites: TObjectList<TJvSprite>;

    FOnCollision: TCollisionEvent;
    FOnSpriteDestinationReached: TJvSpriteEvent;

    FCollisionPrecisePixel: Boolean;
    FClickSpritesPrecise: Boolean;
    FClickSprites: boolean;
    FSortNeeded: boolean;

    procedure SetCollisionDelay  ( const nDelay: Integer);
    procedure SetShowPerformance(const value: boolean);

    procedure OnTimer (Sender: TObject);
    procedure SetActive(const Value: boolean);

    function GetSprite(n: integer): TJvSprite;
    function GetSpriteIndex(aSprite: TJvSprite): Integer;
    function GetSpriteCount: integer;
    procedure SetOnCollision(const Value: TCollisionEvent);

    procedure SetClickSprites ( value: Boolean );
    procedure SetClickSpritesPrecise  ( value: Boolean );
    procedure SetCollisionPrecisePixel ( value: Boolean );

    property VirtualWidth: integer read fVirtualWidth write fVirtualWidth;
    property Virtualheight: integer read fVirtualheight write fVirtualHeight;

  protected

    fLastMouseMoveX, fLastMouseMoveY: integer;
    fMouseDownX, fMouseDownY: integer;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

    procedure PaintVisibleBitmap(Interval: integer);

    // Engine
    function GetDestination( ASprite: TJvSprite ): TPoint;
    procedure SetDestination(ASprite: TJvSprite;  Destination: TPoint);

    procedure CollisionDetection;

    procedure RenderSprites;
    procedure SortSprites;



  public
    ChangeCursor : Boolean;
    SceneName: string;
    lstSpriteClicked: TObjectList<TJvSprite>;
    lstSpriteMoved: TObjectList<TJvSprite>;

    thrdAnimate: ira_ThreadTimer;
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;

    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure Clear;

    property VirtualBitmap : TBitmap read fVirtualBitmap;

    property Active: Boolean read FActive write SetActive;

    // Engine
    function IsAnySpriteMoving : Boolean;
    procedure ProcessSprites(interval: Integer);
    function CreateSprite( const FileName,Guid: string; nFramesX, nFramesY, nDelay, posX, posY: integer; const Transparent: boolean; nPriority:integer ): TJvSprite;overload;
    function CreateSprite(const bmp: TBitmap; const Guid: string; nFramesX, nFramesY, nDelay, posX, posY: integer; const Transparent: boolean; nPriority:integer  ): TJvSprite; overload;
    procedure AddSprite(aSprite: TJvSprite) ;

    procedure RemoveAllSprites;
    procedure RemoveSprite( ASprite: TJvSprite );
    property SpriteCount: integer read GetSpriteCount;
    property Sprites[n: integer]: TJvSprite read GetSprite;
    property SpriteIndex[aSprite: TJvSprite]: integer read GetSpriteIndex;
    Function FindSprite (Guid: string):TJvSprite;

    property Destination[Sprite: TJvSprite]: TPoint read GetDestination write SetDestination;

  published

    property AnimationInterval: integer read FAnimationInterval write FAnimationInterval;
    property CollisionDelay: integer read fCollisionDelay write SetCollisionDelay default 400;
    property ShowPerformance: boolean read FShowPerformance write SetShowPerformance;

    property OnBeforeRender: TJvTheaterEvent read FBeforeRender write FBeforeRender;
    property OnAfterRender: TJvTheaterEvent read FAfterRender write FAfterRender;

    property OnSpriteMouseMove: TJvSpriteMouseMoveEvent read FOnSpriteMouseMove write FOnSpriteMouseMove;
    property OnSpriteMouseDown: TJvSpriteMouseEvent read FOnSpriteMouseDown write FOnSpriteMouseDown;
    property OnSpriteMouseUp: TJvSpriteMouseEvent read FOnSpriteMouseUp write FOnSpriteMouseUp;

    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;

    property ClickSprites: boolean read FClickSprites write SetClickSprites;
    property ClickSpritesPrecise: boolean read FClickSpritesPrecise write SetClickSpritesPrecise;
    property CollisionPrecisePixel: boolean read FCollisionPrecisePixel write SetCollisionPrecisePixel;
    property OnCollision: TCollisionEvent read FOnCollision write SetOnCollision;
    property OnSpriteDestinationReached: TJvSpriteEvent read FOnSpriteDestinationReached write FOnSpriteDestinationReached;


    property Anchors;

    property DragCursor;

    property Cursor;

    property Align;
    property DragMode;
    property Enabled;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Visible;
    property TabOrder;
    property TabStop;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnStartDrag;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnContextPopup;
    property Width;
    property Height;



  end;
  pTJvSpriteLabel = ^TJvSpriteLabel;

  TJvSpriteMoverData = class( TObject )
  private
    FDestination: TPoint;
    FDestinationY: integer;
    FDestinationX: integer;

    fWPinterval: Integer;

    FSpeed: single;
    FSpeedY: single;
    FSpeedX: single;
    function GetDestination: TPoint;
    procedure SetDestination(  Destination: TPoint );
    procedure setWPinterval ( v: Integer );
    procedure CalculateVectors( );
  protected
  public
    FSprite: TJvSprite;

    curWP: Integer;
    TWPinterval: Integer;
    MovePath: TList<TPoint>;
    UseMovePath: boolean;

    constructor Create ; overload;
    destructor Destroy; override;
    property WPinterval: Integer read fWPinterval write setWPinterval;
    property Destination: Tpoint read GetDestination write SetDestination;
    property Speed: single read FSpeed write FSpeed;
    property SpeedX: single read FSpeedX write FSpeedX;
    property SpeedY: single read FSpeedY write FSpeedY;


  end;

  TJvSprite = class( TObject )
  private
    FTheater: TJvTheater;

    FBMP: TBitmap;
    FBMPCurrentFrame: TBitmap;
    fchangingFrame: boolean;
    fchangingBitmap: boolean;


    FAnimated: boolean;
    FFrameWidth, FFrameHeight: integer;
    FFrameX: integer;
    FFrameY: integer;
    FFramesX: integer;
    FFramesY: integer;
    FAnimationDirection: JvAnimDirection;
    FFrameXmin: integer;
    FFrameXmax: integer;

    FAnimationInterval: integer;
    FHideAtEndX: Boolean;
    FDieAtEndX: Boolean;
    FStopAtEndX: Boolean;

    FTransparent: boolean;
    FTransparentColor: TColor;
    FTransparentForced: Boolean;
    lstLabels: Tobjectlist<TJvSpriteLabel>;

    FVisible: boolean;
    FPriority: integer;

    FPositionY: single;
    FPositionX: single;
    FPosition: Tpoint;

    FDrawingRect: Trect;

    FNotifyDestinationReached : boolean;

    FDead: boolean;
    FLifeSpan: integer;
    fDelay: integer;

    Fpause: boolean;

    FMoverData: TJvSpriteMoverData;

    FOnDestinationReached: TJvSpriteEventDstReached;

    function getTransparentColor: TRGB;
    procedure SetPriority(const Value: integer);
    procedure SetDead(const Value: boolean);

    function GetPositionX: single;
    function GetPositionY: single;
    function GetPosition: TPoint;
    procedure SetPosition(const Value: TPoint);
    procedure SetPositionX(const Value: single);
    procedure SetPositionY(const Value: single);

    procedure SetFrameXmin (const Value: Integer);
    procedure SetFrameXmax (const Value: Integer);


  protected

  public
    Guid: string;
    SpriteFileName : string;
    DestinationReached : boolean;
    sTag : string;
    Collision: Boolean;
    GrayScale: Boolean;
    MouseX, MouseY : integer; // coordinate del mouse attuali su questo TJvSprite



    constructor Create();overload ; virtual;
    constructor Create ( const FileName,Guid: string; const nFramesX, nFramesY, nDelay, posX, posY: integer; const TransparentSprite: boolean);overload; virtual;
    constructor Create ( const  bmp: Tbitmap; const Guid: string; const nFramesX, nFramesY, nDelay, posX, posY: integer; const TransparentSprite: boolean);overload; virtual;
    destructor Destroy; override;
    procedure iOnDestinationReached ; virtual;

    procedure ChangeBitmap ( const FileName: string; const nFramesX, nFramesY, nDelay: integer);overload; virtual;
    procedure ChangeBitmap ( const  bmp: Tbitmap;  const nFramesX, nFramesY, nDelay: integer);overload; virtual;

    procedure MouseUp ( x,y: integer; Button: TMouseButton; Shift: TShiftState); virtual;
    procedure MouseDown ( x,y: integer; Button: TMouseButton; Shift: TShiftState); virtual;
    procedure MouseMove ( x,y: integer; Shift: TShiftState); virtual;

    procedure Move(interval: Integer); virtual;
    procedure SetCurrentFrame; virtual;
    procedure DrawFrame; virtual;
    procedure Render;  virtual;

    procedure MakeDelay(msecs: integer);
    function  CollisionDetect ( aSprite: TJvSprite ): Boolean;

    property Dead: boolean read FDead write SetDead;
    property LifeSpan: integer read FLifeSpan write FLifeSpan;


    property Position: TPoint read GetPosition write SetPosition;
    property PositionX: single read GetPositionX write SetPositionX;
    property PositionY: single read GetPositionY write SetPositionY;

    property Priority: integer read FPriority write SetPriority;
    property MoverData: TJvSpriteMoverData read FMoverData write FMoverData;

    property DrawingRect: Trect read FDrawingRect write FDrawingRect;
    property Visible : boolean read FVisible write FVisible default true;

    property BMP: TBitmap read FBMP write FBMP;
    property BmpCurrentFrame: TBitmap read FbmpcurrentFrame write FbmpcurrentFrame;
    property FrameX: integer read FFrameX write FFrameX;
    property FrameY: integer read FFrameY write FFrameY;
    property FramesX: integer read FFramesX write FFramesX;
    property FramesY: integer read FFramesY write FFramesY;
    property FrameXmin: integer read FFrameXmin write SetFrameXmin;
    property FrameXmax: integer read FFrameXmax write SetFrameXmAx;


    property NotifyDestinationReached : boolean read FNotifyDestinationReached write FNotifyDestinationReached;

    property FrameWidth: integer read FFrameWidth write FFrameWidth;
    property FrameHeight: integer read FFrameHeight write FFrameHeight;

    property AnimationDirection: JvAnimDirection read FAnimationDirection write FAnimationDirection;
    property AnimationInterval: integer read FAnimationInterval write FAnimationInterval;
    property HideAtEndX: Boolean read FHideAtEndX write FHideAtEndX default false ;
    property DieAtEndX: Boolean read FDieAtEndX write FDieAtEndX default false;
    property StopAtEndX: Boolean read FStopAtEndX write FStopAtEndX default false ;


    property delay: integer read Fdelay write Fdelay;

    property Transparent: boolean read FTransparent write FTransparent;
    property TransparentColor: Tcolor read FTransparentColor write FTransparentColor;
    property TransparentForced: boolean read FTransparentForced write FTransparentForced;
    property Pause: boolean read FPause write FPause ;

    property Labels : Tobjectlist<TJvSpriteLabel> read lstLabels write lstLabels;

    property OnDestinationreached : TJvSpriteEventDstReached read FOnDestinationreached write FOnDestinationreached;


  end;

  procedure CopyRectTo(SourceBitmap,DestBitmap: Tbitmap; SrcX, SrcY, DstX, DstY: integer; RectWidth, RectHeight: integer; Transparent: boolean;wTrans: integer);
  function GetSegment(bitmap:TBitmap; Row: integer; Col: integer; Width: integer): pointer;
  procedure DoGrayScale (bitmap:TBitmap);
  function imax(v1, v2: Integer): Integer;
  function imin(v1, v2: Integer): Integer;
  function ilimit(vv, min, max: Integer): Integer;
  function TColor2TRGB(cl: TColor): TRGB;
  function TRGB2TColor(rgb: TRGB): TColor;
  function RGB2TColor(r, g, b: Integer): TColor;
  procedure GetLinePoints(X1, Y1, X2, Y2 : Integer; var PathPoints: TList<TPoint>);
  procedure Register;
implementation

procedure Register;
begin
  RegisterComponents('Jv SpriteEngine', [TJvTheater]);
end;
// ----------------------------------------------------------------------------
// GetLinePoints
// ----------------------------------------------------------------------------
procedure GetLinePoints(X1, Y1, X2, Y2 : Integer; var PathPoints: TList<TPoint>);
var
ChangeInX, ChangeInY, i, MinX, MinY, MaxX, MaxY, LineLength : Integer;
ChangingX : Boolean;
Point : TPoint;
begin
  PathPoints.Clear;

  if X1 > X2 then  begin
    ChangeInX := X1 - X2;
    MaxX := X1;
    MinX := X2;
  end
  else begin
    ChangeInX := X2 - X1;
    MaxX := X2;
    MinX := X1;
  end;

  if Y1 > Y2 then  begin
    ChangeInY := Y1 - Y2;
    MaxY := Y1;
    MinY := Y2;
  end
  else  begin
    ChangeInY := Y2 - Y1;
    MaxY := Y2;
    MinY := Y1;
  end;

  if ChangeInX > ChangeInY then  begin
    LineLength := ChangeInX;
    ChangingX := True;
  end
  else begin
    LineLength := ChangeInY;
    ChangingX := false;
  end;


  if X1 = X2 then  begin
    for i := MinY to MaxY do begin
      Point.X := X1;
      Point.Y := i;
      PathPoints.Add(Point);
    end;

    if Y1 > Y2 then  begin
      PathPoints.reverse;
    end;
  end

  else if Y1 = Y2 then  begin
    for i := MinX to MaxX do begin
      Point.X := i;
      Point.Y := Y1;
      PathPoints.Add(Point);
    end;


    if X1 > X2 then begin
      PathPoints.reverse;
    end;
  end
  else begin
    Point.X := X1;
    Point.Y := Y1;
    PathPoints.Add(Point);

    for i := 1 to (LineLength - 1) do  begin
      if ChangingX then  begin
        Point.y := Round((ChangeInY * i)/ChangeInX);
        Point.x := i;
      end

      else  begin
        Point.y := i;
        Point.x := Round((ChangeInX * i)/ChangeInY);
      end;

      if Y1 < Y2 then  Point.y := Point.Y + Y1
      else   Point.Y := Y1 - Point.Y;

      if X1 < X2 then  Point.X := Point.X + X1
      else   Point.X := X1 - Point.X;

      PathPoints.Add(Point);
    end;
    Point.X := X2;
    Point.Y := Y2;
    PathPoints.Add(Point);
  end;
end;
function imax(v1, v2: Integer): Integer;
asm
  cmp  edx,eax
  jng  @1
  mov  eax,edx
@1:
end;
function imin(v1, v2: Integer): Integer;
asm
  cmp  eax,edx
  jng  @1
  mov  eax,edx
@1:
end;
function ilimit(vv, min, max: Integer): Integer;
asm
  cmp eax,edx
  jg @1
  mov eax,edx
  ret
  @1:
  cmp eax,ecx
  jl @2
  mov eax,ecx
  ret
@2:
end;
function TColor2TRGB(cl: TColor): TRGB;
var
  rgb: longint;
begin
  rgb := colortorgb(cl);
  result.r := $FF and rgb;
  result.g := ($FF00 and rgb) shr 8;
  result.b := ($FF0000 and rgb) shr 16;
end;

function TRGB2TColor(rgb: TRGB): TColor;
begin
  with rgb do
    result := r or (g shl 8) or (b shl 16);
end;
function RGB2TColor(r, g, b: Integer): TColor;
begin
  result := r or (g shl 8) or (b shl 16);
end;


{$R-}

constructor TJvSpriteLabel.create ( x,y: integer; FontName: string; FontColor, BackColor: TColor; atext: string;aPenMode: TPenMode; visible: boolean);
begin
  lx := x;
  ly := y;
  lFont:= TFont.Create ;
  lFont.Name := FontName;
  lFont.Color := FontColor;
  ltext:= atext;
  lPenMode:= aPenMode;
  lVisible:= visible;
  lbackcolor := BackColor;
end;
destructor TJvSpriteLabel.Destroy;
begin
  inherited;
end;

function TJvSpriteMoverData.GetDestination: TPoint;
begin
    Result := Point( fDestinationX, fDestinationY );
end;
procedure TJvSpriteMoverData.SetDestination(Destination: TPoint);
begin
  fDestinationX := Destination.X;
  fDestinationY := Destination.Y;
  CalculateVectors;
end;
procedure TJvSpriteMoverData.setWPinterval ( v: Integer );
begin
  fWPinterval := v;
  tWPinterval := v;
end;

constructor TJvSpriteMoverData.create ;
begin
  MovePath:= TList<TPoint>.Create ;
  curWP := 0;
end;
destructor TJvSpriteMoverData.Destroy ;
begin
  MovePath.Free;
end;

procedure TJvSpriteMoverData.CalculateVectors;
var
  Dist: single;
  xpct, ypct: single;
begin


  Dist := Abs( fDestinationX - fSprite.PositionX ) + Abs( fDestinationY - fSprite.PositionY );
  if ( Dist > 0 ) then
  begin
    xPct := Abs( fDestinationX - fSprite.PositionX ) / Dist;
    yPct := Abs( fDestinationY - fSprite.PositionY ) / Dist;
    SpeedX := Speed * xPct;
    SpeedY := Speed * yPct;
    if ( fDestinationX < fSprite.PositionX ) then
      SpeedX := -SpeedX;
    if ( fDestinationY < fSprite.PositionY ) then
      SpeedY := -SpeedY;
  end
  else
  begin
    SpeedX := Speed / 2.0;
    SpeedY := Speed / 2.0;
  end;
end;
function TJvTheater.GetDestination(ASprite: TJvSprite): TPoint;
begin
    Result := ASprite.MoverData.Destination;
end;
procedure TJvTheater.OnTimer(Sender: TObject);
var
  i,k: integer;
begin

  Inc( nFrames );

  fVirtualBitmap.Canvas.Brush.Color := fBackColor;
  fVirtualBitmap.Canvas.FillRect( Rect(0,0,fVirtualBitmap.Width,fVirtualBitmap.Height));

  if Assigned( FBeforeSpriteRender ) then  FBeforeSpriteRender( self,  fVirtualBitmap );

  ProcessSprites( ira_ThreadTimer(Sender).Interval  );
  RenderSprites;

  if Assigned( FOnCollision ) then begin
    iCollisionDelay := iCollisionDelay -  ira_ThreadTimer(Sender).Interval ;
    if iCollisionDelay <= 0 then begin
      iCollisionDelay := fCollisionDelay;
      // CollisionDetection ;


      for i := 0 to lstSprites.Count - 1 do  begin
        for k := i + 1 to lstSprites.Count - 1 do  begin

          if not lstSprites[i].Collision or not lstSprites[k].Collision then Continue;

          if lstSprites[i].CollisionDetect ( lstSprites[k] ) then
            FOnCollision( self, lstSprites[i], lstSprites[k] );

        end;
      end;

    end;
  end;

  if Assigned( FAfterSpriteRender ) then
    FAfterSpriteRender( self, fVirtualBitmap );

  PaintVisibleBitmap (ira_ThreadTimer(Sender).Interval);

  Application.ProcessMessages;

end;

procedure TJvTheater.SetActive(const Value: boolean);
begin

  if not (csDesigning in ComponentState) then begin
    FActive := Value;
    if Not FActive then begin
      thrdAnimate.Enabled := False;
    end
    else begin
      fVirtualWidth:= Width;
      fVirtualHeight:= Height;
      thrdAnimate.Enabled := True ;
    end;
  end;
end;

procedure TJvTheater.SetDestination(ASprite: TJvSprite;  Destination: TPoint);
begin
  ASprite.FMoverData.FDestinationX := Destination.X;
  ASprite.FMoverData.FDestinationY := Destination.Y;
  ASprite.FMoverData.CalculateVectors(  );
end;
procedure TJvTheater.SortSprites;
begin
  FSortNeeded := true;
end;

(*----------------------------------------------------------------------------------*)
(* Carica un Bitmap 24bit uncompressed da file impostando i parametri di animazione *)
(*----------------------------------------------------------------------------------*)
function TJvTheater.CreateSprite(const FileName,Guid: string; nFramesX, nFramesY, nDelay, posX, posY: integer; const Transparent: boolean; nPriority:integer  ): TJvSprite;
var
aSprite: TJvSprite;
begin
  aSprite:= TJvSprite.Create ( Filename, Guid, nFramesX, nFramesY, nDelay, posX, posY, Transparent ) ;
  aSprite.OnDestinationreached := aSprite.iOnDestinationReached ;// aSpriteReachdestination;
  aSprite.Guid := Guid;
  aSprite.fTheater := Self;
  aSprite.Priority := nPriority;

  lstNewSprites.Add( ASprite );
  aSprite.Visible := true;
  Result:= aSprite;
end;
(*---------------------------------------------------------------------------------------------*)
(* Carica un Bitmap 24bit uncompressed da un altro Bitmap impostando i parametri di animazione *)
(*---------------------------------------------------------------------------------------------*)
function TJvTheater.CreateSprite(const bmp: TBitmap; const Guid: string; nFramesX, nFramesY, nDelay, posX, posY: integer; const Transparent: boolean; nPriority:integer  ): TJvSprite;
var
aSprite: TJvSprite;
begin

  aSprite:= TJvSprite.Create ( bmp, Guid, nFramesX, nFramesY, nDelay, posX, posY, Transparent ) ;
  aSprite.OnDestinationreached := aSprite.iOnDestinationReached ;// aSpriteReachdestination;
  aSprite.Guid := Guid;
  aSprite.fTheater := Self;
  aSprite.Priority := nPriority;

  lstNewSprites.Add( ASprite );
  aSprite.Visible := true;
  Result:= aSprite;

end;
procedure TJvTheater.AddSprite(aSprite: TJvSprite) ;
begin
  lstNewSprites.Add( ASprite );
  aSprite.fTheater := Self;
  aSprite.Visible := true;
end;

procedure TJvTheater.CollisionDetection;
var
  i, k : integer;
begin
  if not Assigned( FOnCollision ) then Exit;

  for i := 0 to lstSprites.Count - 1 do  begin
    for k := i + 1 to lstSprites.Count - 1 do  begin
      if not lstSprites[i].Collision or not lstSprites[k].Collision then Continue;
      if lstSprites[i].DrawingRect.IntersectsWith(lstSprites[k].DrawingRect ) then begin
           FOnCollision( self, lstSprites[i], lstSprites[k] )
      end;
    end;
  end;


end;

procedure TJvTheater.RemoveSprite(ASprite: TJvSprite);
begin
    ASprite.Dead := true;
end;



function TJvTheater.GetSpriteIndex(aSprite: TJvSprite): integer;
var
i: integer;
begin
  result:=-1;
  for i := 0 to lstSprites.Count -1 do begin
    if  lstSprites[i] = aSprite then begin
      result:= i;
      Exit;
    end;
  end;

end;
Function TJvTheater.IsAnySpriteMoving :Boolean;
var
  i: integer;
begin
  Result := False;
  for i:= 0 to lstSprites.Count -1 do begin
    if (
      (lstSprites [i].MoverData.fDestinationX <> lstSprites [i].Position.X) or (lstSprites [i].MoverData.FDestinationY <> lstSprites [i].Position.Y)
      )
    and (
      (lstSprites [i].MoverData.SpeedX  <> 0) or  (lstSprites [i].MoverData.SpeedY <> 0)
      )

    then begin
        result:=true;
        exit;
    end;
  end;

end;

Function TJvTheater.FindSprite (Guid: string):TJvSprite;
var
  i: integer;
begin
  Result:=nil;
  for i:= 0 to lstSprites.Count -1 do begin
    if lstSprites [i].Guid  = Guid then  begin
      result:=lstSprites [i];
      exit;
    end;
  end;
  for i:= 0 to lstNewSprites.Count -1 do begin
    if lstNewSprites [i].Guid  = Guid then begin
      result:=lstNewSprites [i];
      exit;
    end;
  end;

end;
function TJvTheater.GetSprite(n: integer): TJvSprite;
begin
  if n >= lstSprites.Count then
    Result := lstNewSprites[n - lstSprites.Count]
  else
    Result :=  lstSprites[n] ;
end;

function TJvTheater.GetSpriteCount: integer;
begin
  Result := lstSprites.Count + lstNewSprites.Count;
end;

procedure TJvTheater.ProcessSprites(interval: Integer);
var
  i, nIndex,L: integer;
begin

   FSortNeeded := false;
   lstSprites.sort(TComparer<TJvSprite>.Construct(
   function (const L, R: TJvSprite): integer
   begin
      result := trunc(L.Priority  - R.Priority  );
   end
  ));

  (* i nuovi sprite vanno nella lista principale *)

  while lstNewSprites.Count > 0 do
  begin
    nIndex := -1;
    for i := 0 to lstSprites.Count - 1 do
      if  lstNewSprites[0].Priority <=  lstSprites[i].Priority then  begin
        nIndex := i;
        Break;
      end;
      if nIndex = -1 then
        lstSprites.Add( lstNewSprites[0] )
      else

      lstSprites.Insert( nIndex, lstNewSprites[0] );
      lstNewSprites.Delete( 0 ); // <-- non libera l'oggetto, ha passato il puntatore
  end;

  // Movimento Sprites
  for i := 0 to lstSprites.Count - 1 do  begin
     lstSprites[i].Move(interval);
  end;
  // Rimuovo  sprite morti (dead=true) dalla lista degli sprites
  for i := lstSprites.Count - 1 downTo 0 do begin
    if lstSprites.Items [i].Dead then
      lstSprites.Delete(i);
  end;

  for i := lstSprites.Count - 1 downTo 0 do begin
    for L := lstSprites[i].Labels.Count - 1 downTo 0 do begin
      if lstSprites[i].Labels [L].Dead then
        lstSprites[i].Labels.Delete(L);
    end;
  end;

  {  while lstDeadSprites.Count > 0 do
  begin
    nIndex := lstSprites.IndexOf( lstDeadSprites[0] );
    if nIndex >= 0 then
    begin
      if Assigned( FOnRemoveSprite ) then  FOnRemoveSprite( self,  lstSprites[nIndex]  );
      lstSprites.Delete( nIndex );     // lo rimuove realmente

    end
    else
    begin
      nIndex := lstNewSprites.IndexOf( lstDeadSprites[0] );
      if nIndex >= 0 then
      begin
        //lstNewSprites[nIndex].Free;
        lstNewSprites.Delete( nIndex ); // non lo rimuove realmente
      end;
    end;

    lstDeadSprites.Delete( 0 );
  end;   }


end;

procedure TJvTheater.RemoveAllSprites;
var
  i: integer;
begin
  for i := lstSprites.Count - 1 downto 0 do
    RemoveSprite( Sprites[i] );
end;

procedure TJvTheater.RenderSprites;
var
  i: integer;
begin

    for i := 0 to lstSprites.Count - 1 do  begin
      lstSprites[i].SetCurrentFrame ;
      if lstSprites[i].Visible then lstSprites[i].Render;
    end;


end;

procedure TJvTheater.SetClickSprites ( value: Boolean );
begin
  FClickSprites := value;
end;
procedure TJvTheater.SetClickSpritesPrecise  ( value: Boolean );
begin
  FClickSpritesPrecise  := value;
end;
procedure TJvTheater.SetCollisionPrecisePixel ( value: Boolean );
begin
  FCollisionPrecisePixel := value;
end;

procedure TJvTheater.SetOnCollision(const Value: TCollisionEvent);
begin
  FOnCollision := Value;
end;
procedure TJvTheater.Clear;
begin
    lstNewSprites.Clear;
    lstSprites.Clear ;
end;


constructor TJvSprite.Create;
begin
  inherited create;
end;
constructor TJvSprite.Create ( const FileName,Guid: string; const nFramesX, nFramesY, nDelay, posX,posY: integer; const TransparentSprite: boolean);
var
rectSource: TRect;
begin
  FBMP:= TBitmap.Create;
  FBMP.LoadFromFile(FileName);
  if FBMP.PixelFormat <> pf24bit then begin
    raise Exception.Create('Need 24 bit Bitmap!');
    FBMP.Free;
    Exit;
  end;

  inherited create;
  Destinationreached := true;

  FAnimated := ( nFramesX > 1 ) ;
  Self.guid:= Guid;
  SpriteFileName:=Filename;
  FMoverData:= TJvSpriteMoverData.Create;
  FMoverData.FSprite := self;

  lstLabels := Tobjectlist<TJvSpriteLabel>.create (True);

  fpause    :=false;

  FramesX  := nFramesX;
  FramesY  := nFramesY;
  FFrameXMin  := 0;
  FFrameXMax  := nFramesX;
  FAnimationInterval := nDelay;
  fDelay:=0;

  FBMPCurrentFrame:=TBitmap.Create;
  FBMPCurrentFrame.Width := FBMP.Width div FramesX;
  FBMPCurrentFrame.Height := FBMP.Height div FramesY;
  FBMPCurrentFrame.PixelFormat := pf24bit;

  if (posX < 0) and (posY < 0 ) then  begin
    FPositionX := FBMPCurrentFrame.Width div 2;
    FPositionY := FBMPCurrentFrame.height div 2 ;
  end
  else begin
    FPositionX:= posX;
    FPositionY:= posY;
  end;

  rectSource.Left := 0;
  rectSource.Top := 0;
  rectSource.Right := ( FBMP.Width div FramesX)-1;
  rectSource.Bottom :=( FBMP.Height div FramesY)-1;


  CopyRectTo(FBMP, fBMPCurrentFrame,RectSource.left,RectSource.top,0,0,RectSource.Width+1,RectSource.Height+1, false ,0 ) ;

  FFrameWidth := FBMPCurrentFrame.Width;
  FFrameHeight := FBMPCurrentFrame.height;

  FOnDestinationReached := iOnDestinationReached ;

  Transparent := TransparentSprite;

end;

procedure TJvSprite.ChangeBitmap ( const FileName: string; const nFramesX, nFramesY, nDelay: integer);
var
rectSource: TRect;
begin
  if bmp = nil then exit; // non ancora caricato

  while fchangingFrame do begin
    application.ProcessMessages ;
  end;

  fchangingBitmap:= True;
  SpriteFileName:=Filename;

  FrameX := 0;
  FrameY := 0;
  FramesX  := nFramesX;
  FramesY  := nFramesY;
  FAnimated := ( nFramesX > 1 ) ;
  FFrameXMin  := 0;
  FFrameXMax  := nFramesX;
  FAnimationInterval := nDelay;

  FBMP.LoadFromFile(filename) ;

  FBMPCurrentFrame.Width := BMP.Width div FramesX;
  FBMPCurrentFrame.Height:= BMP.height div FramesY;
  FBMPCurrentFrame.PixelFormat := pf24bit;


  rectSource.Left := 0;
  rectSource.Top := 0;
  rectSource.Right := ( FBMP.Width div FramesX)-1;
  rectSource.Bottom :=( FBMP.Height div FramesY)-1;


  CopyRectTo(FBMP,fBMPCurrentFrame,RectSource.left,RectSource.top,0,0,RectSource.Width+1,RectSource.Height+1, false ,0 ) ;

  FFrameWidth := FBMPCurrentFrame.Width;
  FFrameHeight := FBMPCurrentFrame.height;

  fchangingBitmap:= false;

end;


constructor TJvSprite.Create ( const bmp: Tbitmap; const Guid: string; const nFramesX, nFramesY, nDelay, posX,posY: integer; const TransparentSprite: boolean);
var
rectSource: TRect;
begin
  if BMP.PixelFormat <> pf24bit then begin
    raise Exception.Create('Need 24 bit Bitmap!');
    Exit;
  end;
  inherited create;
  Destinationreached := true;
  FAnimated := ( nFramesX > 1 ) ;
  Self.Guid:= Guid;
  SpriteFileName:= 'TBitmap';
  FMoverData:= TJvSpriteMoverData.Create;
  FMoverData.FSprite := self;
  FPositionX:= posX;
  FPositionY:= posY;

  lstLabels := Tobjectlist<TJvSpriteLabel>.create (True);

  fpause    :=false;

  FramesX  := nFramesX;
  FramesY  := nFramesY;
  FrameXMin  := 0;
  FrameXMax  := nFramesX;
  FAnimationInterval := nDelay;
  fDelay:=0;


  FBMP:= TBitmap.Create;
  FBMP.Width := BMP.Width;
  FBMP.Height := BMP.Height;
  FBMP.PixelFormat := pf24bit;
  FBMP.Assign(bmp);

  FBMPCurrentFrame:=TBitmap.Create;
  FBMPCurrentFrame.Width := FBMP.Width div FramesX;
  FBMPCurrentFrame.Height := FBMP.Height div FramesY;
  FBMPCurrentFrame.PixelFormat := pf24bit;


  rectSource.Left := 0;
  rectSource.Top := 0;
  rectSource.Right := ( FBMP.Width div FramesX)-1;
  rectSource.Bottom :=( FBMP.Height div FramesY)-1;

  CopyRectTo(FBMP,fBMPCurrentFrame,RectSource.left,RectSource.top,0,0,RectSource.Width+1,RectSource.Height+1,false  ,0) ;

  FFrameWidth := FBMPCurrentFrame.Width;
  FFrameHeight := FBMPCurrentFrame.height;

  FOnDestinationReached := iOnDestinationReached ;


  Transparent := TransparentSprite;


end;
procedure CopyRectTo(SourceBitmap,DestBitmap: Tbitmap; SrcX, SrcY, DstX, DstY: integer; RectWidth, RectHeight: integer; Transparent: boolean;wTrans: integer);
var
  y,x: integer;
  ps, pd: pbyte;
  rl: integer;
  ppRGBCurrentFrame,ppVirtualRGB: pRGB;
  TransTRGB: Trgb;
  label skip;


begin

  if Transparent then begin

     TransTRGB:= TColor2TRGB (wtrans);

    SrcX:=0;
    SrcY:=0;
    if DstX < 0 then begin
      inc(SrcX, -DstX);
      dec(RectWidth, -DstX);
      DstX := 0;
    end;
    if DstY < 0 then begin
      inc(SrcY, -DstY);
      dec(RectHeight, -DstY);
      DstY := 0;
    end;

    DstX := imin(DstX, DestBitmap.Width - 1);
    DstY := imin(DstY, DestBitmap.Height - 1);

    SrcX := imin(imax(SrcX, 0), SourceBitmap.Width - 1);
    SrcY := imin(imax(SrcY, 0), SourceBitmap.Height - 1);

    if SrcX + RectWidth > SourceBitmap.Width then
      RectWidth := SourceBitmap.Width - SrcX;
    if SrcY + RectHeight > SourceBitmap.Height then
      RectHeight := SourceBitmap.Height - SrcY;

    if DstX + RectWidth > DestBitmap.Width then
      RectWidth := DestBitmap.Width - DstX;
    if DstY + RectHeight > DestBitmap.Height then
      RectHeight := DestBitmap.Height - DstY;

    for y := 0 to RectHeight - 1 do begin
      ppRGBCurrentFrame := GetSegment( SourceBitmap, SrcY + y, SrcX, RectWidth);
      ppVirtualRGB := GetSegment(DestBitmap, DstY + y, DstX, RectWidth);
      for x := SrcX to SrcX + RectWidth - 1 do begin
        if (ppRGBCurrentFrame.b <> TransTRGB.b) or (ppRGBCurrentFrame.g <> TransTRGB.g) or (ppRGBCurrentFrame.r <> TransTRGB.r) then begin
            ppVirtualRGB.b := ppRGBCurrentFrame.b;
            ppVirtualRGB.g:= ppRGBCurrentFrame.g;
            ppVirtualRGB.r:= ppRGBCurrentFrame.r;
        end;
        inc(pbyte(ppRGBCurrentFrame),3);
        inc(pbyte(ppVirtualRGB),3);

      end;
    end;


  end
  else begin // non transparent

    if DstX < 0 then begin
      inc(SrcX, -DstX);
      dec(RectWidth, -DstX);
      DstX := 0;
    end;
    if DstY < 0 then begin
      inc(SrcY, -DstY);
      dec(RectHeight, -DstY);
      DstY := 0;
    end;


    DstX := imin(DstX, DestBitmap.Width - 1);
    DstY := imin(DstY, DestBitmap.Height - 1);

    SrcX := imin(imax(SrcX, 0), SourceBitmap.Width - 1);
    SrcY := imin(imax(SrcY, 0), SourceBitmap.Height - 1);

    if SrcX + RectWidth > SourceBitmap.Width then
      RectWidth := SourceBitmap.Width - SrcX;
    if SrcY + RectHeight > SourceBitmap.Height then
      RectHeight := SourceBitmap.Height - SrcY;
    if DstX + RectWidth > DestBitmap.Width then
      RectWidth := DestBitmap.Width - DstX;
    if DstY + RectHeight > DestBitmap.Height then
      RectHeight := DestBitmap.Height - DstY;

      rl := (((RectWidth * 24) + 31) shr 5) shl 2; // row byte length
      for y := 0 to RectHeight - 1 do begin
        ps := GetSegment(SourceBitmap,SrcY + y, SrcX, RectWidth);
        pd := GetSegment(DestBitmap, DstY + y, DstX, RectWidth);
        CopyMemory(pd, ps, rl);
      end;
  end;

end;


procedure TJvSprite.ChangeBitmap ( const  bmp: Tbitmap;  const nFramesX, nFramesY, nDelay: integer);
var
rectSource: TRect;
begin
  if bmp = nil then exit;

  while fchangingFrame do begin
    application.ProcessMessages ;
  end;
  fchangingBitmap:= True;

  FramesX  := nFramesX;
  FramesY  := nFramesY;
  FAnimated := ( nFramesX > 1 ) ;
  FFrameXMin  := 0;
  FFrameXMax  := nFramesX;
  FAnimationInterval := nDelay;

  FBMP.Assign(bmp);

  fbmpCurrentFrame.Width := BMP.Width div FramesX;
  fbmpCurrentFrame.Height:= BMP.height div FramesY;
  FBMPCurrentFrame.PixelFormat := pf24bit;

  FrameX := 0;
  FrameY := 0;

  rectSource.Left := 0;
  rectSource.Top := 0;
  rectSource.Right := ( FBMP.Width div FramesX)-1;
  rectSource.Bottom :=( FBMP.Height div FramesY)-1;


  CopyRectTo(FBMP,fBMPCurrentFrame,RectSource.left,RectSource.top,0,0,RectSource.Width+1,RectSource.Height+1, false ,0 ) ;

  FFrameWidth := FBMPCurrentFrame.Width;
  FFrameHeight := FBMPCurrentFrame.height;

  fchangingBitmap:= false;

end;



destructor TJvSprite.Destroy;
begin

  FBMP.Free;
  FBMPCurrentFrame.Free;
  FMoverData.free;
  lstLabels.Free;
  inherited Destroy;
end;

procedure TJvSprite.MouseUp ( x,y: integer; Button: TMouseButton; Shift:TShiftState);
begin
  //
end;
procedure TJvSprite.MouseDown ( x,y: integer; Button: TMouseButton; Shift:TShiftState);
begin
  //
end;
procedure TJvSprite.MouseMove ( x,y: integer; Shift:TShiftState);
begin
  //
end;
procedure TJvSprite.iOnDestinationReached;
begin
  Destinationreached := true;
  if NotifyDestinationReached then begin
    FNotifyDestinationReached:= false;
    if Assigned(  fTheater.OnSpriteDestinationReached ) then fTheater.OnSpriteDestinationReached( fTheater, Self);
  end;

end;

function TJvSprite.GetPosition: TPoint;
begin
  Result := Point( Trunc( PositionX ), Trunc( PositionY ) );
end;

function TJvSprite.GetPositionX: single;
begin
  Result := FPositionX;
end;

function TJvSprite.GetPositionY: single;
begin
  Result := FPositionY;
end;


procedure TJvSprite.Move(interval: integer);
var
  temp: single;
  oldx, oldy: single;
  label endMove;

begin
  if LifeSpan < 0 then  begin
      Dead := true;
      Exit;
  end;

  if LifeSpan > 0 then
  begin
    LifeSpan := LifeSpan - interval;
    if LifeSpan <= 0 then
    begin
      Dead := true;
      Exit;
    end;
  end;


  if FMoverData.UseMovePath then begin

     if FMoverData.curWP >= FMoverData.MovePath.Count -1 then  begin
       PositionX := FMoverData.MovePath[       FMoverData.MovePath.Count-1      ].X;
       PositionY := FMoverData.MovePath[       FMoverData.MovePath.Count-1      ].Y;
       FMoverData.UseMovePath := False;
       FMoverData.curWP := 0;//FMoverData.MovePath.Count-1;
       if NotifyDestinationReached  then
         if Assigned( FOnDestinationReached ) then FOnDestinationReached(  ); // <--- arriva su chi ha fatto l'override


     end
     else begin

       FMoverData.TWPinterval := FMoverData.TWPinterval - interval;
       if FMoverData.TWPinterval <= 0 then begin

         FMoverData.TWPinterval := FMoverData.WPinterval;
         FMoverData.curWP := FMoverData.curWP + Round(FMoverData.Speed) ;  // posso andare oltre. per qusto sotto devo fixare

         if FMoverData.curWP <= FMoverData.MovePath.Count-1 then begin
           PositionX := FMoverData.MovePath[FMoverData.curWP].X;
           PositionY := FMoverData.MovePath[FMoverData.curWP].Y;
         end
         else begin
           FMoverData.UseMovePath := False;
           FMoverData.curWP := 0;//FMoverData.MovePath.Count-1;
           if NotifyDestinationReached  then
             if Assigned( FOnDestinationReached ) then FOnDestinationReached(  ); // <--- arriva su chi ha fatto l'override
         end;
       end;
     end;


     Exit;
  end;



  // move normal

     if ( PositionX = FMoverData.fDestinationX ) and ( PositionY = FMoverData.fDestinationY ) then begin
       if Not NotifyDestinationReached  then Exit;
       if Assigned( FOnDestinationReached ) then FOnDestinationReached(  ); // <--- arriva su chi ha fatto l'override
       Exit;
     end;

    oldx :=  PositionX;
    oldy :=  PositionY;

    (*************************************************************************)
    (*                              X                                        *)
    (*************************************************************************)
    temp :=  PositionX + FMoverData.SpeedX;
    if ( FMoverData.SpeedX > 0 ) and ( temp > FMoverData.fDestinationX ) then
      PositionX := FMoverData.fDestinationX
    else if ( FMoverData.SpeedX < 0 ) and ( temp < FMoverData.fDestinationX ) then
      PositionX := FMoverData.fDestinationX
    else
      PositionX := PositionX + FMoverData.SpeedX;

    (*************************************************************************)
    (*                              Y                                        *)
    (*************************************************************************)
    temp := PositionY + FMoverData.SpeedY;
    if ( FMoverData.SpeedY > 0 ) and ( temp > FMoverData.fDestinationY ) then
      PositionY := FMoverData.fDestinationY
    else if ( FMoverData.SpeedY < 0 ) and ( temp < FMoverData.fDestinationY ) then
      PositionY := FMoverData.fDestinationY
    else
      PositionY := PositionY + FMoverData.SpeedY;

    if Assigned( FOnDestinationReached ) then
      if ( PositionX <> oldx ) or ( PositionY <> oldY ) then
                  if Not NotifyDestinationReached  then Exit;

    if ( PositionX = FMoverData.fDestinationX ) and ( PositionY = FMoverData.fDestinationY ) then begin
  //          if Not NotifyDestinationReached then Exit;
      if Assigned(FOnDestinationReached) then FOnDestinationReached(   );

    end;


end;

procedure TJvSprite.SetDead(const Value: boolean);
begin
  if FDead <> Value then
  begin
    FDead := Value;
    if FDead then
      fVisible := false;
  end;
end;
function TJvSprite.CollisionDetect(aSprite: TJvSprite): Boolean;
var
  sprTrans,TargetTrans,aTRGB: TRGB;
  L,T,x,y: Integer;
  CollisionArray: array of array of Integer;

begin
  Result := False;
  if DrawingRect.IntersectsWith(aSprite.DrawingRect ) then begin

    if not FTheater.CollisionPrecisePixel then begin
       Result := True;
       Exit;
    end
    else begin
      if Transparent then begin
        sprTrans :=  GetTransparentcolor;
        TargetTrans := aSprite.GetTransparentcolor;

        L:=DrawingRect.Left;
        T:=aSprite.DrawingRect.Top;


        SetLength(CollisionArray, 0 , 0);
        SetLength(CollisionArray, FTheater.VirtualWidth , FTheater.VirtualHeight);


        // qui sotto va come concetto ma non � performante.
        for y := FrameHeight -1 downto 0 do begin
          for x := FrameWidth -1 downto 0 do begin

            aTRGB := TColor2TRGB( FBMPCurrentFrame.Canvas.Pixels [x,y] );
            if (aTRGB.b <> sprTrans.b ) or (aTRGB.g  <> sprTrans.g ) or (aTRGB.r  <> sprTrans.r ) then begin
              if (L + X < 0)  or (L + X > FTheater.VirtualWidth)
              or (T + Y < 0)  or (T + Y > FTheater.VirtualHeight)
              then  Continue;
              CollisionArray[L + X,T + Y]:= 1;
            end;
          end;
        end;

         L:=aSprite.DrawingRect.Left;
         T:=aSprite.DrawingRect.Top;

        for y := aSprite.FrameHeight -1 downto 0 do begin
          for x := aSprite.FrameWidth -1 downto 0 do begin
            aTRGB := TColor2TRGB( FBMPCurrentFrame.Canvas.Pixels [x,y] );
            if (aTRGB.b <> TargetTrans.b ) or (aTRGB.g  <> TargetTrans.g ) or (aTRGB.r  <> TargetTrans.r ) then begin

              if (L + X < 0)  or (L + X > FTheater.VirtualWidth)
              or (T + Y < 0)  or (T + Y > FTheater.VirtualHeight)
              then  Continue;
              if CollisionArray[L + X,T + Y] = 1 then begin
                Result := True;
                Exit;
              end;

            end;

          end;
        end;
      end
      else begin
        Result := True;
        Exit;
      end;
    end;

  end;
end;
procedure TJvSprite.SetPosition(const Value: TPoint);
begin
  fPosition := Value;
  PositionX := Value.X;
  PositionY := Value.Y;
end;

procedure TJvSprite.SetPositionX(const Value: single);
begin
  fPosition.X := trunc(Value);
  FPositionX := Value;

end;

procedure TJvSprite.SetPositionY(const Value: single);
begin
  fPosition.Y := Trunc(Value);
  FPositionY := Value;
end;

function TJvSprite.getTransparentColor: TRGB;
var
  aTrgb: Trgb;
begin
   if fTransparentForced  then begin
     Result:= TColor2TRGB (fTransparentColor);
   end
   else begin
     aTRGB := TColor2TRGB( FBMPCurrentFrame.Canvas.Pixels [0,0] );
   end;
end;

procedure TJvSprite.SetPriority(const Value: integer);
begin
  FPriority := Value;
  FTheater.SorTSprites;
end;

procedure TJvSprite.SetFrameXmin (const Value: Integer);
begin
  if Value > 0 then begin
    FFrameXmin := Value;
    FFrameX := FFrameXmin;
  end;
end;

procedure TJvSprite.SetFrameXmax (const Value: Integer);
begin
  if Value <= FframesX then FFrameXmax := Value;

end;

procedure TJvSprite.SetCurrentFrame;
begin
  if fchangingBitmap then Exit;
  fchangingFrame:= True;

  if FAnimated then begin


    Inc( fDelay );
      if fDelay >= AnimationInterval then  begin
        fDelay := 0;

        if AnimationDirection = dirForward then  begin
          Inc( FFrameX );
          if FFrameX > FFrameXMax -1 then begin
           FFrameX := FramexMin;

             if StopAtEndX then begin
              FFrameX := FFrameXMax -1;
             end;
             if DieAtEndX then begin
              Dead:= True;
              exit;
             end;
             if HideAtEndX then begin
              fVisible:= False;
              exit;
             end;

          end;

       end

       else if AnimationDirection = dirBackward then begin
          Dec( FFrameX );
            if FFrameX < FFrameXMin then  begin
             FFrameX:= FFrameXMin;
             if StopAtEndX then begin
              FFrameX := FFrameXMin ;
             end;
             if DieAtEndX then begin
              Dead:= True;
              exit;
             end;
             if HideAtEndX then begin
              fVisible:= False;
              exit;
             end;

          end;
       end;

    end;
  end;


  DrawFrame;
  fchangingFrame:= false;

end;
procedure TJvSprite.DrawFrame;
var
  rectSource : TRect;
begin
  rectSource.Left := FrameX * BMP.Width div FramesX;
  rectSource.Top := (FrameY-1) * BMP.Height div FramesY;
  rectSource.Right := (rectSource.Left + BMP.Width div FramesX)-1;
  rectSource.Bottom :=( rectSource.Top + BMP.Height div FramesY)-1;

  if FFrameX > FFrameXMax -1 then
    FFrameX := FFrameXmin;

  CopyRectTo(FBMP,fBMPCurrentFrame,RectSource.left,RectSource.top,0,0,RectSource.Width+1,RectSource.Height+1,false ,0) ;


  DrawingRect := rect(Trunc( Position.X )  - fBmpCurrentFrame.Width div 2,
  Trunc( Position.Y ) -  fBmpCurrentFrame.height div 2,
  (Trunc(Position.X ) - fBmpCurrentFrame.Width div 2 ) + fBmpCurrentFrame.Width,
  (Trunc(Position.Y ) -  fBmpCurrentFrame.height div 2) + fBmpCurrentFrame.height);
  //DrawingRect := rect(Trunc( Position.X )  - FrameWidth div 2,
  //Trunc( Position.Y ) -  FrameHeight div 2,
  //(Trunc(Position.X ) - FrameWidth div 2 ) + BmpCurrentFrame.Width,
  //(Trunc(Position.Y ) -  FrameHeight div 2) + BmpCurrentFrame.height);

end;
procedure TJvSprite.Render;
var
  i,y,X: integer;
  wTrans: dword;
  diff,textwidth: Integer;
begin

  X:= DrawingRect.Left ;
  Y:= DrawingRect.top;


  // labels

   for I := 0 to lstLabels.Count -1 do begin

    if lstLabels.Items [i].LifeSpan > 0 then  begin
      lstLabels.Items [i].LifeSpan := lstLabels.Items [i].LifeSpan - fTheater.thrdAnimate.Interval ;
      if lstLabels.Items [i].LifeSpan = 0 then begin
         lstLabels.Items [i].Dead := true;
      end;
    end;


    if lstLabels.Items [i].lVisible  then begin


      fBMPCurrentFrame.Canvas.Font.Assign( lstLabels.Items[i].lFont );
      fBMPCurrentFrame.Canvas.pen.mode := lstLabels.Items[i].lpenmode ;
      fBMPCurrentFrame.Canvas.pen.Color :=  fBMPCurrentFrame.Canvas.Font.Color;
      fBMPCurrentFrame.Canvas.Brush.Style := bsClear;
      fBMPCurrentFrame.Canvas.Font.Quality :=  fqAntialiased;

      if lstLabels.Items[i].lX =-1 then begin    // -1 Center X
          textWidth:=fBMPCurrentFrame.Canvas.TextWidth(lstLabels.Items[i].lText) ;
          Diff := ((FFrameWidth - textWidth) div 2);
          fBMPCurrentFrame.Canvas.TextOut ( diff ,
          lstLabels.Items[i].lY, lstLabels.Items[i].lText  ) ;

      end
      else
      fBMPCurrentFrame.Canvas.TextOut(lstLabels.Items[i].lX , lstLabels.Items[i].lY, lstLabels.Items[i].lText  ) ;


    end;
   end;



   if Transparent then begin

     if fTransparentForced  then begin
       wTrans:= fTransparentColor;
     end
     else begin
       wtrans:= fBMPCurrentFrame.Canvas.Pixels [0,0];
     end;
   end;

   if GrayScale then DoGrayScale ( fBmpCurrentFrame );
   CopyRectTo( fBmpCurrentFrame,FTheater.fvirtualBitmap,0,0,X,Y,fBmpCurrentFrame.Width+1, fBmpCurrentFrame.height+1,Transparent,wtrans ) ;

end;
procedure TJvSprite.MakeDelay(msecs: integer);
var
  FirstTickCount: longint;
begin
  FirstTickCount := GetTickCount;
   repeat
     Application.ProcessMessages;
   until ((GetTickCount-FirstTickCount) >= Longint(msecs));
end;

constructor TJvTheater.Create(Owner: TComponent);
begin
  inherited Create(Owner);
  lstSprites := TObjectList<TJvSprite>.Create (true);
  lstNewSprites := TObjectList<TJvSprite>.Create (false);

  if (csDesigning in ComponentState) then
    FAnimationInterval :=20;

  if not (csDesigning in ComponentState) then  begin
    fVirtualBitmap := TBitmap.Create;
    fVirtualBitmap.Width := Width;
    fVirtualBitmap.Height := Height;
    fVirtualBitmap.PixelFormat := pf24bit;

    lstSpriteClicked:= TObjectList<TJvSprite>.Create(false); // false o ad ogni clear distrugge gli sprite
    lstSpriteMoved:= TObjectList<TJvSprite>.Create(false);
    thrdAnimate := ira_ThreadTimer.Create(self);
    thrdAnimate.KeepAlive := True;
    thrdAnimate.Interval := 20;
    thrdAnimate.OnTimer :=  OnTimer ;
    Active := true;
  end;

end;

destructor TJvTheater.Destroy;
begin

  if not (csDesigning in ComponentState) then begin
    FActive := false;
    thrdAnimate.Enabled := False;
    RemoveAllSprites ;
    FreeAndNil(fVirtualBitmap);
    lstSpriteClicked.free;
    lstSpriteMoved.Free;
    thrdAnimate.Free;
    lstNewSprites.free;
    lstSprites.Free;
  end;

  inherited;
end;

procedure TJvTheater.SetCollisionDelay(const nDelay: integer);
begin
  if nDelay > 0 then begin
    fCollisionDelay := nDelay;
    iCollisionDelay := nDelay;
  end;
end;
procedure TJvTheater.SetShowPerformance(const value: boolean);
begin
  fShowPerformance := value;
end;

procedure TJvTheater.PaintVisibleBitmap ( Interval: integer);
begin

  if (csDesigning in ComponentState) or (fVirtualBitmap.Height = 0) or (fVirtualBitmap.Width = 0) then   exit;

  if assigned (FBeforeRender) then
    FBeforeRender (Self, fVirtualBitmap );

  if ShowPerformance then  begin
    if GetTickCount > nPerformanceEnd then
    begin
      nPerformanceEnd := GetTickCount + 1000;
      nShowFrames := nFrames;
      nFrames := 0;
    end;
    fVirtualBitmap.Canvas.Brush.Color := clWhite;
    fVirtualBitmap.Canvas.Brush.Style := bsSolid;
    fVirtualBitmap.Canvas.Font.Assign( self.Font );
    fVirtualBitmap.Canvas.TextOut( 4, 4, IntToStr( nShowFrames ) );
  end;


  BitBlt(Canvas.Handle, 0, 0, Width, Height, fVirtualBitmap.Canvas.Handle, 0, 0, SRCCOPY);


  if assigned (FAfterRender) then
    FAfterRender (Self, fVirtualBitmap );


    //    StretchDIBits(Canvas.Handle, 0, 0, dx, dy,
    //      0, 0, Width, Height, VisibleBitmap.fData, VisibleBitmap.info, DIB_RGB_COLORS, SRCCOPY);

end;

procedure TJvTheater.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited;
  if (csReading in ComponentState) or (csDesigning in ComponentState) or (csLoading in ComponentState) then
    if assigned(fVirtualBitmap) then  begin
      fVirtualBitmap.Width := Width;
      fVirtualBitmap.Height := Height;
    end;
end;

procedure TJvTheater.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: integer;
  ParForm: TCustomForm;
  spr: TJvSprite;
  pt: TPoint;
  BmpX,BmpY: integer;
  Label NoMoreSprites;
begin
  inherited;
  if not ClickSprites then exit;

  ParForm := GetParentForm(Self);
  if (ParForm<>nil) and (ParForm.Visible) and CanFocus then
    SetFocus;

  pt := Point( x, y );

  if Assigned( FOnmousedown )  then
   FOnmousedown( self, Button, Shift, X, Y );

  lstSpriteClicked.clear;

      for i := lstSprites.Count - 1 downto 0 do begin
        spr := lstSprites[i];
        if spr.Visible then
        begin
          if spr.DrawingRect.Contains ( pt ) then begin
            bmpX:= spr.DrawingRect.Right  - pt.X    ;
            bmpX:= spr.DrawingRect.Width - bmpX;
            bmpY:= spr.DrawingRect.bottom - pt.Y;
            bmpY:= spr.DrawingRect.Height - bmpY;
            Spr.MouseX := bmpX;
            Spr.MouseY := bmpY;
            if spr.Transparent then begin          // Transaprent
              if ClickSpritesPrecise then begin
                if spr.fBMPCurrentFrame.Canvas.Pixels [BmpX,BmpY] <> spr.fBMPCurrentFrame.Canvas.Pixels [0,0] then begin
                  spr.MouseDown(bmpX, bmpY, Button, Shift );
                  lstSpriteClicked.Add(spr);
                end;
              end
              else
              begin
                spr.MouseDown(bmpX, bmpY, Button, Shift);
                lstSpriteClicked.Add(spr);
              end;
            end
            else begin  // no transparent
                spr.MouseDown(bmpX, bmpY, Button, Shift);
                lstSpriteClicked.Add(spr);
            end;
          end;
        end;

      end;

    if Assigned( FOnSpritemousedown ) and (lstSpriteClicked.Count > 0)  then
      FOnSpritemousedown( self, lstSpriteClicked , Button, Shift );

end;



procedure TJvTheater.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  lastx, lasty: integer;
  i, BmpX,BmpY: integer;
  spr: TJvSprite;
  pt: TPoint;
begin
  inherited;
//  if not ClickSprites then
//    Exit;

  if changeCursor then cursor := crDefault;

  lastx := x;
  lasty := y;


  fLastMouseMoveX := lastx;
  fLastMouseMoveY := lasty;
  pt := Point( x, y );



  // normal
  if Assigned( FOnMouseMove ) then
    FOnMouseMove( self, Shift,  X ,  Y  );

  lstSpriteMoved.Clear ;
  for i := lstSprites.Count - 1 downto 0 do begin
    spr := lstSprites[i];
    if spr.Visible then  begin
      if spr.DrawingRect.Contains ( pt ) then begin
        bmpX:= spr.DrawingRect.Right  - pt.X    ;
        bmpX:= spr.DrawingRect.Width - bmpX;
        bmpY:= spr.DrawingRect.bottom - pt.Y;
        bmpY:= spr.DrawingRect.Height - bmpY;
        Spr.MouseX := bmpX;
        Spr.MouseY := bmpY;

        if spr.Transparent then begin          // Transparent
          if ClickSpritesPrecise then begin
            if spr.fBMPCurrentFrame.Canvas.Pixels [BmpX,BmpY] <> spr.fBMPCurrentFrame.Canvas.Pixels [0,0] then begin
              if changeCursor then cursor := crHandpoint;
              spr.MouseMove(bmpX, bmpY, Shift );
              lstSpriteMoved.Add(spr);
            end;
          end
          else
          begin
            if changeCursor then cursor := crHandpoint;
            spr.MouseMove(bmpX, bmpY,  Shift);
            lstSpriteMoved.Add(spr);
          end;
        end
        else begin // no transparent
            if changeCursor then cursor := crHandpoint;
            spr.MouseMove(bmpX, bmpY,  Shift);
            lstSpriteMoved.Add(spr);
        end;
      end;
    end;
end;


    if (lstSpriteMoved.Count > 0) and( Assigned( FOnSpriteMouseMove ) )  then begin
      FOnSpriteMouseMove( self, lstSpriteMoved,Shift );
    end;

end;

procedure TJvTheater.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i, BmpX,BmpY: integer;
  spr: TJvSprite;
  pt: TPoint;
begin

  inherited MouseUp( Button, Shift, X, Y );
  if not ClickSprites then
    Exit;

  pt := Point( x, y );

  lstSpriteClicked.Clear ;
      for i := lstSprites.Count - 1 downto 0 do begin
        spr := lstSprites[i];
        if spr.Visible then begin
          if spr.DrawingRect.Contains ( pt ) then begin
            bmpX:= spr.DrawingRect.Right  - pt.X    ; // <--- sul virtualBitmap
            bmpX:= spr.DrawingRect.Width - bmpX;
            bmpY:= spr.DrawingRect.bottom - pt.Y;
            bmpY:= spr.DrawingRect.Height - bmpY;
            Spr.MouseX := bmpX;
            Spr.MouseY := bmpY;
            if spr.Transparent then begin          // Transaprent
              if ClickSpritesPrecise then begin

                if spr.fBMPCurrentFrame.Canvas.Pixels [BmpX,BmpY] <> spr.fBMPCurrentFrame.Canvas.Pixels [0,0] then begin
                  spr.MouseUp(bmpX, bmpY, Button, Shift);
                  lstSpriteClicked.Add(spr);

                end;
              end
              else
              begin
                  spr.MouseUp(bmpX, bmpY, Button, Shift);
                  lstSpriteClicked.Add(spr);
              end;
            end
            else begin // no transparent
                  spr.MouseUp(bmpX, bmpY, Button, Shift);
                  lstSpriteClicked.Add(spr);
            end;
          end;
        end;
    end;


    if Assigned( FOnSpriteMouseUp ) and (lstSpriteClicked.Count > 0)
      then  FOnSpriteMouseUp( self, lstSpriteClicked , Button, Shift );

end;

function GetSegment(bitmap:TBitmap; Row: integer; Col: integer; Width: integer): pointer;
begin
    result := bitmap.Scanline[Row];
    inc(pbyte(result), Col * 3);
end;


procedure DoGrayScale (bitmap:TBitmap);
var
  x, y,v: integer;
  ppx: PRGB;
  TransTRGB : TRGB;
  label skip;
begin
  TransTRGB := TColor2TRGB( bitmap.Canvas.Pixels[0,0]);
  for y := 0 to bitmap.height - 1 do  begin
    ppx := bitmap.ScanLine[y];
    for x := 0 to bitmap.Width -1 do begin
      if (ppx^.b = TransTRGB.b) and (ppx^.g = TransTRGB.g) and (ppx^.r = TransTRGB.r) then goto skip;

      with ppx^ do begin
        v := (r * 21 + g * 71 + b * 8) div 100;
        r := v;
        g := v;
        b := v;
      end;

      SKIP:
      inc(ppx);
    end;
   end;
end;



end.





