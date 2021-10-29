Var DISABLESPLASHSCREEN
Var SPLASHSCREENHANDLE

!macro SplashScreen
	${SegmentStart}
	${SegmentInit}
		${ReadUserConfigWithDefault} $DISABLESPLASHSCREEN DisableSplashScreen false
	${SegmentPreLaunch}
		; Check if PortableApps.com Platform wants to disable splash screen
		${If} ${IsFile} $PORTABLEAPPSPATH\PortableApps.com\PortableAppsPlatform.exe
		${AndIf} ${ProcessExists} PortableAppsPlatform.exe
			ReadEnvStr $DISABLESPLASHSCREEN PortableApps.comDisableSplash
		${EndIf}

		; Show the splash screen
		${If} $DISABLESPLASHSCREEN != true
			${If} ${IsFile} $DATADIRECTORY\Splash.bmp
				StrCpy $0 $DATADIRECTORY\Splash.bmp
			${Else}
				InitPluginsDir
				FileOpen $SPLASHSCREENHANDLE $PLUGINSDIR\PurkdellApps w
				!include "${PAUL}\Splash.nsh"
				StrCpy $0 $PLUGINSDIR\PurkdellApps
			${EndIf}
			newadvsplash::show /NOUNLOAD 1000 300 200 0xFF00FF /L $0
		${EndIf}
	${SegmentUnload}
		${If} $DISABLESPLASHSCREEN != true
			FileClose $SPLASHSCREENHANDLE
			newadvsplash::stop /WAIT
		${EndIf}
	${SegmentEnd}
!macroend
