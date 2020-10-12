--
--
--

with SDL.Audio.Streams;

package Audiostream_Callbacks is
   use SDL.Audio;

   Stream : Streams.Audio_Stream;

   procedure Callback (Userdata  : in User_Type;
                       Audio_Buf : in Buffer_Base;
                       Audio_Len : in Byte_Count);
   pragma Convention (C, Callback);

end Audiostream_Callbacks;
