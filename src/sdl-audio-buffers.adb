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

package body SDL.Audio.Buffers is

   function To_Buffer (Audio_Buf : in Buffer_Base;
                       Audio_Len : in Byte_Count)
                      return Buffer_Type is
   begin
      return Buffer_Type'(Base   => Audio_Buf,
                          Length => Audio_Len);
   end To_Buffer;


   function Allocate (Length : in Byte_Count)
                     return SDL.Audio.Buffer_Type
   is
      function C_Calloc (Count : in Byte_Count;
                         Size  : in Byte_Count) return Buffer_Base;
      pragma Import (C, C_Calloc, "calloc");

      Base : constant Buffer_Base := C_Calloc (Count => Length, Size => 1);
   begin
      return To_Buffer (Audio_Buf => Base,
                        Audio_Len => Length);
   end Allocate;


   procedure Release (Buffer : in out SDL.Audio.Buffer_Type)
   is
      procedure C_Free (Buffer : in Buffer_Base);
      pragma Import (C, C_Free, "free");
   begin
      C_Free (SDL.Audio.Base (Buffer));
   end Release;


end SDL.Audio.Buffers;
