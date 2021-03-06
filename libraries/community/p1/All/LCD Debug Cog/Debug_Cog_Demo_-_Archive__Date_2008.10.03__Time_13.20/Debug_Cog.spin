{{
***************************************************************
*  Debug_Cog v1.1                                             *
*  Author: Brandon Nimon                                      *
*  Copyright (c) 2008 Parallax, Inc.                          *
*  See end of file for terms of use.                          *
***************************************************************
* This object can be used as a drop-in replacement for the    *
* Debug_Lcd object. It uses a cog to control the LCD, thus    *
* freeing the source cog of the wait time required to display *
* information on the LCD. The only method that is missing is  *
* the custom method which allowed custom character maps. An   *
* added method: cr, it is used for carriage return (same as   *
* putc($0D) or putc(13)).                                     *
* Version 1.1 uses a queue system to allow for up to four     *
* commands to be sent in short succession without great delay *
* (only a few cycles each to set variables). The commands     *
* will be executed in order by the debug cog. If a fifth      *
* command is given before the first has completed the source  *
* cog will have to wait until the fourth position is made     *
* available (and so on). This greatly reduces the wait time   *
* to about 30% for even just two long strings compared to     *
* version 1.0, and the reduction is increased for each        *
* command sent (up to four).                                  *
***************************************************************
}}
OBJ

  lcd : "serial_lcd"                                     ' driver for Parallax Serial LCD
  num : "simple_numbers"                                 ' number to string converter


VAR

  long val1[4], val2[4]                                  ' values passed to cog
  long ntype                                             ' type of values
  long debugstack[100]                                   ' stack
  byte cogon, cog                                        ' keep track of cog execution

  
PUB init(pin, baud, lines)                               ' initiate cogs

  stop
  cogon := (cog := cognew(debug(pin, baud, lines, @val1, @val2, @ntype), @debugstack)) > 0

  
PUB stop                                                 ' stop cogs if already in use
  if cogon~
    cogstop(cog)


PUB debug (pin, baud, lines, val1Addr, val2Addr, typeAddr) | type
  lcd_init(pin, baud, lines)                             ' start up the LCD obj  

  REPEAT
    REPEAT UNTIL ((type := byte[typeAddr]) <> 0)         ' repeat until ntype is changed
      longmove(val1Addr, val1Addr + 4, 3)
      long[val1Addr + 12]~
      longmove(val2Addr, val2Addr + 4, 3)
      long[val2Addr + 12]~
      long[typeAddr] >>= 8
      
    CASE type
      1 : lcd.putc(long[val1Addr])
      2 : lcd.str(long[val1Addr])
      3 : lcd.str(num.dec(long[val1Addr]))
      4 : lcd.str(num.decf(long[val1Addr], long[val2Addr]))
      5 : lcd.str(num.decx(long[val1Addr], long[val2Addr]))
      6 : lcd.str(num.hex(long[val1Addr], long[val2Addr]))
      7 : lcd.str(num.ihex(long[val1Addr], long[val2Addr]))
      8 : lcd.str(num.bin(long[val1Addr], long[val2Addr]))
      9 : lcd.str(num.ibin(long[val1Addr], long[val2Addr]))
      10: lcd.cls                     
      11: lcd.home
      12: lcd.gotoxy(long[val1Addr], long[val2Addr])
      13: lcd.clrln(long[val1Addr])
      14: lcd.cursor(long[val1Addr])
      15: lcd.displayOn
      16: lcd.displayOff
      17: lcd.backLight(long[val1Addr])
    longmove(val1Addr, val1Addr + 4, 3)
    long[val1Addr + 12]~
    longmove(val2Addr, val2Addr + 4, 3)
    long[val2Addr + 12]~
    long[typeAddr] >>= 8    


PUB lcd_init(pin, baud, lines)

'' Initializes LCD object          

  lcd.init(pin, baud, lines)    
 

PUB putc(txbyte)

'' Send a byte to the LCD

  REPEAT UNTIL ntype.byte[3] == 0   ' repeat until ntype is reset
  val1[3] := txbyte
  ntype.byte[3] := 1
  

