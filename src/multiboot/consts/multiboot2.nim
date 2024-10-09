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
  Multiboot2Search* = 32768 ##  How many bytes from the start of the file we search for the header.
  Multiboot2HeaderAlign* = 8
  Multiboot2HeaderMagic* = 0xe85250d6 ##  The magic field should contain this.
  Multiboot2BootloaderMagic* = 0x36d76289 ##  This should be in %eax.
  Multiboot2ModAlign* = 0x00001000 ##  Alignment of multiboot modules.
  Multiboot2InfoAlign* = 0x00000008 ##  Alignment of the multiboot info structure.

const Multiboot2TagAlign* = 8

#  Flags set in the 'flags' member of the multiboot header.
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

const
  Multiboot2MemoryAvailable* = MultibootMemoryAvailable
  Multiboot2MemoryReserved* = MultibootMemoryReserved
  Multiboot2MemoryAcpiReclaimable* = MultibootMemoryAcpiReclaimable
  Multiboot2MemoryNvs* = MultibootMemoryNvs
  Multiboot2MemoryBadRAM* = MultibootMemoryBadram

const
  Multiboot2FramebufferTypeIndexed* = MultibootFramebufferTypeIndexed
  Multiboot2FramebufferTypeRgb* = MultibootFramebufferTypeRgb
  Multiboot2FramebufferTypeEgaText* = MultibootFramebufferTypeEgaText

