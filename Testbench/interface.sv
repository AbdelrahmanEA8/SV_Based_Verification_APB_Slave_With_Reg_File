interface apb_if(input PCLK);
import shared_pkg ::*;
    // Wrapper Inputs
    logic                    PRESETn;
    logic   [ADDR_WIDTH-1:0] PADDR;
    logic                    PSELx;
    logic                    PENABLE;
    logic                    PWRITE;
    logic   [DATA_WIDTH-1:0] PWDATA;
    logic   [STRB_WIDTH-1:0] PSTRB;

    // Wrapper Outputs
    logic                   PREADY;
    logic  [DATA_WIDTH-1:0] PRDATA;
    logic                   PSLVERR;


    // Internal signals
    // logic    [ADDR_WIDTH-1:0] RegADDR;
    // logic                     RegENABLE;
    // logic                     RegWRITE;
    // logic    [DATA_WIDTH-1:0] RegWDATA;
    // logic                     RegREADY;
    // logic    [DATA_WIDTH-1:0] RegRDATA;
    // logic                     RegSLVERR;
    // logic    [STRB_WIDTH-1:0] RegSTRB;

    modport DUT (
        input  PCLK, PRESETn, PADDR , PWDATA , PWRITE , PENABLE , PSELx, PSTRB,
        output PRDATA, PREADY, PSLVERR
    );

    modport Testbench (
        input  PCLK, PRDATA, PREADY, PSLVERR,
        output PRESETn, PADDR , PWDATA , PWRITE , PENABLE , PSELx, PSTRB
    );

    modport Monitor (
        input  PCLK, PRDATA, PREADY, PRESETn, PADDR , PWDATA , PWRITE , PENABLE , PSELx, PSLVERR,PSTRB
    );

    // modport slave (
    //     input PCLK, PRESETn, PADDR, PSELx, PENABLE, PWRITE, PWDATA, PSTRB, RegREADY, RegRDATA, RegSLVERR,
    //     output RegADDR, RegENABLE, RegWRITE, RegWDATA, RegSTRB, PREADY, PRDATA, PSLVERR
    // );

    // modport reg_file (
    //     input PCLK, PRESETn, RegADDR, RegWDATA, RegWRITE, RegENABLE, RegSTRB,
    //     output RegRDATA, RegSLVERR, RegREADY
    // );
    
endinterface