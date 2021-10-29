; vim:ff=unix:gfn=Consolas\:h10:fdm=marker:fen:nowrap:ts=4:sts=0:sw=0:nu
;
; Use Vim for a better compatibility.
;
; Each segment will be called from here.

!macro SegmentOrder
	${SegmentStart}
	${Segment.onInit} ;{{{1
		!insertmacro Variables
		!insertmacro Constants

		!insertmacro ProgressWindow
		${!insertifmacrodef} Custom
	${SegmentInit} ;{{{1
		!insertmacro ExecString
		!insertmacro Launch
		!insertmacro SplashScreen

		; Sorry, I can't give my CER to ya :P
		!if /FileExists "${PAUL}\..\..\..\Cert\Certificate.nsh"
			!include "${PAUL}\..\..\..\Cert\Certificate.nsh"
		!endif

		!insertmacro InstanceManagement
		!insertmacro OpenMutex
		${!insertifmacrodef} Custom
		${If} ${PrimaryInstance}
			!insertmacro ProgressWindow
			!insertmacro Temp
			!insertmacro PluginsDir
			!insertmacro CheckProgramExecutable
		${EndIf}
		!insertmacro LiveMode
		${If} ${PrimaryInstance}
			!insertmacro OperatingSystem
			!insertmacro PathChecks
			!insertmacro BadExit
		${EndIf}
		${!insertifmacrodef} Language
	${SegmentPre} ;{{{1
		${If} ${PrimaryInstance}
			!insertmacro MutexStarting
			!insertmacro RuntimeData
		${EndIf}
		${!insertifmacrodef} Custom
	${SegmentPreLocal} ;{{{1
		${If} ${PrimaryInstance}
			${!insertifmacrodef} Service
			${!insertifmacrodef} Registry
			${!insertifmacrodef} Directory
			${!insertifmacrodef} File
			${!insertifmacrodef} Library
			${!insertifmacrodef} Custom
		${EndIf}
	${SegmentPrePortable} ;{{{1
		${If} ${PrimaryInstance}
			${!insertifmacrodef} UpdatePaths
			${!insertifmacrodef} RememberPaths
			${!insertifmacrodef} Registry
			${!insertifmacrodef} Custom
		${EndIf}
		${!insertifmacrodef} Language
		${If} ${PrimaryInstance}
			${!insertifmacrodef} Directory
			${!insertifmacrodef} File
			${!insertifmacrodef} Library
			${!insertifmacrodef} Service
		${EndIf}
	${SegmentPreLaunch} ;{{{1
		!insertmacro Temp
		!insertmacro ExecString
		${!insertifmacrodef} Custom
		${!insertifmacrodef} Language
		${If} ${PrimaryInstance}
			!insertmacro ProgressWindow
			!insertmacro SplashScreen
		${EndIf}
		!insertmacro WorkingDirectory
		${If} ${PrimaryInstance}
			!insertmacro CloseMutex
		${EndIf}
	${SegmentLaunchPrimary} ;{{{1
		!insertmacro EmptyWorkingSet
		!insertmacro Launch
		!insertmacro EmptyWorkingSet
		!insertmacro CheckRunning
	${SegmentLaunchSecondary} ;{{{1
		!insertmacro LaunchAndExit
	${SegmentPostLaunch} ;{{{1
		${If} ${PrimaryInstance}
			!insertmacro ProgressWindow
			!insertmacro MutexStopping
			${!insertifmacrodef} UnpinFromTaskbar
		${EndIf}
		${!insertifmacrodef} Custom
	${SegmentPostPortable} ;{{{1
		${If} ${PrimaryInstance}
			${!insertifmacrodef} Service
			${!insertifmacrodef} Library
			${If} $RUNLOCALLY != true
				${!insertifmacrodef} File
				${!insertifmacrodef} Directory
				${!insertifmacrodef} Custom
				${!insertifmacrodef} Registry
			${EndIf}
		${EndIf}
	${SegmentPostLocal} ;{{{1
		${If} ${PrimaryInstance}
			${!insertifmacrodef} Custom
			${!insertifmacrodef} Library
			${!insertifmacrodef} File
			${!insertifmacrodef} Directory
			${!insertifmacrodef} Registry
			${!insertifmacrodef} Service
		${EndIf}
	${SegmentPost} ;{{{1
		${!insertifmacrodef} Custom
		${If} ${PrimaryInstance}
			!insertmacro RuntimeData
		${EndIf}
	${SegmentCleanUp} ;{{{1
		${If} ${PrimaryInstance}
			${!insertifmacrodef} Registry
			${!insertifmacrodef} Directory
			${!insertifmacrodef} Custom
			!insertmacro WorkingDirectory
			!insertmacro LiveMode
			!insertmacro Temp
			!insertmacro PluginsDir
			!insertmacro ProgressWindow
		${EndIf}
	${SegmentUnload} ;{{{1
		${If} ${PrimaryInstance}
			!insertmacro ProgressWindow
		${EndIf}
		${!insertifmacrodef} Custom
		${!insertifmacrodef} Registry
		${If} ${PrimaryInstance}
			!insertmacro SplashScreen
		${EndIf}
	${SegmentEnd} ;}}}1
!macroend
