 ; Title: Scintilla Wrapper for AHK

; Group: Special Functions

/*    
    Function: _Add
    Creates a Scintilla component and adds it to the Parent GUI.
    
    This function initializes the Scintilla Component. See <http://www.scintilla.org/Steps.html> for more information on how to add the component to a GUI/Control
    
    Parameters:    
    SCI_Add(hParent, [x, y, w, h, Styles, MsgHandler, path])

    hParent     -   Hwnd of the parent control who will host the Scintilla Component
    x           -   x position for the control (default 5)
    y           -   y position for the control (default 15)
    w           -   Width of the control (default 390)
    h           -   Height of the control (default 270)
    Styles      -   List of window style variable names separated by spaces. The WS_ prefix for the variables 
                    is optional.                    
                    Full list of Style names can be found at 
                    <http://msdn.microsoft.com/en-us/library/ms632600%28v=vs.85%29.aspx>
    MsgHandler  -   Name of the function that will handle the window messages sent by the control.
                    This is very useful for when creating personalized lexing or folding for your control.
    Path        -   Path to the SciLexer.dll file, if omitted the function looks for it                        
                    in the current dir.
    
    Returns:
    HWND - Component handle.
    
    Examples:
    (start code)
    ; Add a component with default values.
    ; The default values are calculated to fit optimally on a 400x300 GUI/Control

    gui +LastFound
    hwnd:=WinExist()
    hSci:=SCI_Add(hwnd)
    Gui, Show, w400 h300
    return
    
    ;---------------------
    
    gui +LastFound
    hwnd:=WinExist()
    hSci:=SCI_Add(hwnd, "","",400,300,"WS_CHILD WS_BORDER WS_VISIBLE")
    Gui, Show, w400 h300
    return
    
    ;---------------------
    
    Gui, add, Tab2, HWNDhwndtab x0 y0 w400 h300,one|two
    hSci:=SCI_Add(hwndtab,"",25,"","","Child Border Visible","", a_desktop "\scilexer.dll")
    Gui, Show, w400 h300
    return
    (end)
*/
SCI_Add(hParent, x=5, y=15, w=390, h=270, Styles="", MsgHandler="", DllPath=""){ 
    static WS_OVERLAPPED:=0x00000000,WS_POPUP:=0x80000000,WS_CHILD:=0x40000000,WS_MINIMIZE:=0x20000000
    ,WS_VISIBLE:=0x10000000,WS_DISABLED:=0x08000000,WS_CLIPSIBLINGS:=0x04000000,WS_CLIPCHILDREN:=0x02000000
    ,WS_MAXIMIZE:=0x01000000,WS_CAPTION:=0x00C00000,WS_BORDER:=0x00800000,WS_DLGFRAME:=0x00400000
    ,WS_VSCROLL:=0x00200000,WS_HSCROLL:=0x00100000,WS_SYSMENU:=0x00080000,WS_THICKFRAME:=0x00040000
    ,WS_GROUP:=0x00020000,WS_TABSTOP:=0x00010000,WS_MINIMIZEBOX:=0x00020000,WS_MAXIMIZEBOX:=0x00010000
    ,WS_TILED:=0x00000000,WS_ICONIC:=0x20000000,WS_SIZEBOX:=0x00040000,WS_EX_CLIENTEDGE:=0x00000200
    ,GuiID:=311210,init:=False
    
    if !init
        old:=OnMessage(0x4E,"SCI_onNotify"),init:=True,old!="SCI_onNotify" ? SCI("oldNotify", RegisterCallback(old))
        
    if !hModule:=DllCall("LoadLibrary", "str", DllPath ? DllPath : "SciLexer.dll")
        return debug ? A_ThisFunc "> Could not load library: " DllPath : -1
       
    hStyle := WS_CHILD | (InStr(Style, "Hidden") ? 0 : WS_VISIBLE) | WS_TABSTOP
    
    if Styles
        Loop, Parse, Styles, %a_tab%%a_space%, %a_tab%%a_space%
            hStyle |= %a_loopfield%+0 ? %a_loopfield% : WS_%a_loopfield%
    
    hSci:=DllCall("CreateWindowEx"
          ,Uint ,WS_EX_CLIENTEDGE   ; Ex Style
          ,Str  ,"Scintilla"        ; Class Name
          ,Str  ,""                 ; Window Name
          ,UInt ,hStyle             ; Window Styles
          ,Int  ,x ? x : 5          ; x
          ,Int  ,y ? y : 15         ; y
          ,Int  ,w ? w : 390        ; Width
          ,Int  ,h ? h : 270        ; Height
          ,UInt ,hParent            ; Parent HWND
          ,UInt ,GuiID              ; (HMENU)GuiID
          ,UInt ,NULL               ; hInstance
          ,UInt ,NULL, "UInt")      ; lpParam
          ,IsFunc(MsgHandler) ? SCI(hSci "MsgHandler", MsgHandler)
          ;,SCI_SendEditor(0,0,0,hSci) ; initialize SCI_SendEditor function
          
    return hSci
}


; [Private Functions]

SCI(var, val=""){
    static
    
	lvar := %var%, val != "" ? %var% := val
    return lvar
}
