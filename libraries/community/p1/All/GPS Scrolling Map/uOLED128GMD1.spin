{{
┌───────────────────────────────┬───────────────────┬────────────────────┐
│    uOLED128GMD1.spin v1.0     │ Author: I.Kövesdi │ Rel.: 22. Feb 2009 │  
├───────────────────────────────┴───────────────────┴────────────────────┤
│                    Copyright (c) 2009 CompElit Inc.                    │               
│                   See end of file for terms of use.                    │               
├────────────────────────────────────────────────────────────────────────┤
│  This is a simple driver for the 4D Systems µOLED-128-GMD1 display     │
│ module. It is developed for GPS with scrolling digital map background  │
│ applications. It does not support all features of the display but      │
│ contains procedures to retrieve a 128x128 Image from a much larger     │
│ Picture that is stored sequentialy on the SD card of the module.       │
│                                                                        │
├────────────────────────────────────────────────────────────────────────┤
│ Background and Detail:                                                 │
│  Images are stored at user specified sector addresses in the memory    │
│ card, simply pixel-by-pixel and one row after another. A 128x128 pixel │
│ Image takes 64 sectors. To redisplay this Image we have to give only   │
│ the starting sector (and the dimension parameters) to the module. If we│
│ store a very large Picture in the SD card as a continuous sequence of  │
│ the 2 bytes / pixel data, we will have then the liberty to collect any │
│ 128x128 Image part of the large picture very easily.                   │                             
│                                                                        │
├────────────────────────────────────────────────────────────────────────┤
│ Note:                                                                  │
│  A 128x128 pixel image contains 32KBytes data in 2 bytes / pixel color │
│ format occupying 64 sectors on the SD card of the display module.      │
│ Because of this, data collection from the large Picture is done        │
│ directly on the SD card, not in HUB memory. This method yields a       │
│ display ready Image at a separate location of the SD card. The Image   │
│ compilation needs >128 SD card Read/Write operations, where each of    │
│ them takes about 100 ms or more. In the Write Sector operations we have│
│ to wait for the ACK by the module and in the Read Sector operations the│
│ bytes will arrive at module determined pace. In both cases, we cannot  │
│ speed up things too much. One Image compilation is usually done within │
│ 16 seconds.                                                            │ 
│  The largest Picture I downloaded up till now, and used successfully,  │
│ was about a 2 MByte scanned and then calibrated map. The MapCalibrator │
│ Windows exe will be issued along with the next version of this driver. │
│ In the new driver the Image compilation will be intertwined with moving│
│ cursor (vehicle symbol display) commands. In this way, while compiling │
│ the next Map Image frame in the background, the actual moving of the   │ 
│ vehicle can be smoothly displayed on the steady primary Image.         │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘  
             

Schematics of the uOLED Prop connection:

This hardware is part of a Propeller/FPU/GPS/uOLED/Emic TextToSpeech app.
The following schematics displays only the currently relevant part of that
circuit. The numbering A8, A9, A10, comes from that.
               
            uOLED-128-GMD1
      ┌────────────────────────┐
      │                        │
      │                        │
      │                        │
      │                        │
      │         SCREEN         │
      │          SIDE          │                                 
      │                        │
      │                        │                              
      │                        │              
      │ 5   4   3   2   1      │    5V         
      │RST GND  Rx  Tx  Vcc    │    │         
      └─┬───┬───┬───┬───┬──────┘    │                        
        │      │   │   │           │             
        │  GND  │   │   └───────────┘  
        │       │   │              
        │       │   │              
        │       │   │              3.3V        P8X32A
        │       │   │               │   ┌─────────┬─────────┐                        
        │       │   │               │   ┤A0 |1        40|A31├                              
        │       │   │               │   ┤A1 |2        39|A30├                              
        │       │   │               │   ┤A2 |3        38|A29├                                         
        │       │   │               │   ┤A3 |4        37|A28├                              
        │       │   │               │   ┤A4 |5        36|A27├                                                            
        │       │   │               │   ┤A5 |6        35|A26├                                            
        │       │   │               │   ┤A6 |7        34|A25├                                           
        │       │   │     R=10K     │   ┤A7 |8        33|A24├                              
        │       │   │   ┌───┳───┳───┫   ┤VSS|9        32|VDD├ 
        │       │   │   │   │   │   │   ┤BOE|10       31| XO├                               
        │       │   │    R  R    │   ┤RES|11       30| XI├        
        │       │   │   │   │   │   └───┤VDD|12       29|VSS├───┐           
        │       │   └───┼───┼───┻───────┤A8 |13       28|A23├   │          
        │       └───────┼───┻───────────┤A9 |14       27|A22├                                               
        └───────────────┻───────────────┤A10|15       26|A21├  GND          
                                        ┤A11|16       25|A20├               
                                        ┤A12|17       24|A19├ 
                                        ┤A13|18       23|A18├ 
                                        ┤A14|19       22|A17├ 
                                        ┤A15|20       21|A16├ 
                                        └───────────────────┘


The Rx, Tx pins of uOLED-128-GMD1 can be directly connected to the pins of
the Prop since the module has 0.0 to 3.3V signal levels on these lines.
 }}


CON

_CLKMODE    = XTAL1 + PLL16X                        
_XINFREQ    = 5_000_000
  
_ACK        = $06            'Acknowledge byte
_NAK        = $15            'Not Acknowledge byte

_RX         = 8              'Propeller Receive pin  to uOLED(Tx|2)
_TX         = 9              'Propeller Transmit pin to uOLED(Rx|3)
_RES        = 10             'Propeller pin          to uOLED(Reset|5)
                             'Active Low on _RES for>20 usec resets uOLED 

'uOLED UART parameters
_OLED_UART_MODE  = %0000
_OLED_UART_BAUD  = 115_200

_ON           = 1
_OFF          = 0


'SD card parameters
_SD_SECTOR_SIZE    = 512

_MAX_SD_SECT_ADDR  = 1_983_999   'For a nominal 1G NOKIA SD card.
'This value depends on SD capacity, brand and on the formatting software.
'I have found it out with experimentation for a given type of SD card.
'My simple method was to run a program that reads the upper 7% of the
'card, sector by sector, while displaying the sector address. It takes a
'lot of time but it freezes reliably at the first unavailable sector
'address. (apprx.100 ms/sector for about an hour on 1G then stops)

_MAX_SD_ADDRRESS   = (_MAX_SD_SECT_ADDR + 1) * _SD_SECTOR_SIZE - 1

'Image size parameters
_WIDTH        = 128
_HEIGHT       = 128  


VAR

