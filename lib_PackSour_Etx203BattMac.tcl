package require BWidget
package require img::ico
package require RLSerial
package require RLEH
#package require RLTime
package require RLStatus
package require RLSound
package require fileutil
package require tile
RLSound::Open ; # [list failbeep fail.wav passbeep pass.wav beep warning.wav]

#07:50 12/09/2022 Use "pass" and "fail" wavs from C:\RLFiles\Sound\Wav
RLSound::Open "pass1 pass.wav pass2 pass.wav pass3 pass.wav pass4 pass.wav \
fail1 fail.wav fail2 fail.wav fail3 fail.wav fail4 fail.wav "

#RLSound::Open "pass1 [pwd]/images/1pass.wav pass2 [pwd]/images/2pass.wav \
#pass3 [pwd]/images/3pass.wav pass4 [pwd]/images/4pass.wav \
#fail1 [pwd]/images/1fail.wav fail2 [pwd]/images/2fail.wav \
#fail3 [pwd]/images/3fail.wav fail4 [pwd]/images/4fail.wav "

if {![info exists gaSet(testedProduct)]} {
  set gaSet(testedProduct) ETX203
}
source Gui_Etx203BattMac.tcl
source [info host]/init$gaSet(pair).tcl
source Lib_Put_[set gaSet(testedProduct)]_Etx203BattMac.tcl
source Lib_Gen_Etx203BattMac.tcl
source Lib_Main_Etx203BattMac.tcl
source Lib_DialogBox.tcl
source Lib_AutoUpdate.tcl
source lib_SQlite.tcl
source LibUrl.tcl


#console show 
set tdsPath //prod-svm1/tds/AT-Testers/JER_AT/ilya/Tools/AT-Etx203-BattMac
set reopenPath "[info host]/HWinit.tcl 1 f"
set ret [CheckUpdates $tdsPath $reopenPath]
if {$ret!=0} {exit}

#console show 

set gaSet(DutFullName) "ETX203"
set gaSet(logType) "old"
set gaSet(maxMultiQty) 4
set gaSet(act) 1
set gaSet(performMacTest) 1
##set gaSet(updatesLogPath) c:\\logs\\updates.txt
set gaSet(userPassOpt) regular
set gaSet(filterBuffer) 1

GUI
#BuildTests
update

#after 50

#Status "Ready"