; vim:ff=unix:gfn=Consolas\:h10:fdm=marker:fen:nowrap:ts=4:sts=0:sw=0:nu
;
; Use Vim for a better compatibility.

!macro BackupFileCall _FILE
	!verbose push 3
	Push `${_FILE}`
	${CallArtificialFunction} BackupFile_
	!verbose pop
!macroend

!macro MoveFileBackCall _PORTABLE _LOCAL
	!verbose push 3
	Push `${_PORTABLE}`
	Push `${_LOCAL}`
	${CallArtificialFunction} MoveFileBack_
	!verbose pop
!macroend

!macro PreserveFileCall _PORTABLE _LOCAL
	!verbose push 3
	Push `${_PORTABLE}`
	Push `${_LOCAL}`
	${CallArtificialFunction} PreserveFile_
	!verbose pop
!macroend

!macro RestoreFileCall _FILE
	!verbose push 3
	Push `${_FILE}`
	${CallArtificialFunction} RestoreFile_
	!verbose pop
!macroend

!define BackupFile "!insertmacro BackupFileCall" ;{{{1

!macro BackupFile_
	!verbose push 3
	Exch $0
	Push $1

	${GetParent} $0 $1
	${IfNot} ${IsDir} $1
		CreateDirectory $1
		${WriteRuntimeData} RemoveDirectoryIfEmpty $1 true
	${EndIf}

	${IfNot} ${IsFile} $0.BackupBy$APPID
	${AndIf} ${IsFile} $0
		${RemoveDirectory} $0.BackupBy$APPID ; is it a directory?
		${MoveFiles} "/SILENT" $0 $0.BackupBy$APPID
	${EndIf}

	Pop $1
	Pop $0
	!verbose pop
!macroend

!define MoveFileBack "!insertmacro MoveFileBackCall" ;{{{1

!macro MoveFileBack_
	!verbose push 3
	Exch $1 ; local
	Exch
	Exch $0 ; portable
	Exch

	CopyFiles /SILENT $0 $1

	Pop $1
	Pop $0
	!verbose pop
!macroend

!define PreserveFile "!insertmacro PreserveFileCall" ;{{{1

!macro PreserveFile_
	!verbose push 3
	Exch $1 ; local
	Exch
	Exch $0 ; portable
	Exch
	Push $2

	Delete $0
	${GetParent} $0 $2
	CreateDirectory $2
	${MoveFiles} "/SILENT" $1 $0

	Pop $2
	Pop $1
	Pop $0
	!verbose pop
!macroend

!define RestoreFile "!insertmacro RestoreFileCall" ;{{{1

!macro RestoreFile_
	!verbose push 3
	Exch $0
	Push $1
	Push $2

	Delete $0
	${If} ${IsFile} $0.BackupBy$APPID
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
