--
--  Inspect SDL.Audio devices and drivers.
--

with Ada.Text_IO;

with SDL.Audio;

procedure Inspection is
   use Ada.Text_IO;
   use SDL.Audio;

   Driver_Count : constant Natural := Get_Number_Of_Drivers;
begin
   if SDL.Initialise then
      null;
   end if;

   Put_Line ("Driver count : " & Driver_Count'Image);
   for Index in 1 .. Driver_Count loop
      Put_Line (Index'Image & ") " & Get_Driver_Name (Index));
   end loop;
   New_Line;

   Put_Line ("Current Driver : " & Current_Driver);
   New_Line;

   declare
      Playback_Device_Count : constant Natural := Get_Number_Of_Devices (False);
      Capture_Device_Count  : constant Natural := Get_Number_Of_Devices (Is_Capture => True);
   begin
      Put_Line ("Playback device count : " & Playback_Device_Count'Image);
      for Index in 1 .. Playback_Device_Count loop
         Put_Line (Index'Image & ") " & Get_Device_Name (Index, False));
      end loop;
      New_Line;

      Put_Line ("Capture Device count : " & Capture_Device_Count'Image);
      for Index in 1 .. Capture_Device_Count loop
         Put_Line (Index'Image & ") " & Get_Device_Name (Index, True));
      end loop;
      New_Line;
   end;

   Put_Line ("Status : " & Status'Image);

end Inspection;
