//------------------------------------------------------------------
// Module: cpu_axim_master
// Description: A simplified CPU model that acts as an AXI-Lite master.
//              It generates a sequence of read and write transactions
//              to test the slaves on the AXI bus.
//------------------------------------------------------------------
module cpu_axim_master #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
) (
    // Global Signals
    input  logic                   clk,
    input  logic                   rstn,
    input  logic                   start_test,
    input  logic [1:0]               ins_type,
    input  logic [ADDR_WIDTH-1:0]    address,
    input  logic [DATA_WIDTH-1:0] data_to_write,
    // AXI-Lite Write Address Channel
    output logic [ADDR_WIDTH-1:0]  M_AXI_AWADDR,
    output logic                   M_AXI_AWVALID,
    input  logic                   M_AXI_AWREADY,

    // AXI-Lite Write Data Channel
    output logic [DATA_WIDTH-1:0]  M_AXI_WDATA,
    output logic                   M_AXI_WVALID,
    input  logic                   M_AXI_WREADY,

    // AXI-Lite Write Response Channel
    input  logic [1:0]             M_AXI_BRESP,
    input  logic                   M_AXI_BVALID,
    output logic                   M_AXI_BREADY,

    // AXI-Lite Read Address Channel
    output logic [ADDR_WIDTH-1:0]  M_AXI_ARADDR,
    output logic                   M_AXI_ARVALID,
    input  logic                   M_AXI_ARREADY,

    // AXI-Lite Read Data Channel
    input  logic [DATA_WIDTH-1:0]  M_AXI_RDATA,
    input  logic [1:0]             M_AXI_RRESP,
    input  logic                   M_AXI_RVALID,
    output logic                   M_AXI_RREADY , test_done ,
    input logic start_write , start_read 


     // Internal control - enable PC update
);



// FSM State Declaration for the test sequence
typedef enum logic [3:0] {
    IDLE       = 4'b0000,
    CHK_CMD      = 4'b0001,
    READ_MEM     = 4'b0010,
    WRITE_MEM    = 4'b0011,
    READ_SPI   = 4'b0100,
    WRITE_SPI  = 4'b0101,
    READ_ADDR  = 4'b0110,
    WRITE_ADDR =4'b0111,
    READ_DATA =4'b1000,
    WRITE_DATA=4'b1001,
    WRITE_RESP =4'b1010,
    READ_RESP =4'b1011,
    DONE =4'b1100

} cpu_state_t;
cpu_state_t cs, ns;


// Internal registers to hold data for the test sequence

logic [DATA_WIDTH-1:0] data_CPU_read;
logic [ADDR_WIDTH-1:0] address_to_access;
logic [DATA_WIDTH-1:0] read_data_reg;




// state transition 
always @(posedge clk) begin
    if(!rstn)begin
        cs<=IDLE;
    end
    else begin
        cs<=ns;
    end
end


always @(*) begin
    case (cs)
        IDLE:begin
            M_AXI_ARVALID=1'b0;
            M_AXI_AWVALID=1'b0;
            M_AXI_RREADY=1'b0;
            M_AXI_WVALID=1'b0;
            M_AXI_BREADY=1'b0;
            if(start_test)begin
                ns=CHK_CMD;
            end
            else begin
                ns=IDLE;
            end
        end 
        CHK_CMD:begin
            if(ins_type == 2'b00)begin
                ns=WRITE_MEM;
            end
            else if(ins_type == 2'b01)begin
                ns=READ_MEM;
            end
            else if(ins_type == 2'b10)begin
                ns=WRITE_SPI;
            end
            else if(ins_type == 2'b11)begin
                ns=READ_SPI;
            end
            else begin
                ns=CHK_CMD;
            end
        end
        WRITE_MEM:begin
            if(start_write)begin
                ns=WRITE_ADDR;
                
            end
            else begin
                ns=WRITE_MEM;
            end
        end
        READ_MEM:begin
            if(start_read)begin
              
                ns=READ_ADDR;
            end
            else begin
                ns=READ_MEM;
            end
        end
        WRITE_SPI:begin
            if(start_write)begin
                ns=WRITE_ADDR;
            end
            else begin
                ns=WRITE_SPI;
            end
        end
        READ_SPI:begin
            if(start_read)begin
                ns=READ_ADDR;
                
            end
            else begin
                ns=READ_SPI;
            end
        end
        READ_ADDR:begin
            M_AXI_ARVALID=1'b1;
            if(M_AXI_ARREADY)begin
                ns=READ_DATA;
            end
            else begin
                ns=READ_ADDR;
            end
        end
        WRITE_ADDR:begin
            M_AXI_AWVALID=1'b1;
            if(M_AXI_AWREADY)begin
                ns=WRITE_DATA;
                
            end
            else begin
                ns=WRITE_ADDR;
            end
        end
        READ_DATA:begin
            M_AXI_ARVALID=1'b0;
            M_AXI_RREADY=1'b1;
            if(M_AXI_RVALID)begin
                ns=DONE;
                
            end
            else begin
                ns=READ_DATA;
            end
        end
        WRITE_DATA:begin
            M_AXI_AWVALID=1'b0;
            M_AXI_WVALID=1'b1;
            if(M_AXI_WREADY)begin
                ns=WRITE_RESP;
                
            end
            else begin
                ns=WRITE_DATA;
            end
        end
        WRITE_RESP:begin
            M_AXI_WVALID=1'b0;
            M_AXI_BREADY=1'b1;
            
            if(M_AXI_BVALID)begin
                ns=DONE;
            end
            else begin
                ns=WRITE_RESP;
            end
        end
        DONE:begin
            M_AXI_RREADY=1'b0;
            test_done=1'b1;
            ns=IDLE;
        end
    endcase
end

always @(posedge clk) begin
    case (cs)
        READ_ADDR:begin
            M_AXI_ARADDR<=address;
        end 
        WRITE_ADDR:begin
            M_AXI_AWADDR<=address;
        end 
        READ_DATA:begin
            
            read_data_reg<= M_AXI_RDATA;
        end
        WRITE_DATA:begin
            M_AXI_WDATA<=data_to_write;
        end
        
    endcase
end
endmodule