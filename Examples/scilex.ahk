#include ../SCI.ahk
    
Gui +LastFound
hwnd:=WinExist()
hSci1:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_VISIBLE")
Gui, show, w400 h300
SCI_SetWrapMode(True, hSci1)
SCI_SetLexer("SCLEX_CPP")
SCI_StyleClearAll()
SCI_SetKeywords(0, "if else switch case default break goto return for while do continue typedef sizeof NULL new delete throw try catch namespace operator this const_cast static_cast dynamic_cast reinterpret_cast true false using typeid and and_eq bitand bitor compl not not_eq or or_eq xor xor_eq")
SCI_StyleSetFore(5, "blue")
SCI_StyleSetBold(5, True)
return