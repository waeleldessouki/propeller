{{
┌──────────────────────────────────────────┐
│ vs1002 MP3 Decoder Driver                │
│ Author: Kit Morton                       │               
│ Copyright (c) 2008 Kit Morton            │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘

This object provides high speed access to the vs10002 mp3 decoder from VLSI Solution (www.vlsi.fi)
Although this object was written for the vs1002 it should work for the vs1003 and vs1033.

This driver does not use the DREQ output from the vs1002 so be aware that your program needs to listen to this line.
If you are not using a 24.576 MHz crystal for the vs1002 then you have to set the clock multiplier. Refer to page 28
of the datasheet for more information.

Functions:
     Start                   This function starts the cog that the ASM driver runs in, and sets up the object of
                             operation. Always call this before using the object.
     WriteDataByte           Send one byte of mp3 data to decode.
     WriteDataBuffer         Send 32 bytes of mp3 data to the vs1002 from the memory address givin.
     Volume                  Returns the current volume of the chip
     SetVolume               Sets the Volume of playback. NewVol must be between 0 and 255. Balance must be between -20 and 20, with -20
                             all the way to the left and 20 all the way to the right.
     SetBaseBoost            Set how mutch the bass is boosted (read the datasheet for more information on the bass boost)
                             Value must be between 0 and 15
     SetFreqLimit            Set the lower frequency limit of your sound system, also used for bass boost. Value must be between 0 and 15.
     Mode                    The current status of the Mode Control register. Bit is a bit mask for the bit of the register you want.
     ReadReg                 This function allows you to read any register of the vs1002
     WriteReg                This function allows you to write any register of the vs1002
     Stop                    Kills the ASM driver cog.   
}}
 
CON
  DIFF      = %00000000_00000001                                                                                                                                                                                                                                                
  RESET     = %00000000_00000100
  OUTOFWAV  = %00000000_00001000
  PDOWN     = %00000000_00010000          
  TESTS     = %00000000_00100000
  STREAM    = %00000000_01000000
  PLUSV     = %00000000_10000000
  DACT      = %00000001_00000000
  SDIORD    = %00000010_00000000
  SDISHARE  = %00000100_00000000
  SDINEW    = %00001000_00000000
  ADPCM     = %00010000_00000000
  ADPCM_HP  = %00100000_00000000
  
VAR                                                                                          
  Long  Operation, RegName, RegValue, DataAddr, Data    ' Misc. hub variables
  Long  cog
  Byte  CurrentVolume
  Word  ModeReg

PUB Start(MOSIPin,MISOPin,CLKPin,CSPin,DCSPin) : okay

  MOSI := |<MOSIPin
  MISO := |<MISOPin
  CLK  := |<CLKPin
  CS   := |<CSPin
  DCS  := |<DCSPin

  okay := cog := cognew(@entry, @Operation) + 1

  CurrentVolume := 0
  
  ModeReg := %00001000_00000000


PUB WriteDataBuffer(OutputDataAddr)
  DataAddr := OutputDataAddr
  repeat until Operation == 0
  Operation := 3
  repeat until Operation == 0

PUB WriteDataByte(OutputData)
  Data := OutputData
  Repeat until Operation == 0
  Operation := 4
  Repeat until Operation == 0

PUB SetBassBoost(Value) | OldBass
  OldBass := ReadReg(2)
  OldBass &= %00000000_00000000_00000000_00001111 'Clear Old Bass Vlaue
  Value <<= 4
  OldBass |= Value
  WriteReg(2,OldBass)

PUB SetFreqLimit(Value) | OldFreq
  OldFreq := ReadReg(2)
  OldFreq &= %00000000_00000000_00000000_11110000 'Clear Old Freq Vlaue
  OldFreq |= Value
  WriteReg(2,OldFreq)    

PUB SetVolume(NewVol,CurrBalance) | Output, Vol
  Vol := 255 - NewVol
  if CurrBalance < 0
    Output := (Vol + CurrBalance) << 8
    Output |= Vol - Currbalance
  else
    Output := (Vol + Currbalance) << 8
    Output |= Vol - CurrBalance
  CurrentVolume := NewVol
  WriteReg(11,Output)
  waitcnt(cnt + 3773)
  Return(Output)
         
