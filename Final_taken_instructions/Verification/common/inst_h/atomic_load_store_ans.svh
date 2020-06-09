function void verify_atomic_load_store_ans(GUVM_sequence_item cmd_trans,GUVM_result_transaction res_trans,GUVM_history_transaction hist_trans);
	bit [31:0]hc,h1,h2,actual_result,exp_result,op,exp_mem_add,actual_mem_add,rs1_data,rs2_data;
	bit [4:0]reg_add;
	bit [31:0] reg_data;
	bit [5:0]i;
	
	//hc = res_trans.result;
	
	//he = res_trans.result;
//	h1 = cmd_trans.swapped_operand;

if (cmd_trans.SOM == SB_HISTORY_MODE)
	begin
	rs1_data = hist_trans.get_reg_data(cmd_trans.rs1);
	rs2_data = hist_trans.get_reg_data(cmd_trans.rs2);
    op= rs1_data+rs2_data;	
	    case(op[1:0])
	        2'b00:reg_data = {{24{0}},{cmd_trans.data[31:24]}};
			2'b01:reg_data = {{24{0}},{cmd_trans.data[23:16]}};
			2'b10:reg_data = {{24{0}},{cmd_trans.data[15:8]}};
			2'b11:reg_data = {{24{0}},{cmd_trans.data[7:0]}};
		endcase
		reg_add = cmd_trans.rd;
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
			if (hist_trans.item_history[i].res_trans.mem_add!=0) begin
				 actual_mem_add = hist_trans.item_history[i].res_trans.mem_add ; 
				break ; 
			end
		end
		exp_mem_add= rs1_data+rs2_data;
		exp_result= hist_trans.get_reg_data(cmd_trans.rd);
		
					if(((exp_result) == (actual_result)) && (exp_mem_add==actual_mem_add))
						begin
							`uvm_info ("ATOMIC_LOAD_STORE_ANS_PASS", $sformatf("DUT Calculation=%b SCOREBOARD Calculation=%b DUT memory address Calculation=%0d SCOREBOARD memory address Calculation=%0d ", actual_result, exp_result,actual_mem_add,exp_mem_add), UVM_LOW)
						end
					else
						begin
							`uvm_error("ATOMIC_LOAD_STORE_ANS_FAIL", $sformatf("DUT Calculation=%0b SCOREBOARD Calculation=%0b DUT memory address Calculation=%0d SCOREBOARD memory address Calculation=%0d ",actual_result,exp_result,actual_mem_add,exp_mem_add))
						end
	end					
endfunction