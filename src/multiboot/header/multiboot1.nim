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
  Multiboot1HeaderAlign* = 4 ## How many bytes from the start of the file
                             ## we search for the header.
  Multiboot1HeaderMagic* = 0x1BADB002 ## The magic field should contain this.

type
  Multiboot1HeaderFlag {.size: sizeof(uint32) .} = enum
    PageAlign  ## Flags set in the 'flags' member
               ## of the multiboot header. Align all
               ## boot modules on i386 page (4KB)
               ## boundaries.
    MemoryInfo ## Must pass memory information to OS.
    VideoMode  ## Must pass video information to OS.
    AoutKludge = 20 ## This flag indicates the use of the address
                    ## fields in the header.
  Multiboot1HeaderFlags* {.size: sizeof(uint32).} = set[Multiboot1HeaderFlag]

type Multiboot1Header* = object
  magic*: uint32 ##  Must be Multiboot1Magic - see above.
  flags*: Multiboot1HeaderFlags
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
