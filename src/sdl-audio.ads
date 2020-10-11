--------------------------------------------------------------------------------------------------------------------
--  Copyright (c) 2020, Luke A. Guest
--  Contributed by Vinzent "Jellix" Saranen
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
--  SDL.Audio
--------------------------------------------------------------------------------------------------------------------

with System.Storage_Elements;

package SDL.Audio is

   --  Implemented functions of the SDL Audio API.
   --  Source: http://wiki.libsdl.org/CategoryAudio

   --  SDL_AudioInit                    -> not mapped, internal use only
   --                                      use SDL.Initialise_Sub_System instead
   --  SDL_AudioQuit                    -> not mapped, internal use only
   --                                      use SDL.Finalise_Sub_System instead
   --  SDL_BuildAudioCVT                -> Conversion.Build_CVT
   --  SDL_ClearQueuedAudio             -> Clear_Queued
   --  SDL_CloseAudio (obsolescent)     -> Close
   --  SDL_CloseAudioDevice             -> Close
   --  SDL_ConvertAudio                 -> Conversion.Convert
   --  SDL_DequeueAudio                 -> TBD, recording functionality (Dequeue)
   --  SDL_FreeWAV                      -> Free_WAV
   --  SDL_GetAudioDeviceName           -> Get_Device_Name
   --  SDL_GetAudioDeviceStatus         -> Get_Status
   --  SDL_GetAudioDriver               -> Get_Driver
   --  SDL_GetAudioStatus (obsolescent) -> Get_Status
   --  SDL_GetCurrentAudioDriver        -> Get_Current_Driver
   --  SDL_GetNumAudioDevices           -> Get_Num_Devices
   --  SDL_GetNumAudioDrivers           -> Get_Num_Drivers
   --  SDL_GetQueuedAudioSize           -> Get_Queued_Size
   --  SDL_LoadWAV                      -> Load_WAV
   --  SDL_LoadWAV_RW                   -> internal only, wrapped by Load_WAV
   --  SDL_LockAudio (obsolescent)      -> Lock
   --  SDL_LockAudioDevice              -> Lock
   --  SDL_MixAudio  (obsolescent)      -> Mix
   --  SDL_MixAudioFormat               -> TBD: Mix
   --  SDL_OpenAudio (obsolescent)      -> Open
   --  SDL_OpenAudioDevice              -> Open
   --  SDL_PauseAudio (obsolescent)     -> Pause
   --  SDL_PauseAudioDevice             -> Pause
   --  SDL_QueueAudio                   -> Queue
   --  SDL_UnlockAudio (obsolescent)    -> Unlock
   --  SDL_UnlockAudioDevice            -> Unlock

   subtype Audio_Buffer  is System.Address; --  C allocated buffer, see Load_WAV
   subtype User_Data_Ptr is System.Address; --  Variable type.

   --  For the callback functionality, ignore any audio format and just treat
   --  is as a raw memory array of bytes.
   subtype Raw_Audio       is System.Storage_Elements.Storage_Array;
   subtype Raw_Audio_Index is System.Storage_Elements.Storage_Offset;
   subtype Raw_Audio_Count is System.Storage_Elements.Storage_Offset;

   type Format_Id is new Interfaces.Unsigned_16;
   --  Format_Id is technically a bit-record with the following meaning for
   --  the bits:
   --  for Format_Id use
   --     record
   --       Sample_Size  : Integer range 0 .. 255 at 0 range  0 ..  7;
   --       Is_Float     : Boolean                at 0 range  8 ..  8;
   --       Is_MSB_First : Boolean                at 0 range 12 .. 12;
   --       Is_Signed    : Boolean                at 0 range 15 .. 15;
   --  end record;
   --
   --   +----------------------  sample is signed if set
   --   |
   --   |        +-------------  sample is bigendian if set
   --   |        |
   --   |        |           +-- sample is float if set
   --   |        |           |
   --   |        |           |  +--sample bit size---+
   --   |        |           |  |                    |
   --  15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0

   --  "Standard" audio formats.
   Unsigned_8     : constant Format_Id := 16#0008#; -- AUDIO_U8
   Signed_8       : constant Format_Id := 16#8008#; -- AUDIO_S8
   Unsigned_16_LE : constant Format_Id := 16#0010#; -- AUDIO_U16LSB
   Signed_16_LE   : constant Format_Id := 16#8010#; -- AUDIO_S16LSB
   Unsigned_16_BE : constant Format_Id := 16#1010#; -- AUDIO_U16MSB
   Signed_16_BE   : constant Format_Id := 16#9010#; -- AUDIO_S16MSB

   --  32 bit audio formats (always signed)
   Signed_32_LE   : constant Format_Id := 16#8020#; -- AUDIO_S32LSB
   Signed_32_BE   : constant Format_Id := 16#9020#; -- AUDIO_S32MSB

   --  Float audio formats
   Float_32_LE    : constant Format_Id := 16#8120#; -- AUDIO_F32LSB
   Float_32_BE    : constant Format_Id := 16#9120#; -- AUDIO_F32MSB

   type Status is (Stopped, Playing, Paused);
   pragma Convention (Convention => C,
                      Entity     => Status);

   type Allowed_Changes_Flags is new Interfaces.C.int;

   Allow_Frequency_Change : constant Allowed_Changes_Flags := 16#0000_0001#;
   Allow_Format_Change    : constant Allowed_Changes_Flags := 16#0000_0002#;
   Allow_Channels_Change  : constant Allowed_Changes_Flags := 16#0000_0004#;
   Allow_Samples_Change   : constant Allowed_Changes_Flags := 16#0000_0008#;
   Allow_Any_Change       : constant Allowed_Changes_Flags := 16#0000_000F#;

   Null_Audio : constant Audio_Buffer;
   Null_User  : constant User_Data_Ptr;

   MAX_MIX_VOLUME : constant := 128;
   subtype Volume is Interfaces.C.int range 0 .. MAX_MIX_VOLUME;

   --  Callback prototype:
   --  User_Data is the pointer stored in User_Data field of the
   --            Audio_Spec.
   --  Stream    is a pointer to the audio buffer you want to fill with
   --            information and
   --  Length    is the length of the audio buffer in bytes.
   type Audio_Callback is access
     procedure (User_Data : in User_Data_Ptr; --  C pointer to user data object
                Stream    : in Audio_Buffer;  --  C pointer to Raw_Audio
                Length    : in Interfaces.C.int);
   pragma Convention (Convention => C,
                      Entity     => Audio_Callback);

   --  The calculated values in this structure are calculated by SDL_OpenAudio().
   --
   --  For multi-channel audio, the default SDL channel mapping is:
   --  2:  FL FR                       (stereo)
   --  3:  FL FR LFE                   (2.1 surround)
   --  4:  FL FR BL BR                 (quad)
   --  5:  FL FR FC BL BR              (quad + center)
   --  6:  FL FR FC LFE SL SR          (5.1 surround - last two can also be BL BR)
   --  7:  FL FR FC LFE BC SL SR       (6.1 surround)
   --  8:  FL FR FC LFE BL BR SL SR    (7.1 surround)
   type Audio_Spec is
      record
         Frequency : Interfaces.C.int;       --  DSP frequency -- samples per second
         Format    : Format_Id;              --  Audio data format
         Channels  : Interfaces.Unsigned_8;  --  Number of channels: 1 mono, 2 stereo
         Silence   : Interfaces.Unsigned_8;  --  Audio buffer silence value (calculated)
         Samples   : Interfaces.Unsigned_16; --  Audio buffer size in sample FRAMES
         Padding   : Interfaces.Unsigned_16; --  Necessary for some compile environments
         Size      : Interfaces.Unsigned_32; --  Audio buffer size in bytes (calculated)
         Callback  : Audio_Callback;         --  Callback that feeds the audio device (NULL to use SDL_QueueAudio())
         User_Data : User_Data_Ptr;          --  Userdata passed to callback (ignored for NULL callbacks).
      end record;
   pragma Convention (Convention => C,
                      Entity     => Audio_Spec);


   type Bool is new Boolean with
     Size => Interfaces.C.int'Size;
   --  FIXME: Equivalent to SDL.SDL_Bool, but it's in the private part, so we
   --         can't use it here.

   --  For audio device related queries.
   type Device_Id is new Interfaces.Unsigned_32; --  Uint32 SDL_AudioDeviceID

   No_Audio_Device : constant Device_Id := 0;
   --  Calls to Open which return a device id, may return an invalid ID to
   --  indicate errors.
   Legacy_Device   : constant Device_Id := 1;
   --  device id used by legacy functions (i.e. SDL.Audio.Simple)

   type Device_Index is new Interfaces.C.int;

   --  For audio driver related queries.
   type Driver_Index is new Interfaces.C.int;

   ---------------------------------------------------------------------
   --  Open
   --
   --  Opens the default audio device with the desired parameters.
   --
   --  This function opens the default audio device with the Required
   --  parameters, and returns True if successful. The audio data passed
   --  to the callback function will be guaranteed to be in the
   --  requested format, and will be automatically converted to the
   --  hardware audio format if necessary.
   --
   --  This function returns False if it failed to open the audio
   --  device, or couldn't set up the audio thread.
   --
   --  To open the audio device a Required Audio_Spec must be created.
   --  You must then fill this structure with your required audio
   --  specifications:
   --
   --  Required.Frequency:
   --    The required audio frequency in samples-per-second.
   --
   --  Required.Format:
   --    The required audio format.
   --
   --  Required.Samples:
   --    The required size of the audio buffer in samples. This number
   --    should be a power of two, and may be adjusted by the audio
   --    driver to a value more suitable for the hardware. Good values
   --    seem to range between 512 and 8192 inclusive, depending on the
   --    application and CPU speed. Smaller values yield faster response
   --    time, but can lead to underflow if the application is doing
   --    heavy processing and cannot fill the audio buffer in time. A
   --    stereo sample consists of both right and left channels in LR
   --    ordering. Note that the number of samples is directly related
   --    to time.
   --
   --  Required.Callback:
   --    This should be set to a function that will be called when the
   --    audio device is ready for more data. It is passed a pointer to
   --    the audio buffer, and the length in bytes of the audio buffer.
   --    This function usually runs in a separate thread, and so you
   --    should protect data structures that it accesses by calling
   --    Lock and Unlock in your code (NOT in your callback!).
   --
   --  Required.User_Data
   --    This pointer is passed as the first parameter to the callback
   --    function.
   --
   --  Open reads these fields from the Required Audio_Spec structure
   --  passed to the function and attempts to find an audio
   --  configuration matching your Required. SDL will convert from your
   --  Required audio settings to the hardware settings as it plays.
   --
   --  The Required Audio_Spec is your working specification. The data
   --  in the working specification is used when building AudioCVT's for
   --  converting loaded data to the hardware format.
   --
   --  Open calculates the Size and Silence fields for the Required
   --  specifications. The Size field stores the total size of the audio
   --  buffer in bytes, while the Silence stores the value used to
   --  represent silence in the audio buffer.
   --
   --  The audio device starts out playing Silence when it's opened, and
   --  should be enabled for playing by calling Pause (False) when you
   --  are ready for your audio callback function to be called. Since
   --  the audio driver may modify the requested size of the audio
   --  buffer, you should allocate any local mixing buffers after you
   --  open the audio device.
   ---------------------------------------------------------------------
   procedure Open (Required : in out Audio_Spec;
                   Success  :    out Boolean);
   pragma Obsolescent (Entity  => Open,
                       Message => "Consider using SDL.Audio.Open (Device => ...) instead.");

   ---------------------------------------------------------------------
   --  Open
   --
   --  Opens the audio device with the desired parameters.
   --
   --  This function opens the audio device with the Desired parameters,
   --  and returns True if successful, placing the actual hardware
   --  parameters in the structure pointed to by Obtained.
   --
   --  This function returns False if it failed to open the audio
   --  device, or couldn't set up the audio thread.
   --
   --  To open the audio device a desired Audio_Spec must be created.
   --  You must then fill this structure with your desired audio
   --  specifications:
   --
   --  Desired.Frequency:
   --    The desired audio frequency in samples-per-second.
   --
   --  Desired.Format:
   --    The desired audio format.
   --
   --  Desired.Samples:
   --    The desired size of the audio buffer in samples. This number
   --    should be a power of two, and may be adjusted by the audio
   --    driver to a value more suitable for the hardware. Good values
   --    seem to range between 512 and 8192 inclusive, depending on the
   --    application and CPU speed. Smaller values yield faster response
   --    time, but can lead to underflow if the application is doing
   --    heavy processing and cannot fill the audio buffer in time. A
   --    stereo sample consists of both right and left channels in LR
   --    ordering. Note that the number of samples is directly related
   --    to time.
   --
   --  Desired.Callback:
   --    This should be set to a function that will be called when the
   --    audio device is ready for more data. It is passed a pointer to
   --    the audio buffer, and the length in bytes of the audio buffer.
   --    This function usually runs in a separate thread, and so you
   --    should protect data structures that it accesses by calling
   --    Lock and Unlock in your code (NOT in your callback!).
   --
   --  Desired.User_Data
   --    This pointer is passed as the first parameter to the callback
   --    function.
   --
   --  Open reads these fields from the Desired Audio_Spec structure
   --  passed to the function and attempts to find an audio
   --  configuration matching your Desired.
   --
   --  The obtained Audio_Spec becomes the working specification and the
   --  Desired specification can be deleted. The data in the working
   --  specification is used when building AudioCVT's for converting
   --  loaded data to the hardware format.
   --
   --  Open calculates the Size and Silence fields for both the Desired
   --  and Obtained specifications. The Size field stores the total size
   --  of the audio buffer in bytes, while the Silence stores the value
   --  used to represent silence in the audio buffer.
   --
   --  The audio device starts out playing Silence when it's opened, and
   --  should be enabled for playing by calling Pause (False) when you
   --  are ready for your audio callback function to be called. Since
   --  the audio driver may modify the requested size of the audio
   --  buffer, you should allocate any local mixing buffers after you
   --  open the audio device.
   ---------------------------------------------------------------------
   procedure Open (Desired  : in out Audio_Spec;
                   Obtained : in out Audio_Spec;
                   Success  :    out Boolean);
   pragma Obsolescent (Entity  => Open,
                       Message => "Consider using SDL.Audio.Open (Device => ...) instead.");

   ---------------------------------------------------------------------
   --  Pause
   --
   --  Pauses and unpauses the audio callback processing.
   --
   --  This function pauses and unpauses the audio callback processing.
   --  It should be called with Pause_On => False after opening the
   --  audio device to start playing sound. This is so you can safely
   --  initialize data for your callback function after opening the
   --  audio device.
   --
   --  Silence will be written to the audio device during the pause.
   ---------------------------------------------------------------------
   procedure Pause (Pause_On : in Bool);
   pragma Obsolescent (Entity  => Pause,
                       Message => "Consider using SDL.Audio.Pause (Device => ...) instead.");

   ---------------------------------------------------------------------
   --  Pause
   --
   --  Use this function to pause and unpause audio playback on a
   --  specified device.
   --
   --  This function pauses and unpauses the audio callback processing
   --  for a given device. Newly-opened audio devices start in the
   --  paused state, so you must call this function with
   --  Pause_On = False after opening the specified audio device to
   --  start playing sound. This allows you to safely initialize data
   --  for your callback function after opening the audio device.
   --  Silence will be written to the audio device while paused, and
   --  the audio callback is guaranteed to not be called. Pausing one
   --  device does not prevent other unpaused devices from running
   --  their callbacks.
   --
   --  Pausing state does not stack; even if you pause a device several
   --  times, a single unpause will start the device playing again, and
   --  vice versa. This is different from how SDL.Audio.Lock_Device
   --  works.
   --
   --  If you just need to protect a few variables from race conditions
   --  vs your callback, you shouldn't pause the audio device, as it
   --  will lead to dropouts in the audio playback. Instead, you should
   --  use SDL.Audio.Lock_Device.
   ---------------------------------------------------------------------
   procedure Pause (Device   : in Device_Id;
                    Pause_On : in Bool);

   ---------------------------------------------------------------------
   --  Get_Status
   --
   --  Gets the current audio state.
   ---------------------------------------------------------------------
   function Get_Status return Status;
   pragma Obsolescent (Entity  => Get_Status,
                       Message => "Consider using SDL.Audio.Get_Status (Device => ...) instead.");

   ---------------------------------------------------------------------
   --  Load_WAV
   --
   --  Load a WAVE file.
   --
   --  This function loads a WAVE file into memory.
   --  If this function succeeds, it returns the given Audio_Spec,
   --  filled with the audio data format of the wave data, and sets
   --  Audio_Buf to a malloc'd buffer containing the audio data, and
   --  sets Audio_Len to the length of that audio buffer, in bytes. You
   --  need to free the audio buffer with Free_WAV when you are done
   --  with it.
   --
   --  This function returns NULL and sets the SDL error message if the
   --  wave file cannot be opened, uses an unknown data format, or is
   --  corrupt. Currently raw, MS-ADPCM and IMA-ADPCM WAVE files are
   --  supported.
   ---------------------------------------------------------------------
   procedure Load_WAV (File_Name : in     String;
                       Spec      :    out Audio_Spec;
                       Audio_Buf :    out Audio_Buffer;
                       Audio_Len :    out Interfaces.Unsigned_32;
                       Success   :    out Boolean);

   ---------------------------------------------------------------------
   --  Free_WAV
   --
   --  Frees previously opened WAV data.
   --
   --  After a WAVE file has been opened with Load_WAV its data can
   --  eventually be freed with Free_WAV. Audio_Buf is a pointer to the
   --  buffer created by Load_WAV.
   ---------------------------------------------------------------------
   procedure Free_WAV (Audio_Buf : in out Audio_Buffer);

   ---------------------------------------------------------------------
   --  Mix
   --
   --  Mix audio data
   --
   --  This function takes two audio buffers of Length bytes each of the
   --  playing audio format and mixes them, performing addition, volume
   --  adjustment, and overflow clipping. The Vol(ume) ranges from 0 to
   --  MIX_MAX_VOLUME and should be set to the maximum value for full
   --  audio volume. Note this does not change hardware volume. This is
   --  provided for convenience -- you can mix your own audio data.
   --
   --  Note: Do not use this function for mixing together more than two
   --        streams of sample data. The output from repeated
   --        application of this function may be distorted by clipping,
   --        because there is no accumulator with greater range than the
   --        input (not to mention this being an inefficient way of
   --        doing it). Use mixing functions from SDL_mixer, OpenAL, or
   --        write your own mixer instead.
   ---------------------------------------------------------------------
   procedure Mix (Destination : in Audio_Buffer;
                  Source      : in Audio_Buffer;
                  Length      : in Interfaces.Unsigned_32;
                  Vol         : in Volume);

   ---------------------------------------------------------------------
   --  Lock
   --
   --  Lock out the callback function.
   --
   --  The lock manipulated by these functions protects the callback
   --  function. During a Lock-Audio period, you can be guaranteed that
   --  the callback function is not running. Do not call these from the
   --  callback function or you will cause deadlock.
   ---------------------------------------------------------------------
   procedure Lock;
   pragma Obsolescent (Entity  => Lock,
                       Message => "Consider using SDL.Audio.Lock (Device => ...) instead.");

   ---------------------------------------------------------------------
   --  Lock
   --
   --  Use this function to lock out the audio callback function for a
   --  specified device.
   --
   --  The lock manipulated by these functions protects the audio
   --  callback function specified in SDL.Audio.Open_Device. During a
   --  SDL.Audio.Lock_Device/SDL.Audio.Unlock_Device pair, you can be
   --  guaranteed that the callback function for that device is not
   --  running, even if the device is not paused. While a device is
   --  locked, any other unpaused, unlocked devices may still run their
   --  callbacks.
   --
   --  Calling this function from inside your audio callback is
   --  unnecessary. SDL obtains this lock before calling your function,
   --  and releases it when the function returns.
   --
   --  You should not hold the lock longer than absolutely necessary. If
   --  you hold it too long, you'll experience dropouts in your audio
   --  playback. Ideally, your application locks the device, sets a few
   --  variables and unlocks again. Do not do heavy work while holding
   --  the lock for a device.
   --
   --  It is safe to lock the audio device multiple times, as long as
   --  you unlock it an equivalent number of times. The callback will
   --  not run until the device has been unlocked completely in this
   --  way. If your application fails to unlock the device
   --  appropriately, your callback will never run, you might hear
   --  repeating bursts of audio, and SDL.Audio.Close_Device will
   --  probably deadlock.
   --
   --  Internally, the audio device lock is a mutex; if you lock from
   --  two threads at once, not only will you block the audio callback,
   --  you'll block the other thread.
   ---------------------------------------------------------------------
   procedure Lock (Device : in Device_Id);

   ---------------------------------------------------------------------
   --  Unlock
   --
   --  Unlocks the callback function locked by a previous Lock call.
   ---------------------------------------------------------------------
   procedure Unlock;
   pragma Obsolescent (Entity  => Unlock,
                       Message => "Consider using SDL.Audio.Unlock (Device => ...) instead.");

   ---------------------------------------------------------------------
   --  Unlock_Device
   --
   --  Unlocks the callback function locked by a previous Lock call.
   ---------------------------------------------------------------------
   procedure Unlock (Device : in Device_Id);

   ---------------------------------------------------------------------
   --  Close
   --
   --  Shuts down audio processing and closes the audio device.
   ---------------------------------------------------------------------
   procedure Close;
   pragma Obsolescent (Entity  => Close,
                       Message => "Consider using SDL.Audio.Close (Device => ) instead.");

   ---------------------------------------------------------------------
   --  Close_Device
   --
   --  Use this function to shut down audio processing and close the
   --  audio device.
   --
   --  The application should close open audio devices once they are no
   --  longer needed. Calling this function will wait until the device's
   --  audio callback is not running, release the audio hardware and
   --  then clean up internal state. No further audio will play from
   --  this device once this function returns.
   --  The device ID is invalid as soon as the device is closed, and is
   --  eligible for reuse in a new Open_Device call immediately.
   ---------------------------------------------------------------------
   procedure Close (Device : in Device_Id);

   ---------------------------------------------------------------------
   --  Clear_Queued
   --
   --  Use this function to drop any queued audio data waiting to be
   --  sent to the hardware.
   --
   --  Immediately after this call, Get_Queued_Size will return 0 and
   --  the hardware will start playing silence if more audio isn't
   --  queued.
   --  This will not prevent playback of queued audio that's already
   --  been sent to the hardware, as we can not undo that, so expect
   --  there to be some fraction of a second of audio that might still
   --  be heard. This can be useful if you want to, say, drop any
   --  pending music during a level change in your game.
   --
   --  You may not queue audio on a device that is using an
   --  application-supplied callback; calling this function on such a
   --  device is always a no-op. You have to use the audio callback or
   --  queue audio with SDL.Audio.Streams.Queue, but not both.
   --
   --  You should not call SDL.Audio.Lock on the device before clearing
   --  the queue; SDL handles locking internally for this function.
   ---------------------------------------------------------------------
   procedure Clear_Queued (Device : in Device_Id);

   ---------------------------------------------------------------------
   --  Get_Queued_Size
   --
   --  Use this function to get the number of bytes of still-queued
   --  audio.
   --
   --  Returns the number of bytes (not samples!) of queued audio.
   --
   --  This is the number of bytes that have been queued for playback
   --  with SDL.Audio.Queue, but have not yet been sent to the hardware.
   --
   --  Once we've sent it to the hardware, this function can not decide
   --  the exact byte boundary of what has been played. It's possible
   --  that we just gave the hardware several kilobytes right before you
   --  called this function, but it hasn't played any of it yet, or
   --  maybe half of it, etc.
   --
   --  You may not queue audio on a device that is using an
   --  application-supplied callback; calling this function on such a
   --  device always returns 0. You have to use the audio callback or
   --  queue audio with SDL.Audio.Queue, but not both.
   --
   --  You should not call SDL.Audio.Lock on the device before
   --  querying; SDL handles locking internally for this function.
   ---------------------------------------------------------------------
   function Get_Queued_Size (Device : in Device_Id) return Interfaces.Unsigned_32;


   ---------------------------------------------------------------------
   --  Queue
   --
   --  Use this function to queue more audio on non-callback devices.
   --
   --  SDL offers two ways to feed audio to the device: you can either
   --  supply a callback that SDL triggers with some frequency to obtain
   --  more audio (pull method), or you can supply no callback, and then
   --  SDL will expect you to supply data at regular intervals (push
   --  method) with this function.
   --
   --  There are no limits on the amount of data you can queue, short of
   --  exhaustion of address space. Queued data will drain to the device
   --  as necessary without further intervention from you. If the device
   --  needs audio but there is not enough queued, it will play silence
   --  to make up the difference. This means you will have skips in your
   --  audio playback if you aren't routinely queueing sufficient data.
   --
   --  This function copies the supplied data, so you are safe to free
   --  it when the function returns. This function is thread-safe, but
   --  queueing to the same device from two threads at once does not
   --  promise which buffer will be queued first.
   --
   --  You may not queue audio on a device that is using an
   --  application-supplied callback; doing so returns an error. You
   --  have to use the audio callback or queue audio with this function,
   --  but not both.
   --
   --  You should not call SDL.Audio.Lock on the device before queueing;
   --  SDL handles locking internally for this function.
   ---------------------------------------------------------------------
   procedure Queue (Device : in Device_Id;
                    Data   : in Audio_Buffer;
                    Lenght : in Interfaces.Unsigned_32);

   ---------------------------------------------------------------------
   --  Device_Name
   --
   --  Use this function to get the name of a specific audio device.
   --
   --  Returns the name of the audio device at the requested index, or
   --  raises Constraint_Error on error (most likely an invalid index).
   --
   --  This function is only valid after successfully initializing the
   --  audio subsystem. The values returned by this function reflect
   --  the latest call to Get_Num_Devices; re-call that function to
   --  re-detect available hardware.
   --  The string returned by this function is UTF-8 encoded.
   ---------------------------------------------------------------------
   function Device_Name (Index      : in Device_Index;
                         Is_Capture : in Bool := False) return String;

   ---------------------------------------------------------------------
   --  Get_Driver
   --
   --  Use this function to get the name of a built in audio driver.
   --
   --  Returns the name of the audio driver at the requested index, or
   --  raises Constraint_Error if an invalid index was specified.
   ---------------------------------------------------------------------
   function Get_Driver (Index : in Driver_Index) return String;

   ---------------------------------------------------------------------
   --  Get_Current_Driver
   --
   --  Use this function to get the name of the current audio driver.
   --
   --  Returns the name of the current audio driver or raises
   --  Constraint_Error if no driver has been initialized (yet).
   ---------------------------------------------------------------------
   function Get_Current_Driver return String;

   ---------------------------------------------------------------------
   --  Get_Device_Status
   --
   --  Use this function to get the current audio state of an audio
   --  device.
   --
   --  Returns the SDL_AudioStatus of the specified audio device.
   --
   --  Opened devices are always PLAYING or PAUSED in normal
   --  circumstances. A failing device may change its status to STOPPED
   --  at any time, and closing a device will progress to STOPPED, too.
   --  Asking for the state on an unopened or unknown device ID will
   --  report STOPPED.
   ---------------------------------------------------------------------
   function Get_Status (Device : in Device_Id) return Status;

   ---------------------------------------------------------------------
   --  Get_Num_Devices
   --
   --  Use this function to get the number of built-in audio devices.
   --
   --  Returns the number of available devices exposed by the current
   --  driver or -1 if an explicit list of devices can't be determined.
   --  A return value of -1 does not necessarily mean an error condition.
   --
   --  This function is only valid after successfully initializing the
   --  audio subsystem.
   --  Note that audio capture support is not implemented as of
   --  SDL 2.0.4, so the Is_Capture parameter is for future expansion
   --  and should always be zero for now.
   --
   --  This function will return -1 if an explicit list of devices can't
   --  be determined. Returning -1 is not an error. For example, if SDL
   --  is set up to talk to a remote audio server, it can't list every
   --  one available on the Internet, but it will still allow a specific
   --  host to be specified in Open_Device.
   --
   --  In many common cases, when this function returns a value <= 0, it
   --  can still successfully open the default device (i.e. empty string
   --  for first argument of Open_Device).
   --
   --  This function may trigger a complete redetect of available
   --  hardware. It should not be called for each iteration of a loop,
   --  but rather once at the start of a loop.
   ---------------------------------------------------------------------
   function Get_Num_Devices (Is_Capture : Bool := False) return Device_Index;

   ---------------------------------------------------------------------
   --  Get_Num_Drivers
   --
   --  Use this function to get the number of built-in audio drivers.
   --
   --  Returns the number of built-in audio drivers.
   --
   --  This function returns a hardcoded number. This never returns a
   --  negative value; if there are no drivers compiled into this build
   --  of SDL, this function returns zero. The presence of a driver in
   --  this list does not mean it will function, it just means SDL is
   --  capable of interacting with that interface. For example, a build
   --  of SDL might have esound support, but if there's no esound server
   --  available, SDL's esound driver would fail if used.
   --
   --  By default, SDL tries all drivers, in its preferred order, until
   --  one is found to be usable.
   ---------------------------------------------------------------------
   function Get_Num_Drivers return Driver_Index;

   ---------------------------------------------------------------------
   --  Open_Device
   --
   --  Use this function to open a specific audio device.
   --
   --  Returns a valid device ID that is > 0 on success or 0 on failure;
   --  call SDL.Error.Get for more information.
   --
   --  For compatibility with SDL 1.2, this will never return 1, since
   --  SDL reserves that ID for the legacy SDL.Audio.Open function.
   --
   --  SDL.Audio.Open, unlike this function, always acts on device ID 1.
   --  As such, this function will never return a 1 so as not to
   --  conflict with the legacy function.
   --
   --  Please note that SDL 2.0 before 2.0.5 did not support recording;
   --  as such, this function was failing if Is_Capture was not zero.
   --  Starting with SDL 2.0.5 recording is implemented and this value
   --  can be True.
   --
   --  Passing in an empty string for device name requests the most
   --  reasonable default (and is equivalent to what SDL.Audio.Open does
   --  to choose a device). The device name is a UTF-8 string reported
   --  by SDL.Audio.Get_Device_Name, but some drivers allow arbitrary
   --  and driver-specific strings, such as a hostname/IP address for a
   --  remote audio server, or a filename in the diskaudio driver.
   --
   --  The Allowed_Changes flags specify how SDL should behave when a
   --  device cannot offer a specific feature. If the application
   --  requests a feature that the hardware doesn't offer, SDL will
   --  always try to get the closest equivalent.
   --
   --  For example, if you ask for float32 audio format, but the sound
   --  card only supports int16, SDL will set the hardware to int16. If
   --  you had set SDL_AUDIO_ALLOW_FORMAT_CHANGE, SDL will change the
   --  format in the Obtained structure. If that flag was not set, SDL
   --  will prepare to convert your callback's float32 audio to int16
   --  before feeding it to the hardware and will keep the originally
   --  requested format in the obtained structure.
   --  If your application can only handle one specific data format,
   --  pass a zero for Allowed_Changes and let SDL transparently handle
   --  any differences.
   --
   --  An opened audio device starts out paused, and should be enabled
   --  for playing by calling SDL.Audio.Pause_Device (devid, False) when
   --  you are ready for your audio callback function to be called.
   --  Since the audio driver may modify the requested size of the audio
   --  buffer, you should allocate any local mixing buffers after you
   --  open the audio device.
   --
   --  The audio callback runs in a separate thread in most cases; you
   --  can prevent race conditions between your callback and other
   --  threads without fully pausing playback with
   --  SDL.Audio.Lock_Device. For more information about the callback,
   --  see Audio_Spec.
   ---------------------------------------------------------------------
   procedure Open (Device_Name     : in     String := "";
                   Is_Capture      : in     Bool   := False;
                   Desired         : in     Audio_Spec;
                   Obtained        :    out Audio_Spec;
                   Allowed_Changes : in     Allowed_Changes_Flags;
                   Device          :    out Device_Id);

   ---------------------------------------------------------------------
   --  Open_Device
   --
   --  Use this function to open a specific audio device.
   --
   --  Returns a valid device ID that is > 0 on success or 0 on failure;
   --  call SDL_GetError() for more information.
   --
   --  For compatibility with SDL 1.2, this will never return 1, since
   --  SDL reserves that ID for the legacy SDL.Audio.Open() function.
   --
   --  SDL.Audio.Open, unlike this function, always acts on device ID 1.
   --  As such, this function will never return a 1 so as not to
   --  conflict with the legacy function.
   --
   --  Please note that SDL 2.0 before 2.0.5 did not support recording;
   --  as such, this function was failing if Is_Capture was not zero.
   --  Starting with SDL 2.0.5 recording is implemented and this value
   --  can be True.
   --
   --  Passing in an empty string for device name requests the most
   --  reasonable default (and is equivalent to what SDL.Audio.Open does
   --  to choose a device). The device name is a UTF-8 string reported
   --  by SDL.Audio.Get_Device_Name, but some drivers allow arbitrary
   --  and driver-specific strings, such as a hostname/IP address for a
   --  remote audio server, or a filename in the diskaudio driver.
   --
   --  An opened audio device starts out paused, and should be enabled
   --  for playing by calling SDL.Audio.Pause_Device (devid, False) when
   --  you are ready for your audio callback function to be called.
   --  Since the audio driver may modify the requested size of the audio
   --  buffer, you should allocate any local mixing buffers after you
   --  open the audio device.
   --
   --  The audio callback runs in a separate thread in most cases; you
   --  can prevent race conditions between your callback and other
   --  threads without fully pausing playback with
   --  SDL.Audio.Lock_Device. For more information about the callback,
   --  see Audio_Spec.
   ---------------------------------------------------------------------
   procedure Open (Device_Name : in     String := "";
                   Is_Capture  : in     Bool   := False;
                   Required    : in out Audio_Spec;
                   Device      :    out Device_Id);

