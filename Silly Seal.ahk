#NoEnv
#SingleInstance Force
#Persistent
SendMode Input
SetBatchLines -1
ListLines Off

DllCall("SetProcessDPIAware")

CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

; =========================================================
; ЗОНА МИНИ-ИГРЫ
; =========================================================

left   := 668
top    := 767
right  := 1248
bottom := 848

w := right - left
h := bottom - top

; =========================================================
; ЦВЕТА
; =========================================================

blueColor1 := 0x03A9F4
blueColor2 := 0x82DAFF
redColor   := 0xE91E63

variation := 60

; =========================================================
; SPEED
; =========================================================

clickDelay := 15
loopDelay := 5

; =========================================================
; АВТО-РЫБАЛКА
; =========================================================

promptKey := "e"

; сколько ждать перед проверкой окончания игры
gameTimeout := 10000

; через сколько снова прожимать E
restartDelay := 1200

; =========================================================
; STATE
; =========================================================

running := false
holding := false

gameActive := false
gameStartTime := 0

lastRed := 0
lastRestart := 0

; =========================================================
; GUI
; =========================================================

Gui, 1:+AlwaysOnTop -Caption +ToolWindow
Gui, 1:Color, 1E1E1E
Gui, 1:Font, cFFFFFF s10 Bold, Segoe UI
Gui, 1:Add, Text, vStatusText w420 h32 Center, OFF
Gui, 1:Show, x20 y20 NoActivate

; =========================================================
; OVERLAY
; =========================================================

Gui, 2:+AlwaysOnTop -Caption +ToolWindow +E0x20 +LastFound
Gui, 2:Color, FF0000

WinSet, Transparent, 40
WinSet, ExStyle, +0x80

Gui, 2:Show, x%left% y%top% w%w% h%h% NoActivate

; =========================================================
; F1
; =========================================================

F1::

running := !running

if (running)
{
    Gosub, ResetState

    GuiControl,, StatusText, СКРИПТ ВКЛЮЧЕН

    SetTimer, MainLoop, %loopDelay%
}
else
{
    SetTimer, MainLoop, Off

    Gosub, ResetState

    GuiControl,, StatusText, СКРИПТ ВЫКЛЮЧЕН
}

return

; =========================================================
; RESET
; =========================================================

ResetState:

SendInput {LButton Up}

holding := false
gameActive := false
gameStartTime := 0
lastRed := 0
lastRestart := 0

Sleep 30

return

; =========================================================
; START FISHING
; =========================================================

StartFishing:

; нажимаем prompt E
SendInput {%promptKey%}

Sleep 120

; начинаем спам ЛКМ
Loop 25
{
    Click
    Sleep 25
}

lastRestart := A_TickCount

return

; =========================================================
; MAIN LOOP
; =========================================================

MainLoop:

if (!running)
    return

blueFound := false
redFound := false

; =========================================================
; RED SEARCH
; =========================================================

PixelSearch, rx, ry, left, top, right, bottom
    , redColor, variation, RGB Fast

if (!ErrorLevel)
    redFound := true

; =========================================================
; BLUE SEARCH
; =========================================================

midX := left + 180

PixelSearch, bx, by, left, top, midX, bottom
    , blueColor1, variation, RGB Fast

if (!ErrorLevel)
    blueFound := true

if (!blueFound)
{
    PixelSearch, bx2, by2, left, top, midX, bottom
        , blueColor2, variation, RGB Fast

    if (!ErrorLevel)
        blueFound := true
}

if (!blueFound)
{
    PixelSearch, bx3, by3, left, top, right, bottom
        , blueColor1, variation, RGB Fast

    if (!ErrorLevel)
        blueFound := true
}

if (!blueFound)
{
    PixelSearch, bx4, by4, left, top, right, bottom
        , blueColor2, variation, RGB Fast

    if (!ErrorLevel)
        blueFound := true
}

; =========================================================
; ИГРА НАЙДЕНА
; =========================================================

if (redFound || blueFound)
{
    if (!gameActive)
    {
        gameActive := true
        gameStartTime := A_TickCount
    }
}
else
{
    ; мини-игры нет
    gameActive := false

    if (holding)
    {
        SendInput {LButton Up}
        holding := false
    }

    ; снова запускаем рыбалку
    if ((A_TickCount - lastRestart) > restartDelay)
    {
        GuiControl,, StatusText, ЗАПУСК РЫБАЛКИ

        Gosub, StartFishing
    }

    return
}

; =========================================================
; ПРОВЕРКА ОКОНЧАНИЯ ИГРЫ
; =========================================================

if ((A_TickCount - gameStartTime) > gameTimeout)
{
    ; несколько кликов для проверки
    Loop 5
    {
        Click
        Sleep 40
    }

    Sleep 150

    ; проверяем ещё раз
    testFound := false

    PixelSearch, tx, ty, left, top, right, bottom
        , redColor, variation, RGB Fast

    if (!ErrorLevel)
        testFound := true

    if (!testFound)
    {
        PixelSearch, tx2, ty2, left, top, right, bottom
            , blueColor1, variation, RGB Fast

        if (!ErrorLevel)
            testFound := true
    }

    if (!testFound)
    {
        PixelSearch, tx3, ty3, left, top, right, bottom
            , blueColor2, variation, RGB Fast

        if (!ErrorLevel)
            testFound := true
    }

    ; если пикселей нет -> игра закончилась
    if (!testFound)
    {
        gameActive := false

        if (holding)
        {
            SendInput {LButton Up}
            holding := false
        }

        GuiControl,, StatusText, ИГРА ЗАКОНЧИЛАСЬ

        Sleep 200

        Gosub, StartFishing

        return
    }
    else
    {
        ; игра ещё идёт
        gameStartTime := A_TickCount
    }
}

; =========================================================
; RED ACTION
; =========================================================

if (redFound)
{
    if (holding)
    {
        SendInput {LButton Up}
        holding := false
        Sleep 15
    }

    GuiControl,, StatusText, КРАСНЫЙ - КЛИК

    Click
    Sleep %clickDelay%

    lastRed := A_TickCount

    return
}

; =========================================================
; BLUE ACTION
; =========================================================

if (blueFound)
{
    GuiControl,, StatusText, СИНИЙ - HOLD

    if ((A_TickCount - lastRed) < 80)
        Sleep 20

    if (!holding)
    {
        SendInput {LButton Down}
        holding := true
    }

    return
}

; =========================================================
; NO BLUE
; =========================================================

if (holding)
{
    SendInput {LButton Up}
    holding := false
}

return

; =========================================================
; ESC
; =========================================================

Esc::

SendInput {LButton Up}
ExitApp

return