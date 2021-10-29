; Azure Zanculmarktum
;
; Remove directory and its contents even if it
; is opened in Windows Explorer.
;
; Example:
; ${RemoveDirectory} C:\Directory

!ifndef REMOVEDIRECTORY_NSH_INCLUDED
!define REMOVEDIRECTORY_NSH_INCLUDED
!include Util.nsh
!include LogicLib.nsh
!include FileFunc.nsh
!include "${PAUL}\MoveFiles.nsh"
!include "${PAUL}\IsFile.nsh"

!macro RemoveDirectoryCall _PATH
	!verbose push 3
	Push `${_PATH}`
	${CallArtificialFunction} RemoveDirectory_
	!verbose pop
!macroend
!define RemoveDirectory "!insertmacro RemoveDirectoryCall"

!macro RemoveDirectory_
	!verbose push 3
	Exch $0

	${If} ${IsDir} $0
		Push $1

		; First, create unique destination directory
		; in the same location
		${GetParent} $0 $1
		GetTempFileName $1 $1
		Delete $1
		RMDir /r $1

		; Move to the newly created directory
		${MoveFiles} "/SILENT" $0 $1

		; And then remove it
		RMDir /r $1

		; This way, user will have no chance
		; to open the directory in Windows
		; Explorer :D

		; NOTE: disabled due to directory that has
		; file(s) that is being used by another app,
		; this function will recursively looping
		; till got crash.
		; Is directory (ns*.tmp) too big and user
		; decide to open it? :( Don't worry, just
		; remove the directory one more time. Well,
		; it's just an empty directory though, not
		; a big concern :P
		;${If} ${IsDir} $1
		;	${RemoveDirectory} $1
		;${EndIf}

		Pop $1
	${EndIf}

	Pop $0
	!verbose pop
!macroend
!endif ; REMOVEDIRECTORY_NSH_INCLUDED