private

   --  Untangle overloaded function names.
   procedure Close_Legacy renames Close;
   pragma Import (Convention    => C,
                  Entity        => Close_Legacy,
                  External_Name => "SDL_CloseAudio");

   --  Untangle overloaded function names.
   procedure Close_Device (Device : in Device_Id) renames Close;
   pragma Import (Convention    => C,
                  Entity        => Close_Device,
                  External_Name => "SDL_CloseAudioDevice");

   --  Untangle overloaded function names.
   function Get_Status_Legacy return Status renames Get_Status;
   pragma Import (Convention    => C,
                  Entity        => Get_Status_Legacy,
                  External_Name => "SDL_GetAudioStatus");

   --  Untangle overloaded function names.
   function Get_Status_Device (Device : in Device_Id) return Status
                               renames Get_Status;
   pragma Import (Convention    => C,
                  Entity        => Get_Status_Device,
                  External_Name => "SDL_GetAudioDeviceStatus");

   --  Untangle overloaded function names.
   procedure Lock_Legacy renames Lock;
   pragma Import (Convention    => C,
                  Entity        => Lock_Legacy,
                  External_Name => "SDL_LockAudio");

   --  Untangle overloaded function names.
   procedure Lock_Device (Device : in Device_Id) renames Lock;
   pragma Import (Convention    => C,
                  Entity        => Lock_Device,
                  External_Name => "SDL_LockAudioDevice");

   pragma Import (Convention    => C,
                  Entity        => Mix,
                  External_Name => "SDL_MixAudio");

   --  Untangle overloaded function names.
   procedure Pause_Legacy (Pause_On : in Bool) renames Pause;
   pragma Import (Convention    => C,
                  Entity        => Pause_Legacy,
                  External_Name => "SDL_PauseAudio");

   --  Untangle overloaded function names.
   procedure Pause_Device (Device   : in Device_Id;
                           Pause_On : in Bool) renames Pause;
   pragma Import (Convention    => C,
                  Entity        => Pause_Device,
                  External_Name => "SDL_PauseAudioDevice");

   --  Untangle overloaded function names.
   procedure Unlock_Legacy renames Unlock;
   pragma Import (Convention    => C,
                  Entity        => Unlock_Legacy,
                  External_Name => "SDL_UnlockAudio");

   --  Untangle overloaded function names.
   procedure Unlock_Device (Device : in Device_Id) renames Unlock;
   pragma Import (Convention    => C,
                  Entity        => Unlock_Device,
                  External_Name => "SDL_UnlockAudioDevice");

   pragma Import (Convention    => C,
                  Entity        => Clear_Queued,
                  External_Name => "SDL_ClearQueuedAudio");

   pragma Import (Convention    => C,
                  Entity        => Get_Queued_Size,
                  External_Name => "SDL_GetQueuedAudioSize");

   pragma Import (Convention    => C,
                  Entity        => Queue,
                  External_Name => "SDL_QueueAudio");

   pragma Import (Convention    => C,
                  Entity        => Get_Num_Devices,
                  External_Name => "SDL_GetNumAudioDevices");

   pragma Import (Convention    => C,
                  Entity        => Get_Num_Drivers,
                  External_Name => "SDL_GetNumAudioDrivers");

   Null_Audio : constant Audio_Buffer  := Audio_Buffer  (System.Null_Address);
   Null_User  : constant User_Data_Ptr := User_Data_Ptr (System.Null_Address);

end SDL.Audio;
