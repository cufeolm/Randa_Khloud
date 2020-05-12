if [file exists "work"] {vdel -all}
vlib work
onerror {quit}

vlog -f ../testing_amber/dut_amber.f 
vlog +incdir+../testing_leon+../common+../common/inst_h+../common/Tests+../common/sequences ../testing_leon/target_pkg.sv

vlog ../testing_amber/amber_interface.sv
vlog ../testing_amber/top.sv

vsim top

run -all
log /* -r
quit
