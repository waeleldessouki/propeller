{{
                                         
                                          DIGITAL I/O BOARD DEMO
                                         
   


┌──────────────────────────────────────────────────────┐
│ DIGITAL I/O Board Shift Register Demonstration       │
│ Author: Michael du Plessis                           │               
│ Copyright (c) 2011 Optimho                           │               
│ See end of file for terms of use.                    │                
└──────────────────────────────────────────────────────┘ 

This demonstration file is written for Parallax DIGITAL I/O BOARD
The Parallax Digital I/O Board makes use of two shift registers, namely the
74HC595 (Serial to Parallel) and the 74HC165 (Parallel to Serial) Shift registers
This program starts two cogs to handle shifting-out(SHiftOUT) and shifting-in(ShiftIN) data simultaneously 

To demonstrate the functionality and speed is program counts up from 1 to 255  


The Digital I/O Board should be supplied from a 9-12v supply for relay power for the demonstration to work.
The inputs also need 9-12V to drive inputs.  
Wiring Connections.
-------------------

 SCLK_RLY -------P12
 LAT_RLY  -------P13
 DATA_RLY -------P11
 SCLK_IN  -------P9
 LOAD_IN  -------P8
 DIN      -------P10
 OE_RLY   -------P14 or GND
 VSS      -- +3.3volts
 VDD      -- GND
 V+       not connected

Jumpers are in there default positions_

_______________________________
Version 1.0   -  Original file


---------------------------------
Enhancements and things to do:
---------------------------------
1. SHiftIN shifts data out so that data ends up MSB first, Fix this.
                                                        This has been done now
2. Change ShiftOUT and ShiftIN to assembly code implementation.

 
}}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

 SCLK_RLY=12
 LAT_RLY =13
 DATA_RLY=11
 SCLK_IN=9
 LOAD_IN=8
 DIN =  10
 OE_RLY = 14


  
VAR
byte OUT_REG
byte IN_REG

OBJ    Sout : "ShiftOUT"
       
      
PUB main
OUT_REG:=0
 Sout.start(SCLK_RLY,LAT_RLY,DATA_RLY,OE_RLY,@OUT_REG)                    ''Start Shiftout 


 repeat
   waitcnt(cnt+clkfreq/10)                                                 ''Slow things down if you want to slow things
   OUT_REG:=OUT_REG+1  'Make the output register the same as               ''Send the contents of the IN_REG to the OUT_REG
                                                                           ''This will output the data in the IN_REG to the
                                                                           ''Output Relays 


DAT
     {<end of object code>}
     
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