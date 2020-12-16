[General]
SyntaxVersion=2
BeginHotkey=121
BeginHotkeyMod=0
PauseHotkey=0
PauseHotkeyMod=0
StopHotkey=123
StopHotkeyMod=0
RunOnce=1
EnableWindow=
MacroID=10323fbe-6cb6-4207-9c50-94cbb2e28e87
Description=连连看教程 - 酷玩蚊仔
Enable=1
AutoRun=0
[Repeat]
Type=0
Number=1
[SetupUI]
Type=2
QUI=
[Relative]
SetupOCXFile=
[Comment]

[Script]
Dim Hwnd// 窗口句柄
Dim LTX, LTY// 左上角格子的取色点
Dim width, height/// 方块宽高
Dim map(18, 10)// 二维数组
Dim backgroundColor// 背景色
Dim total// 剩余方块数
Dim startBlockColor// 起始方块颜色, 目标方块颜色
Dim startBlockX, startBlockY// 起始方块下标
Dim endBlockX, endBlockY// 目标方块下标
Dim timeX, timeY// 时间轴右下角坐标
Dim timeColor// 时间轴右下角颜色
Dim clearPerRound // 每轮遍历寻路成功次数
width = 31
height = 35
backgroundColor = "704C30"
timeColor = "90B0E0"

Call 定位窗口
Call 初始化

Sub 定位窗口
	Hwnd = Plugin.Window.Find(0, "QQ游戏 - 连连看角色版")
	sRect = Plugin.Window.GetClientRect(Hwnd)
	clientRectArray = Split(sRect, "|")
	LTX = clientRectArray(0) + 14 + 10
	LTY = clientRectArray(1) + 181 + 20
	timeX = clientRectArray(0) + 410
	timeY = clientRectArray(1) + 586
End Sub

Sub 初始化
	Dim x, y, blockColor
	total = 0
	For y = 0 To 10
		For x = 0 To 18
			blockColor = GetPixelColor(LTX + width * x, LTY + height * y)
			// MoveTo LTX + width * x, LTY + height * y
			If blockColor <> backgroundColor Then 
				map(x, y) = blockColor
				total = total + 1
			Else 
				map(x, y) = "0"
			End If
		Next
	Next
	Call 寻找起始方块
End Sub

Sub 寻找起始方块
	Dim x, y
	While total > 0
		clearPerRound = 0
		For y = 0 To 10
			For x = 0 To 18
				If map(x, y) <> "0" Then 
					startBlockColor = map(x, y)
					startBlockX = x
					startBlockY = y
					Call 寻找目标方块
				End If
			Next
		Next
		If clearPerRound = 0 Then 
			KeyPress "2", 1
			Call 初始化
		End If
	Wend
	Call 判断游戏结束
End Sub

Sub 寻找目标方块
	Dim x, y
	For y = startBlockY To 10
		For x = 0 To 18
			If x > startBlockX Or y > startBlockY Then // 确保目标方块在起始方块的同行右边或下面
				If map(x, y) = startBlockColor Then 
					endBlockX = x
					endBlockY = y
					Call 判定位置关系 // 不管最终消除成功还是失败，都会回到这里
					If map(startBlockX, startBlockY) = "0" Then 
						Exit Sub // 如果消除成功，退出子程序，回到“Call 寻找目标方块”
					End If
				End If
			End If
		Next
	Next
End Sub

