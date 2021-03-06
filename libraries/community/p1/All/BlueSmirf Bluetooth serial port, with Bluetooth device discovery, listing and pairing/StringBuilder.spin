{{

┌─────────────────────────────────────┐
│ StringBuilder.spin     Version 1.00 │
│ Author: Mathew Brown                │               
│ Released under Parallax MIT licence │               
│ See end of file for terms of use.   │                
└─────────────────────────────────────┘

Simple (non dynamic strings, IE NOT heap based) string building/conjugation methods
 
}}


VAR

  byte StrBuff[128]

  byte Index

PUB New 'Declare new string (resets string index pointer, and returns a Z-terminated null string)

  Index~
  StrBuff[Index]~
  
  return @StrBuff

PUB AddChar(Char) 'Append a single character to the end of the current string, and return the string (Z terminated)

  StrBuff[Index++] := Char
  StrBuff[Index]~
  
  return @StrBuff

PUB AddStr(StrPtr) 'Append the string (passed by pointer) to the end of the current string, and return the string (Z terminated)

  repeat while byte[StrPtr]
    AddChar(byte[StrPtr++])

  return @StrBuff

PUB AddDec(value)|i  'Append an ASCII string representing passed value (passed by value) to the end of the current string, and return the string (Z terminated) 

  if value < 0
    -value
    AddChar("-")

  i := 1_000_000_000

  repeat 10
    if value => i
      AddChar(value / i + "0")
      value //= i
      result~~
    elseif result or i == 1
      AddChar("0")
    i /= 10


  return @StrBuff


DAT
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