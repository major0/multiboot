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

const
  Multiboot2BootloaderMagic* = 0x36d76289 ##  This should be in %eax.
  Multiboot2ModAlign* = 0x00001000 ##  Alignment of multiboot modules.
  Multiboot2InfoAlign* = 0x00000008 ##  Alignment of the multiboot info structure.
  Multiboot2TagAlign* = 8 ## Alignment of multboot tags

type Multiboot2Info* = object
  ## The bootloader is responsible for passing hardware information to the
  ## operating system via the Multiboot Information structure.
  ##
  ## According to the specification, the MBI structure is an MBI block,
  ## followed by some number of MB2 Tags, and terminated with an End tag.
  totalSize*: uint32 ## Represents the total size of the MBI information
                     ## in memory, including all tags.
  reservced*: uint32 ## Unused

type Multiboot2TagType* {.size: sizeof(uint32).} = enum
  ## Tag Types set by the Bootloader
  End, ## No more tags are allowed after the End tag type
  Cmdline,
  BootLoaderName,
  Module,
  BasicMeminfo,
  Bootdev,
  Mmap,
  Vbe,
  Framebuffer,
  ElfSections,
  Apm,
  Efi32,
  Efi64,
  Smbios,
  AcpiOld,
  AcpiNew,
  Network,
  EfiMmap,
  EfiBs,
  Efi32Ih,
  Efi64Ih,
  LoadBaseAddr,

type Multiboot2Tag* = object
  ## All MB2 Tags found in the MBI must begin with the following structure.
  `type`*: Multiboot2TagType ## Indicates the type of data found in this tag.
  size*: uint32 ## Indicates the total size of this tag. The offset of the
                ## address to this tag plus this size is used to locate
                ## the next tag.

type Multiboot2TagEnd* = Multiboot2Tag
  ## The end tag is just an empty Tag, so the size must be equal to the
  ## sizeof(Multiboot2Tag). E.g. 8

type Multiboot2TagString* = object
  ## This tag structure is used by any MBI2 Tag type which only contains
  ## string data. E.g. the Kernel Command Line arguments.
  tag*: Multiboot2Tag
  string*: UncheckedArray[char]

type Multiboot2TagModule* = object
  ## This tag structure is used to pass module information to the kernel.
  ## Modules can be compiled userland programs. This allows the bootloader
  ## to load applications into memory on behalf of the kernel, such as
  ## `init` and or any special userland based drivers. This greatly
  ## simplifies kernel development.
  tag*: Multiboot2Tag
  modStart*: uint32 ## Start address of the module loaded into memory.
  modEnd*: uint32 ## End address of the module loaded into memory.
  cmdline*: UncheckedArray[char] ## Command line arguments to the module.

type Multiboot2TagBasicMeminfo* = object
  tag*: Multiboot2Tag
  memLower*: uint32
  memUpper*: uint32

type Multiboot2TagBootdev* = object
  tag*: Multiboot2Tag
  biosdev*: uint32
  slice*: uint32
  part*: uint32

type Multiboot2MmapEntry* = object
  `addr`*: uint64
  len*: uint64
  `type`*: uint32
  zero*: uint32

type Multiboot2TagMmap* = object
  tag*: Multiboot2Tag
  entrySize*: uint32
  entryVersion*: uint32
  entries*: UncheckedArray[Multiboot2MmapEntry]

type Multiboot2VbeInfoBlock* = object
  externalSpecification*: array[512, uint8]

type Multiboot2VbeModeInfoBlock* = object
  externalSpecification*: array[256, uint8]

type Multiboot2TagVbe* = object
  tag*: Multiboot2Tag
  vbeMode*: uint16
  vbeInterfaceSeg*: uint16
  vbeInterfaceOff*: uint16
  vbeInterfaceLen*: uint16
  vbeControlInfo*: Multiboot2VbeInfoBlock
  vbeModeInfo*: Multiboot2VbeModeInfoBlock

type Multiboot2TagFramebufferCommon* = object
  tag*: Multiboot2Tag
  framebufferAddr*: uint64
  framebufferPitch*: uint32
  framebufferWidth*: uint32
  framebufferHeight*: uint32
  framebufferBpp*: uint8
  framebufferType*: uint8
  reserved*: uint16

type Multiboot2Color* = object
  red*: uint8
  green*: uint8
  blue*: uint8

type Multiboot2FramebufferPallet* = object
  ## While this looks similar to the Multiboot1 FB Pallet, the fields are
  ## reversed.
  numColors*: uint16
  `addr`*: UncheckedArray[Multiboot2Color] ## Pointer to the pallet in memory