Sub 判定位置关系
	If startBlockY = endBlockY Then // 同行,起始方块在左
		Call 一级寻路_右
		If startBlockY > 0 And map(startBlockX, startBlockY) <> "0" Then 
			Call 二级寻路_上右 // 上右下
		End If
		If startBlockY < 10 And map(startBlockX, startBlockY) <> "0" Then 
			Call 二级寻路_下右 // 下右上
		End If
	ElseIf startBlockX = endBlockX Then // 同列,起始方块在上
		Call 一级寻路_下
		If startBlockX > 0 And map(startBlockX, startBlockY) <> "0" Then 
			Call 二级寻路_左下 // 左下右
		End If
		If startBlockX < 18 And map(startBlockX, startBlockY) <> "0" Then 
			Call 二级寻路_右下 // 右下左
		End If
	ElseIf startBlockX < endBlockX Then // 不同行不同列，起始方块在左上
		If startBlockY > 0 Then 
			Call 二级寻路_上右// 上右下
		End If
		If map(startBlockX, startBlockY) <> "0" Then 
			Call 二级寻路_右下 // 右下，右下左，右下右
		End If
		If map(startBlockX, startBlockY) <> "0" Then 
			Call 二级寻路_下右 // 下右，下右下，下右上
		End If
		If startBlockX > 0 And map(startBlockX, startBlockY) <> "0" Then 
			Call 二级寻路_左下 // 左下右
		End If
	Else // 不同行不同列，起始方块在右上
		If startBlockY > 0 Then 
			Call 二级寻路_上左 // 上左下
		End If
		If startBlockX < 18 And map(startBlockX, startBlockY) <> "0" Then 
			Call 二级寻路_右下 // 右下左
		End If
		If map(startBlockX, startBlockY) <> "0" Then 
			Call 二级寻路_下左 // 下左，下左下，下左上
		End If
		If map(startBlockX, startBlockY) <> "0" Then 
			Call 二级寻路_左下 // 左下，左下右，左下左
		End If
	End If
End Sub

Sub 一级寻路_右
	Dim x
	For x = startBlockX + 1 To endBlockX
		If x = endBlockX Then 
			Call 消除
			Exit Sub
		ElseIf map(x, startBlockY) <> "0" Then
			Exit Sub
		End If
	Next
End Sub

Sub 一级寻路_下
	Dim y
	For y = startBlockY + 1 To endBlockY
		If y = endBlockY Then 
			Call 消除
			Exit Sub
		ElseIf map(startBlockX, y) <> "0" Then
			Exit Sub
		End If
	Next
End Sub

Sub 二级寻路_上右 // 上右下
	Dim x, y
	For y = startBlockY - 1 To 0 Step -1 // 起始方块往上遍历
		If map(startBlockX, y) = "0" Then 
			For x = startBlockX + 1 To endBlockX // 往上走到的空格子作为往右走的起点
				If map(x, y) <> "0" Then 
					Exit For
				ElseIf x = endBlockX Then
					Call 三级寻路_下(y)
					Exit Sub
				End If
			Next
		Else 
			Exit Sub
		End If
	Next
End Sub

Sub 二级寻路_上左 // 上左下
	Dim x, y
	For y = startBlockY - 1 To 0 Step -1 
		If map(startBlockX, y) = "0" Then 
			For x = startBlockX - 1 To endBlockX Step -1
				If map(x, y) <> "0" Then 
					Exit For
				ElseIf x = endBlockX Then
					Call 三级寻路_下(y)
					Exit Sub
				End If
			Next
		Else 
			Exit Sub
		End If
	Next
End Sub

Sub 二级寻路_右下 // 右下，右下左，右下右
	Dim x, y
	For x = startBlockX + 1 To 18
		If map(x, startBlockY) = "0" Then 
			For y = startBlockY + 1 To endBlockY
				If x = endBlockX And y = endBlockY Then // 右下
					Call 消除
					Exit Sub
				ElseIf map(x, y) <> "0" Then
					Exit For
				ElseIf y = endBlockY And x < endBlockX Then // 右下右
					Call 三级寻路_右(x)
					If map(startBlockX, startBlockY) = "0" Then 
						Exit Sub
					End If
				ElseIf y = endBlockY And x > endBlockX Then//右下左
					Call 三级寻路_左(x)
					Exit Sub
				End If
			Next
		Else 
			Exit Sub
		End If
	Next
End Sub

Sub 二级寻路_左下 // 左下，左下右，左下左
	Dim x, y
	For x = startBlockX - 1 To 0 Step -1 
		If map(x, startBlockY) = "0" Then 
			For y = startBlockY + 1 To endBlockY
				If x = endBlockX And y = endBlockY Then // 左下
					Call 消除
					Exit Sub
				ElseIf map(x, y) <> "0" Then
					Exit For
				ElseIf y = endBlockY And x < endBlockX Then  // 左下右
					Call 三级寻路_右(x)
					Exit Sub
				ElseIf y = endBlockY And x > endBlockX Then // 左下左
					Call 三级寻路_左(x)
					If map(startBlockX, startBlockY) = "0" Then 
						Exit Sub
					End If
				End If
			Next
		Else 
			Exit Sub
		End If
	Next
