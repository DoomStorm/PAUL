; Require at least NSIS 3.0
!searchparse /noerrors "${NSIS_VERSION}" v _RLNSIS_TEMP b _RLNSIS_TEMP
!searchparse /noerrors "${_RLNSIS_TEMP}" "" _RLNSIS_TEMP - _RLNSIS_TEMP
!searchparse /noerrors "${_RLNSIS_TEMP}" "" _RLNSIS_TEMP . _RLNSIS_TEMP
!if "${_RLNSIS_TEMP}" < 3
	!searchparse /noerrors "${NSIS_VERSION}" v _RLNSIS_TEMP b _RLNSIS_TEMP
	!searchparse /noerrors "${_RLNSIS_TEMP}" "" _RLNSIS_TEMP - _RLNSIS_TEMP
	!error "You only have NSIS ${_RLNSIS_TEMP}, but NSIS 3.0 or later is required for proper script support. Please upgrade to NSIS 3.0 or later and try again."
!endif
!undef _RLNSIS_TEMP
