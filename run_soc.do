
vlib work
vsim -voptargs=+acc work.soc_top -classdebug -uvmcontrol=all -cover
# Add a divider for global signals
add wave -divider "Global Signals"
add wave -color White soc_top/clk
add wave -color Yellow soc_top/rstn

# Add a divider for testbench control
add wave -divider "Testbench Control"
add wave -color Cyan soc_top/start_test
add wave -color Cyan soc_top/ins_type
add wave -color Cyan soc_top/address
add wave -color Cyan soc_top/data_to_write
add wave -color Orange soc_top/test_done

# Add a divider for the CPU Master's FSM state
add wave -divider "CPU Master FSM"
add wave -color Magenta soc_top/cpu_inst/cs

# Add a divider for the AXI Write Channels
add wave -divider "AXI Write Channels"
add wave -color Gold soc_top/axi_awaddr
add wave -color Gold soc_top/axi_awvalid
add wave -color Gold soc_top/axi_awready
add wave -color SpringGreen soc_top/axi_wdata
add wave -color SpringGreen soc_top/axi_wvalid
add wave -color SpringGreen soc_top/axi_wready
add wave -color Violet soc_top/axi_bvalid
add wave -color Violet soc_top/axi_bready

# Add a divider for the AXI Read Channels
add wave -divider "AXI Read Channels"
add wave -color DodgerBlue soc_top/axi_araddr
add wave -color DodgerBlue soc_top/axi_arvalid
add wave -color DodgerBlue soc_top/axi_arready
add wave -color Salmon soc_top/axi_rdata
add wave -color Salmon soc_top/axi_rvalid
add wave -color Salmon soc_top/axi_rready
coverage save soc_top.ucdb -onexit
run -all