PUB Volume
  Return(CurrentVolume)

PUB Mode(Bit)
  Return(ModeReg & Bit)
  
PUB SetMode(Bit, Value)
  If Value == 0
    ModeReg &= !Bit
  else
    ModeReg |= Bit

  WriteReg(0,ModeReg)

PUB ReadReg(CurrRegName)
  RegName := CurrRegName
  repeat until Operation == 0
  Operation := 1
  repeat until Operation == 0
  waitcnt(cnt + 3773)
  result := RegValue  

PUB WriteReg(CurrRegName,CurrRegValue)
  RegName := CurrRegName
  RegValue := CurrRegValue
  repeat until Operation == 0
  Operation := 2
  repeat until Operation == 0
  waitcnt(cnt + 3773)

PUB stop

'' Stop flashing - frees a cog

  if cog
    cogstop(cog~ -  1) 


DAT
entry ' Cond. Instruction                       Effect  comment
                                                        ' Setup pins                  
              or        dira,MOSI                           ' Make MOSI an output
              andn      outa,MOSI                           ' Set MOSI low

              andn      dira,MISO                           ' Make MISO and input

              or        dira,CLK                            ' Make CLK an output
              andn      outa,CLK                            ' Set CLK low

              or        dira,CS                             ' Make CS an output
              or        outa,CS                             ' Set CS High

              or        dira,DCS                            ' Make DCS an output
              or        outa,DCS                            ' Set DCS High
                                                                       
loop                                                                                                                     
                                                        ' Get current operation
              mov       TempAddr,par            wz          ' Move the address of the first hub variable to TempAddr                                                
              rdlong    _Operation,TempAddr                 ' Read Operation from hub to _Operation

                                                        ' Jump to current operation               
              cmp       _Operation,#0           wz          ' Compare _Operation to zero and put the result in Z
        if_z  jmp       #loop                               ' If _Operation is zero then loop around again
              cmp       _Operation,#1           wz          ' Compare _Operation to one and put the result in Z
        if_z  jmp       #_readreg                           ' If _Operation is one then jump to _readreg
              cmp       _Operation,#2           wz          ' Compare _Operation to two and put the result in Z
        if_z  jmp       #_writereg                          ' If _Operation is two then jump to _writereg
              cmp       _Operation,#3           wz          ' Compare _Operation to three and put the result in Z
        if_z  jmp       #_writedatabuffer                   ' If _Operation is three then jump to _writedatabuffer
              cmp       _Operation,#4           wz          ' Compare _Operation to four and put the result into Z
        if_z  jmp       #_writedatabyte                     ' If _Operation is four ten jump to _writedatabyte
              jmp       #loop                               ' If _Operation is none of the above then loop around again
              
_readreg
              xor       outa,CS                         ' Set CS low, select the chip controll interface
              
              mov       TempAddr,par            wz      ' Move the address of the first hub variable to TempAddr
              add       TempAddr,#4                     ' Add offset for Output Variable
              rdlong    OutputBuffer,TempAddr   wc      ' Read Value of RegName form hub memory in to OutputBuffer

              or        OutputBuffer,ReadCmd            ' Or the read command onto the beginning of the buffer 
              
              mov       BitMask,#%1                     ' Setup bit mask
              shl       BitMask,#16                     ' Move bitmask to 16th bit
                                      
              mov       LoopCount,#16                   ' Set number of bits for output loop counter 
              
:output_loop
              shr       BitMask,#1                      ' Shift the bit mask to the right one bit
              test      OutputBuffer,BitMask    wc      ' Pull current bit out of OutputBuffer and put it on wc
              muxc      Outa,MOSI                       ' Set _MOSI pin the current bit
              call      #clock                          ' Send clock pulse              
              
              djnz      LoopCount,#:output_loop         ' Decrement loop counter and loop back to
                                                        ' :input_loop, if LoopCount is zero then keep going

              andn      outa,MOSI                       ' Force MOSI low

              mov       LoopCount,#16                   ' Set number of bits for input loop couter