LONG ptr_Error_Message         'String pointer to Error message
LONG ptr_Ack_Message           'String pointer to Ack message

LONG penColor_Hi
LONG penColor_Lo


BYTE sector_Data[512]          'Sector Data             
BYTE sector_Data_V[512]        'Sector Data for Verify and for Compose
  
  
OBJ

UART    : "FullDuplexSerial"   'For communication between the Prop and uOLED

 
PUB InitDevice : oKay
'-------------------------------------------------------------------------
'--------------------------------┌────────────┐---------------------------
'--------------------------------│ InitDevice │---------------------------
'--------------------------------└────────────┘---------------------------
'-------------------------------------------------------------------------
''     Action: -Resets uOLED-128-GMD1 module
''             -Initializes UART object                                                                           
'' Parameters: None                                  
''    Results: oKay:=TRUE if COG is available for FullDuplexSerial                                                              
''+Reads/Uses: None                                               
''    +Writes: None                                    
''      Calls: Reset                                                             
'------------------------------------------------------------------------- 

'Init (_RES) pin from Prop to uOLED(RESET) High
OUTA[_RES] := 1
DIRA[_RES] := 1

'Make a hardware RESET
Reset

'Initialise FullDuplexSerial for Prop/uOLED communication
oKay:=InitUart(_RX,_TX,_OLED_UART_MODE,_OLED_UART_BAUD)

RETURN oKay
'-------------------------------------------------------------------------


PUB Reset
'-------------------------------------------------------------------------
'-----------------------------------┌───────┐-----------------------------
'-----------------------------------│ Reset │-----------------------------
'-----------------------------------└───────┘-----------------------------
'-------------------------------------------------------------------------
''     Action: Resets uOLED-128-GMD1 module                                                                           
'' Parameters: None                                  
''    Results: None                                                              
''+Reads/Uses: _RES constant                                              
''    +Writes: None                                    
''      Calls: Delay                                                             
'------------------------------------------------------------------------- 

'OUTA[_RES]~
OUTA[_RES] := 0                 'Device Reset
Delay(1)                        '1 ms > 20 us
'OUTA[_RES]~~                        
OUTA[_RES] := 1
Delay(1000)                     'Time to stabilize (>500 ms)
'-------------------------------------------------------------------------


PUB InitUart(rX,tX,mode,baud) : oKay
'-------------------------------------------------------------------------
'----------------------------------┌──────────┐---------------------------
'----------------------------------│ InitUart │---------------------------
'----------------------------------└──────────┘---------------------------
'-------------------------------------------------------------------------
''     Action: -Initializes FullDuplexSerial object:OLED
''             -Transmits 'U' for uOLED autobaud detection
''             -Cheks ACK of recognition of that                                                                          
'' Parameters: -Rx, Tx  pins
''             -UART mode and baud rate                                  
''    Results: oKay:=TRUE if everything is OK                                                              
''+Reads/Uses: None                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerial---------------->UART.Start
''                                              UART.RxFlush
''                                              UART.Tx
''             WaitAck 
''       Note: None                                                              
'------------------------------------------------------------------------- 

ptr_Error_Message := @strErrMess00
IF (oKay := UART.Start(rX,tX,mode,baud))
  'This sets, among other things, the host's Tx pin to High immediately.
  'Beside that, there is a 10K pullup resistor on the line
  Delay(100)           'Wait (more than enough) for everything settled

  'Auto Baud detection
  ptr_Error_Message := @strErrMess01 
  UART.RxFlush        'Buffer should be empty
  UART.Tx("U")
  
  oKay := WaitAck     'Wait for a valid response from the module

RETURN oKay
'-------------------------------------------------------------------------    


PUB Device_Info(o, type_, hrdwr_, frmwr_, hres_, vres_) | i
'-------------------------------------------------------------------------
'-------------------------------┌─────────────┐---------------------------
'-------------------------------│ Device_Info │---------------------------
'-------------------------------└─────────────┘---------------------------
'-------------------------------------------------------------------------
''     Action: Returns (and displays) device information                                                                           
'' Parameters: -Output mode: 0=Serial only, 1=Serial and device screen
''             -HUB/addresses of output parameters                                 
''    Results: -Device type
''             -Hardware Rev.
''             -Software Rev.
''             -Horizontal resolution (in pixels)
''             -Vertical resolution (in pixels)                                                             
''+Reads/Uses: None                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerial---------------->UART.Tx
''                                              UART.Rx                           
'------------------------------------------------------------------------- 

UART.Tx("V")
UART.Tx(o)
'Read Device Information
LONG[type_]  := UART.Rx
LONG[hrdwr_] := UART.Rx
LONG[frmwr_] := UART.Rx
LONG[hres_]  := UART.Rx
LONG[vres_]  := UART.Rx
'-------------------------------------------------------------------------


PUB Ack_Message
'-------------------------------------------------------------------------
'-------------------------------┌─────────────┐---------------------------
'-------------------------------│ Ack_Message │---------------------------
'-------------------------------└─────────────┘---------------------------
'-------------------------------------------------------------------------
''     Action: Returns pointer to ACK Message string                                                                            
'' Parameters: None                                  
''    Results: String pointer                                                              
''+Reads/Uses: None                                               
''    +Writes: None                                    
''      Calls: None                                                           
'------------------------------------------------------------------------- 

RETURN ptr_Ack_Message
'-------------------------------------------------------------------------


PUB Error_Message
'-------------------------------------------------------------------------
'-------------------------------┌───────────────┐-------------------------
'-------------------------------│ Error_Message │-------------------------
'-------------------------------└───────────────┘-------------------------
'-------------------------------------------------------------------------
''     Action: Returns pointer to Error Message string                                                                            
'' Parameters: None                                  
''    Results: String pointer                                                              
''+Reads/Uses: None                                               
''    +Writes: None                                    
''      Calls: None                                                                 
'------------------------------------------------------------------------- 

RETURN ptr_Error_Message
'-------------------------------------------------------------------------


PUB Pixels(onOff)
'-------------------------------------------------------------------------
'--------------------------------┌────────┐-------------------------------
'--------------------------------│ Pixels │-------------------------------
'--------------------------------└────────┘-------------------------------
'-------------------------------------------------------------------------
''     Action: Turns off all pixels of the display but does not power off
''             the unit's internal voltage/current boosters                                                                           
'' Parameters: On/Off                                  
''    Results: None                                                              
''+Reads/Uses: None                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerial---------------->UART.Tx     
''       Note: Decreased power consumption                                                            
'-------------------------------------------------------------------------                                                                

UART.Tx("Y")
UART.Tx(1)
UART.Tx(onOff)
'-------------------------------------------------------------------------      


