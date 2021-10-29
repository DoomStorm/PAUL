!ifndef UNPINFROMTASKBAR_NSH_INCLUDED
!define UNPINFROMTASKBAR_NSH_INCLUDED
!include Util.nsh

!macro UnpinFromTaskbarCall _FILE
	!verbose push 3
	Push `${_FILE}`
	${CallArtificialFunction} UnpinFromTaskbar_
	!verbose pop
!macroend
!define UnpinFromTaskbar "!insertmacro UnpinFromTaskbarCall"

!macro UnpinFromTaskbar_
	!verbose push 3
		Exch $0 ; _FILE
		Push $1 ; exe
		Push $2 ; path
		Push $3 ; temp

		StrCpy $2 1

	${__MACRO__}_GetPath:
		StrCpy $1 $0 "" -$2
		StrCpy $3 $1 1
		StrCmp $3 "\" ${__MACRO__}_CheckLNK
		IntOp $2 $2 + 1
		Goto ${__MACRO__}_GetPath

	${__MACRO__}_CheckLNK:
		StrCpy $1 $1 $2 1
		StrCpy $2 $0 -$2

		MoreInfo::GetFileDescription $0
		Pop $3

		StrCmp $3 "" "" +2
		StrCpy $3 $1 -4

		IfFileExists "$APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\$3.lnk\*.*" ${__MACRO__}_CleanupStack
		IfFileExists "$APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\$3.lnk" "" ${__MACRO__}_CleanupStack

		IfFileExists "$APPDIRECTORY\Bin\pin2taskbar.exe\*.*" ${__MACRO__}_UnpinIt
		IfFileExists "$APPDIRECTORY\Bin\pin2taskbar.exe" ${__MACRO__}_UnpinUsingKMPlayerTool

	${__MACRO__}_UnpinIt:
		Push 5387
		Push $1
		Push $2
		InvokeShellVerb::DoIt
		Pop $3
		Goto ${__MACRO__}_CleanupStack

	${__MACRO__}_UnpinUsingKMPlayerTool:
		ExecWait `"$APPDIRECTORY\Bin\pin2taskbar.exe" unpin "$2\$1"` ; copied from KMPlayer Setup

	${__MACRO__}_CleanupStack:
		Pop $3
		Pop $2
		Pop $1
		Pop $0
	!verbose pop
!macroend
!endif ; UNPINFROMTASKBAR_NSH_INCLUDED
