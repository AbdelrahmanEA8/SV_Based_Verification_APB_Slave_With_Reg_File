import shared_pkg ::*;
import transaction_pkg ::*;
import coverage_pkg ::*;

module apb_tb(apb_if.Testbench apb_if);
    apb_transaction apb_trans = new;
    apb_funct_coverage apb_cov = new;

    initial begin
        chk_rst();
    // Basic Write only with full STRP
        repeat (100) begin
            assert(apb_trans.randomize());
            apb_if.PRESETn = apb_trans.PRESETn;
            apb_if.PADDR = apb_trans.PADDR;
            apb_if.PWDATA = apb_trans.PWDATA;
            apb_if.PWRITE = 1;
            apb_if.PSTRB = 4'hff;
            apb_if.PSELx = 1;
            @(negedge apb_if.PCLK);
            apb_if.PENABLE = 1;
            wait_nclks(2);          // Register file is sequential, we must wait at least 2 clk cycles
            apb_if.PSELx = 0;
            apb_if.PENABLE = 0;
            @(negedge apb_if.PCLK);
        end
    // Basic Write and Read with full STRP
        repeat (5000) begin
            assert(apb_trans.randomize());
            apb_if.PRESETn = apb_trans.PRESETn;
            apb_if.PADDR = apb_trans.PADDR;
            apb_if.PWDATA = apb_trans.PWDATA;
            apb_if.PWRITE = apb_trans.PWRITE;
            apb_if.PSTRB = 4'hff;
            apb_if.PSELx = 1;
            @(negedge apb_if.PCLK);
            apb_if.PENABLE = 1;
            wait_nclks(2);          // Register file is sequential, we must wait at least 2 clk cycles
            apb_if.PSELx = 0;
            apb_if.PENABLE = 0;
            @(negedge apb_if.PCLK);
        end

        chk_rst();
    // Partial Write and Read Using PSTRB
        repeat (5000) begin
            assert(apb_trans.randomize());
            apb_if.PRESETn = apb_trans.PRESETn;
            apb_if.PADDR = apb_trans.PADDR;
            apb_if.PWDATA = apb_trans.PWDATA;
            apb_if.PWRITE = apb_trans.PWRITE;
            apb_if.PSTRB = apb_trans.PSTRB;
            apb_if.PSELx = 1;
            @(negedge apb_if.PCLK);
            apb_if.PENABLE = 1;
            wait_nclks(2);          // Register file is sequential, we must wait at least 2 clk cycles
            apb_if.PSELx = 0;
            apb_if.PENABLE = 0;
            @(negedge apb_if.PCLK);
        end

        chk_rst();
    // Write Without Enable (protocol violation)
        repeat (1000) begin
            assert(apb_trans.randomize());
            apb_if.PRESETn = apb_trans.PRESETn;
            apb_if.PADDR = apb_trans.PADDR;
            apb_if.PWDATA = apb_trans.PWDATA;
            apb_if.PWRITE = apb_trans.PWRITE;
            apb_if.PSTRB = apb_trans.PSTRB;
            apb_if.PSELx = 1;
            @(negedge apb_if.PCLK);
            apb_if.PENABLE = 0;
            wait_nclks(2);          // Register file is sequential, we must wait at least 2 clk cycles
            apb_if.PSELx = 0;
            apb_if.PENABLE = 0;
            @(negedge apb_if.PCLK);
        end
        test_finish = 1;

        wait_nclks(1);
        $stop;
    end

    task chk_rst();
        apb_if.PRESETn=0;
        repeat(5) begin
            @(negedge apb_if.PCLK);
            $display("reset Active , PRDATA=0x%h,PREADY=0x%h",apb_if.PRDATA,apb_if.PREADY);
        end
        apb_if.PRESETn=1;
    endtask

    function assign_values();
            apb_trans.PRDATA = apb_if.PRDATA;
            apb_trans.PREADY = apb_if.PREADY;
    endfunction

    task wait_nclks(int nclks);
            repeat(nclks) begin
                @(negedge apb_if.PCLK);
                assign_values();
            end
    endtask

    
endmodule