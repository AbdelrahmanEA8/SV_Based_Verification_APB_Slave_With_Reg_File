////////////////////////////////////////////////////////////////////////////////
// Author: Abdelrahman Essam Fahmy
// Project: Design of APB Slave With Register File
//
// Description: SLAVE Design 
// 
////////////////////////////////////////////////////////////////////////////////

module apb_slave #(
    parameter ADDR_WIDTH = 32 ,
    parameter DATA_WIDTH = 32 , 
    parameter STRB_WIDTH = DATA_WIDTH / 8)
(
// Slave inputs
    input                           PCLK,
    input                           PRESETn,
    input       [ADDR_WIDTH-1:0]    PADDR,
    input                           PSELx,
    input                           PENABLE,
    input                           PWRITE,
    input       [DATA_WIDTH-1:0]    PWDATA,
    input       [STRB_WIDTH-1:0]    PSTRB,
    input                           RegREADY,
    input       [DATA_WIDTH-1:0]    RegRDATA,
    input                           RegSLVERR,
// Slave outputs
    output reg [ADDR_WIDTH-1:0]     RegADDR,
    output reg                      RegENABLE,
    output reg                      RegWRITE,
    output reg [DATA_WIDTH-1:0]     RegWDATA,
    output reg [STRB_WIDTH-1:0]     RegSTRB,
    output reg                      PREADY,
    output reg [DATA_WIDTH-1:0]     PRDATA,
    output reg                      PSLVERR
);

// States Encoding
    localparam  ST_IDLE   = 2'b00,
                ST_SETUP  = 2'b01,
                ST_ACCESS = 2'b10;

// (* fsm_encoding = "one_hot" *)
reg [1:0] current_state , next_state;

