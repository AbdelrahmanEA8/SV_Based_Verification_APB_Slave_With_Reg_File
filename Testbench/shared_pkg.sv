package shared_pkg;

	parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 32;
	parameter STRB_WIDTH = DATA_WIDTH / 8;
    
    int clk_cycle = 4;
	int test_finish = 0;
	int error_count = 0;
	int correct_count = 0;
	
	// States type using onehot encoding
	typedef enum logic [2:0] {
    ST_IDLE   = 3'b001,
    ST_SETUP  = 3'b010,
    ST_ACCESS = 3'b100
	} state_e;


    parameter ACTIVE_L     = 0;
    parameter INACTIVE_L   = 1;
	parameter ACTIVE_H	   = 1;
    parameter INACTIVE_H   = 0;

	parameter W_PRESETn_ON  = 2;
	parameter W_READ        = 50;	
	parameter W_WRITE       = 50;	
	parameter ACTIVE_W		= 90;
	parameter MAX_DATA      = 32'hFFFF_FFFF;	
	parameter MIN_DATA      = 32'h0000_0000;	

	parameter READ_ACTIVE_PENABLE_LOOP 	  = 12;	
	parameter READ_INACTIVE_PENABLE_LOOP  = 2;	
	parameter WRITE_ACTIVE_PENABLE_LOOP   = 12;	
	parameter WRITE_INACTIVE_PENABLE_LOOP = 2;	
	parameter TOGGLE_LOOP   = 5;
	parameter RANDOM_LOOP   = 10;


	parameter SYS_STATUS_REG	= 32'h0000_0000;
	parameter INT_CTRL_REG		= 32'h0000_0004;
	parameter DEV_ID_REG		= 32'h0000_0008;
	parameter MEM_CTRL_REG		= 32'h0000_000c;
	parameter TEMP_SENSOR_REG	= 32'h0000_0010;
	parameter ADC_CTRL_REG		= 32'h0000_0014;
	parameter DBG_CTRL_REG		= 32'h0000_0018;
	parameter GPIO_DATA_REG		= 32'h0000_001c;
	parameter DAC_OUTPUT_REG	= 32'h0000_0020;
	parameter VOLTAGE_CTRL_REG	= 32'h0000_0024;
	parameter CLK_CONFIG_REG	= 32'h0000_0028;
	parameter TIMER_COUNT_REG	= 32'h0000_002c;
	parameter INPUT_DATA_REG	= 32'h0000_0030;
	parameter OUTPUT_DATA_REG	= 32'h0000_0034;
	parameter DMA_CTRL_REG		= 32'h0000_0038;
	parameter SYS_CTRL_REG		= 32'h0000_003c; 
	parameter VALID_REG_DIST 	= 90;
					
endpackage : shared_pkg