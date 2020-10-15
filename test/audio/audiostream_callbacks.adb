--
--
--

with System;

with SDL.Audio.Buffers;

package body Audiostream_Callbacks is

   Frame_Size : constant Byte_Count :=
     Stereo_Buffers.Frames'Component_Size / System.Storage_Unit;

   procedure User_Callback (Input_Stream : in out SDL.Audio.Streams.Audio_Stream;
                            Audio_Data   : in out Stereo_Buffers.Frames)
   is
      --  FIXME: Proper interface for such usage, i.e. type conversion
      --         between the generic frame type and Buffer_Type.
      Got : Byte_Count;
      Audio_Buf : constant SDL.Audio.Buffer_Type :=
        SDL.Audio.Buffers.To_Buffer
          (Audio_Buf => Buffer_Base (Audio_Data'Address),
           Audio_Len => Audio_Data'Length * Frame_Size);

   begin
      Streams.Stream_Get (Input_Stream, Audio_Buf, Got);
      pragma Unreferenced (Got); --  FIXME
   end User_Callback;

end Audiostream_Callbacks;
