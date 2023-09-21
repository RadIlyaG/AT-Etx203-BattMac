# ***************************************************************************
# CheckUpdates
# ***************************************************************************
proc CheckUpdates {tdsPath reopenPath} {
  global gaSet 
  set fileL [list]
  set updFileL [list]
  set newestFileL [list]
  set newestNamesL [list]
#   puts "tdsPath:<$tdsPath>"
#   puts "reopenPath:<$reopenPath>"
#   update
  if ![file exists $tdsPath] {return 0}
  foreach fi [glob -directory $tdsPath *.*] {
    if ![file exists [pwd]/[file tail $fi]] {
      set mtimLoc 0
    } else {
      set mtimLoc  [file mtime [pwd]/[file tail $fi]]
    }
    set mtimLocF [clock format $mtimLoc -format "%Y.%m.%d-%H.%M.%S"]
    set mtieTds [file mtime $fi]
    set mtieTdsF [clock format $mtieTds -format "%Y.%m.%d-%H.%M.%S"]
    if {$mtimLoc < $mtieTds}  {
      lappend fileL $fi [pwd]
      lappend updFileL [file tail $fi]
      puts "ok $fi $mtimLocF $mtieTdsF $mtimLoc $mtieTds"
    } elseif {$mtimLoc > $mtieTds}  {
      lappend newestFileL $fi [pwd]
      lappend newestNamesL [file tail $fi]
      puts "not ok $fi loc:$mtimLocF tds:$mtieTdsF $mtimLoc $mtieTds"
    }
  }
  
  ##  
  if {[llength $newestNamesL]>0} {
    console show; update
    set mess "The following file/s in TDS is/are older then in the PC:\r"
    foreach fi $newestNamesL {
      append mess "\r$fi"
    }
    append mess "\r\r Please inform the ATE Team person"
    set res [DialogBox  -aspect 2150 -parent . -title "Copy Updates' fail" \
        -message $mess -type [list Exit Continue]] ; # type [list Exit "Avoid exit"]
    #if {[info host] ne "ilya-g-hp-w10"} {}
    if 1 {
      if {$res eq "Exit"} {
        exit
      } elseif {$res eq "Avoid exit"} {
        after 100 {focus .passwd.frame.labpass.e}
        set lp [PasswdDlg .passwd -parent . -logintext ate]
        
        set login [lindex $lp 0]
        set pw    [lindex $lp 1]
        if {($login ne "ate") || (($pw ne "AvoidExit") && ($pw ne "avoidexit") && ($pw ne "ae"))} {
          RLSound::Play information
          DialogBox -icon error -title "Access denied" \
              -message "The Login or Password isn't correct"  -type Ok
          exit
        } else {
          ## Login and Password are correct
        }
      } elseif {$res eq "Continue"} {
        ## continue
      }
    }
    
  }
  
  if {[llength $fileL]>0} {
    set ret [CopyUpdates $fileL]
    if {$ret==0} {
      set gaSet(updatesLogPath) c:\\logs\\updates.txt
      if ![file exists $gaSet(updatesLogPath)] {
        ::fileutil::writeFile $gaSet(updatesLogPath) \r
      }
      set id [open $gaSet(updatesLogPath) a]
      puts $id "[clock format [clock seconds] -format "%Y.%m.%d-%H.%M.%S"] Updated files: $updFileL"
      close $id
      after 1000 exit
      
      ## reopen
      eval exec [info nameofexecutable] $reopenPath &
    }
  } else {
    set ret 0
  }
  return $ret
}
# ***************************************************************************
# CopyUpdates
# ***************************************************************************
proc CopyUpdates {fileL} {
  set ret 0
  wm iconify .
  update
  message .popup -text "Update in progress. Please wait"
  foreach {s d} $fileL {
    if [catch {file copy -force $s $d} res] {
      catch {destroy .popup}
      tk_messageBox -title "Copy Updates' fail" -message $res -type ok
      set ret -1
      break
    }
  } 
  
  catch {destroy .popup} 
  return $ret
}
