--
--
--

with SDL.Audio.Callback,
     SDL.Audio.Frames,
     SDL.Audio.Streams;

package Audiostream_Callbacks is
   use SDL.Audio;

   type Sample_Type is range -2**15 .. 2**15 - 1;

   package Stereo_Buffers is
      new SDL.Audio.Frames.Buffer_Overlays (Sample_Type  => Sample_Type,
                                            Frame_Config => Frames.Config_Stereo);

   procedure User_Callback (Input_Stream : in out SDL.Audio.Streams.Audio_Stream;
                            Audio_Data   : in out Stereo_Buffers.Frames);
   --  The callback gets a reference to the conversion stream, reads it and puts
   --  it back into Audio_Data for playing.

   procedure Callback is new
     SDL.Audio.Callback (User_Data     => SDL.Audio.Streams.Audio_Stream,
                         Audio_Frames  => Stereo_Buffers,
                         User_Callback => User_Callback);

end Audiostream_Callbacks;
