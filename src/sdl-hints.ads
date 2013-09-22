--                              -*- Mode: Ada -*-
--  Filename        : sdl-hints.ads
--  Description     : Configuration variables.
--  Author          : Luke A. Guest
--  Created On      : Sun Sep 22 02:12:00 2013
package SDL.Hints is
   --  TODO: Make this more robust using more functions and platform specific
   --  packages with error checking on returned values?
   --  Would be nice to have the compiler only allow that which is allowed on
   --  a particular platform.
   --  It would be nice to have the binding test the return values as well,
   --  raising an exception on values that are just wrong for a particular
   --  platform, i.e. direct3d on Linux or Mac? Exception raised!

   --  This is raised when something has gone horribly wrong somewhere,
   --  i.e. setting the wrong hint on a platform that does not allow it.
   Hint_Error : exception;

   type Hint is
     (Frame_Buffer_Acceleration,
      Render_Driver,
      Render_OpenGL_Shaders,
      Render_Scale_Quality,
      Render_VSync,
      Video_X11_XVidMode,
      Video_X11_Xinerama,
      Video_X11_XRandR,
      Grab_Keyboard,
      Video_Minimise_On_Focus_Loss,
      Idle_Timer_Disabled,
      IOS_Orientations,
      XInput_Enabled, -- win
      Game_Controller_Config, -- win, mac, linux
      Joystick_Allow_Background_Events,
      Allow_Topmost,
      Timer_Resolution) with  -- win7 and earlier
     Discard_Names => True;

   -- TODO: make this private.
   function Value (H : in Hint) return String with
     Inline => True;

   type Priorities is (Default, Normal, Override) with
     Convention => C;

   procedure Clear with
      Import        => True,
      Convention    => C,
      External_Name => "SDL_ClearHints";

   function Get (H : in Hint) return String;
   function Set (H : in Hint; Value : in String) return Boolean;
   function Set (H : in Hint; Value : in String; Priority : in Priorities)
                return Boolean;
end SDL.Hints;
