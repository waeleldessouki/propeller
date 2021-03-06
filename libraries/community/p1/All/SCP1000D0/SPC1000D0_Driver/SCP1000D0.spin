''=============================================================================
'' @file     SCP1000D0.spin
'' @target   Propeller
''
'' SCP1000D0 routines
''
'' @author   B Mathias Johansson 
''
'' Copyright (c) 2009
'' See end of file for terms of use.
''       
'' @version  V0.1 - Jan, 2009
'' @changes
''  - original version
''=============================================================================
CON
  'Delay
  Del = 800

  'Commands
  Cmd_Reset  = $01
  Cmd_Write  = true
  Cmd_Read   = false
  Cmd_17bit  = $05 'to CFG
  Cmd_DataWR = $06
  Cmd_LPM = $0C

  'Direct regs
  Reg_DataWR = $01
  Reg_AddPtr = $02
  Reg_Operation = $03
  Reg_OpSatus = $04
  Reg_Reset =  $06
  Reg_Status = $07
  Reg_P8 = $1F
  Reg_P16 = $20
  Reg_T = $21
  Reg_Rev = $00
  Reg_Temp = $81 

VAR
  word drdy, csb, miso, mosi, sck
  long temp
  
PUB start(drdy_pin, csb_pin, miso_pin, mosi_pin, sck_pin):ok 
    'Assign SCP1000D0 pins and reset device
    drdy := drdy_pin                                                             
    csb  := csb_pin
    miso := miso_pin
    mosi := mosi_pin
    sck := sck_pin

    'Wait for SCP to init 60ms (dont know if SCP powerup is finished when start is called)
    waitcnt(4_800_000 + cnt)
    'Wait for SCP to preform selftests 90ms (dont know if SCP powerup is finished when start is called)                               
    waitcnt(7_200_000 + cnt)
  
    dira[drdy]~   'Set drdy DataReady to input                                      '

    outa[csb]~~   'Set ChipSelect to high (active low)
    dira[csb]~~   'Set ChipSelect to output

    dira[miso]~   'Set MISO to input 

    outa[mosi]~   'Set MOSI to low
    dira[mosi]~~  'Set MOSI to output

    outa[sck]~   'Set sck to low
    dira[sck]~~  'Set sck to output

    sendReset
    
PUB getSample : presure
    if ina[drdy]  'This is not right (the caller must reset the divice)
       presure:= -1
    else  
       sendCommand(Reg_Operation,Cmd_LPM)  'Single shot
       repeat until ina[drdy]              'Wait for data
       temp:= reciveWord(Reg_Temp)         'Read and store temperature value
       presure:= reciveByte(Reg_P8)        'Read 16 lowest bits
       presure&= %111                      'Mask out 3 lowest bits
       presure<<=16                        'Make room for 16 lowest bits
       presure|= reciveWord(Reg_P16)       'Read 16 lowest bits
       
PUB getChipVersion : ver    
    ver:= reciveByte(Reg_Rev)

PUB getOPStatus
    result:= reciveByte(Reg_OpSatus)

PUB getASICStatus
    result:= reciveByte(Reg_Status)

PUB getDRDY
    result:= ina[drdy]
    
PUB sendReset
    sendCommand(Reg_Reset,Cmd_Reset)
    'Wait for SCP to init 60ms
    waitcnt(4_800_000 + cnt)
    'Wait for SCP to preform selftets 90ms                                    
    waitcnt(7_200_000 + cnt)

PRI sendCommand(register,command)'Sends a command to SCP1000
    register <<= 2     'Make the address 8 bits
    register |= 10     '1 = write to adress 0 = padbit

    outa[csb]~         'Enable SPI to SCP1000
    waitcnt(Del + cnt) 'Sig. Stab.
    
    spiComm(register,8)  'Send 8 bits register address
    spiComm(command,8)   'Send 8 bits command to register
    
    outa[csb]~~        'Disable SPI to device SCP1000
    waitcnt(Del + cnt) 'Sig. Stab.

PRI reciveWord(register):in 'Read 16-bit register
    register<<= 2           'Make the address 8 bits
    register|= 00           '0 = read from address 0 = padbit

    outa[csb]~              'Enable SPI to SCP1000
    waitcnt(Del + cnt)      'Sig. Stab.
    
    spiComm(register,8)     'Write 8 bits address to device
                            'In is nothing, we need to clock in another 16 bits
    in:= spiComm(0,16)      'Send nothing, but we should get back the 16 bits register value
 
    outa[csb]~~             'Disable SPI to device SCP1000
    waitcnt(Del + cnt)      'Sig. Stab.

PRI reciveByte(register):in  ' Read 8-bit register
    register<<= 2            ' Make the address 8 bits
    register|= 00            ' 0 = read from address 0 = padbit

    outa[csb]~               ' Enable SPI to SCP1000
    waitcnt(Del + cnt)       ' Sig. Stab

    spiComm(register,8)      ' Write 8 bits address to device
                             ' in is nothing, we need to clock in another 8 bits
    in:= spiComm(0,8)        ' Send nothing, but we should get back the 8 bits register value

    outa[csb]~~              ' Disable SPI to device SCP1000
    waitcnt(Del + cnt)       ' Sig. Stab

PRI spiComm(out,bits):in|shift  ' Basic SPI duplex send and receive
    shift:= bits-1
    repeat bits
      outa[sck]~                ' SPI clock low
      waitcnt(Del + cnt)        ' Sig. Stab
      outa[mosi] := out>> shift ' Put bit on SPI data bus
      out <<= 1                 ' Rotate byte 1 to the left
      waitcnt(Del + cnt)        ' Sig. Stab
      outa[sck]:=true           ' SPI clock high
      waitcnt(Del + cnt)        ' Sig. Stab
      in <<= 1                  ' Rotate byte 1 to the left
      in |= ina[miso]           ' Or with incoming SPI data
      waitcnt(Del + cnt)        ' Sig. Stab

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