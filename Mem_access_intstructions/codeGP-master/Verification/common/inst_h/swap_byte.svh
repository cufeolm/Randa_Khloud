function void verify_swap_byte(target_seq_item cmd_trans,GUVM_result_transaction res_trans);
	bit [31:0]he,h1,swap_b_res;
	he = res_trans.result;
	h1 = cmd_trans.swapped_operand;
    

swap_b_res={{24{0}},res_trans.result[7:0]};
				$display("swapped_operand=%d",cmd_trans.swapped_operand);
					h1 =   {{24{0}}, cmd_trans.swapped_operand[7:0]};
					//{{(32-immediate){cmd_trans.inst[immediate-1]}}, cmd_trans.inst[immediate-1:0]};
					if((h1) ==swap_b_res)
						begin
							`uvm_info ("SWAP_BYTE_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", swap_b_res, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("SWAP_BYTE_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", swap_b_res, h1))
						end
endfunction