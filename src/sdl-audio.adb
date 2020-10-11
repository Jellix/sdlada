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

with Ada.Exceptions;

with Interfaces.C.Strings;

with SDL.Error,
     SDL.RWops;

package body SDL.Audio is

   use type Interfaces.C.Strings.chars_ptr;

   --  Used internally to check result of Load_WAV.
   type Audio_Spec_Ptr is access all Audio_Spec;
   pragma Convention (Convention => C,
                      Entity     => Audio_Spec_Ptr);

   ---------------------------------------------------------------------
   --  Free_WAV
   ---------------------------------------------------------------------
   procedure Free_WAV (Audio_Buf : in out Audio_Buffer) is
      ---------------------------------------------------------------------
      --  C_Free_WAV
      ---------------------------------------------------------------------
      procedure C_Free_WAV (Audio_Buf : in Audio_Buffer) with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_FreeWAV";
   begin
      C_Free_WAV (Audio_Buf => Audio_Buf);
      Audio_Buf := Audio_Buffer (System.Null_Address);
   end Free_WAV;

   ---------------------------------------------------------------------
   --  Load_WAV
   ---------------------------------------------------------------------
   procedure Load_WAV (File_Name : in     String;
                       Spec      :    out Audio_Spec;
                       Audio_Buf :    out Audio_Buffer;
                       Audio_Len :    out Interfaces.Unsigned_32;
                       Success   :    out Boolean) is
      ------------------------------------------------------------------
      --  C_Load_WAV
      ------------------------------------------------------------------
      function C_Load_WAV (Src      : in RWops.RWops;
                           Free_Src : in Bool;
                           Spec     : in System.Address; --  in out Audio_Spec
                           Buf      : in System.Address; --     out Audio_Buffer
                           Len      : in System.Address) --     out UInt32
                           return Audio_Spec_Ptr with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_LoadWAV_RW";
   begin
      declare
         File_Ops : constant RWops.RWops :=
           RWops.From_File (File_Name => File_Name,
                            Mode      => RWops.Read_Binary);
      begin
         Success :=
           C_Load_WAV (Src      => File_Ops,
                       Free_Src => True,
                       Spec     => Spec'Address,
                       Buf      => Audio_Buf'Address,
                       Len      => Audio_Len'Address) /= null;
      end;
   exception
      when E : SDL.RWops.RWops_Error =>
         SDL.Error.Set (Ada.Exceptions.Exception_Message (E));
         Success := False;
   end Load_WAV;

   ---------------------------------------------------------------------
   --  C_Open
   ---------------------------------------------------------------------
   function C_Open (Desired  : in System.Address;
                    Obtained : in System.Address) return Interfaces.C.int with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenAudio";

   ---------------------------------------------------------------------
   --  C_Open_Device
   ---------------------------------------------------------------------
   function C_Open_Device
     (Device          : in Interfaces.C.Strings.chars_ptr;
      Is_Capture      : in Bool;
      Desired         : in System.Address;
      Obtained        : in System.Address;
      Allowed_Changes : in Allowed_Changes_Flags) return Device_Id with
     Import        => True,
     Convention    => C,
     External_Name => "SDL_OpenAudioDevice";

   ---------------------------------------------------------------------
   --  Open
   ---------------------------------------------------------------------
   procedure Open (Desired  : in out Audio_Spec;
                   Obtained : in out Audio_Spec;
                   Success  :    out Boolean)
   is
      Ret_Value : Interfaces.C.int;
   begin
      Ret_Value := C_Open (Desired  => Desired'Address,
                           Obtained => Obtained'Address);

      Success := Ret_Value = 0;
   end Open;

   ---------------------------------------------------------------------
   --  Open
   ---------------------------------------------------------------------
   procedure Open (Required : in out Audio_Spec;
                   Success  :    out Boolean)
   is
      Ret_Value : Interfaces.C.int;
   begin
      Ret_Value := C_Open (Desired  => Required'Address,
                           Obtained => System.Null_Address);

      Success := Ret_Value = 0;
   end Open;

   ---------------------------------------------------------------------
   --  Open
   ---------------------------------------------------------------------
   procedure Open (Device_Name     : in     String := "";
                   Is_Capture      : in     Bool   := False;
                   Desired         : in     Audio_Spec;
                   Obtained        :    out Audio_Spec;
                   Allowed_Changes : in     Allowed_Changes_Flags;
                   Device          :    out Device_Id) is
      C_Device_Name : Interfaces.C.Strings.chars_ptr :=
        (if Device_Name = ""
         then Interfaces.C.Strings.Null_Ptr
         else Interfaces.C.Strings.New_String (Device_Name));
   begin
      Device :=
        C_Open_Device
          (Device          => C_Device_Name,
           Is_Capture      => Is_Capture,
           Desired         => Desired'Address,
           Obtained        => Obtained'Address,
           Allowed_Changes => Allowed_Changes);
      Interfaces.C.Strings.Free (C_Device_Name);
   end Open;

   ---------------------------------------------------------------------
   --  Open
   ---------------------------------------------------------------------
   procedure Open (Device_Name : in     String := "";
                   Is_Capture  : in     Bool   := False;
                   Required    : in out Audio_Spec;
                   Device      :    out Device_Id) is
      C_Device_Name : Interfaces.C.Strings.chars_ptr :=
        (if Device_Name = ""
         then Interfaces.C.Strings.Null_Ptr
         else Interfaces.C.Strings.New_String (Device_Name));
   begin
      Device :=
        C_Open_Device
          (Device          => C_Device_Name,
           Is_Capture      => Is_Capture,
           Desired         => Required'Address,
           Obtained        => System.Null_Address,
           Allowed_Changes => 0);
      Interfaces.C.Strings.Free (C_Device_Name);
   end Open;

   ---------------------------------------------------------------------
   --  Device_Name
   ---------------------------------------------------------------------
   function Device_Name (Index      : in Device_Index;
                         Is_Capture : in Bool := False) return String is
      function C_Device_Name
        (Index      : in Device_Index;
         Is_Capture : in Bool) return Interfaces.C.Strings.chars_ptr with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetAudioDeviceName";
      C_Result : constant Interfaces.C.Strings.chars_ptr :=
        C_Device_Name (Index      => Index,
                       Is_Capture => Is_Capture);
   begin
      if C_Result /= Interfaces.C.Strings.Null_Ptr then
         return Interfaces.C.Strings.Value (C_Result);
      end if;

      raise Constraint_Error with "Index out of valid range.";
   end Device_Name;

   ---------------------------------------------------------------------
   --  Get_Driver
   ---------------------------------------------------------------------
   function Get_Driver (Index : in Driver_Index) return String is
      function C_Get_Driver
        (Index : in Driver_Index) return Interfaces.C.Strings.chars_ptr with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetAudioDriver";
      C_Result : constant Interfaces.C.Strings.chars_ptr :=
        C_Get_Driver (Index => Index);
   begin
      if C_Result /= Interfaces.C.Strings.Null_Ptr then
         return Interfaces.C.Strings.Value (C_Result);
      end if;

      --  If Get_Driver returns NULL, an invalid index was specified, so
      --  simulate a properly failed index check.
      raise Constraint_Error with "Index out of valid range";
   end Get_Driver;

   ---------------------------------------------------------------------
   --  Get_Current_Driver
   ---------------------------------------------------------------------
   function Get_Current_Driver return String is
      function C_Get_Current_Driver return Interfaces.C.Strings.chars_ptr with
        Import        => True,
        Convention    => C,
        External_Name => "SDL_GetCurrentAudioDriver";
      C_Result : constant Interfaces.C.Strings.chars_ptr :=
        C_Get_Current_Driver;
   begin
      if C_Result /= Interfaces.C.Strings.Null_Ptr then
         return Interfaces.C.Strings.Value (C_Result);
      end if;

      raise Constraint_Error with "No driver has been initialized.";
   end Get_Current_Driver;

end SDL.Audio;
