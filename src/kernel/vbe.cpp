#include "vbe.h"

static VBEMODEINFOBLOCK* gs_pstVBEModeInfo =
        ( VBEMODEINFOBLOCK* ) VBE_MODEINFOBLOCKADDRESS;

inline VBEMODEINFOBLOCK* GetVBEModeInfoBlock()
{
    return gs_pstVBEModeInfo;
}
