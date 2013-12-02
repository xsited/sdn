snmptrap -v 1 -c public 127.0.0.1 .1.3.6.1.6.3 "" 0 0 coldStart.0
snmptrap -v 1 -c public 127.0.0.1 .1.3.6.1.6.3 "" 0 0 linkDown.4
snmptrap -v 1 -c public localhost .1.3.6.1.6.3 "" 0 0 ""  
snmptrap -v 1 -c public localhost .1.3.6.1.6.3 "" 1 0 warmStart.0 
snmptrap -v 1 -c public localhost .1.3.6.1.6.3 "" 1 0 ""
snmptrap -v 1 -c public localhost .1.3.6.1.6.3 "" 2 0 linkUp.0  IF-MIB::ifIndex i 15
snmptrap -v 1 -c public localhost .1.3.6.1.6.3 "" 2 0 ""  IF-MIB::ifIndex i 15
snmptrap -v 1 -c public localhost .1.3.6.1.6.3 "" 3 0 linkDown.0 IF-MIB::ifIndex i 14
snmptrap -v 1 -c public localhost .1.3.6.1.6.3 "" 3 0 "" IF-MIB::ifIndex i 14
