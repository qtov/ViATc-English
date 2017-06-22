; Can call API at the end of this file
; Here must be with a plug-in file name consistent with the label, Vimcore load plug-in, it will run
<Temp>:
; Generally used to define global variables
Global Test
; Add a description of the corresponding plug-in for help in the action description
CustomActions ("<TempAction1>", "Example 1")
; You can also add other pre-run functions, such as TConly Lane, is the pre-loaded file template function menu
; Can refer to TConly.ahk
Return

; %Class% _CheckMode ()
; Vimcore operating mode distinction, that is, when is the normal mode, when is the editing mode
; Can be achieved by customizing the CheckMode () function
; Vimcore in the analysis of each hotkey, will use WinGetClass to get the current window class Class
; Then call% Class% _CheckMode (), as in TC will call TTOTAL_CMD_CheckMode ()
; If the function returns true, it is equivalent to edit mode. If the function returns False, the normal mode

    ; The following to control notepad.exe as an example
Notepad_CheckMode()
{
    ControlGetFocus, ctrl, AHK_CLASS NotePad
        If RegExMatch (ctrl, "Edit")
           Return True
        Return False
}

; Each plug-in can take at least one action, the action in the form of labels to describe
; The following <TempAction1> tag is an action in Temp.ahk
<TempAction1>:
TempAction1()
    Return
    ; It is recommended to call the function through the tag, which can reduce the impact of global variables between plugins developed by different people
TempAction1()
{
    Msgbox % "Hello World"
}
;VimCore API
; ================================================= ======

; RegisterHotkey (Scope, Key, Action, ViClass)
; Registered hotkey function, the definition of the hotkey will have a mode of control
; ------------------------------------------------- ------

; Scope is represented by S globally, and H is represented only in the window of the ViClass class
; Key hotkey, can be a single key, key combination, case-sensitive
; Single key a b c 1, <ctrl> a <alt> b etc ...
; Key combination ga oK JK J <ctrl> j <lwin> k etc ...
; Action, hotkey corresponding to the action, generally in this form: "<TempAcion1>"
; ViClass window class, you can view the corresponding window class through AHK Windows Spy, if the scope specified when the H, the registered hotkey will only ViClass variable in the corresponding window class

; ================================================= ======

; SetHotKey (sKey, sAction, Class)
; Set the hotkey, and RegisterHotkey () to distinguish, through the function of the hotkey is not affected by the model
; Generally used to set Esc, such as SetHotkey ("Escape", "<Esc_TC>", "TTOTAL_CMD")

; ------------------------------------------------- ------
; SKey hotkey, can only be a single key, and does not support <ctrl> <alt> <shift> <win>
; Can only be supported by AHK hotkey variants
; SAction action, hotkey corresponding action.
; Class defines the window class in which the hotkey of the SetHotkey () function takes effect

; ================================================= ======
