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

with SDL.Error;

package body SDL.Audio.Streams is

   ---------------
   --  Streams  --
   ---------------

   function New_Stream (Source_Format   : in Audio_Format;
                        Source_Channels : in Channel_Count;
                        Source_Rate     : in Sample_Rate;
                        Dest_Format     : in Audio_Format;
                        Dest_Channels   : in Channel_Count;
                        Dest_Rate       : in Sample_Rate)
                       return Audio_Stream
   is
      function SDL_New_Audio_Stream (Src_Format   : in Audio_Format;
                                     Src_Channels : in Channel_Count;
                                     Src_Rate     : in Sample_Rate;
                                     Dst_Format   : in Audio_Format;
                                     Dst_Channels : in Channel_Count;
                                     Dst_Rate     : in Sample_Rate)
                                    return Audio_Stream with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_NewAudioStream";

      Stream : Audio_Stream;
   begin
      Stream := SDL_New_Audio_Stream (Source_Format,
                                      Source_Channels,
                                      Source_Rate,
                                      Dest_Format,
                                      Dest_Channels,
                                      Dest_Rate);
      if Stream = null then
         raise Audio_Error with SDL.Error.Get;
      end if;
      return Stream;
   end New_Stream;

   procedure Stream_Put (Stream : in Audio_Stream;
                         Buffer : in Buffer_Type)
   is
      function SDL_Audio_Stream_Put (Stream : in Audio_Stream;
                                     Buf    : in System.Address;
                                     Len    : in C.int)
                                    return C.int with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_AudioStreamPut";

      Result : constant C.int
        := SDL_Audio_Stream_Put (Stream, System.Address (Buffer.Base), C.int (Buffer.Length));
   begin
      if Result /= SDL.Success then
         raise Audio_Error with SDL.Error.Get;
      end if;
   end Stream_Put;

   procedure Stream_Get (Stream : in     Audio_Stream;
                         Buffer : in     Buffer_Type;
                         Read   :    out Byte_Count)
   is
      function SDL_Audio_Stream_Get (Stream : in Audio_Stream;
                                     Buf    : in System.Address;
                                     Len    : in C.int)
                                    return C.int with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_AudioStreamGet";

      Result : constant C.int
        := SDL_Audio_Stream_Get (Stream, System.Address (Buffer.Base), C.int (Buffer.Length));
   begin
      if Result < 0 then
         raise Audio_Error with SDL.Error.Get;
      end if;
      Read := Byte_Count (Result);
   end Stream_Get;

   function Stream_Available (Stream : in Audio_Stream)
                             return Byte_Count
   is
      function SDL_Audio_Stream_Available (Stream : in Audio_Stream)
                                          return C.int with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_AudioStreamAvailable";
   begin
      return Byte_Count (SDL_Audio_Stream_Available (Stream));
   end Stream_Available;

   procedure Stream_Flush (Stream : in Audio_Stream)
   is
      function SDL_Audio_Stream_Flush (Stream : in Audio_Stream)
                                      return C.int with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_AudioStreamFlush";

      Dummy : constant C.int
        := SDL_Audio_Stream_Flush (Stream);
   begin
      null;
   end Stream_Flush;

   procedure Stream_Clear (Stream : in Audio_Stream)
   is
      procedure SDL_Audio_Stream_Clear (Stream : in Audio_Stream)
        with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_AudioStreamClear";
   begin
      SDL_Audio_Stream_Clear (Stream);
   end Stream_Clear;

   procedure Free_Stream (Stream : in out Audio_Stream)
   is
      procedure SDL_Free_Audio_Stream (Stream : in Audio_Stream)
        with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_FreeAudioStream";
   begin
      SDL_Free_Audio_Stream (Stream);
      Stream := null;
   end Free_Stream;

end SDL.Audio.Streams;

