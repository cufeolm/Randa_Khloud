function void verify_Multiply(GUVM_sequence_item cmd_trans,GUVM_result_transaction res_trans,GUVM_history_transaction hist_trans);
	bit [31:0]reg_data,i1,i2,exp_res,actual_res,exp_mem_add,actual_mem_add ;
    bit [4:0]reg_add;
    bit[2:0] i;
	bit [31:0]rs1_data;
    reg_data = i1*i2;
    reg_add = cmd_trans.rd;
    //exp_res= reg_data;
    if (cmd_trans.SOM == SB_HISTORY_MODE)
	begin	
		
		hist_trans.loadreg(reg_data,reg_add);
	end
	else if (cmd_trans.SOM == SB_VERIFICATION_MODE)begin
		foreach(hist_trans.item_history[i]) begin
			if (hist_trans.item_history[i].res_trans.result!=0) begin
				 actual_res = hist_trans.item_history[i].res_trans.result ; 
				//break ; 
			end
		end
		/*foreach(hist_trans.item_history[i]) begin
			if (hist_trans.item_history[i].res_trans.mem_add!=0) begin
				 actual_mem_add = hist_trans.item_history[i].res_trans.mem_add ; 
				break ; 
			end
		end*/
		exp_res = hist_trans.get_reg_data(cmd_trans.rd);
		//exp_mem_add = rs1_data+cmd_trans.simm;
		//$display("1st load r[%d] 2nd load r[%d] data=%h store r[%d]",cmd_trans.rs1,cmd_trans.rs2,cmd_trans.data,cmd_trans.rd);
		//$display("simm=%h %d",cmd_trans.simm,cmd_trans.simm);
		$display ("exp_res=%0d", exp_res);
		if(exp_res == actual_res)
		begin
			`uvm_info ("MUL_PASS", $sformatf("DUT result Calculation=%0d SB result Calculation=%0d",actual_res,exp_res), UVM_LOW)
		end
		else
		begin
			`uvm_error("MUL_FAIL", $sformatf("DUT result Calculation=%0d SB result Calculation=%0d",actual_res,exp_res))
		end
	end
endfunction