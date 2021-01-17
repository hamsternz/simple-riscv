#!/bin/bash
cd sim/scripts
./timer_test.sh 
rtn=$?
echo Return code $rtn
exit $rtn
