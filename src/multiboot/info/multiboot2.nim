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
  Multiboot2BootloaderMagic* = 0x36d76289
    ## This is loaded into a CPU register by the bootloader as a way
    ## to inform the kernel that a multiboot compliant bootloader loaded
    ## everything.
    ## - On x86 this value is loaded into %eax and the address of the mbi
    ##   is loaded into %ebx
    ## - On Mips32 this value is loaded into $r4 and the addr of the mbi
    ##   is loaded into $r5.
  Multiboot2ModAlign* = 0x00001000 ## Alignment of multiboot modules.
  Multiboot2InfoAlign* = 0x00000008
    ## Alignment of the multiboot info structure.

type Multiboot2Info* = object
  ## The bootloader is responsible for passing hardware information to the
  ## operating system via the Multiboot Information structure.
  ##
  ## According to the specification, the MBI structure is an MBI block,
  ## followed by some number of MB2 Tags, and terminated with an End tag.
  totalSize*: uint32
    ## Represents the total size of the MBI information in memory,
    ## including all tags.
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
  ## All MB2 Tags found in the MBI must begin with the following
  ## structure.
  `type`*: Multiboot2TagType
    ## Indicates the type of data found in this tag.
  size*: uint32
    ## Indicates the total size of this tag. The offset of the address
    ## to this tag plus this size is used to locate the next tag.

type Multiboot2TagEnd* = Multiboot2Tag
  ## The `End` tag is an empty Tag wit the size set to
  ## ``sizeof(Multiboot2Tag).``. E.g. 8

type Multiboot2TagString* = object
  ## Used by tags which pass a single UTF-8 encoded, C-style zero
  ## terminated string. E.g. `Multiboot2TagType`_ `Cmdline` and
  ## `BootLoaderName`.
  info*: Multiboot2Tag
  string*: UncheckedArray[char]

type Multiboot2TagModule* = object
  ## This tag structure is used to pass module information to the kernel.
  ## Modules can be compiled userland programs, or simply paths to a file
  ## within the filesystem. This allows the bootloader to load
  ## applications into memory on behalf of the kernel, such as `init`
  ## and or any special userland based drivers. This greatly simplifies
  ## kernel development.
  info*: Multiboot2Tag
  modStart*: uint32
    ## Physical start address of the module loaded into memory.
  modEnd*: uint32
    ## Physical end address of the module loaded into memory.
  cmdline*: UncheckedArray[char]
    ## Zero-terminated, UTF-encoded, string.

type Multiboot2TagBasicMeminfo* = object
  ## Indicates the amount of upper and lower memory.
  ##
  ## May not be provided on EFI platforms if EFI boot services are
  ## enabled and available.
  info*: Multiboot2Tag
  memLower*: uint32 ## Amount of lower memory. max 640k
  memUpper*: uint32
    ## Amount of upper memory. The value will be maximally the
    ## address of the fist upper memory hole minus 1MB.

type Multiboot2TagBootdev* = object
  ## The `Bootdev` tag is used to pass information about the boot device
  ## that the OS was loaded from. Will not be present if the OS was not
  ## loaded from a BIOS disk.
  ##
  ## May be used as a `hint` in determining the root device.
  info*: Multiboot2Tag
  biosdev*: uint32
    ## `biosdev` contains the BIOS drive number as understood by the BIOS
    ## INT 0x13 disk interface. E.g. 0x00 = floppy, 0x80 = hard disk.
  part*: uint32
    ## `part` contains the partition number of the boot device with DOS
    ## style standard partitions being numbered 0-3 and extended partitions
    ## being numbered 4 on.
  sub_part*: uint32
    ## `sub_part` contains the sub-partition number of the boot device for
    ## normal DOS partitions (0-3). If no `sub_part` is was used, or if
    ## the OS was botted from an extended partition (4+), then the
    ## `sub_part` will be set to 0xFFFFFFFF.

