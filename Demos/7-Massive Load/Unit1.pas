unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,math,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DSE_theater, Vcl.ExtCtrls, Vcl.StdCtrls, Generics.Collections ,Generics.Defaults,
  DSE_ThreadTimer, DSE_defs, JvSpriteEngine;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox6: TCheckBox;
    JvTheater1: TJvTheater;
    Timer1: TTimer;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure JvTheater1SpriteDestinationReached(Sender: TObject; ASprite: TJvSprite);
    procedure JvTheater1BeforeRender(Sender: TObject; VirtualBitmap: TBitmap);
    procedure Timer1Timer(Sender: TObject);
    procedure JvTheater1SpriteMouseMove(Sender: TObject; lstSprite: TObjectList<JvSpriteEngine.TJvSprite>; Shift: TShiftState);
  private
    { Private declarations }
    function GetIsoDirection (X1,Y1,X2,Y2:integer): integer;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  Background,SpriteTree, aSprite: Tjvsprite;
  i: Integer;
begin

  Background:= JvTheater1.CreateSprite('..\..\..\!media\back1.bmp','background',{framesX}1,{framesY}1,{Delay}0,{X}0,{Y}0,{transparent}false,{Priority}0);
  Background.Position := Point( Background.FrameWidth div 2 , Background.FrameHeight div 2 );

  JvTheater1.Active := True;
  Randomize;

  for i := 0 to 9 do begin
    aSprite:= JvTheater1.CreateSprite('..\..\..\!media\gabriel_WALK.bmp' ,'gabriel'+ IntToStr(i),{framesX}15,{framesY}6,{Delay}7,
    {X}randomrange(100,900),{Y}randomrange(100,500),{transparent}true,{Priority}1);
    aSprite.Collision := True;

  end;
  for i := 0 to 9 do begin
    aSprite:= JvTheater1.CreateSprite('..\..\..\!media\shahira_WALK.bmp' ,'shahira'+ IntToStr(i),{framesX}15,{framesY}6,{Delay}7,
    {X}randomrange(100,900),{Y}randomrange(100,500),{transparent}true,{Priority}1);
    aSprite.Collision := True;
  end;

  SpriteTree := JvTheater1.CreateSprite('..\..\..\!media\tree.bmp','tree',{framesX}2,{framesY}1,{Delay}5,{X}250,{Y}250,{transparent}true,
    {Priority}250+170); // !!! tree

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

procedure TForm1.JvTheater1BeforeRender(Sender: TObject; VirtualBitmap: TBitmap);
var
  Sprite: TJvSprite;
  I,k: Integer;
begin

    for I := 0 to 9 do begin
      Sprite:= JvTheater1.FindSprite('gabriel' + intTostr(i));
      Sprite.Priority := Sprite.Position.Y;
      if CheckBox6.Checked  then begin

        if Sprite.MoverData.MovePath.Count > 0 then begin
          VirtualBitmap.Canvas.Pen.Color := clSilver;

          VirtualBitmap.Canvas.MoveTo( Sprite.MoverData.MovePath[0].X,Sprite.MoverData.MovePath[0].Y );
          for k := 1 to Sprite.MoverData.MovePath.Count -1 do begin
            VirtualBitmap.Canvas.LineTo( Sprite.MoverData.MovePath[k].X,Sprite.MoverData.MovePath[k].Y );
          end;

        end;
      end;
    end;

    for I := 0 to 9 do begin
     Sprite:= JvTheater1.FindSprite('shahira'+ intTostr(i));
     Sprite.Priority := Sprite.Position.Y;
     if CheckBox6.Checked  then begin
        if Sprite.MoverData.MovePath.Count > 0 then begin
          VirtualBitmap.Canvas.Pen.Color := clRed;

          VirtualBitmap.Canvas.MoveTo( Sprite.MoverData.MovePath[0].X,Sprite.MoverData.MovePath[0].Y );
          for k := 1 to Sprite.MoverData.MovePath.Count -1 do begin
           VirtualBitmap.Canvas.LineTo( Sprite.MoverData.MovePath[k].X,Sprite.MoverData.MovePath[k].Y );
          end;
        end;
     end;
  end;

  Sprite := JvTheater1.FindSprite('tree');
  Sprite.Priority := Sprite.Position.Y + 170;

end;



procedure TForm1.JvTheater1SpriteDestinationReached(Sender: TObject; ASprite: TJvSprite);
begin
  aSprite.MoverData.MovePath.Reverse ;
  aSprite.NotifyDestinationReached := True;
  aSprite.MoverData.UseMovePath := True;
end;

