; vim:ff=unix:gfn=Consolas\:h10:fdm=marker:fen:nowrap:ts=4:sts=0:sw=0:nu
;
; Use Vim for a better compatibility.

!define ValidateRegistryKey `!insertmacro ValidateRegistryKeyCall`
!macro ValidateRegistryKeyCall _KEY _RESULT
	Push `${_KEY}`
	${CallArtificialFunction} ValidateRegistryKey_
	Pop ${_RESULT}
!macroend
!macro ValidateRegistryKey_
	; HKEY_CLASSES_ROOT  --> HKCU\Software\Classes
	; HKEY_CURRENT_USER  --> HKCU
	; HKEY_LOCAL_MACHINE --> HKLM
	; HKCR               --> HKCU\Software\Classes
	Exch $0
	Push $1
	StrCpy $1 $0 17
	${If} $1 == HKEY_CLASSES_ROOT
		StrCpy $0 $0 "" 17
		StrCpy $0 HKCU\Software\Classes$0
	${ElseIf} $1 == HKEY_CURRENT_USER
		StrCpy $0 $0 "" 17
		StrCpy $0 HKCU$0
	${Else}
		StrCpy $1 $0 18
		${If} $1 == HKEY_LOCAL_MACHINE
			StrCpy $0 $0 "" 18
			StrCpy $0 HKLM$0
		${Else}
			StrCpy $1 $0 4
			${If} $1 == HKCR
				StrCpy $0 $0 "" 4
				StrCpy $0 HKCU\Software\Classes$0
			${EndIf}
		${EndIf}
	${EndIf}
	Pop $1
	Exch $0
!macroend

!macro _LL_RegistryKeyExists _a _b _t _f
	!insertmacro _LOGICLIB_TEMP
	registry::_KeyExists /NOUNLOAD `${_b}`
	Pop $_LOGICLIB_TEMP
	!insertmacro _= $_LOGICLIB_TEMP 0 `${_t}` `${_f}`
!macroend
!define RegistryKeyExists `"" LL_RegistryKeyExists`

!macro BackupKeyCall _KEY
	!verbose push 3
	Push `${_KEY}`
	${CallArtificialFunction} BackupKey_
	!verbose pop
!macroend

!macro BackupValueCall _KEY _VALUE
	!verbose push 3
	Push `${_KEY}`
	Push `${_VALUE}`
	${CallArtificialFunction} BackupValue_
	!verbose pop
!macroend

!macro ImportKeyCall
	!verbose push 3
	${CallArtificialFunction} ImportKey_
	!verbose pop
!macroend

!macro ExportKeyCall _KEY
	!verbose push 3
	Push `${_KEY}`
	${CallArtificialFunction} ExportKey_
	!verbose pop
!macroend

!macro RestoreValueCall _KEY _VALUE
	!verbose push 3
	Push `${_KEY}`
	Push `${_VALUE}`
	${CallArtificialFunction} RestoreValue_
	!verbose pop
!macroend

!macro RestoreKeyCall _KEY
	!verbose push 3
	Push `${_KEY}`
	${CallArtificialFunction} RestoreKey_
	!verbose pop
!macroend

