#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include <Misc.au3>

; ===================== 配置信息 =====================
Global Const $NSDA_TITLE = "nsda" ; 目标窗口标题
Global Const $WAIT_TIMEOUT = 3
Global $ConfigFile = @ScriptDir & "\NSDA_Coords.ini"

; 操作坐标（可被拾取修改）
Global $COORD_REFRESH      = IniReadArr($ConfigFile, "coords", "COORD_REFRESH", "1635,200")
Global $COORD_SELECT_ALL   = IniReadArr($ConfigFile, "coords", "COORD_SELECT_ALL", "1498,202")
Global $COORD_C5GAME       = IniReadArr($ConfigFile, "coords", "COORD_C5GAME", "1845,202")
Global $COORD_PRICING      = IniReadArr($ConfigFile, "coords", "COORD_PRICING", "1300,277")
Global $COORD_CONFIRM      = IniReadArr($ConfigFile, "coords", "COORD_CONFIRM", "1312,738")
Global $COORD_FAIL_CONFIRM = IniReadArr($ConfigFile, "coords", "COORD_FAIL_CONFIRM", "959,738")

Global Const $DELAY_REFRESH      = 2 * 60 * 1000
Global Const $DELAY_SELECT_ALL   = 30 * 1000
Global Const $DELAY_C5GAME       = 30 * 1000
Global Const $DELAY_PRICING      = 30 * 1000
Global Const $DELAY_CONFIRM      = 30 * 1000
Global Const $DELAY_LOOP         = 3 * 60 * 60 * 1000

; ===================== GUI 创建 =====================
Global $winW = 700, $winH = 380
Global $hGUI = GUICreate("NSDA自动上架助手", $winW, $winH, -1, -1, -1, $WS_EX_TOPMOST)
GUICtrlCreateLabel("NSDA自动上架助手", $winW / 2 - 100, 15, 200, 25)

; ======== 署名信息 ========
; 灯火通明（济宁）网络有限公司
GUICtrlCreateLabel("版权所有 © 灯火通明（济宁）网络有限公司", $winW - 320 - 20, $winH - 30, 320, 20)

$btnStart = GUICtrlCreateButton("开始", 60, 60, 140, 40)
$btnStop = GUICtrlCreateButton("停止", 220, 60, 140, 40)
$btnSave = GUICtrlCreateButton("保存设置", 380, 60, 140, 40)
$lblStatus = GUICtrlCreateLabel("状态：未启动", 170, 120, 340, 25)
GUICtrlCreateLabel("终止快捷键：Ctrl+Alt+Q", $winW - 250, 120, 200, 25)

Global $inpRefresh, $btnPickRefresh
Global $inpSelectAll, $btnPickSelectAll
Global $inpC5Game, $btnPickC5Game
Global $inpPricing, $btnPickPricing
Global $inpConfirm, $btnPickConfirm
Global $inpFailConfirm, $btnPickFailConfirm

Local $y1 = 170, $y2 = 210, $y3=250
Local $w_label = 70, $w_input = 120, $w_btn = 60, $gap = 60, $x = 60

; 第一行：刷新、全选
GUICtrlCreateLabel("刷新", $x, $y1, $w_label, 18)
$inpRefresh = GUICtrlCreateInput(Arr2Str($COORD_REFRESH), $x+$w_label, $y1, $w_input, 18)
$btnPickRefresh = GUICtrlCreateButton("拾取", $x+$w_label+$w_input, $y1, $w_btn, 18)

GUICtrlCreateLabel("全选", $x+1*($w_label+$w_input+$w_btn+$gap), $y1, $w_label, 18)
$inpSelectAll = GUICtrlCreateInput(Arr2Str($COORD_SELECT_ALL), $x+1*($w_label+$w_input+$w_btn+$gap)+$w_label, $y1, $w_input, 18)
$btnPickSelectAll = GUICtrlCreateButton("拾取", $x+1*($w_label+$w_input+$w_btn+$gap)+$w_label+$w_input, $y1, $w_btn, 18)

; 第二行：C5GAME、定价
GUICtrlCreateLabel("C5GAME", $x, $y2, $w_label, 18)
$inpC5Game = GUICtrlCreateInput(Arr2Str($COORD_C5GAME), $x+$w_label, $y2, $w_input, 18)
$btnPickC5Game = GUICtrlCreateButton("拾取", $x+$w_label+$w_input, $y2, $w_btn, 18)

