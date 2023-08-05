#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.



; --- INITIALIZATION ---

#SingleInstance Force
SetTitleMatchMode, 2

global gui_scale
global hwin
global wwin
global xinv
global yinv
global img_path := "img_files\"
actions := [+16, +13, +7, +2, -3, -6, -9, -15]
target_offset := 13
action_offset := [[115, 75], [95,  75], [115, 60], [95,  60], [60,  60], [80,  60], [60,  75], [80,  75]]
xorder_offset := [60, 79, 98]
yorder_offset := [23, 25, 27]
order_gray := 0xC6C6C6
order_frame := [[61, 7], [76, 22]]
order_frame_stride := 19
order_frame_icons := { 1: "order_shrink", 2: "order_upset", 3: "order_bend", 4: "order_punch", 5: "order_hit", 8: "order_draw"}
path := PathfindPremade()


; --- GUI ---

Gui, Add, Text,, Minecraft must not be fullscreen`nfor the script to work!
Gui, Add, Text,, Hotkey:
Gui, Add, Hotkey, Vforge_hotkey
Gui, Add, Text, ym, Minecraft GUI scale:`nHigher value provides higher accuracy.
Gui, Add, Radio, Checked, 2
Gui, Add, Radio,, 3
Gui, Add, Radio, Vgui_scale, 4
Gui, Add, Button, Default w80, Apply
Gui, Show

GuiClose()
{
    ExitApp
}

ButtonApply()
{
    global forge_hotkey
    if forge_hotkey
        Hotkey, %forge_hotkey%, HotkeyPressed, Off
    Gui, Submit, NoHide 
    if forge_hotkey
        Hotkey %forge_hotkey%, HotkeyPressed, On
    else
    {
        MsgBox Please enter a hotkey.
        return
    }
    Gui, Flash
    Sleep 500
    Gui, Flash, Off
    gui_scale++
    return
}

HotkeyPressed()
{
    if not WinExist("Minecraft")
    {
        MsgBox, 48, Error, Could not find a window titled Minecraft.
        return
    }
    WinActivate
    if (Setup() != 0)
    {
        MsgBox, 48, Error, Couldn't find the anvil GUI.
        WinActivate
        return
    }
	target := GetTarget()
    if not target
    {
        MsgBox Please select an item you wish to forge.
        WinActivate
        return
    }
    else
    {
        Forge(target)
    }
    return
}

; --- FUNCTIONS --- 

Setup()
{
    WinGetPos,,, wwin, hwin	
    ImageSearch, xinv, yinv, 0, 0, wwin, hwin, *Trans0x00FFFF %img_path%inventorytop%gui_scale%.png
    return ErrorLevel
}

Forge(target) 
{
    global actions
    ; [1]last [2]prelast [3]preprelast
    last_actions := GetLastActions()
    last_strike_order := GetStrikeOrder()
    last_strike_order := ProcessStrikeOrder(last_strike_order)
    last := []
    Loop, 3
    {
        i := A_Index
        last[i] := last_actions[(GetRowType(last_strike_order[i]))]
        if last[i]
        {
            target -= actions[last[i]]
        }
    }
    seq := GetActionSequence(target)
    seq.Push(last[3])
    seq.Push(last[2])
    seq.Push(last[1])
	ClickActions(seq)

    return
}

GetLastActions()
{
    global order_frame
    global order_frame_stride
    global order_frame_icons
    xtop := xinv + order_frame[1, 1] * gui_scale
    ytop := yinv + order_frame[1, 2] * gui_scale
    xbot := xinv + order_frame[2, 1] * gui_scale
    ybot := yinv + order_frame[2, 2] * gui_scale
    last_actions := []
    WinActivate
    Loop, 3
    {
        for key, filename in order_frame_icons
        {
            found := false
            ImageSearch,,, xtop, ytop, xbot, ybot, *20 %img_path%%filename%%gui_scale%.png
            if not ErrorLevel
            {
                last_actions.Push(key)
                found := true
                break
            }
        }
        if not found
            last_actions.Push(0)
        xtop += order_frame_stride * gui_scale
        xbot += order_frame_stride * gui_scale

    }
    return last_actions
}

GetStrikeOrder()
{
    global xorder_offset
    global yorder_offset
    global order_gray
    ; [1]last [2]prelast [3]preprelast
    last_strike_order := [[], [], []]
    Loop, 3
    {
        i := A_Index
        Loop, 3
        {
            ii := A_Index
            x := xinv + xorder_offset[ii] * gui_scale
            y := yinv + yorder_offset[4 - i] * gui_scale
            PixelGetColor, color, x, y
            last_strike_order[i, ii] := (color != order_gray)
        }
    }
    return last_strike_order
}

ClickActions(seq)
{
    global action_offset
    for i, action in seq
    {
        if not action
        continue
        x := xinv + action_offset[action, 1] * gui_scale
        y := yinv + action_offset[action, 2] * gui_scale
        Click %x% %y%
        Sleep, 10
    }
    return
}

