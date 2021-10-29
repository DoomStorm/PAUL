; vim:ff=unix:gfn=Consolas\:h10:fdm=marker:fen:nowrap:ts=4:sts=0:sw=0:nu
;
; Use Vim for a better compatibility.
;
; Based on John T. Haller of PortableApps.com works.

!define APPNAME "PurkdellApps Compiler"
!define SHORTNAME "CompilerWizard"

;=== Include Version {{{1
!include Version.nsh

;=== Calculate app ID {{{1
!searchreplace APPID "${APPNAME}" " " ""

;=== Require at least NSIS 3.0 {{{1
!include RequireLatestNSIS.nsh

;=== Sign the Executable {{{1
!if /FileExists ..\..\..\Cert\Sign.nsh
	!include ..\..\..\Cert\Sign.nsh
!endif

;=== Program Details {{{1
Name "${APPNAME}"
OutFile "..\..\${APPID}.exe"
Icon "PAUL.ico"
Caption "${APPNAME}"
VIProductVersion "${VER}"
VIAddVersionKey /LANG=2057 ProductName "${APPNAME}"
VIAddVersionKey /LANG=2057 Comments "A compiler for custom PurkdellApps Universal Launcher builds. For additional details, visit PurkdellApps.blogspot.com"
VIAddVersionKey /LANG=2057 CompanyName PurkdellApps
VIAddVersionKey /LANG=2057 LegalCopyright "Azure Zanculmarktum"
VIAddVersionKey /LANG=2057 FileDescription "${APPNAME}"
VIAddVersionKey /LANG=2057 FileVersion "${VER}"
VIAddVersionKey /LANG=2057 ProductVersion "${VER}"
VIAddVersionKey /LANG=2057 InternalName "${APPNAME}"
VIAddVersionKey /LANG=2057 LegalTrademarks "PurkdellApps is a Trademark of Azure Zanculmarktum"
VIAddVersionKey /LANG=2057 OriginalFilename "${APPID}.exe"

;=== Runtime Switches {{{1
Unicode true
ManifestSupportedOS all
CRCCheck on
WindowIcon off
RequestExecutionLevel user
XPStyle on

; Best Compression {{{2
SetCompress Auto
SetCompressor /SOLID lzma
SetCompressorDictSize 32
SetDatablockOptimize On
;}}}2

;=== Additional Plugins {{{1
!addplugindir /x86-unicode Plugins

;=== Include {{{1
;(NSIS Standard) {{{2
!include LogicLib.nsh
!include FileFunc.nsh
!include TextFunc.nsh

;(Custom) {{{2
!include IsFile.nsh
!include WriteINIStr.nsh
!include UpdatePath.nsh
!include LogicLibAdditions.nsh
;}}}2

;=== Icon & Stye {{{1
BrandingText PurkdellApps™
InstallButtonText Compile
ShowInstDetails nevershow
SubCaption 3 " "
SubCaption 4 " "
InstallColors 268BD2 002B36

;=== Variables {{{1
Var COMMANDLINEMODE
Var PACKAGE
Var PACKAGECONTROL
Var SCRIPTFILE
Var APPID
Var SHORTNAME
Var VERBOSITY
Var VERBOSITYCONTROL
Var LOG
Var LOGCONTROL
Var STATE
Var LAUNCHERCONTROL
Var PACKAGERCONTROL
Var PACKAGER64CONTROL

;=== Pages {{{1
Page custom ShowOptionsWindow LeaveOptionsWindow
Page instfiles

;=== Languages {{{1
LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"

;=== Macros {{{1
!macro WriteSettings _ENTRY _VALUE
	${WriteINIStr} $EXEDIR\Data\Settings.ini "${SHORTNAME}" `${_ENTRY}` `${_VALUE}`
!macroend
!define WriteSettings "!insertmacro WriteSettings"

!macro ReadSettings _RETURN _ENTRY
	ReadINIStr ${_RETURN} $EXEDIR\Data\Settings.ini "${SHORTNAME}" `${_ENTRY}`
!macroend
!define ReadSettings "!insertmacro ReadSettings"

!macro DeleteSettings _ENTRY
	DeleteINIStr $EXEDIR\Data\Settings.ini "${SHORTNAME}" `${_ENTRY}`
!macroend
!define DeleteSettings "!insertmacro DeleteSettings"

;=== Flags {{{1
!define NormalMode "$COMMANDLINEMODE != true"
!define CommandLineMode "$COMMANDLINEMODE == true"

!define /ifndef BM_GETCHECK        0x00F0
!define /ifndef BM_SETCHECK        0x00F1

!define /ifndef BST_UNCHECKED      0
!define /ifndef BST_CHECKED        1

!define /ifndef CB_ADDSTRING                0x0143
!define /ifndef CB_SELECTSTRING             0x014D

!define /ifndef WS_CHILD             0x40000000
!define /ifndef WS_VISIBLE           0x10000000
!define /ifndef WS_CLIPSIBLINGS      0x04000000
!define /ifndef WS_CLIPCHILDREN      0x02000000
!define /ifndef WS_VSCROLL           0x00200000
!define /ifndef WS_TABSTOP           0x00010000

!define /ifndef WS_EX_TRANSPARENT    0x00000020
!define /ifndef WS_EX_WINDOWEDGE     0x00000100
!define /ifndef WS_EX_CLIENTEDGE     0x00000200

!define /ifndef CBS_DROPDOWNLIST      0x0003
!define /ifndef CBS_AUTOHSCROLL       0x0040
!define /ifndef CBS_HASSTRINGS        0x0200

!define /ifndef SS_NOTIFY            0x00000100

!define /ifndef BS_AUTOCHECKBOX      0x00000003
!define /ifndef BS_GROUPBOX          0x00000007
!define /ifndef BS_AUTORADIOBUTTON   0x00000009
!define /ifndef BS_TEXT              0x00000000
!define /ifndef BS_VCENTER           0x00000C00
!define /ifndef BS_MULTILINE         0x00002000

!define /ifndef ES_AUTOHSCROLL       0x00000080

Function .onInit ;{{{1
	; If PAUL was executed with -l or -p[64] parameters
	; use command line mode instead
	${GetParameters} $0
	${If} $0 != ""
		${If}   $0 options -l
		${OrIf} $0 options -p
		${OrIf} $0 options -p64
			StrCpy $COMMANDLINEMODE true
			${IfNot} $0 options -d
				SetSilent silent
			${EndIf}
		${ElseIf} $0 options -c
			Call CommandLineMode
			Quit
		${EndIf}
	${EndIf}

	${If} ${NormalMode}
		; Remove unused entry
		${DeleteSettings} Packager

		; Update path for new location
		${ReadSettings} $0 Drive ; last drive
		${GetRoot} $EXEDIR $1
		${UpdatePath} $EXEDIR\Data\Settings.ini = $0 $1 "" ; replace =X: with =Y:

		; Keep current drive
		CreateDirectory $EXEDIR\Data
		${WriteSettings} Drive $1

		; Pre-fill path
		${ReadSettings} $PACKAGE Package
		${IfNot} ${IsDir} $PACKAGE ; is path exists?
			; No, it's not, clear the package then
			${WriteSettings} Package ""
			StrCpy $PACKAGE ""
		${EndIf}

		; Remove old log file
		Delete $EXEDIR\Data\Log.log
	${Else} ; ${CommandLineMode}
		; Set the state
		${If} $0 options -l
			StrCpy $STATE Launcher
		${ElseIf} $0 options -p
			StrCpy $STATE Packager
		${ElseIf} $0 options -p64
			StrCpy $STATE Packager64
		${EndIf}

		; Is path contains " (quote)?
		StrCpy $3 no-quote
		StrCpy $1 $0 1 -1
		${If} $1 == '"'
			StrCpy $3 quote
		${EndIf}

		; Get last part of passed parameter
		StrCpy $PACKAGE $1
		${For} $2 2 ${NSIS_MAX_STRLEN}
			; Read a string bit-by-bit from right
			StrCpy $1 $0 1 -$2

			${If} $1 == ""
				${ExitFor} ; done if the whole string has already being scanned
			${EndIf}

			${If} $3 != quote
				; If path doesn't contain " (quote),
				; stop reading the string when reaching
				; a white-space character
				${If} $1 == " "
					${ExitFor}
				${EndIf}
			${EndIf}

			; Store it in $PACKAGE
			StrCpy $PACKAGE $1$PACKAGE

			${If} $3 == quote
				; If path contains " (quote), stop
				; reading the string when reaching
				; a quote
				${If} $1 == '"'
					StrCpy $PACKAGE $PACKAGE -1 1 ; trim quote
					${ExitFor}
				${EndIf}
			${EndIf}
		${Next}
		; Now, we have a value of $PACKAGE

		; Set the verbosity
		${If} $0 options "-v 4"
			StrCpy $VERBOSITY 4
		${ElseIf} $0 options "-v 3"
			StrCpy $VERBOSITY 3
		${ElseIf} $0 options "-v 2"
			StrCpy $VERBOSITY 2
		${ElseIf} $0 options "-v 1"
			StrCpy $VERBOSITY 1
		${ElseIf} $0 options "-v 0"
			StrCpy $VERBOSITY 0
		${Else}
			StrCpy $VERBOSITY 3
		${EndIf}

		; Set the log
		${If} $0 options -lo
			StrCpy $LOG ${BST_CHECKED}
		${EndIf}

		; LeaveOptionsWindow function not being
		; called when in command line mode, so
		; call it manually
		Call LeaveOptionsWindow
	${EndIf}
FunctionEnd

Function ShowOptionsWindow ;{{{1
${If} ${NormalMode}
	; Create custom window
	nsDialogs::Create 1018
	Pop $0

	; Create drop list control
	nsDialogs::CreateControl COMBOBOX ${WS_CHILD}|${WS_VISIBLE}|${WS_CLIPSIBLINGS}|${WS_TABSTOP}|${WS_VSCROLL}|${WS_CLIPCHILDREN}|${CBS_AUTOHSCROLL}|${CBS_HASSTRINGS}|${CBS_DROPDOWNLIST} ${WS_EX_WINDOWEDGE}|${WS_EX_CLIENTEDGE} 304 54 81 40 ""
	Pop $VERBOSITYCONTROL
	; Add the string
	SendMessage $VERBOSITYCONTROL ${CB_ADDSTRING} 0 STR:4
	SendMessage $VERBOSITYCONTROL ${CB_ADDSTRING} 0 STR:3
	SendMessage $VERBOSITYCONTROL ${CB_ADDSTRING} 0 STR:2
	SendMessage $VERBOSITYCONTROL ${CB_ADDSTRING} 0 STR:1
	SendMessage $VERBOSITYCONTROL ${CB_ADDSTRING} 0 STR:0
	; Select the string
	${ReadSettings} $VERBOSITY Verbosity
	${If} $VERBOSITY == ""
		StrCpy $VERBOSITY 4
	${EndIf}
	SendMessage $VERBOSITYCONTROL ${CB_SELECTSTRING} -1 STR:$VERBOSITY
	; Create label control
	nsDialogs::CreateControl STATIC ${WS_CHILD}|${WS_VISIBLE}|${WS_CLIPSIBLINGS}|${SS_NOTIFY} ${WS_EX_TRANSPARENT} 246 58 139 10u Verbosity:

	; Create check box control
	nsDialogs::CreateControl BUTTON ${WS_CHILD}|${WS_VISIBLE}|${WS_CLIPSIBLINGS}|${WS_TABSTOP}|${BS_TEXT}|${BS_VCENTER}|${BS_AUTOCHECKBOX}|${BS_MULTILINE} 0 246 82 139 10u "Save log to Data\Log.log"
	Pop $LOGCONTROL
	${ReadSettings} $LOG Log
	SendMessage $LOGCONTROL ${BM_SETCHECK} $LOG 0

	; Create radio button control
	nsDialogs::CreateControl BUTTON ${WS_CHILD}|${WS_VISIBLE}|${WS_CLIPSIBLINGS}|${WS_TABSTOP}|${BS_TEXT}|${BS_VCENTER}|${BS_AUTORADIOBUTTON}|${BS_MULTILINE} 0 12 57 100 10u Launcher
	Pop $LAUNCHERCONTROL
	; Create another radio button control
	nsDialogs::CreateControl BUTTON ${WS_CHILD}|${WS_VISIBLE}|${WS_CLIPSIBLINGS}|${WS_TABSTOP}|${BS_TEXT}|${BS_VCENTER}|${BS_AUTORADIOBUTTON}|${BS_MULTILINE} 0 12 82 100 10u Packager
	Pop $PACKAGERCONTROL
	nsDialogs::CreateControl BUTTON ${WS_CHILD}|${WS_VISIBLE}|${WS_CLIPSIBLINGS}|${WS_TABSTOP}|${BS_TEXT}|${BS_VCENTER}|${BS_AUTORADIOBUTTON}|${BS_MULTILINE} 0 12 107 100 10u Packager64
	Pop $PACKAGER64CONTROL
	; Check the radio button
	${ReadSettings} $STATE State
	${If} $STATE == ""
		StrCpy $STATE Launcher
	${EndIf}
	${Select} $STATE
		${Case} Launcher
			SendMessage $LAUNCHERCONTROL ${BM_SETCHECK} 1 0
		${Case} Packager
			SendMessage $PACKAGERCONTROL ${BM_SETCHECK} 1 0
		${Case} Packager64
			SendMessage $PACKAGER64CONTROL ${BM_SETCHECK} 1 0
	${EndSelect}

	; Create group box control
	nsDialogs::CreateControl BUTTON ${WS_CHILD}|${WS_VISIBLE}|${WS_CLIPSIBLINGS}|${BS_GROUPBOX} ${WS_EX_TRANSPARENT} 2 0 396 49 "Portable App's Base Directory"

	; Create text control and set the focus
	nsDialogs::CreateControl EDIT ${WS_CHILD}|${WS_VISIBLE}|${WS_CLIPSIBLINGS}|${WS_TABSTOP}|${ES_AUTOHSCROLL} ${WS_EX_WINDOWEDGE}|${WS_EX_CLIENTEDGE} 12 18 281 20 $PACKAGE
	Pop $PACKAGECONTROL
	System::Call user32::SetFocus(p$PACKAGECONTROL)

	; Create button control
	nsDialogs::CreateControl BUTTON ${WS_CHILD}|${WS_VISIBLE}|${WS_CLIPSIBLINGS}|${WS_TABSTOP} 0 303 16 83 23 Browse...
	Pop $0
	; Catch clicked button into SelectFolderDialog function
	GetFunctionAddress $1 SelectFolderDialog
	nsDialogs::OnClick $0 $1

	; Create button control
	nsDialogs::CreateControl BUTTON ${WS_CHILD}|${WS_VISIBLE}|${WS_CLIPSIBLINGS}|${WS_TABSTOP} 0 245 106 141 23 "Command line mode"
	Pop $0
	; Catch clicked button into CommandLineMode function
	GetFunctionAddress $1 CommandLineMode
	nsDialogs::OnClick $0 $1

	; Show the window
	nsDialogs::Show
${EndIf}
FunctionEnd

Function SelectFolderDialog ;{{{1
	Pop $0 # HWND

	nsDialogs::SelectFolderDialog "Please select a valid portable app's base directory:" $PACKAGE
	Pop $0
	${If} $0 != error ; do not display any error in text control
		StrCpy $PACKAGE $0
		; Set the content of text control
		SendMessage $PACKAGECONTROL 0x000C 0 STR:$PACKAGE
	${EndIf}
FunctionEnd

Function CommandLineMode ;{{{1
	Pop $0 # HWND

	; Display a message box
	Push "\
	Usage:$\r$\n\
	PurkdellAppsCompiler.exe|paul.exe options package_dir$\r$\n\
	$\r$\n\
	Options:$\r$\n\
	-l|-p[64] [-v 4|3|2|1|0] [-lo] [-d]$\r$\n\
	$\r$\n\
	-l$\tbuild launcher$\r$\n\
	-p$\tbuild package$\r$\n\
	-p64$\tbuild package for 64-bit$\r$\n\
	$\r$\n\
	-v 4$\tset the level of verbosity to all$\r$\n\
	-v 3$\tset the level of verbosity to no script$\r$\n\
	-v 2$\tset the level of verbosity to no info$\r$\n\
	-v 1$\tset the level of verbosity to no warnings$\r$\n\
	-v 0$\tset the level of verbosity to none$\r$\n\
	$\r$\n\
	-lo$\twrite log to the same directory of the script file$\r$\n\
	$\r$\n\
	-d$\tshow details view$\r$\n\
	$\r$\n\
	Example:$\r$\n\
	paul.exe -l X:\PortableApps\AppNamePortable$\r$\n\
	paul.exe -p X:\PortableApps\AppNamePortable$\r$\n\
	paul.exe -p64 X:\PortableApps\AppNamePortable"
	Pop $0 ; haha.. pushing'n'popping, whadajoke lol
	MessageBox MB_TOPMOST|MB_USERICON $0

	; Set the focus to package
	System::Call user32::SetFocus(p$PACKAGECONTROL)
FunctionEnd

Function LeaveOptionsWindow ;{{{1
	${If} ${NormalMode}
		; Get the state
		StrCpy $0 0
		${If} $0 != 1
			SendMessage $LAUNCHERCONTROL ${BM_GETCHECK} 0 0 $0
			${If} $0 == 1
				StrCpy $STATE Launcher
			${EndIf}
		${EndIf}
		${If} $0 != 1
			SendMessage $PACKAGERCONTROL ${BM_GETCHECK} 0 0 $0
			${If} $0 == 1
				StrCpy $STATE Packager
			${EndIf}
		${EndIf}
		${If} $0 != 1
			SendMessage $PACKAGER64CONTROL ${BM_GETCHECK} 0 0 $0
			${If} $0 == 1
				StrCpy $STATE Packager64
			${EndIf}
		${EndIf}
	${EndIf}

	; Verify the NSIS
	${IfNot} ${IsFile} "$EXEDIR\App\NSIS\makensis.exe"
		MessageBox MB_TOPMOST|MB_ICONSTOP "Could not find makensis.exe in $EXEDIR\App\NSIS."
		Abort
	${EndIf}

	; Verify the contents of text control
	${If} ${NormalMode}
		System::Call user32::GetWindowText(p$PACKAGECONTROL,t.s,i${NSIS_MAX_STRLEN})
		Pop $PACKAGE
	${EndIf}
	${If} $PACKAGE == "" ; do not process to the next page if empty
		${If} ${NormalMode}
			System::Call user32::SetFocus(p$PACKAGECONTROL)
		${EndIf}
		Abort
	${ElseIfNot} ${IsDir} $PACKAGE ; or if it's not a directory
		MessageBox MB_TOPMOST|MB_ICONSTOP "The directory you specify does not exist. Please select a valid portable app's base directory."
		${If} ${NormalMode}
			System::Call user32::SetFocus(p$PACKAGECONTROL)
		${EndIf}
		Abort
	${EndIf}

	; Verify the specified package
	ClearErrors
	FindFirst $R0 $0 $PACKAGE\Other\Source\*.ico
	FindClose $R0
	${If} ${Errors}
		MessageBox MB_TOPMOST|MB_ICONSTOP "Could not find the right script file to be compiled in the specified directory."
		Abort
	${EndIf}

	; Verify the script file
	StrCpy $R0 ""
	${Do}
		ClearErrors
		${If} $R0 == ""
			FindFirst $R0 $0 $PACKAGE\Other\Source\*.ico
		${Else}
			FindNext $R0 $0
		${EndIf}
		${IfThen} ${Errors} ${|} ${ExitDo} ${|}
		StrCpy $1 $0 -4 ; remove .ico from the string
		${Select} $STATE
			${Case} Launcher
				${If} ${IsFile} $PACKAGE\Other\Source\$1Portable.nsi
					FileOpen $R1 $PACKAGE\Other\Source\$1Portable.nsi r
					nsisFile::FileFindBytes $R1 5075726B64656C6C4170707320556E6976657273616C204C61756E63686572 -1 ; search for "PurkdellApps Universal Launcher"
					Pop $R2
					FileClose $R1
					${If} $R2 != -1
						StrCpy $SCRIPTFILE $PACKAGE\Other\Source\$1Portable.nsi
						StrCpy $APPID $1Portable
						StrCpy $SHORTNAME $1
						${ExitDo}
					${EndIf}
				${EndIf}
			${Case} Packager
				${If} ${IsFile} $PACKAGE\Other\Source\$1PortablePackager.nsi
					StrCpy $SCRIPTFILE $PACKAGE\Other\Source\$1PortablePackager.nsi
					StrCpy $APPID $1Portable
					StrCpy $SHORTNAME $1
					${ExitDo}
				${EndIf}
			${Case} Packager64
				${If} ${IsFile} $PACKAGE\Other\Source\$1PortablePackager64.nsi
					StrCpy $SCRIPTFILE $PACKAGE\Other\Source\$1PortablePackager64.nsi
					StrCpy $APPID $1Portable
					StrCpy $SHORTNAME $1
					${ExitDo}
				${EndIf}
		${EndSelect}
	${Loop}
	FindClose $R0

	${If} $SCRIPTFILE == ""
		MessageBox MB_TOPMOST|MB_ICONSTOP "Could not find the right script file to be compiled in the specified directory."
		Abort
	${EndIf}

	; Delete existing installer if there is one
	${If} $STATE == Launcher
		Delete $PACKAGE\$APPID.exe
		${If} ${IsFile} $PACKAGE\$APPID.exe
			MessageBox MB_TOPMOST|MB_ICONSTOP "Unable to compile the script file, make sure $PACKAGE\$APPID.exe is not currently running and then recompile again."
			Abort
		${EndIf}
	${EndIf}

	${If} ${NormalMode}
		; Get verbosity
		System::Call user32::GetWindowText(p$VERBOSITYCONTROL,t.s,i${NSIS_MAX_STRLEN})
		Pop $VERBOSITY

		; Is log checked?
		SendMessage $LOGCONTROL ${BM_GETCHECK} 0 0 $LOG

		; Keep settings for next launch
		CreateDirectory $EXEDIR\Data
		${WriteSettings} State $STATE
		${WriteSettings} Package $PACKAGE
		${WriteSettings} Verbosity $VERBOSITY
		${WriteSettings} Log $LOG
	${EndIf}
FunctionEnd

Section Main ;{{{1
	; Show details view if verbosity is not 0
	${If} $VERBOSITY != 0
		SetDetailsView show
	${EndIf}

	SetDetailsPrint textonly
	${Select} $STATE
		${Case} Launcher
			StrCpy $0 "Compiling launcher"
		${Case} Packager
			StrCpy $0 "Packaging $APPID"
		${Case} Packager64
			StrCpy $0 "Packaging $APPID64"
	${EndSelect}
	DetailPrint "$0..."

	; Prevent from showing any install details
	; while executing the script file
	SetDetailsPrint none

	${If} ${CommandLineMode}
		; Remove old log file
		Delete $SCRIPTFILE.log
	${EndIf}

	StrCpy $0 ""
	; Save log to file if checked
	${If} $LOG == ${BST_CHECKED}
		${If} ${NormalMode}
			StrCpy $0 ` /O"$EXEDIR\Data\Log.log"`
		${Else}
			StrCpy $0 ` /O"$SCRIPTFILE.log"`
		${EndIf}
	${EndIf}

	; Build the thing
	GetTempFileName $1
	FileOpen $R0 $1 w
	FileWrite $R0 `!define COMPILED_BY_PAUL$\n`
	FileWrite $R0 `!define PAULVERSION "${VER}"$\n`
	FileWrite $R0 `!define PAUL "$EXEDIR\Other\Source"$\n`
	FileWrite $R0 `!define APPID "$APPID"$\n`
	FileWrite $R0 `!define SHORTNAME "$SHORTNAME"$\n`
	FileClose $R0
	nsExec::ExecToLog `"$EXEDIR\App\NSIS\makensis.exe" /V$VERBOSITY$0 /X"!verbose push 3" /X"!include $1" /X"!verbose pop" "$SCRIPTFILE"`
	Delete $1

	; Is the file have been builded?
	${If} $STATE == Launcher
		StrCpy $0 $PACKAGE\$APPID.exe
	${Else}
		FileOpen $R0 $PACKAGE\Other\Source\PackageName.nsh r
		FileRead $R0 $0
		${TrimNewLines} $0 $0
		FileClose $R0
		Delete $PACKAGE\Other\Source\PackageName.nsh

		${GetParent} $PACKAGE $R0
		StrCpy $0 $R0\$0
	${EndIf}

	${If} ${NormalMode}
		StrCpy $1 "$EXEDIR\Data\Log.log"
	${Else}
		StrCpy $1 "$SCRIPTFILE.log"
	${EndIf}

	SetDetailsPrint textonly
	${If} ${IsFile} $0
		; If so, congratulations!
		DetailPrint "Completed successfully"
		${If} $VERBOSITY != 0
			${If} $LOG != 1
				${If} $VERBOSITY != 1
					SetDetailsPrint listonly
					${If} $VERBOSITY != 2
						DetailPrint ""
					${EndIf}
					DetailPrint "Be sure to check any warning" ; if only I found a way to catch NSIS warning :( Popping from the stack resulting "0" (means: no warning)
				${EndIf}
			${Else}
				SetDetailsPrint listonly
				DetailPrint "See log in $1 for details"
			${EndIf}
		${EndIf}
	${Else}
		; Don't worry, you still have a chance!
		DetailPrint "An error has occurred"
		${If} $VERBOSITY != 0
			${If} $LOG == 1
				SetDetailsPrint listonly
				DetailPrint "See log in $1 for details"
			${Else}
				DetailPrint "An error has occurred, see log for details"
			${EndIf}
		${EndIf}
	${EndIf}

	; Hide completed message
	SetDetailsPrint none
SectionEnd
