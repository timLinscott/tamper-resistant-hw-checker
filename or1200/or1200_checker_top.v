//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's Privilege Checker - top Level                      ////
////                                                              ////
////  This file is part of Tim's A2 Thwart as a part of the       ////
////    CFAR Lab at UM.                                           ////
////                                                              ////
////  Description                                                 ////
////  Checker to watch for HTs performing privilege escalation    ////
////     operates on signals in the or1200_top module			        ////
////                                                              ////
////  To Do:                                                      ////
////   - 				                     						                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Timothy Linscott, timlinsc@umich.edu                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////


`include "or1200_defines.v"

module or1200_checker_top(
	// Clock and reset
	clk, rst,

	secure_supv,

	// IMMU connections
	supv_im, itlb_done, itlb_uxe, itlb_sxe, immu_err, icpu_tag,

	// DMMU connections
	supv_dm, dcpu_we_i, dtlb_ure, dtlb_sre, dtlb_uwe, dtlb_swe, dtlb_done, dmmu_err, dcpu_tag_o,

	// Outputs
	immu_fault_ok, dmmu_fault_ok, supv_consistent

);

// Clock and reset
input clk;
input rst;

//
input[2:0] secure_supv;

// IMMU connections
input supv_im;
input itlb_done;
input itlb_uxe;
input itlb_sxe;
input immu_err;
input [3:0] icpu_tag;

// DMMU connections
input supv_dm;
input dcpu_we_i;
input dtlb_ure;
input dtlb_sre;
input dtlb_uwe;
input dtlb_swe;
input dtlb_done;
input dmmu_err;
input [3:0] dcpu_tag_o;

// Outputs
output immu_fault_ok;
output dmmu_fault_ok;
output supv_consistent;

//
// Internals
//
wire supv;
wire immu_fault, dmmu_fault, immu_fault_ok, dmmu_fault_ok;

//
// Implementation
//

assign supv = ^secure_supv;

assign supv_consistent = supv_im == supv_dm & supv_dm == supv;

// Check MMU permissions
  assign immu_fault = itlb_done &
        (  (!supv & !itlb_uxe)    // Execute in user mode not enabled
        || (supv & !itlb_sxe));   // Execute in supv mode not enabled

  //check whether there is no PFE when one is expected
  assign immu_fault_ok = immu_fault ? immu_err & icpu_tag == `OR1200_DTAG_PE : 1;

  assign dmmu_fault = dtlb_done &
    (  (!dcpu_we_i & !supv & !dtlb_ure) // Load in user mode not enabled
       || (!dcpu_we_i & supv & !dtlb_sre) // Load in supv mode not enabled
       || (dcpu_we_i & !supv & !dtlb_uwe) // Store in user mode not enabled
       || (dcpu_we_i & supv & !dtlb_swe)); // Store in supv mode not enabled

  assign dmmu_fault_ok = dmmu_fault ? dmmu_err & dcpu_tag_o == `OR1200_DTAG_PE : 1;

  endmodule
