/* Copyright 2022 Wirepas Ltd. All Rights Reserved.
 *
 * See file LICENSE.txt for full license details.
 *
 */

SEARCH_DIR(.)

/* Flash is 512 kB and RAM is 64 kB
 *   - 40 kB of Flash is reserved by default for the application. But it is
 *     not a hard limit and could be increased. As application and scratchpad area
 *     are shared by default, if the application is too big, OTAP may be affected.
 *     Please see the Wirepas documentation about OTAP for more details
 *   - Up to 16 kB (minus 8 bytes) of RAM can be used by the app. By default
 *     12 kB (minus 8 bytes), but with custom linker script that can be
 *     increased up to 16 kB by decreasing the origin (down to 0x2000C000)
 *     and increasing length (up to 16K - 8).
 */
MEMORY
{
  FLASH (rx)      : ORIGIN = 0x08044000, LENGTH = 40K /* See above note before changing length */
  RAM (rwx)       : ORIGIN = 0x2000D000, LENGTH = 12K - 8
  INVALID (rwx)   : ORIGIN = 0xFFFFFFFF, LENGTH = 0 /* Sanity check */
}

SECTIONS
{
    .text :
    {
        __text_start__ = .;
        KEEP(*(.entrypoint))
        KEEP(*(.app_header))
        *(.text.*)
        *(.text)
        *(.glue_7)
        *(.glue_7t)
        *(.vfp11_veneer)
        *(.v4_bx)
        *(.rodata.*)
        *(.rodata)
        *(.rodata1)
        . = ALIGN(8);
        __text_end__ = .;
    } >FLASH

    __data_src_start__ = .;

    .rtt (NOLOAD):
    {
        /* Force placing _SEGGER_RTT control block here, if RTT tracing is on */
        *(.rtt_cb_section)
        . = ALIGN(8);
    } >RAM

    .data :
    {
        __data_start__ = .;
        *(.ramtext)
        *(.data.*)
        *(.data)
        *(.data1)
        . = ALIGN(8);
        __data_end__ = .;
    } >RAM AT >FLASH

    __rom_end__ = __data_src_start__ + SIZEOF(.data);

    /* Total size includes persistent data, when implemented */
    __total_size_bytes__ = __rom_end__ - __text_start__;

    .bss :
    {
        __bss_start__ = .;
        *(.bss.*)
        *(.bss)
        *(COMMON)
        . = ALIGN(8);
        __bss_end__ = .;
    } >RAM

    /* Symbols for the RAM */
    __ram_start__ = ORIGIN(RAM);
    __ram_end__ = ORIGIN(RAM) + LENGTH(RAM);

    .invalid :
    {
        *(.init)
        *(.fini)
        *(.preinit_array)
        *(.init_array)
        *(.fini_array)
        *(.ctors)
        *(.dtors)
        *(.jcr)
        *(.eh_frame)
        *(.eh_frame_hdr)
        *(.heap*)
        *(.tbss)
        *(.tdata)
        *(.tdata1)
        *(.got)
        *(.got.plt)
        *(.igot.plt)
        *(.iplt)
        *(.rel.dyn)
        *(.rel.iplt)
    } >INVALID  /* Linking fails if any of these sections have contents. */

    /* C++ exception unwinding information is silently discarded. */
    /DISCARD/ :
    {
        *(.ARM.extab)
        *(.ARM.exidx)
    }
}
