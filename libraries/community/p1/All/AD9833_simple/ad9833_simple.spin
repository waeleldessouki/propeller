{{ AD9833_simple.spin
┌─────────────────────────────────────┬────────────────┬─────────────────────┬───────────────┐
│ AD9833 digital synth driver v1.0    │ BR             │ (C)2017             │  4Feb2017     │
├─────────────────────────────────────┴────────────────┴─────────────────────┴───────────────┤
│                                                                                            │
│ A simple spin driver for AD9833 direct digital synthesis chip.                             │
│                                                                                            │
│ Notes:                                                                                     │
│ •WARNING: this device comes in a 0.5mm pitch SSOP package, not breadboard friendly         │
│ •If you want to mount this on a breadboard, get a schmartboard carrier w/ 0.5mm pitch      │
│ •I used the schmartboard QFN 24pin 0.5mm pitch and left 2 sides of qfn unconnected         │
│ •And get a good magnifying glass & fine soldering iron tip to do the soldering             │
│ •Be warned - using this chip on a breadboard setup makes it very susceptible to noise      │
│ •More reference material:                                                                  │
│  http://www.analog.com/media/en/technical-documentation/data-sheets/AD9833.pdf             │
│                                                                                            │
│ See end of file for terms of use.                                                          │
└────────────────────────────────────────────────────────────────────────────────────────────┘
DEVICE PINOUT & REFERENCE CIRCUIT

     3v3
           10nF         ┌──────┐               
      ┣──────── comp │•     │ Vout   signal out
    ┌─┴─────────  Vdd │      │ AGND   to gnd  
.1uF ┌─.1uF───  Cap │AD9833│ fsync  to prop fsyncpin
    │ ┣───────── DGND │      │ clk    to prop clkpin
        mclk  Mclk │      │ dq     to prop dqpin
                         └──────┘      

}}
CON
  'software constants
  pratio = float(1<<12)/float(360)                    '2^12 / 360


VAR
  long control, mfreq, fratio
  long dqpin,clkpin,fsyncpin                          'SPI data, clock, chip enable

OBJ
fp     :"floatmath"
  
pub init(_dqpin,_clkpin,_fsyncpin, _mfreq)
''initialize spi interface to ad9833. Call once after prop power-up
''defaults to sine wave output; must call setfreq to set frequency
''leaves ds9833 in reset mode; must clear reset bit to get signal
''mfreq is master clock frequency applied on AD9833 pin 5, Hz 

  dqpin := _dqpin
  clkpin := _clkpin
  fsyncpin := _fsyncpin

  dira[fsyncpin]~~
  outa[fsyncpin]~~                                    'fsync idle high

  dira[dqpin]~~                                      

  outa[clkpin]~~                                      'clock idle high
  dira[clkpin]~~                                       

  control:=$0100
  shiftout(control)                                   'put ad9833 into reset mode  

  mfreq := _mfreq
  fratio := fp.fdiv(fp.ffloat(1<<28),fp.ffloat(mfreq)) '2^28 / mclk
  
  
pub setFreq(reg,freq)|msb,lsb,ctrl
''set frequency register 1 or 2
''freq is in Hz, min = 0, max = master clock freq

  reg := 0 #> reg <# 1                                'limit reg to 0 or 1
  freq := 1 #> freq <# mfreq                          'limit from 1 to master clk

  freq := fp.fmul(fp.ffloat(freq),fratio)             'convert from Hz to freq register 
  freq := fp.fround(freq)

  'get lsb and msb, append freq reg address
  lsb := freq.word[0]                                 'get lower 14 bits of frac
  freq <<= 2
  msb := freq.word[1]                                 'get upper 14 bits of frac
  lsb &= %0011_1111_1111_1111                         'clear bits 14,15 to 00
  msb &= %0011_1111_1111_1111  

  if reg
    lsb += %10<<14                                    'set bits 14,15 to 10
    msb += %10<<14               
  else
    lsb += %01<<14                                    'set bits 14,15 to 01
    msb += %01<<14                                  

  'prepare control word
  ctrl := control                                     'copy control to scratch var
  ctrl &= %0000_1111_1111_1111                        'clear upper nibble to 0

  shiftout(ctrl)                                      'write to lsb freq register
  shiftout(lsb)  
  
  ctrl += %0001 << 12                                 'write to msb freq reg
  shiftout(ctrl)  
  shiftout(msb)  


pub setPhs(reg,phs)
''write value to phase register 1 or 2
''phs min = 0, max = 360deg phase shift

  reg := 0 #> reg <# 1                                'limit reg to 0 or 1
  phs := 0 #> phs <# 359                              'limit from 0 to 359

  phs := fp.fmul(fp.ffloat(phs),pratio)               'convert from deg to phs register 
  phs := fp.fround(phs)

  phs &= %0001_1111_1111_1111                         'clear bits 13-15
  if reg
    phs += %110<<13                                   'select phs0 register
  else
    phs += %111<<13                                     

  shiftout(phs)                                       'write to phs register 
  

pub setActive(freq,phs)
''select active frequency & phase registers (0 or 1)

  freq := 0 #> freq <# 1                              'limit to 0 or 1
  phs := 0 #> phs <# 1      

  control &= %1111_0011_1111_1111                     'clear bits 10,11
  if phs
    control += 1 << 10                                'set bit 10
  if freq
    control += 1 << 11                                'set bit 11
  shiftout(control)
  

CON
'command byte options   
  #0, sin,tri

PUB command(sin_or_tri, squ, reset)
''Writes an AD9833 command word
''sin_or_tri   : select sinusoid or triangle wave output (allowed values: sin, tri)
''squ          : select square wave output, overrides sin or tri (allowed values 0,1)
''reset        : place the chip in reset mode, i.e. 0.3v on Vout (allowed values 0,1)
''Usage example: cmd:=command(dds#sin,0,0)    --> select sine wave, clear reset bit
''               cmd:=command(dds#tri,0,0)    --> select triangle wave, clear reset bit
''               cmd:=command(0,1,1)          --> select square wave, set reset bit

  sin_or_tri := 0 #> sin_or_tri <# 1
  squ        := 0 #> squ <# 1
  reset      := 0 #> reset <# 1
  if squ
    sin_or_tri := 0
     
  control := (reset<<8) + (squ<<5) + (sin_or_tri<<1)
  shiftout(control) 


pub shiftout(value)
''shift a word into ad9833

   outa[fsyncpin]~                                    'fsync low
   Value <<= 16                                       'pre-align msb
   repeat 16
     Value <-= 1
     outa[dqpin] := value & 1                         'output data bit
     outa[clkpin]~
     outa[clkpin]~~
   outa[fsyncpin]~~                                   'fsync high


pub chirp (start,stop,mS)|tmp,lsb,msb,ctrl,fsteps,wait,inc,frq,reg,framerate
''frequency chirp using freq0 register, blocks cog while chirping
''arguemnts are start freq, stop freq, and duration of chirp in mS
''NOTE: this will overwrite whatever value is in freq0 register
''NOTE2: also leaves fselect bit=0 at exit, regardless of initial state

   framerate:=400                                     'default number of frequency updates / sec
   start := 1 #> start <# mfreq
   stop  := 1 #> stop <# mfreq
   ms    := 1000/framerate #> ms <# 10_000_000        'upper limit protects overflow in fsteps          

   'calc freq reg initial value
   frq := fp.fmul(fp.ffloat(start),fratio)            'convert from Hz to freq register 
   frq := fp.fround(frq)                      

   'calculate increment to be added to freq reg each pass
   repeat
     fsteps := ms * framerate / 1000                  'total number of frequency steps
     tmp := fp.ffloat(stop - start)
     tmp := fp.fdiv(tmp,fp.ffloat(fsteps)) 
     tmp := fp.fmul(tmp,fratio)                       'convert from deltaHz to deltafreq register 
     inc := fp.ftrunc(tmp)
     if ||inc < 2                                     'if necessary, reduce framerate to
       framerate-=1                                   'handle the cases where sweep time too 
   while ||inc < 2                                    'long with too narrow of a frequency sweep

   'prepare control word
   control &= %0000_0110_1111_1111                    'clear upper nibble, fselect, & reset bits to 0
   ctrl := control                                    'copy control to scratch var
   ctrl += %0001 << 13                                'set B28 mode

   wait := clkfreq/framerate
   tmp:= cnt 

   'loop to step through frequency range
   repeat fsteps
     reg:=frq
     lsb := reg.word[0]                               'get lower 14 bits of frac
     reg <<= 2
     msb := reg.word[1]                               'get upper 14 bits of frac
     lsb &= %0011_1111_1111_1111                      'clear bits 14,15 to 00
     msb &= %0011_1111_1111_1111                      'clear bits 14,15 to 00
     lsb += %01<<14                                   'set bits 14,15 to 01
     msb += %01<<14               
     shiftout(ctrl)                                      
     shiftout(lsb)                                    'write to frq0 register
     shiftout(msb)
     frq+=inc
     tmp+=wait
     waitcnt(tmp)

   shiftout(control)                                  'clear B28 mode bit, but leave fselect=0
     
   
DAT
{{
┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                     TERMS OF USE: MIT License                                       │                                                            
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and    │
│associated documentation files (the "Software"), to deal in the Software without restriction,        │
│including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,│
│and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,│
│subject to the following conditions:                                                                 │
│                                                                                                     │                        │
│The above copyright notice and this permission notice shall be included in all copies or substantial │
│portions of the Software.                                                                            │
│                                                                                                     │                        │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT│
│LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  │
│IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         │
│LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION│
│WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                      │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}   