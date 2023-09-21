set pair [lindex $argv 0]
set gaSet(pair) $pair

switch -exact -- $gaSet(pair) {
  1 {
      console eval {wm geometry . +150+1}
      console eval {wm title . "Con 1"}   
  }
  2 {
      console eval {wm geometry . +150+200}
      console eval {wm title . "Con 2"}
  }
  3 {
      console eval {wm geometry . +150+400}
      console eval {wm title . "Con 3"}
  }
  4 {
      console eval {wm geometry . +150+600}
      console eval {wm title . "Con 4"}
  }
}  

source lib_PackSour_Etx203BattMac.tcl
