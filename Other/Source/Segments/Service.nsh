; Azure Zanculmarktum
;
; This is just rip-off of NSIS Service Library v1.8.1
; to make end-user usage much more easier.
;
; Usage:
; ${GetServiceStatus} service_name $output_var
; ${CreateService} service_name display_name service_type start_type error_control binary_path_name dependencies description
; ${DeleteService} service_name
; ${StartService} service_name
; ${StopService} service_name

!ifndef SERVICE_NSH_INCLUDED
!define SERVICE_NSH_INCLUDED
; Service Control Manager object specific access types
!define /ifndef SC_MANAGER_ALL_ACCESS          0x3F

; Service object specific access type
!define /ifndef SERVICE_ALL_ACCESS             0xF01FF

; Controls
!define /ifndef SERVICE_CONTROL_STOP           0x00000001

; Service State -- for CurrentState
!define /ifndef SERVICE_STOPPED                0x00000001
!define /ifndef SERVICE_START_PENDING          0x00000002
!define /ifndef SERVICE_STOP_PENDING           0x00000003
!define /ifndef SERVICE_RUNNING                0x00000004
!define /ifndef SERVICE_CONTINUE_PENDING       0x00000005
!define /ifndef SERVICE_PAUSE_PENDING          0x00000006
!define /ifndef SERVICE_PAUSED                 0x00000007

; Service Types (Bit Mask)
!define /ifndef SERVICE_KERNEL_DRIVER          0x00000001
!define /ifndef SERVICE_FILE_SYSTEM_DRIVER     0x00000002
!define /ifndef SERVICE_WIN32_OWN_PROCESS      0x00000010
!define /ifndef SERVICE_WIN32_SHARE_PROCESS    0x00000020
!define /ifndef SERVICE_INTERACTIVE_PROCESS    0x00000100

; Start Type
!define /ifndef SERVICE_BOOT_START             0x00000000
!define /ifndef SERVICE_SYSTEM_START           0x00000001
!define /ifndef SERVICE_AUTO_START             0x00000002
!define /ifndef SERVICE_DEMAND_START           0x00000003
!define /ifndef SERVICE_DISABLED               0x00000004

; Error control type
!define /ifndef SERVICE_ERROR_IGNORE           0x00000000
!define /ifndef SERVICE_ERROR_NORMAL           0x00000001
!define /ifndef SERVICE_ERROR_SEVERE           0x00000002
!define /ifndef SERVICE_ERROR_CRITICAL         0x00000003

; Info levels for ChangeServiceConfig2 and QueryServiceConfig2
!define /ifndef SERVICE_CONFIG_DESCRIPTION     1

!macro _ServiceExists _a _b _t _f
	!verbose push 3
	!ifndef RUNASADMIN
		!error "ServiceExists requires administrator privileges. Please !define RUNASADMIN and then recompile again."
	!else
		!insertmacro _LOGICLIB_TEMP
		Push `${_b}`
		${CallArtificialFunction} _LL_ServiceExists
		Pop $_LOGICLIB_TEMP
		!insertmacro _== $_LOGICLIB_TEMP true `${_t}` `${_f}`
	!endif
	!verbose pop
!macroend
!define ServiceExists `"" ServiceExists`

!macro GetServiceStatusCall _NAME _RESULT
	!verbose push 3
	Push `${_NAME}`
	${CallArtificialFunction} GetServiceStatus_
	Pop `${_RESULT}`
	!verbose pop
!macroend
!define GetServiceStatus "!insertmacro GetServiceStatusCall"

!macro CreateServiceCall _SERVICE_NAME _DISPLAY_NAME _SERVICE_TYPE _START_TYPE _ERROR_CONTROL _BINARY_PATH_NAME _DEPENDENCIES _DESCRIPTION
	!verbose push 3
	Push `${_SERVICE_NAME}`
	Push `${_DISPLAY_NAME}`
	Push `${_SERVICE_TYPE}`
	Push `${_START_TYPE}`
	Push `${_ERROR_CONTROL}`
	Push `${_BINARY_PATH_NAME}`
	Push `${_DEPENDENCIES}`
	Push `${_DESCRIPTION}`
	${CallArtificialFunction} CreateService_
	!verbose pop
