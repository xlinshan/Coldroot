program Cold;

{$mode Delphi}{$H+}

uses
    cthreads,classes,LCLIntf,LCLType,sysutils,
    ConnectionThread,
    PacketTypes,
    IdGlobal,IdTCPClient,IdCompressionIntercept,
    FilesFunc;



function OSVersion: string;
var
    osErr: integer;
    response: longint;
begin
    {
    OS := '';
    s := ArrayToString(kernelname.release);
    case s of
    '15.0.0','15.0.2': OS := 'OS X El Capitan v10';
    end;
    MajVer := IntToStr(Lo(DosVersion) - 4);
    MinVer := IntToStr(Hi(DosVersion));
    WriteLn(OS+'.'+MajVer+'.'+MinVer);
    }
    Result := '';
end;

var
    thread : TMainClientThread;
    buffer : TIdBytes;
    MainClient : TIdTCPClient;
    inter : TIdCompressionIntercept;
    IP : string;
begin
    try
        inter := TIdCompressionIntercept.Create();
        inter.CompressionLevel := 9;
        MainClient := TIdTCPClient.Create();
        MainClient.Intercept  := inter;

        thread := TMainClientThread.Create(false);
        thread.IP := '10.211.55.9';
        thread.Port := 889;
        thread.TCPClient := MainClient;
        thread.Active := true;
        thread.WaitFor();
        if thread.ThreadTerminated then
            WriteLn('Main Thread Terminated .[2]..');
    except
        WriteLn('error ..');
    end;

    WriteLn('Finished :( ');

end.