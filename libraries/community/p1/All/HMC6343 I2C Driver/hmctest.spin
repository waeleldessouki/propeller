{{
  HMC6343 driver test
        Tim Moore Aug 08
}}
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 6_000_000                                  'NOTE SPEED

OBJ 
                                                        '1 Cog here 
  uarts         : "pcFullDuplexSerial4FC"               '1 COG for 4 serial ports

  config        : "config"                              'no COG required

  i2cObject     : "basic_i2c_driver"                    '0 COG
  hmc           : "hmc6343object"                       '0 COG
  lis           : "lis302dlobject"                      '0 COG
  i2cScan       : "i2cScan"                             '0 COG
  
VAR
  long i2cSCL
  
Pub Start | X, Y, Z
  config.Init(@pininfo,@i2cinfo)

  waitcnt(clkfreq*3 + cnt)                              'delay for debugging
  
  i2cSCL := config.GetPin(CONFIG#I2C_SCL1)
  ' setup i2cObject
  i2cObject.Initialize(i2cSCL)

  uarts.Init
  uarts.AddPort(0,config.GetPin(CONFIG#DEBUG_RX),config.GetPin(CONFIG#DEBUG_TX),{
}   UARTS#PINNOTUSED,UARTS#PINNOTUSED,UARTS#DEFAULTTHRESHOLD, {
}   UARTS#NOMODE,UARTS#BAUD115200)                      'Add debug port
  uarts.Start                                           'Start the ports
  
  uarts.str(0,string("HMCTest",13))

  i2cScan.i2cScan(i2cSCL)

  lis.Init(i2cSCL,config.GetI2C(CONFIG#LIS3LV02DQ_0))
  
  uarts.str(0,string("HMC6343 ID: "))
  uarts.hex(0,hmc.GetId(i2cSCL, config.GetI2C(CONFIG#HMC6343)),2)
  uarts.tx(0,13)

  repeat
    {
    lis.getAcceleration(i2cSCL,config.GetI2C(CONFIG#LIS3LV02DQ_0),@X,@Y,@Z)
    uarts.str(0,string("LIS3LV02DQ XYZ: "))
    uarts.dec(0,X)
    uarts.tx(0," ")
    uarts.dec(0,Y)
    uarts.tx(0," ")
    uarts.dec(0,Z)
    uarts.tx(0,13)
    }    
    hmc.GetAcceleration(i2cSCL, config.GetI2C(CONFIG#HMC6343),@X,@Y,@Z)
    uarts.str(0,string("Acc XYZ: "))
    uarts.dec(0,-X)
    uarts.tx(0," ")
    uarts.dec(0,-Y)
    uarts.tx(0," ")
    uarts.dec(0,-Z)
    uarts.tx(0,13)

    hmc.GetMag(i2cSCL, config.GetI2C(CONFIG#HMC6343),@X,@Y,@Z)
    uarts.str(0,string("Mag XYZ: "))
    uarts.dec(0,X)
    uarts.tx(0," ")
    uarts.dec(0,Y)
    uarts.tx(0," ")
    uarts.dec(0,Z)
    uarts.tx(0,13)

    hmc.GetHeading(i2cSCL, config.GetI2C(CONFIG#HMC6343),@X,@Y,@Z)
    uarts.str(0,string("Heading XYZ: "))
    if X < 0
      uarts.tx(0,"-")
    uarts.dec(0,||X/10)         
    uarts.tx(0,".")
    uarts.dec(0,||X//10)
    uarts.tx(0," ")
    if Y < 0
      uarts.tx(0,"-")
    uarts.dec(0,(||Y)/10)
    uarts.tx(0,".")
    uarts.dec(0,(||Y)//10)
    uarts.tx(0," ")
    if Z < 0
      uarts.tx(0,"-")
    uarts.dec(0,||Z/10)
    uarts.tx(0,".")
    uarts.dec(0,||Z//10)
    uarts.tx(0,13)

    hmc.GetTilt(i2cSCL, config.GetI2C(CONFIG#HMC6343),@X,@Y)
    uarts.str(0,string("Tilt XYZ: "))
    if X < 0
      uarts.tx(0,"-")
    uarts.dec(0,||X/10)         
    uarts.tx(0,".")
    uarts.dec(0,||X//10)
    uarts.tx(0," ")
    if Y < 0
      uarts.tx(0,"-")
    uarts.dec(0,(||Y)/10)
    uarts.tx(0,".")
    uarts.dec(0,(||Y)//10)
    uarts.tx(0,13)
    waitcnt(clkfreq+cnt)
               
DAT
'pin configuration table for this project
pininfo       word CONFIG#NOT_USED              'pin 0
              word CONFIG#NOT_USED              'pin 1
              word CONFIG#NOT_USED              'pin 2
              word CONFIG#NOT_USED              'pin 3
              word CONFIG#NOT_USED              'pin 4
              word CONFIG#NOT_USED              'pin 5
              word CONFIG#NOT_USED              'pin 6
              word CONFIG#NOT_USED              'pin 7
              word CONFIG#NOT_USED              'pin 8
              word CONFIG#NOT_USED              'pin 9
              word CONFIG#NOT_USED              'pin 10
              word CONFIG#NOT_USED              'pin 11
              word CONFIG#NOT_USED              'pin 12
              word CONFIG#NOT_USED              'pin 13
              word CONFIG#NOT_USED              'pin 14
              word CONFIG#NOT_USED              'pin 15
              word CONFIG#NOT_USED              'pin 16
              word CONFIG#NOT_USED              'pin 17
              word CONFIG#NOT_USED              'pin 18
              word CONFIG#NOT_USED              'pin 19
              word CONFIG#NOT_USED              'pin 20
              word CONFIG#NOT_USED              'pin 21
              word CONFIG#NOT_USED              'pin 22
              word CONFIG#NOT_USED              'pin 23
              word CONFIG#NOT_USED              'pin 24
              word CONFIG#NOT_USED              'pin 25
              word CONFIG#NOT_USED              'pin 26
              word CONFIG#NOT_USED              'pin 27
              word CONFIG#I2C_SCL1              'pin 28 - I2C - eeprom, sensors, rtc, fpu
              word CONFIG#I2C_SDA1              'pin 29
              word CONFIG#DEBUG_TX              'pin 30
              word CONFIG#DEBUG_RX              'pin 31

i2cinfo       byte CONFIG#HMC6343               'HMC6343 compass
              byte %0011_0010
              byte CONFIG#LIS3LV02DQ_0          'LIS3LV02DQ accelometer
              byte %0011_1010
              byte CONFIG#NOT_USED
              byte CONFIG#NOT_USED
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