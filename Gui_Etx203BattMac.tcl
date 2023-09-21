#***************************************************************************
#** GUI
#***************************************************************************
proc GUI {} {
  global gaSet gaGui glTests  
  
  wm title . "$gaSet(pair) : $gaSet(testedProduct)"
  
  wm protocol . WM_DELETE_WINDOW {Quit}
  wm geometry . $gaGui(xy)
  wm resizable . 0 0
  set descmenu {
    "&File" all file 0 {	 
      {command "Log File"  {} {} {} -command ShowLog}
	    {separator}     
      {cascad "&Console" {} console 0 {
        {checkbutton "console show" {} "Console Show" {} -command "console show" -variable gConsole}  
        {command "Capture Console" cc "Capture Console" {} -command CaptureConsole}
        {command "Find Console" console "Find Console" {} -command {GuiFindConsole}}          
      }
      }
      {separator}
      {command "History" History "" {} \
         -command {
           set cmd [list exec "C:\\Program\ Files\\Internet\ Explorer\\iexplore.exe" [pwd]\\history.html &]
           eval $cmd
         }
      }
      {separator}
      {command "E&xit" exit "Exit" {Alt x} -command {Quit}}
    }
    "&Tools" tools tools 0 {
      {command "Browse java..." tools "Browse java..." {} -command {JavaPath}}  
      {command "COMs mapping" init "" {} -command "ComsMapping"}
      {separator}
      {cascad "User-Password option" {} console 0 {
        {radiobutton "Regular" {} "Regular" {} -command {} -variable gaSet(userPassOpt) -value regular}
        {radiobutton "LT" {} "LT" {} -command {} -variable gaSet(userPassOpt) -value lt}
        {radiobutton "Cellcom" {} "Cellcom" {} -command {} -variable gaSet(userPassOpt) -value cellcom}
        {radiobutton "KOS" {} "KOS" {} -command {} -variable gaSet(userPassOpt) -value kos}
      }
      }

    }
    "&About" all about 0 {
      {command "&About" about "" {} -command {About} 
      }
    }
  }
  
  set mainframe [MainFrame .mainframe -menu $descmenu]
  
  set gaSet(sstatus) [$mainframe addindicator]  
  $gaSet(sstatus) configure -width 74 
  
  set gaSet(statBarShortTest) [$mainframe addindicator]
  
  
  set gaSet(startTime) [$mainframe addindicator]
  
  set gaSet(runTime) [$mainframe addindicator]
  $gaSet(runTime) configure -width 5
  

  set fr3 [frame $mainframe.fr3 -relief groove]
    set fr30 [frame $fr3.fr30 -relief groove -bd 2]
      set l1 [Label $fr30.l1 -text "Choose tested product  "]
      set gaGui(testedProduct) [ComboBox $fr30.testedProduct -textvariable gaSet(testedProduct)\
        -justify center -values [lsort [list ETX203 ASMi54 ETX205 ASMi53 ETX-203AX-E1 ETX2i10G ETX2iB ETX203SHDSLB]] \
        -modifycmd {global gaSet ; source Lib_Put_[set gaSet(testedProduct)]_Etx203BattMac.tcl}]
      pack $l1 $gaGui(testedProduct) -side left  
    pack configure $fr30 -fill x
    set fr32 [TitleFrame $fr3.fr32 -relief groove -bd 2 -text "Partial tests"]
      set fr32f [$fr32 getframe]
      set gaGui(performBattTest) [checkbutton $fr32f.performBattTest -variable gaSet(performBattTest)]
      set l01 [Label $fr32f.l01 -text "Battery Test "]
      
      set gaGui(performMacTest) [checkbutton $fr32f.performMacTest -variable gaSet(performMacTest)]
      set l1 [Label $fr32f.l1 -text "MAC Test "]
      
      set gaGui(performSWTest) [checkbutton $fr32f.performSWTest -variable gaSet(performSWTest) -command TogglePerformSWtest]
      set l2 [Label $fr32f.l2 -text "SW Test "]
      set gaGui(entSwVer) [Entry $fr32f.entSwVer -textvariable gaSet(entSwVer) -width 60]
      
      set gaGui(performCpldTest) [checkbutton $fr32f.performCpldTest -variable gaSet(performCpldTest) -command TogglePerformCpldtest]
      set l3 [Label $fr32f.l3 -text "CPLD Test "]
      set gaGui(entCpldVer) [Entry $fr32f.entCpldVer -textvariable gaSet(entCpldVer) -width 60]
      
      set gaGui(performHWTest) [checkbutton $fr32f.performHWTest -variable gaSet(performHWTest) -command TogglePerformHWtest]
      set l4 [Label $fr32f.l4 -text "HW Test "]
      set gaGui(entHwVer) [Entry $fr32f.entHwVer -textvariable gaSet(entHwVer) -width 60]
      
      set gaGui(performSwDateTest) [checkbutton $fr32f.performSwDateTest -variable gaSet(performSwDateTest) -command TogglePerformSwDateTest]
      set l5 [Label $fr32f.l5 -text "SW's date Test "]
      set gaGui(entSwDate) [Entry $fr32f.entSwDate -textvariable gaSet(entSwDate) -width 60]
      
      set gaGui(performInfoTest) [checkbutton $fr32f.performInfoTest -variable gaSet(performInfoTest) -command TogglePerformInfoTest]
      set l6 [Label $fr32f.l6 -text "Info Test "]
      set gaGui(entInfo) [Entry $fr32f.entInfo -textvariable gaSet(entInfo) -width 60]
      
      set gaGui(insertSerNum) [checkbutton $fr32f.insertSerNum -variable gaSet(insertSerNum) -command {}]
      set l7 [Label $fr32f.l7 -text "Insert Serial Number "]
      
      
      grid $gaGui(performBattTest)   $l01                   -sticky w  
      grid $gaGui(performMacTest)    $l1                    -sticky w 
      grid $gaGui(performSWTest)     $l2 $gaGui(entSwVer)   -sticky w  
      grid $gaGui(performCpldTest)   $l3 $gaGui(entCpldVer) -sticky w 
      grid $gaGui(performHWTest)     $l4 $gaGui(entHwVer)   -sticky w  
      grid $gaGui(performSwDateTest) $l5 $gaGui(entSwDate)  -sticky w 
      grid $gaGui(performInfoTest)   $l6 $gaGui(entInfo)  -sticky w 
      grid $gaGui(insertSerNum)      $l7 -sticky w 
      
    pack configure $fr32 -fill x
    set b1 [radiobutton $fr3.b1 -text "Create new log" -variable gaSet(logType) \
        -value new -command CreateNewLog]
    set b2 [radiobutton $fr3.b2 -text "Append to existing log"  -variable gaSet(logType) \
        -value old -command ChooseExistLog]    
    set fr31 [frame $fr3.fr31]    
      set l1 [Label $fr31.l1 -textvariable gaSet(log) -relief sunken]
      bind $l1 <Double-1> {ShowLog}
      set b3 [Button $fr31.b3 -text "Open log" -command ShowLog]
      pack configure $l1 -fill x -expand 1
      pack $l1 $b3  -side left -padx 2 -pady 2
      pack configure $b3 -anchor e
      pack $b1 $b2 $fr31 -padx 2 -pady 2 -anchor w
    pack configure $fr31 -fill x 
  pack $fr3 -padx 2 -pady 2 -fill both
     
    set frDUT [frame $mainframe.frDUT -bd 2 -relief groove] 
      for {set ba 1} {$ba <= $gaSet(maxMultiQty)} {incr ba} {
        set labDUT$ba [Label $frDUT.labDUT$ba -text "UUT's $ba barcode" -width 15]
        set gaGui(entDUT$ba) [Entry $frDUT.entDUT$ba -bd 1 -justify center -width 60\
            -editable 1 -relief groove -textvariable gaSet(entDUT$ba) -command [list ScanUutBarcode $ba]\
            -helptext "Scan a barcode here" -fg SystemWindowText -font {{TkTextFont} 10 bold}]
        set gaGui(clrDut$ba) [Button $frDUT.clrDut$ba -image [image create photo -file  images/clear1.ico] \
            -takefocus 1 \
            -command "
                global gaSet gaGui
                set gaSet(entDUT$ba) \"\"
                $gaGui(entDUT$ba) configure -bg SystemWindow -fg SystemWindowText
                focus -force $gaGui(entDUT$ba)
                
            "]         
        grid [set labDUT$ba] [set gaGui(entDUT$ba)] [set gaGui(clrDut$ba)] -sticky w -padx 2
      } 
#     set frTestPerf [TitleFrame $mainframe.frTestPerf -bd 2 -relief groove \
#         -text "Test Performance"] 
#       set f [$frTestPerf getframe]      17/09/2014 16:26:46
    set frTestPerf [frame $mainframe.frTestPerf -bd 2 -relief groove]     
      set f $frTestPerf
      set frCur [frame $f.frCur]  
        set labCur [Label $frCur.labCur -text "Current Test  " -width 13]
        set gaGui(curTest) [Entry $frCur.curTest -bd 1 \
            -editable 0 -relief groove -textvariable gaSet(curTest) \
	       -justify center -width 50]
        pack $labCur $gaGui(curTest) -padx 7 -pady 1 -side left -fill x;# -expand 1 
      pack $frCur  -anchor w
      #set frStatus [frame $f.frStatus]
      #  set labStatus [Label $frStatus.labStatus -text "Status  " -width 12]
      #  set gaGui(labStatus) [Entry $frStatus.entStatus \
            -bd 1 -editable 0 -relief groove \
	   -textvariable gaSet(status) -justify center -width 58]
      #  pack $labStatus $gaGui(labStatus) -fill x -padx 7 -pady 3 -side left;# -expand 1 	 
      #pack $frStatus -anchor w
      set frFail [frame $f.frFail]
      set gaGui(frFailStatus) $frFail
        set labFail [Label $frFail.labFail -text "Fail Reason  " -width 12]
        set labFailStatus [Entry $frFail.labFailStatus \
            -bd 1 -editable 1 -relief groove \
            -textvariable gaSet(fail) -justify center -width 75]
      pack $labFail $labFailStatus -fill x -padx 7 -pady 3 -side left; # -expand 1	
      #pack $gaGui(frFailStatus) -anchor w
      
      
  
    pack $frDUT  -fill both -expand yes -padx 2 -pady 2 -anchor nw	 
  pack $mainframe -fill both -expand yes

  console eval {.console config -height 14 -width 92}
  console eval {set ::tk::console::maxLines 10000}
  console eval {.console config -font {Verdana 10}}
  focus -force .
  bind . <F1> {console show}

  bind . <Alt-r> {ButRun}
  bind . <Alt-s> {ButStop}

  TogglePerformSWtest
  TogglePerformCpldtest
  TogglePerformHWtest
  TogglePerformSwDateTest
  TogglePerformInfoTest


#   RLStatus::Show -msg atp
#   RLStatus::Show -msg fti
   set gaSet(entDUT1) ""
  focus -force $gaGui(entDUT1)
  
}
# ***************************************************************************
# About
# ***************************************************************************
proc About {} {
  if [file exists history.html] {
    set id [open history.html r]
    set hist [read $id]
    close $id
    regsub -all -- {<[\w\=\#\d\s\"\/]+>} $hist "" a
    regexp {<!---->\s+Changes\s+([\d\.]+).+<!---->} $a m date
  } else {
    set date 14.11.2016 
  }
  tk_messageBox -parent . -type ok -message "The software version: $date" -title "SW version" 
}
proc ButStop {} {
  global gaSet
  set gaSet(act) 0
}

#***************************************************************************
#** Quit
#***************************************************************************
proc Quit {} {
  global gaSet
  SaveInit
  RLSound::Play information
  set ret [DialogBox -title "Confirm exit"\
      -type "yes no" -icon images/question -aspect 2000\
      -text "Are you sure you want to close the application?"]
  if {$ret=="yes"} {exit}
}
# ***************************************************************************
# ShowComs
# ***************************************************************************
proc ShowComs {} {                                                                        
  global gaSet gaGui
  set txt  ""
  for {set ba 1} {$ba<=$gaSet(maxMultiQty)} {incr ba} {
    append txt "UUT's $ba COM number: $gaSet(comDut$ba)\n"  
  }
  DialogBox -title "COMs definitions" -type OK -message "$txt"
  return {}
}
# ***************************************************************************
# ComsMapping
# ***************************************************************************
proc ComsMapping {} {
  global gaSet gaGui  gaTmpSet
  
  if [winfo exists .topHwInit] {
    wm deiconify .topHwInit
    wm deiconify .
    wm deiconify .topHwInit
    return {}
  }
  
  set base .topHwInit
  toplevel $base -class Toplevel
  wm focusmodel $base passive
  wm geometry $base $gaGui(xy)
  wm resizable $base 0 0
  wm title $base "Coms Mapping"
  
  array unset gaTmpSet
  set txt  ""
  for {set ba 1} {$ba<=$gaSet(maxMultiQty)} {incr ba} {
    if ![info exists gaSet(comDut$ba)] {
      set gaSet(comDut$ba) 1
    }
    set gaTmpSet(comDut$ba) $gaSet(comDut$ba)
  }
  set frA [frame $base.frA -bd 2 -relief groove]
  for {set ba 1} {$ba<=$gaSet(maxMultiQty)} {incr ba} {
    set fr [frame $frA.fr$ba -bd 2 -relief groove]
      pack [Label $fr.lab  -text "UUT's $ba COM number:" ] -pady 1 -padx 2 -anchor w -side left
      pack [Entry $fr.cb -justify center -width 5 -editable 1 -textvariable gaTmpSet(comDut$ba)] -pady 1 -padx 2 -anchor w -side left
    pack $fr  -anchor w
  }
  pack $frA
  pack [Separator $base.sep1 -orient horizontal] -fill x -padx 2 -pady 3
  pack [frame $base.frBut ] -pady 4 -anchor e
    pack [ttk::button $base.frBut.butCanc -text Cancel -command ButCancComs -width 7] -side right -padx 6
    pack [ttk::button $base.frBut.butOk -text Ok -command ButOkComs -width 7]  -side right -padx 6
  
  focus -force $base
  grab $base
  return {}
}
# ***************************************************************************
# ButCancComs
# ***************************************************************************
proc ButCancComs {} {
  grab release .topHwInit
  focus .
  destroy .topHwInit
}
# ***************************************************************************
# ButOkComs
# ***************************************************************************
proc ButOkComs {} {
  global gaSet gaTmpSet
  foreach nam [array names gaTmpSet] {
    if {$gaTmpSet($nam)!=$gaSet($nam)} {
      puts "ButOkInventory2 $nam tmp:$gaTmpSet($nam) set:$gaSet($nam)"
      set gaSet($nam) $gaTmpSet($nam)      
    }  
  }
  SaveInit
  ButCancComs
}  
# ***************************************************************************
# TogglePerformSWtest
# ***************************************************************************
proc TogglePerformSWtest {} {
  global gaGui gaSet
  if {[winfo exists $gaGui(performSWTest)] && [info exists gaSet(performSWTest)] && \
      [winfo exists $gaGui(entSwVer)] && [info exists gaSet(entSwVer)]} {
    if {$gaSet(performSWTest)==1} {
      $gaGui(entSwVer) configure -state normal
    } elseif {$gaSet(performSWTest)==0} {
      $gaGui(entSwVer) configure -state disabled
    } 
  }
}

# ***************************************************************************
# TogglePerformCpldtest
# ***************************************************************************
proc TogglePerformCpldtest {} {
  global gaGui gaSet
  if {[winfo exists $gaGui(performCpldTest)] && [info exists gaSet(performCpldTest)] && \
      [winfo exists $gaGui(entCpldVer)] && [info exists gaSet(entCpldVer)]} {
    if {$gaSet(performCpldTest)==1} {
      $gaGui(entCpldVer) configure -state normal
    } elseif {$gaSet(performCpldTest)==0} {
      $gaGui(entCpldVer) configure -state disabled
    } 
  }
}
# ***************************************************************************
# TogglePerformHWtest
# ***************************************************************************
proc TogglePerformHWtest {} {
  global gaGui gaSet
  if {[winfo exists $gaGui(performHWTest)] && [info exists gaSet(performHWTest)] && \
      [winfo exists $gaGui(entHwVer)] && [info exists gaSet(entHwVer)]} {
    if {$gaSet(performHWTest)==1} {
      $gaGui(entHwVer) configure -state normal
    } elseif {$gaSet(performHWTest)==0} {
      $gaGui(entHwVer) configure -state disabled
    } 
  }
}
# ***************************************************************************
# TogglePerformSwDateTest
# ***************************************************************************
proc TogglePerformSwDateTest {} {
  global gaGui gaSet
  if {[winfo exists $gaGui(performSwDateTest)] && [info exists gaSet(performSwDateTest)] && \
      [winfo exists $gaGui(entSwDate)] && [info exists gaSet(entSwDate)]} {
    if {$gaSet(performSwDateTest)==1} {
      $gaGui(entSwDate) configure -state normal
    } elseif {$gaSet(performSwDateTest)==0} {
      $gaGui(entSwDate) configure -state disabled
    } 
  }
}

# ***************************************************************************
# TogglePerformInfoTest
# ***************************************************************************
proc TogglePerformInfoTest {} {
  global gaGui gaSet
  if {[winfo exists $gaGui(performInfoTest)] && [info exists gaSet(performInfoTest)] && \
      [winfo exists $gaGui(entInfo)] && [info exists gaSet(entInfo)]} {
    if {$gaSet(performInfoTest)==1} {
      $gaGui(entInfo) configure -state normal
    } elseif {$gaSet(performInfoTest)==0} {
      $gaGui(entInfo) configure -state disabled
    } 
  }
}
# ***************************************************************************
# ToggleInsertSerNum
# ***************************************************************************
proc ToggleInsertSerNum {} {
  global gaGui gaSet  
}

# ***************************************************************************
# GuiGetSerNum
# ***************************************************************************
proc GuiGetSerNum {} {
  global gaSet gaGui glTests  
  
  set base .topGetSerNum
  if [winfo exists $base] {
    wm deiconify $base
    wm deiconify .
    wm deiconify $base
    return {}
  }
  
  toplevel $base -class Toplevel
  wm focusmodel $base passive
  wm protocol $base WM_DELETE_WINDOW {DialogBox -title "wrong" -message "start again"; destroy .topGetSerNum}
  wm geometry $base +[expr {150+[winfo x .]}]+[expr {20+[winfo y .]}]
  wm resizable $base 0 0
  wm title $base "Get Serial Numbers"
  
  set fr1 [frame $base.fr1  -bd 2 -relief groove]
    set frDUT [frame $fr1.frDUT -bd 2 -relief groove] 
      for {set ba 1} {$ba <= $gaSet(maxMultiQty)} {incr ba} {
        set gaSet(entSN$ba) ""
        set labSN$ba [Label $frDUT.labSN$ba -text "UUT's $ba Serial Number" -width 19]
        set gaGui(entSN$ba) [Entry $frDUT.entSN$ba -bd 1 -justify center -width 15\
            -editable 1 -relief groove -textvariable gaSet(entSN$ba) -command [list ScanUutSN $ba]\
            -helptext "Scan a barcode here" -fg SystemWindowText -font {{TkTextFont} 10 bold}]
        grid [set labSN$ba] [set gaGui(entSN$ba)] -sticky w -padx 2
        
        if {$gaSet(entDUT$ba)==""} {
          $gaGui(entSN$ba) configure -state disabled -takefocus 0
        } else {
          $gaGui(entSN$ba) configure -state normal -takefocus 1
          focus -force $gaGui(entSN$ba)
        }
      } 
    pack $frDUT  -fill both -expand yes -padx 2 -pady 2 -anchor nw
    
    set frClearSN [frame $fr1.frClearSN -bd 2 -relief groove] 
      set gaGui(butClrSN) [Button $frClearSN.b1 -text "Clear SN on UUT/s" -command ClearSNs]
      pack $gaGui(butClrSN) -padx 2 -pady 2 -anchor w	 
    pack $frClearSN  -fill both -expand yes -padx 2 -pady 2 -anchor nw
  pack $fr1 -fill both -expand yes
}
# ***************************************************************************
# ClearSNs
# ***************************************************************************
proc ClearSNs {} {
  global gaSet gaGui
  set res [DialogBox -title Warning -message "Are you sure you want to delete Serial Numbers?" \
     -type "Yes No" -parent .topGetSerNum]
  if {$res=="No"} {return {}}   
  for {set bar 1} {$bar <= $gaSet(maxMultiQty)} {incr bar} {
    if {$gaSet(entDUT$bar)!=""} {
      set gaSet(entSN$bar) "0000000000"
    }  
  }
  ScanUutSN 4  
}
#***************************************************************************
#** CaptureConsole
#***************************************************************************
proc CaptureConsole {} {
  global gaSet
  
  console eval { 
    global gaSet
    set ti [clock format [clock seconds] -format  "%Y.%m.%d_%H.%M.%S"]
    if ![file exists c:/temp] {
      file mkdir c:/temp
      after 1000
    }
    set fi c:\\temp\\ConsoleCapt_[set ti].txt
    if [file exists $fi] {
      set res [tk_messageBox -title "Save Console Content" \
        -icon info -type yesno \
        -message "File $fi already exist.\n\
               Do you want overwrite it?"]      
      if {$res=="no"} {
         set types { {{Text Files} {.txt}} }
         set new [tk_getSaveFile -defaultextension txt \
                 -initialdir c:\\ -initialfile [file rootname $fi]  \
                 -filetypes $types]
         if {$new==""} {return {}}
      }
    }
    set aa [.console get 1.0 end]
    set id [open $fi w]
    puts $id $aa
    close $id
  }
}

