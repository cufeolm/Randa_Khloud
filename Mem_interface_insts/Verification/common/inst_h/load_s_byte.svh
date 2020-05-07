function void verify_load_s_byte(target_seq_item cmd_trans,GUVM_result_transaction res_trans);
	bit [31:0]he,h1,load_b_res;
	he = res_trans.result;
	
    

//load_b_res={{24{res_trans.result[7]}},res_trans.result[7:0]};
				$display("swapped_operand=%d",cmd_trans.swapped_operand);
					
					  h1 ={{(24){cmd_trans.swapped_operand[7]}}, cmd_trans.swapped_operand[7:0]};
					//{{(32-immediate){cmd_trans.inst[immediate-1]}}, cmd_trans.inst[immediate-1:0]};
					if( h1 == he )
						begin
							`uvm_info ("LOAD_SIGNED_BYTE_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", he, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("LOAD_SIGNED_BYTE_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", he, h1))
						end
endfunction