PUB cr

'' Sends a carrage return

  REPEAT UNTIL ntype.byte[3] == 0   ' repeat until ntype is reset
  val1[3] := $0D
  ntype.byte[3] := 1          
  
  
PUB str(strAddr)

'' Send a string to the LCD

  REPEAT UNTIL ntype.byte[3] == 0   ' repeat until ntype is reset
  val1[3] := strAddr
  ntype.byte[3] := 2  


PUB dec(value) 

'' Send a signed decimal number to the LCD

  REPEAT UNTIL ntype.byte[3] == 0   ' repeat until ntype is reset
  val1[3] := value
  ntype.byte[3] := 3    


PUB decf(value, width) 

'' Send a signed decimal value in a space-padded and fixed-width field to the LCD

  REPEAT UNTIL ntype.byte[3] == 0   ' repeat until ntype is reset
  val1[3] := value
  val2[3] := width
  ntype.byte[3] := 4   
  

PUB decx(value, digits) 

'' Sends a signed, zero-padded decimal to the LCD
'' negative values will add an additional digit

  REPEAT UNTIL ntype.byte[3] == 0   ' repeat until ntype is reset
  val1[3] := value
  val2[3] := digits
  ntype.byte[3] := 5   


PUB hex(value, digits)

'' Sends a hexadecimal number to the LCD

  REPEAT UNTIL ntype.byte[3] == 0   ' repeat until ntype is reset
  val1[3] := value
  val2[3] := digits
  ntype.byte[3] := 6  


PUB ihex(value, digits)

'' Sends an indicated ($) hexadecimal number to the LCD

  REPEAT UNTIL ntype.byte[3] == 0   ' repeat until ntype is reset
  val1[3] := value
  val2[3] := digits
  ntype.byte[3] := 7     


PUB bin(value, digits)

'' Sends a binary number to the LCD

  REPEAT UNTIL ntype.byte[3] == 0   ' repeat until ntype is reset
  val1[3] := value
  val2[3] := digits
  ntype.byte[3] := 8  


PUB ibin(value, digits)

'' Sends an indicated (%) binary number to the LCD

  REPEAT UNTIL ntype.byte[3] == 0   ' repeat until ntype is reset
  val1[3] := value
  val2[3] := digits
  ntype.byte[3] := 9       
    

PUB cls

'' Clears LCD

  REPEAT UNTIL ntype.byte[3] == 0   ' repeat until ntype is reset
  ntype.byte[3] := 10 


PUB home

'' Moves cursor to space 0, 0

  REPEAT UNTIL ntype.byte[3] == 0   ' repeat until ntype is reset
  ntype.byte[3] := 11  
  

PUB gotoxy(col, line)

'' Moves cursor to col, line position

  REPEAT UNTIL ntype.byte[3] == 0   ' repeat until ntype is reset
  val1[3] := col
  val2[3] := line
  ntype.byte[3] := 12   

  
PUB clrln(line)

'' Clears a line

  REPEAT UNTIL ntype.byte[3] == 0   ' repeat until ntype is reset
  val1[3] := line  
  ntype.byte[3] := 13  


PUB cursor(type)

'' Selects cursor type
''   0 : cursor off, blink off  
''   1 : cursor off, blink on   
''   2 : cursor on, blink off  
''   3 : cursor on, blink on

  REPEAT UNTIL ntype.byte[3] == 0   ' repeat until ntype is reset
  val1[3] := type
  ntype.byte[3] := 14
       

PUB display(status)

'' Turns LCD display on and off; use display(false) and display(true)

  REPEAT UNTIL ntype.byte[3] == 0   ' repeat until ntype is reset
  if status
    ntype.byte[3] := 15    
  else
    ntype.byte[3] := 16    

      
PUB backLight(status)

'' Turns LCD backlight on and off; use backlight(false) and backlight(true)

  REPEAT UNTIL ntype.byte[3] == 0   ' repeat until ntype is reset
  val1[3] := status  
  ntype.byte[3] := 17   

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