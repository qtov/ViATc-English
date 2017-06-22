<TCCOMMAND+>:
	CustomActions("<OpenDriveThis>"," Open the drive list : Side of the side ")
	CustomActions("<OpenDriveThat>"," Open the drive list : The other side ")
	CustomActions("<MoveDirectoryHotlist>"," Move to a regular folder ")
	CustomActions("<CopyDirectoryHotlist>"," Copy to a favorite folder ")
	CustomActions("<GotoPreviousDirOther>"," Back to the other side ")
	CustomActions("<GotoNextDirOther>"," Move on to the other side ")
	;RegisterHotkey("H","o","<OpenDriveThis>")
	;RegisterHotkey("H","O","<OpenDriveThat>")
	RegisterHotkey("fd","<MoveDirectoryHotlist>","TTOTAL_CMD")
	RegisterHotkey("fb","<CopyDirectoryHotlist>","TTOTAL_CMD")
	; copy / Move to the right  f take file the meaning of  filecopy
	RegisterHotkey("fc","<cm_CopyOtherpanel>","TTOTAL_CMD")
	RegisterHotkey("fx","<cm_MoveOnly>","TTOTAL_CMD")
	;ff copy    fz Cut    fv Paste 
	RegisterHotkey("ff","<cm_CopyToClipboard>","TTOTAL_CMD")
	RegisterHotkey("fz","<cm_CutToClipboard>","TTOTAL_CMD")
	RegisterHotkey("fv","<cm_PasteFromClipboard>","TTOTAL_CMD")
	;fb copy  To a list of favorites ，fd Move to a list of favorites 
	RegisterHotkey("fb","<CopyDirectoryHotlist>","TTOTAL_CMD")
	RegisterHotkey("fd","<MoveDirectoryHotlist>","TTOTAL_CMD")
	RegisterHotkey("ft","<cm_SyncChangeDir>","TTOTAL_CMD")
	RegisterHotkey("gh","<GotoPreviousDirOther>","TTOTAL_CMD")
	RegisterHotkey("gl","<GotoNextDirOther>","TTOTAL_CMD")
	RegisterHotkey("<shift>vh","<cm_SwitchIgnoreList>","TTOTAL_CMD")
return

;<OpenDriveThat>: >> Open the drive list : The other side {{{2
<OpenDriveThis>:
	ControlGetFocus,CurrentFocus,AHK_CLASS TTOTAL_CMD
	if CurrentFocus not in TMyListBox2,TMyListBox1
		return
	if CurrentFocus in TMyListBox2
		SendPos(131)
	else
		SendPos(231)
Return

;<OpenDriveThis>: >> Open the drive list : Side of the side {{{2
<OpenDriveThat>:
	ControlGetFocus,CurrentFocus,AHK_CLASS TTOTAL_CMD
	if CurrentFocus not in TMyListBox2,TMyListBox1
		return
	if CurrentFocus in TMyListBox2
		SendPos(231)
	else
		SendPos(131)
Return

;<DirectoryHotlistother>: >> Common folders : The other side {{{2
<DirectoryHotlistother>:
	ControlGetFocus,CurrentFocus,AHK_CLASS TTOTAL_CMD
	if CurrentFocus not in TMyListBox2,TMyListBox1
		return
	if CurrentFocus in TMyListBox2
		otherlist = TMyListBox1
	else
		otherlist = TMyListBox2
	ControlFocus, %otherlist% ,ahk_class TTOTAL_CMD
	SendPos(526)
	SetTimer WaitMenuPop3
return
WaitMenuPop3:
	winget,menupop,,ahk_class #32768
	if menupop
	{
		SetTimer, WaitMenuPop3 ,Off
		SetTimer, WaitMenuOff3
	}
return
WaitMenuOff3:
	winget,menupop,,ahk_class #32768
	if not menupop
	{
		SetTimer,WaitMenuOff3, off
		goto, goonhot
	}
return
goonhot:
ControlFocus, %CurrentFocus% ,ahk_class TTOTAL_CMD
Return

;<CopyDirectoryHotlist>: >> Copy to a favorite folder {{{2
<CopyDirectoryHotlist>:
	ControlGetFocus,CurrentFocus,AHK_CLASS TTOTAL_CMD
	if CurrentFocus not in TMyListBox2,TMyListBox1
		return
	if CurrentFocus in TMyListBox2
		otherlist = TMyListBox1
	else
		otherlist = TMyListBox2
	ControlFocus, %otherlist% ,ahk_class TTOTAL_CMD
	SendPos(526)
	SetTimer WaitMenuPop1
return
WaitMenuPop1:
winget,menupop,,ahk_class #32768
if menupop
	{
		SetTimer, WaitMenuPop1 ,Off
		SetTimer, WaitMenuOff1
	}
return
WaitMenuOff1:
	winget,menupop,,ahk_class #32768
	if not menupop
	{
		SetTimer,WaitMenuOff1, off
		goto, gooncopy
	}
return
gooncopy:
	ControlFocus, %CurrentFocus% ,ahk_class TTOTAL_CMD
	SendPos(3101)
return

;<MoveDirectoryHotlist>: >> Move to a regular folder {{{2
<MoveDirectoryHotlist>:
	If SendPos(0)
		ControlGetFocus,CurrentFocus,AHK_CLASS TTOTAL_CMD
	if CurrentFocus not in TMyListBox2,TMyListBox1
		return
	if CurrentFocus in TMyListBox2
		otherlist = TMyListBox1
	else
		otherlist = TMyListBox2
	ControlFocus, %otherlist% ,ahk_class TTOTAL_CMD
	SendPos(526)
	SetTimer WaitMenuPop2
return
WaitMenuPop2:
	winget,menupop,,ahk_class #32768
	if menupop
	{
		SetTimer, WaitMenuPop2 ,Off
		SetTimer, WaitMenuOff2
	}
return
WaitMenuOff2:
	winget,menupop,,ahk_class #32768
	if not menupop
	{
	SetTimer,WaitMenuOff2, off
	goto, goonmove
	}
return
GoonMove:
	ControlFocus, %CurrentFocus% ,ahk_class TTOTAL_CMD
	SendPos(1005)
return

;<GotoPreviousDirOther>: >> Back to the other side {{{2
<GotoPreviousDirOther>:
	Send {Tab}
	SendPos(570)
	Send {Tab}
Return

;<GotoNextDirOther>: >> Move on to the other side {{{2
<GotoNextDirOther>:
	Send {Tab}
	SendPos(571)
	Send {Tab}
Return
