; Title: Scintilla Wrapper for AHK

; Group: Special Functions

/*
    Function: Add
    Creates a Scintilla component and adds it to the Parent GUI.

    This function initializes the Scintilla Component. See <http://www.scintilla.org/Steps.html> for more information on how to add the component to a GUI/Control

    Parameters:
    SCI_Add(hParent, [x, y, w, h, Styles, MsgHandler, DllPath])

    hParent     -   Hwnd of the parent control who will host the Scintilla Component
    x           -   x position for the control (default 5)
    y           -   y position for the control (default 15)
    w           -   Width of the control (default 390)
    h           -   Height of the control (default 270)
    Styles      -   List of window style variable names separated by spaces.
                    The WS_ prefix for the variables is optional.
                    Full list of Style names can be found at
                    <http://msdn.microsoft.com/en-us/library/ms632600%28v=vs.85%29.aspx>.

    MsgHandler  -   Name of the function that will handle the window messages sent by the control.
                    This is very useful for when creating personalized lexing or folding for your control.
    DllPath     -   Path to the SciLexer.dll file, if omitted the function looks for it in *a_scriptdir*.

    Returns:
    HWND - Component handle.

    Examples:
    (start code)
    ; Add a component with default values.
    ; It expects scilexer.dll to be on the script's location.
    ; The default values are calculated to fit optimally on a 400x300 GUI/Control

    Gui +LastFound
    hwnd:=WinExist()
    hSci:=SCI_Add(hwnd)
    Gui, show, w400 h300
    return

    ;---------------------
    ; Add a component with default values.
    ; It expects scilexer.dll to be on the script's location.
    ; This script also adds some styles.
    ; If variables "x,y,w,h" are empty the default values are used.

    Gui +LastFound
    hwnd:=WinExist()
    hSci:=SCI_Add(hwnd, x, y, w, h, "WS_CHILD WS_BORDER WS_VISIBLE")
    Gui, show, w400 h300
    return

    ;---------------------
    ; Add a component embedded in a tab with additional code for
    ; hiding/showing the component depending on which tab is open.
    ; If variables "x,w,h" are empty the default values are used.

    Gui, add, Tab2, HWNDhwndtab x0 y0 w400 h300 gtabHandler vtabLast,one|two
    hSci:=SCI_Add(hwndtab,x,25,w,h,"Child Border Visible","",a_desktop "\scilexer.dll")
    Gui, show, w400 h300
    return

    tabHandler:                             ; Tab Handler for the Scintilla Control
    Gui, submit, Nohide
    action := tabLast = "one" ? "Show" : "Hide" ; decide which action to take
    Control,%action%,,,ahk_id %hSci%
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
    ,GuiID:=311210,init:=False, NULL:=0

    if !init        ;  WM_NOTIFY = 0x4E
        old:=OnMessage(0x4E,"SCI_onNotify"),init:=True,old!="SCI_onNotify" ? SCI("oldNotify", RegisterCallback(old))

    if !SCIModule:=DllCall("LoadLibrary", "Str", DllPath ? DllPath : "SciLexer.dll")
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

; Group: Style Definition [General]

/*
    Function: StyleResetDefault
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLERESETDEFAULT>

    This message resets STYLE_DEFAULT to its state when Scintilla was initialised.

    Parameters:
    SCI_StyleResetDefault([hwnd])

    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    >SCI_StyleResetDefault(hSci)
*/
SCI_StyleResetDefault(hwnd=0){

    return SCI_sendEditor(hwnd, "SCI_STYLERESETDEFAULT")
}

/*
    Function: StyleClearAll
    <http://www.scintilla.org/ScintillaDoc.html#SCI_STYLECLEARALL>

    This message sets all styles to have the same attributes as STYLE_DEFAULT.
    If you are setting up Scintilla for syntax coloring, it is likely that the lexical styles you set
    will be very similar. One way to set the styles is to:

    - Set STYLE_DEFAULT to the common features of all styles.
    - Use SCI_STYLECLEARALL to copy this to all styles.
    - Set the style attributes that make your lexical styles different.

    Parameters:
    SCI_StyleClearAll([hwnd])
    
    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.

    Returns:
    Zero - Nothing is returned by this function.

    Examples:
    >SCI_StyleClearAll(hSci)
*/
SCI_StyleClearAll(hwnd=0){

    return SCI_SendEditor(hwnd, "SCI_STYLECLEARALL")
}

                               ; ---- [ INTERNAL FUNCTIONS ] ----- ;

SCI(var, val=""){
    static
    SCN_STYLENEEDED                   := 2000
    SCN_CHARADDED                     := 2001
    SCN_SAVEPOINTREACHED              := 2002
    SCN_SAVEPOINTLEFT                 := 2003
    SCN_MODIFYATTEMPTRO               := 2004
    SCN_KEY                           := 2005
    SCN_DOUBLECLICK                   := 2006
    SCN_UPDATEUI                      := 2007
    SCN_MODIFIED                      := 2008
    SCN_MACRORECORD                   := 2009
    SCN_MARGINCLICK                   := 2010
    SCN_NEEDSHOWN                     := 2011
    SCN_PAINTED                       := 2013
    SCN_USERLISTSELECTION             := 2014
    SCN_URIDROPPED                    := 2015
    SCN_DWELLSTART                    := 2016
    SCN_DWELLEND                      := 2017
    SCN_ZOOM                          := 2018
    SCN_HOTSPOTCLICK                  := 2019
    SCN_HOTSPOTDOUBLECLICK            := 2020
    SCN_CALLTIPCLICK                  := 2021
    SCN_AUTOCSELECTION                := 2022

	lvar := %var%, val != "" ? %var% := val
    return lvar
}

