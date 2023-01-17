global GUI_Open := 0
global GUI_Handle

get_emojis(search_str) {
    FileRead contents, %A_ScriptFullPath%
    f_lines := StrSplit(contents, "`n", "`r")
    l := f_lines.Length()

    emojis := ""

    Loop % l {
        line := f_lines[l--]

        If (SubStr(line, 1, 1) == ":") {
            parts := StrSplit(line, ":`:")
            name := SubStr(parts[1], 5)

            If (InStr(name, search_str)){
                emoji := parts[2]
                emojis .= name "`t" emoji "`n"
            }

        } Else {
            Break
        }
    }

    Return % emojis

}

::$e::
    If (GUI_Open) {
        Sleep 1
        WinActivate % "ahk_id " GUI_Handle
    } Else {
        GUI_Open := 1
        Gui Add, Tab, w400 h350 Theme, Search|Add|Generate|Options
        Gui Font, s, Arial
        Gui Show, Center, Emoji Palette

        Gui Tab, Search
        Gui Add, Edit, vSearchBar w300,
        Gui Add, Button, gSearchBtn x+5 yp, Search
        Gui Add, Edit, vDisplay VScroll +Wrap h200 w350 x10 y+15 +0x100 ReadOnly, % get_emojis("")

        Gui Tab, Add
        Gui Add, Edit, vNameBar w300,
        Gui Add, Edit, vEmojiBar w300,
        Gui Add, Button, gAddBtn, Add

        GUI_Handle := WinExist("A")
    }
Return

; buttons

SearchBtn:
    Gui Submit, NoHide
    GuiControl, , Display, % get_emojis(SearchBar)
Return

AddBtn:
    Gui Submit, NoHide
    FileAppend, `n:OC:$%NameBar%:`:%EmojiBar%, %A_ScriptFullPath%, UTF-8
    Reload
Return

; when X is pressed

GuiClose:
    Gui Destroy
    GUI_Open := 0
Return

; O: omit ending character
; C: case sensitive
:OC:$heart::<3
:OC:$smile::😀