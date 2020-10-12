--
--
--

with SDL.Audio.Buffers;
with SDL.Audio.Frames;

package body Audiostream_Callbacks is

   procedure Clear (Buffer : in out Buffer_Type);
   --  Clear Buffer.

   type Sample_Type is range -2**15 .. 2**15 - 1;

   package Stereo_Buffers is
      new SDL.Audio.Frames.Buffer_Overlays (Sample_Type  => Sample_Type,
                                            Frame_Config => Frames.Config_Stereo);

   procedure Clear (Buffer : in out Buffer_Type) is
      use Stereo_Buffers;
      subtype Frame_Range is Frame_Index
        range First_Index (Buffer) .. Last_Index (Buffer);
   begin
      for Index in Frame_Range loop
         Update (Buffer, Index, Value => (0, 0));
      end loop;
   end Clear;

   procedure Callback (Userdata  : in User_Type;
                       Audio_Buf : in Buffer_Base;
                       Audio_Len : in Byte_Count)
   is
      Buffer : Buffer_Type := Buffers.To_Buffer (Audio_Buf,
                                                 Audio_Len);
      Got : Byte_Count;
      pragma Unreferenced (Userdata, Got);
   begin
      Clear (Buffer);
      Streams.Stream_Get (Stream, Buffer, Got);
   end Callback;

end Audiostream_Callbacks;
