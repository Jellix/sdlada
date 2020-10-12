--
--
--

with Ada.Numerics.Elementary_Functions;

with SDL.Audio.Buffers;
with SDL.Audio.Frames;

package body Play_Callbacks is

   type Sample_Type is range -2**15 .. 2**15 - 1
     with Size => 16;

   package Samples is
      new SDL.Audio.Frames.Buffer_Overlays (Sample_Type  => Sample_Type,
                                            Frame_Config => SDL.Audio.Frames.Config_Stereo);
   N : Integer := 0;

   procedure Player (Userdata  : in User_Type;
                     Audio_Buf : in Buffer_Base;
                     Audio_Len : in Byte_Count)
   is
      pragma Unreferenced (Userdata);
      use SDL.Audio.Frames;
      use Samples;
      use Ada.Numerics.Elementary_Functions;

      Pi      : constant := Ada.Numerics.Pi;
      W_Left  : constant := 0.010;
      W_Right : constant := 0.010;
      W_Phase : constant := 0.00015;
      N_Float : Float;
      Phase_L : Float;
      Phase_R : Float;
      Buffer  : Buffer_Type := Buffers.To_Buffer (Audio_Buf, Audio_Len);
      Frame   : Samples.Frame_Type;
   begin
--      Lock;
      for Index in First_Index (Buffer) .. Samples.Last_Index (Buffer) loop
         N_Float := Float (N);
         Phase_L := 5.0 * Sin (2.0 * Pi * W_Phase * N_Float);
         Phase_R := 5.0 * Cos (2.0 * Pi * W_Phase * N_Float);
         Frame :=
           (Front_Left  => Sample_Type (3000.0 * Sin (2.0 * Pi * W_Left  * N_Float + Phase_L,
                                                      Cycle => 2.0 * Pi)),
            Front_Right => Sample_Type (3000.0 * Sin (2.0 * Pi * W_Right * N_Float + Phase_R,
                                                      Cycle => 2.0 * Pi)));
         Update (Buffer, Index, Value => Frame);
         N := N + 1;
      end loop;
--      Unlock;
   end Player;

end Play_Callbacks;
