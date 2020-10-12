--------------------------------------------------------------------------------------------------------------------
--  Copyright (c) 2020, Vinzent "Jellix" Saranen
--
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

package body SDL.Audio.Callbacks is

   procedure C_Callback (Data   : in User_Data_Ptr;
                         Stream : in Audio_Buffer;
                         Length : in Interfaces.C.int) is
      Ada_User_Data : User_Data with
        Import     => True,
        Convention => Ada;
      for Ada_User_Data'Address use Data;
      Ada_Audio_Data : Raw_Audio (0 .. Raw_Audio_Index (Length - 1)) with
        Import     => True,
        Convention => Ada,
        Address    => Stream;
   begin
      Callback (Data   => Ada_User_Data,
                Stream => Ada_Audio_Data);
   end C_Callback;

end SDL.Audio.Callbacks;
