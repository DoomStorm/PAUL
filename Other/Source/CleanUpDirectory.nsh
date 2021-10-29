; Azure Zanculmarktum
;
; Clean up any files and folders in the specified directory
;
; Usage:
; ${CleanUpDirectory} "path_to_dir" "excluded_files"
; excluded_files = list of excluded files separated by |
;                  leave it empty if you don't have any
;                  files or folders to be excluded
;
; Example:
; ${CleanUpDirectory} "C:\Dir" "myfile.txt|myfile2.txt|myfile3.txt"

!ifndef CLEANUPDIRECTORY_NSH_INCLUDED
!define CLEANUPDIRECTORY_NSH_INCLUDED
!include Util.nsh
!include LogicLib.nsh
!include "${PAUL}\MoveFiles.nsh"
!include "${PAUL}\RemoveDirectory.nsh"
!include "${PAUL}\IsFile.nsh"

!macro CleanUpDirectoryCall _PATH _EXCLUDE
	!verbose push 3
	Push `${_PATH}`
	Push `${_EXCLUDE}`
	${CallArtificialFunction} CleanUpDirectory_
	!verbose pop
!macroend
!define CleanUpDirectory "!insertmacro CleanUpDirectoryCall"

!macro CleanUpDirectory_
	!verbose push 3
	Exch $1 ; _EXCLUDE
	Exch
	Exch $0 ; _PATH
	Exch
	Push $2 ; _EXCLUDE len
	Push $3
	Push $4
	Push $5
	Push $6
	Push $7 ; temp directory

	${If} ${IsDir} $0
		${If} $1 != ""
			; Trim | from |string|
			StrCpy $6 $1 1
			${If} $6 == |
				StrCpy $1 $1 "" 1
			${EndIf}
			StrCpy $6 $1 1 -1
			${If} $6 == |
				StrCpy $1 $1 -1
			${EndIf}

			; Create temp directory in the same directory
			GetTempFileName $7 $0
			Delete $7
			CreateDirectory $7

			; Get characters beetween |
			; yo|hard|boiled|bat --> yo hard boiled bat
			StrLen $2 $1
			IntOp $2 $2 - 1 ; ignore last character that is "" (empty)
			StrCpy $3 0
			${Do}
				StrCpy $5 ""
				${For} $3 $3 $2
					StrCpy $4 $1 1 $3
					${If} $4 == |
						IntOp $3 $3 + 1
						${ExitFor}
					${EndIf}
					StrCpy $5 $5$4
				${Next}
				${If} $5 != ""
					; Preserve excluded files
					${MoveFiles} "/SILENT" $0\$5 $7
				${EndIf}
			${LoopUntil} $3 > $2
		${EndIf}

		; Clean up any files and folders
		StrCpy $2 ""
		${Do}
			${If} $2 == ""
				FindFirst $2 $3 $0\*.*
			${Else}
				FindNext $2 $3
			${EndIf}
			${IfThen} $3 == "" ${|} ${ExitDo} ${|}
			${If}   $3 == .
			${OrIf} $3 == ..
				${Continue}
			${EndIf}
			${If} $1 != ""
				${If} $0\$3 == $7
					${Continue}
				${EndIf}
			${EndIf}
			${If} ${IsDir} $0\$3
				${RemoveDirectory} $0\$3
			${ElseIf} ${IsFile} $0\$3
				Delete $0\$3
			${EndIf}
		${Loop}
		FindClose $2

		${If} $1 != ""
			; Restore excluded files
			${MoveFiles} "/SILENT" $7\*.* $0

			; Remove temp directory
			${RemoveDirectory} $7
		${EndIf}
	${EndIf}

	Pop $7
	Pop $6
	Pop $5
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Pop $0
	!verbose pop
!macroend
!endif ; CLEANUPDIRECTORY_NSH_INCLUDED
