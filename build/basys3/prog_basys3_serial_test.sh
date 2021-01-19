###########################
# Buildscript goes here
###########################
if [ ! -f bitstreams/basys3_serial_test.bit ]
then
  echo BUILD FAILED
  exit 1
fi
. /opt/Xilinx/Vivado/2019.2/settings64.sh
echo source prog_basys3_serial_test.tcl | vivado -mode tcl
exit 0
