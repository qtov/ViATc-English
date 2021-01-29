; user.ahk 
; This file is for your custom commands and any additions to the ViATc.
; It should work with future updates of ViATc.
; This file is loaded automatically at the start/reload of ViATc, before all. 
; This file is not needed and not fully useful.
; To disable it, either rename, move or delete it.
; It is easy to make errors too. Comment out any wonky code that you've added and don't use.

Global UserCommandsArr := object()
UserCommandsArr["<UserCommand1>"] :=" Sample User Command 1 description, MsgBox"
UserCommandsArr["<UserCommand2>"] :=" Sample User Command 2 description, MsgBox"
UserCommandsArr["<UserCommand3>"] :=" Sample User Command 3 description, function with MsgBox"
;UserCommandsArr["<AnyIdea>"] :=" change any description"
;... add as many as you like, you can use any names but surround them with <>
; you can change any name and description
; you have to add commands to the array above, otherwise you won't be able to use them
; AHK will go to end to skip execution of code below at startup/reload of main script 
goto end_of_file

<UserCommand1>:
   MsgBox Hi, this is a UserCommand1 here
Return

<UserCommand2>:
   ;MsgBox Hi, this is a UserCommand2 here
   ;Send {Up}
   goto Wisdom
   ;CheckForUpdates()
Return

<UserCommand3>:
    SampleFunction()
Return

SampleFunction()
{
   MsgBox SampleFunction here
}

; --- TC mappings
#if WinActive( "ahk_class TTOTAL_CMD" )
   ; your TC snippets go here
   ;F1::Media_Play_Pause
   ;F2::Msgbox This is example of a mapping in user.ahk
#if
; end of TC mappings



; --- the below mappings are global
;F3::Msgbox This is a global mapping in user.ahk

/*
; Win+g = toggle gVim
#g::
DetectHiddenWindows, on
IfWinNotExist ahk_class Vim
	Run, c:\Program Files\Vim\Vim82\gvim.exe,,max
Else
IfWinNotActive ahk_class Vim
	WinActivate
Else
	WinMinimize
Return
*/






; don't put anything below this line
end_of_file:
