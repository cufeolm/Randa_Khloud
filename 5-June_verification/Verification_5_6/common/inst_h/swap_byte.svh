function void verify_swap_byte(GUVM_sequence_item cmd_trans,GUVM_result_transaction res_trans,GUVM_history_transaction hist_trans);
	//bit [31:0]he,h1 ;
	bit [31:0] actual_result,actual_mem_add,exp_result,exp_mem_add,rs2_data;
	bit [4:0]reg_add;
	bit [31:0] reg_data;
	bit [5:0]i;
	reg_add = cmd_trans.rd;
	//hc = res_trans.result;
	
	//he = res_trans.result;
//	h1 = cmd_trans.swapped_operand;
if (cmd_trans.SOM == SB_HISTORY_MODE)
	begin	
	    reg_data = {{24{0}},cmd_trans.data[7:0]};
		reg_add = cmd_trans.rd;
		hist_trans.loadreg(reg_data,reg_add);
        rs2_data = hist_trans.get_reg_data(cmd_trans.rs2);		
		
       
	end
	else if (cmd_trans.SOM == SB_VERIFICATION_MODE)begin
		foreach(hist_trans.item_history[i]) begin
			if (hist_trans.item_history[i].res_trans.result!=0) begin
				 actual_result = hist_trans.item_history[i].res_trans.result ; 
				//break ; 
			end
		end
		foreach(hist_trans.item_history[i]) begin
			if (hist_trans.item_history[i].res_trans.mem_add!=0) begin
				 actual_mem_add = hist_trans.item_history[i].res_trans.mem_add ; 
				break ; 
			end
		end
		
		//hc = res_trans.result;
	           exp_result = hist_trans.get_reg_data(cmd_trans.rd);///////
               exp_mem_add=rs2_data;
        //  swap_b_res={{24{0}},res_trans.result[7:0]};
				//$display("swapped_operand=%d",cmd_trans.swapped_operand);

					if(((exp_result) == (actual_result)) && (exp_mem_add==actual_mem_add))
						begin
							`uvm_info ("SWAP__BYTE_PASS", $sformatf("DUT Calculation=%d SCOREBOARD Calculation=%d DUT memory address Calculation=%0d SCOREBOARD memory address Calculation=%0d ", actual_result, exp_result,actual_mem_add,exp_mem_add), UVM_LOW)
						end
					else
						begin
							`uvm_error("SWAP_bYTE_FAIL", $sformatf("DUT Calculation=%0d SCOREBOARD Calculation=%0d DUT memory address Calculation=%0d SCOREBOARD memory address Calculation=%0d ",actual_result,exp_result,actual_mem_add,exp_mem_add))
						end
	end
endfunction