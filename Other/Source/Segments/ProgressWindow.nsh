!ifdef PROGRESSWINDOW
!define /ifndef SWP_NOSIZE          0x0001
!define /ifndef SWP_NOMOVE          0x0002
!define /ifndef SWP_NOZORDER        0x0004
!define /ifndef SWP_NOREDRAW        0x0008
!define /ifndef SWP_NOACTIVATE      0x0010
!define /ifndef SWP_FRAMECHANGED    0x0020  ; The frame changed: send WM_NCCALCSIZE
!define /ifndef SWP_SHOWWINDOW      0x0040
!define /ifndef SWP_HIDEWINDOW      0x0080
!define /ifndef SWP_NOCOPYBITS      0x0100
!define /ifndef SWP_NOOWNERZORDER   0x0200  ; Don't do owner Z ordering
!define /ifndef SWP_NOSENDCHANGING  0x0400  ; Don't send WM_WINDOWPOSCHANGING

!define /ifndef SWP_DRAWFRAME       ${SWP_FRAMECHANGED}
!define /ifndef SWP_NOREPOSITION    ${SWP_NOOWNERZORDER}

!define /ifndef SWP_DEFERERASE      0x2000
!define /ifndef SWP_ASYNCWINDOWPOS  0x4000


!define /ifndef HWND_TOP        0
!define /ifndef HWND_BOTTOM     1
!define /ifndef HWND_TOPMOST    -1
!define /ifndef HWND_NOTOPMOST  -2

Var HIDEPROGRESSWINDOW
Var CURRENTPROGRESS

!macro ProgressMessage _MESSAGE _VALUE
	${If} $HIDEPROGRESSWINDOW != true
		SetDetailsPrint textonly
		DetailPrint `${_MESSAGE}...`
		Sleep 200
		SetDetailsPrint none

		RealProgress::AddProgress /NOUNLOAD `${_VALUE}`

		IntOp $CURRENTPROGRESS $CURRENTPROGRESS + `${_VALUE}`
		${TBProgress_Progress} $CURRENTPROGRESS 100
	${EndIf}
!macroend

!macro DisableTopMost
	${If} $HIDEPROGRESSWINDOW != true
		System::Call user32::SetWindowPos(i$HWNDPARENT,i${HWND_NOTOPMOST},i,i,i,i,i${SWP_NOSIZE}|${SWP_NOMOVE})
	${EndIf}
!macroend

!macro EnableTopMost
	${If} $HIDEPROGRESSWINDOW != true
		System::Call user32::SetWindowPos(i$HWNDPARENT,i${HWND_TOPMOST},i,i,i,i,i${SWP_NOSIZE}|${SWP_NOMOVE})
	${EndIf}
!macroend

!macro ProgressWindow
	${SegmentStart}
	${Segment.onInit}
		${ReadUserConfigWithDefault} $HIDEPROGRESSWINDOW HideProgressWindow false

		${If} $HIDEPROGRESSWINDOW != true
			${WordReplace} $EXEDIR "\" "-" "+" $0
			StrCpy $0 "$0-$BASENAME::ProgressWindow"

			Push $0
			System::Call kernel32::OpenMutex(i1048576,b0,ts)i.r1?e
			System::Call kernel32::CloseHandle(ir1)
			Pop $2
			${If} $2 <> 2
				StrCpy $HIDEPROGRESSWINDOW true
			${EndIf}

			Push $0
			System::Call kernel32::CreateMutex(i0,i0,ts)
		${EndIf}

		${If} $HIDEPROGRESSWINDOW != true
			SetSilent normal
			SetDetailsPrint none
		${EndIf}
	${SegmentInit}
		${If} $HIDEPROGRESSWINDOW != true
			RealProgress::UseProgressBar /NOUNLOAD 9994
		${EndIf}
	${SegmentPreLaunch}
		${ProgressMessage} "Launching app" ""
		${If} $HIDEPROGRESSWINDOW != true
			Sleep 300
			HideWindow
		${EndIf}
	${SegmentPostLaunch}
		${If} $HIDEPROGRESSWINDOW != true
			BringToFront
		${EndIf}
	${SegmentCleanUp}
		${ProgressMessage} "Unloading plugins" ""
		${If} $HIDEPROGRESSWINDOW != true
			Sleep 300
		${EndIf}
	${SegmentUnload}
		${If} $HIDEPROGRESSWINDOW != true
			RealProgress::Unload
		${EndIf}
	${SegmentEnd}
!macroend

!else ; PROGRESSWINDOW
!macro ProgressMessage _MESSAGE _VALUE
!macroend

!macro DisableTopMost
!macroend

!macro EnableTopMost
!macroend

!macro ProgressWindow
!macroend
!endif ; PROGRESSWINDOW

!define ProgressMessage "!insertmacro ProgressMessage"
!define DisableTopMost "!insertmacro DisableTopMost"
!define EnableTopMost "!insertmacro EnableTopMost"
