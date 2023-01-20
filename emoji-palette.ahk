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
    Loop % l {
        line := f_lines[l--]

        ; look for hotstring pattern
        If (SubStr(line, 1, 1) == ":") {
            parts := StrSplit(line, ":`:")
            name := SubStr(parts[1], 5)

            ; add if search string is a substring
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

    ; escape all special characters
    emoji := EmojiBar
    ; first add backtick to backticks
    emoji := RegExReplace(emoji, "``", "``$0")
    ; these only need a backtick
    emoji := RegExReplace(emoji, "[;:]", "``$0")
    ; these ones need to also be enclosed in curly braces
    emoji := RegExReplace(emoji, "[{}^+!#]", "``{$0}")

    FileAppend, `n:OC:$%NameBar%:`:%emoji%, %A_ScriptFullPath%, UTF-8
    GuiControl, , NameBar
    GuiControl, , EmojiBar
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
:OC:$innocent::ʘ‿ʘ
:OC:$reddit_disapproval::ಠ_ಠ
:OC:$table_flip::(╯°□°）╯︵ ┻━┻
:OC:$put_table_back::┬─┬ ノ( ゜-゜ノ)
:OC:$tidy_up::┬─┬⃰͡ (ᵔᵕᵔ͜ )
:OC:$double_flip::┻━┻ ︵ヽ(``Д´)ﾉ︵ ┻━┻
:OC:$fisticuffs::ლ(｀ー´ლ)
:OC:$cute_bear::ʕ•ᴥ•ʔ
:OC:$squinting_bear::ʕᵔᴥᵔʔ
:OC:$GTFO_bear::ʕ •``ᴥ•´ʔ
:OC:$cute_big_eyes::(｡◕‿◕｡)
:OC:$surprised::（　ﾟДﾟ）
:OC:$shrug::¯\_(ツ)_/¯
:OC:$meh::¯\(°_o)/¯
:OC:$perky::(``･ω･´)
:OC:$angry::(╬ ಠ益ಠ)
:OC:$at_what_cost::ლ(ಠ益ಠლ)
:OC:$excited::☜(⌒▽⌒)☞
:OC:$running::ε=ε=ε=┌(`;*´Д``)ﾉ
:OC:$happy::ヽ(´▽``)/
:OC:$basking_in_glory::ヽ(´ー｀)ノ
:OC:$kitty::ᵒᴥᵒ{#}
:OC:$fido::V•ᴥ•V
:OC:$meow::ฅ{^}•ﻌ•{^}ฅ
:OC:$cheers::（ {^}_{^}）o自自o（{^}_{^} ）
:OC:$devious_smile::ಠ‿ಠ
:OC:$4chan_emoticon::( ͡° ͜ʖ ͡°)
:OC:$crying::ಥ_ಥ
:OC:$happy_crying::ಥ‿ಥ
:OC:$breakdown::ಥ﹏ಥ
:OC:$disagree::٩◔̯◔۶
:OC:$flexing::ᕙ(⇀‸↼‶)ᕗ
:OC:$do_you_even_lift_bro::ᕦ(ò_óˇ)ᕤ
:OC:$kirby::⊂(◉‿◉)つ
:OC:$tripping_out::q(❂‿❂)p
:OC:$discombobulated::⊙﹏⊙
:OC:$sad_confused::¯\_(⊙︿⊙)_/¯
:OC:$japanese_lion_face::°‿‿°
:OC:$confused::¿ⓧ_ⓧﮌ
:OC:$confused_scratch::(⊙.☉)7
:OC:$worried::(´･_･``)
:OC:$dear_god_why::щ（ﾟДﾟщ）
:OC:$staring::٩(๏_๏)۶
:OC:$pretty_eyes::ఠ_ఠ
:OC:$strut::ᕕ( ᐛ )ᕗ
:OC:$zoned::(⊙_◎)
:OC:$crazy::ミ●﹏☉ミ
:OC:$trolling::༼∵༽ ༼⍨༽ ༼⍢༽ ༼⍤༽
:OC:$angry_troll::ヽ༼ ಠ益ಠ ༽ﾉ
:OC:$fuck_it::t(-_-t)
:OC:$sad_face::(ಥ⌣ಥ)
:OC:$hugger::(づ￣ ³￣)づ
:OC:$stranger_danger::(づ｡◕‿‿◕｡)づ
:OC:$flip_friend::(ノಠ ∩ಠ)ノ彡( \o°o)\
:OC:$cry_face::｡ﾟ( ﾟஇ‸இﾟ)ﾟ｡
:OC:$cry_troll::༼ ༎ຶ ෴ ༎ຶ༽
:OC:$TGIF::“ヽ(´▽｀)ノ”
:OC:$dancing::┌(ㆆ㉨ㆆ)ʃ
:OC:$sleepy::눈_눈
:OC:$angry_birds::( ఠൠఠ )ﾉ
:OC:$no_support::乁( ◔ ౪◔)「 ┑(￣Д ￣)┍
:OC:$shy::(๑•́ ₃ •̀๑)
:OC:$fly_away::⁽⁽ଘ( ˊᵕˋ )ଓ⁾⁾
:OC:$careless::◔_◔
:OC:$love::♥‿♥
:OC:$touchy_feely::ԅ(≖‿≖ԅ)
:OC:$kissing::( ˘ ³˘)♥
:OC:$shark_face::( ˇ෴ˇ )
:OC:$emo_dance::ヾ(-_- )ゞ
:OC:$dance::♪♪ ヽ(ˇ∀ˇ )ゞ
:OC:$opera::ヾ(´〇``)ﾉ♪♪♪
:OC:$winnie_the_pooh::ʕ •́؈•̀)
:OC:$boxing::ლ(•́•́ლ)
:OC:$fight::(ง'̀-'́)ง
:OC:$headphones::◖ᵔᴥᵔ◗ ♪ ♫
:OC:$robot::`{{}•̃_•̃`{}}
:OC:$seal::(ᵔᴥᵔ)
:OC:$questionable::(Ծ‸ Ծ)
:OC:$winning::(•̀ᴗ•́)و ̑̑
:OC:$zombie::[¬º-°]¬
:OC:$pointing::(☞ﾟヮﾟ)☞
:OC:$chasing::''⌐(ಠ۾ಠ)¬'''
:OC:$whistling::(っ•́｡•́)♪♬
:OC:$injured::(҂◡_◡)
:OC:$creeper::ƪ(ړײ)ƪ​​
:OC:$eye_roll::⥀.⥀
:OC:$flying::ح˚௰˚づ
:OC:$can't_be_unseen::♨_♨
:OC:$looking down::(._.)
:OC:$im_a_hugger::(⊃｡•́‿•̀｡)⊃
:OC:$wizard::(∩｀-´)⊃━☆ﾟ.*･｡ﾟ
:OC:$yum::(っ˘ڡ˘ς)
:OC:$judging::( ఠ ͟ʖ ఠ)
:OC:$tired::( ͡ಠ ʖ̯ ͡ಠ)
:OC:$dislike::( ಠ ʖ̯ ಠ)
:OC:$hitchhiking::(งツ)ว
:OC:$satisfied::(◠﹏◠)
:OC:$sad_crying::(ᵟຶ︵ ᵟຶ)
:OC:$stunna_shades::(っ▀¯▀)つ
:OC:$chicken::ʚ(•｀
:OC:$barf::(´ж｀ς)
:OC:$fuck_off::(° ͜ʖ͡°)╭∩╮
:OC:$smiley_toast::ʕʘ̅͜ʘ̅ʔ
:OC:$exorcism::ح(•̀ж•́)ง †
:OC:$love::-``ღ´-
:OC:$straining::(⩾﹏⩽)
:OC:$dab::ヽ( •_)ᕗ
:OC:$wave_dance::~({^}-{^})~
:OC:$happy_hug::\(ᵔᵕᵔ)/
:OC:$eye_rest::ᴖ̮ ̮ᴖ
:OC:$peepers::ಠಠ
:OC:$judgemental::`{{}ಠʖಠ`{}}