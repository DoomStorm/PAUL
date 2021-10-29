; vim:ff=unix:gfn=Consolas\:h10:fdm=marker:fen:nowrap:ts=4:sts=0:sw=0:nu
;
; Use Vim for a better compatibility.
;
; Based on John T. Haller of PortableApps.com works.

!define APPNAME "PurkdellApps Compiler Console"
!define APPID "paul"

;=== Include Version {{{1
!include Version.nsh

;=== Require at least NSIS 3.0 {{{1
!include RequireLatestNSIS.nsh

;=== Sign the Executable {{{1
!if /FileExists ..\..\..\Cert\Sign.nsh
	!include ..\..\..\Cert\Sign.nsh
!endif

;=== Remove Icon from Executable {{{1
!packhdr "$%TEMP%\exehead.tmp" `"Bin\ResHacker.exe" -delete "$%TEMP%\exehead.tmp", "$%TEMP%\exehead.tmp", ICONGROUP, 103, 1033 && del "Bin\ResHacker.log" && del "Bin\ResHacker.ini"`

;=== Program Details {{{1
Name "${APPNAME}"
OutFile "..\..\${APPID}.exe"
Caption "${APPNAME}"
VIProductVersion "${VER}"
VIAddVersionKey /LANG=2057 ProductName "${APPNAME}"
VIAddVersionKey /LANG=2057 Comments "A console version of PurkdellApps Compiler. For additional details, visit PurkdellApps.blogspot.com"
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
AutoCloseWindow true

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
!include WordFunc.nsh

;(Custom) {{{2
!include LogicLibAdditions.nsh
;}}}2

;=== Icon & Stye {{{1
BrandingText PurkdellApps™

;=== Languages {{{1
LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"

Function .onInit ;{{{1
	SetSilent silent
FunctionEnd

Section Main ;{{{1
	; If PAUL was executed with -l or -p[64] parameters
	; use command line mode instead
	${GetParameters} $0
	${If} $0 == ""
		Exec `"$EXEDIR\PurkdellAppsCompiler.exe" -c`
	${Else}
		${If}   $0 options -l
		${OrIf} $0 options -p
		${OrIf} $0 options -p64
			Exec `"$EXEDIR\PurkdellAppsCompiler.exe" $0`
		${EndIf}
	${EndIf}
SectionEnd