End Sub

Sub 二级寻路_下右 // 下右，下右下，下右上
	Dim x, y
	For y = startBlockY + 1 To 10
		If map(startBlockX, y) = "0" Then 
			For x = startBlockX + 1 To endBlockX
				If x = endBlockX And y = endBlockY Then // 下右
					Call 消除
					Exit Sub
				ElseIf map(x, y) <> "0" Then
					Exit For
				ElseIf x = endBlockX And y < endBlockY Then // 下右下
					Call 三级寻路_下(y)
					If map(startBlockX, startBlockY) = "0" Then 
						Exit Sub
					End If
				ElseIf x = endBlockX And y > endBlockY Then // 下右上
					Call 三级寻路_上(y)
					Exit Sub
				End If
			Next
		Else 
			Exit Sub
		End If
	Next
End Sub

Sub 二级寻路_下左 // 下左，下左下，下左上
	Dim x, y
	For y = startBlockY + 1 To 10 
		If map(startBlockX, y) = "0" Then 
			For x = startBlockX - 1 To endBlockX Step -1 
				If x = endBlockX And y = endBlockY Then // 下左
					Call 消除
					Exit Sub
				ElseIf map(x, y) <> "0" Then
					Exit For
				ElseIf x = endBlockX And y < endBlockY Then // 下左下
					Call 三级寻路_下(y)
					If map(startBlockX, startBlockY) = "0" Then 
						Exit Sub
					End If
				ElseIf x = endBlockX And y > endBlockY Then // 下左上
					Call 三级寻路_上(y)
					Exit Sub
				End If
			Next
		Else 
			Exit Sub
		End If
	Next
End Sub

Sub 三级寻路_上(startY_3)
	Dim y
	For y = startY_3 - 1 To endBlockY Step -1 
		If y = endBlockY Then 
			Call 消除
			Exit Sub
		ElseIf map(endBlockX, y) <> "0" Then
			Exit Sub
		End If
	Next
End Sub

Sub 三级寻路_下(startY_3)
	Dim y
	For y = startY_3 + 1 To endBlockY
		If y = endBlockY Then 
			Call 消除
			Exit Sub
		ElseIf map(endBlockX, y) <> "0" Then
			Exit Sub
		End If
	Next
End Sub

Sub 三级寻路_左(startX_3)
	Dim x
	For x = startX_3 - 1 To endBlockX Step -1 
		If x = endBlockX Then 
			Call 消除
			Exit Sub
		ElseIf map(x, endBlockY) <> "0" Then
			Exit Sub
		End If
	Next
End Sub

Sub 三级寻路_右(startX_3)
	Dim x
	For x = startX_3 + 1 To endBlockX
		If x = endBlockX Then 
			Call 消除
			Exit Sub
		ElseIf map(x, endBlockY) <> "0" Then
			Exit Sub
		End If
	Next
End Sub

Sub 消除
	clearPerRound = clearPerRound + 1
	MoveTo LTX + width * startBlockX, LTY + height * startBlockY
	LeftClick 1
	MoveTo LTX + width * endBlockX, LTY + height * endBlockY
	LeftClick 1
	
	IfColor LTX + width * endBlockX - 10, LTY + height * endBlockY - 20, "F80000", 0 Then
		Call 初始化
	Else 
		map(startBlockX, startBlockY) = "0"
		map(endBlockX, endBlockY) = "0"
		total = total - 2
		If total = 0 Then 
			Call 判断游戏结束
		End If
	End If
End Sub

Sub 判断游戏结束
	IfColor timeX, timeY, timeColor, 1 Then // 时间归0或时间条消失时游戏结束
		TracePrint "游戏结束"
		EndScript
	Else 
		Call 初始化
	End If
End Sub