{{
''***************************************
''*  Distance/Bearing Calculator        *
''*  Author: Thomas P. Sullivan/W1AUV   *
''*  Copyright (c) 2008 TPS             *
''*  See end of file for terms of use.  *
''***************************************

 -----------------REVISION HISTORY-----------------
 v1.00 - Original Version to test Maidenhead routines

}}

CON
  _CLKMODE = XTAL1  + PLL16X
  _XINFREQ = 5_000_000

  RX = 31
  TX = 30
  BPS = 9600

OBJ
  SPORT : "FullDuplexSerial"
  MH    : "Maidenhead_1_08"
  FS    : "FloatString"
 
VAR
  byte src[10]
  byte tar[10]
  byte mhstr[10]
  
PUB StartTest

  SPORT.start(RX, TX, %0000, BPS)
  SPORT.tx(13)
  SPORT.str(string("***************************************",13))
  SPORT.str(string("**            Calculate              **",13))
  SPORT.str(string("**      Distance and Bearing         **",13))
  SPORT.str(string("**        using Maidenhead           **",13))
  SPORT.str(string("**            by W1AUV               **",13))
  SPORT.str(string("***************************************",13,13))

  SPORT.str(string("Compute distance and bearing using Maidenhead coordinates.",13))

  DistBear(String("FN"),String("EM"))                   'Two digit Maidenhead
  DistBear(String("FN32"),String("FN43"))               'Four digit Maidenhead
  DistBear(String("FN32KP"),String("FN42BL"))           'Six digit Maidenhead
  DistBear(String("FN32KP02"),String("FN42BL"))         'Mixed
  DistBear(String("FN32KP02"),String("FN42BL37"))       'Mt. Greylock Overlook (MA) to Mt. Wachusett (MA)
  DistBear(String("FN32HI94"),String("FN41EE88"))       'Olivia's Overlook (MA) to Block Island (RI)
  DistBear(String("FN33KD49"),String("FN42BL37"))       'Mt. Equinox (VT) to Mt. Wachusett (MA)
  DistBear(String("FN32HI94"),String("FN41NI93"))       'Olivia's Overlook (MA) to Martha's Vineyard (MA)
  DistBear(String("FN32OU44"),String("FN22WI40"))       'Hogback (VT) to Catskills (NY)
  DistBear(String("FN32KP02"),String("FN44IG35"))       'Mt. Greylock Overlook (MA) to Mt. Washington (NH)


' *********************************************************************************************************

  SPORT.str(string(13,"Converting NMEA $GPRMC sentences to 8 digit Maidenhead.",13,13))

  if(MH.NMEACS(String("$GPRMC,223159,A,4221.5835,N,07317.0342,W,2.273,199.0,100307,15.0,W45"))>0)
    MH.NMEA2MH(String("$GPRMC,223159,A,4221.5835,N,07317.0342,W,2.273,199.0,100307,15.0,W45"),@mhstr)
    SPORT.str(@mhstr)
    SPORT.tx(13)

  if (MH.NMEACS(String("$GPRMC,135052,A,4208.5491,N,07235.9939,W,0.000,0.0,110307,15.3,W4B"))>0)
    MH.NMEA2MH(String("$GPRMC,135052,A,4208.5491,N,07235.9939,W,0.000,0.0,110307,15.3,W4B"),@mhstr) 
    SPORT.str(@mhstr)
    SPORT.tx(13)

  if (MH.NMEACS(String("$GPRMC,143727,A,4220.4935,N,07314.7327,W,44.136,352.4,110307,15.1,W78"))>0)
    MH.NMEA2MH(String("$GPRMC,143727,A,4220.4935,N,07314.7327,W,44.136,352.4,110307,15.1,W78"),@mhstr) 
    SPORT.str(@mhstr)
    SPORT.tx(13)

  Repeat

PUB DistBear(source,target) | TDist, TBear, RBear
'
' Call TDist (distance),TBear (bearing) and RBear (reverse bearing) by passing
' the address of the source and destination strings holding valid Maidenhead
' coordinates. 
'
  TDist := MH.Distance(source,target)
  TBear := MH.Bearing(source,target)
  RBear := MH.Bearing(target,source)

  FS.SetPrecision(5)
  
  SPORT.str(source)
  SPORT.tx(",")

  SPORT.str(target)
  SPORT.tx(",")

  SPORT.str(FS.FloatToString(TDist))
  SPORT.tx(",")

  SPORT.str(FS.FloatToString(TBear))
  SPORT.tx(",")

  SPORT.str(FS.FloatToString(RBear))

  SPORT.tx(13)
 
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
  