{{
┌───────────────────────────────┬───────────────────┬────────────────────┐
│      uOLED_Demo.spin v1.0     │ Author: I.Kövesdi │ Rel.: 22. Feb 2009 │  
├───────────────────────────────┴───────────────────┴────────────────────┤
│                    Copyright (c) 2009 CompElit Inc.                    │               
│                   See end of file for terms of use.                    │               
├────────────────────────────────────────────────────────────────────────┤
│  Based upon this application you can display any 128x128 sized Image   │
│ part of a large picture stored on the SD card of the uOLED-128-GMD1    │
│ module. This can help in making a scrolling map background for a GPS   │
│ based product.                                                         │
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
│  It does not really matter what method do you use to load large picture│
│ files in the SD card. The only recommendations are to start Picture at │
│ the beginning of a sector and then continue to write pixel data        │
│ row-wise without 'not used gaps' on the card. The Image reconstruction │
│ algorithm relies on continuously stored pixel data of the lage Picture.│
│ -The PictDownLoad.exe WindowsXP application with the image processing  │
│ standard Lena (Lenna) pictures will be send via e-mail upon request as │
│ one of the solutions to store a large Picture on the SD card.          │
│                                                                        │ 
└────────────────────────────────────────────────────────────────────────┘  
}}


CON

_CLKMODE = XTAL1 + PLL16X                        
_XINFREQ = 5_000_000

_ON      = 1
_OFF     = 0

'SD card parameters
_SD_SECTOR_SIZE    = 512
_MAX_SD_SECT_ADDR  = 1_983_999   'For a nominal 1G NOKIA SD card.

'This value depends on SD capacity, brand and on the formatting software.
'I have found it out with experimentation for a given type of SD card.
'My simple method was to run a program that reads the upper 7% of the
'card, sector by sector, while displaying the sector address. It takes a
'lot of time but it freezes reliably at the first unavailable sector
'address. (apprx.100 ms/sector for about an hour on 1G then stops)
  

VAR

LONG dev_Type
LONG hrdwr_Rev
LONG sftwr_Rev
LONG h_Res
LONG v_Res

BYTE sector_Data[_SD_SECTOR_SIZE]


OBJ

DBG   : "FullDuplexSerial"
OLED  : "uOLED128GMD1"
 

PUB Init | oKay, i, j, cntr, b1, b2, s1, a1, s2, a2
'-------------------------------------------------------------------------
'-----------------------------------┌──────┐------------------------------
'-----------------------------------│ Init │------------------------------
'-----------------------------------└──────┘------------------------------
'-------------------------------------------------------------------------
''     Action: -Starts the drivers that will launch a COG directly or
''             implicitly
''             -Checks for successful starts
''             -If so : Calls demo procedures Please read note.
'' Parameters: None                                 
''    Results: None                     
''+Reads/Uses: None                                               
''    +Writes: None                                    
''      Calls: FullDuplexSerialPlus----------->DBG.Start                      
''             uOLED128GMD1------------------->OLED.InitDevice                         
''             Load_Picture_To_SD(1_000) to download_Lena_Small
''             Load_Picture_To_SD(2_000) to download_Lena_Standard
''             Demo_Lena_Standard
''       Note: -First you have to download Picture files from the PC in
''             the SD card of the uOLED-128_GMD1 module.
''             -Comments guide you to download the 128x128 'Lena_Small'
''             and the 512x512 'Lena_Standard' Pictures in the SD card.
''             -After successful downloads, decomment the 'Download_Lena_'
''             procedures and activate the 'Lena_Standard_Demo' one.                                                       
'-------------------------------------------------------------------------

Delay(4_000)

