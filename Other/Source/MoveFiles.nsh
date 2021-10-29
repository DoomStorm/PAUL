!ifndef MOVEFILES_NSH_INCLUDED
!define MOVEFILES_NSH_INCLUDED
!include Util.nsh
!include LogicLib.nsh
!include "${PAUL}\IsFile.nsh"

!define /ifndef FO_MOVE           0x0001
!define /ifndef FO_COPY           0x0002
!define /ifndef FO_DELETE         0x0003
!define /ifndef FO_RENAME         0x0004

!define /ifndef FOF_MULTIDESTFILES         0x0001
!define /ifndef FOF_CONFIRMMOUSE           0x0002
!define /ifndef FOF_SILENT                 0x0004  ; don't create progress/report
!define /ifndef FOF_RENAMEONCOLLISION      0x0008
!define /ifndef FOF_NOCONFIRMATION         0x0010  ; Don't prompt the user.
!define /ifndef FOF_WANTMAPPINGHANDLE      0x0020  ; Fill in SHFILEOPSTRUCT.hNameMappings
                                              ; Must be freed using SHFreeNameMappings
!define /ifndef FOF_ALLOWUNDO              0x0040
!define /ifndef FOF_FILESONLY              0x0080  ; on *.*, do only files
!define /ifndef FOF_SIMPLEPROGRESS         0x0100  ; means don't show names of files
!define /ifndef FOF_NOCONFIRMMKDIR         0x0200  ; don't confirm making any needed dirs
!define /ifndef FOF_NOERRORUI              0x0400  ; don't put up error UI
!define /ifndef FOF_NOCOPYSECURITYATTRIBS  0x0800  ; dont copy NT file Security Attributes

!macro MoveFilesCall _OPTIONS _FROM _TO
	!verbose push 3
	Push `${_OPTIONS}`
	Push `${_FROM}`
	Push `${_TO}`
	${CallArtificialFunction} MoveFiles_
	!verbose pop
!macroend
!define MoveFiles "!insertmacro MoveFilesCall"

!macro MoveFilesWithoutCall _EXCLUDE _FROM _TO
	!verbose push 3
	Push `${_EXCLUDE}`
	Push `${_FROM}`
	Push `${_TO}`
	${CallArtificialFunction} MoveFilesWithout_
	!verbose pop
!macroend
!define MoveFilesWithout "!insertmacro MoveFilesWithoutCall"

!macro MoveFiles_
	!verbose push 3
	Exch $2 ; _TO
	Exch
	Exch $1 ; _FROM
	Exch
	Exch 2
	Exch $0 ; _OPTIONS
	Exch 2
	Push $3
	Push $4
	Push $5

	StrCpy $3 ${FOF_NOCONFIRMATION}|${FOF_NOCONFIRMMKDIR}|${FOF_NOERRORUI}

	; Search for /SILENT parameter
	StrCpy $4 0
	${Do}
		StrCpy $5 $0 7 $4
		${IfThen} $5 == "" ${|} ${ExitDo} ${|}
		${If} $5 == /SILENT
			StrCpy $3 $3|${FOF_SILENT}
			${ExitDo}
		${EndIf}
		IntOp $4 $4 + 1
	${Loop}

	; Search for /FILESONLY parameter
	StrCpy $4 0
	${Do}
		StrCpy $5 $0 10 $4
		${IfThen} $5 == "" ${|} ${ExitDo} ${|}
		${If} $5 == /FILESONLY
			StrCpy $3 $3|${FOF_FILESONLY}
			${ExitDo}
		${EndIf}
		IntOp $4 $4 + 1
	${Loop}

	System::Call *(i$HWNDPARENT,i${FO_MOVE},t"$1",t"$2",i$3,i0,i0,i0)i.s
	Pop $4
	Push $4
	System::Call shell32::SHFileOperationW(is)
	System::Free $4

	Pop $5
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Pop $0
	!verbose pop
!macroend

!macro MoveFilesWithout_
	!verbose push 3
	Exch $2 ; _TO
	Exch
	Exch $1 ; _FROM
	Exch
	Exch 2
	Exch $0 ; _EXCLUDE
	Exch 2
	Push $3 ; _EXCLUDE len
	Push $4
	Push $5
	Push $6
	Push $7
	Push $8

	; Trim | from |string|
	StrCpy $7 $0 1
	${If} $7 == |
		StrCpy $0 $0 "" 1
	${EndIf}
	StrCpy $7 $0 1 -1
	${If} $7 == |
		StrCpy $0 $0 -1
	${EndIf}

	; Trim \*.* from source
	StrCpy $7 $1 4 -4 ; \*.*
	${If} $7 == \*.*
		StrCpy $1 $1 -4
	${EndIf}

	; Trim \*.* from target
	StrCpy $7 $2 4 -4 ; \*.*
	${If} $7 == \*.*
		StrCpy $2 $2 -4
	${EndIf}

	${If} ${IsDir} $1 ; be sure source is present
		; Create temp directory in the same directory
		GetTempFileName $8 $1
		Delete $8
		CreateDirectory $8

		; Be sure target is not a file
		Delete $2

		; Get characters beetween |
		; yo|hard|boiled|bat --> yo hard boiled bat
		StrLen $3 $0
		IntOp $3 $3 - 1 ; ignore last character that is "" (empty)
		StrCpy $4 0
		${Do}
			StrCpy $6 ""
			${For} $4 $4 $3
				StrCpy $5 $0 1 $4
				${If} $5 == |
					IntOp $4 $4 + 1
					${ExitFor}
				${EndIf}
				StrCpy $6 $6$5
			${Next}
			${If} $6 != ""
				; Preserve excluded files
				${MoveFiles} /SILENT $1\$6 $8
			${EndIf}
		${LoopUntil} $4 > $3

		; Move files
		StrCpy $3 ""
		${Do}
			${If} $3 == ""
				FindFirst $3 $4 $1\*.*
			${Else}
				FindNext $3 $4
			${EndIf}
			${IfThen} $4 == "" ${|} ${ExitDo} ${|}
			${If}   $4 == .
			${OrIf} $4 == ..
			${OrIf} $1\$4 == $8
				${Continue}
			${EndIf}
			${MoveFiles} /SILENT $1\$4 $2
		${Loop}
		FindClose $3

		; Restore excluded files
		${MoveFiles} /SILENT $8\*.* $1

		; Remove temp directory
		${RemoveDirectory} $8
	${EndIf}

	Pop $8
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
!endif ; MOVEFILES_NSH_INCLUDED
