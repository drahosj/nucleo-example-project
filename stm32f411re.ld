/**

    Linker Script for STM32F411RE
    
    
Copyright (c) 2014 Jake Drahos <drahos@iastate.edu>
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this 
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation and/or 
other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors 
may be used to endorse or promote products derived from this software without 
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR:w

ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON 
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
    This script is intended to work with STMicroelectronics' setup files
    provided in STM32CubeF4.
    
* Uses the following input sections:
    .isr_vector
    
    .text
    .text*
    .init
    .eh_frame
    
    .data
    
    .bss
    .bss*
    
    .rodata
    .rodata*
    
    .init_array
    .init_array*
    
    .fini_array
    .fini_array*
    
    .ARM
    .ARM.exidx
    
    .jcr

* Defines the following globals (used by the setup file):

    _estack
    _sdata __data_start__
    _edata __data_end__
    
    _sbss __bss_start__
    _ebss __bss_end__
    
    _sidata

/* Entry */

ENTRY(Reset_Handler)

MEMORY 
{
    FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 512K
    RAM (rwx)  : ORIGIN = 0x20000000, LENGTH = 128K
}

_estack = 0x2001FFFF;

SECTIONS
{
    /* required by startup */
    .isr_vector :
    {
        . = ALIGN(4);
        *(.isr_vector)
        . = ALIGN(4);
    } >FLASH
    
    /* .text, .data, .bss */
    .text :
    {
        . = ALIGN(4);
        *(.text)
        *(.text*)
        *(.init)
        *(.fini)
        *(.eh_frame)
        . = ALIGN(4);
    } >FLASH
    .data : 
    {
        . = ALIGN(4);
        _sdata = .; /*required by startup*/
        __data_start__ = _sdata;
        *(.data)
        *(.data*)
        _edata = .; /*required by startup*/
        __data_end__ = _edata;
        . = ALIGN(4);
    } >RAM AT>FLASH /*"virtually" in RAM, loaded "at" flash*/
    .bss : 
    {
        . = ALIGN(4);
        _sbss = .; /*required by startup*/
        __bss_start__ = _sbss;
        *(.bss)
        *(.bss*)
        _ebss = .; /*required by startup*/
        __bss_end__ = _ebss;
        . = ALIGN(4);
    } >RAM
    
    /* .rodata (read only goes in FLASH) */
    .rodata :
    {
        . = ALIGN(4);
        *(.rodata)
        *(.rodata*)
        . = ALIGN(4);
    } >FLASH
    
    /* Additional sections that get spat out by the compiler */
    .init_array :
    {
        . = ALIGN(4);
        *(SORT(.init_array.*)) /*Sorted eg. .init_array.0000 */
        *(.init_array*)
        . = ALIGN(4);
    } >FLASH
    .fini_array :
    {
        . = ALIGN(4);
        *(SORT(.fini_array.*)) /*Sorted eg .fini_array.0000 */
        *(.fini_array*)
        . = ALIGN(4);
    } >FLASH
    .ARM :
    {
        . = ALIGN(4);
        *(.ARM)
        *(.ARM.exidx)
        . = ALIGN(4);
    } >FLASH
    .jcr :
    {
        . = ALIGN(4);
        *(.jcr)
        . = ALIGN(4);
    } >FLASH
    
    _sidata = LOADADDR(.data);
}