package target_package;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    typedef enum logic [31:0] {
        LDW= 32'b11xxxxx000011xxxxx1xxxxxxxxxxxxx,
        SRwM= 32'b11xxxxx001111xxxxx1xxxxxxxxxxxxx,
        SRwMas=32'b11xxxxx011111xxxxx0xxxxxxxxxxxxx,
        A=32'b10xxxxx000000xxxxx000000000xxxxx,
        Aami=32'b10xxxxx010000xxxxx000000000xxxxx,
        Aiami=32'b10xxxxx010000xxxxx1xxxxxxxxxxxxx,
        Awc=32'b10xxxxx001000xxxxx000000000xxxxx,
        Aiwc=32'b10xxxxx001000xxxxx1xxxxxxxxxxxxx,
        Awcami=32'b10xxxxx011000xxxxx000000000xxxxx,
        Aiwcami=32'b10xxxxx011000xxxxx1xxxxxxxxxxxxx,
        N=32'b00000001000000000000000000000000,
        S=32'b10xxxxx000100xxxxx000000000xxxxx,
        Store =32'b11xxxxx0001000000010000000000000,
        Load = 32'b11xxxxx0000000000010000000000000,
        UIM=32'b10xxxxx001010xxxxx000000000xxxxx,
        UIMi=32'b10xxxxx001010xxxxx1xxxxxxxxxxxxx,
        UIMami=32'b10xxxxx011010xxxxx00000000xxxxx,
        UIMiami=32'b10xxxxx011010xxxxx1xxxxxxxxxxxxx,
        UId=32'b10xxxxx001110xxxxx000000000xxxxx,
        Sim=32'b10xxxxx000100xxxxx1xxxxxxxxxxxxx,
        RP=32'b10xxxxx101001xxxxx00000000000000, //5 x bit reserved
        Sami=32'b10xxxxx010100xxxxx000000000xxxxx,
        RY=32'b10xxxxx1010000000000000000000000,
        //RP=32'b10xxxxx101001?????00000000000000,
        //Rw=32'b10xxxxx101010?????00000000000000,
       // Rt=32'b10xxxxx101011?????00000000000000,
      //  Ra=32'b10xxxxx101000xxxxx00000000000000,
        WfrtY=32'b1000000110000xxxxx000000000xxxxx,
        WfitY=32'b1000000110000xxxxx1xxxxxxxxxxxxx,
        Ai=32'b10xxxxx000000xxxxx1xxxxxxxxxxxxx
    } opcode;
    
    
    
    
    
    
    
    

/*
    typedef enum logic [31:0] {
    Load = 32'b11xxxxx0000000000010000000000000,
    //N=32'b00000001000000000000000000000000,
    Store =32'b11xxxxx0001000000010000000000000
    }special_op_t;//this op code for filling and reading the register files
*/

    opcode si_a [] ;
    opcode reg_instruction;
    integer supported_instructions ;
    parameter immediate = 13;
    //includes
	`include"GUVM.sv"



   
    


    function void fill_si_array();// fill supported instruction array
    // this does NOT  affect generalism this makes sure you dont run
    // the same function twice in a test bench
    `ifndef SET_UP_INSTRUCTION_ARRAY
        `define SET_UP_INSTRUCTION_ARRAY
        opcode si_i ; // for iteration only
        supported_instructions = si_i.num() ;
        si_a=new [supported_instructions] ;

        si_i = si_i.first();
        for (integer i=0 ; i < supported_instructions ; i++ )
            begin
                si_a [i]= si_i ;
                si_i=si_i.next();

            end
        $display("array is filled and ready to use");
    `endif
    endfunction


        function GUVM_sequence_item get_format (logic [31:0] inst);
            target_seq_item ay;
            GUVM_sequence_item k ;
            k = new("k");
            ay = new("ay");
            ay.inst=inst;
            ay.op = inst[31:30];
            case (ay.op)
                2'b01 :
                    //call format1
                    ay.disp30 = inst[29:0];
                2'b00 : begin
                    ay.op2 = inst[24:22];
                    case (ay.op2)
                        3'b100,3'b000 :
                            //sethi & no op & unimplemnted format 2
                            begin
                                ay.rd = inst[29:25];
                                ay.imm22 = inst[21:0];
                            end
                        3'b010, 3'b110, 3'b111 :
                            //branch & fp branch & co branch format 2
                            begin
                                ay.a = inst[29];
                                ay.cond = inst[28:25];
                                ay.disp22 = inst[21:0];
                            end
                        default: uvm_report_error("k.instruction", "k.instruction format not defined");
                    endcase
                end
                2'b10, 2'b11 : begin
                    ay.i = inst[13];
                    ay.rd = inst[29:25];
                    ay.op3 = inst[24:19];
                    ay.rs1 = inst[18:14];
                    if (!ay.i)
                        //format 3 register register
                        begin
                            ay.asi = inst[12:5];
                            ay.rs2 = inst[4:0];
                        end
                    else
                        //format 3 register immediate
                        begin
                            ay.imm13 = inst[12:0];
                        end

                end
                default: uvm_report_error("k.instruction", "k.instruction format not defined");
            endcase

            if (!($cast(k,ay)))
                $fatal(1,"failed to cast transaction to leon's transaction");
            return k;
        endfunction

        function bit xis1 (logic[31:0] a,logic[31:0] b);
		logic x;
		x = (a == b);
		if (x === 1'bx)
			begin
				return 1'b1;
			end
		else
			begin
				return 1'b0;
			end
	    endfunction : xis1
        
        
   
                   
    function bit memory_acc_inst(opcode si_a []);
    //$display("pkg:function");
       for(integer k=0;k<supported_instructions;k++)
       begin 
                        if ((si_a[k].name()=="SRwM") || (si_a[k].name()=="SRwMas")) // or any other instruction gets data from memory
                           // if(1)
                            begin
                            //$display("pkg:function_entered");
                            return 1'b1;
                            
                            end
                        
                            
                    
                        
        end                    
    return 1'b0;
    endfunction : memory_acc_inst















endpackage