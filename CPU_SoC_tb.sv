//------------------------------------------------------------------
// Module: soc_top
// Description: A top-level module for a simple System-on-Chip.
//              It connects a single AXI master (CPU) to a single
//              AXI slave (Memory).
//------------------------------------------------------------------
module soc_top;

//------------------------------------------------------------------
// Parameters
//------------------------------------------------------------------
localparam int ADDR_WIDTH = 32;
localparam int DATA_WIDTH = 32;

//------------------------------------------------------------------
// Signals
//------------------------------------------------------------------

// Global Signals
logic clk;
logic rstn;

// Testbench Control Signals
logic       start_test;
logic [1:0] ins_type;
logic [ADDR_WIDTH-1:0] address;
logic [DATA_WIDTH-1:0] data_to_write;
logic       start_write;
logic       start_read;
logic       test_done;

// AXI Bus Wires (to connect master and slave)
// Write Address Channel
logic [ADDR_WIDTH-1:0]  axi_awaddr;
logic                   axi_awvalid;
logic                   axi_awready;
// Write Data Channel
logic [DATA_WIDTH-1:0]  axi_wdata;
logic                   axi_wvalid;
logic                   axi_wready;
// Write Response Channel
logic [1:0]             axi_bresp;
logic                   axi_bvalid;
logic                   axi_bready;
// Read Address Channel
logic [ADDR_WIDTH-1:0]  axi_araddr;
logic                   axi_arvalid;
logic                   axi_arready;
// Read Data Channel
logic [DATA_WIDTH-1:0]  axi_rdata;
logic [1:0]             axi_rresp;
logic                   axi_rvalid;
logic                   axi_rready;


//------------------------------------------------------------------
// Clock and Reset Generation (for simulation)
//------------------------------------------------------------------
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns period clock
end

initial begin
    rstn = 0;
    #20;
    rstn = 1;
    #10;
    start_test = 1;
    ins_type = 2'b00; // WRITE_MEM
    address = 32'h0000_0010;
    data_to_write = 32'hDEADBEEF;
    start_write = 1;
    start_read = 0;
    
    // Wait for the FSM to start
    @(posedge clk);
    start_test = 0;
    start_write = 0;

    // Wait for the test to finish
    wait(test_done);
    
    // Start a read operation to verify the write
    #20;
    ins_type = 2'b01; // READ_MEM
    address = 32'h0000_0010;
    start_read = 1;
    
    @(posedge clk);
    start_read = 0;

    wait(test_done);

    #50;
end

//------------------------------------------------------------------
// Instantiation of Modules
//------------------------------------------------------------------

// Instantiate the AXI Master (CPU)
cpu_axim_master #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) cpu_inst (
    .clk(clk),
    .rstn(rstn),
    .start_test(start_test),
    .ins_type(ins_type),
    .address(address),
    .data_to_write(data_to_write),
    .start_write(start_write),
    .start_read(start_read),
    .test_done(test_done),

    // Connect AXI master ports to the bus wires
    .M_AXI_AWADDR(axi_awaddr),
    .M_AXI_AWVALID(axi_awvalid),
    .M_AXI_AWREADY(axi_awready),
    .M_AXI_WDATA(axi_wdata),
    .M_AXI_WVALID(axi_wvalid),
    .M_AXI_WREADY(axi_wready),
    .M_AXI_BRESP(axi_bresp),
    .M_AXI_BVALID(axi_bvalid),
    .M_AXI_BREADY(axi_bready),
    .M_AXI_ARADDR(axi_araddr),
    .M_AXI_ARVALID(axi_arvalid),
    .M_AXI_ARREADY(axi_arready),
    .M_AXI_RDATA(axi_rdata),
    .M_AXI_RRESP(axi_rresp),
    .M_AXI_RVALID(axi_rvalid),
    .M_AXI_RREADY(axi_rready)
);

// Instantiate the AXI Slave (Memory)
axi_slave_memory #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) mem_inst (
    .clk(clk),
    .rstn(rstn),

    // Connect AXI slave ports to the bus wires
    .S_AXI_AWADDR(axi_awaddr),
    .S_AXI_AWVALID(axi_awvalid),
    .S_AXI_AWREADY(axi_awready),
    .S_AXI_WDATA(axi_wdata),
    .S_AXI_WVALID(axi_wvalid),
    .S_AXI_WREADY(axi_wready),
    .S_AXI_BRESP(axi_bresp),
    .S_AXI_BVALID(axi_bvalid),
    .S_AXI_BREADY(axi_bready),
    .S_AXI_ARADDR(axi_araddr),
    .S_AXI_ARVALID(axi_arvalid),
    .S_AXI_ARREADY(axi_arready),
    .S_AXI_RDATA(axi_rdata),
    .S_AXI_RRESP(axi_rresp),
    .S_AXI_RVALID(axi_rvalid),
    .S_AXI_RREADY(axi_rready)
);



endmodule
