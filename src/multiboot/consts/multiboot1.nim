# MIT License
# 
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

const
  Multiboot1Search* = 8192
    ##  How many bytes from the start of the file we search for the header.
  Multiboot1HeaderAlign* = 4
  Multiboot1HeaderMagic* = 0x1BADB002 ##  The magic field should contain this.
  Multiboot1BootloaderMagic* = 0x2BADB002 ##  This should be in %eax.
  Multiboot1ModAlign* = 0x00001000   ##  Alignment of multiboot modules.
  Multiboot1InfoAlign* = 0x00000004  ##  Alignment of the multiboot info structure.
  Multiboot1PageAlign* = 0x00000001  ##  Flags set in the 'flags' member
                                    ## of the multiboot header. Align all
                                    ## boot modules on i386 page (4KB)
                                    ## boundaries.
  Multiboot1MemoryInfo* = 0x00000002 ##  Must pass memory information to OS.
  Multiboot1VideoMode* = 0x00000004  ##  Must pass video information to OS.
  Multiboot1AoutKludge* = 0x00010000 ##  This flag indicates the use of the address fields in the header.

##  Flags to be set in the 'flags' member of the multiboot info structure.
const
  Multiboot1InfoMemory* = 0x00000001   ##  is there basic lower/upper memory information?
  Multiboot1InfoBootdev* = 0x00000002  ##  is there a boot device set?
  Multiboot1InfoCmdline* = 0x00000004  ##  is the command-line defined?
  MultiBootInfoMods* = 0x00000008     ##  are there modules to do something with?
  #  These next two are mutually exclusive
  Multiboot1InfoAoutSyms* = 0x00000010 ##  is there a symbol table loaded?
  Multiboot1InfoElfShdr* = 0x00000020 ##  is there an ELF section header table?
  # Remaining flags
  Multiboot1InfoMemMap* = 0x00000040 ##  is there a full memory map?
  Multiboot1InfoDriveInfo* = 0x00000080 ##  Is there drive info?
  Multiboot1InfoConfigTable* = 0x00000100 ##  Is there a config table?
  Multiboot1InfoBootLoaderName* = 0x00000200 ##  Is there a boot loader name?
  Multiboot1InfoApmTable* = 0x00000400 ##  Is there a APM table?
  Multiboot1InfoVbeInfo* = 0x00000800 ##  Is there video information?
  Multiboot1InfoFramebufferInfo* = 0x00001000

type Multiboot1Header* = object
  magic*: uint32 ##  Must be Multiboot1Magic - see above.
  flags*: uint32 # Feature flags.
  checksum*: uint32 ##  The flags field plus this one must equal 0 mod 2^32.
  #  These are only valid if Multiboot1AoutKludge is set.
  headerAddr*: uint32
  loadAddr*: uint32
  loadEndAddr*: uint32
  bssEndAddr*: uint32
  entryAddr*: uint32
  #  These are only valid if Multiboot1VideoMode is set.
  modeType*: uint32
  width*: uint32
  height*: uint32
  depth*: uint32

type Multiboot1AoutSymbolTable* = object ##  The symbol table for a.out.
  tabsize*: uint32
  strsize*: uint32
  `addr`*: uint32
  reserved*: uint32

type Multiboot1ElfSectionHeaderTable* = object ##  The section header table for ELF.
  num*: uint32
  size*: uint32
  `addr`*: uint32
  shndx*: uint32

type Multiboot1ExecTableUnion {.union.} = object
  aoutSym*: Multiboot1AoutSymbolTable
  elfSec*: Multiboot1ElfSectionHeaderTable

type Multiboot1FramebufferPallet* = object
  `addr`*: uint32
  numColors*: uint16

type Multiboot1FramebufferRgb* = object
  redFieldPosition*: uint8
  redMaskSize*: uint8
  greenFieldPosition*: uint8
  greenMaskSize*: uint8
  blueFieldPosition*: uint8
  blueMaskSize*: uint8

type Multiboot1FramebufferInfoUnion {.union.} = object
  pallet*: Multiboot1FramebufferPallet
  rgb*: Multiboot1FramebufferRgb

const
  Multiboot1FramebufferTypeIndexed* = 0
  Multiboot1FramebufferTypeRgb* = 1
  Multiboot1FramebufferTypeEgaText* = 2

type Multiboot1Info* = object
  flags*: uint32 ##  Multiboot info version number
  memLower*: uint32 ##  Available memory from BIOS
  memUpper*: uint32
  bootDevice*: uint32 ##  "root" partition
  cmdline*: uint32 ##  Address of the kernel command line string
  modsCount*: uint32 ## Number of boot modules
  modsAddr*: uint32 ## Starting address of boot modules

  execTable*: Multiboot1ExecTableUnion

  mmapLength*: uint32 ##  Memory Mapping buffer length
  mmapAddr*: uint32 ## Memory Mapping buffer start addr
  drivesLength*: uint32 ##  Drive Info buffer size
  drivesAddr*: uint32 ## Drive Info buffer start addr
  configTable*: uint32 ##  ROM configuration table
  bootLoaderName*: uint32 ##  Boot Loader Name
  apmTable*: uint32 ##  APM table

  #  Video
  vbeControlInfo*: uint32
  vbeModeInfo*: uint32
  vbeMode*: uint16
  vbeInterfaceSeg*: uint16
  vbeInterfaceOff*: uint16
  vbeInterfaceLen*: uint16
  framebufferAddr*: uint64
  framebufferPitch*: uint32
  framebufferWidth*: uint32
  framebufferHeight*: uint32
  framebufferBpp*: uint8
  framebufferType*: uint8
  framebufferInfo*: Multiboot1FramebufferInfoUnion

type Multiboot1Color* = object
  red*: uint8
  green*: uint8
  blue*: uint8

const
  Multiboot1MemoryAvailable* = 1
  Multiboot1MemoryReserved* = 2
  Multiboot1MemoryAcpiReclaimable* = 3
  Multiboot1MemoryNvs* = 4
  Multiboot1MemoryBadram* = 5

type Multiboot1MmapEntry* = object
  size*: uint32
  `addr`*: uint64
  len*: uint64
  `type`*: uint32

type Multiboot1ModList* = object
  modStart*: uint32
    ## the memory used goes from bytes 'mod_start'
    ## to 'mod_end-1' inclusive
  modEnd*: uint32
  cmdline*: uint32 ##  Module command line
  pad*: uint32 ##  padding to take it to 16 bytes (must be zero)

type Multiboot1ApmInfo* = object ##  APM BIOS info.
  version*: uint16
  cseg*: uint16
  offset*: uint32
  cseg16*: uint16
  dseg*: uint16
  flags*: uint16
  csegLen*: uint16
  cseg16Len*: uint16
  dsegLen*: uint16
