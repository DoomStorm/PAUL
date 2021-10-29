!macro Variables
	; Initialize variables
	${GetBaseName} $EXEFILE $BASENAME

	StrCpy $PORTABLEAPPNAME "${PORTABLEAPPNAME}"
	StrCpy $APPNAME "${APPNAME}"
	StrCpy $APPID "${APPID}"

	System::Call kernel32::GetCurrentProcess()i.s
	System::Call kernel32::IsWow64Process(is,*i.s)
	Pop $0
	StrCmp $0 0 "" +3
		StrCpy $ARCHITECTURE x86
		Goto +2
		StrCpy $ARCHITECTURE x64

	StrCpy $APPDIRECTORY $EXEDIR\App
	StrCpy $DATADIRECTORY $EXEDIR\Data

	StrCpy $PROGRAMDIRECTORY "$APPDIRECTORY\${APPDIR}"
	!ifdef APPDIR64         ; is it defined?
	!if "${APPDIR64}" != "" ; if so, then is it has a value? If so, then execute this:
	StrCpy $PROGRAMDIRECTORY64 "$APPDIRECTORY\${APPDIR64}"
	!endif
	!endif

	StrCpy $SETTINGSDIRECTORY "$DATADIRECTORY\${APPDIR}"

	StrCpy $DEFAULTDATADIRECTORY "$APPDIRECTORY\DefaultData\${APPDIR}"

	${GetParent} $EXEDIR $PORTABLEAPPSPATH

	StrCpy $TEMPDIRECTORY $TEMP\$APPIDTemp
	StrCpy $LIVEDIRECTORY $TEMP\$APPIDLive

	${GetRoot} $EXEDIR $CURRENTDRIVE

	StrCpy $REGFILE "${SHORTNAME}.reg"

	; Do we have administrator privileges?
	System::Call kernel32::GetModuleHandle(t"shell32.dll")i.s
	System::Call kernel32::GetProcAddress(is,i680)i.s
	Pop $0
	System::Call ::$0()i.s
	Pop $0
	StrCmp $0 1 "" +3
		StrCpy $ACCOUNTTYPE admin
		Goto +2
		StrCpy $ACCOUNTTYPE user

	${ReadLauncherSettings} $LASTDRIVE LastDrive
	${ReadLauncherSettings} $LASTDIRECTORY LastDirectory
!macroend
