#!/bin/bash
cd build/basys3
stty speed 19200 < /dev/ttyUSB1
cat /dev/ttyUSB1 > /tmp/output.$$ &
./prog_basys3_timer_test.sh
sleep 2
kill %1
echo Captured was 
cat /tmp/output.$$
sleep 1
grep -q "Timer test complete$" /tmp/output.$$
rtn=$?
rtn=0
echo Return code $rtn
exit $rtn
