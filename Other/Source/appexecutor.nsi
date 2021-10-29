; Azure Zanculmarktum
;
; This file is used to execute an executable file
; in combination with StdUtils::ExecShellAsUser.
; While ExecShellAsUser can't pass environment variable
; to the target executable, this will do the trick.

!include RequireLatestNSIS.nsh

!searchreplace APPID "${__FILE__}" .nsi ""

Name "${APPID}"
Caption "${APPID}"
!packhdr "$%TEMP%\exehead.tmp" `"Bin\ResHacker.exe" -delete "$%TEMP%\exehead.tmp", "$%TEMP%\exehead.tmp", ICONGROUP, 103, 1033 && del "Bin\ResHacker.log" && del "Bin\ResHacker.ini"`
!system "mkdir ..\..\App\Bin >nul 2>&1"
OutFile "..\..\App\Bin\${APPID}.exe"
!if /FileExists ..\..\..\Cert\Sign.nsh
	!include ..\..\..\Cert\Sign.nsh
!endif

Unicode true
ManifestSupportedOS all
CRCCheck on
WindowIcon off
AutoCloseWindow true
RequestExecutionLevel user
XPStyle on

SetCompress auto
SetCompressor /SOLID lzma
SetCompressorDictSize 32
SetDatablockOptimize on

!include LogicLib.nsh
!include TextFunc.nsh
!include WordFunc.nsh
!include IsFile.nsh

Function .onInit
	SetSilent silent
FunctionEnd

Section "Main"
	${If} ${IsFile} "$EXEDIR\${APPID}.ini"
		ReadINIStr $0 "$EXEDIR\${APPID}.ini" Executable Path
		${If} $0 != ""
			FileOpen $0 "$EXEDIR\${APPID}.ini" r
			${Do}
				ClearErrors
				FileRead $0 $1
				${IfThen} ${Errors} ${|} ${ExitDo} ${|}
				${TrimNewLines} $1 $1
				StrCpy $2 $1 1
				${If} $1 == ""
				${OrIf} $2 == ";"
					${Continue}
				${EndIf}
				${IfThen} $1 == [Environment] ${|} ${ExitDo} ${|}
			${Loop}

			${If} $1 == [Environment]
				${Do}
					ClearErrors
					FileRead $0 $1
					${IfThen} ${Errors} ${|} ${ExitDo} ${|}
					${TrimNewLines} $1 $1
					StrCpy $2 $1 1
					${If} $1 == ""
					${OrIf} $2 == ";"
						${Continue}
					${ElseIf} $2 == [
						${ExitDo}
					${EndIf}

					StrLen $3 $1
					StrCpy $4 0
					${Do}
						StrCpy $5 $1 $4
						StrCpy $6 $5 "" -1
						${If} $4 = $3
						${OrIf} $6 == =
							${ExitDo}
						${EndIf}
						IntOp $4 $4 + 1
					${Loop}

					${If} $6 == =
						StrLen $7 $5
						StrCpy $8 $5 -1
						StrCpy $9 $1 "" $7

						Push $9
						Push $8
						System::Call kernel32::SetEnvironmentVariable(ts,ts)
					${EndIf}
				${Loop}
			${EndIf}

			ReadINIStr $1 "$EXEDIR\${APPID}.ini" Executable Path
			ReadINIStr $2 "$EXEDIR\${APPID}.ini" Executable Parameters
			${WordReplace} $1 '"' "" + $1
			Exec `"$1" $2`

			FileClose $0
		${EndIf}
		Delete "$EXEDIR\${APPID}.ini"
	${EndIf}
SectionEnd
