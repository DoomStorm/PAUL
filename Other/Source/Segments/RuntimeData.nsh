;Macro: read/write from/to runtime data {{{1
!macro WriteRuntimeData _SECTION _ENTRY _VALUE
	!ifndef _WRD_Var
		!define _WRD_Var
		Var /GLOBAL _WRD_FileHandle
		Var /GLOBAL _WRD_FileHandleBackup
	!endif
	CreateDirectory $DATADIRECTORY
	FileClose $_WRD_FileHandle ; unlock
	FileClose $_WRD_FileHandleBackup ; unlock
	${WriteINIStr} $DATADIRECTORY\$BASENAMERuntimeData.ini `${_SECTION}` `${_ENTRY}` `${_VALUE}`
	InitPluginsDir
	${WriteINIStr} $PLUGINSDIR\RuntimeData.ini `${_SECTION}` `${_ENTRY}` `${_VALUE}`
	FileOpen $_WRD_FileHandle $DATADIRECTORY\$BASENAMERuntimeData.ini r ; lock
	FileOpen $_WRD_FileHandleBackup $PLUGINSDIR\RuntimeData.ini r ; lock
!macroend
!define WriteRuntimeData "!insertmacro WriteRuntimeData"

!macro ReadRuntimeData _RESULT _SECTION _ENTRY
	ClearErrors
	IfFileExists $DATADIRECTORY\$BASENAMERuntimeData.ini "" +3
	ReadINIStr ${_RESULT} $DATADIRECTORY\$BASENAMERuntimeData.ini `${_SECTION}` `${_ENTRY}`
	Goto +2
	ReadINIStr ${_RESULT} $PLUGINSDIR\RuntimeData.ini `${_SECTION}` `${_ENTRY}`
!macroend
!define ReadRuntimeData "!insertmacro ReadRuntimeData"

!macro DeleteRuntimeData
	FileClose $_WRD_FileHandle ; unlock
	FileClose $_WRD_FileHandleBackup ; unlock
	Delete $DATADIRECTORY\$BASENAMERuntimeData.ini
	Delete $PLUGINSDIR\RuntimeData.ini
!macroend
!define DeleteRuntimeData "!insertmacro DeleteRuntimeData"
;}}}1

!macro RuntimeData
	${SegmentStart}
	${SegmentPre}
		Delete $DATADIRECTORY\$BASENAMERuntimeData.ini
		; Store current state in runtime data
		${WriteRuntimeData} $APPID Status running
		${WriteRuntimeData} $APPID PluginsDir $PLUGINSDIR
	${SegmentPost}
		${DeleteRuntimeData}
	${SegmentEnd}
!macroend
