#include ../SCI.ahk
    
Gui +LastFound
hwnd:=WinExist()
hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
Gui, show, w400 h300
SCI_StyleSetHotspot("STYLE_DEFAULT", True, hSci1)
SCI_StyleClearAll()
msgbox % SCI_StyleGetHotspot("STYLE_DEFAULT", hSci1)
return