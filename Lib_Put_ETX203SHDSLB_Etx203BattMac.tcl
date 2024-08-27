source Lib_Put_ETX203_Etx203BattMac.tcl
set gaSet(performDgTest) 0
$gaGui(performDgTest) configure -state disabled
update
# ***************************************************************************
# DateTime_Test
# ***************************************************************************
proc DateTime_Test {bar} {
  global gaSet buffer gaGui
  set gaSet(fail) "Logon fail"
  set getBar [$gaGui(entDUT$bar) cget -text]
  set ret [Login $bar]
  if {$ret!=0} {
    set ret [Login $bar]
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
  
  return $ret
}  