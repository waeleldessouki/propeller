''********************************************
''*  Bluetooth Bee library, v0.1             *
''*  Author: Ben Lilley                      *
''*  Copyright (c) 2012-2099 Ben Lilley      *
''*  See end of file for terms of use.       *
''********************************************

{-----------------REVISION HISTORY-----------------
 v0.1 - 2.19.2012 initial release, basic functionallity without parsing btstat responses from bee
 v0.2 - 2.20.2012 fixed outa[pin]~ in disconnect method  
}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  _baud_9600   = 9600
  _baud_19200  = 19200
  _baud_38400  = 38400
  _baud_57600  = 57600
  _baud_230400 = 230400
  _baud_115200 = 115200
  _baud_460800 = 460800

  _bt_status_connected   = %00000001
  _bt_status_configured  = %00000010
  _bt_status_error       = %00000100
    
  _bt_mode_master        = %00000001  
  _bt_mode_permit        = %00000010
  _bt_mode_last_device   = %00000100
  _bt_mode_range         = %00001000
          
  _timeout_seconds = 3
  
OBJ

  bt          : "FullDuplexSerial"  
  
DAT
        ' paramterized commands
        _cmd_set_name           byte "+STNA=",0
        _cmd_set_pin            byte "+STPIN=",0
        _cmd_connect            byte "+CONN=",0 
        _cmd_send_pin           byte "+RTPIN=",0
                
        ' non-parameterized commands
        _cmd_baud_9600          byte "+STBD=9600",0
        _cmd_baud_19200         byte "+STBD=19200",0 
        _cmd_baud_38400         byte "+STBD=38400",0 
        _cmd_baud_57600         byte "+STBD=57600",0 
        _cmd_baud_230400        byte "+STBD=230400",0 
        _cmd_baud_115200        byte "+STBD=115200",0 
        _cmd_baud_460800        byte "+STBD=460800",0 
        _cmd_slave              byte "+STWMOD=0",0
        _cmd_master             byte "+STWMOD=1",0

        _cmd_inquire_0          byte "+INQ=0",0
        _cmd_inquire_1          byte "+INQ=1",0         
        
        _cmd_st_auto_0          byte "+STAUTO=0",0
        _cmd_st_auto_1          byte "+STAUTO=1",0

        _cmd_permit_connect_0   byte "+STOAUT=0",0
        _cmd_permit_connect_1   byte "+STOAUT=1",0
        
        _cmd_delete_pin         byte "+DLPIN",0
        _cmd_get_addr           byte "+RTADDR",0
        _cmd_range_autoconn_0   byte "+LOSSRECONN=0",0
        _cmd_range_autoconn_1   byte "+LOSSRECONN=1",0 
        
VAR
  byte status_flags
  byte mode_flags
  byte _pin[4]
  long _baud
  byte error_buffer [100]
  byte cmd_param_buffer [100]
  byte _dis_pin
  byte _scan_buffer [500]
 
PUB start(pio0, din, dout, baud, mode, auto_connect, permit_devices) : ok | i
 {{
    pio0 - optional pin that can force the xbee to disconnect
    
    mode
      0 = slave
      1 = master

    auto_connect - when enabled, module will automatically try to reconnect to last device 
      0 = off
      1 = on

    pemit_devices - when enabled, paired devices are allowed to iniate connections
      0 = off
      1 = on
 }}

  status_flags := %00000000 
  mode_flags := mode
  
  ok := bt.start(din,dout,0,baud) 

  if ok > -1
    status_flags := status_flags | _bt_status_connected
  else
    error_buffer := string("serial init failure")
    status_flags := status_flags | _bt_status_error
  
  repeat i from 0 to 3
    _pin[i] := 0

  if pio0 > 0
    _dis_pin := pio0
    disconnect(pio0)
  
  if mode > 0 AND ok > 0
    mode_flags := mode_flags | _bt_mode_master
    ok := bt_send_command(@_cmd_master) 
  elseif ok > 0
    ok := bt_send_command(@_cmd_slave) 
  
  if auto_connect > 0 AND ok > 0
    mode_flags := mode_flags | _bt_mode_last_device
    ok := bt_send_command(@_cmd_st_auto_1) 
  else
    ok := bt_send_command(@_cmd_st_auto_0)
    
  if permit_devices > 0 AND ok > 0
    mode_flags := mode_flags | _bt_mode_permit
    ok := bt_send_command(@_cmd_permit_connect_1)
  else
    ok := bt_send_command(@_cmd_permit_connect_0)  

  bt.rxflush


  RETURN ok


PUB scan : ok | mark, i, rxbyte, ptr1
  if _dis_pin > 0
    disconnect(_dis_pin)

  ok := bt_send_command(@_cmd_st_auto_0)
  if ok < 0
    RETURN -1

  ok := bt_send_command(@_cmd_master)
  if ok < 0
    RETURN -1

  waitcnt(clkfreq*3 + cnt)
  
  ok := bt_send_command(@_cmd_inquire_1)
  if ok < 0
    RETURN -1

  i := 0
  mark := cnt
  
  repeat
    if cnt-mark => clkfreq*10
      _scan_buffer[i++] := 0
      RETURN @_scan_buffer
      
    rxbyte := bt.rxtime(100)
    if rxbyte <> -1
      if i < 499
        _scan_buffer[i++] := rxbyte
      else
        _scan_buffer[i++] := 0
        RETURN @_scan_buffer 

PUB disconnect(pin)
   dira[pin]~~
   outa[pin]~~
   waitcnt(clkfreq/10 + cnt)
   outa[pin]~   
   dira[pin]~
   
