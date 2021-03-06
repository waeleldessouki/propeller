'' File: Hitatchi_test.spin
'' test the driver objects
{{
┌──────────────────────────────────────────┐
│ Hitachi LCD compatible Library  tests    │
│ Author: Frank  Freedman                  │
│ Copyright (c) 2011 Frank Freedman        │
│ See end of file for terms of use.        │
└──────────────────────────────────────────┘

}}

OBJ
  HITOUT : "HI_LCD_CNT"

VAR
    byte  CHROUT DSPADX


Pub Main | init1

repeat
  init1 := HITOUT.init_DISP     ' init the display.

  test_dev                      ' Test routines to verify the functionality of the driver.


Pub test_DEV                        ' run the test suite

CHROUT := $21             'start line 1 fill by direct addx test
DSPADX := %10000000
repeat $28
   HITOUT.CMD_OUT(DSPADX)
   HITOUT.DAT_OUT(CHROUT)
   DSPADX ++
   CHROUT ++
waitcnt(cnt + clkfreq*2)

CHROUT := $31             'start line 2 auto cursor right test
DSPADX := %11000000
HITOUT.CMD_OUT(DSPADX)
repeat $28
   HITOUT.DAT_OUT(CHROUT)      'incr char, auto cursor to  next char
   CHROUT ++
waitcnt(cnt + clkfreq*2)



HITOUT.CMD_OUT(%00000001)        ' reset disp and cursor to 00 pos
waitcnt(cnt + clkfreq/10) ' delay longer than busy lasts

CHROUT := $54           ' start line 1st and 2nd char test
DSPADX := %10000000
repeat 2
   HITOUT.CMD_OUT(DSPADX)      ' send start address
   HITOUT.DAT_OUT(CHROUT)      ' send   char for start
   DSPADX ++

CHROUT := $54           ' start line 1 last two charstest
DSPADX := %10100110
repeat 2
   HITOUT.CMD_OUT(DSPADX)      ' send start address
   HITOUT.DAT_OUT(CHROUT)      ' send   char for start
   DSPADX ++

CHROUT := $35             'start begining line 2 test
DSPADX := %11000000
repeat 2
   HITOUT.CMD_OUT(DSPADX)
   HITOUT.DAT_OUT(CHROUT)
   DSPADX ++

CHROUT := $35             '  end of line 2 test
DSPADX := %11100110
repeat 2
   HITOUT.CMD_OUT(DSPADX)      ' send start address
   HITOUT.DAT_OUT(CHROUT)      ' send   char for start
   DSPADX ++
waitcnt(cnt + clkfreq)         ' pause for next iteration

' END OF  THE TEST SECTION

{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}
