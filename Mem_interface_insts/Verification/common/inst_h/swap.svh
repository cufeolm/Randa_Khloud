function void verify_swap(target_seq_item cmd_trans,GUVM_result_transaction res_trans);
	bit [31:0]he,h1 ;
	he = res_trans.result;
	h1 = cmd_trans.swapped_operand;
					if((h1) == (he))
						begin
							`uvm_info ("SWAP_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", he, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("SWAP_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", he, h1))
						end
endfunction