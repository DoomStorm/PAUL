/* Azure Zanculmarktum
 *
 * Read INI string and write with the default
 * value if entry doesn't exist.
 *
 * Usage:
 * ${ReadINIStr} $var file_name section_name entry_name value
 *
 * Example:
 * ${ReadINIStr} $0 MyFile.ini Section Entry Value
 */

!ifndef READINISTR_INCLUDED
!define READINISTR_INCLUDED
!include Util.nsh
!include "${PAUL}\WriteINIStr.nsh"

!macro ReadINIStrCall _RESULT _FILE _SECTION _ENTRY _VALUE
	!verbose push
	!verbose 3
	Push `${_FILE}`
	Push `${_SECTION}`
	Push `${_ENTRY}`
	Push `${_VALUE}`
	${CallArtificialFunction} ReadINIStr_
	Pop ${_RESULT}
	!verbose pop
!macroend
!define ReadINIStr "!insertmacro ReadINIStrCall"

!macro ReadINIStr_
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

	ReadINIStr $4 $0 $1 $2
	StrCmp $4 "" "" ReadINIStr_StackCleanup
		${WriteINIStr} $0 $1 $2 $3
		StrCpy $4 $3

	ReadINIStr_StackCleanup:
		StrCpy $0 $4

		Pop $4
		Pop $3
		Pop $2
		Pop $1
		Exch $0
	!verbose pop
!macroend
!endif ; READINISTR_INCLUDED
