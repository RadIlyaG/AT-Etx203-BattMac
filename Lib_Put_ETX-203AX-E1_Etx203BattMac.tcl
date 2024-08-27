## 23/02/2020 07:45:44 
## Because a mistake, the ETX203_Etx203AX got wrong page of ETX-203AX-E1.
## all the procs of the normal ETX are good, so i will continue to use them,
## just perform a little check of the prompt at the proc Login   
source Lib_Put_ETX203_Etx203BattMac.tcl
set gaSet(performDgTest) 0
$gaGui(performDgTest) configure -state disabled
update