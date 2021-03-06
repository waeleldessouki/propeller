{{      
************************************************
*         SPI Communications Demo for          *                
*               CH Robotics UM6           v1.0 *
*              Author: L. Wendell              *
* **********************************************
}}

CON
    _clkmode = xtal1 + pll16x                           
    _xinfreq = 5_000_000

OBJ
SPI     :       "UM6_SPI_Asm"                    ''UM6 SPI Assembly engine
Ser     :       "FullDuplexSerial"               ''Used in this DEMO for Debug

CON

'       SPI Commands
        ReadReg   = 1                     
        ConfigReg = 2
        SendCmd   = 3

'       Sample UM6 Configuration Registers
        UM6_COMMUNICATION = $00
        UM6_MISC_CONFIG = $02
        UM6_ACCEL_REF_X = $05          
        UM6_ACCEL_REF_Y = $06        

'       Sample UM6 Data Registers
        UM6_ACCEL_PROC_XY = $5E
        UM6_ACCEL_PROC_Z = $5F
        UM6_EULER_ROLL_PITCH = $62    ''Roll and Pitch  (Divide received by 91 to convert to angle)
        UM6_EULER_YAW = $63           ''Yaw             (Divide received by 91 to convert to angle)               
       
'       Sample UM6 Command Registers
        Get_FW_Version = $AA
        Zero_Gyros = $AC
        Set_Accel_Ref = $AF
        Set_Mag_Ref = $B0
        Reset_EKF = $AD
        
VAR
        long Reading, Temp
        long ROLL, PITCH, YAW
        byte Version[4]
PUB SPI_DEMO | MOSI, MISO, SCK, SS

'' -----[ Initialization ]----------------------------------------------------------


''Serial communication Setup
      Ser.start(31, 30, 0, 38_400)  

''UM6-LT Setup
      MOSI  := 0                  '' Set Master Out, Data In UM6-LT Input Pin
      MISO  := 1                  '' Set Master In, Data Out UM6-LT Input Pin                 
      SCK   := 2                  '' Set UM6-LT Clock Pin
      SS    := 3                  '' Set UM6-LT Chip Select Pin

''SPI Setup
      SPI.start                   '' Initialize SPI Engine
    

' -----[ Write to Configuration Register ]-------------------------------------------    

'The following is a sample write to the accelerometer reference vector "X".
'The value has to be converted to a 32-bit IEEE floating point value.
 
{      SPI.UM6_CMD(ConfigReg, MOSI, MISO, SCK, SS,  UM6_ACCEL_REF_X, $3C800000)      }
     

' -----[ Send Commands ]--------------------------------------------------------------                                                                                           
    
'This routine resets the Gyros, sets the Accelrometer reference vector, and sets 
'the Magnetometer reference vector.  It also fetches the firmware version, and
'displays it after pausing for 3 seconds (enough time to enable the serial terminal).

        SPI.UM6_CMD(SendCmd, MOSI, MISO, SCK, SS, Zero_Gyros, 0)
        waitcnt(clkfreq/10 + cnt)      
        SPI.UM6_CMD(SendCmd, MOSI, MISO, SCK, SS, Set_Accel_Ref, 0)
        waitcnt(clkfreq/10 + cnt)      
        SPI.UM6_CMD(SendCmd, MOSI, MISO, SCK, SS, Set_Mag_Ref, 0)
        waitcnt(clkfreq/10 + cnt)      
        Reading := SPI.UM6_CMD(SendCmd, MOSI, MISO, SCK, SS, Get_FW_Version, 0)
        waitcnt(3*clkfreq + cnt)
          
        Version[4] := Reading
        Reading >>= 8
        Version[3] := Reading
        Reading >>= 8
        Version[2] := Reading
        Reading >>= 8
        Version[1] := Reading
        Ser.tx(16)    'Clear Screen
        Ser.tx(1)     'Home Position
        Ser.str(string("Firmware Revision:  "))  
        Ser.tx(Version[1]) 
        Ser.tx(Version[2])
        Ser.tx(Version[3])
        Ser.tx(Version[4])          
        Ser.tx(13)
        waitcnt(3*clkfreq + cnt)      
 

' -----[ Read Data Registers ]-----------------------------------------------------------

'This routine fetches the Roll, Pitch, and Yaw and displays it on your monitor

      repeat 
          Ser.tx(16)    'Clear Screen
          Ser.tx(1)     'Home Position
          Reading := SPI.UM6_CMD(ReadReg, MOSI, MISO, SCK, SS, $58, 0)      
          Temp := Reading & $0000FFFF
          PITCH := ~~Temp
          Temp := Reading & $FFFF0000
          Temp >>= 16
          ROLL := ~~Temp
          Ser.str(string(" Roll = ")) 
          Ser.dec(ROLL/91)
          Ser.str(string("  Pitch = ")) 
          Ser.dec(PITCH/91)
          Reading := SPI.UM6_CMD(ReadReg, MOSI, MISO, SCK, SS, $59, 0)  
          Temp := Reading & $FFFF0000
          Temp >>= 16
          YAW := ~~Temp  
          Ser.str(string("  Yaw = ")) 
          Ser.dec(YAW/91)
          waitcnt(clkfreq/5 + cnt)           
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
 