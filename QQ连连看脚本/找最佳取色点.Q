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
MacroID=2abd1ee3-75b4-4127-97eb-4fbe73f1f72f
Description=找最佳取色点
Enable=0
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
// Call 遍历方块(224+10, 207+20)
// EndScript

// 遍历方块中的每个点
For x = 224 To 224 + 30
	For y = 207 To 207 + 34
		If 遍历取色(x, y) Then 
			TracePrint x & ", " & y
			// EndScript
		End If
	Next
Next


Function 遍历取色(x, y)
	Dim blockIndex, repeatIndex, array(43)
	For blockIndex = 0 To 43 // 遍历一行44个方块
		GetColor = GetPixelColor(x + blockIndex * 31, y)
		For repeatIndex = 0 To 43 // 检查取出的颜色是否有重复
			If array(repeatIndex) = GetColor Or GetColor = "704C30" Then // 颜色重复或为背景色，直接退出
				遍历取色 = False
				Exit Function
			End If
		Next
		array(blockIndex) = GetColor
	Next
	遍历取色 = true // 遍历完成没有重复返回true
End Function
