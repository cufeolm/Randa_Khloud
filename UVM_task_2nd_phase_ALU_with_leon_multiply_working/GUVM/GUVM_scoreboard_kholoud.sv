`uvm_analysis_imp_decl(_mon_trans)
`uvm_analysis_imp_decl(_drv_trans)

class GUVM_scoreboard extends uvm_scoreboard;

	// register the scoreboard in the UVM factory
	`uvm_component_utils(GUVM_scoreboard);

	// analysis implementation ports
	uvm_analysis_imp_mon_trans #(GUVM_result_transaction, GUVM_scoreboard) Mon2Sb_port;
	uvm_analysis_imp_drv_trans #(target_seq_item, GUVM_scoreboard) Drv2Sb_port;

	// TLM FIFOs to store the actual and expected transaction values
	uvm_tlm_fifo #(target_seq_item) drv_fifo;
	uvm_tlm_fifo #(GUVM_result_transaction) mon_fifo;

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		//Instantiate the analysis ports and Fifo
		Mon2Sb_port = new("Mon2Sb", this);
		Drv2Sb_port = new("Drv2Sb", this);
		drv_fifo     = new("drv_fifo", this);  //BY DEFAULT ITS SIZE IS 1 BUT CAN BE UNBOUNDED by putting 0
		mon_fifo     = new("mon_fifo", this);
	endfunction : build_phase

	// write_drv_trans will be called when the driver broadcasts a transaction
	// to the scoreboard
	function void write_drv_trans (target_seq_item input_trans);
		void'(drv_fifo.try_put(input_trans));
	endfunction: write_drv_trans

	// write_mon_trans will be called when the monitor broadcasts the DUT results
	// to the scoreboard
	function void write_mon_trans (GUVM_result_transaction trans);
		void'(mon_fifo.try_put(trans));
	endfunction: write_mon_trans

	task run_phase(uvm_phase phase);
		target_seq_item cmd_trans;
		GUVM_result_transaction res_trans;
		logic [31:0] h1,i1,i2,imm,registered_inst;
		logic[31:0] inv;
		opcode saved_inst;
		integer i,index;
		integer valid;
		bit[31:0] imm_ext;
		integer h2,i3,i4;
		// bit [19:0] sign;
		forever begin
			$display("Scoreboard started");
			
			drv_fifo.get(cmd_trans);
			mon_fifo.get(res_trans);
			// `uvm_info ("READ_INSTRUCTION ", $sformatf("Expected Instruction=%h \n", exp_trans.inst), UVM_LOW)
			// mon_fifo.get(out_trans);
			i1=cmd_trans.operand1;
			i2=cmd_trans.operand2;
			registered_inst=cmd_trans.inst;
			$display("monitor_scb_result=%0d",res_trans.result);
			//imm=cmd_trans.imm_ext; 
			
			$display("Sb: inst is %b %b %b %b %b %b %b %b", cmd_trans.inst[31:28], cmd_trans.inst[27:24], cmd_trans.inst[23:20], cmd_trans.inst[19:16], cmd_trans.inst[15:12], cmd_trans.inst[11:8], cmd_trans.inst[7:4], cmd_trans.inst[3:0]);
			$display("Sb: op1=%0d ", i1);
			$display("Sb: op2=%0d", i2);
			// opcode reg_instruction;
			// `uvm_info ("SCOREBOARD ENTERED ", $sformatf("HELLO IN SCOREBOARD"), UVM_LOW);
			// target_package::reg_instruction = target_package::reg_instruction.first;
			valid = 0;
			for(i=0;i<supported_instructions;i++)
				begin
					if (xis1(cmd_trans.inst,si_a[i])) begin
						valid = 1;
						//saved_inst=si_a[i];
						index=i;
						//break;
						
					end
					// $display("LOOP ENTERED");
					// $display("reg_instruction  ::  Value of  %0s is = %0d",target_package::reg_instruction.name(),target_package::reg_instruction);
				end
				//saved_inst=si_a[index].name();
			if(valid == 0) begin
				`uvm_fatal("instruction fail", $sformatf("Sb: instruction not in pkg and its %b %b %b %b %b %b %b %b", cmd_trans.inst[31:28], cmd_trans.inst[27:24], cmd_trans.inst[23:20], cmd_trans.inst[19:16], cmd_trans.inst[15:12], cmd_trans.inst[11:8], cmd_trans.inst[7:4], cmd_trans.inst[3:0]))
			end
			$display("si_a[index].name() is %s",si_a[index].name());
			$display("index is %0d",index);
			case (si_a[index].name())
				"A":begin
				$display("index is %0d",index);
			    $display("i1=%0d , i2=%0d",i1,i2);
					h1 = i1+i2;
					$display("h1=%0d,res=%0d",h1,res_trans.result);
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("ADDITION_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("ADDITION_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
				end
				
				"S":begin
				$display("SUB_ENTERED");
				$display("i1=%0d, i2=%0d", i1,i2);
					h1 = i1-i2;
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("SUBTRACTION_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("SUBTRACTION_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
				end

				"M":begin    // amber fail
					$display("multiply");
					h1=i1*i2;
					$display("i1=%d,i2=%d,h1=%d",i1,i2,h1);
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("MULTIPLICATION_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("MULTIPLICATION_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end

				end

				"SIM":begin  // leon fail

					$display("signed_integer_multiply");
					h1=i1*i2;
					$display("i1=%d,i2=%d,h1=%d",i1,i2,h1);
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("INT MULTIPLICATION_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("INT MULTIPLICATION_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end


				end


				"Ai":begin
					$display("add_imm");
					imm_ext={{ext_bits{cmd_trans.inst[to_ext]}},cmd_trans.inst[last_imm:first_imm]};
					$display("immediate value is %0d", imm_ext);
					h1 = i1+imm_ext;
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("ADDIMMEDIATE_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("ADDIMMEDIATE_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
				end

				"Awc":begin
					$display("add_with carry");
					h1 = i1+i2;
					$display("h1=%0d,res=%0d",h1,res_trans.result);
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("ADDWITH CARRY_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("ADDWITH CARRY_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
				end

				"Aami":begin

					h1 = i1+i2;
					$display("h1=%0d,res=%0d",h1,res_trans.result);
					$display("Add and modify");
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("ADD&mod ICC_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("ADD&mod ICC_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
				end

				"UId":begin
					$display("unsigned div");
					//$cast(i3,i1);
					//$cast(i4,i2);
					$display("i1=%0d,i2=%0d",i1,i2);
					h1=i1/i2;
					$display("h1=%0d,res=%0d",h1,res_trans.result);
					

					if(h1==(res_trans.result))

						begin
							`uvm_info ("UNSIGN_DIV_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1),UVM_LOW)
						end
					else
						begin
							`uvm_error("UNSIGN_DIV_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end


				end

				"BwA":begin

					$display("bitwise and");
					h1=i1&i2;
					$display("i1=%b, i2=%b, h1=%b",i1,i2,h1);
					if(h1==(res_trans.result))

						begin
							`uvm_info ("bitwise AND_pass", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1),UVM_LOW)
						end
					else
						begin
							`uvm_error("bitwise AND_fail", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1))
						end
				end


				"BAwc":begin                       
					$display("AND with complement");
					inv= ~(i2);
					h1=i1 & inv;
					$display("h1=%b, i1=%b, i2=%b, inv=%b",h1,i1,i2,inv);
					if(h1==(res_trans.result))

						begin
							`uvm_info ("AND_with complement_pass", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1),UVM_LOW)
						end
					else
						begin
							`uvm_error("AND_with complement_fail", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1))
						end


				end


				"BX":begin                  
					$display("XOR");
					h1=i1^i2;
					$display("h1=%b, i1=%b, i2=%b",h1,i1,i2);
					if(h1==(res_trans.result))

						begin
							`uvm_info ("XOR_pass", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1),UVM_LOW)
						end
					else
						begin
							`uvm_error("XOR_fail", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1))
						end

				end

				"BO":begin           
					$display("OR");
					h1=i1|i2;
					$display("11=%b, i2=%b, h1=%b",i1,i2,h1);
					if(h1==(res_trans.result))

						begin
							`uvm_info ("OR_pass", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1),UVM_LOW)
						end
					else
						begin
							`uvm_error("OR_fail", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1))
						end
				end

				"BAI":begin

					$display("and immedite");

					imm_ext={{ext_bits{cmd_trans.inst[to_ext]}},cmd_trans.inst[last_imm:first_imm]};
					$display("immediate value is %0d", imm_ext);
					h1=i1 & imm_ext;
					$display("11=%b, i2=%b, immediate=%b,h1=%b",i1,i2,imm_ext,h1);
					if(h1==(res_trans.result))

						begin
							`uvm_info ("AND_IMMEDIATE_pass", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1),UVM_LOW)
						end
					else
						begin
							`uvm_error("AND_IMMEDIATE_fail", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1))
						end

				end
				"BAIwc":begin
					$display("and _imm_complemnt");
					imm_ext={{ext_bits{cmd_trans.inst[to_ext]}},cmd_trans.inst[last_imm:first_imm]};
					$display("immediate value is %0d", imm_ext);
					inv= ~(imm_ext);
					h1=i1&inv;
					$display("11=%b,i2=%b,immediate=%b,inv=%b,h1=%b",i1,i2,imm_ext,inv,h1);
					if(h1==(res_trans.result))

						begin
							`uvm_info ("AND_IMM_complmnt_pass", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1),UVM_LOW)
						end
					else
						begin
							`uvm_error("AND_IMM_complmnt_fail", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1))
						end

				end
				"BXI":begin
					$display("xor _imm");
					imm_ext={{ext_bits{cmd_trans.inst[to_ext]}},cmd_trans.inst[last_imm:first_imm]};
					$display("immediate value is %0d", imm_ext);
					h1=i1^(imm_ext);
					$display("11=%b,i2=%b,immediate=%b,h1=%b",i1,i2,imm_ext,h1);
					if(h1==(res_trans.result))

						begin
							`uvm_info ("XOR_IMM_pass", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1),UVM_LOW)
						end
					else
						begin
							`uvm_error("XOR_IMM_fail", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1))
						end

				end
				"BXwc":begin
					$display("xor complement");
					inv= ~(i2);
					h1=i1 ^ inv;
					$display("11=%b,i2=%b,inv=%b,h1=%b",i1,i2,inv,h1);
					if(h1==(res_trans.result))

						begin
							`uvm_info ("XOR_COMPLEMENT_pass", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1),UVM_LOW)
						end
					else
						begin
							`uvm_error("XOR_COMPLEMENT_fail", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1))
						end

				end
				
				"BXIwc":begin
					$display("xor imm complement",);
					imm_ext={{ext_bits{cmd_trans.inst[to_ext]}},cmd_trans.inst[last_imm:first_imm]};
					$display("immediate value is %0d", imm_ext);
					inv= ~(imm_ext);
					h1=i1^inv;
					$display("11=%b,i2=%b,immediate=%b,inv=%b,h1=%b",i1,i2,imm_ext,inv,h1);
					if(h1==(res_trans.result))

						begin
							`uvm_info ("XOR_IMM_complmnt_pass", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1),UVM_LOW)
						end
					else
						begin
							`uvm_error("XOR_IMM_complmnt_fail", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1))
						end

				end

				"BOI":begin
					$display("OR_IMM");
					imm_ext={{ext_bits{cmd_trans.inst[to_ext]}},cmd_trans.inst[last_imm:first_imm]};
					h1= i1 |(imm_ext);
					$display("11=%b,i2=%b,immediate=%b,h1=%b",i1,i2,imm_ext,h1);
					if(h1==(res_trans.result))

						begin
							`uvm_info ("OR_IMM_pass", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1),UVM_LOW)
						end
					else
						begin
							`uvm_error("OR_IMM_fail", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1))
						end


				end
				"BOwc":begin
					$display("OR COMPLEMENT");
					inv=~(i2);
					h1= i1|inv;
					$display("11=%b,i2=%b,inv=%b,h1=%b",i1,i2,inv,h1);
					if(h1==(res_trans.result))

						begin
							`uvm_info ("OR_COMPLEMNET_pass", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1),UVM_LOW)
						end
					else
						begin
							`uvm_error("OR_COMPLEMENT_fail", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1))
						end

				end

				"BOIwc":begin
					$display("or_imm_complement");
					imm_ext={{ext_bits{cmd_trans.inst[to_ext]}},cmd_trans.inst[last_imm:first_imm]};
					inv=~(imm_ext);
					h1= i1|inv;
					$display("11=%b,i2=%b,immediate=%b,inv=%b,h1=%b",i1,i2,imm_ext,inv,h1);
					if(h1==(res_trans.result))

						begin
							`uvm_info ("OR_IMM_complm_pass", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1),UVM_LOW)
						end
					else
						begin
							`uvm_error("OR_IMM_complm_fail", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1))
						end

				end



				default:begin
				`uvm_fatal("instruction fail", $sformatf("instruction is not add or mul or sub its %h %d", si_a[index],index))
				//$display("si_a[i] is %s",saved_inst);
				end
			endcase
			
		end
	endtask
endclass: GUVM_scoreboard
