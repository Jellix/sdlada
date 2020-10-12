--
--
--

with Ada.Text_IO;
with Ada.Command_Line;

with SDL.Audio;

with Audio_IO;

procedure Play_WAV is
   use SDL.Audio;
   use Ada.Text_IO;

   WAV_Buffer : Buffer_Type;
   WAV_Spec   : Audio_Spec;
   Obtained   : Audio_Spec;
begin
   if Ada.Command_Line.Argument_Count < 1 then
      Put_Line ("Usage: play_wav <file.wav>");
      return;
   end if;

   if not SDL.Initialise (SDL.Enable_Audio) then
      Put_Line ("Could not initialise SDL audio.");
      return;
   end if;

   for File_Index in 1 .. Ada.Command_Line.Argument_Count loop
      declare
         Filename : String renames Ada.Command_Line.Argument (File_Index);
      begin
         Load_WAV (Filename => Filename,
                   Spec     => WAV_Spec,
                   Buffer   => WAV_Buffer);
         Put ("Rate: "      & WAV_Spec.Frequency'Image);
         Put (" Channels: " & WAV_Spec.Channels'Image);
         Put (" ");
         Audio_IO.Dump (WAV_Spec.Format, Compact => True);
         Put (" File: ");
         Put (Filename);
         New_Line;

         Open (Desired  => WAV_Spec,
               Obtained => Obtained);
         if
           Obtained.Frequency /= WAV_Spec.Frequency or
           Obtained.Format    /= WAV_Spec.Format    or
           Obtained.Channels  /= WAV_Spec.Channels
         then
            Put_Line ("Could not obtain audio quality.");
            return;
         end if;

         Pause (False);
         Queue (1, WAV_Buffer);
         Free_WAV (WAV_Buffer);
         delay 1.000;
         Close;
      exception when Audio_Error =>
         Put ("Could not load file: ");
         Put (Filename);
         New_Line;
      end;
   end loop;

   Quit;
end Play_WAV;
