/*
Copyright by Henry Ko, Nicola Nicolici, Sartaj Aujla and Yuvraj Bal
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/


`timescale 1ns/100ps

`include "define_state.h"

module m2 (
	input logic CLOCK_50_I,
	input logic resetn,
	input logic m2_start,
	input logic  [15:0] SRAM_read_data,
	output logic [17:0] SRAM_address,
	output logic [15:0] SRAM_write_data,
	output logic SRAM_we_n,
	output logic m2_end
);

logic [6:0] address_a[2:0];
logic [6:0] address_b[2:0];
logic [31:0] write_data_a [2:0];
logic [31:0] write_data_b [2:0];
logic write_enable_a [2:0];
logic write_enable_b [2:0];
logic [31:0] read_data_a [2:0];
logic [31:0] read_data_b [2:0];

// instantiate RAM0
dual_port_RAM0 RAM_inst0(
	.address_a ( address_a[0] ),
	.address_b ( address_b[0] ),
	.clock ( CLOCK_50_I ),
	.data_a ( write_data_a[0] ),
	.data_b ( write_data_b[0] ),
	.wren_a ( write_enable_a[0]),
	.wren_b ( write_enable_b[0] ),
	.q_a ( read_data_a[0] ),
	.q_b ( read_data_b[0] )
	);
	
// instantiate RAM1
dual_port_RAM0 RAM_inst1(
	.address_a ( address_a[1] ),
	.address_b ( address_b[1] ),
	.clock ( CLOCK_50_I ),
	.data_a ( write_data_a[1] ),
	.data_b ( write_data_b[1] ),
	.wren_a ( write_enable_a[1]),
	.wren_b ( write_enable_b[1] ),
	.q_a ( read_data_a[1] ),
	.q_b ( read_data_b[1] )
	);
	
// instantiate RAM2
dual_port_RAM2 RAM_inst2(
	.address_a ( address_a[2] ),
	.address_b ( address_b[2] ),
	.clock ( CLOCK_50_I ),
	.data_a ( write_data_a[2] ),
	.data_b ( write_data_b[2] ),
	.wren_a ( write_enable_a[2]),
	.wren_b ( write_enable_b[2] ),
	.q_a ( read_data_a[2] ),
	.q_b ( read_data_b[2] )
	);

m2_state_type state;

//Multiplier 1
logic [31:0] Multi_op_1_1, Multi_op_1_2, Multi_result1;
logic signed [31:0] Multi_result_long1;

//Multipler 2
logic [31:0] Multi_op_2_1, Multi_op_2_2, Multi_result2;
logic signed [31:0] Multi_result_long2;

//Multipler 3
logic [31:0] Multi_op_3_1, Multi_op_3_2, Multi_result3;
logic signed [31:0] Multi_result_long3;

assign Multi_result_long1 = Multi_op_1_1 * Multi_op_1_2;
assign Multi_result_long2 = Multi_op_2_1 * Multi_op_2_2;
assign Multi_result_long3 = Multi_op_3_1 * Multi_op_3_2;

logic [5:0] c_state;

always_comb begin
	Multi_op_1_1 = 32'd0;
	Multi_op_1_2 = 32'd0;
	Multi_op_2_1 = 32'd0;
	Multi_op_2_2 = 32'd0;
	Multi_op_3_1 = 32'd0;
	Multi_op_3_2 = 32'd0;
	
	case(state)
	S_LEAD_IN_FETCH_SPRIME_1: begin
	end
	endcase
end

//C Matrix
always_comb begin
	case(c_state)
	0:   Multi_op_1_1 = 32'sd1448;
	1:   Multi_op_1_1 = 32'sd1448;   
	2:   Multi_op_1_1 = 32'sd1448;   
	3:   Multi_op_1_1 = 32'sd1448;   
	4:   Multi_op_1_1 = 32'sd1448;
	5:   Multi_op_1_1 = 32'sd1448;   
	6:   Multi_op_1_1 = 32'sd1448;   
	7:   Multi_op_1_1 = 32'sd1448;   
	8:   Multi_op_1_1 = 32'sd2008;  
	9:   Multi_op_1_1 = 32'sd1702;
	10:  Multi_op_1_1 = 32'sd1137;
	11:  Multi_op_1_1 = 32'sd399;
	12:  Multi_op_1_1 = -32'sd399; 
	13:  Multi_op_1_1 = -32'sd1137; 
	14:  Multi_op_1_1 = -32'sd1702; 
	15:  Multi_op_1_1 = -32'sd2008;
	16:  Multi_op_1_1 = 32'sd1892; 
	17:  Multi_op_1_1 = 32'sd783;  
	18:  Multi_op_1_1 = -32'sd783;   
	19:  Multi_op_1_1 = -32'sd1892;  
	20:  Multi_op_1_1 = -32'sd1892; 
	21:  Multi_op_1_1 = -32'sd783;   
	22:  Multi_op_1_1 = 32'sd783;    
	23:  Multi_op_1_1 = 32'sd1892;   
	24:  Multi_op_1_1 = 32'sd1702;  
	25:  Multi_op_1_1 = -32'sd399;  
	26:  Multi_op_1_1 = -32'sd2008; 
	27:  Multi_op_1_1 = -32'sd1137;  
	28:  Multi_op_1_1 = 32'sd1137;   
	29:  Multi_op_1_1 = 32'sd2008;  
	30:  Multi_op_1_1 = 32'sd399;    
	31:  Multi_op_1_1 = -32'sd1702;  
	32:  Multi_op_1_1 = 32'sd1448; 
	33:  Multi_op_1_1 = -32'sd1448;  
	34:  Multi_op_1_1 = -32'sd1448; 
	35:  Multi_op_1_1 = 32'sd1448; 
	36:  Multi_op_1_1 = 32'sd1448;  
	37:  Multi_op_1_1 = -32'sd1448; 
	38:  Multi_op_1_1 = -32'sd1448; 
	39:  Multi_op_1_1 = 32'sd1448; 
	40:  Multi_op_1_1 = 32'sd1137; 
	41:  Multi_op_1_1 = -32'sd2008; 
	42:  Multi_op_1_1 = 32'sd399;  
	43:  Multi_op_1_1 = 32'sd1702;  
	44:  Multi_op_1_1 = -32'sd1702;
	45:  Multi_op_1_1 = -32'sd399; 
	46:  Multi_op_1_1 = 32'sd2008; 
	47:  Multi_op_1_1 = -32'sd1137;  
	48:  Multi_op_1_1 = 32'sd783;    
	49:  Multi_op_1_1 = -32'sd1892; 
	50:  Multi_op_1_1 = 32'sd1892; 
	51:  Multi_op_1_1 = -32'sd783;
	52:  Multi_op_1_1 = -32'sd783;
	53:  Multi_op_1_1 = 32'sd1892;
	54:  Multi_op_1_1 = -32'sd1892;
	55:  Multi_op_1_1 = 32'sd783;
	56:  Multi_op_1_1 = 32'sd399;
   57:  Multi_op_1_1 = -32'sd1137;
   58:  Multi_op_1_1 = 32'sd1702;
   59:  Multi_op_1_1 = -32'sd2008;
   60:  Multi_op_1_1 = 32'sd2008;   
   61:  Multi_op_1_1 = -32'sd1702;  
   62:  Multi_op_1_1 = 32'sd1137;   
   63:  Multi_op_1_1 = -32'sd399;   
	endcase
end


always_ff @ (posedge CLOCK_50_I or negedge resetn) begin
	if (!resetn) begin
		state <= S_M2_IDLE;
	
	end else begin
		
		case(state)
		
			S_M2_IDLE: begin
			end
			
			S_LEAD_IN_FETCH_SPRIME_0: begin
			end
			
			S_LEAD_IN_FETCH_SPRIME_1: begin
			end
			
			S_COMMON_FETCH_SPRIME_2: begin
			end
			
			S_LEAD_OUT_FETCH_SPRIME_3: begin
			end
			
			S_LEAD_OUT_FETCH_SPRIME_4: begin 
			end
			
			S_LEAD_IN_COMPUTE_T_0: begin
			end
			
			S_COMMON_COMPUTE_T_1: begin
			end
			
			S_COMMON_COMPUTE_T_2: begin
			end
			
			S_LEAD_OUT_COMPUTE_T_3: begin
			end
			
			S_LEAD_IN_COMPUTE_S_0: begin
			end
			
			S_COMMON_COMPUTE_S_1: begin
			end
			
			S_LEAD_OUT_COMPUTE_S_2: begin
			end
			
			S_COMMON_WRITE_S_0: begin
			end
			
			S_COMMON_WRITE_S_1: begin
			end
			
			S_COMMON_WRITE_S_2: begin
			end
			
			S_COMMON_WRITE_S_3: begin
			end
			
			S_COMMON_WRITE_S_4: begin
			end
			
			S_COMMON_WRITE_S_5: begin
			end
			
			S_COMMON_WRITE_S_6: begin
			end
			
			default: state <= S_M2_IDLE;
		
		endcase
	end
end

endmodule