GUICtrlCreateLabel("定价", $x+1*($w_label+$w_input+$w_btn+$gap), $y2, $w_label, 18)
$inpPricing = GUICtrlCreateInput(Arr2Str($COORD_PRICING), $x+1*($w_label+$w_input+$w_btn+$gap)+$w_label, $y2, $w_input, 18)
$btnPickPricing = GUICtrlCreateButton("拾取", $x+1*($w_label+$w_input+$w_btn+$gap)+$w_label+$w_input, $y2, $w_btn, 18)

; 第三行：确认、失败确认
GUICtrlCreateLabel("确认", $x, $y3, $w_label, 18)
$inpConfirm = GUICtrlCreateInput(Arr2Str($COORD_CONFIRM), $x+$w_label, $y3, $w_input, 18)
$btnPickConfirm = GUICtrlCreateButton("拾取", $x+$w_label+$w_input, $y3, $w_btn, 18)

GUICtrlCreateLabel("失败确认", $x+1*($w_label+$w_input+$w_btn+$gap), $y3, $w_label, 18)
$inpFailConfirm = GUICtrlCreateInput(Arr2Str($COORD_FAIL_CONFIRM), $x+1*($w_label+$w_input+$w_btn+$gap)+$w_label, $y3, $w_input, 18)
$btnPickFailConfirm = GUICtrlCreateButton("拾取", $x+1*($w_label+$w_input+$w_btn+$gap)+$w_label+$w_input, $y3, $w_btn, 18)

$lblPick = GUICtrlCreateLabel("点击对应“拾取”按钮，然后在目标位置按F9，将当前位置坐标自动填入该项。", 60, 320, 800, 20)
GUISetState(@SW_SHOW, $hGUI)
WinSetOnTop($hGUI, "", 1)

; ===================== 全局变量 =====================
Global $bRunning = False
Global $iStep = 0
Global $stepStart = 0
Global $iPicking = 0 ; 0=无, 1=刷新, 2=全选, 3=C5, 4=定价, 5=确认, 6=失败确认
Global $iPickLastX = -1, $iPickLastY = -1

HotKeySet("^!q", "_Terminate") ; Ctrl+Alt+Q 终止程序