type Multiboot2MmapEntryType* {.size: sizeof(uint32).} = enum
  BootloaderReserved = 0
  Ram = 1
  ACPIReclaimable = 3
  Nvs = 4
  Badram = 5

type Multiboot2MmapEntry* = object
  base_addr*: uint64
    ## The physical start address of the memory region.
  size*: uint64
    ## The size of the memory region in bytes.
  `type`*: Multiboot2MmapEntryType
    ## The `type` of the memory region. See: `Multiboot2MmapEntryType`.
  reserved: uint32

type Multiboot2TagMmap* = object
  ## The `Mmap` tag is used to pass the memory map to the kernel.
  info*: Multiboot2Tag
  entrySize*: uint32
    ## Indicates the size of each entry in the memory map and will always
    ## be a multiple of 8.
  entryVersion*: uint32
    ## Indicates the version of the memory map entry structure. Currently
    ## only one version is defined; version `0`.
  entries*: UncheckedArray[Multiboot2MmapEntry]

type Multiboot2VbeInfoBlock* = object
  externalSpecification*: array[512, uint8]

type Multiboot2VbeModeInfoBlock* = object
  externalSpecification*: array[256, uint8]

type Multiboot2TagVbe* = object
  ## The `Vbe` tag is used to pass VBE information to the kernel.
  ## See VBE 2.0 and VBE 3.0 for more information.
  info*: Multiboot2Tag
  vbeMode*: uint16
    ## `vbeMode` inicates the current video mode in the format specified
    ## in VBE 3.0.
  vbeInterfaceSeg*: uint16
    ## `vbeInterfaceSeg` contains the segment address of the VBE as
    ## specified in VBE 2.0. Will be set to 0 if unavailable or if using
    ## a VBE 3.0 protected mode.
  vbeInterfaceOff*: uint16
    ## `vbeInterfaceOff` contains the offset address of the VBE as
    ## in specified in VBE 2.0. Will be set to 0 if unavailable or if
    ## using a VBE 3.0 protected mode.
  vbeInterfaceLen*: uint16
    ## `vbeInterfaceLen` contains the length of the VBE as specified
    ## in VBE 2.0. Will be set to 0 if unavailable or if using a VBE
    ## 3.0 protected mode.
  vbeControlInfo*: Multiboot2VbeInfoBlock
    ## `vbeControlInfo` contains the VBE control information as returned by
    ## VBE Function 00h.
  vbeModeInfo*: Multiboot2VbeModeInfoBlock
    ## `vbeModeInfo` contains the VBE mode information as returned by VBE
    ## Function 01h.

type Multiboot2Color* = object
  red*: uint8
  green*: uint8
  blue*: uint8

type Multiboot2FramebufferPallet* = object
  ## While this looks similar to the Multiboot1 FB Pallet, the fields are
  ## reversed.
  length*: uint32
    ## Indicates the number of `Multiboot2Color` entries in the color
    ## pallet.
  color*: UncheckedArray[Multiboot2Color]

type Multiboot2FramebufferRgb* = MultibootFramebufferRgb

type Multiboot2FramebufferColorInfo* {.union.} = object
  indexed*: Multiboot2FramebufferPallet
  rgb*: Multiboot2FramebufferRgb

type Multiboot2TagFramebufferInfo* = object
  info*: Multiboot2Tag
  framebufferAddr*: uint64
    ## The physical address of the framebuffer. While the field is 64bit,
    ## the bootloader **should** set it under 4GB if possible.
  framebufferPitch*: uint32
    ## FB pitch in bytes.
  framebufferWidth*: uint32
    ## FB width in pixels.
  framebufferHeight*: uint32
    ## FB height in pixels.
  framebufferBpp*: uint8
    ## Bits per pixel.
  framebufferType*: uint8
    ## Used to indicate the framebuffer color type. See `colorInfo`
  reserved: uint8
  colorInfo*: Multiboot2FramebufferColorInfo
    ## if `framebufferType` is 0 then `colorInfo.indexed` is valid.
    ## if `framebufferType` is 1 then `colorInfo.rgb` is valid.

