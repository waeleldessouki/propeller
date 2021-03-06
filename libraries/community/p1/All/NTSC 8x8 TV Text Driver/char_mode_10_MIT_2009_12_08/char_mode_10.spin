{

NTSC character based TV Text driver, with HUB RAM font table   Rev. 02.1

This is just a demo stub to get things running.  See TV driver for more info.  Run this to
see how to incorporate the driver into your own project.

What differentiates this driver from other tile drivers is how the screen memory is done.  Instead
of the screen containing colors and addresses, only character definition numbers are stored.
(in the two color per screen mode)  This makes writing numbers, strings, etc... to the screen a
simple matter of moving the string bytes to the display memory, without having to do address
lookups.

In the colors per char mode, the same idea applies, but it's all about longs instead of bytes.  

The parameters needed to get the driver running are here.  Essentially, you need to define
a segment of RAM for the screen display memory (.5 - 4Kb), display colors, and supply the font table
pointer address to the TV driver.  Other, display specific parameters are in the driver constants,
detailed there.

This quick and dirty demo program will just display the font on screen, using either the 2 color per
screen or 2 color per character modes.  Uncomment the color per character mode, to explore color options.

Once the driver is up and running, all other COGs can be stopped, leaving it to display whatever
character definition numbers are in the screen memory.  

Doug Dingus  10/07

}

CON
  ' Set up the processor clock in the standard way for 80MHz on HYDRA
  ' You will want to edit this to reflect your clock setup
  ' Also necessary is editing the pin definitions, and that's done in the driver itself.
  _CLKMODE = xtal1 + pll8x
  _XINFREQ = 10_000_000 + 0000

VAR
  byte          displayb[4096]   'allocate max display buffer in RAM  40x24 (longs)

  long          index            'just an index...

  long          params[4]                                    'The address of this array gets 
                '[0] screen memory                            passed to the TV driver.
                '[1] font table
                '[2] pix_mode not yet implemented...
                '[3] colors, or 16 bit mode = $00
  
OBJ
  tv : "char_mode_10_TV"         'the actual TV display driver
  
PUB start |  c, o, d, p

    params[0] := @displayb
{
    Simple display buffer, one character per byte.  40x24 = 960 bytes, unless color per
    character mode is on.  In that case, it's one long per character displayed on screen.
}
    
    params[1] := @fonttab
{
    Address of font table.  Each char is 8x8.  There are 128 of these defined in
    this display driver.  User can add or subtract from this as memory and
    display requirements demand.  Driver tested for 256 chars.

    Feel free to create your own font tables.  This one is from an old Atari computer.
    Any 8x8 font should work just fine.  Be sure to mirror the pixels.  This is necessary to
    address how the waitvid command works.

    %1100_0000  --->   %000_0011 = XX------  Where "X" is set on-screen pixel "-" is a reset one.
    
}
    
    params[2] := $0000_0000    'Not implemented....  
  
    
     params[3] := $0000502    
    'params[3] := $00           'Uncomment this to set color per char "fat" mode.
                                'fat being a reference to the increase in screen memory
                                'required to handle color per char mode.


