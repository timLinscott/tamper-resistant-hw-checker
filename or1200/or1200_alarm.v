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

`include "/home/timlinsc/A2-master/fpga_hardware/cores/or1200/or1200_defines.v"

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

reg alarm_sig;

//
// Trigger an alarm when any of the assertions fail
//
//assign alarm = ~(immu_fault_ok & dmmu_fault_ok & supv_consistent & sr_ok & 
 //                   pipeline_ok & mmus_ok) ;

assign alarm = alarm_sig;


always @(*) begin
	casex({sr_ok, pipeline_ok, mmus_ok, immu_fault_ok, dmmu_fault_ok, supv_consistent})
		6'b0?????: alarm_sig <= 1;
		6'b?0????: alarm_sig <= 1;
		6'b??0???: alarm_sig <= 1;
		6'b???0??: alarm_sig <= 1;
		6'b????0?: alarm_sig <= 1;
		6'b?????0: alarm_sig <= 1;
		default: alarm_sig <= 0;
	endcase
end //always

endmodule
