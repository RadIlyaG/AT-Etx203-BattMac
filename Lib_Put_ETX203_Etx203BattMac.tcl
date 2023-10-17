
# ***************************************************************************
# DateTime_Test
# ***************************************************************************
proc DateTime_Test {bar} {  
  global gaSet buffer gaGui
  Status "DateTime_Test in UUT-$bar"
  set gaSet(fail) "Logon fail"
  set getBar [$gaGui(entDUT$bar) cget -text]
  set ret [Login $bar]
  puts "ret of Login 1: <$ret>"
  if {$ret!=0} {
    set ret [Login $bar]
    puts "ret of Login 2: <$ret>"
    if {$ret!=0} {
      AddToLog "FAIL..$gaSet(fail)..FAIL"
      set failTxt "Login fail"
      if [info exists gaSet(CheckPrompt)] {
        append failTxt ". $gaSet(CheckPrompt)"
      }
      $gaGui(entDUT$bar) configure -bg red -text "$getBar. $failTxt"
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
  
  regexp {(date|time)\s+([\d-]+)\s+([\d:]+)\s} $buffer - ma1 dutDate dutTime
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
    kos      {set user "su"     ; set password "Mgrthde6zZMbhA"}
    GC       {set user "su"     ; set password "naijah6E"}
    default  {set user "su"     ; set password "1234"}
  }  
  Status "Login into ETX-2x"
#   set ret [MyWaitFor $gaSet(comDut) {ETX-2I user>} 5 1]
  set com $gaSet(comDut$bar)
  Send $com "\r" stam 0.25
  #Send $com "\r" stam 0.25
  if {([string match {*203*} $buffer]==0) && ([string match {*user>*} $buffer]==0) && \
      ([string match {*TYPE-1*} $buffer]==0) && ([string match {*TYPE-3*} $buffer]==0)} {
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
    set gaSet(prompt) 203
    Send $com "exit all\r" $gaSet(prompt) 2
    set ret [CheckPrompt]
    puts "Login.1 Ret of CheckPrompt: <$ret>" ; update
    return $ret
  }
  if {[string match *ztp* $buffer]} {
    set ret 0
    set gaSet(prompt) ztp
    Send $com "exit all\r" $gaSet(prompt) 2
    return 0
  }
  if {[string match *TYPE-1* $buffer]} {
    set ret 0
    set gaSet(prompt) TYPE-1
    Send $com "exit all\r" $gaSet(prompt) 2
    return 0
  }
  if {[string match *TYPE-3* $buffer]} {
    set ret 0
    set gaSet(prompt) TYPE-3
    Send $com "exit all\r" $gaSet(prompt) 2
    return 0
  }
  if {[string match *eff-rad* $buffer]} {
    set ret 0
    set gaSet(prompt) eff-rad
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
  if {[string match *user>* $buffer]} {
    if {$gaSet(userPassOpt)=="cellcom"} {
      Send $com "\r" stam 0.25
    }
    Send $com "$user\r" stam 0.25
    set ret [Send $com "$password\r" "203" 1]    
    if {$ret==0} {
      set gaSet(prompt) 203
    } elseif {[string match {*TYPE-1*} $buffer]==1} {
      set gaSet(prompt) TYPE-1
      set ret 0
    } elseif {[string match {*TYPE-3*} $buffer]==1} {
      set gaSet(prompt) TYPE-3
      set ret 0
    } elseif {[string match {*fullsave-rad*} $buffer]==1} {
      set gaSet(prompt) fullsave-rad
      set ret 0
    } elseif {[string match {*eff-rad*} $buffer]==1} {
      set gaSet(prompt) eff-rad
      set ret 0
    }
    $gaSet(runTime) configure -text ""
    if {$ret==0} {
      set ret [CheckPrompt]
      puts "Login.2 Ret of CheckPrompt: <$ret>" ; update
      return $ret
    }
    return $ret
  }
  if {$ret!=0} {
    set ret [Wait "Wait for ETX up" 10 white]
    if {$ret!=0} {return $ret}  
  }
  for {set i 1} {$i <= 15} {incr i} { 
    set ret -1
    if {$gaSet(act)==0} {return -2}
    Status "Login into ETX-203"
    puts "Login into ETX-203 i:$i"; update
    $gaSet(runTime) configure -text $i
    Send $com \r stam 5
    #set ret [MyWaitFor $gaSet(comDut) {ETX-2I user> } 5 60]
    if {[string match {*203*} $buffer]==1    || [string match {*ztp*} $buffer]==1 || \
        [string match {*user>*} $buffer]==1  || [string match {*TYPE-1*} $buffer]==1 ||\
        [string match {*TYPE-3*} $buffer]==1 || [string match {*fullsave-rad*} $buffer]==1 ||\
        [string match {*eff-rad*} $buffer]==1} {
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
      puts "Login returnA"
      return 0
    }
  }
  puts "Login 1 ret:<$ret>"
  if {$ret==0} {
    if {[string match *user* $buffer]} {
      Send $com "$user\r" stam 1
      set ret [Send $com "$password\r" "203" 1]
      if {$ret==0} {
        set gaSet(prompt) 203
        if {$ret==0} {
          set ret [CheckPrompt]
          puts "Login.3 Ret of CheckPrompt: <$ret>" ; update
          return $ret
        }
      } elseif {[string match {*ztp*} $buffer]==1} {
        set gaSet(prompt) ztp
        set ret 0
      } elseif {[string match {*TYPE-1*} $buffer]==1} {
        set gaSet(prompt) TYPE-1
        set ret 0
      } elseif {[string match {*TYPE-3*} $buffer]==1} {
        set gaSet(prompt) TYPE-3
        set ret 0
      } elseif {[string match {*fullsave-rad*} $buffer]==1} {
        set gaSet(prompt) fullsave-rad
        set ret 0
      } elseif {[string match {*eff-rad*} $buffer]==1} {
        set gaSet(prompt) eff-rad
        set ret 0
      }
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
# ***************************************************************************
# ReadSWver
# ***************************************************************************
proc ReadSWver {bar} {
  global gaSet buffer gaGui
  Status "Read SW ver. at $bar"
  set com $gaSet(comDut$bar)
  set ret [Send $com "exit all\r" $gaSet(prompt)]
  if {$ret!=0} {return $ret}
  if {$gaSet(userPassOpt)=="kos"} {
    set ret [Send $com "le\r" "#"]
  } else { 
    set ret [Send $com "le\r" $gaSet(prompt)]
  }
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
  global gaSet buffer gaGui
  Status "Read CPLD ver. at $bar"
  set com $gaSet(comDut$bar)
  set ret [Send $com "exit all\r" "$gaSet(prompt)"]
  if {$ret!=0} {return $ret}  
  Send $com "logon\r" stam 1.0
  
  if {[string match {*command not recog*} $buffer]==0} {
    set ret [Send $com "logon debug\r" password]
    if {$ret!=0} {return $ret}
    regexp {Key code:\s+(\d+)\s} $buffer - kc
    catch {exec atedecryptor.exe $kc pass} password
    set ret [Send $com "$password\r" $gaSet(prompt) 1]
    if {$ret!=0} {return $ret}
  }     
    
  set gaSet(fail) "$bar. Read CPLD ver. fail"
  set ret [Send $com "\r" $gaSet(prompt)]
  if {$ret!=0} {return $ret}
  set ret [Send $com "d mem address  c0008000 read char length 1\r" $gaSet(prompt)]
  if {$ret!=0} {return $ret} 
  
  set res [regexp {0xC0008000\s(\w+)\s} $buffer ma val]
  if {$res==0} {
    set gaSet(fail) "$bar. Read CPLD ver. fail"
    return -1
  }
  set val     [string trim $val]
  set guiCpld [string trim $gaSet(entCpldVer)]
  puts "uutCpld:<$val> guiCpld:<$guiCpld>" ; update
  set gaSet(dutCpldVer) $val
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
  if {$gaSet(userPassOpt)=="kos"} {
    set ret [Send $com "show device-information\r" "#"]
  } else { 
    set ret [Send $com "show device-information\r" $gaSet(prompt)]
  }
  if {$ret!=0} {return $ret}
  set res [regexp {Hw\:\s+([\d\.\(\)\w\/ ]+)\,\s} $buffer ma val ]
  if {$res==0} {
    set gaSet(fail) "Read HW ver. fail"
    return -1
  }
  set gaSet(dutHwVer) [string trim $val]
  puts "HW:<$gaSet(dutHwVer)>"
  return 0
}

# ***************************************************************************
# ReadSwDate
# ***************************************************************************
proc ReadSwDate {bar} {
  global gaSet buffer gaGui
  Status "Read SW's date at $bar"
  set com $gaSet(comDut$bar)
  set ret [Send $com "exit all\r" $gaSet(prompt)]
  if {$ret!=0} {return $ret}  
  set ret [Send $com "file\r" $gaSet(prompt)]
  if {$ret!=0} {return $ret}
  set ret [Send $com "show sw-pack\r" $gaSet(prompt)]
  if {$ret!=0} {return $ret}
  set res [regexp {(\d{4}-[\d\-]+)[\s\d\:]+active} $buffer ma val ]
  if {$res==0} {
    set gaSet(fail) "Read SW's date fail"
    return -1
  }
  set gaSet(dutSwDate) [string trim $val]
  puts "SW's date:<$gaSet(dutSwDate)>"
  return 0
}

# ***************************************************************************
# ReadInfo
# ***************************************************************************
proc ReadInfo {bar} {
  global gaSet buffer gaGui
  Status "Read Info at $bar"
  set com $gaSet(comDut$bar)
  set ret [Send $com "exit all\r" $gaSet(prompt)]
  if {$ret!=0} {return $ret}  
  Send $com "info\r" "more" 20
  if {$gaSet(prompt)=="203"} {
    if [string match "*ETX-203\#*" $buffer] {
      set gaSet(fail) "$gaSet(entInfo) not found"
      return -1
    }
  } elseif {$gaSet(prompt)=="ztp"} {
    if [string match "*ztp\#*" $buffer] {
      set gaSet(fail) "$gaSet(entInfo) not found"
      return -1
    }
  }
  
  set maxLoop 25
  set loop 0
  while 1 {
    
    incr loop
    puts "loop:$loop"; update
    set res [string match "*$gaSet(entInfo)*" $buffer]
    if {$res==1} {
      Send $com "\3" $gaSet(prompt)
      Send $com "\r" $gaSet(prompt)
      break
    }
    if {$gaSet(prompt)=="203"} {
      if {[string match "*ETX-203\#*" $buffer] || $loop>$maxLoop || $gaSet(act)==0} {
        set gaSet(fail) "\'$gaSet(entInfo)\' not found"
        return -1
      }
    } elseif {$gaSet(prompt)=="ztp"} {
      if {[string match "*ztp\#*" $buffer] || $loop>$maxLoop || $gaSet(act)==0} {
        set gaSet(fail) "\'$gaSet(entInfo)\' not found"
        return -1
      }
    }
    Send $com "\r" "more" 4
  }
#   if {$res==0} {
#     set gaSet(fail) "Read SW's date fail"
#     return -1
#   }
#   set gaSet(dutInfo) [string trim $val]
#   puts "DUT Info :<$gaSet(dutInfo)>"
  return 0
}

# ***************************************************************************
# CheckPrompt
# ***************************************************************************
proc CheckPrompt {} {
  global gaSet buffer
  catch {unset gaSet(CheckPrompt)}
  if {$gaSet(testedProduct)=="ETX-203AX-E1"} {
    if {[string match *ETX-203AX-E1* $buffer]} {
      puts "CheckPrompt 0.1"
      return 0
    } else {
      puts "Wrong prompt.1 ($buffer)"
      set gaSet(CheckPrompt) "Wrong prompt. Check page"
      return -1
    }  
  } elseif {$gaSet(testedProduct)=="ETX203"} {
    if {[string match *ETX-203AX-E1* $buffer]} {
      puts "Wrong prompt.2 ($buffer)" 
      set gaSet(CheckPrompt) "Wrong prompt. Check page"
      return -1
    } else {
      puts "CheckPrompt 0.2"
      return 0
    }
  } else {  
    puts "CheckPrompt 0.3"
    return 0
  }
}

# ***************************************************************************
# EntryBootMenu
# ***************************************************************************
proc EntryBootMenu {bar} {
  global gaSet buffer
  puts "[MyTime] EntryBootMenu"; update
  set com $gaSet(comDut$bar)
  Status "Entry to Boot Menu of UUT-$bar"
  set gaSet(fail) "Entry to Boot Menu fail"
  set ret [Send $com "admin reboot\r" "yes/no"]
  set ret [Send $com "y\r" "stop auto-boot.." 20]
  if {$ret!=0} {return $ret}
  set ret [Send $com \r\r "\[boot\]:"]
  if {$ret!=0} {return $ret}
  
  return 0
}

# ***************************************************************************
# AdminFactAll
# ***************************************************************************
proc AdminFactAll {bar} {
  global gaSet buffer
  global gaSet buffer gaGui
  set ret [Login $bar]
  if {$ret!=0} {
    set ret [Login $bar]
    if {$ret!=0} {return $ret}
  }
  Status "Admin Factory All to UUT-$bar"  
  set com $gaSet(comDut$bar)
  set ret [Send $com "admin factory-default-all\r" "yes/no"]
  if {$ret!=0} {return $ret} 
  set ret [Send $com "y\r" "seconds" 20]
  if {$ret!=0} {return $ret} 
  Wait "Wait for UUT-$bar up" 30
  return 0
}  
# ***************************************************************************
# VerifySN
# ***************************************************************************
proc VerifySN {bar} {
  global gaSet buffer
  global gaSet buffer gaGui
  set ret [Login $bar]
  if {$ret!=0} {
    set ret [Login $bar]
    if {$ret!=0} {return $ret}
  }  
  Status "Read Serial Number at UUT-$bar"
  set com $gaSet(comDut$bar)
  set ret [Send $com "exit all\r" $gaSet(prompt)]
  if {$ret!=0} {return $ret}  
  set ret [Send $com "configure system\r" system]
  if {$ret!=0} {return $ret}
  set ret [Send $com "show device-information\r" system]
  if {$ret!=0} {return $ret}
  set res [regexp {Serial Number[\s\:]+(\d+)} $buffer ma val ]
  if {$res==0} {
    set res [string match {*Manufacturer Serial Number : Not Available*} $buffer]
    if {$res==0} {
      set gaSet(fail) "Read Serial Number fail"
      return -1
    } else {
      set val "0000000000000000"
    }
  }
  set gaSet(dutSerNum) [string trim $val]
  puts "SerNum:<$gaSet(dutSerNum)> gaSet(entSN$bar):<$gaSet(entSN$bar)>"
  if {[string range $gaSet(dutSerNum) 6 end]=="$gaSet(entSN$bar)"} {
    return 0
  } else {
    set gaSet(fail) "SN is $gaSet(dutSerNum) instead of 000000$gaSet(entSN$bar)"
    return -1
  }
}
