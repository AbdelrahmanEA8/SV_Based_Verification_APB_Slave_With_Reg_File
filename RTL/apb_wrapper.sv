////////////////////////////////////////////////////////////////////////////////
// 
// Project: Design of APB Slave With Register File
//
// Description: Wrapper Design 
// 
//////////////////////////////////////////////////////////////////////////////// 

module apb_wrapper #(
    parameter ADDR_WIDTH = 32 ,
    parameter DATA_WIDTH = 32 , 
    parameter STRB_WIDTH = DATA_WIDTH / 8)
(

// Wrapper Inputs
    input                    PCLK,
    input                    PRESETn,
    input   [ADDR_WIDTH-1:0] PADDR,
    input                    PSELx,
    input                    PENABLE,
    input                    PWRITE,
    input   [DATA_WIDTH-1:0] PWDATA,
    input   [STRB_WIDTH-1:0] PSTRB,

// Wrapper Outputs
    output                   PREADY,
    output  [DATA_WIDTH-1:0] PRDATA,
    output                   PSLVERR
);

    // Internal signals
    wire    [ADDR_WIDTH-1:0] RegADDR;
    wire                     RegENABLE;
    wire                     RegWRITE;
    wire    [DATA_WIDTH-1:0] RegWDATA;
    wire                     RegREADY;
    wire    [DATA_WIDTH-1:0] RegRDATA;
    wire                     RegSLVERR;
    wire    [STRB_WIDTH-1:0] RegSTRB;

    apb_slave_new #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .STRB_WIDTH(STRB_WIDTH)
    ) slave (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PADDR(PADDR),
        .PSELx(PSELx),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PWDATA(PWDATA),
        .PSTRB(PSTRB),
        .PREADY(PREADY),
        .PRDATA(PRDATA),
        .PSLVERR(PSLVERR),
        .RegADDR(RegADDR),
        .RegENABLE(RegENABLE),
        .RegWRITE(RegWRITE),
        .RegWDATA(RegWDATA),
        .RegREADY(RegREADY),
        .RegRDATA(RegRDATA),
        .RegSLVERR(RegSLVERR),
        .RegSTRB(RegSTRB)
    );

    RegisterFile #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) reg_file (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .RegADDR(RegADDR),
        .RegENABLE(RegENABLE),
        .RegWRITE(RegWRITE),
        .RegWDATA(RegWDATA),
        .RegREADY(RegREADY),
        .RegRDATA(RegRDATA),
        .RegSLVERR(RegSLVERR),
        .RegSTRB(RegSTRB)
    );

endmodule