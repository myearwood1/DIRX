LPARAMETERS m.tuDestinationName, m.tcPattern, m.tcAttributes, m.tlRecurse, m.tlExactAttrib

*This extends the original DIR command.
*It uses ADirEx.FLL for speed and functionality
*This routine adds support for a custom keyword, VFPPATH, 
*so that it can scan all files in SET("PATH")
*It creates a cursor or an array.

LOCAL lcOnError, llError, lnSelect, lnReturn, llExactAttrib, ;
	lcTempCursorFinal, lcPattern, lnAttributes, lcAttributes, lnReturn, ;
	laPaths[1], lnFlags, lcDrive

lnSelect = select()

lcOnError = ON("ERROR")

ON ERROR llError = .T.

lnReturn = 0

do while NOT m.llError

	llExactAttrib = m.tlExactAttrib
	lcAttributes = IIF(vartype(m.tcAttributes)='C',upper(m.tcAttributes),'')
	IF EMPTY(m.lcAttributes)
	    lcAttributes = "RA"
	ENDIF

	lcPattern = iif(vartype(m.tcPattern) = "C",m.tcPattern,"")

	if 'VFPPATH'$m.lcPattern
		lnMax = ALINES(laPaths, strtran(';' + SET('Path'),';',chr(13)))
		lcPattern = strtran(m.lcPattern,"VFPPATH","")
		lcLead = addbs(justpath(m.lcPattern))
		lcPattern = justfname(m.lcPattern)
		if "$" $ m.lcLead
			lcDrive = substr(m.lcLead,1,at("$",m.lcLead))
			lcLead = substr(m.lcLead,at("$",m.lcLead)+1)
		else
			lcDrive = ""
		endif
	else
		lnMax=1
		laPaths[m.lnMax]=justpath(m.lcPattern)
		lcPattern = justfname(m.lcPattern)
		lcLead=""
		lcDrive=""
	endif

	lnFlags = ;
		GetADirExDestType('Cursor')+;
		GetADirExVarious('FullPath')+;
		IIF(m.tlRecurse,GetADirExVarious('Recurse'),0)+;
		IIF(m.llExactAttrib,GetADirExFilterFlag('Exact'),0)

	lcTempCursorFinal = SYS(2015)
	select 0
	CREATE CURSOR (m.lcTempCursorFinal) (filename m, writetime T, filesize N(20,0), cfileattribs c(10), folder m, fullname m, fileext c(10), irecords i)

	FOR m.xj = 1 to m.lnMax
		lnReturn = m.lnReturn + ;
			adirex(;
				m.lcTempCursorFinal,;
				iif("\"$laPaths[m.xj],m.lcDrive,m.lcDrive + m.lcLead) + addbs(laPaths[m.xj]) + m.lcPattern,;
				m.lcAttributes,;
				m.lnFlags,;
				0,; && default to all levels if recursing.
				'filename, writetime, filesize, cfileattribs'; && grab only these columns
			)
	ENDFOR

	replace all ;
		fullname with alltrim(filename),;
		folder with addbs(justpath(filename)),;
		filename with justfname(filename), ;
		fileext with UPPER(justext(filename))

	DO CASE
    CASE type("alen(m.tuDestinationName)") = 'N' && Array
    	SELECT * from (m.lcTempCursorFinal) INTO ARRAY &tuDestinationName
	OTHERWISE
		USE IN (SELECT(m.tuDestinationName))
		USE dbf(m.lcTempCursorFinal) AGAIN ALIAS (m.tuDestinationName) IN 0
	endcase

	lnReturn = reccount(m.lcTempCursorFinal)
	use in (select(m.lcTempCursorFinal))

	EXIT

enddo

on error &lcOnError.

if m.llError or x2IsArray(@tuDestinationName)
	SELECT (m.lnSelect)
else
	select (m.tuDestinationName)
endif

RETURN m.lnReturn
