Global Version := "0.5.5.2"
Global Date := "2021/10/15"
; This script works on Windows with AutoHotkey installed, and only as an addition to 
; "Total Commander" - the file manager from www.ghisler.com  
; ViATc tries to resemble the work-flow of Vim and web browser plugins like Vimium 
; or better yet SurfingKeys.
; Author of the original Chinese version is linxinhong https://github.com/linxinhong
; Translator and maintainer of the English version is https://github.com/magicstep  
; you can contact me with the same nickname  m.......p@gmail.com

; tripple ??? and !!! are markers for debugging
; tripple curly braces are for line folding in vim
; {{{1
#SingleInstance Force
#Persistent
#NoEnv
#NoTrayIcon
; user.ahk file is for custom snippets and any addition to the viatc.ahk script
; *i = ignore any read failure
#include *i A_ScriptDir . "\user.ahk"
#include *i user.ahk

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
Setkeydelay -1
SetControlDelay -1
Detecthiddenwindows on
Coordmode Menu,Window
If A_IsCompiled
    Version .= " Compiled Executable"
Global EditorPath :=            ; it is read from ini later
Global EditorArguments :=       ; it is read from ini later
Global ExecuteInHeader :=       ; it is read from marks.ini later
Global IconPath := A_ScriptDir . "\viatc.ico"
Global IconDisabledPath := A_ScriptDir . "\viatcdis.ico"
Global HistoryOfRenamePath := A_ScriptDir . "\history_of_rename.txt"
Global MarksPath := A_ScriptDir . "\marks.ini"
Global UserFilePath :=  A_ScriptDir . "\user.ahk"
KeyTemp :=
Repeat :=
ViatcCommand :=
KeyCount := 0
Global Vim := true
Global InsertMode := False
Global FancyR := True
Global FancyR_Count
Global FancyR_ID
Global FancyR_History := Object()
Global FancyR_Temp
Global FancyR_Vis := False
Global FancyR_IsReplace := False
Global FancyR_IsMultiReplace := False
Global FancyR_IsFind := False
Global ViatcIni
Global GlobalCheckbox
Global CheckForUpdatesButton
Global EnableBuiltInHotkeys :=1
Global EnableBuiltInComboHotkeys :=1
;Global LastOverwrittenMark
ComboKey_Arr := object()
MapKey_Arr := object()
ExecFile_Arr := object()
SendText_Arr := object()
Command_Arr := object()
CmdHistory_Arr := object()
Mark_Arr := object()
HideControl_Arr := object()
CommandInfo_Arr := object()
HelpInfo_Arr := object()
ComboInfo_Arr := object()
ReName_Arr := Object()
STabs := Object()
HideControl_Arr["Toggle"] := False
ViATcIni :=  A_ScriptDir . "\viatc.ini"
If Not FileExist(ViATcIni)
    RegRead,ViATcIni,HKEY_CURRENT_USER,Software\VIATC,ViATcINI
;RegRead,ViATcIni,HKEY_CURRENT_USER,Software\VIATC,ViATcINI
;If Not FileExist(ViATcIni)
	;ViATcIni :=  A_ScriptDir . "\viatc.ini"
;If FileExist(ViATcIni)
    ;Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,ViATcIni,%ViATcIni%
;else
    ;MsgBox no ViATcIni
TcExe := FindPath("exe")
TcIni := FindPath("ini")
Splitpath,TcExe,,TcDir
;Global TCBit:=
If RegExMatch(TcExe,"i)totalcmd64\.exe")
{
    Global TCBit := 64
    Global TCExeOnly := "totalcmd64.exe"
    Global ahk_exe_TC = "ahk_exe totalcmd64.exe"
	Global TCListBox := "LCLListBox"
	Global TCEdit := "Edit1"  ;was Edit2, later both are considered when used
    ; TC changes "Edit1" to "Edit2" when you open any of its windows containing an edit-box
    Global TCEditRename := "Edit1"
    GLobal TCPanel1 := "Window1"
    Global TCPanel2 := "Window11"
	;GLobal TCPanel1 := "LCLListBox2"
	;GLobal TCPanel2 := "LCLListBox1"
}
Else
{
    Global TCBit := 32
    Global TCExeOnly := "totalcmd.exe"
    Global ahk_exe_TC = "ahk_exe totalcmd.exe"
	Global TCListBox := "TMyListBox"
	Global TCEdit := "Edit1"
    Global TCEditRename := "TInEdit1"
    Global TCPanel1 := "TPanel1"
    Global TCPanel2 := "TMyPanel8"
    ;Global TCPanel1 := "LCLListBox2"
	;Global TCPanel2 := "LCLListBox1"
}

GoSub,<ConfigVar>
Menu,FancyR_DefaultsMenu,Add, Insert mode at start `tAlt+I,FancyR_SelMode
Menu,FancyR_DefaultsMenu,Add, Extension unselected at start `tAlt+E,FancyR_SelExt
Menu,FancyR_MENU,Add, &Defaults,:FancyR_DefaultsMenu
Menu,FancyR_MENU,Add, &Keys,FancyR_Keys
Menu,FancyR_MENU,Add, &Help,FancyR_Help

Menu,Tray,NoStandard
Menu,Tray,Add, Run TC (&T),<ToggleTC>
Menu,Tray,Add, Disable (&D),<ToggleViATc>
Menu,Tray,Add, Reload (&R),<ReLoadVIATC>
If Not A_IsCompiled
{
    Menu,Tray,Add, Edit Script (&E),<EditScript>
    Menu,Tray,Add, Edit Script with Vim (&V),<EditScriptWithVim>
}
Menu,Tray,Add
Menu,Tray,Add, Settings (&S),<Setting>
Menu,Tray,Add, Help (&H),<Help>
Menu,Tray,Add
Menu,Tray,Add, Exit (&X),<QuitVIATC>
Menu,Tray,Tip,ViATc %Version%  - Vim mode at TotalCommander
Menu,Tray,Default, Run TC (&T)
If TrayIcon
	Menu,Tray,Icon
Menu,Tray,NoStandard
If FileExist(IconPath)
    Menu,Tray,Icon,%IconPath%
SetHelpInfo()
SetViatcCommand()
SetCommandInfo()
SetDefaultKey()
ReadKeyFromIni()
EmptyMem()
Winactivate,AHK_CLASS TTOTAL_CMD
<Esc>
return
; end of main script }}}1

; --- config {{{1
<ConfigVar>:
Vim := GetConfig("Configuration","Vim")
Toggle := TransHotkey(GetConfig("Configuration","Toggle"),"ALL")
GlobalTogg := GetConfig("Configuration","GlobalTogg")
If GlobalTogg
{
	Hotkey,%Toggle%,<ToggleTC>,On,UseErrorLevel
	Toggle := GetConfig("Configuration","Toggle")
}
Else
{
	HotKey,Ifwinactive,AHK_CLASS TTOTAL_CMD
	Hotkey,%Toggle%,<ToggleTC>,On,UseErrorLevel
	Toggle := GetConfig("Configuration","Toggle")
}
Susp := TransHotkey(GetConfig("Configuration","Suspend"),"ALL")
GlobalSusp := GetConfig("Configuration","GlobalSusp")
If GlobalSusp
{
	HotKey,Ifwinactive
	Hotkey,%Susp%,<ToggleViATc>,On,UseErrorLevel
	Susp := GetConfig("Configuration","Suspend")
}
Else
{
	HotKey,Ifwinactive,AHK_CLASS TTOTAL_CMD
	Hotkey,%Susp%,<ToggleViATc>,On,UseErrorLevel
	Susp := GetConfig("Configuration","Suspend")
}
HistoryOfRename := GetConfig("Configuration","HistoryOfRename")
TrayIcon := GetConfig("Configuration","TrayIcon")
Service := GetConfig("Configuration","Service")
If Not Service
{
	IfWinExist,AHK_CLASS TTOTAL_CMD
	Winactivate,AHK_CLASS TTOTAL_CMD
	Else
	{
		Run,%TcExe%,,UseErrorLevel
		If ErrorLevel = ERROR
			TcExe := FindPath("exe")
	}
	WinWait,AHK_CLASS TTOTAL_CMD
	Settimer,<CheckTCExist>,100
}
StartUp := GetConfig("Configuration","Startup")
If StartUp
{
	RegRead,IsStartup,HKEY_CURRENT_USER,SOFTWARE\Microsoft\Windows\CurrentVersion\Run,ViATc
	If Not RegExMatch(IsStartup,A_ScriptFullPath)
	{
		RegWrite,REG_SZ,HKEY_CURRENT_USEr,SOFTWARE\Microsoft\Windows\CurrentVersion\Run,ViATc,%A_ScriptFullPath%
		If ErrorLevel
			MsgBox,16,ViATc, Set Startup failed ,3
	}
}
Else
	Regdelete,HKEY_CURRENT_USER,SOFTWARE\Microsoft\Windows\CurrentVersion\Run,ViATc
ComboTooltips := GetConfig("Configuration","ComboTooltips")
GlobalSusp := GetConfig("Configuration","GlobalSusp")
TranspHelp := GetConfig("Configuration","TranspHelp")
MaxCount := GetConfig("Configuration","MaxCount")
TranspVar := GetConfig("Configuration","TranspVar")
DefaultSE := GetConfig("SearchEngine","Default")
SearchEng := GetConfig("SearchEngine",DefaultSE)
LnkToDesktop := GetConfig("Other","LnkToDesktop")
HistoryOfRename := GetConfig("Configuration","HistoryOfRename")
IsCapslockAsEscape := GetConfig("Configuration","IsCapslockAsEscape")
FancyVimRename := GetConfig("FancyVimRename","Enabled")
UseSystemClipboard := GetConfig("FancyVimRename","UseSystemClipboard")
FancyR  := GetConfig("FancyVimRename","Enabled")
EditorPath := GetConfig("Paths","EditorPath")
If Not FileExist(EditorPath)   
{
    ;fallback to the system vim path
    RegRead,VimPath,HKEY_LOCAL_MACHINE,Software\vim\gvim,path
    EditorPath := VimPath
    If Not FileExist(EditorPath)   ;fallback to notepad++
        EditorPath := "c:\Program Files (x86)\Notepad++\notepad++.exe" 
    If Not FileExist(EditorPath) ;fallback to the last resort
        EditorPath := "C:\Windows\notepad.exe"  
    SetConfig("Paths","EditorPath",EditorPath)
    ;MsgBox EditorPath in the ini file was not found, it is now updated to %EditorPath%
}
EditorArguments := GetConfig("Paths","EditorArguments")
;Trimming leading and trailing white space is automatic when assigning a variable with only = 
EditorArguments = %EditorArguments% 
EditorArguments :=A_space . EditorArguments . A_space
IniRead,ExecuteInHeader,%MarksPath%,MarkSettings,ExecuteInHeader
Global F11TC := GetConfig("Configuration","F11TC")
Global IrfanView := GetConfig("Configuration","IrfanView")
Global IrfanViewKey := GetConfig("Configuration","IrfanViewKey")
If IrfanView     ;this variable is set in the viatc.ini file
{
	HotKey,Ifwinactive
    Hotkey,%IrfanViewKey%, <Traverse>, On, UseErrorLevel           ;Turn on the dynamic hotkey.
}
Return
;}}}

; --- labels with actions defined {{{1
<32768>:
Get32768()
Return

Get32768()
{
	Global InsertMode
	WinGet,MenuID,ID,AHK_CLASS #32768
	IF MenuID
		InsertMode := True
	Else
	{
		InsertMode := False
		SetTimer,<32768>,OFF
	}
}

<ComboKey>:
ComboKey(A_ThisHotkey)
Return
<CheckTCExist>:
IfWinNotExist,AHK_CLASS TTOTAL_CMD
ExitApp
Return
<RemoveTooltip>:
SetTimer,<RemoveToolTip>, Off
ToolTip
return
<RemoveToolTipEx>:
Ifwinnotactive,AHK_CLASS TTOTAL_CMD
{
	SetTimer,<RemoveToolTipEx>, Off
	ToolTip
}
If A_ThisHotkey = Esc
{
	SetTimer,<RemoveToolTipEx>, Off
	Tooltip
}
return
<Exec>:
If SendPos(0)
	ExecFile()
return
<Text>:
If SendPos(0)
	SendText()
return
<None>:
SendPos(-1)
return
<MsgVar>:
MsgBox % "Text=" SendText_Arr["Hotkeys"] "`n" "Exec=" ExecFile_Arr["HotKeys"] "`n" "MapKeys=" MapKey_Arr["HotKeys"] "`nCombokey=" ComboKey_Arr["Hotkeys"]
Return
<ComboWarnAction>:
Msg := ComboInfo_arr[A_ThisHotkey]
StringSplit,Len,Msg,`n
ControlGetPos,xn,yn,,hn,%TCEdit%,AHK_CLASS TTOTAL_CMD
yn := yn - hn  - ( Len0 - 1 ) * 17
Tooltip,%Msg%,%xn%,%yn%
SetTimer,<RemoveTooltipEx>,50   ; 50 is a delay
settimer,<ComboWarnAction>,off
return
<Esc>:
Send,{Esc}
Vim := True
KeyCount := 0
KeyTemp :=
InsertMode := False
Tooltip
ControlSetText,%TCEdit%,,AHK_CLASS TTOTAL_CMD
Settimer,<RemoveTooltipEx>,off
EmptyMem()
WinClose,ViATc_TabList
Gui,Destroy
Return

<CapsLock>:
    ;Send,{CapsLock}
    SetCapsLockState, % GetKeyState("CapsLock", "T")? "Off":"On"
Return

<CapsLockOn>:
    SetCapsLockState, % "On"
Return

<CapsLockOff>:
    SetCapsLockState, % "Off"
Return

<ToggleTC>:
Ifwinexist,AHK_CLASS TTOTAL_CMD
{
	WinGet,AC,MinMax,AHK_CLASS TTOTAL_CMD
	If Ac = -1
		Winactivate,AHK_ClASS TTOTAL_CMD
	Else
		Ifwinnotactive,AHK_CLASS TTOTAL_CMD
	Winactivate,AHK_CLASS TTOTAL_CMD
	Else
		Winminimize,AHK_CLASS TTOTAL_CMD
}
Else
{
	Run,%TcExe%,,UseErrorLevel
	If ErrorLevel = ERROR
		TcExe := FindPath("exe")
	Loop,6
	{
		WinWait,AHK_CLASS TTOTAL_CMD,,3
		If ErrorLevel
			Run,%TcExe%,,UseErrorLevel
		Else
			Break
	}
	Winactivate,AHK_CLASS TTOTAL_CMD
	If Transparent
		WinSet,Transparent,220,ahk_class TTOTAL_CMD
}
EmptyMem()
Return

<ToggleViATc>:
Suspend
If Not IsSuspended
{
	Menu,Tray,Rename, Disable (&D), Enable (&E)
	TrayTip,, Disabled ViATc,10,17
    If FileExist(IconDisabledPath)
    {
        If A_IsCompiled
            Menu,Tray,Icon,viatcdis.ico
        Else
            Menu,Tray,Icon,%IconDisabledPath%
    }
	Settimer,<GetKey>,100
	IsSuspended := 1
}
Else
{
	Menu,Tray,Rename, Enable (&E), Disable (&D)
	TrayTip,, Enabled ViATc,10,17
    If FileExist(IconPath)
    {
        If A_IsCompiled
            Menu,Tray,icon,%IconPath%,1,1
        Else
            Menu,Tray,Icon,%IconPath%
    }
	Settimer,<GetKey>,off
	IsSuspended := 0
	Suspend,off
}
Return
<GetKey>:
IfWinActive AHK_CLASS TTOTAL_CMD
Suspend,on
Else
	Suspend,off
Return

<ReLoadVIATC>:
ReloadVIATC()
Return
ReloadVIATC()
{
    ToolTip
	ToggleMenu(1)
	If HideControl_arr["Toggle"]
		HideControl()
	Reload
}

<EditScript>:
    run, edit %a_scriptFullPath%    ; open in the default editor
Return

<EditScriptWithVim>:
    run, %EditorPath% . %EditorArguments% . `"%a_scriptFullPath%`" 
Return

<Enter>:
Enter()
Return
<ToggleViatcVim>:
If SendPos(0)
	Vim := !Vim
Return
<ViATcVimOff>:
	Vim := false
Return
<Setting>:
If SendPos(0)
	Setting()
Return
<Help>:
If SendPos(0)
	Help()
Return
<QuitViatc>:
If SendPos(0)
	ExitApp
Return
<Num0>:
SendNum("0")
Return
<Num1>:
SendNum("1")
Return
<Num2>:
SendNum("2")
Return
<Num3>:
SendNum("3")
Return
<Num4>:
SendNum("4")
Return
<Num5>:
SendNum("5")
Return
<Num6>:
SendNum("6")
Return
<Num7>:
SendNum("7")
Return
<Num8>:
SendNum("8")
Return
<Num9>:
SendNum("9")
Return
<Down>:
SendKey("{down}")
Return
<Up>:
SendKey("{up}")
Return
<Left>:
SendKey("{Left}")
Return
<Right>:
SendKey("{Right}")
Return
<ForceDel>:
SendKey("+{Delete}")
Return
<UpSelect>:
SendKey("+{Up}")
Return
<DownSelect>:
SendKey("+{down}")
Return
<PageUp>:
SendKey("{PgUp}")
Return
<PageDown>:
SendKey("{PgDn}")
Return
<Home>:
If SendPos(0)
	GG()
Return
GG()
{
	ControlGetFocus,ctrl,AHK_CLASS TTOTAL_CMD
	PostMessage, 0x19E, 0, 1, %CTRL%, AHK_CLASS TTOTAL_CMD
}
<End>:
If SendPos(0)
	G()
Return
G()
{
	ControlGetFocus,ctrl,AHK_CLASS TTOTAL_CMD
	ControlGet,text,List,,%ctrl%,AHK_CLASS TTOTAL_CMD
	Stringsplit,T,Text,`n
	Last := T0 - 1
	PostMessage, 0x19E, %Last%, 1, %CTRL%, AHK_CLASS TTOTAL_CMD
}

; --- Marks {{{2
<Mark>:
If SendPos(4003)
{
    Loop,22
    {
        ControlGetFocus,ThisControl,AHK_CLASS TTOTAL_CMD
        If (( %ThisControl% = Edit1 ) or ( %ThisControl% = Edit2 ))
        {
            TCEdit := ThisControl
            Break
        }
        Sleep,50
    }
	;ControlSetText,Edit1,m,AHK_CLASS TTOTAL_CMD
	;ControlSetText,Edit2,m,AHK_CLASS TTOTAL_CMD
	ControlSetText,%TCEdit%,m,AHK_CLASS TTOTAL_CMD
    Send {right}
	Postmessage,0xB1,2,2,%TCEdit%,AHK_CLASS TTOTAL_CMD
	SetTimer,<MarkTimer>,100
}
Return
<MarkTimer>:
MarkTimer()
Return
MarkTimer()
{
	Global Mark_Arr,VIATCINI
	ControlGetFocus,ThisControl,AHK_CLASS TTOTAL_CMD

    Loop,22
    {
        ControlGetFocus,ThisControl,AHK_CLASS TTOTAL_CMD
        If (( %ThisControl% = Edit1 ) or ( %ThisControl% = Edit2 ))
            Break
        Sleep,50
    }

    TCEdit =  %ThisControl%
    ;MsgBox  Debugging ThisControl = [%ThisControl%]  on line %A_LineNumber% ;!!! 

	ControlGetText,OutVar,%TCEdit%,AHK_CLASS TTOTAL_CMD
	Match_TCEdit := "i)^" . TCEdit . "$"
	If Not RegExMatch(TCEdit,Match_TCEdit) OR Not RegExMatch(Outvar,"i)^m.?")
	{
		Settimer,<MarkTimer>,Off
		Return
	}
	If RegExMatch(OutVar,"i)^m.$")
	{
		SetTimer,<MarkTimer>,off
		ControlSetText,%TCEdit%,,AHK_CLASS TTOTAL_CMD
        if (OutVar = "m>") or (OutVar = "m<")
        {
            Send {Esc}
        }
        else
            ControlSend,%TCEdit%,{Esc},AHK_CLASS TTOTAL_CMD
		ClipSaved := ClipboardAll
		Clipboard :=
		Postmessage 1075, 2029, 0,, ahk_class TTOTAL_CMD
		ClipWait
		Path := Clipboard
		Clipboard := ClipSaved
		If StrLen(Path) > 80
		{
			SplitPath,Path,,PathDir
			Path1 := SubStr(Path,1,15)
			Path2 := SubStr(Path,RegExMatch(Path,"\\[^\\]*$")-Strlen(Path))
			Path := Path1 . "..." . SubStr(Path2,1,65) "..."
		}
		m := SubStr(OutVar,2,1)
        if (m = " ") or (m = "=") or (m = ";") or (m = "[") or (m = ";")
        {
            Tooltip The space`, ';'`, '=' and '[' are not allowed as marks  
            Settimer,<RemoveHelpTip>,3000
            Return
        }
		Iniread,LastPath,%MarksPath%,MarkList,%m%
        if LastPath and (LastPath != ERROR)
        {
            ;LastOverwrittenMark := m . " >> " . LastPath
            LastOverwrittenMark := m . "=" . LastPath
            IniWrite,%LastOverwrittenMark%,%MarksPath%,MarkSettings,LastOverwrittenMark
            ;tooltip This mark is already on the list
            ;tooltip mark %m% updated`, `nearlier it was `n%LastOverwrittenMark%
            tooltip mark updated`, earlier it was `n%LastOverwrittenMark% `nRestore with:  a'
            Settimer,<RemoveHelpTip>,4000
        }
        ;saving mark to ini file
        IniWrite,%Path%,%MarksPath%,MarkList,%m%
	}
}


<RestoreLastMark>:
RestoreLastMark()
Return

RestoreLastMark()
{
    Iniread,LastOverwrittenMark,%MarksPath%,MarkSettings,LastOverwrittenMark
    ;If Not LastOverwrittenMark
    If (LastOverwrittenMark = "ERROR") or (LastOverwrittenMark = "")
    {
        MsgBox Nothing to restore
        Return false
    }
    ; LastOverwrittenMark is something like "c=C:\"
    m := SubStr(LastOverwrittenMark, 1 , 1)     ; mark is the first char
    LastPath := SubStr(LastOverwrittenMark, 3)  ; path is after =
    Iniread,CurrentPath,%MarksPath%,MarkList,%m%

    MsgBox, 4,, Restore mark %m% `nfrom: %CurrentPath%`nto:     %LastPath%
    ;MsgBox, 4,, Restore mark %m% ? `nEarlier it was %LastPath%

    IfMsgBox Yes
    {
        IniWrite,%LastPath%,%MarksPath%,MarkList,%m%
        LastOverwrittenMark := ""
        IniWrite,%LastOverwrittenMark%,%MarksPath%,MarkSettings,LastOverwrittenMark
        Tooltip Restored
    }
    else
        Tooltip Cancelled
    sleep 800
    Tooltip
}

<ListMarksTooltip>:
ListMarksTooltip()
Return

ListMarksTooltip()
{
		Tooltiplm :=
		IniRead,active_marks,%MarksPath%,MarkSettings,active_marks
		h := 0
        ; !!! outdated below
		loop, Parse , active_marks , `,
		{
			h++
			Iniread,Path,%MarksPath%,MarkList,%A_LoopField%
			if Path != ERROR
				tooltiplm = %tooltiplm%%A_LoopField% `= %Path%`n
		}
		Controlgetpos,xe,ye,we,he,%TCEdit%,ahk_class TTOTAL_CMD
		tooltip,%Tooltiplm%,xe,ye-h*16-5
		return
}


;Execute mark, the name AddMark is misleading
<AddMark>:
AddMark()
Return
;		Iniread,Location,%A_WorkingDir%viatc.ini,mark,%p%

AddMark()
{
	ThisMenuItem := SubStr(A_ThisMenuItem,5,StrLen(A_ThisMenuItem))
	If RegExMatch(ThisMenuItem,"i)\\\\Desktop$")
	{
		Postmessage 1075, 2121, 0,, ahk_class TTOTAL_CMD
		Return
	}
	If RegExMatch(ThisMenuItem,"i)\\\\This PC$")
	{
		Postmessage 1075, 2122, 0,, ahk_class TTOTAL_CMD
		Return
	}
	If RegExMatch(ThisMenuItem,"i)\\\\Control Panel$")
	{
		Postmessage 1075, 2123, 0,, ahk_class TTOTAL_CMD
		Return
	}
	If RegExMatch(ThisMenuItem,"i)\\\\Fonts$")
	{
		Postmessage 1075, 2124, 0,, ahk_class TTOTAL_CMD
		Return
	}
	If RegExMatch(ThisMenuItem,"i)\\\\Network$")
	{
		Postmessage 1075, 2125, 0,, ahk_class TTOTAL_CMD
		Return
	}
	If RegExMatch(ThisMenuItem,"i)\\\\Devices and Printers\$")
	{
		Postmessage 1075, 2126, 0,, ahk_class TTOTAL_CMD
		Return
	}
	If RegExMatch(ThisMenuItem,"i)\\\\Recycle bin$")
	{
		Postmessage 1075, 2127, 0,, ahk_class TTOTAL_CMD
		Return
	}
    If RegExMatch(ThisMenuItem,"i)\\\\Recycle$")
	{
		Postmessage 1075, 2127, 0,, ahk_class TTOTAL_CMD
		Return
	}

    Global ExecuteInHeader
    If ExecuteInHeader
    {
        TCEditHeader := "Edit2"
        if TCBit = 32
             TCEditHeader := "TInEdit1"
        ; execute mark in the panel header, the tabstop above the file list
        ;PostMessage 1075, 2912, 0,, AHK_CLASS TTOTAL_CMD
        Execute(2912)  ; 2912 is like <EditPath> it opens the tabstop above the file list
        ;return
        ;SendPos(2912)  ;<EditPath> this opens the tabstop above the file list
        ;<EditPath>
        ;return
        Sleep 100
        ;Sleep 800

;loop 3
;{
;        ;-- if for some unknown me reasons the command line opens instead of the header then try to open the header again
;        ;Msgbox  Debugging TCEditHeader = [%TCEditHeader%]  on line %A_LineNumber% ;!!!
;        ControlGetFocus,ThisControl,AHK_CLASS TTOTAL_CMD
;        If ( %ThisControl% = TCEditHeader )
;             break
;        ;If (( %ThisControl% = Edit1 ) or ( %ThisControl% = Edit2 ))
;        If ( %ThisControl% = Edit1 )
;        {
;            tooltip Oups`, the command line opened instead of the header. ThisMenuItem = [%ThisMenuItem%]
;            ControlSend, %ThisControl%, {Esc}, ahk_class TTOTAL_CMD
;            ;Send {Esc}
;            Sleep 100
;            SendPos(2912)  ;<EditPath> this opens the tabstop above the file list
;            Sleep 100
;        }
;}

        ; the header should be open by now

        ControlSetText, %TCEditHeader%, %ThisMenuItem%, ahk_class TTOTAL_CMD
        Sleep 90
        ControlSend, %TCEditHeader%, {Enter}, ahk_class TTOTAL_CMD

  ;      ;make sure it was executed
  ;      ControlGetFocus,ThisControl,AHK_CLASS TTOTAL_CMD
  ;      If ( %ThisControl% = TCEditHeader )
  ;          ControlSend, %TCEditHeader%, {Enter}, ahk_class TTOTAL_CMD
  ;      ;Msgbox  Debugging ThisMenuItem = [%ThisMenuItem%]  on line %A_LineNumber% ;!!!

    }
    else
    {
        ; execute mark in the command line
        ControlSetText, %TCEdit%, cd %ThisMenuItem%, ahk_class TTOTAL_CMD
        ControlSend, %TCEdit%, {Enter}, ahk_class TTOTAL_CMD
    }

	Return
}
<ListMark>:
If SendPos(0)
	;ListMark()
	;ListMarkFromMemory()
    ListAllMarksFromIni()
Return
;ListMark()
/*
ListMarkFromMemory()
{
	Global Mark_Arr,VIATCINI
    If Not Mark_Arr["active_marks"]
    {
        Tooltip No marks to show
        Settimer,<RemoveHelpTip>,950
        Return
    }
	ControlGetFocus,TLB,ahk_class TTOTAL_CMD
	ControlGetPos,xn,yn,,,%TLB%,ahk_class TTOTAL_CMD
    ;InfoMark := "Mark will be gone after reload`n" 
    ;MarkMenu = InfoMark . MarkMenu
	Menu,MarkMenu,Show,%xn%,%yn%
	;Menu,%InfoMark%.%MarkMenu%,Show,%xn%,%yn%
} 

ListActiveMarkFromIni()
{

    Menu,MarkMenu,Add,-----,<AddMark>
    Menu,MarkMenu,DeleteAll
    Tooltiplm :=
    IniRead,active_marks,%MarksPath%,MarkSettings,active_marks
    ; active_marks is a string containing a comma separated list of marks
    if active_marks =
    {
        Tooltip No marks to show. The active_marks variable in the marks.ini file is empty
        Settimer,<RemoveHelpTip>,2000
        Return
    }
    if active_marks = ERROR
    {
        Tooltip No marks to show. The active_marks variable was not found in the marks.ini file
        Settimer,<RemoveHelpTip>,2000
        Return
    }
    h := 0
    ;Loop, Parse, InputVar , Delimiters           , [OmitChars]
    loop, Parse , active_marks , `,
    {
        if A_LoopField =
            continue
        h++
        Iniread,Path,%MarksPath%,MarkList,%A_LoopField%
        if Path != ERROR
        {
            mPath := "&" . A_LoopField . ">>" . Path
            Menu,MarkMenu,Add,%mPath%,<AddMark>
        }
    }	

    IniRead,menu_color,%MarksPath%,MarkSettings,menu_color
    if menu_color != ERROR
        Menu, MarkMenu, Color, %menu_color%
    Controlgetpos,xe,ye,we,he,%TCEdit%,ahk_class TTOTAL_CMD
    ControlGetFocus,TLB,ahk_class TTOTAL_CMD
    ControlGetPos,xn,yn,,,%TLB%,ahk_class TTOTAL_CMD
    if h = 0
    {
        Tooltip No marks to show. Nothing was on the active_marks list
        Settimer,<RemoveHelpTip>,2000
        ;Return
    }
    else
        Menu,MarkMenu,Show,%xn%,%yn%
        ;Menu,MarkMenu,Show,xe,ye-h*16-5
    return
}
*/

ListAllMarksFromIni()
{
    Menu,MarkMenu,Add,-----,<AddMark>
    Menu,MarkMenu,DeleteAll
    Tooltiplm :=
    Iniread,all_marks,%MarksPath%,MarkList
    h := 0
    ;Loop, Parse, InputVar , Delimiters           , [OmitChars]
    loop, Parse ,all_marks ,`n
    {
        ;if A_LoopField =
            ;continue
        ;MsgBox %A_LoopField%
        ;Menu,MarkMenu,Add,%A_LoopField%,<AddMark>        ; the "C:\" is lost in marks
        h++
        m := SubStr(A_LoopField,1,1)
        ;MsgBox %m%
        Iniread,Path,%MarksPath%,MarkList,%m%
        if Path and (Path != ERROR)
        {
            mPath := "&" . m . ">>" . Path
            Menu,MarkMenu,Add,%mPath%,<AddMark>
        }
    }	

    IniRead,menu_color,%MarksPath%,MarkSettings,menu_color
    if menu_color != ERROR
        Menu, MarkMenu, Color, %menu_color%
    Controlgetpos,xe,ye,we,he,%TCEdit%,ahk_class TTOTAL_CMD
    ControlGetFocus,TLB,ahk_class TTOTAL_CMD
    ControlGetPos,xn,yn,,,%TLB%,ahk_class TTOTAL_CMD
    if h = 0
    {
        Tooltip No marks to show. Nothing was on the active_marks list
        Settimer,<RemoveHelpTip>,2000
        ;Return
    }
    else
        Menu,MarkMenu,Show,%xn%,%yn%
        ;Menu,MarkMenu,Show,xe,ye-h*16-5
    return
}
; ----- end of marks ----- }}}2


<azCmdHistory>:
	azCmdHistory()
Return
azCmdHistory()
{
    Global TCINI
    Menu,SH,add
    Menu,SH,deleteall
    info := "Commands from previously saved TC session. Reload TC for current history."
    Menu,SH,add,%info%,azSelectCmdHistory
    Menu,SH,Disable,%info%
    n := 0
    TempField :=
    item :=
    Loop
    {
        IniRead,TempField,%TCINI%,Command line history,%n%
        If TempField = ERROR
            Break
        n++
        item := chr(A_Index+64) . ">>" . TempField 
        Menu,SH,add,%item%,azSelectCmdHistory
    }
    ;Send {Esc}
    ControlGetFocus,TLB,ahk_class TTOTAL_CMD
    ControlGetPos,xn,yn,,,%TLB%,ahk_class TTOTAL_CMD
    Menu,SH,show,%xn%,%yn%
}

azSelectCmdHistory:
azSelectCmdHistory()
Return
azSelectCmdHistory()
{
	nPos := A_ThisMenuItem
	nPos := Asc(Substr(nPos,1,1)) - 64 -1
    Global TCINI
    IniRead,cmd,%TCINI%,Command line history,%nPos%
    Send {left}         ;get into command line
    sleep 50
    delay := A_KeyDelay
    SetKeyDelay, -1   ;no delay 
    SendInput {Raw} %cmd%
    ;SendRaw %cmd%
    SetKeyDelay, %delay%
    Send {enter}

    ; if {enter} was missed then try again
    sleep 400
    ControlGetFocus,ThisControl,AHK_CLASS TTOTAL_CMD
    If ThisControl = %TCEdit%  ;Edit1
    {
        Send {enter}
        ;tooltip enter was doubled
    }
}


<azHistory>:
If SendPos(572)
	azhistory()
Return
azhistory()
{
	Sleep, 100
	if WinExist("ahk_class #32768")
	{
		SendMessage,0x01E1
		hmenu := ErrorLevel
		if hmenu!=0
		{
			If Not RegExMatch(GetMenuString(Hmenu,1),".*[\\|/]$")
				Return
			Menu,sh,add
			Menu,sh,deleteall
			a :=
			itemCount := DllCall("GetMenuItemCount", "Uint", hMenu, "Uint")
			Loop %itemCount%
			{
				a := chr(A_Index+64) . ">>" .  GetMenuString(Hmenu,A_Index-1)
				Menu,SH,add,%a%,azSelect
			}
			Send {Esc}
			ControlGetFocus,TLB,ahk_class TTOTAL_CMD
			ControlGetPos,xn,yn,,,%TLB%,ahk_class TTOTAL_CMD
			Menu,SH,show,%xn%,%yn%
			Return
		}
	}
}
GetMenuString(hMenu, nPos)
{
	VarSetCapacity(lpString, 256)
	length := DllCall("GetMenuString"
, "UInt", hMenu
, "UInt", nPos
, "Str", lpString
, "Int", 255
, "UInt", 0x0400)
	return lpString
}


azSelect:
azSelect()
Return
azSelect()
{
	nPos := A_ThisMenuItem
	nPos := Asc(Substr(nPos,1,1)) - 64
	Winactivate,ahk_class TTOTAL_CMD
	Postmessage,1075,572,0,,ahk_class TTOTAL_CMD
	Sleep,100
	if WinExist("ahk_class #32768")
	{
		Loop %nPos%
			SendInput {Down}
		Send {enter}
	}
}
<Internetsearch>:
If SendPos(0)
	Internetsearch()
Return
Internetsearch()
{
	Global SearchEng
	If CheckMode()
	{
		ClipSaved := ClipboardAll
		Clipboard =
		PostMessage 1075, 2017, 0,, ahk_class TTOTAL_CMD
		ClipWait
		rFileName := clipboard
		clipboard := ClipSaved
		StringRight,lastchar,rFileName,1
		If(lastchar = "\" )
			Stringleft,rFileName,rFileName,Strlen(rFileName)-1
		rFileName := RegExReplace(SearchEng,"{%1}",rFileName)
		Run %rFileName%
	}
	Return
}
<GoDesktop>:
If SendPos(0)
{
	ControlSetText,%TCEdit%,CD %A_Desktop%,AHK_CLASS TTOTAL_CMD
	ControlSend,%TCEdit%,{Enter},AHK_CLASS TTOTAL_CMD
}
Return
<GotoParentEx>:
If CheckMode()
	IsRootDir()
SendPos(2002,True)
Return
IsRootDir()
{
	ClipSaved := ClipboardAll
	clipboard :=
	PostMessage,1075,2029,0,,AHK_CLASS TTOTAL_CMD
	ClipWait,1
	Path := Clipboard
	Clipboard := ClipSaved
	If RegExMatch(Path,"^.:\\$")
	{
		PostMessage,1075,2122,0,,AHK_CLASS TTOTAL_CMD
		Path := "i)" . RegExReplace(Path,"\\","")
		ControlGetFocus,focus_control,AHK_CLASS TTOTAL_CMD
		ControlGet,outvar,list,,%focus_control%,AHK_CLASS TTOTAL_CMD
		Loop,Parse,Outvar,`n
		{
			If Not A_LoopField
				Break
			If RegExMatch(A_LoopField,Path)
			{
				Focus := A_Index - 1
				Break
			}
		}
		PostMessage, 0x19E, %Focus%, 1, %focus_control%, AHK_CLASS TTOTAL_CMD
	}
}
<SingleRepeat>:
If SendPos(-1)
	SingleRepeat()
Return
<TCFullScreenAlmost>:
<TCLite>:
If SendPos(0)
{
	ToggleMenu()
	HideControl()
	GoSub,<VisDirTabs>
	Send,{Esc}
}
Return

