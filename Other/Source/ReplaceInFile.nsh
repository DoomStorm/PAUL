!ifndef REPLACEINFILE_NSH_INCLUDED
!define REPLACEINFILE_NSH_INCLUDED
!include Util.nsh
!include FileFunc.nsh
!include "${PAUL}\MoveFiles.nsh"

!define /ifndef CP_ACP         0
!define /ifndef CP_UTF8    65001
!define /ifndef CP_UTF16LE  1200
!define /ifndef CP_UTF16BE  1201

!macro ReplaceInFileCall _OPTIONS _FILE _SEARCH _REPLACE
	!verbose push 3
	Push `${_OPTIONS}`
	Push `${_FILE}`
	Push `${_SEARCH}`
	Push `${_REPLACE}`
	${CallArtificialFunction} ReplaceInFile_
	!verbose pop
!macroend
!define ReplaceInFile          `!insertmacro ReplaceInFileCall ""`
!define ReplaceInFileCS        `!insertmacro ReplaceInFileCall "/S=1"`
!define ReplaceInFileUTF16LE   `!insertmacro ReplaceInFileCall "/U=${CP_UTF16LE}"`
!define ReplaceInFileUTF16LECS `!insertmacro ReplaceInFileCall "/U=${CP_UTF16LE} /S=1"`
!define ReplaceInFileUTF8      `!insertmacro ReplaceInFileCall "/U=${CP_UTF8}"`
!define ReplaceInFileUTF8CS    `!insertmacro ReplaceInFileCall "/U=${CP_UTF8} /S=1"`

!macro ReplaceInFile_
	!verbose push 3
		Exch $3 ; _REPLACE
		Exch
		Exch $2 ; _SEARCH
		Exch
		Exch 2
		Exch $1 ; _FILE
		Exch 2
		Exch 3
		Exch $0 ; _OPTIONS
		Exch 3
		Push $4 ; temp file
		Push $5 ; file handle
		Push $6 ; return value

	;=== Create duplicate
		${GetParent} $1 $4
		GetTempFileName $4 $4
		Delete $4
		CopyFiles /SILENT $1 $4

	;=== Fix NewTextReplace plugin which
	;    always remove the last character
	;    from the file
		FileOpen $5 $4 a
		FileSeek $5 "" END
		FileWriteByte $5 10
		FileClose $5

	;=== Replace in the file
		newtextreplace::_ReplaceInFile /NOUNLOAD $4 $4 $2 $3 $0
		Pop $6
		IntCmp $6 0 "" "" ${__MACRO__}_RenameToOriginal

	;=== Remove duplicate
		Delete $4
		Goto ${__MACRO__}_CleanUpStack

	${__MACRO__}_RenameToOriginal:
		Delete $1
		${MoveFiles} "/SILENT" $4 $1

	${__MACRO__}_CleanUpStack:
		newtextreplace::_Unload

		Pop $6
		Pop $5
		Pop $4
		Pop $3
		Pop $2
		Pop $1
		Pop $0
	!verbose pop
!macroend
!endif ; REPLACEINFILE_NSH_INCLUDED
