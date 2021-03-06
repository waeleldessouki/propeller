'' ******************************************************************************
'' * I2C Test Propeller program                                                 *
'' * Robert Jan Wiepkes                                                         *
'' * Version 1.0                                                                *
'' *                                                                            *
'' * Tests:  i2cObject                                                          *
'' *                                                                            *
'' * by testing:                                                                *
'' *    MAX6956 objects                                            *
'' ******************************************************************************
''
'' this object provides the PUBLIC functions:
''  -> Start  
''
'' this object provides the PRIVATE functions:
''  -> MAX6956Test   - lightshow
''  -> RGBsturing - RGB ledsturing
''  -> RGBinit - init RGB led
'' Revision History:
''  -> V1 - Release
''
''
'' this object uses the following sub OBJECTS:
''  -> i2cObject
''  -> MAX6956Object
''
''
'' Instructions (brief):
'' (1) - setup the propeller - see the Parallax Documentation (www.parallax.com/propeller)
'' (2) - Use a 5mhz crystal on X1 and X2
'' (3) - Connect the SDA lines to Propeller Pin29, and SCL lines to Propeller Pin28.
''       OPTIONAL: Connect the I2C devices
'' (5) - OPTIONAL: Update the i2c Address's for the i2c if you are using them on other address's.
'' (6) - optional: Connect RGBled (common cathode) to Prop pin 0..2 (with resistors in series of anode).
''
     

CON
  _clkmode      = xtal1 + pll16x
  _xinfreq      = 5_000_000
  _stack        = 50
    
  _PinHigh        = 1
  _PinLow         = 0

  i2cSCL        = 28
  i2cSDA        = 29 

  MAX6956_Addr1  = $88
  MAX6956_Addr2  = $98

VAR
  long  i2cAddress, i2cSlaveCounter
  long  teller, teller2, teller3, teller4, randomi, randomStep

OBJ
  i2cObject      : "i2cObject"
  Max6956Object   : "MAX6956Obj"
  Max6956Object2   : "MAX6956Obj"
  text : "tv_text"
  
pub Start | i
  
  'start term
  text.start(12)
  text.out( $00 )

  ' setup i2cobject
  i2cObject.Init(i2cSDA, i2cSCL, false)
'  i2cScan
'  repeat until ina[4] == %1    ' key in pin4, press any key to continue
'  repeat until ina[4] == %0
  teller2 := 0
  teller3 := 0
  teller4 := 0
  randomi := $00
  randomStep := 1
  ' setup the MAX6956 IO expander
  Max6956Object.init(MAX6956_Addr1, i2cSDA, i2cSCL,false)
  MAX6956Object.WriteConfig( $08, $41, $07 )
  MAX6956Object.setAllPorts2LED
  MAX6956Object.DisplayTest( 1 )
  Max6956Object2.init(MAX6956_Addr2, i2cSDA, i2cSCL,false)
  MAX6956Object2.WriteConfig( $08, $41, $07 )
  MAX6956Object2.setAllPorts2LED
  MAX6956Object2.DisplayTest( 1 )
  waitcnt(50_000_000 + cnt)  

  MAX6956Object.DisplayTest( 0 )
  MAX6956Object2.DisplayTest( 0 )
  MAX6956Object.multiPort( 12, 20, %1111_1111_1111_1111_1111 ) 'set MAX pins
  MAX6956Object2.multiPort( 12, 20, %1111_1111_1111_1111_1111 ) 'set MAX pins
  RGBinit
  i := 0
  repeat 
   
    ' i2c state
    RGBout
    text.str(string($A,16,$B,12))
    text.hex(i++, 8)
    ' demo the MAX6956 I/O expander
    if MAX6956Object.isStarted == true
      MAX6956Walk
      'MAX6956Multi
      MAX6956Random

PRI MAX6956Walk | delaytime
  ' demo the MAX6956 i2c I/O Expander
  delaytime := cnt + 8_000_000
  repeat until cnt > delaytime 
  teller3++
  if teller3 == 32
    teller3 := 12
  MAX6956Object2.writePortCurrent(13, 0-teller4 )
  MAX6956Object2.writePortCurrent(30, teller4++ )
  MAX6956Object2.portWalk( teller3 )
  MAX6956Object2.PortOn( 30 )
  MAX6956Object2.PortOn( 13 )
  
  text.str(string($A,2,$B,7,"Walk $"))
  text.hex(teller3, 2)

PRI MAX6956Multi | delaytime
  ' demo the MAX6956 i2c I/O Expander
  teller3++
  MAX6956Object2.multiPort( 12, 20, teller3 )
  text.str(string($A,2,$B,7,"multi $"))
  text.hex(teller3, 8)

PRI MAX6956Random | delaytime
  ' demo the MAX6956 i2c I/O Expander
  delaytime := cnt + 8_000_000
  repeat until cnt > delaytime 
  case randomi
    0 :
      randomStep := 1
    7 :
      randomStep := -1
  randomi += randomStep
  i2cObject.i2cstart
  i2cObject.i2cWrite(MAX6956_Addr1,8)
  i2cObject.i2cWrite( $16,8)
  repeat teller2 from 0 to 9
    i2cObject.i2cWrite( byte [randoms][randomi + teller2],8)
  i2cObject.i2cStop
  
  text.str(string($A,2,$B,8,"random $"))
  text.hex(randomi, 8)

PRI RGBinit
  dira[0] ~~  'red
  dira[1] ~~  'green
  dira[2] ~~  'blue
  teller := 0

PRI RGBout
  teller++
  if teller == 4
    teller := 0
  outa := 0
  outa[teller] := _PinHigh

PRI i2cScan | value, ackbit
  ' Scan the I2C Bus and debug the LCD
  text.str(string("Scanning I2C Bus....",13))

  ' initialize variables
  i2cSlaveCounter := 0
  
  ' i2c Scan - scans all the address's on the bus
  ' sends the address byte and listens for the device to ACK (hold the SDA low)
  repeat i2cAddress from 0 to 127
   
    value :=  i2cAddress << 1 | 0
    ackbit := i2cObject.devicePresent(value)

    ' show the scan on the LCD
    text.str(string($A,2,$B,2,"Scan Addr : $"))
    text.hex(value,2)
    text.str(string(" "))
    if ackbit==true
      text.str(string("ACK"))
    else
      text.str(string("NAK"))      

    ' the device has set the ACK bit 
    if ackbit == true
      text.str(string($A,2,$B,4,"Last Dev  : $"))
      text.hex(value,2)
      i2cSlaveCounter ++
      waitcnt(05_000_000+cnt)

    ' update the counter
    text.str(string($A,2,$B,6,"Devices   : "))
    text.dec(i2cSlaveCounter)    
      
    ' slow the scan so we can read it.    
    waitcnt(20_000_000 + cnt)

DAT
randoms
  byte $00, $20, $42, $64, $86, $A8, $CA, $EC, $FD, $EC, $CA, $A8, $86, $64, $42, $20, $00