interface GUVM_interface(input  i_clk );
    import target_package::*; // importing amber core package
    import uvm_pkg::*;
`include "uvm_macros.svh"

    // core interface ports
    logic       clk_pseudo;
    logic       i_irq;
    logic       i_firq;
    logic       i_system_rdy;

    logic [31:0] o_wb_adr;
    logic [15:0] o_wb_sel;
    logic o_wb_we;
    logic [127:0] i_wb_dat;
    logic [127:0] o_wb_dat;
    logic o_wb_cyc;
    logic o_wb_stb;
    logic i_wb_ack;
    logic i_wb_err;

    // temp. registers
    logic [3:0] Rd;
    logic [3:0] indicator;
    logic [31:0] data_in;


    // declaring the monitor
    GUVM_result_monitor result_monitor_h;

    command_monitor command_monitor_h;

    logic [31:0]next_pc;

    bit allow_pseudo_clk;

    initial begin
        clk_pseudo = 0;
        allow_pseudo_clk = 0 ;
    end 
    always @(i_clk) begin
        if (allow_pseudo_clk)begin
            //$display(clk_pseudo);
            clk_pseudo = i_clk;
        end
    end


task toggle_clk(integer i);
        allow_pseudo_clk =1 ;
        repeat(i)@(posedge clk_pseudo);
        allow_pseudo_clk =0 ;
    endtask


    task send_data(logic [31:0] data);
        data_in = data;
    endtask

    // sending instructions to the core
    task send_inst(logic [31:0] inst);
        indicator = inst[31:28]; // distinguishing the load instruction: amber only
        Rd = inst[15:12]; // destination register address bits: 4 bits 
        if(indicator == 4'b1111) begin // accessing the register file by forcing
            i_wb_dat = {96'hF0801003F0801003F0801003, inst};
            case(Rd)
                4'b0000: dut.u_execute.u_register_bank.r0 = data_in;
                4'b0001: dut.u_execute.u_register_bank.r1 = data_in;
                4'b0010: dut.u_execute.u_register_bank.r2 = data_in;
                4'b0011: dut.u_execute.u_register_bank.r3 = data_in;
                4'b0100: dut.u_execute.u_register_bank.r4 = data_in;
                4'b0101: dut.u_execute.u_register_bank.r5 = data_in;
                4'b0111: dut.u_execute.u_register_bank.r6 = data_in;
                4'b1000: dut.u_execute.u_register_bank.r7 = data_in;
                default: $display("Error in SEL");
            endcase
        end else begin
            i_wb_dat = {96'hF0801003F0801003F0801003, inst};
        end
    endtask


function void update_command_monitor(GUVM_sequence_item cmd);
        //cmd.current_pc=icache_input.rpc;
        command_monitor_h.write_to_cmd_monitor(cmd);

    endfunction
    function void update_result_monitor();
        //result_monitor_h.write_to_monitor(dcache_input.edata,next_pc);
        result_monitor_h.write_to_monitor(o_wb_adr,next_pc);
    endfunction

function logic[31:0] get_cpc();//////////////////////////////////////////////////////////
      $display("current_pc = %b  %t", o_wb_adr,$time);
      return o_wb_adr;
    endfunction

    task get_npc();///////////////////////////////////////////////////////////////////////////
      //toggle_clk(1);
      $display("next_pc = %b    %t", o_wb_adr,$time);
      next_pc = o_wb_adr;
    endtask

function logic [127:0] receive_data();//should be protected
        $display("result: %h", o_wb_dat);
        result_monitor_h.write_to_monitor(o_wb_dat,next_pc);
        return o_wb_dat;
    endfunction 


task reset_dut();
        // amber does not have a reset signal in the core interface
    endtask : reset_dut

function void nop();
        i_wb_dat = 32'b11110000100000000001000000000011;
    endfunction

task set_Up();
        i_irq = 1'b0;
        i_firq = 1'b0;
        i_system_rdy = 1'b1;
        i_wb_ack = 1'b1;
        i_wb_err = 1'b0;
        toggle_clk(10);
    endtask: set_Up


    endinterface: GUVM_interface


























