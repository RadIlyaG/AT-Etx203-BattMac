#***************************************************************************
#** MyTime
#***************************************************************************
proc MyTime {} {
  return [clock format [clock seconds] -format "%Y.%m.%d-%H.%M.%S"]
}

#***************************************************************************
#** Send
#** #set ret [RLCom::SendSlow $com $toCom 150 buffer $fromCom $timeOut]
#** #set ret [Send$com $toCom buffer $fromCom $timeOut]
#** 
#***************************************************************************
proc Send {com sent expected {timeOut 8}} {
  global buffer gaSet
  if {$gaSet(act)==0} {return -2}

  #puts "sent:<$sent>"
  regsub -all {[ ]+} $sent " " sent
  #puts "sent:<[string trimleft $sent]>"
  ##set cmd [list RLSerial::SendSlow $com $sent 50 buffer $expected $timeOut]
  set cmd [list RLSerial::Send $com $sent buffer $expected $timeOut]
  if {$gaSet(act)==0} {return -2}
  set tt "[expr {[lindex [time {set ret [eval $cmd]}] 0]/1000000.0}]sec"
  #puts buffer:<$buffer> ; update
  if {[info exists gaSet(filterBuffer)] && $gaSet(filterBuffer)=="1"} {
    regsub -all -- {\x1B\x5B..\;..H} $buffer " " b1
    regsub -all -- {\x1B\x5B.\;..H}  $b1 " " b1
    regsub -all -- {\x1B\x5B..\;.H}  $b1 " " b1
    regsub -all -- {\x1B\x5B.\;.H}   $b1 " " b1
    regsub -all -- {\x1B\x5B..\;..r} $b1 " " b1
    regsub -all -- {\x1B\x5B.J}      $b1 " " b1
    regsub -all -- {\x1B\x5BK}       $b1 " " b1
    regsub -all -- {\x1B\x5B\x38\x30\x44}     $b1 " " b1
    regsub -all -- {\x1B\x5B\x31\x42}      $b1 " " b1
    regsub -all -- {\x1B\x5B.\x6D}      $b1 " " b1
    regsub -all -- \\\[m $b1 " " b1
    set re \[\x1B\x0D\]
    regsub -all -- $re $b1 " " b2
    #regsub -all -- ..\;..H $b1 " " b2
    regsub -all {\s+} $b2 " " b3
    regsub -all {\-+} $b3 "-" b3
    regsub -all -- {\[0\;30\;47m} $b3 " " b3
    regsub -all -- {\[1\;30\;47m} $b3 " " b3
    regsub -all -- {\[0\;34\;47m} $b3 " " b3
    set buffer $b3
  }
  #puts "sent:<$sent>"
  if 1 {
    #puts "\nsend: ---------- [clock format [clock seconds] -format %T] ---------------------------"
    puts "\nsend: ---------- [MyTime] ---------------------------"
    puts "send: com:$com, ret:$ret tt:$tt, sent=$sent,  expected=$expected, buffer=$buffer"
    puts "send: ----------------------------------------\n"
    update
  }
  
  Delayms 50 ; #RLTime::Delayms 50
  return $ret
}

#***************************************************************************
#** Status
#***************************************************************************
proc Status {txt {color white}} {
  global gaSet gaGui
  #set gaSet(status) $txt
  #$gaGui(labStatus) configure -bg $color
  $gaSet(sstatus) configure -bg $color  -text $txt
  if {$txt!=""} {
    puts "\n ..... $txt ..... /* [MyTime] */ \n"
  }
  $gaSet(runTime) configure -text ""
  update
}


##***************************************************************************
##** Wait
##***************************************************************************
proc Wait {txt count {color white}} {
  global gaSet
  puts "\nStart Wait $txt $count.....[MyTime]"; update
  Status $txt $color 
  for {set i $count} {$i > 0} {incr i -1} {
    if {$gaSet(act)==0} {return -2}
	 $gaSet(runTime) configure -text $i
	 Delay 1 ; #RLTime::Delay 1
  }
  $gaSet(runTime) configure -text ""
  Status "" 
  puts "Finish Wait $txt $count.....[MyTime]\n"; update
  return 0
}

# ***************************************************************************
# MyWaitFor
# ***************************************************************************
proc MyWaitFor {com expected testEach timeout} {
  global buffer gaGui gaSet
  #Status "Waiting for \"$expected\""
  if {$gaSet(act)==0} {return -2}
  puts [MyTime] ; update
  set startTime [clock seconds]
  set runTime 0
  while 1 {
    #set ret [RLCom::Waitfor $com buffer $expected $testEach]
    #set ret [RLCom::Waitfor $com buffer stam $testEach]
    set ret [Send $com \r stam $testEach]
    foreach expd $expected {
      puts "expected:<$expected> expd:<$expd> ret:$ret runTime:$runTime" ; update ; #buffer:<$buffer> 
#       if {$expd=="PASSWORD"} {
#         ## in old versiond you need a few enters to get the uut respond
#         Send $com \r stam 0.25
#       }
      if [string match "*$expd*" $buffer] {
        set ret 0
        break
      }
    }
    #set ret [Send $com \r $expected $testEach]
    set nowTime [clock seconds]; set runTime [expr {$nowTime - $startTime}] 
    $gaSet(runTime) configure -text $runTime
    #puts "i:$i runTime:$runTime ret:$ret buffer:_${buffer}_" ; update
    if {$ret==0} {break}
    if {$runTime>$timeout} {break }
    if {$gaSet(act)==0} {set ret -2 ; break}
    update
  }
  puts "[MyTime] ret:$ret runTime:$runTime"
  $gaSet(runTime) configure -text ""
  Status ""
  return $ret
}   
# ***************************************************************************
# AddToLog
# ***************************************************************************
proc AddToLog {line} {
  global gaSet
  if ![file exists $gaSet(log)] {
    ::fileutil::writeFile $gaSet(log) \r  
  }
  if {$line==""} {
    ::fileutil::insertIntoFile  $gaSet(log) 0 "\n"
  } else {
    ::fileutil::insertIntoFile  $gaSet(log) 0 "..[MyTime]..$line\n"
  }  
  #set id [open $gaSet(log) r+] 
  #puts $id "..[MyTime]..$line"
  #close $id
}
# ***************************************************************************
# ShowLog
# ***************************************************************************
proc ShowLog {} {
  global gaSet
  catch {exec notepad.exe $gaSet(log) &}
}

# ***************************************************************************
# mparray
# ***************************************************************************
proc mparray {a {pattern *}} {
  upvar 1 $a array
  if {![array exists array]} {
	  error "\"$a\" isn't an array"
  }
  set maxl 0
  foreach name [lsort -dict [array names array $pattern]] {
	  if {[string length $name] > $maxl} {
	    set maxl [string length $name]
  	}
  }
  set maxl [expr {$maxl + [string length $a] + 2}]
  foreach name [lsort -dict [array names array $pattern]] {
	  set nameString [format %s(%s) $a $name]
	  puts stdout [format "%-*s = %s" $maxl $nameString $array($name)]
  }
  update
}

# ***************************************************************************
# GetMac
# ***************************************************************************
proc GetMac {fi} {
  set macFile c:/tmp/mac[set fi].txt
  exec c:/radapps/MACServer.exe 0 1 $macFile 1
  set ret [catch {open $macFile r} id]
  if {$ret!=0} {
    set gaSet(fail) "Open Mac File fail"
    return -1
  }
  set buffer [read $id]
  close $id
  file delete $macFile)
  set ret [regexp -all {ERROR} $buffer]
  if {$ret!=0} {
    set gaSet(fail) "MACServer ERROR"
    exec beep.exe
    return -1
  }
  return [lindex $buffer 0]
}


# ***************************************************************************
# CheckMac
# ***************************************************************************
proc CheckMac {ba} {
  global gaSet gaGui
  
  set barc [string range $gaSet(entDUT$ba) 0 10]
  set res [catch {exec $gaSet(JavaPath) -jar [pwd]/CheckMAC.jar $barc A0B1C2D3E4F5} resChk]
  #puts "$barc res:<$res> resChk:<$resChk>"
  
  puts "[MyTime] Res of CheckMAC $barc : <$resChk>" ; update
  #set gaSet(ent1) ""
  if {$resChk=="0"} {  
    #set gaSet(entDUT$ba) "There is no MAC connected to $barc"
    set gaSet(fail) "FAIL...There is no MAC connected to $barc...FAIL"
    set txt "$gaSet(fail)"  
    
    $gaGui(entDUT$ba) configure -background red
    set ret -1
  } elseif {$resChk!="0"} {
    #puts "res:<$res>"
    if {$res=="1"} {
      set gaSet(entDUT$ba) "Error"
      set txt "$resChk" 
      $gaGui(entDUT$ba) configure -background red 
      set ret -1
    } else {
      ## remove the 'already' word
      set resChk [lreplace $resChk [lsearch $resChk already] [lsearch $resChk already]]
      ## remove ID Number and add the barcode itself
      set resChk [lreplace $resChk [lsearch $resChk ID] [lsearch $resChk Number ] $barc]
      ## remove : from MAC
      set resChk [concat [lrange $resChk 0 end-1] [string trimleft [lindex $resChk end] :]]
      set gaSet($ba.dbrMac) [lindex $resChk end]
      Status $resChk
      set txt "$resChk"
      #$gaGui(entDUT$ba) configure -background green
      set ret 0
    }
  }
  
  
  #set txt "$gaSet(ent2)"
  puts $txt
  if ![file exists c:/logs] {
    file mkdir c:/logs
  }
  
  if {$gaSet(logType)=="new"} { 
    set id [open $gaSet(log) w]
    puts $id ""
    close $id
  } elseif {$gaSet(logType)=="old"} {   
    #set id [open $gaSet(log) a+]
  }
  #AddToLog ""
  AddToLog "$txt"
  #close $id  
  
  set gaSet(logType) "old"
  return $ret
}  
 

# ***************************************************************************
# CreateNewLog
# ***************************************************************************
proc CreateNewLog {} {
  global gaSet gaGui
  #set gaSet(ent2) ""
  if ![file exists c:/logs] {
    file mkdir c:/logs
  }
  #$gaGui(ent2) configure -background [ttk::style lookup . -background disabled]
  set types {
    {{Text Files}       {.txt}        }
  }

  set f  [tk_getSaveFile -parent . -title "New log" -initialdir "C:/logs" -initialfile "[MyTime]_" -filetypes $types]
  if {$f!=""} {
    #puts "f:<$f> extension:<[file extension $f]>"   ; update
    if {[file extension $f]!=".txt"} {
      set f $f.txt
    }
    set gaSet(log) $f
  }
  
  focus -force $gaGui(entDUT1)
  update
}
# ***************************************************************************
# ChooseExistLog
# ***************************************************************************
proc ChooseExistLog {} {
  global gaSet gaGui
  #set gaSet(ent2) ""
  #$gaGui(ent2) configure -background [ttk::style lookup . -background disabled]
  set types {
    {{Text Files}       {.txt}        }
  }
  set f  [tk_getOpenFile -parent . -title "Exist log" -initialdir "C:/logs" -filetypes $types]
  if {$f!=""} {
    set gaSet(log) $f
  }
  
  focus -force $gaGui(entDUT1)
  update
}
# ***************************************************************************
# JavaPath
# ***************************************************************************
proc JavaPath {} {
  global gaSet
  set f [tk_getOpenFile -title "Choose java's folder" -initialdir "c:/"]
  if {$f!=""} {
    set gaSet(JavaPath) $f
  }
  
}
# ***************************************************************************
# Delayms
# ***************************************************************************
proc Delayms { ip_timeSec } {
  set x 0
  after $ip_timeSec { set x 1 }
  vwait x
}
# ***************************************************************************
# GetDbrName
# ***************************************************************************
proc GetDbrName {} {
  global gaSet gaGui
  Status "Please wait for retriving DBR's parameters"
  puts "\r[MyTime] GetDbrName"; update
  set barcode $gaSet(entDUT4)
  
  if [file exists MarkNam_$barcode.txt] {
    file delete -force MarkNam_$barcode.txt
  }
  
  if {![file exist $gaSet(JavaPath)]} {
    set txt  "Java application is missing"
    set res [DialogBox -text $txt -icon /images/error.gif -title "Get Dbr Name"]
    return -1
  }
  catch {exec $gaSet(JavaPath) -jar OI4Barcode.jar $barcode} b
  set fileName MarkNam_$barcode.txt
  after 1000
  if ![file exists MarkNam_$barcode.txt] {
    set txt  "File $fileName is not created. Verify the Barcode"
    #set res [DialogBox -text $txt -icon /images/error.gif -title "Get Dbr Name"]
    return $txt
  }
  
  set fileId [open "$fileName"]
    seek $fileId 0
    set res [read $fileId]    
  close $fileId
  
  after 500
  file delete -force MarkNam_$barcode.txt
  
  #set txt "$barcode $res"
  set txt "[string trim $res]"
  puts "GetDbrName txt: <$txt> res:<$res>"
  if [string match *ERROR* $txt] {
    return $txt  
  }
  update
  set gaSet(DutFullName) $res
  #file mkdir [regsub -all / $res .]
  
  puts ""
  return 0
}

# ***************************************************************************
# CRC
# ***************************************************************************
proc CRC {ldata} {

  #demo:
  #set ldata [list 11 02 11 10 00 00 00 00 00 01 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00]
  #set ldata [list 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 00 20 D2 FB 5E C5 00 00 00 00 00 00 00 00 00 00 00]

  set lKey [list \
  00 07 0E 09 1C 1B 12 15 \
  38 3F 36 31 24 23 2A 2D \
  70 77 7E 79 6C 6B 62 65 \
	48 4F 46 41 54 53 5A 5D \
	E0 E7 EE E9 FC FB F2 F5 \
	D8 DF D6 D1 C4 C3 CA CD \
	90 97 9E 99 8C 8B 82 85 \
	A8 AF A6 A1 B4 B3 BA BD \
	C7 C0 C9 CE DB DC D5 D2 \
	FF F8 F1 F6 E3 E4 ED EA \
	B7 B0 B9 BE AB AC A5 A2 \
	8F 88 81 86 93 94 9D 9A \
	27 20 29 2E 3B 3C 35 32 \
	1F 18 11 16 03 04 0D 0A \
	57 50 59 5E 4B 4C 45 42 \
	6F 68 61 66 73 74 7D 7A \
	89 8E 87 80 95 92 9B 9C \
	B1 B6 BF B8 AD AA A3 A4 \
	F9 FE F7 F0 E5 E2 EB EC \
	C1 C6 CF C8 DD DA D3 D4 \
  69 6E 67 60 75 72 7B 7C \
	51 56 5F 58 4D 4A 43 44 \
	19 1E 17 10 05 02 0B 0C \
	21 26 2F 28 3D 3A 33 34 \
	4E 49 40 47 52 55 5C 5B \
	76 71 78 7F 6A 6D 64 63 \
	3E 39 30 37 22 25 2C 2B \
	06 01 08 0F 1A 1D 14 13 \
	AE A9 A0 A7 B2 B5 BC BB \
	96 91 98 9F 8A 8D 84 83 \
	DE D9 D0 D7 C2 C5 CC CB \
	E6 E1 E8 EF FA FD F4 F3 ]

  set crc 00
  set lvar "$ldata"
  foreach a "$lvar" {
    set crc [lindex $lKey [expr 0x$crc^0x$a]]    
  }
  return $crc
}

# ***************************************************************************
# AsciiToHex_Convert_Split
# ***************************************************************************
proc AsciiToHex_Convert_Split {Ascii} {
  for {set i 0} {$i<=[expr [string length $Ascii]-1]} {incr i} {
    set arg [string range $Ascii $i $i]   
    lappend Hex [format %.2X [scan $arg %c]]
  }
  return $Hex
}

# ***************************************************************************
# DecToHex_Convert_Split
# ***************************************************************************
proc DecToHex_Convert_Split {Dec} {
  set Hex [format "%.2X" $Dec]
  return $Hex
}

# ***************************************************************************
# Split_Mac
# ***************************************************************************
proc Split_Mac {Mac} {
  foreach from "0 2 4 6 8 10" to "1 3 5 7 9 11" {
    lappend Split_Mac [string range $Mac $from $to]
  }
  return $Split_Mac
}
# ***************************************************************************
# WritePage0
# ***************************************************************************
proc WritePage0 {bar} {
  global gaGui buffer buff  gaSet
  set com $gaSet(comDut$bar)
  
	if {[Send $com "\r" "\[boot" 1] != 0} {
	  set gaSet(fail) "Failed to get Boot Menu" ; update
    return -1
	}
       
  Send $com  "c ip\r" stam 0.5
  Send $com  "10.10.10.5\r" "\[boot" 1
  Send $com  "c sip\r" stam 0.5
  Send $com  "10.10.10.10\r" "\[boot" 1
  
  Send $com "p\r" "\[boot" 1
  set ret [regexp {device IP[ \(\w \)]+:[ ]+[\w]+.[\w]+.([\w]+).([\w]+)} $buffer var var1 var2]	
  if {$ret!=1} {
    set gaSet(fail) "Failed to get Device IP" ; update
    return -1	  
  }
	  
  # Dec:
  set var1 [string trim $var1]
  set var2 [string trim $var2]
  #dec to Hex
  set var1 [format %.2x $var1]
  set var2 [format %.2x $var2]
  set password "y$var1$var2"
  puts "password:$password"
  
  Send $com "\20\r" "\[boot" 1 ;# Shift ctrl-p
  
  set device 00 ; #constant
	set offSet 00
  Send $com "d2 $device,00,32,$offSet\r" "\[boot" 2
  set ret [regexp {([\w\.]{47})\s+([\w\.]{47})} $buffer var var1 var2]
  if {$ret!=1} {
    set gaSet(fail) "Page0 check fail." ; update
    return -1	  
  }
  set var1 [string trim [regsub -all -- {\.} $var1 " "]]
  set var2 [string trim [regsub -all -- {\.} $var2 " "]]
  set res "$var1 $var2"
  set resL [split $res " "]
  set l1 [list 00 00 00 [string range $gaSet(entSN$bar) 0 1] [string range $gaSet(entSN$bar) 2 3]\
   [string range $gaSet(entSN$bar) 4 5] [string range $gaSet(entSN$bar) 6 7]  [string range $gaSet(entSN$bar) 8 9]] 
  set l2 [lrange $resL 8 end]   
  set page0 [concat $l1 $l2]      		
	  
#   set page0 "00 00 00 [string range $gaSet(entSN$bar) 0 1] [string range $gaSet(entSN$bar) 2 3]\
#    [string range $gaSet(entSN$bar) 4 5] [string range $gaSet(entSN$bar) 6 7] [string range $gaSet(entSN$bar) 8 9]\
#    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"
		  
	puts "page0:<$page0>"; update
  #set device 00 ; #constant
	set crc [CRC $page0]
	#set offSet 00   
  Status "Writing page 0"   	
		
	if {[Send $com "c2 $device,00,$offSet,$page0,$crc\r" "data ?" 3] != 0} {
	 set gaSet(fail) "Writing Error - Page 0"
    return -1
  }			      
  Send $com "$password\r" "\[boot" 2
    
  # Read:
  #d2 <device#>,<page#>,<#byte>,<offset>
  Send $com "d2 $device,00,32,$offSet\r" "\[boot" 2
  set ret [regexp {([\w\.]{47})\s+([\w\.]{47})} $buffer var var1 var2]
  if {$ret!=1} {
    set gaSet(fail) "Page0 check fail." ; update
    return -1	  
  }
  set var1 [string trim [regsub -all -- {\.} $var1 " "]]
  set var2 [string trim [regsub -all -- {\.} $var2 " "]]
  set res "$var1 $var2"
  if {[string match *$page0* $res]==0} {
    set gaSet(fail) "Page0 result fail." ; update
    puts "res:$res"
    puts "pag:$page0"
    #puts stderr "Page$page result fail." 
    return -1    
  }            		
	Send $com "run\r" stam 0.25
  Wait "Wait for UUT-$bar up" 30
	return 0
}

# ***************************************************************************
# Delay
# ***************************************************************************
proc Delay { ip_timeSec } {
  set x 0
  after [ expr { $ip_timeSec * 1000 }] { set x 1 }
  vwait x
}
# ***************************************************************************
# Delayms
# ***************************************************************************
proc Delayms { ip_timeSec } {
  set x 0
  after $ip_timeSec { set x 1 }
  vwait x
}
# ***************************************************************************
# SaveInit
# ***************************************************************************
proc SaveInit {} {
  global gaSet  
  set id [open [info host]/init$gaSet(pair).tcl w]
  puts $id "set gaGui(xy) +[winfo x .]+[winfo y .]"
  puts $id "set gaSet(log)     \"$gaSet(log)\""
  if {[info exists gaSet(JavaPath)] && $gaSet(JavaPath)!=""} {
    puts $id "set gaSet(JavaPath)     \"$gaSet(JavaPath)\""
  }
  for {set ba 1} {$ba<=$gaSet(maxMultiQty)} {incr ba} {
    puts $id "set gaSet(comDut$ba) \"$gaSet(comDut$ba)\""
  }
  puts $id "set gaSet(testedProduct)     \"$gaSet(testedProduct)\""
  
  if {[info exists gaSet(performSWTest)]} {
    puts $id "set gaSet(performSWTest)     \"$gaSet(performSWTest)\""
  }
  if {[info exists gaSet(entSwVer)]} {
    puts $id "set gaSet(entSwVer)          \"$gaSet(entSwVer)\""
  }
  
  if {[info exists gaSet(performHWTest)]} {
    puts $id "set gaSet(performHWTest)     \"$gaSet(performHWTest)\""
  }
  if {[info exists gaSet(entHwVer)]} {
    puts $id "set gaSet(entHwVer)          \"$gaSet(entHwVer)\""
  }
  
  if {[info exists gaSet(performSwDateTest)]} {
    puts $id "set gaSet(performSwDateTest)     \"$gaSet(performSwDateTest)\""
  }
  if {[info exists gaSet(entSwDate)]} {
    puts $id "set gaSet(entSwDate)          \"$gaSet(entSwDate)\""
  }
  
  if {[info exists gaSet(performInfoTest)]} {
    puts $id "set gaSet(performInfoTest)     \"$gaSet(performInfoTest)\""
  }
  if {[info exists gaSet(entInfo)]} {
    regsub -all \" $gaSet(entInfo) \\" entInfo
    puts $id "set gaSet(entInfo)          \"$entInfo\""
  }
 
  close $id
   
}
