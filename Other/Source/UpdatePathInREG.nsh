/* UpdatePathInREG v1.1
 * Azure Zanculmarktum
 *
 * Update path or drive letters in REG file.
 * Requires NewTextReplace plugin v0.5, Registry plugin v4.1
 * and nsisFile plugin v1.0.
 *
 * This is can be used also to replace binary data in
 * the REG file such as:
 * REG_BINARY
 * REG_EXPAND_SZ
 * ...
 *
 * Usage:
 * ${UpdatePathInREG} path_to_reg_file path_from_ran_last current_path
 * or (case-sensitive)
 * ${UpdatePathInREGCS} path_to_reg_file path_from_ran_last current_path
 *
 * Example:
 * ${UpdatePathInREG} $SettingsDirectory\MyReg.reg $LastDirectory $CurrentDirectory
 * ${UpdatePathInREG} $SettingsDirectory\MyReg.reg $LastDrive $CurrentDrive
 * or (case-sensitive)
 * ${UpdatePathInREGCS} $SettingsDirectory\MyReg.reg $LastDirectory $CurrentDirectory
 * ${UpdatePathInREGCS} $SettingsDirectory\MyReg.reg $LastDrive $CurrentDrive
 */

!ifndef UPDATEPATHINREG_INCLUDED
!define UPDATEPATHINREG_INCLUDED
!include Util.nsh
!include WordFunc.nsh
!insertmacro WordReplace

!macro UpdatePathInREGCall _CASE _FILE _PREVIOUS_PATH _NEW_PATH
	!verbose push
	!verbose 3
	Push `${_FILE}`
	Push `${_PREVIOUS_PATH}`
	Push `${_NEW_PATH}`
	Push `${_CASE}`
	${CallArtificialFunction} UpdatePathInREG_
	!verbose pop
!macroend
!define UpdatePathInREG "!insertmacro UpdatePathInREGCall /S=0"
!define UpdatePathInREGCS "!insertmacro UpdatePathInREGCall /S=1"

!macro _UPIREG_ReplaceInThisFile _FIND_IT _REPLACE_WITH
	!verbose push
	!verbose 3
		Push `${_FIND_IT}`
		Push `${_REPLACE_WITH}`
		Push $0
		Push $3
		Push $R0

		Exch $4 ; $R0
		Exch
		Exch $3 ; $3
		Exch
		Exch 2
		Exch $2 ; $0
		Exch 2
		Exch 3
		Exch $1 ; _REPLACE_WITH
		Exch 3
		Exch 4
		Exch $0 ; _FIND_IT
		Exch 4
		Push $5
		Push $6

		!ifndef _UPIREG_RITF_Var
			!define _UPIREG_RITF_Var
			Var /GLOBAL _UPIREG_RITF_IsSucceed
		!endif

		!ifdef UPIREG_RITF_
			!undef UPIREG_RITF_
		!endif
		!define UPIREG_RITF_ ${__LINE__}

	;=== Fix NewTextReplace bug which always removed the last character
		CopyFiles /SILENT $2.NewFile $2.NewFileBackup
		FileOpen $5 $2.NewFileBackup a
		FileSeek $5 "" END
		FileWriteByte $5 10
		FileClose $5

		Delete $2.TestReplace

	;=== Check for Win9x/NT4
		StrCmp $4 Win9x _${UPIREG_RITF_}UseWin9x _${UPIREG_RITF_}UseWin2K

	_${UPIREG_RITF_}UseWin9x:
		Push "$3 /C=0"
		Goto _${UPIREG_RITF_}ReplaceNow

	_${UPIREG_RITF_}UseWin2K:
		Push "$3 /C=0 /U=1200"

	_${UPIREG_RITF_}ReplaceNow:
		Push $1
		Push $0
		Push $2.TestReplace
		Push $2.NewFileBackup
		newtextreplace::_ReplaceInFile /NOUNLOAD
		Pop $6
		IntCmp $6 0 _${UPIREG_RITF_}ReplaceFailed _${UPIREG_RITF_}ReplaceFailed

	;=== Restore the file to the previous name if succeed
		Delete $2.NewFile
		Delete $2.NewFileBackup
		Rename $2.TestReplace $2.NewFile
		StrCpy $_UPIREG_RITF_IsSucceed true
		Goto _${UPIREG_RITF_}Undefine

	_${UPIREG_RITF_}ReplaceFailed:
		Delete $2.TestReplace
		Delete $2.NewFileBackup
		StrCmp $_UPIREG_RITF_IsSucceed true _${UPIREG_RITF_}Undefine
		StrCpy $_UPIREG_RITF_IsSucceed false

	_${UPIREG_RITF_}Undefine:
		!undef UPIREG_RITF_

		Pop $6
		Pop $5
		Pop $4
		Pop $3
		Pop $2
		Pop $1
		Pop $0
	!verbose pop
!macroend

!macro _UPIREG_ConvertToHex _STRING _RESULT
	!verbose push
	!verbose 3
		Push `${_STRING}`

		Exch $0
		Push $1
		Push $2
		Push $3
		Push $4

		!ifdef UPIREG_CTH_
			!undef UPIREG_CTH_
		!endif
		!define UPIREG_CTH_ ${__LINE__}

	;=== Convert to hexadecimal
		Push $0
		registry::_StrToHexA /NOUNLOAD
		Pop $1

		StrCpy $2 ""
		StrCpy $3 0

	_${UPIREG_CTH_}Combine:
		StrCpy $4 $1 2 $3
		StrCmp $4 "" _${UPIREG_CTH_}StoreResult

	;=== Combine each two characters with comma and double 0 (zero)
		StrCmp $2 "" "" +3
		StrCpy $2 $4,00
		Goto +2
		StrCpy $2 $2,$4,00

		IntOp $3 $3 + 2
		Goto _${UPIREG_CTH_}Combine

	_${UPIREG_CTH_}StoreResult:
		StrCpy $0 $2

		!undef UPIREG_CTH_

		Pop $4
		Pop $3
		Pop $2
		Pop $1
		Exch $0

		Pop ${_RESULT}
	!verbose pop
