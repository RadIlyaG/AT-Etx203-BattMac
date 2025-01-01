set gaSet(performDgTest) 0
$gaGui(performDgTest) configure -state disabled
update
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
  if {$ret!=0} {
    $gaGui(entDUT$bar) configure -bg red -text "$getBar. Can't get config-system"
  }
  if {$gaSet(performBattTest)==0} {
    return $ret
  }
  if {$ret==0} { 
    set ret [Send $com "show system-date\r" >system 2]
    if [string match {*cli error*} $buffer] {
      set ret [Send $com "show date-and-time\r" >system]
    }
  }
  if {$ret!=0} {
    $gaGui(entDUT$bar) configure -bg red -text "$getBar. Show Date_Time fail"
    return $ret
  }
  
  regexp {date\s+([\d-]+)\s+([\d:]+)\s} $buffer - dutDate dutTime
  set txt "UUT $bar $getBar. Date: $dutDate"
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
#   if {($mac2<0x0020D2500000) || ($mac2>0x0020D2FFFFFF)} {
#     RLSound::Play fail
#     set gaSet(fail) "The MAC of UUT $bar is $mac"
#     set gaSet(fail) "FAIL..The MAC of UUT $bar is $mac..FAIL"
#     $gaGui(entDUT$bar) configure -bg red -text "$getBar. The MAC of UUT $bar is $mac"
#     set ret [DialogBox -type "Terminate Continue" -icon /images/error -title "MAC check"\
#         -text $gaSet(fail) -aspect 2000]
#     if {$ret=="Terminate"} {
#       return -1
#     }
#   }
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
  if {([string match {*205*} $buffer]==0) && ([string match {*user>*} $buffer]==0) && \
      ([string match {*TYPE-3_e*} $buffer]==0)} {
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
  if {[string match *205* $buffer]} {
    set ret 0
    set gaSet(prompt) 205
    Send $com "exit all\r" $gaSet(prompt) 2
    return 0
  }
  if {[string match *TYPE-3_e* $buffer]} {
    set ret 0
    set gaSet(prompt) TYPE-3_e
    Send $com "exit all\r" $gaSet(prompt) 2
    return 0
  }  
if {[string match *ZTP* $buffer]} {
    set ret 0
    set gaSet(prompt) ZTP
    Send $com "exit all\r" $gaSet(prompt) 2
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
    if {$gaSet(userPassOpt)=="cellcom"} {
      Send $com "\r" stam 0.25
    }
    Send $com "$user\r" stam 0.25
    set ret [Send $com "$password\r" 205 1]
    if {$ret==0} {
      set gaSet(prompt) 205
    } elseif {[string match {*TYPE-3_e*} $buffer]==1} {
      set gaSet(prompt) TYPE-3_e
      set ret 0
    } elseif {[string match {*ZTP*} $buffer]==1} {
      set gaSet(prompt) ZTP
      set ret 0
    }
    $gaSet(runTime) configure -text ""
    return $ret
  }
  if {$ret!=0} {
    set ret [Wait "Wait for ETX up" 10 white]
    if {$ret!=0} {return $ret}  
  }
  for {set i 1} {$i <= 22} {incr i} { 
    set ret -1
    if {$gaSet(act)==0} {return -2}
    Status "Login into ETX-205"
    puts "Login into ETX-205 i:$i"; update
    $gaSet(runTime) configure -text $i
    Send $com \r stam 5
    #set ret [MyWaitFor $gaSet(comDut) {ETX-2I user> } 5 60]
    if {([string match {*205*} $buffer]==1) || ([string match {*user>*} $buffer]==1) || \
        ([string match {*TYPE-3_e*} $buffer]==1) || ([string match {*ZTP*} $buffer]==1)} {
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
      set ret [Send $com "$password\r" "205" 1]
      if {$ret==0} {
        set gaSet(prompt) 205
      } elseif {[string match {*TYPE-3_e*} $buffer]==1} {
        set gaSet(prompt) TYPE-3_e
        set ret 0
      } elseif {[string match {*ZTP*} $buffer]==1} {
        set gaSet(prompt) ZTP
        set ret 0
      }
    }
  }  
  if {$ret!=0} {
    set gaSet(fail) "Login to ETX-205 Fail"
  }
  $gaSet(runTime) configure -text ""
  if {$gaSet(act)==0} {return -2}
  Status $statusTxt
  return $ret
}
# ***************************************************************************
# ReadSWver
# ***************************************************************************
proc ReadSWver {bar} {
  global gaSet buffer gaGui
  Status "Read SW ver. at $bar"
  set com $gaSet(comDut$bar)
  set ret [Send $com "exit all\r" $gaSet(prompt)]
  if {$ret!=0} {return $ret}  
  set ret [Send $com "le\r" $gaSet(prompt)]
  if {$ret!=0} {return $ret}
  set res [regexp {sw\s+\"([\d\.\(\)\w]+)\"\s} $buffer ma val ]
  if {$res==0} {
    set gaSet(fail) "Read SW ver. fail"
    return -1
  }
  set gaSet(dutSwVer) $val
  puts "SW:<$gaSet(dutSwVer)>"
  return 0
}
# ***************************************************************************
# ReadCpldver
# ***************************************************************************
proc ReadCpldver {bar} {
  set gaSet(dutCpldVer) ""
  return 0
}
# ***************************************************************************
# ReadHWver
# ***************************************************************************
proc ReadHWver {bar} {
  global gaSet buffer gaGui
  Status "Read HW ver. at $bar"
  set com $gaSet(comDut$bar)
  set ret [Send $com "exit all\r" $gaSet(prompt)]
  if {$ret!=0} {return $ret}  
  set ret [Send $com "configure system\r" $gaSet(prompt)]
  if {$ret!=0} {return $ret}
  set ret [Send $com "show device-information\r" $gaSet(prompt)]
  if {$ret!=0} {return $ret}
  set res [regexp {Hw\:\s+([\d\.\(\)\w\/\s]+)\,\s} $buffer ma val ]
  if {$res==0} {
    set gaSet(fail) "Read HW ver. fail"
    return -1
  }
  set gaSet(dutHwVer)  [string trim $val]
  puts "HW:<$gaSet(dutHwVer)>"
  return 0
}