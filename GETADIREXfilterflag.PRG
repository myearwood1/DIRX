LPARAMETERS tcFilterType
#include vfp2c.h
LOCAL lcFilterType
lcFilterType = IIF(VARTYPE(m.tcFilterType)='C',upper(m.tcFilterType),'')
DO CASE
    CASE m.lcFilterType = "ALL"
        RETURN ADIREX_FILTER_ALL
    CASE m.lcFilterType = "NONE"
        RETURN ADIREX_FILTER_NONE
    CASE m.lcFilterType = "EXACT"
        RETURN ADIREX_FILTER_EXACT
    CASE m.lcFilterType = "ANY"
        RETURN 0  && Default filter flag (no filter)
    OTHERWISE
        RETURN -1  && Invalid filter type
ENDCASE
