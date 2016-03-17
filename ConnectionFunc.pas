(*
 * Project: Coldroot
 * User: Coldzer0
 * Date: 1/2/16
 *)
unit ConnectionFunc;

{$mode Delphi}
{$SMARTLINK ON}

interface
uses
    LCLIntf, LCLType, LMessages ,SysUtils,Classes,IdThreadSafe,IdGlobal,
    IdContext,IdTCPClient,PacketTypes;


    function RecvString(AContext : TIdContext): String;
    procedure SendString( AContext : TIdContext; const Str: String);

    function ByteArrayToMainPacket(ABuffer: TIdBytes): TMainPacket;
    function MainPacketToByteArray(aRecord: TMainPacket): TIdBytes;

    function ReceiveBuffer(AContext: TIdContext; var ABuffer: TIdBytes): Boolean; overload;
    function SendBuffer(AContext: TIdContext; ABuffer: TIdBytes): Boolean; overload;

    function ReceiveStream(AContext: TIdContext; var AStream: TMemoryStream): Boolean; overload;
    function ClientSendStream(AClient: TIdTCPClient; AStream: TStream): Boolean; overload;


    function ClientSendBuffer(AClient: TIdTCPClient; ABuffer: TIdBytes): Boolean; overload;
    function ClientReceiveBuffer(AClient: TIdTCPClient; var ABuffer: TIdBytes): Boolean; overload;

    procedure ClientSendString( AClient: TIdTCPClient; const Str: String);



    function ArrayToString(const a: array of Char): string;
type
    TGenericRecord<TRecordType> = class

    private
        FValue: TRecordType;
        FIsNil: Boolean;

    public
        /// <summary>
        /// Convert Byte to Record , outputtype : TRecordType
        /// </summary>
        /// <param name="ABuffer">
        /// Byte Array
        /// </param>
        function ByteArrayToMyRecord(ABuffer: TIdBytes): TRecordType;
        // class function ByteArrayToMyRecord(ABuffer: TIdBytes): TRecordType; static;

        /// <summary>
        /// Store a Record into a BYTE Array
        /// </summary>
        /// <param name="aRecord">
        /// adjust this record definition to your needs
        /// </param>
        function MyRecordToByteArray(aRecord: TRecordType): TIdBytes;
        // class function MyRecordToByteArray(aRecord: TRecordType): TIdBytes; static;

        property Value: TRecordType read FValue write FValue;
        property IsNil: Boolean read FIsNil write FIsNil;
    end;

implementation


function ArrayToString(const a: array of Char): string;
begin
    if Length(a)>0 then
    begin
        SetString(Result, PChar(@a[0]), Length(a));
        Result := Trim(Result);
    end
    else
        Result := '';
end;

function RecvString(AContext : TIdContext): String;
begin
    Result := AContext.Connection.IOHandler.ReadString(
    AContext.Connection.IOHandler.ReadInt32,
    IndyTextEncoding_UTF8);
end;

procedure SendString( AContext : TIdContext; const Str: String);
var
    Buf: TIdBytes;
begin
    Buf := IndyTextEncoding_UTF8.GetBytes(Str);
    AContext.Connection.IOHandler.Write(Int32(Length(Buf)));
    AContext.Connection.IOHandler.Write(Buf);
end;

procedure ClientSendString( AClient: TIdTCPClient; const Str: String);
var
    Buf: TIdBytes;
begin
    Buf := IndyTextEncoding_UTF8.GetBytes(Str);
    AClient.IOHandler.Write(Int32(Length(Buf)));
    AClient.IOHandler.Write(Buf);
end;

///
/// -------------   HELPER FUNCTION FOR RECORD EXCHANGE   ---------------------
///

function ClientReceiveBuffer(AClient: TIdTCPClient; var ABuffer: TIdBytes): Boolean; overload;
var
    LSize: LongInt;
begin
    Result := True;
    try
        LSize := AClient.IOHandler.ReadLongInt();
        AClient.IOHandler.ReadBytes(ABuffer, LSize, False);
    except
        Result := False;
    end;
end;

function ClientSendBuffer(AClient: TIdTCPClient; ABuffer: TIdBytes): Boolean; overload;
begin
    try
        Result := True;
        try
            AClient.IOHandler.Write(LongInt(Length(ABuffer)));
            AClient.IOHandler.WriteBufferOpen;
            AClient.IOHandler.Write(ABuffer, Length(ABuffer));
            AClient.IOHandler.WriteBufferFlush;
        finally
            AClient.IOHandler.WriteBufferClose;
        end;
    except
        Result := False;
    end;

end;

