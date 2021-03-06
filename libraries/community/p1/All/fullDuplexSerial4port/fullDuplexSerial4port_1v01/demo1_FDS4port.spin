{Tracy Allen, EME systems.  18-Jan-2011   see end of file for terms of use
Demo program for FullDuplexSerial4portPlus
This demo can be set up on any propeller system.
It is meant to show the basic setup for use as a single serial port, like the original fullDuplexSerial.
Why would you use this?
Maybe you are planning a larger project and want to keep options open for more serial ports later.
Or maybe you need the flow control or options, for something like an XBee say or a fancy modem or scientific instrument.
Or maybe you need a large rx or tx buffer, because the limit here is only the extent of free memory.

This test doesn't do anything serious.  Testing is done through the main system serial port on pins 31=rx and 30=tx,
with a terminal program like PST or CoolTerm on the other end.


Wiring summary:
  -- prop plug or what have you to terminal program.

The setup:
 -- fullDuplexSerial4port is included as an OBJect.   It will start up another cog with the pasm portion, and its spin methods
    will be available to send data bytes and strings, and to receive bytes either with or without blocking.  The basics.
--  A 2nd object is declared, dataIO4port for numeric I/O. Note that it too includes fullDuplexSerial4port.
    However, there is only one copy of fullDuplexSerial4port.  Its methods, code & buffers are shared in common
    It is needed only for numeric data output, or for numeric or string data input.   Sometimes these methods are included within
    serial port object, but I prefer for flexibility to have them in a separate object.
    If you prefer you can merge the methods that you need from dataIO4port back into the main object.
    How to do so is described in the comments with dataIO4port.
 -- The demo initializes port 0 as DEBUG, using pins 31 for rx and 30 for tx.   Ports 1 to 3 are left unused.
    If you prefer, you can change the port number and pins in the CONstants section.
 -- At startup  the program will display the current buffer size.
    A small menu will appear on your terminal screen, asking you to enter a number of repetitions desired.
    The purpose is to show how to read in a decimal value entered at the keyboard.
    The main loop prints out a phrase, the number of times requested.
    However, if the user presses the space bar early, then the program will stop with fewer repetitions.
 -- Note that all calls to  fds and dio always include reference to the port number, DEBUG.
}

CON
_clkmode = xtal1 + pll16x
_xinfreq = 5_000_000

  DEBUG = 0     ' DEBUG port number, for fullDuplexSerial4port to use when sending to terminal
  BAUD = 9600   ' has to match the terminal program on the other end
  RX_PIN = 31
  TX_PIN = 30


  CR = 13
  SP = 32



OBJ
  fds :  "FullDuplexSerial4port"
  dio :  "dataIO4port"

VAR

long reps
byte myString[64]

PUB main
  start_uarts
  fds.str(DEBUG,string(CR,CR,"starting... "))

  showBufferSize
  repeat
    dio.dec(DEBUG,reps:=getReps)   ' a compound statement, gets value, assigns it to a variable, then prints its value
    fds.tx(DEBUG,13)                ' the basic i/o methods are part of fullDuplexSerial4port
    fds.str(DEBUG,string(13,"Press space to break out..."))

    sendFoxOverDog


PUB sendFoxOverDog  | n
repeat n from 1 to reps
  pause(100)  '
  fds.str(DEBUG,@foxdog) ' the string is stored in the DAT section, @foxdog is a pointer to the string
  dio.dec(DEBUG, n)     ' to show how to display a decimal value
  fds.str(DEBUG,string(" times")) ' here is a string embedded in code
  if fds.rxCheck(DEBUG) == SP     ' this calls a method that returns without blocking, with -1 if no key has been pressed, or the ascii of the key
    quit                       ' , here looking for SPacebar=32, quit if so

     ' that's all folks!

PUB start_uarts
'' port 0-3 port index of which serial port
'' rx/tx/cts/rtspin pin number                          #PINNOTUSED = -1  if not used
'' prop debug port rx on p31, tx on p30
'' cts is prop input associated with tx output flow control
'' rts is prop output associated with rx input flow control
'' rtsthreshold - buffer threshold before rts is used   #DEFAULTTHRSHOLD = 0 means use default=buffer 3/4 full
''                                                      note rtsthreshold has no effect unless RTS pin is enabled
'' mode bit 0 = invert rx                               #INVERTRX  bit mask
'' mode bit 1 = invert tx                               #INVERTTX  bit mask
'' mode bit 2 = open-drain/source tx                    #OCTX   bit mask
'' mode bit 3 = ignore tx echo on rx                    #NOECHO   bit mask
'' mode bit 4 = invert cts                              #INVERTCTS   bit mask
'' mode bit 5 = invert rts                              #INVERTRTS   bit mask
'' baudrate                                             desired baud rate, e.g. 9600

  fds.init                        ' sets up and clears the buffers and pointers, returns a pointer to the internal fds data structure
                                  ' always call init before adding or starting ports.

  fds.AddPort(DEBUG, RX_PIN, TX_PIN,-1,-1,0,0,BAUD) ' debug to the terminal screen, without flow control, normal non-inverted mode

' port 1, 2, 3 are not used.   The order that you define ports does not matter.  You don't have to do anything to set up unused ports

  fds.Start
  pause(100)   ' delay to get going before sending or receiving any data


PUB ShowBufferSize | idx
  ' the following shows that it is possible to read the internal data structure of the fds object.
  ' this simply reads the CONstants in fullDuplexSerial4port that define the buffer sizes.
  fds.str(DEBUG,string(CR, "receive buffer size = "))
  dio.dec(DEBUG,fds#RX_SIZE0)
  fds.str(DEBUG,string(CR, "transmit buffer size = "))
  dio.dec(DEBUG,fds#TX_SIZE0)
  fds.tx(DEBUG,CR)

PUB getReps
  fds.str(DEBUG,string(13,13,"Please enter number of repetitions: "))
  return dio.decIn(DEBUG)


PUB pause(ms)
  waitcnt(clkfreq/1000*ms + cnt)

DAT
  foxdog byte 13,"A quick brown fox jumps over the lazy dog ",0

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


