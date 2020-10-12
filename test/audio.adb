with SDL.Audio,
     SDL.Error,
     SDL.Log;

with System;

procedure Audio is
   use type SDL.Audio.Device_Index, SDL.Audio.Driver_Index;
begin
   SDL.Log.Set (Category => SDL.Log.Application, Priority => SDL.Log.Debug);

   if SDL.Initialise (Flags => SDL.Enable_Audio) then
      SDL.Log.Put_Debug (Message => "Checking for audio drivers...");

      for i in 0 .. SDL.Audio.Get_Num_Drivers - 1 loop
         SDL.Log.Put_Debug (Message => SDL.Audio.Get_Driver (Index => i));
      end loop;

      SDL.Log.Put_Debug (Message => "Checking for audio devices...");

      for i in 0 .. SDL.Audio.Get_Num_Devices - 1 loop
         SDL.Log.Put_Debug (Message => SDL.Audio.Device_Name (Index => i));
      end loop;

      SDL.Log.Put_Debug (Message => "Checking for recording devices...");

      for i in 0 .. SDL.Audio.Get_Num_Devices (Is_Capture => SDL.Audio.True) - 1 loop
         SDL.Log.Put_Debug (Message => SDL.Audio.Device_Name (Index      => i,
                                                              Is_Capture => SDL.Audio.True));
      end loop;
   end if;

   SDL.Log.Put_Debug ("Trying to open the default audio device, requesting 16 bit/48 kHz 5.1 surround...");
   declare
      Obtained : SDL.Audio.Audio_Spec;
      Device   : SDL.Audio.Device_Id;
      use type SDL.Audio.Device_Id;
   begin
      SDL.Audio.Open
        (Desired         => SDL.Audio.Audio_Spec'(Frequency => 48000,
                                                  Format    => SDL.Audio.Unsigned_16_LE,
                                                  Channels  => 6,
                                                  Silence   => <>,
                                                  Samples   => 512,
                                                  Padding   => <>,
                                                  Size      => <>,
                                                  Callback  => null,
                                                  User_Data => System.Null_Address),
         Obtained        => Obtained,
         Device_Name     => "",
         Is_Capture      => SDL.Audio.False,
         Allowed_Changes => SDL.Audio.Allow_Any_Change,
         Device          => Device);

      if Device = SDL.Audio.No_Audio_Device then
         SDL.Log.Put_Debug (Message => "Call failed, did not get a device id!");
         SDL.Log.Put_Error (Message => SDL.Error.Get);
      else
         SDL.Log.Put_Debug (Message => "Obtained audio data:");
         SDL.Log.Put_Debug (Message => "Frequency:" & Obtained.Frequency'Image);
         SDL.Log.Put_Debug (Message => "Format   :" & Obtained.Format'Image);
         SDL.Log.Put_Debug (Message => "Channels :" & Obtained.Channels'Image);
         SDL.Log.Put_Debug (Message => "Silence  :" & Obtained.Silence'Image);
         SDL.Log.Put_Debug (Message => "Samples  :" & Obtained.Samples'Image);
         SDL.Log.Put_Debug (Message => "Size     :" & Obtained.Size'Image);

         SDL.Audio.Close (Device => Device);
      end if;
   end;

   SDL.Finalise;
end Audio;
