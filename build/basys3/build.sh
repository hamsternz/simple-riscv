###########################
# Buildscript goes here
###########################
. /opt/Xilinx/Vivado/2019.2/settings64.sh
echo source build.tcl | vivado -mode tcl
if [ ! -f bitstreams/basys3_top_level.bit ]
then
  echo BUILD FAILED
  return 1
fi
echo Build OK
return 0
