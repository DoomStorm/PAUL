; Azure Zanculmarktum
;
; Create directory that can be accessed (read/write)
; even without administrator privileges.
;
; NOTE: you need to set RequestExecutionLevel admin
;       in your script. Otherwise the directory will
;       only be created when you run installer as
;       an administrator.
;
; Usage: 
; ${CreateDirectoryAsUser} path_to_create
;
; Example:
; ${CreateDirectoryAsUser} $PROGRAMFILES\Dir

!ifndef CREATEDIRECTORYASUSER_NSH_INCLUDED
!define CREATEDIRECTORYASUSER_NSH_INCLUDED
!include Util.nsh
!include LogicLib.nsh
!include "${PAUL}\IsFile.nsh"
!include "${PAUL}\RemoveDirectory.nsh"

!macro CreateDirectoryAsUserCall _PATH
	!verbose push 3
	Push `${_PATH}`
	${CallArtificialFunction} _CDAU_CheckParent
	!verbose pop
!macroend
!define CreateDirectoryAsUser "!insertmacro CreateDirectoryAsUserCall"

!macro _CDAU_CheckParent
	!verbose push 3
	Exch $0 ; _PATH
	Push $1 ; _PATH len
	Push $2 ; int counter
	Push $3 ; parent
	Push $4 ; parent len
	Push $5

	StrLen $1 $0
	StrCpy $2 0
	${Do}
		StrCpy $3 $0 $2
		StrLen $4 $3
		${IfThen} $1 == $4 ${|} ${ExitDo} ${|}
		StrCpy $5 $3 1 -1
		${If} $5 == "\"
			StrCpy $3 $3 -1
			${IfNot} ${IsDir} $3
				Push $3
				${CallArtificialFunction2} CreateDirectoryAsUser_
			${EndIf}
		${EndIf}
		IntOp $2 $2 + 1
	${Loop}

	${IfNot} ${IsDir} $0
		Push $0
		${CallArtificialFunction2} CreateDirectoryAsUser_
	${EndIf}

	Pop $5
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Pop $0
	!verbose pop
!macroend

!macro CreateDirectoryAsUser_
	!verbose push 3
	Exch $0
	Push $1

	; Create unique directory
	GetTempFileName $1
	Delete $1
	${RemoveDirectory} $1
	CreateDirectory $1

	; Move to specified location
	Rename $1 $0

	; Is it still exists?
	${If} ${IsDir} $1
		${RemoveDirectory} $1 ; if so, then remove it
	${EndIf}

	Pop $1
	Pop $0
	!verbose pop
!macroend
!endif ;CREATEDIRECTORYASUSER_NSH_INCLUDED
