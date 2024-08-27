# ***************************************************************************
# ScanUutBarcode
# ***************************************************************************
proc ScanUutBarcode {ba} {
  global gaSet gaDBox  gaGui
  console eval {.console delete 1.0 end}
  console eval {set ::tk::console::maxLines 100000}
  update
  puts "ScanUutBarcode $ba"; update
  set gaSet(act) 1
  Power all on
  
  for {set i 1} {$i<=$gaSet(maxMultiQty)} {incr i} {
    $gaGui(entDUT$i) configure -bg SystemWindow -fg SystemWindowText -text [string toupper [$gaGui(entDUT$i) cget -text]]
  }
  if {$ba==4} {
    focus -force $gaGui(entDUT1)
    #console eval {.console delete 1.0 end}
    
    for {set i 1} {$i<=$gaSet(maxMultiQty)} {incr i} {
      set barc $gaSet(entDUT$i)
      if {([string length $barc] ne 11) && ([string length $barc] ne 12)} {
        if {[string length $barc] eq 0} {
          puts "$i is empty entry"
          if {$i=="4"} {
            DialogBox -title "Wrong ID barcode" -message "UUT's 4 barcode can't be empty" -type Ok
            return -1  
          }
        } else {
          DialogBox -title "Wrong ID barcode" -message "$barc is not legal ($i)" -type Ok
          return -1
        }
        
      }
    }
    
    set entSwVer [set gaSet(entSwVer) [string trim $gaSet(entSwVer)]] ; puts "entSwVer:<$entSwVer>"
    if {$gaSet(performSWTest)=="1" && $entSwVer==""} {
      set txt  "No SW version was defined"
      #$gaGui(entDUT$bar) configure -bg red -text $txt 
      #AddToLog $txt
      set res [DialogBox -text $txt -icon /images/error.gif -title "SW verification"]
      return -1  
    }
    
    set entCpldVer [set gaSet(entCpldVer) [string trim $gaSet(entCpldVer)]] ; puts "entCpldVer:<$entCpldVer>"
    switch -exact -- $gaSet(testedProduct) {
      ETX2i10G - ETX2iB {set gaSet(performCpldTest) 0; TogglePerformCpldtest}
      default { ## do not change}
    }
      
    if {$gaSet(performCpldTest)=="1" && $entCpldVer==""} {
      set txt  "No CPLD version was defined"
      #$gaGui(entDUT$bar) configure -bg red -text $txt 
      #AddToLog $txt
      set res [DialogBox -text $txt -icon /images/error.gif -title "CPLD verification"]
      return -1  
    }
    
    set entHwVer [set gaSet(entHwVer) [string trim $gaSet(entHwVer)]] ; puts "entHwVer:<$entHwVer>"
    if {$gaSet(performHWTest)=="1" && $entHwVer==""} {
      set txt  "No HW version was defined"
      #$gaGui(entDUT$bar) configure -bg red -text $txt 
      #AddToLog $txt
      set res [DialogBox -text $txt -icon /images/error.gif -title "HW verification"]
      return -1  
    }
    
    set entSwDate [set gaSet(entSwDate) [string trim $gaSet(entSwDate)]] ; puts "entSwDate:<$entSwDate>"
    switch -exact -- $gaSet(testedProduct) {
      ETX203 {## do not change}
      ASMi53  - ASMi54 - ETX205 {set gaSet(performSwDateTest) 0; TogglePerformSwDateTest}
    }
    if {$gaSet(performSwDateTest)=="1" && $entSwDate==""} {
      set txt  "No SW's date was defined"
      #$gaGui(entDUT$bar) configure -bg red -text $txt 
      #AddToLog $txt
      set res [DialogBox -text $txt -icon /images/error.gif -title "SW's date verification"]
      return -1  
    }
    
    set entInfo [set gaSet(entInfo) [string trim $gaSet(entInfo)]] ; puts "entInfo:<$entInfo>"
    switch -exact -- $gaSet(testedProduct) {
      ETX203 - ETX2i10G - ETX2iB {## do not change}
      default {set gaSet(performInfoTest) 0; TogglePerformInfoTest}
    }
    if {$gaSet(performInfoTest)=="1" && $entInfo==""} {
      set txt  "No Info was defined"
      #$gaGui(entDUT$bar) configure -bg red -text $txt 
      #AddToLog $txt
      set res [DialogBox -text $txt -icon /images/error.gif -title "Info verification"]
      return -1  
    }
    
    switch -exact -- $gaSet(testedProduct) {
      ETX203 - ETX2i10G - ETX2iB - ETX205 {
        set ret [GetDbrName]
        puts "\n Ret of GetDbrName: <$ret>"
        if {$ret != 0} {
          set res [DialogBox -text "Problem to get the DBR Name:\n$ret" -icon /images/error.gif -title "Get DBR Name"]
          return -1  
        }
        puts "DutFullName: $gaSet(DutFullName)"
        
        ## 08:27 20/02/2022 'stam' should be replaced by Menashe+MeirKa+Ronen's options
        if [string match *stam* $gaSet(DutFullName)] {
          set gaSet(insertSerNum) 1
        } else {
          ## don't change the user's choice
        }
      }
      default {set gaSet(insertSerNum) 0; ToggleInsertSerNum}
    }
    set getSerNm 0
    puts "gaSet(insertSerNum):$gaSet(insertSerNum)"
    if {$gaSet(insertSerNum)==1} {
      set getSerNm 1
    } else {
      set gaSet(insertSerNum) 0
      
#       01/02/2021 11:15:52
#       set ret [GetDbrName]
#       if {$ret!=0} {return $ret}
#       puts "gaSet(DutFullName):<$gaSet(DutFullName)>" ; update
#       if {[string match *LY* $gaSet(DutFullName)]} {
#         set getSerNm 1
#         set gaSet(insertSerNum) 1
#       }
    }
    if $getSerNm {
      set ::x 0
      puts [MyTime]; update
      GuiGetSerNum
      puts [MyTime]; update
      vwait ::x 
      puts [MyTime]; update
      for {set barco 1} {$barco <= $gaSet(maxMultiQty)} {incr barco} { 
        if {($gaSet(entDUT$barco)=="" && $gaSet(entSN$barco)=="") ||\
            ($gaSet(entDUT$barco)!="" && $gaSet(entSN$barco)!="")} {
          ## all OK          
        } else {
          set txt  "Wrong Serial Numbers"
          set res [DialogBox -text $txt -icon /images/error.gif -title "Serial Numbers"]
          return -1  
        } 
      }
    }
    
    
    for {set bar 1} {$bar <= $gaSet(maxMultiQty)} {incr bar} {   
      set gaSet($bar.dbrMac) Mac
      set gaSet($bar.dutMac) Mac 
      set barc $gaSet(entDUT$bar)
      set gaSet(ButRunTime) [clock seconds]
      puts "\n[MyTime] .. ScanUutBarcode ba:$ba bar:$bar barc:$barc"
      if {$barc==""} {continue}
      if {[string length $barc] ne "11" && [string length $barc] ne "12"} {set ret 0; continue}
      AddToLog ""
      if {$gaSet(performMacTest)==1} {
        set ret [CheckMac $bar]
      } else {
        set ret 0
      }  
      if {$ret==0} {
        catch {RLEH::Close}
        catch {RLSerial::Close $gaSet(comDut$bar)}
        after 200      
        RLEH::Open
        switch -exact -- $gaSet(testedProduct) {
          ETX203 - ASMi54 - ETX205 - ETX-203AX-E1 - ETX2i10G - ETX2iB - ETX203SHDSLB {RLSerial::Open $gaSet(comDut$bar) 9600 n 8 1}
          ASMi53 {RLSerial::Open $gaSet(comDut$bar) 115200 n 8 1}
        }
        set ret [DateTime_Test $bar]
        
        if {$ret==0} {
          if {$gaSet(performMacTest)==1} {
            set ret [ReadMac $bar]
          } else {
            set ret 0
          }  
          if {$ret==0} {
            if {$gaSet($bar.dbrMac)!=$gaSet($bar.dutMac)} {
              set txt  "$barc. DBR MAC:$gaSet($bar.dbrMac), UUT MAC:$gaSet($bar.dutMac)"
              $gaGui(entDUT$bar) configure -bg red -text $txt 
              AddToLog $txt
              set ret -1
            }
          } else {
            $gaGui(entDUT$bar) configure -bg red -text "$gaSet(fail)" 
          }
        }
        
        if {$ret==0} {
          if {$gaSet(performSWTest)==1} {
            set ret [ReadSWver $bar]
            if {$ret==0} {
              if {$gaSet(entSwVer)!=$gaSet(dutSwVer)} {
                set txt  "$barc. UUT's SW is $gaSet(dutSwVer). Should be $gaSet(entSwVer)"
                $gaGui(entDUT$bar) configure -bg red -text $txt 
                AddToLog $txt
                set ret -1
              } else {
                set txt  "$barc. SW: $gaSet(dutSwVer)"
                AddToLog $txt
              }
            } else {
              $gaGui(entDUT$bar) configure -bg red -text "$gaSet(fail)" 
            }
          } else {
            set ret 0
          }  
        }
        
        if {$ret==0} {
          if {$gaSet(performCpldTest)==1} {
            set ret [ReadCpldver $bar]
            if {$ret==0} {
              if {$gaSet(entCpldVer)!=$gaSet(dutCpldVer)} {
                set txt  "$barc. UUT's CPLD is $gaSet(dutCpldVer). Should be $gaSet(entCpldVer)"
                $gaGui(entDUT$bar) configure -bg red -text $txt 
                AddToLog $txt
                set ret -1
              } else {
                set txt  "$barc. CPLD: $gaSet(dutCpldVer)"
                AddToLog $txt
              }
            } else {
              $gaGui(entDUT$bar) configure -bg red -text "$gaSet(fail)" 
            }
          } else {
            set ret 0
          }  
        }
        
        if {$ret==0} {
          if {$gaSet(performHWTest)==1} {
            set ret [ReadHWver $bar]
            if {$ret==0} {
              if {$gaSet(entHwVer)!=$gaSet(dutHwVer)} {
                set txt  "$barc. UUT's HW is $gaSet(dutHwVer). Should be $gaSet(entHwVer)"
                $gaGui(entDUT$bar) configure -bg red -text $txt 
                AddToLog $txt
                set ret -1
              } else {
                set txt  "$barc. HW: $gaSet(dutHwVer)"
                AddToLog $txt
              }
            } else {
              $gaGui(entDUT$bar) configure -bg red -text "$gaSet(fail)" 
            }
          } else {
            set ret 0
          }  
        }
        
        if {$ret==0} {
          if {($gaSet(testedProduct)=="ETX203" || $gaSet(testedProduct)=="ETX2i10G"  || $gaSet(testedProduct)=="ETX2iB" ) && $gaSet(performSwDateTest)==1} {
            set ret [ReadSwDate $bar]
            if {$ret==0} {
              if {$gaSet(entSwDate)!=$gaSet(dutSwDate)} {
                set txt  "$barc. UUT SW's date is $gaSet(dutSwDate). Should be $gaSet(entSwDate)"
                $gaGui(entDUT$bar) configure -bg red -text $txt 
                AddToLog $txt
                set ret -1
              } else {
                set txt  "$barc. SW's date: $gaSet(dutSwDate)"
                AddToLog $txt
              }
            } else {
              $gaGui(entDUT$bar) configure -bg red -text "$gaSet(fail)" 
            }
          } else {
            set ret 0
          }  
        }
        
        if {$ret==0} {
          if {($gaSet(testedProduct)=="ETX203" || $gaSet(testedProduct)=="ETX2i10G"  || $gaSet(testedProduct)=="ETX2iB" ) && $gaSet(performInfoTest)==1} {
            set ret [ReadInfo $bar]
            if {$ret=="0"} {
              set txt  "$barc. \'$gaSet(entInfo)\' found"
              AddToLog $txt
            } else {
              $gaGui(entDUT$bar) configure -bg red -text "$barc. $gaSet(fail)" 
              AddToLog $gaSet(fail)
              set ret -1
            }
          } else {
            set ret 0
          }  
        }
        
        if {$ret==0} {
          if {$gaSet(insertSerNum)==1} {
            set ret [InsertSerNum $bar]
            if {$ret=="0"} {
              set txt  "$barc. \'$gaSet(dutSerNum)\' found"
              AddToLog $txt
            } else {
              $gaGui(entDUT$bar) configure -bg red -text "$barc. $gaSet(fail)" 
              AddToLog $gaSet(fail)
              set ret -1
            }
          } else {
            set ret 0
          }  
        }
        
        if {$ret==0} {
          if {$gaSet(performDgTest)==1} {
            set ret [DyingGasp $bar]
            if {$ret=="0"} {
              set txt  "$barc. \'DyingGasp\' found in report"
              AddToLog $txt
            } else {
              $gaGui(entDUT$bar) configure -bg red -text "$barc. $gaSet(fail)" 
              AddToLog $gaSet(fail)
              set ret -1
            }
          } else {
            set ret 0
          }  
        }
        
        catch {RLSerial::Close $gaSet(comDut$bar)}
        catch {RLEH::Close}
      } else {
        $gaGui(entDUT$bar) configure -bg red -text "$barc. No MAC" 
      }
        
      if {$ret==0} {
        $gaGui(entDUT$bar) configure -bg green -fg SystemWindowText -text "$barc. PASS"  
        RLSound::Play pass$bar
        set gaSet(runStatus) "Pass"
        set gaSet(fail) ""
      } else {
        $gaGui(entDUT$bar) configure -bg red -fg yellow
        RLSound::Play fail$bar
        set gaSet(runStatus) "Fail"
        set gaSet(fail) [lrange [split [$gaGui(entDUT$bar) cget -text] " "] 1 end]
      }
      
      SQliteAddLine $barc
      puts "[MyTime] .. ScanUutBarcodeUUUT-$bar ret:$ret" ; 
      Delayms 1000; #1500
      if {$bar==4} {
        focus -force $gaGui(entDUT1)
        $gaGui(entDUT1) selection range 0 end
      }  
    }
  } else {
    $gaGui(entDUT$ba) configure -bg SystemWindow  -fg SystemWindowText
    set next [expr { 1 + $ba}]
    #$gaGui(entDUT$next) selection range 0 end
    $gaGui(entDUT$next) configure -bg SystemWindow -text ""  -fg SystemWindowText
    focus -force $gaGui(entDUT$next)
    Status "Read ID barcode in $next UUT"
    set ret 0
  }
  return {}
}

# ***************************************************************************
# ScanUutSN
# ***************************************************************************
proc ScanUutSN {ba} {
  global gaSet gaDBox  gaGui
  set gaSet(act) 1
  #console eval {.console delete 1.0 end}
  #puts "ScanUutSN $ba"; update
  Status "Read Serial Number of UUT-$ba"
  set lSNs [list ]
  if {$ba==4} {
    set sn [$gaGui(entSN$ba) cget -text]
    puts "UUT-$ba SN: $sn"
    if {([string length $sn] ne 10) || (![string is digit $sn])} {
      set txt "Serial Number $ba ($sn) is wrong"
      DialogBox -title "Wrong SN" -type Ok -message $txt -parent .topGetSerNum -place below
      after 100
      $gaGui(entSN$ba) selection range 0 end
      #wm deiconify .topGetSerNum
      raise .topGetSerNum
      focus -force $gaGui(entSN$ba)
      #update
      return -1
    } 
     
    for {set bar 1} {$bar <= $gaSet(maxMultiQty)} {incr bar} {
      if {$gaSet(entSN$bar)!=""} {
        lappend lSNs $gaSet(entSN$bar)
      }  
    }
    puts "[MyTime] lSNs:<$lSNs>" ; update
    
    if {[llength $lSNs] != [llength [lsort -unique $lSNs] ]} {
      if {[llength [lsort -unique $lSNs]] eq "1" && [lindex $lSNs 0] eq "0000000000"} {
        puts "it's clear, it's OK"
        destroy .topGetSerNum
        set ::x 1 
      } else {
        set txt "Serial Numbers are not unique!"
        DialogBox -title "Wrong SN" -type Ok -message $txt -parent .topGetSerNum -place below
        after 100
        $gaGui(entSN$ba) selection range 0 end
        raise .topGetSerNum
        return -1
      }
    } else {
      destroy .topGetSerNum
      set ::x 1  
    }
    set ret 0
    
  } else {
    $gaGui(entSN$ba) configure -bg SystemWindow  -fg SystemWindowText
    set sn [$gaGui(entSN$ba) cget -text]
    puts "UUT-$ba SN: $sn"
    if {([string length $sn] ne 10) || (![string is digit $sn])} {
      set txt "Serial Number $ba ($sn) is wrong"
      DialogBox -title "Wrong SN" -type Ok -message $txt
      after 100
      $gaGui(entSN$ba) selection range 0 end
      raise .topGetSerNum
      focus -force $gaGui(entSN$ba)
      update
      return -1
    } 
    
    for {set i $ba} {$i < $gaSet(maxMultiQty)} {incr i} {
      set next [expr { 1 + $i}]  
      puts "i:$i next:$next gaSet(entDUT$next):<$gaSet(entDUT$next)>"; update
      if {$gaSet(entDUT$next)!=""} {
        break
      }  
    }
    $gaGui(entSN$next) configure -bg SystemWindow -text ""  -fg SystemWindowText
    focus -force $gaGui(entSN$next)
    #Status "Read Serial Number of $next UUT"
    if {$next eq "4" && $gaSet(entDUT$next) eq ""} {
      destroy .topGetSerNum
      set ::x 1 
    }
    set ret 0
  }  
}
# ***************************************************************************
# InsertSerNum
# ***************************************************************************
proc InsertSerNum {bar} {
  global gaSet buffer gaLocal
  puts "\n[MyTime] InsertSerNum $bar"; update
  set ret 0
  set com $gaSet(comDut$bar)
  set ret [VerifySN $bar]
  if {$ret!=0} {
    set ret [Send $com "exit all\r" $gaSet(prompt)]
    if {$ret!=0} {
      set ret [Send $com "exit all\r" $gaSet(prompt)]
      if {$ret!=0} {return $ret}
    }  
    set ret [EntryBootMenu $bar]
    if {$ret!=0} {return $ret}   
    set ret [WritePage0 $bar]
    if {$ret!=0} {return $ret} 
    set ret [AdminFactAll $bar]
    if {$ret!=0} {return $ret} 
    set ret [VerifySN $bar]
    if {$ret!=0} {return $ret}
  }
  return $ret
}
