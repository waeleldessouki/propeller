{{

┌──────────────────────────────────────────┐
| Memsic 2125 VGA Display Demo             |
| Author: Emmanuel POULY                   |               
| Copyright (c) 2012 Parallax, Inc.        |      
| See end of file for terms of use.        |                
└──────────────────────────────────────────┘

}}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  tiles = gr#tiles       '512x384

  xIn   = 1     'PIN connection to propeller
  yIn   = 0     'PIN connection to propeller
  Xrot  = 256   'Cartesian coordinate
  Yrot  = 232   'Cartesian coordinate
  H     = 22    'Height of rectangle
  L     = 100   'Lengh (2*L) of rectangle 
  PerX  = 90    'Used for perspective along x
  PerY  = 35    'Used for perspective along y
  Limit = 30    'Limit of rotationnal angle +/- 30°
  
OBJ
  Math          :        "Float32Full" 
  MM2125        :        "MXD2125"
  gr            :        "vga graphics ASM"

VAR
    long        Xa, Ya, Xb, Yb, Xc, Yc, Xd, Yd
    long        Xe, Ye, Xf, Yf, Xg, Yg, Xh, Yh 
    long        offset, scale, Ax, Ay, Teta           

PUB MainLoop | i

    Math.start                                          'Start Math object
    MM2125.start(xIn, yIn)                              'Initialize Memsic 2125 
    gr.start                                            'Start Graphics VGA ASM

    offset := 90 * (clkfreq / 200)                      'Offset value for sensor data conversion
    scale  := clkfreq / 800                             'Scale value for sensor data conversion
    
    gr.pointcolor(1)                                  
    repeat i from 0 to tiles - 1                        'Init tile colors to white on black
       gr.color(i,$FF00)
     
   repeat   
      
        gr.pointcolor(1)
        
        Calcul_Coord

        gr.line(Xa,Ya,Xb,Yb)      'line (AB)
        gr.line(Xa,Ya,Xd,Yd)      'line (AD)
        gr.line(Xb,Yb,Xc,Yc)      'line (BC)
        gr.line(Xd,Yd,Xc,Yc)      'line (DC)
        if Ax > -Teta
              gr.line(Xd,Yd,Xe,Ye)      'line (DE)
              gr.line(Xe,Ye,Xf,Yf)      'line (EF)
        if Ax < -Teta
              gr.line(Xa,Ya,Xh,Yh)      'line (AH)
              gr.line(Xh,Yh,Xg,Yg)      'line (HG) 

        gr.line(Xc,Yc,Xf,Yf)      'line (CF)
        gr.line(Xb,Yb,Xg,Yg)      'line (BG)
        gr.line(Xg,Yg,Xf,Yf)      'line (GF)      
                                                        
        repeat 150000              
        
        gr.pointcolor(0)

        gr.line(Xa,Ya,Xb,Yb)      'line (AB) 
        gr.line(Xa,Ya,Xd,Yd)      'line (AD)
        gr.line(Xb,Yb,Xc,Yc)      'line (BC)
        gr.line(Xd,Yd,Xc,Yc)      'line (DC)
        if Ax > -Teta
              gr.line(Xd,Yd,Xe,Ye)      'line (DE)
              gr.line(Xe,Ye,Xf,Yf)      'line (EF)
        if Ax < -Teta
              gr.line(Xa,Ya,Xh,Yh)      'line (AH)
              gr.line(Xh,Yh,Xg,Yg)      'line (HG)   

        gr.line(Xc,Yc,Xf,Yf)      'line (CF)
        gr.line(Xb,Yb,Xg,Yg)      'line (BG)
        gr.line(Xg,Yg,Xf,Yf)      'line (GF)


PUB  Calcul_Coord | Rd_Sx, Rd_Sy, Rd_TSy, Rd_TSx, Rd_Px, Rd_Py, Alpha

  Ax      := Limit <# (MM2125.x*90-offset)/scale * -1 #> -Limit     
  Ay      := Limit <# (MM2125.y*90-offset)/scale #> -Limit  

  Rd_Sx   := Math.FRound(Math.FMul(Math.FFloat(L),Math.FSub(1.0,Math.Cos(Math.radians(Math.FFloat(Ax))))))
  Rd_Sy   := Math.FRound(Math.FMul(Math.FFloat(L),Math.Sin(Math.radians(Math.FFloat(Ax)))) )

  Rd_TSx  := Math.FRound(Math.FMul(Math.FFloat(H),Math.Sin(Math.radians(Math.FFloat(Ax)))))
  Rd_TSy  := Math.FRound(Math.FMul(Math.FFloat(H),Math.Cos(Math.radians(Math.FFloat(Ax)))))

  Alpha   := Math.radians(Math.FFloat(Ay))
  Rd_Px   := Math.FRound(Math.FDiv(Math.FSub(Math.FMul(Math.FFloat(PerX),Math.Cos(Alpha)),Math.Fmul(Math.FFloat(PerY),Math.Sin(Alpha))),2.0))
  Rd_Py   := Math.FRound(Math.FDiv(Math.FAdd(Math.FMul(Math.FFloat(PerX),Math.Sin(Alpha)),Math.Fmul(Math.FFloat(PerY),Math.Cos(Alpha))),2.0))

  Xa      := Xrot +Rd_Sx -Rd_Px +PerX/2 -L
  Ya      := Yrot -Rd_Sy +Rd_Py -PerY/2

  Xb      := Xrot -Rd_Sx -Rd_Px +PerX/2 +L
  Yb      := Yrot +Rd_Sy +Rd_Py -PerY/2

  Xd      := Xrot +Rd_Sx +Rd_TSx -Rd_Px +PerX/2 -L
  Yd      := Yrot -Rd_Sy -Rd_TSy +Rd_Py -PerY/2

  Xc      := Xrot -Rd_Sx +Rd_TSx -Rd_Px +PerX/2 +L
  Yc      := Yrot +Rd_Sy -Rd_TSy +Rd_Py -PerY/2

  Xe      := Xrot +Rd_Sx +Rd_TSx +Rd_Px +PerX/2 -L
  Ye      := Yrot -Rd_Sy -Rd_TSy -Rd_Py -PerY/2

  Xf      := Xrot -Rd_Sx +Rd_TSx +Rd_Px +PerX/2 +L
  Yf      := Yrot +Rd_Sy -Rd_TSy -Rd_Py -PerY/2

  Xg      := Xrot -Rd_Sx +Rd_Px +PerX/2 +L
  Yg      := Yrot +Rd_Sy -Rd_Py -PerY/2

  Xh      := Xrot +Rd_Sx +Rd_Px +PerX/2 -L
  Yh      := Yrot -Rd_Sy -Rd_Py -PerY/2

  Teta    := Math.FRound(Math.Degrees(Math.ATan2(Math.FFloat(Rd_Py), Math.FFloat(Rd_Px))))

DAT
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