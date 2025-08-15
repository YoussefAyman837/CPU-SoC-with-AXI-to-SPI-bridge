//------------------------------------------------------------------
// Module: axi_slave_memory
// Description: A simple AXI-Lite slave that acts as a memory block.
//              It responds to read and write requests from an AXI master.
//------------------------------------------------------------------
module axi_slave_memory #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int MEM_DEPTH  = 256 // 256 locations of 32-bit data
) (
    // Global Signals
    input  logic                   clk,
    input  logic                   rstn,

    // AXI-Lite Slave Interface
    // Write Address Channel
    input  logic [ADDR_WIDTH-1:0]  S_AXI_AWADDR,
    input  logic                   S_AXI_AWVALID,
    output logic                   S_AXI_AWREADY,

    // Write Data Channel
    input  logic [DATA_WIDTH-1:0]  S_AXI_WDATA,
    input  logic                   S_AXI_WVALID,
    output logic                   S_AXI_WREADY,

    // Write Response Channel
    output logic [1:0]             S_AXI_BRESP,
    output logic                   S_AXI_BVALID,
    input  logic                   S_AXI_BREADY,

    // Read Address Channel
    input  logic [ADDR_WIDTH-1:0]  S_AXI_ARADDR,
    input  logic                   S_AXI_ARVALID,
    output logic                   S_AXI_ARREADY,

    // Read Data Channel
    output logic [DATA_WIDTH-1:0]  S_AXI_RDATA,
    output logic [1:0]             S_AXI_RRESP,
    output logic                   S_AXI_RVALID,
    input  logic                   S_AXI_RREADY
);

//------------------------------------------------------------------
// Internal Signals and Memory
//------------------------------------------------------------------

// The actual memory block
logic [DATA_WIDTH-1:0] mem [MEM_DEPTH-1:0];

// Internal registers to latch address and data
logic [ADDR_WIDTH-1:0] awaddr_reg;
logic [ADDR_WIDTH-1:0] araddr_reg;
logic [DATA_WIDTH-1:0] wdata_reg;

// Internal logic for state management
logic aw_transfer_done;
logic w_transfer_done;
logic ar_transfer_done;

//------------------------------------------------------------------
// AXI Write Logic
//------------------------------------------------------------------

// Write Address Channel: We are always ready to accept an address.
assign S_AXI_AWREADY = 1'b1;

// Write Data Channel: We are always ready to accept data.
assign S_AXI_WREADY = 1'b1;

// Latch the write address when the handshake happens
always_ff @(posedge clk) begin
    if (S_AXI_AWVALID && S_AXI_AWREADY) begin
        awaddr_reg <= S_AXI_AWADDR;
    end
end

// Perform the memory write when the data handshake happens
// This uses the address that was previously latched.
always_ff @(posedge clk) begin
    if (S_AXI_WVALID && S_AXI_WREADY) begin
        // Note: For simplicity, we are ignoring WSTRB and writing the full word.
        // A more complex design would use WSTRB as a byte-enable.
        mem[awaddr_reg[9:2]] <= S_AXI_WDATA; // Using a subset of address bits for indexing
    end
end

// Write Response Channel
// The slave must send a response after a write is complete.
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        S_AXI_BVALID <= 1'b0;
        S_AXI_BRESP  <= 2'b0;
    end else begin
        // If a write transaction just completed, assert BVALID
        if (S_AXI_WVALID && S_AXI_WREADY && !S_AXI_BVALID) begin
            S_AXI_BVALID <= 1'b1;
            S_AXI_BRESP  <= 2'b00; // 'OKAY' response
        end
        // De-assert BVALID once the master accepts the response
        else if (S_AXI_BVALID && S_AXI_BREADY) begin
            S_AXI_BVALID <= 1'b0;
        end
    end
end

//------------------------------------------------------------------
// AXI Read Logic
//------------------------------------------------------------------

// Read Address Channel: We are always ready to accept a read address.
assign S_AXI_ARREADY = 1'b1;

// Latch the read address when the handshake happens
always_ff @(posedge clk) begin
    if (S_AXI_ARVALID && S_AXI_ARREADY) begin
        araddr_reg <= S_AXI_ARADDR;
    end
end

// Read Data Channel
// The slave drives the data and the VALID signal.
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        S_AXI_RVALID <= 1'b0;
        S_AXI_RDATA  <= '0;
        S_AXI_RRESP  <= 2'b0;
    end else begin
        // When a read address is received, get the data from memory and assert RVALID
        if (S_AXI_ARVALID && S_AXI_ARREADY && !S_AXI_RVALID) begin
            S_AXI_RVALID <= 1'b1;
            S_AXI_RDATA  <= mem[S_AXI_ARADDR[9:2]]; // Drive data from memory
            S_AXI_RRESP  <= 2'b00; // 'OKAY' response
        end
        // De-assert RVALID once the master accepts the data
        else if (S_AXI_RVALID && S_AXI_RREADY) begin
            S_AXI_RVALID <= 1'b0;
        end
    end
end

endmodule
