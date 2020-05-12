
//generates the sequence of instructions needed to test an add instruction 

class GUVM_sequence extends uvm_sequence #(GUVM_sequence_item);
    `uvm_object_utils(GUVM_sequence);
    //target_seq_item nop , temp ,reset;
    //target_seq_item c;
    function new(string name = "GUVM_sequence");
        super.new(name);
    endfunction : new

    task genNop(integer i , logic[31:0] data );//sends i number of nop with data
        repeat(i) begin
            target_seq_item nop ;
            nop = target_seq_item::type_id::create("nop");
            nop.ran_constrained(NOP); 
            nop.data = data ; 
            start_item(nop);
            finish_item(nop);
        end
    endtask


    function target_seq_item copy(target_seq_item targ);//deep copy of a seq item
        target_seq_item x ;
        x = target_seq_item::type_id::create("x");
        x.do_copy(targ);
        return x ;
    endfunction
    
    
    task send(target_seq_item targ);//sends a seq item 
        start_item(targ);
        finish_item(targ);
    endtask

    task resetSeq();//sends reset sequence
        target_seq_item reset;
        reset=target_seq_item::type_id::create("reset");
        reset.SOM = SB_RESET_MODE;
        send(reset);
    endtask
    /*task body();
        $display("GUVM_seq");
    endtask*/
    function opcode findOP(string s);//returns the op code corresponding to string s from package
        foreach(si_a[i]) // supported instruction is number of instructions in opcodes array of the core
        begin
            if(si_a[i].name == s) return si_a[i] ;
        end
        return NOP ; 
    endfunction

endclass : GUVM_sequence

