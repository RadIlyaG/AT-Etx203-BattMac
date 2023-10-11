
# ***************************************************************************
# DateTime_Test
# ***************************************************************************
proc DateTime_Test {bar} {
  global gaSet buffer gaGui
  Status "DateTime_Test in UUT-$bar"
  set gaSet(fail) "Logon fail"
  set getBar [$gaGui(entDUT$bar) cget -text]
  set ret [Login $bar]
  if {$ret!=0} {
    set ret [Login $bar]
    if {$ret!=0} {
      AddToLog "FAIL..$gaSet(fail)..FAIL"
      $gaGui(entDUT$bar) configure -bg red -text "$getBar. Login fail"
      return $ret
    }
  }
  set gaSet(fail) "Logon fail"
  set com $gaSet(comDut$bar)
  Send $com "exit all\r" stam 0.25 
  set ret [Send $com "configure system\r" >system]
  if {$ret==0} { 
    set ret [Send $com "show system-date\r" >system]
  }
  if {$ret!=0} {
    $gaGui(entDUT$bar) configure -bg red -text "$getBar. Show system-date fail"
    return $ret
  }
  
  regexp {date\s+([\d-]+)\s+([\d:]+)\s} $buffer - dutDate dutTime
  set txt "UUT $bar date: $dutDate"
  puts $txt
  if {$dutDate=="1970-01-01"} {
    set gaSet(fail) "FAIL..$txt. Battery not exist..FAIL"
    $gaGui(entDUT$bar) configure -bg red -text "$getBar. Battery not exist"
    set ret -1
  } else {
    set ret 0
  }
  AddToLog $txt
  Status ""
  return $ret
}

# ***************************************************************************
# ReadMac
# ***************************************************************************
proc ReadMac {bar} {
  global gaSet buffer gaGui
#   set ret [Login $bar]
#   if {$ret!=0} {
#     set ret [Login $bar]
#     if {$ret!=0} {return $ret}
#   }
  Status "Read Mac at $bar"
  set getBar [$gaGui(entDUT$bar) cget -text]
  set gaSet(fail) "Read MAC fail"
  set com $gaSet(comDut$bar)
  #Send $com "exit all\r" stam 0.25
  #set ret [Send $com "configure system\r" ">system"]
  #if {$ret!=0} {return $ret} 
  set ret [Send $com "show device-information\r" ">system"]
  if {$ret!=0} {return $ret}
  
  set mac 00-00-00-00-00-00
  regexp {MAC\s+Address[\s:]+([\w\-]+)} $buffer - mac
  if [string match *:* $mac] {
    set mac [join [split $mac :] ""]
  }
  set mac1 [join [split $mac -] ""]
  set mac2 0x$mac1
  puts "mac1:$mac1" ; update
  if {($mac2<0x0020D2500000) || ($mac2>0x0020D2FFFFFF)} {
    RLSound::Play fail
    set gaSet(fail) "The MAC of UUT $bar is $mac"
    set gaSet(fail) "FAIL..The MAC of UUT $bar is $mac..FAIL"
    $gaGui(entDUT$bar) configure -bg red -text "$getBar. The MAC of UUT $bar is $mac"
#     set ret [DialogBox -type "Terminate Continue" -icon /images/error -title "MAC check"\
#         -text $gaSet(fail) -aspect 2000]
#     if {$ret=="Terminate"} {
#       return -1
#     }
  }
  set gaSet($bar.dutMac) $mac1
  
  return 0
}

#***************************************************************************
#**  Login
#***************************************************************************
proc Login {bar} {
  global gaSet buffer gaLocal
  set ret 0
  set statusTxt  [$gaSet(sstatus) cget -text]
  switch -exact -- $gaSet(userPassOpt) {
    lt       {set user "ecorad" ; set password "Dwdm.c0re!"}
    cellcom  {set user "admin"  ; set password "Reshatot"}
    default  {set user "su"     ; set password "1234"}
  }  
  Status "Login into ETX-2x"
#   set ret [MyWaitFor $gaSet(comDut) {ETX-2I user>} 5 1]
  set com $gaSet(comDut$bar)
  Send $com "\r" stam 0.25
  #Send $com "\r" stam 0.25
  if {([string match {*203*} $buffer]==0) && ([string match {*user>*} $buffer]==0)} {
    set ret -1  
  } else {
    set ret 0
  }
  if {[string match {*Are you sure?*} $buffer]==1} {
   Send $com n\r stam 1
  }
   
   
  if {[string match *password* $buffer] || [string match {*press a key*} $buffer]} {
    set ret 0
    Send $com \r stam 0.25
  }
  if {[string match *FPGA* $buffer]} {
    set ret 0
    Send $com exit\r\r -2I
  }
  if {[string match *:~$* $buffer] || [string match *login:* $buffer] || [string match *Password:* $buffer]} {
    set ret 0
    Send $com \x1F\r\r -2I
  }
  if {[string match *203* $buffer]} {
    set ret 0
    Send $com "exit all\r" 203 2
    return 0
  }
  if {[string match *->* $buffer]} {
    set ret 0
    Send $com exit\r\r stam 2
  }
  if {[string match *boot* $buffer]} {
    Send $com run\r stam 1
  }
  if {[string match *user* $buffer]} {
    Send $com "$user\r" stam 0.25
    set ret [Send $com "$password\r" "203"]
    $gaSet(runTime) configure -text ""
    return $ret
  }
  if {$ret!=0} {
    set ret [Wait "Wait for ETX up" 10 white]
    if {$ret!=0} {return $ret}  
  }
  for {set i 1} {$i <= 12} {incr i} { 
    if {$gaSet(act)==0} {return -2}
    Status "Login into ETX-203"
    puts "Login into ETX-203 i:$i"; update
    $gaSet(runTime) configure -text $i
    Send $com \r stam 5
    #set ret [MyWaitFor $gaSet(comDut) {ETX-2I user> } 5 60]
    if {([string match {*203*} $buffer]==1) || ([string match {*user>*} $buffer]==1)} {
      puts "if1 <$buffer>"
      set ret 0
      break
    }
    ## exit from boot menu 
    if {[string match *boot* $buffer]} {
      Send $com run\r stam 1
    }   
    if {[string match *login:* $buffer]} { }
    if {[string match *:~$* $buffer] || [string match *login:* $buffer] || [string match *Password:* $buffer]} {
      Send $com \x1F\r\r -2I
      return 0
    }
  }
  if {$ret==0} {
    if {[string match *user* $buffer]} {
      Send $com "$user\r" stam 1
      set ret [Send $com "$password\r" "203"]
    }
  }  
  if {$ret!=0} {
    set gaSet(fail) "Login to ETX-203 Fail"
  }
  $gaSet(runTime) configure -text ""
  if {$gaSet(act)==0} {return -2}
  Status $statusTxt
  return $ret
}