<TCFullScreenWithExePlugin>:
If SendPos(0)
{
    ; an external exe program is required
    program = %A_ScriptDir%\TcFullScreen.exe
    if FileExist(program)
        Run %program% 
    else
    {
        link = https://magicstep.github.io/viatc/TcFullScreen/
        MsgBox, 4, , %program% is required. You can download it from %link% `nOpen link?
        IfMsgBox Yes
            Run %link% 
    }
}
Return

<TCFullScreen>:
If SendPos(0)
{
	ToggleMenu()
	HideControl()
	GoSub,<VisDirTabs>
	If HideControl_arr["Max"]
	{
		PostMessage 1075, 2016, 0,, ahk_class TTOTAL_CMD
		HideControl_arr["Max"] := 0
		Return
	}
	WinGet,AC,MinMax,AHK_CLASS TTOTAL_CMD
	If AC = 1
	{
		PostMessage 1075, 2016, 0,, ahk_class TTOTAL_CMD
		PostMessage 1075, 2015, 0,, ahk_class TTOTAL_CMD
		HideControl_arr["Max"] := 0
	}
	If AC = 0
	{
		PostMessage 1075, 2015, 0,, ahk_class TTOTAL_CMD
		HideControl_arr["Max"] := 1
	}
}
Return
<CreateNewFile>:
If SendPos(0)
	CreateNewFile()
Return

<GOLastTab>:
if SendPos(0)
{
	PostMessage 1075, 5001, 0,, ahk_class TTOTAL_CMD
	PostMessage 1075, 3006, 0,, ahk_class TTOTAL_CMD
}
Return
<DeleteLHistory>:
If SendPos(0)
	DeleteHistory(1)
Return
<DeleteRHistory>:
If SendPos(0)
	DeleteHistory(0)
Return
DeleteHistory(A)
{
	Global TCEXE,TCINI
	If A
	{
		H := "LeftHistory"
		DelMsg := " Delete the left folder history ?  TC will be terminated and reloaded"
	}
	Else
	{
		H := "RightHistory"
    DelMsg := " Delete the right folder history ? TC will be terminated and reloaded"
	}
	MsgBox,4,ViATC,%DelMsg%
	IfMsgBox YES
	{
		Winkill,AHK_CLASS TTOTAL_CMD
		n := 0
		Loop
		{
			IniRead,TempField,%TCINI%,%H%,%n%
			If TempField = ERROR
				Break
			IniDelete,%TCINI%,%H%,%n%
			n++
		}
		Run,%TCEXE%,,UseErrorLevel
		If ErrorLevel = ERROR
            TcExe := FindPath("exe")
			;TCEXE := findpath(1)
		WinWait,AHK_CLASS TTOTAL_CMD,3
		Winactivate,AHK_CLASS TTOTAL_CMD
	}
	Else
		Winactivate,AHK_CLASS TTOTAL_CMD
}
<DelCmdHistory>:
If SendPos(0)
	DeleteCmd()
Return
DeleteCMD()
{
	Global TCEXE,TCINI,CmdHistory
	CmdHistory := Object()
	MsgBox,4,ViATc, Delete command line history ?
	IfMsgBox YES
	{
		Winkill ahk_class TTOTAL_CMD
		n := 0
		TempField :=
		Loop
		{
			IniRead,TempField,%TCINI%,Command line history,%n%
			If TempField = ERROR
				Break
			IniDelete,%TCINI%,Command line history,%n%
			n++
		}
		Run,%TCEXE%,,UseErrorLevel
		If ErrorLevel = ERROR
            TcExe := FindPath("exe")
			;TCEXE := findpath(1)
		WinWait,AHK_CLASS TTOTAL_CMD,3
		Winactivate,AHK_CLASS TTOTAL_CMD
	}
	Else
		Winactivate ahk_class TTOTAL_CMD
}

<ListMapKey>:
If SendPos(0)
	ListMapKey()
Return
<ListMapKeyMultiColumn>:
If SendPos(0)
	ListMapKeyMultiColumn()
Return
ListMapKeyMultiColumn()  
{
	Global MapKey_Arr,CommandInfo_Arr,ExecFile_Arr,SendText_Arr
	Map := MapKey_Arr["Hotkeys"]
	Stringsplit,ListMap,Map,%A_Space%
    Global ColumnCount := 3
    ItemCount := 0
	Loop,% ListMap0
	{
		If ListMap%A_Index%
		{
			Action := MapKey_Arr[ListMap%A_Index%]
			If Action = <Exec>
			{
				EX := SubStr(ListMap%A_Index%,1,1) . TransHotkey(SubStr(ListMap%A_Index%,2))
				Action := "(" . ExecFile_Arr[EX] . ")"
			}
			If Action = <Text>
			{
				TX := SubStr(ListMap%A_Index%,1,1) . TransHotkey(SubStr(ListMap%A_Index%,2))
				Action := "{" . SendText_Arr[TX] . "}"
			}
            line := SubStr(ListMap%A_Index%,1,1) . "  " . SubStr(ListMap%A_Index%,2) . "  " . Action
            loop 10*ColumnCount
            {
                if StrLen(line) < 20*ColumnCount
                    line .= " "
                else
                    break
            }
            loop 4
            {
                if StrLen(line) < 25*ColumnCount
                    line .= "`t"
                    ;line .= " " ;"`t"
                else
                    break
            }


			;LM .= %line%
			LM .= line
			;LM .= SubStr(ListMap%A_Index%,1,1) . "  " . SubStr(ListMap%A_Index%,2) . "  " . Action  . "`t`t"
            ItemCount ++
            if Mod(ItemCount, ColumnCount) = 0
                LM .= "`n"
		}
	}
	ControlGetPos,xn,yn,,hn,%TCEdit%,AHK_CLASS TTOTAL_CMD
	yn := yn - hn - ( ListMap0 * 8 ) - 2
	Tooltip,%LM%,%xn%,%yn%
	Settimer,<RemoveToolTipEx>,100
}

;ListMapKeySingleColumn()
ListMapKey()
{
	Global MapKey_Arr,CommandInfo_Arr,ExecFile_Arr,SendText_Arr
	Map := MapKey_Arr["Hotkeys"]
    InfoLine := "ini file mappings only, built-in not listed`nG=Global   H=Hotkey   C=ComboKey`n"
	Stringsplit,ListMap,Map,%A_Space%
	Loop,% ListMap0
	{
		If ListMap%A_Index%
		{
			Action := MapKey_Arr[ListMap%A_Index%]
			If Action = <Exec>
			{
				EX := SubStr(ListMap%A_Index%,1,1) . TransHotkey(SubStr(ListMap%A_Index%,2))
				Action := "(" . ExecFile_Arr[EX] . ")"
			}
			If Action = <Text>
			{
				TX := SubStr(ListMap%A_Index%,1,1) . TransHotkey(SubStr(ListMap%A_Index%,2))
				Action := "{" . SendText_Arr[TX] . "}"
			}
			;LM .= SubStr(ListMap%A_Index%,1,1) . "   " . SubStr(ListMap%A_Index%,2) . " `t" . Action  . "`n"
			LM .= SubStr(ListMap%A_Index%,1,1) . "   " . SubStr(ListMap%A_Index%,2) . "   " . Action  . "`n"
		}
	}

    LM = %InfoLine%%LM%
    MsgBox  %LM%
    ;; show tooltip
	;ControlGetPos,xn,yn,,hn,%TCEdit%,AHK_CLASS TTOTAL_CMD
	;yn := yn - hn - ( ListMap0 * 8 ) - 2
	;Tooltip,%LM%,%xn%,%yn%
	;Settimer,<RemoveToolTipEx>,100
}

<FocusCmdLineEx>:
If SendPos(4003)
{
	ControlSetText,%TCEdit%,:,AHK_CLASS TTOTAL_CMD
	ControlSetText,Edit1,:,AHK_CLASS TTOTAL_CMD
	ControlSetText,Edit2,:,AHK_CLASS TTOTAL_CMD
	Send,{end}
}
Return

<WinMaxLeft>:
If SendPos(0)
	WinMaxLeft()
Return
WinMaxLeft()
{
	ControlGetPos,x,y,w,h,%TCPanel2%,ahk_class TTOTAL_CMD
	ControlGetPos,tm1x,tm1y,tm1W,tm1H,%TCPanel1%,ahk_class TTOTAL_CMD
	If (tm1w < tm1h) ; Is it vertical or horizontal  True for vertical  False for horizontal
	{
        ; vertical  (so Left and Right)
        ;MsgBox P1 tm1x,tm1y=%tm1x%,%tm1y%    tm1W,tm1H=%tm1W%,%tm1H%    `nP2 x,y=%x%,%y%   w,h=%w%,%h%
        ; it seems that numbers for both and especially Panel2 are incorrect
        ; original line below, perhaps it should be tm1x+w but is doesn't work either
		;ControlMove,%TCPanel1%,x+w,,,,ahk_class TTOTAL_CMD
        ; 2000 is just a big numer to make Panel1 wide, pushing panel2 out of screen
        ControlMove,%TCPanel1%,2000,,,,ahk_class TTOTAL_CMD
        ; another way to fix it would be set both panels to 50% and then double the first panel
        ;SendPos(909) ;<cm_50Percent>
	}
	else    ;horizontal (so Upper and Lower)
        ; original line below but doesn't work as numbers for Panel2 are incorrect
		;ControlMove,%TCPanel1%,0,y+h,,,ahk_class TTOTAL_CMD
        ; 2000 is just a big numer to make Panel1 tall, pushing panel2 out of screen
		ControlMove,%TCPanel1%,0,2000,,,ahk_class TTOTAL_CMD
        ; another way to fix it would be set both panels to 50% and then double the first panel
	ControlClick, %TCPanel1%,ahk_class TTOTAL_CMD
	WinActivate ahk_class TTOTAL_CMD
}
<WinMaxRight>:
If SendPos(0)
{
	ControlMove,%TCPanel1%,0,53,,,ahk_class TTOTAL_CMD
	ControlClick,%TCPanel1%,ahk_class TTOTAL_CMD
	WinActivate ahk_class TTOTAL_CMD
}
Return
<AlwayOnTop>:
If SendPos(0)
	AlwayOnTop()
Return
AlwayOnTop()
{
	WinGet,ExStyle,ExStyle,ahk_class TTOTAL_CMD
	If (ExStyle & 0x8)
		WinSet,AlwaysOnTop,off,ahk_class TTOTAL_CMD
	else
		WinSet,AlwaysOnTop,on,ahk_class TTOTAL_CMD
}
<Transparent>:
If SendPos(0)
	Transparent()
Return
Transparent()
{
	Global VIATCINI,Transparent,TranspVar
	IniRead,Transparent,%VIATCINI%,Configuration,Transparent
	If Transparent
	{
		WinSet,Transparent,255,ahk_class TTOTAL_CMD
		IniWrite,0,%VIATCINI%,Configuration,Transparent
		Transparent := 0
	}
	Else
	{
		WinSet,Transparent,%TranspVar%,ahk_class TTOTAL_CMD
		IniWrite,1,%VIATCINI%,Configuration,Transparent
		Transparent := 1
	}
}
<ReLoadTC>:
If SendPos(0)
{
	ToggleMenu(1)
	If HideControl_arr["Toggle"]
		HideControl()
	WinKill,AHK_CLASS TTOTAL_CMD
	Loop,100
	{
		IfWinNotExist,AHK_CLASS TTOTAL_CMD
		Break
	}
	GoSub,<ToggleTC>
}
Return
<QuitTc>:
WinClose,AHK_CLASS TTOTAL_CMD
return
<Half>:
If SendPos(0)
	Half()
Return

; this function didn't work, always returned 0, now dirty fixed, but not fully 
Half()
{
	winget,tid,id,ahk_class TTOTAL_CMD
	controlgetfocus,ctrl,ahk_id %tid%
	controlget,cid,hwnd,,%ctrl%,ahk_id %tid%
	controlgetpos,x1,y1,w1,h1,THeaderClick2,ahk_id %tid%  ;not setting any variables
	controlgetpos,x,y,w,h,%ctrl%,ahk_id %tid%   ;seems good
	SendMessage,0x01A1,1,0,,ahk_id %cid%
	Height := ErrorLevel
	SendMessage,0x018E,0,0,,ahk_id %cid%
	Top := ErrorLevel
    h1 := 0 ;this line was needed as h1 was not set
    HalfLine := Ceil( ((h-h1)/Height)/2 ) + Top
    ;Recalculate again, a bit innacurate, it's a quick dirty fix
    ;HalfLine := Ceil( Height/2 ) + Top - 1   
    ;debug info in the line below !!!
    ;MsgBox, h=%h% h1=%h1% Top=%Top% HalfLine=%HalfLine%   Height=%Height%  x1=%x1% y1=%y1% w1=%w1% x=%x% y=%y% w=%w%
	PostMessage, 0x19E, %HalfLine%, 1,, AHK_id %cid%
}

<azTab>:
If SendPos(0)
	azTab()
Return
azTab()
{
	Global TabsBreak,TcExe
	If RegExMatch(TcExe,"i)totalcmd64\.exe")
    {
       MsgBox This doesn't work with totalcmd64, 64bit not supported. 
	   Return 
    }
	TCid := WinExist("AHK_CLASS TTOTAL_CMD")
    ;MsgBox  Debugging TCid = [%TCid%]  on line %A_LineNumber% ;!!!
	WinClose,ViATc_TabList
	ControlGetPos,xe,ye,we,he,Edit1,AHK_CLASS TTOTAL_CMD
	Gui,New
	Gui,+HwndTabsHwnd -Caption  +Owner%TCid%
	Gui,Add,ListBox,x2 y2 w%we% gSetTab
	Index := 1
    try  ; Attempts to execute code.
    {
        tabs = ControlGetTabs("TMyTabControl1","AHK_CLASS TTOTAL_CMD")
    }
      catch e  ; Handles the first error/exception raised by the block above.
      {
          MsgBox, An exception was thrown!`nSpecifically: %e%
      }

    ; !!! the ControlGetTabs is causing a nasty error on first use
	for i,tab in ControlGetTabs("TMyTabControl1","AHK_CLASS TTOTAL_CMD")
	{
		vTab := Chr(Index+64) . ":" . Tab
		STabs[vTab] := "L" . A_index
		If A_Index = 1
		{
			ControlGet,TMyT2,hwnd,,TMyTabControl2,AHK_CLASS TTOTAL_CMD
			If TMyT2
				GuiControl,,ListBox1,===== left ===================
			Else
			{
				ControlGetPos,x1,y1,,,TPanel1,AHK_CLASS TTOTAL_CMD
				ControlGetPos,x2,y2,,,TMyTabControl1,AHK_CLASS TTOTAL_CMD
				If ( x2 < x1 ) OR ( y2 < y1 )
					GuiControl,,ListBox1,===== left ===================
				Else
					GuiControl,,ListBox1,===== right ===================
			}
		}
		GuiControl,,ListBox1,%vTab%
		Index++
	}
	TabsBreak := Index
	for i,tab in ControlGetTabs("TMyTabControl2","AHK_CLASS TTOTAL_CMD")
	{
		vTab := Chr(Index+64) . ":" . Tab
		STabs[vTab] := "R" . A_index
		If A_index = 1
		{
			GuiControl,,ListBox1,===== right ===================
		}
		GuiControl,,ListBox1,%vTab%
		Index++
	}
	h := (Index+1)*13
	GuiControl,Move,ListBox1,h%h%
	WinGetPos,wx,wy,ww,wh,AHK_CLASS TTOTAL_CMD
	x := xe + wx - 1
	w := we +  4
	h := h + 4
	y := ye - h + wy
	GUiControl,Focus,ListBox2
	Gui,Show,h%h% w%w% x%x% y%y%,ViATc_TabList
	Postmessage,0xB1,7,7,%TCEdit%,AHK_CLASS TTOTAL_CMD
}

SetTab:
ControlGet,var,Choice,,Listbox1
Pos := SubStr(var,1,1)
If Not RegExMatch(Pos,"=")
{
	Pos := Asc(Pos) - 65
	TabsBreak--
	If ( Pos < TabsBreak )
	{
		PostMessage,0x1330,%Pos%,0,TMyTabControl1,AHK_CLASS TTOTAL_CMD
		If Not LeftRight()
			PostMessage,1075,4001,0,,AHK_CLASS TTOTAL_CMD
	}
	TabsBreak--
	If ( Pos > TabsBreak )
	{
		Pos := Pos - TabsBreak - 1
		PostMessage,0x1330,%Pos%,0,TMyTabControl2,AHK_CLASS TTOTAL_CMD
		If Not LeftRight()
			PostMessage,1075,4002,0,,AHK_CLASS TTOTAL_CMD
	}
	WinClose,AHK_ID %TabsHwnd%
	Return
}
return

LeftRight()
{
	ControlGetPos,x1,y1,,,TPanel1,AHK_CLASS TTOTAL_CMD
	ControlGetFocus,TLB,AHK_CLASS TTOTAL_CMD
	ControlGetPos,x2,y2,,,%TLB%,AHK_CLASS TTOTAL_CMD
	If ( x2 < x1 ) OR ( y2 < y1 )
		Return True
	Else
		Return False
}
ControlGetTabs(Control, WinTitle="", WinText="")
{
	static TCM_GETITEMCOUNT := 0x1304
, TCM_GETITEM := A_IsUnicode ? 0x133C : 0x1305
, TCIF_TEXT := 1
, TCITEM_SIZE := 16 + A_PtrSize*3
, MAX_TEXT_LENGTH := 260
, MAX_TEXT_SIZE := MAX_TEXT_LENGTH * (A_IsUnicode ? 2 : 1)
	static PROCESS_VM_OPERATION := 0x8
, PROCESS_VM_READ := 0x10
, PROCESS_VM_WRITE := 0x20
, READ_WRITE_ACCESS := PROCESS_VM_READ |PROCESS_VM_WRITE |PROCESS_VM_OPERATION
, MEM_COMMIT := 0x1000
, MEM_RELEASE := 0x8000
, PAGE_READWRITE := 4
	if Control is not integer
	{
		ControlGet Control, Hwnd,, %Control%, %WinTitle%, %WinText%
		if ErrorLevel
			return
	}
	WinGet pid, PID, ahk_id %Control%
	hproc := DllCall("OpenProcess", "uint", READ_WRITE_ACCESS
, "int", false, "uint", pid, "ptr")
	if !hproc
		return
	remote_item := DllCall("VirtualAllocEx", "ptr", hproc, "ptr", 0
, "uptr", TCITEM_SIZE + MAX_TEXT_SIZE
, "uint", MEM_COMMIT, "uint", PAGE_READWRITE, "ptr")
	remote_text := remote_item + TCITEM_SIZE
	VarSetCapacity(local_item, TCITEM_SIZE, 0)
	NumPut(TCIF_TEXT,      local_item, 0, "uint")
	NumPut(remote_text,    local_item, 8 + A_PtrSize)
	NumPut(MAX_TEXT_LENGTH, local_item, 8 + A_PtrSize*2, "int")
	VarSetCapacity(local_text, MAX_TEXT_SIZE)
	DllCall("WriteProcessMemory", "ptr", hproc, "ptr", remote_item
, "ptr", &local_item, "uptr", TCITEM_SIZE, "ptr", 0)
	tabs := []
	SendMessage TCM_GETITEMCOUNT,,,, ahk_id %Control%
	Loop % (ErrorLevel != "FAIL") ? ErrorLevel : 0
	{
		SendMessage TCM_GETITEM, A_Index-1, remote_item,, ahk_id %Control%
		if (ErrorLevel = 1)
			DllCall("ReadProcessMemory", "ptr", hproc, "ptr", remote_text
, "ptr", &local_text, "uptr", MAX_TEXT_SIZE, "ptr", 0)
		else
			local_text := ""
		tabs[A_Index] := local_text
	}
	DllCall("VirtualFreeEx", "ptr", hproc, "ptr", remote_item
, "uptr", 0, "uint", MEM_RELEASE)
	DllCall("CloseHandle", "ptr", hproc)
	return tabs
}

