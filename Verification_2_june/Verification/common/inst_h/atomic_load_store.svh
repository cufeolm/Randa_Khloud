function void verify_atomic_load_store(GUVM_sequence_item cmd_trans,GUVM_result_transaction res_trans,GUVM_history_transaction hist_trans);
	bit [31:0]actual_result,exp_result,h2,actual_mem_add,exp_address,rs1_data;
	bit [4:0]reg_add;
	bit [31:0] reg_data;
	bit [5:0]i;
	reg_add = cmd_trans.rd;
	
	//hc = res_trans.result;
	//reg_data = cmd_trans.data[7:0];
	//he = res_trans.result;
//	h1 = cmd_trans.swapped_operand;
if (cmd_trans.SOM == SB_HISTORY_MODE)
	begin	
		hist_trans.loadreg({{24{0}},cmd_trans.data[7:0]},cmd_trans.rd);
        rs1_data = hist_trans.get_reg_data(cmd_trans.rs1);		
	end
	
	else if (cmd_trans.SOM == SB_VERIFICATION_MODE)begin
	    foreach(hist_trans.item_history[i])begin
			if (hist_trans.item_history[i].res_trans.result!==0) begin
				 actual_result = hist_trans.item_history[i].res_trans.result ; 
				// break ; 
			end
		end
		
		foreach(hist_trans.item_history[i])begin
			if (hist_trans.item_history[i].res_trans.mem_add!==0) begin
				 actual_mem_add = hist_trans.item_history[i].res_trans.mem_add ; 
				 break ; 
			end
		end
		
		
		
		
		//hc = res_trans.result;
	           exp_result = hist_trans.get_reg_data(cmd_trans.rd);///////
               exp_address=rs1_data+cmd_trans.simm;

					if((exp_result == actual_result) && (exp_address== actual_mem_add) )
						begin
							`uvm_info ("ATOMIC_LOAD_STORE_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d Actual Address=%h Expected Address=%h", actual_result, exp_result,actual_mem_add, exp_address), UVM_LOW)
						end
					else
						begin
							`uvm_error("ATOMIC_LOAD_STORE_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d Actual Address=%h Expected Address=%h", actual_result, exp_result,actual_mem_add, exp_address))
						end
	end					
endfunction