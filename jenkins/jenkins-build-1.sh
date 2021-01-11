#!/bin/bash
cd sim/scripts
./isa_check.sh 
rtn=$?
echo Return code $rtn
exit $rtn
