--  Pong-Demo for SDLAda, root package for graphics objects.
--  Copyright (C) 2012 - 2020, Vinzent "Jellix" Saranen

with SDL.Video.Renderers;
private with SDL.Video.Palettes;

package Pong is

   type Display_Object is abstract tagged private;

   ---------------------------------------------------------------------
   --  Draw
   --
   --  Draws the display object through given renderer at its current
   --  position.
   ---------------------------------------------------------------------
   procedure Draw (This     : in out Display_Object;
                   Renderer : in out SDL.Video.Renderers.Renderer) is abstract;

   ---------------------------------------------------------------------
   --  Move
   --
   --  Moves the display object by one amount of its current velocity
   --  vector.
   ---------------------------------------------------------------------
   procedure Move (This    : in out Display_Object;
                   Clipped :    out Boolean) is abstract;

   ---------------------------------------------------------------------
   --  Position
   --
   --  Returns the current position of the object in screen coordinates.
   ---------------------------------------------------------------------
   function Position (This : in Display_Object) return SDL.Coordinates;

   ---------------------------------------------------------------------
   --  Speed
   --
   --  Returns the current speed of the object.
   ---------------------------------------------------------------------
   function Speed (This : in Display_Object) return Float;

   ---------------------------------------------------------------------
   --  Set_Speed
   --
   --  Sets a new speed for the the object.
   ---------------------------------------------------------------------
   procedure Set_Speed (This      : in out Display_Object;
                        New_Speed : in     Float);

private

   type Smooth_Coordinates is
      record
         X : Float;
         Y : Float;
      end record;

   type Smooth_Bounds is
      record
         Min : Smooth_Coordinates;
         Max : Smooth_Coordinates;
      end record;

   type Display_Object is abstract tagged
      record
         Bounds  : Smooth_Bounds;      --  Area in which movement is allowed.
         Old_Pos : Smooth_Coordinates; --  Retains old position when moved
         New_Pos : Smooth_Coordinates; --  New position after a call to Move
         Size    : SDL.Sizes;          --  Size of object (for collision detection).
         Colour  : SDL.Video.Palettes.Colour; --  Draw colour.
         Speed   : Float;              --  Moving speed of object.
      end record;

end Pong;