type Multiboot2TagElfSections* = object
  ## This tag is used to pass ELF section header table to the kernel. All
  ## sections are loaded, and the physuical address of the fields of the
  ## ELF section header then refer to wehere the sections are in memory.
  ## See the ELF specification for how to read the section headers.
  info*: Multiboot2Tag
  num*: uint16
    ## Number of entries in the table.
  entsize*: uint16
    ## Size of each entry.
  shndx*: uint16
    ## Index of the section header names string table in the `sections` array.
  sections*: UncheckedArray[uint8]

type Multiboot2TagApm* = object
  ## The `Apm` tag is used to pass APM information to the kernel.
  ## See the Advanced Power Management (APM) specification for more
  ## information.
  info*: Multiboot2Tag
  version*: uint16
    ## Version of the APM table.
  cseg*: uint16
    ## 32-bit code segment
  offset*: uint32
    ## offset of the entrypoint
  cseg16*: uint16
    ## 16-bit code segment
  dseg*: uint16
    ## 16-bit data segment
  flags*: uint16
  csegLen*: uint16
    ## length of the 32-bit code segment
  cseg16Len*: uint16
    ## length of the 16-bit code segment
  dsegLen*: uint16
    ## length of the 16-bit data segment

type Multiboot2TagEfi32* = object
  ## The `Efi32` tag is used to pass the 386 EFI system table to the
  ## kernel.
  info*: Multiboot2Tag
  pointer*: uint32

type Multiboot2TagEfi64* = object
  ## The `Efi64` tag is used to pass the AMD64 EFI system table to the
  ## kernel.
  info*: Multiboot2Tag
  pointer*: uint64

type Multiboot2TagSmbios* = object
  ## The `Smbios` tag is used to pass SMBIOS information to the kernel.
  info*: Multiboot2Tag
  major*: uint8
  minor*: uint8
  reserved: array[6, uint8]
  tables*: UncheckedArray[uint8]

type Multiboot2TagOldAcpi* = object
  info*: Multiboot2Tag
  rsdp*: UncheckedArray[uint8]
    ## Copy of the RSDP as defined per ACPI1.0

type Multiboot2TagNewAcpi* = object
  info*: Multiboot2Tag
  rsdp*: UncheckedArray[uint8]
    ## Copy of the RSDP as defined per ACPI2.0 and later.

type Multiboot2TagNetwork* = object
  ## The `Network` tag is used to pass network information to the kernel
  ## specified as DHCP. The DHCPACK structure is used even if the network
  ## information was not aqcuired via DHCP.
  ## This tag appears **once per card**.
  info*: Multiboot2Tag
  dhcpack*: UncheckedArray[uint8]

type Multiboot2TagEfiMmap* = object
  ## Provides the EFI memory map as per the EFI specification. May not be
  ## present on EFI systems if the EFI services are still running.
  info*: Multiboot2Tag
  descrSize*: uint32
    ## descriptor size in bytes
  descrVers*: uint32
    ## descriptor version
  efiMmap*: UncheckedArray[uint8]
    ## EFI memory map. See the EFI specification for more information.

type Multiboot2TagEfi32Ih* = object
  ## The `Efi32Ih` tag is used to pass the 386 EFI image handler. Usually
  ## the bootloader image handle.
  info*: Multiboot2Tag
  pointer*: uint32

type Multiboot2TagEfi64Ih* = object
  ## The `Efi64Ih` tag is used to pass the AMD64 EFI image handler. Usually
  ## the bootloader image handle.
  info*: Multiboot2Tag
  pointer*: uint64

type Multiboot2TagLoadBaseAddr* = object
  ## The `LoadBaseAddr` tag is used to pass the load base address to the
  ## kernel. Only provided if image has relocatbale header tag.
  info*: Multiboot2Tag
  loadBaseAddr*: uint32

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