'Start FullDuplexSerialPlus Driver for debug. The Driver will launch a
'COG for serial communication with Parallax Serial Terminal
IF (oKay := DBG.Start(31, 30, 0, 57600))
  DBG.Str(STRING(16, 1))
  DBG.Str(STRING("UART for Debug Terminal Started.", 10, 13))
  Delay(1000)
  IF (OLED.InitDevice)            'uOLED is OK
    OLED.Contrast(10)             'To elongate life of the display
    DBG.Str(STRING("4D SYSTEMS module is initialized.", 10, 13))
    OLED.Device_Info(1,@dev_Type,@hrdwr_Rev,@sftwr_Rev,@h_Res,@v_Res)

    IF (dev_Type<>$00)OR(h_Res<>$28)OR(v_Res<>$28)
      DBG.Str(STRING("Other than uOLED-128-GMD1 module is detected!"))
      DBG.Str(STRING(10, 13))
      DBG.Str(STRING("Reset module manually if the screen is not dimm!"))
      DBG.Str(STRING(10, 13))
      DBG.Str(STRING("Then remove Power quickly while display is dimm."))
      DBG.Str(STRING(10, 13))
      DBG.Str(STRING("Check everything before next Power On. Take care."))
      DBG.Str(STRING(10, 13))
      REPEAT                      'Until power OFF
    ELSE
      DBG.Str(STRING("uOLED-128-GMD1 module is detected."))
      DBG.Str(STRING(10, 13)) 
      DBG.Str(STRING("  Module Ver: "))
      DBG.Hex(dev_Type,2)
      DBG.Str(STRING(10, 13))
      DBG.Str(STRING("Hardware Rev: "))
      DBG.Hex(hrdwr_Rev,2)
      DBG.Str(STRING(10, 13))
      DBG.Str(STRING("Software Rev: "))
      DBG.Hex(sftwr_Rev,2)
      DBG.Str(STRING(10, 13))
      
    Delay(6_000)

    'I used PictDownload.exe with (of course) the same UART settings as
    'for the PST debug. So, first you have to see the debug printouts on
    'the PST window to verify a proper serial connection.
    
    'I placed the large picture completely on the screen and I did not
    'allow screen or energy savers to redraw the screen during download.
    'It is designed to work, and maybe it works with that way, too. But I
    'did not verified that up till now.
    
    'Download Lena Small (It worked with 100 ms sector delay)
    Load_Picture_To_SD(1_000)
  
    'If this was successful, comment out the previous code line and
    'decomment the next load procedure, before recompiling 
  
    'Download Lena Standard
    'Load_Picture_To_SD(2_000)       '<--next procedure

    'If this step was successful, too, then comment out the previous code
    'line and activate the next demo procedure before recompiling

    'Demo_Lena_Standard

    Shut_Off


ELSE
  'uOLED initialization failed. We may have now a problem here with
  'Power Off. Take care.
  DBG.Str(STRING("uOLED Error:"))
  DBG.Str(OLED.Error_Message)
  DBG.Str(STRING(10, 13))
  OLED.Reset
'After this, remove power, preferably while the screen is dimm. We did not
'establish communication with the module, so we cannot initiate a proper
'PowerDown sequence. Please, do not make this very often. Before trying
'again, please check (and double check) everything. If you did not take
'the trouble to make the Reset line connection, you can reset uOLED with a
'ground connected wire before power off.
'-------------------------------------------------------------------------


PUB Demo_Lena_Standard
'-------------------------------------------------------------------------
'--------------------------┌────────────────────┐-------------------------
'--------------------------│ Demo_Lena_Standard │-------------------------
'--------------------------└────────────────────┘-------------------------
'-------------------------------------------------------------------------
''     Action: -Displays the 'Lena_Small' Image for a while
''             -Displays some Images from the 'Lena_Standard' Picture                                                          
'' Parameters: None                                 
''    Results: None                     
''+Reads/Uses: SD card sectors of the 'Lena_Small' and 'Lena_Standard'
''             Pictures starting at sector 1_000(64) and sector
''             2_000(1024), respectively                                               
''    +Writes: 64 SD card sectors starting at sector 10_000(64)                                    
''      Calls: uOLED128GMD1---------->OLED.Collect_Image_From_Picture
''                                    OLED.Disp_Image_From_SD                                        
'-------------------------------------------------------------------------

'Display Lena Small first, No Image collection needed here.
OLED.Disp_Image_From_SD(0,0,128,128,16,1000)
  
'Meanwhile collect the second frame from Lena Standard
OLED.Collect_Image_From_Picture(2_000,512,512,240,80,10_000)
'Display it.
OLED.Disp_Image_From_SD(0,0,128,128,16,10_000)

'Collect and display some other Images from Lena Standard Picture

OLED.Collect_Image_From_Picture(2_000,512,512,240,120,10_000)
OLED.Disp_Image_From_SD(0,0,128,128,16,10_000)

OLED.Collect_Image_From_Picture(2_000,512,512,240,160,10_000)
OLED.Disp_Image_From_SD(0,0,128,128,16,10_000)
        
OLED.Collect_Image_From_Picture(2_000,512,512,240,200,10_000)
OLED.Disp_Image_From_SD(0,0,128,128,16,10_000)

OLED.Collect_Image_From_Picture(2_000,512,512,240,240,10_000)
OLED.Disp_Image_From_SD(0,0,128,128,16,10_000)

OLED.Collect_Image_From_Picture(2_000,512,512,240,280,10_000)
OLED.Disp_Image_From_SD(0,0,128,128,16,10_000)

