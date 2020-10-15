--
--
--

with System;

with SDL.Audio.Buffers;

package body Audiostream_Callbacks is

   Frame_Size : constant Byte_Count :=
     Stereo_Buffers.Frames'Component_Size / System.Storage_Unit;

   procedure User_Callback (Userdata   : in out User_Data;
                            Audio_Data : in out Stereo_Buffers.Frames)
   is
      --  FIXME: Proper interface for such usage, i.e. type conversion
      --         between the generic frame type and Buffer_Type.
      Got : Byte_Count;
      pragma Unreferenced (Userdata, Got);
      Audio_Buf : constant SDL.Audio.Buffer_Type :=
        SDL.Audio.Buffers.To_Buffer
          (Audio_Buf => Buffer_Base (Audio_Data'Address),
           Audio_Len => Audio_Data'Length * Frame_Size);

   begin
      Streams.Stream_Get (Stream, Audio_Buf, Got);
   end User_Callback;

end Audiostream_Callbacks;
