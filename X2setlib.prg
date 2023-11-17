* Program: X2SetLib.PRG

* SET LIBRARY TO the passed library 

* RETURNs a logical value indicating success

* Copyright (c) 1997-2013 Visionpace   All Rights Reserved
*               17501 East 40 Hwy., Suite 218
*               Independence, MO 64055
*               816-350-7900 
*               http://www.visionpace.com
*               http://vmpdiscussion.visionpace.com
* Author:  Tom DeMay and Drew Speedie

*  Usage:
*    IF X2SETLIB('FoxTools')
*      * FoxTools.FLL was successfully installed
*    ELSE
*      * FoxTools.FLL could not be successfully installed
*      DO X3MsgSvc.Prg WITH 'No FoxTools.FLL'
*      * or:
*      * DO x3winmsg WITH 'Cannot continue without FoxTools.FLL'
*      quit
*    ENDIF

* Parameters:
*     tcLibrary (R) Name of library (.FLL/.PLB) to SET LIBRARY TO
*                   NOTE:  if you only pass the filename, no extension
*                          the '.FLL' or '.PLB' extension is assumed,
*                          based on the value of _DOS/_WINDOWS      
PARAMETERS tcLibrary
PRIVATE pcOnError, plSuccess

IF (TYPE('m.tcLibrary') = 'C') AND (NOT EMPTY(m.tcLibrary))
  tcLibrary = UPPER(ALLTRIM(m.tcLibrary))
  IF '.' $ m.tcLibrary
  ELSE
    IF _DOS
      tcLibrary = m.tcLibrary + '.PLB'
    ELSE
      tcLibrary = m.tcLibrary + '.FLL'
    ENDIF
  ENDIF
ELSE
  RETURN .F.
ENDIF

IF m.tcLibrary $ SET('LIBRARY')
  * tcLibrary is already loaded, no need to continue
  RETURN .T.
ENDIF

pcOnError = ON('ERROR')
plSuccess = .T.
ON ERROR plSuccess = .F.

DO CASE
  CASE FILE(m.tcLibrary)
    SET LIBRARY TO (m.tcLibrary) ADDITIVE

  CASE FILE(SYS(2004) + m.tcLibrary)
    * tcLibrary is in the directory where
    * FoxPro is installed (for an .EXE-
    * distributed app in Visual FoxPro, 
    * this is where VFP5.DLL/VFP6EnU.DLL
    * are located)
    SET LIBRARY TO (SYS(2004) + m.tcLibrary) ADDITIVE

  CASE FILE(LEFT(SYS(16 ,0), RAT('\', SYS(16, 0))) + m.tcLibrary)
    * An .EXE is running in VFP, and the library
    * is located in the directory where the
    * .EXE is located 
    SET LIBRARY TO (LEFT(SYS(16, 0), RAT('\', SYS(16, 0))) + m.tcLibrary) ADDITIVE

  OTHERWISE
    * Assume the library is in the path
    SET LIBRARY TO (m.tcLibrary) ADDITIVE
ENDCASE

ON ERROR &pcOnError.

RETURN m.plSuccess
