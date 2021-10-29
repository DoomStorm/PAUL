;Read/write from/to INI configuration file
!macro WriteUserConfig _ENTRY _VALUE
	${WriteINIStr} $EXEDIR\$BASENAME.ini $BASENAME `${_ENTRY}` `${_VALUE}`
!macroend
!define WriteUserConfig "!insertmacro WriteUserConfig"

!macro ReadUserConfig _RESULT _ENTRY
	ClearErrors
	ReadINIStr ${_RESULT} $EXEDIR\$BASENAME.ini $BASENAME `${_ENTRY}`
!macroend
!define ReadUserConfig "!insertmacro ReadUserConfig"

!macro ReadUserConfigWithDefault _RESULT _ENTRY _VALUE
	${ReadINIStr} ${_RESULT} $EXEDIR\$BASENAME.ini $BASENAME `${_ENTRY}` `${_VALUE}`
!macroend
!define ReadUserConfigWithDefault "!insertmacro ReadUserConfigWithDefault"

!macro WriteLauncherSettings _ENTRY _VALUE
	CreateDirectory $DATADIRECTORY
	${WriteINIStr} $DATADIRECTORY\$APPIDSettings.ini $APPIDSettings `${_ENTRY}` `${_VALUE}`
	SetFileAttributes $DATADIRECTORY\$APPIDSettings.ini HIDDEN
!macroend
!define WriteLauncherSettings "!insertmacro WriteLauncherSettings"

!macro ReadLauncherSettings _RESULT _ENTRY
	ClearErrors
	ReadINIStr ${_RESULT} $DATADIRECTORY\$APPIDSettings.ini $APPIDSettings `${_ENTRY}`
!macroend
!define ReadLauncherSettings "!insertmacro ReadLauncherSettings"
