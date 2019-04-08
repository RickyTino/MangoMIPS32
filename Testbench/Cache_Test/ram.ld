MEMORY
{       
    ram    : ORIGIN = 0xBFC00000, LENGTH = 0x00001000
}
 
SECTIONS
{
    .text :
    {
        *(.text)
    } > ram
 
    .data :
    {
        *(.data)
    } > ram
 
    .bss :
    {
        *(.bss)
    } > ram

    .reginfo :
    {
        *(.reginfo)
    } > ram
}
 
ENTRY (_start)

