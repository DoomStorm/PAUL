; vim:ff=unix:gfn=Consolas\:h10:fdm=marker:fen:nowrap:ts=4:sts=0:sw=0:nu
;
; Use Vim for a better compatibility.

!macro BackupDirectoryCall _PATH
	!verbose push 3
	Push `${_PATH}`
	${CallArtificialFunction} BackupDirectory_
	!verbose pop
!macroend

!macro MoveDirectoryBackCall _PORTABLE _LOCAL
	!verbose push 3
	Push `${_PORTABLE}`
	Push `${_LOCAL}`
	${CallArtificialFunction} MoveDirectoryBack_
	!verbose pop
!macroend

!macro PreserveDirectoryCall _PORTABLE _LOCAL
	!verbose push 3
	Push `${_PORTABLE}`
	Push `${_LOCAL}`
	${CallArtificialFunction} PreserveDirectory_
	!verbose pop
!macroend

!macro RestoreDirectoryCall _PATH
	!verbose push 3
	Push `${_PATH}`
	${CallArtificialFunction} RestoreDirectory_
	!verbose pop
!macroend

!define BackupDirectory "!insertmacro BackupDirectoryCall" ;{{{1

!macro BackupDirectory_
	!verbose push 3
	Exch $0
	Push $1

	${GetParent} $0 $1
	${IfNot} ${IsDir} $1
		Delete $1 ; is it a file?
		CreateDirectory $1
		${WriteRuntimeData} RemoveDirectoryIfEmpty $1 true
	${EndIf}

	${IfNot} ${IsDir} $0.BackupBy$APPID
	${AndIf} ${IsDir} $0
		Delete $0.BackupBy$APPID ; is it a file?
		${MoveFiles} "/SILENT" $0 $0.BackupBy$APPID
	${EndIf}

	Pop $1
	Pop $0
	!verbose pop
!macroend

!define MoveDirectoryBack "!insertmacro MoveDirectoryBackCall" ;{{{1

!macro MoveDirectoryBack_
	!verbose push 3
	Exch $1 ; local
	Exch
	Exch $0 ; portable
	Exch

	CreateDirectory $1
	CopyFiles /SILENT $0\*.* $1

	Pop $1
	Pop $0
	!verbose pop
!macroend

!define PreserveDirectory "!insertmacro PreserveDirectoryCall" ;{{{1

!macro PreserveDirectory_
	!verbose push 3
	Exch $1 ; local
	Exch
	Exch $0 ; portable
	Exch

	${RemoveDirectory} $0
	CreateDirectory $0
	${MoveFiles} "/SILENT" $1\*.* $0

	Pop $1
	Pop $0
	!verbose pop
!macroend

!define RestoreDirectory "!insertmacro RestoreDirectoryCall" ;{{{1

!macro RestoreDirectory_
	!verbose push 3
	Exch $0
	Push $1
	Push $2

	${RemoveDirectory} $0
	${If} ${IsDir} $0.BackupBy$APPID
		${MoveFiles} "/SILENT" $0.BackupBy$APPID $0
	${EndIf}

	${GetParent} $0 $1
	${ReadRuntimeData} $2 RemoveDirectoryIfEmpty $1
	${If} $2 == true
		RMDir $1
	${EndIf}

	Pop $2
	Pop $1
	Pop $0
	!verbose pop
!macroend
