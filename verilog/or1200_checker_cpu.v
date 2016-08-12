//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's Privilege Checker - CPU Level                      ////
////                                                              ////
////  This file is part of Tim's A2 Thwart as a part of the       ////
////    CFAR Lab at UM.                                           ////
////                                                              ////
////  Description                                                 ////
////  Checker to watch for HTs performing privilege escalation    ////
////     operates on signals in the or1200_cpu module		  ////
////                                                              ////
////  To Do:                                                      ////
////   - 							  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Timothy Linscott, timlinsc@umich.edu                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "or1200_defines.v"

`define OR1200_OPCODE `OR1200_OPERAND_WIDTH-1:`OR1200_OPERAND_WIDTH-6

module or1200_checker_cpu(
	  // Clock and reset
	  clk, rst,

	  // Direct connection to SR
	  sr_in, sr_out, sr_rst, sr_clk, spr_we, spr_addr, du_write, ex_spr_write, flag_we,
	   cy_we, ov_we, spr_dat_o, esr,

      // CPU connections
      from_sr, to_sr, sr_we, branch_op, except_started, except_flushpipe,

      // MMU connections 
      immu_en, dmmu_en, sr_dmmu, sr_immu,

      // Instructions to watch
      if_instr, ex_instr, wb_instr, if_freeze, id_freeze, ex_freeze,
      if_flushpipe, id_flushpipe, ex_flushpipe, wb_flushpipe,

      // Interrupt connections
      except_type,

      // Outputs
      sr_ok, pipeline_ok, mmus_ok, secure_supv
	 );

	parameter countdown_max = 4'he;

   //
   // Clock and reset
   //
   input	clk;
   input	rst;

   // Direct connection to SR
   input sr_in;  //from sprs, SR[SM] only
   input sr_out;
   input sr_rst;
   input sr_clk;
   input spr_we; 
   input[`OR1200_OPERAND_WIDTH-1:0] spr_addr;
   input du_write;
   input ex_spr_write;
   input flag_we;
   input cy_we;
   input ov_we;
   input [`OR1200_OPERAND_WIDTH-1:0] spr_dat_o;
   input [`OR1200_SR_WIDTH-1:0] esr;

   // CPU connections
   input from_sr;
   input to_sr;
   input sr_we;
   input [`OR1200_BRANCHOP_WIDTH-1:0] branch_op;
   input except_started;
   input except_flushpipe;
   
   // MMU checks
   input immu_en;
   input dmmu_en;
   input sr_dmmu;
   input sr_immu;

   // Instructions to watch (pipe is IF, OD, EX, MEM, WB)
   input [`OR1200_OPERAND_WIDTH-1:0] if_instr;
   input [`OR1200_OPERAND_WIDTH-1:0] ex_instr;
   input [`OR1200_OPERAND_WIDTH-1:0] wb_instr;
   input if_freeze; 
   input id_freeze;
   input ex_freeze;
   input if_flushpipe; 
   input id_flushpipe;
   input ex_flushpipe;
   input wb_flushpipe;

   // Interrupt connections
   input [`OR1200_EXCEPT_WIDTH-1:0]  except_type;
   
   //
   // Output signals
   //
   output sr_ok;
   output pipeline_ok;
   output mmus_ok;
   output[2:0] secure_supv; //sends a bitstring of even parity when 1, else odd parity

 wire sr_sel;
 wire [31:0] unqualified_cs, spr_cs_write_only;
 wire sr_we_check, sr_we_ok, clk_ok,  ex_ok, flush_ok, countdown_live;
 wire supv_consistent, sr_in_consistent, usr_mode_privs_recognized;

 reg supv_reg; //mimics the supervisor bit of the SR

 reg[2:0] mtspr_in_pipe; // Of IF, ID, EX, this vector stores which are processing a l.mtspr
 reg[3:0] except_countdown;

  //
  // IMPLEMENTATION
  //
  assign sr_ok = sr_in_consistent & sr_we_ok & clk_ok;
  assign pipeline_ok = supv_consistent & flush_ok & countdown_live;
  assign mmus_ok = (dmmu_en == sr_dmmu) & (immu_en == sr_immu & ~except_started);
  assign secure_supv = (~supv_reg & ^mtspr_in_pipe) | (supv_reg & ~^mtspr_in_pipe) ? ~mtspr_in_pipe : mtspr_in_pipe;

  // Directly check supervision register
  always @(posedge sr_clk or `OR1200_RST_EVENT sr_rst)
  begin
    if(sr_rst == `OR1200_RST_VALUE)
      supv_reg <= 1;
    else if (sr_we | except_started) begin
      supv_reg <= sr_in;
    end
  end

  assign unqualified_cs = 32'b1 << spr_addr[`OR1200_SPR_GROUP_BITS];

  assign spr_cs_write_only = unqualified_cs & {32{du_write | (ex_spr_write & supv_reg)}};

  assign sr_sel = (spr_cs_write_only[`OR1200_SPR_GROUP_SYS] && (spr_addr[10:0] == `OR1200_SPR_SR));

  // Check that cpu output to_sr == sprs input to_sr w.r.t. supv
  assign sr_in_consistent = ((except_started | ((branch_op == `OR1200_BRANCHOP_RFE) & esr[`OR1200_SR_SM]) 
            | (spr_we & sr_sel & spr_dat_o[`OR1200_SR_SM]) | sr_out) == sr_in);

  assign supv_consistent = (supv_reg == sr_out) & (sr_out == !sr_rst);

  assign sr_we_check = (spr_we && sr_sel && mtspr_in_pipe[2]) | (branch_op == `OR1200_BRANCHOP_RFE) | 
      flag_we | cy_we | ov_we;

  assign sr_we_ok = sr_we == sr_we_check;

  assign clk_ok = clk == sr_clk;

  // Check instruction pipeline for a legitimate reason to write to the SR
  always @(posedge clk or posedge rst) begin
  	if (rst) begin
  		// reset
  		mtspr_in_pipe = 3'b0;
  	end
  	else begin
  		//l.mtspr in EX stage
  		if(!ex_freeze & id_freeze | ex_flushpipe) begin
  			mtspr_in_pipe[2] = 0; //NOP added to pipeline
  		end
  		else if (!ex_freeze)
  			mtspr_in_pipe[2] = mtspr_in_pipe[1];

  		//l.mtspr in ID stage
  		if(!id_freeze & if_freeze | id_flushpipe) begin
  			mtspr_in_pipe[1] = 0; //NOP added to pipeline
  		end
  		else if (!id_freeze)
  			mtspr_in_pipe[1] = mtspr_in_pipe[0];
  			
  		if(if_flushpipe) begin
  			mtspr_in_pipe[2] = 0;
  		end
  		else if (!if_freeze)
  			mtspr_in_pipe[0] = if_instr[`OR1200_OPCODE] == `OR1200_OR32_MTSPR;	
  	end
  end

  /* *_flushpipe = except_flushpipe | pc_we | extend_flush | du_flush_pipe
   *  except_flushpipe = = |except_trig & ~|state;
   *  pc_we = (du_write && (npc_sel | ppc_sel));  // Debug unit-controlled
   *  extend_flush = except_flushpipe | (~except_flushpipe & pc_we)
   */
  assign flush_ok = (except_flushpipe == if_flushpipe & if_flushpipe == ex_flushpipe & ex_flushpipe == wb_flushpipe) &
                    (if_flushpipe ? if_instr[`OR1200_OPCODE] == `OR1200_OR32_NOP : 1'b1) &
                    (ex_flushpipe ? ex_instr[`OR1200_OPCODE] == `OR1200_OR32_NOP : 1'b1) &
                    (wb_flushpipe ? wb_instr[`OR1200_OPCODE] == `OR1200_OR32_NOP : 1'b1);

  always @(posedge clk or posedge rst) begin
  	if (rst) begin
  		// reset
  		except_countdown = 0;
  	end
  	else if (clk & except_type == `OR1200_EXCEPT_TICK) begin  			
  		except_countdown = except_countdown + 1;
  	end
  end

  assign countdown_live = (except_countdown < countdown_max);
endmodule // or1200_checker