!macroend
!define CreateService "!insertmacro CreateServiceCall"

!macro DeleteServiceCall _NAME
	!verbose push 3
	Push `${_NAME}`
	${CallArtificialFunction} DeleteService_
	!verbose pop
!macroend
!define DeleteService "!insertmacro DeleteServiceCall"

!macro StartServiceCall _NAME
	!verbose push 3
	Push `${_NAME}`
	${CallArtificialFunction} StartService_
	!verbose pop
!macroend
!define StartService "!insertmacro StartServiceCall"

!macro StopServiceCall _NAME
	!verbose push 3
	Push `${_NAME}`
	${CallArtificialFunction} StopService_
	!verbose pop
!macroend
!define StopService "!insertmacro StopServiceCall"

!macro _LL_ServiceExists
	!verbose push 3
		Exch $0 ; service name
		Push $1
		Push $2
		Push $3

		StrCpy $3 false

	;=== Open service handle
		System::Call advapi32::OpenSCManagerW(n,n,i${SC_MANAGER_ALL_ACCESS})i.s
		Pop $1
		StrCmp $1 0 ${__MACRO__}_SetReturn

		Push $0
		Push $1
		System::Call advapi32::OpenServiceW(is,ts,i${SERVICE_ALL_ACCESS})i.s
		Pop $2
		StrCmp $2 0 ${__MACRO__}_CloseHandle

	;=== Return true if exists
		StrCpy $3 true

	;=== Close opened service handle
		Push $2
		System::Call advapi32::CloseServiceHandle(is)n

	${__MACRO__}_CloseHandle:
		Push $1
		System::Call advapi32::CloseServiceHandle(is)n

	${__MACRO__}_SetReturn:
		; Set the return value
		StrCpy $0 $3

	;=== Clean up the stack
		Pop $3
		Pop $2
		Pop $1
		Exch $0
	!verbose pop
!macroend

; typedef struct _SERVICE_STATUS {
;     DWORD   dwServiceType;
;     DWORD   dwCurrentState;
;     DWORD   dwControlsAccepted;
;     DWORD   dwWin32ExitCode;
;     DWORD   dwServiceSpecificExitCode;
;     DWORD   dwCheckPoint;
;     DWORD   dwWaitHint;
; } SERVICE_STATUS, *LPSERVICE_STATUS;

!macro GetServiceStatus_
	!verbose push 3
	Exch $0 ; service name
	Push $1
	Push $2
	Push $3
	Push $4

	StrCpy $4 error

	${If} ${ServiceExists} $0
		; Open service handle
		System::Call advapi32::OpenSCManagerW(n,n,i${SC_MANAGER_ALL_ACCESS})i.s
		Pop $1
		${If} $1 <> 0
			Push $0
			Push $1
			System::Call advapi32::OpenServiceW(is,ts,i${SERVICE_ALL_ACCESS})i.s
			Pop $2
			${If} $2 <> 0
				; Create LPSERVICE_STATUS struct
				System::Call *(i,i,i,i,i,i,i)i.s
				Pop $3

				; Get service status
				Push $2
				System::Call advapi32::QueryServiceStatus(is,i$3)i

				; Get the value of dwCurrentState
				System::Call *$3(i,i.s)
				Pop $4 ; return value

				; Free memory
				System::Free $3

				; Convert to hexadecimal
				IntFmt $4 "0x0000000%X" $4

				${Select} $4
					${Case} ${SERVICE_STOPPED}
						StrCpy $4 stopped
					${Case} ${SERVICE_START_PENDING}
						StrCpy $4 start-pending
					${Case} ${SERVICE_STOP_PENDING}
						StrCpy $4 stop-pending
					${Case} ${SERVICE_RUNNING}
						StrCpy $4 running
					${Case} ${SERVICE_CONTINUE_PENDING}
						StrCpy $4 continue-pending
					${Case} ${SERVICE_PAUSE_PENDING}
						StrCpy $4 pause-pending
					${Case} ${SERVICE_PAUSED}
						StrCpy $4 paused
				${EndSelect}

				; Close opened service handle
				Push $2
				System::Call advapi32::CloseServiceHandle(is)n
			${EndIf}

			; Close opened service handle
			Push $1
			System::Call advapi32::CloseServiceHandle(is)n
		${EndIf}
	${Else}
		StrCpy $4 not-found
	${EndIf}

	StrCpy $0 $4

	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Exch $0
	!verbose pop
