ENTRY(_start)

SECTIONS
{
  . = 0x00000000;

  .text : ALIGN(4)
  {
    *(.text .text.*)
  }

  .rodata : ALIGN(4)
  {
    *(.rodata .rodata.*)
  }

  .data : ALIGN(4)
  {
    *(.data .data.*)
  }

  .bss : ALIGN(4)
  {
    *(.bss .bss.* COMMON)
  }

  /DISCARD/ :
  {
    *(.comment)
    *(.note*)
    *(.eh_frame*)
  }
}

