--
--
--

with Ada.Text_IO;

package body Audio_IO is

   procedure Dump (Format : in Audio_Format; Compact : in Boolean := False) is
      use Ada.Text_IO;
   begin
      if Compact then
         Put ("Bits: "        & Format.Bits'Image);
         Put (" Signed: "     & Format.Signed'Image);
         Put (" Float: "      & Format.Float'Image);
         Put (" Big_Endian: " & Format.Big_Endian'Image);
      else
         Put_Line (" Bits         : "  & Format.Bits'Image);
         Put_Line (" Float        :  " & Format.Float'Image);
         Put_Line (" Big_endian   :  " & Format.Big_Endian'Image);
         Put_Line (" Signed       :  " & Format.Signed'Image);
      end if;
   end Dump;

   procedure Dump (Spec : in Audio_Spec; Compact : in Boolean := False) is
      use Ada.Text_IO;
   begin
      Put_Line ("Frequency     : " & Spec.Frequency'Image);
      if Compact then
         Put ("Format        :");
         Dump (Spec.Format, Compact => True);
         New_Line;
      else
         Put_Line ("Format        :");
         Dump (Spec.Format);
      end if;
      Put_Line ("Channels      : " & Spec.Channels'Image);
      Put_Line ("Silence       : " & Spec.Silence'Image);
      Put_Line ("Samples       : " & Spec.Samples'Image);
      Put_Line ("Padding       : " & Spec.Padding'Image);
      Put_Line ("Size          : " & Spec.Size'Image);
   end Dump;

end Audio_IO;
