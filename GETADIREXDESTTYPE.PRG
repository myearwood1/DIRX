#INCLUDE vfp2c.h
LPARAMETERS tcDestType
LOCAL lcDestType
lcDestType = iif(vartype(tcDestType)="C",upper(m.tcDestType),"")
DO CASE
    CASE m.lcDestType = "ARRAY"
        RETURN ADIREX_DEST_ARRAY
    CASE m.lcDestType = "CURSOR"
        RETURN ADIREX_DEST_CURSOR
    CASE m.lcDestType = "CALLBACK"
        RETURN ADIREX_DEST_CALLBACK
    OTHERWISE
        RETURN -1  && Invalid destination type
ENDCASE
