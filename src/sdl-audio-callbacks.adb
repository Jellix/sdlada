package body SDL.Audio.Callbacks is

   procedure C_Callback (Data   : in User_Data_Ptr;
                         Stream : in Audio_Buffer;
                         Length : in Interfaces.C.int) is
      Ada_User_Data : User_Data with
        Import     => True,
        Convention => Ada;
      for Ada_User_Data'Address use Data;
      Ada_Audio_Data : Raw_Audio (0 .. Raw_Audio_Index (Length - 1)) with
        Import     => True,
        Convention => Ada,
        Address    => Stream;
   begin
      Callback (Data   => Ada_User_Data,
                Stream => Ada_Audio_Data);
   end C_Callback;

end SDL.Audio.Callbacks;
