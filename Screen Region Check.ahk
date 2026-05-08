#SingleInstance Force
CoordMode, Mouse, Screen

F1::
    ToolTip, Кликни 1-й угол
    KeyWait, LButton, D
    MouseGetPos, x1, y1
    KeyWait, LButton

    ToolTip, Кликни 2-й угол
    KeyWait, LButton, D
    MouseGetPos, x2, y2
    KeyWait, LButton

    ToolTip, Кликни 3-й угол
    KeyWait, LButton, D
    MouseGetPos, x3, y3
    KeyWait, LButton

    ToolTip, Кликни 4-й угол
    KeyWait, LButton, D
    MouseGetPos, x4, y4
    KeyWait, LButton

    ToolTip

    ; ищем границы прямоугольника
    left := x1, right := x1, top := y1, bottom := y1

    Loop 4
    {
        x := x%A_Index%
        y := y%A_Index%

        if (x < left)
            left := x
        if (x > right)
            right := x
        if (y < top)
            top := y
        if (y > bottom)
            bottom := y
    }

    width := right - left
    height := bottom - top

    MsgBox,
    (LTrim
    Углы:
    1: %x1%, %y1%
    2: %x2%, %y2%
    3: %x3%, %y3%
    4: %x4%, %y4%

    Прямоугольник:
    Left Top: %left%, %top%
    Right Bottom: %right%, %bottom%
    Width: %width%
    Height: %height%
    )
return