; ----- fancy rename {{{1
<FancyR>:
If SendPos(0)
	FancyRCreateGui()
Return
FancyRCreateGui()
{
	Static WM_CHAR := 0x102
	Global GetName :=
    Global UseSystemClipboard
	WinClose,AHK_ID %FancyR_ID%
	PostMessage 1075, 1007, 0,, ahk_class TTOTAL_CMD
    ;loop 8 times to wait till the little rename line opens, so we can copy content
	Loop,8
	{
		ControlGetFocus,ThisControl,AHK_CLASS TTOTAL_CMD
        ;If ThisControl = Edit1
        If ThisControl = %TCEditRename%
		{
			;ControlGetText,GetName,TInEdit1,AHK_CLASS TTOTAL_CMD
			ControlGetText,GetName,%ThisControl%,AHK_CLASS TTOTAL_CMD
			Break
		}
		Sleep,50
	}
        ;MsgBox  ThisControl %ThisControl% ;!!!
        ;MsgBox  GetName %GetName% ;!!!
    ;  ".." gives empty GetName
	If Not GetName
        Return

	If GetName == ".."
    {
       ;MsgBox Sorry cannot rename ..
       Return
    }

    IniRead,HistoryOfRename,%ViatcIni%,Configuration,HistoryOfRename
    If HistoryOfRename
    {
        ; save to file the original filename for possible undo rename, 
        file := FileOpen(HistoryOfRenamePath ,"a")
        file.write("`n" . GetName)
        file.close()
    }

	StringRight,GetDir,GetName,1
	If GetDir = \
	{
		StringLeft,GetName,GetName,Strlen(GetName)-1
		GetDir := True
	}
	Else
		GetDir := False


	WinGet,TCID,ID,AHK_CLASS TTOTAL_CMD
	Gui,New
	Gui,+HwndFancyR_ID
	Gui,+Owner%TCID%
	Gui,Menu,FancyR_MENU

    Gui,Font,s12,Arial  ;font for the rename window
	Gui,Add,Edit,r3 x9 y103  w820 -WantReturn gFancyR_Edit,%GetName%
	;Gui,Add,Edit,r1 w800 -WantReturn gFancyR_Edit,%GetName%  ;original
    Gui,Font,s9
    If HistoryOfRename
        Gui, Add, Text, x9 y10 w800 h23, Original filename saved to the "history_of_rename.txt"  
    else
        Gui, Add, Text, x9 y10 w800 h23, Original filename     not saving "history_of_rename.txt"  
    Gui, Add, Button, x310 y6 w70 h21 gFancyR_history,  &Browse it
    Gui,Font,s12
    Gui, Add, Edit, x9 y30 w820 r3 ReadOnly, %GetName%  ;original 


    Gui,Font,s18
	Gui,Add,StatusBar
	;Gui,Add,Button,Default Hidden gFancyR_Enter
    Gui,Font,s9,Arial  ;font for the rename window
    Gui, Add, Button, x515 y4 w140 h22 gCancel, &Cancel ; = q
    Gui, Add, Button, x690 y4 w140 h22 Default gFancyR_Enter, &OK ;= Enter
	;Gui,Show,h400,ViATc Fancy Rename
	Gui,Show,,ViATc Fancy Rename
    PostMessage,0x00C5,255,,%ThisControl%,AHK_ID %FancyR_ID%  ;LIMITTEXT to 255
    ;PostMessage,0x00C5,256,,%ThisControl%,AHK_ID %FancyR_ID%  ;LIMITTEXT to 256

	FancyR_Insert := GetConfig("FancyVimRename","InsertMode")
	If FancyR_Insert
    {
		Menu,FancyR_DefaultsMenu,Check, Insert mode at start `tAlt+I
		Status := "  mode : Insert                                 "
        FancyR := false
       	FancyR_Vis := false
    }
    Else
	{
		Menu,FancyR_DefaultsMenu,Uncheck, Insert mode at start `tAlt+I
		;Status := "  mode : Vim Normal                             "
        Status := "  mode : Visual                                 "
       	FancyR_Vis := true
        FancyR := true    ; normal mode commands will work too
	}
	ControlSetText,msctls_statusbar321,%status%,AHK_ID %FancyR_ID%
	If GetConfig("FancyVimRename","UnselectExt")
	{
		SplitPath,GetName,,,Ext
        If FancyR_Insert
            Menu,FancyR_DefaultsMenu,Check, Insert mode at start `tAlt+I
        else
            Menu,FancyR_DefaultsMenu,Uncheck, Insert mode at start `tAlt+I
        Menu,FancyR_DefaultsMenu,Check, Extension unselected at start `tAlt+E
	}
	If Ext And ( Not GetDir )
	{
		StartPos := 0
		EndPos := StrLen(GetName) - strlen(Ext) - 1
		FancyR_DefaultsMenuPos(StartPos,EndPos)
	}

	FancyR_History["s"] := 0
    FancyR_IsReplace := False
    FancyR_IsMultiReplace := False
    FancyR_Count := 0

	;FancyR_History[0] := StartPos . "," . EndPos . "," . GetName
	FancyR_History[0] := StartPos . "|" . EndPos . "|" . GetName
	FancyR_History["String"] := GetName
	OnMessage(WM_CHAR,"GetFindText")
}
GetFindText(byRef w, byRef l)
{
	If FancyR_IsFind
	{
		ThisChar := Chr(w)
		ControlGetText,Text,Edit1,AHK_ID %FancyR_ID%
		GetPos := FancyR_GetPos()
		StartPos := GetPos[2] + 1
		Pos := RegExMatch(Text,RegExReplace(ThisChar,"\+|\?|\.|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0"),"",StartPos)
		FancyR_DefaultsMenuPos(Pos-1,Pos)
		FancyR_IsFind := False
		FancyR := True
		Return 0
	}
}
FancyR_Num:
FancyR_SendNum()
Return
FancyR_Down:
Key := FancyR_Vis ? "+{Down}" : "{Down}"
FancyR_SendKey(key)
Return
FancyR_Up:
Key := FancyR_Vis ? "+{Up}" : "{Up}"
FancyR_SendKey(key)
Return
FancyR_Left:
Key := FancyR_Vis ? "+{Left}" : "{Left}"
FancyR_SendKey(key)
Return
FancyR_Word:
Key := FancyR_Vis ? "^+{Right}" : "^{Right}"
FancyR_SendKey(key)
Return
FancyR_WordEnd:
Key := FancyR_Vis ? "^+{Right}+{Left}" : "^{Right}{Left}"
FancyR_SendKey(key)
Return
FancyR_BackWord:
Key := FancyR_Vis ? "^+{Left}" : "^{Left}"
FancyR_SendKey(key)
Return
FancyR_Right:
Key := FancyR_Vis ? "+{Right}" : "{Right}"
FancyR_SendKey(key)
Return
FancyR_SDown:
FancyR_SendKey("+{Down}")
Return
FancyR_SLeft:
FancyR_SendKey("+{Left}")
Return
FancyR_SUp:
FancyR_SendKey("+{Up}")
Return
FancyR_SRight:
FancyR_SendKey("+{Right}")
Return
FancyR_Find:
If FancyR_SendKey("")
{
	FancyR := False
	FancyR_IsFind := True
}
Return
FancyR_DeselectSimple:
    ;If FancyR_SendKey("")
    {
        Send {Right}{Left}   ; deselect
    }
Return
FancyR_DeselectStart:
    if FancyR    
    {
        Pos := FancyR_GetPos()
        Pos := Pos[1]
        FancyR_DefaultsMenuPos(Pos,Pos)
    }
    else
       FancyR_SendKey("")    
return
FancyR_DeselectEnd:
    if FancyR    
    {
        Pos := FancyR_GetPos()
        Pos := Pos[2]
        FancyR_DefaultsMenuPos(Pos,Pos)
    }
    else
       FancyR_SendKey("")    
Return
FancyR_Selectall:
If FancyR_SendKey("")
{
	ControlGetText,Text,Edit1,AHK_ID %FancyR_ID%
	Pos := Strlen(Text)
	FancyR_DefaultsMenuPos(0,Pos)
}
Return
FancyR_SelectFileName:
If FancyR_SendKey("")
{
	ControlGetText,Text,Edit1,AHK_ID %FancyR_ID%
	splitpath,Text,,,,FileName
	Pos := Strlen(FileName)
	FancyR_DefaultsMenuPos(0,Pos)
}
Return
FancyR_SelectExt:
If FancyR_SendKey("")
{
	ControlGetText,Text,Edit1,AHK_ID %FancyR_ID%
	splitpath,Text,,,FileExt,FileName
	Pos1 := Strlen(FileName)
	Pos2 := Strlen(FileExt)
	FancyR_DefaultsMenuPos(Pos1+1,Pos1+Pos2+1)
}
Return
;start of the line
FancyR_Home:
If FancyR_SendKey("")
{
    ;FancyR_DefaultsMenuPos(0,0)
    Key := FancyR_Vis ? "+{Home}" : "{Home}"
    FancyR_SendKey(key)
}
Return
;start of the top line
FancyR_HomeTop:
If FancyR_SendKey("")
{
    ;FancyR_DefaultsMenuPos(0,0)
    Key := FancyR_Vis ? "+{Home}" : "{Home}"
    FancyR_SendKey(key)
    FancyR_SendKey(key)
    FancyR_SendKey(key)
}
Return
FancyR_End:
If FancyR_SendKey("")
{
	;ControlGetText,Text,Edit1,AHK_ID %FancyR_ID%
	;Pos := Strlen(Text)
	;FancyR_DefaultsMenuPos(Pos,Pos)
    Key := FancyR_Vis ? "+{End}" : "{End}"
    FancyR_SendKey(key)
}
Return
FancyR_Copy:
If FancyR_SendKey("")
{
	Pos := FancyR_GetPos()
	ControlGetText,Text,Edit1,AHK_ID %FancyR_ID%
	FancyR_Temp := SubStr(Text,Pos[1]+1,Pos[2]-Pos[1])
    If UseSystemClipboard
        Clipboard = %FancyR_Temp%
}
Return
FancyR_Backspace:
If FancyR_SendKey("")
{
	FancyR_Cut(-1)
	Send {Backspace}
}
Return
FancyR_Substitute:
If FancyR
{
    FancyR_Cut(0)
	Send {Delete}
    gosub FancyR_InsertMode
}
else
    If FancyR_SendKey("")

FancyR_Delete:
If FancyR_SendKey("")
{
	FancyR_Cut(0)
	Send {Delete}
}
Return
FancyR_Paste:
If FancyR_SendKey("")
	FancyR_Paste()
Return
FancyR_Transpose:
If FancyR_SendKey("")
{
	Pos := FancyR_GetPos()
	ControlGetText,Text,Edit1,AHK_ID %FancyR_ID%
	If Pos[1] > 0
	{
		TextA := SubStr(Text,Pos[1],1)
		TextB := SubStr(Text,Pos[1]+1,1)
		SetText := SubStr(Text,1,Pos[1]-1) . TextB . TextA . SubStr(Text,Pos[1]+2)
		ControlSetText,Edit1,%SetText%,AHK_ID %FancyR_ID%
		FancyR_DefaultsMenuPos(Pos[1],Pos[2])
		FancyR_Edit()
	}
}
Return
FancyR_Replace:
If FancyR_SendKey("")
{
	FancyR_IsReplace := True
    gosub FancyR_DeselectSimple
	Pos := FancyR_GetPos()
	If Pos[1] = Pos[2]
	{
		FancyR_DefaultsMenuPos(Pos[1],Pos[1]+1)
		FancyR := False
	}
}
Return
FancyR_MultiReplace:
If FancyR_SendKey("")
{
    FancyR := False
    FancyR_Vis := False
	FancyR_IsMultiReplace := True
    Status := "  mode : Replace                                "
    gosub FancyR_DeselectSimple
    ControlSetText,msctls_statusbar321,%status%,AHK_ID %FancyR_ID%
    gosub FancyR_DeselectSimple
    Send +{Right}        ; select one char
	Pos := FancyR_GetPos()
	If Pos[1] = Pos[2]
	{
		FancyR_DefaultsMenuPos(Pos[1],Pos[1]+1)
		FancyR := False
	}
}
Return
FancyR_visual:
If FancyR_SendKey("")
{
	FancyR_Vis := !FancyR_Vis
	If FancyR_Vis
	{
		Status := "  mode : Visual                                 "
		ControlSetText,msctls_statusbar321,%status%,AHK_ID %FancyR_ID%
        ;!!! experimental below
        ;Gui, HwndFancyR_ID:Color, red , ahk_id %FancyR_ID% 
        Gui, Edit1:Color, cRed 
        ;Gui, Color, %CustomColor%
        RGB := 0xFF66AA
        ;GuiControl, %FancyR_ID%: +c%RGB%, ahk_id %FancyR_ID% 
        Gui, Edit1:Font, cBlue Bold
        Gui, Font, s18 cRed Bold, Verdana
        GuiControl, Font, msctls_statusbar321
        GuiControl, Font, Edit1
        GuiControl, HwndFancyR_ID: +c%RGB%, Edit1, color red ;ahk_id %FancyR_ID% 
        Gui, msctls_statusbar321:Font, cBlue Bold
        Gui, Hotstring:Color, Red, Green
        Gui, HwndFancyR_ID:Color, Red, Green
        ;Tooltip v 
	}
	Else
	{
        ;gosub FancyR_DeselectEnd
        gosub FancyR_DeselectSimple
        WinSet, Region,, ahk_id %FancyR_ID% ; Restore the window to its original/default display area. !!!!
		Status := "  mode : Vim Normal                             "
		ControlSetText,msctls_statusbar321,%status%,AHK_ID %FancyR_ID%
	}
}
Return
FancyR_InsertMode:
;If FancyR_SendKey("")
{
    FancyR_Count := 0
	FancyR := False
	FancyR_Vis := False
	Status := "  mode : Insert                                 "
	ControlSetText,msctls_statusbar321,%status%,AHK_ID %FancyR_ID%
}
Return

FancyR_Insert:
if FancyR
{
    gosub FancyR_DeselectStart
    gosub FancyR_InsertMode
}
else
   FancyR_SendKey("")    
Return

FancyR_InsertHome:
if FancyR
{
    gosub FancyR_InsertMode
    gosub FancyR_DeselectSimple
    Send {Home}
}
else
   FancyR_SendKey("")    
Return
FancyR_Append:
if FancyR
{
    gosub FancyR_DeselectEnd
    gosub FancyR_InsertMode
    Send {Right}
}
else
   FancyR_SendKey("")    
Return
FancyR_AppendEnd:
if FancyR
{
    gosub FancyR_DeselectEnd
    gosub FancyR_InsertMode
    Send {End}
}
else
   FancyR_SendKey("")    
Return
FancyR_Esc:
    ;gosub FancyR_DeselectEnd
    FancyR := True
    FancyR_IsReplace := False
    FancyR_IsMultiReplace := False
    FancyR_Count := 0
    Status := "  mode : Vim Normal                             "
    Tooltip
    Settimer,<RemoveHelpTip>,off
    ControlSetText,msctls_statusbar321,%status%,AHK_ID %FancyR_ID%
Return
FancyR_Quit:
If FancyR_SendKey("")
	WinClose,AHK_ID %FancyR_ID%
Return
FancyR_Undo:
If FancyR_SendKey("")
	FancyR_Undo()
Return
FancyR_history:
	Global HistoryOfRenamePath
	match = `"$0
	file := Regexreplace(HistoryOfRenamePath,".*",match)
	If Fileexist(EditorPath)
		editfile := EditorPath . EditorArguments . file
	Else
		editfile := "notepad.exe" . a_space . file
	Run,%editfile%,,UseErrorLevel
Return

FancyR_Enter:
GuiControlGet,NewName,,Edit1
Gui,Destroy
Postmessage,1075,1007,0,,AHK_CLASS TTOTAL_CMD
Loop,40
{
	ControlGetFocus,This,AHK_CLASS TTOTAL_CMD
    If This = %TCEditRename%
	{
		ControlGetText,ConfirName,%TCEditRename%,AHK_CLASS TTOTAL_CMD
		ControlSetText,%TCEditRename%,%NewName%,AHK_CLASS TTOTAL_CMD
		Break
	}
	Sleep,50
}
If Diff(ConfirName,GetName)
	ControlSend,%TCEditRename%,{enter},AHK_CLASS TTOTAL_CMD
Else
	Return
Return
FancyR_Edit:
FancyR_Edit()
Return
FancyR_SelMode:
SetConfig("FancyVimRename","InsertMode",!GetConfig("FancyVimRename","InsertMode"))
If GetConfig("FancyVimRename","InsertMode")
    Menu,FancyR_DefaultsMenu,Check, Insert mode at start `tAlt+I
Else
    Menu,FancyR_DefaultsMenu,Uncheck, Insert mode at start `tAlt+I
Return
FancyR_SelExt:
SetConfig("FancyVimRename","UnselectExt",!GetConfig("FancyVimRename","UnselectExt"))
If GetConfig("FancyVimRename","UnselectExt")
	Menu,FancyR_DefaultsMenu,Check, Extension unselected at start `tAlt+E
Else
	Menu,FancyR_DefaultsMenu,UnCheck, Extension unselected at start `tAlt+E
Return

FancyR_Help:
FancyR_Help()
Return

FancyR_Help()
{
	rename_help =
(
If you can't type, then press i to edit properly in so called "Insert mode"
To always start in "Insert mode" open "Defaults" menu and select "Insert mode at start"
)

	WinGetPos,,,w,h,AHK_ID %FancyR_ID%
    ;MsgBox, 262144, MyTitle, My Text Here   ;Always-on-top is  262144
	MsgBox , 262144, Help for Fancy Rename , %rename_help%
    ;tooltip,%rename_help%,0,%h%
	;Settimer,<RemoveHelpTip>,50
	Return
}


FancyR_Keys:
FancyR_Keys()
Return

FancyR_Keys()
{
	rename_keys =
(
 ----- keys for a simple Vim emulator -----
q :  Quit rename without saving (in Normal and Visual mode)
i :  Insert mode
I :  Insert at front
a :  Append 
A :  Append at end
v :  Visual select mode, v again to toggle to Vim Normal mode
Esc :  Vim's Normal mode
^[  :  Same as Esc
Capslock : Same as Esc (only if this is enabled in the settings)
                   Use Ctrl+Capslock to get Capslock 
Alt+c = Cancel button : Quit rename without saving (in any mode)
Enter = OK button :  Save rename

j :  Move downward N lines (if filename is so long that it wraps)
k :  Move up N lines (if filename is so long that it wraps)
h :  Move to the left N characters
l :  Move to the right N characters
H :  Select to the left N characters
L :  Select to the right N characters
w :  Word
e :  End of a word
b :  Back a word
u :  Undo (multiple too)
x :  Delete forward
X :  Delete backward (like backspace or X in vim)
d :  Delete backward (like backspace or X in vim)
s :  Substitute character or selection
y :  Copy selection (Visual mode)
p :  Paste 
f :  Find characters, E.g 'f' then 'a' to find 'a'
t :  Transpose two characters at the cursor
r :  Replace one character at the cursor
R :  Replace characters continuously untill Esc
g :  Put cursor at the first character of the first line
0 :  Put cursor at the first character of the line
^ :  Put cursor at the first character of the line
$ :  Put cursor at the last character  of the line
n :  Select the file name
[ :  Select the file name
] :  Select the extension
' :  Select all
< or , :  Deselect with cursor at selection start
> or . :  Deselect with cursor at selection end
)
	WinGetPos,,,w,h,AHK_ID %FancyR_ID%
    ;MsgBox, 262144, MyTitle, My Text Here   ;Always-on-top is  262144
	MsgBox , 262144, Keys for Fancy Rename , %rename_keys%
    ;tooltip,%rename_help%,0,%h%
	;Settimer,<RemoveHelpTip>,50
	Return
}

<RemoveHelpTip>:
Ifwinnotactive,AHK_ID %FancyR_ID%
{
	SetTimer,<RemoveHelpTip>, Off
	ToolTip
}
return
FancyR_SendKey(ThisKey)
{
	If FancyR
	{
		FancyR_Count := FancyR_Count ? FancyR_Count : 1
		Loop % FancyR_Count
		{
			Send %ThisKey%
		}
		FancyR_Count := 0
		ControlGetText,status,msctls_statusbar321,AHK_ID %FancyR_ID%
		status := SubStr(status,1,Strlen(status)-3) . "   "
		ControlSetText,msctls_statusbar321,%status%,AHK_ID %FancyR_ID%
		Return True
	}
	Else
	{
		Send %A_ThisHotkey%
		Return False
	}
}
FancyR_SendNum()
{
	If A_ThisHotkey is integer
		ThisNum := A_ThisHotkey
	Else
		Return
	If FancyR
	{
		If FancyR_Count
			FancyR_Count := ThisNum + (FancyR_Count * 10 )
		Else
            If ThisNum = 0
            {
                ;FancyR_DefaultsMenuPos(0,0)
                Key := FancyR_Vis ? "+{Home}" : "{Home}"
                FancyR_SendKey(key)
                Return False
            }
            else
			   FancyR_Count := ThisNum + 0
		if FancyR_Count > 256
			FancyR_Count := 256
		ControlGetText,status,msctls_statusbar321,AHK_ID %FancyR_ID%
		StringRight,isNumber,status,3
		If RegExMatch(isNumber,"\s\s\s")
			Status := RegExReplace(Status,"\s\s\s$") . FancyR_Count . "  "
		If RegExMatch(isNumber,"\d\s\s")
			Status := RegExReplace(Status,"\d\s\s$") . FancyR_Count  . " "
		If RegExMatch(isNumber,"\d\d\s")
			Status := RegExReplace(Status,"\d\d\s$") . FancyR_Count
		If RegExMatch(isNumber,"\d\d\d")
			Status := RegExReplace(Status,"\d\d\d$") . FancyR_Count
		ControlSetText,msctls_statusbar321,%status%,AHK_ID %FancyR_ID%
		Return True
	}
	Else
	{
		Send %A_ThisHotkey%
		Return False
	}
}
FancyR_Undo()
{
	DontSetText := False
	Serial := FancyR_History["s"]
	If  Serial > 0
		Serial--
	Else
		DontSetText := True
	Change := FancyR_History[Serial]
	;Stringsplit,Pos,Change,`,   ;When fancy-renaming a name including a comma, the undo function truncates till the comma.
	Stringsplit,Pos,Change,|    ; "|" is a divider because it is not allowed in filenames
	If Not DontSetText
		ControlSetText,Edit1,%Pos3%,AHK_ID %FancyR_ID%
	FancyR_DefaultsMenuPos(Pos1,Pos2)
	FancyR_History["s"] := Serial
	FancyR_History["String"] := Pos3
}
FancyR_Edit()
{
	Match := "^" . RegExReplace(FancyR_History["String"],"\+|\?|\.|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0") . "$"
	ControlGetText,Change,Edit1,AHK_ID %FancyR_ID%
	if Not RegExMatch(Change,Match)
	{
		Serial := FancyR_History["s"]
		Serial++
		pos := FancyR_GetPos()
		StartPos := pos[1]
		EndtPos  := pos[2]
		;FancyR_History[Serial] :=  StartPos . "," . EndPos . "," .  Change
		FancyR_History[Serial] :=  StartPos . "|" . EndPos . "|" .  Change
		FancyR_History["s"] := Serial
		FancyR_History["String"] := change
		If FancyR_IsReplace
		{
			FancyR_IsReplace := !FancyR_IsReplace
			FancyR := True
		}
		If FancyR_IsMultiReplace
		{
			Pos := FancyR_GetPos()
			If Pos[1] = Pos[2]
			{
				FancyR_DefaultsMenuPos(Pos[1],Pos[1]+1)
			}
		}
	}
}
FancyR_Cut(Length)
{
	Pos := FancyR_GetPos()
	ControlGetText,Text,Edit1,AHK_ID %FancyR_ID%
	If Pos[1] = Pos[2]
	{
		Pos1 := Pos[1] + 1 + Length
		Len  := 1
	}
	Else
	{
		Pos1 := Pos[1] + 1
		Len := Pos[2] - Pos[1]
	}
	FancyR_Temp := SubStr(Text,Pos1,Len)
}
FancyR_Paste(Direction="")
{
    Global UseSystemClipboard
    If UseSystemClipboard
        FancyR_Temp := Clipboard
	Pos := FancyR_GetPos()
	ControlGetText,Text,Edit1,AHK_ID %FancyR_ID%
	SetText := SubStr(Text,1,Pos[1]) . FancyR_Temp . SubStr(Text,Pos[1]+1)
	Pos1 := Pos[1] + Strlen(FancyR_Temp)
	ControlSetText,Edit1,%SetText%,AHK_ID %FancyR_ID%
	FancyR_DefaultsMenuPos(Pos1,Pos1)
	FancyR_Edit()
}
FancyR_GetPos()
{
	Pos := []
	ControlGet,Edit_ID,hwnd,,Edit1,AHK_ID %FancyR_ID%
	Varsetcapacity(StartPos,2)
	Varsetcapacity(EndPos,2)
	Sendmessage,0x00B0,&StartPos,&EndPos,,AHK_ID %Edit_ID%
	Pos[1] := NumGet(StartPos)
	Pos[2] := NumGet(EndPos)
	Return Pos
}
FancyR_DefaultsMenuPos(Pos1,Pos2)
{
	PostMessage,0x00B1,%Pos1%,%Pos2%,Edit1,AHK_ID %FancyR_ID%
}


; --- hardcoded settings {{{1
SetDefaultKey()
{
    ; ---------  keys for quick-search (\ or ctrl+s)
	Hotkey,Ifwinactive,ahk_class TQUICKSEARCH
	Hotkey,+j,<Down>
	Hotkey,+k,<Up>    
	Hotkey,!j,<Down>
	Hotkey,!k,<Up>
    Hotkey,^g,<Down>
	Hotkey,^t,<Up>
    ; ---------  keys for search (? or alt+F7)
    Hotkey,Ifwinactive,ahk_class TFindFile
	Hotkey,!j,<Down>
	Hotkey,!k,<Up>
    Hotkey,^g,<Down>
	Hotkey,^t,<Up>
    Hotkey,^e,<Down>
	Hotkey,^y,<Up>
    ; ---------  keys for Help
	Hotkey,Ifwinactive,Help   VIATC %Version%
	Hotkey,j,<Down>
	Hotkey,k,<Up>    
	Hotkey,h,<Left>    
	Hotkey,l,<Right>    

    ; --------- IsCapslockAsEscape
    IniRead,IsCapslockAsEscape,%ViatcIni%,Configuration,IsCapslockAsEscape
    if IsCapslockAsEscape
	    Hotkey,$CapsLock,<Esc>,On,UseErrorLevel



    ; -------- single keys
IniRead,EnableBuiltInHotkeys,%ViatcIni%,Configuration,EnableBuiltInHotkeys
if EnableBuiltInHotkeys
{    
	Hotkey,Ifwinactive,AHK_CLASS TTOTAL_CMD
	HotKey,1,<Num1>,on,UseErrorLevel
	HotKey,2,<Num2>,on,UseErrorLevel
	HotKey,3,<Num3>,on,UseErrorLevel
	HotKey,4,<Num4>,on,UseErrorLevel
	HotKey,5,<Num5>,on,UseErrorLevel
	HotKey,6,<Num6>,on,UseErrorLevel
	HotKey,7,<Num7>,on,UseErrorLevel
	HotKey,8,<Num8>,on,UseErrorLevel
	HotKey,9,<Num9>,on,UseErrorLevel
	HotKey,0,<Num0>,on,UseErrorLevel
	HotKey,+a,<SelectAllBoth>,on,UseErrorLevel
	Hotkey,b,<PageUp>,On,UseErrorLevel
	Hotkey,+b,<azTab>,On,UseErrorLevel
	;HotKey,c,<CloseCurrentTab>,on,UseErrorLevel
    HotKey,+c,<ExecuteDOS>,on,UseErrorLevel
	HotKey,d,<DirectoryHotlist>,on,UseErrorLevel
	HotKey,+d,<GoDesktop>,on,UseErrorLevel
	;HotKey,e,<ContextMenu>,on,UseErrorLevel
	HotKey,+e,<Edit>,on,UseErrorLevel
	Hotkey,f,<PageDown>,On,UseErrorLevel
	Hotkey,+g,<End>,On,UseErrorLevel
	HotKey,h,<left>,on,UseErrorLevel
    HotKey,+h,<GotoPreviousDir>,on,UseErrorLevel
    Hotkey,i,<Return>,on,UseErrorLevel
	HotKey,j,<Down>,on,UseErrorLevel
    HotKey,+j,<DownSelect>,on,UseErrorLevel
	HotKey,k,<up>,on,UseErrorLevel
    HotKey,+k,<UpSelect>,on,UseErrorLevel
	HotKey,l,<right>,on,UseErrorLevel
	HotKey,+l,<GotoNextDir>,on,UseErrorLevel
    Hotkey,m,<Mark>,On,UseErrorLevel
	Hotkey,+m,<Half>,On,UseErrorLevel
	Hotkey,n,<azhistory>,On,UseErrorLevel
	Hotkey,+n,<DirectoryHistory>,On,UseErrorLevel
	HotKey,o,<SrcOpenDrives>,on,UseErrorLevel
	HotKey,+o,<OpenDrives>,on,UseErrorLevel
	HotKey,p,<PackFiles>,on,UseErrorLevel
	HotKey,+p,<UnpackFiles>,on,UseErrorLevel
	HotKey,q,<SrcQuickview>,on,UseErrorLevel
	HotKey,+q,<Internetsearch>,on,UseErrorLevel
    Hotkey,r,<RenameSingleFile>,on,UseErrorLevel
	Hotkey,+r,<FancyR>,on,UseErrorLevel
    ;Hotkey,+r,<MultiRenameFiles>,on,UseErrorLevel
	HotKey,t,<OpenNewTab>,on,UseErrorLevel
	HotKey,+t,<OpenNewTabBg>,on,UseErrorLevel
	HotKey,u,<GotoParentEx>,on,UseErrorLevel
	HotKey,+u,<GotoRoot>,on,UseErrorLevel
	Hotkey,v,<ContextMenu>,On,UseErrorLevel
	Hotkey,w,<SrcCustomViewMenu>,On,UseErrorLevel
	Hotkey,+w,<Enter>,On,UseErrorLevel
	Hotkey,x,<CloseCurrentTab>,On,UseErrorLevel
	Hotkey,y,<Copy>,On,UseErrorLevel
	;Hotkey,+y,<MoveOnly>,On,UseErrorLevel
    ;Hotkey,y,<CopyNamesToClip>,On,UseErrorLevel
    Hotkey,+y,<CopyFullNamesToClip>,On,UseErrorLevel
	Hotkey,.,<SingleRepeat>,On,UseErrorLevel
	Hotkey,/,<ShowQuickSearch>,On,UseErrorLevel
	Hotkey,+/,<SearchFor>,On,UseErrorLevel
	Hotkey,`;,<FocusCmdLine>,On,UseErrorLevel
	Hotkey,:,<FocusCmdLineEx>,On,UseErrorLevel
	Hotkey,[,<SelectCurrentName>,On,UseErrorLevel
	Hotkey,^[,<Esc>,On,UseErrorLevel
	Hotkey,+[,<UnselectCurrentName>,On,UseErrorLevel
	Hotkey,],<SelectCurrentExtension>,On,UseErrorLevel
	Hotkey,+],<UnselectCurrentExtension>,On,UseErrorLevel
	Hotkey,\,<ExchangeSelection>,On,UseErrorLevel
	Hotkey,|,<ClearAll>,On,UseErrorLevel
	;Hotkey,+\,<ClearAll>,On,UseErrorLevel
	Hotkey,=,<MatchSrc>,On,UseErrorLevel
	Hotkey,-,<SwitchSeparateTree>,On,UseErrorLevel
    Hotkey,\,<ExchangeSelection>,On,UseErrorLevel
	Hotkey,',<ListMark>,On,UseErrorLevel
    Hotkey,+',<ListMark>,On,UseErrorLevel
	;Hotkey,`,,<None>,On,UseErrorLevel
	Hotkey,$Enter,<Enter>,On,UseErrorLevel
	Hotkey,Esc,<Esc>,On,UseErrorLevel
}

    ; --------- Special characters in ini files
    ; The following four characters: space ; = [   are not allowed as keys in ini files 
    ;   thus they cannot be directly remapped as hotkeys (nor be used as marks in ViATc).
    ; Below is a workaround 
    IniRead,command,%ViatcIni%,SpecialHotkey,Char_space
    if %command%
	    Hotkey, $space,%command%,On,UseErrorLevel
    IniRead,command,%ViatcIni%,SpecialHotkey,Char_semicolon
    if %command%
	    Hotkey,`;,%command%,On,UseErrorLevel
    IniRead,command,%ViatcIni%,SpecialHotkey,Char_equals
    if %command%
	    Hotkey,=,%command%,On,UseErrorLevel
    IniRead,command,%ViatcIni%,SpecialHotkey,Char_[
    if %command%
	    Hotkey,[,%command%,On,UseErrorLevel        

    ; ------ combo keys:
IniRead,EnableBuiltInComboHotkeys,%ViatcIni%,Configuration,EnableBuiltInComboHotkeys
if EnableBuiltInComboHotkeys
{    
    ComboKeyAdd("ca","<SetAttrib>")
    ComboKeyAdd("a'","<RestoreLastMark>")
	ComboKeyAdd("chc","<DelCmdHistory>")
	ComboKeyAdd("chl","<DeleteLHistory>")
	ComboKeyAdd("chr","<DeleteRHistory>")
	ComboKeyAdd("g1","<SrcActivateTab1>")
	ComboKeyAdd("g2","<SrcActivateTab2>")
	ComboKeyAdd("g3","<SrcActivateTab3>")
	ComboKeyAdd("g4","<SrcActivateTab4>")
	ComboKeyAdd("g5","<SrcActivateTab5>")
	ComboKeyAdd("g6","<SrcActivateTab6>")
	ComboKeyAdd("g7","<SrcActivateTab7>")
	ComboKeyAdd("g8","<SrcActivateTab8>")
	ComboKeyAdd("g9","<SrcActivateTab9>")
	ComboKeyAdd("g0","<GoLastTab>")
	ComboKeyAdd("ga","<CloseAllTabs>")
	ComboKeyAdd("gb","<OpenDirInNewTabOther>")
	ComboKeyAdd("ge","<Exchange>")
	ComboKeyAdd("gg","<Home>")
	ComboKeyAdd("gn","<OpenDirInNewTab>")
	ComboKeyAdd("gp","<SwitchToPreviousTab>")
	ComboKeyAdd("gr","<SwitchToPreviousTab>")
	ComboKeyAdd("gt","<SwitchToNextTab>")
	ComboKeyAdd("gw","<ExchangeWithTabs>")
	ComboKeyAdd("s1","<SrcSortByCol1>")
	ComboKeyAdd("s2","<SrcSortByCol2>")
	ComboKeyAdd("s3","<SrcSortByCol3>")
	ComboKeyAdd("s4","<SrcSortByCol4>")
	ComboKeyAdd("s5","<SrcSortByCol5>")
	ComboKeyAdd("s6","<SrcSortByCol6>")
	ComboKeyAdd("s7","<SrcSortByCol7>")
	ComboKeyAdd("s8","<SrcSortByCol8>")
	ComboKeyAdd("s9","<SrcSortByCol9>")
	ComboKeyAdd("sd","<SrcByDateTime>")
	ComboKeyAdd("se","<SrcByExt>")
	ComboKeyAdd("sg","<Internetsearch>")
	ComboKeyAdd("sn","<SrcByName>")
	ComboKeyAdd("sr","<SrcNegOrder>")
	ComboKeyAdd("ss","<SrcBySize>")
    ComboKeyAdd("<Shift>vmt","<SwitchDarkmode>")
	ComboKeyAdd("<Shift>vmd","<EnableDarkmode>")
	ComboKeyAdd("<Shift>vml","<DisableDarkmode>")
	ComboKeyAdd("<Shift>vb","<VisButtonbar>")
	ComboKeyAdd("<Shift>vc","<VisCurDir>")
	ComboKeyAdd("<Shift>vd","<VisDriveButtons>")
	ComboKeyAdd("<Shift>vf","<VisKeyButtons>")
	ComboKeyAdd("<Shift>vn","<VisCmdLine>")
	ComboKeyAdd("<Shift>vo","<VisTwoDriveButtons>")
	ComboKeyAdd("<Shift>vr","<VisDriveCombo>")
	ComboKeyAdd("<Shift>vs","<VisStatusbar>")
	ComboKeyAdd("<Shift>vt","<VisTabHeader>")
	ComboKeyAdd("<Shift>vw","<VisDirTabs>")
    ComboKeyAdd("za","<TCFullScreenAlmost>")
	ComboKeyAdd("zf","<TCFullScreen>")
	ComboKeyAdd("zp","<TCFullScreenWithExePlugin>")
	ComboKeyAdd("zh","<WinMaxRight>")
	ComboKeyAdd("zl","<WinMaxLeft>")
	ComboKeyAdd("zm","<Maximize>")
	ComboKeyAdd("zn","<Minimize>")
	ComboKeyAdd("zq","<QuitTC>")
	ComboKeyAdd("zr","<ReLoadTC>")
	ComboKeyAdd("zd","<Restore>")
	ComboKeyAdd("zs","<Transparent>")
	ComboKeyAdd("zt","<AlwayOnTop>")
	ComboKeyAdd("zv","<VerticalPanels>")
	ComboKeyAdd("zw","<WidePanelToggle>")
	ComboKeyAdd("zx","<WidePanelToggle>")
	ComboKeyAdd("zi","<100Percent>")
	ComboKeyAdd("zz","<50Percent>")
	ComboKeyAdd("zc","<CommandBrowser>")
 }   
    ; -------  keys for fancy rename 
	Hotkey,IfWinActive,ViATc Fancy Rename
	Hotkey,j,FancyR_Down,on,UseErrorLevel
	Hotkey,k,FancyR_Up,on,UseErrorLevel
	Hotkey,h,FancyR_Left,on,UseErrorLevel
	Hotkey,l,FancyR_Right,on,UseErrorLevel
	Hotkey,w,FancyR_Word,on,UseErrorLevel
    Hotkey,e,FancyR_WordEnd,on,UseErrorLevel
	Hotkey,b,FancyR_BackWord,on,UseErrorLevel
	Hotkey,+j,FancyR_SDown,on,UseErrorLevel
	Hotkey,+k,FancyR_SUp,on,UseErrorLevel
	Hotkey,+h,FancyR_SLeft,on,UseErrorLevel
	Hotkey,+l,FancyR_SRight,on,UseErrorLevel
	Hotkey,y,FancyR_Copy,on,UseErrorLevel
	Hotkey,d,FancyR_Backspace,on,UseErrorLevel
    Hotkey,s,FancyR_Substitute,on,UseErrorLevel
	Hotkey,x,FancyR_Delete,on,UseErrorLevel
    Hotkey,+x,FancyR_Backspace,on,UseErrorLevel
	Hotkey,i,FancyR_Insert,on,UseErrorLevel
	Hotkey,+i,FancyR_InsertHome,on,UseErrorLevel
	Hotkey,a,FancyR_Append,on,UseErrorLevel
	Hotkey,+a,FancyR_AppendEnd,on,UseErrorLevel
	Hotkey,t,FancyR_Transpose,on,UseErrorLevel
	Hotkey,f,FancyR_Find,on,UseErrorLevel
    Hotkey,r,FancyR_Replace,on,UseErrorLevel
	Hotkey,+r,FancyR_MultiReplace,on,UseErrorLevel
	Hotkey,',FancyR_Selectall,on,UseErrorLevel
	;Hotkey,s,FancyR_DeselectStart,on,UseErrorLevel
	;Hotkey,o,FancyR_DeselectEnd,on,UseErrorLevel
	Hotkey,+`,,FancyR_DeselectStart,on,UseErrorLevel   ; <
	Hotkey,+.,FancyR_DeselectEnd,on,UseErrorLevel      ; >
	Hotkey,`,,FancyR_DeselectStart,on,UseErrorLevel    ; ,
	Hotkey,.,FancyR_DeselectEnd,on,UseErrorLevel       ; .
	Hotkey,n,FancyR_Selectfilename,on,UseErrorLevel
    Hotkey,[,FancyR_Selectfilename,on,UseErrorLevel
    Hotkey,],FancyR_Selectext,on,UseErrorLevel
    Hotkey,+6,FancyR_Home,on,UseErrorLevel
	Hotkey,g,FancyR_HomeTop,on,UseErrorLevel
	Hotkey,$,FancyR_End,on,UseErrorLevel
	Hotkey,+g,FancyR_End,on,UseErrorLevel
	Hotkey,q,FancyR_Quit,on,UseErrorLevel
	Hotkey,u,FancyR_Undo,on,UseErrorLevel
	Hotkey,v,FancyR_Visual,on,UseErrorLevel
	Hotkey,p,FancyR_Paste,on,UseErrorLevel
	Hotkey,Esc,FancyR_Esc,on,UseErrorLevel
	Hotkey,^[,FancyR_Esc,on,UseErrorLevel
    if IsCapslockAsEscape
    	Hotkey,Capslock,FancyR_Esc,on,UseErrorLevel
	;Hotkey,^Capslock,Capslock,on,UseErrorLevel
	Hotkey,1,FancyR_Num,on,UseErrorLevel
	Hotkey,2,FancyR_Num,on,UseErrorLevel
	Hotkey,3,FancyR_Num,on,UseErrorLevel
	Hotkey,4,FancyR_Num,on,UseErrorLevel
	Hotkey,5,FancyR_Num,on,UseErrorLevel
	Hotkey,6,FancyR_Num,on,UseErrorLevel
	Hotkey,7,FancyR_Num,on,UseErrorLevel
	Hotkey,8,FancyR_Num,on,UseErrorLevel
	Hotkey,9,FancyR_Num,on,UseErrorLevel
    Hotkey,0,FancyR_Num,on,UseErrorLevel
}


;; usage: If controlActive("SomeClassName")
;controlActive(controlClassName,winName:="a")
;{
;    controlGetFocus,focusedControl,% winName
;    return controlClassName=focusedControl?1:0
;}

ControlActive(ClassNN, WinTitle) {
    ControlGetFocus, CurCon, % WinTitle
    Return (CurCon=ClassNN)
}

; ---  operation {{{
SendKey(HotKey)
{
	Global KeyCount,KeyTemp,Repeat,MaxCount
	If CheckMode()
	{
		If KeyTemp
		{
			ComboKey(A_ThisHotkey)
			Return
		}
		If KeyCount
		{
			ControlSetText,%TCEdit%,,AHK_CLASS TTOTAL_CMD
			If KeyCount > %MaxCount%
				keyCount := MaxCount
			Repeat := KeyCount . ">>" . hotkey
			Loop,%KeyCount%
				Send %hotkey%
			KeyCount := 0
		}
		Else
		{
			Send %hotkey%
			Repeat := 1 . ">>" . hotkey
		}
	}
	Else
	{
		hotkey := TransSendKey(A_ThisHotkey)
		Send %hotkey%
	}
}

SendNum(HotKey)
{
	Global KeyCount,KeyTemp,GetNum
	If CheckMode()
	{
		If KeyTemp
		{
			ComboKey(A_ThisHotkey)
			Return
		}
		If KeyCount
			KeyCount := Hotkey + (KeyCount * 10 )
		Else
			KeyCount := HotKey + 0
		ControlSetText,%TCEdit%,%KeyCount%,AHK_CLASS TTOTAL_CMD
	}
	Else
	{
		hotkey := TransSendKey(A_ThisHotkey)
		Send %hotkey%
	}
}

SendPos(Num,IsCount=False)
{
	Global KeyCount,KeyTemp,Repeat
	If IsCount
		Count := KeyCount ? KeyCount : 1
	Else
		Count := 1
	KeyCount := 0
	If CheckMode()
	{
		If KeyTemp
		{
			ComboKey(A_ThisHotkey)
			Return False
		}
		ControlSetText,%TCEdit%,,AHK_CLASS TTOTAL_CMD
		If Num < 0
			Return True
		If Num
		{
			Repeat := Count . "@" . Num
			Loop,%Count%
				PostMessage 1075, %Num%, 0,, AHK_CLASS TTOTAL_CMD
		}
		Return True
	}
	Else
	{
		hotkey := TransSendKey(A_ThisHotkey)
		Send %hotkey%
		Return False
	}
}

; Execute TC's commands, you can find them in TOTALCMD.INC file in TC dir
Execute(command)
{
        PostMessage 1075, %command%, 0,, AHK_CLASS TTOTAL_CMD
}

ExecFile()
{
	Global ExecFile_Arr,KeyTemp,GoExec,Repeat
	IfWinActive,AHK_CLASS TTOTAL_CMD
	{
		Key := "H" . A_ThisHotkey
		If Not ExecFile_Arr[Key]
			Key := "G" . A_ThisHotkey
	}
	Else
		Key := "G" . A_ThisHotkey
	If GoExec
		File := ExecFile_Arr[GoExec]
	Else
		File := ExecFile_Arr[Key]
	Run,%File%,,UseErrorLevel,ExecID
	If ErrorLevel = ERROR
	{
		MsgBox  run %File% failure
		Return
	}
	WinWait,AHK_PID %ExecID%,,3
	WinActivate,AHK_PID %ExecID%
	Repeat := "(" . File . ")"
	GoExec :=
}

SendText()
{
	Global SendText_Arr,KeyTemp,Repeat,GoText
	IfWinActive,AHK_CLASS TTOTAL_CMD
	{
		Key := "H" . A_ThisHotkey
		If Not SendText_Arr[Key]
			Key := "G" . A_ThisHotkey
	}
	Else
		Key := "G" . A_ThisHotkey
	If GoText
		Text := SendText_Arr[GoText]
	Else
		Text := SendText_Arr[Key]
	IfWinActive,AHK_CLASS TTOTAL_CMD
	{
		ControlGetFocus,ThisControl,AHK_CLASS TTOTAL_CMD
		If RegExMatch(Text,"^[#!\^\+]\{.*}.*")
			ControlSend,%ThisControl%,%Text%,AHK_CLASS TTOTAL_CMD
		Else
		{
			ControlSetText,%TCEdit%,%Text%,AHK_CLASS TTOTAL_CMD
			Postmessage,1075,4003,0,,AHK_CLASS TTOTAL_CMD
			PosEnd := Strlen(Text)
			PostMessage,0x00B1,%PosEnd%,%PosEnd%,%TCEdit%,AHK_CLASS TTOTAL_CMD
		}
	}
	Else
		Send,%Text%
	Repeat := "{" . Text . "}"
	GoText :=
}

Combokey(Hotkey)  ; {{{1
{
	Global ComboKey_Arr,KeyTemp,KeyCount,ComboInfo_arr,ComboTooltips,Repeat,SendText_Arr,ExecFile_Arr,GoExec,GoText
	If ComboTooltips And ( Not KeyTemp ) And CheckMode() And ComboInfo_Arr[A_ThisHotkey]
		Settimer,<ComboWarnAction>,50   ; 50 is a delay
	If checkMode()
	{
		KeyCount := 0
		KeyTemp .= A_ThisHotkey
		AllCK := Combokey_Arr["Hotkeys"]
		MatchString := "[^&]\s" . RegExReplace(KeyTemp,"\+|\?|\.|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0")
		If RegExMatch(AllCK,MatchString)
		{
			MatchString .= "\s"
			If RegExMatch(AllCk,MatchString)
			{
				Settimer,<RemoveToolTipEx>,off
				Tooltip
				ControlSetText,%TCEdit%,,AHK_CLASS TTOTAL_CMD
				Action := ComboKey_Arr[KeyTemp]
				If RegExMatch(Action,"<Text>")
					GoText := "C" . KeyTemp
				If RegExMatch(Action,"<Exec>")
					GoExec := "C" . KeyTemp
				KeyTemp :=
				If IsLabel(Action)
				{
					GoSub,%Action%
					Repeat := Action
				}
				Else
					MsgBox % KeyTemp " command " Action " Error "
			}
			Else
				ControlSetText,%TCEdit%,%KeyTemp%,AHK_CLASS TTOTAL_CMD
		}
		Else
		{
			ControlSetText,%TCEdit%,,AHK_CLASS TTOTAL_CMD
			KeyTemp :=
			Tooltip
		}
	}
	Else
	{
		Key := TransSendKey(A_ThisHotkey)
		Send,%key%
	}
}
ComboKeyAdd(Key,Action,IsGlobal=False)
{
	Global ComboKey_Arr,ComboInfo_Arr,CommandInfo_Arr,ExecFile_Arr,SendText_Arr
	Key_T := TransHotkey(key,"ALL")
	Info := Key . " >>" . CommandInfo_Arr[Action]
	If Action = <Text>
	{
		Key_N := "C" . Key_T
		Info := Key . " >> Send text  " . SendText_Arr[Key_N]
	}
	If Action = <Exec>
	{
		Key_N := "C" . Key_T
		Info := key . " >> run  " . ExecFile_Arr[Key_N]
	}
	ComboKey_Arr["Hotkeys"] .= A_Space . A_Space . Key_T . A_Space . A_Space
	ComboKey_Arr[Key_T] := Action
	Key_T := TransHotkey(key,"First")
	ComboInfo_Arr[Key_T] .= Info . "`n"
	If IsGlobal
		Hotkey,Ifwinactive
	Else
		Hotkey,Ifwinactive,AHK_CLASS TTOTAL_CMD
	Hotkey,%Key_T%,<ComboKey>,On,UseErrorLevel
}
CombokeyDelete(Key,IsGlobal=False)
{
	Global ComboKey_Arr
	Key_T := "\s" . TransHotkey(Key,"ALL") . "\s"
	ComboKey_Arr["Hotkeys"] := RegExReplace(Combokey_Arr["Hotkeys"],Key_T)
	Key_T := "\s" . TransHotkey(Key,"First")
	If RegExMatch(ComboKey_Arr["Hotkeys"],Key_T)
		Return
	If IsGlobal
		Hotkey,Ifwinactive
	Else
		Hotkey,Ifwinactive,AHK_CLASS TTOTAL_CMD
	Key_T := TransHotkey(Key,"First")
	Hotkey,%Key_T%,Off
}
SingleRepeat()
{
	Global Repeat
	If RegExMatch(Repeat,">>")
	{
		KeyCount := SubStr(Repeat,1,(RegExMatch(Repeat,">>") - 1))
		Loop,%KeyCount%
			SendKey(SubStr(Repeat,(RegExMatch(Repeat,">>")+2,StrLen(Repeat))))
		Return
	}
	If RegExMatch(Repeat,"^<.*>$")
	{
		If IsLabel(Repeat) AND Not RegExMatch(Repeat,"i)<SingleRepeat>")
			GoSub,%Repeat%
		Return
	}
	If RegExMatch(Repeat,"[0-9]*@[0-9]*")
	{
		Stringsplit,Num,Repeat,@
		Loop % Num1
			Postmessage 1075, %Num2%, 0,, ahk_class TTOTAL_CMD
	}
	If RegExMatch(Repeat,"^\(.*\)$")
	{
		File := SubStr(Repeat,2,StrLen(File)-1)
		If FileExist(File)
		{
			Run,%File%,,UseErrorLevel,ExecID
			WinWait,AHK_PID %ExecID%,,3
			WinActivate,AHK_PID %ExecID%
		}
	}
	If RegExMatch(Repeat,"^\{.*\}$")
	{
		Text := SubStr(Repeat,2,StrLen(Text)-1)
		Send,%Text%
	}
}
CheckMode()
{
	IfWinNotActive,AHK_CLASS TTOTAL_CMD
	Return True
	WinGet,MenuID,ID,AHK_CLASS #32768
	IF MenuID
		Return False
	ControlGetFocus,ListBox,ahk_class TTOTAL_CMD
	Ifinstring,ListBox,%TCListBox%
	If Vim
		Return true
	Else
		Return False
	Else
		Return False
}
TransHotkey(Hotkey,pos="ALL")
{
	If Pos = ALL
	{
		Loop
		{
			If RegExMatch(Hotkey,"^<[^<>]+><[^<>]+>.*$")
			{
				Hotkey1 := SubStr(Hotkey,2,RegExMatch(Hotkey,"><.*")-2)
				If RegExMatch(Hotkey1,"i)(l|r)?(ctrl|control|shift|win|alt)")
				{
					HK := SubStr(Hotkey,RegExMatch(Hotkey,"><.*")+2,Strlen(Hotkey)-RegExMatch(Hotkey,"><.*")-1)
					Hotkey2 := SubStr(HK,1,RegExMatch(HK,">")-1)
					Hotkey3 := SubStr(HK,RegExMatch(HK,">")+1)
					NewHotkey := Hotkey1 . " & " . Hotkey2 . Hotkey3
				}
				Else
					NewHotkey := Hotkey1  . HK := SubStr(Hotkey,RegExMatch(Hotkey,"><.*")+1,Strlen(Hotkey)-RegExMatch(Hotkey,"><.*"))
				Break
			}
			If RegExMatch(Hotkey,"^<[^<>]+>.+$")
			{
				Hotkey1 := SubStr(Hotkey,2,RegExMatch(Hotkey,">.+")-2)
				If RegExMatch(Hotkey1,"i)(l|r)?(ctrl|control|shift|win|alt)")
				{
					Hotkey2 := SubStr(Hotkey,RegExMatch(Hotkey,">.+")+1)
					NewHotkey := Hotkey1 . " & " . Hotkey2
				}
				Else
				{
					Hotkey2 := SubStr(Hotkey,RegExMatch(Hotkey,">.+")+1)
					NewHotkey := Hotkey1 . Hotkey2
				}
				Break
			}
			If RegExMatch(Hotkey,"^<[^<>]+>$")
			{
				NewHotkey := SubStr(Hotkey,2,Strlen(Hotkey)-2)
				Break
			}
			NewHotkey := Hotkey
			Break
		}
	}
	Else
	{
		Loop
		{
			If RegExMatch(Hotkey,"^<[^<>]+><[^<>]+>.*")
			{
				Hotkey1 := SubStr(Hotkey,2,RegExMatch(Hotkey,"><")-2)
				If RegExMatch(Hotkey1,"i)(l|r)?(ctrl|control|shift|win|alt)")
				{
					HK := SubStr(Hotkey,RegExMatch(Hotkey,"><")+2,Strlen(Hotkey)-RegExMatch(Hotkey,"><")-1)
					Hotkey2 := SubStr(HK,1,RegExMatch(HK,">")-1)
					NewHotkey := Hotkey1 . " & " . Hotkey2
				}
				Else
					NewHotkey := Hotkey1
				Break
			}
			If RegExMatch(Hotkey,"^<[^<>]+>.+")
			{
				Hotkey1 := SubStr(Hotkey,2,RegExMatch(Hotkey,">")-2)
				If RegExMatch(Hotkey1,"i)(l|r)?(ctrl|control|shift|win|alt)")
				{
					NewHotkey := Hotkey1 . " & " . SubStr(Hotkey,RegExMatch(Hotkey,">")+1,1)
				}
				Else
					NewHotkey := Hotkey1
				Break
			}
			If RegExMatch(Hotkey,"i)^<(l|r)?(ctrl|control|shift|win|alt)>$")
			{
				NewHotkey := SubStr(Hotkey,2,Strlen(Hotkey)-2)
				Break
			}
			If RegExMatch(Hotkey,"^<[^<>]+>$")
			{
				NewHotkey := SubStr(Hotkey,2,Strlen(Hotkey)-2)
				Break
			}
			If RegExMatch(Hotkey,"^.*")
				NewHotkey := Substr(hotkey,1,1)
			Break
		}
	}
	Return NewHotkey
}
CheckScope(key)
{
	If RegExMatch(Key,"^<[^<>]+>$|^<[^<>]+><[^<>]+>$|^.$")
		Scope := "H"
	Else
		Scope := "C"
	If RegExMatch(Key,"i)^<(shift|lshift|rshift|ctrl|lctrl|rctrl|control|lcontrol|rcontrol|lwin|rwin|alt|lalt|ralt)>.$")
		Scope := "H"
	return Scope
}
TransSendKey(hotkey)
{
	Loop
	{
		If RegExMatch(Hotkey,"i)^Esc$")
		{
			Hotkey := "{Esc}"
			Break
		}
		If StrLen(hotkey) > 1 AND Not RegExMatch(Hotkey,"^\+.$")
		{
			Hotkey := "{" . hotkey . "}"
			If RegExMatch(hotkey,"i)(shift|lshift|rshift)(\s\&\s)?.+$")
				Hotkey := "+" . RegExReplace(hotkey,"i)(shift|lshift|rshift)(\s\&\s)?")
			If RegExMatch(hotkey,"i)(ctrl|lctrl|rctrl|control|lcontrol|rcontrol)(\s\&\s)?.+$")
				Hotkey := "^" . RegExReplace(hotkey,"i)(ctrl|lctrl|rctrl|control|lcontrol|rcontrol)(\s\&\s)?")
			If RegExMatch(hotkey,"i)(lwin|rwin)(\s\&\s)?.+$")
				Hotkey := "#" . RegExReplace(hotkey,"i)(lwin|rwin)(\s\&\s)?")
			If RegExMatch(hotkey,"i)(alt|lalt|ralt)(\s\&\s)?.+$")
				Hotkey := "!" . RegExReplace(hotkey,"i)(alt|lalt|ralt)(\s\&\s)?")
		}
		If RegExMatch(Hotkey,"^\+.$")
		{
			Hotkey := SubStr(Hotkey,1,1) . "{" . SubStr(Hotkey,2) . "}"
		}
		GetKeyState,Var,CapsLock,T
		If Var = D
		{
			If RegExMatch(Hotkey,"^\+\{[a-z]\}$")
			{
				Hotkey := SubStr(Hotkey,2)
				Break
			}
			If RegExMatch(Hotkey,"^[a-z]$")
			{
				Hotkey := "+{" . Hotkey . "}"
				Break
			}
			If RegExMatch(Hotkey,"^\{[a-z]\}$")
			{
				Hotkey := "+" . Hotkey
				Break
			}
		}
		Break
	}
	Return hotkey
}

; --- configuration {{{1
FindPath(File)
{
    Global TCEXE, ViatcIni
    FileSF_FileName:= "C:\"
	If RegExMatch(File,"exe")
	{
		GetPath32 := "C:\Program Files (x86)\totalcmd\totalcmd.exe"
		GetPath64 := "C:\Program Files\totalcmd\totalcmd64.exe"
		Reg := "InstallDir"
		FileSF_Option := 3
		FileSF_FileName:= "C:\Program Files\totalcmd\"
		FileSF_Prompt := "TOTALCMD.EXE"
		FileSF_Filter := "*.EXE"
		FileSF_Error := "Could not find TOTALCMD.EXE nor TOTALCMD64.EXE"
        TCEXE := GetConfig("Paths","TCPath")
        If TCEXE = ERROR
            TCEXE = %GetPath64%
        GetPath = %TCEXE%
        If FileExist(GetPath)
            Return GetPath
        RegRead,Dir,HKEY_CURRENT_USER,Software\Ghisler\Total Commander,%Reg%
        StringRight, LastChar, Dir, 1
        if !(LastChar="\")
            Dir := Dir . "\"
        GetPath := Dir . "TOTALCMD64.EXE"
        If FileExist(GetPath)
        {
            ;Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,%Reg%,%GetPath%
            SetConfig("Paths","TCPath",GetPath)
            Return GetPath
        } 
        GetPath := "C:\totalcmd\TOTALCMD64.EXE"
        If FileExist(GetPath)
        {
            SetConfig("Paths","TCPath",GetPath)
            Return GetPath
        }
        GetPath := "C:\totalcmd\TOTALCMD.EXE"
        If FileExist(GetPath)
        {
            SetConfig("Paths","TCPath",GetPath)
            Return GetPath
        }
        GetPath := Dir . "TOTALCMD.EXE"
        If FileExist(GetPath)
        {
            SetConfig("Paths","TCPath",GetPath)
            Return GetPath
        } 
        
	}
	If RegExMatch(File,"ini")
	{
        Reg := "TCIni"
        RegRead,GetPath,HKEY_CURRENT_USER,Software\VIATC,%Reg%
        If FileExist(GetPath)
            Return GetPath
        RegRead,GetPath,HKEY_CURRENT_USER,Software\Ghisler\Total Commander,"IniFileName"
        If FileExist(GetPath)
        {
            Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,%Reg%,%GetPath%
            Return GetPath
        } 
		GetPath := "C:\Users\" . A_UserName . "\AppData\Roaming\GHISLER\wincmd.ini"
        If FileExist(GetPath)
        {
            Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,%Reg%,%GetPath%
            ;SetConfig("Paths","TCIni",GetPath)
            ;MsgBox, "Found the wincmd.ini file"
            Return GetPath
        }
        GetPath := "C:\Users\" . A_UserName . "\Documents\wincmd.ini"
        If FileExist(GetPath)
        {
            Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,%Reg%,%GetPath%
            Return GetPath
        }
        Splitpath,TcExe,,TcDir
        GetPath = %TcDir%\wincmd.ini
        If FileExist(GetPath)
        {
            Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,%Reg%,%GetPath%
            Return GetPath
        }
        ;MsgBox, "Could not find the wincmd.ini file in the typical places"            
        FileSF_Option := 3
        FileSF_FileName:= "C:\Users\" . A_UserName . "\AppData\Roaming\GHISLER\"
        FileSF_Prompt := " Select the wincmd.ini file "
        FileSF_Filter := "*.INI"
        FileSF_Error := "Could not find wincmd.ini"
        
	}

	If FileExist(GetPath)
	{
		FilegetAttrib,Attrib,%GetPath%
		IfNotInString, Attrib, D
		{
			Return GetPath
		}
	}
	If FileExist(GetPath64)
	{
		;Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,%Reg%,%GetPath64%
        TCEXE = %GetPath64%
        SetConfig("Paths","TCPath",TCEXE)
		Return GetPath64
	}
	If FileExist(GetPath32)
	{
		;Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,%Reg%,%GetPath32%
        TCEXE = %GetPath32%
        SetConfig("Paths","TCPath",TCEXE)
		Return GetPath32
	}
	FileSelectFile,GetPath,%FileSF_Option%,%FileSF_FileName%,%FileSF_Prompt%,%FileSF_Filter%
	If ErrorLevel
	{
		MsgBox %FileSF_Error%
		Return
	}
	Else
    {
        If RegExMatch(File,"exe")
        {
            TCEXE = %GetPath%
            SetConfig("Paths","TCPath",TCEXE)
        }
        If RegExMatch(File,"ini")
            Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,%Reg%,%GetPath%
    }
	Return GetPath
}
ReadKeyFromIni()
{
	Global ViatcIni,ExecFile_Arr,SendText_Arr,MapKey_Arr,MapKey_Arr
	Loop,Read,%ViatcIni%
	{
		If RegExMatch(SubStr(RegExReplace(A_LoopReadLine,"\s"),1,1),";")
			Continue
		If RegExMatch(A_LoopReadLine,"i)\[.*\]")
			IsReadKey := False
		If RegExMatch(A_LoopReadLine,"i)\[Hotkey\]")
		{
			IsReadKey := True
			IsHotkey := True
			IsGlobalHotkey := False
			IsCombokey := False
			Continue
		}
		If RegExMatch(A_LoopReadLine,"i)\[GlobalHotkey\]")
		{
			IsReadKey := True
			IsGlobalHotkey := True
			IsHotkey := False
			IsCombokey := False
			Continue
		}
		If RegExMatch(A_LoopReadLine,"i)\[ComboKey\]")
		{
			IsReadKey := True
			IsCombokey := True
			IsHotkey := False
			IsGlobalHotkey := False
			Continue
		}
		If IsReadkey
		{
			StringPos := RegExMatch(A_LoopReadLine,"=[<|\(|\{].*[>|\)\}]$",Action)
			If StringPos
			{
				Key := SubStr(A_LoopReadLine,1,StringPos-1)
				Action := SubStr(Action,2)
			}
			If IsGlobalHotkey
				MapKeyAdd(Key,Action,"G")
			If IsHotkey
				MapKeyAdd(Key,Action,"H")
			If IsCombokey
				MapKeyAdd(Key,Action,"C")
		}
	}
}
MapKeyAdd(Key,Action,Scope)
{
	Global MapKey_Arr,ExecFile_Arr,SendText_Arr
	If RegExMatch(CheckScope(key),"C")
		Scope := "C"
	If Not RegExMatch(Action,"^[<|\(|\{].*[>|\)\}]$")
		Return False
	If Not IsLabel(Action) AND RegExMatch(Action,"^<.*>$")
	{
		return False
	}
	If RegExMatch(Action,"^\(.*\)$")
	{
		Key_T := Scope . TransHotkey(Key)
		ExecFile_Arr["HotKeys"] .= A_Space . Key_T . A_Space
		ExecFile_Arr[Key_T] := Substr(Action,2,Strlen(Action)-2)
		Action := "<Exec>"
	}
	If RegExMatch(Action,"^\{.*\}$")
	{
		Key_T := Scope . TransHotkey(Key)
		SendText_Arr["HotKeys"] .= A_Space . Key_T . A_Space
		SendText_Arr[Key_T] := Substr(Action,2,Strlen(Action)-2)
		Action := "<Text>"
	}
	If Scope = G
	{
		HotKey,IfWinActive
		Key_T := TransHotkey(Key)
		Hotkey,%Key_T%,%Action%,On,UseErrorLevel
	}
	If Scope = H
	{
		Hotkey,IfWinActive,AHK_CLASS TTOTAL_CMD
		Key_T := TransHotkey(Key)
		Hotkey,%Key_T%,%Action%,On,UseErrorLevel
	}
	If Scope = C
		ComboKeyAdd(Key,Action)
	Key_T := "i)\s" . Scope . RegExReplace(Key,"\+|\?|\.|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0") . "\s"
	If RegExMatch(MapKey_Arr["Hotkeys"],Key_T)
		Return true
	Else
	{
		Key := Scope . Key
		MapKey_Arr["Hotkeys"] .= A_space . Key . A_Space
	}
	MapKey_Arr[Key] := Action
	Return true
}
MapKeyDelete(Key,Scope)
{
	Global MapKey_Arr
	If Scope = G
	{
		Key_T := TransHotkey(Key)
		Hotkey,IfWinActive
		Hotkey,%Key_T%,Off
	}
	If Scope = H
	{
		Key_T := TransHotkey(Key)
		Hotkey,IfWinActive,AHK_CLASS TTOTAL_CMD
		Hotkey,%Key_T%,Off
	}
	If Scope = G
		CombokeyDelete(Key)
	DelKey := "\s" . Scope . RegExReplace(Key,"\+|\?|\.|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0") . "\s"
	Mapkey_Arr["Hotkeys"] := RegExReplace(MapKey_Arr["Hotkeys"],DelKey)
}
GetConfig(Section,Key)
{
	Global ViatcIni
	IniRead,Getvar,%ViatcIni%,%Section%,%Key%
	If RegExMatch(Getvar,"^ERROR$")
		GetVar := CreateConfig(Section,key)
    ;Trimming leading and trailing white space is automatic when assigning a variable with only = 
    GetVar = %GetVar% 
	Return GetVar
}
SetConfig(Section,Key,Var)
{
	Global ViatcIni
	IniWrite,%Var%,%ViatcIni%,%Section%,%Key%
}
CreateConfig(Section,Key)
{
	Global ViatcIni
    If Not FileExist(ViATcIni)
    {
        ViATcIni :=  A_ScriptDir . "\viatc.ini"
        Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,ViATcIni,%ViATcIni%
        MsgBox, 
        (
A new, limited viatc.ini file was just created because the real file
was not found. You can search for the real one and put it into place. 
You can also download a default one. 
There is also one in Templates folder - it might be older than the newest.
        )
    }

	If Section = Configuration
    {
        If Key = TrayIcon
            SetVar := 1
        If Key = Vim
            SetVar := 1
        If Key = Toggle
            SetVar := "<LWin>F"
        If Key = GlobalTogg
            SetVar := 1
        If Key = Suspend
            SetVar := "<Alt>``"
        If Key = HistoryOfRename 
            SetVar := 1
        If Key = GlobalSusp
            SetVar := 0
        If Key = Startup
            SetVar := 0
        If Key = Service
            SetVar := 1
    	If Key = ComboTooltips
    		SetVar := 1
    	If Key = TranspHelp
    		SetVar := 0
    	If Key = Transparent
    		SetVar := 0
    	If Key = TranspVar
    		SetVar := 220
    	If Key = MaxCount
    		SetVar := 999
        If Key = HistoryOfRename
            SetVar := 0
        If Key = IsCapslockAsEscape
            SetVar := 0
    }

	If Section = Paths
    {
        If Key = TCEXE
            SetVar := "C:\Program Files\totalcmd\TOTALCMD64.EXE"
        If Key = TCINI
            SetVar := "C:\Users\" . %A_UserName% . "\AppData\Roaming\GHISLER\wincmd.ini"
        If Key = EditorArguments 
            SetVar := " -p --remote-tab-silent "
    }

	If Section = SearchEngine
    {
		If Key = Default
			SetVar := 1
        If Key = 1
            SetVar := "http://www.google.com/search?q={%1}"
        If Key = 2
            SetVar := "https://duckduckgo.com/html?q={%1}"
    }
	If Section = FancyVimRename
    {
		If Key = Enabled
			SetVar := 0
        If Key = Mode
            SetVar := 1
        If Key = UnselectExt
            SetVar := 1
    }
	If Section = Other
		If Key = LnkToDesktop
			SetVar := 1
    
	IniRead,GetVar,%ViatcIni%,%Section%,%Key%
	If Getvar = ERROR
		Iniwrite,%SetVar%,%ViatcIni%,%Section%,%Key%
	Return SetVar
}
ToggleMenu(a=0)
{
	Global TCMenuHandle
	WinGet,hwin,Id,AHK_CLASS TTOTAL_CMD
	If hwin
		MenuHandle := DllCall("GetMenu", "uint", hWin)
	If MenuHandle
	{
		DllCall("SetMenu", "uint", hWin, "uint", 0)
		TCmenuHandle := MenuHandle
	}
	Else
		DllCall("SetMenu", "uint", hWin, "uint", TCmenuHandle )
	if a
	{
		WinSet,Style,+0xC10000,AHK_CLASS TTOTAL_CMD
		DllCall("SetMenu", "uint", hWin, "uint", TCmenuHandle )
	}
}
HideControl()
{
	Global HideControl_arr,TcIni,TCmenuHandle
	if HideControl_arr["Toggle"]
	{
		HideControl_arr["Toggle"] := False
		if HideControl_arr["KeyButtons"]
			PostMessage 1075, 2911, 0,, AHK_CLASS TTOTAL_CMD
		if HideControl_arr["drivebar1"]
			PostMessage 1075, 2902, 0,, AHK_CLASS TTOTAL_CMD
		if HideControl_arr["DriveBar2"]
			PostMessage 1075, 2903, 0,, AHK_CLASS TTOTAL_CMD
		if HideControl_arr["DriveBarFlat"]
			PostMessage 1075, 2904, 0,, AHK_CLASS TTOTAL_CMD
		if HideControl_arr["InterfaceFlat"]
			PostMessage 1075, 2905, 0,, AHK_CLASS TTOTAL_CMD
		if HideControl_arr["DriveCombo"]
			PostMessage 1075, 2906, 0,, AHK_CLASS TTOTAL_CMD
		if HideControl_arr["DirectoryTabs"]
			PostMessage 1075, 2916, 0,, AHK_CLASS TTOTAL_CMD
		if HideControl_arr["XPthemeBg"]
			PostMessage 1075, 2923, 0,, AHK_CLASS TTOTAL_CMD
		if HideControl_arr["CurDir"]
			PostMessage 1075, 2907, 0,, AHK_CLASS TTOTAL_CMD
		if HideControl_arr["TabHeader"]
			PostMessage 1075, 2908, 0,, AHK_CLASS TTOTAL_CMD
		if HideControl_arr["StatusBar"]
			PostMessage 1075, 2909, 0,, AHK_CLASS TTOTAL_CMD
		if HideControl_arr["CmdLine"]
			PostMessage 1075, 2910, 0,, AHK_CLASS TTOTAL_CMD
		if HideControl_arr["HistoryHotlistButtons"]
			PostMessage 1075, 2919, 0,, AHK_CLASS TTOTAL_CMD
		if HideControl_arr["BreadCrumbBar"]
			PostMessage 1075, 2926, 0,, AHK_CLASS TTOTAL_CMD
		if HideControl_arr["ButtonBar"]
			PostMessage 1075,2901, 0,, AHK_CLASS TTOTAL_CMD
		WinSet,Style,+0xC10000,AHK_CLASS TTOTAL_CMD
		winActivate,AHK_CLASS TTOTAL_CMD
		Settimer,FS,off
		WinGet,hwin,Id,AHK_CLASS TTOTAL_CMD
		If hwin
			DllCall("SetMenu", "uint", hWin, "uint", TCmenuHandle )
	}
	Else
	{
		HideControl_arr["Toggle"] := True
		IniRead,v_KeyButtons,%TCINI%,LayOut,KeyButtons
		HideControl_arr["KeyButtons"] := v_KeyButtons
		If v_KeyButtons
			PostMessage 1075, 2911, 0,, AHK_CLASS TTOTAL_CMD
		IniRead,v_drivebar1,%TcIni%,layout,drivebar1
		HideControl_arr["drivebar1"] := v_drivebar1
		If v_DriveBar1
			PostMessage 1075, 2902, 0,, AHK_CLASS TTOTAL_CMD
		IniRead,v_DriveBar2,%TcIni%,Layout,DriveBar2
		HideControl_arr["DriveBar2"] := v_DriveBar2
		If v_DriveBar2
			PostMessage 1075, 2903, 0,, AHK_CLASS TTOTAL_CMD
		IniRead,v_DriveBarFlat,%TcIni%,Layout,DriveBarFlat
		HideControl_arr["DriveBarFlat"] := v_DriveBarFlat
		If v_DriveBarFlat
			PostMessage 1075, 2904, 0,, AHK_CLASS TTOTAL_CMD
		IniRead,v_InterfaceFlat,%TcIni%,Layout,InterfaceFlat
		HideControl_arr["InterfaceFlat"] := v_InterfaceFlat
		If v_InterfaceFlat
			PostMessage 1075, 2905, 0,, AHK_CLASS TTOTAL_CMD
		IniRead,v_DriveCombo,%TcIni%,Layout,DriveCombo
		HideControl_arr["DriveCombo"] := v_DriveCombo
		If v_DriveCombo
			PostMessage 1075, 2906, 0,, AHK_CLASS TTOTAL_CMD
		IniRead,v_DirectoryTabs,%TcIni%,Layout,DirectoryTabs
		HideControl_arr["DirectoryTabs"] := v_DirectoryTabs
		If v_DirectoryTabs
			PostMessage 1075, 2916, 0,, AHK_CLASS TTOTAL_CMD
		IniRead,v_XPthemeBg,%TcIni%,Layout,XPthemeBg
		HideControl_arr["XPthemeBg"] := v_XPthemeBg
		If v_XPthemeBg
			PostMessage 1075, 2923, 0,, AHK_CLASS TTOTAL_CMD
		IniRead,v_CurDir,%TcIni%,Layout,CurDir
		HideControl_arr["CurDir"] := v_CurDir
		If v_CurDir
			PostMessage 1075, 2907, 0,, AHK_CLASS TTOTAL_CMD
		IniRead,v_TabHeader,%TcIni%,Layout,TabHeader
		HideControl_arr["TabHeader"] := v_TabHeader
		If v_TabHeader
			PostMessage 1075, 2908, 0,, AHK_CLASS TTOTAL_CMD
		IniRead,v_StatusBar,%TcIni%,Layout,StatusBar
		HideControl_arr["StatusBar"] := v_StatusBar
		If v_StatusBar
			PostMessage 1075, 2909, 0,, AHK_CLASS TTOTAL_CMD
		IniRead,v_CmdLine,%TcIni%,Layout,CmdLine
		HideControl_arr["CmdLine"] := v_CmdLine
		If v_CmdLine
			PostMessage 1075, 2910, 0,, AHK_CLASS TTOTAL_CMD
		IniRead,v_HistoryHotlistButtons,%TcIni%,Layout,HistoryHotlistButtons
		HideControl_arr["HistoryHotlistButtons"] := v_HistoryHotlistButtons
		If v_HistoryHotlistButtons
			PostMessage 1075, 2919, 0,, AHK_CLASS TTOTAL_CMD
		IniRead,v_BreadCrumbBar,%TcIni%,Layout,BreadCrumbBar
		HideControl_arr["BreadCrumbBar"] := v_BreadCrumbBar
		If v_BreadCrumbBar
			PostMessage 1075, 2926, 0,, AHK_CLASS TTOTAL_CMD
		IniRead,v_ButtonBar	,%TcIni%,Layout,ButtonBar
		HideControl_arr["ButtonBar"] := v_ButtonBar
		If v_ButtonBar
			PostMessage 1075,2901, 0,, AHK_CLASS TTOTAL_CMD
		WinSet,Style,-0xC00000,AHK_CLASS TTOTAL_CMD
		winActivate,AHK_CLASS TTOTAL_CMD
	}
}
FS:
FS()
Return
FS()
{
	WinGet,hwin,Id,AHK_CLASS TTOTAL_CMD
	If hwin
		MenuHandle := DllCall("GetMenu", "uint", hWin)
	Else
		Settimer,FS,off
	If MenuHandle
		DllCall("SetMenu", "uint", hWin, "uint", 0)
}

Enter() ;  on Enter pressed {{{2
{
	Global MapKey_Arr,CommandInfo_Arr,ExecFile_Arr,SendText_Arr,TabsBreak

    Loop,8
    {
        ControlGetFocus,ThisControl,AHK_CLASS TTOTAL_CMD
        ;The bar with path above file list has ID = Window17 11 or 12  TInEdit1 in 32bit TC ClassNN: PathPanel1
        ;You can edit this bar if you click on it's empty space, or if you rename ".." at the top of the list
        If (( %ThisControl% = Edit1) or ( %ThisControl% = Edit2) or ( %ThisControl% = Window17))  ;!!!
        {
            ;MsgBox  ThisControl = [%ThisControl%]  on line %A_LineNumber% ;!!!
            Break
        }
        Sleep,50
    }

    ;Match_TCEdit := "^" . TCEdit . "$"   ;<-------good working
	;If RegExMatch(ThisControl,Match_TCEdit)
    If (( %ThisControl% = Edit1) or ( %ThisControl% = Edit2) or ( %ThisControl% = Window17))  ;!!!
	{
        TCEdit = %ThisControl%  ;!!! added
        ; ----- command line (like the ex mode in Vim)
		ControlGetText,CMD,%TCEdit%,AHK_CLASS TTOTAL_CMD
		If RegExMatch(CMD,"^:.*")
		{
			ControlGetPos,xn,yn,,hn,%TCEdit%,AHK_CLASS TTOTAL_CMD
			ControlSetText,%TCEdit%,,AHK_CLASS TTOTAL_CMD
			CMD := SubStr(CMD,2)
			If RegExMatch(CMD,"i)^se?t?t?i?n?g?\s*$")
			{
				Setting()
				Return
			}
			If RegExMatch(CMD,"i)^he?l?p?\s*")
			{
				Help()
				Return
			}
			If RegExMatch(CMD,"i)^re?l?o?a?d?\s*$")
			{
				ReloadVIATC()
				Return
			}
			If RegExMatch(CMD,"i)^ma?p?\s*$")
			{
				Map := MapKey_Arr["Hotkeys"]
				Stringsplit,ListMap,Map,%A_Space%
				Loop,% ListMap0
				{
					If ListMap%A_Index%
					{
						Action := MapKey_Arr[ListMap%A_Index%]
						If Action = <Exec>
						{
							EX := SubStr(ListMap%A_Index%,1,1) . TransHotkey(SubStr(ListMap%A_Index%,2))
							Action := "(" . ExecFile_Arr[EX] . ")"
						}
						If Action = <Text>
						{
							TX := SubStr(ListMap%A_Index%,1,1) . TransHotkey(SubStr(ListMap%A_Index%,2))
							Action := "{" . SendText_Arr[TX] . "}"
						}
						LM .= SubStr(ListMap%A_Index%,1,1) . "  " . SubStr(ListMap%A_Index%,2) . "  " . Action  . "`n"
					}
				}
				yn := yn - hn - ( ListMap0 * 8 )
				Tooltip,%LM%,%xn%,%yn%
				Settimer,<RemoveToolTipEx>,100
				Return
			}
			If RegExMatch(CMD,"i)^ma?p?\s*[^\s]*")
			{
				CMD1 := RegExReplace(CMD,"i)^ma?p?\s*")
				Key := SubStr(CMD1,1,RegExMatch(CMD1,"\s")-1)
				Action := SubStr(CMD1,RegExMatch(CMD1,"\s[^\s]")+1)
				yn := yn -  hn - 9
				If RegExMatch(CheckScope(key),"C")
					If Not MapKeyAdd(Key,Action,"C")
						Tooltip, The mapping failed `, action %Action% mistaken ,%xn%,%yn%
				Else
					Tooltip, The mapping is successful ,%xn%,%yn%
				Else
					If Not MapKeyAdd(Key,Action,"H")
						Tooltip, The mapping failed ,%xn%,%yn%
				Else
					Tooltip, The mapping is successful ,%xn%,%yn%
				Sleep,2000
				Tooltip
				Return
			}
			If RegExMatch(CMD,"i)^sma?p?\s*[^\s]*")
			{
				CMD1 := RegExReplace(CMD,"i)^sma?p?\s*")
				Key := SubStr(CMD1,1,RegExMatch(CMD1,"\s")-1)
				Action := SubStr(CMD1,RegExMatch(CMD1,"\s[^\s]")+1)
				yn := yn -  hn - 9
				If RegExMatch(Key,"^[^<][^>]+$|^<[^<>]*>[^<>][^<>]+$|^<[^<>]+><[^<>]+>.+$")
					Tooltip, The mapping failed `, Global hotkeys do not support Combo Keys ,%xn%,%yn%
				Else
					If Not MapKeyAdd(Key,Action,"G")
						Tooltip, The mapping failed ,%xn%,%yn%
				Else
					Tooltip, The mapping is successful ,%xn%,%yn%
				Sleep,2000
				Tooltip
				Return
			}
			If RegExMatch(CMD,"i)^qu?i?t?")
			{
				GoSub,<QuitTC>
				Return
			}
			If RegExMatch(CMD,"i)^e.*")
			{
				EditViATcIniFile()
				Return
			}
			yn := yn -  hn - 9
			Tooltip, Invalid command line ,%xn%,%yn%
            ControlSetText,Edit1,:,AHK_CLASS TTOTAL_CMD
            ControlSetText,Edit2,:,AHK_CLASS TTOTAL_CMD
            Send {Right}
			Sleep,2000
			Tooltip
		}
		Else
			ControlSend,%TCEdit%,{Enter},AHK_CLASS TTOTAL_CMD
	}
	Else
		ControlSend,%ThisControl%,{Enter},AHK_CLASS TTOTAL_CMD
} ; Enter() end }}}2

; --- ini file {{{2
CreateNewFile()
{
	Global ViatcIni
	If CheckMode()
	{
		Menu,CreateNewFile,Add
		Menu,CreateNewFile,DeleteAll
		Index := 0
		Loop,23
		{
			IniRead,file,%ViatcIni%,TemplateList,%A_Index%
			If file <> ERROR
			{
				Splitpath,file,,,ext
				ext := "." . ext
				Icon_file :=
				Icon_idx :=
				RegRead,filetype,HKEY_CLASSES_ROOT,%ext%
				If Not filetype
				{
					Loop,HKEY_CLASSES_ROOT,%ext%,2
						If RegExMatch(A_LoopRegName,".*\.")
							filetype := A_LoopRegName
				}
				RegRead,iconfile,HKEY_CLASSES_ROOT,%filetype%\DefaultIcon
				Loop,% StrLen(iconfile)
				{
					If RegExMatch(SubStr(iconfile,Strlen(iconfile)-A_index+1,1),",")
					{
						icon_file := SubStr(iconfile,1,Strlen(iconfile)-A_index)
						icon_idx := Substr(iconfile,Strlen(iconfile)-A_index+2,A_index)
						Break
					}
				}
				file := "&" . chr(64+A_Index) . ">>" . Substr(file,2,RegExMatch(file,"\)")-2)
				Menu,CreateNewFile,Add,%file%,CreateFile
				Menu,CreateNewFile,Icon,%file%,%icon_file%,%icon_idx%
				Index++
				File :=
			}
		}
		If Index > 1
			Menu,CreateNewFile,Add
		Menu,CreateNewFile,Add, folder (&W),MkDir
		Menu,CreateNewFile,Icon, folder (&W),%A_WinDir%\system32\Shell32.dll,-4
		Menu,CreateNewFile,Add, Blank file (&V),CreateFile
		Menu,CreateNewFile,Icon, Blank file (&V),%A_WinDir%\system32\Shell32.dll,-152
		Menu,CreateNewFile,Add, A shortcut (&Y),Shortcut
		Menu,CreateNewFile,Icon, A shortcut (&Y),%A_WinDir%\system32\Shell32.dll,-30
		Menu,CreateNewFile,Add
		Menu,CreateNewFile,Add, Add to new template (&X),template
		Menu,CreateNewFile,Icon, Add to new template (&X),%A_WinDir%\system32\Shell32.dll,-155
		Menu,CreateNewFile,Add, Configuration: edit viatc.ini at the bottom (&Z),<EditViATcIniFile>
		Menu,CreateNewFile,Icon, Configuration: edit viatc.ini at the bottom (&Z),%A_WinDir%\system32\Shell32.dll,-151
		ControlGetFocus,TLB,ahk_class TTOTAL_CMD
		ControlGetPos,xn,yn,,,%TLB%,ahk_class TTOTAL_CMD
		Menu,CreateNewFile,show,%xn%,%yn%
	}
}
MkDir:
PostMessage 1075, 907, 0,, ahk_class TTOTAL_CMD
Return
Shortcut:
PostMessage 1075, 1004, 0,, ahk_class TTOTAL_CMD
If LnkToDesktop
	Settimer,SetLnkToDesktop,50
Return
SetLnkToDesktop:
Loop,4
{
	If WinExist("AHK_CLASS TInpComboDlg")
	{
		ControlGetText,Path,TAltEdit1,AHK_CLASS TInpComboDlg
		Splitpath,Path,FileName
		NewFileName := A_Desktop . "\" . FileName
		ControlSetText,TAltEdit1,%NewFileName%,AHK_CLASS TInpComboDlg
		Break
	}
	Sleep,500
}
Settimer,SetLnkToDesktop,off
return

template:
template()
Return
template()
{
	Global CNF
	ClipSaved := ClipboardAll
	Clipboard :=
	SendMessage 1075, 2018, 0,, ahk_class TTOTAL_CMD
	ClipWait,2
	If Clipboard
		temp_File := Clipboard
	Else
		Return
	Clipboard := ClipSaved
	Filegetattrib,Attributes,%Temp_file%
	IfInString, Attributes, D
	{
		MsgBox ,, Add a new template, Please select the file
		Return
	}
	Splitpath,temp_file,,,Ext
	WinGet,hwndtc,id,AHK_CLASS TTOTAL_CMD
	Gui,new,+Theme +Owner%hwndtc% +HwndCNF
	Gui,Add,Text,x10 y10, Template name
	Gui,Add,Edit,x90 y8 w275,%ext%
	Gui,Add,Text,x10 y42, Template file
	Gui,Add,Edit,x90 y40 w275 h20 +ReadOnly,%temp_File%
	Gui,Add,button,x140 y68 default gTemp_save, OK (&O)
	Gui,Add,button,x200 y68 g<Cancel>, Cancel (&C)
	Gui,Show,, Create a new template
	Controlsend,edit1,{ctrl a},ahk_id %CNF%
	Controlsend,edit2,{end},ahk_id %CNF%
}
Temp_save:
temp_save()
Return
Temp_save()
{
	Global CNF,TCDir,ViatcIni
	ControlGettext,tempName,edit1,ahk_id %cnf%
	ControlGettext,tempPath,edit2,ahk_id %cnf%
	ShellNew := A_ScriptDir . "\Templates"
	;ShellNew := TCDir . "\ShellNew"
	If Not InStr(Fileexist(ShellNew),"D")
		FileCreateDir,%ShellNew%
	Filecopy,%tempPath%,%ShellNew%,1
	Splitpath,tempPath,FileName
	New := 1
	Loop,23
	{
		IniRead,file,%ViatcIni%,TemplateList,%A_Index%
		If file = ERROR
			Break
		New++
	}
	IniWrite,(%tempName%)\%FileName%,%ViatcIni%,TemplateList,%New%
	Gui,Destroy
	EmptyMem()
}
CreateFile:
CreateFile(SubStr(A_ThisMenuItem,5,Strlen(A_ThisMenuItem)))
Return
CreateFile(item)
{
	Global ViatcIni,TCDir,CNF_New
	ClipSaved := ClipboardAll
	Clipboard :=
	SendMessage 1075, 2029, 0,, ahk_class TTOTAL_CMD
	ClipWait,2
	If Clipboard
		NewPath := Clipboard
	Else
		Return
	Clipboard := ClipSaved
	If RegExMatch(NewPath,"^\\\\Computer$")
		Return
	If RegExMatch(NewPath,"i)\\\\Control panel$")
		Return
	If RegExMatch(NewPath,"i)\\\\Fonts$")
		Return
	If RegExMatch(NewPath,"i)\\\\Internet$")
		Return
	If RegExMatch(NewPath,"i)\\\\Printer$")
		Return
	If RegExMatch(NewPath,"i)\\\\Recycle bin$")
		Return
	Loop,23
	{
		IniRead,file,%ViatcIni%,TemplateList,%A_Index%
		Match := Substr(file,2,RegExMatch(file,"\)")-2)
		if RegExMatch(Match,item) Or RegExMatch(Item,"\(&V\)$")
		{
			If RegExMatch(Item,"\(&V\)$")
			{
				File := A_Temp . "\viatcTemp"
				If Fileexist(file)
					Filedelete,%File%
				FileAppend,,%File%,UTF-8
			}
			Else
				file := A_ScriptDir . "\Templates" . Substr(file,RegExMatch(file,"\)")+1,Strlen(file))
				;file := TCDir . "\ShellNew" . Substr(file,RegExMatch(file,"\)")+1,Strlen(file))
			If Fileexist(file)
			{
				Splitpath,file,filename,,fileext
				WinGet,hwndtc,id,AHK_CLASS TTOTAL_CMD
				Gui,new,+Theme +Owner%hwndtc% +HwndCNF_New
				Gui,Add,Text,hidden ,%file%
				Gui,Add,Edit,x10 y10 w340 h22 -Multi,%filename%
				Gui,Add,button,x200 y40 w70 gTemp_create Default, OK (&O)
				Gui,Add,button,x280 y40 w70 g<Cancel>, Cancel (&C)
				Gui,Show,w360 h70, create a new file
				Controlsend,edit1,{ctrl a},ahk_id %CNF_New%
				If Fileext
					Loop,% strlen(fileext)+1
						Controlsend,edit1,+{left},ahk_id %CNF_New%
			}
			Else
			{
				MsgBox  The template file has been moved or deleted
				IniDelete,%ViatcIni%,TemplateList,%A_Index%
			}
			Break
		}
	}
}
Temp_Create:
Temp_Create()
Return
Temp_Create()
{
	Global CNF_New
	ControlGetText,FilePath,Static1,AHK_ID %CNF_New%
	ControlGetText,NewFile,Edit1,AHK_ID %CNF_New%
	ClipSaved := ClipboardAll
	Clipboard :=
	SendMessage 1075, 2029, 0,, ahk_class TTOTAL_CMD
	ClipWait,2
	If Clipboard
		NewPath := Clipboard
	Else
		Return
	If RegExmatch(NewPath,"^\\\\Desktop$")
		NewPath := A_Desktop
	NewFile := NewPath . "\" . NewFile
	If Fileexist(NewPath)
	{
		Filecopy,%FilePath%,%NewFile%,1
		If ErrorLevel
			MsgBox  The file already exists
		Gui,Destroy
		EmptyMem()
	}
	Clipboard := ClipSaved
	ControlGetFocus,focus_control,AHK_CLASS TTOTAL_CMD
	MatchCtrl := "^" . TCListBox
	If RegExMatch(focus_control,MatchCtrl)
	{
		Splitpath,NewFile,NewFileName,,NewFileExt
		Matchstr := RegExReplace(newfileName,"\+|\?|\.|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0")
		Loop,100
		{
			ControlGet,outvar,list,,%focus_control%,AHK_CLASS TTOTAL_CMD
			If RegExMatch(outvar,Matchstr)
			{
				Matchstr := "^" . Matchstr
				Loop,Parse,Outvar,`n
				{
					If RegExMatch(A_LoopField,MatchStr)
					{
						Focus := A_Index - 1
						Break
					}
				}
				PostMessage, 0x19E, %Focus%, 1, %focus_control%, AHK_CLASS TTOTAL_CMD
				Break
			}
			Sleep,50
		}
	}
	If NewFileExt
		Run,%newFile%,,UseErrorLevel
	Else
		Postmessage,1075,904,0,,AHK_CLASS TTOTAL_CMD
	Return
}

<Cancel>:
Gui,Cancel
Return
EmptyMem(PID="AHK Rocks")
{
	pid:=(pid="AHK Rocks") ? DllCall("GetCurrentProcessId") : pid
	h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
	DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
	DllCall("CloseHandle", "Int", h)
}
Diff(String1,String2)
{
	String2 := "^" . RegExReplace(String2,"\+|\?|\.|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0") "$"
	If RegExMatch(String1,String2)
		Return True
	Else
		Return False
}

Setting() ; --- {{{1
{
	Global StartUp,Service,TrayIcon,Vim,GlobalTogg,Toggle,GlobalSusp,Susp,ComboTooltips,TranspHelp,Transparent,SearchEng,DefaultSE,ViATcIni,TCExe,TCINI,NeedReload,LnkToDesktop,HistoryOfRename,FancyVimRename, IsCapslockAsEscape,UseSystemClipboard
	NeedReload := 1
	Global ListView
	Global MapKey_Arr,CommandInfo_Arr,ExecFile_Arr,SendText_Arr
	Vim := GetConfig("Configuration","Vim")
	Gui,Destroy
	Gui,+Theme +hwndviatcsetting 
    ;Gui,+SBARS_SIZEGRIP
    Gui,+0x100A +0x40000
    Gui, +Resize  ; Make the window resizable.
    WinSet, Style, +Resize, A
    WinSet, Style, +WS_SIZEBOX, A
    WinSet, Style, +0x40000, A

    ;Gui, Color, 0xA0A0F0
	Gui,Add,GroupBox,x10 y526 h37 w170 cFF0000, ; viatc.ini file
    ;Gui, Add, Progress, x10 y529 h37 w170 BackgroundSilver Disabled
    Gui,Add,Text,x24 y539 w60, viatc.ini :
    Gui,Add,Button,x70 y535 w54 center g<BackupViATcIniFile>, &Backup
	Gui,Add,Button,x130 y535 w40 g<EditViATcIniFile>, &Edit
	Gui,Add,Button,x240 y535 w80 center Default g<GuiEnter>, &OK 
	Gui,Add,Button,x330 y535 w80 center g<GuiCancel>, &Cancel 
	;Gui,Add,Tab2,x10 y6 +theme h520 w405 center choose2, &General (&G) | Hotkeys (&H) | Paths (&P)
	Gui,Add,Tab2,x10 y6 +theme h520 w405 center choose2, &General  | &Hotkeys  | &Paths  | &Misc
	Gui,Add,GroupBox,x16 y32 H170 w390, Global Settings
	Gui,Add,CheckBox,x25 y50 h20 checked%startup% vStartup, &Startup VIATC
	Gui,Add,CheckBox,x180 y50 h20 checked%Service% vService, Background process  &1  
	Gui,Add,CheckBox,x25 y70 h20 checked%TrayIcon% vTrayIcon, System-tray &icon
	Gui,Add,CheckBox,x180 y70 h40 checked%Vim% vVim, Enable &ViATc mode at start, `nif unchecked, all is disabled till first Esc
	Gui,Add,Text,x25 y100 h20, Hotkey to &Activate/Minimize TC
	Gui,Add,Edit,x24 y120 h20 w140 vToggle ,%Toggle%
	Gui,Add,CheckBox,x180 y120 h20 checked%GlobalTogg% vGlobalTogg, &Global hotkey, so it will work outside TC too
	Gui,Add,Text,x25 y150 h20, Hotkey to &Enable/Disable ViATc
	Gui,Add,Edit,x25 y170 h20 w140 vSusp ,%Susp%
	Gui,Add,CheckBox,x180 y170 h20 checked%GlobalSusp% vGlobalSusp, Global hotkey &2
	Gui,Add,GroupBox,x16 y210 H310 w390, Other settings
	Gui,Add,Text,x25 y228 h20, &Website used to search for the selected file or folder:
	D := 1
	Loop,15
	{
		IniRead,SE,%ViATcINI%,SearchEngine,%A_Index%
		If SE = ERROR
			IniDelete,%ViATcINI%,SearchEngine,%A_Index%
		Else
		{
			IniDelete,%ViATcINI%,SearchEngine,%A_Index%
			If A_Index = %DefaultSE%
			{
				DefaultSE := D
				IniWrite,%D%,%ViATcIni%,SearchEngine,Default
			}
			IniWrite,%SE%,%ViATcIni%,SearchEngine,%D%
			SE_Arr .= SE . "|"
			D++
		}
	}
	D--
	If DefaultSE > %D%
	{
		DefaultSE := D
		IniWrite,%D%,%ViATcIni%,SearchEngine,Default
	}
	Gui,Add,ComboBox,x25 y246 h20 w326 choose%DefaultSE% AltSubmit vDefaultSE R5 hwndaa g<SetDefaultSE>,%SE_Arr%
	Gui,Add,Button,x356 y246 h20 w22 g<AddSearchEng>,&+
	Gui,Add,Button,x380 y246 h20 w22 g<DelSearchEng>,&-
	Gui,Add,CheckBox,x25 y280 h20 checked%ComboTooltips% vComboTooltips, Show tooltips after the first key of Combo Key  &3
	Gui,Add,CheckBox,x25 y309 h20 checked%transpHelp% vTranspHelp, &Transparent help interface (needs reload as all)
	Gui,Add,Button,x270 y305 h27 w120 Center g<Help>, Open VIATC Help   &4
    Gui,Add,CheckBox,x25 y340 h20 checked%HistoryOfRename% vHistoryOfRename, HistoryOf&Rename ; - see history_of_rename.txt
    Gui,Add,Link,x135 y343 h20, - see <a href="%A_ScriptDir%\history_of_rename.txt">history_of_rename.txt</a>
    Gui, Add, Button, x270 y340 w80 h21 gFancyR_history,  Edit   &5
    ;Gui,Add,Link,x135 y363 h20, - see <a href="%EditorPath% . %EditorArguments% . %HistoryOfRenamePath%">%HistoryOfRenamePath%</a>
    ;Gui,Add,CheckBox,x25 y370 h20 checked%FancyVimRename% vFancyVimRename, &Fancy Rename

    Gui,Add,CheckBox,x25 y400 h20 checked%IsCapslockAsEscape% vIsCapslockAsEscape, Capslock as Escape   &6

    ;Gui,Add,Button,x270 y405 h30 w120 Center g<BackupViATcIniFile>, &Backup viatc.ini file
    ;  (this checkbox not working yet)
    ;Gui, Add, Picture, x170 y420 w60 h-1, %A_ScriptDir%\viatc.ico

	Gui,Tab,2

	Gui,Add,GroupBox,x16 y32 h488 w390, 
	Gui,Add,text,x20 y340 h50, * column legend:`n  G - Global Key`n  H - Hotkey`n  C - Combo Key
	Gui,Add,text,x130 y336 h50, Right-click any item on the list to edit or delete, `nor select any item and press ---> ;the Delete button
    Gui,Add,Button,x285 y350 h20 w65 g<DeleItem>, &Delete
    Gui,Add,text,x130 y361 h20,      Double-click to edit.
    ;Gui,Add,Button,x350 y370 h40 w65 g<DeleItem>, Delete (&D)
	Gui,Add,text,x130 y375 h20, Add items below. How? Open the help window 
    Gui,Add,Button,x130 y390 h20 w50 Center g<Help>, &Help
	Gui,Add,text,x180 y390 h20,      and choose the fifth tab: Commands
	;Gui,Add,Button,x350 y420 h20 w50 Center g<Help>, (&Help)
	;Gui,Add,text,x330 y450 h20, choose the fifth `ntab: Commands
	Gui,Add,GroupBox,x16 y410 h110 w390, ; Adding commands
	Gui,Add,Text,x35 y423 h20, Hot&key
	Gui,Add,Edit,x78 y420 h20 w90 g<CheckGorH>
    Gui,Add,Button,x168 y420 w30 h19 g<PutShift>, Sh&ift
    Gui,Add,Button,x199 y420 w26 h19 g<PutCtrl>, Ct&rl
    Gui,Add,Button,x225 y420 w26 h19 g<PutAlt>, Al&t
    Gui,Add,Button,x250 y420 w32 h19 g<PutLWin>, L&Win
	Gui,Add,CheckBox,x289 y421 h20 vGlobalCheckbox , G&lobal
	Gui,Add,Button,x340 y420 w60 g<TestTH>, &Analyze
	Gui,Add,text,x22 y449 h20, Comma&nd
	Gui,Add,Edit,x78 y446 h20 w320
	Gui,Add,Button,x20 y470 h20 w80 g<ViatcCmd> ,    &1  ViATc ...
	Gui,Add,Button,x120 y470 h20 w80 g<TCCMD> ,    &2  TC ...
	Gui,Add,Button,x220 y470 h20 w80 g<RunFile>,   &3  Run  ...
	Gui,Add,Button,x320 y470 h20 w80 g<SendString>,&4  Send text ...
	Gui,Add,text,x22 y492 h20, Buttons 1,2,3,4 will fill-in the Command field above.
    Gui,Add,Button,x270 y492 h25 w130 g<CheckKey>, &Save Hotkey

	;Gui,Add,ListView,x16 y32 h300 w390 count20 sortdesc  -Multi vListView g<ListViewDK>,*| Hotkey | Command | Description
    ;the +0x40000 adds resizing
	Gui,Add,ListView,x16 y32 h300 w390 count20 -Multi vListView g<ListViewDK> +0x40000, # |*| Hotkey | Command | Description
	;Gui,Add,ListView,x16 y32 h300 w390 count20 sortdesc  -Multi vListView g<ListViewDK> +0x40000,*| Hotkey | Command | Description
	Lv_modifycol(3,60)
	Lv_modifycol(4,100)
	Lv_modifycol(5,400)
	lv := MapKey_Arr["Hotkeys"]
	Stringsplit,Index,lv,%A_Space%
    Index := Index0 - 1
	Loop,%Index%
	{
		If Index%A_Index%
		{
			Scope := SubStr(Index%A_Index%,1,1)
			Key := SubStr(Index%A_Index%,2)
			Action := MapKey_Arr[Index%A_Index%]
			Info := CommandInfo_Arr[Action]
			If Action = <Exec>
			{
				Action := " Run "
				Key_T := Scope . TransHotkey(Key)
				Info := ExecFile_Arr[key_T]
			}
			If Action = <Text>
			{
				Action := " Send text "
				Key_T := Scope . TransHotkey(Key)
				Info := SendText_Arr[key_T]
			}
            Num := Round(A_Index/2)
			LV_Add(vis,Num,Scope,Key,Action,Info)
		}
	}
    ; add last line because it is often obscured by a scrollbar
    LV_Add(vis," ","","","","")
    ;LV_Add(vis," ","","","","empty line because it is often obscured by a scrollbar")

	Gui,Tab,3
	Gui,Add,GroupBox,x16 y32 h480 w390, 
	Gui,Add,Text,x18 y35 h16 center,TC executable "TOTALCMD64.EXE" or "TOTALCMD.EXE" location :
	Gui,Add,Edit,x18 y55 h20 +ReadOnly w350,%TCEXE%
	Gui,Add,Button,x375 y53 w30 g<GuiTCEXE>, &1 ...
	Gui,Add,Text,x18 y100 h16 center,TC "wincmd.ini" file location :
	Gui,Add,Edit,x18 y120 h20 +ReadOnly w350,%TCINI%
	Gui,Add,Button,x375 y120 w30 g<GuiTCINI> , &2 ...
	Gui,Add,Text,x18 y165 h16 center,ViATc "viatc.ini" location (changing will move the current file) :
	Gui,Add,Edit,x18 y185 h20 +ReadOnly w350,%ViATcIni%
	Gui,Add,Button,x375 y185 w30 g<GuiViATcINI> , &3 ...
	Gui,Add,Text,x18 y230 h16 center,Editor's location. For vim find "gvim.exe" :
	Gui,Add,Edit,x18 y250 h20 vGuiEditorPath +ReadOnly w350,%EditorPath%
    Gui,Add,Button,x375 y250 w30 g<GuiEditorPath> , &4 ...
    Gui,Add,Text,x140 y280 h16 center, for a new tab in vim use:
    Gui,Add,Text,x381 y278 h16 center,  &5 
    Gui,Add,Edit,x262 y278 h18 +ReadOnly w105, -p --remote-tab-silent 
	Gui,Add,Text,x18 y280 h16 center,Editor's arguments :
	Gui,Add,Text,x381 y300 h16 center,  &6 
	Gui,Add,Edit,x18 y300 h20 w350 vGuiEditorArguments,%EditorArguments%
	Gui,Add,Text,x381 y350 h16 center,  &7 
    Gui,Add,Link,x315 y350 h20, <a href="C:\Windows\regedit.exe">regedit.exe</a> 
	Gui,Add,Text,x18 y350 h20 , Paths of ini files 2 and 3 are saved to the registry ;if changed 
	Gui,Add,Text,x381 y370 h16 center,  &8 
	Gui,Add,Edit,x18 y370 h20 +ReadOnly w350,Computer\HKEY_CURRENT_USER\Software\VIATC

	Gui,Tab,4
	;Gui,Add,GroupBox,x16 y32 h170 w390, Marks
	Gui,Add,GroupBox,x16 y32 h480 w390, ; whole tab

    Gui,Add,GroupBox,x20 y46 h37 w174 , ; marks.ini file
    Gui,Add,Text,x33 y59 w60, marks.ini :
    Gui,Add,Button,x90 y55 w54 center g<BackupMarksFile>, &1 Backup
	Gui,Add,Button,x150 y55 w40 g<EditMarksFile>, &2 Edit

	Gui,Add,GroupBox,x20 y86 h37 w174, ;wincmd.ini
    Gui,Add,Text,x33 y99 w60, wincmd.ini:
    Gui,Add,Button,x90 y95 w54 center g<BackupTCIniFile>,&3 Backup
	Gui,Add,Button,x150 y95 w40 g<EditTCIniFile>, &4 Edit

    Gui,Add,GroupBox,x226 y46 h37 w174 , ; user.ahk file
    Gui,Add,Text,x233 y59 w50, user.ahk :
    Gui,Add,Button,x292 y55 w54 center g<BackupUserFile>, &5 Backup
	Gui,Add,Button,x352 y55 w40 g<EditUserFile>, &6 Edit

    ;Gui,Add,Text,x185 y300 h16 center,  &V 
    Gui,Add, Picture, gGreet x170 y280 w60 h-1, %A_ScriptDir%\viatc.ico
	Gui,Add,Button,x170 y360 w60 gWisdom, &Wisdom


	;Gui,Add,GroupBox,x26 y400 h112 w370, Internet
	Gui,Add,GroupBox,x46 y400 h100 w330, Internet
	Gui,Add,Button,x130 y420 w140 vCheckForUpdatesButton gCheckForUpdates, Check for &updates
	;Gui,Add,Text,x72 y450 h16 center,  &ViATc Website: 
    ;Gui,Add,Link,x149 y450 h20, <a href="https://magicstep.github.io/viatc/">magicstep.github.io/viatc</a> 
	Gui,Add,Text,x120 y450 h16 center,  &Visit: 
    Gui,Add,Link,x145 y450 h20, <a href="https://magicstep.github.io/viatc/">magicstep.github.io/viatc</a> 
	;Gui,Add,Text,x120 y480 h16 center,  &What's New: 
    ;Gui,Add,Link,x185 y480 h20, <a href="https://magicstep.github.io/viatc/WhatsNew/">Version Log</a> 
	Gui,Add,Text,x120 y480 h16 center, Version &Log:
    Gui,Add,Link,x185 y480 h20, <a href="https://magicstep.github.io/viatc/WhatsNew/">What's New</a> 
    

	Gui,Tab
	Gui,Add,Button,x280 y5 w30 h20 center hidden g<ChangeTab>,&G
	Gui,Add,Button,x280 y5 w30 h20 center hidden g<ChangeTab>,&H
	Gui,Add,Button,x280 y5 w30 h20 center hidden g<ChangeTab>,&P
	Gui,Add,Button,x280 y5 w30 h20 center hidden g<ChangeTab>,&M
	Gui,Show,h570 w420,Settings   VIATC %Version% 
}

;gGreet
Greet:
KeyWait, LButton, Up
MsgBox Thank you for using ViATc.
Return

;gWisdom
Wisdom:
Array := ["If you had a fortune cookie what would you like it to say?"
         ,"If you could speak for 1 minute and be heard by everybody in the world, what would you say?"
            ,"If you could make one thing come true for all the souls on the planet what would it be?" 
             ,"What is it that you love the most about yourself?"
              ,"What is the ultimate goal of a human being?"
                 ,"What thing doesn't exist but should?"
                   ,"There's always time to feel good."
                       ,"Remember to take breaks."
                           ,"All is well." ]
Random, rand, 1,Array.Length()
MsgBox  % Array[rand] %rand%
Return

GuiContextMenu:
If A_GuiControl <> ListView
	Return
EventInfo := A_EventInfo
Menu,RightClick,Add
Menu,RightClick,DeleteAll
Menu,RightClick,Add,Edit (&E),<EditItem>
Menu,RightClick,Add,Delete (&D),<DeleItem>
Menu,RightClick,Show
Return

;exit windows on ESC
GuiEscape:
Tooltip
Gui,Destroy
;If NeedReload
    ;GoSub,<ReloadVIATC>
;Else
    EmptyMem()
Return


<BackupViATcIniFile>:
BackupViATcIniFile()
Return

BackupViATcIniFile()
{
    FormatTime, CurrentDateTime,, yyyy-MM-dd_hh;mm.ss
    NewFile=%VIATCINI%_%CurrentDateTime%_backup.ini
    FileCopy,%VIATCINI%,%NewFile%
    If Fileexist(NewFile)
        Tooltip Backup of settings succesfull
    Else
        MsgBox Backup of settings failed
    
    Sleep,1400
    Tooltip
    Return
    ;GuiControlGet,VarPos,Pos,Edit4
    ;Tooltip, The mapping failed ,%VarPosX%,%VarPosY%
}

<EditViATcIniFile>:
If SendPos(0)
	EditViATcIniFile()
Return

EditViATcIniFile()
{
	Global viatcini
	match = `"$0
	INI := Regexreplace(viatcini,".*",match)
	If Fileexist(EditorPath)
		editini := EditorPath . EditorArguments . ini 
	Else
		editini := "notepad.exe" . a_space . ini
	Run,%editini%,,UseErrorLevel
	Return
}

<BackupMarksFile>:
BackupMarksFile()
Return

BackupMarksFile()
{
    FormatTime, CurrentDateTime,, yyyy-MM-dd_hh;mm.ss
    NewFile=%MarksPath%_%CurrentDateTime%_backup.ini
    FileCopy,%MarksPath%,%NewFile%
    If Fileexist(NewFile)
        Tooltip Backup of marks succesfull
    Else
        MsgBox Backup of marks failed
    
    Sleep,1400
    Tooltip
    Return
}

<EditMarksFile>:
If SendPos(0)
    EditMarksFile()
Return

EditMarksFile()
{
	Global MarksPath
	match = `"$0
	file := Regexreplace(MarksPath,".*",match)
	If Fileexist(EditorPath)
		editfile := EditorPath . EditorArguments . file
	Else
		editfile := "notepad.exe" . a_space . file
	Run,%editfile%,,UseErrorLevel
	Return
}

<BackupTCIniFile>:
BackupTCIniFile()
Return

BackupTCIniFile()
{
    global TCIni
    FormatTime, CurrentDateTime,, yyyy-MM-dd_hh;mm.ss
    NewFile=%TCIni%_%CurrentDateTime%_backup.ini
    FileCopy,%TCIni%,%NewFile%
    If Fileexist(NewFile)
        Tooltip Backup of wincmd.ini succesfull. `n%NewFile%
        ;MsgBox,,, Backup of wincmd.ini succesfull. `n`nIt is now in`n%NewFile%
    Else
        MsgBox,0x10,, Backup of wincmd.ini failed. `n`nCouldn't copy %TCIni% `nto %NewFile%
    ;Sleep,1400
    ;Tooltip
    Return
}

<EditTCIniFile>:
If SendPos(0)
    EditTCIniFile()
Return

EditTCIniFile()
{
	Global TCIni
    ; $0 is the substring that matches the entire pattern
	match = `"$0
	file := Regexreplace(TCIni,".*",match)
	If FileExist(EditorPath)
		editfile := EditorPath . EditorArguments . file
	Else
		editfile := "notepad.exe" . a_space . file
	Run,%editfile%,,UseErrorLevel
	Return
}


<BackupUserFile>:
BackupUserFile()
Return

BackupUserFile()
{
    FormatTime, CurrentDateTime,, yyyy-MM-dd_hh;mm.ss
    NewFile=%UserFilePath%_%CurrentDateTime%_backup.ahk
    FileCopy,%UserFilePath%,%NewFile%
    If Fileexist(NewFile)
        Tooltip Backup of user.ahk succesfull
    Else
        MsgBox Backup of user.ahk failed
    
    Sleep,1400
    Tooltip
    Return
}

; Edit user.ahk
<EditUserFile>:
	Global UserFilePath
	match = `"$0
	file := Regexreplace(UserFilePath,".*",match)
	If Fileexist(EditorPath)
		editfile := EditorPath . EditorArguments . file
	Else
		editfile := "notepad.exe" . a_space . file
	Run,%editfile%,,UseErrorLevel
Return




<AddSearchEng>:
AddSearchEng()
Return
AddSearchEng()
{
	Global ViATcSetting,ViATcIni
	ControlgetText,SE,Edit3,AHK_ID %VIATCSetting%
	Controlget,SEList,list,,combobox1,AHK_ID %VIATCSetting%
	Stringsplit,List,SEList,`n
	List0++
	GuiControl,,combobox1,%SE%
	IniWrite,%SE%,%VIATCINI%,SearchEngine,%List0%
    Tooltip The search engine added.
    Sleep,1400
    Tooltip
}
<DelSearchEng>:
DelSearchEng()
Return
DelSearchEng()
{
	Global ViATcSetting,ViATcIni,DefaultSE
	Controlget,SEList,list,,combobox1,AHK_ID %VIATCSetting%
	IniDelete,%ViATcIni%,SearchEngine,%DefaultSE%
	Stringsplit,List,SEList,`n
	Loop,%List0%
	{
		If A_Index = %DefaultSE%
			Continue
		NewSEList .= "|" . List%A_Index%
	}
	DefaultSE--
	GuiControl,,combobox1,%NewSEList%
	IniWrite,%DefaultSE%,%VIATCINI%,SearchEngine,Default
    Tooltip The search engine removed.
    Sleep,1400
    Tooltip
}
<SetDefaultSE>:
SetDefaultSE()
Return
SetDefaultSE()
{
	Global ViATcSetting,DefaultSE,ViATcIni,SearchEng
	GuiControlget,SE,,combobox1,AHK_ID %VIATCSetting%
	If RegExMatch(SE,"^\d+$")
	{
		DefaultSE := SE
		IniRead,SearchEng,%VIATCINI%,SearchEngine,%DefaultSE%
		IniWrite,%SE%,%VIATCINI%,SearchEngine,Default
	}
}
; on OK pressed
<GuiEnter>:
CheckKey()  ;this is what Save button does on the Settings middle tab
Gui,Submit
Global EditorPath, EditorArguments
EditorPath := GuiEditorPath
;Trimming leading and trailing white space is automatic when assigning a variable with only = 
EditorArguments = GuiEditorArguments
IniWrite,%TrayIcon%,%ViATcIni%,Configuration,TrayIcon
IniWrite,%Vim%,%ViATcIni%,Configuration,Vim
IniWrite,%Toggle%,%ViATcIni%,Configuration,Toggle
IniWrite,%Susp%,%ViATcIni%,Configuration,Suspend
IniWrite,%GlobalTogg%,%ViATcIni%,Configuration,GlobalTogg
IniWrite,%GlobalSusp%,%ViATcIni%,Configuration,GlobalSusp
IniWrite,%StartUp%,%ViATcIni%,Configuration,StartUp
IniWrite,%Service%,%ViATcIni%,Configuration,Service
IniWrite,%ComboTooltips%,%ViATcIni%,Configuration,ComboTooltips
IniWrite,%TranspHelp%,%ViATcIni%,Configuration,TranspHelp
IniWrite,%HistoryOfRename%,%ViATcIni%,Configuration,HistoryOfRename
IniWrite,%FancyVimRename%,%ViATcIni%,FancyVimRename,Enabled
IniWrite,%IsCapslockAsEscape%,%ViATcIni%,Configuration,IsCapslockAsEscape
IniWrite,%GuiEditorPath%,%ViATcIni%,Paths,EditorPath
IniWrite,%GuiEditorArguments%,%ViATcIni%,Paths,EditorArguments
EditorArguments :=A_space . EditorArguments . A_space

If NeedReload
	GoSub,<ReloadVIATC>
Else
	GoSub,<ConfigVar>
Return
<GuiCancel>:
Gui,Destroy
EmptyMem()
Return
<ListViewDK>:
If RegExMatch(A_GuiEvent,"DoubleClick")
{
	EventInfo := A_EventInfo
	EditItem()
}
Tooltip
Return
<EditItem>:
EditItem()
Return
EditItem()
{
	Global EventInfo,VIATCSetting
	If EventInfo
	{
		LV_GetText(Scope,EventInfo,2)
		LV_GetText(Key,EventInfo,3)
		LV_GetText(Action,EventInfo,4)
		LV_GetText(Info,EventInfo,5)

		If RegExMatch(Scope,"G")
            Guicontrol,,GlobalCheckbox, 1
		If RegExMatch(Scope,"[C|H]")
			GuiControl,,GlobalCheckbox,0
		If Key
			GuiControl,,Edit4,%Key%
		If Action =  run
			Action := "(" . Info . ")"
		If Action =  Send text
			Action := "{" . Info . "}"
		If Action
			GuiControl,,Edit5,%Action%
	}
}
<DeleItem>:
DeleItem()
Return
DeleItem()
{
	Global EventInfo,ViATcIni,MapKey_Arr,VIATCSetting
	ControlGet,Line,List,Count Focused,SysListView321,AHK_ID %VIATCSetting%
	EventInfo := Line
	If EventInfo
	{
		LV_GetText(Get,EventInfo,1)
		LV_GetText(GetText,EventInfo,2)
		Lv_Delete(EventInfo)
		Key := A_Space . Get . GetText . A_Space
		RegExReplace(MapKey_Arr["Hotkeys"],Key)
		MapKeyDelete(GetText,Get)
		If Get = H
			IniDelete,%ViATcIni%,Hotkey,%GetText%
		If Get = G
			IniDelete,%ViATcIni%,GlobalHotkey,%GetText%
		If Get = C
			IniDelete,%ViATcIni%,ComboKey,%GetText%
	}
}

; for the button "1 ViATc ..."
<ViatcCmd>:
VimCMD()
Return
VimCMD()
{
	Global ViatcCommand,CommandInfo_Arr
	Stringsplit,kk,ViatcCommand,%A_Space%
	Gui,New
	Gui,+HwndViatcCmdHwnd
	Gui,Add,ListView,w740 h700 -Multi g<GetViatcCmd>, # | Command | Description
	Lv_delete()
	Lv_modifycol(1,40)
	Lv_modifycol(2,155)
	Lv_modifycol(3,520)
	Loop,%kk0%
	{
		key := kk%A_Index%
		Info := CommandInfo_Arr[key]
		LV_ADD(vis,A_Index-1,key,info)
	}
	kk := kk%0% - 1
	lv_delete(1)
	Gui, Add, Button, x280 y720 w60 h24 Default g<ViatcCmdB1>, &OK
	Gui, Add, Button, x350 y720 w60 h24 g<Cancel>, &Cancel
	Gui,Show,,VIATC Command
}
<ViatcCmdB1>:
ControlGet,EventInfo,List, Count Focused,SysListView321,ahk_id %ViatcCmdHwnd%
lv_gettext(actiontxt,EventInfo,2)
ControlSetText,edit5,%actiontxt%,AHK_ID %VIATCSetting%
Gui,Destroy
EmptyMem()
Winactivate,AHK_ID %VIATCSetting%
Return
<GetViatcCmd>:
lv_gettext(actiontxt,A_EventInfo,2)
ControlSetText,edit5,%actiontxt%,AHK_ID %VIATCSetting%
Gui,Destroy
EmptyMem()
Winactivate,AHK_ID %VIATCSetting%
Return
;selecting internal TC command for Settings button 2
<TCCMD>:
tccmd()
Return
tccmd()
{
	Global VIATCSetting,TCEXE
	Ifwinexist,AHK_CLASS TTOTAL_CMD
	Winactivate,AHK_CLASS TTOTAL_CMD
	Else
	{
		Run,%TCEXE%
		WinWait,AHK_CLASS TTOTAL_CMD,1
		Winactivate,AHK_CLASS TTOTAL_CMD
	}
	Cli := ClipboardAll
	Clipboard :=
	Postmessage 1075, 2924, 0,, ahk_class TTOTAL_CMD
	Clipwait,0.5
	Loop
	{
		If Clipboard
			Break
		Else
			Ifwinexist,ahk_class TCmdSelForm
		Clipwait,0.5
		Else
			Break
	}
	If Clipboard
	{
		actiontxt := Clipboard
		actiontxt := Regexreplace(actiontxt,"^cm_","<") . ">"
	}
	Else
		actiontxt :=
	Clipboard := cli
	If actiontxt
		GuiControl,text,edit5,%actiontxt%
	Winactivate,AHK_ID %VIATCSetting%
}
<RunFile>:
SelectFile()
Return
SelectFile()
{
	Global VIATCSetting
	Fileselectfile,outvar,,,VIATC run
	If outvar
		outvar := "(" . outvar . ")"
	Winactivate,AHK_ID %VIATCSetting%
	GuiControl,text,edit5,%outvar%
}
<SendString>:
GetSendString()
Return
GetSendString()
{
	Global VIATCSetting,VIATCSettingString
	Gui,New
	Gui,+Owner%VIATCSetting%
	Gui,Add,Edit,w550 h20
	Gui,Add,Button,x390 y30 h20 g<GetSendStringEnter> Default, OK (&O)
	Gui,Add,Button,x457 y30 h20 g<GetSendStringCancel>, Cancel (&C)
	Gui,Add,Text,x11 y30 h20, Enter some text to be later placed on demand into a TC command line.
	Gui,Show,,VIATC. text
}
<GetSendStringEnter>:
GuiControlGet,txt4,,Edit1
if txt4
	txt4 := "{" . txt4 . "}"
ControlSetText,edit5,%txt4%,AHK_ID %VIATCSetting%
GUi,Destroy
EmptyMem()
Return
<GetSendStringCancel>:
GUi,Destroy
EmptyMem()
Winactivate,AHK_ID %VIATCSetting%
Return
<GuiTCEXE>:
GuiTCEXE()
return
GuiTCExe()
{
	Global TCEXE,VIATCSetting
	Fileselectfile,TCEXE,3,C:\Program Files\totalcmd\, Select "TOTALCMD64.EXE" or "TOTALCMD.EXE",*.exe
	If ErrorLevel
		Return
    SetConfig("Paths","TCPath",TCEXE)
	;Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,InstallDir,%TCEXE%
	GuiControl,text,Edit6,%TCEXE%
}
<GuiTCIni>:
GuiTCIni()
return
GuiTCIni()
{
	Global TCINI,VIATCSetting
	Fileselectfile,TCINI,3,C:\Users\%A_UserName%\AppData\Roaming\GHISLER\, Select the "wincmd.ini" file,*.ini
	If ErrorLevel
		Return
	Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,TCIni,%TCINI%
	GuiControl,text,Edit7,%TCINI%
}
<GuiViATcIni>:
GuiViATcIni()
return
GuiViATcIni()
{
	Global ViATcIni,VIATCSetting
	Splitpath,ViATcINI,,ViATcINIDir
	Fileselectfolder,NewDir,,3,ViATc.ini  Save as
	If ErrorLevel
		Return
	If Not Fileexist(NewDir)
		FileCreateDir,%NewDir%
	FileMove,%ViATcINI%,%NewDir%\viatc.ini
	ViATcINI := NewDir . "\ViATc.ini"
	Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,ViATcINI,%ViATcINI%
	GuiControl,text,Edit8,%ViATcINI%
	GoSub,<ReloadVIATC>
}

<GuiEditorPath>:
GuiEditorPath()
return
GuiEditorPath()
{
	Global EditorPath,VIATCSetting
	Fileselectfile,EditorPath,3,C:\Program Files (x86)\Vim\, Select the gvim.exe file or any other editor,*.exe
	If ErrorLevel
		Return
    SetConfig("Paths","EditorPath",EditorPath)
	GuiControl,text,Edit9,%EditorPath%
}

<CheckGorH>:
CheckGorH()
Tooltip
Return
CheckGorH()
{
	Global ViATcSetting
	GuiControlGet,Key,,Edit4,AHK_CLASS %ViATcSetting%
	If Key
		If RegExMatch(CheckScope(key),"C")
			GuiControl,Disable,GlobalCheckbox
	Else
		GuiControl,Enable,GlobalCheckbox
	Else
		GuiControl,Enable,GlobalCheckbox
}


<PutShift>:
   PutShift()
Return
PutShift()
{
    GuiControl,text,edit4,<Shift>
}

<PutCtrl>:
   PutCtrl()
Return
PutCtrl()
{
    GuiControl,text,edit4,<Ctrl>
}

<PutAlt>:
   PutAlt()
Return
PutAlt()
{
    GuiControl,text,edit4,<Alt>
}

<PutLWin>:
   PutLWin()
Return
PutLWin()
{
    GuiControl,text,edit4,<LWin>
}

<CheckKey>:
CheckKey()
Return
CheckKey()
{
	Global VIATCSetting,ViATcIni,MapKey_Arr,ExecFile_Arr,SendText_Arr,CommandInfo_Arr,NeedReload
	GuiControlGet,Scope,,GlobalCheckbox,AHK_CLASS %ViATcSetting%
	GuiControlGet,Key,,Edit4,AHK_CLASS %ViATcSetting%
	GuiControlGet,Action,,Edit5,AHK_CLASS %ViATcSetting%
	If Scope
		Scope := "G"
	Else
		Scope := "H"
	If RegExMatch(CheckScope(key),"C")
	{
		Scope := "C"
		GuiControl,,GlobalCheckbox,0
	}
	If Action And Key
	{
		NeedReload := 1
		If RegExMatch(Scope,"i)G")
		{
			If MapKeyAdd(Key,Action,Scope)
				Iniwrite,%Action%,%ViatcIni%,GlobalHotkey,%Key%
			Else
			{
				GuiControlGet,VarPos,Pos,Edit4
				Tooltip, The mapping failed ,%VarPosX%,%VarPosY%
				Sleep,2000
				Tooltip
				Return
			}
		}
		If RegExMatch(Scope,"i)H")
		{
			If MapKeyAdd(Key,Action,Scope)
				Iniwrite,%Action%,%ViatcIni%,Hotkey,%Key%
			Else
			{
				GuiControlGet,VarPos,Pos,Edit4
				Tooltip, The mapping failed ,%VarPosX%,%VarPosY%
				Sleep,2000
				Tooltip
				Return
			}
		}
		If RegExMatch(Scope,"i)C")
		{
			If MapKeyAdd(Key,Action,Scope)
				Iniwrite,%Action%,%ViatcIni%,ComboKey,%Key%
			Else
			{
				GuiControlGet,VarPos,Pos,Edit4
				Tooltip, The mapping failed ,%VarPosX%,%VarPosY%
				Sleep,2000
				Tooltip
				Return
			}
		}
		Loop,% LV_GetCount()
		{
			LV_GetText(GetScope,A_Index,1)
			LV_GetText(GetKey,A_Index,2)
			LV_GetText(GetAction,A_Index,3)
			Scope_M := "i)" . Scope
			Key_M := "i)" . RegExReplace(Key,"\+|\?|\.|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0")
			Action_M := "i)" . RegExReplace(Action,"\+|\?|\.|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0")
			If RegExMatch(GetScope,Scope_M) AND RegExMatch(GetKey,Key_M) AND RegExMatch(GetAction,Action_M)
				Return
			If RegExMatch(GetScope,Scope_M) AND RegExMatch(GetKey,Key_M) AND Not RegExMatch(GetAction,Action_M)
			{
				Info := CommandInfo_Arr[Action]
				If RegExMatch(Action,"^\(.*\)$")
				{
					Action := " run "
					Key_T := Scope . TransHotkey(Key)
					Info := ExecFile_Arr[key_T]
				}
				If RegExMatch(Action,"^\{.*\}$")
				{
					Action := " Send text "
					Key_T := Scope . TransHotkey(Key)
					Info := SendText_Arr[key_T]
				}
				Lv_Modify(A_Index,vis,Scope,Key,Action,Info)
				Return
			}
		}
		Info := CommandInfo_Arr[Action]
		If RegExMatch(Action,"^\(.*\)$")
		{
			Action := " run "
			Key_T := Scope . TransHotkey(Key)
			Info := ExecFile_Arr[key_T]
		}
		If RegExMatch(Action,"^\{.*\}$")
		{
			Action := " Send text "
			Key_T := Scope . TransHotkey(Key)
			Info := SendText_Arr[key_T]
		}
		LV_Add(vis,Scope,Key,Action,Info)
	}
	Else
	{
		GuiControlGet,VarPos,Pos,Edit4
		;Tooltip, Shortcuts or commands are empty ,%VarPosX%,%VarPosY%
		;Sleep,2000
		;Tooltip
        ToolTip, Shortcuts or commands are empty ,%VarPosX%,%VarPosY%
        SetTimer, RemoveToolTip, -1500
        return
        RemoveToolTip:
        ToolTip
        return
	}
}
<ChangeTab>:
ChangeTab()
Return
ChangeTab()
{
	If RegExMatch(A_GuiControl,"G")
		GuiControl,choose,SysTabControl321,1
	If RegExMatch(A_GuiControl,"H")
		GuiControl,choose,SysTabControl321,2
	If RegExMatch(A_GuiControl,"P")
		GuiControl,choose,SysTabControl321,3
	If RegExMatch(A_GuiControl,"M")
		GuiControl,choose,SysTabControl321,4
}
; --- analysis {{{2
<TestTH>:
TH()
Return
TH()
{
	;GuiControlGet,Scope,,Button25,AHK_CLASS %ViATcSetting%
    GuiControlGet,Scope,,GlobalCheckbox,AHK_CLASS %ViATcSetting%
    ;Gui, Submit, NoHide ;this command submits the guis' datas' state
    ;Scope = GlobalCheckbox 

	GuiControlGet,Key,,Edit4,AHK_CLASS %ViATcSetting%
	if key
	{
		If Scope
			KeyType := "Global Key"
		Else
			KeyType := "Hotkey"
		If RegExMatch(CheckScope(key),"C")
			KeyType := "Combo Key"
		Msg :=  KeyType . "`n"
		Key1 := TransHotkey(Key,"First")
		Msg .= "1 Key :" . Key1 . "`n"
		Key2 := TransHotkey(Key,"ALL")
		KeyT := SubStr(Key2,Strlen(key1)+1)
		Stringsplit,T,KeyT
		N := 2
		Loop,%T0%
		{
			Msg .= " " . N . " Key :" . T%A_index% . "`n"
			N++
		}
		GuiControlGet,VarPos,Pos,Edit4
		VarPosY := VarPosY - VarPosH - ( T0 * 17)
		Tooltip,%Msg%,%VarPosX%,%VarPosY%
		Settimer,<RemoveTTEx>,5000
	}
	else
	{
		Msg := " Please enter the hotkey to be analyzed in the hotkey field "
		GuiControlGet,VarPos,Pos,Edit4
		VarPosY := VarPosY - VarPosH + 17
		Tooltip,%Msg%,%VarPosX%,%VarPosY%
		Settimer,<RemoveTTEx>,2500
	}
}
return
<RemoveTTEx>:
SetTimer,<RemoveTTEx>, Off
ToolTip
return
<RemoveTT>:
Ifwinnotactive,AHK_ID %ViATcSetting%
{
	SetTimer,<RemoveTT>, Off
	ToolTip
}
return

Help() ; --- Help {{{1  
{
	Global TranspHelp,HelpInfo_Arr
	Gui,New
	Gui,+HwndVIATCHELP
    Gui, +Resize  ; Make the window resizable.
	Gui,Font,s8,Arial Bold
	Gui,Add,Text,x12 y10 w30 h18 center Border g<ShowHelp>,Esc
	Gui,Add,Text,x52 y10 w26 h18 center Border g<ShowHelp>,F1
	Gui,Add,Text,x80 y10 w26 h18 center Border g<ShowHelp>,F2
	Gui,Add,Text,x108 y10 w26 h18 center Border g<ShowHelp>,F3
	Gui,Add,Text,x136 y10 w26 h18 center Border g<ShowHelp>,F4
	Gui,Add,Text,x164 y10 w26 h18 center Border g<ShowHelp>,F5
	Gui,Add,Text,x192 y10 w26 h18 center Border g<ShowHelp>,F6
	Gui,Add,Text,x220 y10 w26 h18 center Border g<ShowHelp>,F7
	Gui,Add,Text,x248 y10 w26 h18 center Border g<ShowHelp>,F8
	Gui,Add,Text,x276 y10 w26 h18 center Border g<ShowHelp>,F9
	Gui,Add,Text,x304 y10 w26 h18 center Border g<ShowHelp>,F10
	Gui,Add,Text,x332 y10 w26 h18 center Border g<ShowHelp>,F11
	Gui,Add,Text,x360 y10 w26 h18 center Border g<ShowHelp>,F12
	Gui,Add,Text,x12 y35 w22 h18 center Border g<ShowHelp>,``~
	Gui,Add,Text,x36 y35 w22 h18 center Border g<ShowHelp>,1!
	Gui,Add,Text,x60 y35 w22 h18 center Border g<ShowHelp>,2@
	Gui,Add,Text,x84 y35 w22 h18 center Border g<ShowHelp>,3#
	Gui,Add,Text,x108 y35 w22 h18 center Border g<ShowHelp>,4$
	Gui,Add,Text,x132 y35 w22 h18 center Border g<ShowHelp>,5`%
	Gui,Add,Text,x156 y35 w22 h18 center Border g<ShowHelp>,6^
	Gui,Add,Text,x180 y35 w22 h18 center Border g<ShowHelp>,7&
	Gui,Add,Text,x204 y35 w22 h18 center Border g<ShowHelp>,8*
	Gui,Add,Text,x228 y35 w22 h18 center Border g<ShowHelp>,9(
	Gui,Add,Text,x252 y35 w22 h18 center Border g<ShowHelp>,0)
	Gui,Add,Text,x276 y35 w22 h18 center Border g<ShowHelp>,-_
	Gui,Add,Text,x300 y35 w22 h18 center Border g<ShowHelp>,=+
	Gui,Add,Text,x324 y35 w62 h18 center Border g<ShowHelp>,Backspace
	Gui,Add,Text,x12 y55 w40 h18 center Border g<ShowHelp>,Tab
	Gui,Add,Text,x54 y55 w22 h18 center Border g<ShowHelp>,Q
	Gui,Add,Text,x78 y55 w22 h18 center Border g<ShowHelp>,W
	Gui,Add,Text,x102 y55 w22 h18 center Border g<ShowHelp>,E
	Gui,Add,Text,x126 y55 w22 h18 center Border g<ShowHelp>,R
	Gui,Add,Text,x150 y55 w22 h18 center Border g<ShowHelp>,T
	Gui,Add,Text,x174 y55 w22 h18 center Border g<ShowHelp>,Y
	Gui,Add,Text,x198 y55 w22 h18 center Border g<ShowHelp>,U
	Gui,Add,Text,x222 y55 w22 h18 center Border g<ShowHelp>,I
	Gui,Add,Text,x246 y55 w22 h18 center Border g<ShowHelp>,O
	Gui,Add,Text,x270 y55 w22 h18 center Border g<ShowHelp>,P
	Gui,Add,Text,x294 y55 w22 h18 center Border g<ShowHelp>,[{
    Gui,Add,Text,x318 y55 w22 h18 center Border g<ShowHelp>,]}
    Gui,Add,Text,x342 y55 w44 h18 center Border g<ShowHelp>,\|
    Gui,Add,Text,x12 y75 w60 h18 center Border g<ShowHelp>,CapsLock
    Gui,Add,Text,x74 y75 w22 h18 center Border g<ShowHelp>,A
    Gui,Add,Text,x98 y75 w22 h18 center Border g<ShowHelp>,S
    Gui,Add,Text,x122 y75 w22 h18 center Border g<ShowHelp>,D
    Gui,Add,Text,x146 y75 w22 h18 center Border g<ShowHelp>,F
    Gui,Add,Text,x170 y75 w22 h18 center Border g<ShowHelp>,G
    Gui,Add,Text,x194 y75 w22 h18 center Border g<ShowHelp>,H
    Gui,Add,Text,x218 y75 w22 h18 center Border g<ShowHelp>,J
    Gui,Add,Text,x242 y75 w22 h18 center Border g<ShowHelp>,K
    Gui,Add,Text,x266 y75 w22 h18 center Border g<ShowHelp>,L
    Gui,Add,Text,x290 y75 w22 h18 center Border g<ShowHelp>,`;:
    Gui,Add,Text,x314 y75 w22 h18 center Border g<ShowHelp>,'`"
    Gui,Add,Text,x338 y75 w48 h18 center Border g<ShowHelp>,Enter
    Gui,Add,Text,x12 y95 w70 h18 center Border g<ShowHelp>,LShift
    Gui,Add,Text,x84 y95 w22 h18 center Border g<ShowHelp>,Z
    Gui,Add,Text,x108 y95 w22 h18 center Border g<ShowHelp>,X
    Gui,Add,Text,x132 y95 w22 h18 center Border g<ShowHelp>,C
    Gui,Add,Text,x156 y95 w22 h18 center Border g<ShowHelp>,V
    Gui,Add,Text,x180 y95 w22 h18 center Border g<ShowHelp>,B
    Gui,Add,Text,x204 y95 w22 h18 center Border g<ShowHelp>,N
    Gui,Add,Text,x228 y95 w22 h18 center Border g<ShowHelp>,M
    Gui,Add,Text,x252 y95 w22 h18 center Border g<ShowHelp>,`,<
    Gui,Add,Text,x276 y95 w22 h18 center Border g<ShowHelp>,.>
    Gui,Add,Text,x300 y95 w22 h18 center Border g<ShowHelp>,/?
    Gui,Add,Text,x324 y95 w62 h18 center Border g<ShowHelp>,RShift
    Gui,Add,Text,x12 y115 w40 h18 center Border g<ShowHelp>,LCtrl
    Gui,Add,Text,x54 y115 w40 h18 center Border g<ShowHelp>,LWin
    Gui,Add,Text,x96 y115 w40 h18 center Border g<ShowHelp>,LAlt
    Gui,Add,Text,x138 y115 w122 h18 center Border g<ShowHelp>,Space
    Gui,Add,Text,x262 y115 w40 h18 center Border g<ShowHelp>,RAlt
    Gui,Add,Text,x304 y115 w40 h18 center Border g<ShowHelp>,Apps
    Gui,Add,Text,x346 y115 w40 h18 center Border g<ShowHelp>,RCtrl
	Gui,Font,s10,Arial
    Gui,Add,Text,x399 y10 w200 h135 , Click on the keyboard to see what the key does. Please note that some info might not be accurate because any of the hotkeys can be overriden in the Settings.`n`n`nYou can use hjkl below.
	Gui,Font,s9,Arial Bold    
    Gui,Add,Groupbox,x12 y135 w574 h40
    Gui,Add,Button,x15 y146 w60 gIntro, &1  Intro
    Gui,Add,Button,x80 y146 w75 gFunct, &2  Hotkey
    Gui,Add,Button,x159 y146 w100 gCombok, &3  Combo Key
    Gui,Add,Button,x265 y146 w130 gCmdl, &4  Command Line
    Gui,Add,Button,x400 y146 w105 gAction, &5  Commands
    Gui,Add,Button,x510 y146 w67 gAbout, &6  About
    Intro := HelpInfo_Arr["Intro"]
    Gui,Font,s11,Arial   ;font for the bottom textarea box in help window
    ;Gui,Font,s12,Georgia   ;font for the bottom textarea box in help window
    ;the +0x40000 adds resizing
    Gui,Add,Edit,x12 y180 w574 h310 +ReadOnly +0x40000,%Intro%
    Gui,Show,AutoSize w600 h500,Help   VIATC %Version% 
    If TranspHelp
        WinSet,Transparent,220,ahk_id %VIATCHELP%
    Return
	}
	Intro:
	var := HelpInfo_Arr["Intro"]
	GuiControl,Text,Edit1,%var%
	Return
	Funct:
	var := HelpInfo_Arr["Funct"]
	GuiControl,Text,Edit1,%var%
	Return
	Combok:
	var := HelpInfo_Arr["Combok"]
	GuiControl,Text,Edit1,%var%
	Return
	cmdl:
	var := HelpInfo_Arr["cmdl"]
	GuiControl,Text,Edit1,%var%
	Return
	action:
	var := HelpInfo_Arr["command"]
	GuiControl,Text,Edit1,%var%
	Return
	about:
	var := HelpInfo_Arr["about"]
	GuiControl,Text,Edit1,%var%
	Return

<ShowHelp>:
ShowHelp(A_GuiControl)
Return
ShowHelp(control)
{
    Global HelpInfo_Arr
    Var := HelpInfo_Arr[Control]
    GuiControl,Text,Edit1,%var%
}

SetHelpInfo()  ; --- graphical keyboard in help {{{2
{
    Global HelpInfo_arr
    HelpInfo_arr["Esc"] :="Esc >> Esc. Like in Vim it cancels all unfinished commands"
    HelpInfo_arr["F1"] :="F1 >> No mapping `nOpen TC help"
    HelpInfo_arr["F2"] :="F2 >> No mapping `nRefresh the source window"
    HelpInfo_arr["F3"] :="F3 >> No mapping `nView file"
    HelpInfo_arr["F4"] :="F4 >> No mapping `nEdit file"
    HelpInfo_arr["F5"] :="F5 >> No mapping `nCopy file"
    HelpInfo_arr["F6"] :="F6 >> No mapping `nRename or move file"
    HelpInfo_arr["F7"] :="F7 >> No mapping `nNew folder"
    HelpInfo_arr["F8"] :="F8 >> No mapping `nDelete Files (Move to Recycle Bin or delete it directly - Determined by configuration)"
    HelpInfo_arr["F9"] :="F9 >> No mapping `nActivate the menu for the source window  (Left or right)"
    HelpInfo_arr["F10"] :="F10 >> No mapping `nActivate the left menu or exit the menu "
    HelpInfo_arr["F11"] :="F11 >> No mapping "
    HelpInfo_arr["F12"] :="F12 >> No mapping "
    HelpInfo_arr["``~"] :="`` >> No mapping `n~ >> No mapping "
    HelpInfo_arr["1!"] :="1 >> numerical 1, Used for counting `n! >> No mapping "
    HelpInfo_arr["2@"] :="2 >> numerical 2, Used for counting `n@ >> No mapping "
    HelpInfo_arr["3#"] :="3 >> numerical 3, Used for counting `n# >> No mapping "
    HelpInfo_arr["4$"] :="4 >> numerical 4, Used for counting `n$ >> No mapping "
    HelpInfo_arr["5%"] :="5 >> numerical 5, Used for counting `n% >> No mapping "
    HelpInfo_arr["6^"] :="6 >> numerical 6, Used for counting `n^ >> No mapping "
    HelpInfo_arr["7&"] :="7 >> numerical 7, Used for counting `n& >> No mapping "
    HelpInfo_arr["8*"] :="8 >> numerical 8, Used for counting `n* >> No mapping "
    HelpInfo_arr["9("] :="9 >> numerical 9, Used for counting `n( >> No mapping "
    HelpInfo_arr["0)"] :="0 >> numerical 0, Used for counting `n) >> No mapping "
    HelpInfo_arr["-_"] :="- >> Toggle the independent folder tree panel status `n_ >> No mapping "
    HelpInfo_arr["=+"] :="= >> target = source `n+ >> No mapping "
    HelpInfo_arr["Backspace"] :="Backspace >> No mapping `n Go up a folder or delete the text in edit mode "
    HelpInfo_arr["Tab"] :="Tab >> No mapping `nSwitch the window "
    HelpInfo_arr["Q"] :="q >> Quick view `nQ >> Use the default browser to search for the current file or folder name "
    HelpInfo_arr["W"] :="w >> Small menu `nW >> No mapping "
    HelpInfo_arr["E"] :="e >> e...  (Combo Key, requires another key) `nec >> Compare files by content`nef >> Edit file`neh >> Toggle hidden files`nep >> Edit path in tabbar`n`n`nE >> Edit file prompt"
    HelpInfo_arr["R"] :="r >> Rename`nR >> Fancy Rename (a crude Vim emulator in a new window)"
    HelpInfo_arr["T"] :="t >> New tab `nT >> Create a new tab in the background  `n`nctrl+t >>  Go up in QuickSearch (opened by / or ctrl+s)  ctrl+t works the same in real Vim search,   and ctrl+g is down (mnemonic hint: T is above G) "
    HelpInfo_arr["Y"] :="y >> Copy window like F5  `nY >> Copy the file name and the full path "
    HelpInfo_arr["U"] :="u >> Up a directory `nU >> Up to the root directory "
    HelpInfo_arr["I"] :="i >> Enter `nI >>  Make target = source " ;No mapping "
    HelpInfo_arr["O"] :="o >> Open the drive list `nO >> Open the list of drives and special folders.  Equivalent to 'This PC' in Windows Explorer"
    HelpInfo_arr["P"] :="p >> pack files/folders `nP >> unPack "
    HelpInfo_arr["[{"] :="[ >> Select files with the same name `n{ >> Unselect files with the same name "
    HelpInfo_arr["]}"] :="] >> Select files with the same extension `n} >> Unselect files with the same extension "
    HelpInfo_arr["\|"] :="\ >> Invert all selections for files (but not folders, use * for both)  `n| >> Clears all selections"
    ; CapsLock used to sometimes quit in 'fancy rename' instead of going to Vim mode, it is mapped there again
    HelpInfo_arr["CapsLock"] :="CapsLock >> Esc (in some cases it doesn't behave identical"
    HelpInfo_arr["A"] :="a >> (Combo Key, requires another key) Mostly regarding ViATc or files`nah >> ViATc Help`nao >> ViATc Off`nas >> ViATc Setting`naq >> Quit ViATc`nar >> Reload VIATC`nam >> Show file tooltip`nan >> Create a new file`naa >> Select all files but exclude folders`n...`n`n A >>  All selected:  Files and folders "
    HelpInfo_arr["S"] :="s >> Sort by... (Combo Key, requires another key) `nS >> (Combo Key, requires another key) show all, executables, etc. `nsn >> Source window :  Sort by file name `nse >> Source window :  Sort by extension `nss >> Source window :  Sort by size `nst >> Source window :  Sort by date and time `nsr >> Source window :  Reverse sort `ns1 >> Source window :  Sort by column 1`ns2 >> Source window :  Sort by 2`ns3 >> Source window :  Sort by column 3`ns4 >> Source window :  Sort by column 4`ns5 >> Source window :  Sort by column 5`ns6 >> Source window :  Sort by column 6`ns7 >> Source window :  Sort by column 7`ns8 >> Source window :  Sort by column 8`ns9 >> Source window :  Sort by column 9 >>"
    HelpInfo_arr["D"] :="d >> Favourite folders hotlist`nD >> Open the desktop folder "
    HelpInfo_arr["F"] :="f >> Page down, Equivalent to PageDown`nF >> FtpDisconnect " ;Switch to TC Default fast search mode "
    HelpInfo_arr["G"] :="g >> Tab operation (Combo Key, requires another key) `nG >> Go to the end of the file list `ngg >> Go to the first line of the file list `ngt >> Next tab (Ctrl+Tab)`ngp >> Previous tab (Ctrl+Shift+Tab) also gr, I don't know how to bind gT`nga >> Close All tabs `ngc >> Close the Current tab `ngn >> New tab ( And open the folder at the cursor )`ngb >> New tab ( Open the folder in another window )`nge >> Exchange left and right windows `ngw >> Exchange left and right windows With their tabs `ngi >> Enter `ngg >> Go to the first line of the file list `ng1 >> Source window :  Activate the tab  1`ng2 >> Source window :  Activate the tab  2`ng3 >> Source window :  Activate the tab  3`ng4 >> Source window :  Activate the tab  4`ng5 >> Source window :  Activate the tab  5`ng6 >> Source window :  Activate the tab  6`ng7 >> Source window :  Activate the tab  7`ng8 >> Source window :  Activate the tab  8`ng9 >> Source window :  Activate the tab  9`ng0 >> Go to the last tab `n`nctrl+g >>  Go down in QuickSearch (opened by / or ctrl+s)  ctrl+g works the same in real Vim search,  ctrl+t is up (mnemonic hint: T is above G) "
    HelpInfo_arr["H"] :="h >> Left arrow key. Works in thumbnail and brief mode. In full mode the effect is the cursor enters command line. `nH >> Go Backward in dir history"
    HelpInfo_arr["J"] :="j >> Go Down num times `nJ >> Select down Num files (folders),  Go down in QuickSearch(opened by / or ctrl+s)`n alt+j >>  Go down in QuickSearch (go down with ctrl+g as well, same like in real Vim search)"
    HelpInfo_arr["K"] :="k >> Go Up num times `nK >> Select up Num files (folders),   Go up in QuickSearch(opened by / or ctrl+s)`n alt+k >>  Go up in QuickSearch  (go up with ctrl+t as well, same like in real Vim search)"
    HelpInfo_arr["L"] :="l >> Right arrow key. Works in thumbnail and brief mode. In full mode the effect is the cursor enters command line. `nL >> Go Forward in dir history"
    HelpInfo_arr["`;:"] :="; >> Put focus on the command line `n: >> Get into VIATC command line mode : (like ex mode in vim)"
    HelpInfo_arr["'"""] :="' >> Marks. `n Go to mark by single quote (Create mark by m) `n"" >> No mapping "
    HelpInfo_arr["Enter"] :="Enter >> Enter "
    HelpInfo_arr["LShift"] :="Lshift >> Left shift key, can also be accessed in hotkeys by Shift "
    HelpInfo_arr["Z"] :="z >> Various TC window settings (Combo Key, requires another key) `nzz >> Set the window divider at 50%`nzx >> Set the window divider at 100%`nzl >> Maximize the left panel `nzh >> Maximize the right panel `nzt >> The TC window remains always on top `nzn >> minimize  Total Commander`nzm >> maximize  Total Commander`nzd >> Return to normal size, Restore down`nzv >> Vertical / Horizontal arrangement `nzs >>TC Transparent, see-through `nzw or zx >> One 100% Wide Horizontal panel. Good for long filenames. Toggle.`nzq >> Quit TC`nzr >> Reload TC`n`n`nZ >> Tooltip by mouse-over`n"
    ;HelpInfo_arr["X"] :="x >> Delete Files\folders`nX >> Force Delete, like shift+delete ignores recycle bin"
    HelpInfo_arr["X"] :="x >> Close tab`nX >> Enter or Run file under cursor"
    HelpInfo_arr["C"] :="c >> (Combo Key, requires another key) `ncc >> Delete `ncf >> Force Delete, like shift+delete ignores recycle bin`nC  >> Console. Run cmd.exe in the current directory"
    HelpInfo_arr["V"] :="v >> Context menu `nV >> View... (Combo Key, requires another key)`n<Shift>vb >> Toggle visibility :  toolbar `n<Shift>vd >> Toggle visibility :  Drive button `n<Shift>vo >> Toggle visibility :  Two drive button bars `n<Shift>vr >> Toggle visibility :  Drive list `n<Shift>vc >> Toggle visibility :  Current folder `n<Shift>vt >> Toggle visibility :  Sort tab `n<Shift>vs >> Toggle visibility :  Status Bar `n<Shift>vn >> Toggle visibility :  Command Line `n<Shift>vf >> Toggle visibility :  Function button `n<Shift>vw >> Toggle visibility :  Folder tab `n "
    HelpInfo_arr["B"] :="b >> Move up a page, Equivalent to PageUp`nB >> Open the tabbed browsing window, works in 32bit TConly"
    HelpInfo_arr["N"] :="n >> Show the folder history ( a-z navigation )`nN >> Show the folder history "
    HelpInfo_arr["M"] :="m >> Marking function like in Vim. Create mark by m then go to mark by single quote. For example ma will make mark a then press 'a to go to mark a `n When m is pressed the command line displays m and prompts to enter the mark letter, when this letter is entered command line closes and the current folder-path is stored as the mark. You can browse away to a different folder, and when you press ' it will show all the marks, press a and you will go to the folder where you were before.`n`n`nM >> Move to the middle of the list (the position is often inaccurate, and if there are few lines the cursor might stay the same) Alternatively you can just use 11j"
    HelpInfo_arr[",<"] :=", >> Drives and locations `n< >> No mapping "
    HelpInfo_arr[".>"] :=". >> Repeat the last command. For example: `n   when you enter 10j (go down 10 lines) then to repeat just press the dot .`n   when you enter gt (switch to the next tab) then to repeat you only need to press .`n`n`n> >> No mapping "
    HelpInfo_arr["/?"] :="/ >> Use quick search `n? >> Use the file search function ( advanced )"
    HelpInfo_arr["RShift"] :="Rshift >> right shift key, can also be Shift instead "
    HelpInfo_arr["LCtrl"] :="Lctrl >> left ctrl key, can also be control or ctrl instead "
    HelpInfo_arr["LWin"] :="LWin >>Win key. Due to ahk limits the LWin must be used witl 'L', 'Win' alone cannot be used"
    HelpInfo_arr["LAlt"] :="LAlt >> left Alt key, Can also be Alt instead "
    HelpInfo_arr["Space"] :="Space >> Space, No mapping "
    HelpInfo_arr["RAlt"] :="RAlt >> right Alt key, can also be Alt instead "
    HelpInfo_arr["Apps"] :="Apps >> Open the context menu ( Right-click menu )"
    HelpInfo_arr["RCtrl"] :="Rctrl >> right ctrl key, can also be control or ctrl instead "
HelpInfo_arr["Intro"] := ("ViATc " . Version . " - Vim mode at Total Commander `nTotal Commander (called later TC) is the greatest file manager, get it from www.ghisler.com`n`nViATc provides enhancements and shortcuts to TC trying to resemble the work-flow of Vim and web browser plugins like Vimium or better yet SurfingKeys.`nTo disable the ViATc press alt+`` (alt+backtick which is next to the 1 key) (this shortcut can be modifed), or simply quit ViATc, TC won't be affected.`nTo show/hide TC window: double-click the tray icon, or press Win+F (modifiable)`n")
    HelpInfo_arr["Funct"] :="Single key press to operate. `nA hotkey can be any character and it can be prepended by a number. For example 10j will move down 10 rows. Pressing 10K will select 10 rows upward.`nA hotkey can have one modifier: Ctrl, Alt, Shift or LWin (must be LWin not Win).`nAll how the hotkey is written is case insensitive co <ctrl>a is same as <Ctrl>A - it will treated as lowercase. `n`nExamples of mappings:`n<LWin>g          - this works as intended`n<Ctrl><Shift>a  - invalid, more than one modifier`n<Ctrl><F12>    - not as intended, this time characters of the second key will be interpreted as separate ordinary characters < F 1 2 >  Besides F keys are not allowed only <Ctrl><Shift><Alt><LWin> `n`nPlease click on the keyboard above to get details of each key.`nAlso in the TC window press sm = show mappings from the ini file."
    HelpInfo_arr["ComboK"] :="Combo Keys take multiple keys to operate. `nKeys can be composed of any characters`nThe first key can have one modifier (ctrl/lwin/shift/alt). All the following keys cannot have modifiers `n`nExamples :`nab                      - means press a and release, then press b to work`n<ctrl>ab             - means press ctrl+a and release, then press b to work`n<ctrl>a<ctrl>b   - invalid, the second key cannot have a modifier`n<ctrl><alt>ab    - invalid, the first key cannot have two modifiers`n`n`nVIATC comes by default with the following Combo Keys: e,a,s,S,g,z,c,V and a comma. Click the keyboard above for details of what they do. On the keyboard are mostly keys built-in the script and some from ini file. For mappings that are in viatc.ini open the Settings window where you can remap everything, you can override built-in keys, you can even remap single Hotkeys into Combo Keys and vice versa."
    HelpInfo_arr["cmdl"] :="The command line in VIATC supports abbreviations :h :s :r :m :sm :e :q, They are respectively `n:help    Display help information `n:setting     Set the VIATC interface `n:reload   Re-run VIATC`n:map     Show or map hotkeys. If you type :map in the command line then all custom hotkeys (all ini file mappings, but not built-in) will be displayed in a tooltip`n If the input is :map key command, where key represents the hotkey to map (it can be a Combo Key or a Hotkey). This feature is suitable for the scenario where there is a temporary need for a mapping, after closing VIATC this mapping won't be saved. If you want to make a permanent mapping you can use the VIATC Settings interface, or directly edit viatc.ini file.`n:smap and :map are the same except map is a global hotkey and does not support mapping Combo Keys `n:edit  Directly edit ViATc.ini file `n:q quit TC`n`nAll mappings added using the command line are temporary (one session, not saved into the ini file). Examples `n:map <shift>a <Transparent>   (Mapping A to make TC transparent)`n:map ggg (E:\google\chrome.exe)   (Mapping the ggg Combo Key to run chrome.exe program `n:map abcd {cd E:\ {enter}}    (Mapping the abcd Combo Key to send   cd E:\ {enter}   to TC's command line, where {enter} will be interpreted by VIATC as pressing the Enter key."
    HelpInfo_arr["command"] :="All commands can be found in the Settings window on the 'Hotkeys' tab. Commands are divided into 4 categories, there are 4 buttons there that will help you to fill-in the 'Command' textbox:`n`n1.ViATc command `n`n2.TC internal command, they begin with the 'cm_' such as cm_PackFiles but will be input as <PackFiles>.`nDon't panick when the Settings window disappears, it will reappear after double-click, OK or Cancel`n`n3. Run a program or open a file. TC has similar functions built-in but ViATc way might be more convenient`n`n4. Send a string of text. If you want to input a text into the command line then you can use the Combo Key to map the command of sending a text string.`n`nThe above commands, 1 and 2 must be surrounded with <  > , 3 needs to be surrounded with (  ) , and 4 with {  }`n`n`nRight-click any item on the list to edit or delete. Double-click to edit, or select any item and press Delete `nPress the Analysis button anytime to get a tooltip info about the Hotkey`nUse the Global option only when you want Hotkey to work everywhere outside TC. The Global option is not available for ComboKey`nSave to take effect, OK will save and reload. Cancel if you mess-up. Please make backups of the ini file before any changes, there is a button for it in the bottom-left corner of Settings window"
    HelpInfo_arr["About"] :="Author of the original Chinese version is Linxinhong `nhttps://github.com/linxinhong`n`nTranslator and maintainer of the English version is magicstep https://github.com/magicstep  contact me there or with the same nickname m.......p@gmail.com    I don't speak Chinese, I've used Google translate initially and then rephrased and modified this software. `n`nYou can download a compiled executable on https://magicstep.github.io/viatc `nThe compiled version is most likely older than the current script. If you want the most recent script version then download `n https://github.com/magicstep/ViATc-English/archive/master.zip"
} ;}}}2

SetComboInfo() ; combo keys help {{{2
{
    Global ComboInfo_arr
    ComboInfo_arr["s"] :="sn >> Source window :  Sort by file name `nse >> Source window :  Sort by extension `nss >> Source window :  Sort by size `nsd >> Source window :  Sort by date and time `nsr >> Source window :  Reverse sort `ns1 >> Source window :  Sort by column 1`ns2 >> Source window :  Sort by 2`ns3 >> Source window :  Sort by column 3`ns4 >> Source window :  Sort by column 4`ns5 >> Source window :  Sort by column 5`ns6 >> Source window :  Sort by column 6`ns7 >> Source window :  Sort by column 7`ns8 >> Source window :  Sort by column 8`ns9 >> Source window :  Sort by column 9"
    ComboInfo_arr["z"] :="zz >> Set the window divider at 50%`nzx >> Set the window divider at 100% (TC 8.0+)`nzi >> Maximize the left panel `nzo >> Maximize the right panel `nzt >>TC window always on top `nzn >> minimize  Total Commander`nzm >> maximize  Total Commander`nzr >> Return to normal size `nzv >> Vertical / Horizontal arrangement `nzs >>TC transparent `nzf >> Full screen TC`nzl >> The simplest TC`nzq >> Exit TC`nza >> Reload TC"
    ComboInfo_arr["g"] :="g`n ------------------------------ `ngn >> Next tab (Ctrl+Tab)`ngp >> Previous tab (Ctrl+Shift+Tab)`nga >> Close All tabs `ngc >> Close the Current tab `ngt >> New tab ( And open the folder at the cursor )`ngb >> New tab ( Open the folder in another window )`nge >> Exchange left and right windows `ngw >> Exchange left and right windows With their tabs `ngi >> Enter `ngg >> Go to the first line in the file list `ng1 >> Source window :  Activate the tab  1`ng2 >> Source window :  Activate the tab  2`ng3 >> Source window :  Activate the tab  3`ng4 >> Source window :  Activate the tab  4`ng5 >> Source window :  Activate the tab  5`ng6 >> Source window :  Activate the tab  6`ng7 >> Source window :  Activate the tab  7`ng8 >> Source window :  Activate the tab  8`ng9 >> Source window :  Activate the tab  9`ng0 >> Go to the last tab "
    ComboInfo_arr["Shift & v"] :="<Shift>vb >> Toggle visibility :  Toolbar `n<Shift>vd >> Toggle visibility :  Drive button `n<Shift>vo >> Toggle visibility :  Two drive button bars `n<Shift>vr >> Toggle visibility :  Drive list `n<Shift>vc >> Toggle visibility :  Current folder `n<Shift>vt >> Toggle visibility :  Sort tab `n<Shift>vs >> Toggle visibility :  Status Bar `n<Shift>vn >> Toggle visibility :  Command Line `n<Shift>vf >> Toggle visibility :  Function buttons `n<Shift>vw >> Toggle visibility :  Folder tab `n<Shift>ve >> Browse internal commands "
    ComboInfo_arr["c"] :="cl >> Delete the history of the left folder `ncr >> Delete the history of the right folder `ncc >> Delete command line history "
}


; ----  ViATc commands, command's descriptions {{{2
SetViatcCommand()  ; --- internal ViATc commands
{
    Global ViatcCommand
    ViatcCommand := " <None> <Help> <Setting> <ViATcVimOff> <ToggleViATc> <ToggleViatcVim> <ToggleTC> <QuitTC> <ReloadTC> <QuitVIATC> <ReloadVIATC> <Enter> <Return> <FancyR> <SingleRepeat> <Esc> <CapsLock> <CapsLockOn> <CapsLockOff> <Num0> <Num1> <Num2> <Num3> <Num4> <Num5> <Num6> <Num7> <Num8> <Num9> <Down> <Up> <Left> <Right> <PageUp> <PageDown> <Home> <Half> <End> <DownSelect> <UpSelect> <ForceDel> <Mark> <ListMark> <RestoreLastMark> <SetTitleAsDateTime> <CheckForUpdates> <Internetsearch> <azHistory> <azCmdHistory> <ListMapKey> <ListMapKeyMultiColumn> <WinMaxLeft> <WinMaxRight> <AlwayOnTop> <GoLastTab> <azTab> <Transparent> <DeleteLHistory> <DeleteRHistory> <DelCmdHistory> <CreateNewFile> <TCFullScreenAlmost> <TCFullScreen> <TCFullScreenWithExePlugin> <BackupViATcIniFile> <EditViATcIniFile> <BackupTCIniFile> <EditTCIniFile> <BackupMarksFile> <EditMarksFile> <BackupUserFile> <EditUserFile>"

; add user commands
for index, element in UserCommandsArr
    ViatcCommand := ViatcCommand . " " . index
    ;Msgbox  Debugging index = [%index%]  on line %A_LineNumber% ;!!!
}

SetCommandInfo()  ; --- command's descriptions
{
    Global CommandInfo_Arr

    ; add  descriptions of user commands
    for index, element in UserCommandsArr
        CommandInfo_Arr[index] := UserCommandsArr[index]

    CommandInfo_Arr["<ReLoadVIATC>"] :=" Reload VIATC"
    CommandInfo_Arr["<ReLoadTC>"] :=" Reload TC"
    CommandInfo_Arr["<QuitTC>"] :=" Exit TC"
    CommandInfo_Arr["<QuitViATc>"] :=" Exit ViATc"
    CommandInfo_Arr["<None>"] :=" do nothing "
    CommandInfo_Arr["<Setting>"] :=" Settings window "
    CommandInfo_Arr["<FocusCmdLine:>"] := " Command line mode. Focus on the command line with : at the beginning"
    CommandInfo_Arr["<CreateNewFile>"] := " Menu to create a new file (can be from a template) or a new directory "
    CommandInfo_Arr["<Help>"] :=  " ViATc Help"
    CommandInfo_Arr["<Setting>"] := " VIATC Settings"
    CommandInfo_Arr["<ToggleTC>"] :=" Show / Hide TC"
    CommandInfo_Arr["<ToggleViATc>"] :=" Enable / Disable most of ViATc, global shortcuts will still work. For disabling all use <ViATcVimOff> "
    CommandInfo_Arr["<ViATcVimOff>"] :=" Switch-off all ViATc functionality till Esc will switch on. This is more than <ToggleViATc>"
    CommandInfo_Arr["<Enter>"] :=" Enter does a lot of advanced checks,  use <Return> for simplicity"
    CommandInfo_Arr["<Return>"] :=" Just sends an Enter key"
    CommandInfo_Arr["<FancyR>"] :=" Fancy Rename in a new window with a crude Vim emulator"
    CommandInfo_Arr["<SingleRepeat>"] :=" Repeat the last command "
    CommandInfo_Arr["<Esc>"] :=" Reset and send ESC"
    CommandInfo_Arr["<CapsLock>"] :=" Toggle CapsLock"
    CommandInfo_Arr["<CapsLockOn>"] :=" CapsLock On"
    CommandInfo_Arr["<CapsLockOff>"] :=" CapsLock Off"
    CommandInfo_Arr["<BackupViATcIniFile>"] :=" Backup viatc.ini file "
    CommandInfo_Arr["<EditViATcIniFile>"] :=" Edit viatc.ini file "
    CommandInfo_Arr["<BackupMarksFile>"] :=" Backup marks.ini file "
    CommandInfo_Arr["<EditMarksFile>"] :=" Edit marks.ini file "
    CommandInfo_Arr["<BackupTCIniFile>"] :=" Backup wincmd.ini file that belongs to TC"
    CommandInfo_Arr["<EditTCIniFile>"] :=" Edit wincmd.ini file that belongs to TC"
    CommandInfo_Arr["<BackupUserFile>"] :=" Backup user.ahk file "
    CommandInfo_Arr["<EditUserFile>"] :=" Edit user.ahk file"
    CommandInfo_Arr["<Num0>"] :=" numerical 0, can be used for repeats in 10 j "
    CommandInfo_Arr["<Num1>"] :=" numerical 1, can be used for repeats in 10 j "
    CommandInfo_Arr["<Num2>"] :=" numerical 2"
    CommandInfo_Arr["<Num3>"] :=" numerical 3"
    CommandInfo_Arr["<Num4>"] :=" numerical 4"
    CommandInfo_Arr["<Num5>"] :=" numerical 5"
    CommandInfo_Arr["<Num6>"] :=" numerical 6"
    CommandInfo_Arr["<Num7>"] :=" numerical 7"
    CommandInfo_Arr["<Num8>"] :=" numerical 8"
    CommandInfo_Arr["<Num9>"] :=" numerical 9"
    CommandInfo_Arr["<Down>"] :=" Down "
    CommandInfo_Arr["<Up>"] :=" Up "
    CommandInfo_Arr["<Left>"] :=" Left"
    CommandInfo_Arr["<Right>"] :=" Right"
    CommandInfo_Arr["<DownSelect>"] :=" Select Down "
    CommandInfo_Arr["<UpSelect>"] :=" Select Up"
    CommandInfo_Arr["<Home>"] :=" Go to the first line, Equivalent to Home key"
    CommandInfo_Arr["<Half>"] :=" Go to the middle of the list (this doesn't work properly)"
    CommandInfo_Arr["<End>"] :=" Go to last line, Equivalent to End key "
    CommandInfo_Arr["<PageUp>"] :=" Page Up "
    CommandInfo_Arr["<PageDown>"] :=" Page Down "
    CommandInfo_Arr["<ForceDel>"] :=" Forced Delete, like shift+delete ignores recycle bin"
    CommandInfo_Arr["<Mark>"] :=" Marks like in Vim, Mark the current folder with ma, use 'a to go to the corresponding mark "
    CommandInfo_Arr["<RestoreLastMark>"] :=" Restore the last overwritten mark "
    CommandInfo_Arr["<SetTitleAsDateTime>"] :=" Set the TC title as DateTime"
    CommandInfo_Arr["<CheckForUpdates>"] :=" Check for the ViATc updates "
    CommandInfo_Arr["<ListMark>"] :=" Offer to use marks created earlier by m like in Vim "
    CommandInfo_Arr["<ListMarksTooltip>"] :=" Show all marks in a tooltip (show only, not able to use)"
    CommandInfo_Arr["<Internetsearch>"] :=" Use the default internet browser to search for the current file or folder"
    CommandInfo_Arr["<azHistory>"] :=" Folder history menu, A-Z selection "
    CommandInfo_Arr["<azCmdHistory>"] :=" View the command history "
    CommandInfo_Arr["<ListMapKey>"] :=" Show custom mapping keys. It's better to just open Settings window instead. "
    CommandInfo_Arr["<ListMapKeyMultiColumn>"] :=" Show custom mapping keys in columns. It's better to just open Settings window instead. "
    CommandInfo_Arr["<WinMaxLeft>"] :=" Maximize left panel "
    CommandInfo_Arr["<WinMaxRight>"] :=" Maximize right panel "
    CommandInfo_Arr["<AlwayOnTop>"] :=" TC always on top. Toggle "
    CommandInfo_Arr["<Transparent>"] :=" TC Transparent. See-through. Toggle "
    CommandInfo_Arr["<DeleteLHistory>"] :=" Delete history of the left folder "
    CommandInfo_Arr["<DeleteRHistory>"] :=" Delete history of the right folder "
    CommandInfo_Arr["<DelCmdHistory>"] :=" Delete command-line history "
    CommandInfo_Arr["<GoLastTab>"] :=" Go to the last tab "
    CommandInfo_Arr["<TCFullScreenAlmost>"] :=" TC almost full screen. Windows taskbar still visible"
    CommandInfo_Arr["<TCFullScreen>"] :=" TC full screen. "
    CommandInfo_Arr["<TCFullScreenWithExePlugin>"] :=" TC full screen. An external exe program is required, You'll be asked to download. "
    CommandInfo_Arr["<azTab>"] := " a-z tab selection (works only in 32 bit TC with a nasty error on first use and in 64 bit TC it is unavailable)"
    CommandInfo_Arr["<SrcComments>"] :=" Source window :  Show file comments "
    CommandInfo_Arr["<SrcShort>"] :=" Source window :  List "
    CommandInfo_Arr["<SrcLong>"] :=" Source window :  Details "
    CommandInfo_Arr["<SrcTree>"] :=" Source window :  Folder Tree "
    CommandInfo_Arr["<SrcQuickview>"] :=" Source window :  Quick View "
    CommandInfo_Arr["<VerticalPanels>"] :=" Vertical / Horizontal arrangement "
    CommandInfo_Arr["<WidePanelToggle>"] :=" One 100% Wide Horizontal panel. Toggle"
    CommandInfo_Arr["<SrcQuickInternalOnly>"] :=" Source window :  Quick View ( No plugins )"
    CommandInfo_Arr["<SrcHideQuickview>"] :=" Source window :  Close the Quick View window "
    CommandInfo_Arr["<SrcExecs>"] :=" Source window :  Executable file "
    CommandInfo_Arr["<SrcAllFiles>"] :=" Source window :  All files "
    CommandInfo_Arr["<SrcUserSpec>"] :=" Source window :  The last selected file "
    CommandInfo_Arr["<SrcUserDef>"] :=" Source window :  User defined type "
    CommandInfo_Arr["<SrcByName>"] :=" Source window :  Sort by file name "
    CommandInfo_Arr["<SrcByExt>"] :=" Source window :  Sort by extension "
    CommandInfo_Arr["<SrcBySize>"] :=" Source window :  Sort by size "
    CommandInfo_Arr["<SrcByDateTime>"] :=" Source window :  Sort by date and time "
    CommandInfo_Arr["<SrcUnsorted>"] :=" Source window :  Not sorted "
    CommandInfo_Arr["<SrcNegOrder>"] :=" Source window :  Reverse sort "
    CommandInfo_Arr["<SrcOpenDrives>"] :=" Source window :  Open the drive list "
    CommandInfo_Arr["<SrcThumbs>"] :=" Source window :  Thumbnails "
    CommandInfo_Arr["<SrcCustomViewMenu>"] :=" Source window :  Customize the view menu "
    CommandInfo_Arr["<SrcPathFocus>"] :=" Source window :  Focus on the path "
    CommandInfo_Arr["<LeftComments>"] :=" Left window :  Show file comments "
    CommandInfo_Arr["<LeftShort>"] :=" Left window :  List "
    CommandInfo_Arr["<LeftLong>"] :=" Left window :  Details "
    CommandInfo_Arr["<LeftTree>"] :=" Left window :  Folder Tree "
    CommandInfo_Arr["<LeftQuickview>"] :=" Left window :  Quick View "
    CommandInfo_Arr["<LeftQuickInternalOnly>"] :=" Left window :  Quick View ( No plugins )"
    CommandInfo_Arr["<LeftHideQuickview>"] :=" Left window :  Close the Quick View window "
    CommandInfo_Arr["<LeftExecs>"] :=" Left window :  executable file "
    CommandInfo_Arr["<LeftAllFiles>"] :=" Left window :  All files "
    CommandInfo_Arr["<LeftUserSpec>"] :=" Left window :  The last selected file "
    CommandInfo_Arr["<LeftUserDef>"] :=" Left window :  Custom type "
    CommandInfo_Arr["<LeftByName>"] :=" Left window :  Sort by file name "
    CommandInfo_Arr["<LeftByExt>"] :=" Left window :  Sort by extension "
    CommandInfo_Arr["<LeftBySize>"] :=" Left window :  Sort by size "
    CommandInfo_Arr["<LeftByDateTime>"] :=" Left window :  Sort by date and time "
    CommandInfo_Arr["<LeftUnsorted>"] :=" Left window :  Not sorted "
    CommandInfo_Arr["<LeftNegOrder>"] :=" Left window :  Reverse sort "
    CommandInfo_Arr["<LeftOpenDrives>"] :=" Left window :  Open the drive list "
    CommandInfo_Arr["<LeftPathFocus>"] :=" Left window :  Focus on the path "
    CommandInfo_Arr["<LeftDirBranch>"] :=" Left window :  Expand all folders "
    CommandInfo_Arr["<LeftDirBranchSel>"] :=" Left window :  Only the selected folder is expanded "
    CommandInfo_Arr["<LeftThumbs>"] :=" window :  Thumbnails "
    CommandInfo_Arr["<LeftCustomViewMenu>"] :=" window :  Customize the view menu "
    CommandInfo_Arr["<RightComments>"] :=" Right window :  Show file comments "
    CommandInfo_Arr["<RightShort>"] :=" Right window :  List "
    CommandInfo_Arr["<RightLong>"] :=" details "
    CommandInfo_Arr["<RightTre>"] :=" Right window :  Folder Tree "
    CommandInfo_Arr["<RightQuickvie>"] :=" Right window :  Quick View "
    CommandInfo_Arr["<RightQuickInternalOnl>"] :=" Right window :  Quick View ( No plugins )"
    CommandInfo_Arr["<RightHideQuickvie>"] :=" Right window :  Close the Quick View window "
    CommandInfo_Arr["<RightExec>"] :=" Right window :  executable file "
    CommandInfo_Arr["<RightAllFile>"] :=" Right window :  All files "
    CommandInfo_Arr["<RightUserSpe>"] :=" Right window :  The last selected file "
    CommandInfo_Arr["<RightUserDe>"] :=" Right window :  Custom type "
    CommandInfo_Arr["<RightByNam>"] :=" Right window :  Sort by file name "
    CommandInfo_Arr["<RightByEx>"] :=" Right window :  Sort by extension "
    CommandInfo_Arr["<RightBySiz>"] :=" Right window :  Sort by size "
    CommandInfo_Arr["<RightByDateTim>"] :=" Right window :  Sort by date and time "
    CommandInfo_Arr["<RightUnsorte>"] :=" Right window :  Not sorted "
    CommandInfo_Arr["<RightNegOrde>"] :=" Right window :  Reverse sort "
    CommandInfo_Arr["<RightOpenDrives>"] :=" Right window :  Open the drive list "
    CommandInfo_Arr["<RightPathFocu>"] :=" Right window :  Focus on the path "
    CommandInfo_Arr["<RightDirBranch>"] :=" Right window :  Expand all folders "
    CommandInfo_Arr["<RightDirBranchSel>"] :=" Right window :  Only the selected folder is expanded "
    CommandInfo_Arr["<RightThumb>"] :=" Right window :  Thumbnails "
    CommandInfo_Arr["<RightCustomViewMen>"] :=" Right window :  Customize the view menu "
    CommandInfo_Arr["<List>"] :=" Lister ( use the lister program to view )"
    CommandInfo_Arr["<ListInternalOnly>"] :=" Lister ( use the lister program, but not plugin / multimedia )"
    CommandInfo_Arr["<Edit>"] :=" edit "
    CommandInfo_Arr["<Copy>"] :=" copy "
    CommandInfo_Arr["<CopySamepanel>"] :=" Copy to the current window "
    CommandInfo_Arr["<CopyOtherpanel>"] :=" Copy to another window "
    CommandInfo_Arr["<RenMov>"] :=" Rename / Move "
    CommandInfo_Arr["<MkDir>"] :=" New Folder "
    CommandInfo_Arr["<Delete>"] :=" Delete "
    CommandInfo_Arr["<TestArchive>"] :=" Test compression package "
    CommandInfo_Arr["<PackFiles>"] :=" Compressed file "
    CommandInfo_Arr["<UnpackFiles>"] :=" Unzip files "
    CommandInfo_Arr["<RenameOnly>"] :=" Rename (Shift+F6)"
    CommandInfo_Arr["<RenameSingleFile>"] :=" Rename current file "
    CommandInfo_Arr["<MoveOnly>"] :=" Move (F6)"
    CommandInfo_Arr["<Properties>"] :=" Display file properties, or if folder then calculate space "
    CommandInfo_Arr["<CreateShortcut>"] :=" Create Shortcut "
    CommandInfo_Arr["<OpenAsUser>"] :=" Run the file under cursor as onother user "
    CommandInfo_Arr["<Split>"] :=" Split files "
    CommandInfo_Arr["<Combine>"] :=" Merge documents "
    CommandInfo_Arr["<Encode>"] :=" Encoding file (MIME/UUE/XXE  format )"
    CommandInfo_Arr["<Decode>"] :=" Decode the file (MIME/UUE/XXE/BinHex  format )"
    CommandInfo_Arr["<CRCcreate>"] :=" Create a check file "
    CommandInfo_Arr["<CRCcheck>"] :=" Verify checksum "
    CommandInfo_Arr["<SetAttrib>"] :=" Change attributes "
    CommandInfo_Arr["<Config>"] :=" Configuration :  layout "
    CommandInfo_Arr["<DisplayConfig>"] :=" Configuration :  display "
    CommandInfo_Arr["<IconConfig>"] :=" Configuration :  icon "
    CommandInfo_Arr["<FontConfig>"] :=" Configuration :  Font "
    CommandInfo_Arr["<ColorConfig>"] :=" Configuration :  Colour "
    CommandInfo_Arr["<ConfTabChange>"] :=" Configuration :  Tabs "
    CommandInfo_Arr["<DirTabsConfig>"] :=" Configuration :  Folder tab "
    CommandInfo_Arr["<CustomColumnConfig>"] :=" Configuration :  Custom columns "
    CommandInfo_Arr["<CustomColumnDlg>"] :=" Change the current custom column "
    CommandInfo_Arr["<LanguageConfig>"] :=" Configuration :  Language "
    CommandInfo_Arr["<Config2>"] :=" Configuration :  Operation method "
    CommandInfo_Arr["<EditConfig>"] :=" Configuration :  edit / view "
    CommandInfo_Arr["<CopyConfig>"] :=" Configuration :  copy / delete "
    CommandInfo_Arr["<RefreshConfig>"] :=" Configuration :  Refresh "
    CommandInfo_Arr["<QuickSearchConfig>"] :=" Configuration :  quick search "
    CommandInfo_Arr["<FtpConfig>"] :=" Configuration : FTP"
    CommandInfo_Arr["<PluginsConfig>"] :=" Configuration :  Plugin "
    CommandInfo_Arr["<ThumbnailsConfig>"] :=" Configuration :  Thumbnails "
    CommandInfo_Arr["<LogConfig>"] :=" Configuration :  Log file "
    CommandInfo_Arr["<IgnoreConfig>"] :=" Configuration :  Hide the file "
    CommandInfo_Arr["<PackerConfig>"] :=" Configuration :  Compression program "
    CommandInfo_Arr["<ZipPackerConfig>"] :=" Configuration : ZIP  Compression program "
    CommandInfo_Arr["<Confirmation>"] :=" Configuration :  other / confirm "
    CommandInfo_Arr["<ConfigSavePos>"] :=" Save location "
    CommandInfo_Arr["<ButtonConfig>"] :=" Change the toolbar "
    CommandInfo_Arr["<ConfigSaveSettings>"] :=" Save Settings "
    CommandInfo_Arr["<ConfigChangeIniFiles>"] :=" Modify the configuration file directly "
    CommandInfo_Arr["<ConfigSaveDirHistory>"] :=" Save the folder history "
    CommandInfo_Arr["<ChangeStartMenu>"] :=" Change the Start menu "
    CommandInfo_Arr["<NetConnect>"] :=" Mapping network drives "
    CommandInfo_Arr["<NetDisconnect>"] :=" Disconnect the network drive "
    CommandInfo_Arr["<NetShareDir>"] :=" Share the current folder "
    CommandInfo_Arr["<NetUnshareDir>"] :=" Cancel folder sharing "
    CommandInfo_Arr["<AdministerServer>"] :=" Show system shared folder "
    CommandInfo_Arr["<ShowFileUser>"] :=" Displays the remote user of the local file "
    CommandInfo_Arr["<GetFileSpace>"] :=" Calculate the footprint "
    CommandInfo_Arr["<VolumeId>"] :=" Set the tab "
    CommandInfo_Arr["<VersionInfo>"] :=" Version Information "
    CommandInfo_Arr["<ExecuteDOS>"] :=" cmd.exe Console with Command Prompt "
    CommandInfo_Arr["<CompareDirs>"] :=" Compare folders "
    CommandInfo_Arr["<CompareDirsWithSubdirs>"] :=" Compare folders ( Also mark a subfolder that does not have another window )"
    CommandInfo_Arr["<ContextMenu>"] :=" Show the context menu "
    CommandInfo_Arr["<ContextMenuInternal>"] :=" Show the context menu ( Internal association )"
    CommandInfo_Arr["<ContextMenuInternalCursor>"] :=" Displays the internal context menu for the file at the cursor "
    ;CommandInfo_Arr["<ShowRemoteMenu>"] :=" Media Center Remote Control Play / Pause key context menu "
    CommandInfo_Arr["<ShowRemoteMenu>"] :=" Menu with various actions to choose from ..."
    CommandInfo_Arr["<SyncChangeDir>"] :=" Synchronous directory changing in both windows "
    CommandInfo_Arr["<EditComment>"] :=" Edit file comments "
    CommandInfo_Arr["<FocusLeft>"] :=" Focus on the left window "
    CommandInfo_Arr["<FocusRight>"] :=" Focus on the right window "
    CommandInfo_Arr["<FocusCmdLine>"] :=" Focus on the command line "
    CommandInfo_Arr["<FocusButtonBar>"] :=" Focus on the toolbar "
    CommandInfo_Arr["<CountDirContent>"] :=" Calculate the space occupied by all folders "
    CommandInfo_Arr["<UnloadPlugins>"] :=" Unload all plugins "
    CommandInfo_Arr["<DirMatch>"] :=" Mark a new file, Hide the same "
    CommandInfo_Arr["<Exchange>"] :=" Exchange left and right windows "
    CommandInfo_Arr["<MatchSrc>"] :=" target  =  source "
    CommandInfo_Arr["<ReloadSelThumbs>"] :=" Refresh the thumbnail of the selected file "
    CommandInfo_Arr["<DirectCableConnect>"] :=" Direct cable connection "
    CommandInfo_Arr["<NTinstallDriver>"] :=" Load  NT  Parallel port driver "
    CommandInfo_Arr["<NTremoveDriver>"] :=" Unloading  NT  Parallel port driver "
    CommandInfo_Arr["<PrintDir>"] :=" Print a list of files "
    CommandInfo_Arr["<PrintDirSub>"] :=" Print a list of files ( Contains subfolders )"
    CommandInfo_Arr["<PrintFile>"] :=" Print the contents of the file "
    CommandInfo_Arr["<SpreadSelection>"] :=" Select a set of files "
    CommandInfo_Arr["<SelectBoth>"] :=" Select :  Files and folders "
    CommandInfo_Arr["<SelectFiles>"] :=" Select :  Only file "
    CommandInfo_Arr["<SelectFolders>"] :=" Select :  Only folders "
    CommandInfo_Arr["<ShrinkSelection>"] :=" Shrink Selection "
    CommandInfo_Arr["<ClearFiles>"] :=" Clear selected :  Only files "
    CommandInfo_Arr["<ClearFolders>"] :=" Clear selected:  Only folders "
    CommandInfo_Arr["<ClearSelCfg>"] :=" Clear selected:  File and / or folders ( Depending on configuration )"
    CommandInfo_Arr["<SelectAll>"] :=" All selected :  File and / or folders ( Depending on configuration )"
    CommandInfo_Arr["<SelectAllBoth>"] :=" All selected :  Files and folders "
    CommandInfo_Arr["<SelectAllFiles>"] :=" All selected :  Only file "
    CommandInfo_Arr["<SelectAllFolders>"] :=" All selected :  Only folders "
    CommandInfo_Arr["<ClearAll>"] :=" Clear All  :  Files and folders "
    CommandInfo_Arr["<ClearAllFiles>"] :=" Clear All  :  Only file "
    CommandInfo_Arr["<ClearAllFolders>"] :=" Clear All  :  Only folders "
    CommandInfo_Arr["<ClearAllCfg>"] :=" Clear All  :  File and / or folders ( Depending on configuration )"
    CommandInfo_Arr["<ExchangeSelection>"] :=" Reverse selection "
    CommandInfo_Arr["<ExchangeSelBoth>"] :=" Reverse selection :  Files and folders "
    CommandInfo_Arr["<ExchangeSelFiles>"] :=" Reverse selection :  Only file "
    CommandInfo_Arr["<ExchangeSelFolders>"] :=" Reverse selection :  Only folders "
    CommandInfo_Arr["<SelectCurrentExtension>"] :=" Select the same file with the same extension "
    CommandInfo_Arr["<UnselectCurrentExtension>"] :=" Do not select the same file with the same extension "
    CommandInfo_Arr["<SelectCurrentName>"] :=" Select the file with the same file name "
    CommandInfo_Arr["<UnselectCurrentName>"] :=" Do not select files with the same file name "
    CommandInfo_Arr["<SelectCurrentNameExt>"] :=" Select the file with the same file name and extension "
    CommandInfo_Arr["<UnselectCurrentNameExt>"] :=" Do not select files with the same file name and extension "
    CommandInfo_Arr["<SelectCurrentPath>"] :=" Select the same path under the file ( Expand the folder + Search for files )"
    CommandInfo_Arr["<UnselectCurrentPath>"] :=" Do not choose the same path under the file ( Expand the folder + Search the file )"
    CommandInfo_Arr["<RestoreSelection>"] :=" Restore the selection list "
    CommandInfo_Arr["<SaveSelection>"] :=" Save the selection list "
    CommandInfo_Arr["<SaveSelectionToFile>"] :=" Export the selection list "
    CommandInfo_Arr["<SaveSelectionToFileA>"] :=" Export the selection list (ANSI)"
    CommandInfo_Arr["<SaveSelectionToFileW>"] :=" Export the selection list (Unicode)"
    CommandInfo_Arr["<SaveDetailsToFile>"] :=" Export details "
    CommandInfo_Arr["<SaveDetailsToFileA>"] :=" Export details (ANSI)"
    CommandInfo_Arr["<SaveDetailsToFileW>"] :=" Export details (Unicode)"
    CommandInfo_Arr["<LoadSelectionFromFile>"] :=" Import selection list ( From the file )"
    CommandInfo_Arr["<LoadSelectionFromClip>"] :=" Import the selection list ( From the clipboard )"
    CommandInfo_Arr["<EditPermissionInfo>"] :=" Setting permissions (NTFS)"
    CommandInfo_Arr["<EditAuditInfo>"] :=" Review the document (NTFS)"
    CommandInfo_Arr["<EditOwnerInfo>"] :=" Get ownership (NTFS)"
    CommandInfo_Arr["<CutToClipboard>"] :=" Cut the selected file to the clipboard "
    CommandInfo_Arr["<CopyToClipboard>"] :=" Copy the selected file to the clipboard "
    CommandInfo_Arr["<PasteFromClipboard>"] :=" Paste from the clipboard to the current folder "
    CommandInfo_Arr["<CopyNamesToClip>"] :=" Copy the file name "
    CommandInfo_Arr["<CopyFullNamesToClip>"] :=" Copy the file name and the full path "
    CommandInfo_Arr["<CopyNetNamesToClip>"] :=" Copy the file name and network path "
    CommandInfo_Arr["<CopySrcPathToClip>"] :=" Copy the source path "
    CommandInfo_Arr["<CopyTrgPathToClip>"] :=" Copy the destination path "
    CommandInfo_Arr["<CopyFileDetailsToClip>"] :=" Copy the file details "
    CommandInfo_Arr["<CopyFpFileDetailsToClip>"] :=" Copy the file details and the full path "
    CommandInfo_Arr["<CopyNetFileDetailsToClip>"] :=" Copy file details and network path "
    CommandInfo_Arr["<FtpConnect>"] :="FTP  connection "
    CommandInfo_Arr["<FtpNew>"] :=" New  FTP  connection "
    CommandInfo_Arr["<FtpDisconnect>"] :=" disconnect  FTP  connection "
    CommandInfo_Arr["<FtpHiddenFiles>"] :=" Show hidden FTP files "
    CommandInfo_Arr["<FtpAbort>"] :=" Stop the current  FTP  command "
    CommandInfo_Arr["<FtpResumeDownload>"] :=" FtpResumeDownload "
    CommandInfo_Arr["<FtpSelectTransferMode>"] :=" Select the transfer mode "
    CommandInfo_Arr["<FtpAddToList>"] :=" Add to download list "
    CommandInfo_Arr["<FtpDownloadList>"] :=" FtpDownloadList "
    CommandInfo_Arr["<GotoPreviousDir>"] :=" GotoPreviousDir in tab history"
    CommandInfo_Arr["<GotoNextDir>"] :=" GotoNextDir in tab history"
    CommandInfo_Arr["<DirectoryHistory>"] :=" Folder history "
    CommandInfo_Arr["<GotoPreviousLocalDir>"] :=" GotoPreviousLocalDir (non-FTP)"
    CommandInfo_Arr["<GotoNextLocalDir>"] :=" GotoNextLocalDir (non-FTP)"
    CommandInfo_Arr["<DirectoryHotlist>"] :=" DirectoryHotlist "
    CommandInfo_Arr["<GoToRoot>"] :=" Go to the root folder "
    CommandInfo_Arr["<GoToParent>"] :=" Go to the upper folder "
    CommandInfo_Arr["<GoToDir>"] :=" Open the folder or archive at the cursor "
    CommandInfo_Arr["<OpenDesktop>"] :=" desktop "
    CommandInfo_Arr["<OpenDrives>"] :=" my computer "
    CommandInfo_Arr["<OpenControls>"] :=" control panel "
    CommandInfo_Arr["<OpenFonts>"] :=" Font "
    CommandInfo_Arr["<OpenNetwork>"] :=" OpenNetwork "
    CommandInfo_Arr["<OpenPrinters>"] :=" printer "
    CommandInfo_Arr["<OpenRecycled>"] :=" Recycle bin "
    CommandInfo_Arr["<CDtree>"] :=" Change the folder "
    CommandInfo_Arr["<TransferLeft>"] :=" Open the folder or the compressed package at the cursor in the left window "
    CommandInfo_Arr["<TransferRight>"] :=" Open the folder or archive at the cursor in the right window "
    CommandInfo_Arr["<EditPath>"] :=" Edit the path of the source window "
    CommandInfo_Arr["<GoToFirstFile>"] :=" The cursor moves to the first file in the list "
    CommandInfo_Arr["<GotoNextDrive>"] :=" Go to the next drive "
    CommandInfo_Arr["<GotoPreviousDrive>"] :=" Go to the previous drive "
    CommandInfo_Arr["<GotoNextSelected>"] :=" Go to the next selected file "
    CommandInfo_Arr["<GotoPrevSelected>"] :=" Go to the previous selected file "
    CommandInfo_Arr["<GotoDriveA>"] :=" Go to the drive  A"
    CommandInfo_Arr["<GotoDriveC>"] :=" Go to the drive  C"
    CommandInfo_Arr["<GotoDriveD>"] :=" Go to the drive  D"
    CommandInfo_Arr["<GotoDriveE>"] :=" Go to the drive  E"
    CommandInfo_Arr["<GotoDriveF>"] :=" Go to the drive  F"
    CommandInfo_Arr["<GotoDriveG>"] :=" Go to the drive  G"
    CommandInfo_Arr["<GotoDriveH>"] :=" Go to the drive  H"
    CommandInfo_Arr["<GotoDriveI>"] :=" Go to the drive  I"
    CommandInfo_Arr["<GotoDriveJ>"] :=" Go to the drive  J"
    CommandInfo_Arr["<GotoDriveK>"] :=" You can customize other drives "
    CommandInfo_Arr["<GotoDriveU>"] :=" Go to the drive  U"
    CommandInfo_Arr["<GotoDriveZ>"] :=" GotoDriveZ, max 26"
    CommandInfo_Arr["<HelpIndex>"] :=" Help index "
    CommandInfo_Arr["<Keyboard>"] :=" TC Keyboard layout, list of TC shortcuts "
    CommandInfo_Arr["<Register>"] :=" registration message "
    CommandInfo_Arr["<VisitHomepage>"] :=" access  Totalcmd  website "
    CommandInfo_Arr["<About>"] :=" About  Total Commander"
    CommandInfo_Arr["<Exit>"] :=" Exit  Total Commander"
    CommandInfo_Arr["<Minimize>"] :=" minimize  Total Commander"
    CommandInfo_Arr["<Maximize>"] :=" maximize  Total Commander"
    CommandInfo_Arr["<Restore>"] :=" Restore down. Return to normal size "
    CommandInfo_Arr["<ClearCmdLine>"] :=" Clear the command line "
    CommandInfo_Arr["<NextCommand>"] :=" Next command "
    CommandInfo_Arr["<PrevCommand>"] :=" Previous command "
    CommandInfo_Arr["<AddPathToCmdline>"] :=" Copy the path to the command line "
    CommandInfo_Arr["<MultiRenameFiles>"] :=" Batch rename "
    CommandInfo_Arr["<SysInfo>"] :=" system message "
    CommandInfo_Arr["<OpenTransferManager>"] :=" Background Transfer Manager "
    CommandInfo_Arr["<SearchFor>"] :=" Search for files "
    CommandInfo_Arr["<FileSync>"] :=" Synchronize folders "
    CommandInfo_Arr["<Associate>"] :=" File association "
    CommandInfo_Arr["<InternalAssociate>"] :=" Define internal associations "
    CommandInfo_Arr["<CompareFilesByContent>"] :=" Compare the contents of the file "
    CommandInfo_Arr["<IntCompareFilesByContent>"] :=" Use the internal comparison program "
    CommandInfo_Arr["<CommandBrowser>"] :=" Browse TC commands. On OK it is copied into clipboard "
    CommandInfo_Arr["<VisButtonbar>"] :=" Toggle visibility :  toolbar "
    CommandInfo_Arr["<VisDriveButtons>"] :=" Toggle visibility :  Drive button "
    CommandInfo_Arr["<VisTwoDriveButtons>"] :=" Toggle visibility :  Two drive button bars "
    CommandInfo_Arr["<VisFlatDriveButtons>"] :=" Switch :  flat / convex drive button "
    CommandInfo_Arr["<VisFlatInterface>"] :=" Switch :  flat / Three-dimensional user interface "
    CommandInfo_Arr["<VisDriveCombo>"] :=" Toggle visibility :  Drive list "
    CommandInfo_Arr["<VisCurDir>"] :=" Toggle visibility :  Current folder "
    CommandInfo_Arr["<VisBreadCrumbs>"] :=" Toggle visibility :  Path navigation bar "
    CommandInfo_Arr["<VisTabHeader>"] :=" Toggle visibility :  Sort tab "
    CommandInfo_Arr["<VisStatusbar>"] :=" Toggle visibility :  Status Bar "
    CommandInfo_Arr["<VisCmdLine>"] :=" Toggle visibility :  Command Line "
    CommandInfo_Arr["<VisKeyButtons>"] :=" Toggle visibility :  Function button "
    CommandInfo_Arr["<ToggleViatcVim>"] :=" Toggle Viatc Vim Mode "
    CommandInfo_Arr["<ShowHoverTooltip>"] :=" Show file tooltip by moving cursor over it "
    CommandInfo_Arr["<ShowQuickSearch>"] :=" Show the quick search window "
    CommandInfo_Arr["<SwitchLongNames>"] :=" Toggle visibility :  Long file name display "
    CommandInfo_Arr["<RereadSource>"] :=" Refresh the source window "
    CommandInfo_Arr["<ShowOnlySelected>"] :=" Only the selected files are displayed "
    CommandInfo_Arr["<SwitchHidSys>"] :=" Toggle hidden or system file display "
    CommandInfo_Arr["<Switch83Names>"] :=" Toggle : 8.3  Type file name lowercase display "
    CommandInfo_Arr["<SwitchDirSort>"] :=" Toggle :  The folders are sorted by name "
    CommandInfo_Arr["<DirBranch>"] :=" Expand all folders "
    CommandInfo_Arr["<DirBranchSel>"] :=" Only the selected folder is expanded "
    CommandInfo_Arr["<50Percent>"] :=" Set the window divider at 50%"
    CommandInfo_Arr["<100Percent>"] :=" Set the window divider at 100% (TC 8.0+)"
    CommandInfo_Arr["<VisDirTabs>"] :=" Toggle visibility :  Folder tab "
    CommandInfo_Arr["<VisXPThemeBackground>"] :=" Toggle : XP  Theme background "
    CommandInfo_Arr["<SwitchOverlayIcons>"] :=" Toggle :  Overlay icon display "
    CommandInfo_Arr["<VisHistHotButtons>"] :=" Toggle visibility :  Folder history and frequently used folder buttons "
    CommandInfo_Arr["<SwitchWatchDirs>"] :=" Enable / Disable :  The folder is automatically refreshed "
    CommandInfo_Arr["<SwitchIgnoreList>"] :=" Enable / Disable :  Customize hidden files "
    CommandInfo_Arr["<SwitchX64Redirection>"] :=" Toggle : 32  Bit system32  Directory redirect (64 Bit  Windows)"
    CommandInfo_Arr["<SeparateTreeOff>"] :=" Close the separate folder tree panel "
    CommandInfo_Arr["<SeparateTree1>"] :=" A separate folder tree panel "
    CommandInfo_Arr["<SeparateTree2>"] :=" Two separate folder tree panels "
    CommandInfo_Arr["<SwitchSeparateTree>"] :=" Toggle the independent folder tree panel status "
    CommandInfo_Arr["<ToggleSeparateTree1>"] :=" Toggle visibility :  A separate folder tree panel "
    CommandInfo_Arr["<ToggleSeparateTree2>"] :=" Toggle visibility :  Two separate folder tree panels "
    CommandInfo_Arr["<UserMenu1>"] :=" User menu  1"
    CommandInfo_Arr["<UserMenu2>"] :=" User menu  2"
    CommandInfo_Arr["<UserMenu3>"] :=" User menu  3"
    CommandInfo_Arr["<UserMenu4>"] :="..."
    CommandInfo_Arr["<UserMenu5>"] :="5"
    CommandInfo_Arr["<UserMenu6>"] :="6"
    CommandInfo_Arr["<UserMenu7>"] :="7"
    CommandInfo_Arr["<UserMenu8>"] :="8"
    CommandInfo_Arr["<UserMenu9>"] :="9"
    CommandInfo_Arr["<UserMenu10>"] :=" You can define other user menus "
    CommandInfo_Arr["<OpenNewTab>"] :=" New tab "
    CommandInfo_Arr["<OpenNewTabBg>"] :=" New tab ( In the background )"
    CommandInfo_Arr["<OpenDirInNewTab>"] :=" New tab ( And open the folder at the cursor )"
    CommandInfo_Arr["<OpenDirInNewTabOther>"] :=" New tab ( Open the folder in another window )"
    CommandInfo_Arr["<SwitchToNextTab>"] :=" Next tab (Ctrl+Tab)"
    CommandInfo_Arr["<SwitchToPreviousTab>"] :=" Previous tab (Ctrl+Shift+Tab)"
    CommandInfo_Arr["<CloseCurrentTab>"] :=" Close the Current tab "
    CommandInfo_Arr["<CloseAllTabs>"] :=" Close All tabs "
    CommandInfo_Arr["<DirTabsShowMenu>"] :=" Display the tab menu "
    CommandInfo_Arr["<ToggleLockCurrentTab>"] :=" Lock/Unlock the current tab "
    CommandInfo_Arr["<ToggleLockDcaCurrentTab>"] :=" Lock/Unlock the current tab ( You can change the folder )"
    CommandInfo_Arr["<ExchangeWithTabs>"] :=" Exchange left and right windows and their tabs "
    CommandInfo_Arr["<GoToLockedDir>"] :=" Go to the root folder of the locked tab "
    CommandInfo_Arr["<SrcActivateTab1>"] :=" Source window :  Activate the tab  1"
    CommandInfo_Arr["<SrcActivateTab2>"] :=" Source window :  Activate the tab  2"
    CommandInfo_Arr["<SrcActivateTab3>"] :="..."
    CommandInfo_Arr["<SrcActivateTab4>"] :=" max 99 "
    CommandInfo_Arr["<SrcActivateTab5>"] :="5"
    CommandInfo_Arr["<SrcActivateTab6>"] :="6"
    CommandInfo_Arr["<SrcActivateTab7>"] :="7"
    CommandInfo_Arr["<SrcActivateTab8>"] :="8"
    CommandInfo_Arr["<SrcActivateTab9>"] :="9"
    CommandInfo_Arr["<SrcActivateTab10>"] :="0"
    CommandInfo_Arr["<TrgActivateTab1>"] :=" Target window :  Activate the tab  1"
    CommandInfo_Arr["<TrgActivateTab2>"] :=" Target window :  Activate the tab  2"
    CommandInfo_Arr["<TrgActivateTab3>"] :="..."
    CommandInfo_Arr["<TrgActivateTab4>"] :=" max 99 "
    CommandInfo_Arr["<TrgActivateTab5>"] :="5"
    CommandInfo_Arr["<TrgActivateTab6>"] :="6"
    CommandInfo_Arr["<TrgActivateTab7>"] :="7"
    CommandInfo_Arr["<TrgActivateTab8>"] :="8"
    CommandInfo_Arr["<TrgActivateTab9>"] :="9"
    CommandInfo_Arr["<TrgActivateTab10>"] :="0"
    CommandInfo_Arr["<LeftActivateTab1>"] :=" Left window :  Activate the tab  1"
    CommandInfo_Arr["<LeftActivateTab2>"] :=" Left window :  Activate the tab  2"
    CommandInfo_Arr["<LeftActivateTab3>"] :="..."
    CommandInfo_Arr["<LeftActivateTab4>"] :=" max 99 "
    CommandInfo_Arr["<LeftActivateTab5>"] :="5"
    CommandInfo_Arr["<LeftActivateTab6>"] :="6"
    CommandInfo_Arr["<LeftActivateTab7>"] :="7"
    CommandInfo_Arr["<LeftActivateTab8>"] :="8"
    CommandInfo_Arr["<LeftActivateTab9>"] :="9"
    CommandInfo_Arr["<LeftActivateTab10>"] :="0"
    CommandInfo_Arr["<RightActivateTab1>"] :=" Right window :  Activate the tab  1"
    CommandInfo_Arr["<RightActivateTab2>"] :=" Right window :  Activate the tab  2"
    CommandInfo_Arr["<RightActivateTab3>"] :="..."
    CommandInfo_Arr["<RightActivateTab4>"] :=" max 99 "
    CommandInfo_Arr["<RightActivateTab5>"] :="5"
    CommandInfo_Arr["<RightActivateTab6>"] :="6"
    CommandInfo_Arr["<RightActivateTab7>"] :="7"
    CommandInfo_Arr["<RightActivateTab8>"] :="8"
    CommandInfo_Arr["<RightActivateTab9>"] :="9"
    CommandInfo_Arr["<RightActivateTab10>"] :="0"
    CommandInfo_Arr["<SrcSortByCol1>"] :=" Source window :  Sort by column 1"
    CommandInfo_Arr["<SrcSortByCol2>"] :=" Source window :  Sort by column 2"
    CommandInfo_Arr["<SrcSortByCol3>"] :="..."
    CommandInfo_Arr["<SrcSortByCol4>"] :=" max 99  Column "
    CommandInfo_Arr["<SrcSortByCol5>"] :="5"
    CommandInfo_Arr["<SrcSortByCol6>"] :="6"
    CommandInfo_Arr["<SrcSortByCol7>"] :="7"
    CommandInfo_Arr["<SrcSortByCol8>"] :="8"
    CommandInfo_Arr["<SrcSortByCol9>"] :="9"
    CommandInfo_Arr["<SrcSortByCol10>"] :="0"
    CommandInfo_Arr["<SrcSortByCol99>"] :="9"
    CommandInfo_Arr["<TrgSortByCol1>"] :=" Target window :  Sort by column 1"
    CommandInfo_Arr["<TrgSortByCol2>"] :=" Target window :  Sort by column 2"
    CommandInfo_Arr["<TrgSortByCol3>"] :="..."
    CommandInfo_Arr["<TrgSortByCol4>"] :=" max 99  Column "
    CommandInfo_Arr["<TrgSortByCol5>"] :="5"
    CommandInfo_Arr["<TrgSortByCol6>"] :="6"
    CommandInfo_Arr["<TrgSortByCol7>"] :="7"
    CommandInfo_Arr["<TrgSortByCol8>"] :="8"
    CommandInfo_Arr["<TrgSortByCol9>"] :="9"
    CommandInfo_Arr["<TrgSortByCol10>"] :="0"
    CommandInfo_Arr["<TrgSortByCol99>"] :="9"
    CommandInfo_Arr["<LeftSortByCol1>"] :=" Left window :  Sort by column 1"
    CommandInfo_Arr["<LeftSortByCol2>"] :=" Left window :  Sort by column 2"
    CommandInfo_Arr["<LeftSortByCol3>"] :="..."
    CommandInfo_Arr["<LeftSortByCol4>"] :=" max 99  Column "
    CommandInfo_Arr["<LeftSortByCol5>"] :="5"
    CommandInfo_Arr["<LeftSortByCol6>"] :="6"
    CommandInfo_Arr["<LeftSortByCol7>"] :="7"
    CommandInfo_Arr["<LeftSortByCol8>"] :="8"
    CommandInfo_Arr["<LeftSortByCol9>"] :="9"
    CommandInfo_Arr["<LeftSortByCol10>"] :="0"
    CommandInfo_Arr["<LeftSortByCol99>"] :="9"
    CommandInfo_Arr["<RightSortByCol1>"] :=" Right window :  Sort by column 1"
    CommandInfo_Arr["<RightSortByCol2>"] :=" Right window :  Sort by column 2"
    CommandInfo_Arr["<RightSortByCol3>"] :="..."
    CommandInfo_Arr["<RightSortByCol4>"] :=" max 99  Column "
    CommandInfo_Arr["<RightSortByCol5>"] :="5"
    CommandInfo_Arr["<RightSortByCol6>"] :="6"
    CommandInfo_Arr["<RightSortByCol7>"] :="7"
    CommandInfo_Arr["<RightSortByCol8>"] :="8"
    CommandInfo_Arr["<RightSortByCol9>"] :="9"
    CommandInfo_Arr["<RightSortByCol10>"] :="0"
    CommandInfo_Arr["<RightSortByCol99>"] :="9"
    CommandInfo_Arr["<SrcCustomView1>"] :=" Source window :  Customize the column view  1"
    CommandInfo_Arr["<SrcCustomView2>"] :=" Source window :  Customize the column view  2"
    CommandInfo_Arr["<SrcCustomView3>"] :="..."
    CommandInfo_Arr["<SrcCustomView4>"] :=" 29 max"
    CommandInfo_Arr["<SrcCustomView5>"] :="5"
    CommandInfo_Arr["<SrcCustomView6>"] :="6"
    CommandInfo_Arr["<SrcCustomView7>"] :="7"
    CommandInfo_Arr["<SrcCustomView8>"] :="8"
    CommandInfo_Arr["<SrcCustomView9>"] :="9"
    CommandInfo_Arr["<LeftCustomView1>"] :=" Left window :  Customize the column view  1"
    CommandInfo_Arr["<LeftCustomView2>"] :=" Left window :  Customize the column view  2"
    CommandInfo_Arr["<LeftCustomView3>"] :="..."
    CommandInfo_Arr["<LeftCustomView4>"] :=" 29 max"
    CommandInfo_Arr["<LeftCustomView5>"] :="5"
    CommandInfo_Arr["<LeftCustomView6>"] :="6"
    CommandInfo_Arr["<LeftCustomView7>"] :="7"
    CommandInfo_Arr["<LeftCustomView8>"] :="8"
    CommandInfo_Arr["<LeftCustomView9>"] :="9"
    CommandInfo_Arr["<RightCustomView1>"] :=" Right window :  Customize the column view  1"
    CommandInfo_Arr["<RightCustomView2>"] :=" Right window :  Customize the column view  2"
    CommandInfo_Arr["<RightCustomView3>"] :="..."
    CommandInfo_Arr["<RightCustomView4>"] :=" 29 max"
    CommandInfo_Arr["<RightCustomView5>"] :="5"
    CommandInfo_Arr["<RightCustomView6>"] :="6"
    CommandInfo_Arr["<RightCustomView7>"] :="7"
    CommandInfo_Arr["<RightCustomView8>"] :="8"
    CommandInfo_Arr["<RightCustomView9>"] :="9"
    CommandInfo_Arr["<SrcNextCustomView>"] :=" Source window :  Next custom view "
    CommandInfo_Arr["<SrcPrevCustomView>"] :=" Source window :  Previous view "
    CommandInfo_Arr["<TrgNextCustomView>"] :=" Target window :  Next custom view "
    CommandInfo_Arr["<TrgPrevCustomView>"] :=" Target window :  Previous view "
    CommandInfo_Arr["<LeftNextCustomView>"] :=" Left window :  Next custom view "
    CommandInfo_Arr["<LeftPrevCustomView>"] :=" Left window :  Previous view "
    CommandInfo_Arr["<RightNextCustomView>"] :=" Right window :  Next custom view "
    CommandInfo_Arr["<RightPrevCustomView>"] :=" Right window :  Previous view "
    CommandInfo_Arr["<LoadAllOnDemandFields>"] :=" All files are loaded with notes as needed "
    CommandInfo_Arr["<LoadSelOnDemandFields>"] :=" Only selected files are loading notes as needed "
    CommandInfo_Arr["<ContentStopLoadFields>"] :=" Stop background loading notes "
    CommandInfo_Arr["<SwitchDarkmode>"] :="Toggle dark mode on and off"
    CommandInfo_Arr["<EnableDarkmode>"] :="Turn dark mode on"
    CommandInfo_Arr["<DisableDarkmode>"] :="Turn dark mode off. Light mode"
}

; ---- Action Codes{{{3
<SrcComments>:
SendPos(300)
Return
<SrcShort>:
SendPos(301)
Return
<SrcLong>:
SendPos(302)
Return
<SrcTree>:
SendPos(303)
<SrcQuickview>:
SendPos(304)
Return
<VerticalPanels>:
SendPos(305)
Return
<WidePanelToggle>:
SendPos(305)  ;<VerticalPanels>
if %wide%
{
    SendPos(909)  ;<50Percent>:
    wide:=false
}
else
{
    SendPos(910)  ;<100Percent>:
    wide:=true
}
Return
<SrcQuickInternalOnly>:
SendPos(306)
Return
<SrcHideQuickview>:
SendPos(307)
Return
<SrcExecs>:
SendPos(311)
Return
<SrcAllFiles>:
SendPos(312)
Return
<SrcUserSpec>:
SendPos(313)
Return
<SrcUserDef>:
SendPos(314)
Return
<SrcByName>:
SendPos(321)
Return
<SrcByExt>:
SendPos(322)
Return
<SrcBySize>:
SendPos(323)
Return
<SrcByDateTime>:
SendPos(324)
Return
<SrcUnsorted>:
SendPos(325)
Return
<SrcNegOrder>:
SendPos(330)
Return
<SrcOpenDrives>:
SendPos(331)
Return
<SrcThumbs>:
SendPos(269	)
Return
<SrcCustomViewMenu>:
SendPos(270)
Return
<SrcPathFocus>:
SendPos(332)
Return
Return
<LeftComments>:
SendPos(100)
Return
<LeftShort>:
SendPos(101)
Return
<LeftLong>:
SendPos(102)
Return
<LeftTree>:
SendPos(103)
Return
<LeftQuickview>:
SendPos(104)
Return
<LeftQuickInternalOnly>:
SendPos(106)
Return
<LeftHideQuickview>:
SendPos(107)
Return
<LeftExecs>:
SendPos(111)
Return
<LeftAllFiles>:
SendPos(112)
Return
<LeftUserSpec>:
SendPos(113)
Return
<LeftUserDef>:
SendPos(114)
Return
<LeftByName>:
SendPos(121)
Return
<LeftByExt>:
SendPos(122)
Return
<LeftBySize>:
SendPos(123)
Return
<LeftByDateTime>:
SendPos(124)
Return
<LeftUnsorted>:
SendPos(125)
Return
<LeftNegOrder>:
SendPos(130)
Return
<LeftOpenDrives>:
SendPos(131)
Return
<LeftPathFocus>:
SendPos(132)
Return
<LeftDirBranch>:
SendPos(203)
Return
<LeftDirBranchSel>:
SendPos(204)
Return
<LeftThumbs>:
SendPos(69)
Return
<LeftCustomViewMenu>:
SendPos(70)
Return
Return
<RightComments>:
SendPos(200)
Return
<RightShort>:
SendPos(201)
Return
<RightLong>:
SendPos(202)
Return
<RightTre>:
SendPos(203)
Return
<RightQuickvie>:
SendPos(204)
Return
<RightQuickInternalOnl>:
SendPos(206)
Return
<RightHideQuickvie>:
SendPos(207)
Return
<RightExec>:
SendPos(211)
Return
<RightAllFile>:
SendPos(212)
Return
<RightUserSpe>:
SendPos(213)
Return
<RightUserDe>:
SendPos(214)
Return
<RightByNam>:
SendPos(221)
Return
<RightByEx>:
SendPos(222)
Return
<RightBySiz>:
SendPos(223)
Return
<RightByDateTim>:
SendPos(224)
Return
<RightUnsorte>:
SendPos(225)
Return
<RightNegOrde>:
SendPos(230)
Return
<RightOpenDrive>:
<RightOpenDrives>:
SendPos(231)
Return
<RightPathFocu>:
SendPos(232)
Return
<RightDirBranch>:
SendPos(2035)
Return
<RightDirBranchSel>:
SendPos(2048)
Return
<RightThumb>:
SendPos(169)
Return
<RightCustomViewMen>:
SendPos(170)
Return
Return
<List>:
SendPos(903)
Return
<ListInternalOnly>:
SendPos(1006)
Return
<Edit>:
SendPos(904)
Return
<Copy>:
SendPos(905)
Return
<CopySamepanel>:
SendPos(3100)
Return
<CopyOtherpanel>:
SendPos(3101)
Return
<RenMov>:
SendPos(906)
Return
<MkDir>:
SendPos(907)
Return
<Delete>:
SendPos(908)
Return
<TestArchive>:
SendPos(518)
Return
<PackFiles>:
SendPos(508)
Return
<UnpackFiles>:
SendPos(509)
Return
<RenameOnly>:
SendPos(1002)
Return
<RenameSingleFile>:
SendPos(1007)
Return
<MoveOnly>:
SendPos(1005)
Return
<Properties>:
SendPos(1003)
Return
<CreateShortcut>:
SendPos(1004)
Return
<Return>:
SendPos(1001)
Return
<OpenAsUser>:
SendPos(2800)
Return
<Split>:
SendPos(560)
Return
<Combine>:
SendPos(561)
Return
<Encode>:
SendPos(562)
Return
<Decode>:
SendPos(563)
Return
<CRCcreate>:
SendPos(564)
Return
<CRCcheck>:
SendPos(565)
Return
<SetAttrib>:
SendPos(502)
Return
Return
<Config>:
SendPos(490)
Return
<DisplayConfig>:
SendPos(486)
Return
<IconConfig>:
SendPos(477)
Return
<FontConfig>:
SendPos(492)
Return
<ColorConfig>:
SendPos(494)
Return
<ConfTabChange>:
SendPos(497)
Return
<DirTabsConfig>:
SendPos(488)
Return
<CustomColumnConfig>:
SendPos(483)
Return
<CustomColumnDlg>:
SendPos(2920)
Return
<LanguageConfig>:
SendPos(499)
Return
<Config2>:
SendPos(516)
Return
<EditConfig>:
SendPos(496)
Return
<CopyConfig>:
SendPos(487)
Return
<RefreshConfig>:
SendPos(478)
Return
<QuickSearchConfig>:
SendPos(479)
Return
<FtpConfig>:
SendPos(489)
Return
<PluginsConfig>:
SendPos(484)
Return
<ThumbnailsConfig>:
SendPos(482)
Return
<LogConfig>:
SendPos(481)
Return
<IgnoreConfig>:
SendPos(480)
Return
<PackerConfig>:
SendPos(491)
Return
<ZipPackerConfig>:
SendPos(485)
Return
<Confirmation>:
SendPos(495)
Return
<ConfigSavePos>:
SendPos(493)
Return
<ButtonConfig>:
SendPos(498)
Return
<ConfigSaveSettings>:
SendPos(580)
Return
<ConfigChangeIniFiles>:
SendPos(581)
Return
<ConfigSaveDirHistory>:
SendPos(582)
Return
<ChangeStartMenu>:
SendPos(700)
Return
Return
<NetConnect>:
SendPos(512)
Return
<NetDisconnect>:
SendPos(513)
Return
<NetShareDir>:
SendPos(514)
Return
<NetUnshareDir>:
SendPos(515)
Return
<AdministerServer>:
SendPos(2204)
Return
<ShowFileUser>:
SendPos(2203)
Return
Return
<GetFileSpace>:
SendPos(503)
Return
<VolumeId>:
SendPos(505)
Return
<VersionInfo>:
SendPos(510)
Return
<ExecuteDOS>:
SendPos(511)
Return
<CompareDirs>:
SendPos(533)
Return
<CompareDirsWithSubdirs>:
SendPos(536)
Return
<ContextMenu>:
SendPos(2500)
Return
<ContextMenuInternal>:
SendPos(2927)
Return
<ContextMenuInternalCursor>:
SendPos(2928)
Return
<ShowRemoteMenu>:
SendPos(2930)
Return
<SyncChangeDir>:
SendPos(2600)
Return
<EditComment>:
SendPos(2700)
Return
<FocusLeft>:
SendPos(4001)
Return
<FocusRight>:
SendPos(4002)
Return
<FocusCmdLine>:
SendPos(4003)
Return
<FocusButtonBar>:
SendPos(4004)
Return
<CountDirContent>:
SendPos(2014)
Return
<UnloadPlugins>:
SendPos(2913)
Return
<DirMatch>:
SendPos(534)
Return
<Exchange>:
SendPos(531)
Return
<MatchSrc>:
SendPos(532)
Return
<ReloadSelThumbs>:
SendPos(2918)
Return
Return
<DirectCableConnect>:
SendPos(2300)
Return
<NTinstallDriver>:
SendPos(2301)
Return
<NTremoveDriver>:
SendPos(2302)
Return
Return
<PrintDir>:
SendPos(2027)
Return
<PrintDirSub>:
SendPos(2028)
Return
<PrintFile>:
SendPos(504)
Return
Return
<SpreadSelection>:
SendPos(521)
Return
<SelectBoth>:
SendPos(3311)
Return
<SelectFiles>:
SendPos(3312)
Return
<SelectFolders>:
SendPos(3313)
Return
<ShrinkSelection>:
SendPos(522)
Return
<ClearFiles>:
SendPos(3314)
Return
<ClearFolders>:
SendPos(3315)
Return
<ClearSelCfg>:
SendPos(3316)
Return
<SelectAll>:
SendPos(523)
Return
<SelectAllBoth>:
SendPos(3301)
Return
<SelectAllFiles>:
SendPos(3302)
Return
<SelectAllFolders>:
SendPos(3303)
Return
<ClearAll>:
SendPos(524)
Return
<ClearAllFiles>:
SendPos(3304)
Return
<ClearAllFolders>:
SendPos(3305)
Return
<ClearAllCfg>:
SendPos(3306)
Return
<ExchangeSelection>:
SendPos(525)
Return
<ExchangeSelBoth>:
SendPos(3321)
Return
<ExchangeSelFiles>:
SendPos(3322)
Return
<ExchangeSelFolders>:
SendPos(3323)
Return
<SelectCurrentExtension>:
SendPos(527)
Return
<UnselectCurrentExtension>:
SendPos(528)
Return
<SelectCurrentName>:
SendPos(541)
Return
<UnselectCurrentName>:
SendPos(542)
Return
<SelectCurrentNameExt>:
SendPos(543)
Return
<UnselectCurrentNameExt>:
SendPos(544)
Return
<SelectCurrentPath>:
SendPos(537)
Return
<UnselectCurrentPath>:
SendPos(538)
Return
<RestoreSelection>:
SendPos(529)
Return
<SaveSelection>:
SendPos(530)
Return
<SaveSelectionToFile>:
SendPos(2031)
Return
<SaveSelectionToFileA>:
SendPos(2041)
Return
<SaveSelectionToFileW>:
SendPos(2042)
Return
<SaveDetailsToFile>:
SendPos(2039)
Return
<SaveDetailsToFileA>:
SendPos(2043)
Return
<SaveDetailsToFileW>:
SendPos(2044)
Return
<LoadSelectionFromFile>:
SendPos(2032)
Return
<LoadSelectionFromClip>:
SendPos(2033)
Return
Return
<EditPermissionInfo>:
SendPos(2200)
Return
<EditAuditInfo>:
SendPos(2201)
Return
<EditOwnerInfo>:
SendPos(2202)
Return
Return
<CutToClipboard>:
SendPos(2007)
Return
<CopyToClipboard>:
SendPos(2008)
Return
<PasteFromClipboard>:
SendPos(2009)
Return
<CopyNamesToClip>:
SendPos(2017)
Return
<CopyFullNamesToClip>:
SendPos(2018)
Return
<CopyNetNamesToClip>:
SendPos(2021)
Return
<CopySrcPathToClip>:
SendPos(2029)
Return
<CopyTrgPathToClip>:
SendPos(2030)
Return
<CopyFileDetailsToClip>:
SendPos(2036)
Return
<CopyFpFileDetailsToClip>:
SendPos(2037)
Return
<CopyNetFileDetailsToClip>:
SendPos(2038)
Return
Return
<FtpConnect>:
SendPos(550)
Return
<FtpNew>:
SendPos(551)
Return
<FtpDisconnect>:
SendPos(552)
Return
<FtpHiddenFiles>:
SendPos(553)
Return
<FtpAbort>:
SendPos(554)
Return
<FtpResumeDownload>:
SendPos(555)
Return
<FtpSelectTransferMode>:
SendPos(556)
Return
<FtpAddToList>:
SendPos(557)
Return
<FtpDownloadList>:
SendPos(558)
Return
Return
<GotoPreviousDir>:
SendPos(570,True)
Return
<GotoNextDir>:
SendPos(571,True)
Return
<DirectoryHistory>:
SendPos(572)
Return
<GotoPreviousLocalDir>:
SendPos(573)
Return
<GotoNextLocalDir>:
SendPos(574)
Return
<DirectoryHotlist>:
SendPos(526)
Return
<GoToRoot>:
SendPos(2001)
Return
<GoToParent>:
SendPos(2002,True)
Return
<GoToDir>:
SendPos(2003)
Return
<OpenDesktop>:
SendPos(2121)
Return
<OpenDrives>:
SendPos(2122)
Return
<OpenControls>:
SendPos(2123)
Return
<OpenFonts>:
SendPos(2124)
Return
<OpenNetwork>:
SendPos(2125)
Return
<OpenPrinters>:
SendPos(2126)
Return
<OpenRecycled>:
SendPos(2127)
Return
<CDtree>:
SendPos(500)
Return
<TransferLeft>:
SendPos(2024)
Return
<TransferRight>:
SendPos(2025)
Return
<EditPath>:
SendPos(2912)
Return
<GoToFirstFile>:
SendPos(2050)
Return
<GotoNextDrive>:
SendPos(2051)
Return
<GotoPreviousDrive>:
SendPos(2052)
Return
<GotoNextSelected>:
SendPos(2053)
Return
<GotoPrevSelected>:
SendPos(2054)
Return
<GotoDriveA>:
SendPos(2061)
Return
<GotoDriveC>:
SendPos(2063)
Return
<GotoDriveD>:
SendPos(2064)
Return
<GotoDriveE>:
SendPos(2065)
Return
<GotoDriveF>:
SendPos(2066)
Return
<GotoDriveG>:
SendPos(2067)
Return
<GotoDriveH>:
SendPos(2068)
Return
<GotoDriveI>:
SendPos(2069)
Return
<GotoDriveJ>:
SendPos(2070)
Return
<GotoDriveK>:
SendPos(2071)
Return
<GotoDriveL>:
SendPos(2072)
Return
<GotoDriveU>:
SendPos(2081)
Return
<GotoDriveZ>:
SendPos(2086)
Return
Return
<HelpIndex>:
SendPos(610)
Return
<Keyboard>:
SendPos(620)
Return
<Register>:
SendPos(630)
Return
<VisitHomepage>:
SendPos(640)
Return
<About>:
SendPos(690)
Return
Return
<Exit>:
SendPos(24340)
Return
<Minimize>:
SendPos(2000)
Return
<Maximize>:
SendPos(2015)
Return
<Restore>:
SendPos(2016)
Return
Return
<ClearCmdLine>:
SendPos(2004)
Return
<NextCommand>:
SendPos(2005)
Return
<PrevCommand>:
SendPos(2006)
Return
<AddPathToCmdline>:
SendPos(2019)
Return
Return
<MultiRenameFiles>:
SendPos(2400)
Return
<SysInfo>:
SendPos(506)
Return
<OpenTransferManager>:
SendPos(559)
Return
<SearchFor>:
SendPos(501)
Return
<FileSync>:
SendPos(2020)
Return
<Associate>:
SendPos(507)
Return
<InternalAssociate>:
SendPos(519)
Return
<CompareFilesByContent>:
SendPos(2022)
Return
<IntCompareFilesByContent>:
SendPos(2040)
Return
<CommandBrowser>:
SendPos(2924)
Return
Return
<VisButtonbar>:
SendPos(2901)
Return
<VisDriveButtons>:
SendPos(2902)
Return
<VisTwoDriveButtons>:
SendPos(2903)
Return
<VisFlatDriveButtons>:
SendPos(2904)
Return
<VisFlatInterface>:
SendPos(2905)
Return
<VisDriveCombo>:
SendPos(2906)
Return
<VisCurDir>:
SendPos(2907)
Return
<VisBreadCrumbs>:
SendPos(2926)
Return
<VisTabHeader>:
SendPos(2908)
Return
<VisStatusbar>:
SendPos(2909)
Return
<VisCmdLine>:
SendPos(2910)
Return
<VisKeyButtons>:
SendPos(2911)
Return
<ShowHoverTooltip>:
SendPos(2914)
Return
<ShowQuickSearch>:
SendPos(2915)
Return
<SwitchLongNames>:
SendPos(2010)
Return
<RereadSource>:
SendPos(540)
Return
<ShowOnlySelected>:
SendPos(2023)
Return
<SwitchHidSys>:
SendPos(2011)
Return
<Switch83Names>:
SendPos(2013)
Return
<SwitchDirSort>:
SendPos(2012)
Return
<DirBranch>:
SendPos(2026)
Return
<DirBranchSel>:
SendPos(2046)
Return
<50Percent>:
SendPos(909)
Return
<100Percent>:
SendPos(910)
Return
<VisDirTabs>:
SendPos(2916)
Return
<VisXPThemeBackground>:
SendPos(2923)
Return
<SwitchOverlayIcons>:
SendPos(2917)
Return
<VisHistHotButtons>:
SendPos(2919)
Return
<SwitchWatchDirs>:
SendPos(2921)
Return
<SwitchIgnoreList>:
SendPos(2922)
Return
<SwitchX64Redirection>:
SendPos(2925)
Return
<SeparateTreeOff>:
SendPos(3200)
Return
<SeparateTree1>:
SendPos(3201)
Return
<SeparateTree2>:
SendPos(3202)
Return
<SwitchSeparateTree>:
SendPos(3203)
Return
<ToggleSeparateTree1>:
SendPos(3204)
Return
<ToggleSeparateTree2>:
SendPos(3205)
Return
Return
<UserMenu1>:
SendPos(701)
Return
<UserMenu2>:
SendPos(702)
Return
<UserMenu3>:
SendPos(703)
Return
<UserMenu4>:
SendPos(704)
Return
<UserMenu5>:
SendPos(70)
Return
<UserMenu6>:
SendPos(70)
Return
<UserMenu7>:
SendPos(70)
Return
<UserMenu8>:
SendPos(70)
Return
<UserMenu9>:
SendPos(70)
Return
<UserMenu10>:
SendPos(710)
Return
Return
<OpenNewTab>:
SendPos(3001)
Return
<OpenNewTabBg>:
SendPos(3002)
Return
<OpenDirInNewTab>:
SendPos(3003)
Return
<OpenDirInNewTabOther>:
SendPos(3004)
Return
<SwitchToNextTab>:
SendPos(3005)
Return
<SwitchToPreviousTab>:
SendPos(3006)
Return
<CloseCurrentTab>:
SendPos(3007)
Return
<CloseAllTabs>:
SendPos(3008)
Return
<DirTabsShowMenu>:
SendPos(3014)
;SendPos(3009)
Return
<ToggleLockCurrentTab>:
SendPos(3010)
Return
<ToggleLockDcaCurrentTab>:
SendPos(3012)
Return
<ExchangeWithTabs>:
SendPos(535)
Return
<GoToLockedDir>:
SendPos(3011)
Return
<SrcActivateTab1>:
SendPos(5001)
Return
<SrcActivateTab2>:
SendPos(5002)
Return
<SrcActivateTab3>:
SendPos(5003)
Return
<SrcActivateTab4>:
SendPos(5004)
Return
<SrcActivateTab5>:
SendPos(5005)
Return
<SrcActivateTab6>:
SendPos(5006)
Return
<SrcActivateTab7>:
SendPos(5007)
Return
<SrcActivateTab8>:
SendPos(5008)
Return
<SrcActivateTab9>:
SendPos(5009)
Return
<SrcActivateTab10>:
SendPos(5010)
Return
<TrgActivateTab1>:
SendPos(5101)
Return
<TrgActivateTab2>:
SendPos(5102)
Return
<TrgActivateTab3>:
SendPos(5103)
Return
<TrgActivateTab4>:
SendPos(5104)
Return
<TrgActivateTab5>:
SendPos(5105)
Return
<TrgActivateTab6>:
SendPos(5106)
Return
<TrgActivateTab7>:
SendPos(5107)
Return
<TrgActivateTab8>:
SendPos(5108)
Return
<TrgActivateTab9>:
SendPos(5109)
Return
<TrgActivateTab10>:
SendPos(5110)
Return
<LeftActivateTab1>:
SendPos(5201)
Return
<LeftActivateTab2>:
SendPos(5202)
Return
<LeftActivateTab3>:
SendPos(5203)
Return
<LeftActivateTab4>:
SendPos(5204)
Return
<LeftActivateTab5>:
SendPos(5205)
Return
<LeftActivateTab6>:
SendPos(5206)
Return
<LeftActivateTab7>:
SendPos(5207)
Return
<LeftActivateTab8>:
SendPos(5208)
Return
<LeftActivateTab9>:
SendPos(5209)
Return
<LeftActivateTab10>:
SendPos(5210)
Return
<RightActivateTab1>:
SendPos(5301)
Return
<RightActivateTab2>:
SendPos(5302)
Return
<RightActivateTab3>:
SendPos(5303)
Return
<RightActivateTab4>:
SendPos(5304)
Return
<RightActivateTab5>:
SendPos(5305)
Return
<RightActivateTab6>:
SendPos(5306)
Return
<RightActivateTab7>:
SendPos(5307)
Return
<RightActivateTab8>:
SendPos(5308)
Return
<RightActivateTab9>:
SendPos(5309)
Return
<RightActivateTab10>:
SendPos(5310)
Return
Return
<SrcSortByCol1>:
SendPos(6001)
Return
<SrcSortByCol2>:
SendPos(6002)
Return
<SrcSortByCol3>:
SendPos(6003)
Return
<SrcSortByCol4>:
SendPos(6004)
Return
<SrcSortByCol5>:
SendPos(6005)
Return
<SrcSortByCol6>:
SendPos(6006)
Return
<SrcSortByCol7>:
SendPos(6007)
Return
<SrcSortByCol8>:
SendPos(6008)
Return
<SrcSortByCol9>:
SendPos(6009)
Return
<SrcSortByCol10>:
SendPos(6010)
Return
<SrcSortByCol99>:
SendPos(6099)
Return
<TrgSortByCol1>:
SendPos(6101)
Return
<TrgSortByCol2>:
SendPos(6102)
Return
<TrgSortByCol3>:
SendPos(6103)
Return
<TrgSortByCol4>:
SendPos(6104)
Return
<TrgSortByCol5>:
SendPos(6105)
Return
<TrgSortByCol6>:
SendPos(6106)
Return
<TrgSortByCol7>:
SendPos(6107)
Return
<TrgSortByCol8>:
SendPos(6108)
Return
<TrgSortByCol9>:
SendPos(6109)
Return
<TrgSortByCol10>:
SendPos(6110)
Return
<TrgSortByCol99>:
SendPos(6199)
Return
<LeftSortByCol1>:
SendPos(6201)
Return
<LeftSortByCol2>:
SendPos(6202)
Return
<LeftSortByCol3>:
SendPos(6203)
Return
<LeftSortByCol4>:
SendPos(6204)
Return
<LeftSortByCol5>:
SendPos(6205)
Return
<LeftSortByCol6>:
SendPos(6206)
Return
<LeftSortByCol7>:
SendPos(6207)
Return
<LeftSortByCol8>:
SendPos(6208)
Return
<LeftSortByCol9>:
SendPos(6209)
Return
<LeftSortByCol10>:
SendPos(6210)
Return
<LeftSortByCol99>:
SendPos(6299)
Return
<RightSortByCol1>:
SendPos(6301)
Return
<RightSortByCol2>:
SendPos(6302)
Return
<RightSortByCol3>:
SendPos(6303)
Return
<RightSortByCol4>:
SendPos(6304)
Return
<RightSortByCol5>:
SendPos(6305)
Return
<RightSortByCol6>:
SendPos(6306)
Return
<RightSortByCol7>:
SendPos(6307)
Return
<RightSortByCol8>:
SendPos(6308)
Return
<RightSortByCol9>:
SendPos(6309)
Return
<RightSortByCol10>:
SendPos(6310)
Return
<RightSortByCol99>:
SendPos(6399)
Return
Return
<SrcCustomView1>:
SendPos(271)
Return
<SrcCustomView2>:
SendPos(272)
Return
<SrcCustomView3>:
SendPos(273)
Return
<SrcCustomView4>:
SendPos(274)
Return
<SrcCustomView5>:
SendPos(275)
Return
<SrcCustomView6>:
SendPos(276)
Return
<SrcCustomView7>:
SendPos(277)
Return
<SrcCustomView8>:
SendPos(278)
Return
<SrcCustomView9>:
SendPos(279)
Return
<LeftCustomView1>:
SendPos(710)
Return
<LeftCustomView2>:
SendPos(72)
Return
<LeftCustomView3>:
SendPos(73)
Return
<LeftCustomView4>:
SendPos(74)
Return
<LeftCustomView5>:
SendPos(75)
Return
<LeftCustomView6>:
SendPos(76)
Return
<LeftCustomView7>:
SendPos(77)
Return
<LeftCustomView8>:
SendPos(78)
Return
<LeftCustomView9>:
SendPos(79)
Return
<RightCustomView1>:
SendPos(171)
Return
<RightCustomView2>:
SendPos(172)
Return
<RightCustomView3>:
SendPos(173)
Return
<RightCustomView4>:
SendPos(174)
Return
<RightCustomView5>:
SendPos(175)
Return
<RightCustomView6>:
SendPos(176)
Return
<RightCustomView7>:
SendPos(177)
Return
<RightCustomView8>:
SendPos(178)
Return
<RightCustomView9>:
SendPos(179)
Return
<SrcNextCustomView>:
SendPos(5501)
Return
<SrcPrevCustomView>:
SendPos(5502)
Return
<TrgNextCustomView>:
SendPos(5503)
Return
<TrgPrevCustomView>:
SendPos(5504)
Return
<LeftNextCustomView>:
SendPos(5505)
Return
<LeftPrevCustomView>:
SendPos(5506)
Return
<RightNextCustomView>:
SendPos(5507)
Return
<RightPrevCustomView>:
SendPos(5508)
Return
<LoadAllOnDemandFields>:
SendPos(5512)
Return
<LoadSelOnDemandFields>:
SendPos(5513)
Return
<ContentStopLoadFields>:
SendPos(5514)
Return

<SwitchDarkmode>:
SendPos(2950)
    Return
<EnableDarkmode>:
SendPos(2951)
Return
<DisableDarkmode>:
SendPos(2952)
Return

;}}}


;----------------- Aux ----------

<SetTitleAsDateTime>:
SetTitleAsDateTime()
Return

SetTitleAsDateTime()
{
    SetTimer subTimer, 500
}

subTimer:
if WinActive( "ahk_class TTOTAL_CMD" )
if WinActive(ahk_exe_TC)
{
   FormatTime, time,, dd.MM.yyyy - HH:mm:ss
   WinGet, ProcessPath, ProcessPath
   FileGetVersion, version, %ProcessPath%
   IfInString, ProcessPath, TOTALCMD64.EXE
      WinSetTitle Total Commander (x64)- %version% -     %time%
   else
      WinSetTitle Total Commander - %version% -     %time%
}
Return


;----------------- F11TC ----------
; $ prefix in the hotkey (or #UseHook earlier in the script) will prevent the script from
; being triggered if the script uses the Send command to send the keys that comprise the hotkey itself
#If %F11TC%
$F11::
If WinActive(ahk_exe_TC)
{
    If F11TC = 1
        gosub <TcFullScreen>
    If F11TC = 2
        gosub <TcFullScreenAlmost>
    Else If F11TC = 3
        gosub <TCFullScreenWithExePlugin>
}
else send, {F11}
return   
#If


;----------------- IrfanView ----------
#If %IrfanView%   ;this variable is set in the viatc.ini file
#If (WinActive("ahk_exe i_view32.exe") or WinActive("ahk_exe i_view64.exe"))
#If (WinActive("ahk_class IrfanView") or WinActive("ahk_class FullScreenClass"))
;IrfanView map  j = right = next
    j::Send {Right}
    ;IrfanView map  k = left = prev
    k::Send {Left}
#If

; IrfanView autoadvance folder in TotalCommander
; Limitations and TODO: 
;   - it will execute whatever extension of the first file is, you have to be sure it's an image
;   - it will get stuck at the last nested folder, you have to go up a folder manually
;   - not every keyboard have ScrollLock, perhaps the Insert key is better
<Traverse>:
;ComObjCreate("SAPI.SpVoice").Speak("Traverse")
If (WinActive("ahk_exe i_view32.exe")
or WinActive("ahk_exe i_view64.exe")
or WinActive(ahk_exe_TC))
{
    ;the second Esc is if Irfan was full-screen, Irfan has an option to exit with one Esc too
    Send {Esc}{Esc}
    loop 11
    {
        If WinActive(ahk_exe_TC)
            break
        Sleep, 200  ; let it close, 400 is sometimes not enough
    }
    If WinActive(ahk_exe_TC)
    {
        Send {BackSpace}    ; go up a dir
        Sleep, 30
        ; check if TC is still active, it would mean that no files were opened
        loop 9   ; max depth of nested folders
        if WinActive(ahk_exe_TC)
        {   
            ; TC is active so no files were opened
            ;tooltip subfolder: %A_Index% 
            msg = hold Escape or %IrfanViewKey% or ScrollLock to abort
            ;msg = hold Escape or ScrollLock to abort
            subfolder := A_Index - 2
            if subfolder > 0
                msg .= "`nsubfolder: " . subfolder
            ControlGetFocus,CurrentListBox,ahk_class TTOTAL_CMD
            ControlGetPos,xn,yn,,,%CurrentListBox%,AHK_CLASS TTOTAL_CMD
            xn += 90
            yn -= 25
            Tooltip,%Msg%,%xn%,%yn%
            Send {Down}     ; ommit the ".." or the folder just visited
            ;Sleep, 30
            Send {Space}    ; highlight/mark
            Sleep, 900      ; this delay is only for the user to have time to see what's about to be opened
            ; Abort on Esc
            If GetKeyState("Escape", "P")
            {
                ; The Escape key has been pressed, so break out of the loop.
                ;MsgBox Aborted
                Tooltip,aborted,%xn%,%yn%
                sleep 2000
                break
                ;MsgBox paused until OK
            }

            ;Ikey := '"' . %IrfanViewKey% . '"'            
            ;Ikey="%IrfanViewKey%"
            ;Msgbox  Debugging IrfanViewKey = [%IrfanViewKey%]  on line %A_LineNumber% ;!!!
            ;Msgbox  Debugging Ikey = [%Ikey%]  on line %A_LineNumber% ;!!!
            ;If GetKeyState(%Ikey%, "P")
            ;If GetKeyState(%IrfanViewKey%, "P")   ; doesn't work
            If GetKeyState(IrfanViewKey, "P")
            {
                Tooltip,aborted,%xn%,%yn%
                sleep 2000
                break
            }

            ; Abort on ScrollLock being "P"hysically pressed and held
            If GetKeyState("ScrollLock", "P")
            {
                ; The ScrollLock key has been pressed, so break out of the loop.
                Tooltip,aborted,%xn%,%yn%
                sleep 2000
                break
                ;MsgBox paused until OK
            }
            Send {Space}    ; unselect
            Send {Enter}    ; God please it's an image not an exe
            ;subfolder := A_Index - 1
            ;if subfolder > 0
                ;msg .= "`nsubfolder: " . subfolder . " ----"
            ;Tooltip,%Msg%,%xn%,%yn%   ;!!!!!added
            Sleep, 600
        }
    }
    tooltip
    ;Sleep, 1900
    ;Send {F11}     ; hide cursor in IrfanView by F11 if configured that way
    ;Send +a        ; uppercase A turns on an autoadvance in Irfanview
}
else ;Irfanview and TC are not active, so something else will take the key
    send, {%IrfanViewKey%}
Return


; IrfanView autoadvance folder in TotalCommander
; Limitations and TODO: 
;   - it will execute whatever extension of the first file is, you have to be sure it's an image
;   - it will get stuck at the last nested folder, you have to go up a folder manually
;   - not every keyboard have ScrollLock, perhaps the Insert key is better
#If %IrfanView%     ;this variable is set in the viatc.ini file
ScrollLock::
If (WinActive("ahk_exe i_view32.exe")
or WinActive("ahk_exe i_view64.exe")
or WinActive(ahk_exe_TC))
{
    ;the second Esc is if Irfan was full-screen, Irfan has an option to exit with one Esc too
    Send {Esc}{Esc}
    loop 11
    {
        If WinActive(ahk_exe_TC)
            break
        Sleep, 200  ; let it close, 400 is sometimes not enough
    }
    If WinActive(ahk_exe_TC)
    {
        Send {BackSpace}    ; go up a dir
        Sleep, 30
        ; check if TC is still active, it would mean that no files were opened
        loop 9   ; max depth of nested folders
        if WinActive(ahk_exe_TC)
        {   
            ; TC is active so no files were opened
            ;tooltip subfolder: %A_Index% 
            ;msg = hold ScrollLock to abort
            msg = hold Escape or ScrollLock to abort
            subfolder := A_Index - 2
            if subfolder > 0
                msg .= "`nsubfolder: " . subfolder
            ControlGetFocus,CurrentListBox,ahk_class TTOTAL_CMD
            ControlGetPos,xn,yn,,,%CurrentListBox%,AHK_CLASS TTOTAL_CMD
            xn += 90
            yn -= 25
            Tooltip,%Msg%,%xn%,%yn%
            Send {Down}     ; ommit the ".." or the folder just visited
            ;Sleep, 30
            Send {Space}    ; highlight/mark
            Sleep, 900      ; this delay is only for the user to have time to see what's about to be opened
            ; Abort on Esc
            If GetKeyState("Escape", "P")
                break
            ; The Escape key has been pressed, so break out of the loop.

            ; Abort on ScrollLock being "P"hysically pressed and held
            If GetKeyState("ScrollLock", "P")
            {
                ; The ScrollLock key has been pressed, so break out of the loop.
                Tooltip,aborted,%xn%,%yn%
                sleep 2000
                break
                ;Msgbox paused until OK
            }
            Send {Space}    ; unselect
            Send {Enter}    ; God please it's an image not an exe
            ;subfolder := A_Index - 1
            ;if subfolder > 0
                ;msg .= "`nsubfolder: " . subfolder . " ----"
            ;Tooltip,%Msg%,%xn%,%yn%   ;!!!!!added
            Sleep, 600
        }
    }
    tooltip
    ;Sleep, 1900
    ;Send {F11}     ; hide cursor in IrfanView by F11 if configured that way
    ;Send +a        ; uppercase A turns on an autoadvance in Irfanview
}
else ;Irfanview and TC are not active, so something else will take the key
    send, {ScrollLock}
return
#If


<CheckForUpdates>:
CheckForUpdates()
Return

CheckForUpdates()
{
    If Not IsInternetConnected()
    {
        MsgBox, 48, ViATc, Offline! Check the internet connection.
        Return false
    }
    file_name := "latest_version.txt"
    ;file_path := A_ScriptDir . "\" . file_name
    file_path := A_Temp . "\" . file_name
    /*
    ;vCheckForUpdatesButton    ClassNN:	Button47
    ControlGetPos,xn,yn,,hn,%CheckForUpdatesButton%,ahk_class AutoHotkeyGUI
    xn := xn + 130
    yn := yn - 95
    Tooltip,%xn%   %yn%,%xn%,%yn%
    sleep 1000
    */
    xn := 130 + 50
    yn := 420 + 20
    Tooltip,Wait ...,%xn%,%yn%
    ;sleep 1000
    ;Tooltip Wait ...
    If FileExist(file_path)
    {
        FileDelete, %file_path%
        If ErrorLevel   ; cannot delete
            MsgBox, Cannot delete old temporary file %file_path% `nthus the next message might be misleading
           ;MsgBox, Cannot delete old temporary file %file_path% thus if the next message is "Up to date" then it might be misleading
    }
    UrlDownloadToFile, https://magicstep.github.io/viatc/%file_name%, %file_path%
    Tooltip 
    If FileExist(file_path)
    {
        if A_IsCompiled 
            FileReadLine, ver, %file_path%, 4
        else 
            FileReadLine, ver, %file_path%, 2
        ;Msg = You are using version :`t %Version%`n
        If (ver = Version)
            Msg .= "Up to date"
        else
            Msg .= "There is a new version:`t" . ver "`nYou are using version :`t" . Version
            ;Msg .= "There is a new version:`t" . %ver% ;`nYou are using version :`t %Version%

        FileRead, content, %file_path%
        Msg .= "`n`n`n" . content
        MsgBox, %Msg%
        FileDelete, %file_path%
    }
    else
    {
        MsgBox, Could not locate %file_path% `nPerhaps it could not be downloaded`, or there is no write access. `nTry again or visit https://magicstep.github.io/viatc
        Return false
    }
}

IsInternetConnected(flag=0x40) {
Return DllCall("Wininet.dll\InternetGetConnectedState", "Str", flag,"Int",0)
}









; vim: fdm=marker set foldlevel=2
; vim set nofoldenable  ; temporarily disables folding when opening the file, but all folds are restored as soon as you hit zc
;-----------------------------
