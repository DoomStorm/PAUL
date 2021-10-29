!ifndef MESSAGEBOX_INCLUDED
!define MESSAGEBOX_INCLUDED
!include Util.nsh

!define /ifndef MB_OK                       0x00000000
!define /ifndef MB_OKCANCEL                 0x00000001
!define /ifndef MB_ABORTRETRYIGNORE         0x00000002
!define /ifndef MB_YESNOCANCEL              0x00000003
!define /ifndef MB_YESNO                    0x00000004
!define /ifndef MB_RETRYCANCEL              0x00000005
!define /ifndef MB_CANCELTRYCONTINUE        0x00000006
!define /ifndef MB_ICONHAND                 0x00000010
!define /ifndef MB_ICONQUESTION             0x00000020
!define /ifndef MB_ICONEXCLAMATION          0x00000030
!define /ifndef MB_ICONASTERISK             0x00000040
!define /ifndef MB_USERICON                 0x00000080
!define /ifndef MB_ICONWARNING              ${MB_ICONEXCLAMATION}
!define /ifndef MB_ICONERROR                ${MB_ICONHAND}

!define /ifndef MB_ICONINFORMATION          ${MB_ICONASTERISK}
!define /ifndef MB_ICONSTOP                 ${MB_ICONHAND}

!define /ifndef MB_DEFBUTTON1               0x00000000
!define /ifndef MB_DEFBUTTON2               0x00000100
!define /ifndef MB_DEFBUTTON3               0x00000200
!define /ifndef MB_DEFBUTTON4               0x00000300

!define /ifndef MB_APPLMODAL                0x00000000
!define /ifndef MB_SYSTEMMODAL              0x00001000
!define /ifndef MB_TASKMODAL                0x00002000
!define /ifndef MB_HELP                     0x00004000

!define /ifndef MB_NOFOCUS                  0x00008000
!define /ifndef MB_SETFOREGROUND            0x00010000
!define /ifndef MB_DEFAULT_DESKTOP_ONLY     0x00020000

!define /ifndef MB_TOPMOST                  0x00040000
!define /ifndef MB_RIGHT                    0x00080000
!define /ifndef MB_RTLREADING               0x00100000

!macro MessageBoxCall _OPTIONS _MESSAGE
	!verbose push 3
	Push `${_OPTIONS}`
	Push `${_MESSAGE}`
	${CallArtificialFunction} MessageBox_
	!verbose pop
!macroend
!define MessageBox "!insertmacro MessageBoxCall"

!macro MessageBox_
	!verbose push 3
	Exch $1 ; _MESSAGE
	Exch
	Exch $0 ; _OPTIONS
	Exch
	Push $2
	System::Call kernel32::GetModuleHandle(i0)i.r2
	System::Call '*(&l4,i,i,t,t,i,t,i,k,i)i(,$HWNDPARENT,r2,"$1","$PORTABLEAPPNAME | PurkdellApps",0x00009000|$0,i103,_)i.r0'
	System::Call user32::MessageBoxIndirect(ir0)i.r1
	System::Free $0
	StrCmp $1 1 "" +3
		StrCpy $0 ok
		Goto +26
	StrCmp $1 2 "" +3
		StrCpy $0 cancel
		Goto +23
	StrCmp $1 3 "" +3
		StrCpy $0 abort
		Goto +20
	StrCmp $1 4 "" +3
		StrCpy $0 retry
		Goto +17
	StrCmp $1 5 "" +3
		StrCpy $0 ignore
		Goto +14
	StrCmp $1 6 "" +3
		StrCpy $0 yes
		Goto +11
	StrCmp $1 7 "" +3
		StrCpy $0 no
		Goto +8
	StrCmp $1 10 "" +3
		StrCpy $0 try
		Goto +5
	StrCmp $1 11 "" +3
		StrCpy $0 continue
		Goto +2
	StrCpy $0 ""
	Pop $2
	Pop $1
	Exch $0
	!verbose pop
!macroend
!endif ; MESSAGEBOX_INCLUDED
