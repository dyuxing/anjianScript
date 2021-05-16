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
MacroID=4d32130e-f801-4a4e-8da1-20e5fbf4731c
Description=无找图云脚本
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
Set xPost = CreateObject("Msxml2.ServerXMLHTTP.3.0")
xPost.Open "Get", "http://localhost:80/api4", False
xPost.Send 
Delay 10
codeBlock = "" // 子程序要执行的代码
If xPost.readyState=4 Then
    TracePrint xPost.responsetext
//    Execute (xPost.responsetext)
    list = Split(xPost.responsetext, "||") // 用双管道符拆分成数组
    For i = 0 To UBound(list) // 根据数组长度决定循环次数
    	If InStr(list(i), "subCode:") = 0 Then // 没有subCode标记说明是主程序要执行的代码，才执行
    		Execute (list(i)) // 把字符串解析成代码执行
    		If codeBlock <> "" Then // 如果有语句需要子程序执行，就调用子程序
    			Call runCodeBlock
    		End If
    	End If
    Next
End If
xPost.abort
Set xPost = Nothing
Sub runCodeBlock
	subList = Split(Replace(codeBlock, "subCode:", ""), "|") // 去除subCode标记，用管道符拆分成数组
	For j = 0 To UBound(subList)
		Execute (subList(j)) // 把字符串解析成代码执行
	Next
	codeBlock = "" // 清空子程序要执行的代码
End Sub