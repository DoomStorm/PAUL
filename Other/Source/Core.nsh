; vim:ff=unix:gfn=Consolas\:h10:fdm=marker:fen:nowrap:ts=4:sts=0:sw=0:nu
;
; Use Vim for a better compatibility.

;=== Runtime Switches {{{1
Unicode true
ManifestSupportedOS all
CRCCheck on
WindowIcon off
AutoCloseWindow true
!ifndef RUNASADMIN
RequestExecutionLevel user
!else
RequestExecutionLevel admin
!endif
XPStyle on

; Best Compression {{{2
SetCompress auto
SetCompressor /SOLID lzma
SetCompressorDictSize 32
SetDatablockOptimize on

!ifdef PROGRESSWINDOW ;{{{2
ChangeUI all "${PAUL}\ProgressWindow.bin"
SubCaption 3 " "
SubCaption 4 " "
CompletedText " "
!endif ;}}}2

;=== Calculate app name {{{1
!searchreplace APPNAME "${PORTABLEAPPNAME}" " Portable" ""

;=== Sign the Executable {{{1
!if /FileExists "${PAUL}\..\..\..\Cert\Sign.nsh"
	!include "${PAUL}\..\..\..\Cert\Sign.nsh"
!endif

;=== Segment Order {{{1
!if /FileExists SegmentOrder.nsh
!include SegmentOrder.nsh
!else
!include "${PAUL}\SegmentOrder.nsh"
!endif

;=== Validate defines {{{1
!ifdef  NONELEVATED
!ifndef RUNASADMIN
	!error "NONELEVATED should be combined with RUNASADMIN."
!endif
!endif

;=== Program Details {{{1
Name "${PORTABLEAPPNAME}"
OutFile "..\..\${APPID}.exe"
Caption "${PORTABLEAPPNAME} | PurkdellApps"
VIProductVersion "${VER}"
!define /redef /date DATE "%d %B %Y %H:%M:%S"
VIAddVersionKey /LANG=2057 PAULVersion "${PAULVERSION}"
VIAddVersionKey /LANG=2057 BuildDate "${DATE}"
VIAddVersionKey /LANG=2057 ProductName "${PORTABLEAPPNAME}"
VIAddVersionKey /LANG=2057 Comments "Allows ${APPNAME} to be run from a removable drive.  For additional details, visit PurkdellApps.blogspot.com"
VIAddVersionKey /LANG=2057 CompanyName PurkdellApps
VIAddVersionKey /LANG=2057 LegalCopyright "Azure Zanculmarktum"
VIAddVersionKey /LANG=2057 FileDescription "${PORTABLEAPPNAME}"
VIAddVersionKey /LANG=2057 FileVersion "${VER}"
VIAddVersionKey /LANG=2057 ProductVersion "${VER}"
VIAddVersionKey /LANG=2057 InternalName "${PORTABLEAPPNAME}"
VIAddVersionKey /LANG=2057 LegalTrademarks "PurkdellApps is a Trademark of Azure Zanculmarktum"
VIAddVersionKey /LANG=2057 OriginalFilename "${APPID}.exe"

;=== Additional Plugins {{{1
!addplugindir /x86-unicode "${PAUL}\Plugins"
!addplugindir /x86-unicode Plugins

;=== Include {{{1
;(NSIS Standard) {{{2
!include FileFunc.nsh
!include WordFunc.nsh
!include WinVer.nsh
!include LogicLib.nsh
!include Util.nsh

;(Custom) {{{2
!include "${PAUL}\CompilerUtils.nsh"
!include "${PAUL}\ProcFunc.nsh"
!include "${PAUL}\WriteINIStr.nsh"
!include "${PAUL}\ReadINIStr.nsh"
!include "${PAUL}\MessageBox.nsh"
!include "${PAUL}\UpdatePath.nsh"
!include "${PAUL}\UpdatePathInREG.nsh"
!include "${PAUL}\UnpinFromTaskbar.nsh"
!include "${PAUL}\IsFile.nsh"
!include "${PAUL}\SetEnvironmentVariable.nsh"
!include "${PAUL}\RemoveDirectory.nsh"
!include "${PAUL}\CreateDirectoryAsUser.nsh"
!include "${PAUL}\MoveFiles.nsh"
!include "${PAUL}\LogicLibAdditions.nsh"
!include "${PAUL}\ReplaceInFile.nsh"
!ifdef PROGRESSWINDOW
!include "${PAUL}\TBProgress.nsh"
!endif
!include "${PAUL}\CleanUpDirectory.nsh"
;}}}2

;=== Program Icon {{{1
Icon "${SHORTNAME}.ico"

;=== Icon & Stye {{{1
BrandingText PurkdellApps

;=== Languages {{{1
LoadLanguageFile "${NSISDIR}\Contrib\Language files\${LAUNCHERLANGUAGE}.nlf"

Function .onInit ;{{{1
	; Unlike SilentInstall this one will still
	; shows message when executable has been
	; modified. Allowing us to know if the
	; launcher has been infected by the virus.
	SetSilent silent

	${RunSegment}
FunctionEnd

!macro Init ;{{{1
	${RunSegment}
!macroend

!macro Pre ;{{{1
	${RunSegment}
!macroend

!macro PreLocal ;{{{1
	${RunSegment}
!macroend

!macro PrePortable ;{{{1
	${RunSegment}
!macroend

!macro PreLaunch ;{{{1
	${RunSegment}
!macroend

!macro LaunchPrimary ;{{{1
	${RunSegment}
!macroend

!macro LaunchSecondary ;{{{1
	${RunSegment}
!macroend

!macro PostLaunch ;{{{1
	${RunSegment}
!macroend

!macro PostPortable ;{{{1
	${RunSegment}
!macroend

!macro PostLocal ;{{{1
	${RunSegment}
!macroend

!macro Post ;{{{1
	${RunSegment}
!macroend

!macro CleanUp ;{{{1
	${RunSegment}
!macroend

!macro Unload ;{{{1
	${RunSegment}
!macroend

Section Main ;{{{1
	${CallHook} {
	${CallHook} Launch
	${CallHook} }
SectionEnd
