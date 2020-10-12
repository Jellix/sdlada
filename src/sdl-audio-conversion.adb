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

package body SDL.Audio.Conversion is

   ---------------------------------------------------------------------
   --  Build_CVT
   ---------------------------------------------------------------------
   procedure Build_CVT (CVT          : in out SDL.Audio.Conversion.CVT;
                        Src_Format   : in     Format_Id;
                        Src_Channels : in     Interfaces.Unsigned_8;
                        Src_Rate     : in     Interfaces.C.int;
                        Dst_Format   : in     Format_Id;
                        Dst_Channels : in     Interfaces.Unsigned_8;
                        Dst_Rate     : in     Interfaces.C.int;
                        Success      :    out Boolean)
   is
      ------------------------------------------------------------------
      --  C_Build_CVT
      ------------------------------------------------------------------
      function C_Build_CVT (CVT          : in System.Address; --  in out Conversion;
                            Src_Format   : in Format_Id;
                            Src_Channels : in Interfaces.Unsigned_8;
                            Src_Rate     : in Interfaces.C.int;
                            Dst_Format   : in Format_Id;
                            Dst_Channels : in Interfaces.Unsigned_8;
                            Dst_Rate     : in Interfaces.C.int) return Interfaces.C.int with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_BuildAudioCVT";
      C_Result : Interfaces.C.int;
   begin
      C_Result := C_Build_CVT (CVT          => CVT'Address,
                               Src_Format   => Src_Format,
                               Src_Channels => Src_Channels,
                               Src_Rate     => Src_Rate,
                               Dst_Format   => Dst_Format,
                               Dst_Channels => Dst_Channels,
                               Dst_Rate     => Dst_Rate);

      Success := C_Result = 1;
   end Build_CVT;

   ---------------------------------------------------------------------
   --  Convert
   ---------------------------------------------------------------------
   procedure Convert (CVT     : in out SDL.Audio.Conversion.CVT;
                      Success :    out Boolean)
   is
      ------------------------------------------------------------------
      --  C_Convert
      ------------------------------------------------------------------
      function C_Convert (CVT : in System.Address) --  in out Conversion
                          return Interfaces.C.int with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_ConvertAudio";
      C_Result : Interfaces.C.int;
   begin
      C_Result := C_Convert (CVT => CVT'Address);

      Success := C_Result = 0;
   end Convert;

end SDL.Audio.Conversion;
