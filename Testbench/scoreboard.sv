package scoreboard_pkg;
  import shared_pkg ::*;
  import transaction_pkg ::*;

    class apb_scoreboard;

        // Golden model out
        logic [DATA_WIDTH-1:0]           PRDATA_ref;
        logic                            PREADY_ref;
        logic                            PSLVERR_ref;
        state_e                          current_state;
        logic [DATA_WIDTH-1 : 0]         A_RegWDATA;

        logic [DATA_WIDTH-1:0] reg_file [shortint];

        // Transaction object
        apb_transaction apb_trans = new;

        task check_data(apb_transaction trans_in);
            ref_model(trans_in);
            if (PRDATA_ref == trans_in.PRDATA && PREADY_ref == trans_in.PREADY) 
            begin
                correct_count++;
            end
            else begin
                error_count++;
                $display("%t PRDATA=%h,PRDATA_ref=%h,%s",$time,trans_in.PRDATA,PRDATA_ref,"PRDATA");
                $display("%t PREADY=%h,PREADY_ref=%h,%s",$time,trans_in.PREADY,PREADY_ref,"PREADY");
                $display("=======================================================================");
            end

        endtask

        task ref_model(apb_transaction trans_in);
            A_RegWDATA = 0;
		        if (trans_in.PSTRB[0]) begin
                    A_RegWDATA[7:0]	= trans_in.PWDATA[7:0];
                end
                if (trans_in.PSTRB[1]) begin
                    A_RegWDATA[15:8] = trans_in.PWDATA[15:8];
                end
                if (trans_in.PSTRB[2]) begin
                    A_RegWDATA[23:16] = trans_in.PWDATA[23:16];
                end
                if (trans_in.PSTRB[3]) begin
                    A_RegWDATA[31:24] = trans_in.PWDATA[31:24];
                end

            if (!trans_in.PRESETn) begin
                PRDATA_ref    = 0;
                PREADY_ref    = 0;
                PSLVERR_ref   = 0;
                current_state = ST_IDLE;
            end
            else begin
                PREADY_ref    = 0;
                PSLVERR_ref   = 0;
                PRDATA_ref    = 0;
            case (current_state)
                ST_IDLE: begin
                    if (trans_in.PSELx) begin
                        current_state = ST_SETUP;
                    end
                    else begin
                        current_state = ST_IDLE;
                    end
                end
                ST_SETUP: begin
                    // State transition
                    if (trans_in.PSELx) begin
                        if (trans_in.PENABLE) begin
                            current_state = ST_ACCESS;
                            // PREADY_ref = 1;
                            // if (!trans_in.PWRITE) begin
                            //     PRDATA_ref = reg_file[trans_in.PADDR];
                            //     PSLVERR_ref = 0;
                            // end
                        end
                        else begin
                            current_state = ST_SETUP;
                        end
                    end
                    else begin
                        current_state = ST_IDLE;
                    end

                end
                ST_ACCESS: begin
                    PREADY_ref = 1;
                    PRDATA_ref = 0;
                    PSLVERR_ref = 0;
                            if (!trans_in.PWRITE) begin
                                PRDATA_ref = reg_file[trans_in.PADDR];
                            end
                            else begin
                            // calc_data_strb(trans_in.PSTRB);
                                reg_file[trans_in.PADDR] = A_RegWDATA;
                            end
                    // if (PSLVERR_ref) begin
                    //     current_state = ST_IDLE;
                    //     PRDATA_ref = 0;
                    //     PREADY_ref = 0;
                    //     PSLVERR_ref = 0;
                    // end
                    // else begin
                        // if (trans_in.PENABLE && PREADY_ref) begin
                        //     current_state = ST_SETUP;
                        //     PRDATA_ref = 0;
                        //     PREADY_ref = 0;
                        //     PSLVERR_ref = 0;
                        // end
                        // else if (!trans_in.PENABLE && PREADY_ref) begin
                        //     current_state = ST_IDLE;
                        //     PRDATA_ref = 0;
                        //     PREADY_ref = 0;
                        //     PSLVERR_ref = 0;
                        // end
                        // else begin
                        //     current_state = ST_ACCESS;
                        // end
                    ////
                        if (!trans_in.PSELx) begin
                            current_state=ST_IDLE;
                        end
                        else begin
                            if (trans_in.PENABLE && trans_in.PREADY) begin
                                current_state = ST_SETUP;
                            end
                            else begin
                                current_state = ST_ACCESS;
                            end
                        end
                    end
                default: current_state = ST_IDLE;
            endcase
            end

            // // Push data inside reg_file
            //     if (PWRITE_ref & PENABLE_ref) begin
            //         reg_file[PADDR_ref]=PWDATA_ref;
            //     end
        endtask

        // task ref_model(apb_transaction trans_in);
        //     A_RegWDATA = 0;
		//         if (trans_in.PSTRB[0]) begin
        //             A_RegWDATA[7:0]	= trans_in.PWDATA[7:0];
        //         end
        //         if (trans_in.PSTRB[1]) begin
        //             A_RegWDATA[15:8] = trans_in.PWDATA[15:8];
        //         end
        //         if (trans_in.PSTRB[2]) begin
        //             A_RegWDATA[23:16] = trans_in.PWDATA[23:16];
        //         end
        //         if (trans_in.PSTRB[3]) begin
        //             A_RegWDATA[31:24] = trans_in.PWDATA[31:24];
        //         end

        //     if (!trans_in.PRESETn) begin
        //         PRDATA_ref    = 0;
        //         PREADY_ref    = 0;
        //         PSLVERR_ref   = 0;
        //         current_state = ST_IDLE;
        //     end
        //     else begin
        //         PREADY_ref    = 0;
        //         PSLVERR_ref   = 0;
        //         PRDATA_ref    = 0;
        //     case (current_state)
        //         ST_IDLE: begin
        //             if (trans_in.PSELx) begin
        //                 current_state = ST_SETUP;
        //                 if (trans_in.PWRITE) begin
        //                     // calc_data_strb(trans_in.PSTRB);
        //                     reg_file[trans_in.PADDR] = A_RegWDATA;
        //                 end
        //             end
        //             else begin
        //                 current_state = ST_IDLE;
        //             end
        //         end
        //         ST_SETUP: begin
        //             // State transition
        //             if (trans_in.PSELx) begin
        //                 if (trans_in.PENABLE) begin
        //                     current_state = ST_ACCESS;
        //                     // PREADY_ref = 1;
        //                     // if (!trans_in.PWRITE) begin
        //                     //     PRDATA_ref = reg_file[trans_in.PADDR];
        //                     //     PSLVERR_ref = 0;
        //                     // end
        //                 end
        //                 else begin
        //                     current_state = ST_SETUP;
        //                 end
        //             end
        //             else begin
        //                 current_state = ST_IDLE;
        //             end

        //         end
        //         ST_ACCESS: begin
        //             PREADY_ref = 1;
        //             PRDATA_ref = 0;
        //             PSLVERR_ref = 0;
        //                     if (!trans_in.PWRITE) begin
        //                         PRDATA_ref = reg_file[trans_in.PADDR];
        //                     end
        //             // if (PSLVERR_ref) begin
        //             //     current_state = ST_IDLE;
        //             //     PRDATA_ref = 0;
        //             //     PREADY_ref = 0;
        //             //     PSLVERR_ref = 0;
        //             // end
        //             // else begin
        //                 // if (trans_in.PENABLE && PREADY_ref) begin
        //                 //     current_state = ST_SETUP;
        //                 //     PRDATA_ref = 0;
        //                 //     PREADY_ref = 0;
        //                 //     PSLVERR_ref = 0;
        //                 // end
        //                 // else if (!trans_in.PENABLE && PREADY_ref) begin
        //                 //     current_state = ST_IDLE;
        //                 //     PRDATA_ref = 0;
        //                 //     PREADY_ref = 0;
        //                 //     PSLVERR_ref = 0;
        //                 // end
        //                 // else begin
        //                 //     current_state = ST_ACCESS;
        //                 // end
        //             ////
        //                 if (!trans_in.PSELx) begin
        //                     current_state=ST_IDLE;
        //                 end
        //                 else begin
        //                     if (trans_in.PENABLE && trans_in.PREADY) begin
        //                         current_state = ST_SETUP;
        //                     end
        //                     else begin
        //                         current_state = ST_ACCESS;
        //                     end
        //                 end
        //             end
        //         default: current_state = ST_IDLE;
        //     endcase
        //     end

        //     // // Push data inside reg_file
        //     //     if (PWRITE_ref & PENABLE_ref) begin
        //     //         reg_file[PADDR_ref]=PWDATA_ref;
        //     //     end
        // endtask

        // function void encode_address(apb_transaction trans_in);
        //     if (trans_in.PSELx) begin
        //         case (encoding)
        //             2'b00: address_encoding = 4'b0001; 
        //             2'b01: address_encoding = 4'b0010; 
        //             2'b10: address_encoding = 4'b0100; 
        //             2'b11: address_encoding = 4'b0001; 
        //             default: address_encoding = 4'b0000;
        //         endcase
        // end else begin
        //     address_encoding = 0;
        // end
        // endfunction : encode_address
        
        // task calc_data_strb(logic [STRB_WIDTH-1:0] trans_in.PSTRB);
		//         A_RegWDATA = 0;
		//         if (trans_in.PSTRB[0]) begin
        //             A_RegWDATA[7:0]	= trans_in.PWDATA[7:0];
        //         end
        //         if (trans_in.PSTRB[1]) begin
        //             A_RegWDATA[15:8] = trans_in.PWDATA[15:8];
        //         end
        //         if (trans_in.PSTRB[2]) begin
        //             A_RegWDATA[23:16] = trans_in.PWDATA[23:16];
        //         end
        //         if (trans_in.PSTRB[3]) begin
        //             A_RegWDATA[31:24] = trans_in.PWDATA[31:24];
        //         end
        // endtask

    endclass
    
endpackage