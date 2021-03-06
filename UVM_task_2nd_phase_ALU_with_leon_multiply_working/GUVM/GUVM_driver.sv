class GUVM_driver extends uvm_driver #(target_seq_item);
    `uvm_component_utils(GUVM_driver)

    virtual GUVM_interface bfm;

    uvm_analysis_port #(target_seq_item) Drv2Sb_port;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        // Get interface reference from config database
        if(!uvm_config_db#(virtual GUVM_interface)::get(this, "", "bfm", bfm)) begin
            `uvm_error("", "uvm_config_db::get failed")
        end
        Drv2Sb_port = new("Drv2Sb", this);
    endfunction

    task run_phase(uvm_phase phase);
        target_seq_item cmd;
        forever begin: cmd_loop
            $display("driver has started");
            bfm.reset_dut();
            bfm.set_Up();
            $display("driver starting fetching");
            
            //first load
            seq_item_port.get_next_item(cmd);
            //$display leon
                $display("driver first load fetch");
                $display("inst is %b %b %b %b %b %b %b %b", cmd.inst[31:28], cmd.inst[27:24], cmd.inst[23:20], cmd.inst[19:16], cmd.inst[15:12], cmd.inst[11:8], cmd.inst[7:4], cmd.inst[3:0]);
                //$display("rs1 address = %0d and data=%0d", cmd.inst[29:25], cmd.data);
                /* display riscy
            display("driver starting fetching");
            $display("inst is: %b %b %b %b %b", cmd.inst[31:20], cmd.inst[19:15], cmd.inst[14:12], cmd.inst[11:7], cmd.inst[6:0]);
            $display("rs1 address = %0d and data = %0d", cmd.inst[19:15], cmd.data);*/
                /* display amber
            $display("driver is fetshing the first load");
            $display("inst = %b %b %b %b %b", cmd.inst[31:28], cmd.inst[27:20], cmd.inst[19:16], cmd.inst[15:12], cmd.inst[11:0]);
            $display("rs1 address = %0d and data = %0d", cmd.inst[15:12], cmd.data); */ // rd addres
            bfm.load(cmd.inst, cmd.data);
            seq_item_port.item_done();

            //second load
            seq_item_port.get_next_item(cmd);
            //$display leon
                $display("driver second load fetch");
                $display("inst is %b %b %b %b %b %b %b %b", cmd.inst[31:28], cmd.inst[27:24], cmd.inst[23:20], cmd.inst[19:16], cmd.inst[15:12], cmd.inst[11:8], cmd.inst[7:4], cmd.inst[3:0]);
                //$display("rs2 address = %0d and data=%0d", cmd.inst[29:25], cmd.data);
                /* display riscy
            /*$display("driver starting fetching");
            $display("inst is: %b %b %b %b %b", cmd.inst[31:20], cmd.inst[19:15], cmd.inst[14:12], cmd.inst[11:7], cmd.inst[6:0]);
            $display("rs1 address = %0d and data = %0d", cmd.inst[19:15], cmd.data);*/
                /* display amber
            $display("driver is fetshing the second load");
            $display("inst = %b %b %b %b %b", cmd.inst[31:28], cmd.inst[27:20], cmd.inst[19:16], cmd.inst[15:12], cmd.inst[11:0]);
            $display("rs2 address = %0d and data = %0d", cmd.inst[15:12], cmd.data); */ // rd addres
            bfm.load(cmd.inst, cmd.data);
            //bfm.load(cmd.inst, cmd.imm_data);
            seq_item_port.item_done();

            //instruction to be verified
            seq_item_port.get_next_item(cmd);
                // display leon
                $display("driver instruction fetch");
                $display("inst is %b %b %b %b %b %b %b %b", cmd.inst[31:28], cmd.inst[27:24], cmd.inst[23:20], cmd.inst[19:16], cmd.inst[15:12], cmd.inst[11:8], cmd.inst[7:4], cmd.inst[3:0]);
                $display("rs1 address = %0d and rs2 address = %0d and rd address = %0d", cmd.rs1, cmd.rs2, cmd.rd);
                $display("op1= %0d op2= %0d",cmd.operand1,cmd.operand2);
                //$display("op1= %0d op_imm= %0d",cmd.operand1,cmd.operand_imm);
                // display riscy
            /*$display("driver instruction fetch");
            $display("inst is: %b %b %b %b %b %b", cmd.inst[31:26], cmd.inst[25:20], cmd.inst[19:15], cmd.inst[14:12], cmd.inst[11:7], cmd.inst[6:0]);
            $display("rs1 address = %0d and rs2 address = %0d and rd address = %0d", cmd.inst[19:15], cmd.inst[25:20], cmd.inst[11:7]);*/
                /* display amber
            $display("drive is fetching the instruction");
            $display("inst is %b %b %b %b %b %b %b %b", cmd.inst[31:28], cmd.inst[27:26], cmd.inst[25], cmd.inst[24:21], cmd.inst[20], cmd.inst[19:16], cmd.inst[15:12], cmd.inst[11:4], cmd.inst[3:0]);
            $display("rs1 address = %0d and rs2 address = %0d and rd address = %0d", cmd.inst[19:16], cmd.inst[3:0], cmd.inst[15:12]);*/
            if(memory_acc_inst(si_a))
            begin
            bfm.swap_inst(cmd.inst, cmd.data);
            $display("driver swap done");
            end
            else
            begin
          bfm.verify_inst(cmd.inst);
            end
            Drv2Sb_port.write(cmd);

            seq_item_port.item_done();

            //store result
            seq_item_port.get_next_item(cmd);
                // display leon
                $display("driver store fetch");
                $display("inst is %b %b %b %b %b %b %b %b",cmd.inst[31:28],cmd.inst[27:24],cmd.inst[23:20],cmd.inst[19:16],cmd.inst[15:12],cmd.inst[11:8],cmd.inst[7:4],cmd.inst[3:0]);
                //$display("rd address = %0d",cmd.inst[29:25]);
                // display riscy
           /* $display("driver store fetch");
            $display("inst is: %b %b %b %b %b %b", cmd.inst[31:26], cmd.inst[25:20], cmd.inst[19:15], cmd.inst[14:12], cmd.inst[11:7], cmd.inst[6:0]);
            $display("rd address = %0d",cmd.inst[11:7]);*/
                // display amber
            /*$display("driver is fetshing the result");
            $display("inst = %b %b %b %b %b", cmd.inst[31:28], cmd.inst[27:20], cmd.inst[19:16], cmd.inst[15:12], cmd.inst[11:0]);
            $display("rd address = %0d", cmd.inst[15:12]);*/
            bfm.store(cmd.inst);
            seq_item_port.item_done();
        end: cmd_loop
    endtask: run_phase

endclass: GUVM_driver