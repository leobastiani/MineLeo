#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <WinAPISys.au3>
#include <File.au3>
_Singleton("MineLeo", 0)

If not FileExists(@ScriptDir & "\MineLeo.ini") Then
    ErrorBox("O arquivo MineLeo.ini não foi encontrado")
EndIf

Func _IniWrite($key, $val)
    Return IniWrite(@ScriptDir & "\MineLeo.ini", "MineLeo", $key, $val)
EndFunc   ;==>_IniWrite

Func _IniRead($key, $def)
    Return _WinAPI_ExpandEnvironmentStrings(IniRead(@ScriptDir & "\MineLeo.ini", "MineLeo", $key, $def))
EndFunc   ;==>_IniRead

Func ErrorBox($msg)
    MsgBox($MB_ICONERROR, "Erro", $msg)
    Exit
EndFunc   ;==>ErrorBox

Func FolderMustExist($folderPath, $msg)
    If not FileExists($folderPath) Then
        ErrorBox($msg)
    EndIf
EndFunc   ;==>FolderMustExist

Func DOS($cmd)
    ; https://www.autoitscript.com/autoit3/docs/functions/RunWait.htm
    RunWait(@ComSpec & " /c " & $cmd)    ; don't forget " " before "/c"
EndFunc   ;==>DOS

$Nome = _IniRead("Nome", "")
$MinecraftPath = _IniRead("MinecraftPath", "C:\Games\Minecraft 1.12.2 Rus")
$MinecraftGamePath = _IniRead("MinecraftGamePath", "%appdata%\.minecraft")
$GoogleDrivePath = _IniRead("GoogleDrivePath", "%userprofile%\Google Drive")
; path do minecraft no GoogleDrive
$MinecraftGDPath = _IniRead("GoogleDrivePath", "%userprofile%\Google Drive\MineLeo")
$MinecraftName = _IniRead("MinecraftName", "Minecraft 1.12.2")
$Server = _IniRead("Server", "http://localhost/api.php")

FolderMustExist($MinecraftPath, "Pasta do Minecraft não encontrada. Por favor, instale-o.")
FolderMustExist($MinecraftGamePath, "A pasta .minecraft não foi encontrada. Por favor, verifique.")
FolderMustExist($GoogleDrivePath, "Pasta do Google Drive não encontrada. Por favor, instale-o.")
FolderMustExist($MinecraftGDPath, "A pasta do MineLeo no Google Drive não foi encontrada. Por favor, verifique.")

If $Nome = "" Then
    ErrorBox("Configure seu nome no arquivo MineLeo.ini")
EndIf

Func JunctionSavesWorlds()
    ; faz a junction de todas as pastas no googledrive
    Local $aFileList = _FileListToArray($MinecraftGDPath & "\saves", "*")
    For $i = 1 To $aFileList[0]
        If not FileExists($MinecraftGamePath & "\saves\" & $aFileList[$i]) Then
            DOS("mklink /J """ & $MinecraftGamePath & "\saves\" & $aFileList[$i] & """ """ & $MinecraftGDPath & "\saves\" & $aFileList[$i] & """")
        EndIf
    Next
EndFunc   ;==>JunctionSavesWorlds

JunctionSavesWorlds()

If ProcessExists("googledrivesync.exe") Then
    ErrorBox("Feche o Google Drive Sync antes de iniciar.")
EndIf

Func HTTP($url)
    ; esse 1 é pra forçar o cache
    Local $ret = BinaryToString(InetRead($url, 1))
    Local $error = @error
    If $error <> 0 Then
        ErrorBox("Não foi possível conectar ao servidor.")
    EndIf
    Return $ret
EndFunc   ;==>HTTP

Func API($cmd)
    Global $Server
    Return HTTP($Server & "?" & $cmd)
EndFunc   ;==>API

Func StartMine()
    Global $MinecraftPath
    Run($MinecraftPath & "\Minecraft.exe")
EndFunc   ;==>StartMine

$Owner = API("owner")
Func HasOwner()
    Global $Owner
    If $Owner <> "None" Then
        $resp = MsgBox($MB_YESNO, "Servidor iniciado", "Servidor iniciado por: " & $Owner & @CRLF & "Deseja liberar o controle?")
        If $resp = $IDYES Then
            $resp = MsgBox($MB_YESNO, "Tem certeza", "Tem certeza que deseja liberar o controle?")
            If $resp = $IDYES Then
                Return False
            EndIf
        EndIf
        Return True
    EndIf
    Return False
EndFunc   ;==>HasOwner

If HasOwner() Then
    StartMine()
    Exit
EndIf

API("request=" & $Nome)

StartMine()

WinWait("Magic Launcher")
WinWaitClose("Magic Launcher")

Sleep(5000)
If WinExists($MinecraftName) Then
    WinWaitClose($MinecraftName)

    Run("C:\Program Files\Google\Drive\googledrivesync.exe")
    MsgBox(0, "Google Drive Sync Iniciado", "Por favor, espere até que o Google Drive Sync termine de enviar os arquivos.")
    DOS("explorer """ & $GoogleDrivePath & """")
EndIf


API("free")

