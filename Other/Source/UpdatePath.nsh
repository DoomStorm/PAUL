/* UpdatePath v1.0.2
 * Azure Zanculmarktum
 *
 * Requires NewTextReplace plugin v0.5.
 *
 * Usage example:
 * ${UpdatePath} $SettingsDirectory\my.file file:/// $LastDirectory $CurrentDirectory "//"
 * ${UpdatePath} $SettingsDirectory\my.file file:/// $LastDrive $CurrentDrive "//"
 *
 * You can also use:
 * ${UpdatePathUTF16LE}
 * ${UpdatePathUTF8}
 *
 * or (case-sensitive)
 * ${UpdatePathCS}
 * ${UpdatePathUTF16LECS}
 * ${UpdatePathUTF8CS}
 */

!ifndef UPDATEPATH_INCLUDED
!define UPDATEPATH_INCLUDED
!include Util.nsh
!include WordFunc.nsh
!insertmacro WordReplace

!macro UpdatePathCall _CASE _FILE _SEARCH_PAIR _PREVIOUS_PATH _NEW_PATH _SLASH
	!verbose push
	!verbose 3
	Push `${_FILE}`
	Push `${_SEARCH_PAIR}`
	Push `${_PREVIOUS_PATH}`
	Push `${_NEW_PATH}`
	Push `${_SLASH}`
	Push `${_CASE}`
	${CallArtificialFunction} UpdatePath_
	!verbose pop
!macroend
!define UpdatePath          `!insertmacro UpdatePathCall "/S=0 /C=0"`
!define UpdatePathCS        `!insertmacro UpdatePathCSCall "/S=1 /C=0"`

!define UpdatePathUTF16LE   `!insertmacro UpdatePathCall "/S=0 /C=0 /U=1200"`
!define UpdatePathUTF16LECS `!insertmacro UpdatePathCSCall "/S=1 /C=0 /U=1200"`

!define UpdatePathUTF8      `!insertmacro UpdatePathCall "/S=0 /C=0 /U=65001"`
!define UpdatePathUTF8CS    `!insertmacro UpdatePathCSCall "/S=1 /C=0 /U=65001"`

!macro UpdatePath_
	!verbose push
	!verbose 3
		Exch $5 ; _CASE
		Exch
		Exch $4 ; _SLASH
		Exch
		Exch 2
		Exch $3 ; _NEW_PATH
		Exch 2
		Exch 3
		Exch $2 ; _PREVIOUS_PATH
		Exch 3
		Exch 4
		Exch $1 ; _SEARCH_PAIR
		Exch 4
		Exch 5
		Exch $0 ; _FILE
		Exch 5
		Push $6
		Push $7
		Push $8

	;=== Skip if file doesn't exist
		IfFileExists $0\*.* _UP_CleanupStack ; check if file is directory
		IfFileExists $0 _UP_ComparePaths _UP_CleanupStack

	_UP_ComparePaths:
		StrCmp $2 "" _UP_CleanupStack
		StrCmp $2 $3 _UP_CleanupStack _UP_ReplaceBackSlash

	_UP_ReplaceBackSlash:
		StrCmp $4 "" _UP_DefaultBackSlash
		StrCmp $4 "\" _UP_DefaultBackSlash

		Push $2
		Push "\"
		Push $4
		Push "+"
		${CallArtificialFunction2} WordReplace_
		Pop $6

		Push $3
		Push "\"
		Push $4
		Push "+"
		${CallArtificialFunction2} WordReplace_
		Pop $7

		Goto _UP_ReplaceInThisFile

	_UP_DefaultBackSlash:
		StrCpy $6 $2
		StrCpy $7 $3

	_UP_ReplaceInThisFile:
		; Fix NewTextReplace bug which always remove the last character
		CopyFiles /SILENT $0 $0.Backup
		FileOpen $8 $0 a
		FileSeek $8 "" END
		FileWriteByte $8 10
		FileClose $8

		Push $5
		Push $1$7
		Push $1$6
		Push $0.NewFile
		Push $0
		newtextreplace::_ReplaceInFile /NOUNLOAD
		Pop $8
		IntCmp $8 0 _UP_ReplaceFailed _UP_ReplaceFailed _UP_ReplaceSucceed

	_UP_ReplaceSucceed:
		Delete $0
		Rename $0.NewFile $0
		Delete $0.Backup
		Goto _UP_UnloadPlugins

	_UP_ReplaceFailed:
		Delete $0
		Rename $0.Backup $0
		Delete $0.NewFile

	_UP_UnloadPlugins:
		newtextreplace::_Unload

	_UP_CleanupStack:
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
!endif ; UPDATEPATH_INCLUDED
