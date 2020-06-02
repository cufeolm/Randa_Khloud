if [file exists "work"] {vdel -all}
vlib work
onerror {quit}

vlog -f ../testing_amber_a/dut_amber.f 
vlog +incdir+../testing_amber_a+../common+../common/inst_h+../common/Tests+../common/sequences ../testing_amber_a/target_pkg.sv

vlog ../testing_amber_a/amber_interface.sv
vlog ../testing_amber_a/top.sv

#vsim top

#run -all
#log /* -r
quit
