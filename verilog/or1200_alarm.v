//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's Privilege Checker - alarm module                   ////
////                                                              ////
////  This file is part of Tim's A2 Thwart as a part of the       ////
////    CFAR Lab at UM.                                           ////
////                                                              ////
////  Description                                                 ////
////  Takes the results of tests from the other checker modules   ////
////    and signals an alarm if there is an error. 				  ////
////                                                              ////
////  To Do:                                                      ////
////   - 										                  ////
////                                                              ////
////  Author(s):                                                  ////
////      - Timothy Linscott, timlinsc@umich.edu                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "or1200_defines.v"

module or1200_alarm(
	//clk
	clk,

	//from cpu-level checker
	sr_ok, pipeline_ok, mmus_ok, secure_supv,

	// from top-level checker
	immu_fault_ok, dmmu_fault_ok, supv_consistent,

	//output signal
	alarm
);

input clk;

//from cpu-level checker
input sr_ok;
input pipeline_ok;
input mmus_ok;
input[2:0] secure_supv;

// from top-level checker
input immu_fault_ok;
input dmmu_fault_ok;
input supv_consistent;

output alarm;

//
// Trigger an alarm when any of the assertions fail
//
assign alarm = !(immu_fault_ok & dmmu_fault_ok & supv_consistent & sr_ok & 
                    pipeline_ok & mmus_ok) ;

endmodule
