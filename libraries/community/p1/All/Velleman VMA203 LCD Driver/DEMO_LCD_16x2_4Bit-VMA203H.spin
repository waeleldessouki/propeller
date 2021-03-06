''File: VMA203-LCD_16x2_4Bit-DEMOH.spin
' Modified by Miro Kefurt   (mirox@aol.com)

''See Chapter 7 PARALLAX PROPELLER          e-Book  by Miro Kefurt 
' Tested OK     2018-08-24      PAB and VMA203
' Version A     2018-08-24      OBJ  = LCD : "LCD_16x2_4Bit-VMA203A" 
' Version B     2018-08-24 OK   Replace waitcnt(clkfreq/4 + cnt)
' Version C     2018-08-24 OK   OBJ  = LCD : "LCD_16x2_4Bit-VMA203C"          
' Version D     2018-08-24      Turn Display off at the END of demo
' Version E     2018-08-24      Turn Display off/on 12 times before END
' Version F     2018-08-25      Add  Blink the display 20 times at a 1Hz rate
' Version G     2018-08-25      Add License
' Version H     2018-08-25      Add Number count on Line 1 and Letter count on Line 2 

CON
                         
  _XINFREQ      = 5_000_000                     ' Crystal Ferquency 5MHz
  _CLKMODE      = XTAL1 + PLL16X                ' External Crystal @ 16x = 80MHz

OBJ
  LCD : "LCD_16x2_4Bit-VMA203H"
  
PUB DEMO  | i
  LCD.START                                     ' Start LCD Object

  LCD.CLEAR                                     ' Clears display 
  
  LCD.MOVE(3,1)                                 ' Move Cursor to Position 3 Line 1
  LCD.STR(STRING("Hello World!"))               ' Print String

  LCD.Blink (8)                                 ' Blink the display 8 times at a 1Hz rate

  
  waitcnt(clkfreq*2 + cnt)                     ' Rest 2 seconds
  LCD.MOVE(3,2)                                ' Move Cursor to Position 3 Line 2 
  LCD.STR(STRING(" 1 - 5 = "))                 ' Print String

  LCD.DEC (1-5)                                ' Print Decimal Result

  waitcnt(clkfreq*4 + cnt)                     ' Rest 4 seconds 
  LCD.CLEAR                                             'clears display  

  LCD.STR(STRING("HEX(255) = 0x"))             ' Print String  

  LCD.HEX(255,2)                               ' Print Hex Number 

  waitcnt(clkfreq*4 + cnt)                     ' Rest 4 seconds 
  LCD.CLEAR                                    ' Clears display  

  LCD.STR(STRING("DEC(170) = "))               ' Print String   

  LCD.MOVE(1,2)                                ' Move Cursor to Position 1 Line 2
  
  LCD.BIN(170,8)                               ' Print Binary Number  
  waitcnt(clkfreq*4 + cnt)                     ' Rest 4 seconds 
  LCD.CLEAR                                    ' Clears display  

  i := 48                                        'Set first CHAR to 48 = 0
  repeat while i < 58
    LCD.CHAR (i)                                 ' Print CHAR  (0 to 9)
    i := i+1                                     ' Increment i by one
    waitcnt(clkfreq + cnt)                       ' Wait 1 second

  LCD.MOVE(1,2)                                 ' Move Cursor to Position 1 Line 2  

  i := 65                                          'Set first CHAR to 48 = A
  repeat 16
    LCD.CHAR (i)                                 ' Print CHAR  (A to P)
    i := i+1                                     ' Increment i by one
    waitcnt(clkfreq + cnt)                       ' Wait 1 second
    
  waitcnt(clkfreq*4 + cnt)                       ' Rest 4 seconds 
  LCD.CLEAR                                      ' Clears display  

  LCD.MOVE(1,1) ' 1234567890123456              ' Move Cursor to Position 1 Line 1    
  LCD.STR(STRING("VMA203 DEMO END."))           ' Print String 
  LCD.MOVE(4,2)                                 ' Move Cursor to Position 4 Line 2 
  LCD.STR(STRING("HAVE FUN !"))                 ' Print String    


  waitcnt(clkfreq*8 + cnt)                     ' Rest 8 seconds 
  LCD.DOFF                                             'Turns display OFF

  repeat 6                                     ' Repeat 6 times
    waitcnt(clkfreq + cnt)                     ' Rest 1 s 
    LCD.DON                                             'Turns display ON

    waitcnt(clkfreq + cnt)                     ' Rest 1 s 
    LCD.DOFF                                             'Turns display OFF

  waitcnt(clkfreq/2 + cnt)                     ' Rest 1/2 s 
  LCD.DON                                             'Turns display ON 

  waitcnt(clkfreq*4 + cnt)                     ' Rest 4 seconds 
  LCD.CLEAR                                    ' Clears display  

  waitcnt(clkfreq + cnt)                       ' Rest 1 s  
  LCD.END                                               'ends LCD


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
  