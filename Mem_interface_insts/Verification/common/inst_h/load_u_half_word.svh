function void verify_load_u_half_word(target_seq_item cmd_trans,GUVM_result_transaction res_trans);
	bit [31:0]he,h1,atm_b_res;
	he = res_trans.result;
	
    

//atm_b_res={{24{0}},res_trans.result[7:0]};
				$display("swapped_operand=%d",cmd_trans.swapped_operand);
					h1 =   {{16{0}}, cmd_trans.swapped_operand[15:0]};
					if((h1) ==he)
						begin
							`uvm_info ("LOAD_UNSIGNED_HALF_WORD_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%b ", he, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("LOAD_UNSIGNED_HALF_WORD_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%b ", he, h1))
						end
endfunction