(*
 * Project: Coldroot ..
 * User: Coldzer0 ..
 * Date: 3/16/16 ..
 *)
unit FilesFunc;

{$mode Delphi}
{$SMARTLINK ON}

interface
    uses
        fileutil,sysutils,classes;




    function GetAllinDir(Dir : string): TStringList;

implementation

function GetAllinDir(Dir : string): TStringList;
var
    Files: TStringList;
    i : Integer;
begin
    Files := FindAllFiles(Dir, '*.*', false); // find all file and folder in given path ..
    try
        Result := Files;
        WriteLn(Files.Count);
        for i := 0 to Files.Count -1 do
            WriteLn(Files[i]);
    finally
        Files.Free;
    end;
end;


end.