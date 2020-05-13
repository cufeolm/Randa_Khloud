class GUVM_sequence extends uvm_sequence #(GUVM_sequence_item);
    `uvm_object_utils(GUVM_sequence);
    target_seq_item command,load1,load2,store,load3,load4 ;
    target_seq_item c;
    function new(string name = "GUVM_sequence");
        super.new(name);
    endfunction : new

    task body();
       repeat(10)
        begin
            load1 = target_seq_item::type_id::create("load1");
            load2 = target_seq_item::type_id::create("load2");
            load3 = target_seq_item::type_id::create("load3");
            load4 = target_seq_item::type_id::create("load4");
            command = target_seq_item::type_id::create("command");
            store = target_seq_item::type_id::create("store");
            //opcode x=A ;
           // $display("hello , this is the sequence,%d",command.upper_bit);
           // command.ran_constrained_dep_inst(RY);
            command.ran_constrained(UId);
            
            //command.ran();

            command.setup();
            load1.load(command.rs1);
            load2.load(command.rs2);
            //load3.load_dep(command.rs1);
          //  load4.load_dep(command.rs2);
            //read1.Read_status_reg(command.rd);
            
            
            store.store(command.rd);

          // command.operand1=load1.data;
           command.operand1=load1.data;
          // if(generate_immediate(si_a))
           //begin
         //  $display("IF condition started");
         // command.operand_imm=load2.imm_data;
          // end
           //else
          // begin
           //command.operand2=load2.data;
           command.operand2=load2.data;
           command.swapped_operand=command.data;
           //command.operand1=load1.data;
         //  end
           // command.operand1=load1.US_data;
            //command.operand2=load2.US_data;
            


            start_item(load1);
            finish_item(load1);
             



            start_item(load2);
            finish_item(load2);
            
           // start_item(load3);
            //finish_item(load3);

            //start_item(load4);
           // finish_item(load4);
          //  start_item(read1);
           // finish_item(read1);


            start_item(command);
            finish_item(command);
            //start_item(command);
           // finish_item(command);
            

            start_item(store);
            finish_item(store);
            
        end
    endtask : body


endclass : GUVM_sequence