; ================ 主消息循环 =====================
While 1
    $msg = GUIGetMsg()
    Switch $msg
        Case $GUI_EVENT_CLOSE
            _SaveCoords()
            Exit
        Case $btnStart
            _SaveCoords()
            If Not $bRunning Then
                $bRunning = True
                GUICtrlSetData($lblStatus, "状态：运行中...")
                $iStep = 0
                $stepStart = TimerInit()
            EndIf
        Case $btnStop
            $bRunning = False
            GUICtrlSetData($lblStatus, "状态：已停止")
        Case $btnSave
            _SaveCoords()
            GUICtrlSetData($lblStatus, "状态：设置已保存")
        Case $btnPickRefresh
            $iPicking = 1
            GUICtrlSetData($lblStatus, "状态：请把鼠标移到‘刷新’目标，按F9完成拾取")
        Case $btnPickSelectAll
            $iPicking = 2
            GUICtrlSetData($lblStatus, "状态：请把鼠标移到‘全选’目标，按F9完成拾取")
        Case $btnPickC5Game
            $iPicking = 3
            GUICtrlSetData($lblStatus, "状态：请把鼠标移到‘C5GAME’目标，按F9完成拾取")
        Case $btnPickPricing
            $iPicking = 4
            GUICtrlSetData($lblStatus, "状态：请把鼠标移到‘定价’目标，按F9完成拾取")
        Case $btnPickConfirm
            $iPicking = 5
            GUICtrlSetData($lblStatus, "状态：请把鼠标移到‘确认’目标，按F9完成拾取")
        Case $btnPickFailConfirm
            $iPicking = 6
            GUICtrlSetData($lblStatus, "状态：请把鼠标移到‘失败确认’目标，按F9完成拾取")
    EndSwitch

    ; 跟踪并显示鼠标实时坐标
    If $iPicking > 0 Then
        Local $pos = MouseGetPos()
        If $pos[0] <> $iPickLastX Or $pos[1] <> $iPickLastY Then
            Switch $iPicking
                Case 1
                    GUICtrlSetData($inpRefresh, $pos[0]&","&$pos[1])
                Case 2
                    GUICtrlSetData($inpSelectAll, $pos[0]&","&$pos[1])
                Case 3
                    GUICtrlSetData($inpC5Game, $pos[0]&","&$pos[1])
                Case 4
                    GUICtrlSetData($inpPricing, $pos[0]&","&$pos[1])
                Case 5
                    GUICtrlSetData($inpConfirm, $pos[0]&","&$pos[1])
                Case 6
                    GUICtrlSetData($inpFailConfirm, $pos[0]&","&$pos[1])
            EndSwitch
            $iPickLastX = $pos[0]
            $iPickLastY = $pos[1]
        EndIf
    EndIf

    ; 按F9后锁定坐标并退出拾取
    If $iPicking > 0 And _IsPressed("78") Then
        Local $pos = MouseGetPos()
        Switch $iPicking
            Case 1
                GUICtrlSetData($inpRefresh, $pos[0]&","&$pos[1])
                GUICtrlSetData($lblStatus, "状态：刷新坐标已填入")
            Case 2
                GUICtrlSetData($inpSelectAll, $pos[0]&","&$pos[1])
                GUICtrlSetData($lblStatus, "状态：全选坐标已填入")
            Case 3
                GUICtrlSetData($inpC5Game, $pos[0]&","&$pos[1])
                GUICtrlSetData($lblStatus, "状态：C5GAME坐标已填入")
            Case 4
                GUICtrlSetData($inpPricing, $pos[0]&","&$pos[1])
                GUICtrlSetData($lblStatus, "状态：定价坐标已填入")
            Case 5
                GUICtrlSetData($inpConfirm, $pos[0]&","&$pos[1])
                GUICtrlSetData($lblStatus, "状态：确认坐标已填入")
            Case 6
                GUICtrlSetData($inpFailConfirm, $pos[0]&","&$pos[1])
                GUICtrlSetData($lblStatus, "状态：失败确认坐标已填入")
        EndSwitch
        $iPicking = 0
        $iPickLastX = -1
        $iPickLastY = -1
        Sleep(500)
    EndIf

    If $bRunning Then
        _LoadCoords()
        AutoUploadTask()
    EndIf
    Sleep(30)
WEnd

; ===================== 辅助函数 =====================
Func IniReadArr($filename, $section, $key, $default)
    Local $s = IniRead($filename, $section, $key, $default)
    Local $a = StringSplit($s, ",")
    If $a[0] = 2 Then
        Local $arr[2]
        $arr[0] = Number($a[1])
        $arr[1] = Number($a[2])
        Return $arr
    Else
        Local $arr[2] = [0,0]
        Return $arr
    EndIf
EndFunc

Func Arr2Str($a)
    Return $a[0]&","&$a[1]
EndFunc

Func _LoadCoords()
    $COORD_REFRESH      = StringToCoord(GUICtrlRead($inpRefresh))
    $COORD_SELECT_ALL   = StringToCoord(GUICtrlRead($inpSelectAll))
    $COORD_C5GAME       = StringToCoord(GUICtrlRead($inpC5Game))
    $COORD_PRICING      = StringToCoord(GUICtrlRead($inpPricing))
    $COORD_CONFIRM      = StringToCoord(GUICtrlRead($inpConfirm))
    $COORD_FAIL_CONFIRM = StringToCoord(GUICtrlRead($inpFailConfirm))
EndFunc

Func _SaveCoords()
    IniWrite($ConfigFile, "coords", "COORD_REFRESH", GUICtrlRead($inpRefresh))
    IniWrite($ConfigFile, "coords", "COORD_SELECT_ALL", GUICtrlRead($inpSelectAll))
    IniWrite($ConfigFile, "coords", "COORD_C5GAME", GUICtrlRead($inpC5Game))
    IniWrite($ConfigFile, "coords", "COORD_PRICING", GUICtrlRead($inpPricing))
    IniWrite($ConfigFile, "coords", "COORD_CONFIRM", GUICtrlRead($inpConfirm))
    IniWrite($ConfigFile, "coords", "COORD_FAIL_CONFIRM", GUICtrlRead($inpFailConfirm))
