function void verify_load_from_alternate_space(GUVM_sequence_item cmd_trans,GUVM_result_transaction res_trans,GUVM_history_transaction hist_trans);
bit [31:0]reg_data,i1,i2,h1,hc ;
    bit [4:0]reg_add;
    reg_data = cmd_trans.data;
    reg_add = cmd_trans.rd;
    //h1= reg_data;
    if (cmd_trans.SOM == SB_HISTORY_MODE)
	begin	
		hist_trans.loadreg(reg_data,reg_add);

	end
	else if (cmd_trans.SOM == SB_VERIFICATION_MODE)begin
		foreach(hist_trans.item_history[i])begin
			if (hist_trans.item_history[i].res_trans.result!==0) begin
				 hc = hist_trans.item_history[i].res_trans.result ; 
				 break ; 
			end
		end
		h1 = hist_trans.get_reg_data(cmd_trans.rd);
		if((h1) == (hc))
		begin
			`uvm_info ("load_from_alternate_space_PASS", $sformatf("DUT Calculation=%h SB Calculation=%h ", hc, h1), UVM_LOW)
		end
		else
		begin
			`uvm_error("load_from_alternate_space_FAIL", $sformatf("DUT Calculation=%h SB Calculation=%h ", hc, h1))
		end
	end







endfunction