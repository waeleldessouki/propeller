{Written by Richard Newstead, G3CWI, May 2012}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  
  'assign pins
  W_CLK    = 3
  FQ_UD    = 2
  SER_DATA = 1
  RST      = 0

  P23      = 23 'Mirrors W_CLK
  P22      = 22 'Mirrors SER_DATA 
  P21      = 21 'Mirrors FQ_UQ 
  P20      = 20 'Mirrors RST

  'System clock
  Fclock   = 180_000_000 'Hz

Var
  Long f, cog
  Byte W0
  Long AD9851_Stack[32]

Pub Reset

'Set ports to outputs
    dira[0..3]  ~~   'Data to AD9851                                  
    dira[20..23]~~   'Quickstart LED repeater 

'Reset device
    'Toggle RST
    !Outa[RST]
    Dly
    !Outa[RST]
    Dly

'Switch device to serial mode
'(assumes hard wired parallel word)
    'Toggle W_CLK
    !Outa[W_CLK]
    Dly
    !Outa[W_ClK]
    Dly
    
    'Toggle FQ_UD
    !Outa[FQ_UD]
    Dly
    !Outa[FQ_UD]
    Dly

'Clear register

  Outa[SER_DATA]~ 'fill register with zeros

  'Send 40 clock cycles
  Repeat 80
    !Outa[W_CLK]
    Dly
  
  !Outa[FQ_UD]
  Dly 
  !Outa[FQ_UD]  
  Dly

Pub Freq (Fout)
   
 'Calculate the frequency word required  
    Fout <<= 1
      repeat 32   'perform long division of (Fout / Fclock) * 2^32
        f <<= 1
        if Fout => Fclock
          Fout -= Fclock
          f++           
        Fout <<= 1
 
    'Shift out the data LSB first (32 bits)
    f <-= 1  ' pre-align lsb
      repeat 32   
        outa[SER_DATA] := (f ->= 1) & 1                 '
        Dly
        !outa[W_CLK]
        Dly        
        !outa[W_CLK]
        Dly
        
 'Phase registers and clock multiplier
 'Sets clock multiplier to x 6
    W0  := %0000_0001
        
 'Shift out word W0
    W0 <-= 1     ' pre-align lsb 
      repeat 8
        outa[SER_DATA] := (W0 ->= 1) & 1
        Dly               
        !outa[W_CLK]                                
        Dly
        !outa[W_CLK]
        Dly     

 'Send FQ_UD to transfer data into DDS registers              
      !outa[FQ_UD]                               
      Dly
      !outa[FQ_UD]
      Dly
      
PRI Dly

'Mirrors data lines to LEDs and adds delays
'to help visual debug

  {If Outa[W_CLK] == 1
    Outa[P23]    := 1
  ELSE
    Outa[P23] := 0

  If Outa[SER_DATA] == 1
    Outa[P22]       := 1
  ELSE
    Outa[P22] := 0

  If Outa[FQ_UD] == 1
    Outa[P21]    := 1
  ELSE
    Outa[P21] := 0

  If Outa[RST] == 1
    Outa[P20]  := 1
  ELSE
    Outa[P20] := 0}

Waitcnt (clkfreq/200_000 + cnt) 'min about clkfreq/200_000

    
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   AD9851: MIT License                                                  │                                                            
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