procedure TForm1.JvTheater1SpriteMouseMove(Sender: TObject; lstSprite: TObjectList<JvSpriteEngine.TJvSprite>; Shift: TShiftState);
begin
  Label1.Caption := 'MouseMove : ' + lstSprite[0].Guid;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  Sprite: Tjvsprite;
  I: Integer;
begin

  for I := 0 to 9 do begin
     Sprite:= JvTheater1.FindSprite('gabriel' + intTostr(i));
     if Sprite.MoverData.CurWP < Sprite.MoverData.MovePath.Count -1 then begin
     Sprite.FrameY :=  GetIsoDirection ( Sprite.Position.X, Sprite.Position.Y,
                                                Sprite.MoverData.MovePath [ Sprite.MoverData.CurWP +1].X ,
                                                Sprite.MoverData.MovePath [ Sprite.MoverData.CurwP +1].Y);
     end;
  end;
  for I := 0 to 9 do begin
     Sprite:= JvTheater1.FindSprite('shahira' + intTostr(i));
     if Sprite.MoverData.CurWP < Sprite.MoverData.MovePath.Count -1 then begin
     Sprite.FrameY :=  GetIsoDirection ( Sprite.Position.X, Sprite.Position.Y,
                                                Sprite.MoverData.MovePath [ Sprite.MoverData.CurWP +1].X ,
                                                Sprite.MoverData.MovePath [ Sprite.MoverData.CurwP +1].Y);
     end;
  end;


end;


procedure TForm1.Button1Click(Sender: TObject);
var
  Sprite: Tjvsprite;
  Point,Point2,lastPoint :Tpoint;
  tmpPath: TList<TPoint>;
  I,wayPoints,k: Integer;
begin

   for I := 0 to 9 do begin
     Sprite:= JvTheater1.FindSprite('gabriel' + IntToStr(i));
     Sprite.PositionX := RandomRange(100,900);
     Sprite.PositionY := RandomRange(100,500);
     Sprite.MoverData.MovePath.Clear ;

     LastPoint := Sprite.Position;

     for WayPoints := 0 to 6 do begin
       Point.X:= randomrange ( 100,500);
       Point.Y:= randomrange ( 100,500);

       tmpPath:= TList<TPoint>.Create;
       GetLinePoints( LastPoint.X, LastPoint.Y,  Point.X, Point.Y,  tmpPath );

       for k := 0 to tmpPath.Count -1 do begin
         Point2:=tmpPath[k];
         Sprite.MoverData.MovePath.Add(Point2);
       end;
       LastPoint := Point;
       tmpPath.Free ;


     end;

     Sprite.MoverData.UseMovePath := True;
     Sprite.MoverData.Speed := 1.0;  // minimum usepath
     Sprite.MoverData.WPinterval  := 50; // delay
     Sprite.NotifyDestinationReached := True;

   end;

   for I := 0 to 9 do begin
     Sprite:= JvTheater1.FindSprite('shahira' + IntToStr(i));
     Sprite.PositionX := RandomRange(100,900);
     Sprite.PositionY := RandomRange(100,500);
     Sprite.MoverData.MovePath.Clear ;

     LastPoint := Sprite.Position;

     for WayPoints := 0 to 6 do begin
       Point.X:= randomrange ( 100,500);
       Point.Y:= randomrange ( 100,500);

       tmpPath:= TList<TPoint>.Create;
       GetLinePoints( LastPoint.X, LastPoint.Y,  Point.X, Point.Y,  tmpPath );

       for k := 0 to tmpPath.Count -1 do begin
         Point2:=tmpPath[k];
         Sprite.MoverData.MovePath.Add(Point2);
       end;
       LastPoint := Point;
       tmpPath.Free ;


     end;

     Sprite.MoverData.UseMovePath := True;
     Sprite.MoverData.Speed := 1.0;  // minimum usepath
     Sprite.MoverData.WPinterval  := 50; // delay
     Sprite.NotifyDestinationReached := True;

   end;


end;


procedure TForm1.Button2Click(Sender: TObject);
var
  Sprite: Tjvsprite;
  i: Integer;
  SpriteLabel : TjvspriteLabel;
begin

   for I := 0 to 9 do begin
     Sprite:= JvTheater1.FindSprite('gabriel' + IntToStr(i));
     Sprite.labels.Clear ;
     SpriteLabel := TjvspriteLabel.create(0,64,'Verdana',clYellow,clBlack,'Gabriel',pmCopy,True);
     Sprite.Labels.Add(SpriteLabel);
   end;
   for I := 0 to 9 do begin
     Sprite:= JvTheater1.FindSprite('shahira' + IntToStr(i));
     Sprite.labels.Clear ;
     SpriteLabel := TjvspriteLabel.create(0,64,'Verdana',clYellow,clBlack,'Shahira',pmCopy,True);
     Sprite.Labels.Add(SpriteLabel);
   end;

end;


end.
