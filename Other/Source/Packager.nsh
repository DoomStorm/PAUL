; vim:ff=unix:gfn=Consolas\:h10:fdm=marker:fen:nowrap:ts=4:sts=0:sw=0:nu
;
; Use Vim for a better compatibility.

!ifndef FILENAME
!define FILENAME "${PORTABLEAPPNAME}_${FRIENDLYVER}_${APPLANGUAGE}"
!searchreplace FILENAME "${FILENAME}" _English _en-US
!endif
!searchreplace FILENAME "${FILENAME}" " " _
!ifdef SETUPEXTRACTOR
!define /redef FILENAME "${FILENAME}_Setup_Extractor"
!endif

; Store FILENAME into PackageName.nsh so that PAUL can read
!system "echo ${FILENAME}.paf.exe> PackageName.nsh"

!searchreplace APPNAME "${PORTABLEAPPNAME}" " Portable" ""

!ifndef COMMONFILESPLUGIN
	!define EXTRACTDIR "$INSTDIR\${APPID}"
!else
	!define EXTRACTDIR "$INSTDIR\CommonFiles\${SHORTNAME}"
!endif

!define AddFiles "File /r /x thumbs.db /x desktop.ini"

!ifdef SETUPEXTRACTOR
	!ifdef SETUPFILE
	!if "${SETUPFILE}" == ""
		!error "The defined SETUPFILE could not be found. Please define SETUPFILE with its contents."
	!endif
	!else
		!error "The defined SETUPFILE could not be found. Please define SETUPFILE with its contents."
	!endif
	!define OnlineExtractor "$EXTRACTORTYPE == Online"
	!define OfflineExtractor "$EXTRACTORTYPE == Offline"
!endif

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

