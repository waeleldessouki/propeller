{{
─────────────────────────────────────────────────
File: Wifly Web Server V01.spin
Version: 01.0
Copyright (c) 2012 Ben.Thacker.Enterprises
See end of file for terms of use.

Author: Ben Thacker  
─────────────────────────────────────────────────
}}

{    
  Theory of operation:
  The Propeller chip interfaces with a RN-XV Wifly via the serial
  port. The RN-XV Wifly provides Wi-Fi connectivity using 802.11 b/g
  standards. In this simple configuration that I am using, the RN-XV
  hardware only requires four connections (Pwr, Tx, Rx and Gnd)
  to create a wireless data connection.

  If the RN-XV Wifly does not connect to a network the propeller will
  execute a setup procedure and request your ssid name and password
  during the setup of the RN-XV Wifly.

  Connect to the RN-XV Wifly via your favorite web browser using
  the ip address displayed after it has joined your wireless network
  and a HTML web page will be returned. Be sure to include index.html
  in the url. For example http://192.168.1.118/index.html

  When the RN-XV receives the "GET /index.html" message a simple HTML
  page is returned by the propeller. Enter data in the username field
  of the HTML page, click submit and the data is sent back to the
  Wifly/propeller in a POST message. The Wifly/propeller will then return
  the data along with another HTML page to display the data received.

 ======================================================================
  Hardware:  
  
  RN-XV
  Wifly                 Propeller                Terminal/PC                 

  +3.3V
  Gnd
              10Ω
   rx   <──────────<  rn_xv_tx
   tx   >──────────>  rn_xv_rx
                        term_rx   <────────────<  prop_plug_tx
                        term_tx   >────────────>  prop_plug_rx
}

'----------------------------------------------------------------------
CON

  _clkmode         = xtal1 + pll16x              'Use crystal * 16
  _xinfreq         = 5_000_000                   '5MHz * 16 = 80 MHz

  term_rx           = 27                         'Serial Rx line
  term_tx           = 26                         'Serial tx line
  rn_xv_rx          =  9                         'RN-XV serial Rx line
  rn_xv_tx          =  8                         'RN-XV serial tx line

  LF                = 10                         'Line Feed
  CR                = 13                         'Carrage Return
  BUFFERSIZE        = 1024                       'Buffer size
  TBUFFERSIZE       = 256                        'Temporary buffer size
  ERASE_BUFFER      = 1                          'Erase flag
  DONT_ERASE_BUFFER = 0                          'Do not erase flag
  
'----------------------------------------------------------------------
OBJ

  RN_XV: "Parallax Serial Terminal Extended"
  Term:  "Parallax Serial Terminal Extended"
  STR:   "Strings2"

'----------------------------------------------------------------------
VAR

  byte tBuffer[TBUFFERSIZE]
  byte Buffer[BUFFERSIZE]
  long Buffer_Index

'----------------------------------------------------------------------
PUB Main | start, end, isize, pos, index, index1, Rx

  RN_XV.StartRxTx( rn_xv_rx, rn_xv_tx, 0, 9600 ) 'initialize RN-XV serial io
  Term.StartRxTx( term_rx, term_tx, 0, 9600 )    'initialize term serial io

  Term.Str(@AppHeader)                           'Print info header from string in DAT section.
  Term.Str(String("*** Starting ***",LF,CR))

  Buffer_Index := 0                              'Start index used to read/write buffer at 0

  autoconnect

  repeat
    if (RN_XV.RxCount > 0)                        'Get number of characters waiting in receive buffer
      Wifly_FillBuffer(2000)                      'Fill buffer until no more characters or 2000 ms pass
      if ( STR.strPos(@Buffer, string("GET /index.html"),0) ) => 0
        Send_index_HTML
        RN_XV.RxFlush
        Clear_Buffer
        Enter_Command_Mode
        delay_ms(250)
        Close_Exit
      elseif (pos := STR.strPos(@Buffer, string("GET"),0) ) => 0
        RN_XV.RxFlush
        Clear_Buffer
        Enter_Command_Mode
        delay_ms(250)
        Close_Exit
      elseif (pos := STR.strPos(@Buffer, string("username="),0) ) => 0
        start := pos + 9
        isize := strsize(@Buffer)
        end := start + (isize - start)
        index1 := 0
        repeat index from start to end
          Rx := Buffer[index]
          if(Rx == "+")
            Rx := ","
          tBuffer[index1++] := Rx
        tBuffer[index1] := 0
        Send_hello_HTML(@tBuffer)
        delay_ms(250)
        Clear_Buffer
        Enter_Command_Mode
        Close_Exit
      else
        RN_XV.RxFlush
        Clear_Buffer

