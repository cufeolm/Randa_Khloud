function void verify_load_u_byte_ans(target_seq_item cmd_trans,GUVM_result_transaction res_trans);
	bit [31:0]he,h1,atm_b_res;
	he = res_trans.result;
	
    

//atm_b_res={{24{0}},res_trans.result[7:0]};
				$display("swapped_operand=%d",cmd_trans.swapped_operand);
					h1 =   {{24{0}}, cmd_trans.swapped_operand[7:0]};
					if((h1) ==he)
						begin
							`uvm_info ("LOAD_UNSIGNED_BYTE_ALTERNATE_SPACE_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", he, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("LOAD_UNSIGNED_BYTE_ALTERNATE_SPACE_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", he, h1))
						end
endfunction