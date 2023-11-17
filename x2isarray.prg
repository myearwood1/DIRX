* 
*  X2IsArray.PRG
*  RETURNs a logical value indicating whether the
*  variable PASSED BY REFERENCE or the passed Object, PropertyName
*  is an array.
*
*  Author:  Drew Speedie  
*           Special thanks to Mike Yearwood and Chris Bohling
*           mJindrova from Tek-Tips
*
*  USAGE
*  =====================================
*  IF X2IsArray(@m.SomeVariable)
*    ...
*  ENDIF
*  IF X2IsArray(SomeObject,"SomeProperty")
*    ...
*  ENDIF
* 
*  lParameters
*   tuVariable (R) Memory variable to be checked, 
*                    passed here BY REFERENCE
*                    -OR-
*                  Object whose tcProperty is to be
*                    checked
*   tcProperty (O) If tuVariable is passed as an object
*                    reference, this parameter is REQUIRED,
*                    and indicates the property of the
*                    tuVariable object that is checked for
*                    being an array
*                  If tuVariable is passed as a memory
*                    variable, DO NOT PASS THIS PARAMETER,
*                    or this routine will RETURN .F.
*
#IF VAL(LEFT(SUBSTR(VERSION(),AT("FOXPRO",UPPER(VERSION()))+7),3))<3
	#DEFINE LPARAMETERS PARAMETERS
#ENDIF
LPARAMETERS tuVariable, tcPropertyName
EXTERNAL ARRAY tuVariable
#IF VAL(LEFT(SUBSTR(VERSION(),AT("FOXPRO",UPPER(VERSION()))+7),3))<9
	RETURN IIF(EMPTY(m.tcPropertyName),TYPE("m.tuVariable[1]")#"U",TYPE("ALEN(m.tuVariable."+m.tcPropertyName+")")="N")
#ELSE
	RETURN IIF(EMPTY(m.tcPropertyName),TYPE("m.tuVariable",1)="A",TYPE("m.tuVariable."+m.tcPropertyName,1)="A")
#ENDIF

*The following has been deprecated in favor of the above. 
*Type of an array's first element is not U works
*type(alen(object.property)) also works.

* 
*  X2IsArray.PRG
*  RETURNs a logical value indicating whether the
*  variable PASSED BY REFERENCE or the passed Object.Property
*  is an array.
*
*  Copyright (c) 2004-2005 Visionpace   All Rights Reserved
*                17501 East 40 Hwy., Suite 218
*                Independence, MO 64055
*                816-350-7900 
*                http://www.visionpace.com
*                http://vmpdiscussion.visionpace.com
*  Author:  Drew Speedie  
*           Special thanks to Mike Yearwood and Chris Bohling
*           mJindrova and Chris Miller from Tek-Tips
*
*  USAGE
*  =====================================
*  IF X2IsArray(@m.SomeVariable)
*    ...
*  ENDIF
*  IF X2IsArray(SomeObject,"SomeProperty")
*    ...
*  ENDIF
* 
*
*  lParameters
*   tuVariable (R) Memory variable to be checked, 
*                    passed here BY REFERENCE
*                    -OR-
*                  Object whose tcProperty is to be
*                    checked
*   tcProperty (O) If tuVariable is passed as an object
*                    reference, this parameter is REQUIRED,
*                    and indicates the property of the
*                    tuVariable object that is checked for
*                    being an array
*                  If tuVariable is passed as a memory
*                    variable, DO NOT PASS THIS PARAMETER,
*                    or this routine will RETURN .F.
*


LOCAL llRetVal

DO CASE
  #if version(5)>=600
  ******************************************************
  CASE PCOUNT() = 1 AND NOT VARTYPE(m.tuVariable) = "O"
  ******************************************************
    #if version(5)>=900
      llRetVal = TYPE("m.tuVariable",1) = "A" 
    #else
      llRetVal = TYPE("ALEN(m.tuVariable)") = "N"
    #endif
  #endif
  ******************************************************
  CASE PCOUNT() = 1 AND TYPE("ALEN(m.tuVariable)") = "N" 
  ******************************************************
    llRetVal = .t.
  ******************************************************
  CASE VARTYPE(m.tuVariable) = "O" ;
       AND VARTYPE(m.tcProperty) = "C" ;
       AND NOT EMPTY(m.tcProperty)
  ******************************************************
    llRetVal = TYPE("ALEN(m.tuVariable." + m.tcProperty + ")") = "N"
  ******************************************************
  OTHERWISE 
  ******************************************************
    *
    *  you apparently haven't passed the parameters
    *  properly -- we could have RETURNed .NULL. here,
    *  but then every time you call X2IsArray(), you
    *  would have to check for .NULL, .T., and .F. 
    *  rather than just .T. or .F., so it's up to you
    *  to pass the parameters correctly
    *    Roses are red
    *    Violets are blue
    *    To pass parms correctly
    *    Is all up to you
    *
    llRetVal = .f.
ENDCASE

RETURN m.llRetVal
 