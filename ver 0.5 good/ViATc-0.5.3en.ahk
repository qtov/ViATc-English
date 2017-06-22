#SingleInstance Force
#Persistent
#NoEnv
#NoTrayIcon
Setkeydelay,-1
SetControlDelay,-1
Detecthiddenwindows,on
Coordmode,Menu,Window
Version := "0.52"
KeyTemp :=
Repeat :=
VimAction :=
KeyCount := 0
Global Vim := true
Global InsertMode := False
Global VimRN
Global VimRN_Count
Global VimRN_ID
Global VimRN_History := Object()
Global VimRN_Temp
Global VimRN_Vis := False
Global VimRN_IsReplace := False
Global VimRN_IsMultiReplace := False
Global VimRN_IsFind := False
GroupKey_Arr := object()
MapKey_Arr := object()
ExecFile_Arr := object()
SendText_Arr := object()
Command_Arr := object()
CmdHistory_Arr := object()
Mark_Arr := object()
HideControl_Arr := object()
ActionInfo_Arr := object()
HelpInfo_Arr := object()
GroupInfo_Arr := object()
ReName_Arr := Object()
STabs := Object()
HideControl_Arr["Toggle"] := False
TcExe := FindPath("exe")
TcIni := FindPath("ini")
Splitpath,TcExe,,TcDir
If RegExMatch(TcExe,"i)totalcmd64\.exe")
{
	Global TCListBox := "LCLListBox"
	Global TCEdit := "Edit2"
	GLobal TCPanel1 := "Window1"
	Global TCPanel2 := "Window11"
}
Else
{
	Global TCListBox := "TMyListBox"
	Global TCEdit := "Edit1"
	Global TCPanel1 := "TPanel1"
	Global TCPanel2 := "TMyPanel8"
}
RegRead,ViATcIni,HKEY_CURRENT_USER,Software\VIATC,ViATcINI
If Not FileExist(ViATcINI)
	ViatcIni := TcDir . "\viatc.ini"
GoSub,<ConfigVar>
Menu,VimRN_Set,Add, default Vim mode `tAlt+V,VimRN_SelMode
Menu,VimRN_Set,Add, The default suffix is selected `tAlt+F,VimRN_SelExt
Menu,VimRN_MENU,Add, Settings (&S),:VimRN_Set
Menu,VimRN_MENU,Add, Help (&H),VimRN_Help
Menu,Tray,NoStandard
Menu,Tray,Add, Run TC (&T),<ToggleTC>
Menu,Tray,Add, Disable (&D),<EnableVIM>
Menu,Tray,Add, Reload (&R),<ReLoadVIATC>
Menu,Tray,Add
Menu,Tray,Add, Settings (&S),<Setting>
Menu,Tray,Add, Help (&H),<Help>
Menu,Tray,Add
Menu,Tray,Add, Exit (&X),<QuitVIATC>
Menu,Tray,Tip,Vim Mode At TotalCommander
Menu,Tray,Default, Run TC (&T)
If TrayIcon
	Menu,Tray,Icon
Menu,Tray,NoStandard
Menu,Tray,Icon,%A_WorkingDir%\viatc.ico
SetHelpInfo()
SetVimAction()
SetActionInfo()
SetDefaultKey()
ReadKeyFromIni()
EmptyMem()
return
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
	Hotkey,%Susp%,<EnableVim>,On,UseErrorLevel
	Susp := GetConfig("Configuration","Suspend")
}
Else
{
	HotKey,Ifwinactive,AHK_CLASS TTOTAL_CMD
	Hotkey,%Susp%,<EnableVim>,On,UseErrorLevel
	Susp := GetConfig("Configuration","Suspend")
}
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
			Msgbox,16,ViATc, Set boot failed ,3
	}
}
Else
	Regdelete,HKEY_CURRENT_USER,SOFTWARE\Microsoft\Windows\CurrentVersion\Run,ViATc
GroupWarn := GetConfig("Configuration","GroupWarn")
GlobalSusp := GetConfig("Configuration","GlobalSusp")
Transparent := GetConfig("Configuration","Transparent")
TranspHelp := GetConfig("Configuration","TranspHelp")
MaxCount := GetConfig("Configuration","MaxCount")
TranspVar := GetConfig("Configuration","TranspVar")
DefaultSE := GetConfig("SearchEngine","Default")
SearchEng := GetConfig("SearchEngine",DefaultSE)
LnkToDesktop := GetConfig("Other","LnkToDesktop")
Return
<32768>:
Get32768()
RETURN
Get32768()
{
	Global InsertMode
	WinGet,MenuID,ID,AHK_CLASS #32768
	IF MenuID
		InsertMode := True
	ELSE
	{
		InsertMode := False
		SetTimer,<32768>,OFF
	}
}
<GroupKey>:
GroupKey(A_ThisHotkey)
Return
<CheckTCExist>:
IfWinNotExist,AHK_CLASS TTOTAL_CMD
ExitApp
Return
<RemoveToolTip>:
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
Msgbox % "Text=" SendText_Arr["Hotkeys"] "`n" "Exec=" ExecFile_Arr["HotKeys"] "`n" "MapKeys=" MapKey_Arr["HotKeys"] "`nGroupkey=" GroupKey_Arr["Hotkeys"]
Return
<GroupWarnAction>:
Msg := GroupInfo_arr[A_ThisHotkey]
StringSplit,Len,Msg,`n
ControlGetPos,xn,yn,,hn,%TCEdit%,AHK_CLASS TTOTAL_CMD
yn := yn - hn  - ( Len0 - 1 ) * 17
Tooltip,%Msg%,%xn%,%yn%
SetTimer,<RemoveTooltipEx>,50
settimer,<GroupWarnAction>,off
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
		WinWait,AHK_CLASS TTOTAL_CMD,,0
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
<EnableVIM>:
Suspend
If Not IsSuspended
{
	Menu,Tray,Rename, Disable (&D), Enable (&E)
	TrayTip,, Disabled ViATc,10,17
	If A_IsCompiled
		Menu,Tray,icon,%A_ScriptFullPath%,5,1
	Else
		Menu,Tray,Icon,%A_WorkingDir%\viatcdis.ico
;Menu,Tray,icon,%A_AHKPath%,5,1
	Settimer,<GetKey>,100
	IsSuspended := 1
}
Else
{
	Menu,Tray,Rename, Enable (&E), Disable (&D)
	TrayTip,, Enabled ViATc,10,17
	If A_IsCompiled
		Menu,Tray,icon,%A_ScriptFullPath%,1,1
	Else
		Menu,Tray,Icon,%A_WorkingDir%\viatc.ico
;Menu,Tray,icon,%A_AHKPath%,1,1
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
	ToggleMenu(1)
	If HideControl_arr["Toggle"]
		HideControl()
	Reload
}
<Enter>:
Enter()
Return
<Hint>:
If SendPos(0)
	Vim := !Vim
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
<Mark>:
If SendPos(4003)
{
	ControlGet,EditId,Hwnd,,AHK_CLASS TTOTAL_CMD
	ControlSetText,%TCEdit%,m,AHK_CLASS TTOTAL_CMD
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
	ControlGetText,OutVar,%TCEdit%,AHK_CLASS TTOTAL_CMD
	Match_TCEdit := "i)^" . TCEdit . "$"
	If Not RegExMatch(ThisControl,Match_TCEdit) OR Not RegExMatch(Outvar,"i)^m.?")
	{
		Settimer,<MarkTimer>,Off
		Return
	}
	If RegExMatch(OutVar,"i)^m.$")
	{
		SetTimer,<MarkTimer>,off
		ControlSetText,%TCEdit%,,AHK_CLASS TTOTAL_CMD
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
		M := SubStr(OutVar,2,1)
		mPath := "&" . m . ">>" . Path
		If RegExMatch(Mark_Arr["ms"],m)
		{
			DelM := Mark_Arr[m]
			Menu,MarkMenu,Delete,%DelM%
			Menu,MarkMenu,Add,%mPath%,<AddMark>
			Mark_Arr["ms"] := Mark_Arr["ms"] . m
			Mark_Arr[m] := mPath
		}
		Else
		{
			Menu,MarkMenu,Add,%mPath%,<AddMark>
			Mark_Arr["ms"] := Mark_Arr["ms"] . m
			Mark_Arr[m] := mPath
		}
	}
}
<AddMark>:
AddMark()
Return
AddMark()
{
	ThisMenuItem := SubStr(A_ThisMenuItem,5,StrLen(A_ThisMenuItem))
	If RegExMatch(ThisMenuItem,"i)\\\\ desktop $")
	{
		Postmessage 1075, 2121, 0,, ahk_class TTOTAL_CMD
		Return
	}
	If RegExMatch(ThisMenuItem,"i)\\\\ computer $")
	{
		Postmessage 1075, 2122, 0,, ahk_class TTOTAL_CMD
		Return
	}
	If RegExMatch(ThisMenuItem,"i)\\\\ All control panel items $")
	{
		Postmessage 1075, 2123, 0,, ahk_class TTOTAL_CMD
		Return
	}
	If RegExMatch(ThisMenuItem,"i)\\\\Fonts$")
	{
		Postmessage 1075, 2124, 0,, ahk_class TTOTAL_CMD
		Return
	}
	If RegExMatch(ThisMenuItem,"i)\\\\ The internet $")
	{
		Postmessage 1075, 2125, 0,, ahk_class TTOTAL_CMD
		Return
	}
	If RegExMatch(ThisMenuItem,"i)\\\\ printer $")
	{
		Postmessage 1075, 2126, 0,, ahk_class TTOTAL_CMD
		Return
	}
	If RegExMatch(ThisMenuItem,"i)\\\\ Recycle bin $")
	{
		Postmessage 1075, 2127, 0,, ahk_class TTOTAL_CMD
		Return
	}
	ControlSetText, %TCEdit%, cd %ThisMenuItem%, ahk_class TTOTAL_CMD
	ControlSend, %TCEdit%, {Enter}, ahk_class TTOTAL_CMD
	Return
}
<ListMark>:
If SendPos(0)
	ListMark()
Return
ListMark()
{
	Global Mark_Arr,VIATCINI
	If Not Mark_Arr["ms"]
		Return
	ControlGetFocus,TLB,ahk_class TTOTAL_CMD
	ControlGetPos,xn,yn,,,%TLB%,ahk_class TTOTAL_CMD
	Menu,MarkMenu,Show,%xn%,%yn%
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
<TCLite>:
If SendPos(0)
{
	ToggleMenu()
	HideControl()
	GoSub,<VisDirTabs>
	Send,{Esc}
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
<Editviatcini>:
If SendPos(0)
	Editviatcini()
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
		DelMsg := " Delete the left folder history ?"
	}
	Else
	{
		H := "RightHistory"
		DelMsg := " Delete the right folder history ?"
	}
	Msgbox,4,ViATC,%DelMsg%
	Ifmsgbox YES
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
			TCEXE := findpath(1)
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
	Msgbox,4,ViATc, Delete command line history ?
	Ifmsgbox YES
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
			TCEXE := findpath(1)
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
ListMapKey()
{
	Global MapKey_Arr,ActionInfo_Arr,ExecFile_Arr,SendText_Arr
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
	ControlGetPos,xn,yn,,hn,%TCEdit%,AHK_CLASS TTOTAL_CMD
	yn := yn - hn - ( ListMap0 * 8 ) - 2
	Tooltip,%LM%,%xn%,%yn%
	Settimer,<RemoveToolTipEx>,100
}
<FocusCmdLineEx>:
If SendPos(4003)
{
	ControlSetText,%TCEdit%,:,AHK_CLASS TTOTAL_CMD
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
        ; it seems that numbers for Panel2 are incorrect
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
Half()
{
	winget,tid,id,ahk_class TTOTAL_CMD
	controlgetfocus,ctrl,ahk_id %tid%
	controlget,cid,hwnd,,%ctrl%,ahk_id %tid%
	controlgetpos,x1,y1,w1,h1,THeaderClick2,ahk_id %tid%
	controlgetpos,x,y,w,h,%ctrl%,ahk_id %tid%
	SendMessage,0x01A1,1,0,,ahk_id %cid%
	Hight := ErrorLevel
	SendMessage,0x018E,0,0,,ahk_id %cid%
	Top := ErrorLevel
	HalfLine := Ceil( ((h-h1)/Hight)/2 ) + Top
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
		Return
	TCid := WinExist("AHK_CLASS TTOTAL_CMD")
	WinClose,ViATc_TabList
	ControlGetPos,xe,ye,we,he,Edit1,AHK_CLASS TTOTAL_CMD
	Gui,New
	Gui,+HwndTabsHwnd -Caption  +Owner%TCid%
	Gui,Add,ListBox,x2 y2 w%we% gSetTab
	Index := 1
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
<VimRN>:
If SendPos(0)
	VimRNCreateGui()
Return
VimRNCreateGui()
{
	Static WM_CHAR := 0x102
	Global GetName
	WinClose,AHK_ID %VimRN_ID%
	PostMessage 1075, 1007, 0,, ahk_class TTOTAL_CMD
	Loop,8
	{
		ControlGetFocus,ThisCtrl,AHK_CLASS TTOTAL_CMD
		If ThisCtrl = TInEdit1
		{
			ControlGetText,GetName,TInEdit1,AHK_CLASS TTOTAL_CMD
			Break
		}
		Sleep,50
	}
	If Not GetName
		Return
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
	Gui,+HwndVimRN_ID
	Gui,+Owner%TCID%
	Gui,Menu,VimRN_MENU
	Gui,Add,Edit,r6 w300 -WantReturn gVimRN_Edit,%GetName%
	Gui,Add,StatusBar
	Gui,Add,Button,Default Hidden gVimRN_Enter
	Gui,Show,h125,ViATc  Rename 
	PostMessage,0x00C5,256,,Edit1,AHK_ID %VimRN_ID%
	VimRN := GetConfig("VimReName","Mode")
	If VimRN
	{
		Menu,VimRN_Set,Check, default Vim mode `tAlt+V
		Status := "  mode : Vim                                    "
	}
	Else
		Status := "  mode : Normal                                 "
	ControlSetText,msctls_statusbar321,%status%,AHK_ID %VimRN_ID%
	If GetConfig("VimReName","SelectExt")
	{
		SplitPath,GetName,,,Ext
		Menu,VimRN_Set,Check, default Vim mode `tAlt+V
		Menu,VimRN_Set,Check, The default suffix is selected `tAlt+E
	}
	If Ext And ( Not GetDir )
	{
		StartPos := 0
		EndPos := StrLen(GetName) - strlen(Ext) - 1
		VimRN_SetPos(StartPos,EndPos)
	}
	VimRN_History["s"] := 0
	VimRN_History[0] := StartPos . "," . EndPos . "," . GetName
	VimRN_History["String"] := GetName
	OnMessage(WM_CHAR,"GetFindText")
}
GetFindText(byRef w, byRef l)
{
	If VimRN_IsFind
	{
		ThisChar := Chr(w)
		ControlGetText,Text,Edit1,AHK_ID %VimRN_ID%
		GetPos := VimRN_GetPos()
		StartPos := GetPos[2] + 1
		Pos := RegExMatch(Text,RegExReplace(ThisChar,"\+|\?|\.|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0"),"",StartPos)
		VimRN_SetPos(Pos-1,Pos)
		VimRN_IsFind := False
		VimRN := True
		Return 0
	}
}
VimRN_Num:
VimRN_SendNum()
Return
VimRN_Down:
Key := VimRN_Vis ? "+{Down}" : "{Down}"
VimRN_SendKey(key)
Return
VimRN_Up:
Key := VimRN_Vis ? "+{Up}" : "{Up}"
VimRN_SendKey(key)
Return
VimRN_Left:
Key := VimRN_Vis ? "+{Left}" : "{Left}"
VimRN_SendKey(key)
Return
VimRN_Right:
Key := VimRN_Vis ? "+{Right}" : "{Right}"
VimRN_SendKey(key)
Return
VimRN_SDown:
VimRN_SendKey("+{Down}")
Return
VimRN_SLeft:
VimRN_SendKey("+{Left}")
Return
VimRN_SUp:
VimRN_SendKey("+{Up}")
Return
VimRN_SRight:
VimRN_SendKey("+{Right}")
Return
VimRN_Find:
If VimRN_SendKey("")
{
	VimRN := False
	VimRN_IsFind := True
}
Return
VimRN_SelectThis:
If VimRN_SendKey("")
{
	Pos := VimRN_GetPos()
	Pos := Pos[2]
	VimRN_SetPos(Pos,Pos)
}
return
VimRN_Selectall:
If VimRN_SendKey("")
{
	ControlGetText,Text,Edit1,AHK_ID %VimRN_ID%
	Pos := Strlen(Text)
	VimRN_SetPos(0,Pos)
}
Return
VimRN_SelectFileName:
If VimRN_SendKey("")
{
	ControlGetText,Text,Edit1,AHK_ID %VimRN_ID%
	splitpath,Text,,,,FileName
	Pos := Strlen(FileName)
	VimRN_SetPos(0,Pos)
}
Return
VimRN_SelectExt:
If VimRN_SendKey("")
{
	ControlGetText,Text,Edit1,AHK_ID %VimRN_ID%
	splitpath,Text,,,FileExt,FileName
	Pos1 := Strlen(FileName)
	Pos2 := Strlen(FileExt)
	VimRN_SetPos(Pos1+1,Pos1+Pos2+1)
}
Return
VimRN_Home:
If VimRN_SendKey("")
	VimRN_SetPos(0,0)
