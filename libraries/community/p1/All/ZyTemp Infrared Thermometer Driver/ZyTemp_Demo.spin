{{      
┌──────────────────────────────────────────┐
│ ZyTemp IR Thermometer Demo v1.0          │
│ Author: Pat Daderko (DogP)               │               
│ Copyright (c) 2010                       │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘

This demonstrates reading object and ambient temperatures with a ZyTemp (http://www.zytemp.com/) infrared
thermometer.  Embedded modules can be purchased, or they are commonly found as rebranded low cost handheld
devices.  This has been tested with TN105i2 (1:1 distance to spot) and TN203 (6:1 distance to spot, plus laser).
These were rebranded as CEN-TECH #93983 and #93984 respectively, from Harbor Freight.

These modules communicate using an SPI-like protocol.  The thermometer must be the Master though, so I modified
the SPI engine to support Slave operation (and included it with this demo).  The pins are accessible by opening
the case of either thermometer.  There's a 0.1" header at the bottom of both PCBs with labels.

The pins are labeled:
A: Action
G: Ground
C: Clock      
D: Data
V: Vdd

This demo connects Clock to P0, Data to P1, Action to P2, and of course Ground to Vss.

To take readings, the Action pin is grounded by pressing the button.  This demo watches that pin to determine
when to read temperatures.  This can also be pulled down at the pin if you'd like Propeller control.  You must
be careful though... the button does short this to ground, so I recommend putting in a series resistor (1k or so)
to prevent shorting the output from the Propeller in case you press the button while connected.  On the TN203,
the laser seems to be grounded through this pin as well, so there's ~10mA sunk when grounded.  If you have the
series resistor, you'll still get readings, but the laser won't light.  This demo displays the object and ambient
temperatures to the debug RS232 port.

While I haven't tried it, I believe you can power the thermometer through the Vdd pin.  I've always left the
internal battery installed and left Vdd disconnected though.  I believe the laser on the TN203 is powered
seperately though.  You should remove the battery if powering from Vdd.

The modules have an EEPROM to store emissivity values, which can be changed, though this demo doesn't use that
functionality.  More information on the protocol, messages, and features can be found by downloading the manuals
on the ZyTemp website.         

This code was based on Beau Schwabe's SPI Spin Demo.
}}

CON
    _clkmode = xtal1 + pll16x                           
    _xinfreq = 5_000_000

OBJ
SPI     :       "SPI_Spin"                              ''The Standalone SPI Spin engine
Ser     :       "FullDuplexSerial"                      ''Used in this DEMO for Debug

CON
MASTER=0
SLAVE=1

VAR
LONG sixteenths[16]

PUB ZyTemp_Demo|DQ,CLK,Start,ClockDelay,ClockState,Type,Data,Temp

''Serial communication Setup
    Ser.start(31, 30, 0, 9600)  '' Initialize serial communication to the PC through the USB connector
                                '' To view Serial data on the PC use the Parallax Serial Terminal (PST) program.
''SPI Setup
    ClockDelay:=15
    ClockState:=1
    SPI.start(ClockDelay, ClockState) '' Initialize SPI Engine with Clock Delay of 15us and Clock State of 1

    SPI.setMasterSlave(SLAVE)


''Pin Setup
    DQ    := 1                  '' Set Data Pin
    CLK   := 0                  '' Set Clock Pin
    Start := 2                  '' Set Start Pin
    dira[Start]~                '' Make Start Pin input to read when pressed (can also drive start pin, though you should disable the module's button)

''Make LUT for sixteenths
    sixteenths[0]:=string("0000")
    sixteenths[1]:=string("0625")
    sixteenths[2]:=string("1250")
    sixteenths[3]:=string("1875")
    sixteenths[4]:=string("2500")
    sixteenths[5]:=string("3125")
    sixteenths[6]:=string("3750")
    sixteenths[7]:=string("4375")
    sixteenths[8]:=string("5000")
    sixteenths[9]:=string("5625")
    sixteenths[10]:=string("6250")
    sixteenths[11]:=string("6875")
    sixteenths[12]:=string("7500")
    sixteenths[13]:=string("8125")
    sixteenths[14]:=string("8750")
    sixteenths[15]:=string("9375")

    'SPI.SHIFTOUT(DQ, CLK, SPI#MSBFIRST , 8, $53)  ''could send data for setting emissivity (more complicated, don't need yet, default 0.95)                                                                                 

      repeat
        waitpne(|<Start, |<Start, 0) ''only read when button is pressed
        Type := SPI.SHIFTIN(DQ, CLK, SPI#MSBPOST, 8)  '' read the message type
        Data := SPI.SHIFTIN(DQ, CLK, SPI#MSBPOST, 32)  '' read the message data

        if Type == $4C ''Object Temp
          if (Data&$FF == $0D) AND (Type+(Data>>16)+(Data>>24))&$FF==((Data>>8)&$FF) ''checksum good
            Ser.str(string("Object Temp:"))
            Temp := ((Data>>16)-((273<<4)+2)) ''(Value/16)-273.15 (actually 273.125 in calculation)
            Ser.dec(Temp>>4) ''output whole degrees (in C)
            Ser.tx(".")
            Ser.str(@BYTE[sixteenths[(Temp&$F)]]) ''output fraction degrees (in C)
            Ser.str(string("°C"))
            Ser.tx(13)
        elseif Type == $66 ''Ambient Temp
          if (Data&$FF == $0D) AND (Type+(Data>>16)+(Data>>24))&$FF==((Data>>8)&$FF) ''checksum good
            Ser.str(string("Ambient Temp:"))
            Temp := ((Data>>16)-((273<<4)+2)) ''(Value/16)-273.15 (actually 273.125 in calculation)
            Ser.dec(Temp>>4) ''output whole degrees (in C)
            Ser.tx(".")
            Ser.str(@BYTE[sixteenths[(Temp&$F)]]) ''output fraction degrees (in C)
            Ser.str(string("°C"))
            Ser.tx(13)
        {elseif Type == $53 'Emissivity? or system status? (valid packet, though doesn't seem to output anything useful)
          if (Data&$FF == $0D) AND (Type+(Data>>16)+(Data>>24))&$FF==((Data>>8)&$FF) 'checksum good
            Ser.str(string("Packet $53:"))
            Ser.hex(Data,8)
            Ser.tx(13)
        else
          Ser.str(string("Unknown Msg Type:$"))
          Ser.hex(Type,2)
          Ser.tx(",")
          Ser.hex(Data,8)
          Ser.tx(13)}
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