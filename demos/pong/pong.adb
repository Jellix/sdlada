--  Pong-Demo for SDLAda, root package for graphics objects.
--  Copyright (C) 2012 - 2020, Vinzent "Jellix" Saranen

package body Pong is

   ---------------------------------------------------------------------
   --  Position
   ---------------------------------------------------------------------
   function Position (This : in Display_Object) return SDL.Coordinates is
   begin
      return SDL.Coordinates'(X => SDL.Dimension (This.New_Pos.X),
                              Y => SDL.Dimension (This.New_Pos.Y));
   end Position;

   ---------------------------------------------------------------------
   --  Speed
   ---------------------------------------------------------------------
   function Speed (This : in Display_Object) return Float is
   begin
      return This.Speed;
   end Speed;

   ---------------------------------------------------------------------
   --  Set_Speed
   ---------------------------------------------------------------------
   procedure Set_Speed (This      : in out Display_Object;
                        New_Speed : in     Float) is
   begin
      This.Speed := New_Speed;
   end Set_Speed;

end Pong;
