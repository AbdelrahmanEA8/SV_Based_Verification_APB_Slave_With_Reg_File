package transaction_pkg;
  import shared_pkg::*;
    
    class apb_transaction;
        // wrapper in
        bit                                   PCLK;
        rand logic                            PRESETn;
        rand logic [ADDR_WIDTH-1:0]           PADDR;
        rand logic [DATA_WIDTH-1:0]           PWDATA;
        rand logic                            PWRITE;
        // rand logic                            PENABLE;
        // rand logic                            PSELx;
        logic                            PENABLE;
        logic                            PSELx;
        rand logic [STRB_WIDTH-1:0]           PSTRB;

        // wrapper out
        logic [DATA_WIDTH-1:0]      PRDATA;
        logic                       PREADY;
        logic                       PSLVERR;
        

        // --------------------------------------- Constraints --------------------------------------- //

        constraint PRESETn_constraints {
            PRESETn dist {
                ACTIVE_L := W_PRESETn_ON,
                INACTIVE_L  := 100 - W_PRESETn_ON
            };
        }

        // constraint PSELX_constraints {
        //     PSELx dist {
        //         ACTIVE_H := ACTIVE_W,
        //         INACTIVE_H  := 100-ACTIVE_W
        //     };
        // }

        // constraint PENABLE_constraints {
        //     PENABLE dist {
        //         ACTIVE_H := ACTIVE_W,
        //         INACTIVE_H  := 100-ACTIVE_W
        //     };
        // }

        constraint PWRITE_constraints {
            PWRITE dist { 
                ACTIVE_H := W_WRITE,
                INACTIVE_H := W_READ 
            };
        }

        constraint PWDATA_constraints {
            PWDATA dist {
                MAX_DATA           := RANDOM_LOOP,
                MIN_DATA           := RANDOM_LOOP,
                [1 : MAX_DATA-1]  :/ 100-RANDOM_LOOP
            };

            (!PWRITE) -> PWDATA==0;
        }

        constraint PADDR_constraints {
            PADDR dist {
                SYS_STATUS_REG :/ VALID_REG_DIST,
                INT_CTRL_REG :/ VALID_REG_DIST,
                DEV_ID_REG :/ VALID_REG_DIST,
                MEM_CTRL_REG :/ VALID_REG_DIST,
                TEMP_SENSOR_REG :/ VALID_REG_DIST,
                ADC_CTRL_REG :/ VALID_REG_DIST,
                DBG_CTRL_REG :/ VALID_REG_DIST,
                GPIO_DATA_REG :/ VALID_REG_DIST,
                DAC_OUTPUT_REG :/ VALID_REG_DIST,
                VOLTAGE_CTRL_REG :/ VALID_REG_DIST,
                CLK_CONFIG_REG :/ VALID_REG_DIST,
                TIMER_COUNT_REG :/ VALID_REG_DIST,
                INPUT_DATA_REG :/ VALID_REG_DIST,
                OUTPUT_DATA_REG :/ VALID_REG_DIST,
                DMA_CTRL_REG :/ VALID_REG_DIST,
                SYS_CTRL_REG :/ VALID_REG_DIST
            };
        }

        constraint pstrb_bits {
            if (PWRITE)
                foreach (PSTRB[i])  PSTRB[i] dist {ACTIVE_H := ACTIVE_W, INACTIVE_H := 100 - ACTIVE_W};
            else 
                PSTRB == 0;
        }
    endclass //transact
endpackage