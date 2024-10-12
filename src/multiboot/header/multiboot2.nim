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
#
# The header tags are terminated with an End tag, which is just an `empty`
# tag of Multiboot2HeaderTag type with the set set correctly.

const
  Multiboot2HeaderAlign* = 8
  Multiboot2HeaderMagic* = 0xe85250d6 ##  The magic field should contain this.

type Multiboot2Header* = object
  magic*: uint32
    ## `magic` **must** be set to `Multiboot2HeaderMagic`
  architecture*: uint32 ## ISA
  length*: uint32
    ## `length` should be set to the total length. I.e. the header and all
    ## tags.
  checksum*: uint32
    ## The above fields plus this one **must** equal ``0 mod 2^32``.
    ## E.g. ``-(magic + architecture + length)``

type Multiboot2Architecture* {.size: sizeof(uint32).} = enum
  I386 = 0,
  Mips32 = 4,

type
  Multiboot2HeaderFlag* {.size: sizeof(uint16).} = enum
    Optional,
      ## If the `Optional` flag is set, then this tag is optional. If not
      ## set then this tag is required. Not setting this bit does not
      ## garantee that this tag will be present in the MBI.
      ## See `Multiboot2HeaderTag` for more information.
  Multiboot2HeaderFlags* {.size: sizeof(uint16)} = set[Multiboot2HeaderFlag]

type Multiboot2HeaderTagType* {.size: sizeof(uint16).} = enum
  ## Header tag types set during compilation to instruct the bootloader on
  ## how to boot the kernel.
  End, ## Tag structure is `Multiboot2HeaderTagEnd`
  InformationRequest,
    ## Tag structure is `Multiboot2HeaderTagInformationRequest`
  Address, ## Tag structure is `Multiboot2HeaderTagAddres`
  EntryAddress, ## Tag structure is `Multiboot2HeaderTagEntryAddress`
  ConsoleFlags, ## Tag structure is `Multiboot2HeaderTagConsoleFlags`
  Framebuffer, ## Tag structure is `Multiboot2HeaderTagFramebuffer`
  ModuleAlign, ## Tag structure is `Multiboot2HeaderTagModuleAlign`
  EfiBs, ## Tag structure is `Multiboot2HeaderTagEfiBs`
  EntryAddressEfi64,
    ## Tag structure is `Multiboot2HeaderTagEntryAddressEfi64`
  Relocatable, ## Tag structure is `Multiboot2HeaderTagRelocatable`

type Multiboot2HeaderTag* = object
  tagType*: Multiboot2HeaderTagType
  flags*: Multiboot2HeaderFlags
    ## Per tag flags. If bit 0 is set, this tag is optional.
    ##
    ## This field seems to have been designed such that various tag types
    ## could use the other 15 bits, but according to the spec, only bit 0
    ## is used for all tag types. The most obvious example of this is the
    ## `Multiboot2HeaderTagConsoleFlags`_, which could easily have used the
    ## other 15 bits, but instead uses a consoleFlags field.
  size*: uint32
    ## Total size of tag, including per-tag data

type Multiboot2HeaderTagEnd* = Multiboot2HeaderTag
  ## The end tag is just an empty Tag. The `info.type` must be set to
  ## `Multiboot2HeaderTagType`_ `End`, and the size must be equal to the
  ## sizeof(`Multiboot2HeaderTag`_). E.g. 8

type Multiboot2HeaderTagInformationRequest* = object
  ## Inform the bootloader as to what information the OS needs. It should
  ## be noted that if `Multiboot2HeaderFlag`_ `Optional` flag is not set
  ## in `flags`, that that does not garantee the requested information
  ## will be present in he MBI. The Bootloader has no obligation to
  ## provide an MBI tag for non-existant resources. E.g. requesting
  ## video/fb information when no video/fb device is present results in
  ## no video/vb MBI data being passed from the bootloader to the OS.
  info*: Multiboot2HeaderTag
    ## `info.type` must be set to `Multiboot2HeaderTagType.InformationRequest`
  requests*: UncheckedArray[uint32]

type Multiboot2HeaderTagAddress* = object
  ## Indicates binary address information for non-ELF kernels. This tag
  ## is not necessary for ELF kernels and only exists to aid in booting
  ## kernels of alternate formats. E.g. a.out.
  ##
  ## All of the address fields in this tag must be physical addresses.
  info*: Multiboot2HeaderTag
    ## `info.tagType` **must** be `Multiboot2TagType.Address`
  headerAddr*: uint32
    ## Address of the Multiboot2 header
  loadAddr*: uint32
    ## Address of the beginning of the text segment. The offset in the OS
    ## image file at which to start loading is defined by the offset at
    ## which the header was found, minus ``(headerAddr - loadAddr)``. `lastAddr`
    ## **must** be less than or equal to `headerAddr`.
  loadEndAddr*: uint32
    ## End of the load addr. (`loadEndAddr` - `loadAddr`) specifies load
    ## size.
  bssEndAddr*: uint32
    ## bootloader must initialize this area to zero, and reserves the
    ## memory it occupies to avoid placing boot modules and other data
    ## to the OS in this area. If `bssEndAddr` is 0, the bootloader will
    ## assume that the text and data segments are the whole of the OS
    ## image.

