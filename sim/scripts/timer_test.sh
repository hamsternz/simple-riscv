###########################
# Buildscript goes here
###########################
. /opt/Xilinx/Vivado/2019.2/settings64.sh
vivado -mode tcl <<EOF
source timer_test.tcl
EOF
grep -q "^All tests complete$" timer_test.sim/sim_1/behav/xsim/simulate.log
exit $?
