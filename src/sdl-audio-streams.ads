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
--  SDL.Audio.Streams
--------------------------------------------------------------------------------------------------------------------

package SDL.Audio.Streams is

   ---------------
   --  Streams  --
   ---------------

   type Audio_Stream is private;

   function New_Stream (Source_Format   : in Audio_Format;
                        Source_Channels : in Channel_Count;
                        Source_Rate     : in Sample_Rate;
                        Dest_Format     : in Audio_Format;
                        Dest_Channels   : in Channel_Count;
                        Dest_Rate       : in Sample_Rate)
                       return Audio_Stream;

   procedure Stream_Put (Stream : in Audio_Stream;
                         Buffer : in Buffer_Type);

   procedure Stream_Get (Stream : in     Audio_Stream;
                         Buffer : in     Buffer_Type;
                         Read   :    out Byte_Count);

   function Stream_Available (Stream : in Audio_Stream)
                             return Byte_Count;

   procedure Stream_Flush (Stream : in Audio_Stream);

   procedure Stream_Clear (Stream : in Audio_Stream);

   procedure Free_Stream (Stream : in out Audio_Stream);

private

   type Audio_Stream_Record is null record;
   type Audio_Stream is access all Audio_Stream_Record;

end SDL.Audio.Streams;