function SendBuffer(AContext: TIdContext; ABuffer: TIdBytes): Boolean; overload;
begin
    try
        Result := True;
        try
            AContext.Connection.IOHandler.Write(LongInt(Length(ABuffer)));
            AContext.Connection.IOHandler.WriteBufferOpen;
            AContext.Connection.IOHandler.Write(ABuffer, Length(ABuffer));
            AContext.Connection.IOHandler.WriteBufferFlush;
        finally
            AContext.Connection.IOHandler.WriteBufferClose;
        end;
    except
        Result := False;
    end;
end;

function ReceiveBuffer(AContext: TIdContext; var ABuffer: TIdBytes)
: Boolean; overload;
var
    LSize: LongInt;
begin
    Result := True;
    try
        LSize := AContext.Connection.IOHandler.ReadLongInt();
        AContext.Connection.IOHandler.ReadBytes(ABuffer, LSize, False);
    except
        Result := False;
    end;
end;

///
/// ---------------------   HELP FUNCTION FOR STREAM  EXCHANGE  --------------
///

function ReceiveStream(AContext: TIdContext; var AStream: TMemoryStream): Boolean; overload;
var
    LSize: LongInt;
begin
    Result := True;
    try
        LSize := AContext.Connection.IOHandler.ReadLongInt();
        AContext.Connection.IOHandler.ReadStream(AStream, LSize, False);
    except
        Result := False;
    end;
end;

function ClientReceiveStream(AClient: TIdTCPClient; var AStream: TStream)
: Boolean; overload;
var
    LSize: LongInt;
begin
    Result := True;
    try
        LSize := AClient.IOHandler.ReadLongInt();
        AClient.IOHandler.ReadStream(AStream, LSize, False);
    except
        Result := False;
    end;
end;

function SendStream(AContext: TIdContext; AStream: TStream): Boolean; overload;
var
    StreamSize: LongInt;
begin
    try
        Result := True;
        try
            StreamSize := (AStream.Size);

                // AStream.Seek(0, soFromBeginning);
            AStream.Position := 0;
            AContext.Connection.IOHandler.Write(LongInt(StreamSize));
            AContext.Connection.IOHandler.WriteBufferOpen;
            AContext.Connection.IOHandler.Write(AStream, 0, False);
            AContext.Connection.IOHandler.WriteBufferFlush;
        finally
            AContext.Connection.IOHandler.WriteBufferClose;
        end;
    except
        Result := False;
    end;

end;

function ClientSendStream(AClient: TIdTCPClient; AStream: TStream): Boolean; overload;
var
    StreamSize: LongInt;
begin
    try
        Result := True;
        try
            StreamSize := (AStream.Size);

                // AStream.Seek(0, soFromBeginning);
                // AClient.IOHandler.LargeStream := True;
                // AClient.IOHandler.SendBufferSize := 32768;

            AClient.IOHandler.Write(LongInt(StreamSize));
            AClient.IOHandler.WriteBufferOpen;
            AClient.IOHandler.Write(AStream, 0, False);
            AClient.IOHandler.WriteBufferFlush;
        finally
            AClient.IOHandler.WriteBufferClose;
        end;
    except
        Result := False;
    end;
end;

///
/// ---------------   HELPER FUNCTION FOR RECORD EXCHANGE  ------------------
/// (not using generic syntax features of DELPHI 2009 and better )

function MainPacketToByteArray(aRecord: TMainPacket): TIdBytes;
var
    LSource: PAnsiChar;
begin
    aRecord.Signature := $DEAD;
    LSource := PAnsiChar(@aRecord);
    SetLength(Result, SizeOf(TMainPacket));
    Move(LSource[0], Result[0], SizeOf(TMainPacket));
end;

function ByteArrayToMainPacket(ABuffer: TIdBytes): TMainPacket;
var
    LDest: PAnsiChar;
begin
    LDest := PAnsiChar(@Result);
    Move(ABuffer[0], LDest[0], SizeOf(TMainPacket));
end;

function TGenericRecord<TRecordType>.MyRecordToByteArray
    (aRecord: TRecordType): TIdBytes;
var
    LSource: PAnsiChar;
begin
    LSource := PAnsiChar(@aRecord);
    SetLength(Result, SizeOf(TRecordType));
    Move(LSource[0], Result[0], SizeOf(TRecordType));
end;

function TGenericRecord<TRecordType>.ByteArrayToMyRecord(ABuffer: TIdBytes)
: TRecordType;
var
    LDest: PAnsiChar;
begin
    LDest := PAnsiChar(@Result);
    Move(ABuffer[0], LDest[0], SizeOf(TRecordType));
end;

end.