PUB Power(onOff)
'-------------------------------------------------------------------------
'---------------------------------┌───────┐-------------------------------
'---------------------------------│ Power │-------------------------------
'---------------------------------└───────┘-------------------------------
'-------------------------------------------------------------------------
''     Action: Powers off the unit, but not completly. This command should
''             be used before actually removing all power.                                                                           
'' Parameters: None                                  
''    Results: None                                                              
''+Reads/Uses: None                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerial---------------->UART.Tx
''             WaitAck     
''       Note: Rx, Tx lines (and god knows what else) remain active to
''             send an ACK and to recognize a Power ON command (if any)
''             later.                              
'------------------------------------------------------------------------- 
                                                        
UART.Tx("Y")
UART.Tx(3)
UART.Tx(onOff)
WaitAck
'-------------------------------------------------------------------------

  
PUB Shut_Down
'-------------------------------------------------------------------------
'--------------------------------┌───────────┐----------------------------
'--------------------------------│ Shut_Down │----------------------------
'--------------------------------└───────────┘----------------------------
'-------------------------------------------------------------------------
''     Action: Does a recommended Shut Down procedure                                                                           
'' Parameters: None                                  
''    Results: None                                                              
''+Reads/Uses: _OFF                                               
''    +Writes: None                                    
''      Calls: Contrast, Background_Color, Pixels, Power
''       Note: Power can be removed safely and completely after this
''             procedure.                                                                
'------------------------------------------------------------------------- 

Contrast(0)
Background_Color(0,0,0)
Clear_Screen
Pixels(_OFF)
Power(_OFF)
'-------------------------------------------------------------------------


PUB Contrast(c)
'-------------------------------------------------------------------------
'---------------------------------┌──────────┐----------------------------
'---------------------------------│ Contrast │----------------------------
'---------------------------------└──────────┘----------------------------
'-------------------------------------------------------------------------
''     Action: Sets the contrast of the display                                           
'' Parameters: Contrast (0..15)                      
''    Results: None                                                              
''+Reads/Uses: None                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerial---------------->UART.Tx
''             WaitAck     
''       Note: One of the Display Control Functions                              
'-------------------------------------------------------------------------

UART.Tx("Y")
UART.Tx(2)
UART.Tx(c)
WaitAck
'-------------------------------------------------------------------------


PUB Clear_Screen
'-------------------------------------------------------------------------
'-------------------------------┌──────────────┐--------------------------
'-------------------------------│ Clear_Screen │--------------------------
'-------------------------------└──────────────┘--------------------------
'-------------------------------------------------------------------------
''     Action: Fills the entire screen with the actual background color.                  
'' Parameters: None                                  
''    Results: None                                                              
''+Reads/Uses: None                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerial---------------->UART.Tx
''             WaitAck                                                                                 
'------------------------------------------------------------------------- 
                                                                    
UART.Tx("E")
WaitAck
'-------------------------------------------------------------------------


PUB Background_Color(r, g, b)
'-------------------------------------------------------------------------
'-----------------------------┌──────────────────┐------------------------
'-----------------------------│ Background_Color │------------------------
'-----------------------------└──────────────────┘------------------------
'-------------------------------------------------------------------------
''     Action: Sets the actual background color.                                          
'' Parameters: R, G, B                               
''    Results: None                                                              
''+Reads/Uses: None                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerial---------------->UART.Tx
''             WaitAck                                                                                 
'-------------------------------------------------------------------------                                                                                                          '

