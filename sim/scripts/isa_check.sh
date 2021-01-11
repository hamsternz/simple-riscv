###########################
# Buildscript goes here
###########################
. /opt/Xilinx/Vivado/2019.2/settings64.sh
vivado -mode tcl <<EOF
source isa_check.tcl
EOF
grep -q "^All tests complete$" isa_check.sim/sim_1/behav/xsim/simulate.log
exit $?
