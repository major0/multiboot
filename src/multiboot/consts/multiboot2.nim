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
  Multiboot2Search* = 32768 ##  How many bytes from the start of the file we search for the header.
  Multiboot2HeaderAlign* = 8
  Multiboot2HeaderMagic* = 0xe85250d6 ##  The magic field should contain this.
  Multiboot2BootloaderMagic* = 0x36d76289 ##  This should be in %eax.
  Multiboot2ModAlign* = 0x00001000 ##  Alignment of multiboot modules.
  Multiboot2InfoAlign* = 0x00000008 ##  Alignment of the multiboot info structure.

const Multiboot2TagAlign* = 8

##  Flags set in the 'flags' member of the multiboot header.
const
  Multiboot2TagTypeEnd* = 0
  Multiboot2TagTypeCmdline* = 1
  Multiboot2TagTypeBootLoaderName* = 2
  Multiboot2TagTypeModule* = 3
  Multiboot2TagTypeBasicMeminfo* = 4
  Multiboot2TagTypeBootdev* = 5
  Multiboot2TagTypeMmap* = 6
  Multiboot2TagTypeVbe* = 7
  Multiboot2TagTypeFramebuffer* = 8
  Multiboot2TagTypeElfSections* = 9
  Multiboot2TagTypeApm* = 10
  Multiboot2TagTypeEfi32* = 11
  Multiboot2TagTypeEfi64* = 12
  Multiboot2TagTypeSmbios* = 13
  Multiboot2TagTypeAcpiOld* = 14
  Multiboot2TagTypeAcpiNew* = 15
  Multiboot2TagTypeNetwork* = 16
  Multiboot2TagTypeEfiMmap* = 17
  Multiboot2TagTypeEfiBs* = 18
  Multiboot2TagTypeEfi32Ih* = 19
  Multiboot2TagTypeEfi64Ih* = 20
  Multiboot2TagTypeLoadBaseAddr* = 21

const
  Multiboot2HeaderTagTypeEnd* = 0
  Multiboot2HeaderTagTypeInformationRequest* = 1
  Multiboot2HeaderTagTypeAddress* = 2
  Multiboot2HeaderTagTypeEntryAddress* = 3
  Multiboot2HeaderTagTypeConsoleFlags* = 4
  Multiboot2HeaderTagTypeFramebuffer* = 5
  Multiboot2HeaderTagTypeModuleAlign* = 6
  Multiboot2HeaderTagTypeEfiBs* = 7
  Multiboot2HeaderTagTypeEntryAddressEfi64* = 9
  Multiboot2HeaderTagTypeRelocatable* = 10

const
  Multiboot2ArchitectureI386* = 0
  Multiboot2ArchitectureMips32* = 4

const
  Multiboot2HeaderTagOptional* = 1

const
  Multiboot2LoadPreferenceNone* = 0
  Multiboot2LoadPreferenceLow* = 1
  Multiboot2LoadPreferenceHigh* = 2

const
  Multiboot2ConsoleFlagsConsoleRequired* = 1
  Multiboot2ConsoleFlagsEgaTextSupported* = 2

type Multiboot2Header* = object
  magic*: uint32 ##  Must be MultibootMagic
  architecture*: uint32 ##  ISA
  headerLength*: uint32 ##  Total header length.
  checksum*: uint32 ##  The above fields plus this one must equal 0 mod 2^32.

type Multiboot2HeaderTag* = object
  `type`*: uint16
  flags*: uint16
  size*: uint32

type Multiboot2HeaderTagInformationRequest* = object
  `type`*: uint16
  flags*: uint16
  size*: uint32
  requests*: UncheckedArray[uint32]

type Multiboot2HeaderTagAddress* = object
  `type`*: uint16
  flags*: uint16
  size*: uint32
  headerAddr*: uint32
  loadAddr*: uint32
  loadEndAddr*: uint32
  bssEndAddr*: uint32

type Multiboot2HeaderTagEntryAddress* = object
  `type`*: uint16
  flags*: uint16
  size*: uint32
  entryAddr*: uint32

type Multiboot2HeaderTagConsoleFlags* = object
  `type`*: uint16
  flags*: uint16
  size*: uint32
  consoleFlags*: uint32

type Multiboot2HeaderTagFramebuffer* = object
  `type`*: uint16
  flags*: uint16
  size*: uint32
  width*: uint32
  height*: uint32
  depth*: uint32

type Multiboot2HeaderTagModuleAlign* = object
  `type`*: uint16
  flags*: uint16
  size*: uint32

type Multiboot2HeaderTagRelocatable* = object
  `type`*: uint16
  flags*: uint16
  size*: uint32
  minAddr*: uint32
  maxAddr*: uint32
  align*: uint32
  preference*: uint32

type Multiboot2Color* = object
  red*: uint8
  green*: uint8
  blue*: uint8

