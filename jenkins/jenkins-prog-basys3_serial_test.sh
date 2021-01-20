#!/bin/bash
cd build/basys3
stty speed 19200 < /dev/ttyUSB1
sleep 1000 > /dev/ttyUSB1 &
cat /dev/ttyUSB1 > /tmp/output.$$ &
./prog_basys3_serial_test.sh
sleep 2
kill %2
kill %1
sleep 1
grep -q "Text 5 characters long" /tmp/output.$$
rtn=$?
if [ `ls -l /tmp/output.$$  | awk '{ print $5 }'` -ne 69 ]
then
  echo ERROR File is wrong size
  rtn=1
else
  echo ====================
  echo Captured was:
  cat /tmp/output.$$
  echo ====================
fi
rm /tmp/output.$$
echo Return code $rtn
exit $rtn
