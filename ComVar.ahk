﻿
#Requires Autohotkey v2
;AutoGUI 2.5.8 creator: Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter creator: github.com/mmikeww/AHK-v2-script-converter
;Easy_AutoGUI_for_AHKv2 github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2

myGui := Gui()
ButtonOK := myGui.Add("Button", "x159 y49 w86 h22", "&OK")
ButtonOK.OnEvent("Click", OnEventHandler)
ButtonOK.SetIcon("Shell32.dll", 4)
myGui.OnEvent('Close', (*) => ExitApp())
myGui.Title := "Window"
myGui.Show("w620 h420")

OnEventHandler(*)
{
	ToolTip("Click! This is a sample action.`n"
	. "Active GUI element values include:`n"  
	. "ButtonOK => " ButtonOK.Text "`n", 77, 277)
	SetTimer () => ToolTip(), -3000 ; tooltip timer
}
