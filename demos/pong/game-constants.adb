--  Pong-Demo for SDLAda, game constants.
--  Copyright (C) 2020, Vinzent "Jellix" Saranen

package body Game.Constants is

   function Get (Mode : in SDL.Video.Displays.Mode) return Screen_Constants is
     (Screen_Constants'(Game_Speed        => Ada.Real_Time.Milliseconds (10),
                        Background_Color  => Black,
                        Line_Colour       => Gray,
                        Ball_Colour       => White,
                        Paddle_Colour     => White,
                        Min_Winning_Score => 11,
                        Min_Difference    => 2,
                        Left_Goal         => Left_Goal (Mode => Mode),
                        Right_Goal        => Right_Goal (Mode => Mode),
                        Ball_Size         => Ball_Size (Mode => Mode),
                        Paddle_Width      => Paddle_Width (Mode => Mode),
                        Paddle_Height     => Paddle_Height (Mode => Mode),
                        Ball_Initial      => Ball_Initial (Mode => Mode),
                        Ball_Bounds       => Ball_Bounds (Mode => Mode),
                        Paddle_Bounds     => Paddle_Bounds (Mode => Mode),
                        Threshold         => Threshold (Mode => Mode),
                        Ball_Speed        => Ball_Speed (Mode => Mode),
                        Computer_Speed    => Computer_Speed (Mode => Mode),
                        Player_Speed      => Player_Speed (Mode => Mode)));
   --  If this function stays in the private part of the spec, we get an
   --  Program_Error "access before elaboration". Weird.

end Game.Constants;
