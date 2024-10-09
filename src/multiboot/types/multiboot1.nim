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

import common

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
  ## While this looks similar to the Multiboot2 FB Pallet, the fields are
  ## reversed.
  `addr`*: uint32
  numColors*: uint16

type Multiboot1FramebufferRgb* = MultibootFramebufferRgb

type Multiboot1FramebufferUnion {.union.} = object
  pallet*: Multiboot1FramebufferPallet
  rgb*: Multiboot1FramebufferRgb

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
  framebufferInfo*: Multiboot1FramebufferUnion

type Multiboot1Color* = object
  red*: uint8
  green*: uint8
  blue*: uint8

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
