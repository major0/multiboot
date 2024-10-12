# Copyright (c) 2024 Mark Ferrell
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Layout of the Multiboot2 header
# Offset	Type	Field Name	  Note
# 0	    u32	  magic	        required
# 4	    u32	  architecture	required
# 8	    u32	  header_length	required
# 12	    u32	  checksum	    required
# 16-XX	      tags	        required

const
  Multiboot2Search* = 32768 ##  How many bytes from the start of the file we search for the header.
  Multiboot2HeaderAlign* = 8
  Multiboot2HeaderMagic* = 0xe85250d6 ##  The magic field should contain this.
  Multiboot2BootloaderMagic* = 0x36d76289 ##  This should be in %eax.
  Multiboot2ModAlign* = 0x00001000 ##  Alignment of multiboot modules.
  Multiboot2InfoAlign* = 0x00000008 ##  Alignment of the multiboot info structure.
  Multiboot2TagAlign* = 8 ## Alignment of multboot tags

type Multiboot2Header* = object
  magic*: uint32 ## Must be MultibootMagic
  architecture*: uint32 ## ISA
  length*: uint32 ## Total header length; including all header tags.
  checksum*: uint32 ## The above fields plus this one must equal 0 mod 2^32.

type Multiboot2Architecture* {.size: sizeof(uint32).} = enum
  I386 = 0,
  Mips32 = 4,

# General Tag Structure
# u16  type
# u16  flags # if bit0 is set ten this tag is optional
# u16  size
type Multiboot2HeaderTag* = object
  `type`*: uint16
  flags*: uint16
  size*: uint32

type
  Multiboot2HeaderFlag {.size: sizeof(uint16).} = enum
    Optional,
  Multiboot2HeaderFlags* {.size: sizeof(uint16)} = set[Multiboot2HeaderFlag]

type Multiboot2HeaderTagType* {.size: sizeof(uint16).} = enum
  ## Header tag types set during compilation to instruct the bootloader on
  ## how to boot the kernel.
  End, ## No more tags are allowed after the End tag type
  InformationRequest,
  Address,
  EntryAddress,
  ConsoleFlags,
  Framebuffer,
  ModuleAlign,
  EfiBs,
  EntryAddressEfi64,
  Relocatable,

type Multiboot2LoadPreference* {.size: sizeof(uint16).} = enum
  None,
  Low,
  High,

type
  MultiBoot2ConsoleFlag {.size: sizeof(uint16).} = enum
    ConsoleRequired,
    EgaTextSupported,
  MultibootConsoleFlags* = set[MultiBoot2ConsoleFlag]

type Multiboot2HeaderTagInformationRequest* = object
  tag*: Multiboot2HeaderTag
  requests*: UncheckedArray[uint32]

type Multiboot2HeaderTagAddress* = object
  tag*: Multiboot2HeaderTag
  headerAddr*: uint32
  loadAddr*: uint32
  loadEndAddr*: uint32
  bssEndAddr*: uint32

type Multiboot2HeaderTagEntryAddress* = object
  tag*: Multiboot2HeaderTag
  entryAddr*: uint32

type Multiboot2HeaderTagConsoleFlags* = object
  tag*: Multiboot2HeaderTag
  consoleFlags*: uint32

type Multiboot2HeaderTagFramebuffer* = object
  tag*: Multiboot2HeaderTag
  width*: uint32
  height*: uint32
  depth*: uint32

type Multiboot2HeaderTagModuleAlign* = object
  tag*: Multiboot2HeaderTag

type Multiboot2HeaderTagRelocatable* = object
  tag*: Multiboot2HeaderTag
  minAddr*: uint32
  maxAddr*: uint32
  align*: uint32
  preference*: uint32


