@ECHO OFF
SETLOCAL EnableDelayedExpansion

set PATH=%PATH%;C:\Program Files (x86)\AutoIt3\Aut2Exe

ResetName.au3 ""

Aut2exe /in MineLeo.au3 /icon Minecraft.ico
7z a MineLeo.zip MineLeo.exe MineLeo.ini
del MineLeo.exe

ResetName.au3 "Leonardo"