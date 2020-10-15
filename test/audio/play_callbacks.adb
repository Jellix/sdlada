--
--
--

with Ada.Numerics.Elementary_Functions;

package body Play_Callbacks is

   N : Integer := 0;

   procedure Player (Userdata  : in out User_Data;
                     Audio_Buf : in out Samples.Frames)
   is
      pragma Unreferenced (Userdata);
      use SDL.Audio.Frames;
      use Ada.Numerics.Elementary_Functions;

      Pi      : constant := Ada.Numerics.Pi;
      W_Left  : constant := 0.010;
      W_Right : constant := 0.010;
      W_Phase : constant := 0.00015;
      N_Float : Float;
      Phase_L : Float;
      Phase_R : Float;
      Frame   : Samples.Frame_Type;
   begin
      for Index in Audio_Buf'First .. Audio_Buf'Last loop
         N_Float := Float (N);
         Phase_L := 5.0 * Sin (2.0 * Pi * W_Phase * N_Float);
         Phase_R := 5.0 * Cos (2.0 * Pi * W_Phase * N_Float);
         Frame :=
           (Front_Left  => Sample_Type (3000.0 * Sin (2.0 * Pi * W_Left  * N_Float + Phase_L,
                                                      Cycle => 2.0 * Pi)),
            Front_Right => Sample_Type (3000.0 * Sin (2.0 * Pi * W_Right * N_Float + Phase_R,
                                                      Cycle => 2.0 * Pi)));
         Audio_Buf (Index) := Frame;
         N := N + 1;
      end loop;
   end Player;

end Play_Callbacks;
