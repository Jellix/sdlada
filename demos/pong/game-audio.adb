--  Pong-Demo for SDLAda, audio stuff.
--  Copyright (C) 2012 - 2020, Vinzent "Jellix" Saranen

with Ada.Command_Line,
     Ada.Directories,
     Ada.Text_IO;

with Interfaces;

with SDL.Audio.Callback,
     SDL.Audio.Frames,
     SDL.Error,
     SDL.RWops;

package body Game.Audio is

   package Samples is new
     SDL.Audio.Frames.Buffer_Overlays (Sample_Type  => Interfaces.Unsigned_16,
                                       Frame_Config => SDL.Audio.Frames.Config_Mono);

   Silence : constant Samples.Frame_Type := (others => 16#0000#);
   --  FIXME: Provide the Silence value as parameter to the generic, so it is
   --         directly available for all users of the instance.

   No_Wave : constant SDL.Audio.Buffer_Type := SDL.Audio.Null_Buffer;

   --  Play_Info
   type Play_Info is
      record
         Data  : SDL.Audio.Buffer_Type;
         Index : Samples.Frame_Index;
      end record;

   Nothing : constant Play_Info :=
               Play_Info'(Data  => SDL.Audio.Null_Buffer,
                          Index => 0);

   --  Loaded WAVs.
   WAV_Ping : SDL.Audio.Buffer_Type;
   WAV_Pong : SDL.Audio.Buffer_Type;

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
   begin
      begin
         SDL.Audio.Load_WAV (Filename =>
                               Ada.Directories.Compose
                                 (Containing_Directory => Data_Dir,
                                  Name                 => "ping",
                                  Extension            => "wav"),
                             Spec      => WAV_Spec,
                             Buffer    => WAV_Ping);
      exception
         when SDL.RWops.RWops_Error | SDL.Audio.Audio_Error =>
            Ada.Text_IO.Put_Line (File => Ada.Text_IO.Standard_Error,
                                  Item => SDL.Error.Get);

         WAV_Ping := No_Wave;
      end;

      begin
         SDL.Audio.Load_WAV (Filename =>
                               Ada.Directories.Compose
                                 (Containing_Directory => Data_Dir,
                                  Name                 => "pong",
                                  Extension            => "wav"),
                             Spec      => WAV_Spec,
                             Buffer    => WAV_Pong);
      exception
         when SDL.RWops.RWops_Error | SDL.Audio.Audio_Error =>
            Ada.Text_IO.Put_Line (File => Ada.Text_IO.Standard_Error,
                                  Item => SDL.Error.Get);

            WAV_Pong := No_Wave;
      end;
   end Load_Data;

   ---------------------------------------------------------------------
   --  My_Callback
   ---------------------------------------------------------------------
   procedure My_Callback (User_Data : in out Play_Info;
                          Stream    : in out Samples.Frames)
   is
      use type SDL.Audio.Buffer_Type;
   begin
      if User_Data.Data = SDL.Audio.Null_Buffer then
         --  No data available at all.
         Stream := (others => Silence);
         return;
         --  This is just a performance short cut, technically the code below
         --  handles empty buffers quite well.
      end if;

      Stream_Audio :
      declare
         --  Buffer indices are 1 based, so we can use Last_Index like Length.
         --  FIXME: Make code independent from actual array bounds.
         Last_Frame : constant Samples.Frame_Index :=
           Samples.Frame_Index'Min
             (Samples.Last_Index (User_Data.Data) - User_Data.Index,
              Stream'Last);
      begin
         --  Fill buffer with available audio data and update the audio index.
         for Frame in 1 .. Last_Frame loop
            Stream (Frame) := Samples.Value (Buffer => User_Data.Data,
                                             Frame  => Frame + User_Data.Index);
         end loop;

         --  If the input buffer was too short fill the remaining buffer with
         --  "silence".
         Stream (Last_Frame + 1 .. Stream'Last) := (others => Silence);

         --  Update data index from user data.
         User_Data.Index := User_Data.Index + Last_Frame;

         if User_Data.Index >= Samples.Last_Index (User_Data.Data) then
            --  Nothing more to stream...
            User_Data := Nothing;
         end if;
      end Stream_Audio;
   end My_Callback;

   procedure Audio_Callback is new
     SDL.Audio.Callback (User_Data     => Play_Info,
                         Audio_Frames  => Samples,
                         User_Callback => My_Callback);

   ---------------------------------------------------------------------
   --  Initialize
   ---------------------------------------------------------------------
   procedure Initialize is
      Required : SDL.Audio.Audio_Spec;
   begin
      Currently_Playing := Nothing;

      Load_Data;
      Required :=
        SDL.Audio.Audio_Spec'(Frequency => 48_000,
                              Format    => SDL.Audio.Audio_S16_LSB,
                              Channels  => 1,
                              Silence   => 0,
                              Samples   => 512,
                              Padding   => 0,
                              Size      => 0,
                              Callback  => Audio_Callback'Access,
                              Userdata  => Currently_Playing'Address);

      --  SDL2 API. Enumerate and report devices.
      for D in 1 .. SDL.Audio.Get_Number_Of_Devices (Is_Capture => False) loop
         Ada.Text_IO.Put_Line
           ("Audio device """ &
              SDL.Audio.Get_Device_Name (Index      => D,
                                         Is_Capture => False) & """ found.");
      end loop;

      declare
         Obtained : SDL.Audio.Audio_Spec;
      begin
         SDL.Audio.Open (Device          => Audio_Device,
                         Device_Name     => "",
                         Is_Capture      => False,
                         Desired         => Required,
                         Obtained        => Obtained,
                         Allowed_Changes => SDL.Audio.Allow_No_Change);
         SDL.Audio.Pause (Device   => Audio_Device,
                          Pause_On => False);
      exception
         when SDL.Audio.Audio_Error =>
            Ada.Text_IO.Put_Line (File => Ada.Text_IO.Standard_Error,
                                  Item => "Failed to initialize audio");
      end;
      pragma Unreferenced (Required);
   end Initialize;

   ---------------------------------------------------------------------
   --  Finalize
   ---------------------------------------------------------------------
   procedure Finalize is
   begin
      SDL.Audio.Pause (Device   => Audio_Device,
                       Pause_On => True);
      SDL.Audio.Close (Device => Audio_Device);

      SDL.Audio.Free_WAV (Buffer => WAV_Ping);
      SDL.Audio.Free_WAV (Buffer => WAV_Pong);
   end Finalize;

   ---------------------------------------------------------------------
   --  Play_Ping
   ---------------------------------------------------------------------
   procedure Play_Ping is
      use type SDL.Audio.Buffer_Type;
   begin
      SDL.Audio.Lock (Device => Audio_Device);

      --  Only write new buffer if previous one has played already.
      if Currently_Playing.Data = SDL.Audio.Null_Buffer then
         Currently_Playing :=
           Play_Info'(Data   => WAV_Ping,
                      Index  => 0);
      end if;

      SDL.Audio.Unlock (Device => Audio_Device);
   end Play_Ping;

   ---------------------------------------------------------------------
   --  Play_Pong
   ---------------------------------------------------------------------
   procedure Play_Pong is
      use type SDL.Audio.Buffer_Type;
   begin
      SDL.Audio.Lock (Device => Audio_Device);

      --  Only write new buffer if previous one has played already.
      if Currently_Playing.Data = SDL.Audio.Null_Buffer then
         Currently_Playing :=
           Play_Info'(Data  => WAV_Pong,
                      Index => 0);
      end if;

      SDL.Audio.Unlock (Device => Audio_Device);
   end Play_Pong;

end Game.Audio;
