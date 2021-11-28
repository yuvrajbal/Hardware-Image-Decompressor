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

endmodule
