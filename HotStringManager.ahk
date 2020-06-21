;v 2.0 Safer and faster phrase lister < Warning for multilineText < HotstringSearch < DoubleSpace < KeresésKésleltetés stb. < Új ShortString ajánlások  < ÚjGUI + Biztonság < Javított Delete < Javított AltSpace < Fejlett menüvel < ...
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Persistent
#SingleInstance Force
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input
;SendMode Input / Play /  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;#NoTrayIcon 
;—————————————————
; ---- OPTIONS ---
Menu, Tray, Icon, %A_WinDir%\system32\SHELL32.dll, 2
#Hotstring t ;c
#Hotstring EndChars -()[]{}:;'",.?!`n `t
IsModifier:=1

;--------------------------
; INITIALISE
;--------------------------
gosub ~NumLock  ;to get proper status

;--------------------------
;#IfWinActive ahk_class Notepad
;::edr::eldorDoubleRainbow
;#IfWinActive ahk_class OpusApp or IfWinActive ahk_class  rctrl_renwnd32 ; Word -ben érvényes ; or IfWinActive ahk_exe WINWORD.EXE
;--------------------------
; HOTKEYS
;--------------------------
^+-::	gosub HotsrtingHozzáadóMenü 
^-::	gosub HotstringHozzáadom
^Insert::Reload
~^z:: Click up ; to reset hotsrting buffer if needed 
;~ ~BackSpace:: click up
!CapsLock:: gosub HotstringTüzelő


#inputlevel 1
SendLevel 1
~NumLock::
	if (getkeystate("NumLock","T")){
		IsModifier:= 1
	}else{
		IsModifier:= 0
	}
