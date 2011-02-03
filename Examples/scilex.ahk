#include ../SCI.ahk
    
Gui +LastFound
hwnd:=WinExist()
hSci1:=SCI_Add(hwnd, x, y, w, h)
Gui, show, w400 h300
SCI_SetWrapMode(True)

; stores "This is my truncated text".
SCI_AddText("This is my truncated text, this is not added!", 25)
SCI_ClearAll()
return