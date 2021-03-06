''=============================================================================
'' @file     OW-SearchDemo
'' @target   Propeller
''
'' This demonstration routine searches the 1-wire network all lists all devices
'' found. The results are displayed using vga_text or tv_text.
''
''   ───OW-SearchDemo
''        ├──OneWire
''        └──vga_text
''
''
'' @author   Cam Thompson, Micromega Corporation
''
'' Copyright (c) 2006 Parallax, Inc.
'' See end of file for terms of use.       
'' 
'' @version  V1.0 - July 18, 2006
'' @changes
''  - original version
''=============================================================================

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  OW_DATA           = 0                                 ' 1-wire data pin

  SKIP_ROM          = $CC                               ' 1-wire commands
  READ_SCRATCHPAD   = $BE
  CONVERT_T         = $44

  CLS               = $00                               ' clear screen
  HOME              = $01                               ' home
  CR                = $0D                               ' carriage return
  DEG               = $B0                               ' degree symbol

  MAX_DEVICES       = 10                                ' maximum number of 1-wire devices
  
OBJ

  term          : "vga_text"
  'term          : "tv_text"
  ow            : "OneWire"
  fp            : "FloatString"
  f             : "FloatMath"                           ' could also use Float32

VAR

  long  addressList[MAX_DEVICES*2]                      ' 64-bit address buffer

PUB main | n, i, p

  term.start(16)                                        ' start VGA terminal
' term.start(12)                                        ' start TV terminal

  setColor(6)
  displayString(0, 0, string("      1-Wire Search Demo       "))
  setColor(0)

  ow.start(OW_DATA)                                     ' start 1-wire object, pin 0

  n := ow.search(0, MAX_DEVICES, @addressList)          ' search the 1-wire network
  displayString(1, 7, string("Devices found: "))
  term.dec(n)

  setColor(3)
  displayString(2, 0, string("Device"))
  displayString(2, 7, string("    Address     "))
  'term.str(string(CR, "Device Address"))                ' display each device
  setColor(0)

  p := @addressList
  repeat n 
    term.out(CR)
    case byte[p]                                        ' display family name
      $01:    term.str(@ds2401_name)
      '$05:    term.str(@ds2405_name)
      $10:    term.str(@ds1820_name)
      $22:    term.str(@ds1822_name)
      other:  term.str(@unknown_name)
    printAddress(p)                                     ' display 64-bit address
    if ow.crc8(8, p) <> 0                               ' check crc of address
      term.str(string("?crc"))
    p += 8
   
PUB printAddress(a)
  repeat 8
    term.hex(byte[a++], 2)

PUB displayString(row, col, s)
  setPosition(row, col)
  term.str(s)

PUB setPosition(row, col)
  if row => 0
    term.out($B)
    term.out(row)
  if col => 0
    term.out($A)
    term.out(col)

PUB setColor(c)
  term.out($C)
  term.out(c)

DAT
ds2401_name     byte    "DS2401 ", 0
ds2405_name     byte    "DS2405 ", 0 
ds1820_name     byte    "DS1820 ", 0 
ds1822_name     byte    "DS1822 ", 0 
unknown_name    byte    "       ", 0