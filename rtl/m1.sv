/*
Copyright by Henry Ko and Nicola Nicolici
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/


`timescale 1ns/100ps

`include "define_state.h"

module m1 (
	input logic CLOCK_50_I,
	input logic resetn,
	input logic m1_start,
	input logic  [15:0] SRAM_read_data,
	output logic [17:0] SRAM_address,
	output logic [15:0] SRAM_write_data,
	output logic SRAM_we_n,
	output logic m1_end
);

//Parameters

parameter 	Y_OFFSET = 18'd0, //0 - 38,399
				U_OFFSET = 18'd38400, // 38,400 - 57,599
				V_OFFSET= 18'd57600, //57,600 - 76,799
				//76,800 - 146,943
				RGB_OFFSET = 18'd146944, // 146,944 - 262,143
				
				FILTER_D21 = 8'd21,	
				FILTER_D52 = 8'd52,
				FILTER_D159 = 8'd159,

				CSC_76284 = 18'd76284,
				CSC_25624 = 18'd25624,
				CSC_132251 = 18'd132251,
				CSC_104595 = 18'd104595,
				CSC_53281 = 18'd53281;

m1_state_type state;

//Y
logic [15:0] Y_address;
logic [15:0] Y_even;
logic [15:0] Y_odd;
logic [15:0] Y_odd2;

//U
logic [15:0] U_address;
logic [15:0] U_even;
logic [7:0] U_odd;
logic [47:0] U_shift;
logic signed [31:0] U_odd_accum;

//V
logic [15:0] V_address;
logic [15:0] V_even;
logic [7:0] V_odd;
logic [47:0] V_shift;
logic signed [31:0] V_odd_accum;
logic signed [31:0] V_odd_accum2;

//RGB
logic [17:0] RGB_address;
logic signed [31:0] RGB_red; //need to change to 8 bit in future 
logic signed [31:0] RGB_green;
logic signed [31:0] RGB_green_buf;
logic signed [31:0] RGB_blue;
logic signed [31:0] RGB_blue_buf;
logic signed [31:0] RGB_red_buf;


//Multiplier 1
logic [31:0] Multi_op_1_1, Multi_op_1_2, Multi_result1;
logic signed [31:0] Multi_result_long1;

//Multipler 2
logic [31:0] Multi_op_2_1, Multi_op_2_2, Multi_result2;
logic signed [31:0] Multi_result_long2;

assign Multi_result_long1 = Multi_op_1_1 * Multi_op_1_2;
assign Multi_result_long2 = Multi_op_2_1 * Multi_op_2_2;

//Column Counter
logic [7:0] col_counter;

//Multiplications
always_comb begin
	Multi_op_1_1 = 32'd0;
	Multi_op_1_2 = 32'd0;
	Multi_op_2_1 = 32'd0;
	Multi_op_2_2 = 32'd0;
	
	case(state)
		S_LEAD_IN_7: begin
			Multi_op_1_1 = FILTER_D21;				//Operands for  1st multiplication for CC
			Multi_op_1_2 = U_shift[47:40] + U_shift[7:0];
			Multi_op_2_1 = FILTER_D21;
			Multi_op_2_2 = V_shift[47:40] + V_shift[7:0];
		end
		
		S_COMMON_0: begin					//Operands for 2nd multiplication
			Multi_op_1_1 = FILTER_D52;
			Multi_op_1_2 = U_shift[39:32] + U_shift[15:8];
			Multi_op_2_1 = FILTER_D52;
			Multi_op_2_2 = V_shift[39:32] + V_shift[15:8];	
		end
		
		S_COMMON_1: begin
			Multi_op_1_1 = FILTER_D159;		//Operands for 3rd multiplication
			Multi_op_1_2 = U_shift[31:24] + U_shift[23:16];
			Multi_op_2_1 = FILTER_D159;
			Multi_op_2_2 = V_shift[31:24] + V_shift[23:16];	
		end
		
		S_COMMON_2: begin
			Multi_op_1_1 = CSC_76284;			//Operands for R pixel 
			Multi_op_1_2 = Y_even - 5'd16;		// 
			Multi_op_2_1 = CSC_104595;
			Multi_op_2_2 = V_shift[31:24]- 8'd128;		//REPLACEd WITH UPSAMPLED VALUES (V’)
		end
		
		S_COMMON_3: begin
			Multi_op_1_1 = CSC_25624;			//Operand for G pixel 
			Multi_op_1_2 = U_shift[31:24] - 8'd128;		//REPLACEd WITH UPSAMPLED VALUES (U’) 
			Multi_op_2_1 = CSC_53281;
			Multi_op_2_2 = V_shift[31:24]- 8'd128;		//REPLACEd WITH UPSAMPLED VALUES (V’) 
	
		end
		
		S_COMMON_4: begin
			Multi_op_1_1 = CSC_132251;
			Multi_op_1_2 = U_shift[31:24] - 8'd128;
			Multi_op_2_1 = CSC_25624;
			Multi_op_2_2 = U_odd_accum- 8'd128;		// U’ODD 
		end
		
		S_COMMON_5: begin
			Multi_op_1_1 = CSC_76284;
			Multi_op_1_2 = Y_odd - 8'd16;		//Yodd
			Multi_op_2_1 = CSC_104595;
			Multi_op_2_2 = V_odd_accum - 8'd128;
		end
		
		S_COMMON_6: begin
			Multi_op_1_1 = CSC_53281;
			Multi_op_1_2 = V_odd_accum - 8'd128;
			Multi_op_2_1 = CSC_132251;
			Multi_op_2_2 = U_odd_accum - 8'd128;	
		end
		
		S_COMMON_7: begin
			Multi_op_1_1 = FILTER_D21;
			Multi_op_1_2 = U_shift[47:40] + U_shift[7:0];
			Multi_op_2_1 = FILTER_D21;
			Multi_op_2_2 = V_shift[47:40] + V_shift[7:0];
		end
		
		S_COMMON_8: begin
			Multi_op_1_1 = FILTER_D52;
			Multi_op_1_2 = U_shift[39:32] + U_shift[15:8];
			Multi_op_2_1 = FILTER_D52;
			Multi_op_2_2 = V_shift[39:32] + V_shift[15:8];
		end

		S_COMMON_9: begin
			Multi_op_1_1 = FILTER_D159;		//Operands for 3rd multiplication
			Multi_op_1_2 = U_shift[31:24] + U_shift[23:16];
			Multi_op_2_1 = FILTER_D159;
			Multi_op_2_2 = V_shift[31:24] + V_shift[23:16];	
		end
		
		S_COMMON_10: begin
			Multi_op_1_1 = CSC_76284;			//Operands for R pixel 
			Multi_op_1_2 = Y_even - 5'd16;		// 
			Multi_op_2_1 = CSC_104595;
			Multi_op_2_2 = V_shift[31:24]- 8'd128;		//REPLACEd WITH UPSAMPLED VALUES (V’)
		end
		
		S_COMMON_11: begin
			Multi_op_1_1 = CSC_25624;			//Operand for G pixel 
			Multi_op_1_2 = U_shift[31:24] - 8'd128;		//REPLACEd WITH UPSAMPLED VALUES (U’) 
			Multi_op_2_1 = CSC_53281;
			Multi_op_2_2 = V_shift[15:8]- 8'd128;		//REPLACEd WITH UPSAMPLED VALUES (V’) 
	
		end
		
		S_COMMON_12: begin
			Multi_op_1_1 = CSC_132251;
			Multi_op_1_2 = U_shift[31:24] - 8'd128;
			Multi_op_2_1 = CSC_25624;
			Multi_op_2_2 = U_odd_accum - 8'd128;		// U’ODD 
		end

		S_COMMON_13: begin
			Multi_op_1_1 = CSC_76284;
			Multi_op_1_2 = Y_odd2 - 8'd16;		//Yodd
			Multi_op_2_1 = CSC_104595;
			Multi_op_2_2 = V_odd_accum2 - 8'd128;		//
		end
		
		S_COMMON_14: begin
			Multi_op_1_1 = CSC_53281;
			Multi_op_1_2 = V_odd_accum - 8'd128;
			Multi_op_2_1 = CSC_132251;
			Multi_op_2_2 = U_odd_accum - 8'd128;
		end

		S_COMMON_15: begin
			Multi_op_1_1 = FILTER_D21;
			Multi_op_1_2 = U_shift[47:40] + U_shift[7:0];
			Multi_op_2_1 = FILTER_D21;
			Multi_op_2_2 = V_shift[47:40] + V_shift[7:0];
		end		
	endcase
end

always_ff @ (posedge CLOCK_50_I or negedge resetn) begin
	if (!resetn) begin 
		state <= S_M1_IDLE;
		SRAM_we_n <= 1'b1;
		SRAM_address <= 18'd0;
		SRAM_write_data <= 16'd0;
		col_counter <= 8'd0;
		Y_address <= 16'd0;
		Y_even <= 16'd0;
		Y_odd <= 16'd0;
		m1_end <= 1'b0;
		U_address <= 16'd0;
		V_address <= 16'd0;
		U_even <= 16'd0;
		U_odd <= 8'd0;
		U_odd_accum <= 32'd0;
		V_odd_accum <= 32'd0;
		U_shift <= 48'd0;
		V_shift <= 48'd0;
		RGB_red <= 32'b0;
		RGB_green <= 32'b0;
		RGB_green_buf <= 32'b0;
		RGB_blue <= 32'b0;
		RGB_blue_buf <= 32'b0;
		RGB_address <= 18'b0;		
		
	end else begin
	
		case(state)
						
			S_M1_IDLE: begin
			if(m1_start == 1)
				state <=S_LEAD_IN_0;	
			end
			
			S_LEAD_IN_0: begin
			col_counter <= 8'd0;
			SRAM_we_n <= 1'b1;
			SRAM_address <= U_address + U_OFFSET;		//location 38400(U0,U1)
			U_address <= U_address + 16'd1;			//move to next address , U2,U3
			state <= S_LEAD_IN_1;
			end
			
			S_LEAD_IN_1: begin
			SRAM_address <= V_address + V_OFFSET;		//location 57600(V0,V1)
			V_address <= V_address + 16'd1;			//move to next address , V2,V3
			state <= S_LEAD_IN_2;
			end
			
			S_LEAD_IN_2: begin
			SRAM_address <= U_address + U_OFFSET;		//Ram location for U2,U3 
			U_address <= U_address + 16'd1;			//increment U address by 1
			state <= S_LEAD_IN_3;							
			end
			
			S_LEAD_IN_3: begin
			SRAM_address <= V_address + V_OFFSET;		// Ram location for V2,V3
			V_address <= V_address + 16'd1;			//increment V address
			U_even <= SRAM_read_data[15:8]; 			//U0
			U_odd <= SRAM_read_data[7:0]; 			//U1
			U_shift[47:40] <= SRAM_read_data[15:8]; 		//U0	
			U_shift[39:32] <= SRAM_read_data[15:8]; 		//U0
			U_shift[31:24] <= SRAM_read_data[15:8]; 		//U0
			U_shift[23:16] <= SRAM_read_data[7:0]; 		//U1
			
			state <= S_LEAD_IN_4;
			end 
			
			S_LEAD_IN_4: begin							          
         SRAM_address <= Y_address + Y_OFFSET; 		//Y0,Y1
			Y_address <= Y_address + 16'd1;			//increment y address
			V_even <= SRAM_read_data[15:8]; 			//V0
			V_odd <= SRAM_read_data[7:0]; 			//V1
			
			V_shift[47:40] <= SRAM_read_data[15:8]; 		//V0
			V_shift[39:32] <= SRAM_read_data[15:8];	 	//V0
			V_shift[31:24] <= SRAM_read_data[15:8];	 	//V0
			V_shift[23:16] <= SRAM_read_data[7:0]; 		//V1
			
			state <= S_LEAD_IN_5;
			end
			
			S_LEAD_IN_5: begin
			U_even <= SRAM_read_data[15:8]; 			//buffer U2
			U_odd <= SRAM_read_data[7:0]; 			//buffer U3
			U_shift[15:8] <= SRAM_read_data[15:8]; 		//U2
			U_shift[7:0] <= SRAM_read_data[7:0];			 //U3
			
			state <= S_LEAD_IN_6;
			end 
			
			S_LEAD_IN_6: begin
			V_even <= SRAM_read_data[15:8]; 			//buffer V2
			V_odd <= SRAM_read_data[7:0]; 			//buffer V3
			V_shift[15:8] <= SRAM_read_data[15:8]; 		//V2
			V_shift[7:0] <= SRAM_read_data[7:0];			 //V3
			
			state <= S_LEAD_IN_7;
			end
			
			S_LEAD_IN_7: begin
			Y_even <= SRAM_read_data[15:8]; 			//Buffer Y0
			Y_odd <= SRAM_read_data[7:0]; 			//Buffer Y1
			U_odd_accum <= Multi_result_long1;			// 21(U0 + U3)
			V_odd_accum <=  Multi_result_long2;			// 21(V0 + V3)
			
			state <= S_COMMON_0;
			end	
			
			S_COMMON_0: begin
			col_counter <= col_counter + 1'd1;
			
			U_odd_accum <= $signed(U_odd_accum - Multi_result_long1);	// 21(U0 + U3) - 52(U0 + U2) 
			V_odd_accum <= $signed(V_odd_accum - Multi_result_long1);	// 21(V0 + V3) - 52(V1 + V2) 
			state <= S_COMMON_1;
			end
			
			S_COMMON_1: begin
			if (col_counter < 8'd156) begin
				SRAM_address <= U_address + U_OFFSET;		//location 38402(U4,U5)
				U_address <= U_address + 16'd1;			//increment U add value by 1
			end
			
			U_odd_accum <= $signed(U_odd_accum + Multi_result_long1 + 18'd128)>>8; // U1’=[21(U0 + U3) - 52(U0 + U2) + 159 (U0+U1)]/256
			V_odd_accum <= $signed(V_odd_accum + Multi_result_long1 + 18'd128)>>8; // V1’ =[21(V0 + V5) - 52(V1 + V2) + 159 (U0+U1)]/256
			state <= S_COMMON_2;
			end
			
			S_COMMON_2: begin
			if(col_counter < 8'd156) begin
				SRAM_address <= V_address + V_OFFSET;		//location 57600(V4,V5)
				V_address <= V_address + 16'd1;			//increment V add value by 1
			end

			RGB_red <= $signed(Multi_result_long1 + Multi_result_long2) >> 16; //76284+104595
			RGB_green <= Multi_result_long1;			 //76284
			RGB_blue <= Multi_result_long1;			//76284

			state <= S_COMMON_3;
			end
			
			S_COMMON_3: begin

			SRAM_address <= Y_address + Y_OFFSET;		//location 1 (Y2,Y3)
			Y_address <= Y_address + 16'd1;			//increment Y add value by 1
			RGB_green <= $signed(RGB_green - Multi_result_long1 - Multi_result_long2) >> 16;//store green pixel value
			SRAM_we_n <= 1'd1;				//write in next clock cycle
			//SRAM_we_n <= 1'd0;	
			state <= S_COMMON_4;				
			end
			
			S_COMMON_4: begin
			if(col_counter < 8'd156) begin
				U_even <=  SRAM_read_data[15:8]; 			//Buffer U4
				U_odd   <=  SRAM_read_data[7:0]; 			//BUffer U5
				U_shift  <= (U_shift << 18'd8);				//shift one value
				U_shift [7:0] <= SRAM_read_data[15:8];			//add new value in LSB
			end
			
			else begin
			U_shift  <= (U_shift << 18'd8);				//shift one value
			U_shift [7:0] <= U_odd[7:0];  //U159
			end
			
			SRAM_address <= RGB_address + RGB_OFFSET;	//Move to RGB segment to write 
			RGB_address <= RGB_address + 18'd1;		 //Increment address 
			
			RGB_blue <= $signed(RGB_blue + Multi_result_long1) >> 16; 	//B0
			RGB_green_buf <= Multi_result_long2;			//Next green px partial value
			SRAM_we_n <= 1'd0;				
			//SRAM_write_data <= {(RGB_red[15] ? 8'd0: | RGB_red[14:8] ? 8'd255: RGB_red[7:0]), (RGB_green[15] ? 8'd0: | RGB_green[14:8] ? 8'd255: RGB_green[7:0])}; 		//R0G0
			state <= S_COMMON_5;
			end
			
			S_COMMON_5: begin
			if(col_counter < 8'd156) begin
				V_even <=  SRAM_read_data[15:8]; 			// Buffer V4
				V_odd   <=  SRAM_read_data[7:0]; 			//V5
				V_shift  <= (V_shift << 18'd8);				//shift one value
				V_shift [7:0] <= SRAM_read_data[15:8];			//add new value in LSB
			end
			
			else begin
			V_shift  <= (V_shift << 18'd8);				//shift one value
			V_shift [7:0] <= V_odd;	//159	//add new value in LSB
			end
			SRAM_write_data <= {(RGB_red[15] ? 8'd0: | RGB_red[14:8] ? 8'd255: RGB_red[7:0]), (RGB_green[15] ? 8'd0: | RGB_green[14:8] ? 8'd255: RGB_green[7:0])}; 		//R0G0
			//RGB_red <= $signed(Multi_result_long1 + Multi_result_long2) >> 16; 	//R1
			SRAM_address <= RGB_address + RGB_OFFSET;	//move to Beven   /Rodd
			RGB_address <= RGB_address + 18'd1;		//inc RGB address		
			//RGB_red <= $signed(Multi_result_long1 + Multi_result_long2) >> 16; 	//R1
			//RGB_green <= $signed(Multi_result_long1 - RGB_green_buf);		//partial g sum
			RGB_green_buf <= $signed(Multi_result_long1 - RGB_green_buf);		//partial g sum
			RGB_blue_buf <= Multi_result_long1; //need to buffer here, 76284*yodd
			SRAM_we_n <= 1'd0;
			
			state <= S_COMMON_6;
			end
			
			S_COMMON_6: begin
			Y_even <= SRAM_read_data[15:8]; // Buffer Y2
			Y_odd <= SRAM_read_data[7:0]; //Buffer Y3
			SRAM_write_data <= {(RGB_blue[15] ? 8'd0: | RGB_blue[14:8] ? 8'd255: RGB_blue[7:0]), (RGB_red[15] ? 8'd0: | RGB_red[14:8] ? 8'd255: RGB_red[7:0])}; 		// write Beven   /Rodd(B0R1)
			
			RGB_red <= $signed(Multi_result_long1 + Multi_result_long2) >> 16; 	//R1
			//RGB_green <= $signed(RGB_green_buf - Multi_result_long1) >>16;		//Computed GODD
			RGB_green_buf <= $signed(RGB_green_buf - Multi_result_long1) >>16;		//Computed GODD
			
			RGB_blue_buf <= $signed(RGB_blue_buf + Multi_result_long1) >>16;		//Computed BODD
			SRAM_address <= RGB_address + RGB_OFFSET;		//Move to write address
			RGB_address <= RGB_address + 18'd1;		//inc RGB address	
			SRAM_we_n <= 1'd0;	
			U_odd_accum <= 32'd0;	
			//V_odd_accum <= 32'd0;	
			
			state <= S_COMMON_7;
			end
			
			S_COMMON_7: begin
			SRAM_we_n <= 1'd1;	
			//RGB_green <= RGB_green_buf;
			SRAM_write_data <= {(RGB_green[15] ? 8'd0: | RGB_green[14:8] ? 8'd255: RGB_green[7:0]), (RGB_blue[15] ? 8'd0: | RGB_blue[14:8] ? 8'd255: RGB_blue[7:0])}; 			// Write GODD/BODD(G1B1)
			U_odd_accum <= Multi_result_long1;			// 21(U0 + U4)
			V_odd_accum2 <=  Multi_result_long2;			// 21(V0 + V4)
			state <= S_COMMON_8;
			end

			S_COMMON_8: begin
			U_odd_accum <= $signed(U_odd_accum - Multi_result_long1);	// 21(U0 + U4) - 52(U0 + U3) 
			V_odd_accum2 <= $signed(V_odd_accum2 - Multi_result_long1);	// 21(V0 + V4) - 52(V0 + V3) 
			state <= S_COMMON_9;
			end
			
			S_COMMON_9: begin
			//No U Address here
			U_odd_accum <= $signed(U_odd_accum + Multi_result_long1 + 18'd128)>>8; // U1’=[21(U0 + U3) - 52(U0 + U2) + 159 (U0+U1)]/256
			V_odd_accum2 <= $signed(V_odd_accum2 + Multi_result_long1 + 18'd128)>>8; // V1’ =[21(V0 + V5) - 52(V1 + V2) + 159 (U0+U1)]/256
			state <= S_COMMON_10;
			end
			
			S_COMMON_10: begin
			//No V Address here
			RGB_red <= $signed(Multi_result_long1 + Multi_result_long2) >> 16; //76284+104595
			RGB_green <= Multi_result_long1;			 //76284
			RGB_blue <= Multi_result_long1;			//76284

			state <= S_COMMON_11;
			end
			
			S_COMMON_11: begin

			SRAM_address <= Y_address + Y_OFFSET;		//location 2 (Y4,Y5)
			Y_address <= Y_address + 16'd1;			//increment Y add value by 1
			RGB_green <= $signed(RGB_green - Multi_result_long1 - Multi_result_long2) >> 16;//store green pixel value
			SRAM_we_n <= 1'd1;				//write in next clock cycle
		
			state <= S_COMMON_12;				
			end
			
			S_COMMON_12: begin
			Y_odd2 <= SRAM_read_data[7:0]; //Buffer Y5
			U_shift  <= (U_shift << 18'd8);				//shift one value
			U_shift [7:0] <= U_odd;				//add new value in LSB
			SRAM_address <= RGB_address + RGB_OFFSET;	//Move to RGB segment to write 
			RGB_address <= RGB_address + 18'd1;		 //Increment address 
			
			RGB_blue <= $signed(RGB_blue + Multi_result_long1) >> 16; 	//B0
			RGB_green_buf <= Multi_result_long2;			//Next green px partial value
			SRAM_we_n <= 1'd0;				//no write in next cycle

			state <= S_COMMON_13;
			end
			
			S_COMMON_13: begin

			V_shift  <= (V_shift << 18'd8);				//shift one value
			V_shift [7:0] <= V_odd;		//add new value in LSB
			
			SRAM_write_data <= {(RGB_red[15] ? 8'd0: | RGB_red[14:8] ? 8'd255: RGB_red[7:0]), (RGB_green[15] ? 8'd0: | RGB_green[14:8] ? 8'd255: RGB_green[7:0])}; 		//RevenGeven(R2G2)
			
			SRAM_address <= RGB_address + RGB_OFFSET;	//move to Beven   /Rodd
			RGB_address <= RGB_address + 18'd1;		//inc RGB address	
			RGB_red_buf <= $signed(Multi_result_long1 + Multi_result_long2) >> 16; 	//R3
			RGB_green <= $signed(Multi_result_long1 - RGB_green_buf);		//partial g sum
			RGB_blue_buf <= Multi_result_long1; //need to buffer here, 76284*yodd
			SRAM_we_n <= 1'd0;
			state <= S_COMMON_14;
			end
			
			S_COMMON_14: begin
			//Y_even <= SRAM_read_data[15:8]; // Buffer Y4
			
			SRAM_write_data <= {(RGB_blue[15] ? 8'd0: | RGB_blue[14:8] ? 8'd255: RGB_blue[7:0]), (RGB_red[15] ? 8'd0: | RGB_red[14:8] ? 8'd255: RGB_red[7:0])}; 		// write Beven   /Rodd(B2R3)

			RGB_green <= $signed(RGB_green - Multi_result_long1) >>16;		//Computed GODD
			RGB_blue <= $signed(RGB_blue_buf + Multi_result_long1) >>16;		//Computed BODD
			SRAM_address <= RGB_address + RGB_OFFSET;		//Move to write address
			RGB_address <= RGB_address + 18'd1;		//inc RGB address	
			SRAM_we_n <= 1'd0;	
			U_odd_accum <= 32'd0;	
			V_odd_accum <= 32'd0;	
			state <= S_COMMON_15;
			end
			
			S_COMMON_15: begin
			SRAM_write_data <= {(RGB_green[15] ? 8'd0: | RGB_green[14:8] ? 8'd255: RGB_green[7:0]), (RGB_blue[15] ? 8'd0: | RGB_blue[14:8] ? 8'd255: RGB_blue[7:0])}; 			// Write GODD/BODD(G3B3)
			U_odd_accum <= Multi_result_long1;			// 21(U0 + U5)
			V_odd_accum <=  Multi_result_long2;			// 21(V0 + V5)
			SRAM_we_n <= 1'd1;	
				if (col_counter == 8'd157 ) begin
					if ((RGB_address + RGB_OFFSET) == 18'd262143) begin
						m1_end <= 1'b1;
						state <= S_M1_IDLE;
					end else begin
						state <= S_LEAD_IN_0;
					end
				
				end else
					state <=  S_COMMON_0;
			end
			
			default: state <= S_M1_IDLE;
			
		endcase
	end
end


endmodule