;=== Delete existing installer if there is one {{{1
!ifndef COMMONFILESPLUGIN
	!verbose push 3
	!system `attrib -r -a -s -h -i -x "..\..\..\${FILENAME}.paf.exe" >nul 2>&1 && del "..\..\..\${FILENAME}.paf.exe" >nul 2>&1`
	!verbose pop
	!if /FileExists "..\..\..\${FILENAME}.paf.exe"
		!error "Unable to compile the script file, make sure ..\..\..\${FILENAME}.paf.exe is not currently running and then recompile again."
	!endif
!else
	!verbose push 3
	!system `attrib -r -a -s -h -i -x "..\..\..\..\${FILENAME}.paf.exe" >nul 2>&1 && del "..\..\..\..\${FILENAME}.paf.exe" >nul 2>&1`
	!verbose pop
	!if /FileExists "..\..\..\..\${FILENAME}.paf.exe"
		!error "Unable to compile the script file, make sure ..\..\..\..\${FILENAME}.paf.exe is not currently running and then recompile again."
	!endif
!endif

;=== Sign the Executable {{{1
!if /FileExists "${PAUL}\..\..\..\Cert\Sign.nsh"
	!include "${PAUL}\..\..\..\Cert\Sign.nsh"
!endif

;=== Program Details {{{1
Name "${PORTABLEAPPNAME}"
!ifndef COMMONFILESPLUGIN
	OutFile "..\..\..\${FILENAME}.paf.exe"
!else
	OutFile "..\..\..\..\${FILENAME}.paf.exe"
!endif
Caption "${PORTABLEAPPNAME} | PurkdellApps"
VIProductVersion "${VER}"
VIAddVersionKey /LANG=2057 ProductName "${PORTABLEAPPNAME}"
VIAddVersionKey /LANG=2057 CompanyName PurkdellApps
VIAddVersionKey /LANG=2057 LegalCopyright "Azure Zanculmarktum"
VIAddVersionKey /LANG=2057 FileDescription "${PORTABLEAPPNAME}"
VIAddVersionKey /LANG=2057 FileVersion "${VER}"
VIAddVersionKey /LANG=2057 ProductVersion "${FRIENDLYVER}"
VIAddVersionKey /LANG=2057 InternalName "${PORTABLEAPPNAME}"
VIAddVersionKey /LANG=2057 LegalTrademarks "PurkdellApps is a Trademark of Azure Zanculmarktum"
VIAddVersionKey /LANG=2057 OriginalFilename "${FILENAME}.paf.exe"

;=== Additional Plugins {{{1
!addplugindir /x86-unicode "${PAUL}\Plugins"
!addplugindir /x86-unicode Plugins

;=== Include {{{1
;(NSIS Standard) {{{2
!include MUI2.nsh
!include FileFunc.nsh
!include WordFunc.nsh
!include LogicLib.nsh
!include TextFunc.nsh

;(Custom) {{{2
!include "${PAUL}\ProcFunc.nsh"
!include "${PAUL}\WriteINIStr.nsh"
!include "${PAUL}\IsFile.nsh"
!include "${PAUL}\LogicLibAdditions.nsh"
!include "${PAUL}\RemoveDirectory.nsh"
!include "${PAUL}\CleanUpDirectory.nsh"
;}}}2

;=== Program Icon {{{1
Icon "${SHORTNAME}.ico"
!define MUI_ICON "${SHORTNAME}.ico"

;=== Icon & Stye {{{1
BrandingText PurkdellApps™
InstallButtonText E&xtract

;=== Pages {{{1
!define MUI_WELCOMEFINISHPAGE_BITMAP "${PAUL}\Packager.bmp"

;INPUTBOXPAGE {{{2
!ifdef INPUTBOXPAGE
	Page custom ShowInputBox LeaveInputBox
!endif

;SETUPEXTRACTOR {{{2
!ifdef SETUPEXTRACTOR
	Page custom ShowSetupExtractor LeaveSetupExtractor
!endif

;COMPONENTS {{{2
!ifdef ADDITIONALCOMPONENTS | MULTILINGUALSECTION
	!define MUI_COMPONENTSPAGE_CHECKBITMAP "${PAUL}\Checks.bmp"
	!define MUI_COMPONENTSPAGE_NODESC
	!define MUI_TEXT_COMPONENTS_TITLE "Choose Components"
	!define MUI_TEXT_COMPONENTS_SUBTITLE "Choose which features of ${PORTABLEAPPNAME} you want to extract."
	!define MUI_COMPONENTSPAGE_TEXT_TOP "Check the components you want to extract and uncheck the components you don't want to extract. Click Next to continue."
	!define MUI_COMPONENTSPAGE_TEXT_COMPLIST "Select components to extract:"
	!insertmacro MUI_PAGE_COMPONENTS
!endif

;DIRECTORY {{{2
!define MUI_TEXT_DIRECTORY_TITLE "Choose Extract Location"
!define MUI_TEXT_DIRECTORY_SUBTITLE "Choose the folder in which to extract ${PORTABLEAPPNAME}."
!define MUI_DIRECTORYPAGE_TEXT_TOP "Setup will extract ${PORTABLEAPPNAME} in the following folder. To extract in a different folder, click Browse and select another folder. Click Extract to start the extraction."
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
!ifndef COMMONFILESPLUGIN
	!define MUI_TEXT_FINISH_TITLE $INSTFILES_TITLE
	!define MUI_TEXT_FINISH_SUBTITLE $INSTFILES_SUBTITLE
	!define MUI_TEXT_FINISH_INFO_TITLE "Completing the ${PORTABLEAPPNAME} Setup"
	!define MUI_FINISHPAGE_TEXT "${PORTABLEAPPNAME} has been extracted on your device.$\r$\n$\r$\nClick Finish to close this wizard."
	!define MUI_FINISHPAGE_TITLE_3LINES
	!define MUI_FINISHPAGE_RUN
	!define MUI_FINISHPAGE_RUN_TEXT "Open ${PORTABLEAPPNAME} folder"
	!define MUI_FINISHPAGE_RUN_NOTCHECKED
	!define MUI_FINISHPAGE_RUN_FUNCTION OpenInstDir
	!define MUI_PAGE_CUSTOMFUNCTION_PRE PreFinish
	!insertmacro MUI_PAGE_FINISH
!endif ;}}}2

;=== Languages {{{1
!insertmacro MUI_LANGUAGE English

;=== Macros {{{1
!macro MainSection ;{{{2
!define MainSection_Open
Section "${PORTABLEAPPNAME}" SecMain
	SetDetailsPrint textonly
	${IfNot} ${IsDir} "${EXTRACTDIR}"
		StrCpy $EXTRACTINGSTATUS "Extracting ${PORTABLEAPPNAME}..."
	${Else}
		StrCpy $EXTRACTINGSTATUS "Upgrading ${PORTABLEAPPNAME}..."
	${EndIf}
	DetailPrint $EXTRACTINGSTATUS

	SetDetailsPrint none ;=== Hide any install details

	SectionIn RO ;=== Set this section to read-only

	;=== Extract Files
!macroend
!define MainSection "!insertmacro MainSection"

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
			${RemoveDirectory} "${EXTRACTDIR}\$1"
		${ElseIf} ${IsFile} "${EXTRACTDIR}\$1"
			Delete "${EXTRACTDIR}\$1"
		${EndIf}
	${Loop}
	FindClose $0
!macroend
!define CleanUpDestination "!insertmacro CleanUpDestination"

!macro MainSectionEnd ;{{{2
!ifndef MainSection_Open
	!error "There isn't MainSection clause open!"
!else
	;=== Get cancelled signal
	Pop $0

	;=== Do not extract anything if something is wrong
	;i.e. failed downloading setup file
	${If} $0 != Cancelled
		SetOutPath "${EXTRACTDIR}"
	!ifdef MAINLAUNCHER
		File "..\..\${MAINLAUNCHER}"
	!endif
	!ifdef OTHERLAUNCHER1
		File "..\..\${OTHERLAUNCHER1}"
	!endif
	!ifdef OTHERLAUNCHER2
		File "..\..\${OTHERLAUNCHER2}"
	!endif
	!ifdef OTHERLAUNCHER3
		File "..\..\${OTHERLAUNCHER3}"
	!endif
	!ifdef OTHERLAUNCHER4
		File "..\..\${OTHERLAUNCHER4}"
	!endif
	!ifdef OTHERLAUNCHER5
		File "..\..\${OTHERLAUNCHER5}"
	!endif
	!ifdef OTHERLAUNCHER6
		File "..\..\${OTHERLAUNCHER6}"
	!endif
	!ifdef OTHERLAUNCHER7
		File "..\..\${OTHERLAUNCHER7}"
	!endif
	!ifdef OTHERLAUNCHER8
		File "..\..\${OTHERLAUNCHER8}"
	!endif
	!ifdef OTHERLAUNCHER9
		File "..\..\${OTHERLAUNCHER9}"
	!endif
	!ifdef OTHERLAUNCHER10
		File "..\..\${OTHERLAUNCHER10}"
	!endif
		File /oname=help.html "${SHORTNAME}.html"

	!ifndef COMMONFILESPLUGIN
		SetOutPath "${EXTRACTDIR}\App\AppInfo"
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Format Type PortableApps.comFormat
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Format Version 3.0
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Details Name "${PORTABLEAPPNAME}"
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Details AppID "${APPID}"
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Details Publisher "${PUBLISHER} & PurkdellApps"
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Details Homepage "http://purkdellapps.blogspot.com/search?q=${SHORTNAME}"
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Details Category "${CATEGORY}"
		FileOpen $R0 "${EXTRACTDIR}\help.html" r ;=== Get Description from help.html
		nsisFile::FileFindBytes $R0 3C683220636C6173733D227461676C696E65223E -1 ;=== Search for <h2 class="tagline">
		;Pop $R1
		;${If} $R1 <> -1
		FileRead $R0 $0 ;=== Get the result
		${TrimNewLines} $0 $0
		StrCpy $0 $0 "" 20 ;=== Trim <h2 class="tagline"> 
		StrCpy $0 $0 -5 ;=== Trim </h2>
		;${EndIf}
		FileClose $R0
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Details Description $0
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Details Language "${APPLANGUAGE}"
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" License Shareable true
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" License OpenSource true
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" License Freeware true
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" License CommercialUse true
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Version PackageVersion "${VER}"
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Version DisplayVersion "${FRIENDLYVER}"
	!ifndef OTHERLAUNCHER1
		File /oname=appicon.ico "${SHORTNAME}.ico"
		File /oname=appicon_16.png "${SHORTNAME}_16.png"
		File /oname=appicon_32.png "${SHORTNAME}_32.png"
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Icons 1
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Start "${MAINLAUNCHER}"
	!else
		File /oname=appicon1.ico "${SHORTNAME}.ico"
		File /oname=appicon1_16.png "${SHORTNAME}_16.png"
		File /oname=appicon1_32.png "${SHORTNAME}_32.png"
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Icons 2
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Start1 "${MAINLAUNCHER}"
		MoreInfo::GetProductName "${EXTRACTDIR}\${MAINLAUNCHER}"
		Pop $0
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Name1 $0
		!searchreplace APPICON "${OTHERLAUNCHER1}" Portable.exe ""
		File /oname=appicon2.ico "${APPICON}.ico"
		File /oname=appicon2_16.png "${APPICON}_16.png"
		File /oname=appicon2_32.png "${APPICON}_32.png"
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Start2 "${OTHERLAUNCHER1}"
		MoreInfo::GetProductName "${EXTRACTDIR}\${OTHERLAUNCHER1}"
		Pop $0
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Name2 $0
	!endif
	!ifdef OTHERLAUNCHER2
		!searchreplace APPICON "${OTHERLAUNCHER2}" Portable.exe ""
		File /oname=appicon3.ico "${APPICON}.ico"
		File /oname=appicon3_16.png "${APPICON}_16.png"
		File /oname=appicon3_32.png "${APPICON}_32.png"
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Icons 3
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Start3 "${OTHERLAUNCHER2}"
		MoreInfo::GetProductName "${EXTRACTDIR}\${OTHERLAUNCHER2}"
		Pop $0
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Name3 $0
	!endif
	!ifdef OTHERLAUNCHER3
		!searchreplace APPICON "${OTHERLAUNCHER3}" Portable.exe ""
		File /oname=appicon4.ico "${APPICON}.ico"
		File /oname=appicon4_16.png "${APPICON}_16.png"
		File /oname=appicon4_32.png "${APPICON}_32.png"
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Icons 4
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Start4 "${OTHERLAUNCHER3}"
		MoreInfo::GetProductName "${EXTRACTDIR}\${OTHERLAUNCHER3}"
		Pop $0
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Name4 $0
	!endif
	!ifdef OTHERLAUNCHER4
		!searchreplace APPICON "${OTHERLAUNCHER4}" Portable.exe ""
		File /oname=appicon5.ico "${APPICON}.ico"
		File /oname=appicon5_16.png "${APPICON}_16.png"
		File /oname=appicon5_32.png "${APPICON}_32.png"
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Icons 5
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Start5 "${OTHERLAUNCHER4}"
		MoreInfo::GetProductName "${EXTRACTDIR}\${OTHERLAUNCHER4}"
		Pop $0
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Name5 $0
	!endif
	!ifdef OTHERLAUNCHER5
		!searchreplace APPICON "${OTHERLAUNCHER5}" Portable.exe ""
		File /oname=appicon6.ico "${APPICON}.ico"
		File /oname=appicon6_16.png "${APPICON}_16.png"
		File /oname=appicon6_32.png "${APPICON}_32.png"
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Icons 6
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Start6 "${OTHERLAUNCHER5}"
		MoreInfo::GetProductName "${EXTRACTDIR}\${OTHERLAUNCHER5}"
		Pop $0
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Name6 $0
	!endif
	!ifdef OTHERLAUNCHER6
		!searchreplace APPICON "${OTHERLAUNCHER6}" Portable.exe ""
		File /oname=appicon7.ico "${APPICON}.ico"
		File /oname=appicon7_16.png "${APPICON}_16.png"
		File /oname=appicon7_32.png "${APPICON}_32.png"
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Icons 7
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Start7 "${OTHERLAUNCHER6}"
		MoreInfo::GetProductName "${EXTRACTDIR}\${OTHERLAUNCHER6}"
		Pop $0
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Name7 $0
	!endif
	!ifdef OTHERLAUNCHER7
		!searchreplace APPICON "${OTHERLAUNCHER7}" Portable.exe ""
		File /oname=appicon8.ico "${APPICON}.ico"
		File /oname=appicon8_16.png "${APPICON}_16.png"
		File /oname=appicon8_32.png "${APPICON}_32.png"
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Icons 8
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Start8 "${OTHERLAUNCHER7}"
		MoreInfo::GetProductName "${EXTRACTDIR}\${OTHERLAUNCHER7}"
		Pop $0
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Name8 $0
	!endif
	!ifdef OTHERLAUNCHER8
		!searchreplace APPICON "${OTHERLAUNCHER8}" Portable.exe ""
		File /oname=appicon9.ico "${APPICON}.ico"
		File /oname=appicon9_16.png "${APPICON}_16.png"
		File /oname=appicon9_32.png "${APPICON}_32.png"
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Icons 9
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Start9 "${OTHERLAUNCHER8}"
		MoreInfo::GetProductName "${EXTRACTDIR}\${OTHERLAUNCHER8}"
		Pop $0
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Name9 $0
	!endif
	!ifdef OTHERLAUNCHER9
		!searchreplace APPICON "${OTHERLAUNCHER9}" Portable.exe ""
		File /oname=appicon10.ico "${APPICON}.ico"
		File /oname=appicon10_16.png "${APPICON}_16.png"
		File /oname=appicon10_32.png "${APPICON}_32.png"
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Icons 10
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Start10 "${OTHERLAUNCHER9}"
		MoreInfo::GetProductName "${EXTRACTDIR}\${OTHERLAUNCHER9}"
		Pop $0
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Name10 $0
	!endif
	!ifdef OTHERLAUNCHER10
		!searchreplace APPICON "${OTHERLAUNCHER10}" Portable.exe ""
		File /oname=appicon11.ico "${APPICON}.ico"
		File /oname=appicon11_16.png "${APPICON}_16.png"
		File /oname=appicon11_32.png "${APPICON}_32.png"
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Icons 11
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Start11 "${OTHERLAUNCHER10}"
		MoreInfo::GetProductName "${EXTRACTDIR}\${OTHERLAUNCHER10}"
		Pop $0
		${WriteINIStr} "${EXTRACTDIR}\App\AppInfo\appinfo.ini" Control Name11 $0
	!endif
	!ifdef APPICON
		!undef APPICON
	!endif
	!endif ; COMMONFILESPLUGIN

		SetOutPath "${EXTRACTDIR}\Other\Help"
		${AddFiles} "${PAUL}\Help\*.*"
		!if /FileExists Help\*.*
			${AddFiles} Help\*.*
		!endif

	!ifdef INCLUDESOURCE
		SetOutPath "${EXTRACTDIR}\Other\Source"
		${AddFiles} /x PackageName.nsh /x *.log *.*
	!endif
	${EndIf}
SectionEnd
!endif
!macroend
!define MainSectionEnd "!insertmacro MainSectionEnd"
;}}}2

;=== Variables {{{1
Var AUTOMATEDINSTALL
Var PORTABLEAPPSPATH
Var INSTFILES_TITLE
Var INSTFILES_SUBTITLE
!ifdef INPUTBOXPAGE
	Var VERSION
	Var VERSIONCONTROL
!endif
!ifdef SETUPEXTRACTOR
	Var SETUPEXTRACTOR
	Var SETUPFILE
	Var FILEREQUEST
	Var OUTPUTDIR
	Var DIRREQUEST
	Var OFFLINEEXTRACTOR
	Var ONLINEEXTRACTOR
	Var EXTRACTORTYPE
!endif
Var EXTRACTINGSTATUS

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
		${If}   ${ProcessExists} ${MAINLAUNCHER}
	!ifdef OTHERLAUNCHER1
		${OrIf} ${ProcessExists} ${OTHERLAUNCHER1}
	!endif
	!ifdef OTHERLAUNCHER2
		${OrIf} ${ProcessExists} ${OTHERLAUNCHER2}
	!endif
	!ifdef OTHERLAUNCHER3
		${OrIf} ${ProcessExists} ${OTHERLAUNCHER3}
	!endif
	!ifdef OTHERLAUNCHER4
		${OrIf} ${ProcessExists} ${OTHERLAUNCHER4}
	!endif
	!ifdef OTHERLAUNCHER5
		${OrIf} ${ProcessExists} ${OTHERLAUNCHER5}
	!endif
	!ifdef OTHERLAUNCHER6
		${OrIf} ${ProcessExists} ${OTHERLAUNCHER6}
	!endif
	!ifdef OTHERLAUNCHER7
		${OrIf} ${ProcessExists} ${OTHERLAUNCHER7}
	!endif
	!ifdef OTHERLAUNCHER8
		${OrIf} ${ProcessExists} ${OTHERLAUNCHER8}
	!endif
	!ifdef OTHERLAUNCHER9
		${OrIf} ${ProcessExists} ${OTHERLAUNCHER9}
	!endif
	!ifdef OTHERLAUNCHER10
		${OrIf} ${ProcessExists} ${OTHERLAUNCHER10}
	!endif
		!if "${_event}" == OnInit
			${IfThen} ${Cmd} ${|} MessageBox MB_OKCANCEL|MB_ICONINFORMATION "Please close all instances of ${PORTABLEAPPNAME}.  The portable app can not be upgraded while it is running." IDOK ${|} ${|} ${Continue} ${|}
		!else if "${_event}" == OnLeaveDirectory
			MessageBox MB_OK|MB_ICONINFORMATION "Please close all instances of ${PORTABLEAPPNAME} and then click OK.  The portable app can not be upgraded while it is running."
		!endif
		${Else}
			${ExitDo}
		${EndIf}
		Abort
	${Loop}
	!macroend
	!insertmacro CheckIfRunning OnInit

	Call Init

	!ifdef MULTILINGUALSECTION
	Call LanguageSelector
	!endif

	ClearErrors
	;=== Check for a specified installation directory
	${GetOptions} $CMDLINE /DESTINATION= $0

	${IfNot} ${Errors}
		StrCpy $1 $0 1 -1
		${IfThen} $1 == "\" ${|} StrCpy $0 $0 -1 ${|}
		StrCpy $INSTDIR $0

		;=== Check for PortableApps.com Platform
		!ifdef COMMONFILESPLUGIN
			${GetParent} $INSTDIR $0
		!endif

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

!ifdef INPUTBOXPAGE
Function ShowInputBox ;{{{1
	!insertmacro MUI_HEADER_TEXT "${APPNAME} Version" "Enter the ${APPNAME} Version."

	;=== Create a new dialog
	nsDialogs::Create 1018
	Pop $0

	;=== Label control
	nsDialogs::CreateControl STATIC 0x40000000|0x10000000|0x04000000|0x00000100 0x00000020 0 0 100% 20u "Specify the ${APPNAME} Version to be used for url and/or setup file name. If you don't know what to enter, please refer to:"

	;=== Link control
	nsDialogs::CreateControl LINK 0x40000000|0x10000000|0x04000000|0x00010000|0x0000000B 0 0 30 100% 10u "${PORTABLEAPPNAME} Homepage"
	Pop $0
	GetFunctionAddress $1 OpenHomepage
	nsDialogs::OnClick $0 $1

	;=== Label control
	nsDialogs::CreateControl STATIC 0x40000000|0x10000000|0x04000000|0x00000100 0x00000020 0 47 100% 10u "to obtain the value."

	;=== Group box control
	nsDialogs::CreateControl BUTTON 0x40000000|0x10000000|0x04000000|0x00000007 0x00000020 0 95 100% 57 Version

	;=== Text control
	nsDialogs::CreateControl EDIT 0x40000000|0x10000000|0x04000000|0x00010000|0x00000080 0x00000100|0x00000200 15 119 416 20 $VERSION
	Pop $VERSIONCONTROL
	System::Call user32::SetFocus(p$VERSIONCONTROL)

	;=== Display the page
	nsDialogs::Show
FunctionEnd

Function OpenHomepage ;{{{1
	;=== Open the link
	ExecShell "" "http://purkdellapps.blogspot.com/search?q=${SHORTNAME}"
FunctionEnd

Function LeaveInputBox ;{{{1
	;=== Get specified version
	System::Call user32::GetWindowText(p$VERSIONCONTROL,t.s,i${NSIS_MAX_STRLEN})
	Pop $VERSION

	;=== Verify the specified version
	${If} $VERSION == ""
		System::Call user32::SetFocus(p$VERSIONCONTROL)
		Abort
	${EndIf}

	Call VerifyVersion
FunctionEnd
!endif

!ifdef SETUPEXTRACTOR
!define /ifndef OFN_READONLY 0x00000001
!define /ifndef OFN_OVERWRITEPROMPT 0x00000002
!define /ifndef OFN_HIDEREADONLY 0x00000004
!define /ifndef OFN_NOCHANGEDIR 0x00000008
!define /ifndef OFN_SHOWHELP 0x00000010
!define /ifndef OFN_ENABLEHOOK 0x00000020
!define /ifndef OFN_ENABLETEMPLATE 0x00000040
!define /ifndef OFN_ENABLETEMPLATEHANDLE 0x00000080
!define /ifndef OFN_NOVALIDATE 0x00000100
!define /ifndef OFN_ALLOWMULTISELECT 0x00000200
!define /ifndef OFN_EXTENSIONDIFFERENT 0x00000400
!define /ifndef OFN_PATHMUSTEXIST 0x00000800
!define /ifndef OFN_FILEMUSTEXIST 0x00001000
!define /ifndef OFN_CREATEPROMPT 0x00002000
!define /ifndef OFN_SHAREAWARE 0x00004000
!define /ifndef OFN_NOREADONLYRETURN 0x00008000
!define /ifndef OFN_NOTESTFILECREATE 0x00010000
!define /ifndef OFN_NONETWORKBUTTON 0x00020000
!define /ifndef OFN_NOLONGNAMES 0x00040000 ; force no long names for 4.x modules
!define /ifndef OFN_EXPLORER 0x00080000 ; new look commdlg
!define /ifndef OFN_NODEREFERENCELINKS 0x00100000
!define /ifndef OFN_LONGNAMES 0x00200000 ; force long names for 3.x modules
!define /ifndef OFN_ENABLEINCLUDENOTIFY 0x00400000 ; send include message to callback
!define /ifndef OFN_ENABLESIZING 0x00800000
!define /ifndef OFN_DONTADDTORECENT 0x02000000
!define /ifndef OFN_FORCESHOWHIDDEN 0x10000000 ; Show All files including System and hidden files

Function ShowSetupExtractor ;{{{1
	!insertmacro MUI_HEADER_TEXT "${APPNAME} Setup Extractor" "Select the ${APPNAME} Setup to extract."

	;=== Create a new dialog
	nsDialogs::Create 1018
	Pop $SETUPEXTRACTOR

	;=== Group box control
	nsDialogs::CreateControl BUTTON 0x40000000|0x10000000|0x04000000|0x00000007 0x00000020 0 77 100% 57 "${APPNAME} Setup:"
	nsDialogs::CreateControl BUTTON 0x40000000|0x10000000|0x04000000|0x00000007 0x00000020 0 167 100% 57 "Save Downloaded ${APPNAME} Setup to:"

	;=== Label control
	nsDialogs::CreateControl STATIC 0x40000000|0x10000000|0x04000000|0x00000100 0x00000020 0 0 100% 35u "Setup extractor will extract files from the ${APPNAME} Setup. Select Offline Extractor if you have ${APPNAME} Setup, then click Browse to select it. Select Online Extractor if you don't have ${APPNAME} Setup, and setup extractor will download it."

	;=== File request
	nsDialogs::CreateControl BUTTON 0x40000000|0x10000000|0x04000000|0x00010000 0 -108 98 90 24 Browse...
	Pop $0
	GetFunctionAddress $1 LocateSetupFile
	nsDialogs::OnClick $0 $1

	${GetParent} $SETUPFILE $0
	${If} $SETUPFILE == ""
	${OrIfNot} ${IsFile} "$0\${SETUPFILE}"
		StrCpy $SETUPFILE "${SETUPFILE}"
	${EndIf}
	${If} ${IsFile} "$EXEDIR\${SETUPFILE}"
		StrCpy $SETUPFILE "$EXEDIR\${SETUPFILE}"
	${EndIf}
	nsDialogs::CreateControl EDIT 0x40000000|0x10000000|0x04000000|0x00010000|0x00000080|0x00000800 0x00000100|0x00000200 15 101 315 20 $SETUPFILE
	Pop $FILEREQUEST

	;=== Dir request
	nsDialogs::CreateControl BUTTON 0x40000000|0x10000000|0x04000000|0x00010000 0 -108 188 90 24 Browse...
	Pop $0
	GetFunctionAddress $1 SaveSetupFile
	nsDialogs::OnClick $0 $1

	${If} $OUTPUTDIR == ""
		StrCpy $OUTPUTDIR $EXEDIR
	${EndIf}
	StrCpy $SETUPFILE "$OUTPUTDIR\${SETUPFILE}"
	nsDialogs::CreateControl EDIT 0x40000000|0x10000000|0x04000000|0x00010000|0x00000080|0x00000800 0x00000100|0x00000200 15 191 315 20 $OUTPUTDIR
	Pop $DIRREQUEST

	;=== Radio button control
	nsDialogs::CreateControl BUTTON 0x40000000|0x10000000|0x04000000|0x00010000|0x00000000|0x00000C00|0x00000009|0x00002000 0 0 60 100% 10u "Offline Extractor"
	Pop $OFFLINEEXTRACTOR
	GetFunctionAddress $0 SetOfflineExtractor
	nsDialogs::OnClick $OFFLINEEXTRACTOR $0

	nsDialogs::CreateControl BUTTON 0x40000000|0x10000000|0x04000000|0x00010000|0x00000000|0x00000C00|0x00000009|0x00002000 0 0 150 100% 10u "Online Extractor"
	Pop $ONLINEEXTRACTOR
	GetFunctionAddress $0 SetOnlineExtractor
	nsDialogs::OnClick $ONLINEEXTRACTOR $0

	${If} $EXTRACTORTYPE != Online
		Call SetOfflineExtractor
	${Else}
		Call SetOnlineExtractor
	${EndIf}
	SendMessage $0 0x00F1 1 0

	;=== Display the page
	nsDialogs::Show
FunctionEnd

Function LocateSetupFile ;{{{1
	StrCpy $0 "${SETUPFILE}"
	StrLen $1 $0
	IntOp $1 $1 + 1

	StrCpy $6 (&l4,i,i0,i,i0,i0,i0,t,i${NSIS_MAX_STRLEN},t,i${NSIS_MAX_STRLEN},t,t,i,&i2,&i2,t,i0,i0,i0)i

	System::Call *(&t$1"$0",&t$1"$0",&i10)i.s
	Pop $2

	System::Call *$6(,$HWNDPARENT,,$2,,,,"",,"",,"$EXEDIR","",0xA01800|${OFN_HIDEREADONLY}|${OFN_PATHMUSTEXIST}|${OFN_FILEMUSTEXIST}|${OFN_LONGNAMES},,,,,,).s
	Pop $3

	System::Call comdlg32::GetOpenFileNameW(i$3)i.s
	Pop $4
	System::Call *$3$6(,,,,,,,.s)
	Pop $5
	System::Free $3
	System::Free $2

	${If} $4 == 1
		SendMessage $FILEREQUEST 0x000C 0 STR:$5
		StrCpy $SETUPFILE $5
	${EndIf}
FunctionEnd

Function SaveSetupFile ;{{{1
	nsDialogs::SelectFolderDialog "Select the folder to save ${APPNAME} Setup in:" "${SETUPFILE}"
	Pop $0
	${If} $0 != error
		SendMessage $DIRREQUEST 0x000C 0 STR:$0
		StrCpy $1 $0 1 -1
		${IfThen} $1 == "\" ${|} StrCpy $0 $0 -1 ${|}
		StrCpy $OUTPUTDIR $0
		StrCpy $SETUPFILE "$OUTPUTDIR\${SETUPFILE}"
	${EndIf}
FunctionEnd

Function SetOfflineExtractor ;{{{1
	;=== Show Offline Extractor
	GetDlgItem $0 $SETUPEXTRACTOR 1200
	ShowWindow $0 1
	GetDlgItem $0 $SETUPEXTRACTOR 1203
	ShowWindow $0 1
	GetDlgItem $0 $SETUPEXTRACTOR 1204
	ShowWindow $0 1

	;=== Hide Online Extractor
	GetDlgItem $0 $SETUPEXTRACTOR 1205
	ShowWindow $0 0
	GetDlgItem $0 $SETUPEXTRACTOR 1206
	ShowWindow $0 0
	GetDlgItem $0 $SETUPEXTRACTOR 1201
	ShowWindow $0 0

	;=== Remember the state
	StrCpy $EXTRACTORTYPE Offline
	StrCpy $0 $OFFLINEEXTRACTOR
FunctionEnd

Function SetOnlineExtractor ;{{{1
	;=== Hide Offline Extractor
	GetDlgItem $0 $SETUPEXTRACTOR 1200
	ShowWindow $0 0
	GetDlgItem $0 $SETUPEXTRACTOR 1203
	ShowWindow $0 0
	GetDlgItem $0 $SETUPEXTRACTOR 1204
	ShowWindow $0 0

	;=== Show Online Extractor
	GetDlgItem $0 $SETUPEXTRACTOR 1205
	ShowWindow $0 1
	GetDlgItem $0 $SETUPEXTRACTOR 1206
	ShowWindow $0 1
	GetDlgItem $0 $SETUPEXTRACTOR 1201
	ShowWindow $0 1

	;=== Remember the state
	StrCpy $EXTRACTORTYPE Online
	StrCpy $0 $ONLINEEXTRACTOR
FunctionEnd

Function LeaveSetupExtractor ;{{{1
	; Be sure specified setup file is present
	${If} ${OfflineExtractor}
		${IfNot} ${IsFile} $SETUPFILE
			Abort
		${EndIf}
	${EndIf}
FunctionEnd
!endif

Function PreDirectory ;{{{1
	${IfThen} $AUTOMATEDINSTALL == true ${|} Abort ${|}
FunctionEnd

Function LeaveDirectory ;{{{1
	!define /ifndef WM_SETTEXT 0x000C

	;=== Allow use of environment variable in the destination directory
	${If} $INSTDIR contains %
		ExpandEnvStrings $INSTDIR $INSTDIR
	${EndIf}

	;=== Append "\" inside text control
	${If} $INSTDIR != ""
		StrCpy $2 $INSTDIR "" -1
		${If} $2 == "\"
			StrCpy $1 $INSTDIR
		${Else}
			StrCpy $1 "$INSTDIR\"
		${EndIf}

	;=== Set the contents inside text control
		FindWindow $0 "#32770" "" $HWNDPARENT
		GetDlgItem $0 $0 1019
		SendMessage $0 ${WM_SETTEXT} 0 STR:$1
	${EndIf}

	;=== Check for invalid destination directory
	GetInstDirError $0
	${If} $0 > 0
	${OrIf} "${EXTRACTDIR}" contains $PROGRAMFILES
	${OrIf} "${EXTRACTDIR}" contains $PROGRAMFILES64
		Abort
	${EndIf}

!ifdef NOREMOVABLEDRIVE
	;=== Prevent from extracting into removable drive
	!define /ifndef DRIVE_UNKNOWN     0
	!define /ifndef DRIVE_NO_ROOT_DIR 1
	!define /ifndef DRIVE_REMOVABLE   2
	!define /ifndef DRIVE_FIXED       3
	!define /ifndef DRIVE_REMOTE      4
	!define /ifndef DRIVE_CDROM       5
	!define /ifndef DRIVE_RAMDISK     6

	; Get current drive
	${GetRoot} $INSTDIR $0

	; Get drive type
	Push "$0\"
	System::Call kernel32::GetDriveTypeW(ts)i.s
	Pop $0

	; Is it run from inside removable drive?
	${If} $0 == ${DRIVE_REMOVABLE}
		; If so, prevent user from running
		MessageBox MB_ICONINFORMATION "You cannot extract ${PORTABLEAPPNAME} into removable drive. It will cause issues when you trying to stop your device that is running ${PORTABLEAPPNAME}. Please select another location instead."
		Abort
	${EndIf}
!endif ; NOREMOVABLEDRIVE

	;=== Check if launcher is running
	${If} ${IsDir} "${EXTRACTDIR}"
		!insertmacro CheckIfRunning OnLeaveDirectory
	${EndIf}
FunctionEnd

Function PreInstFiles ;{{{1
	${IfNot} ${IsDir} "${EXTRACTDIR}"
		StrCpy $INSTFILES_TITLE Extracting
		StrCpy $INSTFILES_SUBTITLE "Please wait while ${PORTABLEAPPNAME} is being extracted."
	${Else}
		StrCpy $INSTFILES_TITLE Upgrading
		StrCpy $INSTFILES_SUBTITLE "Please wait while ${PORTABLEAPPNAME} is being upgraded."
	${EndIf}
FunctionEnd

Function ShowInstFiles ;{{{1
	w7tbp::Start
FunctionEnd

Function LeaveInstFiles ;{{{1
	!ifndef COMMONFILESPLUGIN
	;=== Refresh PortableApps.com Menu
	${If} ${IsFile} $INSTDIR\PortableApps.com\PortableAppsPlatform.exe
	${AndIf} ${ProcessExists} PortableAppsPlatform.exe
		;=== Send message for the Menu to refresh
		${IfNot} ${IsFile} $INSTDIR\PortableApps.com\App\PortableAppsPlatform.exe
			Push PortableApps.comPlatformWindowMessageToRefresh$INSTDIR\PortableApps.com\PortableAppsPlatform.exe
		${Else} ; old message
			Push PortableApps.comPlatformWindowMessageToRefresh$INSTDIR\PortableApps.com\App\PortableAppsPlatform.exe
		${EndIf}
		System::Call user32::RegisterWindowMessage(ts)i.s
		Pop $0
		SendMessage 65535 $0 0 0 /TIMEOUT=1
	${EndIf}
	!endif
FunctionEnd

Function PreFinish ;{{{1
	${IfThen} $AUTOMATEDINSTALL == true ${|} Abort ${|}
	EnableWindow $mui.Button.Cancel 1
	System::Call user32::GetSystemMenu(i$HWNDPARENT,i0)i.s
	System::Call user32::EnableMenuItem(is,i0xF060,i0)
FunctionEnd

!ifndef COMMONFILESPLUGIN
Function OpenInstDir ;{{{1
	;=== Open installation directory when finished
	ExecShell "" "${EXTRACTDIR}\"
FunctionEnd
!endif

Function .onInstFailed ;{{{1
	;=== Remove directory if empty
	RMDir "${EXTRACTDIR}"
FunctionEnd
