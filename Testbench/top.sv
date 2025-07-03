import transaction_pkg::*;
module apb_top();
    bit PCLK;

    apb_transaction trans = new;

    // Clk Generation
    initial begin
        PCLK=0;
        forever begin
            #10 PCLK=~PCLK;
        end
    end
    
    apb_if apb_vif (PCLK);
    apb_wrapper duv (
        .PCLK(apb_vif.PCLK),
        .PRESETn(apb_vif.PRESETn),
        .PADDR(apb_vif.PADDR),
        .PSELx(apb_vif.PSELx),
        .PENABLE(apb_vif.PENABLE),
        .PWRITE(apb_vif.PWRITE),
        .PWDATA(apb_vif.PWDATA),
        .PSTRB(apb_vif.PSTRB),
        .PREADY(apb_vif.PREADY),
        .PRDATA(apb_vif.PRDATA),
        .PSLVERR(apb_vif.PSLVERR)
    );

    apb_tb tb (apb_vif.Testbench);
    apb_monitor monitor (apb_vif.Monitor);

endmodule