PUB get_addr(addr_ptr) : ok
  {{ addr_ptr = pointer to 6 byte array }}
  ' TODO _cmd_get_addr

PUB inquire_on : ok

  waitcnt(clkfreq*3 + cnt)    
  ok := bt_send_command(@_cmd_inquire_1)
  waitcnt(clkfreq*3 + cnt)
  bt.rxflush
  
  RETURN ok

PUB inquire_off : ok

  waitcnt(clkfreq*3 + cnt)    
  ok := bt_send_command(@_cmd_inquire_0)
  waitcnt(clkfreq*3 + cnt)
  bt.rxflush
  
  RETURN ok

PUB set_name(name) : ok
  {{ name = 0 terminated string ptr }}
  ok := param_cmd(@_cmd_set_name, name)
  bt.rxflush
  RETURN ok

PUB set_pin(pin) : ok | i,p 
  {{ pin = 0 term string ptr }}
  
  p := @pin
  repeat i from 0 to 3
    _pin[i] := byte[p++]
    
  ok := param_cmd(@_cmd_set_pin, pin)
  bt.rxflush
  RETURN ok

PUB send_pin(pin) : ok 
  {{ pin = 0 term string ptr }}
  ok := param_cmd(@_cmd_send_pin , pin)
  bt.rxflush
  RETURN ok

PUB delete_pin(pin) : ok 
  {{ pin = 0 term string ptr }}
  ok := param_cmd(@_cmd_delete_pin , pin)
  bt.rxflush
  RETURN ok

PUB set_baud_9600 : ok
  ok := bt_send_command(@_cmd_baud_9600)
  bt.rxflush
  RETURN ok

PUB set_baud_19200 : ok
  ok := bt_send_command(@_cmd_baud_19200)
  bt.rxflush   
  RETURN ok

PUB set_baud_38400 : ok
  ok := bt_send_command(@_cmd_baud_38400)
  bt.rxflush
  RETURN ok

PUB set_baud_57600 : ok
  ok := bt_send_command(@_cmd_baud_57600)
  bt.rxflush
  RETURN ok

PUB set_baud_115200 : ok
  ok := bt_send_command(@_cmd_baud_115200)
  bt.rxflush
  RETURN ok
  
PUB set_baud_230400 : ok
  ok := bt_send_command(@_cmd_baud_230400)
  bt.rxflush
  RETURN ok
  
PUB set_baud_460800 : ok
  ok := bt_send_command(@_cmd_baud_460800)
  bt.rxflush
  RETURN ok

PUB set_oor_autoconnect : ok
  ok := bt_send_command(@_cmd_range_autoconn_1)
  bt.rxflush
  RETURN ok

PUB unset_oor_autoconnect : ok
  ok := bt_send_command(@_cmd_range_autoconn_0)
  bt.rxflush
  RETURN ok

PUB connect(addr) : ok
  {{ addr = 0 term string ptr }}
  ok := param_cmd(@_cmd_connect, addr)
  bt.rxflush
  RETURN ok

PUB tx(value)
  bt.tx(value)
  
PUB hex(value, digits)
  bt.hex(value, digits)
  
PUB bin(value, digits)
  bt.bin(value, digits)
   
PUB dec(value)
  bt.dec(value)

PUB str(value)
  bt.str(value)

PUB rxflush
  bt.rxflush

PUB rxcheck  
  RETURN bt.rxcheck
  
PUB rxtime(ms)
   RETURN bt.rxtime(ms)
   
PUB rx
  RETURN bt.rx
    
PUB get_error

  RETURN @error_buffer

PRI param_cmd(cmd_ptr, param) : ok | buff_ptr, param_ptr
  bytefill(@cmd_param_buffer, 0, 100)
 
  buff_ptr := @cmd_param_buffer
  param_ptr := param
  
  repeat while byte[cmd_ptr] <> 0
    byte[buff_ptr++] := byte[cmd_ptr++]

  repeat while byte[param_ptr] <> 0
    byte[buff_ptr++] := byte[param_ptr++]   
   
  byte[buff_ptr++] := 0

  waitcnt(clkfreq*3 + cnt)
  ok := bt_send_command(@cmd_param_buffer)
  waitcnt(clkfreq*3 + cnt) 
  
  RETURN ok

 
PRI bt_send_command(cmd_ptr) | i, ok, bb
  bytefill(@error_buffer, 0, 100)

  bt.tx($0D)
  bt.tx($0A)
  bt.str(cmd_ptr)
  bt.tx($0D)
  bt.tx($0A)

  ok := bt_wait_ok

  if ok < 0
    status_flags := status_flags | _bt_status_error

  RETURN ok   

PRI bt_wait_ok | r, mark, e_idx

  mark := cnt
  e_idx := 0
  
  repeat
    r := bt.rxtime(100)

    if cnt-mark => clkfreq*_timeout_seconds
      error_buffer[e_idx++] := 0 
      RETURN -1
    
    if r == $4F
       error_buffer[e_idx++] := r
       repeat
         if cnt-mark => clkfreq*_timeout_seconds
           error_buffer[e_idx++] := 0 
           RETURN -1
           
         r := bt.rxtime(100)
         if r == $4B
           RETURN 1
         elseif r => $20 AND e_idx < 100
           error_buffer[e_idx++] := r
    elseif r => $20 AND e_idx < 100
       error_buffer[e_idx++] := r 

  RETURN 0              
      

PUB stop
  bt.stop
  status_flags := status_flags & !_bt_status_connected 


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