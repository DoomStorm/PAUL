; vim:ff=unix:gfn=Consolas\:h10:fdm=marker:fen:nowrap:ts=4:sts=0:sw=0:nu
;
; Use Vim for a better compatibility.

; Create segment definitions {{{1
!define SegmentStart           `!if      "${__SEGMENT__}" == ThisIsAnEmptyStringThatIsUsedAsDummy`
!define Segment.onInit         `!else if "${__SEGMENT__}" == .onInit`
!define SegmentInit            `!else if "${__SEGMENT__}" == Init`
!define SegmentPre             `!else if "${__SEGMENT__}" == Pre`
!define SegmentPreLocal        `!else if "${__SEGMENT__}" == PreLocal`
!define SegmentPrePortable     `!else if "${__SEGMENT__}" == PrePortable`
!define SegmentPreLaunch       `!else if "${__SEGMENT__}" == PreLaunch`
!define SegmentLaunchPrimary   `!else if "${__SEGMENT__}" == LaunchPrimary`
!define SegmentLaunchSecondary `!else if "${__SEGMENT__}" == LaunchSecondary`
!define SegmentPostLaunch      `!else if "${__SEGMENT__}" == PostLaunch`
!define SegmentPostPortable    `!else if "${__SEGMENT__}" == PostPortable`
!define SegmentPostLocal       `!else if "${__SEGMENT__}" == PostLocal`
!define SegmentPost            `!else if "${__SEGMENT__}" == Post`
!define SegmentCleanUp         `!else if "${__SEGMENT__}" == CleanUp`
!define SegmentUnload          `!else if "${__SEGMENT__}" == Unload`
!define SegmentEnd             `!endif`

; Call a segment-calling function {{{1
!macro CallHook _rev
	!if "${_rev}" == {
		!insertmacro Init
		Restart:
		!insertmacro Pre
		!insertmacro PreLocal
		!insertmacro PrePortable
		!insertmacro PreLaunch
	!else if "${_rev}" == }
		Restore:
		!insertmacro PostLaunch
		!insertmacro PostPortable
		!insertmacro PostLocal
		!insertmacro Post
		; Restart launcher if wasn't closed properly
		${If} $BADEXIT == true
			StrCpy $BADEXIT false
			Goto Restart
		${EndIf}
		TheEnd:
		!insertmacro CleanUp
		!insertmacro Unload
	!else if "${_rev}" == Launch
		${If} ${PrimaryInstance}
			!insertmacro LaunchPrimary
		${Else}
			!insertmacro LaunchSecondary
		${EndIf}
	!endif
!macroend
!define CallHook "!insertmacro CallHook"

; Run an action {{{1
!macro RunSegment _SEGMENT
	!verbose push 3
	!ifndef __FUNCTION__
		!define /redef __SEGMENT__ ${_SEGMENT}
	!else
		!define /redef __SEGMENT__ "${__FUNCTION__}"
	!endif
	!verbose pop

	!insertmacro SegmentOrder

	!verbose push 3
	!ifdef __SEGMENT__
		!undef __SEGMENT__
	!endif
	!verbose pop
!macroend
!define RunSegment `!insertmacro RunSegment "${__MACRO__}"`

; Include the segments {{{1
!include "${PAUL}\Segments\*.nsh"
