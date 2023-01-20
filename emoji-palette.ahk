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
            name := SubStr(parts[1], 6)

            ; add if search string is a substring
            If (InStr(name, search_str)){
                emoji := parts[2]
                ; add to beginning of string
                emojis := name ": " emoji "`n" . emojis
            }
        } Else {
            Break
        }
    }

    ; remove last newline
    Return % SubStr(emojis, 1, StrLen(emojis) - 1)
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

::$emoji_palette::
    Sleep 1
    If WinExist("ahk_id " gui_id) {
        WinActivate
    } Else {
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

        gui_id := WinExist("A")
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

    ; escape `;: characters
    emoji := EmojiBar
    ; backticks need to be escaped first
    emoji := RegExReplace(emoji, "``", "``$0")
    emoji := RegExReplace(emoji, "[;:]", "``$0")

    FileAppend, `n:OCT:$%NameBar%:`:%emoji%, %A_ScriptFullPath%, UTF-8
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
Return

; O: omit ending character
; C: case sensitive
; T: escape {}^+!# characters
:OCT:$innocent::ʘ‿ʘ
:OCT:$reddit_disapproval::ಠ_ಠ
:OCT:$table_flip::(╯°□°）╯︵ ┻━┻
:OCT:$put_table_back::┬─┬ ノ( ゜-゜ノ)
:OCT:$tidy_up::┬─┬⃰͡ (ᵔᵕᵔ͜ )
:OCT:$double_flip::┻━┻ ︵ヽ(``Д´)ﾉ︵ ┻━┻
:OCT:$fisticuffs::ლ(｀ー´ლ)
:OCT:$cute_bear::ʕ•ᴥ•ʔ
:OCT:$squinting_bear::ʕᵔᴥᵔʔ
:OCT:$GTFO_bear::ʕ •``ᴥ•´ʔ
:OCT:$cute_big_eyes::(｡◕‿◕｡)
:OCT:$surprised::（　ﾟДﾟ）
:OCT:$shrug::¯\_(ツ)_/¯
:OCT:$meh::¯\(°_o)/¯
:OCT:$perky::(``･ω･´)
:OCT:$angry::(╬ ಠ益ಠ)
:OCT:$at_what_cost::ლ(ಠ益ಠლ)
:OCT:$excited::☜(⌒▽⌒)☞
:OCT:$running::ε=ε=ε=┌(`;*´Д``)ﾉ
:OCT:$happy::ヽ(´▽``)/
:OCT:$basking_in_glory::ヽ(´ー｀)ノ
:OCT:$kitty::ᵒᴥᵒ#
:OCT:$fido::V•ᴥ•V
:OCT:$meow::ฅ^•ﻌ•^ฅ
:OCT:$cheers::（ ^_^）o自自o（^_^ ）
:OCT:$devious_smile::ಠ‿ಠ
:OCT:$4chan_emoticon::( ͡° ͜ʖ ͡°)
:OCT:$crying::ಥ_ಥ
:OCT:$happy_crying::ಥ‿ಥ
:OCT:$breakdown::ಥ﹏ಥ
:OCT:$disagree::٩◔̯◔۶
:OCT:$flexing::ᕙ(⇀‸↼‶)ᕗ
:OCT:$do_you_even_lift_bro::ᕦ(ò_óˇ)ᕤ
:OCT:$kirby::⊂(◉‿◉)つ
:OCT:$tripping_out::q(❂‿❂)p
:OCT:$discombobulated::⊙﹏⊙
:OCT:$sad_confused::¯\_(⊙︿⊙)_/¯
:OCT:$japanese_lion_face::°‿‿°
:OCT:$confused::¿ⓧ_ⓧﮌ
:OCT:$confused_scratch::(⊙.☉)7
:OCT:$worried::(´･_･``)
:OCT:$dear_god_why::щ（ﾟДﾟщ）
:OCT:$staring::٩(๏_๏)۶
:OCT:$pretty_eyes::ఠ_ఠ
:OCT:$strut::ᕕ( ᐛ )ᕗ
:OCT:$zoned::(⊙_◎)
:OCT:$crazy::ミ●﹏☉ミ
:OCT:$trolling::༼∵༽ ༼⍨༽ ༼⍢༽ ༼⍤༽
:OCT:$angry_troll::ヽ༼ ಠ益ಠ ༽ﾉ
:OCT:$fuck_it::t(-_-t)
:OCT:$sad_face::(ಥ⌣ಥ)
:OCT:$hugger::(づ￣ ³￣)づ
:OCT:$stranger_danger::(づ｡◕‿‿◕｡)づ
:OCT:$flip_friend::(ノಠ ∩ಠ)ノ彡( \o°o)\
:OCT:$cry_face::｡ﾟ( ﾟஇ‸இﾟ)ﾟ｡
:OCT:$cry_troll::༼ ༎ຶ ෴ ༎ຶ༽
:OCT:$TGIF::“ヽ(´▽｀)ノ”
:OCT:$dancing::┌(ㆆ㉨ㆆ)ʃ
:OCT:$sleepy::눈_눈
:OCT:$angry_birds::( ఠൠఠ )ﾉ
:OCT:$no_support::乁( ◔ ౪◔)「 ┑(￣Д ￣)┍
:OCT:$shy::(๑•́ ₃ •̀๑)
:OCT:$fly_away::⁽⁽ଘ( ˊᵕˋ )ଓ⁾⁾
:OCT:$careless::◔_◔
:OCT:$love::♥‿♥
:OCT:$touchy_feely::ԅ(≖‿≖ԅ)
:OCT:$kissing::( ˘ ³˘)♥
:OCT:$shark_face::( ˇ෴ˇ )
:OCT:$emo_dance::ヾ(-_- )ゞ
:OCT:$dance::♪♪ ヽ(ˇ∀ˇ )ゞ
:OCT:$opera::ヾ(´〇``)ﾉ♪♪♪
:OCT:$winnie_the_pooh::ʕ •́؈•̀)
:OCT:$boxing::ლ(•́•́ლ)
:OCT:$fight::(ง'̀-'́)ง
:OCT:$headphones::◖ᵔᴥᵔ◗ ♪ ♫
:OCT:$seal::(ᵔᴥᵔ)
:OCT:$questionable::(Ծ‸ Ծ)
:OCT:$winning::(•̀ᴗ•́)و ̑̑
:OCT:$zombie::[¬º-°]¬
:OCT:$pointing::(☞ﾟヮﾟ)☞
:OCT:$chasing::''⌐(ಠ۾ಠ)¬'''
:OCT:$whistling::(っ•́｡•́)♪♬
:OCT:$injured::(҂◡_◡)
:OCT:$creeper::ƪ(ړײ)ƪ​​
:OCT:$eye_roll::⥀.⥀
:OCT:$flying::ح˚௰˚づ
:OCT:$can't_be_unseen::♨_♨
:OCT:$looking_down::(._.)
:OCT:$im_a_hugger::(⊃｡•́‿•̀｡)⊃
:OCT:$wizard::(∩｀-´)⊃━☆ﾟ.*･｡ﾟ
:OCT:$yum::(っ˘ڡ˘ς)
:OCT:$judging::( ఠ ͟ʖ ఠ)
:OCT:$tired::( ͡ಠ ʖ̯ ͡ಠ)
:OCT:$dislike::( ಠ ʖ̯ ಠ)
:OCT:$hitchhiking::(งツ)ว
:OCT:$satisfied::(◠﹏◠)
:OCT:$sad_crying::(ᵟຶ︵ ᵟຶ)
:OCT:$stunna_shades::(っ▀¯▀)つ
:OCT:$chicken::ʚ(•｀
:OCT:$barf::(´ж｀ς)
:OCT:$fuck_off::(° ͜ʖ͡°)╭∩╮
:OCT:$smiley_toast::ʕʘ̅͜ʘ̅ʔ
:OCT:$exorcism::ح(•̀ж•́)ง †
:OCT:$love::-``ღ´-
:OCT:$straining::(⩾﹏⩽)
:OCT:$dab::ヽ( •_)ᕗ
:OCT:$wave_dance::~(^-^)~
:OCT:$happy_hug::\(ᵔᵕᵔ)/
:OCT:$eye_rest::ᴖ̮ ̮ᴖ
:OCT:$peepers::ಠಠ
:OCT:$judgemental::{ಠʖಠ}
:OCT:$robot::{•̃_•̃}