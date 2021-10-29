!macro EmptyWorkingSet
	; Moves unused physical memory to virtual memory
	System::Call kernel32::GetCurrentProcess()i.s
	System::Call psapi::EmptyWorkingSet(is)
!macroend
