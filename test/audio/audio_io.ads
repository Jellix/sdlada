--
--
--

with SDL.Audio;

package Audio_IO is
   use SDL.Audio;

   procedure Dump (Format : in Audio_Format; Compact : in Boolean := False);
   procedure Dump (Spec : in Audio_Spec; Compact : in Boolean := False);

end Audio_IO;
