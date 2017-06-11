OUTPUT_FORMAT("binary")
ENTRY(start)
SECTIONS
{
    g_localApicAddr = 0x00006000;
    g_activeCpuCount = 0x00006008;
    . = 1M;

    .text 0x0000000000100000:
    {
        *(.text)
    }

    .data :
    {
        *(.data)
    }

    .bss :
    {
        __bss_start = .;
        *(.bss)
        __bss_end = .;
    }
}
