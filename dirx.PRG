LPARAMETERS m.tuDestinationName, m.tcPatterns, m.tcAttributes, m.tlRecurse, m.tlExactAttrib
*This extends the original DIR command.
*It uses ADirEx.FLL for speed and functionality
*This routine adds support for a custom keyword, VFPPATH, 
*so that it can scan all files in SET("PATH")
*It creates a cursor or an array.

*This routine now takes multiple filespecs separated by semis.

*The following command will find all _* lb? and fr? in the vfp Search Path
*as well as the .tmp files in a tempfolder on C:
*DirX("c_tempfiles","VFPPATH\_*.LB?;VFPPATH\_*.FR?;c:\tempfolder\*.tmp")

LOCAL lcOnError, llError, lnSelect, lnReturn, llExactAttrib, ;
	lcTempCursorFinal, lcPatterns, lcPattern, laPatterns[1], ;
	lnAttributes, lcAttributes, laPaths[1], lnFlags, lcDrive, lnX, lnY

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

	lnFlags = ;
		GetADirExDestType('Cursor')+;
		GetADirExVarious('FullPath')+;
		IIF(m.tlRecurse,GetADirExVarious('Recurse'),0)+;
		IIF(m.llExactAttrib,GetADirExFilterFlag('Exact'),0)

	lcTempCursorFinal = SYS(2015)
	select 0
	CREATE CURSOR (m.lcTempCursorFinal) (filename m, creationtime T, accesstime T, writetime T, filesize N(20,0), cfileattribs c(10), folder m, fullname m, fileext c(10), irecords i, recnum i)

	lcPatterns = iif(vartype(m.tcPatterns) = "C", m.tcPatterns, "")

	lcPatterns = chrtran(m.lcPatterns, chr(13)+chr(10), "")
	
	lcPatterns = chrtran(lcPatterns, ';', chr(13))

*See if there are more than one Pattern separated by ;

	lnPatterns = alines(laPatterns,m.lcPatterns)
	for m.lnY = 1 to m.lnPatterns

		lcPattern = upper(justfname(laPatterns[m.lnY]))
		laPatterns[m.lnY] = strtran(upper(m.laPatterns[m.lnY]),"VFPPATH",SET('Path'))
		laPatterns[m.lnY] = strtran(upper(m.laPatterns[m.lnY]),m.lcPattern,"")
		laPatterns[m.lnY] = chrtran(laPatterns[m.lnY],';',chr(13))

		*Process vfppath expansion or not
		FOR m.lnX = 1 to alines(laPaths,laPatterns[m.lnY])

			if ":"$laPaths[m.lnX] or "$"$laPaths[m.lnX] or left(laPaths[m.lnx],1)="\"
				laPaths[m.lnX] = addbs(laPaths[m.lnX]) + m.lcPattern
			else
				laPaths[m.lnX] = fullpath(curdir()) + addbs(laPaths[m.lnX]) + m.lcPattern
			endif

			lnReturn = m.lnReturn + ;
				adirex(;
					m.lcTempCursorFinal,;
					laPaths[m.lnX],;
					m.lcAttributes,;
					m.lnFlags,;
					0,; && default to all levels if recursing.
					'filename, creationtime, accesstime, writetime, filesize, cfileattribs'; && grab only these columns
				)
		ENDFOR m.lnX

	ENDFOR m.lnY

	replace all ;
		fullname with alltrim(filename),;
		folder with addbs(justpath(filename)),;
		filename with justfname(filename), ;
		fileext with UPPER(justext(filename)), ;
		recnum with recno()

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
