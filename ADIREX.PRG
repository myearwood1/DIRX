LPARAMETERS tcCursorName, tcFilePattern, tnFileAttribs, tnFlags, tnMaxRecursion, tcFieldList
local lcParms
lcParms = x5pitems("m.tcCursorName, m.tcFilePattern, m.tnFileAttribs, m.tnFlags, m.tnMaxRecursion, m.tcFieldList",pcount())
#include vfp2c.h
IF NOT vfp2c32()
    RETURN .F.
ENDIF
return eval("ADIREX(" + m.lcParms + ")")
