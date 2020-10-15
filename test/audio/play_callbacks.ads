--
--
--

with SDL.Audio.Callback,
     SDL.Audio.Frames;

package Play_Callbacks is
   use SDL.Audio;

   type User_Data is null record;

   type Sample_Type is range -2**15 .. 2**15 - 1
     with Size => 16;

   package Samples is
      new SDL.Audio.Frames.Buffer_Overlays (Sample_Type  => Sample_Type,
                                            Frame_Config => SDL.Audio.Frames.Config_Stereo);
   procedure Player (Userdata  : in out User_Data;
                     Audio_Buf : in out Samples.Frames);

   procedure Callback is new SDL.Audio.Callback (User_Data     => User_Data,
                                                 Audio_Frames  => Samples,
                                                 User_Callback => Player);

end Play_Callbacks;
