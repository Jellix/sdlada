--
--
--

with SDL.Audio.Callback,
     SDL.Audio.Streams;

package Audiostream_Callbacks is
   use SDL.Audio;

   Stream : Streams.Audio_Stream;

   type User_Data is null record; -- No user data here.

   procedure User_Callback (Userdata  : in out User_Data;
                            Audio_Buf : in     SDL.Audio.Buffer_Type);

   procedure Callback is new
     SDL.Audio.Callback (User_Data     => User_Data,
                         User_Callback => User_Callback);

end Audiostream_Callbacks;