'----------------------------------------------------------------------
PUB autoconnect | pos, lcnt

  RN_XV.rxflush
  Term.rxflush

  Enter_Command_Mode
    
  'Reboot to get device into a known state
  RN_XV.Str(String("reboot",CR))
  pos := Wifly_FillBuffer_Check_Ack(string("*READY*"),ERASE_BUFFER,6000)
  pos := Wifly_FillBuffer_Check_Ack(string("Listen"),DONT_ERASE_BUFFER,6000)

  Enter_Command_Mode

  'Displays connection status in this HEX format: 8nnn
  'Check the 3rd byte of hex string returned. 0 means no association
  RN_XV.Str(String("show con",CR))
  pos := Wifly_FillBuffer_Check_Ack(string("8"),ERASE_BUFFER,1000)
  if(Buffer[pos+2] == "0")
    setup
    'Reboot RN-XV Wifly module so that the settings take effect
    RN_XV.Str(String("reboot",CR))
    pos := Wifly_FillBuffer_Check_Ack(string("*READY*"),ERASE_BUFFER,6000)

  RN_XV.Str(String("exit",CR))                   ' Exit command mode if we haven't already
  pos := Wifly_FillBuffer_Check_Ack(string("EXIT"),ERASE_BUFFER,1000)

  Clear_Buffer

'----------------------------------------------------------------------
PUB setup | retval

  'factory RESET saves the settings to the config file, no need to "save"
  RN_XV.Str(String("factory RESET",CR))
  retval := Wifly_FillBuffer_Check_Ack(string("AOK"),ERASE_BUFFER,1000)

  'Setup uart buffer rx  0x10
  RN_XV.Str(String("set uart mode 0x10",CR))
  retval := Wifly_FillBuffer_Check_Ack(string("AOK"),ERASE_BUFFER,1000)

  'Select the authentication mode WPA2-PSK
  RN_XV.Str(String("set wlan auth 4",CR))
  retval := Wifly_FillBuffer_Check_Ack(string("AOK"),ERASE_BUFFER,500)
 
  'Deactivate remote connection automatic message
  RN_XV.Str(String("set com remote 0",CR))
  retval := Wifly_FillBuffer_Check_Ack(string("AOK"),ERASE_BUFFER,500)

  'Set port number
  RN_XV.Str(String("set ip localport 80",CR))
  retval := Wifly_FillBuffer_Check_Ack(string("AOK"),ERASE_BUFFER,500)

  'Scan for connection points
  RN_XV.Str(String("scan",CR))
  retval := Wifly_FillBuffer_Check_Ack(string("<2.32>"),ERASE_BUFFER,1000)
  retval := Wifly_FillBuffer_Check_Ack(string("SCAN>"),DONT_ERASE_BUFFER,3000)

  bytefill(@tBuffer, 0, TBUFFERSIZE)          'Clear Buffer to all 0's
  Term.Str(String("Type name of your ssid and press Enter."))
  Term.StrIn(@tBuffer)
  RN_XV.Str(String("set wlan ssid "))
  RN_XV.Str(@tBuffer)
  RN_XV.Str(String(CR))
  retval := Wifly_FillBuffer_Check_Ack(string("AOK"),ERASE_BUFFER,500)

  bytefill(@tBuffer, 0, TBUFFERSIZE)          'Clear Buffer to all 0's
  Term.Str(String("Type your phrase (password) and press Enter."))
  Term.StrIn(@tBuffer)
  RN_XV.Str(String("set wlan phrase "))
  RN_XV.Str(@tBuffer)
  RN_XV.Str(String(CR))
  retval := Wifly_FillBuffer_Check_Ack(string("AOK"),ERASE_BUFFER,1000)

  'Save settings in config file
  RN_XV.Str(String("save",CR))
  retval := Wifly_FillBuffer_Check_Ack(string("AOK"),ERASE_BUFFER,500)

'----------------------------------------------------------------------
PUB Send_index_HTML

    RN_XV.Str(string("<html><title>Propeller/WiFly Web Server</title>"))
    delay_ms(1)
    RN_XV.Str(string("<form name="))
    delay_ms(1)
    RN_XV.Str(String(34))
    RN_XV.Str(string("input"))
    RN_XV.Str(String(34))
    delay_ms(1)
    RN_XV.Str(string(" action="))
    RN_XV.Str(String(34))
    RN_XV.Str(string("/"))
    RN_XV.Str(String(34))
    delay_ms(1)
    RN_XV.Str(string(" method="))
    RN_XV.Str(String(34))
    RN_XV.Str(string("post"))
    RN_XV.Str(String(34))
    delay_ms(1)
    RN_XV.Str(string(">Username:<input type="))
    RN_XV.Str(String(34))
    RN_XV.Str(string("text"))
    delay_ms(1)
    RN_XV.Str(String(34))
    RN_XV.Str(string(" name="))
    delay_ms(1)
    RN_XV.Str(String(34))
    RN_XV.Str(string("username"))
    delay_ms(1)
    RN_XV.Str(String(34))
    RN_XV.Str(string(" />  <input type="))
    delay_ms(1)
    RN_XV.Str(String(34))
    RN_XV.Str(string("submit"))
    RN_XV.Str(String(34))
    delay_ms(1)
    RN_XV.Str(string(" value="))
    RN_XV.Str(String(34))
    RN_XV.Str(string("Submit"))
    delay_ms(1)
    RN_XV.Str(String(34))
    RN_XV.Str(string(" /></form> </html>",CR,LF))
    delay_ms(1)

