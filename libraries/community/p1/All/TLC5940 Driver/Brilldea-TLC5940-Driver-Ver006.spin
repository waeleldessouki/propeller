''**************************************
''
''  TLC5940 Driver Ver. 00.6
''
''  Timothy D. Swieter, E.I.
''  www.brilldea.com
''
''  Copyright (c) 2008 Timothy D. Swieter, E.I.
''  See end of file for terms of use. 
''
''  Updated: May 14, 2008
''
''Description:
''This program sends grey scale data to 3 TI TLC5940
''LED control chips wired in series.  Multiple cogs
''can be launched with this program.
''
''This program launches a cog, configures the I/O
''and then clocks out data out to the chips when flagged to do so.
''This program only uses the upper 8 bits of the 12 bits
''available for each channel.  The data is loaded into a
''buffer.  There is a two buffer system.  Data is loaded
''into the offscreen buffer.  When ready the offscreen buffer
''is copied to the onscreen buffer.  This program runs at
''about a 40+frames/second.
''
''reference:
''      tlc5940.pdf (Datasheet for chip)
''      Parallax Forums (discussion regarding TLC5940)
''
''To Do:
''      add dot correction capability
''      convert serial shifting routine to ASM
''
''Revision Notes:
'' 0.4 Initial release
'' --- Update object to include MIT License
''     Made the document prettier and added comments
'' 0.5
'' 0.6 Changed variables and code so that up to 6 LED Painters
''     can be connected in a series
''
''**************************************
CON
'***************************************
  
  '***************************************
  ' System Definitions     
  '***************************************

  _OUTPUT       = 1             'Sets pin to output in DIRA register
  _INPUT        = 0             'Sets pin to input in DIRA register  
  _HIGH         = 1             'High=ON=1=3.3v DC
  _ON           = 1
  _LOW          = 0             'Low=OFF=0=0v DC
  _OFF          = 0
  _ENABLE       = 1             'Enable (turn on) function/mode
  _DISABLE      = 0             'Disable (turn off) function/mode

  _test         = 381

'***************************************
VAR               'Variables to be located here
'***************************************

  'Cog related
  long  cog                     'Values of cog running driver code
  long  stack[40]               'Stack space for spin cog

  'I/O pins
  long  SCLKpin                 'Serial clock line, data is lastched in on rising edge of clock
  long  SINpin                  'Serial data line into the chip
  long  XLATpin                 'Serial latch line, after all data clocked in, then a latch is performed
  long  GSCLKpin                'Reference clock for grayscale PWM control, counts when Blank is low
  long  BLANKpin                'Blanks all outputs when high.  GS counter is also reset.
  long  VPRGpin                 'When low the device is in GS mode.  When high, the device is in DC mode
  long  DCPROGpin               'Always low, high is not used by this driver

  'Data related
  long  UpdateFlag              'Flag to signal a screen update
  long  OffScreenBuffer[72]     'Working buffer to hold data
  long  OnScreenBuffer[72]      'Buffer of data to be sent to the chip
' long  OffScreenBuffer[24]     'Working buffer to hold data
' long  OnScreenBuffer[24]      'Buffer of data to be sent to the chip
' long  OffScreenBuffer[12]     'Working buffer to hold data
' long  OnScreenBuffer[12]      'Buffer of data to be sent to the chip

'***************************************
OBJ               'Object declaration to be located here
'***************************************

  GSCLK         : "Brilldea-GSCLK-Driver-Ver001.spin"   'Driver isn't complete, but it works