r := ((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3)

UART.Tx("B")
UART.Tx(R.byte[1])
UART.Tx(R.byte[0])
WaitAck
'-------------------------------------------------------------------------


PUB Pen_Color(r, g, b)
'-------------------------------------------------------------------------
'----------------------------------┌───────────┐--------------------------
'----------------------------------│ Pen_Color │--------------------------
'----------------------------------└───────────┘--------------------------
'-------------------------------------------------------------------------
''     Action: Sets  the penColor_Hi, Low global variables                                
'' Parameters: R, G, B                               
''    Results: None                                                              
''+Reads/Uses: penColor_Hi, penColor_Lo                           
''    +Writes: None                                    
''      Calls: None
''       Note: Many drawing procedure uses the penColor_Hi, penColor_Lo
''             global variables.
'-------------------------------------------------------------------------                                                                                                      '

r := ((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3)

penColor_Hi := R.byte[1]
penColor_Lo := R.byte[0]
'-------------------------------------------------------------------------


PUB Pen_Size(p)
'-------------------------------------------------------------------------
'---------------------------------┌──────────┐----------------------------
'---------------------------------│ Pen_Size │----------------------------
'---------------------------------└──────────┘----------------------------
'-------------------------------------------------------------------------
''     Action: Sets Solid or Wire Frame drawing mode.                                     
'' Parameters: Pen size: 0 for solid, 1 for wireframe mode
''    Results: None                                                              
''+Reads/Uses: None                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerial---------------->UART.Tx
''             WaitAck                                                                
'-------------------------------------------------------------------------

UART.Tx("p")
UART.Tx(p)
WaitAck
'-------------------------------------------------------------------------


PUB Put_Pixel(x, y)
'-------------------------------------------------------------------------
'--------------------------------┌───────────┐----------------------------
'--------------------------------│ Put_Pixel │----------------------------
'--------------------------------└───────────┘----------------------------
'-------------------------------------------------------------------------
''     Action: Puts a pixel with the actual penColor.                                                                           
'' Parameters: Pixel coordinates                                  
''    Results: None                                                              
''+Reads/Uses: penColor_Hi, penColor_Lo                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerial---------------->UART.Tx
''             WaitAck                                                             
'-------------------------------------------------------------------------                                                  

UART.Tx("P")
UART.Tx(x)
UART.Tx(y)
UART.Tx(penColor_Hi)
UART.Tx(penColor_Lo)
WaitAck
'-------------------------------------------------------------------------


PUB Read_Pixel(x, y, c_, r_, g_, b_) | rgb
'-------------------------------------------------------------------------
'-------------------------------┌────────────┐----------------------------
'-------------------------------│ Read_Pixel │----------------------------
'-------------------------------└────────────┘----------------------------
'-------------------------------------------------------------------------
''     Action: Gives back the R, G, B colors of a pixel                                                                           
'' Parameters: Pixel coordinates                                  
''    Results: R, G, B color components of the 64K uOLED color word                                                             
''+Reads/Uses: None                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerial-----------------UART.Tx
''                                              UART.Rx
''             WaitACK
''       Note: R, G, B Values are passed by reference                                                              
'-------------------------------------------------------------------------   

UART.Tx("R")
UART.Tx(x)
UART.Tx(y)
WaitAck
rgb.BYTE[1] := UART.Rx
rgb.BYTE[0] := UART.Rx
LONG[r_] := rgb.BYTE[1] & %1111_1000
LONG[g_] := ((rgb.BYTE[1]&%0000_0111)<<5)+((rgb.BYTE[0]&%1110_0000)>>3)
LONG[b_] := (rgb.BYTE[0] & %0001_1111) << 3
'-------------------------------------------------------------------------

  
PUB Line(x1, y1, x2, y2)
'-------------------------------------------------------------------------
'----------------------------------┌──────┐-------------------------------
'----------------------------------│ Line │-------------------------------
'----------------------------------└──────┘-------------------------------
'-------------------------------------------------------------------------
''     Action: Draws a line with the actual penColor                                                                           
'' Parameters: Start - End point coordinates                                 
''    Results: None                                                              
''+Reads/Uses: penColor_Hi, penColor_Lo                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerial-----------------UART.Tx
''             WaitACK                                                       
'------------------------------------------------------------------------- 

UART.Tx("L")    
UART.Tx(x1)
UART.Tx(y1)
UART.Tx(x2)
UART.Tx(y2)
UART.Tx(penColor_Hi)
UART.Tx(penColor_Lo)
WaitAck
'-------------------------------------------------------------------------


PUB Triangle(x1,y1,x2,y2,x3,y3)|vx1,vy1,vx2,vy2,vpz
'-------------------------------------------------------------------------
'--------------------------------┌──────────┐-----------------------------
'--------------------------------│ Triangle │-----------------------------
'--------------------------------└──────────┘-----------------------------
'-------------------------------------------------------------------------
''     Action: Draws a triangle with the actual penColor                                                                           
'' Parameters: Coordinates of the vertices of the triangle                                  
''    Results: None                                                              
''+Reads/Uses: penColor_Hi, penColor_Lo                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerial-----------------UART.Tx
''             WaitACK                                        
''       Note: -Checks and corrects for left handed triangles.
''             -Draws accordingly to the preset Solid or Wire Frame
''             drawing mode. Use Pen_Size procedure to set drawing mode                                                              
'------------------------------------------------------------------------- 

'Check for Right Handed Triangle
vx1 := x2 - x1
vy1 := y2 - y1
vx2 := x3 - x1
vy2 := y3 - y1
vpz := vy1*vx2-vx1*vy2
IF (vpz < 0)
  'Left Handed Triangle: Exchange vertices 2, 3 
  vx1 := x2
  x2 := x3
  x3 := vx1
  vy1 := y2
  y2 := y3
  y3 := vy1                          

UART.Tx("G")    
UART.Tx(x1)
UART.Tx(y1)
UART.Tx(x2)
UART.Tx(y2)
UART.Tx(x3)
UART.Tx(y3)  
UART.Tx(penColor_Hi)
UART.Tx(penColor_Lo)
WaitAck
'-------------------------------------------------------------------------


PUB Rectangle(x1, y1, x2, y2)
'-------------------------------------------------------------------------
'---------------------------------┌───────────┐---------------------------
'---------------------------------│ Rectangle │---------------------------
'---------------------------------└───────────┘---------------------------
'-------------------------------------------------------------------------
''     Action: Draws a rectangle with the actual penColor                                                                           
'' Parameters: Coordinates of top left and bottom right vertices of the
''             rectangle                                  
''    Results: None                                                              
''+Reads/Uses: penColor_Hi, penColor_Lo                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerial-----------------UART.Tx
''             WaitACK
''       Note: Draws accordingly to the preset Solid or Wire Frame drawing    
''             mode. Use Pen_Size procedure to set drawing mode                                                                                   
'------------------------------------------------------------------------- 
    
UART.Tx("r")    
UART.Tx(x1)
UART.Tx(y1)
UART.Tx(x2)
UART.Tx(y2)
UART.Tx(penColor_Hi)
UART.Tx(penColor_Lo)
WaitAck
'-------------------------------------------------------------------------


PUB Poligon(n, x_, y_) | i
'-------------------------------------------------------------------------
'----------------------------------┌─────────┐----------------------------
'----------------------------------│ Poligon │----------------------------
'----------------------------------└─────────┘----------------------------
'-------------------------------------------------------------------------
''     Action: Draws a poligon with the actual penColor                                                                           
'' Parameters: -poligon size (3-7)
''             -pointers to x, y coordinate arrays of vertices                                  
''    Results: None                                                              
''+Reads/Uses: penColor_Hi, penColor_Lo                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerial-----------------UART.Tx
''             WaitACK
''       Note: Only wire frame drawing mode is supported                                                             
'------------------------------------------------------------------------- 

CASE n
  3..7:
    UART.Tx("g")
    UART.Tx(n)
    REPEAT i FROM 0 TO (n - 1)
      UART.Tx(BYTE[x_][i])  
      UART.Tx(BYTE[y_][i])
    UART.Tx(penColor_Hi)
    UART.Tx(penColor_Lo)
    WaitAck      
  OTHER:
'-------------------------------------------------------------------------  


PUB Circle(x, y, r)
'-------------------------------------------------------------------------
'------------------------------------┌────────┐---------------------------
'------------------------------------│ Circle │---------------------------
'------------------------------------└────────┘---------------------------
'-------------------------------------------------------------------------
''     Action: Draws a circle with the actual penColor                                                                          
'' Parameters: -Center coordinates
''             -Radius                                  
''    Results: None                                                              
''+Reads/Uses: penColor_Hi, penColor_Lo                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerial-----------------UART.Tx
''             WaitACK
''       Note: Draws accordingly to the preset Solid or Wire Frame drawing    
''             mode. Use Pen_Size procedure to set drawing mode                                                                   
'-------------------------------------------------------------------------                                    

UART.Tx("C")    
UART.Tx(x)
UART.Tx(y)
UART.Tx(r)
UART.Tx(penColor_Hi)
UART.Tx(penColor_Lo)
WaitAck
'-------------------------------------------------------------------------


PUB Opaque_Text
'-------------------------------------------------------------------------
'-------------------------------┌─────────────┐---------------------------
'-------------------------------│ Opaque_Text │---------------------------
'-------------------------------└─────────────┘---------------------------
'-------------------------------------------------------------------------
''     Action: Sets text mode to opaque (In this mode the rectangular text
''             area is filled with actual background color before printing
''             a text)                                                                           
'' Parameters: None                                  
''    Results: None                                                              
''+Reads/Uses: None                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerial-----------------UART.Tx
''             WaitACK
''       Note: See Background_Color procedure                                                         
'-------------------------------------------------------------------------                                                                     

UART.Tx("O")
UART.Tx(1)
WaitAck
'-------------------------------------------------------------------------
  

PUB Transparent_Text
'-------------------------------------------------------------------------
'----------------------------┌──────────────────┐-------------------------
'----------------------------│ Transparent_Text │-------------------------
'----------------------------└──────────────────┘-------------------------
'-------------------------------------------------------------------------
''     Action: Sets text mode to transparent (only text will be printed)                            
'' Parameters: None                                  
''    Results: None                                                              
''+Reads/Uses: None                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerial-----------------UART.Tx
''             WaitACK                                                         
'-------------------------------------------------------------------------                                                              
'Sets text mode to transparent

UART.Tx("O")
UART.Tx(0)
WaitAck
'-------------------------------------------------------------------------


PUB Text_Formatted(c,r,f, strPtr_,t)
'-------------------------------------------------------------------------
'-----------------------------┌────────────────┐--------------------------
'-----------------------------│ Text_Formatted │--------------------------
'-----------------------------└────────────────┘--------------------------
'-------------------------------------------------------------------------
''     Action: Displays a string or decimal number with standard fonts of
''             ASCII characters                                                                                   
'' Parameters: -Column and Raw of starting position
''             -Font selection
''             -Pinter to string or decimal value                               
''    Results: None                                                              
''+Reads/Uses: penColor_Hi, penColor_Lo                                             
''    +Writes: None                                    
''      Calls: FullDuplexSerial-----------------UART.Tx
''             WaitACK                                                            
'-------------------------------------------------------------------------                                   

UART.Tx("s")
UART.Tx(c)
UART.Tx(r)
UART.Tx(f)
UART.Tx(penColor_Hi)
UART.Tx(penColor_Lo)
IF t
  UART.Dec(strPtr_)
ELSE
  UART.Str(strPtr_)
UART.Tx(0)
WaitAck
'-------------------------------------------------------------------------


PUB Text_Unformatted(x,y,f,w,h,strPtr_,t)
'-------------------------------------------------------------------------
'-----------------------------┌──────────────────┐------------------------
'-----------------------------│ Text_Unformatted │------------------------
'-----------------------------└──────────────────┘------------------------
'-------------------------------------------------------------------------
''     Action: Displays a string or a decimal number with bitmapped
''             (enlargeable) characters    
'' Parameters: -Start position of the string in pixels
''             -Font selection
''             -Horizontal font size multiplier
''             -Vertical font size multiplier
''             -Pointer to string or number value
''             -Output type  
''    Results: None                                                              
''+Reads/Uses: penColor_Hi, penColor_Lo                                             
''    +Writes: None                                    
''      Calls: FullDuplexSerial-----------------UART.Tx
''             WaitACK                                                               
'-------------------------------------------------------------------------                 

UART.Tx("S")
UART.Tx(x)
UART.Tx(y)
UART.Tx(f)
UART.Tx(penColor_Hi)
UART.Tx(penColor_Lo)
UART.Tx(w)
UART.Tx(h)
IF t
  UART.Dec(strPtr_)
ELSE
  UART.Str(strPtr_)
UART.Tx(0)
WaitAck
'-------------------------------------------------------------------------

  
PUB Char_Formatted(chr, c, r)
'-------------------------------------------------------------------------
'-----------------------------┌────────────────┐--------------------------
'-----------------------------│ Char_Formatted │--------------------------
'-----------------------------└────────────────┘--------------------------
'-------------------------------------------------------------------------
''     Action: Draws an ASCII(32-127) character on the screen.                                                                   
'' Parameters: -ASCII character
''             -Column and Raw of starting position                  
''    Results: None                                                              
''+Reads/Uses: penColor_Hi, penColor_Lo                                             
''    +Writes: None                                    
''      Calls: FullDuplexSerial-----------------UART.Tx
''             WaitACK                                                             
'------------------------------------------------------------------------- 

UART.Tx("T")
UART.Tx(chr)
UART.Tx(c)
UART.Tx(r)
UART.Tx(penColor_Hi)
UART.Tx(penColor_Lo)
WaitAck
'-------------------------------------------------------------------------


PUB Chat_Unformatted(chr, x, y, w, h)
'-------------------------------------------------------------------------
'----------------------------┌──────────────────┐-------------------------
'----------------------------│ Chat_Unformatted │-------------------------
'----------------------------└──────────────────┘-------------------------
'-------------------------------------------------------------------------
''     Action: Displays an enlargeable, bitmapped character                                                             
'' Parameters: -ASCII character
''             -Starting position in pixels
''             -Horizontal font size multiplier
''             -Vertical font size multiplier               
''    Results: None                                                              
''+Reads/Uses: penColor_Hi, penColor_Lo                                             
''    +Writes: None                                    
''      Calls: FullDuplexSerial-----------------UART.Tx
''             WaitACK                                                            
'-------------------------------------------------------------------------                               

UART.Tx("t")
UART.Tx(chr)
UART.Tx(x)
UART.Tx(y)
UART.Tx(penColor_Hi)
UART.Tx(penColor_Lo)
UART.Tx(w)
UART.Tx(h)
WaitAck
'-------------------------------------------------------------------------


PUB Copy_Image_To_SD(x,y,w,h,sAddr) | i
'-------------------------------------------------------------------------
'----------------------------┌──────────────────┐-------------------------
'----------------------------│ Copy_Image_To_SD │-------------------------
'----------------------------└──────────────────┘-------------------------
'-------------------------------------------------------------------------
''     Action: Copies a rectangular area of display of specified size to
''             the SD card memory.                                                                           
'' Parameters: -Top left corner of area
''             -Area size as width and height
''             -2 bytes sector address                                  
''    Results: None                                                              
''+Reads/Uses: None                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerial-----------------UART.Tx
''             WaitACK                                                             
'-------------------------------------------------------------------------     

UART.Tx("@")
UART.Tx("C")
UART.Tx(x)
UART.Tx(y)
UART.Tx(w)
UART.Tx(h)
REPEAT i FROM 2 TO 0
  UART.Tx(sAddr.BYTE[i])
  WaitAck
'-------------------------------------------------------------------------  

     
PUB Disp_Image_From_SD(x,y,w,h,m,sAddr)|i
'-------------------------------------------------------------------------
'---------------------------┌────────────────────┐------------------------
'---------------------------│ Disp_Image_From_SD │------------------------
'---------------------------└────────────────────┘------------------------
'-------------------------------------------------------------------------
''     Action: Diplays a stored image from the SD card,                                                                           
'' Parameters: -Top left position
''             -Width and height
''             -Color mode, 8 for 256, 16 for 64K colors
''             -Sector address                                 
''    Results: None                                                              
''+Reads/Uses: None                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerial-----------------UART.Tx
''             WaitACK                                                                
'------------------------------------------------------------------------- 

UART.Tx("@")
UART.Tx("I")
UART.Tx(x)
UART.Tx(y)
UART.Tx(w)
UART.Tx(h)
UART.Tx(m) 
REPEAT i FROM 2 TO 0
  UART.Tx(sAddr.BYTE[i])
  WaitAck
'-------------------------------------------------------------------------  


PUB Set_SD_ByteAddress(addr) : oKay | i
'-------------------------------------------------------------------------
'--------------------------┌────────────────────┐-------------------------
'--------------------------│ Set_SD_ByteAddress │-------------------------
'--------------------------└────────────────────┘-------------------------
'-------------------------------------------------------------------------
''     Action: -Cheks for valid address
''             -Sets the card memory address pointer for byte wise reads
''             and writes.                                                                           
'' Parameters: Address                                  
''    Results: OK if address is in range                                                              
''+Reads/Uses: @strNull, @strAckMess03, _MAX_SD_ADDRRESS                                                 
''    +Writes: None                                    
''      Calls: FullDuplexSerial-----------------UART.Tx
''             WaitACK  
''       Note: After the read or write the address pointer is
''             automatically incremented.                                                              
'-------------------------------------------------------------------------   

ptr_Error_Message := @strNull
ptr_Ack_Message := @strAckMess03
oKay := TRUE

IF ((addr > _MAX_SD_ADDRRESS) OR (addr < 0))
  oKay := FALSE
  ptr_Error_Message :=  @strErrMess02
  RETURN oKay

UART.Tx("@")
UART.Tx("A")
REPEAT i FROM 3 TO 0
  UART.Tx(addr.BYTE[i])
  WaitAck
'-------------------------------------------------------------------------  


PUB Read_SD_Byte
'-------------------------------------------------------------------------
'------------------------------┌──────────────┐---------------------------
'------------------------------│ Read_SD_Byte │---------------------------
'------------------------------└──────────────┘---------------------------
'-------------------------------------------------------------------------
''     Action: Reads one byte from the uSD card at address set by the
''             Set_SD_ByteAddress procedure or by a previous read&write.                                                                           
'' Parameters: None                                  
''    Results: Byte from SD card                                                              
''+Reads/Uses: None                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerial-----------------UART.Tx
''                                              UART.Rx
''             WaitACK  
''       Note: SD card memory Address pointer is automatically incremented
''             to the next address location.                                                             
'------------------------------------------------------------------------- 
 
UART.tx("@")
UART.tx("r")
RESULT := UART.Rx
'-------------------------------------------------------------------------

  
PUB Write_SD_Byte(b)
'-------------------------------------------------------------------------
'----------------------------┌───────────────┐----------------------------
'----------------------------│ Write_SD_Byte │----------------------------
'----------------------------└───────────────┘----------------------------
'-------------------------------------------------------------------------
''     Action: Writes one byte to the uSD card at address set by the
''             Set_SD_ByteAddress procedure or by a previous read&write.                                                                          
'' Parameters: Byte to store                                  
''    Results: None                                                              
''+Reads/Uses: None                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerial-----------------UART.Tx
''             WaitACK  
''       Note: SD card memory Address pointer is automatically incremented
''             to the next address location.                                                                 
'------------------------------------------------------------------------- 

UART.Tx("@")
UART.Tx("w")
UART.Tx(b)
WaitAck
'-------------------------------------------------------------------------


PUB Write_SD_Sector(sectorAddr, sectorData_) : oKay | i
'-------------------------------------------------------------------------
'----------------------------┌─────────────────┐--------------------------
'----------------------------│ Write_SD_Sector │--------------------------
'----------------------------└─────────────────┘--------------------------
'-------------------------------------------------------------------------
''     Action: -Cheks for valid Sector Address
''             -Writes 512 bytes to SD sector                                                               
'' Parameters: -SD sector
''             -Pointer to 512 bytes sector data array                                  
''    Results: None                                                              
''+Reads/Uses: @strErrMess03, @strAckMess03                                                
''    +Writes: ptr_Error_Message, ptr_Ack_Message                                   
''      Calls: FullDuplexSerial-----------------UART.Tx
''             Verify_Sector_Address 
''             WaitACK  
''       Note: None                                                              
'------------------------------------------------------------------------- 

ptr_Error_Message := @strErrMess03   'ACK will clear this
ptr_Ack_Message := @strAckMess03     'If any

IF NOT (oKay := Verify_Sector_Address(sectorAddr)) 
  ptr_Error_Message :=  @strErrMess02
  RETURN oKay
  
'Sector Address is valid. Send command
UART.Tx("@")
UART.Tx("W")

'Send Sector Address
REPEAT i FROM 2 TO 0
  UART.Tx(sectorAddr.BYTE[i])

'Send Sector Data
REPEAT i FROM 0 TO (_SD_SECTOR_SIZE-1)
  UART.Tx(BYTE[sectorData_][i])

'Wait for ACK
oKay := WaitAck

RETURN oKay
'-------------------------------------------------------------------------


PUB Read_SD_Sector(sectorAddr, sectorData_) : oKay | i
'-------------------------------------------------------------------------
'------------------------------┌────────────────┐-------------------------
'------------------------------│ Read_SD_Sector │-------------------------
'------------------------------└────────────────┘-------------------------
'-------------------------------------------------------------------------
''     Action: -Cheks for valid Sector Address
''             -Reads 512 bytes from SD sector                                                               
'' Parameters: -SD sector address
''             -Pointer to 512 bytes sector data array                                  
''    Results: 512 byte sector data                                                              
''+Reads/Uses: @strNull, @strAckMess03                                                
''    +Writes: ptr_Error_Message, ptr_Ack_Message                                   
''      Calls: FullDuplexSerial-----------------UART.Tx
''                                              UART.Rx
''             Verify_Sector_Address                                                                        
'------------------------------------------------------------------------- 

ptr_Error_Message := @strNull
ptr_Ack_Message := @strAckMess03

IF NOT (oKay := Verify_Sector_Address(sectorAddr)) 
  ptr_Error_Message :=  @strErrMess02
  RETURN oKay

'Send command
UART.Tx("@")
UART.Tx("R")
  
'Send Sector Address (3 bytes)
REPEAT i FROM 2 TO 0
  UART.Tx(sectorAddr.BYTE[i])  
 
'Read Sector Data
REPEAT i FROM 0 TO (_SD_SECTOR_SIZE-1)
  BYTE[sectorData_][i] := UART.Rx
'-------------------------------------------------------------------------
  

PUB Write_Verify_SD_Sector(sectorAddr, sectorData_) : oKay | i
'-------------------------------------------------------------------------
'------------------------┌────────────────────────┐-----------------------
'------------------------│ Write_Verify_SD_Sector │-----------------------
'------------------------└────────────────────────┘-----------------------
'-------------------------------------------------------------------------
''     Action: Writes SD sector with verify                                                                           
'' Parameters: -Sector address
''             -Pointer to 512 byte sector data array                                  
''    Results: OK of successful                                                              
''+Reads/Uses: @strNull                                               
''    +Writes: ptr_Error_Message                                
''      Calls: Write_Sd_Sector, Read_Sd_Sector
''       Note: None                                                              
'------------------------------------------------------------------------- 

IF (oKay:=Write_SD_Sector(sectorAddr,sectorData_))
  Read_SD_Sector(sectorAddr, @sector_Data_V)
  
  'Compare original and retrieved arrays. We cannot use the fast string
  'comparison here. First it seemed to be a good idea , but it was not.
  'Find out why?
  ptr_Error_Message := @strNull   
  REPEAT i FROM 0 TO (_SD_SECTOR_SIZE-1)
    IF (BYTE[sectorData_][i]<>BYTE[@sector_Data_V][i])
      ptr_Error_Message := @strErrMess04 
      oKay := FALSE
      QUIT
 
RETURN oKay
'-------------------------------------------------------------------------  


PUB Collect_Image_From_Picture(ps,ph,pw,ix,iy,is):oK|i,j,sa,aa,sb,ab
'-------------------------------------------------------------------------
'---------------------┌────────────────────────────┐----------------------
'---------------------│ Collect_Image_From_Picture │----------------------
'---------------------└────────────────────────────┘----------------------
'-------------------------------------------------------------------------
''     Action: -Cheks Image position in Picture (If fully inside then OK)
''             -Verify sector addresses
''             -Collects a 128x128 Image from a larger Picture stored on
''              the SD card and writes the data of the Image to the SD
''              card                                                                           
'' Parameters: -Sector address of stored Picture
''             -Pixel height of stored Picture
''             -Pixel width of stored Picture
''             -Pixel coordinates of top left corner of Image on the large
''              Picture
''             -Sector address of the Image data on SD card                          
''    Results: OK if cheks are all right                                                              
''+Reads/Uses: @strNull, @strErrMess10, @strErrMess2                                                 
''    +Writes: ptr_Error_Message                                   
''      Calls: Verify_Sector_Address, AddressesOfImageLine
''             Collect1stHalfOfSector, Collect2ndHalfOfSector
''             Write_SD_Sector                                                              
'------------------------------------------------------------------------- 

ptr_Error_Message := @strNull

'Check position parameters
IF (oK := ((ix + _WIDTH) > pw) OR ((iy + _HEIGHT) > ph))
  ptr_Error_Message := @strErrMess10
  RETURN oK

'Check Sector Address parameters
i := Verify_Sector_Address(ps)       'For Picture
j := Verify_Sector_Address(is)       'For Image

IF (oK := NOT (i AND j))
  ptr_Error_Message :=  @strErrMess02
  RETURN oK

'Build up Image in SD card memory starting at sector 'is' (Image Sector)
'One sector holds 2 lines of Image. First line is stored in the 1st half,
'second line in the 2nd half of the sector

j~                                'Image sector rel. counter = 0
REPEAT i FROM 0 TO _HEIGHT STEP 2
  AddressesOfImageLine(ps,ph,pw,ix,iy+i,@sa,@aa,@sb,@ab)
  Collect1stHalfOfSector(sa,aa,sb,ab)
  AddressesOfImageLine(ps,ph,pw,ix,iy+i+1,@sa,@aa,@sb,@ab)
  Collect2ndHalfOfSector(sa,aa,sb,ab)
  'Now sector data for 2 lines of Image are collected in the sector_Data_V
  'array. Write this array to the next data sector of the Image
  Write_SD_Sector(is + j, @sector_Data_V)
  j++                            'Increment sector counter


PUB Verify_Sector_Address(sa) : oKay
'-------------------------------------------------------------------------
'-------------------------┌───────────────────────┐-----------------------
'-------------------------│ Verify_Sector_Address │-----------------------
'-------------------------└───────────────────────┘-----------------------
'-------------------------------------------------------------------------
''     Action: Cheks for a valid sector address                                                                           
'' Parameters: Sector address                                  
''    Results: OK if valid                                                              
''+Reads/Uses: _MAX_SD_SECT_ADDR                                              
''    +Writes: None                                    
''      Calls: None                                                             
'------------------------------------------------------------------------- 

RETURN NOT ((sa > _MAX_SD_SECT_ADDR) OR (sa < 0))
'-------------------------------------------------------------------------
  

PRI AddressesOfImageLine(s0,h,w,x,y,s1_,a1_,s2_,a2_)|i,a,s1,a1,s2,a2
'-------------------------------------------------------------------------
'-------------------------┌──────────────────────┐------------------------
'-------------------------│ AddressesOfImageLine │------------------------
'-------------------------└──────────────────────┘------------------------
'-------------------------------------------------------------------------
'     Action: Calculates the sector/byte adresses of the pixels at the
'             beginning/end of a line of the Image within a large Picture                                                                           
' Parameters: -Sector address of stored Picture
'             -Pixel height of stored Picture
'             -Pixel width of stored Picture
'             -Pixel coordinates of the leftmost point of the line within
'              the large Picture                                  
'    Results: Sector/byte addresses of the endpoints of the line                                                              
'+Reads/Uses: _SD_SECTOR_SIZE, _WIDTH                                              
'    +Writes: None                                    
'      Calls: None
'       Note: Results are passed by reference                                                              
'------------------------------------------------------------------------- 

'Calculate the byte address of 1st pixel of insert's line within picture
a := 2*(y * w + x) 
'Calculate the containing sector
i := a / _SD_SECTOR_SIZE
s1 := s0 + i
'Calculate the byte address in the containing sector
a1 := a - i * _SD_SECTOR_SIZE

'Calculate the byte address of last pixel of insert's line within picture
a := a + 2 * (_WIDTH - 1)
'Calculate the containing sector
i := a / _SD_SECTOR_SIZE
s2 := s0 + i
'Calculate the byte address in the containing sector
a2 := a - i * _SD_SECTOR_SIZE

'Return values via the pointers
LONG[s1_] := s1
LONG[a1_] := a1
LONG[s2_] := s2
LONG[a2_] := a2
'-------------------------------------------------------------------------


PRI Collect1stHalfOfSector(sa, aa, sb, ab) | i, j, k
'-------------------------------------------------------------------------
'------------------------┌────────────────────────┐-----------------------
'------------------------│ Collect1stHalfOfSector │-----------------------
'------------------------└────────────────────────┘-----------------------
'-------------------------------------------------------------------------
'     Action: Collects first 256 bytes of Image sector data                                                                            
' Parameters: Sector/byte addresses of endpoints a, b of the line                                   
'    Results: None                                                              
'+Reads/Uses: /@sector_Data, @sector_Data_V                                               
'    +Writes: @sector_Data, @sector_Data_V                                    
'      Calls: Read_SD_Sector                                                          
'------------------------------------------------------------------------- 

IF (sa == sb)  'Data are in the same SD sector
  Read_SD_Sector(sa, @sector_Data)
  BYTEMOVE(@Sector_Data_V, @sector_Data+aa, 256)
ELSE           'Data are in 2 consecutive sectors
  'Read 1st sector
  Read_SD_Sector(sa, @sector_Data)
  i := 512 - aa
  BYTEMOVE(@Sector_Data_V, @sector_Data+aa, i)
  'Read 2nd sector
  Read_SD_Sector(sb, @sector_Data)
  j := ab + 2
  BYTEMOVE(@Sector_Data_V + i, @sector_Data, j)
'-------------------------------------------------------------------------
  

PRI Collect2ndHalfOfSector(sa, aa, sb, ab) | i, j, k
'-------------------------------------------------------------------------
'-------------------------┌────────────────────────┐----------------------
'-------------------------│ Collect2ndHalfOfSector │----------------------
'-------------------------└────────────────────────┘----------------------
'-------------------------------------------------------------------------
'     Action: Collects second 256 bytes of Image sector data                                                                            
' Parameters: Sector/byte addresses of endpoints a, b of the line                                   
'    Results: None                                                              
'+Reads/Uses: /@sector_Data, @sector_Data_V                                               
'    +Writes: @sector_Data, @sector_Data_V                                   
'      Calls: Read_SD_Sector                                                      
'------------------------------------------------------------------------- 

IF (sa == sb)  'Data are in the same SD sector
  Read_SD_Sector(sa, @sector_Data)
  BYTEMOVE(@Sector_Data_V + 256, @sector_Data+aa+2, 256)
ELSE           'Data are in 2 consecutive sectors
  'Read 1st sector
  Read_SD_Sector(sa, @sector_Data)
  i := 512 - aa
  BYTEMOVE(@Sector_Data_V + 256, @sector_Data+aa, i)
  'Read 2nd sector
  Read_SD_Sector(sb, @sector_Data)
  j := ab + 2
  BYTEMOVE(@Sector_Data_V + 256 + i, @sector_Data, j)
'-------------------------------------------------------------------------
  

PRI Delay(t) | c
'-------------------------------------------------------------------------
'---------------------------------┌───────┐-------------------------------
'---------------------------------│ Delay │-------------------------------
'---------------------------------└───────┘-------------------------------
'-------------------------------------------------------------------------
'     Action: Delays program execution                                                         
' Parameters: delay in ms                                 
'    Results: None                     
'+Reads/Uses: 53_000 to check for a for a max. 53 sec delay                                               
'    +Writes: None                                    
'      Calls: None                                           
'------------------------------------------------------------------------- 

IF t > 53_000
  t := 53_000

c := CLKFREQ / 1000
c := t * c

WAITCNT(c + CNT)  
'-------------------------------------------------------------------------


PRI WaitAck : oKay | c
'-------------------------------------------------------------------------
'-------------------------------┌─────────┐-------------------------------
'-------------------------------│ WaitAck │-------------------------------
'-------------------------------└─────────┘-------------------------------
'-------------------------------------------------------------------------
'     Action: -Waits 100 ms for uOLED response
'             -Checks response, timeout
'             -Sets error and ACK messages                                            
' Parameters: None                                 
'    Results: -IF ACKnowledged THEN
'                RESULT := TRUE
'                clears Error Message 
'                sets ACK Message                
'             -ELSE (when NOT ACKnowledged or timed out)
'                RESULT := FALSE
'                Sets ACK Message                    
'+Reads/Uses: 53_000 to check for a for a max. 53 sec delay                                               
'    +Writes: None                                    
'      Calls: None
'       Note: If operation is not acknowledged or timed out then preset
'             error message 'drops through'                                          
'------------------------------------------------------------------------- 

c := UART.RxTime(100)
CASE c
  _ACK:
    oKay := TRUE
    ptr_Ack_Message := @strAckMess00
    ptr_Error_Message := @strNull
  _NAK:
    oKay := FALSE
    ptr_Ack_Message := @strAckMess01 
  OTHER:
    oKay := FALSE
    ptr_Ack_Message := @strAckMess02
    
RETURN oKay
'-------------------------------------------------------------------------


DAT

strNull      BYTE 0                    'Null string

'Acknowledge error messages
strAckMess00 BYTE "ACKnowledged", 0
strAckMess01 BYTE "Not ACKnowledged", 0
strAckMess02 BYTE "ACK Timed Out", 0
strAckMess03 BYTE "Not Checked", 0

'uOLED function error messages
strErrMess00 BYTE "UART Not Started", 0
strErrMess01 BYTE "No AutoBaud Response", 0
strErrMess02 BYTE "Address not available", 0
strErrMess03 BYTE "Sector Write Failed", 0
strErrMess04 BYTE "Sector Verify Failed", 0

'Frame Display & Scroll error messages
strErrMess10 BYTE "Display Position Error", 0
strErrMess11 BYTE "Scroll Position Error", 0


{{

┌────────────────────────────────────────────────────────────────────────┐
│                        TERMS OF USE: MIT License                       │                                                            
├────────────────────────────────────────────────────────────────────────┤
│  Permission is hereby granted, free of charge, to any person obtaining │
│ a copy of this software and associated documentation files (the        │ 
│ "Software"), to deal in the Software without restriction, including    │
│ without limitation the rights to use, copy, modify, merge, publish,    │
│ distribute, sublicense, and/or sell copies of the Software, and to     │
│ permit persons to whom the Software is furnished to do so, subject to  │
│ the following conditions:                                              │
│                                                                        │
│  The above copyright notice and this permission notice shall be        │
│ included in all copies or substantial portions of the Software.        │  
│                                                                        │
│  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND        │
│ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     │
│ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. │
│ IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   │
│ CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   │
│ TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      │
│ SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 │
└────────────────────────────────────────────────────────────────────────┘
}}
                                                                                                