:input_loop
              test      MISO,ina                wc      ' Get the current bit form the MISO pin and put it in "C"
              rcl       InputBuffer,#1                  ' Rotate the current bit form "C" into InputBuffer          
              call      #clock                          ' Send clock pulse

              djnz      LoopCount,#:input_loop          ' Decrement loop counter and loop back to
                                                        ' :input_loop, if LoopCount is zero then keep going

              mov       TempAddr,par            wz      ' Move the address of the first hub variable to TempAddr
              add       TempAddr,#8                     ' Add offset for Input
              wrlong    InputBuffer,TempAddr            ' Write InputBuffer to the hub ram

              xor       outa,CS                         ' Set CS high, unselect the chip controll interface                                             

              mov       TempAddr,par            wz      ' Move the address of the first hub variable to TempAddr                                                                                                                  
              wrlong    zero,TempAddr                   ' Clear Operation
              
              jmp       #loop                           ' Go back and wait for the next operation

_writereg
              xor       outa,CS                         ' Set CS low, select the chip controll interface

              mov       TempAddr,par            wz      ' Move the address of the first hub variable to TempAddr
              add       TempAddr,#4                     ' Add offset for Output Variable
              rdlong    OutputBuffer,TempAddr           ' Read Value of RegName form hub memory into OutputBuffer

              or        OutputBuffer,WriteCmd           ' Or the write command onto the beginning of the output buffer  
              
              mov       BitMask,#%1                     ' Setup bit mask
              shl       BitMask,#16                     ' Move bitmask to 16th bit
                                      
              mov       LoopCount,#16                   ' Set number of bits for output loop counter 
              
:name_output_loop
              shr       BitMask,#1                      ' Shift the bit mask to the right one bit
              test      OutputBuffer,BitMask    wc      ' Pull current bit out of OutputBuffer and put it on wc
              muxc      Outa,MOSI                       ' Set _MOSI pin the current bit
              call      #clock                          ' Send clock pulse              
              
              djnz      LoopCount,#:name_output_loop    ' Decrement loop counter and loop back to

              mov       TempAddr,par            wz      ' Move the address of the first hub variable to TempAddr
              add       TempAddr,#8                     ' Add offset for Output Variable
              rdlong    OutputBuffer,TempAddr           ' Read Value of Output form hub memory inot OutputBuffer
              
              mov       BitMask,#%1                     ' Setup bit mask
              shl       BitMask,#16                     ' Move bitmask to 16th bit
                                      
              mov       LoopCount,#16                   ' Set number of bits for output loop counter
                                                        ' :input_loop, if LoopCount is zero then keep going
:value_output_loop
              shr       BitMask,#1                      ' Shift the bit mask to the right one bit
              test      OutputBuffer,BitMask    wc      ' Pull current bit out of OutputBuffer and put it on wc
              muxc      Outa,MOSI                       ' Set _MOSI pin the current bit
              call      #clock                          ' Send clock pulse              
              
              djnz      LoopCount,#:value_output_loop   ' Decrement loop counter and loop back to
              

              andn      outa,MOSI                       ' Force MOSI low

              xor       outa,CS                         ' Set CS high, unselect the chip controll interface                                             

              mov       TempAddr,par            wz      ' Move the address of the first hub variable to TempAddr                                                                                                                  
              wrlong    zero,TempAddr                   ' Clear Operation
              
              jmp       #loop                           ' Go back and wait for the next operation

_writedatabuffer
              xor       outa,DCS                        ' Set DCS low, select the chip data interface
              mov       TempAddr,par            wz      ' Move the address of the first hub variable to TempAddr
              add       TempAddr,#12                    ' Add offset for DataAddr Variable
              rdlong    Outaddr,TempAddr        wc      ' Read Value of DataAddr form hub memory in to OutputAddr

              mov       loopcount,#32                   ' Set the number of bytes to shift out

:Output
              rdbyte    OutputBuffer,Outaddr            ' Read the first byte from hub memory
              add       Outaddr,#1                      ' Incriment the address for the next byte
                                  
              mov       BitMask,#%1                     ' Setup bit mask
              shl       BitMask,#8                      ' Move bitmask to 16th bit
                                      
              mov       LoopCount2,#8                   ' Set number of bits for output loop counter 
              
