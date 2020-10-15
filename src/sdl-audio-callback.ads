--------------------------------------------------------------------------------------------------------------------
--  This software is provided 'as-is', without any express or implied
--  warranty. In no event will the authors be held liable for any damages
--  arising from the use of this software.
--
--  Permission is granted to anyone to use this software for any purpose,
--  including commercial applications, and to alter it and redistribute it
--  freely, subject to the following restrictions:
--
--     1. The origin of this software must not be misrepresented; you must not
--     claim that you wrote the original software. If you use this software
--     in a product, an acknowledgment in the product documentation would be
--     appreciated but is not required.
--
--     2. Altered source versions must be plainly marked as such, and must not be
--     misrepresented as being the original software.
--
--     3. This notice may not be removed or altered from any source
--     distribution.
--------------------------------------------------------------------------------------------------------------------
--  SDL.Audio.Callback
--------------------------------------------------------------------------------------------------------------------
with SDL.Audio.Frames;

generic
   type User_Data is private; --  type of data being passed in the callback
   with package Audio_Frames is new SDL.Audio.Frames.Buffer_Overlays (<>);
   --  The instance of the SDL.Audio.Frames.Buffer_Overlay you use for your
   --  audio data.
   with procedure User_Callback (Data   : in out User_Data;
                                 Stream : in out Audio_Frames.Frames);
   --  This shall be your actual callback function being called by the wrapper
   --  declared here.
   --  The Stream is declared 'in out', so that the same type of callback can be
   --  used for both recording and playing callbacks, in practive it is either
   --  'in' or 'out', never both.
procedure SDL.Audio.Callback (Data   : in System.Address;
                              Stream : in Buffer_Base;
                              Length : in Interfaces.C.int) with
  Convention => C;
