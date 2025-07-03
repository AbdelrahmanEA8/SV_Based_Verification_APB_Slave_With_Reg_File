package coverage_pkg;
  import shared_pkg ::*;
  import transaction_pkg ::*;
    
    class apb_funct_coverage;
        apb_transaction my_trans = new;

        covergroup apb_funct_cov_cg;

            PRESETn_cp :    coverpoint my_trans.PRESETn {
                bins deasserted = {ACTIVE_L};
                bins asserted = {INACTIVE_L};
                bins asserted_deasserted_trans = (ACTIVE_L => INACTIVE_L);
                bins deasserted_asserted_trans = (INACTIVE_L => ACTIVE_L);
            }

            PWRITE_cp : coverpoint my_trans.PWRITE {
                bins write = {ACTIVE_H};
                bins read = {INACTIVE_H};
                bins write_read_trans = (ACTIVE_H => INACTIVE_H);
                bins read_write_trans = (ACTIVE_H => ACTIVE_H);
            }

            PWDATA_cp : coverpoint my_trans.PWDATA iff(my_trans.PWRITE) {
                bins zeros = {MIN_DATA};
                bins ones = {MAX_DATA};
                bins others = default;
            }

            PADDR_cp :  coverpoint my_trans.PADDR {
                bins SYS_STATUS_REG_b   = {SYS_STATUS_REG};
                bins INT_CTRL_REG_b     = {INT_CTRL_REG};
                bins DEV_ID_REG_b       = {DEV_ID_REG};
                bins MEM_CTRL_REG_b     = {MEM_CTRL_REG};
                bins TEMP_SENSOR_REG_b  = {TEMP_SENSOR_REG};
                bins ADC_CTRL_REG_b     = {ADC_CTRL_REG};
                bins DBG_CTRL_REG_b     = {DBG_CTRL_REG};
                bins GPIO_DATA_REG_b    = {GPIO_DATA_REG};
                bins DAC_OUTPUT_REG_b   = {DAC_OUTPUT_REG};
                bins VOLTAGE_CTRL_REG_b = {VOLTAGE_CTRL_REG};
                bins CLK_CONFIG_REG_b   = {CLK_CONFIG_REG};
                bins TIMER_COUNT_REG_b  = {TIMER_COUNT_REG};
                bins INPUT_DATA_REG_b   = {INPUT_DATA_REG};
                bins OUTPUT_DATA_REG_b  = {OUTPUT_DATA_REG};
                bins DMA_CTRL_REG_b     = {DMA_CTRL_REG};
                bins SYS_CTRL_REG_b     = {SYS_CTRL_REG};
                option.auto_bin_max     = 0;
            }

            PSELx_cp :  coverpoint my_trans.PSELx {
                bins selected = {ACTIVE_H};
                bins unselected = {INACTIVE_H};
            }
            
            PENABLE_cp :  coverpoint my_trans.PENABLE {
                bins enabled = {ACTIVE_H};
                bins not_enabled = {INACTIVE_H};
            }
            
            PRDATA_cp : coverpoint my_trans.PRDATA iff(my_trans.PREADY && !my_trans.PWRITE) {
                bins zeros = {MIN_DATA};
                bins ones = {MAX_DATA};
                bins others = default;
            }

            PREADY_cp : coverpoint my_trans.PREADY {
                bins ready = {ACTIVE_H};
                bins not_ready  = {INACTIVE_H};
            }

        // Reset and Transaction Interaction
            // PRESETn_cross_PREADY : cross PRESETn_cp, PREADY_cp;

        // Protocol Behavior
            PSELx_cross_PENABLE : cross PSELx_cp, PENABLE_cp {
                bins Setup_phase    =    binsof(PSELx_cp.selected) && binsof(PENABLE_cp.not_enabled);
                bins Access_phase   =    binsof(PSELx_cp.selected) && binsof(PENABLE_cp.enabled);
                bins Idle_phase     =    binsof(PSELx_cp.unselected);
                // option.auto_bin_max = 0;
            }

            PWRITE_cross_PREADY :  cross PWRITE_cp, PREADY_cp;
            
        // Functional Access to Register File
            PWRITE_cross_RegADDR : cross PWRITE_cp, PADDR_cp;

        endgroup

        function new();
            apb_funct_cov_cg=new;
        endfunction

        function sample_data(apb_transaction trans_in);
            my_trans = trans_in;
            apb_funct_cov_cg.sample();
        endfunction
    endclass
    
endpackage