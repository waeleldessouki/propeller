{{
*****************************************
* RX Demo version 1.4                   *
* Author: Rich Harman                   *
* Copyright (c) 2009 Rich Harman        *
* See end of file for terms of use.     *
*****************************************


*****************************************************************
 Read RC inputs on 6 pins, output same values on 6 more pins
*****************************************************************
 Coded by Rich Harman  15 Jul 2009
*****************************************************************
 Thanks go to SamMishal for his help getting the counters to work
*****************************************************************

Theory of Operation:

Launch three cogs using the object RX.spin which in turn each start
two counters.

This approach does NOT need the pulses to arrive on the pins in any
certain order, nor does it require the pins to be all connected.

Whatever pulse is received on pin 1 is then sent out to pin 7 and
so on.

}}
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000


VAR
  long  pulsewidth[6]

DAT
  pins  LONG 1, 2, 3, 4, 5, 6

OBJ
  LCD        : "LCD_16X2_GG"
  RX         : "RX"
  servo      : "Servo32v6"

PUB Init

  LCD.start
  waitcnt(clkfreq/4 + cnt)
  LCD.clear
  LCD.str(string("RX Demo v 1.4 "))
  waitcnt(clkfreq + cnt)
  LCD.clear
  servo.start

  Rxinput

PUB RXinput  | i, pulse[6]

  LCD.clear

  RX.start(@pins,@pulseWidth)
  waitcnt(clkfreq/2 + cnt)

  repeat
    repeat i from 0 to 5
      pulse[i] := pulsewidth[i]                              ' capture pulse values from pins 1 - 6
      out(i + 7, pulse[i])                                   ' send servo pulses to pins 7 - 12

    lcd.debug(pulse[0], 4, 1, 4)                   '(value, X, Y, decimal?, digits, places)
    lcd.debug(pulse[1], 10, 1, 6)
    lcd.debug(pulse[2], 16, 1, 6)
    lcd.debug(pulse[3], 4, 2, 4)
    lcd.debug(pulse[4], 10, 2, 6)
    lcd.debug(pulse[5], 16, 2, 6)


PUB out(_pin, _pulse)

    servo.set(_pin, _pulse)


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
│ARISING FROM,     OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}        