const
  Multiboot2MemoryAvailable* = 1
  Multiboot2MemoryReserved* = 2
  Multiboot2MemoryAcpiReclaimable* = 3
  Multiboot2MemoryNvs* = 4
  Multiboot2MemoryBadRAM* = 5

type Multiboot2MmapEntry* = object
  `addr`*: uint64
  len*: uint64
  `type`*: uint32
  zero*: uint32

type Multiboot2Tag* = object
  `type`*: uint32
  size*: uint32

type Multiboot2TagString* = object
  `type`*: uint32
  size*: uint32
  string*: UncheckedArray[char]

type Multiboot2TagModule* = object
  `type`*: uint32
  size*: uint32
  modStart*: uint32
  modEnd*: uint32
  cmdline*: UncheckedArray[char]

type Multiboot2TagBasicMeminfo* = object
  `type`*: uint32
  size*: uint32
  memLower*: uint32
  memUpper*: uint32

type Multiboot2TagBootdev* = object
  `type`*: uint32
  size*: uint32
  biosdev*: uint32
  slice*: uint32
  part*: uint32

type Multiboot2TagMmap* = object
  `type`*: uint32
  size*: uint32
  entrySize*: uint32
  entryVersion*: uint32
  entries*: UncheckedArray[Multiboot2MmapEntry]

type Multiboot2VbeInfoBlock* = object
  externalSpecification*: array[512, uint8]

type Multiboot2VbeModeInfoBlock* = object
  externalSpecification*: array[256, uint8]

type Multiboot2TagVbe* = object
  `type`*: uint32
  size*: uint32
  vbeMode*: uint16
  vbeInterfaceSeg*: uint16
  vbeInterfaceOff*: uint16
  vbeInterfaceLen*: uint16
  vbeControlInfo*: Multiboot2VbeInfoBlock
  vbeModeInfo*: Multiboot2VbeModeInfoBlock

const
  Multiboot2FramebufferTypeIndexed* = 0
  Multiboot2FramebufferTypeRgb* = 1
  Multiboot2FramebufferTypeEgaText* = 2

type Multiboot2TagFramebufferCommon* = object
  `type`*: uint32
  size*: uint32
  framebufferAddr*: uint64
  framebufferPitch*: uint32
  framebufferWidth*: uint32
  framebufferHeight*: uint32
  framebufferBpp*: uint8
  framebufferType*: uint8
  reserved*: uint16

type Multiboot2FramebufferIndexed* = object
  paletteNumColors*: uint16
  palette*: UncheckedArray[Multiboot2Color]

type Multiboot2FramebufferRgb* = object
  redFieldPosition*: uint8
  redMaskSize*: uint8
  greenFieldPosition*: uint8
  geenMaskSize*: uint8
  blueFieldPosition*: uint8
  blueMaskSize*: uint8

type Multiboot2FramebufferUnion* {.union.} = object
  indexed*: Multiboot2FramebufferIndexed
  rgb*: Multiboot2FramebufferRgb

type Multiboot2TagFramebuffer* = object
  common*: Multiboot2TagFramebufferCommon
  `union`*: Multiboot2FramebufferUnion

type Multiboot2TagElfSections* = object
  `type`*: uint32
  size*: uint32
  num*: uint32
  entsize*: uint32
  shndx*: uint32
  sections*: UncheckedArray[char]

type Multiboot2TagApm* = object
  `type`*: uint32
  size*: uint32
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
  `type`*: uint32
  size*: uint32
  pointer*: uint32

type Multiboot2TagEfi64* = object
  `type`*: uint32
  size*: uint32
  pointer*: uint64

type Multiboot2TagSmbios* = object
  `type`*: uint32
  size*: uint32
  major*: uint8
  minor*: uint8
  reserved*: array[6, uint8]
  tables*: UncheckedArray[uint8]

type Multiboot2TagOldAcpi* = object
  `type`*: uint32
  size*: uint32
  rsdp*: UncheckedArray[uint8]

type Multiboot2TagNewAcpi* = object
  `type`*: uint32
  size*: uint32
  rsdp*: UncheckedArray[uint8]

type Multiboot2TagNetwork* = object
  `type`*: uint32
  size*: uint32
  dhcpack*: UncheckedArray[uint8]

type Multiboot2TagEfiMmap* = object
  `type`*: uint32
  size*: uint32
  descrSize*: uint32
  descrVers*: uint32
  efiMmap*: UncheckedArray[uint8]

type Multiboot2TagEfi32Ih* = object
  `type`*: uint32
  size*: uint32
  pointer*: uint32

type Multiboot2TagEfi64Ih* = object
  `type`*: uint32
  size*: uint32
  pointer*: uint64

type Multiboot2TagLoadBaseAddr* = object
  `type`*: uint32
  size*: uint32
  loadBaseAddr*: uint32
