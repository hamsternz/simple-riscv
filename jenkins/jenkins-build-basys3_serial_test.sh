#!/bin/bash
cd build/basys3
./build_basys3_serial_test.sh
rtn=$?
echo Return code $rtn
exit $rtn
