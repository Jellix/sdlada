with SDL.Audio,
     SDL.Error,
     SDL.Log;

with Interfaces.C;
with System;

procedure Audio is
   use type SDL.Audio.Device_Index, SDL.Audio.Driver_Index;

   procedure List_Drivers is
   begin
      SDL.Log.Put_Debug (Message => "Checking for available audio drivers...");

      for i in 0 .. SDL.Audio.Get_Num_Drivers - 1 loop
         SDL.Log.Put_Debug
           (Message => "  Found: """ & SDL.Audio.Get_Driver (Index => i) & """");
      end loop;

      SDL.Log.Put_Debug
        (Message =>
           "  Current audio driver is """ & SDL.Audio.Get_Current_Driver & """");
   end List_Drivers;

   procedure List_Devices is
   begin
      SDL.Log.Put_Debug (Message => "Checking for audio devices...");

      for i in 0 .. SDL.Audio.Get_Num_Devices - 1 loop
         SDL.Log.Put_Debug
           (Message => "  Found """ & SDL.Audio.Device_Name (Index => i) & """");
      end loop;

      SDL.Log.Put_Debug (Message => "Checking for recording devices...");

      for i in 0 .. SDL.Audio.Get_Num_Devices (Is_Capture => SDL.Audio.True) - 1 loop
         SDL.Log.Put_Debug
           (Message =>
              "  Found """ &
              SDL.Audio.Device_Name (Index      => i,
                                     Is_Capture => SDL.Audio.True) & """");
      end loop;
   end List_Devices;

   procedure Open_Device (Frequency : in Interfaces.C.int;
                          Format    : in SDL.Audio.Format_Id;
                          Channels  : in Interfaces.Unsigned_8)
   is
      function Format_Image (Value : in SDL.Audio.Format_Id) return String is
        (Value.Sample_Size'Image & " bits/sample, " &
         (if Value.Is_Signed then "" else "un") & "signed " &
         (if Value.Is_Float then "float" else "integer") & ", " &
         (if Value.Is_MSB_First then "big" else "little") & " endian");

      Obtained : SDL.Audio.Audio_Spec;
      Device   : SDL.Audio.Device_Id;
      use type SDL.Audio.Device_Id;
   begin
      SDL.Log.Put_Debug
        (Message =>
           "Trying to open default audio device, requesting" &
           Frequency'Image & " Hz," &
           Format_Image (Value => Format) & "," &
           Channels'Image & " channels.");

      SDL.Audio.Open
        (Desired         => SDL.Audio.Audio_Spec'(Frequency => Frequency,
                                                  Format    => Format,
                                                  Channels  => Channels,
                                                  Silence   => 123,
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
         SDL.Log.Put_Error (Message => SDL.Error.Get);
         SDL.Log.Put_Debug (Message => "Call failed, did not get a device id!");
      else
         SDL.Log.Put_Debug (Message => "Obtained audio data:");
         SDL.Log.Put_Debug (Message => "Frequency:" & Obtained.Frequency'Image);
         SDL.Log.Put_Debug
           (Message => "Format   :" & Format_Image (Value => Obtained.Format));
         SDL.Log.Put_Debug (Message => "Channels :" & Obtained.Channels'Image);
         SDL.Log.Put_Debug (Message => "Silence  :" & Obtained.Silence'Image);
         SDL.Log.Put_Debug (Message => "Samples  :" & Obtained.Samples'Image);
         SDL.Log.Put_Debug (Message => "Size     :" & Obtained.Size'Image);

         SDL.Audio.Close (Device => Device);
      end if;
   end Open_Device;

begin
   SDL.Log.Set (Category => SDL.Log.Application, Priority => SDL.Log.Debug);

   if SDL.Initialise (Flags => SDL.Enable_Audio) then
      List_Drivers;
      List_Devices;
      Open_Device (Frequency => 22_500,
                   Format    => SDL.Audio.Unsigned_8,
                   Channels  => 1);
      Open_Device (Frequency => 48_000,
                   Format    => SDL.Audio.Unsigned_16_LE,
                   Channels  => 6);
      Open_Device (Frequency => 48_000,
                   Format    => SDL.Audio.Signed_16_LE,
                   Channels  => 2);
   end if;

   SDL.Finalise;
end Audio;
