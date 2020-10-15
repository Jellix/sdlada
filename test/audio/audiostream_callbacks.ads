--
--
--

with SDL.Audio.Callback,
     SDL.Audio.Frames,
     SDL.Audio.Streams;

package Audiostream_Callbacks is
   use SDL.Audio;

   Stream : Streams.Audio_Stream;

   type Sample_Type is range -2**15 .. 2**15 - 1;

   package Stereo_Buffers is
      new SDL.Audio.Frames.Buffer_Overlays (Sample_Type  => Sample_Type,
                                            Frame_Config => Frames.Config_Stereo);

   type User_Data is null record; -- No user data here.

   procedure User_Callback (Userdata   : in out User_Data;
                            Audio_Data : in out Stereo_Buffers.Frames);

   procedure Callback is new
     SDL.Audio.Callback (User_Data     => User_Data,
                         Audio_Frames  => Stereo_Buffers,
                         User_Callback => User_Callback);

end Audiostream_Callbacks;
