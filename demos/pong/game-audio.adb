--  Pong-Demo for SDLAda, audio stuff.
--  Copyright (C) 2012 - 2020, Vinzent "Jellix" Saranen

with Ada.Command_Line,
     Ada.Directories,
     Ada.Text_IO;

with Interfaces.C;

with SDL.Audio.Callbacks,
     SDL.Error;

with System.Storage_Elements;

package body Game.Audio is

   subtype Byte_Array is System.Storage_Elements.Storage_Array;
   subtype Byte_Index is System.Storage_Elements.Storage_Offset;

   --  WAV_Info
   type WAV_Info is
      record
         Buffer : SDL.Audio.Audio_Buffer;
         Length : Interfaces.Unsigned_32;
      end record;

   No_Wave : constant WAV_Info :=
               WAV_Info'(Buffer => SDL.Audio.Null_Audio,
                         Length => 0);

   --  Play_Info
   type Play_Info is
      record
         Data       : SDL.Audio.Audio_Buffer;
         Length     : Byte_Index;
         Data_Index : Byte_Index;
      end record;

   Nothing : constant Play_Info :=
               Play_Info'(Data       => SDL.Audio.Null_Audio,
                          Length     => 0,
                          Data_Index => 0);

   --  Loaded WAVs.
   WAV_Ping : WAV_Info;
   WAV_Pong : WAV_Info;

   --  Which is currently playing.
   Currently_Playing : Play_Info;

   Audio_Device : SDL.Audio.Device_Id;

   ---------------------------------------------------------------------
   --  Load_Data
   ---------------------------------------------------------------------
   procedure Load_Data;

   procedure Load_Data is
      Data_Dir : constant String :=
        Ada.Directories.Compose
          (Containing_Directory =>
             Ada.Directories.Containing_Directory
               (Name => Ada.Command_Line.Command_Name),
           Name => "data");
      WAV_Spec : SDL.Audio.Audio_Spec;
      Success  : Boolean;
   begin
      SDL.Audio.Load_WAV (File_Name =>
                            Ada.Directories.Compose
                              (Containing_Directory => Data_Dir,
                               Name                 => "ping",
                               Extension            => "wav"),
                          Spec      => WAV_Spec,
                          Audio_Buf => WAV_Ping.Buffer,
                          Audio_Len => WAV_Ping.Length,
                          Success   => Success);
      pragma Unreferenced (WAV_Spec);

      if not Success then
         Ada.Text_IO.Put_Line (File => Ada.Text_IO.Standard_Error,
                               Item => SDL.Error.Get);

         WAV_Ping := No_Wave;
      end if;

      SDL.Audio.Load_WAV (File_Name =>
                             Ada.Directories.Compose
                              (Containing_Directory => Data_Dir,
                               Name                 => "pong",
                               Extension            => "wav"),
                          Spec      => WAV_Spec,
                          Audio_Buf => WAV_Pong.Buffer,
                          Audio_Len => WAV_Pong.Length,
                          Success   => Success);

      if not Success then
         Ada.Text_IO.Put_Line (File => Ada.Text_IO.Standard_Error,
                               Item => SDL.Error.Get);

         WAV_Pong := No_Wave;
      end if;
   end Load_Data;

   ---------------------------------------------------------------------
   --  My_Callback
   ---------------------------------------------------------------------
   procedure My_Callback (User_Data : in out Play_Info;
                          Stream    : in     SDL.Audio.Audio_Buffer;
                          Length    : in     Interfaces.C.int)
   is
      use type SDL.Audio.Audio_Buffer;
      use type Byte_Index;

      In_Buf   : Byte_Array (0 .. Byte_Index (User_Data.Length - 1));
      for In_Buf'Address use System.Address (User_Data.Data);
      Out_Buf  : Byte_Array (0 .. Byte_Index (Length) - 1);
      for Out_Buf'Address use System.Address (Stream);

      Last_Byte : Byte_Index;
   begin
      if
        User_Data.Data /= SDL.Audio.Null_Audio
      then
         --  Now fill buffer with audio data and update the audio index.
         Last_Byte := Byte_Index'Min (Byte_Index (User_Data.Length - User_Data.Data_Index),
                                      Out_Buf'Length);

         Out_Buf (Out_Buf'First .. Last_Byte - 1) :=
           In_Buf (User_Data.Data_Index .. User_Data.Data_Index + Last_Byte - 1);
         Out_Buf (Last_Byte     .. Out_Buf'Last) := (others => 0);

         User_Data.Data_Index := User_Data.Data_Index + Last_Byte;

         if
           User_Data.Data_Index >= User_Data.Length
         then
            User_Data := Nothing;
         end if;
      else
         --  Fill target buffer with silence.
         Out_Buf := Byte_Array'(Out_Buf'Range => 0);
      end if;
   end My_Callback;

   package Audio_Callback is new SDL.Audio.Callbacks (User_Data => Play_Info,
                                                      Callback  => My_Callback);

   ---------------------------------------------------------------------
   --  Initialize
   ---------------------------------------------------------------------
   procedure Initialize is
      Required : SDL.Audio.Audio_Spec;
      use type SDL.Audio.Device_Id,
               SDL.Audio.Device_Index;
   begin
      Currently_Playing := Nothing;

      Load_Data;
      Required :=
        SDL.Audio.Audio_Spec'(Frequency => 48_000,
                              Format    => SDL.Audio.Signed_16_LE,
                              Channels  => 1,
                              Silence   => 0,
                              Samples   => 512,
                              Padding   => 0,
                              Size      => 0,
                              Callback  => Audio_Callback.C_Callback'Access,
                              User_Data => SDL.Audio.User_Data_Ptr (Currently_Playing'Address));

      --  SDL2 API. Enumerate and report devices.
      for D in 0 .. SDL.Audio.Get_Num_Devices - 1 loop
         Ada.Text_IO.Put_Line
           ("Audio device """ &
              SDL.Audio.Device_Name (Index      => D,
                                     Is_Capture => SDL.Audio.False) & """ found.");
      end loop;

      SDL.Audio.Open (Required => Required,
                      Device   => Audio_Device);
      pragma Unreferenced (Required);

      if Audio_Device = 0 then
         Ada.Text_IO.Put_Line (File => Ada.Text_IO.Standard_Error,
                               Item => "Failed to initialize audio");
      else
         SDL.Audio.Pause (Device   => Audio_Device,
                          Pause_On => SDL.Audio.False);
      end if;
   end Initialize;

   ---------------------------------------------------------------------
   --  Finalize
   ---------------------------------------------------------------------
   procedure Finalize is
   begin
      SDL.Audio.Pause (Device   => Audio_Device,
                       Pause_On => SDL.Audio.True);
      SDL.Audio.Close (Device => Audio_Device);

      SDL.Audio.Free_WAV (Audio_Buf => WAV_Ping.Buffer);
      SDL.Audio.Free_WAV (Audio_Buf => WAV_Pong.Buffer);
   end Finalize;

   ---------------------------------------------------------------------
   --  Play_Ping
   ---------------------------------------------------------------------
   procedure Play_Ping is
      use type SDL.Audio.Audio_Buffer;
   begin
      SDL.Audio.Lock (Device => Audio_Device);

      --  Only write new buffer if previous one has played already.
      if
        Currently_Playing.Data = SDL.Audio.Null_Audio
      then
         Currently_Playing :=
           Play_Info'(Data       => WAV_Ping.Buffer,
                      Length     => Byte_Index (WAV_Ping.Length),
                      Data_Index => 0);
      end if;

      SDL.Audio.Unlock (Device => Audio_Device);
   end Play_Ping;

   ---------------------------------------------------------------------
   --  Play_Pong
   ---------------------------------------------------------------------
   procedure Play_Pong is
      use type SDL.Audio.Audio_Buffer;
   begin
      SDL.Audio.Lock (Device => Audio_Device);

      --  Only write new buffer if previous one has played already.
      if
        Currently_Playing.Data = SDL.Audio.Null_Audio
      then
         Currently_Playing :=
           Play_Info'(Data       => WAV_Pong.Buffer,
                      Length     => Byte_Index (WAV_Pong.Length),
                      Data_Index => 0);
      end if;

      SDL.Audio.Unlock (Device => Audio_Device);
   end Play_Pong;

end Game.Audio;