type Multiboot2FramebufferRgb* = MultibootFramebufferRgb

type Multiboot2FramebufferUnion* {.union.} = object
  indexed*: Multiboot2FramebufferPallet
  rgb*: Multiboot2FramebufferRgb

type Multiboot2TagFramebuffer* = object
  common*: Multiboot2TagFramebufferCommon
  `union`*: Multiboot2FramebufferUnion

type Multiboot2TagElfSections* = object
  tag*: Multiboot2Tag
  num*: uint32
  entsize*: uint32
  shndx*: uint32
  sections*: UncheckedArray[char]

type Multiboot2TagApm* = object
  tag*: Multiboot2Tag
  version*: uint16
  cseg*: uint16
  offset*: uint32
  cseg16*: uint16
  dseg*: uint16
  flags*: uint16
  csegLen*: uint16
  cseg16Len*: uint16
  dsegLen*: uint16

type Multiboot2TagEfi32* = object
  tag*: Multiboot2Tag
  pointer*: uint32

type Multiboot2TagEfi64* = object
  tag*: Multiboot2Tag
  pointer*: uint64

type Multiboot2TagSmbios* = object
  tag*: Multiboot2Tag
  major*: uint8
  minor*: uint8
  reserved*: array[6, uint8]
  tables*: UncheckedArray[uint8]

type Multiboot2TagOldAcpi* = object
  tag*: Multiboot2Tag
  rsdp*: UncheckedArray[uint8]

type Multiboot2TagNewAcpi* = object
  tag*: Multiboot2Tag
  rsdp*: UncheckedArray[uint8]

type Multiboot2TagNetwork* = object
  tag*: Multiboot2Tag
  dhcpack*: UncheckedArray[uint8]

type Multiboot2TagEfiMmap* = object
  tag*: Multiboot2Tag
  descrSize*: uint32
  descrVers*: uint32
  efiMmap*: UncheckedArray[uint8]

type Multiboot2TagEfi32Ih* = object
  tag*: Multiboot2Tag
  pointer*: uint32

type Multiboot2TagEfi64Ih* = object
  tag*: Multiboot2Tag
  pointer*: uint64

type Multiboot2TagLoadBaseAddr* = object
  tag*: Multiboot2Tag
  loadBaseAddr*: uint32

# These 2 types are compatible between Multiboot v1 and v2
type Multiboot2Memory* = MultibootMemory
type Multiboot2FramebufferType* = MultibootFramebufferType

iterator items*(mbi: ptr Multiboot2Info): ptr Multiboot2Tag {.inline.} =
  ## Iterate over the tags in the multiboot information.
  ##
  ## The Multiboot2Info structure and all of its Tag structures are
  ## already setup and created in memory by the bootloader. So we just
  ## need to iterate existing memory structures.
  ##
  ## Each tag structure can be of different size, but the beginning of each
  ## tag structure is identical and can be cast to Multiboot2Tag for the
  ## purpose of iteration.
  ##
  ## The caller needs to interogate the tag.type field and recast the tag
  ## accordingly.
  if not mbi.isNil:
    var tag: ptr Multiboot2Tag = cast[ptr Multiboot2Tag](cast[uint32](mbi.unsafeAddr) + cast[uint32](sizeof(Multiboot2Info)))
    while true:
      block tagLoop:
        if tag.`type` == Multiboot2TagType.End:
          break tagLoop
        yield tag
        tag = cast[ptr Multiboot2Tag](cast[uint32](tag.unsafeAddr) + tag.size)


proc get*(mbi: ptr Multiboot2Info, tagType: Multiboot2TagType): ptr Multiboot2Tag =
  ## Check if the given multiboot header contains the given tag type and
  ## return a ptr to that tag.

  if not mbi.isNil:
    for tag in mbi.items:
      if tag.`type` == tagType:
        result = tag
        return


proc contains*(mbi: ptr Multiboot2Info, tagType: Multiboot2TagType): bool =
  ## Check if the given multiboot header contains the given tag type.
  var tag: ptr Multiboot2Tag = get(mbi, tagType)

  if tag.isNil:
    result = false
  result = true

proc size*(mbi: ptr Multiboot2Info): int =
  if not mbi.isNil:
    result = cast[int](mbi.totalSize)
  result = 0

proc len*(mbi: ptr Multiboot2Info): int =
  result = 0
  if not mbi.isNil:
    for tag in mbi:
      result += 1
