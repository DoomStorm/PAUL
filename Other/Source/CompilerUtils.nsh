; vim:ff=unix:gfn=Consolas\:h10:fdm=marker:fen:nowrap:ts=4:sts=0:sw=0:nu
;
; Use Vim for a better compatibility.

; Insert a macro if it was exist
!macro !insertifmacrodef _NAME
	!ifmacrodef ${_NAME}
		!insertmacro ${_NAME}
	!endif
!macroend
!define !insertifmacrodef "!insertmacro !insertifmacrodef"