Return
VimRN_End:
If VimRN_SendKey("")
{
	ControlGetText,Text,Edit1,AHK_ID %VimRN_ID%
	Pos := Strlen(Text)
	VimRN_SetPos(Pos,Pos)
}
Return
VimRN_Copy:
If VimRN_SendKey("")
{
	Pos := VimRN_GetPos()
	ControlGetText,Text,Edit1,AHK_ID %VimRN_ID%
	VimRN_Temp := SubStr(Text,Pos[1]+1,Pos[2]-Pos[1])
}
Return
VimRN_Backspace:
If VimRN_SendKey("")
{
	VimRN_Cut(-1)
	Send {Backspace}
}
Return
VimRN_Delete:
If VimRN_SendKey("")
{
	VimRN_Cut(0)
	Send {Delete}
}
Return
VimRN_Paste:
If VimRN_SendKey("")
	VimRN_Paste()
Return
VimRN_Trade:
If VimRN_SendKey("")
{
	Pos := VimRN_GetPos()
	ControlGetText,Text,Edit1,AHK_ID %VimRN_ID%
	If Pos[1] > 0
	{
		TextA := SubStr(Text,Pos[1],1)
		TextB := SubStr(Text,Pos[1]+1,1)
		SetText := SubStr(Text,1,Pos[1]-1) . TextB . TextA . SubStr(Text,Pos[1]+2)
		ControlSetText,Edit1,%SetText%,AHK_ID %VimRN_ID%
		VimRN_SetPos(Pos[1],Pos[2])
		VimRN_Edit()
	}
}
Return
VimRN_Replace:
If VimRN_SendKey("")
{
	VimRN_IsReplace := True
	Pos := VimRN_GetPos()
	If Pos[1] = Pos[2]
	{
		VimRN_SetPos(Pos[1],Pos[1]+1)
		VimRN := False
	}
}
Return
VimRN_MultiReplace:
If VimRN_SendKey("")
{
	VimRN_IsMultiReplace := True
	Pos := VimRN_GetPos()
	If Pos[1] = Pos[2]
	{
		VimRN_SetPos(Pos[1],Pos[1]+1)
		VimRN := False
	}
}
Return
VimRN_visual:
If VimRN_SendKey("")
{
	VimRN_Vis := !VimRN_Vis
	If VimRN_Vis
	{
		Status := "  mode : Visual                                 "
		ControlSetText,msctls_statusbar321,%status%,AHK_ID %VimRN_ID%
	}
	Else
	{
		Status := "  mode : Vim                                    "
		ControlSetText,msctls_statusbar321,%status%,AHK_ID %VimRN_ID%
	}
}
Return
VimRN_Insert:
If VimRN_SendKey("")
{
	VimRN := False
	Status := "  mode : Normal                                 "
	ControlSetText,msctls_statusbar321,%status%,AHK_ID %VimRN_ID%
}
Return
VimRN_Esc:
VimRN := True
VimRN_IsReplace := False
VimRN_IsMultiReplace := False
VimRN_Count := 0
Status := "  mode : Vim                                    "
Tooltip
Settimer,<RemoveHelpTip>,off
ControlSetText,msctls_statusbar321,%status%,AHK_ID %VimRN_ID%
Return
VimRN_Quit:
If VimRN_SendKey("")
	WinClose,AHK_ID %VimRN_ID%
Return
VimRN_Undo:
If VimRN_SendKey("")
	VimRN_Undo()
Return
VimRN_Enter:
GuiControlGet,NewName,,Edit1
Gui,Destroy
Postmessage,1075,1007,0,,AHK_CLASS TTOTAL_CMD
Loop,40
{
	ControlGetFocus,This,AHK_CLASS TTOTAL_CMD
	If This = TInEdit1
	{
		ControlGetText,ConfirName,TInEdit1,AHK_CLASS TTOTAL_CMD
		ControlSetText,TInEdit1,%NewName%,AHK_CLASS TTOTAL_CMD
		Break
	}
	Sleep,50
}
If Diff(ConfirName,GetName)
	ControlSend,TInEdit1,{enter},AHK_CLASS TTOTAL_CMD
Else
	Return
Return
VimRN_Edit:
VimRN_Edit()
Return
VimRN_SelMode:
SetConfig("VimReName","Mode",!GetConfig("VimReName","Mode"))
If GetConfig("VimReName","Mode")
	Menu,VimRN_Set,Check, default Vim mode `tAlt+V
Else
	Menu,VimRN_Set,UnCheck, default Vim mode `tAlt+V
Return
VimRN_SelExt:
SetConfig("VimReName","SelectExt",!GetConfig("VimReName","SelectExt"))
If GetConfig("VimReName","SelectExt")
	Menu,VimRN_Set,Check, The default suffix is selected `tAlt+E
Else
	Menu,VimRN_Set,UnCheck, The default suffix is selected `tAlt+E
