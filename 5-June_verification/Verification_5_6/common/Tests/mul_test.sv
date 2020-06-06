class mul_test extends GUVM_test;
    `uvm_component_utils(mul_test);
    function new(string name = "mul_test", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        cmdline_proc = uvm_cmdline_processor::get_inst();
        env_h   = GUVM_env::type_id::create("env_h",this);
        generic_sequence_h = mul_sequence::type_id::create("generic_sequence_h");
    endfunction: build_phase 
   
endclass: mul_test
