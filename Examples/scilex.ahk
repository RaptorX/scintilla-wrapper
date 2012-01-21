#include ../SCI.ahk
#singleinstance force

Gui +LastFound
hwnd:=WinExist(), sci := new scintilla, sci2 := new scintilla
Sci.add(hwnd, 0, 10), sci.SetWrapMode(True), sci.SetText(false,txt:="this is #1")
Sci2.add(hwnd, 0, 290), sci2.SetWrapMode(True), sci2.SetText(false,txt2:="this")

Gui, show, w400 h570
sci.GetText(sci.getlength()+1, &myvar, sci.hwnd)
msgbox % strget(&myvar, "CP0")
sci2.GetText(sci2.getlength()+1, &myvar2, sci2.hwnd) ; memory corruption happens at second call
                                                     ; i suspect all functions in line 28 have that issue.
msgbox % strget(&myvar2, "CP0")

; logically speaking this wrapper is complete... you can call all functions from dll without issues.
; i need to test them all though because of errors like this one. 
; i NEED basic functions working (which i assume they do) and multi component interface
; which atm has this error because i use the scintilla component in AHK-TK (will add lexing later on) \m/

return

GuiClose:
exitapp