return
~Space up:: ;LControl & Space:: 		;LAlt & space up:: ;!space:: 
	If (A_ThisHotkey == A_PriorHotkey && A_TimeSincePriorHotkey < 350)
{
		IsModifier:=0
		;KeyWait,LAlt
		;send, {LAlt up}
		;~ SendInput,{space}
		;~ sleep 50
		SendInput,{bs}{bs}
		;~ sleep 50
		Loop
		{
			Sleep,10
			if (GetKeystate("Enter") = 1) or (GetKeystate("?") = 1) or (GetKeystate(".") = 1) or (GetKeystate("Space") = 1) or (GetKeystate("!") = 1) or (GetKeystate("/") = 1) or (GetKeystate("\") = 1) or (GetKeystate(":") = 1) or (GetKeystate(";") = 1) or (GetKeystate("'") = 1)
			{
				;~ msgbox loopEnd
				break
			}
		}
		;~ KeyWait,space,D
		;~ KeyWait,space
		IsModifier:=1
}
return

^.::
	InputBox, UserInput, HotString kereső, Légyszi add meg a keresett kifejezést: ;(legalább 2 karaktert) ; , , ; 640, 480
	if ErrorLevel{
		; MsgBox, CANCEL was pressed.
	}else{
		;~ if	StrLen(UserInput)<2{
			;~ MsgBox, A kifejezés legalább 2 karakteres legyen!
			;~ return
			;~ }
		MsgBox, 4,,Az egész sort kéred? 
		IfMsgBox Yes
		{
			Scope:="Line"
		}else{
			Scope:="Phrase"
		}
		HitCounter:=0
		HitList:=""
		HitLine:=""
		FileRead, OldScript, GeneralHotStrings.txt
		;msgbox % OldScript	
		Loop, parse, OldScript, `n, `r
		{
			SorFelek:=StrSplit(A_LoopField,":")
			
			If RegExMatch(SorFelek[5],"(?i).*" . UserInput . ".*" ) {	
				if RegExMatch(SorFelek[5],"[a-záéiíóöőúüű][A-ZÖÜÓŐÚÉÁŰÍ]") {
					; Send,% "`n" + SorFelek[5]
					If (Scope="Phrase") {
						HitLine:="`r`n" + SorFelek[5]
					}else{
						HitLine:="`r`n" + A_LoopField
					}
					HitList:=HitList . HitLine
					HitCounter += 1
					;Sleep, 60
					;EnLista := (EnLista "`r" SorFelek[5])
				}
			}
		}
		MsgBox, % "Vágólapra másolt találataim száma," UserInput " kifejezésre:" HitCounter
		Clipboard := HitList
	}
	; Clipboard = %EnLista% 
return


HotstringTüzelő:
return


HotstringHozzáadom:
	gosub PrepareText 
    send, {End} ;^{Right}
	gosub AddHotstring
return
HotsrtingHozzáadóMenü:
	if !WinExist("Új AutoText")	{
		gosub PrepareText
		gosub LoadMenu
	}Else{
		WinActivate, Új AutoText, , , 
	}
return

PrepareText:
    ;AutoTrim Off  ; Retain any leading and trailing whitespace on the clipboard.
    ClipboardOld = %ClipboardAll%
    Clipboard =  ; Must start off blank for detection to work.
	Send, ^c
	;~ sleep 100
    ClipWait 1
    if ErrorLevel {  ; ClipWait timed out.
        send, ^+{Left}
		sleep 40
		Send, ^c
		ClipWait 1
		if ErrorLevel { 
			Clipboard = %ClipboardOld% 
			return
		}
	}else{
    }
	
	Hotstring:=RTrim(Clipboard, OmitChars := " `t`r`n") ;
	;~ StringReplace, Hotstring, Hotstring, ``, ````, All  ; Do this replacement first to avoid interfering with the others below.
    ;~ StringReplace, Hotstring, Hotstring, `r`n, ``r, All  ; Using `r works better than `n in MS Word, etc.
    ;~ StringReplace, Hotstring, Hotstring, `n, ``r, All
    ;~ StringReplace, Hotstring, Hotstring, %A_Tab%, ``t, All
    ;~ StringReplace, Hotstring, Hotstring, `;, ```;, All
    Clipboard = %ClipboardOld%  ; Restore previous contents of clipboard.
; Create a suggestion for activator
	ShortString:="" ;Reset ShortString
	if (instr(Hotstring,"`r")) or (instr(Hotstring,"`n"))
	{
		Msgbox,1, Figyelmeztetlek, hogy többsoros szöveget jelöltél ki!: `n ——— `n %Hotstring%
			IfmsgBox, Ok
			{
			}Else{
				Exit
			}
	}
	
	if Hotstring contains % A_Space
	{
		HotSplit:= StrSplit(Hotstring," ")
		For index, element in HotSplit
		{
			ShortString .= SubStr(element,1,1)
		}
	}else{
		testString := RegExReplace(Hotstring, "[áéiíóöőúüű]", "a")
		if testString is lower
		{
		ShortString := SubStr(Hotstring,1,1) . SubStr(Hotstring,0)
		}else{
		ShortString := RegExReplace(Hotstring, "[a-záéiíóöőúüű ]", "")
		StringLower,ShortString, ShortString
		}	
	}
	ShortString := trim(ShortString, omitchars := " `t`r`n")
    hotOptions:=""
	;~ msgbox % shortstring
return
LoadMenu:
	IsModifier:=0
	
	Gui Font, s9, Tahoma
	Gui Add, Text, x3 y5 w471 h33, % "Add meg a maximum 40 karakter hoszú aktiváló szöveget/rövidítést, a következő kifejezéshez: -" . Hotstring . "-"
	Gui Add, Edit, vShortString gCsekkold x3 y40 w251 h21,% ShortString
	; Gui Add, Button, Default gCsekkold x263 y40 w70 h23, &VanMár?
	Gui Add, Button, gListaNyit x263 y40 w70 h23, &Lista
	Gui Add, Button, Default gFelveszem x336 y40 w65 h23, &Felveszem
	Gui Add, Button, gGuiEscape x405 y40 w62 h23, &Kilépek
	Gui Add, CheckBox, vCaps x3 y69 w163 h25, Pontos&Nagybetűk (C)
	Gui Add, CheckBox, vNoTrigger x324 y69 w130 h25, &SpaceSeKell (*)
	Gui Add, CheckBox, vNoSpace x179 y69 w131 h25, MindígRa&gozom (O)
	Gui Add, CheckBox, vAlwaysTrigger x3 y95 w140 h25, &RagRövidítés (?)
	Gui Add, CheckBox, vExpression x179 y95 w130 h25, &MakróIndító (X)
	Gui Add, CheckBox, vLeaveTriggerText x324 y95 w130 h25, &HozzáÍrom (B0)
	Gui Add, Text, x5 y125 w463 h2 0x10
	Gui Add, Text, x133 y135 w220 h20 +0x200, Korábbi hozzárenedlésed a rövidítéshez:
	Gui Add, Button, gTorold x356 y135 w100 h20, Jelölteket&Töröld
	Gui Add, ListView,sort -Hdr vSelectedItems x16 y160 w441 h441, Opc|Rov|Desc
	LV_ModifyCol()
	LV_ModifyCol(2, "Sort")

	Gui Show, w473 h608, Új AutoText ;h182
	
	sleep 10 
	send, {end}
	gosub Csekkold
Return
GuiEscape:
	Gui, destroy
	IsModifier:=1
	reload
	Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
    ; ENG: The hotstring just added appears to be improperly formatted.  Would you like to open the script for editing? Note that the bad hotstring is at the bottom of the script.
    MsgBox, 4,, Baj van a felülírással. Megnyissam a szerkesztőt és leellenőrzöd a változást kézzel? (Legalul keresd)
		IfMsgBox, Yes, gosub ListaNyit
return
GuiClose:
	Gui, destroy
	send, {End} ;{left}^{right}
	IsModifier:=1
	reload
	Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
    ; ENG: The hotstring just added appears to be improperly formatted.  Would you like to open the script for editing? Note that the bad hotstring is at the bottom of the script.
    MsgBox, 4,, Baj van a felülírással. Megnyissam a szerkesztőt és leellenőrzöd a változást kézzel? (Legalul keresd)
		IfMsgBox, Yes, gosub ListaNyit
return

ListaNyit:
	run Notepad "GeneralHotStrings.txt"
return
Felveszem:
	Gui, Submit, NoHide
			hotOptions:=""
			
			GuiControlGet, Caps
			GuiControlGet, NoTrigger
			GuiControlGet, NoSpace
			GuiControlGet, AlwaysTrigger
			GuiControlGet, Expression
			
			If (Caps = 1) 
				hotOptions .= "C"
			If (NoTrigger = 1) 
				hotOptions .= "*"
			If (NoSpace = 1) 
				hotOptions .= "O"
			If (AlwaysTrigger = 1) 
				hotOptions .= "?"
			If (Expression = 1) 
				hotOptions .= "X"
			If (LeaveTriggerText = 1) 
				hotOptions .= "B0"
			
			gosub AddHotstring
return
;~Enter::LoopStopper:=1
Csekkold:
	GuiControlGet, ShortString	
	If (StrLen(Trim (ShortString))>1){
		FileRead, OldScript, GeneralHotStrings.txt
		;msgbox % OldScript	
		LV_Delete()
		Loop, parse, OldScript, `n, `r
		{
			If RegExMatch(A_LoopField,"(?i):" . ShortString . ".*:" )
			{	
				SorFelek:=StrSplit(A_LoopField,":")
				LV_Add(,SorFelek[2],SorFelek[3],SorFelek[5])
			}
		}
		LV_ModifyCol()
		LV_ModifyCol(2, "Sort")
	}
return
Torold:
    ;GuiControlGet,SelectedItems, ListView
	ControlGet, SelectedItems, List, Selected Col2, SysListView321
	;MsgBox % SelectedItems
	Loop, parse, SelectedItems, `n, `r
	{
	    ShortString:=A_LoopField
		gosub, Torlom
	}
	gosub, Csekkold	
return
Torlom:
	NewScript:=""
	FileRead, OldScript, GeneralHotStrings.txt
	;; Msgbox % ShortString
	Loop, parse, OldScript, `n, `r
	{
			If  !InStr(A_LoopField,":" . ShortString . "::") and !(A_LoopField="")
		{
			;smgbox A_LoopField
			NewScript.="`n" . A_LoopField
		}
	}
	file := FileOpen("GeneralHotStrings.txt", "w") ;open the file after "Wiping"
	file.write(NewScript)
	file.close()
	Sleep 100
return
; -----------

AddHotstring:
	If (Trim(ShortString) = "") 
	{
		; eng: You didn't provide an abbreviation. The hotstring has not been added.
		MsgBox Nem adtál meg rövidítést. Adj meg mégis, vagy nyomd meg a Mégse-t, ha lefújod az akciót!
		return
	}else if (StrLen(ShortString)>10){
		msgbox Nem Jó a rövidítés - túl hosszú!
		return
	}else{
		gosub Torlom
		FullString:=":" . hotOptions . ":" . ShortString . "::" . Hotstring
		; Add the hotstring and reload the script:
		FileAppend, `n%FullString%, GeneralHotStrings.txt  ; Put a `n at the beginning in case file lacks a blank line at its end.
		; SoundBeep  
		sleep, 100
		gosub GuiClose
	}
return
;~ #IfWinNotActive ahk_exe Chrome.exe ;AND (Ismodifier=1)

#inputlevel 0
;~ #IfWinNotActive ahk_exe Chrome.exe  ahk_exe EXCEL.EXE

#If (WinActive( "ahk_exe chrome.exe",,"Új lap" ) || !WinActive( "ahk_exe excel.exe",,"" )) && ( isModifier = 1 )

#Include GeneralHotStrings.txt

;~ #Include GeneralHotStrings.AHK
;~ #IfWinActive
;~ #if
;~ #ifWinActive
;~ #if (Ismodifier=1)
	
	;~ #inputlevel 0
		;~ #IfWinNotActive ahk_exe Chrome.exe
		;~ #Include GeneralHotStrings.AHK
	;~ #IfWinActive ahk_exe Chrome.exe
	;~ #IfWinActive 
		;~ #Include GeneralHotStrings.AHK
		
;--------------------------------------------------------------------------------
; FUNCTIONS
;--------------------------------------------------------------------------------
