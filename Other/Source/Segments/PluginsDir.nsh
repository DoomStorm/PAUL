Var LAUNCHERFILEHANDLE

!macro PluginsDir
	${SegmentStart}
	${SegmentInit} ;{{{1
		InitPluginsDir
		${WriteINIStr} $PLUGINSDIR\$APPID.ini Path Home $EXEDIR
		FileOpen $LAUNCHERFILEHANDLE $PLUGINSDIR\$APPID.ini r
	${SegmentCleanUp} ;{{{1
		; Clean up other PluginsDir that previously
		; didn't cleaned up yet e.g. when launcher
		; wasn't closed properly
		StrCpy $R0 ""
		${Do}
			ClearErrors
			${If} $R0 == ""
				FindFirst $R0 $0 $TEMP\ns*.tmp
			${Else}
				FindNext $R0 $0
			${EndIf}
			${IfThen} ${Errors} ${|} ${ExitDo} ${|}
			${If} $TEMP\$0 == $PLUGINSDIR ; be sure it's not current PluginsDir
				${Continue}
			${EndIf}
			${If} ${IsDir} $TEMP\$0
				${If} ${IsFile} $TEMP\$0\$APPID.ini
					ReadINIStr $1 $TEMP\$0\$APPID.ini Path Home
					; Be sure that the PluginsDir was created by
					; this launcher and wasn't created by other
					; instances
					${If} $1 == $EXEDIR
						${RemoveDirectory} $TEMP\$0
					${EndIf}
				${EndIf}
			${ElseIf} ${IsFile} $TEMP\$0
				; It is safe to just delete ns*.tmp (that is file),
				; because if it being used by other instances it
				; will be read-only
				Delete $TEMP\$0
			${EndIf}
		${Loop}
		FindClose $R0

		; Delete launcher.ini from PluginsDir
		FileClose $LAUNCHERFILEHANDLE
		Delete $PLUGINSDIR\$APPID.ini
	${SegmentEnd} ;}}}1
!macroend