type Multiboot2HeaderTagEntryAddress* = object
  ## All address fields in this tag must be physical addresses.
  info*: Multiboot2HeaderTag
    ## `info.tagType`_ must be `Multiboot2TagType.EntryAddress`_
  entryAddr*: uint32
    ## Physical address which the bootloader should jump to in order to
    ## start the kernel.

type
  MultiBoot2ConsoleFlag* {.size: sizeof(uint32).} = enum
    ConsoleRequired,
    EgaTextSupported,
  Multiboot2ConsoleFlags* {.size: sizeof(uint32).} = set[MultiBoot2ConsoleFlag]

type Multiboot2HeaderTagConsoleFlags* = object
  info*: Multiboot2HeaderTag
    ## info.tagType must be `Multiboot2HeaderTagType.ConsoleFlags`
  consoleFlags*: Multiboot2ConsoleFlags
    ## Flags indicating what console to use.
    ## Note: not setting bit0 (`Optional`) in `info.flags` will not
    ## garantee that any console will be made available. E.g. if there are
    ## no console devices available, then the bootloader will still load
    ## the kernel.

type Multiboot2HeaderTagFramebuffer* = object
  ## This tag specifies the preferred graphics mode to usse.
  info*: Multiboot2HeaderTag
  width*: uint32
  height*: uint32
  depth*: uint32

type Multiboot2HeaderTagModuleAlign* = object
  ## If this tag is present, then all modules must be page aligned.
  info*: Multiboot2HeaderTag
    ## `info.tagType` **must** be `Multiboot2TagType.ModuleAlign`

type Multiboot2HeaderTagEfiBs* = object
  ## If this tag is present, then the kernel supports starting without
  ## terminating EFI boot services. This means that the kernel must
  ## support EFI.
  info*: Multiboot2HeaderTag
    ## `info.tagType` **must** be `Multiboot2TagType.EfiBs`

type Multiboot2HeaderTagEfiI386* = object
  ## All of the address fields in this tag must be physical addresses.
  ## This will cause the bootloader to ignore the entrypoint specified in
  ## the ELF header.
  ## This tag is ignored on EFI amd64 systems.
  info*: Multiboot2HeaderTag
    ## `info.tagType` **must** be `Multiboot2TagType.EfiI386`
  entryAddr*: uint32
    ## The physical address the bootloader should jump to in order to
    ## start running EFI code.

type Multiboot2HeaderTagEntryAddressEfi64* = object
  ## All address fields in this tag must be physical addresses.
  ## This will cause the bootloader to ignore the entrypoint specified in
  ## the ELF header.
  ## This tag is only taken into account on EFI amd64 systems.
  info*: Multiboot2HeaderTag
    ## `info.tagType` **must** be `Multiboot2TagType.EntryAddressEfi64`
  entryAddr*: uint32
    ## Physical address which the bootloader should jump to in order to
    ## start the kernel.

type Multiboot2LoadPreference* {.size: sizeof(uint16).} = enum
  None,
    ## No address placement suggestions.
  Low,
    ## Try to load the kernel as low in memory as possible, but no
    ## lower than `Multiboot2HeaderTagRelocatable.minAddr`.
  High,
    ## Try to load the kernel as high in memory as possible, but no
    ## higher than `Multiboot2HeaderTagRelocatable.maxAddr`.

type Multiboot2HeaderTagRelocatable* = object
  ## This tag indicates that the kernel is relocatable.
  ## All addresses in this tag must be physical addresses.
  info*: Multiboot2HeaderTag
    ## `info.tagType` **must** be `Relocatable`
  minAddr*: uint32
    ## Lowest possible address to load the kernel.
  maxAddr*: uint32
    ## No portion of the kernel should be loaded above this address.
  align*: uint32
    ## Alignment in Memory. E.g. 4096
  preference*: Multiboot2LoadPreference
    ## Load address placement suggestions for the bootloader.
    ## E.g. `None`, `Low`, `High` This can be used to inform the
    ## bootloader to load the kernel into as low address as
    ## possible, but no lower than `minAddr`.

