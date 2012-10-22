#include ..\SCI.ahk
#singleinstance force

/*
    ---------------------
    This is an example of how to highlight without selecting a pre-existing lexer.
    In this example we will manually tell scintilla which positions to color.

    In this case we use SCLEX_CONTAINER to tell scintilla that we will manually do the coloring.
    I set some random text in the control, set some styles and use the Search Label together with a simple search function
    To tell scintilla what to color.
*/

Gui +LastFound
sci := new scintilla(WinExist())

; Set some options
sci.SetWrapMode(true), sci.Notify := "Notify"   ; The notify option tells the wrapper which function to call when WM_NOTIFY is sent

Gui, Show,  w600 h400
return

GuiClose:
    ExitApp
    
Notify(wParam, lParam, msg, hwnd, obj){
    
    if (obj.scnCode = SCN_CHARADDED)
        tooltip % chr(obj.ch)
    return
}