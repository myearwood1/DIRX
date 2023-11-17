LPARAMETERS m.tcFunctionType
#include vfp2c.h
LOCAL lcFunctionType
lcFunctionType=iif(vartype(m.tcFunctionType)<>"C","",UPPER(m.tcFunctionType))
DO CASE
    CASE m.lcFunctionType = "RECURSE"
        RETURN ADIREX_RECURSE
    CASE m.lcFunctionType = "FULLPATH"
        RETURN ADIREX_FULLPATH
	CASE m.lcFunctionType = "STRING_FILEATTRIBUTES"
		RETURN ADIREX_STRING_FILEATTRIBUTES
    CASE m.lcFunctionType = "DISABLE_FSREDIRECTION"
        RETURN ADIREX_DISABLE_FSREDIRECTION
    OTHERWISE
        RETURN -1  && Invalid filter type
ENDCASE