'----------------------------------------------------------------------
PUB Send_hello_HTML(stradd)
'
    RN_XV.Str(string("<html>"))
    delay_ms(1)
    RN_XV.Str(string("  <head>"))
    delay_ms(1)
    RN_XV.Str(string("    <title>Propeller/WiFly Web Server</title>"))
    delay_ms(1)
    RN_XV.Str(string("  </head>"))
    delay_ms(1)
    RN_XV.Str(string("  <body>"))
    delay_ms(1)
    RN_XV.Str(string("    <h1>Hello back at you "))
    delay_ms(1)
    RN_XV.Str(stradd)    
    delay_ms(1)
    RN_XV.Str(string("    </h1>"))
    delay_ms(1)
    RN_XV.Str(string("  </body>"))
    delay_ms(1)
    RN_XV.Str(string("</html>",CR,LF))
    delay_ms(1)

'----------------------------------------------------------------------
PUB Enter_Command_Mode | lcnt, retval

  lcnt := 0
  repeat
    RN_XV.Str(String(CR))                        'check to see if we are already in command mode
    retval := Wifly_FillBuffer_Check_Ack(string("<2.32>"),ERASE_BUFFER,1000)

    if(retval < 0)
      RN_XV.Str(String("$$$"))                   'Enter command mode
      retval := Wifly_FillBuffer_Check_Ack(string("CMD"),ERASE_BUFFER,1000)
    ++lcnt
    if( lcnt => 3)  'reboot after 4 attempts
      reboot
  until retval => 0

'----------------------------------------------------------------------
PUB Close_Exit | retval

  RN_XV.Str(String("close",CR))
  retval := Wifly_FillBuffer_Check_Ack(string("*CLOS*"),ERASE_BUFFER,1000)

  RN_XV.Str(String("exit",CR))
  retval := Wifly_FillBuffer_Check_Ack(string("EXIT"),ERASE_BUFFER,1000)

'----------------------------------------------------------------------
PUB Wifly_FillBuffer_Check_Ack(ackstring,erase,ms)

  result := -1
  if(erase)                                      'if true
    Clear_Buffer                                 '  clear the buffer
  Wifly_FillBuffer(ms)

  result := STR.strPos(@Buffer, ackstring,0)

  return result

'----------------------------------------------------------------------
PUB Wifly_FillBuffer(ms) | Rx, Rxcnt, tm

  Rxcnt := 0
  tm := cnt
  repeat until (cnt - tm) / (clkfreq / 1000) > ms
    '1 second Divided by 9600 gives 104uS per bit. 104uS * 10 bits per byte = 1.04 ms
    '2 ms is long enough to wait before realizing the transmission has ended or maybe never started
    repeat while (Rx := RN_XV.CharTime(2) ) => 0
       if( Rx > 0)
         Buffer[Buffer_Index++] := Rx
         ++Rxcnt
       if (Buffer_Index => BUFFERSIZE)
         Buffer_Index := 0                       'Loop buffer around
          '*error* Buffer overflow
    if( Rxcnt > 0)
      if( Buffer_Index == 0)
        Buffer_Index := BUFFERSIZE
      Buffer[Buffer_Index] := 0
      Term.str(@Buffer)
      quit

'----------------------------------------------------------------------
PUB Clear_Buffer

  Buffer_Index := 0
  bytefill(@Buffer, 0, BUFFERSIZE-1)             'Clear Buffer to all 0's

'----------------------------------------------------------------------
PUB Delay_ms(mS)                                 'Delay_ms routine

  waitcnt((clkfreq/1000) * mS + cnt)

'----------------------------------------------------------------------

PUB Delay_us(uS)                                 'Delay_us routine

  waitcnt((clkfreq/1000000) * uS + cnt)

'----------------------------------------------------------------------
DAT

  AppHeader byte  CR,LF,"Wifly Web Server V01.spin is Alive",CR,LF,0

{{

┌──────────────────────────────────────────────────────────────────────────────────────┐
│                           TERMS OF USE: MIT License                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this  │
│software and associated documentation files (the "Software"), to deal in the Software │ 
│without restriction, including without limitation the rights to use, copy, modify,    │
│merge, publish, distribute, sublicense, and/or sell copies of the Software, and to    │
│permit persons to whom the Software is furnished to do so, subject to the following   │
│conditions:                                                                           │                                            │
│                                                                                      │                                               │
│The above copyright notice and this permission notice shall be included in all copies │
│or substantial portions of the Software.                                              │
│                                                                                      │                                                │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   │
│INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         │
│PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    │
│HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION     │
│OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE        │
│SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                │
└──────────────────────────────────────────────────────────────────────────────────────┘
}}