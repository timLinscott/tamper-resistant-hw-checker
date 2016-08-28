add wave -position insertpoint  \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/or1200_genpc/clk \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/or1200_genpc/pcreg \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/or1200_genpc/pc
add wave -position insertpoint  \
sim:/orpsoc_testbench/dut/arbiter_dbus0/wbm0_adr_o \
sim:/orpsoc_testbench/dut/arbiter_dbus0/wbm_adr_o \
sim:/orpsoc_testbench/dut/arbiter_dbus0/wbm_dat_o \
sim:/orpsoc_testbench/dut/arbiter_dbus0/wbm_sel_o \
sim:/orpsoc_testbench/dut/arbiter_dbus0/wbm_err_i \
sim:/orpsoc_testbench/dut/arbiter_dbus0/wb_slave_sel
add wave -position insertpoint  \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/or1200_lsu/id_addrbase \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/or1200_lsu/id_addrofs \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/or1200_lsu/dcpu_adr_o \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/if_insn \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/if_pc \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/alu_op \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/alu_op2 \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/if_freeze \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/if_flushpipe \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/sr 
add wave -position insertpoint  \
sim:/orpsoc_testbench/dut/or1200_top0/supv \
sim:/orpsoc_testbench/dut/or1200_top0/alarm
add wave -position insertpoint  \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_alarm/sr_ok \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_alarm/pipeline_ok \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_alarm/mmus_ok \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_alarm/immu_fault_ok \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_alarm/dmmu_fault_ok \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_alarm/supv_consistent
add wave -position insertpoint  \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/or1200_checker_cpu/supv_reg \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/or1200_checker_cpu/sr_we \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/or1200_checker_cpu/except_started \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/or1200_checker_cpu/sr_in \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/or1200_checker_cpu/sr_in_consistent \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/or1200_checker_cpu/sr_we_ok \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/or1200_checker_cpu/clk_ok \
sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/or1200_checker_cpu/mtspr_in_pipe

#add wave -position insertpoint  \
#sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/or1200_lsu/lsu_stall \
#sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/or1200_lsu/dcpu_cycstb_o \
#sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/or1200_lsu/dcpu_rty_i \
#sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/or1200_lsu/lsu_unstall
#add wave -position insertpoint  \
#sim:/orpsoc_testbench/dut/or1200_top0/or1200_dc_top/or1200_dc_fsm/state

#Use force to simulate a hardware Trojan
#force sim:/orpsoc_testbench/dut/or1200_top0/supv 1
#force sim:/orpsoc_testbench/dut/or1200_top0/or1200_cpu/or1200_sprs/to_sr(0) 1 152525ns

run 153550ns