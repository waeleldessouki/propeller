{{

┌──────────────────────────────────────────┐
│ Demo program for VGA_HiResTerminal 1.0   │
│ Author: Eric Ratliff                     │               
│ Copyright (c) 2008 Eric Ratliff          │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘

VGA_HiResTerminal_Demo, to test operation of VGA version of terminal object 'VGA_HiResTerminal'
by Eric Ratliff 2008.7.4

}}
CON _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

OBJ
  Terminal :    "VGA_HiResTerminal"
  Num   :       "Numbers"       ' string manipulations, used here just for a formatting constant

VAR
  long Sync ' place where screen refresh timing is signaled, use is optional
  
PUB go 
  Terminal.Start(Terminal#DevBoardVGABasePin,@Sync)' start showing the Duty variable on the video screen
  Terminal.out_literal("A")
  Terminal.SetXY(2,6)
  Terminal.dec_formattad(12345,Num#DSDEC14)
  repeat

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