; All programs are generic
<General>:
    CustomActions ("<1>","Count prefix 1")
    CustomActions ("<2>","Count prefix 2")
    CustomActions ("<3>","Count prefix 3")
    CustomActions ("<4>","Count prefix 4")
    CustomActions ("<5>","Count prefix 5")
    CustomActions ("<6>","Count prefix 6")
    CustomActions ("<7>","Count prefix 7")
    CustomActions ("<8>","Count prefix 8")
    CustomActions ("<9>","Count prefix 9")
    CustomActions ("<0>","Count prefix 0")
    CustomActions ("<left>","Move [Count] times to the left")
    CustomActions ("<Right>","Move [Count] times to the right")
    CustomActions ("<Down>","Move down [Count] times")
    CustomActions ("<Up>","Move up [Count] times")
    CustomActions ("<AlwayOnTop>","Set Window Overrides")
    CustomActions ("<TransParent>","Set Window Transparency")
    CustomActions ("<Repeat>","repeat the last action")
    CustomActions ("<SaveClipBoard>","Save Clipboard Data")
    CustomActions ("<ReturnClipBoard>","Return saved data to clipboard")
return
<1>:
return
<2>:
return
<3>:
return
<4>:
return
<5>:
return
<6>:
return
<7>:
return
<8>:
return
<9>:
return
<0>:
return
<Left>:
	Send,{left}
return
<Right>:
	Send,{Right}
return
<Down>:
	Send,{Down}
return
<Up>:
	Send,{Up}
return
<Insert_Mode>:
	WinGetClass,Class,A
		Vim_HotKeyTemp[Class] := ""
	HotkeyControl(False)
return
<Normal_Mode>:
	HotkeyControl(True)
	WinGetClass,Class,A
		Vim_HotKeyTemp[Class] := ""
	Vim_HotKeyCount := 0
	Tooltip
	Send,{%A_Thishotkey%}
return
; <AlwayOnTop> {{{1
<AlwayOnTop>:
		AlwayOnTop()
Return
AlwayOnTop()
{
	win :=  WinExist(A)
	WinGet,ExStyle,ExStyle,ahk_id %win%
	If (ExStyle & 0x8)
   		WinSet,AlwaysOnTop,off,ahk_id %win%
	else
   		WinSet,AlwaysOnTop,on,ahk_id %win%
}
; <TransParent> {{{1
<TransParent>:
		TransParent()
Return
TransParent()
{
	win :=  WinExist(A)
	WinGet,TranspVar,Transparent,ahk_id %win%
	If Not TranspVar ;the first general will get a null value
	{
		WinSet,Transparent,220,ahk_id %win%
		return
	}
	If TranspVar <> 255 
	{
		WinSet,Transparent,255,ahk_id %win%
	}
	Else
	{
		TranspVar:= 220
		WinSet,Transparent,%TranspVar%,ahk_id %win%
	}
}
<SaveClipBoard>:
	ClipboardSaved := ClipboardALL
return
<ReturnClipBoard>:
	Sleep,100
	Clipboard := ClipboardSaved
	ClipboardSaved := ""
return
<Reload>:
	Reload
return
