Var BADEXIT

!macro BadExit
	${ReadRuntimeData} $0 $APPID Status
	${If} $0 == running
		;=== We're in the bad exit mode, let's ask the user if he/she wants to cleaning things up
		${MessageBox} ${MB_YESNO}|${MB_ICONSTOP} "$PORTABLEAPPNAME did not close properly last time it was run. Would you like to cleaning it up now?"
		Pop $0
		${If} $0 == yes
			${ReadRuntimeData} $0 $APPID PluginsDir
			${If}    $0 != ""
			${AndIf} $0 != $PLUGINSDIR
				${RemoveDirectory} $0
			${EndIf}
			StrCpy $BADEXIT true
			Goto Restore
		${EndIf}
	${EndIf}
!macroend
