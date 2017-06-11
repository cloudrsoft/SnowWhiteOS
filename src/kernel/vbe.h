#ifndef VBE_H_INCLUDED
#define VBE_H_INCLUDED

#include "types.h"

#define VBE_MODEINFOBLOCKADDRESS        0x7E00

#pragma pack( push, 1 )

typedef struct VBEInfoBlockStruct
{
    u16 wModeAttribute;
    u8 bWinAAttribute;
    u8 bWinBAttribute;
    u16 wWinGranulity;
    u16 wWinSize;
    u16 wWinASegment;
    u16 wWinBSegment;
    u32 dwWinFuncPtr;
    u16 wu8sPerScanLine;

    u16 wXResolution;
    u16 wYResolution;
    u8 bXCharSize;
    u8 bYCharSize;
    u8 bNumberOfPlane;
    u8 bBitsPerPixel;
    u8 bNumberOfBanks;
    u8 bMemoryModel;
    u8 bBankSize;
    u8 bNumberOfImagePages;
    u8 bReserved;

    u8 bRedMaskSize;
    u8 bRedFieldPosition;
    u8 bGreenMaskSize;
    u8 bGreenFieldPosition;
    u8 bBlueMaskSize;
    u8 bBlueFieldPosition;
    u8 bReservedMaskSize;
    u8 bReservedFieldPosition;
    u8 bDirectColorModeInfo;

    u32 dwPhysicalBasePointer;
    u32 dwReserved1;
    u32 dwReserved2;

    u16 wLinearu8sPerScanLine;
    u8 bBankNumberOfImagePages;
    u8 bLinearNumberOfImagePages;
    u8 bLinearRedMaskSize;
    u8 bLinearRedFieldPosition;
    u8 bLinearGreenMaskSize;
    u8 bLinearGreenFieldPosition;
    u8 bLinearBlueMaskSize;
    u8 bLinearBlueFieldPosition;
    u8 bLinearReservedMaskSize;
    u8 bLinearReservedFieldPosition;
    u32 dwMaxPixelClock;
    u8 vbReserved[ 189 ];
} VBEMODEINFOBLOCK;

#pragma pack( pop )

VBEMODEINFOBLOCK* GetVBEModeInfoBlock( void );

#endif // VBE_H_INCLUDED
