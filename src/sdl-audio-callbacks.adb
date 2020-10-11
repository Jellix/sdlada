package body SDL.Audio.Callbacks is

   procedure C_Callback (Data   : in User_Data_Ptr;
                         Stream : in Audio_Buffer;
                         Length : in Interfaces.C.int) is
      Ada_User_Data : User_Data with
        Import     => True,
        Convention => Ada;
      for Ada_User_Data'Address use Data;
   begin
      Callback (Data   => Ada_User_Data,
                Stream => Stream,
                Length => Length);
   end C_Callback;

end SDL.Audio.Callbacks;