!define BackupKey "!insertmacro BackupKeyCall" ;{{{1

!macro BackupKey_
	!verbose push 3
	Exch $0
	Push $1
	Push $R0

	StrCpy $1 able-backup-key

	${ValidateRegistryKey} $0 $0

	; Skip this key if HKLM and we have
	; no administrator privileges
	StrCpy $R0 $0 4
	${If} $R0 == HKLM
	${AndIf} $ACCOUNTTYPE != admin
		StrCpy $1 unable-backup-key
	${EndIf}

	${If} $1 == able-backup-key
	${AndIfNot} ${RegistryKeyExists} HKEY_CURRENT_USER\Software\PurkdellApps\Keys\$0
	${AndIf} ${RegistryKeyExists} $0
		registry::_MoveKey /NOUNLOAD $0 HKEY_CURRENT_USER\Software\PurkdellApps\Keys\$0
		Pop $R0
	${EndIf}

	Pop $R0
	Pop $1
	Pop $0
	!verbose pop
!macroend

!define BackupValue "!insertmacro BackupValueCall" ;{{{1

!macro BackupValue_
	!verbose push 3
	Exch $1 ; value
	Exch
	Exch $0 ; key
	Exch
	Push $R0

	${ValidateRegistryKey} $0 $0

	registry::_MoveValue /NOUNLOAD $0 $1 HKEY_CURRENT_USER\Software\PurkdellApps\Values $0\$1
	Pop $R0

	Pop $R0
	Pop $1
	Pop $0
	!verbose pop
!macroend

!define ImportKey "!insertmacro ImportKeyCall" ;{{{1

!macro ImportKey_
	!verbose push 3
	Push $0
	Push $R0
	${If} ${IsFile} $DATADIRECTORY\$REGFILE
		StrCpy $0 success-import-key

		; Win9x/NT4 registration file
		registry::_RestoreKey /NOUNLOAD $DATADIRECTORY\$REGFILE
		Pop $R0
		${If} $R0 != 0
			; Win2K/XP registration file
			${If} ${IsFile} $SYSDIR\reg.exe
				nsExec::ExecToStack `"$SYSDIR\reg.exe" import "$DATADIRECTORY\$REGFILE"`
				Pop $R0
				${If} $R0 != 0
					StrCpy $0 failed-import-key
				${EndIf}
			${Else}
				StrCpy $0 failed-import-key
			${EndIf}
		${EndIf}

		${If} $0 == failed-import-key
			${WriteRuntimeData} RegistryKey FailedToRestoreKey true
		${Else}
			Sleep 100
		${EndIf}
	${EndIf}
	Pop $R0
	Pop $0
	!verbose pop
!macroend

!define ExportKey "!insertmacro ExportKeyCall" ;{{{1

!macro ExportKey_
	!verbose push 3
	Exch $0
	Push $1

	CreateDirectory $DATADIRECTORY
	registry::_SaveKey /NOUNLOAD $0 $DATADIRECTORY\$REGFILE /A=1
	Pop $1
	Sleep 100

	Pop $1
	Pop $0
	!verbose pop
!macroend

!define RestoreValue "!insertmacro RestoreValueCall" ;{{{1

!macro RestoreValue_
	!verbose push 3
	Exch $1 ; value
	Exch
	Exch $0 ; key
	Exch
	Push $R0

	${ValidateRegistryKey} $0 $0

	registry::_DeleteValue /NOUNLOAD $0 $1
	Pop $R0
	registry::_MoveValue /NOUNLOAD HKEY_CURRENT_USER\Software\PurkdellApps\Values $0\$1 $0 $1
	Pop $R0

	registry::_DeleteKeyEmpty /NOUNLOAD HKEY_CURRENT_USER\Software\PurkdellApps\Values
	Pop $R0
	registry::_DeleteKeyEmpty /NOUNLOAD HKEY_CURRENT_USER\Software\PurkdellApps
	Pop $R0

	Pop $R0
	Pop $1
	Pop $0
	!verbose pop
!macroend

!define RestoreKey "!insertmacro RestoreKeyCall" ;{{{1

!macro RestoreKey_
	!verbose push 3
	Exch $0
	Push $1
	Push $R0

	StrCpy $1 able-restore-key

	${ValidateRegistryKey} $0 $0

	; Skip this key if HKLM and we have
	; no administrator privileges
	StrCpy $R0 $0 4
	${If} $R0 == HKLM
	${AndIf} $ACCOUNTTYPE != admin
		StrCpy $1 unable-restore-key
	${EndIf}

	${If} $1 == able-restore-key
		registry::_DeleteKey /NOUNLOAD $0
		Pop $R0
		${If} ${RegistryKeyExists} HKEY_CURRENT_USER\Software\PurkdellApps\Keys\$0
			; Set original key back
			registry::_MoveKey /NOUNLOAD HKEY_CURRENT_USER\Software\PurkdellApps\Keys\$0 $0
			Pop $R0
			${Do}
				; Clean up the key
				${GetParent} $0 $0
				registry::_DeleteKeyEmpty /NOUNLOAD HKEY_CURRENT_USER\Software\PurkdellApps\Keys\$0
				Pop $R0
			${LoopUntil} $0 == ""
		${EndIf}

		; Clean up the rest key
		registry::_DeleteKeyEmpty /NOUNLOAD HKEY_CURRENT_USER\Software\PurkdellApps
		Pop $R0
	${EndIf}

	Pop $R0
	Pop $1
	Pop $0
	!verbose pop
!macroend
