--
--
--

with SDL.Audio;

package Play_Callbacks is
   use SDL.Audio;

   procedure Player (Userdata  : in User_Type;
                     Audio_Buf : in Buffer_Base;
                     Audio_Len : in Byte_Count);
   pragma Convention (C, Player);

end Play_Callbacks;
