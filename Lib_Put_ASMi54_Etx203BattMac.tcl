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
  AddToLog "No need check Date-Time in ASMi54"
  return 0
  
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
  set ret [Send $com "3\r" "cation"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "1\r" "Interface Status"]
  if {$ret!=0} {return $ret}
  
  set mac 00-00-00-00-00-00
  regexp {MAC\s+Address[\s:]+\(([\w\-]+)\)} $buffer - mac
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
    default  {set user "su"     ; set password "1234"}
  }  
  Status "Login into ASMi54"
#   set ret [MyWaitFor $gaSet(comDut) {ETX-2I user>} 5 1]
  set com $gaSet(comDut$bar)
  Send $com "\r" stam 1
  #Send $com "\r" stam 0.25
  if {([string match {*exit*} $buffer]==0) && ([string match {*menu*} $buffer]==0)} {
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
  
  if {[string match {*main menu*} $buffer] || [string match {*Inventory*} $buffer] } {
    set ret 0
    Send $com "!\r" tilities 2
    return 0
  }
  if {[string match *boot* $buffer]} {
    Send $com @ stam 1
  }
  
  if {[string match {*USER NAME:*} $buffer]} {
    Send $com "$user\r" stam 0.25
    set ret [Send $com "$password\r" "tilities"]
    $gaSet(runTime) configure -text ""
    return $ret
  }
  if {$ret!=0} {
    set ret [Wait "Wait for ASMi54 up" 10 white]
    if {$ret!=0} {return $ret}  
  }
  for {set i 1} {$i <= 7} {incr i} { 
    if {$gaSet(act)==0} {return -2}
    Status "Login into ASMi54"
    puts "Login into ASMi54 i:$i"; update
    $gaSet(runTime) configure -text $i
    Send $com \r stam 5
    if {[string match *boot* $buffer]} {
      Send $com @ stam 1
    }
    #set ret [MyWaitFor $gaSet(comDut) {ETX-2I user> } 5 60]
    if {([string match {*exit*} $buffer]==1) || ([string match {*menu*} $buffer]==1)} {
      puts "if1 <$buffer>"
      set ret 0
      break
    }
    ## exit from boot menu 
    
  }
  if {$ret==0} {
    if {[string match {*USER NAME:*} $buffer]} {
      Send $com "$user\r" stam 1
      set ret [Send $com "$password\r" "tilities"]
    }
  }  
  if {$ret!=0} {
    set gaSet(fail) "Login to ASMi54 Fail"
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
  set getBar [$gaGui(entDUT$bar) cget -text]
  puts "ReadSWver getBar:<$getBar>"
  Status "Read SW ver. at $bar"
  set com $gaSet(comDut$bar)
  Send $com "!\r" tilities 2
  Send $com "1\r" stam 2
  set gaSet(filterBuffer) 0
  set ret [Send $com "g 1,8\r" "exit" 2]
  set gaSet(filterBuffer) 1
  set res [regexp {\[7m([\w\.]+)\s} $buffer - val]
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
  set getBar [$gaGui(entDUT$bar) cget -text]
  puts "ReadHWver getBar:<$getBar>"
  Status "Read HW ver. at $bar"
  set com $gaSet(comDut$bar)
  Send $com "!\r" tilities 2
  Send $com "1\r" stam 2
  set res [regexp {\s+([\w\-\.]+)\s+4001} $buffer - val]
  if {$res==0} {
    set gaSet(fail) "Read HW ver. fail"
    return -1
  }
  set gaSet(dutHwVer)  $val
  puts "SW:<$gaSet(dutHwVer)>"
  return 0
}