EndFunc

Func StringToCoord($s)
    Local $a = StringSplit($s, ",")
    If $a[0]=2 Then
        Local $arr[2]
        $arr[0] = Number($a[1])
        $arr[1] = Number($a[2])
        Return $arr
    Else
        Local $arr[2] = [0,0]
        Return $arr
    EndIf
EndFunc

Func _Terminate()
    _SaveCoords()
    Exit
EndFunc

; ===================== 激活目标窗口函数 =====================
Func ActivateNSDA()
    If WinExists($NSDA_TITLE) Then
        WinActivate($NSDA_TITLE)
        WinWaitActive($NSDA_TITLE, "", $WAIT_TIMEOUT)
        Sleep(200)
        Return True
    Else
        MsgBox(48, "错误", "未找到 NSDA 主窗口，请先打开NSDA软件！")
        Return False
    EndIf
EndFunc

; ===================== 自动上架主流程 =====================
Func AutoUploadTask()
    Switch $iStep
        Case 0
            GUICtrlSetData($lblStatus, "状态：刷新中...")
            If ActivateNSDA() Then
                MouseClick("left", $COORD_REFRESH[0], $COORD_REFRESH[1], 1, 0)
                $stepStart = TimerInit()
                $iStep = 1
            Else
                $bRunning = False
                GUICtrlSetData($lblStatus, "状态：未找到窗口，已停止")
            EndIf

        Case 1
            If TimerDiff($stepStart) >= $DELAY_REFRESH Then
                GUICtrlSetData($lblStatus, "状态：全选中...")
                If ActivateNSDA() Then
                    MouseClick("left", $COORD_SELECT_ALL[0], $COORD_SELECT_ALL[1], 1, 0)
                    $stepStart = TimerInit()
                    $iStep = 2
                Else
                    $bRunning = False
                    GUICtrlSetData($lblStatus, "状态：未找到窗口，已停止")
                EndIf
            EndIf

        Case 2
            If TimerDiff($stepStart) >= $DELAY_SELECT_ALL Then
                GUICtrlSetData($lblStatus, "状态：上架C5GAME中...")
                If ActivateNSDA() Then
                    MouseClick("left", $COORD_C5GAME[0], $COORD_C5GAME[1], 1, 0)
                    $stepStart = TimerInit()
                    $iStep = 3
                Else
                    $bRunning = False
                    GUICtrlSetData($lblStatus, "状态：未找到窗口，已停止")
                EndIf
            EndIf

        Case 3
            If TimerDiff($stepStart) >= $DELAY_C5GAME Then
                GUICtrlSetData($lblStatus, "状态：一键定价中...")
                If ActivateNSDA() Then
                    MouseClick("left", $COORD_PRICING[0], $COORD_PRICING[1], 1, 0)
                    $stepStart = TimerInit()
                    $iStep = 4
                Else
                    $bRunning = False
                    GUICtrlSetData($lblStatus, "状态：未找到窗口，已停止")
                EndIf
            EndIf

        Case 4
            If TimerDiff($stepStart) >= $DELAY_PRICING Then
                GUICtrlSetData($lblStatus, "状态：确认上架中...")
                If ActivateNSDA() Then
                    MouseClick("left", $COORD_CONFIRM[0], $COORD_CONFIRM[1], 1, 0)
                    $stepStart = TimerInit()
                    $iStep = 5
                Else
                    $bRunning = False
                    GUICtrlSetData($lblStatus, "状态：未找到窗口，已停止")
                EndIf
            EndIf

        Case 5
            If TimerDiff($stepStart) >= $DELAY_CONFIRM Then
                If ActivateNSDA() Then
                    MouseClick("left", $COORD_FAIL_CONFIRM[0], $COORD_FAIL_CONFIRM[1], 1, 0)
                    GUICtrlSetData($lblStatus, "状态：等待下次循环...")
                    $stepStart = TimerInit()
                    $iStep = 6
                Else
                    $bRunning = False
                    GUICtrlSetData($lblStatus, "状态：未找到窗口，已停止")
                EndIf
            EndIf

        Case 6
            If TimerDiff($stepStart) >= $DELAY_LOOP Then
                $iStep = 0 ; 重新开始
            EndIf
    EndSwitch
EndFunc