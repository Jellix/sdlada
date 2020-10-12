--------------------------------------------------------------------------------------------------------------------
--  Copyright (c) 2020, Vinzent "Jellix" Saranen
--
--  This software is provided 'as-is', without any express or implied
--  warranty. In no event will the authors be held liable for any damages
--  arising from the use of this software.
--
--  Permission is granted to anyone to use this software for any purpose,
--  including commercial applications, and to alter it and redistribute it
--  freely, subject to the following restrictions:
--
--     1. The origin of this software must not be misrepresented; you must not
--     claim that you wrote the original software. If you use this software
--     in a product, an acknowledgment in the product documentation would be
--     appreciated but is not required.
--
--     2. Altered source versions must be plainly marked as such, and must not be
--     misrepresented as being the original software.
--
--     3. This notice may not be removed or altered from any source
--     distribution.
--------------------------------------------------------------------------------------------------------------------
--  SDL.Audio.Conversion, audio format conversion.
--
--  TODO: SDL_AudioStream interface.
--------------------------------------------------------------------------------------------------------------------

package SDL.Audio.Conversion with Preelaborate => True is

   --  Filter function prototype
   type CVT;                         -- SDL_AudioCVT
   type Filter_Callback is access
     procedure (Conv_Table : in CVT;
                Format     : in Format_Id);
   pragma Convention (Convention => C,
                      Entity     => Filter_Callback);

   --  The maximum number of SDL_AudioFilter functions in SDL_AudioCVT is
   --  currently limited to 9. The SDL_AudioCVT.filters array has 10 pointers,
   --  one of which is the terminating NULL pointer.
   CVT_MAX_FILTERS : constant := 9; -- SDL_AUDIOCVT_MAX_FILTERS

   type Filter_Callbacks is array (0 .. CVT_MAX_FILTERS) of Filter_Callback;
   pragma Convention (Convention => C,
                      Entity     => Filter_Callbacks);

   --  A structure to hold a set of audio conversion filters and buffers.
   --
   --  Note that various parts of the conversion pipeline can take advantage
   --  of SIMD operations (like SSE2, for example). SDL_AudioCVT doesn't require
   --  you to pass it aligned data, but can possibly run much faster if you set
   --  both its (buf) field to a pointer that is aligned to 16 bytes, and its
   --  (len) field to something that's a multiple of 16, if possible.
   type CVT is -- SDL_AudioCVT
      record
         Needed       : Bool;                --  True if conversion possible
         Src_Format   : Format_Id;           --  source audio format
         Dst_Format   : Format_Id;           --  target audio format
         Rate_Incr    : Interfaces.C.double; --  rate conversion increment
         Buf          : Audio_Buffer;        --  buffer to hold entire audio data
         Len          : Interfaces.C.int;    --  length of original audio buffer
         Len_Cvt      : Interfaces.C.int;    --  length of converted audio buffer
         Len_Mult     : Interfaces.C.int;    --  buffer must be len*len_mult big
         Len_Ratio    : Interfaces.C.double; --  Given len, final size is len * len_ratio
         Filters      : Filter_Callbacks;    --  NULL terminated list of filter functions
         Filter_Index : Interfaces.C.int;    --  Current audio conversion function
      end record;
   --  pragma Pack (CVT);
   --  This structure is 84 bytes on 32-bit architectures, make sure GCC
   --  doesn't pad it out to 88 bytes to guarantee ABI compatibility between
   --  compilers.
   pragma Convention (Convention => C,
                      Entity     => CVT);

   ---------------------------------------------------------------------
   --  Build_CVT
   --
   --  Initializes a Conversion structure for conversion
   --
   --  Before a Conversion structure can be used to convert audio data
   --  it must be initialized with source and destination information.
   --
   --  Src_Format and Dst_Format are the source and destination format
   --  of the conversion (for information on audio formats see
   --  Audio_Spec). Src_Channels and Dst_Channels are the number of
   --  channels in the source and destination formats. Finally, Src_Rate
   --  and Dst_Rate are the frequency or samples-per-second of the
   --  source and destination formats. Once again, see Audio_Spec.
   --
   --  Returns True if the filter could be built or False if not.
   ---------------------------------------------------------------------
   procedure Build_CVT (CVT          : in out SDL.Audio.Conversion.CVT;
                        Src_Format   : in     Format_Id;
                        Src_Channels : in     Interfaces.Unsigned_8;
                        Src_Rate     : in     Interfaces.C.int;
                        Dst_Format   : in     Format_Id;
                        Dst_Channels : in     Interfaces.Unsigned_8;
                        Dst_Rate     : in     Interfaces.C.int;
                        Success      :    out Boolean);

   ---------------------------------------------------------------------
   --  Convert
   --
   --  Convert audio data to a desired audio format.
   --
   --  Convert takes one parameter, cvt, which was previously
   --  initialized. Initializing a Conversion record is a two step
   --  process. First of all, the structure must be passed to Build_CVT
   --  along with source and destination format parameters. Secondly,
   --  the CVT.Buf and CVT.Len fields must be setup. CVT.Buf should
   --  point to the audio data and CVT.Len should be set to the length
   --  of the audio data in bytes. Remember, the length of the buffer
   --  pointed to by CVT.Buf show be CVT.Len * CVT.Len_Mult bytes in
   --  length.
   --
   --  Once the Conversion structure is initialized then we can pass it
   --  to Convert, which will convert the audio data pointer to by
   --  CVT.Buf. If Convert returned 0 then the conversion was completed
   --  successfully, otherwise -1 is returned.
   --
   --  If the conversion completed successfully then the converted audio
   --  data can be read from CVT.Buf. The amount of valid, converted,
   --  audio data in the buffer is equal to CVT.Len * CVT.Len_Ratio.
   ---------------------------------------------------------------------
   procedure Convert (CVT     : in out SDL.Audio.Conversion.CVT;
                      Success :    out Boolean);

end SDL.Audio.Conversion;
