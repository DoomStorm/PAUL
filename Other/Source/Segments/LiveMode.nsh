!macro LiveMode
	${SegmentStart}
	${SegmentInit}
		${ReadUserConfigWithDefault} $RUNLOCALLY RunLocally false

		${If} $RUNLOCALLY != true
		${AndIf} ${PrimaryInstance}
			CreateDirectory $DATADIRECTORY
			ClearErrors
			;=== Check for read/write
			FileOpen $R0 $DATADIRECTORY\writetest.tmp w
			${If} ${Errors}
				;== Write failed, so we're read-only
				${MessageBox} ${MB_YESNO}|${MB_ICONQUESTION} "$PORTABLEAPPNAME can not run directly from a read-only location. Would you like to temporarily copy it to the local hard drive and run it from there?"
				Pop $0
				${If} $0 == yes
					StrCpy $RUNLOCALLY true
				${Else}
					Goto TheEnd
				${EndIf}
			${Else}
				;== Write sucessful, so delete it
				FileClose $R0
				Delete $DATADIRECTORY\writetest.tmp
			${EndIf}
		${EndIf}

		;=== Check if we previously were in Live mode
		Push "$MUTEXSTRING::LiveMode"
		System::Call kernel32::OpenMutex(i1048576,b0,ts)i.r0?e
		System::Call kernel32::CloseHandle(ir0)
		Pop $0
		${If} $0 <> 2
			StrCpy $RUNLOCALLY true
		${EndIf}

		${If} $RUNLOCALLY == true
			;=== Create a mutex to indicate that the launcher is in Live mode
			Push "$MUTEXSTRING::LiveMode"
			System::Call kernel32::CreateMutex(i0,i0,ts)

			${If} ${PrimaryInstance}
				;=== Copy all the necessary files to temporary directory
				${RemoveDirectory} $LIVEDIRECTORY
				CreateDirectory $LIVEDIRECTORY\App
				CreateDirectory $LIVEDIRECTORY\Data
				CopyFiles /SILENT $APPDIRECTORY\*.* $LIVEDIRECTORY\App
				CopyFiles /SILENT $DATADIRECTORY\*.* $LIVEDIRECTORY\Data
			${EndIf}

			;=== Set up variables for use in Live mode
			StrCpy $APPDIRECTORY $LIVEDIRECTORY\App
			StrCpy $DATADIRECTORY $LIVEDIRECTORY\Data
			StrCpy $PROGRAMDIRECTORY "$APPDIRECTORY\${APPDIR}"
			StrCpy $SETTINGSDIRECTORY "$DATADIRECTORY\${APPDIR}"
		${EndIf}
	${SegmentCleanUp}
		${If} $RUNLOCALLY == true
			${RemoveDirectory} $LIVEDIRECTORY
		${EndIf}
	${SegmentEnd}
!macroend
