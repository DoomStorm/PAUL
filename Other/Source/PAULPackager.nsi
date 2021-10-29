; vim:ff=unix:gfn=Consolas\:h10:fdm=marker:fen:nowrap:ts=4:sts=0:sw=0:nu
;
; Use Vim for a better compatibility.
;
; Based on John T. Haller of PortableApps.com works.

!define FILENAME     "PAUL_${FRIENDLYVER}_en-US"
!define APPNAME      "PurkdellApps Universal Launcher"
!define APPID        "PAUL"
!define APPLANGUAGE  "English"
!define PUBLISHER    "PurkdellApps"
!define CATEGORY     "Development"
!define MAINLAUNCHER "PurkdellAppsCompiler.exe"

;=== Include Version {{{1
!include Version.nsh

;=== Some Useful Defines {{{1
!define EXTRACTDIR "$INSTDIR\${APPID}"

!define AddFiles "File /r /x thumbs.db /x desktop.ini"

;=== Runtime Switches {{{1
Unicode true
ManifestSupportedOS all
CRCCheck on
AutoCloseWindow true
RequestExecutionLevel user
AllowRootDirInstall true
ShowInstDetails nevershow

; Best Compression {{{2
SetCompress auto
SetCompressor /SOLID lzma
SetCompressorDictSize 32
SetDatablockOptimize On
;}}}2

;=== Sign the Executable {{{1
!if /FileExists "..\..\..\Cert\Sign.nsh"
	!include "..\..\..\Cert\Sign.nsh"
!endif

;=== Program Details {{{1
Name "${APPNAME}"
OutFile "..\..\..\${FILENAME}.paf.exe"
Caption "${APPNAME} | PurkdellApps"
VIProductVersion "${VER}"
VIAddVersionKey /LANG=2057 ProductName "${APPNAME}"
VIAddVersionKey /LANG=2057 CompanyName PurkdellApps
VIAddVersionKey /LANG=2057 LegalCopyright "Azure Zanculmarktum"
VIAddVersionKey /LANG=2057 FileDescription "${APPNAME}"
VIAddVersionKey /LANG=2057 FileVersion "${VER}"
VIAddVersionKey /LANG=2057 ProductVersion "${FRIENDLYVER}"
VIAddVersionKey /LANG=2057 InternalName "${APPNAME}"
VIAddVersionKey /LANG=2057 LegalTrademarks "PurkdellApps is a Trademark of Azure Zanculmarktum"
VIAddVersionKey /LANG=2057 OriginalFilename "${FILENAME}.paf.exe"

;=== Additional Plugins {{{1
!addplugindir /x86-unicode Plugins

;=== Include {{{1
;(NSIS Standard) {{{2
!include MUI2.nsh
!include FileFunc.nsh
!include WordFunc.nsh
!include LogicLib.nsh
!include TextFunc.nsh

;(Custom) {{{2
!include ProcFunc.nsh
!include WriteINIStr.nsh
!include LogicLibAdditions.nsh
!include IsFile.nsh
;}}}2

;=== Program Icon {{{1
Icon "PAUL.ico"
!define MUI_ICON "PAUL.ico"

;=== Icon & Stye {{{1
BrandingText PurkdellApps™
InstallButtonText E&xtract

;=== Pages {{{1
!define MUI_WELCOMEFINISHPAGE_BITMAP Packager.bmp

;COMPONENTS {{{2
!define MUI_COMPONENTSPAGE_CHECKBITMAP "Checks.bmp"
!define MUI_COMPONENTSPAGE_NODESC
!define MUI_TEXT_COMPONENTS_TITLE "Choose Components"
!define MUI_TEXT_COMPONENTS_SUBTITLE "Choose which features of ${APPNAME} you want to extract."
!define MUI_COMPONENTSPAGE_TEXT_TOP "Check the components you want to extract and uncheck the components you don't want to extract. Click Next to continue."
!define MUI_COMPONENTSPAGE_TEXT_COMPLIST "Select components to extract:"
!insertmacro MUI_PAGE_COMPONENTS

;DIRECTORY {{{2
!define MUI_TEXT_DIRECTORY_TITLE "Choose Extract Location"
!define MUI_TEXT_DIRECTORY_SUBTITLE "Choose the folder in which to extract ${APPNAME}."
!define MUI_DIRECTORYPAGE_TEXT_TOP "Setup will extract ${APPNAME} in the following folder. To extract in a different folder, click Browse and select another folder. Click Extract to start the extraction."
!define MUI_DIRECTORYPAGE_VERIFYONLEAVE
!define MUI_PAGE_CUSTOMFUNCTION_PRE PreDirectory
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE LeaveDirectory
!insertmacro MUI_PAGE_DIRECTORY

;INSTFILES {{{2
!define MUI_TEXT_INSTALLING_TITLE $INSTFILES_TITLE
!define MUI_TEXT_INSTALLING_SUBTITLE $INSTFILES_SUBTITLE
!define MUI_TEXT_ABORT_TITLE "Extraction Aborted"
!define MUI_TEXT_ABORT_SUBTITLE "Setup was not completed successfully."
!define MUI_PAGE_CUSTOMFUNCTION_PRE PreInstFiles
!define MUI_PAGE_CUSTOMFUNCTION_SHOW ShowInstFiles
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE LeaveInstFiles
!insertmacro MUI_PAGE_INSTFILES

;FINISH {{{2
!define MUI_TEXT_FINISH_TITLE $INSTFILES_TITLE
!define MUI_TEXT_FINISH_SUBTITLE $INSTFILES_SUBTITLE
!define MUI_TEXT_FINISH_INFO_TITLE "Completing the ${APPNAME} Setup"
!define MUI_FINISHPAGE_TEXT "${APPNAME} has been extracted on your device.$\r$\n$\r$\nClick Finish to close this wizard."
!define MUI_FINISHPAGE_TITLE_3LINES
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "Open ${APPNAME} folder"
!define MUI_FINISHPAGE_RUN_NOTCHECKED
!define MUI_FINISHPAGE_RUN_FUNCTION OpenInstDir
!define MUI_PAGE_CUSTOMFUNCTION_PRE PreFinish
!insertmacro MUI_PAGE_FINISH
;}}}2

;=== Languages {{{1
!insertmacro MUI_LANGUAGE English

;=== Macros {{{1
!macro CleanUpDestination ;{{{2
	;=== Clean up any files and folders in the destination directory
	StrCpy $0 ""
	${Do}
		${If} $0 == ""
			FindFirst $0 $1 "${EXTRACTDIR}\*.*"
		${Else}
			FindNext $0 $1
		${EndIf}
		${IfThen} $1 == "" ${|} ${ExitDo} ${|}
		${IfThen} $1 == . ${|} ${Continue} ${|}
		${IfThen} $1 == .. ${|} ${Continue} ${|} ;=== Be sure to skip parent directory
		${IfThen} $1 == Data ${|} ${Continue} ${|} ;=== Be sure to preserve Data directory
		StrCpy $2 "${MAINLAUNCHER}" -4 ;trim .exe
		${IfThen} $1 == $2.ini ${|} ${Continue} ${|} ;=== Be sure to preserve user configuration
		${If} ${IsDir} "${EXTRACTDIR}\$1"
			RMDir /r "${EXTRACTDIR}\$1"
		${ElseIf} ${IsFile} "${EXTRACTDIR}\$1"
			Delete "${EXTRACTDIR}\$1"
		${EndIf}
	${Loop}
	FindClose $0
!macroend
!define CleanUpDestination "!insertmacro CleanUpDestination"
;}}}2

;=== Variables {{{1
Var AUTOMATEDINSTALL
Var PORTABLEAPPSPATH
Var INSTFILES_TITLE
Var INSTFILES_SUBTITLE

Function .onInit ;{{{1
	;=== Get long path name of TEMP
	Push $TEMP
	System::Call kernel32::GetLongPathName(ts,t.s,i${NSIS_MAX_STRLEN})i.s
	Pop $0
	Pop $1
	${If} $0 != error
	${AndIf} $1 != $TEMP
		UnsafeStrCpy $TEMP $1
	${EndIf}

	!macro CheckIfRunning _event
	;=== Check if launcher is running
	${Do}
		${If} ${ProcessExists} ${MAINLAUNCHER}
		!if "${_event}" == OnInit
			${IfThen} ${Cmd} ${|} MessageBox MB_OKCANCEL|MB_ICONINFORMATION "Please close all instances of ${APPNAME}.  The portable app can not be upgraded while it is running." IDOK ${|} ${|} ${Continue} ${|}
		!else if "${_event}" == OnLeaveDirectory
			MessageBox MB_OK|MB_ICONINFORMATION "Please close all instances of ${APPNAME} and then click OK.  The portable app can not be upgraded while it is running."
		!endif
		${Else}
			${ExitDo}
		${EndIf}
		Abort
	${Loop}
	!macroend
	!insertmacro CheckIfRunning OnInit

	ClearErrors
	;=== Check for a specified installation directory
	${GetOptions} $CMDLINE /DESTINATION= $0

	${IfNot} ${Errors}
		StrCpy $1 $0 1 -1
		${IfThen} $1 == "\" ${|} StrCpy $0 $0 -1 ${|}
		StrCpy $INSTDIR $0

		;=== Check for PortableApps.com Platform
		;=== Check that it exists at the right location
		${If} ${IsFile} $0\PortableApps.com\PortableAppsPlatform.exe
		;=== Check that it's running
		${AndIf} ${ProcessExists} PortableAppsPlatform.exe
			;=== Do a partially automated install
			StrCpy $AUTOMATEDINSTALL true
		${EndIf}
	${Else}
		ClearErrors
		;=== Check legacy location
		${GetOptions} $CMDLINE -o $0
		${IfNot} ${Errors}
			StrCpy $1 $0 1 -1
			${IfThen} $1 == "\" ${|} StrCpy $0 $0 -1 ${|}
			StrCpy $INSTDIR $0
		${Else}
			;=== No installation directory found
			${GetDrives} HDD+FDD GetDrivesCallBack
			${If} $PORTABLEAPPSPATH != ""
				StrCpy $INSTDIR $PORTABLEAPPSPATH
			${Else}
				;If within Program Files, TEMP or IE Cache, no default install path
				${If}   $EXEDIR contains $PROGRAMFILES
				${OrIf} $EXEDIR contains $PROGRAMFILES64
				${OrIf} $EXEDIR contains $INTERNET_CACHE
				${OrIf} $EXEDIR contains $TEMP
					StrCpy $INSTDIR ""
				${Else}
					StrCpy $INSTDIR $EXEDIR
				${EndIf}
			${EndIf}
		${EndIf}
	${EndIf}

	;=== Destroy the size LOL
	SectionSetSize 0 0
	SectionSetSize 1 0
FunctionEnd

Function GetDrivesCallBack ;{{{1
	;=== Skip usual floppy letters
	${If} $8 == "FDD"
		${If} $9 == "A:\"
		${OrIf} $9 == "B:\"
			Push $0
			Return
		${EndIf}
	${EndIf}

	${If} ${IsDir} $9PortableApps
		StrCpy $PORTABLEAPPSPATH $9PortableApps
	${EndIf}

	Push $0
FunctionEnd

Function PreDirectory ;{{{1
	${IfThen} $AUTOMATEDINSTALL == true ${|} Abort ${|}
FunctionEnd

Function LeaveDirectory ;{{{1
	;=== Check for invalid destination directory
	GetInstDirError $0
	${If} $0 > 0
	${OrIf} "${EXTRACTDIR}" contains $PROGRAMFILES
	${OrIf} "${EXTRACTDIR}" contains $PROGRAMFILES64
		Abort
	${EndIf}

	;=== Check if launcher is running
	${If} ${IsDir} "${EXTRACTDIR}"
		!insertmacro CheckIfRunning OnLeaveDirectory
	${EndIf}
FunctionEnd

Function PreInstFiles ;{{{1
	${IfNot} ${IsDir} "${EXTRACTDIR}"
		StrCpy $INSTFILES_TITLE Extracting
		StrCpy $INSTFILES_SUBTITLE "Please wait while ${APPNAME} is being extracted."
	${Else}
		StrCpy $INSTFILES_TITLE Upgrading
		StrCpy $INSTFILES_SUBTITLE "Please wait while ${APPNAME} is being upgraded."
	${EndIf}
FunctionEnd

Function ShowInstFiles ;{{{1
	w7tbp::Start
FunctionEnd

Function LeaveInstFiles ;{{{1
	;=== Refresh PortableApps.com Menu
	${If} ${IsFile} $INSTDIR\PortableApps.com\PortableAppsPlatform.exe
	${AndIf} ${ProcessExists} PortableAppsPlatform.exe
		;=== Send message for the Menu to refresh
		${IfNot} ${IsFile} $INSTDIR\PortableApps.com\App\PortableAppsPlatform.exe
			StrCpy $2 PortableApps.comPlatformWindowMessageToRefresh$INSTDIR\PortableApps.com\PortableAppsPlatform.exe
			System::Call user32::RegisterWindowMessage(tr2)i.r3
			SendMessage 65535 $3 0 0 /TIMEOUT=1
		${Else} ; old message
			StrCpy $2 PortableApps.comPlatformWindowMessageToRefresh$INSTDIR\PortableApps.com\App\PortableAppsPlatform.exe
			System::Call user32::RegisterWindowMessage(tr2)i.r3
			SendMessage 65535 $3 0 0 /TIMEOUT=1
		${EndIf}
	${EndIf}
FunctionEnd

Function PreFinish ;{{{1
	${IfThen} $AUTOMATEDINSTALL == true ${|} Abort ${|}
	EnableWindow $mui.Button.Cancel 1
	System::Call user32::GetSystemMenu(i$HWNDPARENT,i0)i.s
	System::Call user32::EnableMenuItem(is,i0xF060,i0)
FunctionEnd

Function OpenInstDir ;{{{1
	;=== Open installation directory when finished
	ExecShell "" "${EXTRACTDIR}\"
FunctionEnd

Function .onInstFailed ;{{{1
	;=== Remove directory if empty
	RMDir "${EXTRACTDIR}"
FunctionEnd

Section "${APPNAME}" ;{{{1
	SetDetailsPrint textonly
	${IfNot} ${IsDir} "${EXTRACTDIR}"
		DetailPrint "Extracting ${APPNAME}..."
	${Else}
		DetailPrint "Upgrading ${APPNAME}..."
	${EndIf}

	SetDetailsPrint none

	SectionIn RO

	${CleanUpDestination}

	SetOutPath "${EXTRACTDIR}"
	File "..\..\${MAINLAUNCHER}"
	File ..\..\paul.exe
	File /oname=help.html "${APPID}.html"

	SetOutPath "${EXTRACTDIR}\App\NSIS"
	File ..\..\App\NSIS\COPYING
	File ..\..\App\NSIS\makensis.exe

	SetOutPath "${EXTRACTDIR}\App\NSIS\Bin"
	${AddFiles} ..\..\App\NSIS\Bin\*.*

	SetOutPath "${EXTRACTDIR}\App\NSIS\Contrib"
	${AddFiles} ..\..\App\NSIS\Contrib\*.*

	SetOutPath "${EXTRACTDIR}\App\NSIS\Include"
	${AddFiles} ..\..\App\NSIS\Include\*.*

	SetOutPath "${EXTRACTDIR}\App\NSIS\Plugins\x86-unicode"
	${AddFiles} ..\..\App\NSIS\Plugins\x86-unicode\*.*

	SetOutPath "${EXTRACTDIR}\App\NSIS\Stubs"
	${AddFiles} ..\..\App\NSIS\Stubs\*.*

	SetOutPath "${EXTRACTDIR}\App\AppInfo"
	${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Format Type PortableApps.comFormat
	${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Format Version 3.0
	${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Details Name "${APPNAME}"
	${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Details AppID "${APPID}"
	${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Details Publisher "${PUBLISHER}"
	${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Details Homepage "http://purkdellapps.blogspot.com/search?q=${APPID}"
	${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Details Category "${CATEGORY}"
	FileOpen $R0 "${EXTRACTDIR}\help.html" r ;=== Get Description from help.html
	nsisFile::FileFindBytes $R0 3C683220636C6173733D227461676C696E65223E -1 ;=== Search for <h2 class="tagline">
	FileRead $R0 $0 ;=== Get the result
	${TrimNewLines} $0 $0
	StrCpy $0 $0 "" 20 ;=== Trim <h2 class="tagline"> 
	StrCpy $0 $0 -5 ;=== Trim </h2>
	FileClose $R0
	${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Details Description $0
	${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Details Language "${APPLANGUAGE}"
	${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" License Shareable true
	${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" License OpenSource true
	${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" License Freeware true
	${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" License CommercialUse true
	${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Version PackageVersion "${VER}"
	${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Version DisplayVersion "${FRIENDLYVER}"
	File /oname=appicon.ico "${APPID}.ico"
	File /oname=appicon_16.png "${APPID}_16.png"
	File /oname=appicon_32.png "${APPID}_32.png"
	${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Icons 1
	${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Start "${MAINLAUNCHER}"

	SetOutPath "${EXTRACTDIR}\Other\Help"
	${AddFiles} "Help\*.*"

	SetOutPath "${EXTRACTDIR}\Other\Source"
	${AddFiles} *.*
SectionEnd

Section "Portable App Template" ;{{{1
	RMDir /r "$INSTDIR\AppNamePortable"
	SetOutPath "$INSTDIR\AppNamePortable"
	${AddFiles} ..\..\..\AppNamePortable\*.*
SectionEnd