'***************************************
PUB StartTLC5940(_sclk, _sin, _xlat, _gsclk, _blank, _vprg, _dcprog) : okay
'***************************************
'' Start TLC5940 driver - setup I/O pins, initiate variables, starts a cog
'' returns cog ID (1-8) if good or 0 if no good

  'Qualify the I/O values to see if they are good
  if lookdown(_sclk: 31..0)
    if lookdown(_sin: 31..0)
      if lookdown(_xlat: 31..0)
        if lookdown(_gsclk: 31..0)
          if lookdown(_blank: 31..0)
            if lookdown(_vprg: 31..0)
              if lookdown(_dcprog: 31..0)

                'Start a cog with the update/serial shifting routine
                okay:= cog:= cognew(SendDataTLC5940(_sclk, _sin, _xlat, _gsclk, _blank, _vprg, _dcprog), @stack) + 1 'Returns 0-8 depending on success/failure

'***************************************
PUB StopTLC5940
'***************************************
'' Stops a cog running the TLC5940 driver (only allows one cog)

  if cog
    cogstop(cog~ -  1)

'***************************************
PUB SetChValue(_ch, _red, _grn, _blu) | temp0, temp1, temp2
'***************************************
'' Set an RGB value for a specific channel - 8 bit for each color

  'Qualify that the channel and value must be correct  
  if lookdown(_ch: 96..0)
    if lookdown(_red: 255..0)
      if lookdown(_grn: 255..0)
        if lookdown(_blu: 255..0)
          'Calculate the address where to move the data
          if 15 => _ch
            temp0 := _ch + @OffScreenBuffer[0]
            temp1 := _ch + @OffScreenBuffer[4]
            temp2 := _ch + @OffScreenBuffer[8]
          elseif 31 => _ch
            temp0 := (_ch - 16) + @OffScreenBuffer[12]
            temp1 := (_ch - 16) + @OffScreenBuffer[16]
            temp2 := (_ch - 16) + @OffScreenBuffer[20]
          elseif 47 => _ch
            temp0 := (_ch - 32) + @OffScreenBuffer[24]
            temp1 := (_ch - 32) + @OffScreenBuffer[28]
            temp2 := (_ch - 32) + @OffScreenBuffer[32]
          elseif 63 => _ch
            temp0 := (_ch - 48) + @OffScreenBuffer[36]
            temp1 := (_ch - 48) + @OffScreenBuffer[40]
            temp2 := (_ch - 48) + @OffScreenBuffer[44]
          elseif 79 => _ch
            temp0 := (_ch - 64) + @OffScreenBuffer[48]
            temp1 := (_ch - 64) + @OffScreenBuffer[52]
            temp2 := (_ch - 64) + @OffScreenBuffer[56]
          else
            temp0 := (_ch - 80) + @OffScreenBuffer[60]
            temp1 := (_ch - 80) + @OffScreenBuffer[64]
            temp2 := (_ch - 80) + @OffScreenBuffer[68]                                    
          'Move the data
          bytemove(temp0, @_red, 1)
          bytemove(temp1, @_grn, 1)
          bytemove(temp2, @_blu, 1)                    

'***************************************
PUB UpdateScreen
'***************************************
'' Flags for a screen update 
'' This routine must be called for the data to be sent

  UpdateFlag := _ENABLE

'***************************************
PRI SendDataTLC5940(_sclk, _sin, _xlat, _gsclk, _blank, _vprg, _dcprog) | temp0
'***************************************
'' The main code that runs in another cog
'' An update is sent of grey scale data in the OnScreenBuffer

  'Initialize the I/O and start a grey scale clock cog running
  'this is done from within this routine so that the proper cog
  'has the proper I/O configured.  
  InitTLC5940(_sclk, _sin, _xlat, _gsclk, _blank, _vprg, _dcprog)

  'Loop forever sending data out
  repeat    

    'The routine only sends data when there is an update
    'so it holds here until flagged to update
    repeat until UpdateFlag

    'Clear the flag
    UpdateFlag := _Disable           

    'Moves the off screen buffer to the on screen buffer
    longmove(@OnScreenBuffer, @OffScreenBuffer, 72)
  
    '6 longs in a transmission of grey scale data for one chip
    'Shifted from MSB (CH15 long 11) to LSB (CH0 long 0)
    repeat temp0 from 71 to 0
      '4 channels in a long
      repeat 4
        '8 bits of channel data, plus 4 padded bits
        repeat 8
          'Shift the MSB onto the output line
          outa[SINpin] := (OnScreenBuffer[temp0] <-= 1) & 1