:output_loop
              shr       BitMask,#1                      ' Shift the bit mask to the right one bit
              test      OutputBuffer,BitMask    wc      ' Pull current bit out of OutputBuffer and put it on wc
              muxc      Outa,MOSI                       ' Set _MOSI pin the current bit
              call      #clock                          ' Send clock pulse              
              
              djnz      LoopCount2,#:output_loop        ' Decrement loopcounter2 and loop back to
                                                        ' :output_loop, if LoopCount2 is zero then keep going
                                                        
              djnz      LoopCount,#:Output              ' Decrement loopcounter and loop back to
                                                        ' :output, if LoopCount is zero then keep going
                                                                                                           
              andn      outa,MOSI                       ' Force MOSI low

              xor       outa,DCS                        ' Set DCS high, unselect the chip data interface                                                

              mov       TempAddr,par            wz      ' Move the address of the first hub variable to TempAddr                                                                                                                  
              wrlong    zero,TempAddr                   ' Clear Operation
              
              jmp       #loop                           ' Go back and wait for the next operation

_writedatabyte
              xor       outa,DCS                        ' Set DCS low, select the chip data interface
              mov       TempAddr,par            wz      ' Move the address of the first hub variable to TempAddr
              add       TempAddr,#16                    ' Add offset for DataAddr Variable
              rdlong    OutputBuffer,TempAddr   wc      ' Read Value of Data form hub memory in to OutputBuffer
                                  
              mov       BitMask,#%1                     ' Setup bit mask
              shl       BitMask,#8                      ' Move bitmask to 16th bit
                                      
              mov       LoopCount,#8                    ' Set number of bits for output loop counter 
              
:output_loop
              shr       BitMask,#1                      ' Shift the bit mask to the right one bit
              test      OutputBuffer,BitMask    wc      ' Pull current bit out of OutputBuffer and put it on wc
              muxc      Outa,MOSI                       ' Set _MOSI pin the current bit
              call      #clock                          ' Send clock pulse              
              
              djnz      LoopCount,#:output_loop         ' Decrement loopcounter and loop back to
                                                        ' :output_loop, if LoopCount2 is zero then keep going
                                                                                                           
              andn      outa,MOSI                       ' Force MOSI low

              xor       outa,DCS                        ' Set DCS high, unselect the chip data interface                                                

              mov       TempAddr,par            wz      ' Move the address of the first hub variable to TempAddr                                                                                                                  
              wrlong    zero,TempAddr                   ' Clear Operation
              
              jmp       #loop                           ' Go back and wait for the next operation
              
clock              
              mov       CLK,#0                  wz, nr  ' Load Z with 1
              mov       Time,cnt                        ' Move curent value of cnt to Time
              add       Time,#30                        ' Add wait time to Time
              muxz      outa,CLK                        ' Set CLK high
              waitcnt   Time,#30                        ' Wait 15 clock ticks
              muxnz     outa,CLK                        ' Set CLK low                                                                                                     
clock_ret     ret        
                                           

{
############################ Defined data #############################
}

zero          long      0                               ' Define as zero to 0
WriteCmd      long      %1000000000
ReadCmd       long      %1100000000     
                                                                                
{
############################# Define Pins #############################
}

MOSI          long      0                               ' Pin number of MOSI
MISO          long      0                               ' Pin number of MISO
CLK           long      0                               ' Pin number of CLK
CS            long      0                               ' Pin number of CS
DCS           long      0                               ' Pin number of DCS

{
########################### Other Variables ###########################
}

_Operation              res     1                       ' Variable that stores the current operaion
OutputBuffer            res     1                       ' Variable to store the data to be shifted out
InputBuffer             res     1                       ' Variable to store the data that has just been shifted in
TempAddr                res     1                       ' Temporary holder for address of first hub variable
Time                    res     1                       ' Use to store count to wait four
BitMask                 res     1                       ' Bit mask for geting bits out of OutputBuffer
LoopCount               res     1                       ' Used to keap track of how many times it has looped around
LoopCount2              res     1                       ' Used to keap track of how many times it has looped around
Outaddr                 res     1

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