!macroend

; CreateServiceW(
;     SC_HANDLE    hSCManager,
;     LPCWSTR     lpServiceName,
;     LPCWSTR     lpDisplayName,
;     DWORD        dwDesiredAccess,
;     DWORD        dwServiceType,
;     DWORD        dwStartType,
;     DWORD        dwErrorControl,
;     LPCWSTR     lpBinaryPathName,
;     LPCWSTR     lpLoadOrderGroup,
;     LPDWORD      lpdwTagId,
;     LPCWSTR     lpDependencies,
;     LPCWSTR     lpServiceStartName,
;     LPCWSTR     lpPassword
;     );

!macro CreateService_
	!verbose push 3
	Exch $7 ; _DESCRIPTION
	Exch
	Exch $6 ; lpDependencies
	Exch
	Exch 2
	Exch $5 ; lpBinaryPathName
	Exch 2
	Exch 3
	Exch $4 ; dwErrorControl
	Exch 3
	Exch 4
	Exch $3 ; dwStartType
	Exch 4
	Exch 5
	Exch $2 ; dwServiceType
	Exch 5
	Exch 6
	Exch $1 ; lpDisplayName
	Exch 6
	Exch 7
	Exch $0 ; lpServiceName
	Exch 7
	Push $8
	Push $9
	Push $R0

	StrCpy $9 error

	${IfNot} ${ServiceExists} $0
		System::Call advapi32::OpenSCManagerW(,,i${SC_MANAGER_ALL_ACCESS})i.s
		Pop $8
		${If} $8 <> 0
			; Create service
			${If} $6 == "" ; lpDependencies
				StrCpy $6 n
			${Else}
				Push $6
				StrCpy $6 ts
			${EndIf}
			Push $5 ; lpBinaryPathName
			Push $4 ; dwErrorControl
			Push $3 ; dwStartType
			Push $2 ; dwServiceType
			Push $1 ; lpDisplayName
			Push $0 ; lpServiceName
			Push $8
			System::Call advapi32::CreateServiceW(is,ts,ts,i${SERVICE_ALL_ACCESS},is,is,is,ts,,,$6,,)i.s
			Pop $9

			${If} $7 != ""
				; Write description of service
				Push $7
				Push $9
				System::Call advapi32::ChangeServiceConfig2W(is,i${SERVICE_CONFIG_DESCRIPTION},*ts)i.s
				Pop $R0
				${If} $R0 == error
					WriteRegStr HKEY_LOCAL_MACHINE "SYSTEM\CurrentControlSet\Services\$0" "Description" $7
				${EndIf}
			${EndIf}

			Push $8
			System::Call advapi32::CloseServiceHandle(is)
		${EndIf}
	${Else}
		StrCpy $9 already-exist
	${EndIf}

	StrCpy $0 $9

	Pop $R0
	Pop $9
	Pop $8
	Pop $7
	Pop $6
	Pop $5
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Exch $0
	!verbose pop
!macroend

