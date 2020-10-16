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

procedure SDL.Audio.Callback (Data   : in System.Address;
                              Stream : in Buffer_Base;
                              Length : in Interfaces.C.int) is
   Ada_User_Data : User_Data with
     Import     => True,
     Convention => Ada;
   for Ada_User_Data'Address use Data;

   --  Assertions to ensure (at least in debug mode with assertions enabled)
   --  that frames are always full bytes (i.e. mod 8 = 0).
   pragma Assert (Audio_Frames.Frames'Component_Size mod System.Storage_Unit  = 0);

   --  We assume the buffers are contiguous (i.e. no weird padding), so the
   --  length in Frames (the actual type of each array element) is the array's
   --  component size divided by Storage_Unit (i.e. 8 bit).
   Frame_Size : constant Natural := Audio_Frames.Frames'Component_Size / System.Storage_Unit;

   --  Audio buffers should alway be proper multiples of two, so that the given
   --  length in bytes is divisable by a full frame.
   pragma Assert (Natural (Length) mod Audio_Frames.Frames'Component_Size = 0);

   --  The instance of Audio_Frames gives us all the information we need about
   --  the individual size of audio frames, so we can map them directly.
   Ada_Audio_Frames : Audio_Frames.Frames (1 .. Natural (Length) / Frame_Size) with
     Import     => True, -- Avoid default initialization.
     Convention => Ada,
     Address    => System.Address (Stream);
begin
   --  Call the actual user callback, but with a more type safe interface.
   User_Callback (Data   => Ada_User_Data,
                  Stream => Ada_Audio_Frames);
end SDL.Audio.Callback;
