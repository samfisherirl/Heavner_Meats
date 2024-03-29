; Place in folder where you'd like py venv or installers
#SingleInstance Force
Persistent
#Requires AutoHotkey v2
#Warn all, Off
SetKeyDelay 5, 5, "Play"

; Tray definition =================================================================
; Tray.Delete() python -m compileall .
pathStorage := []
obj := configRead()
handleConfigJson(obj)
env := VGUI()
SetWindowTheme(env.myGUI)

;The script defines a class named "VGUI" that creates a GUI and adds buttons to it. Each button is assigned an "OnEvent" method that is triggered when the user clicks on it. These methods contain commands to launch virtual environments and run the different packaging tools.
class VGUI
{
	__New()
	{
		global pathStorage
		SplitPath(A_AppData, , &AppData)
		this.MyGui := Gui(, "Launcher")
		SetWindowAttribute(this.MyGui)

		this.MyGui.OnEvent('Close', (*) => ExitApp())
		this.myGUI.SetFont("cWhite")
		Grp1 := this.MyGUI.AddGroupBox("x7 y4 w267 h93", ".venv")
		this.AppData := AppData
		this.main := false
		this.pip := ""
		this.pypath := ""
		this.clipboard := ""
		this.venv_packages := ""
		this.PID := false
		this.activate_bat := false
		this.jdata := ""
		this.launch := this.MyGUI.AddButton("x19 y20 w121 h23", "&Launch existing venv").OnEvent("Click", this.launch_click)
		; creates a new VENV environment at this location
		; checks if autopytoexe is installed, checks if cmd and venv open, otherwise opens venv and writes a standard  autopytoexe GUI
		this.three11 := this.MyGUI.AddButton("x152 y56 w101 h23", "Create .venv").OnEvent("Click", this.three11_create)
		DDL := []
		for i in pathStorage {
			DDL.Push(i.FileName)
		}
		DDL.Push(["", ""])
		this.dropdown := this.MyGUI.Add("DropDownList", "x152 y22 w100 Choose2", DDL)

		; checks if CXFreeze is installed, checks if cmd and venv open, otherwise opens venv and writes a CXFreeze quickstart
		this.compileClick := this.MyGUI.AddButton("x19 y56 w121 h23", "Add/Del Python Path").OnEvent("Click", passBrowseGUI)
		SplitPath(pathStorage[1].filePath, , &d)
		SplitPath(d, , &Dir)
		this.pythonFolder := d
		this.pythonsitePackages := Dir "\Lib\site-packages"
		; prints standard pyinstaller script
		this.Grp2 := this.MyGUI.AddGroupBox("x7 y98 w267 h190", "Installers")
		;divider
		this.Nuitka := this.MyGUI.AddButton("x19 y127 w101 h23", "&Nuitka").OnEvent("Click", this.Nuitka_Click)
		; checks if nuitka is installed, checks if cmd and venv open, otherwise opens venv and writes a standard nuitka installer
		this.autopytoexe := this.MyGUI.AddButton("x152 y127 w101 h23", "&AutoPytoEXE").OnEvent("Click", this.autopytoexe_Click)
		; checks if autopytoexe is installed, checks if cmd and venv open, otherwise opens venv and writes a standard  autopytoexe GUI requirements_Click
		this.requirements := this.MyGUI.Add("Button", "x19 y162 w101 h23", "Requirements.txt").OnEvent("Click", this.requirements_Click)
		; checks if CXFreeze is installed, checks if cmd and venv open, otherwise opens venv and writes a CXFreeze quickstart
		this.PyInstaller := this.MyGUI.AddButton("x152 y162 w101 h23", "PyInstaller").OnEvent("Click", this.PyInstaller_Click)
		; prints standard pyinstaller script
		this.input := this.MyGUI.Add("Edit", "r1 vMyEdit y202 x19 w240", A_ScriptDIr)
		this.input.OnEvent("Change", this.setRun)
		this.input.Value := A_ScriptDir
		this.browse := this.MyGUI.AddButton("x19 y232 w101 h23", "&Browse for Py file").OnEvent("Click", this.browse_click)
		this.run := this.MyGUI.AddButton("x152 y232 w101 h23", "&Run py file").OnEvent("Click", this.run_click)
		this.jpath := A_ScriptDir "\venv\config_venv.json"
		this.MyGUI.Add("GroupBox", "x282 y7 w235 h282", "Guide")
		this.MyGUI.Add("Text", "x294 y25 w195 h256", "1. Locate python.exe with 'add python path'. `n`n2.Create venv or 'virtual enviroment'. `n`n3. The app should automatically activate the (venv) after creating, `n`nfor future activating just keep a copy of this app in the folder of py app. Run exe and click 'Launch'. `n`nInstead of 'pip install (x)' use 'python -m pip install --upgrade (x)`n`nLook for 'requirements.txt' and click requirements button, but it should handle for you. ")
		this.findConfig()
		this.setDropdown()
		darkMode(this.MyGUI)
		this.dropdown.choose(1)
		this.MyGui.Show("w559 h380")
		;ControlFocus this.DropDown, this.mygui
		Send "{Down}"
	}
	findConfig() {
		if FileExist(A_ScriptDir "\venv\config_venv.json") {
			json := FileRead(A_ScriptDir "\venv\config_venv.json")
			if json != "" {
				jdata := Jsons.Load(&json)
				this.main := jdata["main"]
				this.input.Value := this.main
			}
		}
		if not this.main {
			this.findMAINorLatestPy()
			if !DirExist(A_ScriptDir "\venv") {
				DirCreate A_ScriptDir "\venv"
			}
			if this.main != false {
				this.jdata := Map("main", this.main)
				x := FileOpen(this.jpath, "w")
				x.Write(Jsons.Dump(this.jdata))
				x.Close()
			}
		}
	}