// State Transition
    always @ (posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            current_state <= ST_IDLE;
        end
        else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        case (current_state)
          ST_IDLE : begin
                if (PSELx) begin
                    next_state = ST_SETUP;
                end
                else begin
                    next_state = ST_IDLE;
                end
          end 
          ST_SETUP : begin
                if (PSELx) begin
                    if (PENABLE) begin
                        next_state = ST_ACCESS;
                    end
                    else begin
                        next_state = ST_SETUP;
                    end
                end
                else begin
                    next_state = ST_IDLE;
                end
          end
          ST_ACCESS : begin
            // PSLVERR is only considered valid during the last cycle of an APB transfer,
            // when PSEL, PENABLE, and PREADY are all HIGH.
                if (!PSELx) begin
                    next_state=ST_IDLE;
                end
                else begin
                    if (PENABLE && RegREADY) begin
                        next_state = ST_SETUP;
                    end
                    else begin
                        next_state = ST_ACCESS;
                    end
                end
          end
          default : next_state = ST_IDLE;
        endcase
    end
    
// All Output signals shown in this section are sampled at the rising edge of PCLK.
    always @(*) begin     
        if(!PRESETn) begin
            RegADDR    = 0;
            RegWRITE   = 0;
            RegWDATA   = 0;
            RegSTRB    = 0;
            RegENABLE  = 0;
            PRDATA     = 0;
            PREADY     = 0;
            PSLVERR    = 0;
        end
        else begin
            if (current_state == ST_SETUP) begin
                RegENABLE   = 0;
                PRDATA   = 0;
                PREADY      = 0;
                PSLVERR     = 0;
                RegWRITE    = PWRITE;
                RegADDR     = PADDR;
                if (PWRITE && !PSTRB==4'h0) begin
                    RegWDATA = PWDATA;
                    RegSTRB  = PSTRB;
                end
                else begin
                // For read transfers, the Requester must drive all bits of PSTRB LOW.
                    RegSTRB = 0;
                    RegWDATA =0;
                end
            end
              else if (current_state == ST_ACCESS) begin
                RegENABLE = 1;
                PRDATA   = 0;
                PREADY = RegREADY;
                if (RegREADY) begin
                    PSLVERR = RegSLVERR;
                    if (!PWRITE) begin
                        PRDATA = RegRDATA;
                    end
                end
              end
              else begin
            // PENABLE,PREADY is deasserted. unless there is another transfer to the same peripheral.
                RegENABLE = 0;
                PREADY    = 0; 
            // It is recommended, but not required, that PSLVERR is driven LOW when PENABLE, PREADY are LOW
                PSLVERR   = 0;
                PRDATA   = 0;
                RegADDR    = 0;
                RegWRITE   = 0;
                RegWDATA   = 0;
                RegSTRB    = 0;
              end
        end
    end

/////////////////////////////////////////////////// Assertions  ////////////////////////////////////////////////////////
`ifdef SIM
ST_A1 : assert property (
    @(posedge PCLK)  
    !PRESETn |-> RegADDR==0 && !RegWRITE && RegWDATA==0 && RegSTRB==0 && !RegENABLE && PRDATA==0 && !PREADY && !PSLVERR
);

// ST_A2 : assert property (
//     @(posedge PCLK)  
//     (!PRESETn || !PSELx -> current_state == ST_IDLE)
// );

// ST_A3 : assert property (
//     @(posedge PCLK) disable iff(!PRESETn) 
//     (PSELx && PENABLE -> current_state == ST_ACCESS)
// );

// ST_A4: assert property (
//     @(posedge PCLK) disable iff(!PRESETn) 
//     (PSELx && PENABLE && $rose(PREADY) => current_state == ST_SETUP)
// );

apb_protocol : assert property (
    @(posedge PCLK) disable iff (!PRESETn) 
    PENABLE |-> PSELx
);

addr_stable : assert property (
    @(posedge PCLK) disable iff(!PRESETn) 
    PSELx && RegENABLE |-> $stable(RegADDR)
);

Wdata_stable : assert property (
    @(posedge PCLK) disable iff(!PRESETn) 
    PSELx && RegENABLE && RegWRITE |-> $stable(RegWDATA)
);

pready_when_expected : assert property (
    @(negedge PCLK) disable iff(!PRESETn) 
    PREADY |-> PSELx && RegENABLE
);

rdata_valid : assert property (
    @(negedge PCLK) disable iff(!PRESETn) 
    (PSELx && RegENABLE && !RegWRITE && PREADY) |-> !$isunknown(PRDATA)
);

reg_enable_when_access : assert property (
    @(negedge PCLK) disable iff(!PRESETn) 
    RegENABLE |-> PSELx
);

reg_addr_matched : assert property (
    @(posedge PCLK) disable iff(!PRESETn) 
    RegENABLE |-> (RegADDR == PADDR)
);

reg_wdata_matched : assert property (
    @(negedge PCLK) disable iff(!PRESETn) 
    RegENABLE && RegWRITE && !(RegSTRB==4'h0) |-> (RegWDATA == PWDATA)
);

reg_write_matched : assert property (
    @(posedge PCLK) disable iff(!PRESETn) 
    RegENABLE |-> (RegWRITE == PWRITE)
);

no_write_when_zero_strb : assert property (
    @(negedge PCLK) disable iff(!PRESETn) 
    (RegENABLE && RegWRITE && RegSTRB == 4'h0) |-> (RegWDATA == 32'h0)
);


cov_ST_A1 : cover property (
    @(posedge PCLK)  
    !PRESETn |-> RegADDR==0 && !RegWRITE && RegWDATA==0 && RegSTRB==0 && !RegENABLE && PRDATA==0 && !PREADY && !PSLVERR
);

// ST_A2 : assert property (
//     @(posedge PCLK)  
//     (!PRESETn || !PSELx -> current_state == ST_IDLE)
// );

// ST_A3 : assert property (
//     @(posedge PCLK) disable iff(!PRESETn) 
//     (PSELx && PENABLE -> current_state == ST_ACCESS)
// );

// ST_A4: assert property (
//     @(posedge PCLK) disable iff(!PRESETn) 
//     (PSELx && PENABLE && $rose(PREADY) => current_state == ST_SETUP)
// );

cov_apb_protocol : cover property (
    @(posedge PCLK) disable iff (!PRESETn) 
    PENABLE |-> PSELx
);

cov_addr_stable : cover property (
    @(posedge PCLK) disable iff(!PRESETn) 
    PSELx && RegENABLE |-> $stable(RegADDR)
);

cov_Wdata_stable : cover property (
    @(posedge PCLK) disable iff(!PRESETn) 
    PSELx && RegENABLE && RegWRITE |-> $stable(RegWDATA)
);

cov_pready_when_expected : cover property (
    @(negedge PCLK) disable iff(!PRESETn) 
    PREADY |-> PSELx && RegENABLE
);

cov_rdata_valid : cover property (
    @(negedge PCLK) disable iff(!PRESETn) 
    (PSELx && RegENABLE && !RegWRITE && PREADY) |-> !$isunknown(PRDATA)
);

cov_reg_enable_when_access : cover property (
    @(negedge PCLK) disable iff(!PRESETn) 
    RegENABLE |-> PSELx
);

cov_reg_addr_matched : cover property (
    @(posedge PCLK) disable iff(!PRESETn) 
    RegENABLE |-> (RegADDR == PADDR)
);

cov_reg_wdata_matched : cover property (
    @(negedge PCLK) disable iff(!PRESETn) 
    RegENABLE && RegWRITE && !(RegSTRB==4'h0) |-> (RegWDATA == PWDATA)
);

cov_reg_write_matched : cover property (
    @(posedge PCLK) disable iff(!PRESETn) 
    RegENABLE |-> (RegWRITE == PWRITE)
);

cov_no_write_when_zero_strb : cover property (
    @(negedge PCLK) disable iff(!PRESETn) 
    (RegENABLE && RegWRITE && RegSTRB == 4'h0) |-> (RegWDATA == 32'h0)
);

`endif

endmodule