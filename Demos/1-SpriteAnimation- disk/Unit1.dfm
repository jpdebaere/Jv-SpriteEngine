object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'JvSpriteEngine - disk'
  ClientHeight = 722
  ClientWidth = 1032
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object JvTheater1: TJvTheater
    Left = 0
    Top = 0
    Width = 1024
    Height = 600
    AnimationInterval = 20
    CollisionDelay = 0
    ShowPerformance = False
    OnSpriteMouseDown = JvTheater1SpriteMouseDown
    ClickSprites = True
    ClickSpritesPrecise = False
    CollisionPrecisePixel = False
    TabOrder = 0
  end
end
