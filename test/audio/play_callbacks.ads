--
--
--

with SDL.Audio.Callback;

package Play_Callbacks is
   use SDL.Audio;

   type User_Data is null record;

   procedure Player (Userdata  : in out User_Data;
                     Audio_Buf : in     SDL.Audio.Buffer_Type);

   procedure Callback is new SDL.Audio.Callback (User_Data     => User_Data,
                                                 User_Callback => Player);

end Play_Callbacks;
