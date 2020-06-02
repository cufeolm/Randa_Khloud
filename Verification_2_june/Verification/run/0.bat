
vsim -c -do "transcript file trans/run.txt;vsim top +UVM_TESTNAME=mul_test +ARG_INST=UDIVR ; log /* -r ; run -all ; quit"
