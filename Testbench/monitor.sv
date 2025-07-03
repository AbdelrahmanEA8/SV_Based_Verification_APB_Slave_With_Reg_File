import shared_pkg ::*;
import transaction_pkg ::*;
import coverage_pkg ::*;
import scoreboard_pkg ::*;

module apb_monitor(apb_if.Monitor apb_if);
    apb_transaction apb_trans = new;
    apb_funct_coverage apb_cov = new;
    apb_scoreboard apb_sb = new;

    initial begin
        forever begin
            @(posedge apb_if.PCLK);
            // Inputs
            apb_trans.PRESETn = apb_if.PRESETn;
            apb_trans.PADDR = apb_if.PADDR;
            apb_trans.PSELx = apb_if.PSELx;
            apb_trans.PENABLE = apb_if.PENABLE;
            apb_trans.PWRITE = apb_if.PWRITE;
            apb_trans.PWDATA = apb_if.PWDATA;
            apb_trans.PSTRB = apb_if.PSTRB;
            
            @(negedge apb_if.PCLK);
            // Outputs
            apb_trans.PRDATA = apb_if.PRDATA;
            apb_trans.PREADY = apb_if.PREADY;
            apb_trans.PSLVERR = apb_if.PSLVERR;

        fork
            begin
                apb_cov.sample_data(apb_trans);
            end

            begin
                apb_sb.check_data(apb_trans);
            end
        join

        if(test_finish) begin
            $display("\n***************************************************");
            $display("Verification process has successfully finished");
            $display("***************************************************");
            $display("************** TEST SUMMARY ***********************");
            $display("** Correct Transactions: %0d", correct_count);
            $display("** Error Transactions:   %0d", error_count);
            $display("***************************************************");
        end

    end
    end
endmodule