Return
VimRN_Help:
VimRN_Help()
Return
VimRN_Help()
{
	test =
(
h :  move to the left N Character 
j :  Move Downward N Character 
k :  Move up N Character 
l :  move to the right N Character 
w :  Select the file name 
e :  Select the extension 
u :  Revoked 
x :  Removed later 
d :  Deleted forward 
y :  Copy characters 
p :  Paste the character 
t :  Two characters for changing the cursor 
r :  Only replace the characters at the cursor 
R :  Replace all characters after the cursor, Straight encounter Esc
a :  select all 
g :  The cursor is in the first character 
b :  The cursor is at the last character 
s :  The cursor is at the last character of the selected character 
f :  Find characters, E.g f Press after a, Is to find a
q :  Exit rename 
i :  Edit mode 
v :  Select mode 
Esc :  Normal mode 
Enter :  Save rename 
)
	WinGetPos,,,w,h,AHK_ID %VimRN_ID%
	tooltip,%test%,0,%h%
	Settimer,<RemoveHelpTip>,50
	Return
}
<RemoveHelpTip>:
Ifwinnotactive,AHK_ID %VimRN_ID%
{
	SetTimer,<RemoveHelpTip>, Off
	ToolTip
}
return
VimRN_SendKey(ThisKey)
{
	If VimRN
	{
		VimRN_Count := VimRN_Count ? VimRN_Count : 1
		Loop % VimRN_Count
		{
			Send %ThisKey%
		}
		VimRN_Count := 0
		ControlGetText,status,msctls_statusbar321,AHK_ID %VimRN_ID%
		status := SubStr(status,1,Strlen(status)-3) . "   "
		ControlSetText,msctls_statusbar321,%status%,AHK_ID %VimRN_ID%
		Return True
	}
	Else
	{
		Send %A_ThisHotkey%
		Return False
	}
}
VimRN_SendNum()
{
	If A_ThisHotkey is integer
		ThisNum := A_ThisHotkey
	Else
		Return
	If VimRN
	{
		If VimRN_Count
			VimRN_Count := ThisNum + (VimRN_Count * 10 )
		Else
			VimRN_Count := ThisNum + 0
		if VimRN_Count > 256
			VimRN_Count := 256
		ControlGetText,status,msctls_statusbar321,AHK_ID %VimRN_ID%
		StringRight,isNumber,status,3
		If RegExMatch(isNumber,"\s\s\s")
			Status := RegExReplace(Status,"\s\s\s$") . VimRN_Count . "  "
		If RegExMatch(isNumber,"\d\s\s")
			Status := RegExReplace(Status,"\d\s\s$") . VimRN_Count  . " "
		If RegExMatch(isNumber,"\d\d\s")
			Status := RegExReplace(Status,"\d\d\s$") . VimRN_Count
		If RegExMatch(isNumber,"\d\d\d")
			Status := RegExReplace(Status,"\d\d\d$") . VimRN_Count
		ControlSetText,msctls_statusbar321,%status%,AHK_ID %VimRN_ID%
		Return True
	}
	Else
	{
		Send %A_ThisHotkey%
		Return False
	}
}
VimRN_Undo()
{
	DontSetText := False
	Serial := VimRN_History["s"]
	If  Serial > 0
		Serial--
	Else
		DontSetText := True
	Change := VimRN_History[Serial]
	Stringsplit,Pos,Change,`,
	If Not DontSetText
		ControlSetText,Edit1,%Pos3%,AHK_ID %VimRN_ID%
	VimRN_SetPos(Pos1,Pos2)
	VimRN_History["s"] := Serial
	VimRN_History["String"] := Pos3
}
VimRN_Edit()
{
	Match := "^" . RegExReplace(VimRN_History["String"],"\+|\?|\.|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0") . "$"
	ControlGetText,Change,Edit1,AHK_ID %VimRN_ID%
	if Not RegExMatch(Change,Match)
	{
		Serial := VimRN_History["s"]
		Serial++
		pos := VimRN_GetPos()
		StartPos := pos[1]
		EndtPos  := pos[2]
		VimRN_History[Serial] :=  StartPos . "," . EndPos . "," .  Change
		VimRN_History["s"] := Serial
		VimRN_History["String"] := change
		If VimRN_IsReplace
		{
			VimRN_IsReplace := !VimRN_IsReplace
			VimRN := True
		}
		If VimRN_IsMultiReplace
		{
			Pos := VimRN_GetPos()
			If Pos[1] = Pos[2]
			{
				VimRN_SetPos(Pos[1],Pos[1]+1)
			}
		}
	}
}
VimRN_Cut(Length)
{
	Pos := VimRN_GetPos()
	ControlGetText,Text,Edit1,AHK_ID %VimRN_ID%
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
	VimRN_Temp := SubStr(Text,Pos1,Len)
}
VimRN_Paste(Direction="")
{
	Pos := VimRN_GetPos()
	ControlGetText,Text,Edit1,AHK_ID %VimRN_ID%
	SetText := SubStr(Text,1,Pos[1]) . VimRN_Temp . SubStr(Text,Pos[1]+1)
	Pos1 := Pos[1] + Strlen(VimRN_Temp)
	ControlSetText,Edit1,%SetText%,AHK_ID %VimRN_ID%
	VimRN_SetPos(Pos1,Pos1)
	VimRN_Edit()
}
VimRN_GetPos()
{
	Pos := []
	ControlGet,Edit_ID,hwnd,,Edit1,AHK_ID %VimRN_ID%
	Varsetcapacity(StartPos,2)
	Varsetcapacity(EndPos,2)
	Sendmessage,0x00B0,&StartPos,&EndPos,,AHK_ID %Edit_ID%
	Pos[1] := NumGet(StartPos)
	Pos[2] := NumGet(EndPos)
	Return Pos
}
VimRN_SetPos(Pos1,Pos2)
{
	PostMessage,0x00B1,%Pos1%,%Pos2%,Edit1,AHK_ID %VimRN_ID%
}
SetDefaultKey()
{
	Hotkey,Ifwinactive,ahk_class TQUICKSEARCH
	Hotkey,+j,<Down>
	Hotkey,+k,<Up>
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
	HotKey,j,<Down>,on,UseErrorLevel
	HotKey,k,<up>,on,UseErrorLevel
	HotKey,h,<left>,on,UseErrorLevel
	HotKey,l,<right>,on,UseErrorLevel
	HotKey,+k,<UpSelect>,on,UseErrorLevel
	HotKey,+j,<DownSelect>,on,UseErrorLevel
	HotKey,+h,<GotoPreviousDir>,on,UseErrorLevel
	HotKey,+l,<GotoNextDir>,on,UseErrorLevel
	HotKey,d,<DirectoryHotlist>,on,UseErrorLevel
	HotKey,+d,<GoDesktop>,on,UseErrorLevel
	Hotkey,.,<SingleRepeat>,On,UseErrorLevel
	HotKey,e,<ContextMenu>,on,UseErrorLevel
	HotKey,+e,<ExecuteDOS>,on,UseErrorLevel
	HotKey,u,<GotoParentEx>,on,UseErrorLevel
	HotKey,+u,<GotoRoot>,on,UseErrorLevel
	Hotkey,i,<CreateNewFile>,on,UseErrorLevel
	Hotkey,x,<Delete>,On,UseErrorLevel
	Hotkey,+x,<ForceDel>,On,UseErrorLevel
	HotKey,o,<LeftOpenDrives>,on,UseErrorLevel
	HotKey,+o,<RightOpenDrive>,on,UseErrorLevel
	HotKey,q,<SrcQuickview>,on,UseErrorLevel
	HotKey,p,<PackFiles>,on,UseErrorLevel
	HotKey,+p,<UnpackFiles>,on,UseErrorLevel
	HotKey,t,<OpenNewTab>,on,UseErrorLevel
	HotKey,+t,<OpenNewTabBg>,on,UseErrorLevel
	Hotkey,r,<VimRN>,on,UseErrorLevel
	Hotkey,+r,<MultiRenameFiles>,on,UseErrorLevel
	Hotkey,f,<PageDown>,On,UseErrorLevel
	Hotkey,+f,<Hint>,On,UseErrorLevel
	Hotkey,b,<PageUp>,On,UseErrorLevel
	Hotkey,+b,<azTab>,On,UseErrorLevel
	Hotkey,y,<CopyNamesToClip>,On,UseErrorLevel
	Hotkey,+y,<CopyFullNamesToClip>,On,UseErrorLevel
	Hotkey,/,<ShowQuickSearch>,On,UseErrorLevel
	Hotkey,+/,<SearchFor>,On,UseErrorLevel
	Hotkey,`;,<FocusCmdLine>,On,UseErrorLevel
	Hotkey,:,<FocusCmdLineEx>,On,UseErrorLevel
	Hotkey,[,<SelectCurrentName>,On,UseErrorLevel
	Hotkey,+[,<UnselectCurrentName>,On,UseErrorLevel
	Hotkey,],<SelectCurrentExtension>,On,UseErrorLevel
	Hotkey,+],<UnselectCurrentExtension>,On,UseErrorLevel
	Hotkey,\,<ExchangeSelection>,On,UseErrorLevel
	Hotkey,+\,<ClearAll>,On,UseErrorLevel
	Hotkey,=,<MatchSrc>,On,UseErrorLevel
	Hotkey,-,<SwitchSeparateTree>,On,UseErrorLevelHotkey,\,<ExchangeSelection>,On,UseErrorLevel
	Hotkey,v,<SrcCustomViewMenu>,On,UseErrorLevel
	HotKey,a,<SetAttrib>,on,UseErrorLevel
	Hotkey,m,<Mark>,On,UseErrorLevel
	Hotkey,+m,<Half>,On,UseErrorLevel
	Hotkey,',<ListMark>,On,UseErrorLevel
	HotKey,+q,<Internetsearch>,on,UseErrorLevel
	Hotkey,+g,<End>,On,UseErrorLevel
	Hotkey,w,<EditComment>,On,UseErrorLevel
	Hotkey,n,<azhistory>,On,UseErrorLevel
	Hotkey,+n,<DirectoryHistory>,On,UseErrorLevel
	Hotkey,`,,<None>,On,UseErrorLevel
	Hotkey,$Enter,<Enter>,On,UseErrorLevel
	Hotkey,Esc,<Esc>,On,UseErrorLevel
	HotKey,+a,<None>,on,UseErrorLevel
	Hotkey,+.,<None>,On,UseErrorLevel
	Hotkey,+w,<None>,On,UseErrorLevel
	Hotkey,+s,<None>,On,UseErrorLevel
	Hotkey,+',<None>,On,UseErrorLevel
	GroupKeyAdd("zz","<50Percent>")
	GroupKeyAdd("zi","<WinMaxLeft>")
	GroupKeyAdd("zo","<WinMaxRight>")
	GroupKeyAdd("zt","<AlwayOnTop>")
	GroupKeyAdd("zn","<Minimize>")
	GroupKeyAdd("zm","<Maximize>")
	GroupKeyAdd("zr","<Restore>")
	GroupKeyAdd("zv","<VerticalPanels>")
	GroupKeyAdd("zs","<Transparent>")
	GroupKeyAdd("zf","<TCFullScreen>")
	GroupKeyAdd("zl","<TCLite>")
	GroupKeyAdd("zq","<QuitTC>")
	GroupKeyAdd("za","<ReLoadTC>")
	GroupKeyAdd("sn","<SrcByName>")
	GroupKeyAdd("se","<SrcByExt>")
	GroupKeyAdd("ss","<SrcBySize>")
	GroupKeyAdd("sd","<SrcByDateTime>")
	GroupKeyAdd("sr","<SrcNegOrder>")
	GroupKeyAdd("s1","<SrcSortByCol1>")
	GroupKeyAdd("s2","<SrcSortByCol2>")
	GroupKeyAdd("s3","<SrcSortByCol3>")
	GroupKeyAdd("s4","<SrcSortByCol4>")
	GroupKeyAdd("s5","<SrcSortByCol5>")
	GroupKeyAdd("s6","<SrcSortByCol6>")
	GroupKeyAdd("s7","<SrcSortByCol7>")
	GroupKeyAdd("s8","<SrcSortByCol8>")
	GroupKeyAdd("s9","<SrcSortByCol9>")
	GroupKeyAdd("gn","<SwitchToNextTab>")
	GroupKeyAdd("gp","<SwitchToPreviousTab>")
	GroupKeyAdd("ga","<CloseAllTabs>")
	GroupKeyAdd("gc","<CloseCurrentTab>")
	GroupKeyAdd("gt","<OpenDirInNewTab>")
	GroupKeyAdd("gb","<OpenDirInNewTabOther>")
	GroupKeyAdd("ge","<Exchange>")
	GroupKeyAdd("gw","<ExchangeWithTabs>")
	GroupKeyAdd("gi","<Enter>")                 ;!!!added
	GroupKeyAdd("g1","<SrcActivateTab1>")
	GroupKeyAdd("g2","<SrcActivateTab2>")
	GroupKeyAdd("g3","<SrcActivateTab3>")
	GroupKeyAdd("g4","<SrcActivateTab4>")
	GroupKeyAdd("g5","<SrcActivateTab5>")
	GroupKeyAdd("g6","<SrcActivateTab6>")
	GroupKeyAdd("g7","<SrcActivateTab7>")
	GroupKeyAdd("g8","<SrcActivateTab8>")
	GroupKeyAdd("g9","<SrcActivateTab9>")
	GroupKeyAdd("g0","<GoLastTab>")
	GroupKeyAdd("gg","<Home>")
	GroupKeyAdd("<Shift>vb","<VisButtonbar>")
	GroupKeyAdd("<Shift>vd","<VisDriveButtons>")
	GroupKeyAdd("<Shift>vo","<VisTwoDriveButtons>")
	GroupKeyAdd("<Shift>vr","<VisDriveCombo>")
	GroupKeyAdd("<Shift>vc","<VisCurDir>")
	GroupKeyAdd("<Shift>vt","<VisTabHeader>")
	GroupKeyAdd("<Shift>vs","<VisStatusbar>")
	GroupKeyAdd("<Shift>vn","<VisCmdLine>")
	GroupKeyAdd("<Shift>vf","<VisKeyButtons>")
	GroupKeyAdd("<Shift>vw","<VisDirTabs>")
	GroupKeyAdd("<Shift>ve","<CommandBrowser>")
	GroupKeyAdd("cl","<DeleteLHistory>")
	GroupKeyAdd("cr","<DeleteRHistory>")
	GroupKeyAdd("cc","<DelCmdHistory>")
	Hotkey,IfWinActive,ViATc  Rename 
	Hotkey,j,VimRN_Down,on,UseErrorLevel
	Hotkey,k,VimRN_Up,on,UseErrorLevel
	Hotkey,h,VimRN_Left,on,UseErrorLevel
	Hotkey,l,VimRN_Right,on,UseErrorLevel
	Hotkey,+j,VimRN_SDown,on,UseErrorLevel
	Hotkey,+k,VimRN_SUp,on,UseErrorLevel
	Hotkey,+h,VimRN_SLeft,on,UseErrorLevel
	Hotkey,+l,VimRN_SRight,on,UseErrorLevel
	Hotkey,y,VimRN_Copy,on,UseErrorLevel
	Hotkey,d,VimRN_Backspace,on,UseErrorLevel
	Hotkey,x,VimRN_Delete,on,UseErrorLevel
	Hotkey,i,VimRN_Insert,on,UseErrorLevel
	Hotkey,r,VimRN_Replace,on,UseErrorLevel
	Hotkey,t,VimRN_Trade,on,UseErrorLevel
	Hotkey,f,VimRN_Find,on,UseErrorLevel
	Hotkey,+r,VimRN_MultiReplace,on,UseErrorLevel
	Hotkey,a,VimRN_Selectall,on,UseErrorLevel
	Hotkey,s,VimRN_SelectThis,on,UseErrorLevel
	Hotkey,w,VimRN_Selectfilename,on,UseErrorLevel
	Hotkey,e,VimRN_Selectext,on,UseErrorLevel
	Hotkey,g,VimRN_Home,on,UseErrorLevel
	Hotkey,b,VimRN_End,on,UseErrorLevel
	Hotkey,q,VimRN_Quit,on,UseErrorLevel
	Hotkey,u,VimRN_Undo,on,UseErrorLevel
	Hotkey,v,VimRN_Visual,on,UseErrorLevel
	Hotkey,p,VimRN_Paste,on,UseErrorLevel
	Hotkey,Esc,VimRN_Esc,on,UseErrorLevel
	Hotkey,1,VimRN_Num,on,UseErrorLevel
	Hotkey,2,VimRN_Num,on,UseErrorLevel
	Hotkey,3,VimRN_Num,on,UseErrorLevel
	Hotkey,4,VimRN_Num,on,UseErrorLevel
	Hotkey,5,VimRN_Num,on,UseErrorLevel
	Hotkey,6,VimRN_Num,on,UseErrorLevel
	Hotkey,7,VimRN_Num,on,UseErrorLevel
	Hotkey,8,VimRN_Num,on,UseErrorLevel
	Hotkey,9,VimRN_Num,on,UseErrorLevel
	Hotkey,0,VimRN_Num,on,UseErrorLevel
}
SendKey(HotKey)
{
	Global KeyCount,KeyTemp,Repeat,MaxCount
	If CheckMode()
	{
		If KeyTemp
		{
			GroupKey(A_ThisHotkey)
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
			GroupKey(A_ThisHotkey)
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
			GroupKey(A_ThisHotkey)
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
ExecFile()
{
	Global ExecFile_Arr,KeyTemp,GoExec,Repeat
	IfWinActive,AHK_CLASS TTOTAL_CMD
	{
		Key := "H" . A_ThisHotkey
		If Not ExecFile_Arr[Key]
			Key := "S" . A_ThisHotkey
	}
	Else
		Key := "S" . A_ThisHotkey
	If GoExec
		File := ExecFile_Arr[GoExec]
	Else
		File := ExecFile_Arr[Key]
	Run,%File%,,UseErrorLevel,ExecID
	If ErrorLevel = ERROR
	{
		Msgbox  run %File% failure 
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
			Key := "S" . A_ThisHotkey
	}
	Else
		Key := "S" . A_ThisHotkey
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
Groupkey(Hotkey)
{
	Global GroupKey_Arr,KeyTemp,KeyCount,GroupInfo_arr,GroupWarn,Repeat,SendText_Arr,ExecFile_Arr,GoExec,GoText
	If GroupWarn And ( Not KeyTemp ) And CheckMode() And GroupInfo_Arr[A_ThisHotkey]
		Settimer,<GroupWarnAction>,50
	If checkMode()
	{
		KeyCount := 0
		KeyTemp .= A_ThisHotkey
		AllGK := Groupkey_Arr["Hotkeys"]
		MatchString := "[^&]\s" . RegExReplace(KeyTemp,"\+|\?|\.|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0")
		If RegExMatch(AllGK,MatchString)
		{
			MatchString .= "\s"
			If RegExMatch(AllGk,MatchString)
			{
				Settimer,<RemoveToolTipEx>,off
				Tooltip
				ControlSetText,%TCEdit%,,AHK_CLASS TTOTAL_CMD
				Action := GroupKey_Arr[KeyTemp]
				If RegExMatch(Action,"<Text>")
					GoText := "G" . KeyTemp
				If RegExMatch(Action,"<Exec>")
					GoExec := "G" . KeyTemp
				KeyTemp :=
				If IsLabel(Action)
				{
					GoSub,%Action%
					Repeat := Action
				}
				Else
					Msgbox % KeyTemp " action " Action " Error "
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
GroupKeyAdd(Key,Action,IsGlobal=False)
{
	Global GroupKey_Arr,GroupInfo_Arr,ActionInfo_Arr,ExecFile_Arr,SendText_Arr
	Key_T := TransHotkey(key,"ALL")
	Info := Key . " >>" . ActionInfo_Arr[Action]
	If Action = <Text>
	{
		Key_N := "G" . Key_T
		Info := Key . " >> Send text  " . SendText_Arr[Key_N]
	}
	If Action = <Exec>
	{
		Key_N := "G" . Key_T
		Info := key . " >> run  " . ExecFile_Arr[Key_N]
	}
	GroupKey_Arr["Hotkeys"] .= A_Space . A_Space . Key_T . A_Space . A_Space
	GroupKey_Arr[Key_T] := Action
	Key_T := TransHotkey(key,"First")
	GroupInfo_Arr[Key_T] .= Info . "`n"
	If IsGlobal
		Hotkey,Ifwinactive
	Else
		Hotkey,Ifwinactive,AHK_CLASS TTOTAL_CMD
	Hotkey,%Key_T%,<GroupKey>,On,UseErrorLevel
}
GroupkeyDelete(Key,IsGlobal=False)
{
	Global GroupKey_Arr
	Key_T := "\s" . TransHotkey(Key,"ALL") . "\s"
	GroupKey_Arr["Hotkeys"] := RegExReplace(Groupkey_Arr["Hotkeys"],Key_T)
	Key_T := "\s" . TransHotkey(Key,"First")
	If RegExMatch(GroupKey_Arr["Hotkeys"],Key_T)
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
		Scope := "G"
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
FindPath(File)
{
	If RegExMatch(File,"exe")
	{
		GetPath := A_WorkingDir . "\totalcmd.exe"
		GetPath64 := A_WorkingDir . "\totalcmd64.exe"
		Reg := "InstallDir"
		FileSF_Option := 3
		FileSF_FileName:=
		FileSF_Prompt := "TOTALCMD.EXE"
		FileSF_Filter := "*.EXE"
		FileSF_Error := " turn on TOTALCMD.EXE failure "
	}
	If RegExMatch(File,"ini")
	{
		GetPath := A_workingDir . "\wincmd.ini"
		Reg := "IniFileName"
		FileSF_Option := 3
		FileSF_FileName:=
		FileSF_Prompt := " Select the profile "
		FileSF_Filter := "*.INI"
		FileSF_Error := " turn on TC The configuration file failed "
	}
	RegRead,GetPath,HKEY_CURRENT_USER,Software\VIATC,%Reg%
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
		Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,%Reg%,%GetPath64%
		Return GetPath64
	}
	If FileExist(GetPath)
	{
		Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,%Reg%,%GetPath%
		Return GetPath
	}
	FileSelectFile,GetPath,%FileSF_Option%,%FileSF_FileName%,%FileSF_Prompt%,%FileSF_Filter%
	If ErrorLevel
	{
		Msgbox %FileSF_Error%
		Return
	}
	Else
		Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,%Reg%,%GetPath%
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
			IsGroupkey := False
			Continue
		}
		If RegExMatch(A_LoopReadLine,"i)\[GlobalHotkey\]")
		{
			IsReadKey := True
			IsGlobalHotkey := True
			IsHotkey := False
			IsGroupkey := False
			Continue
		}
		If RegExMatch(A_LoopReadLine,"i)\[GroupKey\]")
		{
			IsReadKey := True
			IsGroupkey := True
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
				MapKeyAdd(Key,Action,"S")
			If IsHotkey
				MapKeyAdd(Key,Action,"H")
			If IsGroupkey
				MapKeyAdd(Key,Action,"G")
		}
	}
}
MapKeyAdd(Key,Action,Scope)
{
	Global MapKey_Arr,ExecFile_Arr,SendText_Arr
	If RegExMatch(CheckScope(key),"G")
		Scope := "G"
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
	If Scope = S
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
	If Scope = G
		GroupKeyAdd(Key,Action)
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
	If Scope = S
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
		GroupkeyDelete(Key)
	DelKey := "\s" . Scope . RegExReplace(Key,"\+|\?|\.|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0") . "\s"
	Mapkey_Arr["Hotkeys"] := RegExReplace(MapKey_Arr["Hotkeys"],DelKey)
}
GetConfig(Section,Key)
{
	Global ViatcIni
	IniRead,Getvar,%ViatcIni%,%Section%,%Key%
	If RegExMatch(Getvar,"^ERROR$")
		GetVar := CreateConfig(Section,key)
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
	If Section = Configuration
		If Key = TrayIcon
			SetVar := 1
	If Key = Vim
		SetVar := 1
	If Key = Toggle
		SetVar := "<lwin>F"
	If Key = GlobalTogg
		SetVar := 1
	If Key = Suspend
		SetVar := "<alt>``"
	If Key = GlobalSusp
		SetVar := 0
	If Key = Startup
		SetVar := 0
	If Key = Service
		SetVar := 1
	If Key = GroupWarn
		SetVar := 1
	If Key = TranspHelp
		SetVar := 0
	If Key = Transparent
		SetVar := 0
	If Key = TranspVar
		SetVar := 220
	If Key = MaxCount
		SetVar := 99
	If Section = SearchEngine
		If Key = Default
			SetVar := 1
	If Key = 1
		SetVar := "http://www.google.com/search?q={%1}"
	If Key = 2
		SetVar := "http://www.bing.com/search?q={%1}"
	If Section = VimReName
		If Key = Mode
			SetVar := 1
	If Key = SelectExt
		SetVar := 1
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
Enter()
{
	Global MapKey_Arr,ActionInfo_Arr,ExecFile_Arr,SendText_Arr,TabsBreak
	ControlGetFocus,ThisControl,AHK_CLASS TTOTAL_CMD
	Match_TCEdit := "^" . TCEdit . "$"
	If RegExMatch(ThisControl,Match_TCEdit)
	{
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
				If RegExMatch(CheckScope(key),"G")
					If Not MapKeyAdd(Key,Action,"G")
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
					Tooltip, The mapping failed `, Global hotkeys do not support key combinations ,%xn%,%yn%
				Else
					If Not MapKeyAdd(Key,Action,"S")
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
				Editviatcini()
				Return
			}
			yn := yn -  hn - 9
			Tooltip, Invalid command line ,%xn%,%yn%
			Sleep,2000
			Tooltip
		}
		Else
			ControlSend,%TCEdit%,{Enter},AHK_CLASS TTOTAL_CMD
	}
	Else
		ControlSend,%ThisControl%,{Enter},AHK_CLASS TTOTAL_CMD
}
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
			IniRead,file,%ViatcIni%,ShellNew,%A_Index%
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
		Menu,CreateNewFile,Add, Configuration (&Z),M_EVI
		Menu,CreateNewFile,Icon, Configuration (&Z),%A_WinDir%\system32\Shell32.dll,-151
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
	Settimer,SetLnkToDestop,50
Return
SetLnkToDestop:
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
Settimer,SetLnkToDestop,off
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
		Msgbox ,, Add a new template, Please select the file 
		Return
	}
	Splitpath,temp_file,,,Ext
	WinGet,hwndtc,id,AHK_CLASS TTOTAL_CMD
	Gui,new,+Theme +Owner%hwndtc% +HwndCNF
	Gui,Add,Text,x10 y10, Template name 
	Gui,Add,Edit,x50 y8 w205,%ext%
	Gui,Add,Text,x10 y42, Template source 
	Gui,Add,Edit,x50 y40 w205 h20 +ReadOnly,%temp_File%
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
	ShellNew := TCDir . "\ShellNew"
	If Not InStr(Fileexist(ShellNew),"D")
		FileCreateDir,%ShellNew%
	Filecopy,%tempPath%,%TCDir%\ShellNew,1
	Splitpath,tempPath,FileName
	New := 1
	Loop,23
	{
		IniRead,file,%ViatcIni%,ShellNew,%A_Index%
		If file = ERROR
			Break
		New++
	}
	IniWrite,(%tempName%)\%FileName%,%ViatcIni%,ShellNew,%New%
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
		IniRead,file,%ViatcIni%,ShellNew,%A_Index%
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
				file := TCDir . "\ShellNew" . Substr(file,RegExMatch(file,"\)")+1,Strlen(file))
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
				Msgbox  The template source has been moved or deleted 
				IniDelete,%ViatcIni%,ShellNew,%A_Index%
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
			Msgbox  The file already exists 
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
M_EVI:
Editviatcini()
Return
Editviatcini()
{
	Global viatcini
	RegRead,path,HKEY_LOCAL_MACHINE,Software\vim\gvim,path
	match = `"$0
	INI := Regexreplace(viatcini,".*",match)
	path := path . " "
	If Fileexist(path)
		;editini := path . a_space . ini                 ;open in a new Vim instance
		editini := path . " --remote-tab-silent " . ini  ;open in a new Vim tab
	Else
		editini := "notepad.exe" . a_space . ini
	Run,%editini%,,UseErrorLevel
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
Setting()
{
	Global StartUp,Service,TrayIcon,Vim,GlobalTogg,Toggle,GlobalSusp,Susp,GroupWarn,TranspHelp,Transparent,SearchEng,DefaultSE,ViATcIni,TCExe,TCINI,NeedReload
	NeedReload := 1
	Global ListView
	Global MapKey_Arr,ActionInfo_Arr,ExecFile_Arr,SendText_Arr
	Vim := GetConfig("Configuration","Vim")
	Gui,Destroy
	Gui,+Theme +hwndviatcsetting
	Gui,Add,Button,x10 y335 w180 g<EditViATCIni>, Edit viatc.ini file (&E)
	Gui,Add,Button,x240 y335 w80 center Default g<GuiEnter>, OK (&O)
	Gui,Add,Button,x330 y335 w80 center g<GuiCancel>, Cancel (&C)
	Gui,Add,Tab2,x10 y6 +theme h320 w405 center choose2, Genereal (&U) | Hot key (&P) | Path setting (&M)
	Gui,Add,GroupBox,x16 y32 H170 w390, Global Settings 
	Gui,Add,CheckBox,x25 y50 h20 checked%startup% vStartup, Startup VIATC(&R)
	Gui,Add,CheckBox,x180 y50 h20 checked%Service% vService, Background process (&B)
	Gui,Add,CheckBox,x25 y70 h20 checked%TrayIcon% vTrayIcon, System tray icon (&T)
	Gui,Add,CheckBox,x180 y70 h20 checked%Vim% vVim, default VIM mode (&V)
	Gui,Add,Text,x25 y100 h20, Activate/Minimize TC (&F)
	Gui,Add,Edit,x24 y120 h20 w140 vToggle ,%Toggle%
	Gui,Add,CheckBox,x180 y120 h20 checked%GlobalTogg% vGlobalTogg, Global (&G)
	Gui,Add,Text,x25 y150 h20, Enable/Disable VIM Hotkey (&A)
	Gui,Add,Edit,x25 y170 h20 w140 vSusp ,%Susp%
	Gui,Add,CheckBox,x180 y170 h20 checked%GlobalSusp% vGlobalSusp, Global (&L)
	Gui,Add,GroupBox,x16 y210 H110 w390, Other settings 
	Gui,Add,Text,x25 y228 h20, Search for the selected file name or folder (&Q)
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
	Gui,Add,ComboBox,x25 y246 h20 w226 choose%DefaultSE% AltSubmit vDefaultSE R5 hwndaa g<SetDefaultSE>,%SE_Arr%
	Gui,Add,Button,x256 y246 h20 w22 g<AddSearchEng>,+
	Gui,Add,Button,x280 y246 h20 w22 g<DelSearchEng>,-
	Gui,Add,CheckBox,x25 y270 h20 checked%GroupWarn% vGroupWarn, Key combination tooltips (for: s g z c V) (&K)
	Gui,Add,CheckBox,x25 y295 h20 checked%transpHelp% vTranspHelp, Transparent help interface  (&I)
	Gui,Add,Button,x270 y280 h30 w120 Center g<Help>, Open VIATC Help (&H)
	Gui,Tab,2
	Gui,Add,ListView,x16 y32 h170 w390 count20 sortdesc  -Multi vListView g<ListViewDK>,*| hot key | action | Description 
	Lv_modifycol(2,100)
	Lv_modifycol(3,100)
	Lv_modifycol(4,300)
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
			Info := ActionInfo_Arr[Action]
			If Action = <Exec>
			{
				Action := " run "
				Key_T := Scope . TransHotkey(Key)
				Info := ExecFile_Arr[key_T]
			}
			If Action = <Text>
			{
				Action := " Send text "
				Key_T := Scope . TransHotkey(Key)
				Info := SendText_Arr[key_T]
			}
			LV_Add(vis,Scope,Key,Action,Info)
		}
	}
	Gui,Add,GroupBox,x16 y210 h110 w390
	Gui,Add,Text,x22 y223 h20, hot key (&K)
	Gui,Add,Edit,x78 y220 h20 w100 g<CheckGorH>
	Gui,Add,CheckBox,x183 y221 h20, Global (&G)
	Gui,Add,Button,x260 y220 w50 g<TestTH>, analysis 
	Gui,Add,text,x28 y249 h20, action (&W)
	Gui,Add,Edit,x78 y246 h20 w320
	Gui,Add,Button,x21 y270 h20 w100 g<VimCMD> ,VIM command (&V)
	Gui,Add,Button,x140 y270 h20 w100 g<TCCMD> ,TC command (&T)
	Gui,Add,Button,x21 y294 h20 w100 g<RunFile>, run (&R)
	Gui,Add,Button,x140 y294 h20 w100 g<SendString>, String (&S)
	Gui,Add,Button,x260 y274 h40 w60 g<CheckKey>, Save (&L)
	Gui,Add,Button,x325 y274 h40 w65 g<DeleItem>, Delete (&A)
	Gui,Tab,3
	Gui,Add,Text,x18 y35 h16 center,TC Executable program location :
	Gui,Add,Edit,x18 y55 h20 +ReadOnly w350,%TCEXE%
	Gui,Add,Button,x375 y53 w30 g<GuiTCEXE>,...
	Gui,Add,Text,x18 y80 h16 center,TC Profile (ini file) location :
	Gui,Add,Edit,x18 y100 h20 +ReadOnly w350,%TCINI%
	Gui,Add,Button,x375 y98 w30 g<GuiTCINI> ,...
	Gui,Add,Text,x18 y125 h16 center,ViATc Profile location :
	Gui,Add,Edit,x18 y145 h20 +ReadOnly w350,%ViATcIni%
	Gui,Add,Button,x375 y143 w30 g<GuiViATcINI> ,...
	Gui,Tab
	Gui,Add,Button,x280 y5 w30 h20 center hidden g<ChangeTab>,&U
	Gui,Add,Button,x280 y5 w30 h20 center hidden g<ChangeTab>,&P
	Gui,Add,Button,x280 y5 w30 h20 center hidden g<ChangeTab>,&M
	GUi,Show,h370 w420,VIATC Settings 
}
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
GuiEscape:
Tooltip
Gui,Destroy
If NeedReload
	GoSub,<ReloadVIATC>
Else
	EmptyMem()
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
<GuiEnter>:
Gui,Submit
IniWrite,%TrayIcon%,%ViATcIni%,Configuration,TrayIcon
IniWrite,%Vim%,%ViATcIni%,Configuration,Vim
IniWrite,%Toggle%,%ViATcIni%,Configuration,Toggle
IniWrite,%Susp%,%ViATcIni%,Configuration,Suspend
IniWrite,%GlobalTogg%,%ViATcIni%,Configuration,GlobalTogg
IniWrite,%GlobalSusp%,%ViATcIni%,Configuration,GlobalSusp
IniWrite,%StartUp%,%ViATcIni%,Configuration,StartUp
IniWrite,%Service%,%ViATcIni%,Configuration,Service
IniWrite,%GroupWarn%,%ViATcIni%,Configuration,GroupWarn
IniWrite,%TranspHelp%,%ViATcIni%,Configuration,TranspHelp
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
		LV_GetText(Scope,EventInfo,1)
		LV_GetText(Key,EventInfo,2)
		LV_GetText(Action,EventInfo,3)
		LV_GetText(Info,EventInfo,4)
		If RegExMatch(Scope,"S")
			GuiControl,,Button18,1
		If RegExMatch(Scope,"[G|H]")
			GuiControl,,Button18,0
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
		If Get = S
			IniDelete,%ViATcIni%,GlobalHotkey,%GetText%
		If Get = G
			IniDelete,%ViATcIni%,GroupKey,%GetText%
	}
}
<VIMCMD>:
VimCMD()
Return
VimCMD()
{
	Global VimAction,ActionInfo_Arr
	Stringsplit,kk,VimAction,%A_Space%
	Gui,New
	Gui,+HwndVIMCMDHwnd
	Gui,Add,ListView,w400 h400 -Multi g<GetVIMCMD>, Serial number | action | Description 
	Lv_delete()
	Lv_modifycol(1,40)
	Lv_modifycol(2,110)
	Lv_modifycol(3,420)
	Loop,%kk0%
	{
		key := kk%A_Index%
		Info := ActionInfo_Arr[key]
		LV_ADD(vis,A_Index-1,key,info)
	}
	kk := kk%0% - 1
	lv_delete(1)
	Gui, Add, Button, x280 y420 w60 h24 Default g<VIMCMDB1>, &OK
	Gui, Add, Button, x350 y420 w60 h24 g<Cancel>, &Cancel
	Gui,Show,,VIATC Default action 
}
<VIMCMDB1>:
ControlGet,EventInfo,List, Count Focused,SysListView321,ahk_id %VIMCMDHwnd%
lv_gettext(actiontxt,EventInfo,2)
ControlSetText,edit5,%actiontxt%,AHK_ID %VIATCSetting%
Gui,Destroy
EmptyMem()
Winactivate,AHK_ID %VIATCSetting%
Return
<GetVIMCMD>:
lv_gettext(actiontxt,A_EventInfo,2)
ControlSetText,edit5,%actiontxt%,AHK_ID %VIATCSetting%
Gui,Destroy
EmptyMem()
Winactivate,AHK_ID %VIATCSetting%
Return
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
	Gui,Add,Edit,w500 h20
	Gui,Add,Button,x390 y30 h20 g<GetSendStringEnter> Default, OK (&O)
	Gui,Add,Button,x457 y30 h20 g<GetSendStringCancel>, Cancel (&C)
	Gui,Show,,VIATC String 
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
	Fileselectfile,TCEXE,3,TOTALCMD.EXE, select TOTALCMD.EXE,*.exe
	If ErrorLevel
		Return
	Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,InstallDir,%TCEXE%
	GuiControl,text,Edit6,%TCEXE%
}
<GuiTCIni>:
GuiTCIni()
return
GuiTCIni()
{
	Global TCINI,VIATCSetting
	Fileselectfile,TCINI,3,, Select the ini file, The default is WINCMD.INI,*.ini
	If ErrorLevel
		Return
	Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,IniFileName,%TCINI%
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
<CheckGorH>:
CheckGorH()
Tooltip
Return
CheckGorH()
{
	Global ViATcSetting
	GuiControlGet,Key,,Edit4,AHK_CLASS %ViATcSetting%
	If Key
		If RegExMatch(CheckScope(key),"G")
			GuiControl,Disable,Button18
	Else
		GuiControl,Enable,Button18
	Else
		GuiControl,Enable,Button18
}
<CheckKey>:
CheckKey()
Return
CheckKey()
{
	Global VIATCSetting,ViATcIni,MapKey_Arr,ExecFile_Arr,SendText_Arr,ActionInfo_Arr,NeedReload
	GuiControlGet,Scope,,Button18,AHK_CLASS %ViATcSetting%
	GuiControlGet,Key,,Edit4,AHK_CLASS %ViATcSetting%
	GuiControlGet,Action,,Edit5,AHK_CLASS %ViATcSetting%
	If Scope
		Scope := "S"
	Else
		Scope := "H"
	If RegExMatch(CheckScope(key),"G")
	{
		Scope := "G"
		GuiControl,,Button18,0
	}
	If Action And Key
	{
		NeedReload := 1
		If RegExMatch(Scope,"i)S")
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
		If RegExMatch(Scope,"i)G")
		{
			If MapKeyAdd(Key,Action,Scope)
				Iniwrite,%Action%,%ViatcIni%,GroupKey,%Key%
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
				Info := ActionInfo_Arr[Action]
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
		Info := ActionInfo_Arr[Action]
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
		Tooltip, Shortcuts or actions are empty ,%VarPosX%,%VarPosY%
		Sleep,2000
		Tooltip
	}
}
<ChangeTab>:
ChangeTab()
Return
ChangeTab()
{
	If RegExMatch(A_GuiControl,"U")
		GuiControl,choose,SysTabControl321,1
	If RegExMatch(A_GuiControl,"P")
		GuiControl,choose,SysTabControl321,2
	If RegExMatch(A_GuiControl,"M")
		GuiControl,choose,SysTabControl321,3
}
<TestTH>:
TH()
Return
TH()
{
	GuiControlGet,Scope,,Button18,AHK_CLASS %ViATcSetting%
	GuiControlGet,Key,,Edit4,AHK_CLASS %ViATcSetting%
	if key
	{
		If Scope
			KeyType := " Global key "
		Else
			KeyType := " Hot key "
		If RegExMatch(CheckScope(key),"G")
			KeyType := " Key combination "
		Msg :=  KeyType . "`n"
		Key1 := TransHotkey(Key,"First")
		Msg .= " First 1 Key :" . Key1 . "`n"
		Key2 := TransHotkey(Key,"ALL")
		KeyT := SubStr(Key2,Strlen(key1)+1)
		Stringsplit,T,KeyT
		N := 2
		Loop,%T0%
		{
			Msg .= " First " . N . " Key :" . T%A_index% . "`n"
			N++
		}
		GuiControlGet,VarPos,Pos,Edit4
		VarPosY := VarPosY - VarPosH - ( T0 * 17)
		Tooltip,%Msg%,%VarPosX%,%VarPosY%
		Settimer,<RemoveTTEx>,5000
	}
	else
	{
		Msg := " Please enter the shortcut key to be analyzed in the shortcut key field "
		GuiControlGet,VarPos,Pos,Edit4
		VarPosY := VarPosY - VarPosH + 17
		Tooltip,%Msg%,%VarPosX%,%VarPosY%
		Settimer,<RemoveTTEx>,1500
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
Help()
{
	Global TranspHelp,HelpInfo_Arr
	Gui,New
	Gui,+HwndVIATCHELP
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
    Gui,Add,Groupbox,x12 y135 w574 h40
    Gui,Add,Button,x15 y146 w60 gIntro, Intro (&I)
    Gui,Add,Button,x80 y146 w105 gFunck, Function key (&K)
    Gui,Add,Button,x189 y146 w130 gGroupk, Key combination (&G)
    Gui,Add,Button,x322 y146 w120 gCmdl, Command Line (&C)
    Gui,Add,Button,x448 y146 w62 gAction, Action (&J)
    Gui,Add,Button,x515 y146 w62 gAbout, About (&A)
    Intro := HelpInfo_Arr["Intro"]
    Gui,Font,s11,Arial  ;font for the bottom textarea box in help window
    Gui,Add,Edit,x12 y180 w574 h310 +ReadOnly,%Intro%
    Gui,Show,w600 h500,VIATC  help 
    If TranspHelp
        WinSet,Transparent,220,ahk_id %VIATCHELP%
    Return
	}
	Intro:
	var := HelpInfo_Arr["Intro"]
	GuiControl,Text,Edit1,%var%
	Return
	funck:
	var := HelpInfo_Arr["funck"]
	GuiControl,Text,Edit1,%var%
	Return
	Groupk:
	var := HelpInfo_Arr["Groupk"]
	GuiControl,Text,Edit1,%var%
	Return
	cmdl:
	var := HelpInfo_Arr["cmdl"]
	GuiControl,Text,Edit1,%var%
	Return
	action:
	var := HelpInfo_Arr["action"]
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
	SetHelpInfo()
	{
		Global HelpInfo_arr
		HelpInfo_arr["Esc"] :="Esc >> Reset all states"
		HelpInfo_arr["F1"] :="F1 >> No mapping `n Open TC help"
		HelpInfo_arr["F2"] :="F2 >> No mapping `n Refresh the source window"
		HelpInfo_arr["F3"] :="F3 >> No mapping `n View file"
		HelpInfo_arr["F4"] :="F4 >> No mapping `n Edit file"
		HelpInfo_arr["F5"] :="F5 >> No mapping `n Copy file"
		HelpInfo_arr["F6"] :="F6 >> No mapping `n Rename or move file"
		HelpInfo_arr["F7"] :="F7 >> No mapping `n New folder"
		HelpInfo_arr["F8"] :="F8 >> No mapping `n Delete Files (Move to Recycle Bin or delete it directly － Determined by configuration)"
		HelpInfo_arr["F9"] :="F9 >> No mapping `n Activate the menu for the source window  ( Left or right )"
		HelpInfo_arr["F10"] :="F10 >> No mapping `n Activate the left menu or exit the menu "
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
		HelpInfo_arr["Tab"] :="Tab >> No mapping `n Switch the window "
		HelpInfo_arr["Q"] :="q >> Quick view function `nQ >> Use the default browser to search for the current file name / Folder name "
		HelpInfo_arr["W"] :="w >> Edit file notes `nW >> No mapping "
		HelpInfo_arr["E"] :="e >> The right-click shortcut menu is displayed `nE >> Run in the current directory CMD.EXE"
		HelpInfo_arr["R"] :="r >> Rename the file `nR >> Batch rename file "
		HelpInfo_arr["T"] :="t >> New tab `nT >> Create a new tab in the background "
		HelpInfo_arr["Y"] :="y >> Copy the file name `nY >> Copy the file name and the full path "
		HelpInfo_arr["U"] :="u >> Up a directory `nU >> Up to the root directory "
		HelpInfo_arr["I"] :="i >> Insert a new folder `nI >> No mapping "
		HelpInfo_arr["O"] :="o >> Open the left drive list `nO >> Open the list of right drives "
		HelpInfo_arr["P"] :="p >> Compressed file / folder `nP >> unzip "
		HelpInfo_arr["[{"] :="[ >> Select files with the same file name `n{ >> Do not select files with the same file name "
		HelpInfo_arr["]}"] :="] >> Select files with the same extension `n} >> Do not select files with the same extension "
		HelpInfo_arr["\|"] :="\ >> Invert all selections for files and folders  `n| >> Clears all selections"
		HelpInfo_arr["CapsLock"] :="CapsLock  No mapping "
		HelpInfo_arr["A"] :="a >> Change attributes `n A >> No mapping "
		HelpInfo_arr["S"] :="s >> Sort by... (key combination, requires another key) `nS >> No mapping `nsn >> Source window :  Sort by file name `nse >> Source window :  Sort by extension `nss >> Source window :  Sort by size `nst >> Source window :  Sort by date and time `nsr >> Source window :  Reverse sort `ns1 >> Source window :  Sort by column 1`ns2 >> Source window :  Sort by 2`ns3 >> Source window :  Sort by column 3`ns4 >> Source window :  Sort by column 4`ns5 >> Source window :  Sort by column 5`ns6 >> Source window :  Sort by column 6`ns7 >> Source window :  Sort by column 7`ns8 >> Source window :  Sort by column 8`ns9 >> Source window :  Sort by column 9 >>"
		HelpInfo_arr["D"] :="d >> Favourite folders hotlist`nD >> Open the desktop folder "
		HelpInfo_arr["F"] :="f >> Page down, Equivalent to PageDown`nF >> Switch to TC Default fast search mode "
		HelpInfo_arr["G"] :="g >> Tab operation (key combination, requires another key) `nG >> Go to the end of the file list `ngg >> Go to the first line of the file list `ngn >> Next tab (Ctrl+Tab)`ngp >> Previous tab (Ctrl+Shift+Tab)`nga >> Close all tabs `ngc >> Close the current tab `ngt >> New tab ( And open the folder at the cursor )`ngb >> New tab ( Open the folder in another window )`nge >> Exchange left and right windows `ngw >> Exchange left and right windows and their tabs `ngg >> Go to the first line of the file list `ng1 >> Source window :  Activate the tab  1`ng2 >> Source window :  Activate the tab  2`ng3 >> Source window :  Activate the tab  3`ng4 >> Source window :  Activate the tab  4`ng5 >> Source window :  Activate the tab  5`ng6 >> Source window :  Activate the tab  6`ng7 >> Source window :  Activate the tab  7`ng8 >> Source window :  Activate the tab  8`ng9 >> Source window :  Activate the tab  9`ng0 >> Go to the last tab "
		HelpInfo_arr["H"] :="h >> Move Left num times `nH >> Go Backward in dir history"
		HelpInfo_arr["J"] :="j >> Move Downward num times `nJ >> Select down Num File ( folder )"
		HelpInfo_arr["K"] :="k >> Move Up num times `nK >> Choose from the top Num File ( folder )"
		HelpInfo_arr["L"] :="l >> Move Right num times `nL >> Go Forward in dir history"
		HelpInfo_arr["`;:"] :="; >> Put focus on the command line `n: >> Get into VIATC command line mode : (like ex mode in vim)"
		HelpInfo_arr["'"""] :="' >> Show all marks (Mark by m) `n"" >> No mapping "
		HelpInfo_arr["Enter"] :="Enter >> Enter "
		HelpInfo_arr["LShift"] :="Lshift >> Left shift key, can also be made by Shift instead "
		HelpInfo_arr["Z"] :="z >> Tool (key combination, requires another key) `nZ >> No mapping `nzz >> Set the window divider at 50%`nzx >> Set the window divider at 100%`nzi >> Maximize the left panel `nzo >> Maximize the right panel `nzt >> The TC window remains always on top `nzn >> minimize  Total Commander`nzm >> maximize  Total Commander`nzr >> Return to normal size, Restore `nzv >> Vertical / Horizontal arrangement `nzs >>TC Transparent `nzf >> The simplest TC`nzq >> Exit TC`nza >> Reload TC"
		HelpInfo_arr["X"] :="x >> Delete Files\folders`nX >> Force Delete, like shift+delete ignores recycle bin"
		HelpInfo_arr["C"] :="c >> Clear (key combination, requires another key) `nC >> No mapping `ncl >> Delete the history of the left folder `ncr >> Delete the history of the right folder `ncc >> Delete command line history "
		HelpInfo_arr["V"] :="v >> View menu ( band a-z navigation )`nV >> View... (key combination, requires another key)`n<Shift>vb >> display / hide :  toolbar `n<Shift>vd >> display / hide :  Drive button `n<Shift>vo >> display / hide :  Two drive button bars `n<Shift>vr >> display / hide :  Drive list `n<Shift>vc >> display / hide :  Current folder `n<Shift>vt >> display / hide :  Sort tab `n<Shift>vs >> display / hide :  Status Bar `n<Shift>vn >> display / hide :  Command Line `n<Shift>vf >> display / hide :  Function button `n<Shift>vw >> display / hide :  Folder tab `n<Shift>ve >> Browse internal commands "
		HelpInfo_arr["B"] :="b >> Move up a page, Equivalent to PageUp`nB >> Open the tabbed browsing window "
		HelpInfo_arr["N"] :="n >> Show the folder history ( band a-z navigation )`nN >> No mapping "
		HelpInfo_arr["M"] :="m >> Marking function, Mark the current folder `nM >> Move to the middle of the list `n Marking function, Similar to VIM m key. When m is pressed the command line displays m and prompts to enter the mark letter, You can save the current folder path to the mark. For example, enter it in the normal mode ma Enter, Then press ' it will show all the marks, Press then a, you will go to the corresponding folder "
		HelpInfo_arr[",<"] :=", >> Display command history ( band a-z navigation )`n< >> No mapping "
		HelpInfo_arr[".>"] :=". >> Repeat the last action `n> >> No mapping `n Repeat the last action, For example when you enter 10j move downward 10 rows, and want to move down again 10 rows, no need to press again 10j Just press the dot . It also works if you press gn switching to the next tab, Move again? Only need to press ."
		HelpInfo_arr["/?"] :="/ >> Use quick search `n? >> Use the file search function ( advanced )"
		HelpInfo_arr["RShift"] :="Rshift >> right shift key, Can also be made by Shift instead "
		HelpInfo_arr["LCtrl"] :="Lctrl >> left ctrl key, Can also be made by control or ctrl instead "
		HelpInfo_arr["LWin"] :="LWin >>Win key. Due to ahk limits the lwin key must be used instead"
		HelpInfo_arr["LAlt"] :="LAlt >> left Alt key, Can also be alt instead "
		HelpInfo_arr["Space"] :="Space >> Space, No mapping "
		HelpInfo_arr["RAlt"] :="RAlt >> right Alt key, Can also be made by alt instead "
		HelpInfo_arr["Apps"] :="Apps >> Open the context menu ( Right-click menu )"
		HelpInfo_arr["RCtrl"] :="Rctrl >> right ctrl key, Can also be made by control or ctrl instead "
    HelpInfo_arr["Intro"] :="Combination of Vim shortcut system with TC will speed up TC operation. Up to two buttons can complete most of the tasks that need to be done with the mouse. `nIf you have ever used Vim and are used to TC then you will love ViATc.`nIf you are using TC, but feel that mouse clicking is not quick enough, then you will want to use ViATc.`nUse two hands on the keyboard to knock out is the original intention of ViATc.`nViATc does :`nOperate TC With Vim style h,j,k,l moves and more; Press : (semicolon) for command line mode.`nWhen you do not need it use Alt+~ (can be modifed) to disable all ViATc functionality, or simply quit ViATc, TC won't be affected at all. `nNone of the shortcut keys are in conflict with TC.`nResides in the tray icon, Double-click the tray icon, or Win+F (modifable) to toggle show/hide TC window`nKey combinations (chords) for TC customization like transparent, always on top, there are more... `n`n Waiting for your suggestions, let's make ViATc easier to use."
		HelpInfo_arr["Funck"] :="Single press to operate `nFunction keys are divided by type, Can be numbers Num0-Num9, character a-z, other characters and so on. By default entering numbers does not cause task operations, only the value of the number is recorded, and then an operation can be repeated by pressing a key that allows multiple operations. For example press 10j and the result is move down 10 rows. Press 10K and it is selecting 10 rows upward. By moving in the list (hjkl/JK) you can make multiple operations.`nImportant!   In VIATC the expression function keys (Single press) can be: control,alt,win,shift. Four modifiers and characters, but each character can only be associated with one modifier `n<LWin>f (must be LWin Not Win)    -this works as intended`n<ctrl><F12>    -not as intended, this time characters of the second modifier will be interpreted as separate ordinary characters < F 1 2 >`n<ctrl><shift>a -invalid, more than a single modifier`nWant to know what can be done with each key? Please click on the keyboard above to get details of each button."
		HelpInfo_arr["GroupK"] :="Key combination (chords). Press twice or more to achieve the operation `nLike in VIM, the key combination can be very flexible to map, at the same time not limited to the 26 keyboard letters. Unlike function keys the key combination can consist of multiple characters. But there is one thing to note, the first key of a key combination can only have up to one modifier (ctrl/lwin/shift/alt). All the following keys cannot have modifiers `n E.g :`n<ctrl>ab (means press ctrl+a and release, then press b to work)`n<ctrl>a<ctrl>b    -invalid, The first key can have up to one modifier, but the second key cannot`nVIATC comes by default with five groups of keys. Click the keyboard above for details z,c,v,g,s"
		HelpInfo_arr["cmdl"] :="The command line in VIATC supports abbreviations :h :s :r :m :sm :e, They are respectively `n:help    Display help information `n:setting     Set the VIATC interface `n:reload   Re-run VIATC`n:map     Show or map hotkeys `n If you type :map in the command line then all custom hotkeys will be displayed.`n If the input is :map key action, where key represents the hotkey to map (it can be a key combination or a function key) action represents the action to be carried out. This feature is suitable for the scenario where there is a temporary need for a function mapping, after closing VIATC this mapping won't be saved. If you want to make a permanent mapping you can use the VIATC Settings interface, or directly edit viatc.ini file which is located in the TC directory.`n:smap and :map are the same except map is a global hotkey and does not support mapping key combinations `n:edit  Directly edit ViATc.ini file "
		HelpInfo_arr["action"] :="In VIATC all operations can be understood as actions. All actions can be found in the hotkey mapping tab of the Settings interface. Actions are divided into four categories :`n1.VIATC takes action, VIATC provides some TC enhancements to make more convenient to operate TC.`n2.TC Internal action, that is TC internal commands beginning with the cm_ such as cm_SrcComments.`n3. Run a program or open a file. Of course TC has similar functions built-in but ViATc way is often more convenient than using TC to run a program or edit a file.`n4. Send a string. If you want TC to always enter a text, you can use the key combination to map the action of sending a string, Convenient ah !!`n The above four actions, 1 and 2 must be surrounded by <  > , 3 needs to be surrounded with (  ) , 4 with {  }.`nFor example `n:map <shift>a <Transparent>   (Mapping shift key to make TC transparent)`n:map ggg (E:\google\chrome.exe)   (Mapping the ggg key combination to run chrome.exe program `n:map abcd {cd E:\ {enter}}    (Mapping the abcd key combination to send   cd E:\ {enter}   to TC's command line, where {enter} will be Interpreted by VIATC as pressing the Enter key."
		HelpInfo_arr["About"] :="If you have any questions please contact me (linxinhong.sky@gmail.com) author of the original Chinese version (who knows just basic English). It was translated to English by magicstep (who knows nothing about Chinese) relying on Google translate and then smoothing it out a bit."
	}
	SetGroupInfo()
	{
		Global GroupInfo_arr
		GroupInfo_arr["s"] :="sn >> Source window :  Sort by file name `nse >> Source window :  Sort by extension `nss >> Source window :  Sort by size `nsd >> Source window :  Sort by date and time `nsr >> Source window :  Reverse sort `ns1 >> Source window :  Sort by column 1`ns2 >> Source window :  Sort by 2`ns3 >> Source window :  Sort by column 3`ns4 >> Source window :  Sort by column 4`ns5 >> Source window :  Sort by column 5`ns6 >> Source window :  Sort by column 6`ns7 >> Source window :  Sort by column 7`ns8 >> Source window :  Sort by column 8`ns9 >> Source window :  Sort by column 9"
		GroupInfo_arr["z"] :="zz >> Set the window divider at 50%`nzx >> Set the window divider at 100% (TC 8.0+)`nzi >> Maximize the left panel `nzo >> Maximize the right panel `nzt >>TC window always on top `nzn >> minimize  Total Commander`nzm >> maximize  Total Commander`nzr >> Return to normal size `nzv >> Vertical / Horizontal arrangement `nzs >>TC transparent `nzf >> Full screen TC`nzl >> The simplest TC`nzq >> Exit TC`nza >> Reload TC"
		GroupInfo_arr["g"] :="gn >> Next tab (Ctrl+Tab)`ngp >> Previous tab (Ctrl+Shift+Tab)`nga >> Close all tabs `ngc >> Close the current tab `ngt >> New tab ( And open the folder at the cursor )`ngb >> New tab ( Open the folder in another window )`nge >> Exchange left and right windows `ngw >> Exchange left and right windows and their tabs `ngg >> Go to the first line in the file list `ng1 >> Source window :  Activate the tab  1`ng2 >> Source window :  Activate the tab  2`ng3 >> Source window :  Activate the tab  3`ng4 >> Source window :  Activate the tab  4`ng5 >> Source window :  Activate the tab  5`ng6 >> Source window :  Activate the tab  6`ng7 >> Source window :  Activate the tab  7`ng8 >> Source window :  Activate the tab  8`ng9 >> Source window :  Activate the tab  9`ng0 >> Go to the last tab "
		GroupInfo_arr["Shift & v"] :="<Shift>vb >> display / hide :  Toolbar `n<Shift>vd >> display / hide :  Drive button `n<Shift>vo >> display / hide :  Two drive button bars `n<Shift>vr >> display / hide :  Drive list `n<Shift>vc >> display / hide :  Current folder `n<Shift>vt >> display / hide :  Sort tab `n<Shift>vs >> display / hide :  Status Bar `n<Shift>vn >> display / hide :  Command Line `n<Shift>vf >> display / hide :  Function buttons `n<Shift>vw >> display / hide :  Folder tab `n<Shift>ve >> Browse internal commands "
		GroupInfo_arr["c"] :="cl >> Delete the history of the left folder `ncr >> Delete the history of the right folder `ncc >> Delete command line history "
	}
	SetVimAction()
	{
		Global VimAction
		VimAction := " <help> <Setting> <ToggleTC> <EnableVIM> <QuitTC> <ReloadTC> <QuitVIATC> <ReloadVIATC> <Enter> <singleRepeat> <Esc> <Num0> <Num1> <Num2> <Num3> <Num4> <Num5> <Num6> <Num7> <Num8> <Num9> <Down> <up> <Left> <Right> <DownSelect> <PageUp> <PageDown> <Home> <Half> <End> <UpSelect> <ForceDel> <Mark> <ListMark> <Internetsearch> <azHistory> <ListMapKey> <WinMaxLeft> <WinMaxRight> <AlwayOnTop> <GoLastTab> <Transparent> <DeleteLHistory> <DeleteRHistory> <DelCmdHistory> <CreateNewFile> <TCLite> <TCFullScreen> <EditViATCIni> <azTab>"
	}
	SetActionInfo()
	{
		Global ActionInfo_arr
		ActionInfo_Arr["<azTab>"] := " use a-z To browse the tab (x64 unavailable)"
		ActionInfo_Arr["<ReLoadVIATC>"] :=" Reload VIATC"
		ActionInfo_Arr["<ReLoadTC>"] :=" Reload TC"
		ActionInfo_Arr["<QuitTC>"] :=" Exit TC"
		ActionInfo_Arr["<QuitViATc>"] :=" Exit ViATc"
		ActionInfo_Arr["<None>"] :=" do nothing "
		ActionInfo_Arr["<Setting>"] :=" Settings interface "
		ActionInfo_Arr["<FocusCmdLine:>"] := " Command line mode. Focus on the command line with : at the beginning"
		ActionInfo_Arr["<CreateNewFile>"] := " File template function, Create a new file or a new directory "
		ActionInfo_Arr["<TCLite>"] := " The simplest TC"
		ActionInfo_Arr["<ExReName>"] := " Rename, Do not select an extension "
		ActionInfo_Arr["<Help>"] := "VIATC Help "
		ActionInfo_Arr["<Setting>"] := "VIATC Settings"
		ActionInfo_Arr["<ToggleTC>"] :=" Show / Hide TC"
		ActionInfo_Arr["<EnableVIM>"] :=" Enable / Disable VIM mode "
		ActionInfo_Arr["<Enter>"] :=" Enter "
		ActionInfo_Arr["<SingleRepeat>"] :=" Repeat the last action "
		ActionInfo_Arr["<Esc>"] :=" Reset and send ESC"
		ActionInfo_Arr["<EditViATCIni>"] :=" Directly edit ViATc.ini file "
		ActionInfo_Arr["<Num0>"] :=" numerical 0"
		ActionInfo_Arr["<Num1>"] :=" numerical 1"
		ActionInfo_Arr["<Num2>"] :=" numerical 2"
		ActionInfo_Arr["<Num3>"] :=" numerical 3"
		ActionInfo_Arr["<Num4>"] :=" numerical 4"
		ActionInfo_Arr["<Num5>"] :=" numerical 5"
		ActionInfo_Arr["<Num6>"] :=" numerical 6"
		ActionInfo_Arr["<Num7>"] :=" numerical 7"
		ActionInfo_Arr["<Num8>"] :=" numerical 8"
		ActionInfo_Arr["<Num9>"] :=" numerical 9"
		ActionInfo_Arr["<Down>"] :=" Down "
		ActionInfo_Arr["<up>"] :=" Up "
		ActionInfo_Arr["<Left>"] :=" Left"
		ActionInfo_Arr["<Right>"] :=" Right"
		ActionInfo_Arr["<DownSelect>"] :=" Select Down "
		ActionInfo_Arr["<UpSelect>"] :=" Select Up"
		ActionInfo_Arr["<Home>"] :=" Go to the first line, Equivalent to Home key "
		ActionInfo_Arr["<Half>"] :=" Go to the middle of the list "
		ActionInfo_Arr["<End>"] :=" Go to last line, Equivalent to End key "
		ActionInfo_Arr["<PageUp>"] :=" Page Up "
		ActionInfo_Arr["<PageDown>"] :=" Page Down "
		ActionInfo_Arr["<ForceDel>"] :=" Forced Delete, like shift+delete ignores recycle bin"
		ActionInfo_Arr["<Mark>"] :=" Marking function, Mark the current folder, use ' to open the corresponding mark "
		ActionInfo_Arr["<ListMark>"] :=" Show all marks ( Mark by m like in VIM) "
		ActionInfo_Arr["<Internetsearch>"] :=" Use the default internet browser to search for the current file "
		ActionInfo_Arr["<azHistory>"] :=" Prefix the history of the folder, Easy to use a-z navigation "
		ActionInfo_Arr["<azCmdHistory>"] :=" View the command history "
		ActionInfo_Arr["<ListMapKey>"] :=" Show custom mapping keys "
		ActionInfo_Arr["<WinMaxLeft>"] :=" Maximize left panel "
		ActionInfo_Arr["<WinMaxRight>"] :=" Maximize right panel "
		ActionInfo_Arr["<AlwayOnTop>"] :=" TC always on top "
		ActionInfo_Arr["<Transparent>"] :=" TC Transparent "
		ActionInfo_Arr["<DeleteLHistory>"] :=" Delete history of the left folder "
		ActionInfo_Arr["<DeleteRHistory>"] :=" Delete history of the right folder "
		ActionInfo_Arr["<DelCmdHistory>"] :=" Delete command line history "
		ActionInfo_Arr["<GoLastTab>"] :=" Go to the last tab "
		ActionInfo_Arr["<TCLite>"] :=" Simplest TC"
		ActionInfo_Arr["<TCFullScreen>"] :="TC full screen "
		ActionInfo_Arr["<SrcComments>"] :=" Source window :  Show file comments "
		ActionInfo_Arr["<SrcShort>"] :=" Source window :  List "
		ActionInfo_Arr["<SrcLong>"] :=" Source window :  Details "
		ActionInfo_Arr["<SrcTree>"] :=" Source window :  Folder Tree "
		ActionInfo_Arr["<SrcQuickview>"] :=" Source window :  Quick View "
		ActionInfo_Arr["<VerticalPanels>"] :=" Vertical / Horizontal arrangement "
		ActionInfo_Arr["<SrcQuickInternalOnly>"] :=" Source window :  Quick View ( No plugins )"
		ActionInfo_Arr["<SrcHideQuickview>"] :=" Source window :  Close the Quick View window "
		ActionInfo_Arr["<SrcExecs>"] :=" Source window :  Executable file "
		ActionInfo_Arr["<SrcAllFiles>"] :=" Source window :  All files "
		ActionInfo_Arr["<SrcUserSpec>"] :=" Source window :  The last selected file "
		ActionInfo_Arr["<SrcUserDef>"] :=" Source window :  Custom type "
		ActionInfo_Arr["<SrcByName>"] :=" Source window :  Sort by file name "
		ActionInfo_Arr["<SrcByExt>"] :=" Source window :  Sort by extension "
		ActionInfo_Arr["<SrcBySize>"] :=" Source window :  Sort by size "
		ActionInfo_Arr["<SrcByDateTime>"] :=" Source window :  Sort by date and time "
		ActionInfo_Arr["<SrcUnsorted>"] :=" Source window :  Not sorted "
		ActionInfo_Arr["<SrcNegOrder>"] :=" Source window :  Reverse sort "
		ActionInfo_Arr["<SrcOpenDrives>"] :=" Source window :  Open the drive list "
		ActionInfo_Arr["<SrcThumbs>"] :=" Source window :  Thumbnails "
		ActionInfo_Arr["<SrcCustomViewMenu>"] :=" Source window :  Customize the view menu "
		ActionInfo_Arr["<SrcPathFocus>"] :=" Source window :  Focus on the path "
		ActionInfo_Arr["<LeftComments>"] :=" Left window :  Show file comments "
		ActionInfo_Arr["<LeftShort>"] :=" Left window :  List "
		ActionInfo_Arr["<LeftLong>"] :=" Left window :  Details "
		ActionInfo_Arr["<LeftTree>"] :=" Left window :  Folder Tree "
		ActionInfo_Arr["<LeftQuickview>"] :=" Left window :  Quick View "
		ActionInfo_Arr["<LeftQuickInternalOnly>"] :=" Left window :  Quick View ( No plugins )"
		ActionInfo_Arr["<LeftHideQuickview>"] :=" Left window :  Close the Quick View window "
		ActionInfo_Arr["<LeftExecs>"] :=" Left window :  executable file "
		ActionInfo_Arr["<LeftAllFiles>"] :=" Left window :  All files "
		ActionInfo_Arr["<LeftUserSpec>"] :=" Left window :  The last selected file "
		ActionInfo_Arr["<LeftUserDef>"] :=" Left window :  Custom type "
		ActionInfo_Arr["<LeftByName>"] :=" Left window :  Sort by file name "
		ActionInfo_Arr["<LeftByExt>"] :=" Left window :  Sort by extension "
		ActionInfo_Arr["<LeftBySize>"] :=" Left window :  Sort by size "
		ActionInfo_Arr["<LeftByDateTime>"] :=" Left window :  Sort by date and time "
		ActionInfo_Arr["<LeftUnsorted>"] :=" Left window :  Not sorted "
		ActionInfo_Arr["<LeftNegOrder>"] :=" Left window :  Reverse sort "
		ActionInfo_Arr["<LeftOpenDrives>"] :=" Left window :  Open the drive list "
		ActionInfo_Arr["<LeftPathFocus>"] :=" Left window :  Focus on the path "
		ActionInfo_Arr["<LeftDirBranch>"] :=" Left window :  Expand all folders "
		ActionInfo_Arr["<LeftDirBranchSel>"] :=" Left window :  Only the selected folder is expanded "
		ActionInfo_Arr["<LeftThumbs>"] :=" window :  Thumbnails "
		ActionInfo_Arr["<LeftCustomViewMenu>"] :=" window :  Customize the view menu "
		ActionInfo_Arr["<RightComments>"] :=" Right window :  Show file notes "
		ActionInfo_Arr["<RightShort>"] :=" Right window :  List "
		ActionInfo_Arr["<RightLong>"] :=" details "
		ActionInfo_Arr["<RightTre>"] :=" Right window :  Folder Tree "
		ActionInfo_Arr["<RightQuickvie>"] :=" Right window :  Quick View "
		ActionInfo_Arr["<RightQuickInternalOnl>"] :=" Right window :  Quick View ( No plugins )"
		ActionInfo_Arr["<RightHideQuickvie>"] :=" Right window :  Close the Quick View window "
		ActionInfo_Arr["<RightExec>"] :=" Right window :  executable file "
		ActionInfo_Arr["<RightAllFile>"] :=" Right window :  All files "
		ActionInfo_Arr["<RightUserSpe>"] :=" Right window :  The last selected file "
		ActionInfo_Arr["<RightUserDe>"] :=" Right window :  Custom type "
		ActionInfo_Arr["<RightByNam>"] :=" Right window :  Sort by file name "
		ActionInfo_Arr["<RightByEx>"] :=" Right window :  Sort by extension "
		ActionInfo_Arr["<RightBySiz>"] :=" Right window :  Sort by size "
		ActionInfo_Arr["<RightByDateTim>"] :=" Right window :  Sort by date and time "
		ActionInfo_Arr["<RightUnsorte>"] :=" Right window :  Not sorted "
		ActionInfo_Arr["<RightNegOrde>"] :=" Right window :  Reverse sort "
		ActionInfo_Arr["<RightOpenDrive>"] :=" Right window :  Open the drive list "
		ActionInfo_Arr["<RightPathFocu>"] :=" Right window :  Focus on the path "
		ActionInfo_Arr["<RightDirBranch>"] :=" Right window :  Expand all folders "
		ActionInfo_Arr["<RightDirBranchSel>"] :=" Right window :  Only the selected folder is expanded "
		ActionInfo_Arr["<RightThumb>"] :=" Right window :  Thumbnails "
		ActionInfo_Arr["<RightCustomViewMen>"] :=" Right window :  Customize the view menu "
		ActionInfo_Arr["<List>"] :=" To view ( Use the view program )"
		ActionInfo_Arr["<ListInternalOnly>"] :=" To view ( Use the view program, But not plugin / multimedia )"
		ActionInfo_Arr["<Edit>"] :=" edit "
		ActionInfo_Arr["<Copy>"] :=" copy "
		ActionInfo_Arr["<CopySamepanel>"] :=" Copy to the current window "
		ActionInfo_Arr["<CopyOtherpanel>"] :=" Copy to another window "
		ActionInfo_Arr["<RenMov>"] :=" Rename / Move "
		ActionInfo_Arr["<MkDir>"] :=" New Folder "
		ActionInfo_Arr["<Delete>"] :=" Delete "
		ActionInfo_Arr["<TestArchive>"] :=" Test compression package "
		ActionInfo_Arr["<PackFiles>"] :=" Compressed file "
		ActionInfo_Arr["<UnpackFiles>"] :=" Unzip files "
		ActionInfo_Arr["<RenameOnly>"] :=" Rename (Shift+F6)"
		ActionInfo_Arr["<RenameSingleFile>"] :=" Rename current file "
		ActionInfo_Arr["<MoveOnly>"] :=" Move (F6)"
		ActionInfo_Arr["<Properties>"] :=" Display properties "
		ActionInfo_Arr["<CreateShortcut>"] :=" Create Shortcut "
		ActionInfo_Arr["<Return>"] :=" Simulate ENTER key "
		ActionInfo_Arr["<OpenAsUser>"] :=" Run the file under cursor as onother user "
		ActionInfo_Arr["<Split>"] :=" Split files "
		ActionInfo_Arr["<Combine>"] :=" Merge documents "
		ActionInfo_Arr["<Encode>"] :=" Encoding file (MIME/UUE/XXE  format )"
		ActionInfo_Arr["<Decode>"] :=" Decode the file (MIME/UUE/XXE/BinHex  format )"
		ActionInfo_Arr["<CRCcreate>"] :=" Create a check file "
		ActionInfo_Arr["<CRCcheck>"] :=" Verify checksum "
		ActionInfo_Arr["<SetAttrib>"] :=" Change the property "
		ActionInfo_Arr["<Config>"] :=" Configuration :  layout "
		ActionInfo_Arr["<DisplayConfig>"] :=" Configuration :  display "
		ActionInfo_Arr["<IconConfig>"] :=" Configuration :  icon "
		ActionInfo_Arr["<FontConfig>"] :=" Configuration :  Font "
		ActionInfo_Arr["<ColorConfig>"] :=" Configuration :  Colour "
		ActionInfo_Arr["<ConfTabChange>"] :=" Configuration :  Tabs "
		ActionInfo_Arr["<DirTabsConfig>"] :=" Configuration :  Folder tab "
		ActionInfo_Arr["<CustomColumnConfig>"] :=" Configuration :  Custom columns "
		ActionInfo_Arr["<CustomColumnDlg>"] :=" Change the current custom column "
		ActionInfo_Arr["<LanguageConfig>"] :=" Configuration :  Language "
		ActionInfo_Arr["<Config2>"] :=" Configuration :  Operation method "
		ActionInfo_Arr["<EditConfig>"] :=" Configuration :  edit / To view "
		ActionInfo_Arr["<CopyConfig>"] :=" Configuration :  copy / delete "
		ActionInfo_Arr["<RefreshConfig>"] :=" Configuration :  Refresh "
		ActionInfo_Arr["<QuickSearchConfig>"] :=" Configuration :  fast Search "
		ActionInfo_Arr["<FtpConfig>"] :=" Configuration : FTP"
		ActionInfo_Arr["<PluginsConfig>"] :=" Configuration :  Plugin "
		ActionInfo_Arr["<ThumbnailsConfig>"] :=" Configuration :  Thumbnails "
		ActionInfo_Arr["<LogConfig>"] :=" Configuration :  Log file "
		ActionInfo_Arr["<IgnoreConfig>"] :=" Configuration :  Hide the file "
		ActionInfo_Arr["<PackerConfig>"] :=" Configuration :  Compression program "
		ActionInfo_Arr["<ZipPackerConfig>"] :=" Configuration : ZIP  Compression program "
		ActionInfo_Arr["<Confirmation>"] :=" Configuration :  other / confirm "
		ActionInfo_Arr["<ConfigSavePos>"] :=" Save location "
		ActionInfo_Arr["<ButtonConfig>"] :=" Change the toolbar "
		ActionInfo_Arr["<ConfigSaveSettings>"] :=" Save Settings "
		ActionInfo_Arr["<ConfigChangeIniFiles>"] :=" Modify the configuration file directly "
		ActionInfo_Arr["<ConfigSaveDirHistory>"] :=" Save the folder history "
		ActionInfo_Arr["<ChangeStartMenu>"] :=" Change the Start menu "
		ActionInfo_Arr["<NetConnect>"] :=" Mapping network drives "
		ActionInfo_Arr["<NetDisconnect>"] :=" Disconnect the network drive "
		ActionInfo_Arr["<NetShareDir>"] :=" Share the current folder "
		ActionInfo_Arr["<NetUnshareDir>"] :=" Cancel folder sharing "
		ActionInfo_Arr["<AdministerServer>"] :=" Show system shared folder "
		ActionInfo_Arr["<ShowFileUser>"] :=" Displays the remote user of the local file "
		ActionInfo_Arr["<GetFileSpace>"] :=" Calculate the footprint "
		ActionInfo_Arr["<VolumeId>"] :=" Set the tab "
		ActionInfo_Arr["<VersionInfo>"] :=" Version Information "
		ActionInfo_Arr["<ExecuteDOS>"] :=" Open the Command Prompt window "
		ActionInfo_Arr["<CompareDirs>"] :=" Compare folders "
		ActionInfo_Arr["<CompareDirsWithSubdirs>"] :=" Compare folders ( Also mark a subfolder that does not have another window )"
		ActionInfo_Arr["<ContextMenu>"] :=" Show the shortcut menu "
		ActionInfo_Arr["<ContextMenuInternal>"] :=" Show the shortcut menu ( Internal association )"
		ActionInfo_Arr["<ContextMenuInternalCursor>"] :=" Displays the internal context menu for the file at the cursor "
		ActionInfo_Arr["<ShowRemoteMenu>"] :=" Media Center Remote Control Play / Pause key shortcut menu "
		ActionInfo_Arr["<SyncChangeDir>"] :=" Both sides of the window are synchronized to change the folder "
		ActionInfo_Arr["<EditComment>"] :=" Edit file notes "
		ActionInfo_Arr["<FocusLeft>"] :=" Focus on the left window "
		ActionInfo_Arr["<FocusRight>"] :=" Focus on the right window "
		ActionInfo_Arr["<FocusCmdLine>"] :=" Focus on the command line "
		ActionInfo_Arr["<FocusButtonBar>"] :=" Focus on the toolbar "
		ActionInfo_Arr["<CountDirContent>"] :=" Calculate the space occupied by all folders "
		ActionInfo_Arr["<UnloadPlugins>"] :=" Unload all plugins "
		ActionInfo_Arr["<DirMatch>"] :=" Mark a new file, Hide the same person "
		ActionInfo_Arr["<Exchange>"] :=" Exchange left and right windows "
		ActionInfo_Arr["<MatchSrc>"] :=" target  =  source "
		ActionInfo_Arr["<ReloadSelThumbs>"] :=" Refresh the thumbnail of the selected file "
		ActionInfo_Arr["<DirectCableConnect>"] :=" Direct cable connection "
		ActionInfo_Arr["<NTinstallDriver>"] :=" Load  NT  Parallel port driver "
		ActionInfo_Arr["<NTremoveDriver>"] :=" Unloading  NT  Parallel port driver "
		ActionInfo_Arr["<PrintDir>"] :=" Print a list of files "
		ActionInfo_Arr["<PrintDirSub>"] :=" Print a list of files ( Contains subfolders )"
		ActionInfo_Arr["<PrintFile>"] :=" Print the contents of the file "
		ActionInfo_Arr["<SpreadSelection>"] :=" Select a set of files "
		ActionInfo_Arr["<SelectBoth>"] :=" Select :  Files and folders "
		ActionInfo_Arr["<SelectFiles>"] :=" Select :  Only file "
		ActionInfo_Arr["<SelectFolders>"] :=" Select :  Only folders "
		ActionInfo_Arr["<ShrinkSelection>"] :=" Shrink Selection "
		ActionInfo_Arr["<ClearFiles>"] :=" Clear selected :  Only files "
		ActionInfo_Arr["<ClearFolders>"] :=" Clear selected:  Only folders "
		ActionInfo_Arr["<ClearSelCfg>"] :=" Clear selected:  File and / or folders ( Depending on configuration )"
		ActionInfo_Arr["<SelectAll>"] :=" All selected :  File and / or folders ( Depending on configuration )"
		ActionInfo_Arr["<SelectAllBoth>"] :=" All selected :  Files and folders "
		ActionInfo_Arr["<SelectAllFiles>"] :=" All selected :  Only file "
		ActionInfo_Arr["<SelectAllFolders>"] :=" All selected :  Only folders "
		ActionInfo_Arr["<ClearAll>"] :=" Clear All  :  Files and folders "
		ActionInfo_Arr["<ClearAllFiles>"] :=" Clear All  :  Only file "
		ActionInfo_Arr["<ClearAllFolders>"] :=" Clear All  :  Only folders "
		ActionInfo_Arr["<ClearAllCfg>"] :=" Clear All  :  File and / or folders ( Depending on configuration )"
		ActionInfo_Arr["<ExchangeSelection>"] :=" Reverse selection "
		ActionInfo_Arr["<ExchangeSelBoth>"] :=" Reverse selection :  Files and folders "
		ActionInfo_Arr["<ExchangeSelFiles>"] :=" Reverse selection :  Only file "
		ActionInfo_Arr["<ExchangeSelFolders>"] :=" Reverse selection :  Only folders "
		ActionInfo_Arr["<SelectCurrentExtension>"] :=" Select the same file with the same extension "
		ActionInfo_Arr["<UnselectCurrentExtension>"] :=" Do not select the same file with the same extension "
		ActionInfo_Arr["<SelectCurrentName>"] :=" Select the file with the same file name "
		ActionInfo_Arr["<UnselectCurrentName>"] :=" Do not select files with the same file name "
		ActionInfo_Arr["<SelectCurrentNameExt>"] :=" Select the file with the same file name and extension "
		ActionInfo_Arr["<UnselectCurrentNameExt>"] :=" Do not select files with the same file name and extension "
		ActionInfo_Arr["<SelectCurrentPath>"] :=" Select the same path under the file ( Expand the folder + Search for files )"
		ActionInfo_Arr["<UnselectCurrentPath>"] :=" Do not choose the same path under the file ( Expand the folder + Search the file )"
		ActionInfo_Arr["<RestoreSelection>"] :=" Restore the selection list "
		ActionInfo_Arr["<SaveSelection>"] :=" Save the selection list "
		ActionInfo_Arr["<SaveSelectionToFile>"] :=" Export the selection list "
		ActionInfo_Arr["<SaveSelectionToFileA>"] :=" Export the selection list (ANSI)"
		ActionInfo_Arr["<SaveSelectionToFileW>"] :=" Export the selection list (Unicode)"
		ActionInfo_Arr["<SaveDetailsToFile>"] :=" Export details "
		ActionInfo_Arr["<SaveDetailsToFileA>"] :=" Export details (ANSI)"
		ActionInfo_Arr["<SaveDetailsToFileW>"] :=" Export details (Unicode)"
		ActionInfo_Arr["<LoadSelectionFromFile>"] :=" Import selection list ( From the file )"
		ActionInfo_Arr["<LoadSelectionFromClip>"] :=" Import the selection list ( From the clipboard )"
		ActionInfo_Arr["<EditPermissionInfo>"] :=" Setting permissions (NTFS)"
		ActionInfo_Arr["<EditAuditInfo>"] :=" Review the document (NTFS)"
		ActionInfo_Arr["<EditOwnerInfo>"] :=" Get ownership (NTFS)"
		ActionInfo_Arr["<CutToClipboard>"] :=" Cut the selected file to the clipboard "
		ActionInfo_Arr["<CopyToClipboard>"] :=" Copy the selected file to the clipboard "
		ActionInfo_Arr["<PasteFromClipboard>"] :=" Paste from the clipboard to the current folder "
		ActionInfo_Arr["<CopyNamesToClip>"] :=" Copy the file name "
		ActionInfo_Arr["<CopyFullNamesToClip>"] :=" Copy the file name and the full path "
		ActionInfo_Arr["<CopyNetNamesToClip>"] :=" Copy the file name and network path "
		ActionInfo_Arr["<CopySrcPathToClip>"] :=" Copy the source path "
		ActionInfo_Arr["<CopyTrgPathToClip>"] :=" Copy the destination path "
		ActionInfo_Arr["<CopyFileDetailsToClip>"] :=" Copy the file details "
		ActionInfo_Arr["<CopyFpFileDetailsToClip>"] :=" Copy the file details and the full path "
		ActionInfo_Arr["<CopyNetFileDetailsToClip>"] :=" Copy file details and network path "
		ActionInfo_Arr["<FtpConnect>"] :="FTP  connection "
		ActionInfo_Arr["<FtpNew>"] :=" New  FTP  connection "
		ActionInfo_Arr["<FtpDisconnect>"] :=" disconnect  FTP  connection "
		ActionInfo_Arr["<FtpHiddenFiles>"] :=" Show hidden FTP files "
		ActionInfo_Arr["<FtpAbort>"] :=" Stop the current  FTP  command "
		ActionInfo_Arr["<FtpResumeDownload>"] :=" FtpResumeDownload "
		ActionInfo_Arr["<FtpSelectTransferMode>"] :=" Select the transfer mode "
		ActionInfo_Arr["<FtpAddToList>"] :=" Add to download list "
		ActionInfo_Arr["<FtpDownloadList>"] :=" FtpDownloadList "
		ActionInfo_Arr["<GotoPreviousDir>"] :=" GotoPreviousDir "
		ActionInfo_Arr["<GotoNextDir>"] :=" GotoNextDir "
		ActionInfo_Arr["<DirectoryHistory>"] :=" Folder history "
		ActionInfo_Arr["<GotoPreviousLocalDir>"] :=" GotoPreviousLocalDir (non-FTP)"
		ActionInfo_Arr["<GotoNextLocalDir>"] :=" GotoNextLocalDir (non-FTP)"
		ActionInfo_Arr["<DirectoryHotlist>"] :=" DirectoryHotlist "
		ActionInfo_Arr["<GoToRoot>"] :=" Go to the root folder "
		ActionInfo_Arr["<GoToParent>"] :=" Go to the upper folder "
		ActionInfo_Arr["<GoToDir>"] :=" Open the folder or archive at the cursor "
		ActionInfo_Arr["<OpenDesktop>"] :=" desktop "
		ActionInfo_Arr["<OpenDrives>"] :=" my computer "
		ActionInfo_Arr["<OpenControls>"] :=" control panel "
		ActionInfo_Arr["<OpenFonts>"] :=" Font "
		ActionInfo_Arr["<OpenNetwork>"] :=" OpenNetwork "
		ActionInfo_Arr["<OpenPrinters>"] :=" printer "
		ActionInfo_Arr["<OpenRecycled>"] :=" Recycle bin "
		ActionInfo_Arr["<CDtree>"] :=" Change the folder "
		ActionInfo_Arr["<TransferLeft>"] :=" Open the folder or the compressed package at the cursor in the left window "
		ActionInfo_Arr["<TransferRight>"] :=" Open the folder or archive at the cursor in the right window "
		ActionInfo_Arr["<EditPath>"] :=" Edit the path of the source window "
		ActionInfo_Arr["<GoToFirstFile>"] :=" The cursor moves to the first file in the list "
		ActionInfo_Arr["<GotoNextDrive>"] :=" Go to the next drive "
		ActionInfo_Arr["<GotoPreviousDrive>"] :=" Go to the previous drive "
		ActionInfo_Arr["<GotoNextSelected>"] :=" Go to the next selected file "
		ActionInfo_Arr["<GotoPrevSelected>"] :=" Go to the previous selected file "
		ActionInfo_Arr["<GotoDriveA>"] :=" Go to the drive  A"
		ActionInfo_Arr["<GotoDriveC>"] :=" Go to the drive  C"
		ActionInfo_Arr["<GotoDriveD>"] :=" Go to the drive  D"
		ActionInfo_Arr["<GotoDriveE>"] :=" Go to the drive  E"
		ActionInfo_Arr["<GotoDriveF>"] :=" You can customize other drives "
		ActionInfo_Arr["<GotoDriveZ>"] :=" GotoDriveZ, max 26"
		ActionInfo_Arr["<HelpIndex>"] :=" Help index "
		ActionInfo_Arr["<Keyboard>"] :=" Shortcut list "
		ActionInfo_Arr["<Register>"] :=" registration message "
		ActionInfo_Arr["<VisitHomepage>"] :=" access  Totalcmd  website "
		ActionInfo_Arr["<About>"] :=" About  Total Commander"
		ActionInfo_Arr["<Exit>"] :=" Exit  Total Commander"
		ActionInfo_Arr["<Minimize>"] :=" minimize  Total Commander"
		ActionInfo_Arr["<Maximize>"] :=" maximize  Total Commander"
		ActionInfo_Arr["<Restore>"] :=" Return to normal size "
		ActionInfo_Arr["<ClearCmdLine>"] :=" Clear the command line "
		ActionInfo_Arr["<NextCommand>"] :=" Next command "
		ActionInfo_Arr["<PrevCommand>"] :=" Previous command "
		ActionInfo_Arr["<AddPathToCmdline>"] :=" Copy the path to the command line "
		ActionInfo_Arr["<MultiRenameFiles>"] :=" Batch rename "
		ActionInfo_Arr["<SysInfo>"] :=" system message "
		ActionInfo_Arr["<OpenTransferManager>"] :=" Background Transfer Manager "
		ActionInfo_Arr["<SearchFor>"] :=" Search for files "
		ActionInfo_Arr["<FileSync>"] :=" Synchronize folders "
		ActionInfo_Arr["<Associate>"] :=" File association "
		ActionInfo_Arr["<InternalAssociate>"] :=" Define internal associations "
		ActionInfo_Arr["<CompareFilesByContent>"] :=" Compare the contents of the file "
		ActionInfo_Arr["<IntCompareFilesByContent>"] :=" Use the internal comparison program "
		ActionInfo_Arr["<CommandBrowser>"] :=" Browse internal commands "
		ActionInfo_Arr["<VisButtonbar>"] :=" display / hide :  toolbar "
		ActionInfo_Arr["<VisDriveButtons>"] :=" display / hide :  Drive button "
		ActionInfo_Arr["<VisTwoDriveButtons>"] :=" display / hide :  Two drive button bars "
		ActionInfo_Arr["<VisFlatDriveButtons>"] :=" Switch :  flat / Stereo drive button "
		ActionInfo_Arr["<VisFlatInterface>"] :=" Switch :  flat / Three-dimensional user interface "
		ActionInfo_Arr["<VisDriveCombo>"] :=" display / hide :  Drive list "
		ActionInfo_Arr["<VisCurDir>"] :=" display / hide :  Current folder "
		ActionInfo_Arr["<VisBreadCrumbs>"] :=" display / hide :  Path navigation bar "
		ActionInfo_Arr["<VisTabHeader>"] :=" display / hide :  Sort tab "
		ActionInfo_Arr["<VisStatusbar>"] :=" display / hide :  Status Bar "
		ActionInfo_Arr["<VisCmdLine>"] :=" display / hide :  Command Line "
		ActionInfo_Arr["<VisKeyButtons>"] :=" display / hide :  Function button "
		ActionInfo_Arr["<ShowHint>"] :=" Show file prompts "
		ActionInfo_Arr["<ShowQuickSearch>"] :=" Show the quick search window "
		ActionInfo_Arr["<SwitchLongNames>"] :=" Open / Close :  Long file name display "
		ActionInfo_Arr["<RereadSource>"] :=" Refresh the source window "
		ActionInfo_Arr["<ShowOnlySelected>"] :=" Only the selected files are displayed "
		ActionInfo_Arr["<SwitchHidSys>"] :=" Open / Close :  Hidden or system file display "
		ActionInfo_Arr["<Switch83Names>"] :=" Open / Close : 8.3  Type file name lowercase display "
		ActionInfo_Arr["<SwitchDirSort>"] :=" Open / Close :  The folders are sorted by name "
		ActionInfo_Arr["<DirBranch>"] :=" Expand all folders "
		ActionInfo_Arr["<DirBranchSel>"] :=" Only the selected folder is expanded "
		ActionInfo_Arr["<50Percent>"] :=" Set the window divider at 50%"
		ActionInfo_Arr["<100Percent>"] :=" Set the window divider at 100% (TC 8.0+)"
		ActionInfo_Arr["<VisDirTabs>"] :=" display / hide :  Folder tab "
		ActionInfo_Arr["<VisXPThemeBackground>"] :=" display / hide : XP  Theme background "
		ActionInfo_Arr["<SwitchOverlayIcons>"] :=" Open / Close :  Overlay icon display "
		ActionInfo_Arr["<VisHistHotButtons>"] :=" display / hide :  Folder history and frequently used folder buttons "
		ActionInfo_Arr["<SwitchWatchDirs>"] :=" Enable / Disable :  The folder is automatically refreshed "
		ActionInfo_Arr["<SwitchIgnoreList>"] :=" Enable / Disable :  Customize hidden files "
		ActionInfo_Arr["<SwitchX64Redirection>"] :=" Open / Close : 32  Bit  system32  Directory redirect (64  Bit  Windows)"
		ActionInfo_Arr["<SeparateTreeOff>"] :=" Close the separate folder tree panel "
		ActionInfo_Arr["<SeparateTree1>"] :=" A separate folder tree panel "
		ActionInfo_Arr["<SeparateTree2>"] :=" Two separate folder tree panels "
		ActionInfo_Arr["<SwitchSeparateTree>"] :=" Toggle the independent folder tree panel status "
		ActionInfo_Arr["<ToggleSeparateTree1>"] :=" Open / Close :  A separate folder tree panel "
		ActionInfo_Arr["<ToggleSeparateTree2>"] :=" Open / Close :  Two separate folder tree panels "
		ActionInfo_Arr["<UserMenu1>"] :=" User menu  1"
		ActionInfo_Arr["<UserMenu2>"] :=" User menu  2"
		ActionInfo_Arr["<UserMenu3>"] :=" User menu  3"
		ActionInfo_Arr["<UserMenu4>"] :="..."
		ActionInfo_Arr["<UserMenu5>"] :="5"
		ActionInfo_Arr["<UserMenu6>"] :="6"
		ActionInfo_Arr["<UserMenu7>"] :="7"
		ActionInfo_Arr["<UserMenu8>"] :="8"
		ActionInfo_Arr["<UserMenu9>"] :="9"
		ActionInfo_Arr["<UserMenu10>"] :=" You can define other user menus "
		ActionInfo_Arr["<OpenNewTab>"] :=" New tab "
		ActionInfo_Arr["<OpenNewTabBg>"] :=" New tab ( In the background )"
		ActionInfo_Arr["<OpenDirInNewTab>"] :=" New tab ( And open the folder at the cursor )"
		ActionInfo_Arr["<OpenDirInNewTabOther>"] :=" New tab ( Open the folder in another window )"
		ActionInfo_Arr["<SwitchToNextTab>"] :="Next tab (Ctrl+Tab)"
		ActionInfo_Arr["<SwitchToPreviousTab>"] :=" Previous tab (Ctrl+Shift+Tab)"
		ActionInfo_Arr["<CloseCurrentTab>"] :=" Close the current tab "
		ActionInfo_Arr["<CloseAllTabs>"] :=" Close all tabs "
		ActionInfo_Arr["<DirTabsShowMenu>"] :=" Display the tab menu "
		ActionInfo_Arr["<ToggleLockCurrentTab>"] :=" Lock/Unlock the current tab "
		ActionInfo_Arr["<ToggleLockDcaCurrentTab>"] :=" Lock/Unlock the current tab ( You can change the folder )"
		ActionInfo_Arr["<ExchangeWithTabs>"] :=" Exchange left and right windows and their tabs "
		ActionInfo_Arr["<GoToLockedDir>"] :=" Go to the root folder of the locked tab "
		ActionInfo_Arr["<SrcActivateTab1>"] :=" Source window :  Activate the tab  1"
		ActionInfo_Arr["<SrcActivateTab2>"] :=" Source window :  Activate the tab  2"
		ActionInfo_Arr["<SrcActivateTab3>"] :="..."
		ActionInfo_Arr["<SrcActivateTab4>"] :=" max 99 "
		ActionInfo_Arr["<SrcActivateTab5>"] :="5"
		ActionInfo_Arr["<SrcActivateTab6>"] :="6"
		ActionInfo_Arr["<SrcActivateTab7>"] :="7"
		ActionInfo_Arr["<SrcActivateTab8>"] :="8"
		ActionInfo_Arr["<SrcActivateTab9>"] :="9"
		ActionInfo_Arr["<SrcActivateTab10>"] :="0"
		ActionInfo_Arr["<TrgActivateTab1>"] :=" Target window :  Activate the tab  1"
		ActionInfo_Arr["<TrgActivateTab2>"] :=" Target window :  Activate the tab  2"
		ActionInfo_Arr["<TrgActivateTab3>"] :="..."
		ActionInfo_Arr["<TrgActivateTab4>"] :=" max 99 "
		ActionInfo_Arr["<TrgActivateTab5>"] :="5"
		ActionInfo_Arr["<TrgActivateTab6>"] :="6"
		ActionInfo_Arr["<TrgActivateTab7>"] :="7"
		ActionInfo_Arr["<TrgActivateTab8>"] :="8"
		ActionInfo_Arr["<TrgActivateTab9>"] :="9"
		ActionInfo_Arr["<TrgActivateTab10>"] :="0"
		ActionInfo_Arr["<LeftActivateTab1>"] :=" Left window :  Activate the tab  1"
		ActionInfo_Arr["<LeftActivateTab2>"] :=" Left window :  Activate the tab  2"
		ActionInfo_Arr["<LeftActivateTab3>"] :="..."
		ActionInfo_Arr["<LeftActivateTab4>"] :=" max 99 "
		ActionInfo_Arr["<LeftActivateTab5>"] :="5"
		ActionInfo_Arr["<LeftActivateTab6>"] :="6"
		ActionInfo_Arr["<LeftActivateTab7>"] :="7"
		ActionInfo_Arr["<LeftActivateTab8>"] :="8"
		ActionInfo_Arr["<LeftActivateTab9>"] :="9"
		ActionInfo_Arr["<LeftActivateTab10>"] :="0"
		ActionInfo_Arr["<RightActivateTab1>"] :=" Right window :  Activate the tab  1"
		ActionInfo_Arr["<RightActivateTab2>"] :=" Right window :  Activate the tab  2"
		ActionInfo_Arr["<RightActivateTab3>"] :="..."
		ActionInfo_Arr["<RightActivateTab4>"] :=" max 99 "
		ActionInfo_Arr["<RightActivateTab5>"] :="5"
		ActionInfo_Arr["<RightActivateTab6>"] :="6"
		ActionInfo_Arr["<RightActivateTab7>"] :="7"
		ActionInfo_Arr["<RightActivateTab8>"] :="8"
		ActionInfo_Arr["<RightActivateTab9>"] :="9"
		ActionInfo_Arr["<RightActivateTab10>"] :="0"
		ActionInfo_Arr["<SrcSortByCol1>"] :=" Source window :  Sort by column 1"
		ActionInfo_Arr["<SrcSortByCol2>"] :=" Source window :  Sort by column 2"
		ActionInfo_Arr["<SrcSortByCol3>"] :="..."
		ActionInfo_Arr["<SrcSortByCol4>"] :=" most  99  Column "
		ActionInfo_Arr["<SrcSortByCol5>"] :="5"
		ActionInfo_Arr["<SrcSortByCol6>"] :="6"
		ActionInfo_Arr["<SrcSortByCol7>"] :="7"
		ActionInfo_Arr["<SrcSortByCol8>"] :="8"
		ActionInfo_Arr["<SrcSortByCol9>"] :="9"
		ActionInfo_Arr["<SrcSortByCol10>"] :="0"
		ActionInfo_Arr["<SrcSortByCol99>"] :="9"
		ActionInfo_Arr["<TrgSortByCol1>"] :=" Target window :  Sort by column 1"
		ActionInfo_Arr["<TrgSortByCol2>"] :=" Target window :  Sort by column 2"
		ActionInfo_Arr["<TrgSortByCol3>"] :="..."
		ActionInfo_Arr["<TrgSortByCol4>"] :=" most  99  Column "
		ActionInfo_Arr["<TrgSortByCol5>"] :="5"
		ActionInfo_Arr["<TrgSortByCol6>"] :="6"
		ActionInfo_Arr["<TrgSortByCol7>"] :="7"
		ActionInfo_Arr["<TrgSortByCol8>"] :="8"
		ActionInfo_Arr["<TrgSortByCol9>"] :="9"
		ActionInfo_Arr["<TrgSortByCol10>"] :="0"
		ActionInfo_Arr["<TrgSortByCol99>"] :="9"
		ActionInfo_Arr["<LeftSortByCol1>"] :=" Left window :  Sort by column 1"
		ActionInfo_Arr["<LeftSortByCol2>"] :=" Left window :  Sort by column 2"
		ActionInfo_Arr["<LeftSortByCol3>"] :="..."
		ActionInfo_Arr["<LeftSortByCol4>"] :=" most  99  Column "
		ActionInfo_Arr["<LeftSortByCol5>"] :="5"
		ActionInfo_Arr["<LeftSortByCol6>"] :="6"
		ActionInfo_Arr["<LeftSortByCol7>"] :="7"
		ActionInfo_Arr["<LeftSortByCol8>"] :="8"
		ActionInfo_Arr["<LeftSortByCol9>"] :="9"
		ActionInfo_Arr["<LeftSortByCol10>"] :="0"
		ActionInfo_Arr["<LeftSortByCol99>"] :="9"
		ActionInfo_Arr["<RightSortByCol1>"] :=" Right window :  Sort by column 1"
		ActionInfo_Arr["<RightSortByCol2>"] :=" Right window :  Sort by column 2"
		ActionInfo_Arr["<RightSortByCol3>"] :="..."
		ActionInfo_Arr["<RightSortByCol4>"] :=" most  99  Column "
		ActionInfo_Arr["<RightSortByCol5>"] :="5"
		ActionInfo_Arr["<RightSortByCol6>"] :="6"
		ActionInfo_Arr["<RightSortByCol7>"] :="7"
		ActionInfo_Arr["<RightSortByCol8>"] :="8"
		ActionInfo_Arr["<RightSortByCol9>"] :="9"
		ActionInfo_Arr["<RightSortByCol10>"] :="0"
		ActionInfo_Arr["<RightSortByCol99>"] :="9"
		ActionInfo_Arr["<SrcCustomView1>"] :=" Source window :  Customize the column view  1"
		ActionInfo_Arr["<SrcCustomView2>"] :=" Source window :  Customize the column view  2"
		ActionInfo_Arr["<SrcCustomView3>"] :="..."
		ActionInfo_Arr["<SrcCustomView4>"] :=" 29 max"
		ActionInfo_Arr["<SrcCustomView5>"] :="5"
		ActionInfo_Arr["<SrcCustomView6>"] :="6"
		ActionInfo_Arr["<SrcCustomView7>"] :="7"
		ActionInfo_Arr["<SrcCustomView8>"] :="8"
		ActionInfo_Arr["<SrcCustomView9>"] :="9"
		ActionInfo_Arr["<LeftCustomView1>"] :=" Left window :  Customize the column view  1"
		ActionInfo_Arr["<LeftCustomView2>"] :=" Left window :  Customize the column view  2"
		ActionInfo_Arr["<LeftCustomView3>"] :="..."
		ActionInfo_Arr["<LeftCustomView4>"] :=" 29 max"
		ActionInfo_Arr["<LeftCustomView5>"] :="5"
		ActionInfo_Arr["<LeftCustomView6>"] :="6"
		ActionInfo_Arr["<LeftCustomView7>"] :="7"
		ActionInfo_Arr["<LeftCustomView8>"] :="8"
		ActionInfo_Arr["<LeftCustomView9>"] :="9"
		ActionInfo_Arr["<RightCustomView1>"] :=" Right window :  Customize the column view  1"
		ActionInfo_Arr["<RightCustomView2>"] :=" Right window :  Customize the column view  2"
		ActionInfo_Arr["<RightCustomView3>"] :="..."
		ActionInfo_Arr["<RightCustomView4>"] :=" 29 max"
		ActionInfo_Arr["<RightCustomView5>"] :="5"
		ActionInfo_Arr["<RightCustomView6>"] :="6"
		ActionInfo_Arr["<RightCustomView7>"] :="7"
		ActionInfo_Arr["<RightCustomView8>"] :="8"
		ActionInfo_Arr["<RightCustomView9>"] :="9"
		ActionInfo_Arr["<SrcNextCustomView>"] :=" Source window :  Next custom view "
		ActionInfo_Arr["<SrcPrevCustomView>"] :=" Source window :  Previous view "
		ActionInfo_Arr["<TrgNextCustomView>"] :=" Target window :  Next custom view "
		ActionInfo_Arr["<TrgPrevCustomView>"] :=" Target window :  Previous view "
		ActionInfo_Arr["<LeftNextCustomView>"] :=" Left window :  Next custom view "
		ActionInfo_Arr["<LeftPrevCustomView>"] :=" Left window :  Previous view "
		ActionInfo_Arr["<RightNextCustomView>"] :=" Right window :  Next custom view "
		ActionInfo_Arr["<RightPrevCustomView>"] :=" Right window :  Previous view "
		ActionInfo_Arr["<LoadAllOnDemandFields>"] :=" All files are loaded with notes as needed "
		ActionInfo_Arr["<LoadSelOnDemandFields>"] :=" Only selected files are loading notes as needed "
		ActionInfo_Arr["<ContentStopLoadFields>"] :=" Stop background loading notes "
}
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
<ShowHint>:
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
SendPos(3009)
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
