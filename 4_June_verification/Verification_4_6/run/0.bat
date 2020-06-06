
vsim -c -do "transcript file trans/run.txt;vsim top +UVM_TESTNAME=bief_test +ARG_INST=BIEF ; log /* -r ; run -all ; quit"
