#!/bin/bash
cd build/basys3
./build_basys3_serial.sh
rtn=$?
echo Return code $rtn
exit $rtn
