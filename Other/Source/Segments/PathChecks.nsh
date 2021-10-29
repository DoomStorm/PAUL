!macro PathChecks
	;=== Check for Program Files
	StrCpy $0 ""
	${If} $EXEDIR contains $PROGRAMFILES
		StrCpy $0 $PROGRAMFILES
	${ElseIf} $EXEDIR contains $PROGRAMFILES64
		StrCpy $0 $PROGRAMFILES64
	${EndIf}
	${If} $0 != ""
		${MessageBox} ${MB_ICONSTOP} "$PORTABLEAPPNAME cannot be run from inside $0. This location is for standard local software only. Please use this application from another location."
		Goto TheEnd
	${EndIf}
!macroend
