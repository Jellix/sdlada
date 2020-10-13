--  Pong-Demo for SDLAda, game constants.
--  Copyright (C) 2012 - 2020, Vinzent "Jellix" Saranen

with Ada.Real_Time;

with SDL.Video.Displays,
     SDL.Video.Palettes,
     SDL.Video.Rectangles;

package Game.Constants is

   use type SDL.Dimension;

   --  Most constants depend on the screen resolution. To avoid recalculating
   --  them over and over again, we provide functionality to calculate them
   --  once and for all once the screen size is known.
   type Screen_Constants is
      record
         --  Screen independent.
         Game_Speed       : Ada.Real_Time.Time_Span;    --  Frame/update rate.
         Background_Color : SDL.Video.Palettes.Colour;
         Line_Colour      : SDL.Video.Palettes.Colour;
         Ball_Colour      : SDL.Video.Palettes.Colour;
         Paddle_Colour    : SDL.Video.Palettes.Colour;

         --  Minimum score and points difference to reach winning condition.
         Min_Winning_Score : Positive;
         Min_Difference    : Positive;

         --  Screen dependent.
         Left_Goal      : SDL.Dimension;   -- X coordinate of left goal area
         Right_Goal     : SDL.Dimension;   -- X coordinate of right goal area
         Ball_Size      : SDL.Dimension;   -- Size of ball sqircle.
         Paddle_Width   : SDL.Dimension;   -- Width of a paddle.
         Paddle_Height  : SDL.Dimension;   -- Height (length) of a paddle.
         Ball_Initial   : SDL.Coordinates; -- Starting position of ball.
         Ball_Bounds    : SDL.Video.Rectangles.Rectangle; --  Ball movement area.
         Paddle_Bounds  : SDL.Video.Rectangles.Rectangle; -- movement bounds of paddle
         Threshold      : SDL.Dimension; --  Minimum position difference before computer moves its paddle.
         Ball_Speed     : Float;
         Computer_Speed : Float;
         Player_Speed   : Float;
      end record;

   ---------------------------------------------------------------------
   --  Get
   --
   --  Retrieve all video mode specific constants. See Screen_Constants
   --  type.
   ---------------------------------------------------------------------
   function Get (Mode : in SDL.Video.Displays.Mode) return Screen_Constants;

private

   Black : constant SDL.Video.Palettes.Colour :=
     SDL.Video.Palettes.Colour'(Red   => 16#00#,
                                Green => 16#00#,
                                Blue  => 16#00#,
                                Alpha => 16#FF#);

   Gray : constant SDL.Video.Palettes.Colour :=
     SDL.Video.Palettes.Colour'(Red   => 16#80#,
                                Green => 16#80#,
                                Blue  => 16#80#,
                                Alpha => 16#FF#);

   White : constant SDL.Video.Palettes.Colour :=
     SDL.Video.Palettes.Colour'(Red   => 16#FF#,
                                Green => 16#FF#,
                                Blue  => 16#FF#,
                                Alpha => 16#FF#);

   function Left_Goal (Mode : in SDL.Video.Displays.Mode) return SDL.Dimension is
     (Mode.Width / 16);

   function Right_Goal (Mode : in SDL.Video.Displays.Mode) return SDL.Dimension is
     (Mode.Width - Left_Goal (Mode));

   function Ball_Size (Mode : in SDL.Video.Displays.Mode) return SDL.Dimension is
     (Mode.Width / 80);

   function Paddle_Width (Mode : in SDL.Video.Displays.Mode) return SDL.Dimension is
     (Mode.Width / 80);

   function Paddle_Height (Mode : in SDL.Video.Displays.Mode) return SDL.Dimension is
     (Mode.Height / 8);

   function Ball_Initial (Mode : in SDL.Video.Displays.Mode) return SDL.Coordinates is
     (SDL.Coordinates'(X => Mode.Width  / 2 - Ball_Size (Mode) / 2,
                       Y => Mode.Height / 2 - Ball_Size (Mode) / 2));

   --  Ball can use the full screen
   function Ball_Bounds (Mode : in SDL.Video.Displays.Mode) return SDL.Video.Rectangles.Rectangle is
     (SDL.Video.Rectangles.Rectangle'(X      => 0,
                                      Y      => 0,
                                      Width  => Mode.Width,
                                      Height => Mode.Height));

   function Border_Left (Mode : in SDL.Video.Displays.Mode) return SDL.Dimension is
     (Mode.Width / 80);

   function Border_Top (Mode : in SDL.Video.Displays.Mode) return SDL.Dimension is
     (Mode.Height / 10);

   function Paddle_Bounds (Mode : in SDL.Video.Displays.Mode) return SDL.Video.Rectangles.Rectangle is
      (SDL.Video.Rectangles.Rectangle'(X      => Border_Left (Mode),
                                       Y      => Border_Top (Mode),
                                       Width  => Mode.Width  - 2 * Border_Left (Mode),
                                       Height => Mode.Height - 2 * Border_Top (Mode)));

   --  Minimum position difference before computer moves its paddle.
   function Threshold (Mode : in SDL.Video.Displays.Mode) return SDL.Dimension is
     (Paddle_Height (Mode) / 4);

   --  Speed constants for movement.
   function Ball_Speed (Mode : in SDL.Video.Displays.Mode) return Float is
     (Float (Mode.Width) / 160.0);

   function Computer_Speed (Mode : in SDL.Video.Displays.Mode) return Float is
     (Float (Mode.Height) / 50.0);

   function Player_Speed (Mode : in SDL.Video.Displays.Mode) return Float is
     (Float (Mode.Height) / 50.0);

end Game.Constants;
