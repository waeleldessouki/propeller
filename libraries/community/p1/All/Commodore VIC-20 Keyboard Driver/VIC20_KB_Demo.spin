''------------------------------------------------------------------------------------------------
'' Commodore VIC-20 Keyboard Driver Demo
''
'' Copyright (c) 2018 Mike Christle
'' See end of file for terms of use.
''
'' History:
'' 1.0.0 - Original release - 10/23/2018.
''------------------------------------------------------------------------------------------------

CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

OBJ

  key : "VIC20_KB"
  pst : "Parallax Serial Terminal"
                             
PUB MainRoutine | K

  pst.Start(115200)
  key.Start

  repeat
    K := key.Key
    if K <> 0
      pst.Dec(K)
      pst.Char(pst#NL)

{{
┌────────────────────────────────────────────────────────────────────────────┐
│                       TERMS OF USE: MIT License                            │                                                            
├────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining       │
│a copy of this software and associated documentation files (the "Software"),│
│to deal in the Software without restriction, including without limitation   │
│the rights to use, copy, modify, merge, publish, distribute, sublicense,    │
│and/or sell copies of the Software, and to permit persons to whom the       │
│Software is furnished to do so, subject to the following conditions:        │                                                           │
│                                                                            │                                                  │
│The above copyright notice and this permission notice shall be included in  │
│all copies or substantial portions of the Software.                         │
│                                                                            │                                                  │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  │
│IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    │
│FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL     │
│THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER  │
│LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     │
│FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         │
│DEALINGS IN THE SOFTWARE.                                                   │
└────────────────────────────────────────────────────────────────────────────┘
}}                    