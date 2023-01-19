global GUI_Open := 0
global GUI_Handle

arms_left := ["╰", "ヽ", "\", "੧", "⋋", "ლ", "ლ", "ᕙ", "୧", "┌"
    , "└", "٩", "ᕦ", "へ", "¯\_", "╚", "═", "c", "乁", "o͡͡͡╮"]
arms_right := ["╯", "ﾉ", "ノ", "/", "੭", "⋌", "⊃", "つ", "ᕗ", "୨", "┐", "┘", "و"
    , "ง", "ᕤ", "ᓄ", "_/¯", "═╝", "ㄏ", "ᕤ", "╭", "o͡͡͡", "ノ", "⌒", "."]
arms_symmetric := ["凸", "〜", "┌∩┐", "∩", "╭∩╮"]
bodies_left := ["(", "[", "༼", "ʕ", "໒(", "/"]
bodies_right := [")", "]", "༽", "ʔ", ")७", "\"]
bodies_symmetric := ["|", "⁞", "།", "།", "║"]
cheeks := [".", "✿", "˵", "v", ">", "<", "*", "”", "=", "~", "∗", ":"]
eyes := ["^", "＾", "o", "°", "•́", "•̀", "*", "ಥ", "O͡"
    , "ݓ", "☆", "･", "・", "﹒", "՞", "︣", "⌣", "@"]
mouths_and_noses := ["ω", "_", "ਊ", "︿", "o", "〜", "〰"
    , "∧", "д", "۝", "ڡ", "ʖ", "▽", "∀", "◡"]

get_emojis(search_str) {
    FileRead contents, %A_ScriptFullPath%
    f_lines := StrSplit(contents, "`n", "`r")
    l := f_lines.Length()

    emojis := ""
    idx := 0
    Loop % l {
        line := f_lines[l--]

        ; look for hotstring pattern
        If (SubStr(line, 1, 1) == ":") {
            parts := StrSplit(line, ":`:")
            name := SubStr(parts[1], 5)

            ; add if search string is a substring
            If (InStr(name, search_str)){
                emoji := parts[2]
                emojis .= name "`t" emoji
                ; two columns
                If (Mod(idx, 2) == 0)
                    emojis .= "`t`t`t"
                Else
                    emojis .= "`n"
            }
        } Else {
            Break
        }
        idx++
    }

    Return % emojis
}

row(name, arr, offset, x_pos, y_pos, max=10) {
    global
    Gui, Add, Text, x%x_pos% y%y_pos%, %name%
    For idx, element in arr {
        ; idx is not 0 indexed
        idx--
        btn_id := idx + offset
        If (Mod(idx, max) != 0) {
            Gui, Add, Button, x+5 yp w20 v%btn_id% gEmojiBtn, %element%
        } Else {
            Gui, Add, Button, x%x_pos% y+10 w20 v%btn_id% gEmojiBtn, %element%
        }
    }

    Return arr.Length()
}

::$e::
    Sleep 1
    If (GUI_Open) {
        WinActivate % "ahk_id " GUI_Handle
    } Else {
        GUI_Open := 1
        Gui Add, Tab, w550 h525 Theme, Search|Add|Options
        Gui Font, s, Arial
        Gui Show, Center, Emoji Palette

        Gui Tab, Search
        Gui Add, Edit, vSearchBar w300
        Gui Add, Edit, vDisplay VScroll h450 w525 y+15 xp ReadOnly, % get_emojis("")
        Gui Add, Button, gSearchBtn w75 h25 xp+310 yp-40, Search

        Gui Tab, Add
        Gui, Add, Text, , Name
        Gui Add, Edit, vNameBar w150 xp+50 yp
        Gui, Add, Text, xp+160 yp, Emoji
        Gui Add, Edit, vEmojiBar w200 xp+50 yp
        Gui Add, Button, gAddBtn w50 h50 xp+210 yp, Add
        Gui Add, Button, gRandomBtn w150 h50 x400 y450, Random Emoji

        btn_count := 0
        btn_count += row("Arms Left", arms_left, btn_count, 20, 75)
        btn_count += row("Arms Right", arms_right, btn_count, 290, 75)
        btn_count += row("Arms Symmetric", arms_symmetric, btn_count, 20, 200)
        btn_count += row("Bodies Left", bodies_left, btn_count, 290, 200)
        btn_count += row("Bodies Right", bodies_right, btn_count, 20, 275)
        btn_count += row("Bodies Symmetric", bodies_symmetric, btn_count, 290, 275)
        btn_count += row("Cheeks", cheeks, btn_count, 20, 350)
        btn_count += row("Eyes", eyes, btn_count, 290, 350)
        btn_count += row("Mouths and Noses", mouths_and_noses, btn_count, 20, 450, 20)

        Gui Tab, Options
        Gui, Add, CheckBox, vSymmetricRandEmoji, Symmetrical Random Emojis
        Gui Add, Button, gReloadBtn w100 h50 x250 y250, Reload

        GUI_Handle := WinExist("A")
    }
Return

SearchBtn:
    Gui Submit, NoHide
    GuiControl, , Display, % get_emojis(SearchBar)
Return

AddBtn:
    Gui Submit, NoHide

    If (StrLen(NameBar) >= 39) {
        MsgBox The name is too long
        Return
    } Else If (NameBar == "" or EmojiBar == "") {
        MsgBox The name or emoji field is empty
        Return
    }

    FileAppend, `n:OC:$%NameBar%:`:%EmojiBar%, %A_ScriptFullPath%, UTF-8
    GuiControl, , NameBar,
    GuiControl, , EmojiBar,
Return

EmojiBtn:
    Gui Submit, NoHide
    GuiControlGet, emoji_char, , % A_GuiControl
    GuiControl, , EmojiBar, %EmojiBar%%emoji_char%
Return

ReloadBtn:
    Reload
Return

get_rand(arr) {
    Random rand, 1, arr.Length()
    Return arr[rand]
}
RandomBtn:
    Gui, Submit, NoHide
    ; reset emoji bar
    GuiControl, , EmojiBar,
    Random arm_l, 0, 1
    Random arm_r, 0, 1
    Random body_l, 0, 1
    Random body_r, 0, 1

    rand_emoji := ""
    If SymmetricRandEmoji {
        arm := get_rand(arms_symmetric)
        body := get_rand(bodies_symmetric)
        cheek := get_rand(cheeks)
        eye := get_rand(eyes)
        mouth := get_rand(mouths_and_noses)

        rand_emoji = %arm%%body%%cheek%%eye%%mouth%%eye%%cheek%%body%%arm%

    } Else {
        If arm_l
            rand_emoji .= get_rand(arms_left)
        Else
            rand_emoji .= get_rand(arms_symmetric)

        If body_l
            rand_emoji .= get_rand(bodies_left)
        Else
            rand_emoji .= get_rand(bodies_symmetric)

        rand_emoji .= get_rand(cheeks)
        rand_emoji .= get_rand(eyes)
        rand_emoji .= get_rand(mouths_and_noses)
        rand_emoji .= get_rand(eyes)
        rand_emoji .= get_rand(cheeks)

        If body_r
            rand_emoji .= get_rand(bodies_right)
        Else
            rand_emoji .= get_rand(bodies_symmetric)

        If arm_r
            rand_emoji .= get_rand(arms_right)
        Else
            rand_emoji .= get_rand(arms_symmetric)
    }

    GuiControl, , EmojiBar, %rand_emoji%
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