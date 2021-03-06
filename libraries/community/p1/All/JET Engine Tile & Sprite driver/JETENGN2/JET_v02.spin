'' JET ENGINE v1
'' (C)2018 IRQ Interactive
'' Spin Glue code
'' very loosley based on JT Cook's Ranquest driver
''
'' Specs:
'' Tilemap of 16x12 tiles
'' 32 Sprites per screen, 8 per line, lots of settings

CON

' constants
 SCANLINE_BUFFER = $7800
 NUM_LINES = gfx#NUM_LINES
 DISPLAY_LIST = SCANLINE_BUFFER - (32*4 + 36) ''$775C
 request_scanline       = DISPLAY_LIST-2      'address of scanline buffer for TV driver
 unused1                = DISPLAY_LIST-4      'used to be tilemap_adr
 unused2                = DISPLAY_LIST-6 'used to be tile_adr
 border_color           = DISPLAY_LIST-8 'border color                 
 oam_adr                = DISPLAY_LIST-10 'address of where sprite attribs are stored
 oam_in_use             = DISPLAY_LIST-12
 debug_shizzle          = DISPLAY_LIST-16
 text_colors_old        = DISPLAY_LIST-18 'UNUSED!
 first_subscreen        = DISPLAY_LIST-20
 buffer_attribs         = DISPLAY_LIST-28 'array of 8 bytes
 aatable                = DISPLAY_LIST-60 'array of 32 bytes
 aatable8               = DISPLAY_LIST-76 'array of 16 bytes
 text_colors            = DISPLAY_LIST-140 'array of 16 longs ''$7074

 x_tiles = 16 '*16=240
 y_tiles = 12 '*16=160

 num_sprites    = gfx#num_sprites


OBJ
  tv    : "JET_v02_composite.spin"             ' tv driver 256 pixel scanline
  gfx   : "JET_v02_rendering.spin"    ' graphics engine

VAR

   long cog_number ''used for rendering engine
   long cog_total  ''used for rendering engine
''used to stop and start tv driver

PUB tv_start(NorP)
  long[@tvparams+12]:=NorP ''NTSC or PAL60
  tv.start(@tvparams)

PUB tv_stop
   tv.stop
   
PUB start(video_pins,NorP)               | i, ready
                                                
  long[@tvparams+8]:=video_pins ''map pins for video out

  
  ' Boot requested number of rendering cogs:
  ' this must be 4, because bit magic 
  cog_total :=4
  cog_number := 0
  ready~
  repeat cog_total
    gfx.start(cog_number,@ready)
    cog_number++
  ready~~
  word[border_color]:=$04 ''default border color
  'start tv driver
  tv_start(NorP)

PUB Wait_Vsync ''wait until frame is done drawing
    repeat while tv_vblank
    repeat until tv_vblank
PUB Set_Border_Color(bcolor) | i ''set the color for border around screen
    long[border_color]:=bcolor
PUB Set_Filter(i1,s1p,s1e,s1s,i2,s2p,s2e,s2s)
  ovli1             := i1
  ovls1_ptr         := s1p       
  ovls1_end         := s1e      
  ovls1_start       := s1s     
  ovli2             := i2      
  ovls2_ptr         := s2p      
  ovls2_end         := s2e   
  ovls2_start       := s2s
PUB Set_Scrollborder(pal,patp,pate,pats)
  borderpal         := pal
  scrollborder_ptr  := patp
  scrollborder_end  := pate
  scrollborder_start:= pats
          
DAT
tvparams
tv_vblank               long    0               'status
tv_enable               long    1               'enable
tv_pins                 long    %011_0000       'pins ' PROTO/DEMO BOARD = %001_0101 ' HYDRA = %011_0000
tv_mode                 long    0               'mode - default to NTSC
tv_ho                   long    0               'ho
tv_vo                   long    0               'vo
tv_broadcast            long    50_000_000'_xinfreq<<4  'broadcast
tv_auralcog             long    0               'auralcog
                        

'nextline               long    0

ovli1                   long    %011000_000
ovls1_ptr               long    %0
ovls1_end               long    %0
ovls1_start             long    %0
ovli2                   long    %100000_000
ovls2_ptr               long    %0
ovls2_end               long    %0
ovls2_start             long    %0

borderpal               long    $07_05_03_02
scrollborder_ptr        long    %0
scrollborder_end        long    %0
scrollborder_start      long    %0

{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    TERMS OF USE: Parallax Object Exchange License                                            │                                                            
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