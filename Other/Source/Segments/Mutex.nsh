Var STATUSMUTEX

!macro MutexStarting
	; Create a mutex to indicate that the
	; launcher is still processing its script
	Push "$MUTEXSTRING::Starting"
	System::Call kernel32::CreateMutex(i0,i0,ts)i.s
	Pop $STATUSMUTEX
!macroend

!macro CloseMutex
	Push $STATUSMUTEX
	System::Call kernel32::CloseHandle(is)?e
!macroend

!macro MutexStopping
	; Create a mutex to indicate that the
	; launcher is currently stopping
	Push "$MUTEXSTRING::Stopping"
	System::Call kernel32::CreateMutex(i0,i0,ts)
!macroend
