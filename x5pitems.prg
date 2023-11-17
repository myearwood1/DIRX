*
*  X5PITEMS.PRG
*  "P"arse "ITEMS" from a comma-delimited list
*
*  Receives a single string containing a comma-delimited
*  list of items, RETURNs a string containing the
*  leftmost portion of the string containing the passed
*  number of items, including the comma delimiters --
*  the passed string is updated to parse off the final
*  number of comma-delimited items that EXCEED the
*  passed desired number of items.
*
*  The actual items in the list are not modified in
*  any way (no TRIM(), no UPPER(), etc.).
*
*  RETURNs SPACE(0) if parameters are passed incorrectly.
*
*  Copyright (c) 2003-2005 Visionpace   All Rights Reserved
*                17501 East 40 Hwy., Suite 218
*                Independence, MO 64055
*                816-350-7900
*                http://www.visionpace.com
*                http://vmpdiscussion.visionpace.com
*  Author:  Mike Yearwood, Mike Potjer, and Drew Speedie
*
*
*  While this utility can be used to parse any comma-
*  delimited string in the intended manner, its primary
*  intended usage is to facilitate passing an LPARAMETERS
*  statement to a callback or .PRG without turning
*  un-passed parameters into explicit parameters when
*  making that call.
*
*  For example, consider the following pseude-code in
*  methods of a subclass/instance and its parent class
*  method:
*
*    *  instance/subclass method
*    LPARAMETERS One, Two, Three
*    IF NOT DODEFAULT(One, Two, Three)
*      RETURN .F.
*    ENDIF
*    ... processing here
*    RETURN .T.
*
*    *  parent class method
*    LPARAMETERS One, Two, Three
*    IF PCOUNT() > 2
*      *  3rd parameter is optional - do something here
*    ENDIF
*    ...processing here
*    RETURN .T.
*
*  The instance/subclass method receives three (3) parameters
*  and then passes them to the callback.  However, when
*  the parent class method checks the PCOUNT(), it
*  erroneously determines that it received the third
*  parameter explicitly whenever the instance/subclass
*  was passed only 2 parameters by the code that called
*  it.
*
*  One remedy for this scenario is a conditional callback:
*
*    *  instance/subclass method
*    LPARAMETERS One, Two, Three
*    IF PCOUNT() > 2
*      IF NOT DODEFAULT(One, Two, Three)
*        RETURN .F.
*      ENDIF
*    ELSE
*      IF NOT DODEFAULT(One, Two)
*        RETURN .F.
*      ENDIF
*    ENDIF   
*    ... processing here
*    RETURN .T.
*
*  but this gets pretty ungainly when there are several
*  optional parameters.
*
*  So this .PRG can be called to eliminate the extra
*  optional/unpassed parameters from the list via a
*  single call here, whereupon the resulting string 
*  can be passed to the callback without passing the 
*  optional parameters explicitly, as demonstrated in 
*  the Usage examples below.
*
*  Usage:
*
*    LPARAMETERS One, Two, Three, Four, Five
*    LOCAL lcParameters
*    lcParameters = X5PITEMS("One, Two, @Three, @Four, Five", PCOUNT())
*    IF NOT DODEFAULT(&lcParameters.)
*      RETURN .F.
*    ENDIF
*    *  ... processing here
*    RETURN .T.
*
*  Optionally include a test for a blank value RETURNed
*  from this PRG:
*
*    LPARAMETERS One, Two, Three, Four, Five
*    LOCAL lcParameters
*    lcParameters = X5PITEMS("One, Two, @Three, @Four, Five", PCOUNT())
*    IF EMPTY(lcParameters) OR NOT DODEFAULT(&lcParameters.)
*      RETURN .F.
*    ENDIF
*    *  ... processing here
*    RETURN .T.
*
* Mike Yearwood pointed out the following as a tighter, faster way to do the above:
*
*    IF NOT ;
*          EVALUATE(;
*           "DODEFAULT(" ;
*             + X5PITEMS(;
*               "One, Two, @Three, @Four, Five", ;
*               PCOUNT();
*             ) ; && close for the X5PITEMS
*           + ")" ; && close for the DODEFAULT
*          ) && close for the EVALUATE
*      RETURN .F.
*    ENDIF
*
* The above is formatted so that you can see all the parts.  As it takes only
* one (1) line of code, no extra variables and most importantly, no macro
* substitution (which is slower), he prefers to do that instead.
*
*  Examples:
*    XXDTES("XXFWNTBO.VCX", "X5PITEMS", "ctrBusinessObjectManager", "SQLExecute")
*    XXDTES("XXFWNTBO.VCX", "X5PITEMS", "ctrBusinessObject", "SQLExecute")
*    XXDTES("XXFWNTDS.VCX", "X5PITEMS", "ctrDataSource", "SQLExecute")
*    XXDTES("XXFWNTDS.VCX", "X5PITEMS", "cusDataSourceBehavior", "SQLExecute")
*  
*  lParameters
*    tcString (R) List of comma delimited items/values from 
*                   which to parse tnItems items, starting
*                   from the left of the string 
*     tnItems (R) Number of items to extract from tcString
*                  
LPARAMETERS tcString, tnItems, tlConditionalLeadingComma

IF (NOT VARTYPE(m.tcString) = "C") OR EMPTY(m.tcString)
  ASSERT .F. MESSAGE "The first tcString parameter must be a string consisting of a comma delimited list of items."
  RETURN SPACE(0)
ENDIF

IF (NOT VARTYPE(m.tnItems) = "N") OR (m.tnItems < 0)
  ASSERT .F. MESSAGE "The second tnItems parameter must be a number representing the desired number of items."
  RETURN SPACE(0)
ENDIF

if pcount()=3 and type("m.tlConditionalLeadingComma")<>"L"
  ASSERT .F. MESSAGE "The third tlConditionalLeadingComma parameter must be a logical .T./.F."
  RETURN SPACE(0)
endif

IF m.tnItems = 0
  *
  *  m.tnItems passed explicitly as 0/zero, so all
  *  we have to do is RETURN empty/blank text
  *
  RETURN SPACE(0)
ENDIF

LOCAL lcString, lcRetVal

*
*  ensure a trailing comma, for easy parsing below
*
IF NOT RIGHTC(m.tcString, 1) = ","
  m.lcString = m.tcString + ","
ELSE
  m.lcString = m.tcString
ENDIF

IF m.tnItems > OCCURS(",", m.lcString)
  ASSERT .F. MESSAGE ;
       "The tnItems parameter was passed as a number greater than the number of items in tcString"
  RETURN SPACE(0)
ENDIF

*
*  parse the m.tnItems number of items from the
*  comma-delimited m.tcString string 
*
m.lcRetval = LEFTC(m.lcString, AT_C(",", m.lcString, m.tnItems) - 1)

if pcount()=3 and m.tlConditionalLeadingComma AND !empty(alltrim(m.lcRetVal))
	m.lcRetVal = "," + m.lcRetVal
endif

RETURN m.lcRetVal
