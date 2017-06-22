#SingleInstance
Menu, Tray, Icon, viatc.ico

Setkeydelay,-1 
SetControlDelay,-1
Detecthiddenwindows,on
Coordmode,Menu,Window
;=======================================================
Init()
Global VIATC_INI := GetPath_VIATC_INI()
Global TCEXE := GetPath_TCEXE()
Global TCINI := GetPath_TCINI()
Vim_HotkeyList .= " <> "
ReadConfigToRegHK()
;Msgbox % Substr(Vim_HotkeyList,RegExMatch(Vim_HotkeyList,"\s<>\s"))
Traytip,,ViATc-0.6.1en is running,,17
Sleep,1800
Traytip
;RegisterHotkey("zf","<TCFullScreen>","TTOTAL_CMD")
;RegisterHotkey("zl","<TCLite>","TTOTAL_CMD")
;RegisterHotkey("zq","<QuitTC>","TTOTAL_CMD")
;RegisterHotkey("za","<ReloadTC>","TTOTAL_CMD")
; ==========================================
; Esc hotkey must be mapped in the following form
; Ensure Esc functions are not affected hotkeycontrol
; If you do not like this map, you will fail to return to normal mode
; ==========================================
return
; ===================================================
; Read the configuration and register the hotkey
ReadConfigToRegHK()
{
	Config_section := VIATC_IniRead()
	Loop,Parse,Config_section,`n
	{
		; Global is a global domain, registered global hotkey
		If RegExMatch(A_LoopField,"i)^Global$")
		{
			; When Global, Class empty
			CLASS :=
			; Acquiring Global hotkey list
			KeyList := VIATC_IniRead("Global")
			Loop,Parse,KeyList,`n
			{
				; Hot key acquisition portion of INI
				Key := RegExReplace(A_LoopField,"=[<\(\{\[].*[\]\}\)>]$")
				; Get hot key corresponding Action
				Action := SubStr(A_LoopField,Strlen(Key)+2,Strlen(A_LoopField))
				; Registered hotkey
				If RegExMatch(Key,"^\$.*")
				{
					Key := SubStr(Key,2)
					If RegExMatch(Key,"^[^\$].*")
					{
						Key := ResolveHotkey(Key)
						SetHotkey(Key.1,Action,CLASS)
						Continue
					}
				}
				RegisterHotkey(Key,Action,CLASS)
			}
		}
		; AHKC beginning of all domains, corresponding to the hot key to register the CLASS
		If RegExMatch(A_LoopField,"^AHKC_")
		{
			; Get the class
			AHKC := A_LoopField ; obtaining AHKC_XXXXX class, in this case for the outer loop LoopField
			; Get CLASS class from the AHKC
			CLASS := SubStr(AHKC,6,Strlen(AHKC))
			; Get a list of hot key corresponding to AHKC
			KeyList := VIATC_IniRead(AHKC)
			Loop,Parse,KeyList,`n
			{
				; Hot key acquisition portion of INI
				Key := RegExReplace(A_LoopField,"=[\[<\(\{].*[\]\}\)>]$")
				; Get hot key corresponding Action
				Action := SubStr(A_LoopField,Strlen(Key)+2,Strlen(A_LoopField))
				; Registered hotkey
				If RegExMatch(Key,"^\$.*")
				{
					Key := SubStr(Key,2)
					If RegExMatch(Key,"^[^\$].*")
					{
						Key := ResolveHotkey(Key)
						SetHotkey(Key.1,Action,CLASS)
						Continue
					}
				}
				RegisterHotkey(Key,Action,CLASS)
			}
		}
	}
}

; Read ini file, if the item is read VIATC option is created in less time reading
VIATC_IniRead(section="",key="")
{
	IniRead,Value,%VIATC_INI%,%section%,%key%
	If RegExMatch(Value,"ERROR")
	{
		Value := Options(key)
		If Not RegExMatch(Value,"^ERROR$")
		{
			IniWrite,%Value%,%VIATC_INI%,%section%,%key%
		}
		Else
			Value := ""
	}
	Return Value
}
; Add INI
VIATC_IniWrite(section,key,value)
{
	IniWrite,%Value%,%VIATC_INI%,%section%,%key%
	Return ErrorLevel
}
; Delete INI
VIATC_IniDelete(section,key)
{
	IniDelete,%VIATC_INI%,%section%,%key%
	Return ErrorLevel
}
; Return options and their default values to the array, non-option returns ERROR
Options(opt)
{
	If RegExMatch(opt,"^TrayIcon$")
		Return True
	If RegExMatch(opt,"^VimMode$")
		Return True
	If RegExMatch(opt,"^TransParent$")
		Return False
	If RegExMatch(opt,"^Startup$")
		Return False
	If RegExMatch(opt,"^GroupWarn$")
		Return True
	If RegExMatch(opt,"^MaxCount$")
		Return 99
	If RegExMatch(opt,"^Toggle$")
		Return "<lwin>e"
	If RegExMatch(opt,"^TranspVar$")
		Return 220
	If RegExMatch(opt,"^SearchEng$")
		Return "http://www.google.com/?#q={%1}"
	Return "ERROR"
}
; Obtaining VIATC profile path
GetPath_VIATC_INI()
{
	NeedRegWrite := False
	Loop ; Loop here is useless, just used when a certain condition is satisfied, stop using the Find
	{
	; Looks in the current directory
		gPath := A_ScriptDir "\viatc.ini"
		If FileExist(gPath)
			Break
	; Look in the registry VIATC
		RegRead,gPath,HKEY_CURRENT_USER,Software\ViATc,ViATcIni
			If FileExist(gPath) 
				Break
			Else
				NeedRegWrite := True
	; Look for the TC directory
		TCEXE := GetPath_TCEXE()
		Splitpath,TCEXE,,TCDir
		gPath := TCDir "\viatc.ini"
		If FileExist(gPath)
			break
	; Use GUI look
		FileSelectFile,gPath,3,,Find the TC configuration file(wincmd.ini),*.ini
		If ErrorLevel
		{
			Msgbox 查找ViATc.ini文件失败
			return
		}
	; To save the registry VIATC
		break
	}
	If FileExist(gPath)
	{
		If NeedRegWrite
			Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,ViATcINI,%gPath%
		return gPath
	}
}
; Obtaining wincmd.ini profile path
GetPath_TCINI()
{
	NeedRegWrite := False
	Loop ;Loop here is useless, just used when a certain condition is satisfied, stop using the Find
	{
	; Find VIATC registry value
		RegRead,gPath,HKEY_CURRENT_USER,Software\ViATc,IniFileName
		If FileExist(gPath) 
			Break
		Else
			NeedRegWrite := True
	; Looks in the current directory
		gPath := A_ScriptDir "\wincmd.ini"
		If FileExist(gPath)
			Break
		TCEXE := GetPath_TCEXE()
		Splitpath,TCEXE,,TCDir
		gPath := TCDir "\wincmd.ini"
		If FileExist(gPath)
			break
	; Use GUI look
		FileSelectFile,gPath,3,,Find the TC configuration file(wincmd.ini),*.ini
		If ErrorLevel
		{
			Msgbox Failed to find TC configuration file: wincmd.ini
			return
		}
		break
	}
	; Save value in the registry to VIATC
	If FileExist(gPath)
	{
		If NeedRegWrite
			Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,IniFileName,%gPath%
		return gPath
	}
}
; Get Totalcmd.exe file path
GetPath_TCEXE()
{
	NeedRegWrite := False ; the need to write registry
	Loop ; Loop here is useless, just used when a certain condition is satisfied, stop using the Find
	{
		; Find VIATC registry value
		RegRead,gPath,HKEY_CURRENT_USER,Software\ViATc,InstallDir
		If FileExist(gPath) 
			Break
		Else
			NeedRegWrite := True
		; Use the process to find
		Process,Exist,TOTALCMD.exe
		PID := ErrorLevel
		WinGet,gPath,ProcessPath,AHK_PID %PID%
		If gPath
			Break
		; Looks in the current directory
		gPath := A_ScriptDir "\totalcmd.exe"
		If FileExist(gPath)
			Break
		gPath := A_ScriptDir "\totalcmd64.exe"
		If FileExist(gPath)
			Break
		; Use GUI look
		FileSelectFile,gPath,3,,Find TOTALCMD.exe or TOTALCMD64.exe,*.exe
		If ErrorLevel
		{
			Msgbox Find Totalcmd.exe failed
			return
		}
		Break
	}
	If FileExist(gPath)
	{
		If NeedRegWrite
			Regwrite,REG_SZ,HKEY_CURRENT_USER,Software\VIATC,InstallDir,%gPath%
		Return gPath
	}
	; Save value in the registry to VIATC
}
EmptyMem()
{
	return
}
; ===================================================
#include vimcore.0.2.1.ahk
; #include Actions\Debug.ahk
#include Actions\General.ahk
#include Actions\TCCOMMAND.ahk
#include Actions\TConly.ahk
#include Actions\MSWord.ahk
#include Actions\temp.ahk
#include Actions\Tools.ahk
#include Actions\TCCOMMAND+.ahk
#include Actions\QDir.ahk