{   THERE IS NO COLOR CHECKING IN THIS DRIVER!!

    The color values you supply are fed directly to the video generator.  There is a color lookup
    table at propeller.wikispaces.com, along with a screen capture to help you choose valid
    color table entries.

    Here is the color table, for reference:

    $02, $03, $04, $05, $06, $07                      Six intensities
    $19, $1a, $1b, $1c, $1d, $1e, $98, $af            Magenta
    $29, $2a, $2b, $2c, $2d, $2e, $a8, $bf
    $39, $3a, $3b, $3c, $3d, $3e, $b8, $cf
    $49, $4a, $4b, $4c, $4d, $4e, $c8, $df            Red
    $59, $5a, $5b, $5c, $5d, $5e, $d8, $ef            
    $69, $6a, $6b, $6c, $6d, $6e, $e8, $ff            Orange
    $79, $7a, $7b, $7c, $7d, $7e, $f8, $0f
    $89, $8a, $8b, $8c, $8d, $8e, $08, $1f            
    $99, $9a, $9b, $9c, $9d, $9e, $18, $2f            Green
    $a9, $aa, $ab, $ac, $ad, $ae, $28, $3f            
    $b9, $ba, $bb, $bc, $bd, $be, $38, $4f
    $c9, $ca, $cb, $cc, $cd, $ce, $48, $5f            
    $d9, $da, $db, $dc, $dd, $de, $58, $6f            Blue
    $e9, $ea, $eb, $ec, $ed, $ee, $68, $7f            
    $f9, $fa, $fb, $fc, $fd, $fe, $78, $8f
                                                        
    This table is missing one hue, those values are:        $0a, $0b, $0c, $0d, $0e, $0f    Darker Blue

    Your best case colors, for TEXT are either just the intensities, shown at the top of the table
    ,or entries 2 - 6 for any HUE.  These are moderate saturation colors that will display well on
    a wide range of NTSC display devices.

    This version of the driver uses static color timing, which limits the number of acceptable
    color combinations.

    Generally, the better combinations are:

    Char color and char background are same HUE, different INTENSITY.

    Char background either white or black, char HUE and INTENSITY

    Worst case is contrasting HUES in same character cell.

       (It's on the TO DO list.)
                                


    By default, this driver is a two color one to make best use of memory.  The
    background color is specified in the LSB, with the foreground being the next
    most significant byte.  ($05, being the foreground color, in the params assignment above.)

    The upper two bytes are not used, typically set to zero.



    If params[3] = 0, then screen memory becomes one long per character, with the
    upper word being colors, and the lower one characters.  The byte definitions are:

     [background_color] [foreground_color] [unused] [character].....

}


   c := 0

'This is the two color per screen test code.  It can be left uncommented as the two color per
'character mode just over writes this.  
   
    repeat index from 0 to 2048
      c := c + 1                         'display the characters in the font table in sequence
      c := c & %01111111                 'only 128 chars in the supplied font table.
      byte [@displayb] [index] := c      'put them in the screen memory buffer
        


'This is the color per character mode demo code --uncomment, along with params[3] above to
'see some color combinations.

{
      repeat index from 0 to 4095  step 4
        c := c + 1                             'display all chars, in sequence
        c := c & %01111111                     'there are only 128 chars defined in font
        displayb[index] := $da + (c / 4)       'set variable background color
        displayb[index + 1] := $06             'set character pixel color
        displayb[index + 2] := $00             'unused...
        displayb[index + 3] := $01  + c        'put chars in screen memory
}

    tv.start(@params)    'start the tv cog & pass it the parameter block

DAT
              'font definition pixels are mirror image, due to the way waitvid works.
              'Atari 8 bit international font used here
              'There are 128 chars defined in this table.  256 are possible.
fonttab
           byte byte %00000000   ' '       
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
                      
           byte byte %00000000   '!'       
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00000000             
                      
           byte byte %00000000   '"'       
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
                       
           byte byte %00000000   '         
           byte byte %01100110             
           byte byte %11111111             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %11111111             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00011000   '$'       
           byte byte %01111100             
           byte byte %00000110             
           byte byte %00111100             
           byte byte %01100000             
           byte byte %00111110             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000   '%'       
           byte byte %01100110             
           byte byte %00110110             
           byte byte %00011000             
           byte byte %00001100             
           byte byte %01100110             
           byte byte %01100010             
           byte byte %00000000             
                       
           byte byte %00111000   '&'       
           byte byte %01101100             
           byte byte %00111000             
           byte byte %00011100             
           byte byte %11110110             
           byte byte %01100110             
           byte byte %11011100             
           byte byte %00000000             
                       
           byte byte %00000000   '''       
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
                       
           byte byte %00000000   '('       
           byte byte %01110000             
           byte byte %00111000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00111000             
           byte byte %01110000             
           byte byte %00000000             
                      
           byte byte %00000000   ')'       
           byte byte %00001110             
           byte byte %00011100             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011100             
           byte byte %00001110             
           byte byte %00000000             
                       
           byte byte %00000000   '*'       
           byte byte %01100110             
           byte byte %00111100             
           byte byte %11111111             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %00000000             
           byte byte %00000000             
                       
           byte byte %00000000   '+'       
           byte byte %00011000             
           byte byte %00011000             
           byte byte %01111110             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00000000             
                       
           byte byte %00000000   ','       
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00001100             
                       
           byte byte %00000000   '-'       
           byte byte %00000000             
           byte byte %00000000             
           byte byte %01111110             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
                       
           byte byte %00000000   '.'       
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000   '/'       
           byte byte %01100000             
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00001100             
           byte byte %00000110             
           byte byte %00000010             
           byte byte %00000000             
                       
           byte byte %00000000   '0'       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01110110             
           byte byte %01101110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   '1'       
           byte byte %00011000             
           byte byte %00011100             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %00000000   '2'       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00001100             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %00000000   '3'       
           byte byte %01111110             
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00110000             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   '4'       
           byte byte %00110000             
           byte byte %00111000             
           byte byte %00111100             
           byte byte %00110110             
           byte byte %01111110             
           byte byte %00110000             
           byte byte %00000000             
                       
           byte byte %00000000   '5'       
           byte byte %01111110             
           byte byte %00000110             
           byte byte %00111110             
           byte byte %01100000             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   '6'       
           byte byte %00111100             
           byte byte %00000110             
           byte byte %00111110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   '7'       
           byte byte %01111110             
           byte byte %01100000             
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00001100             
           byte byte %00001100             
           byte byte %00000000             
                       
           byte byte %00000000   '8'       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   '9'       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %01100000             
           byte byte %00110000             
           byte byte %00011100             
           byte byte %00000000             
                       
           byte byte %00000000   ':'       
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000   '''       
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00001100             
                       
           byte byte %01100000   '<'       
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00001100             
           byte byte %00011000             
           byte byte %00110000             
           byte byte %01100000             
           byte byte %00000000             
                       
           byte byte %00000000   '='       
           byte byte %00000000             
           byte byte %01111110             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %01111110             
           byte byte %00000000             
           byte byte %00000000             
                       
           byte byte %00000110   '>'       
           byte byte %00001100             
           byte byte %00011000             
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00001100             
           byte byte %00000110             
           byte byte %00000000             
                       
           byte byte %00000000   '?'       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000   '         
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01110110             
           byte byte %01110110             
           byte byte %00000110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00000000   'A'       
           byte byte %00011000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00000000   'B'       
           byte byte %00111110             
           byte byte %01100110             
           byte byte %00111110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111110             
           byte byte %00000000             
                       
           byte byte %00000000   'C'       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   'D'       
           byte byte %00011110             
           byte byte %00110110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00110110             
           byte byte %00011110             
           byte byte %00000000             
                       
           byte byte %00000000   'E'       
           byte byte %01111110             
           byte byte %00000110             
           byte byte %00111110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %00000000   'F'       
           byte byte %01111110             
           byte byte %00000110             
           byte byte %00111110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00000000             
                       
           byte byte %00000000   'G'       
           byte byte %01111100             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %01110110             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00000000   'H'       
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00000000   'I'       
           byte byte %01111110             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %00000000   'J'       
           byte byte %01100000             
           byte byte %01100000             
           byte byte %01100000             
           byte byte %01100000             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   'K'       
           byte byte %01100110             
           byte byte %00110110             
           byte byte %00011110             
           byte byte %00011110             
           byte byte %00110110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00000000   'L'       
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %00000000   'M'       
           byte byte %11000110             
           byte byte %11101110             
           byte byte %11111110             
           byte byte %11010110             
           byte byte %11000110             
           byte byte %11000110             
           byte byte %00000000             
                       
           byte byte %00000000   'N'       
           byte byte %01100110             
           byte byte %01101110             
           byte byte %01111110             
           byte byte %01111110             
           byte byte %01110110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00000000   'O'       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   'P'       
           byte byte %00111110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00000000             
                       
           byte byte %00000000   'Q'       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00110110             
           byte byte %01101100             
           byte byte %00000000             
                       
           byte byte %00000000   'R'       
           byte byte %00111110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111110             
           byte byte %00110110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00000000   'S'       
           byte byte %00111100             
           byte byte %00000110             
           byte byte %00111100             
           byte byte %01100000             
           byte byte %01100000             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   'T'       
           byte byte %01111110             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000   'U'       
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %00000000   'V'       
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000   'W'       
           byte byte %11000110             
           byte byte %11000110             
           byte byte %11010110             
           byte byte %11111110             
           byte byte %11101110             
           byte byte %11000110             
           byte byte %00000000             
                       
           byte byte %00000000   'X'       
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00000000   'Y'       
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000   'Z'       
           byte byte %01111110             
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00001100             
           byte byte %00000110             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %00000000   '['       
           byte byte %01111000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %01111000             
           byte byte %00000000             
                       
           byte byte %00000000   '\'       
           byte byte %00000010             
           byte byte %00000110             
           byte byte %00001100             
           byte byte %00011000             
           byte byte %00110000             
           byte byte %01100000             
           byte byte %00000000             
                       
           byte byte %00000000   ']'       
           byte byte %00011110             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011110             
           byte byte %00000000             
                       
           byte byte %00000000   '^'       
           byte byte %00010000             
           byte byte %00111000             
           byte byte %01101100             
           byte byte %11000110             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
                       
           byte byte %00000000   '_'       
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %11111111             
           byte byte %00000000             
                       
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %01100000             
           byte byte %01111100             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00001100             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %01101100             
           byte byte %00110110             
           byte byte %00000000             
           byte byte %01101110             
           byte byte %01101110             
           byte byte %01111110             
           byte byte %01110110             
           byte byte %00000000             
                       
           byte byte %00110000             
           byte byte %00011000             
           byte byte %01111110             
           byte byte %00000110             
           byte byte %00111110             
           byte byte %00000110             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00111100             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00111100             
           byte byte %00011000             
           byte byte %00001100             
                       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %00000000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00001100             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00001100             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00011100             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00111000             
           byte byte %00001100             
           byte byte %00001100             
           byte byte %00011110             
           byte byte %00001100             
           byte byte %00001100             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %00000000             
           byte byte %01100110             
           byte byte %00000000             
           byte byte %00011100             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000             
           byte byte %01100110             
           byte byte %00000000             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %01101100             
           byte byte %00000000             
           byte byte %00111100             
           byte byte %01100000             
           byte byte %01111100             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %01100110             
           byte byte %00000000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000             
           byte byte %01100110             
           byte byte %00000000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %01100110             
           byte byte %00000000             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %00111000             
           byte byte %01100000             
           byte byte %01111100             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %00000000             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %00000000             
           byte byte %00011100             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01111110             
           byte byte %00000110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00001100             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01111110             
           byte byte %00000110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %01101100             
           byte byte %00110110             
           byte byte %00000000             
           byte byte %00111110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00111100             
           byte byte %11000011             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01111110             
           byte byte %00000110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00111100             
           byte byte %01100000             
           byte byte %01111100             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00001100             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %01100000             
           byte byte %01111100             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01111110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00011110             
           byte byte %00000110             
           byte byte %00011110             
           byte byte %00000110             
           byte byte %01111110             
           byte byte %00011000             
           byte byte %01111000             
           byte byte %00000000             
                       
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %01111110             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %01111110             
           byte byte %00111100             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00001100             
           byte byte %01111110             
           byte byte %00001100             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00000000             
                       
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00110000             
           byte byte %01111110             
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00000000             
                       
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000   'a'       
           byte byte %00000000             
           byte byte %00111100             
           byte byte %01100000             
           byte byte %01111100             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00000000   'b'       
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00111110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111110             
           byte byte %00000000             
                       
           byte byte %00000000   'c'       
           byte byte %00000000             
           byte byte %00111100             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   'd'       
           byte byte %01100000             
           byte byte %01100000             
           byte byte %01111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00000000   'e'       
           byte byte %00000000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01111110             
           byte byte %00000110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   'f'       
           byte byte %01110000             
           byte byte %00011000             
           byte byte %01111100             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000   'g'       
           byte byte %00000000             
           byte byte %01111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %01100000             
           byte byte %00111110             
                       
           byte byte %00000000   'h'       
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00111110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00000000   'i'       
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00011100             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   'j'       
           byte byte %01100000             
           byte byte %00000000             
           byte byte %01100000             
           byte byte %01100000             
           byte byte %01100000             
           byte byte %01100000             
           byte byte %00111100             
                       
           byte byte %00000000   'k'       
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00110110             
           byte byte %00011110             
           byte byte %00110110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00000000   'l'       
           byte byte %00011100             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   'm'       
           byte byte %00000000             
           byte byte %01100110             
           byte byte %11111110             
           byte byte %11111110             
           byte byte %11010110             
           byte byte %11000110             
           byte byte %00000000             
                       
           byte byte %00000000   'n'       
           byte byte %00000000             
           byte byte %00111110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00000000   'o'       
           byte byte %00000000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   'p'       
           byte byte %00000000             
           byte byte %00111110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111110             
           byte byte %00000110             
           byte byte %00000110             
                       
           byte byte %00000000   'q'       
           byte byte %00000000             
           byte byte %01111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %01100000             
           byte byte %01100000             
                       
           byte byte %00000000   'r'       
           byte byte %00000000             
           byte byte %00111110             
           byte byte %01100110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00000000             
                       
           byte byte %00000000   's'       
           byte byte %00000000             
           byte byte %01111100             
           byte byte %00000110             
           byte byte %00111100             
           byte byte %01100000             
           byte byte %00111110             
           byte byte %00000000             
                       
           byte byte %00000000   't'       
           byte byte %00011000             
           byte byte %01111110             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %01110000             
           byte byte %00000000             
                       
           byte byte %00000000   'u'       
           byte byte %00000000             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00000000   'v'       
           byte byte %00000000             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000   'w'       
           byte byte %00000000             
           byte byte %11000110             
           byte byte %11010110             
           byte byte %11111110             
           byte byte %01111100             
           byte byte %01101100             
           byte byte %00000000             
                       
           byte byte %00000000   'x'       
           byte byte %00000000             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00000000   'y'       
           byte byte %00000000             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00110000             
           byte byte %00011110             
                       
           byte byte %00000000   'z'       
           byte byte %00000000             
           byte byte %01111110             
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00001100             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01111110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00011000   '|'       
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
                       
           byte byte %00000000             
           byte byte %01111110             
           byte byte %00011110             
           byte byte %00111110             
           byte byte %01110110             
           byte byte %01100110             
           byte byte %01100000             
           byte byte %00000000             
                       
           byte byte %00010000             
           byte byte %00011000             
           byte byte %00011100             
           byte byte %00011110             
           byte byte %00011100             
           byte byte %00011000             
           byte byte %00010000             
           byte byte %00000000             
                       
           byte byte %00001000             
           byte byte %00011000             
           byte byte %00111000             
           byte byte %01111000             
           byte byte %00111000             
           byte byte %00011000             
           byte byte %00001000             
           byte byte %00000000             
                                           
                                           



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
                                           
                                           
                                           
                                           
                                           
                                           
                                           
                                           
                                           
                                           
                                           
                                           
                                           