'          waitcnt(_test + cnt)
          
          'Toggle the clock pin high
          outa[SCLKpin] := _HIGH

'          waitcnt(_test + cnt)
          
          'Toggle the clock pin low
          outa[SCLKpin] := _LOW
        outa[SINpin] := _LOW

        waitcnt(_test + cnt)
        
        'clock out four low bits
        repeat 4
          'Toggle the clock pin high
          outa[SCLKpin] := _HIGH

'         waitcnt(_test + cnt)
                    
          'Toggle the clock pin low
          outa[SCLKpin] := _LOW
    'Toggle the latch pin high
    outa[XLATpin] := _HIGH
    'Toggle the latch pin low
    outa[XLATpin] := _LOW
    'Toggle the clock high one more time (according to data sheet)
    outa[SCLKpin] := _HIGH
    'Toggle the clock low one more time (according to data sheet)
    outa[SCLKpin] := _LOW   

'***************************************
PRI InitTLC5940(_sclk, _sin, _xlat, _gsclk, _blank, _vprg, _dcprog) | temp0
'***************************************

''Initializes the I/O based on parameters

  'Initialize the I/O direction and state
  SCLKpin := _sclk              'Clock for data going to/from the chip
  dira[SCLKpin] := _OUTPUT
  outa[SCLKpin] := _LOW

  SINpin  := _sin               'Data going into the chip
  dira[SINpin] := _OUTPUT
  outa[SINpin] := _LOW

  XLATpin := _xlat              'Latch for the chip
  dira[XLATpin] := _OUTPUT
  outa[XLATpin] := _LOW

  VPRGpin := _vprg              'Multimode pin, see datasheet
  dira[VPRGpin] := _OUTPUT
  outa[VPRGpin] := _LOW

  DCPROGpin := _dcprog          'Unused, but must be high
  dira[DCPROGpin] := _OUTPUT
  outa[DCPROGpin] := _LOW

  'Send out zeros to everything before starting greyscale    
  '6 longs in a transmission of grey scale data for one chip
  'Shifted from MSB (CH15 long 11) to LSB (CH0 long 0)
  repeat temp0 from 71 to 0
    '4 channels in a long
    repeat 4
        '8 bits of channel data, plus 4 padded bits
        repeat 8
          'Shift the MSB onto the output line
          outa[SINpin] := (OnScreenBuffer[temp0] <-= 1) & 1

          
'         waitcnt(_test + cnt)


          'Toggle the clock pin high
          outa[SCLKpin] := _HIGH

'         waitcnt(_test + cnt)
                    
          'Toggle the clock pin low
          outa[SCLKpin] := _LOW
        outa[SINpin] := _LOW

'       waitcnt(_test + cnt)
                  
        'clock out four low bits
        repeat 4
          'Toggle the clock pin high
          outa[SCLKpin] := _HIGH

          waitcnt(_test + cnt)
                                        
          'Toggle the clock pin low
          outa[SCLKpin] := _LOW
  'Toggle the latch pin high
  outa[XLATpin] := _HIGH
  'Toggle the latch pin low
  outa[XLATpin] := _LOW
  'Toggle the clock high one more time (according to data sheet)
  outa[SCLKpin] := _HIGH
  'Toggle the clock low one more time (according to data sheet)
  outa[SCLKpin] := _LOW   

  'Begin routines in seperate cog, done last so that zeros are in the registers before
  'data clocking so the display doesn't blink or change wildly on startup
  GSCLK.Start(_gsclk, _blank)   'Start a cog that solely handles the greyscale clock (PWM)

'***************************************
DAT                             
'***************************************
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