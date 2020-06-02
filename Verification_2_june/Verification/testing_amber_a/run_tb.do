onerror {quit}

vlog +incdir+../testing_amber_a+../common+../common/inst_h+../common/Tests+../common/sequences ../testing_amber_a/target_pkg.sv

vlog ../testing_amber_a/amber_interface.sv
vlog ../testing_amber_a/top.sv

#vsim -novopt top

#log /* -r

#run -all
quit