OLED.Collect_Image_From_Picture(2_000,512,512,240,320,10_000)
OLED.Disp_Image_From_SD(0,0,128,128,16,10_000)

OLED.Collect_Image_From_Picture(2_000,512,512,230,240,10_000)
OLED.Disp_Image_From_SD(0,0,128,128,16,10_000)
    
REPEAT 3
  Delay(50_000)

'Display Lena Small again to signal finish of demo
OLED.Disp_Image_From_SD(0,0,128,128,16,1000)  
Delay(10_000)
'-------------------------------------------------------------------------

PUB Shut_Off
'-------------------------------------------------------------------------
'-------------------------------┌───────────┐-----------------------------
'-------------------------------│ Shut_Off  │-----------------------------
'-------------------------------└───────────┘-----------------------------
'-------------------------------------------------------------------------
''     Action: Shuts off the display
'' Parameters: None                                 
''    Results: None                     
''+Reads/Uses: None                                        
''    +Writes: 64 SD card sectors starting at sector 10_000(64)                                    
''      Calls: uOLED128GMD1---------->OLED.Shut_Down
''             FullDuplexSerial------>DBG.Str                                       
'-------------------------------------------------------------------------
OLED.Shut_Down
DBG.Str(STRING(10, 13)) 
DBG.Str(STRING("Now you can remove power from uOLED-128-GMD1",10,13))
'-------------------------------------------------------------------------



PUB Load_Picture_To_SD(sectAddr)|highByte,lowByte,noOfSectors,i,j,k
'-------------------------------------------------------------------------
'--------------------------┌────────────────────┐-------------------------
'--------------------------│ Load_Picture_To_SD │-------------------------
'--------------------------└────────────────────┘-------------------------
'-------------------------------------------------------------------------
''     Action: Reads a large Picture file from the PC and stores it in the
''             SD card while using the uOLED-128-GMD1 as a debug display                                                                    
'' Parameters: Sector Address                                 
''    Results: Picture file on SD starting at the specified sector                     
''+Reads/Uses: None                                       
''    +Writes: None                                    
''      Calls: uOLED128GMD1--------------->OLED.Clear_Screen
''                                         OLED.Opaque_Text
''                                         OLED.Pen_Color
''                                         OLED.Text_Formatted
''                                         OLED.Text_Unformatted
''                                         OLED.Write_SD_Sector
''             FullDuplexSerial----------->DBG.Rx
''       Note: Picture file should be not smaller than 128x128 pixels
'-------------------------------------------------------------------------   

OLED.Clear_Screen
OLED.Opaque_Text

IF NOT OLED.Verify_Sector_Address(sectAddr)
  OLED.Pen_Color(255,0,0) 
  OLED.Text_Formatted(0,1,2,STRING("Invalid Sector!"),0)
  OLED.Text_Formatted(0,2,2,STRING("Quitting..."),0)
  Delay(4_000)
  RETURN 
ELSE
  OLED.Pen_Color(255,255,0) 
  OLED.Text_Formatted(0,1,2,STRING("Waiting for"),0)
  OLED.Text_Formatted(0,2,2,STRING("Reception..."),0) 

  'Receiving No. of Sectrors
  highByte := DBG.Rx
  lowByte := DBG.Rx

  noOfSectors := 256 * highByte + lowByte

  i := sectAddr + noOfSectors

  IF NOT OLED.Verify_Sector_Address(i)
    OLED.Pen_Color(255,0,0) 
    OLED.Text_Formatted(0,1,2,STRING("Invalid Sector!"),0)
    OLED.Text_Formatted(0,2,2,STRING("Quitting..."),0)
    Delay(4_000)
    RETURN 
  ELSE
    OLED.Clear_Screen
    OLED.Pen_Color(0,255,0) 
    OLED.Text_Formatted(0,1,2,STRING("Receiving data.."),0) 

    OLED.Pen_Color(0,255,0) 
    REPEAT i FROM 0 TO (noOfSectors-1)
      REPEAT j FROM 0 to (_SD_SECTOR_SIZE - 1)
        sector_Data[j] := DBG.Rx
      k := sectAddr + i  
      OLED.Write_SD_Sector(k,@sector_Data)  
      OLED.Clear_Screen
      OLED.Text_Formatted(0,1,2,STRING("Write to sector"),0)
      OLED.Text_Unformatted(0, 25, 2, 2, 2, k, 1)
      k := noOfSectors - i - 1  
      OLED.Text_Formatted(0,4,2,STRING("Not yet received"),0)
      OLED.Text_Unformatted(0, 61, 2, 2, 2, k, 1)
      OLED.Text_Formatted(0,7,2,STRING("sector"),0)
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
   