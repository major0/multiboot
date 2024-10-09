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

const
  Multiboot1MemoryAvailable* = MultibootMemoryAvailable
  Multiboot1MemoryReserved* = MultibootMemoryReserved
  Multiboot1MemoryAcpiReclaimable* = MultibootMemoryAcpiReclaimable
  Multiboot1MemoryNvs* = MultibootMemoryNvs
  Multiboot1MemoryBadram* = MultibootMemoryBadram

const
  Multiboot1FramebufferTypeIndexed* = MultibootFramebufferTypeIndexed
  Multiboot1FramebufferTypeRgb* = MultibootFramebufferTypeRgb
  Multiboot1FramebufferTypeEgaText* = MultibootFramebufferTypeEgaText