!macroend

!macro UpdatePathInREG_
	!verbose push
	!verbose 3
		Exch $3 ; _CASE
		Exch
		Exch $2 ; _NEW_PATH
		Exch
		Exch 2
		Exch $1 ; _PREVIOUS_PATH
		Exch 2
		Exch 3
		Exch $0 ; _FILE
		Exch 3
		Push $4
		Push $5
		Push $6
		Push $7
		Push $8
		Push $9
		Push $R0

		StrCmp $1 "" _UPIREG_CleanupStack
		StrCmp $1 $2 _UPIREG_CleanupStack
		IfFileExists $0\*.* _UPIREG_CleanupStack
		IfFileExists $0 _UPIREG_CheckForWin9x _UPIREG_CleanupStack

	_UPIREG_CheckForWin9x:
		Delete $0.NewFile

		FileOpen $4 $0 r

		;=== Is it Win9x/NT4?
		FileRead $4 $5
		StrCpy $6 $5 8
		StrCmp $6 REGEDIT4 _UPIREG_Win9x _UPIREG_Win2K

	_UPIREG_Win9x:
		StrCpy $R0 Win9x
		Goto _UPIREG_FixREG

	_UPIREG_Win2K:
		;=== No it's not, use Win2K/XP instead
		StrCpy $R0 Win2K

	_UPIREG_FixREG:
		FileSeek $4 "" SET

	_UPIREG_NextLine:
		StrCpy $7 0
		StrCpy $8 $\r$\n

		ClearErrors
		StrCmp $R0 Win9x "" +3
		FileRead $4 $5
		Goto +2
		FileReadUTF16LE $4 $5
		IfErrors _UPIREG_EndOfFile _UPIREG_CheckValue

	_UPIREG_CheckValue:
		StrCpy $6 $5 2 -2
		StrCmp $6 $\r$\n "" +2
		StrCpy $5 $5 -2

		StrCpy $6 $5 2
		StrCmp $6 "  " _UPIREG_PlaceHexInOneLine

		StrCpy $6 $5 1
		StrCmp $6 '"' _UPIREG_CheckForHex _UPIREG_AppendToNewFile

	_UPIREG_CheckForHex:
		StrCpy $6 $5 4 $7
		IntOp $7 $7 + 1
		StrCmp $6 "" _UPIREG_AppendToNewFile
		StrCmp $6 =hex _UPIREG_GetHex
		Goto _UPIREG_CheckForHex

	_UPIREG_GetHex:
		StrCpy $6 $5 1 $7
		IntOp $7 $7 + 1
		StrCmp $6 "" _UPIREG_AppendToNewFile
		StrCmp $6 : _UPIREG_PlaceHexInOneLine
		Goto _UPIREG_GetHex

	_UPIREG_PlaceHexInOneLine:
		StrCmp $6 "  " "" +2
		StrCpy $5 $5 "" 2

		StrCpy $6 $5 1 -1
		StrCmp $6 "\" "" _UPIREG_AppendToNewFile
		StrCpy $5 $5 -1

		StrCpy $8 ""

	_UPIREG_AppendToNewFile:
		FileOpen $9 $0.NewFile a
		FileSeek $9 "" END
		StrCmp $R0 Win9x "" +3
		FileWrite $9 $5$8
		Goto +2
		FileWriteUTF16LE $9 $5$8
		FileClose $9

		Goto _UPIREG_NextLine

	_UPIREG_EndOfFile:
		FileClose $4

		IfFileExists $0.NewFile _UPIREG_ReplaceIt _UPIREG_CleanupStack

	_UPIREG_ReplaceIt:
		;=== Convert previous path to double back-slash
		Push $1
		Push "\"
		Push "\\"
		Push "+"
		${CallArtificialFunction2} WordReplace_
		Pop $4

		;=== Convert new path to double back-slash
		Push $2
		Push "\"
		Push "\\"
		Push "+"
		${CallArtificialFunction2} WordReplace_
		Pop $5

		!insertmacro _UPIREG_ReplaceInThisFile $4 $5

		!insertmacro _UPIREG_ConvertToHex $1 $4
		!insertmacro _UPIREG_ConvertToHex $2 $5
		!insertmacro _UPIREG_ReplaceInThisFile $4 $5

		StrCmp $_UPIREG_RITF_IsSucceed true _UPIREG_Succeed _UPIREG_Failed

	_UPIREG_Succeed:
		Delete $0
		StrCmp $R0 Win9x "" _UPIREG_FixEncoding
		Rename $0.NewFile $0
		Goto _UPIREG_UnloadPlugins

	_UPIREG_FixEncoding:
		FileOpen $7 $0.NewFile r
		FileOpen $9 $0 a
		FileWriteByte $9 255
		FileWriteByte $9 254

	_UPIREG_Loop:
		nsisFile::FileReadBytes $7 3072
		Pop $8
		StrCmp $8 "" _UPIREG_Done

		nsisFile::FileWriteBytes $9 $8
		Goto _UPIREG_Loop

	_UPIREG_Done:
		FileClose $7
		FileClose $9

	_UPIREG_Failed:
		Delete $0.NewFile

	_UPIREG_UnloadPlugins:
		newtextreplace::_Unload
		registry::_Unload

	_UPIREG_CleanupStack:
		Pop $R0
		Pop $9
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
!endif ; UPDATEPATHINREG_INCLUDED
