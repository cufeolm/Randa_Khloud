function void verify_swap_word(GUVM_sequence_item cmd_trans,GUVM_result_transaction res_trans,GUVM_history_transaction hist_trans);
	//bit [31:0]he,h1 ;
	bit [31:0] actual_result,actual_mem_add,exp_result,exp_mem_add,rs1_data,op;
	bit [4:0]reg_add;
	bit [31:0] reg_data;
	bit [5:0]i;
	//reg_add = cmd_trans.rd;
	//hc = res_trans.result;
	//reg_data = cmd_trans.data;
	//he = res_trans.result;
//	h1 = cmd_trans.swapped_operand;
if (cmd_trans.SOM == SB_HISTORY_MODE)
	begin
	    rs1_data = hist_trans.get_reg_data(cmd_trans.rs1);
	    op= rs1_data;	
	    case(op[1:0])
			2'b00:reg_data = {{cmd_trans.data[31:8]},{cmd_trans.data[7:0]}};
			2'b01:reg_data = {{cmd_trans.data[1:0]},{cmd_trans.data[31:24]}};
			2'b10:reg_data = {{cmd_trans.data[15:0]},{cmd_trans.data[31:16]}};
			2'b11:reg_data = {{cmd_trans.data[23:0]},{cmd_trans.data[31:24]}};
		endcase
		
	    reg_add = cmd_trans.rd;
	    //hc = res_trans.result;
	    //reg_data = cmd_trans.data;
		hist_trans.loadreg(reg_data,reg_add);
        
	end
	else if (cmd_trans.SOM == SB_VERIFICATION_MODE)begin
		foreach(hist_trans.item_history[i]) begin
			if (hist_trans.item_history[i].res_trans.result!=0) begin
				 actual_result = hist_trans.item_history[i].res_trans.result ; 
				//break ; 
			end
		end
		
		foreach(hist_trans.item_history[i]) begin
		if (xis1(hist_trans.item_history[i].cmd_trans.inst,findOP("Store")))begin
			if (hist_trans.item_history[i].res_trans.mem_add!=0) begin
				 actual_mem_add = hist_trans.item_history[i].res_trans.mem_add ; 
				//break ; 
			end
		end
		
		//hc = res_trans.result;
	           exp_result = hist_trans.get_reg_data(cmd_trans.rd);///////
               exp_mem_add=rs1_data;
        //  swap_b_res={{24{0}},res_trans.result[7:0]};
				//$display("swapped_operand=%d",cmd_trans.swapped_operand);

					if(((exp_result) == (actual_result)) )
					//&& (exp_mem_add==actual_mem_add))
						begin
							`uvm_info ("SWAP_PASS", $sformatf("DUT Calculation=%h SCOREBOARD Calculation=%h DUT memory address Calculation=%0h SCOREBOARD memory address Calculation=%0b ", actual_result, exp_result,actual_mem_add,exp_mem_add), UVM_LOW)
						end
					else
						begin
							`uvm_error("SWAP_FAIL", $sformatf("DUT Calculation=%h SCOREBOARD Calculation=%h DUT memory address Calculation=%0h SCOREBOARD memory address Calculation=%0b ",actual_result,exp_result,actual_mem_add,exp_mem_add))
						end
	end
endfunction