	setDropdown() {
		global pathStorage
		this.dropdown.Delete()
		for i in pathStorage
		{
			if Trim(i.fileName) != "" {
				this.dropdown.Add([i.fileName])
			}
		}
		this.dropdown.Opt("Choose1")
	}
	setRun(*) {
		Sleep(1)
	}
	launch_click(*) {
		;Launch VENV in command window by finding nearest activate.bat file below directory
		env.isCMDopen_and_isVENVlaunched()
		if (env.PID = 0) {
			env.openCommandPrompt()
		}
		env.findNearest_venv_Folder()
		env.activator()
	}
	BrowsePathHandler(*) {
		env.isCMDopen_and_isVENVlaunched()
		env.sendEnter()
		env.WinActivate()
		Selection := DirSelect(A_ScriptDir)
		if Selection {

			env.ControlSendTextToCMD("cd `"" Selection "`"")
			env.sendEnter()
			env.ControlSendTextToCMD("python -m compileall .")
			env.sendEnter()
		}
	}
	findMAINorLatestPy() {
		; looks for "activate.bat" file
		Loop Files, A_ScriptDir "\*.py" ; Recurse into subfolders.
		{
			if ("main.py" = A_LoopFileName) {
				this.main := A_LoopFilePath
				return
			}
			else {
				this.main := A_LoopFilePath
			}
		}
		; couldnt find main, now look for latest py file
		list_of_files := []
		Loop Files, A_ScriptDir "\*.py", "R"  ; Recurse into subfolders.
		{
			;FileGetTime
			list_of_files.Push(A_LoopFilePath)
		}
		try {
			latest_file := {
				path: list_of_files[1],
				modified: FileGetTime(list_of_files[1])
			}
			for file in list_of_files {
				if latest_file.modified < FileGetTime(file) {
					latest_file.path := list_of_files[A_Index]
					latest_file.modified := FileGetTime(file)
				}
			}
			this.main := latest_file.path
		}
	}
	create_click(*) {
		env.isCMDopen_and_isVENVlaunched(1)
		;Creates and Launches VENV in command window, in folder with this file
		env.pythonFolder := env.AppData "\Local\Programs\Python\Python310"
		env.ControlSendTextToCMD("`"" env.pythonFolder "\python.exe`" -m venv venv")
		env.create_env()
	}
	three11_create(*) {
		global pathStorage
		env.isCMDopen_and_isVENVlaunched(1)
		;Creates and Launches VENV in command window, in folder with this file
		for obj in pathStorage
		{
			if InStr(obj.filePath, env.dropdown.Value) {
				SplitPath(obj.filePath, , &Dir)
				env.pythonFolder := Dir
			}
		}
		env.ControlSendTextToCMD("`"" env.pythonFolder "\python.exe`" -m venv venv")
		env.create_env()
	}


	create_env() {
		env.sendEnter()
		env.WinActivate()  ; Show the result.
		sleep(1000)
		loop 15 {
			if (env.activate_bat == 0) {
				sleep(1000)
				env.findNearest_venv_Folder()
			}
			else {
				break
			}
		}
		env.pypath := A_ScriptDir "\venv\Scripts\python.exe"
		env.activator()
		env.ControlSendTextToCMD("`"" env.pypath "`" -m pip install --upgrade pip")
		env.sendEnter()
		r := false
		Loop Files, A_ScriptDir "\*.txt", "R"  ; Recurse into subfolders.
		{
			if ("requirements.txt" = A_LoopFileName) {
				env.ControlSendTextToCMD("`"" env.pypath "`" -m pip install -r `"" A_LoopFilePath "`"")
				env.sendEnter()
				r := true
				break
			} else {
				Loop Files, A_ScriptDir "\*.py", "R" {
					if InStr(A_LoopFileName, "main") {
						break
						; add main.py pipreqs maker
					}
				}
			}
		}
		if not r {
			installfromImports()
		}
		;env.jdata := Map("main", env.main)
		;x := FileOpen(env.jpath, "w")
		;x.Write(Jsons.Dump(env.jdata))
		;x.Close()
	}
	Nuitka_click(*) {
		; checks if nuitka is installed, opens venv and writes a standard nuitka installer
		env.isCMDopen_and_isVENVlaunched()
		env.installer("nuitka")
		env.installer("packaging")
		env.installer("setuptools")
		env.sendEnter()
		env.findNearest_venv_Folder()
		env.WinActivate()
		sleep(500)
		Result := MsgBox("onefile? (Yes)", , "YesNo")
		if Result = "Yes"
			env.ControlSendTextToCMD("`"" env.pip "`" -m nuitka --onefile --windows-icon-from-ico=C:\Users\Sam\Documents\icons\Python.ico `"" env.input.value "`"")
		else
			env.ControlSendTextToCMD("`"" env.pip "`" -m nuitka --standalone --windows-icon-from-ico=C:\Users\Sam\Documents\icons\Python.ico `"" env.input.value "`"")

	}
	autopytoexe_Click(*) {
		; checks if autopytoexe is installed, opens venv and runs the easy autopytoexe GUI
		env.isCMDopen_and_isVENVlaunched()
		env.installer("auto-py-to-exe")
		env.findNearest_venv_Folder()
		env.WinActivate()
		sleep(500)
		env.WinActivate()
		env.ControlSendTextToCMD("auto-py-to-exe")
		env.sendEnter()
		env.WinActivate()
	}
	installer(txt) {
		env.ControlSendTextToCMD("`"" env.pip "`" install -U " txt)
		env.sendEnter()
	}
	requirements_Click(*) {
		; checks if CXFreeze is installed, opens venv and runs the  CXFreeze quickstart
		env.isCMDopen_and_isVENVlaunched()
		; Send the text to the inactive Notepad edit control.
		; The third parameter is omitted so the last found window is used.
		env.findNearest_venv_Folder()
		env.WinActivate()
		env.installer("pipreqs")
		env.ControlSendTextToCMD("pipreqs .")
		env.sendEnter()
		env.WinActivate()
		sleep(500)
	}
	PyInstaller_Click(*) {
		global exeName
		; prints standard pyinstaller script
		env.isCMDopen_and_isVENVlaunched()
		env.installer("packaging")
		env.installer("setuptools")
		env.installer("pyinstaller")
		fileselected := FileSelect(1, A_ScriptDir, "File Select", "`"" env.pip "`" (*.py)")
		; Send the text to the inactive Notepad edit control.
		; The third parameter is omitted so the last found window is used.
		SplitPath(fileselected, &Dir)
		x := MsgBox("Onefile?", "Onefile(y) or standalone(n)?", "8228")
		if (x == "Yes") {
			x := " --onefile "
		}
		else if (x == "No") {
			x := " --onedir "
		}
		y := MsgBox("Console?", "Console(y) or GUI(n)?", "8228")
		if (y == "Yes") {
			y := "--console"
		}
		else if (y == "No") {
			y := "--windowed"
		}
		IB := InputBox("Enter Name for Exe.", "Exe", "w440 h280")
		if IB.Result = "Cancel"
			exeName := ""
		else
			exeName := "--name `"" IB.Value "`" "
		env.ControlSendTextToCMD("pyinstaller --noconfirm " exeName x y " --clean --paths `"" env.venv_packages "`" `"" fileselected "`"")
		env.WinActivate()
		FileAppend("pyinstaller --noconfirm " exeName x y " --clean --paths `"" env.venv_packages "`" `"" fileselected "`"", A_ScriptDir "\setup.py")
	}

	browse_click(*) {
		SelectedFile := FileSelect(3, A_ScriptDir, "Open a file", "`"" env.pip "`" File (*.py; *.py)")
		if SelectedFile {
			env.input.value := selectedFile
			env.main := selectedFile
			env.jdata := Map("main", env.main)
			FileOpen(env.jpath, "w").Write(Jsons.Dump(env.jdata))
		}
	}


	run_click(*) {
		if not (env.activate_bat) {
			env.launch_click()
		}
		if (env.main) {
			env.ControlSendTextToCMD("`"" env.pypath "`" `"" env.input.value "`" ")
			env.sendEnter()
			return
		}
		SelectedFile := FileSelect(3, , "Open a file", "`"" env.pypath "`" File (*.py; *.py)")
		if SelectedFile {
			env.input.value := selectedFile
			env.ControlSendTextToCMD("`"" env.main "`" " selectedFile)
			env.sendEnter()
		}

	}

	check_inputfield() {
		if env.input.value != A_ScriptDir {

		}
	}
	parseCFG(path) {
		try {
			z := FileRead(path)
			Loop Parse, z, "`n" "`r" {
				if InStr(A_LoopField, "executable") {
					p := StrSplit(A_LoopField, "=")[2]
					p := Trim(p)
					SplitPath(p, , &Dir)
					return Dir
				}
			}
		} catch as e
		{

		}
	}

	findNearest_venv_Folder() {
		; looks for "activate.bat" file
		v := A_ScriptDir "\venv"
		if (env.activate_bat == 0) {
			if direxist(v) && FileExist(v "\Scripts\activate.bat") {

				env.activate_bat := v "\Scripts\activate.bat"
				SplitPath(v "\Scripts\activate.bat", , &OutDir)
				SplitPath(OutDir, , &Dir)
				env.venv_packages := v . "\Lib\site-packages"
				try {
					env.pythonFolder := env.parseCFG(v . "\pyvenv.cfg")
				} catch {
					Sleep(1)
				}
				env.assignVenv(v)
			}
			else {
				Loop Files, A_ScriptDir "\*.*", "R"  ; Recurse into subfolders.
				{
					if ("activate.bat" = A_LoopFileName) {

						env.activate_bat := A_LoopFilePath
						SplitPath(A_LoopFilePath, , &Dir)
						env.pip := Dir . "\pip3.exe"
						env.pypath := Dir . "\python.exe"
						SplitPath(Dir, , &d)
						env.venv_packages := d "\Lib\site-packages"
						env.pythonFolder := env.parseCFG(d "\pyvenv.cfg")
						env.assignVenv(Dir)
						break
					}
				} } }
		else {
			return env.activate_bat
		}
	}

	assignVenv(folder) {
		env.pythonFolder := env.parseCFG(folder "\pyvenv.cfg")
		env.activate_bat := folder "\Scripts\activate.bat"
		SplitPath(env.activate_bat, , &Dir)
		env.pip := Dir . "\pip.exe"
		env.pypath := Dir . "\python.exe"
		env.venv_packages := folder "\Lib\site-packages"
	}

	isCMDopen_and_isVENVlaunched(Mode := 0) {
		if (env.PID == 0) {
			env.openCommandPrompt()
		}
		else if not WinExist("ahk_pid " env.PID) {
			env.openCommandPrompt()
		}
		;The "isCMDopen_and_isVENVlaunched" method is used to check whether the command prompt window has been launched or not. If it has not been launched, it is launched. The "activator" method is used to activate the command prompt window and run a batch file to activate the virtual environment.
		if not (Mode == 1) { ; if specified with param (1) will skip looking for the "activate.bat" file
			env.findNearest_venv_Folder()
			env.activator()
		}
	}
	activator() {
		env.ControlSendTextToCMD("`"" env.activate_bat "`"")
		env.sendEnter()
		env.WinActivate()  ; Show the result.
	}
	WinActivate() {
		try {
			WinActivate "ahk_pid " env.PID
		}
		catch {
			exitapp
		}
	}
	openCommandPrompt() {
		; checks if command window has been launched
		Run "cmd.exe", , "Min", &PID  ; Run Notepad minimized.
		WinWait "ahk_pid " PID  ; Wait for it to appear.
		env.PID := PID
	}
	ControlSendTextToCMD(text) {
		env.clipboard := A_Clipboard
		A_Clipboard := text
		Sleep(50)
		SetKeyDelay(5, 5, "Play")
		Clipwait
		env.WinActivate()
		SendInput("^v")
		env.WinActivate()
		A_Clipboard := env.clipboard
	}
	sendEnter() {
		;ControlSendEnter
		ControlSend("{Enter}", , "ahk_pid " env.PID)
		env.WinActivate()
	}
	checkSession() {
		if FileExist(A_ScriptDir "\session.txt") {

		}
	}
	GuiClose(*)
	{ ; V1toV2: Added bracket
		ExitApp()
	} ; Added bracket in the end
}

installfromImports() {
	listofPy := []
	Loop Files, A_ScriptDir "\*.py", "R"  ; Scripts
	{
		if not InStr(A_LoopFilePath, "site-packages") and not InStr(A_LoopFilePath, "\Scripts\") {
			listofPy.Push(A_LoopFilePath)
		}
	}
	if (listofPy.Length > 0) && (listofPy.Length < 100) {
		for f in listofPy {
			filecontents := FileRead(f)
			loop parse, filecontents, "`n" {
				if InStr(A_LoopField, "import") {
					/*
					regex this:
					from selenium import webdriver
					from webdriver_manager.chrome import ChromeDriverManager
					from webdriver_manager.microsoft import EdgeChromiumDriverManager, IEDriverManager
					import psutil
					
					
					*/
				}
			}
		}
	}
}

nameForExe() {
	global exeName
	myGui := Gui()
	myGui.SetFont("s15")
	Edit1 := myGui.Add("Edit", "x8 y16 w185 h32", "Name")
	ogcButtonOK := myGui.Add("Button", "x208 y16 w75 h29", "&OK")
	ogcButtonOK.OnEvent("Click", OnEventHandler)
	myGui.OnEvent('Close', (*) => ExitApp())
	myGui.Title := "Window"
	myGui.Show("w296 h66")

	OnEventHandler(*)
	{
		exeName := Edit1.Value
		myGui.Destroy
	}
}


configRead() {
	if FileExist(A_MyDocuments "\config_venv.json") {
		f := FileRead(A_MyDocuments "\config_venv.json")
		if f != "" {
			jdata := Jsons.Load(&f)
			return jdata
		} else {
			return false
		}
	} else {
		SplitPath(A_AppData, , &AppData)
		if DirExist(AppData "\Local\Programs\Python")
		{
			pypaths := []
			Loop Files, AppData "\Local\Programs\Python\*.*", "D"
			{
				if FileExist(A_LoopFilePath "\python.exe")
				{
					pypaths.Push(A_LoopFilePath "\python.exe")
				}
			}
			FileOpen(A_MyDocuments "\config_venv.json", "w").Write(Jsons.Dump(Map("pypaths", pypaths)))
		}
	}
}

handleConfigJson(obj) {
	global pathStorage
	if pathStorage != ""
	if obj != false {
		pythons := []
		for path in obj['pypaths'] {
			pathStorage.Push(cleanPath(path))
		}
	}
	else {
		Msgbox("Please select a python path to save for use. Located in /%AppdataLocal%/Programs/Python/Python311/Scripts/python.exe")
		browsePaths(firstTime := true)
	}
}

passBrowseGUI(*) {
	browsePaths()
}

browsePaths(firstTime := false) {
	global pathStorage
	myGui := Gui()
	myGui.SetFont("s11")
	myGui.Opt(" +AlwaysOnTop")
	LB := myGui.Add("ListBox", "x16 y8 w267 h404")
	if firstTime {
		ret := BRowse()
		if ret == false {
			ExitApp()
		}
	} else {
		for objs in pathStorage {
			LB.Add([objs.DisplayPath])
		}
	}
	ogcButtonRemove := myGui.Add("Button", "x304 y8 w80 h106", "Remove")
	ogcButtonAdd := myGui.Add("Button", "x304 y152 w80 h106", "Add")
	ogcButtonClose := myGui.Add("Button", "x304 y304 w80 h106", "Close")
	ogcButtonRemove.OnEvent("Click", Remove)
	ogcButtonAdd.OnEvent("Click", BRowse)
	ogcButtonClose.OnEvent("Click", Destroyer)
	myGui.OnEvent('Close', (*) => ExitApp())
	myGui.Title := "Locate Python Path"
	myGui.Show("w420 h450")

	BRowse(*)
	{
		filePath := FileSelect(1, , 'Select "python.exe" path', '"python.exe" (*.exe)')

		if filePath != "" {
			pathObj := cleanPath(filePath)
			LB.Add([pathObj.DisplayPath])
			pathStorage.Push(pathObj.filePath)
			savePathCfg()
		} else {
			Msgbox("nothing selected, no python found. Exiting.")
			return false
		}
	}
	Remove(*) {
		for i in pathStorage {
			if InStr(i.DisplayPath, LB.Value) {
				pathStorage.RemoveAt(A_Index)
				break
			}
		}
		LB.Delete(LB.Value)
		savePathCfg()
	}
	Destroyer(*)
	{
		env.setDropdown()
		myGui.Destroy
	}
}


cleanPath(filePath) {
	len := strlen(filePath)
	if len > 30 {
		displayPath := SubStr(filePath, len - 30, 31)
	} else {
		displayPath := filePath
	}
	SplitPath(filePath, &fileName, &Dir)
	Loop files, Dir "\*.*"
	{
		if InStr(A_LoopFileName, "python") && InStr(A_LoopFileName, ".dll") && not  InStr(A_LoopFileName, "python3.dll"){
			fileName := A_LoopFileName
			break
		}
	}
	return {
		displayPath: displayPath,
		fileName: fileName,
		filePath: filePath
	}
}


savePathCfg() {
	global pathStorage
	justPathsForExport := []
	if pathStorage = [] {
		FileOpen(A_MyDocuments "\config_venv.json", "w").Write("")
		return 
	}
	for y in pathStorage
	{
		justPathsForExport.Push(y.FilePath)
	}
	FileOpen(A_MyDocuments "\config_venv.json", "w").Write(Jsons.Dump(Map("pypaths", justPathsForExport)))
}

;;;; AHK v2 - https://github.com/TheArkive/JXON_ahk2
;MIT License
;Copyright (c) 2021 TheArkive
;Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
;The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
;THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;
; Example ===================================================================================
; ===========================================================================================

; Msgbox "The idea here is to create several nested arrays, save to text with jxon_dump(), and then reload the array with jxon_load().  The resulting array should be the same.`r`n`r`nThis is what this example shows."
; a := Map(), b := Map(), c := Map(), d := Map(), e := Map(), f := Map() ; Object() is more technically correct than {} but both will work.

; d["g"] := 1, d["h"] := 2, d["i"] := ["purple","pink","pippy red"]
; e["g"] := 1, e["h"] := 2, e["i"] := Map("1","test1","2","test2","3","test3")
; f["g"] := 1, f["h"] := 2, f["i"] := [1,2,Map("a",1.0009,"b",2.0003,"c",3.0001)]

; a["test1"] := "test11", a["d"] := d
; b["test3"] := "test33", b["e"] := e
; c["test5"] := "test55", c["f"] := f

; myObj := Map()
; myObj["a"] := a, myObj["b"] := b, myObj["c"] := c, myObj["test7"] := "test77", myObj["test8"] := "test88"

; g := ["blue","green","red"], myObj["h"] := g ; add linear array for testing

; q := Chr(34)
; textData2 := Jxon_dump(myObj,4) ; ===> convert array to JSON
; msgbox "JSON output text:`r`n===========================================`r`n(Should match second output.)`r`n`r`n" textData2

; newObj := Jxon_load(&textData2) ; ===> convert json back to array

; textData3 := Jxon_dump(newObj,4) ; ===> break down array into 2D layout again, should be identical
; msgbox "Second output text:`r`n===========================================`r`n(should be identical to first output)`r`n`r`n" textData3

; msgbox "textData2 = textData3:  " ((textData2=textData3) ? "true" : "false")

; ===========================================================================================
; End Example ; =============================================================================
; ===========================================================================================

; originally posted by user coco on AutoHotkey.com
; https://github.com/cocobelgica/AutoHotkey-JSON
class Jsons {

	static Load(&src, args*) {
		key := "", is_key := false
		stack := [tree := []]
		next := '"{[01234567890-tfn'
		pos := 0

		while ((ch := SubStr(src, ++pos, 1)) != "") {
			if InStr(" `t`n`r", ch)
				continue
			if !InStr(next, ch, true) {
				testArr := StrSplit(SubStr(src, 1, pos), "`n")

				ln := testArr.Length
				col := pos - InStr(src, "`n", , -(StrLen(src) - pos + 1))

				msg := Format("{}: line {} col {} (char {})"
					, (next == "") ? ["Extra data", ch := SubStr(src, pos)][1]
					: (next == "'") ? "Unterminated string starting at"
						: (next == "\") ? "Invalid \escape"
						: (next == ":") ? "Expecting ':' delimiter"
						: (next == '"') ? "Expecting object key enclosed in double quotes"
						: (next == '"}') ? "Expecting object key enclosed in double quotes or object closing '}'"
						: (next == ",}") ? "Expecting ',' delimiter or object closing '}'"
						: (next == ",]") ? "Expecting ',' delimiter or array closing ']'"
						: ["Expecting JSON value(string, number, [true, false, null], object or array)"
							, ch := SubStr(src, pos, (SubStr(src, pos) ~= "[\]\},\s]|$") - 1)][1]
					, ln, col, pos)

				throw Error(msg, -1, ch)
			}

			obj := stack[1]
			is_array := (obj is Array)

			if i := InStr("{[", ch) { ; start new object / map?
				val := (i = 1) ? Map() : Array()	; ahk v2

				is_array ? obj.Push(val) : obj[key] := val
				stack.InsertAt(1, val)

				next := '"' ((is_key := (ch == "{")) ? "}" : "{[]0123456789-tfn")
			} else if InStr("}]", ch) {
				stack.RemoveAt(1)
				next := (stack[1] == tree) ? "" : (stack[1] is Array) ? ",]" : ",}"
			} else if InStr(",:", ch) {
				is_key := (!is_array && ch == ",")
				next := is_key ? '"' : '"{[0123456789-tfn'
			} else { ; string | number | true | false | null
				if (ch == '"') { ; string
					i := pos
					while i := InStr(src, '"', , i + 1) {
						val := StrReplace(SubStr(src, pos + 1, i - pos - 1), "\\", "\u005C")
						if (SubStr(val, -1) != "\")
							break
					}
					if !i ? (pos--, next := "'") : 0
						continue

					pos := i ; update pos

					val := StrReplace(val, "\/", "/")
					val := StrReplace(val, '\"', '"')
						, val := StrReplace(val, "\b", "`b")
						, val := StrReplace(val, "\f", "`f")
						, val := StrReplace(val, "\n", "`n")
						, val := StrReplace(val, "\r", "`r")
						, val := StrReplace(val, "\t", "`t")

					i := 0
					while i := InStr(val, "\", , i + 1) {
						if (SubStr(val, i + 1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
							continue 2

						xxxx := Abs("0x" . SubStr(val, i + 2, 4)) ; \uXXXX - JSON unicode escape sequence
						if (xxxx < 0x100)
							val := SubStr(val, 1, i - 1) . Chr(xxxx) . SubStr(val, i + 6)
					}

					if is_key {
						key := val, next := ":"
						continue
					}
				} else { ; number | true | false | null
					val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$", , pos) - pos)

					if IsInteger(val)
						val += 0
					else if IsFloat(val)
						val += 0
					else if (val == "true" || val == "false")
						val := (val == "true")
					else if (val == "null")
						val := ""
					else if is_key {
						pos--, next := "#"
						continue
					}

					pos += i - 1
				}

				is_array ? obj.Push(val) : obj[key] := val
				next := obj == tree ? "" : is_array ? ",]" : ",}"
			}
		}

		return tree[1]
	}
	static Dump(obj, indent := "", lvl := 1) {
		if IsObject(obj) {
			if !obj.__Class = "Map" {
				convertedObject := Map()
				for k, v in obj.OwnProps() {
					convertedObject.Set(k, v)
				}
				obj := convertedObject
			}
			If !(obj is Array || obj is Map || obj is String || obj is Number)
				throw Error("Object type not supported.", -1, Format("<Object at 0x{:p}>", ObjPtr(obj)))

			if IsInteger(indent)
			{
				if (indent < 0)
					throw Error("Indent parameter must be a postive integer.", -1, indent)
				spaces := indent, indent := ""

				Loop spaces ; ===> changed
					indent .= " "
			}
			indt := ""

			Loop indent ? lvl : 0
				indt .= indent

			is_array := (obj is Array)

			lvl += 1, out := "" ; Make #Warn happy
			for k, v in obj {
				if IsObject(k) || (k == "")
					throw Error("Invalid object key.", -1, k ? Format("<Object at 0x{:p}>", ObjPtr(obj)) : "<blank>")

				if !is_array ;// key ; ObjGetCapacity([k], 1)
					out .= (ObjGetCapacity([k]) ? Jsons.Dump(k) : escape_str(k)) (indent ? ": " : ":") ; token + padding

				out .= Jsons.Dump(v, indent, lvl) ; value
					. (indent ? ",`n" . indt : ",") ; token + indent
			}

			if (out != "") {
				out := Trim(out, ",`n" . indent)
				if (indent != "")
					out := "`n" . indt . out . "`n" . SubStr(indt, StrLen(indent) + 1)
			}

			return is_array ? "[" . out . "]" : "{" . out . "}"

		} Else If (obj is Number)
			return obj
		Else ; String
			return escape_str(obj)

		escape_str(obj) {
			obj := StrReplace(obj, "\", "\\")
			obj := StrReplace(obj, "`t", "\t")
			obj := StrReplace(obj, "`r", "\r")
			obj := StrReplace(obj, "`n", "\n")
			obj := StrReplace(obj, "`b", "\b")
			obj := StrReplace(obj, "`f", "\f")
			obj := StrReplace(obj, "/", "\/")
			obj := StrReplace(obj, '"', '\"')

			return '"' obj '"'
		}
	}
	static ConvertObjectToMap(InputObject) {
		if IsObject(InputObject) {
			if InputObject.__Class = "Map" {
				return InputObject
			}
			else {
				return Jsons.Convert(InputObject)
			}
		}
		else {
			return InputObject
		}
	}
	static Convert(obj) {
		convertedObject := Map()
		for k, v in obj.OwnProps() {
			convertedObject.Set(k, v)
		}
		return convertedObject
	}
}


darkMode(myGUI) {
	if (VerCompare(A_OSVersion, "10.0.17763") >= 0)
	{
		DWMWA_USE_IMMERSIVE_DARK_MODE := 19
		if (VerCompare(A_OSVersion, "10.0.18985") >= 0)
		{
			DWMWA_USE_IMMERSIVE_DARK_MODE := 20
		}
		DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", myGUI.hWnd, "Int", DWMWA_USE_IMMERSIVE_DARK_MODE, "Int*", true, "Int", 4)
		; listView => SetExplorerTheme(LV1.hWnd, "DarkMode_Explorer"), SetExplorerTheme(LV2.hWnd, "DarkMode_Explorer")
		uxtheme := DllCall("GetModuleHandle", "Str", "uxtheme", "Ptr")
		DllCall(DllCall("GetProcAddress", "Ptr", uxtheme, "Ptr", 135, "Ptr"), "Int", 2) ; ForceDark
		DllCall(DllCall("GetProcAddress", "Ptr", uxtheme, "Ptr", 136, "Ptr"))
	}
	;else
	;SetExplorerTheme(LV1.hWnd), SetExplorerTheme(LV2.hWnd)

}

blackBG(params*) {
	for ctrl in params {
		ctrl.Opt("Background000000")
	}
}




ToggleTheme(GuiCtrlObj, *)
{
	switch GuiCtrlObj.Text
	{
		case "DarkMode":
		{
			SetWindowAttribute(Main)
			SetWindowTheme(Main)
		}
		default:
		{
			SetWindowAttribute(Main, False)
			SetWindowTheme(Main, False)
		}
	}
}




SetWindowAttribute(GuiObj, DarkMode := True)
{
	global DarkColors          := Map("Background", "0x202020", "Controls", "0x404040", "Font", "0xE0E0E0")
	global TextBackgroundBrush := DllCall("gdi32\CreateSolidBrush", "UInt", DarkColors["Background"], "Ptr")
	static PreferredAppMode    := Map("Default", 0, "AllowDark", 1, "ForceDark", 2, "ForceLight", 3, "Max", 4)

	if (VerCompare(A_OSVersion, "10.0.17763") >= 0)
	{
		DWMWA_USE_IMMERSIVE_DARK_MODE := 19
		if (VerCompare(A_OSVersion, "10.0.18985") >= 0)
		{
			DWMWA_USE_IMMERSIVE_DARK_MODE := 20
		}
		uxtheme := DllCall("kernel32\GetModuleHandle", "Str", "uxtheme", "Ptr")
		SetPreferredAppMode := DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 135, "Ptr")
		FlushMenuThemes     := DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 136, "Ptr")
		switch DarkMode
		{
			case True:
			{
				DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", GuiObj.hWnd, "Int", DWMWA_USE_IMMERSIVE_DARK_MODE, "Int*", True, "Int", 4)
				DllCall(SetPreferredAppMode, "Int", PreferredAppMode["ForceDark"])
				DllCall(FlushMenuThemes)
				GuiObj.BackColor := DarkColors["Background"]
			}
			default:
			{
				DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", GuiObj.hWnd, "Int", DWMWA_USE_IMMERSIVE_DARK_MODE, "Int*", False, "Int", 4)
				DllCall(SetPreferredAppMode, "Int", PreferredAppMode["Default"])
				DllCall(FlushMenuThemes)
				GuiObj.BackColor := "Default"
			}
		}
	}
}


SetWindowTheme(GuiObj, DarkMode := True)
{
	static GWL_WNDPROC        := -4
	static GWL_STYLE          := -16
	static ES_MULTILINE       := 0x0004
	static LVM_GETTEXTCOLOR   := 0x1023
	static LVM_SETTEXTCOLOR   := 0x1024
	static LVM_GETTEXTBKCOLOR := 0x1025
	static LVM_SETTEXTBKCOLOR := 0x1026
	static LVM_GETBKCOLOR     := 0x1000
	static LVM_SETBKCOLOR     := 0x1001
	static LVM_GETHEADER      := 0x101F
	static GetWindowLong      := A_PtrSize = 8 ? "GetWindowLongPtr" : "GetWindowLong"
	static SetWindowLong      := A_PtrSize = 8 ? "SetWindowLongPtr" : "SetWindowLong"
	static Init               := False
	static LV_Init            := False
	global IsDarkMode         := DarkMode

	Mode_Explorer  := (DarkMode ? "DarkMode_Explorer"  : "Explorer" )
	Mode_CFD       := (DarkMode ? "DarkMode_CFD"       : "CFD"      )
	Mode_ItemsView := (DarkMode ? "DarkMode_ItemsView" : "ItemsView")

	for hWnd, GuiCtrlObj in GuiObj
	{
		switch GuiCtrlObj.Type
		{
			case "Button", "CheckBox", "ListBox", "UpDown":
			{
				DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_Explorer, "Ptr", 0)
			}
			case "ComboBox", "DDL":
			{
				DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_CFD, "Ptr", 0)
			}
			case "Edit":
			{
				if (DllCall("user32\" GetWindowLong, "Ptr", GuiCtrlObj.hWnd, "Int", GWL_STYLE) & ES_MULTILINE)
				{
					DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_Explorer, "Ptr", 0)
				}
				else
				{
					DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_CFD, "Ptr", 0)
				}
			}
			case "ListView":
			{
				if !(LV_Init)
				{
					static LV_TEXTCOLOR   := SendMessage(LVM_GETTEXTCOLOR,   0, 0, GuiCtrlObj.hWnd)
					static LV_TEXTBKCOLOR := SendMessage(LVM_GETTEXTBKCOLOR, 0, 0, GuiCtrlObj.hWnd)
					static LV_BKCOLOR     := SendMessage(LVM_GETBKCOLOR,     0, 0, GuiCtrlObj.hWnd)
					LV_Init := True
				}
				GuiCtrlObj.Opt("-Redraw")
				switch DarkMode
				{
					case True:
					{
						SendMessage(LVM_SETTEXTCOLOR,   0, DarkColors["Font"],       GuiCtrlObj.hWnd)
						SendMessage(LVM_SETTEXTBKCOLOR, 0, DarkColors["Background"], GuiCtrlObj.hWnd)
						SendMessage(LVM_SETBKCOLOR,     0, DarkColors["Background"], GuiCtrlObj.hWnd)
					}
					default:
					{
						SendMessage(LVM_SETTEXTCOLOR,   0, LV_TEXTCOLOR,   GuiCtrlObj.hWnd)
						SendMessage(LVM_SETTEXTBKCOLOR, 0, LV_TEXTBKCOLOR, GuiCtrlObj.hWnd)
						SendMessage(LVM_SETBKCOLOR,     0, LV_BKCOLOR,     GuiCtrlObj.hWnd)
					}
				}
				DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_Explorer, "Ptr", 0)
				
				; To color the selection - scrollbar turns back to normal
				;DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_ItemsView, "Ptr", 0)

				; Header Text needs some NM_CUSTOMDRAW coloring
				LV_Header := SendMessage(LVM_GETHEADER, 0, 0, GuiCtrlObj.hWnd)
				DllCall("uxtheme\SetWindowTheme", "Ptr", LV_Header, "Str", Mode_ItemsView, "Ptr", 0)
				GuiCtrlObj.Opt("+Redraw")
			}
		}
	}

	if !(Init)
	{
		; https://www.autohotkey.com/docs/v2/lib/CallbackCreate.htm#ExSubclassGUI
		global WindowProcNew := CallbackCreate(WindowProc)  ; Avoid fast-mode for subclassing.
		global WindowProcOld := DllCall("user32\" SetWindowLong, "Ptr", GuiObj.Hwnd, "Int", GWL_WNDPROC, "Ptr", WindowProcNew, "Ptr")
		Init := True
	}
}



WindowProc(hwnd, uMsg, wParam, lParam)
{
	critical
	static WM_CTLCOLOREDIT    := 0x0133
	static WM_CTLCOLORLISTBOX := 0x0134
	static WM_CTLCOLORBTN     := 0x0135
	static WM_CTLCOLORSTATIC  := 0x0138
	static DC_BRUSH           := 18

	if (IsDarkMode)
	{
		switch uMsg
		{
			case WM_CTLCOLOREDIT, WM_CTLCOLORLISTBOX:
			{
				DllCall("gdi32\SetTextColor", "Ptr", wParam, "UInt", DarkColors["Font"])
				DllCall("gdi32\SetBkColor", "Ptr", wParam, "UInt", DarkColors["Controls"])
				DllCall("gdi32\SetDCBrushColor", "Ptr", wParam, "UInt", DarkColors["Controls"], "UInt")
				return DllCall("gdi32\GetStockObject", "Int", DC_BRUSH, "Ptr")
			}
			case WM_CTLCOLORBTN:
			{
				DllCall("gdi32\SetDCBrushColor", "Ptr", wParam, "UInt", DarkColors["Background"], "UInt")
				return DllCall("gdi32\GetStockObject", "Int", DC_BRUSH, "Ptr")
			}
			case WM_CTLCOLORSTATIC:
			{
				DllCall("gdi32\SetTextColor", "Ptr", wParam, "UInt", DarkColors["Font"])
				DllCall("gdi32\SetBkColor", "Ptr", wParam, "UInt", DarkColors["Background"])
				return TextBackgroundBrush
			}
		}
	}
	return DllCall("user32\CallWindowProc", "Ptr", WindowProcOld, "Ptr", hwnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam)
}