/*
    Function : SendEditor
    Posts the messages used to modify the control's behaviour.

    Parameters:
    SCI_sendEditor(hwnd, msg, [wParam, lParam])

    hwnd    -   The hwnd of the control that you want to operate on. Useful for when you have more than 1
                Scintilla components in the same script. The wrapper will remember the last used hwnd,
                so you can specify it once and only specify it again when you want to operate on a different
                component.
    msg     -   The message to be posted, full list can be found here:
                <http://www.scintilla.org/ScintillaDoc.html>
    wParam  -   wParam for the message
    lParam  -   lParam for the message

    Returns:
    Status code of the DllCall performed.

    Examples:
    (Start Code)
    SCI_sendEditor(hSci1, "SCI_SETMARGINWIDTHN",0,40)  ; Set the margin 0 to 40px on the first component.
    SCI_sendEditor(0, "SCI_SETWRAPMODE",1,0)           ; Set the wrap mode to True on the last used component.
    SCI_sendEditor(hSci2, "SCI_SETMARGINWIDTHN",0,50)  ; Set the margin 0 to 50px on the second component.
    (End)
*/
SCI_sendEditor(hwnd, msg, wParam=0, lParam=0){
    static

    hwnd := !hwnd ? oldhwnd : hwnd, oldhwnd := hwnd
    if !init
    {
        INVALID_POSITION                  := -1
        SCI_START                         := 2000
        SCI_OPTIONAL_START                := 3000
        SCI_LEXER_START                   := 4000
        SCI_ADDTEXT                       := 2001
        SCI_ADDSTYLEDTEXT                 := 2002
        SCI_INSERTTEXT                    := 2003
        SCI_CLEARALL                      := 2004
        SCI_CLEARDOCUMENTSTYLE            := 2005
        SCI_GETLENGTH                     := 2006
        SCI_GETCHARAT                     := 2007
        SCI_GETCURRENTPOS                 := 2008
        SCI_GETANCHOR                     := 2009
        SCI_GETSTYLEAT                    := 2010
        SCI_REDO                          := 2011
        SCI_SETUNDOCOLLECTION             := 2012
        SCI_SELECTALL                     := 2013
        SCI_SETSAVEPOINT                  := 2014
        SCI_GETSTYLEDTEXT                 := 2015
        SCI_CANREDO                       := 2016
        SCI_MARKERLINEFROMHANDLE          := 2017
        SCI_MARKERDELETEHANDLE            := 2018
        SCI_GETUNDOCOLLECTION             := 2019
        SCWS_INVISIBLE                    := 0
        SCWS_VISIBLEALWAYS                := 1
        SCWS_VISIBLEAFTERINDENT           := 2
        SCI_GETVIEWWS                     := 2020
        SCI_SETVIEWWS                     := 2021
        SCI_POSITIONFROMPOINT             := 2022
        SCI_POSITIONFROMPOINTCLOSE        := 2023
        SCI_GOTOLINE                      := 2024
        SCI_GOTOPOS                       := 2025
        SCI_SETANCHOR                     := 2026
        SCI_GETCURLINE                    := 2027
        SCI_GETENDSTYLED                  := 2028
        SC_EOL_CRLF                       := 0
        SC_EOL_CR                         := 1
        SC_EOL_LF                         := 2
        SCI_CONVERTEOLS                   := 2029
        SCI_GETEOLMODE                    := 2030
        SCI_SETEOLMODE                    := 2031
        SCI_STARTSTYLING                  := 2032
        SCI_SETSTYLING                    := 2033
        SCI_GETBUFFEREDDRAW               := 2034
        SCI_SETBUFFEREDDRAW               := 2035
        SCI_SETTABWIDTH                   := 2036
        SCI_GETTABWIDTH                   := 2121
        SC_CP_UTF8                        := 65001
        SC_CP_DBCS                        := 1
        SCI_SETCODEPAGE                   := 2037
        SCI_SETUSEPALETTE                 := 2039
        MARKER_MAX                        := 31
        SC_MARK_CIRCLE                    := 0
        SC_MARK_ROUNDRECT                 := 1
        SC_MARK_ARROW                     := 2
        SC_MARK_SMALLRECT                 := 3
        SC_MARK_SHORTARROW                := 4
        SC_MARK_EMPTY                     := 5
        SC_MARK_ARROWDOWN                 := 6
        SC_MARK_MINUS                     := 7
        SC_MARK_PLUS                      := 8
        SC_MARK_VLINE                     := 9
        SC_MARK_LCORNER                   := 10
        SC_MARK_TCORNER                   := 11
        SC_MARK_BOXPLUS                   := 12
        SC_MARK_BOXPLUSCONNECTED          := 13
        SC_MARK_BOXMINUS                  := 14
        SC_MARK_BOXMINUSCONNECTED         := 15
        SC_MARK_LCORNERCURVE              := 16
        SC_MARK_TCORNERCURVE              := 17
        SC_MARK_CIRCLEPLUS                := 18
        SC_MARK_CIRCLEPLUSCONNECTED       := 19
        SC_MARK_CIRCLEMINUS               := 20
        SC_MARK_CIRCLEMINUSCONNECTED      := 21
        SC_MARK_BACKGROUND                := 22
        SC_MARK_DOTDOTDOT                 := 23
        SC_MARK_ARROWS                    := 24
        SC_MARK_PIXMAP                    := 25
        SC_MARK_FULLRECT                  := 26
        SC_MARK_CHARACTER                 := 10000
        SC_MARKNUM_FOLDEREND              := 25
        SC_MARKNUM_FOLDEROPENMID          := 26
        SC_MARKNUM_FOLDERMIDTAIL          := 27
        SC_MARKNUM_FOLDERTAIL             := 28
        SC_MARKNUM_FOLDERSUB              := 29
        SC_MARKNUM_FOLDER                 := 30
        SC_MARKNUM_FOLDEROPEN             := 31
        SC_MASK_FOLDERS                   := 0xFE000000
        SCI_MARKERDEFINE                  := 2040
        SCI_MARKERSETFORE                 := 2041
        SCI_MARKERSETBACK                 := 2042
        SCI_MARKERADD                     := 2043
        SCI_MARKERDELETE                  := 2044
        SCI_MARKERDELETEALL               := 2045
        SCI_MARKERGET                     := 2046
        SCI_MARKERNEXT                    := 2047
        SCI_MARKERPREVIOUS                := 2048
        SCI_MARKERDEFINEPIXMAP            := 2049
        SCI_MARKERADDSET                  := 2466
        SCI_MARKERSETALPHA                := 2476
        SC_MARGIN_SYMBOL                  := 0
        SC_MARGIN_NUMBER                  := 1
        SCI_SETMARGINTYPEN                := 2240
        SCI_GETMARGINTYPEN                := 2241
        SCI_SETMARGINWIDTHN               := 2242
        SCI_GETMARGINWIDTHN               := 2243
        SCI_SETMARGINMASKN                := 2244
        SCI_GETMARGINMASKN                := 2245
        SCI_SETMARGINSENSITIVEN           := 2246
        SCI_GETMARGINSENSITIVEN           := 2247
        STYLE_DEFAULT                     := 32
        STYLE_LINENUMBER                  := 33
        STYLE_BRACELIGHT                  := 34
        STYLE_BRACEBAD                    := 35
        STYLE_CONTROLCHAR                 := 36
        STYLE_INDENTGUIDE                 := 37
        STYLE_CALLTIP                     := 38
        STYLE_LASTPREDEFINED              := 39
        STYLE_MAX                         := 127
        SC_CHARSET_ANSI                   := 0
        SC_CHARSET_DEFAULT                := 1
        SC_CHARSET_BALTIC                 := 186
        SC_CHARSET_CHINESEBIG5            := 136
        SC_CHARSET_EASTEUROPE             := 238
        SC_CHARSET_GB2312                 := 134
        SC_CHARSET_GREEK                  := 161
        SC_CHARSET_HANGUL                 := 129
        SC_CHARSET_MAC                    := 77
        SC_CHARSET_OEM                    := 255
        SC_CHARSET_RUSSIAN                := 204
        SC_CHARSET_CYRILLIC               := 1251
        SC_CHARSET_SHIFTJIS               := 128
        SC_CHARSET_SYMBOL                 := 2
        SC_CHARSET_TURKISH                := 162
        SC_CHARSET_JOHAB                  := 130
        SC_CHARSET_HEBREW                 := 177
        SC_CHARSET_ARABIC                 := 178
        SC_CHARSET_VIETNAMESE             := 163
        SC_CHARSET_THAI                   := 222
        SC_CHARSET_8859_15                := 1000
        SCI_STYLECLEARALL                 := 2050
        SCI_STYLESETFORE                  := 2051
        SCI_STYLESETBACK                  := 2052
        SCI_STYLESETBOLD                  := 2053
        SCI_STYLESETITALIC                := 2054
        SCI_STYLESETSIZE                  := 2055
        SCI_STYLESETFONT                  := 2056
        SCI_STYLESETEOLFILLED             := 2057
        SCI_STYLEGETFORE                  := 2481
        SCI_STYLEGETBACK                  := 2482
        SCI_STYLEGETBOLD                  := 2483
        SCI_STYLEGETITALIC                := 2484
        SCI_STYLEGETSIZE                  := 2485
        SCI_STYLEGETFONT                  := 2486
        SCI_STYLEGETEOLFILLED             := 2487
        SCI_STYLEGETUNDERLINE             := 2488
        SCI_STYLEGETCASE                  := 2489
        SCI_STYLEGETCHARACTERSET          := 2490
        SCI_STYLEGETVISIBLE               := 2491
        SCI_STYLEGETCHANGEABLE            := 2492
        SCI_STYLEGETHOTSPOT               := 2493
        SCI_STYLERESETDEFAULT             := 2058
        SCI_STYLESETUNDERLINE             := 2059
        SC_CASE_MIXED                     := 0
        SC_CASE_UPPER                     := 1
        SC_CASE_LOWER                     := 2
        SCI_STYLESETCASE                  := 2060
        SCI_STYLESETCHARACTERSET          := 2066
        SCI_STYLESETHOTSPOT               := 2409
        SCI_SETSELFORE                    := 2067
        SCI_SETSELBACK                    := 2068
        SCI_GETSELALPHA                   := 2477
        SCI_SETSELALPHA                   := 2478
        SCI_SETCARETFORE                  := 2069
        SCI_ASSIGNCMDKEY                  := 2070
        SCI_CLEARCMDKEY                   := 2071
        SCI_CLEARALLCMDKEYS               := 2072
        SCI_SETSTYLINGEX                  := 2073
        SCI_STYLESETVISIBLE               := 2074
        SCI_GETCARETPERIOD                := 2075
        SCI_SETCARETPERIOD                := 2076
        SCI_SETWORDCHARS                  := 2077
        SCI_BEGINUNDOACTION               := 2078
        SCI_ENDUNDOACTION                 := 2079
        INDIC_MAX                         := 7
        INDIC_PLAIN                       := 0
        INDIC_SQUIGGLE                    := 1
        INDIC_TT                          := 2
        INDIC_DIAGONAL                    := 3
        INDIC_STRIKE                      := 4
        INDIC_HIDDEN                      := 5
        INDIC_BOX                         := 6
        INDIC_ROUNDBOX                    := 7
        INDIC0_MASK                       := 0x20
        INDIC1_MASK                       := 0x40
        INDIC2_MASK                       := 0x80
        INDICS_MASK                       := 0xE0
        SCI_INDICSETSTYLE                 := 2080
        SCI_INDICGETSTYLE                 := 2081
        SCI_INDICSETFORE                  := 2082
        SCI_INDICGETFORE                  := 2083
        SCI_SETWHITESPACEFORE             := 2084
        SCI_SETWHITESPACEBACK             := 2085
        SCI_SETSTYLEBITS                  := 2090
        SCI_GETSTYLEBITS                  := 2091
        SCI_SETLINESTATE                  := 2092
        SCI_GETLINESTATE                  := 2093
        SCI_GETMAXLINESTATE               := 2094
        SCI_GETCARETLINEVISIBLE           := 2095
        SCI_SETCARETLINEVISIBLE           := 2096
        SCI_GETCARETLINEBACK              := 2097
        SCI_SETCARETLINEBACK              := 2098
        SCI_STYLESETCHANGEABLE            := 2099
        SCI_AUTOCSHOW                     := 2100
        SCI_AUTOCCANCEL                   := 2101
        SCI_AUTOCACTIVE                   := 2102
        SCI_AUTOCPOSSTART                 := 2103
        SCI_AUTOCCOMPLETE                 := 2104
        SCI_AUTOCSTOPS                    := 2105
        SCI_AUTOCSETSEPARATOR             := 2106
        SCI_AUTOCGETSEPARATOR             := 2107
        SCI_AUTOCSELECT                   := 2108
        SCI_AUTOCSETCANCELATSTART         := 2110
        SCI_AUTOCGETCANCELATSTART         := 2111
        SCI_AUTOCSETFILLUPS               := 2112
        SCI_AUTOCSETCHOOSESINGLE          := 2113
        SCI_AUTOCGETCHOOSESINGLE          := 2114
        SCI_AUTOCSETIGNORECASE            := 2115
        SCI_AUTOCGETIGNORECASE            := 2116
        SCI_USERLISTSHOW                  := 2117
        SCI_AUTOCSETAUTOHIDE              := 2118
        SCI_AUTOCGETAUTOHIDE              := 2119
        SCI_AUTOCSETDROPRESTOFWORD        := 2270
        SCI_AUTOCGETDROPRESTOFWORD        := 2271
        SCI_REGISTERIMAGE                 := 2405
        SCI_CLEARREGISTEREDIMAGES         := 2408
        SCI_AUTOCGETTYPESEPARATOR         := 2285
        SCI_AUTOCSETTYPESEPARATOR         := 2286
        SCI_AUTOCSETMAXWIDTH              := 2208
        SCI_AUTOCGETMAXWIDTH              := 2209
        SCI_AUTOCSETMAXHEIGHT             := 2210
        SCI_AUTOCGETMAXHEIGHT             := 2211
        SCI_SETINDENT                     := 2122
        SCI_GETINDENT                     := 2123
        SCI_SETUSETABS                    := 2124
        SCI_GETUSETABS                    := 2125
        SCI_SETLINEINDENTATION            := 2126
        SCI_GETLINEINDENTATION            := 2127
        SCI_GETLINEINDENTPOSITION         := 2128
        SCI_GETCOLUMN                     := 2129
        SCI_SETHSCROLLBAR                 := 2130
        SCI_GETHSCROLLBAR                 := 2131
        SCI_SETINDENTATIONGUIDES          := 2132
        SCI_GETINDENTATIONGUIDES          := 2133
        SCI_SETHIGHLIGHTGUIDE             := 2134
        SCI_GETHIGHLIGHTGUIDE             := 2135
        SCI_GETLINEENDPOSITION            := 2136
        SCI_GETCODEPAGE                   := 2137
        SCI_GETCARETFORE                  := 2138
        SCI_GETUSEPALETTE                 := 2139
        SCI_GETREADONLY                   := 2140
        SCI_SETCURRENTPOS                 := 2141
        SCI_SETSELECTIONSTART             := 2142
        SCI_GETSELECTIONSTART             := 2143
        SCI_SETSELECTIONEND               := 2144
        SCI_GETSELECTIONEND               := 2145
        SCI_SETPRINTMAGNIFICATION         := 2146
        SCI_GETPRINTMAGNIFICATION         := 2147
        SC_PRINT_NORMAL                   := 0
        SC_PRINT_INVERTLIGHT              := 1
        SC_PRINT_BLACKONWHITE             := 2
        SC_PRINT_COLORONWHITE             := 3
        SC_PRINT_COLORONWHITEDEFAULTBG    := 4
        SCI_SETPRINTCOLORMODE             := 2148
        SCI_GETPRINTCOLORMODE             := 2149
        SCFIND_WHOLEWORD                  := 2
        SCFIND_MATCHCASE                  := 4
        SCFIND_WORDSTART                  := 0x00100000
        SCFIND_REGEXP                     := 0x00200000
        SCFIND_POSIX                      := 0x00400000
        SCI_FINDTEXT                      := 2150
        SCI_FORMATRANGE                   := 2151
        SCI_GETFIRSTVISIBLELINE           := 2152
        SCI_GETLINE                       := 2153
        SCI_GETLINECOUNT                  := 2154
        SCI_SETMARGINLEFT                 := 2155
        SCI_GETMARGINLEFT                 := 2156
        SCI_SETMARGINRIGHT                := 2157
        SCI_GETMARGINRIGHT                := 2158
        SCI_GETMODIFY                     := 2159
        SCI_SETSEL                        := 2160
        SCI_GETSELTEXT                    := 2161
        SCI_GETTEXTRANGE                  := 2162
        SCI_HIDESELECTION                 := 2163
        SCI_POINTXFROMPOSITION            := 2164
        SCI_POINTYFROMPOSITION            := 2165
        SCI_LINEFROMPOSITION              := 2166
        SCI_POSITIONFROMLINE              := 2167
        SCI_LINESCROLL                    := 2168
        SCI_SCROLLCARET                   := 2169
        SCI_REPLACESEL                    := 2170
        SCI_SETREADONLY                   := 2171
        SCI_NULL                          := 2172
        SCI_CANPASTE                      := 2173
        SCI_CANUNDO                       := 2174
        SCI_EMPTYUNDOBUFFER               := 2175
        SCI_UNDO                          := 2176
        SCI_CUT                           := 2177
        SCI_COPY                          := 2178
        SCI_PASTE                         := 2179
        SCI_CLEAR                         := 2180
        SCI_SETTEXT                       := 2181
        SCI_GETTEXT                       := 2182
        SCI_GETTEXTLENGTH                 := 2183
        SCI_GETDIRECTFUNCTION             := 2184
        SCI_GETDIRECTPOINTER              := 2185
        SCI_SETOVERTYPE                   := 2186
        SCI_GETOVERTYPE                   := 2187
        SCI_SETCARETWIDTH                 := 2188
        SCI_GETCARETWIDTH                 := 2189
        SCI_SETTARGETSTART                := 2190
        SCI_GETTARGETSTART                := 2191
        SCI_SETTARGETEND                  := 2192
        SCI_GETTARGETEND                  := 2193
        SCI_REPLACETARGET                 := 2194
        SCI_REPLACETARGETRE               := 2195
        SCI_SEARCHINTARGET                := 2197
        SCI_SETSEARCHFLAGS                := 2198
        SCI_GETSEARCHFLAGS                := 2199
        SCI_CALLTIPSHOW                   := 2200
        SCI_CALLTIPCANCEL                 := 2201
        SCI_CALLTIPACTIVE                 := 2202
        SCI_CALLTIPPOSSTART               := 2203
        SCI_CALLTIPSETHLT                 := 2204
        SCI_CALLTIPSETBACK                := 2205
        SCI_CALLTIPSETFORE                := 2206
        SCI_CALLTIPSETFOREHLT             := 2207
        SCI_CALLTIPUSESTYLE               := 2212
        SCI_VISIBLEFROMDOCLINE            := 2220
        SCI_DOCLINEFROMVISIBLE            := 2221
        SCI_WRAPCOUNT                     := 2235
        SC_FOLDLEVELBASE                  := 0x400
        SC_FOLDLEVELWHITEFLAG             := 0x1000
        SC_FOLDLEVELHEADERFLAG            := 0x2000
        SC_FOLDLEVELBOXHEADERFLAG         := 0x4000
        SC_FOLDLEVELBOXFOOTERFLAG         := 0x8000
        SC_FOLDLEVELCONTRACTED            := 0x10000
        SC_FOLDLEVELUNINDENT              := 0x20000
        SC_FOLDLEVELNUMBERMASK            := 0x0FFF
        SCI_SETFOLDLEVEL                  := 2222
        SCI_GETFOLDLEVEL                  := 2223
        SCI_GETLASTCHILD                  := 2224
        SCI_GETFOLDPARENT                 := 2225
        SCI_SHOWLINES                     := 2226
        SCI_HIDELINES                     := 2227
        SCI_GETLINEVISIBLE                := 2228
        SCI_SETFOLDEXPANDED               := 2229
        SCI_GETFOLDEXPANDED               := 2230
        SCI_TOGGLEFOLD                    := 2231
        SCI_ENSUREVISIBLE                 := 2232
        SC_FOLDFLAG_LINEBEFORE_EXPANDED   := 0x0002
        SC_FOLDFLAG_LINEBEFORE_CONTRACTED := 0x0004
        SC_FOLDFLAG_LINEAFTER_EXPANDED    := 0x0008
        SC_FOLDFLAG_LINEAFTER_CONTRACTED  := 0x0010
        SC_FOLDFLAG_LEVELNUMBERS          := 0x0040
        SC_FOLDFLAG_BOX                   := 0x0001
        SCI_SETFOLDFLAGS                  := 2233
        SCI_ENSUREVISIBLEENFORCEPOLICY    := 2234
        SCI_SETTABINDENTS                 := 2260
        SCI_GETTABINDENTS                 := 2261
        SCI_SETBACKSPACEUNINDENTS         := 2262
        SCI_GETBACKSPACEUNINDENTS         := 2263
        SC_TIME_FOREVER                   := 10000000
        SCI_SETMOUSEDWELLTIME             := 2264
        SCI_GETMOUSEDWELLTIME             := 2265
        SCI_WORDSTARTPOSITION             := 2266
        SCI_WORDENDPOSITION               := 2267
        SC_WRAP_NONE                      := 0
        SC_WRAP_WORD                      := 1
        SC_WRAP_CHAR                      := 2
        SCI_SETWRAPMODE                   := 2268
        SCI_GETWRAPMODE                   := 2269
        SC_WRAPVISUALFLAG_NONE            := 0x0000
        SC_WRAPVISUALFLAG_END             := 0x0001
        SC_WRAPVISUALFLAG_START           := 0x0002
        SCI_SETWRAPVISUALFLAGS            := 2460
        SCI_GETWRAPVISUALFLAGS            := 2461
        SC_WRAPVISUALFLAGLOC_DEFAULT      := 0x0000
        SC_WRAPVISUALFLAGLOC_END_BY_TEXT  := 0x0001
        SC_WRAPVISUALFLAGLOC_START_BY_TEXT:= 0x0002
        SCI_SETWRAPVISUALFLAGSLOCATION    := 2462
        SCI_GETWRAPVISUALFLAGSLOCATION    := 2463
        SCI_SETWRAPSTARTINDENT            := 2464
        SCI_GETWRAPSTARTINDENT            := 2465
        SC_CACHE_NONE                     := 0
        SC_CACHE_CARET                    := 1
        SC_CACHE_PAGE                     := 2
        SC_CACHE_DOCUMENT                 := 3
        SCI_SETLAYOUTCACHE                := 2272
        SCI_GETLAYOUTCACHE                := 2273
        SCI_SETSCROLLWIDTH                := 2274
        SCI_GETSCROLLWIDTH                := 2275
        SCI_TEXTWIDTH                     := 2276
        SCI_SETENDATLASTLINE              := 2277
        SCI_GETENDATLASTLINE              := 2278
        SCI_TEXTHEIGHT                    := 2279
        SCI_SETVSCROLLBAR                 := 2280
        SCI_GETVSCROLLBAR                 := 2281
        SCI_APPENDTEXT                    := 2282
        SCI_GETTWOPHASEDRAW               := 2283
        SCI_SETTWOPHASEDRAW               := 2284
        SCI_TARGETFROMSELECTION           := 2287
        SCI_LINESJOIN                     := 2288
        SCI_LINESSPLIT                    := 2289
        SCI_SETFOLDMARGINCOLOR            := 2290
        SCI_SETFOLDMARGINHICOLOR          := 2291
        SCI_LINEDOWN                      := 2300
        SCI_LINEDOWNEXTEND                := 2301
        SCI_LINEUP                        := 2302
        SCI_LINEUPEXTEND                  := 2303
        SCI_CHARLEFT                      := 2304
        SCI_CHARLEFTEXTEND                := 2305
        SCI_CHARRIGHT                     := 2306
        SCI_CHARRIGHTEXTEND               := 2307
        SCI_WORDLEFT                      := 2308
        SCI_WORDLEFTEXTEND                := 2309
        SCI_WORDRIGHT                     := 2310
        SCI_WORDRIGHTEXTEND               := 2311
        SCI_HOME                          := 2312
        SCI_HOMEEXTEND                    := 2313
        SCI_LINEEND                       := 2314
        SCI_LINEENDEXTEND                 := 2315
        SCI_DOCUMENTSTART                 := 2316
        SCI_DOCUMENTSTARTEXTEND           := 2317
        SCI_DOCUMENTEND                   := 2318
        SCI_DOCUMENTENDEXTEND             := 2319
        SCI_PAGEUP                        := 2320
        SCI_PAGEUPEXTEND                  := 2321
        SCI_PAGEDOWN                      := 2322
        SCI_PAGEDOWNEXTEND                := 2323
        SCI_EDITTOGGLEOVERTYPE            := 2324
        SCI_CANCEL                        := 2325
        SCI_DELETEBACK                    := 2326
        SCI_TAB                           := 2327
        SCI_BACKTAB                       := 2328
        SCI_NEWLINE                       := 2329
        SCI_FORMFEED                      := 2330
        SCI_VCHOME                        := 2331
        SCI_VCHOMEEXTEND                  := 2332
        SCI_ZOOMIN                        := 2333
        SCI_ZOOMOUT                       := 2334
        SCI_DELWORDLEFT                   := 2335
        SCI_DELWORDRIGHT                  := 2336
        SCI_LINECUT                       := 2337
        SCI_LINEDELETE                    := 2338
        SCI_LINETRANSPOSE                 := 2339
        SCI_LINEDUPLICATE                 := 2404
        SCI_LOWERCASE                     := 2340
        SCI_UPPERCASE                     := 2341
        SCI_LINESCROLLDOWN                := 2342
        SCI_LINESCROLLUP                  := 2343
        SCI_DELETEBACKNOTLINE             := 2344
        SCI_HOMEDISPLAY                   := 2345
        SCI_HOMEDISPLAYEXTEND             := 2346
        SCI_LINEENDDISPLAY                := 2347
        SCI_LINEENDDISPLAYEXTEND          := 2348
        SCI_HOMEWRAP                      := 2349
        SCI_HOMEWRAPEXTEND                := 2450
        SCI_LINEENDWRAP                   := 2451
        SCI_LINEENDWRAPEXTEND             := 2452
        SCI_VCHOMEWRAP                    := 2453
        SCI_VCHOMEWRAPEXTEND              := 2454
        SCI_LINECOPY                      := 2455
        SCI_MOVECARETINSIDEVIEW           := 2401
        SCI_LINELENGTH                    := 2350
        SCI_BRACEHIGHLIGHT                := 2351
        SCI_BRACEBADLIGHT                 := 2352
        SCI_BRACEMATCH                    := 2353
        SCI_GETVIEWEOL                    := 2355
        SCI_SETVIEWEOL                    := 2356
        SCI_GETDOCPOINTER                 := 2357
        SCI_SETDOCPOINTER                 := 2358
        SCI_SETMODEVENTMASK               := 2359
        EDGE_NONE                         := 0
        EDGE_LINE                         := 1
        EDGE_BACKGROUND                   := 2
        SCI_GETEDGECOLUMN                 := 2360
        SCI_SETEDGECOLUMN                 := 2361
        SCI_GETEDGEMODE                   := 2362
        SCI_SETEDGEMODE                   := 2363
        SCI_GETEDGECOLOR                  := 2364
        SCI_SETEDGECOLOR                  := 2365
        SCI_SEARCHANCHOR                  := 2366
        SCI_SEARCHNEXT                    := 2367
        SCI_SEARCHPREV                    := 2368
        SCI_LINESONSCREEN                 := 2370
        SCI_USEPOPUP                      := 2371
        SCI_SELECTIONISRECTANGLE          := 2372
        SCI_SETZOOM                       := 2373
        SCI_GETZOOM                       := 2374
        SCI_CREATEDOCUMENT                := 2375
        SCI_ADDREFDOCUMENT                := 2376
        SCI_RELEASEDOCUMENT               := 2377
        SCI_GETMODEVENTMASK               := 2378
        SCI_SETFOCUS                      := 2380
        SCI_GETFOCUS                      := 2381
        SCI_SETSTATUS                     := 2382
        SCI_GETSTATUS                     := 2383
        SCI_SETMOUSEDOWNCAPTURES          := 2384
        SCI_GETMOUSEDOWNCAPTURES          := 2385
        SC_CURSORNORMAL                   := -1
        SC_CURSORWAIT                     := 4
        SCI_SETCURSOR                     := 2386
        SCI_GETCURSOR                     := 2387
        SCI_SETCONTROLCHARSYMBOL          := 2388
        SCI_GETCONTROLCHARSYMBOL          := 2389
        SCI_WORDPARTLEFT                  := 2390
        SCI_WORDPARTLEFTEXTEND            := 2391
        SCI_WORDPARTRIGHT                 := 2392
        SCI_WORDPARTRIGHTEXTEND           := 2393
        VISIBLE_SLOP                      := 0x01
        VISIBLE_STRICT                    := 0x04
        SCI_SETVISIBLEPOLICY              := 2394
        SCI_DELLINELEFT                   := 2395
        SCI_DELLINERIGHT                  := 2396
        SCI_SETXOFFSET                    := 2397
        SCI_GETXOFFSET                    := 2398
        SCI_CHOOSECARETX                  := 2399
        SCI_GRABFOCUS                     := 2400
        CARET_SLOP                        := 0x01
        CARET_STRICT                      := 0x04
        CARET_JUMPS                       := 0x10
        CARET_EVEN                        := 0x08
        SCI_SETXCARETPOLICY               := 2402
        SCI_SETYCARETPOLICY               := 2403
        SCI_SETPRINTWRAPMODE              := 2406
        SCI_GETPRINTWRAPMODE              := 2407
        SCI_SETHOTSPOTACTIVEFORE          := 2410
        SCI_SETHOTSPOTACTIVEBACK          := 2411
        SCI_SETHOTSPOTACTIVEUNDERLINE     := 2412
        SCI_SETHOTSPOTSINGLELINE          := 2421
        SCI_PARADOWN                      := 2413
        SCI_PARADOWNEXTEND                := 2414
        SCI_PARAUP                        := 2415
        SCI_PARAUPEXTEND                  := 2416
        SCI_POSITIONBEFORE                := 2417
        SCI_POSITIONAFTER                 := 2418
        SCI_COPYRANGE                     := 2419
        SCI_COPYTEXT                      := 2420
        SC_SEL_STREAM                     := 0
        SC_SEL_RECTANGLE                  := 1
        SC_SEL_LINES                      := 2
        SCI_SETSELECTIONMODE              := 2422
        SCI_GETSELECTIONMODE              := 2423
        SCI_GETLINESELSTARTPOSITION       := 2424
        SCI_GETLINESELENDPOSITION         := 2425
        SCI_LINEDOWNRECTEXTEND            := 2426
        SCI_LINEUPRECTEXTEND              := 2427
        SCI_CHARLEFTRECTEXTEND            := 2428
        SCI_CHARRIGHTRECTEXTEND           := 2429
        SCI_HOMERECTEXTEND                := 2430
        SCI_VCHOMERECTEXTEND              := 2431
        SCI_LINEENDRECTEXTEND             := 2432
        SCI_PAGEUPRECTEXTEND              := 2433
        SCI_PAGEDOWNRECTEXTEND            := 2434
        SCI_STUTTEREDPAGEUP               := 2435
        SCI_STUTTEREDPAGEUPEXTEND         := 2436
        SCI_STUTTEREDPAGEDOWN             := 2437
        SCI_STUTTEREDPAGEDOWNEXTEND       := 2438
        SCI_WORDLEFTEND                   := 2439
        SCI_WORDLEFTENDEXTEND             := 2440
        SCI_WORDRIGHTEND                  := 2441
        SCI_WORDRIGHTENDEXTEND            := 2442
        SCI_SETWHITESPACECHARS            := 2443
        SCI_SETCHARSDEFAULT               := 2444
        SCI_AUTOCGETCURRENT               := 2445
        SCI_ALLOCATE                      := 2446
        SCI_TARGETASUTF8                  := 2447
        SCI_SETLENGTHFORENCODE            := 2448
        SCI_ENCODEDFROMUTF8               := 2449
        SCI_FINDCOLUMN                    := 2456
        SCI_GETCARETSTICKY                := 2457
        SCI_SETCARETSTICKY                := 2458
        SCI_TOGGLECARETSTICKY             := 2459
        SCI_SETPASTECONVERTENDINGS        := 2467
        SCI_GETPASTECONVERTENDINGS        := 2468
        SCI_SELECTIONDUPLICATE            := 2469
        SC_ALPHA_TRANSPARENT              := 0
        SC_ALPHA_OPAQUE                   := 255
        SC_ALPHA_NOALPHA                  := 256
        SCI_SETCARETLINEBACKALPHA         := 2470
        SCI_GETCARETLINEBACKALPHA         := 2471
        SCI_STARTRECORD                   := 3001
        SCI_STOPRECORD                    := 3002
        SCI_SETLEXER                      := 4001
        SCI_GETLEXER                      := 4002
        SCI_COLORISE                      := 4003
        SCI_SETPROPERTY                   := 4004
        KEYWORDSET_MAX                    := 8
        SCI_SETKEYWORDS                   := 4005
        SCI_SETLEXERLANGUAGE              := 4006
        SCI_LOADLEXERLIBRARY              := 4007
        SCI_GETPROPERTY                   := 4008
        SCI_GETPROPERTYEXPANDED           := 4009
        SCI_GETPROPERTYINT                := 4010
        SCI_GETSTYLEBITSNEEDED            := 4011
        SC_MOD_INSERTTEXT                 := 0x1
        SC_MOD_DELETETEXT                 := 0x2
        SC_MOD_CHANGESTYLE                := 0x4
        SC_MOD_CHANGEFOLD                 := 0x8
        SC_PERFORMED_USER                 := 0x10
        SC_PERFORMED_UNDO                 := 0x20
        SC_PERFORMED_REDO                 := 0x40
        SC_MULTISTEPUNDOREDO              := 0x80
        SC_LASTSTEPINUNDOREDO             := 0x100
        SC_MOD_CHANGEMARKER               := 0x200
        SC_MOD_BEFOREINSERT               := 0x400
        SC_MOD_BEFOREDELETE               := 0x800
        SC_MULTILINEUNDOREDO              := 0x1000
        SC_MODEVENTMASKALL                := 0x1FFF
        SCEN_CHANGE                       := 768
        SCEN_SETFOCUS                     := 512
        SCEN_KILLFOCUS                    := 256
        SCK_DOWN                          := 300
        SCK_UP                            := 301
        SCK_LEFT                          := 302
        SCK_RIGHT                         := 303
        SCK_HOME                          := 304
        SCK_END                           := 305
        SCK_PRIOR                         := 306
        SCK_NEXT                          := 307
        SCK_DELETE                        := 308
        SCK_INSERT                        := 309
        SCK_ESCAPE                        := 7
        SCK_BACK                          := 8
        SCK_TAB                           := 9
        SCK_RETURN                        := 13
        SCK_ADD                           := 310
        SCK_SUBTRACT                      := 311
        SCK_DIVIDE                        := 312
        SCMOD_NORM                        := 0
        SCMOD_SHIFT                       := 1
        SCMOD_CTRL                        := 2
        SCMOD_ALT                         := 4
    }

    if !%hwnd%_df
	{
        SendMessage, SCI_GETDIRECTFUNCTION,0,0,,ahk_id %hwnd%
        %hwnd%_df := ErrorLevel
        SendMessage, SCI_GETDIRECTPOINTER,0,0,,ahk_id %hwnd%
        %hwnd%_dp := ErrorLevel
	}

    ; The fast way to control Scintilla
    return DllCall(%hwnd%_df
                  ,"UInt" ,%hwnd%_dp
                  ,"Int"  ,%msg%
                  ,"UInt" ,wParam
                  ,"UInt" ,lParam)
}

