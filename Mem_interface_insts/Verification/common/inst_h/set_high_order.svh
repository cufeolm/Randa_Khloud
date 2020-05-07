function void verify_set_high_order(target_seq_item cmd_trans,GUVM_result_transaction res_trans);
logic[31:0] h1,hc;
h1={cmd_trans.inst[21:0],10'b0};
hc=res_trans.result;
					
					if(h1==(hc))
						begin
							`uvm_info ("SET HIGH ORDER_pass", $sformatf("Actual Calculation=%0d Expected Calculation=%0d ", hc, h1),UVM_LOW)
						end
					else
						begin
							`uvm_error("SET HIGH ORDER_fail", $sformatf("Actual Calculation=%0d Expected Calculation=%0d ", hc, h1))
						end
endfunction