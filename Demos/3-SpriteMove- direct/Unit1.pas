unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,math,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Generics.Collections ,Generics.Defaults,
  JvSpriteEngine;

type
  TForm1 = class(TForm)
    Button1: TButton;
    JvTheater1: TJvTheater;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure JvTheater1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure JvTheater1SpriteDestinationReached(Sender: TObject; ASprite: TJvSprite);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    function GetIsoDirection (X1,Y1,X2,Y2:integer): integer;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  gabriel,shahira: TBitmap;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  Background: TJvSprite;
begin

  Background:= JvTheater1.CreateSprite('..\..\..\!media\back1.bmp','background',{framesX}1,{framesY}1,{Delay}0,{X}0,{Y}0,{transparent}false,{Priority}0);
  Background.Position := Point( Background.FrameWidth div 2 , Background.FrameHeight div 2 );

  JvTheater1.Active := True;

  gabriel := TBitmap.Create;
  gabriel.LoadFromFile( '..\..\..\!media\gabriel_WALK.bmp');

  shahira := TBitmap.Create;
  shahira.LoadFromFile( '..\..\..\!media\shahira_WALK.bmp');

  JvTheater1.CreateSprite(gabriel ,'gabriel',{framesX}15,{framesY}6,{Delay}7,{X}100,{Y}100,{transparent}true,{Priority}1);
  JvTheater1.CreateSprite(shahira,'shahira',{framesX}15,{framesY}6,{Delay}7,{X}200,{Y}100,{transparent}true,{Priority}1);
  gabriel.Free;
  shahira.Free;

  Randomize;

end;




function TForm1.GetIsoDirection (X1,Y1,X2,Y2:integer): integer;
begin

  if (X2 = X1) and (Y2 = Y1) then Result:=1

  else if (X2 = X1) and (Y2 < Y1) then Result:=4
  else if (X2 = X1) and (Y2 > Y1) then Result:=1

  else if (X2 < X1) and (Y2 < Y1) then Result:=5
  else if (X2 > X1) and (Y2 < Y1) then Result:=3

  else if (X2 > X1) and (Y2 > Y1) then Result:=2
  else if (X2 < X1) and (Y2 > Y1) then Result:=6

  else if (X2 > X1) and (Y2 = Y1) then Result:=3
  else if (X2 < X1) and (Y2 = Y1) then Result:=5;


end;

procedure TForm1.JvTheater1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  SpriteGabriel, SpriteShahira: TJvSprite;
begin

   SpriteGabriel:= JvTheater1.FindSprite('gabriel');
   SpriteShahira:= JvTheater1.FindSprite('shahira');

   SpriteGabriel.MoverData.Destination := Point(X, Y);
   SpriteShahira.MoverData.Destination := Point(X, Y);
   SpriteGabriel.NotifyDestinationReached := True;
   SpriteShahira.NotifyDestinationReached := True;

   SpriteGabriel.MoverData.Speed := 2.0;
   SpriteShahira.MoverData.Speed := 2.0;

end;

procedure TForm1.JvTheater1SpriteDestinationReached(Sender: TObject; ASprite: TJvSprite);
begin
  ShowMessage( ASprite.Guid + ' reached destination point.');
end;



procedure TForm1.Timer1Timer(Sender: TObject);
var
  SpriteGabriel, SpriteShahira: TJvSprite;
begin

   SpriteGabriel:= JvTheater1.FindSprite('gabriel');
   SpriteShahira:= JvTheater1.FindSprite('shahira');
   SpriteGabriel.FrameY :=  GetIsoDirection ( SpriteGabriel.Position.X, SpriteGabriel.Position.Y,
                                              SpriteGabriel.MoverData.Destination.X,SpriteGabriel.MoverData.Destination.Y);
   SpriteShahira.FrameY :=  GetIsoDirection ( SpriteShahira.Position.X, SpriteShahira.Position.Y,
                                              SpriteShahira.MoverData.Destination.X,SpriteShahira.MoverData.Destination.Y);

end;

procedure TForm1.Button1Click(Sender: TObject);
var
  SpriteGabriel, SpriteShahira: TJvSprite;
begin

   SpriteGabriel:= JvTheater1.FindSprite('gabriel');
   SpriteShahira:= JvTheater1.FindSprite('shahira');
   SpriteGabriel.PositionX := 100;
   SpriteGabriel.PositionY := randomrange ( 50,580);
   SpriteShahira.PositionX := 1000;
   SpriteShahira.PositionY := randomrange ( 50,580);


end;


end.
