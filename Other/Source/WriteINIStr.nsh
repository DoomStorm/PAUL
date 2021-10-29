/* Azure Zanculmarktum
 *
 * Add a space beetween [Section] in INI file.
 * Requires NewTextReplace v0.5 plug-in.
 *
 * [Section]
 * Entry=Value
 * [Section2]
 * Entry2=Value2
 *
 * Become:
 *
 * [Section]
 * Entry=Value
 *
 * [Section2]
 * Entry2=Value2
 *
 * Usage:
 * Just like using default WriteINIStr.
 */

!ifndef WRITEINISTR_INCLUDED
!define WRITEINISTR_INCLUDED
!include Util.nsh

!macro WriteINIStrCall _FILE _SECTION _ENTRY _VALUE
	!verbose push
	!verbose 3
	Push `${_FILE}`
	Push `${_SECTION}`
	Push `${_ENTRY}`
	Push `${_VALUE}`
	${CallArtificialFunction2} WriteINIStr_
	!verbose pop
!macroend
!define WriteINIStr "!insertmacro WriteINIStrCall"

!macro WriteINIStr_
	!verbose push
	!verbose 3
	Exch $3 ; _VALUE
	Exch
	Exch $2 ; _ENTRY
	Exch
	Exch 2
	Exch $1 ; _SECTION
	Exch 2
	Exch 3
	Exch $0 ; _FILE
	Exch 3
	Push $4
	Push $5

	IfFileExists $0\*.* WriteINIStr_StackCleanup
	IfFileExists $0 "" WriteINIStr_WriteOutput
		newtextreplace::_FindInFile $0 [$1] ""
		Pop $4
		IntCmp $4 0 "" "" WriteINIStr_WriteOutput
			FileOpen $4 $0 a
			FileSeek $4 -2 END ; get 2 characters from the end of the file
			FileRead $4 $5
			FileSeek $4 "" END
			StrCmp $5 $\r$\n +2
			FileWrite $4 $\r$\n
			FileWrite $4 $\r$\n
			FileClose $4

	WriteINIStr_WriteOutput:
		WriteINIStr $0 $1 $2 $3

	WriteINIStr_StackCleanup:
		Pop $5
		Pop $4
		Pop $3
		Pop $2
		Pop $1
		Pop $0

		newtextreplace::_Unload
	!verbose pop
!macroend
!endif ; WRITEINISTR_INCLUDED
