; VimCore 0.0.2
; 2013-04-10
; By Array ( linxinhong.sky@gmail.com )
#UseHook on
#NoEnv
Init()
{
	Gosub,<Init>
	LoadPlugin()
}
<Init>:
Global Vim_HotkeyList := ""
Global Vim_HotkeyExist := ""
Global Vim_HotkeyTemp := []
Global Vim_HotkeyCount := 0
Global Vim_Mode := True
Global Vim_Repeat := []
Global Vim_Actions := []
Global Vim_Timer := 0
return
;=========================================================
; RegisterHotkey(Key,Action,Class="") {{{2
RegisterHotkey(Key,Action,Class="")
{
	If Not CLASS AND RegExMatch(Key,">[^<]{2}")
	{
		Msgbox % " Not recommended in global hotkeys “" Key "” With a single key , Please re-set "
		Return
	}
	If Not IsVimLabel(Action)
	{
		Msgbox % "1Key " Key " map to Action " Action " Error !"
		Return
	}
	switch := False ; Used to determine whether the saved hotkey was successful 
	for,i,k in ResolveHotkey(Key)
	{
		If SetHotkey(K,"<HotkeyLabel>",Class)
			switch := True
		Else
			Msgbox % "2Key " Key " map to Action " Action " Error !"
	}
	If switch ; If the hotkey is saved successfully ， Save the hotkey body into memory 
	{
		If RegExMatch(HK_Match(Key,Class),"[^\n]*")
			HK_Delete(Key,Class)
		HK_Write(Key,Action,Class)
	}
	If RegExMatch(Action,"^\(.*\)$")
	{
		Info := " run  " . Action
		CustomActions(Action,Info)
	}
	If RegExMatch(Action,"^\{.*\}$")
	{
		Info := " send  " . Action
		CustomActions(Action,Info)
	}
	If RegExMatch(Action,"^\[.*\]$")
	{
		Info := " Macro  " . Action
		CustomActions(Action,Info)
	}
}
; SetHotkey(key,Action,Class="") {{{2
;  Set hotkey ， Returns the result of the setup 
SetHotkey(key,Action,Class="")
{
	If IsHotkey(Key,Class)
		Return True
	Else
	{
		If Strlen(Class) > 0
		{
			Hotkey,IfWinActive,AHK_CLASS %CLASS%
			GroupAdd,Vim_Group_Class,AHK_CLASS %class%
		}
		Else
		{
			Hotkey,IfWinActive
			
		}
		Hotkey,%Key%,%Action%,On,UseErrorLevel
		If ErrorLevel And ( Not RegExMatch(Action,"<HotkeyLabel>") )
		{
			Msgbox % "Key " Key " map to " Action " Error !"
			Return False
		}
		;  in case Action for HotkeyLabel, Then RegisterHotkey() Called 。
		If RegExMatch(Action,"<HotkeyLabel>")
			Vim_HotkeyExist .= A_Tab . Strlen(Class) . "|" . Class . Strlen(Key) . "|" Key . A_Tab
		Return True
	}
}
<HotkeyLabel>:
	HotkeyLabel()
return
; HotkeyLabel() {{{2
HotkeyLabel()
{
	ThisHotkey := GetThisHotkey()
	IfWinActive,AHK_GROUP VIM_Group_Class
	{
		WinGetClass,Class,A
		Key := ResolveHotkey(ThisHotkey)
		If Not IsHotkey(Key.1,Class)
			Class :=
	}
	Else
		Class :=	
	If Not Vim_HotkeyTemp[Class]
		Null := True
	Vim_HotkeyTemp[Class] .= ThisHotkey
	;  Determine whether the current mode is VIM or the text input mode
	;  By custom ThisClass_CheckMode() Function decides 
	;  Such as  TConly.ahk  inner TTOTAL_CMD_CheckMode()
	Action := HK_Match(Vim_HotkeyTemp[Class],Class)
	CheckMode := Class "_CheckMode"
	If ( IsFunc(CheckMode) AND (%CheckMode%()) ) OR (Not Action And Null)
	{
		Send,% TransSendKey(A_Thishotkey)
		Vim_HotkeyTemp[Class] := ""
		Return
	}
	If IsVimLabel(Action)
	{
		Settimer,<TimeOutExecSub>,off
		ExecSub(Action,Vim_HotkeyCount,Class)
		Vim_HotkeyTemp[Class] := ""
		Vim_Timer := 0
		return
	}
	List := Vim_HotkeyTemp[Class] "`n================================`n"
	If Action
	{
		Settimer,<TimeOutExecSub>,50
		;If GroupWarn
		Loop,Parse,Action,%A_tab%
		{
			If A_Loopfield
			{
				T := HK_Read(A_LoopField)
				list .= T.Key " >> " Vim_Actions[T.Action] "`n"
			}
		}
		Tooltip,%list%
		return
	}
	Else
	{
		Vim_HotkeyTemp[Class] := ""
		Tooltip
	}
}
;<TimeOutExecSub>:
<TimeOutExecSub>:
	TimeOutExecSub()
Return
TimeOutExecSub()
{
	Vim_Timer++
	If Vim_Timer > 30
	{
		Settimer,<TimeOutExecSub>,off
		WinGetClass,Class,A
		Action := HK_Match(Vim_HotkeyTemp[Class],Class,False)
		If IsVimLabel(Action)
			ExecSub(Action,Vim_HotkeyCount,Class)
		Vim_HotkeyTemp[Class] := ""
		Vim_Timer := 0
	}
}
; ExecSub(Action,Count=0,Class="") {{{2
ExecSub(Action,Count=0,Class="")
{
	Tooltip
	If Not Class
		WinGetClass,Class,A
	Count := Count ? Count : 1
	If RegExMatch(Action,"^<.*>$")
	{
		If RegExMatch(Action,"^<\d>$")
		{
			Vim_HotkeyCount :=  Vim_HotkeyCount * 10 + SubStr(Action,2,1)
			If Vim_HotkeyCount > 99
				Vim_HotkeyCount := 99
		}
		Else
		{
			Loop % Count
			{
				
				GoSub %Action%
				If Not Vim_HotkeyCount
					Break
			}
			Vim_HotkeyCount := 0
		}
	}
	If RegExMatch(Action,"^\{.*\}$")
	{
		Text := Substr(Action,2,Strlen(Action)-2)
		Loop % Count
			Send,%Text%
	}
	If RegExMatch(action,"^\(.*\)$")
	{
		File := Substr(Action,2,Strlen(Action)-2)
		Run,%File%,,UseErrorLevel,ExecID
		If ErrorLevel = ERROR
		{
			Msgbox  run %File% failure 
			Return
		}
		WinWait,AHK_PID %ExecID%,,3
		WinActivate,AHK_PID %ExecID%
	}
	If RegExMatch(action,"^\[.*\]$")
		Micro(action,class)
	If RegExMatch(Action,"<Repeat>")
		return
	Else
		Vim_Repeat[Class] := Count "|" Action
}
<Repeat>:
	Repeat()
return
; Repeat() {{{2
Repeat()
{
	WinGetClass,Class,A
	RegExMatch(Vim_Repeat[Class],"\d+\|",c)
	Vim_HotkeyCount := SubStr(c,1,Strlen(c)-1)
	RegExMatch(Vim_Repeat[Class],"\|.*",l)
	Action := SubStr(l,2,Strlen(l))
	ExecSub(Action,Vim_HotkeyCount,Class)
}
; Micro(action,class) {{{2
;  Simple macro definition 
Micro(action,class)
{
	If FileExist(VIATC_INI)
	{
		section := Substr(action,2,strlen(action)-2)
		INIRead,m,%VIATC_INI%,%section%
		Loop,Parse,m,"`n"
		{
			If RegExMatch(A_LoopField,"^\d*$")
				Sleep,%A_LoopField%
			a := RegExReplace(A_LoopField,"=\d*$")
			If Not IsVimLabel(a)
				Continue
			c := Substr(A_LoopField,Strlen(a)+2)
			If Not RegExMatch(c,"\d*")
				Continue
			Vim_HotkeyCount := c
			ExecSub(a,c,class)
		}
	}
}
; LoadPlugin() {{{2
;  Load the script ， And modify VIATC
LoadPlugin()
{
	NeedReload := False
	IfExist %A_Workingdir%\Actions
	{
		Loop,%A_Workingdir%\Actions\*.ahk
		{
			Label := "<" RegExReplace(A_LoopFileName,"i)\.ahk") ">"
			If IsVimLabel(Label)
			{
				GoSub,%Label%
				Continue
			}
			Else
			{
				NeedReload := true
				FileAppend, #include Actions\%A_LoopFileName%`n , %A_ScriptName%
			}
		}	
		If NeedReload
			msgbox,4,Plugin, New action added ， Please reboot ！
		IfMsgbox yes
			Reload
	}
}
; CustomActions(Action,Info="") {{{2
;  Add custom Actions Help information 
CustomActions(Action,Info="")
{
	aMatch := "\s" . ToMatch(Action) . "\s"
	If Not RegExMatch(Vim_Actions["All"],aMatch)
	{
		Plugin_Label := RegExReplace(A_ThisLabel,"^<|>$")
		Vim_Actions["All"] .= A_Space . Action . A_Space
		Vim_Actions[Plugin_Label] .= A_Space . Action . A_Space
		Vim_Actions[action] := Info
	}
}
; HotkeyControl(Control) {{{2
;  Enable or disable hotkeys  
HotkeyControl(Control="")
{
	IfWinActive,AHK_GROUP Vim_Group_Class
	{
		WinGetClass,Class,A
		Hotkey,IfWinActive,AHK_CLASS %Class%
	}
	Else
	{
		Hotkey,IfWinActive
		Class := ""
	}
	M := "i)" Strlen(Class) "\|" ToMatch(Class)
	Loop,Parse,Vim_HotkeyExist,%A_Tab%
	{
		If RegExMatch(A_LoopField,M)
		{
			Key := RegExReplace(RegExReplace(A_LoopField,M),"^\d+\|")
			If Control
				Hotkey,%Key%,on ,,UseErrorLevel
			Else
				Hotkey,%Key%,off ,,UseErrorLevel
		}
	}
*/
}
; ToMatch(Key) {{{2
;  Regular expression escapes 
ToMatch(Key)
{
	Key := RegExReplace(Key,"\+|\?|\.|\*|\{|\}|\(|\)|\||\^|\$|\[|\]|\\","\$0")
	Return RegExReplace(Key,"\s","\s")
}
; IsVimHotkey(Key,Class) {{{2
;  Returns whether or not a description is a hotkey 
;  already exists ， return True， Hotkey does not exist ， return False
IsHotkey(Key,Class)
{
	t := Strlen(Class) "|" . Class . Strlen(key) . "|" . Key
	m := "i)\t" . ToMatch(t) . "\t"
	If Vim_HotkeyExist
		Return RegExMatch(Vim_HotkeyExist,m)
	Else
		return False
}
; IsVimLabel(Label) {{{2
;  Returns whether it is available Label
IsVimLabel(Label)
{
	If RegExMatch(Label,"^<.*>$")
		Return IsLabel(Label)
	return RegExMatch(Label,"^[\(\{\[].*[\}\)\]]$")
}
; GetThisHotkey() {{{2
;  Get the current hotkey ， Case sensitive 
GetThisHotkey()
{
	If RegExMatch(A_ThisHotkey,"^[a-z]$")
	{
		GetKeyState,Var,CapsLock,T
		If Var = D
		{
			If RegExMatch(A_ThisHotkey,"i)^(l|r)?shift\s&\s[a-z]$") 
				ThisHotkey := Substr(A_ThisHotkey,0)
			ThisHotkey := "shift & " . A_ThisHotkey
            ;;send capslock  ;added by magicstep
		}
		Else
			ThisHotkey := A_ThisHotkey
	}
	Else
		ThisHotkey := A_ThisHotkey
	Loop
	{
		If RegExMatch(ThisHotkey,"i)(l|r)?(ctrl|alt|win|shift)\s&\s",m)
		{
			ThisHotKey := "<" . RegExReplace(m,"\s&\s",">") . SubStr(ThisHotKey,Strlen(m)+1,1)
			Break
		}
		If RegExMatch(ThisHotKey,"i)^(f\d\d?)|esc|escape|space|tab|enter|bs|del|ins|home|end|pgup|pgdn|up|down|left|right|<|>$",m)
		{
			ThisHotKey := "<" . m . ">"
			Break
		}
		Break
	}
	Return ThisHotKey
}
; TransSendKey(hotkey) {{{2
;  in SendKey Time ， will hotkey Convert to Send Can support the format 
TransSendKey(hotkey)
{
	Loop
	{
		If RegExMatch(Hotkey,"i)^(f\d\d?)|esc|escpa|space|tab|enter|bs|del|ins|home|end|pgup|pgdn|up|down|left|right|!|#|\+|\^|\{|\}$")
		{
			Hotkey := "{" . Hotkey . "}"
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
; ResolveHotkey(KeyList) {{{2
ResolveHotkey(KeyList)
{
	Keys := []
	NewKeyList := []
	n := 1
	Loop
	{
		Pos := RegExMatch(KeyList,"<[^<>]*>",A_Index)
		If Pos
		{
			LoopKey := SubStr(KeyList,1,Pos-1)
			Loop,Parse,LoopKey
			{
				If Asc(A_LoopField) >= 65 And Asc(A_LoopField) <= 90
				{
					Keys[n] := "shift"
					n++
					Keys[n] := Chr(Asc(A_LoopField)+32)
				}
				Else
					Keys[n] := A_LoopField
				n++
			}
			KeyList := SubStr(KeyList,Pos,Strlen(KeyList))
			Pos := RegExMatch(KeyList,">")
			Keys[n] := SubStr(KeyList,2,Pos-2)
			KeyList := SubStr(KeyList,Pos+1,Strlen(KeyList))
			n++
		}
		Else
		{
			Loop,Parse,KeyList
			{
				If Asc(A_LoopField) >= 65 And Asc(A_LoopField) <= 90
				{
					Keys[n] := "shift"
					n++
					Keys[n] := Chr(Asc(A_LoopField)+32)
				}
				Else
					Keys[n] := A_LoopField
				n++
			}
			Break
		}
	}
	n := 1
	For,i,key in Keys
	{
		If RegExMatch(key,"i)(l|r)?(ctrl|shift|win|alt)") 
		{
			List .= Key " & " 
			Continue
		}
		Else
		{
			List .= Key
			NewKeyList[n] := List
			List := 
		}
		n++
	}
	Return NewKeyList
}
; HK_Match(key,class) {{{2
;  Match by class and hotkey 
;  If exactly match ， It is returned action
;  If fuzzy match ， Returns all the matching elements 
;  If there is no match ， return False
HK_Match(Key="",Class="",ALL=True)
{
	; Key When there is a pass ， For inquiries Class under ，Key Whether there is a correspondence Action
	; Key When there is no pass ， For inquiries Class Under all the hot key body 
	; ALL The default is true ， Perform a fuzzy match 
	; ALL For leave ， Make an exact match 
	If Strlen(Key) > 0
	{
		;  Prevents uppercase characters from appearing 
		Loop,Parse,Key
		{
			If Asc(A_LoopField) >= 65 And Asc(A_LoopField) <= 90
				m .= "<shift>" . Chr(Asc(A_LoopField)+32)
			Else
				m .= A_LoopField
		}
		Key := m
		;  Fuzzy match , Return all possible 
		s := Vim_HotkeyList
		m := 
		idx := 0
		Loop
		{
			Match := "i)\t" . Strlen(Class) . "\|" . ToMatch(Class) . "\d+\|" . ToMatch(Key) . "[^\s]*\d+\|[<\(\{\[][^\t]*[>\)\}\]]\t" 
			Pos := RegExMatch(s,Match,n)
			If Pos
			{
				m .= n
				s := SubStr(s,Pos+strlen(n),strlen(s))
				idx++
			}
			Else
				Break
		}
		If ( idx > 1 ) AND ALL
			Return m
		Else
		{	
			;  Complete match 
			Match := "i)\t" . Strlen(Class) . "\|" . ToMatch(Class) . Strlen(key) . "\|" . ToMatch(Key) . "[^\s]*\d+\|[<\(\{\[][^\t]*[>\)\}\]]\t" 
			Pos := RegExMatch(Vim_HotkeyList,Match)
			If Pos
			{
				T := HK_Read(SubStr(Vim_HotkeyList,Pos,Strlen(Vim_HotkeyList)))
				Return T.Action
			}
			Else
				Return m
		}
	}
	Else
	{
		s := Vim_HotkeyList
		m := 
		Loop
		{
			Match := "i)\t" . Strlen(Class) . "\|" . ToMatch(Class) . "[^\t]*\t" 
			Pos := RegExMatch(s,Match,n)
			If Pos
			{
				m .= n
				s := SubStr(s,Pos+strlen(n),strlen(s))
			}
			Else
				Break
		}
		return m
	}
}
; HK_write(Key,Action,Class="") {{{2
;  Add a new hotkey body 
HK_write(Key,Action,Class="")
{
	;  data structure  : " 10|TTOTAL_CMD7|<lwin>e6|<test> "
	;  Left and right with a space 
	;  The first number is added |, 10|  description CLASS Have 10 Bit long ， which is TTOTAL_CMD
	;  The second number is added |, 7|  description Key Have 7 Bit long ， which is <lwin>e
	;  The third number is added |, 6|  description Action Have 6 Bit long ， which is <test>
	If RegExMatch(Key,"\s|\t")
		return
	Else
	{
		Loop,Parse,Key
		{
			If Asc(A_LoopField) >= 65 And Asc(A_LoopField) <= 90
				m .= "<shift>" . Chr(Asc(A_LoopField)+32)
			Else
				m .= A_LoopField
		}
		Key := m
	}
	If Not IsVimLabel(Action)
		return
	Vim_HotkeyList .= A_Tab . Strlen(Class) . "|" Class . Strlen(Key) . "|" . Key . Strlen(Action) . "|" . Action . A_Tab
}
; HK_Read(string) {{{2
;  Resolve hotkey data for the corresponding class 、 Hotkey 、 Action and other information 
;  Return one Object, For example : obj := HK_Read("10|TTOTAL_CMD7|<lwin>e6|<test>")
; msgbox % obj.class => TTOTAL_CMD
; msgbox % obj.key => <lwin>e
; msgbox % obj.action => <test>
HK_Read(string)
{
	If Not String
		Return
	T := []
	Pos1 := RegExMatch(string,"\d*\|",len)
	Pos1 += Strlen(Len)
	Len1 := SubStr(len,1,Strlen(len)-1)
	If Pos1
		T.Class := SubStr(string,Pos1,len1)
;======================================================
	String2 := SubStr(string,Pos1+Len1,Strlen(string))
;======================================================
	Pos2 := RegExMatch(string2,"\d*\|",len)
	Pos2 += Strlen(Len)
	Len2 := SubStr(len,1,Strlen(len)-1)
	If Pos2
		T.Key := SubStr(string2,Pos2,len2)
;======================================================
	String3 := SubStr(string2,Pos2+Len2,Strlen(string2))
;======================================================
	Pos3 := RegExMatch(string3,"\d*\|",len)
	Pos3 += Strlen(Len)
	Len3 := SubStr(len,1,Strlen(len)-1)
	If Pos3
		T.Action := SubStr(string3,Pos3,len3)
	return T
}
; HK_Delete(Key,Class) {{{2
;  delete key with class The corresponding hotkey 
HK_Delete(Key,Class)
{
	Action := HK_Match(Key,Class)
	Match := "i)\t" . Strlen(Class) . "\|" . ToMatch(Class) . Strlen(key) . "\|" . ToMatch(Key) . Strlen(Action) . "\|" . ToMatch(Action)
	Vim_HotkeyList := RegExReplace(Vim_HotkeyList,Match)
}