GetActionSequence(target)
{
    global path
    global actions
    i := target + 1
    seq := []
    Loop
    {
        if (i = 1)
            break
        seq.Push(path[i])
        i -= actions[path[i]]
    }
    return seq
}

GetTarget() 
{
    global target_offset
    ImageSearch, xtarget,, 0, 0, wwin, hwin, *Trans0x00FFFF %img_path%targetred%gui_scale%.png
    offset := xinv + target_offset * gui_scale
    return Round((xtarget - offset) / gui_scale)
}

PathfindPremade()
{
    prev := [0, 6, 4, 4, 4, 7, 4, 3, 3, 3, 5, 3, 4, 2, 3, 2, 1, 1, 1, 1, 2, 3, 2, 1, 1, 1, 2, 2, 2, 1, 1, 1, 1, 2, 1, 2, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    return prev
}

ProcessStrikeOrder(matrix)
{
    ; Don't ask.
    matrix := CrossRow(matrix, 1)
    matrix := CrossRow(matrix, 2)
    matrix := CrossRow(matrix, 1)
    matrix := CrossRow(matrix, 2)
    matrix := CrossRow(matrix, 3)
    matrix := CrossRow(matrix, 1)
    matrix := CrossRow(matrix, 2)
    matrix := CrossRow(matrix, 3)

    if ConfirmStrikeOrder(matrix)
        return matrix

    l := GetRowType(matrix[1])
    pl := GetRowType(matrix[2])
    ppl := GetRowType(matrix[3])
    if (l = pl)
        matrix := CrossType(matrix, 1, l)
    else if (l = ppl)
        matrix := CrossType(matrix, 1, l)
    else if (pl = ppl)
        matrix := CrossType(matrix, 2, pl)

    matrix := CrossRow(matrix, 1)
    matrix := CrossRow(matrix, 2)
    matrix := CrossRow(matrix, 3)

    if ConfirmStrikeOrder(matrix)
        return matrix

    matrix := CrossType(matrix, 1, GetRowType(matrix[1]))
    matrix := CrossType(matrix, 2, GetRowType(matrix[2]))
    matrix := CrossType(matrix, 3, GetRowType(matrix[3]))
    if not ConfirmStrikeOrder(matrix)
        MsgBox, 48, Error, Cannot process this sequence of finishing strikes.
    return matrix
}

ConfirmStrikeOrder(matrix)
{
    return (GetRowType(matrix[1]) >= 0 && GetRowType(matrix[2]) >= 0 && GetRowType(matrix[3]) >= 0)
}
    
GetRowType(row)
{
    if ( row[1] && !row[2] && !row[3])
        return 1
    if (!row[1] &&  row[2] && !row[3])
        return 2
    if (!row[1] && !row[2] &&  row[3])
        return 3
    if (!row[1] && !row[2] && !row[3])
        return 0
    if ( row[1] &&  row[2] &&  row[3])
        return -4
    if ( row[1] &&  row[2] && !row[3])
        return -2
    if ( row[1] && !row[2] &&  row[3])
        return -1
    if (!row[1] &&  row[2] &&  row[3])
        return -3
}

CrossRow(matrix, row)
{
    type := GetRowType(matrix[row])
    if (type > 0)
    {
        matrix[1][type] := 0
        matrix[2][type] := 0
        matrix[3][type] := 0
        matrix[row][type] := 1
    }
    return matrix
}

CrossType(matrix, row, type)
{
    if not type
        return
    else if (type = -4)
        type := 1
    else if (type < 0)
        type := -type
    matrix[row][1] := 0
    matrix[row][2] := 0
    matrix[row][3] := 0
    matrix[1][type] := 0
    matrix[2][type] := 0
    matrix[3][type] := 0
    matrix[row][type] := 1
    return matrix
}

; --- UNUSED ---
/*

join( strArray )
{
  s := ""
  for i,v in strArray
    s .= ", " . v
  return substr(s, 3)
}

join2D( strArray2D )
{
  s := ""
  for i,array in strArray2D
    s .= ", [" . join(array) . "]"
  return substr(s, 3)
}

Pathfind()
{
    global actions
    queue := []
    arrlen := 151
    visited := []
    prev := []
    dist := []
    Loop % arrlen
    {
        prev[A_Index] := -1
        dist[A_Index] := 10000
        visited[A_Index] := false
    }
    prev[1] := 0
    dist[1] := 0

    ; Dijkstra's algorithm
    Loop
    {
        ; Find minimal dist among non-visited

        i := -1
        min_dist := 10000
        Loop % arrlen
        {
            ii := A_Index
            if ((not visited[ii]) && (dist[ii] < min_dist))
            {
                min_dist := dist[ii]
                i := ii
            }
        }

        if (min_dist = 10000)
        {
            break      
        }

        Loop % actions.Length()
        {
            neighbor := i + actions[A_Index]
            if (neighbor > 0 && adj <= arrlen)
            {
                if (dist[neighbor] > (dist[i] + 1))
                {
                    dist[neighbor] := dist[i] + 1
                    prev[neighbor] := A_Index
                }
            }
        }
        visited[i] := true
    }
    return prev
}

*/
