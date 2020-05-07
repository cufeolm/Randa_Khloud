function void verify_load_word_ans(target_seq_item cmd_trans,GUVM_result_transaction res_trans);
	bit [31:0]he,h1,load_b_res;
	he = res_trans.result;


					
					 h1 =cmd_trans.swapped_operand;
					  //h1 =cmd_trans.swapped_operand[15:0];
					//{{(32-immediate){cmd_trans.inst[immediate-1]}}, cmd_trans.inst[immediate-1:0]};
					if( h1 == he )
						begin
							`uvm_info ("LOAD_WORD_ALTERNATE_SPACE_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", he, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("LOAD_WORD_ALTERNATE_SPACE_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", he, h1))
						end
endfunction