!macro DeleteService_
	!verbose push 3
	Exch $0 ; service name
	Push $1
	Push $2
	Push $3

	StrCpy $3 error

	${If} ${ServiceExists} $0
		; Open service handle
		System::Call advapi32::OpenSCManagerW(n,n,i${SC_MANAGER_ALL_ACCESS})i.s
		Pop $1
		${If} $1 <> 0
			Push $0
			Push $1
			System::Call advapi32::OpenServiceW(is,ts,i${SERVICE_ALL_ACCESS})i.s
			Pop $2
			${If} $2 <> 0
				; Delete the service
				Push $2
				System::Call advapi32::DeleteService(is)i.s
				Pop $3
				${If} $3 = 1
					StrCpy $3 succeed
				${Else}
					StrCpy $3 error
				${EndIf}

				; Close opened service handle
				Push $2
				System::Call advapi32::CloseServiceHandle(is)n
			${EndIf}

			; Close opened service handle
			Push $1
			System::Call advapi32::CloseServiceHandle(is)n
		${EndIf}
	${Else}
		StrCpy $3 not-found
	${EndIf}

	; Set return value
	StrCpy $0 $3

	Pop $3
	Pop $2
	Pop $1
	Exch $0
	!verbose pop
!macroend

!macro StartService_
	!verbose push 3
	Exch $0 ; service name
	Push $1
	Push $2
	Push $3
	Push $4

	StrCpy $3 error

	${If} ${ServiceExists} $0
		${GetServiceStatus} $0 $4
		${If} $4 != running
			; Open service handle
			System::Call advapi32::OpenSCManagerW(n,n,i${SC_MANAGER_ALL_ACCESS})i.s
			Pop $1
			${If} $1 <> 0
				Push $0
				Push $1
				System::Call advapi32::OpenServiceW(is,ts,i${SERVICE_ALL_ACCESS})i.s
				Pop $2
				${If} $2 <> 0
					; Start the service
					Push $2
					System::Call advapi32::StartServiceW(is,i0,i0)i.s
					Pop $3
					${If} $3 = 1
						StrCpy $3 succeed
					${Else}
						StrCpy $3 error
					${EndIf}

					; Don't overdo it, please rest a bit
					Sleep 100

					; Close opened service handle
					Push $2
					System::Call advapi32::CloseServiceHandle(is)n
				${EndIf}

				; Close opened service handle
				Push $1
				System::Call advapi32::CloseServiceHandle(is)n
			${EndIf}
		${Else}
			StrCpy $3 already-running
		${EndIf}
	${Else}
		StrCpy $3 not-found
	${EndIf}

	; Set return value
	StrCpy $0 $3

	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Exch $0
	!verbose pop
!macroend

!macro StopService_
	!verbose push 3
	Exch $0 ; service name
	Push $1
	Push $2
	Push $3
	Push $4

	StrCpy $3 error

	${If} ${ServiceExists} $0
		${GetServiceStatus} $0 $4
		${If} $4 != stopped
			; Open service handle
			System::Call advapi32::OpenSCManagerW(n,n,i${SC_MANAGER_ALL_ACCESS})i.s
			Pop $1
			${If} $1 <> 0
				Push $0
				Push $1
				System::Call advapi32::OpenServiceW(is,ts,i${SERVICE_ALL_ACCESS})i.s
				Pop $2
				${If} $2 <> 0
					; Create LPSERVICE_STATUS struct
					System::Call *(i,i,i,i,i,i,i)i.s
					Pop $4

					; Stop the service
					Push $2
					System::Call advapi32::ControlService(is,i${SERVICE_CONTROL_STOP},i$4)i.s
					Pop $3
					${If} $3 = 1
						StrCpy $3 succeed
					${Else}
						StrCpy $3 error
					${EndIf}

					; Don't overdo it, please rest a bit
					Sleep 100

					; Free memory
					System::Free $4

					; Close opened service handle
					Push $2
					System::Call advapi32::CloseServiceHandle(is)n
				${EndIf}

				; Close opened service handle
				Push $1
				System::Call advapi32::CloseServiceHandle(is)n
			${EndIf}
		${Else}
			StrCpy $3 already-stopped
		${EndIf}
	${Else}
		StrCpy $3 not-found
	${EndIf}

	; Set return value
	StrCpy $0 $3

	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Exch $0
	!verbose pop
!macroend
!endif ; SERVICE_NSH_INCLUDED
