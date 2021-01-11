#!/bin/bash
cd build/basys3
./build.sh
rtn=$?
echo Return code $rtn
exit $rtn
