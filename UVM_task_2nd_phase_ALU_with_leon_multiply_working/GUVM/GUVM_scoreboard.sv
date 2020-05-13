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
		drv_fifo     = new("drv_fifo", this,4);  //BY DEFAULT ITS SIZE IS 1 BUT CAN BE UNBOUNDED by putting 0
		mon_fifo     = new("mon_fifo", this,4);
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
		bit [31:0] h1,i1,i2,imm,registered_inst;
		bit [63:0] MULT_expected;
		bit [32:0] ADD_carry_expected;
		bit carry;
		bit [31:0] swap__b_res;
		
		opcode saved_inst;
		integer i,index;
		integer valid;
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
			
			$display("Sb: inst is %b %b %b %b %b %b %b %b", cmd_trans.inst[31:28], cmd_trans.inst[27:24], cmd_trans.inst[23:20], cmd_trans.inst[19:16], cmd_trans.inst[15:12], cmd_trans.inst[11:8], cmd_trans.inst[7:4], cmd_trans.inst[3:0]);
			$display("Sb: op1=%0b ", i1);
			$display("Sb: op2=%0b", i2);
		//	$display("Sb: result=%0b", res_trans.result);
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
					h1 = i1+i2;
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("ADDITION_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("ADDITION_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
				end
				"Ai":begin
					$display("add_imm");
					//imm={cmd_trans.inst[31:20],{(32-immediate){cmd_trans.inst[19]}}};
					$display("immediate value is %0d", imm);
				//	h1 = i1+imm;
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("ADDIMMEDIATE_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("ADDIMMEDIATE_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
				end
				
				"Aami":begin
				$display("index is %0d",index);
					h1 = i1+i2;
				
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("ADDITION_AND_MODIFY_ICC_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("ADDITION_AND_MODIFY_ICC_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
				end
				
				"Aiami":begin
				$display("Sim_ENTERED");
				//i2=cmd_trans.operand_imm;
				$display("Sb: imm_oprand=%0d", i2);
				imm={{(32-immediate){cmd_trans.inst[immediate-1]}}, cmd_trans.inst[immediate-1:0]};
				$display("Sb: imm=%0d", imm);
					h1 = i1+imm;
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("ADDITION_AND_MODIFY_ICC_IMMEDIATE_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("ADDITION_AND_MODIFY_ICC_IMMEDIATE_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
				end
				
				
				"Awc":begin
				$display("index is %0d",index);
					ADD_carry_expected = i1+i2;
					carry =ADD_carry_expected[32];
					h1 = ADD_carry_expected+carry; 
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("ADDITION_WITH_CARRY_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("ADDITION_WITH_CARRY_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
				end
				
				"S":begin
				$display("SUB_ENTERED");
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
				
				"Rs":begin
				$display("SUB_ENTERED");
					h1 = i2-i1;
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("REVERSE_SUBTRACTION_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("REVERSE_SUBTRACTION_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
				end
				
				
				
				"Sim":begin
				$display("Sim_ENTERED");
				//i2=cmd_trans.operand_imm;
				$display("Sb: imm_oprand=%0d", i2);
				imm={{(32-immediate){cmd_trans.inst[immediate-1]}}, cmd_trans.inst[immediate-1:0]};
				$display("Sb: imm=%0d", imm);
					h1 = i1-imm;
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("SUBTRACTION_IMMEDIATE_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("SUBTRACTION_IMMEDIATE_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
				end
				
				
				
				
				
				"C":begin
				$display("comp_ENTERED");
					h1 = i2-i1;
					//imm={{(32-immediate){cmd_trans.inst[immediate-1]}}, cmd_trans.inst[immediate-1:0]};
				  //  $display("Sb: imm=%0d", imm);
					//h1 = i1-imm;
			          //h1 = i1-cmd_trans.inst[immediate-1:0];
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("COMPARE_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("COMPARE_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
					end
				"CN":begin
				$display("COMP_NEGATIVE_ENTERED");
					//h1 = i1+(~i2+1);
					imm={{(32-immediate){cmd_trans.inst[immediate-1]}}, cmd_trans.inst[immediate-1:0]};
				$display("Sb: imm=%0b", imm);
					h1 = i1+(~cmd_trans.inst[immediate-1:0]+1);
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("COMPARE_NEGATIVE_PASS", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("COMPARE_NEGATIVE_FAIL", $sformatf("Actual Calculation=%b Expected Calculation=%b ", res_trans.result, h1))
						end		
						
						
						
						
				end
				"M":begin
				$display("MULTIPLY_ENTERED");
					h1 = i1*i2;
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("MULTIPLCATION_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("MULTIPLCATION_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
				
				end
				
				"Mh":begin
				//$display("MULTIPLY_ENTERED");
					//MULT_expected = (i1*i2)>>32;
					//h1 =(((~i1)+1)*(unsigned'(i2)))>>32;
					MULT_expected =(((~signed'(i1))+1)*((~signed'(i2))+1))>>32;
					
					if((MULT_expected) == (res_trans.result))
						begin
							`uvm_info ("MULTIPLCATION_HIGH_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, MULT_expected), UVM_LOW)
						end
					else
						begin
							`uvm_error("MULTIPLCATION_HIGH_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, MULT_expected))
						end
				end
				
				"Mhs":begin
				//$display("MULTIPLY_ENTERED");
					//MULT_expected = (i1*i2)>>32;
					//h1 =(((~i1)+1)*(unsigned'(i2)))>>32;
					MULT_expected =(((~signed'(i1))+1)*((~unsigned'(i2))+1))>>32;
					if((MULT_expected) == (res_trans.result))
						begin
							`uvm_info ("MULTIPLCATION_HIGH_SINGED_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, MULT_expected), UVM_LOW)
						end
					else
						begin
							`uvm_error("MULTIPLCATION_HIGH_SINGED_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, MULT_expected))
						end
				end
				
				
				
				"MA":begin
				$display("MULTIPLY_ENTERED");
					h1 = i1*i2;
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("MULTIPLCATION_ACCUMELATE_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("MULTIPLCATION_ACCUMELATE_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
				end
				
				"Mhu":begin
				$display("MULTIPLY_ENTERED");
				     //unsigned'(y)
					MULT_expected = ( unsigned'(i1)* unsigned'(i2))>>32;
					if((MULT_expected) == (res_trans.result))
						begin
							`uvm_info ("MULTIPLCATION_HIGH_UNSIGNED_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, MULT_expected), UVM_LOW)
						end
					else
						begin
							`uvm_error("MULTIPLCATION_HIGH_UNSIGNED_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, MULT_expected))
						end
				end
				/*"Mhu":begin
				//$display("MULTIPLY_ENTERED");
					h1 = i1*i2;
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("MULTIPLCATION_HIGH_UNSIGNED_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("MULTIPLCATION_HIGH_UNSIGNED_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
				end*/
				
				"UIMi":begin
				$display("Sim_ENTERED");
				//i2=cmd_trans.operand_imm;
				$display("Sb: imm_oprand=%0d", i2);
				imm={{(32-immediate){cmd_trans.inst[immediate-1]}}, cmd_trans.inst[12:0]};
				$display("Sb: imm=%0d", imm);
					h1 = i1*imm;
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("UNSIGNED_IMMEDIATE_MULTIPLICATION_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("UNSIGNED_IMMEDIATE_MULTIPLICATION_Fail", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
				end
				
				"UId":begin
					$display("unsigned div");
					//$cast(i3,i1);
					//$cast(i4,i2);
					$display("i1=%0d,i2=%0d",i1,i2);
					h1=unsigned'(i1)/unsigned'(i2);
					//h1=i1/i2;
					$display("h1=%0d,res=%0h",h1,res_trans.result);
					

					if(h1==(res_trans.result))

						begin
							`uvm_info ("UNSIGN_DIV_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1),UVM_LOW)
						end
					else
						begin
							`uvm_error("UNSIGN_DIV_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
				end
				
				"SId":begin
					$display("unsigned div");
					//$cast(i3,i1);
					//$cast(i4,i2);
					$display("i1=%0d,i2=%0d",i1,i2);
					//h1=i1/i2;
					h1=(((~signed'(i1))+1)/((~signed'(i2))+1));
					$display("h1=%0d,res=%0h",h1,res_trans.result);
					

					if(h1==(res_trans.result))

						begin
							`uvm_info ("UNSIGN_DIV_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1),UVM_LOW)
						end
					else
						begin
							`uvm_error("UNSIGN_DIV_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
					end
					
				"Rem":begin
					//$display("unsigned div");
					//$cast(i3,i1);
					//$cast(i4,i2);
					$display("i1=%0d,i2=%0d",i1,i2);
					//i1=((~i1)+1);
					//i2=((~i2)+1);
					//i1=((~signed'(i1))+1);
					//i2=((~signed'(i2))+1);
					i1=unsigned'((~i1)+1);
					i2=unsigned'((~i2)+1);
					//h1=i1/i2;
					//h1=~((((~i1)+1)%((~signed'(i2))+1))+1);
					if(i1>i2)
					begin
					h1=i1-i2;
					end
					else if(i1<i2)
					begin
					h1=i1;
					end
					else
					h1=0;
					//h1=(((~unsigned'(i1))+1)%((~signed'(i2))+1));
					$display("h1=%0d,res=%0h",h1,res_trans.result);
					$display("h1=%0b",h1);

					if(h1==(res_trans.result))

						begin
							`uvm_info ("SIGNED_REMAINDER_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1),UVM_LOW)
						end
					else
						begin
							`uvm_error("SIGNED_REMAINDER_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
					end
					
				"Ru":begin
					//$display("unsigned div");
					//$cast(i3,i1);
					//$cast(i4,i2);
					$display("i1=%0d,i2=%0d",i1,i2);
					//h1=i1/i2;
					h1=(unsigned'(i1))%(unsigned'(i2));
					$display("h1=%0d,res=%0h",h1,res_trans.result);
					

					if(h1==(res_trans.result))

						begin
							`uvm_info ("UNSIGNED_REMAINDER_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1),UVM_LOW)
						end
					else
						begin
							`uvm_error("UNSIGNED_REMAINDER_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
					end
				
				
				"WfrtY":begin
					//$display("unsigned div");
					//$cast(i3,i1);
					//$cast(i4,i2);
					$display("i1=%0d,i2=%0d",i1,i2);
					//h1=i1/i2;
					h1=i1^i2;
					$display("h1=%0d,res=%0h",h1,res_trans.result);
					

					if(h1==(res_trans.result))

						begin
							`uvm_info ("UNSIGNED_REMAINDER_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1),UVM_LOW)
						end
					else
						begin
							`uvm_error("UNSIGNED_REMAINDER_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
					end
				
				
				
				
				
				
		
			
				
				"UIM":begin
				$display("MULTIPLY_ENTERED");
					h1 = i1*i2;
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("UNSIGNED_INTEGER_MULTIPLCATION_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("UNSIGNED_INTEGER_MULTIPLCATION_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
				end

				
				
				"SRwM":begin
				
					h1 = cmd_trans.swapped_operand;
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("SWAP_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("SWAP_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
						end
				end
				
				"Sabbram":begin
				swap__b_res={{24{0}},res_trans.result[7:0]};
				$display("swapped_operand=%d",cmd_trans.swapped_operand);
					h1 =   {{24{0}}, cmd_trans.swapped_operand[7:0]};
					//{{(32-immediate){cmd_trans.inst[immediate-1]}}, cmd_trans.inst[immediate-1:0]};
					if((h1) ==swap__b_res)
						begin
							`uvm_info ("SWAP_BYTE_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", swap__b_res, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("SWAP_BYTE_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", swap__b_res, h1))
						end
				end
                "SRwMas":begin
				
					h1 = cmd_trans.swapped_operand;
					if((h1) == (res_trans.result))
						begin
							`uvm_info ("SWAP_FROM_ALTERNATE_SPACE_PASS", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1), UVM_LOW)
						end
					else
						begin
							`uvm_error("SWAP_FROM_ALTERNATE_SPACE_FAIL", $sformatf("Actual Calculation=%d Expected Calculation=%d ", res_trans.result, h1))
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
