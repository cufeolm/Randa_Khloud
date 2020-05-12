package target_package;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    // instructions opcodes verified in this core 
    typedef enum logic [31:0] {
        LDW= 32'b11xxxxx000011xxxxx1xxxxxxxxxxxxx,
       LWfAs=32'b11xxxxx010000xxxxx0xxxxxxxxxxxxx,
        A=32'b10xxxxx000000xxxxx000000000xxxxx,
        ADDCC=32'b10xxxxx010000xxxxx000000000xxxxx,
        ADDX =32'b10xxxxx001000xxxxx000000000xxxxx,
        Ai=32'b10xxxxx000000xxxxx1xxxxxxxxxxxxx,
        Jalr_cpc=32'b10xxxxx111000xxxxx10000000001100,
        BO=32'b10xxxxx000010xxxxx000000000xxxxx,
        Jalrr=32'b10xxxxx111000xxxxx000000000xxxxx,
        NOP=32'b00000001000000000000000000000000,
        S=32'b10xxxxx000100xxxxx000000000xxxxx,
        BIE=32'b0010001010xxxxxxxxxxxxxxxxxxxxxx,
        BA= 32'b0001000010xxxxxxxxxxxxxxxxxxxxxx,
        //Bie=32'b0010001010xxxxxxxxxxxxxxxxxxxxxx,
        Store =32'b11xxxxx0001000000010000000000000,
        Load = 32'b11xxxxx0000000000010000000000000
    } opcode;
    // mutual instructions between cores have the same name so we can verify all cores using one scoreboard

    opcode si_a [] ;    // opcodes array to store enums so we can randomize and use them
    integer supported_instructions ;    // number of instructions in the array
    `include "leon_defines.sv"
	`include"GUVM.sv"   // including GUVM classes 


    // fill supported instruction array
    function void fill_si_array();
    // this does NOT  affect generalism
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
    `endif
    endfunction

    // function to determine format of verfied instruction and fill its operands
    function GUVM_sequence_item get_format (logic [31:0] inst);
        target_seq_item ay;
        GUVM_sequence_item k ;
        k = new("k");
        ay = new("ay");
        ay.inst=inst;
        ay.op = inst[31:30];
        case (ay.op)
            CALL :
                //call format1
                ay.disp30 = inst[29:0];
            SETHI_NOP_BRANCH : begin
                ay.op2 = inst[24:22];
                case (ay.op2)
                    3'b100,3'b000 :
                        //sethi & no op & unimplemnted format 2
                        begin
                            ay.rd = inst[29:25];
                            ay.imm22 = inst[21:0];
                            ay.simm = {{10{inst[21]}},inst[21:0]};
                            ay.zimm = {{10{0}},inst[21:0]};
                        end
                    3'b010, 3'b110, 3'b111 :
                        //branch & fp branch & co branch format 2
                        begin
                            ay.a = inst[29];
                            ay.cond = inst[28:25];
                            ay.disp22 = inst[21:0];
                            ay.simm = {{10{inst[21]}},inst[21:0]};
                            ay.zimm = {{10{0}},inst[21:0]};
                        end
                    default: uvm_report_error("k.instruction", "k.instruction format not defined");
                endcase
            end
            Remaining_instructions, Remaining_instructions1 : begin
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
                        ay.simm = {{19{inst[12]}},inst[12:0]};
                        ay.zimm = {{19{0}},inst[12:0]};
                    end

            end
            default: uvm_report_error("k.instruction", "k.instruction format not defined");
        endcase

        if (!($cast(k,ay)))
            $fatal(1,"failed to cast transaction to leon's transaction");
        return k;
    endfunction


    // used in if conditions to compare between (x) and (1 or 0)
    function bit xis1 (logic[31:0] a,logic[31:0] b);
    logic x;
    x = (a == b);
    if(x==1) return 1 ;
    else if (x === 1'bx)
        begin
            return 1'b1;
        end
    else
        begin
            return 1'b0;
        end
    endfunction : xis1

endpackage