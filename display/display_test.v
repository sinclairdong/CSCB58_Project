// Part 2 skeleton

module display_test
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        // KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		HEX0,
		HEX1,
		HEX3,
		LEDR,
		KEY
	);

	input			CLOCK_50;				//	50 MHz
	input   [17:0]   SW;
	input [3:0] KEY;
	output [17:0] LEDR;
	// input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	output [7:0] HEX0;
	output [7:0] HEX1;
	output [7:0] HEX3;
	
	wire resetn;
	assign resetn = SW[17];
	wire done;
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [7:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	/*
	resetn,
			clock,
			colour,
			x, y, plot,
			VGA_R,
			VGA_G,
			VGA_B,
			VGA_HS,
			VGA_VS,
			VGA_BLANK,
			VGA_SYNC,
			VGA_CLK);
	*/
	
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(col),
			.x(x),
			.y(y),	
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
	
    // Instansiate datapath
	display d0(
	.clock(CLOCK_50),
		    .position(SW[7:0]),
		    .address(SW[15:8]),
		    .done(done),
		    
		    .x(x),
		    .y(y),
		    .colour(colour));
    
	 assign writeEn = KEY[0];
    wire [27:0] RateDivider; 
	 wire enable;
    counter_28_bits (RateDivider, resetn , CLOCK_50, SW[16]);
	assign enable = (RateDivider == 28'b0) ? 1 : 0;
	wire col;
	assign col = 3'b001;
	wire [7:0] q;
	counter_8_bits pos (q, resetn, CLOCK_50, enable);
	hex_display(q[3:0], HEX0);
	hex_display(q[7:4], HEX1);
	assign LEDR[17] = enable;
	
	// sw 16 start	input [2:0] 	hex_display(q2[2:0], HEX3);color,
	// sw 17 high to allow changes
	
    
endmodule

/*
module get_address(
	// get the data for read
	input mode 4b'0000;
	input load_out 1'b1;
		done,
		x,
	input clk;
	input reset;
	
	// get the address
	output [7:0]address;
	output [7:0]position;
	
		 )

endmodule
*/

// position
//8 bit ram (according to ram contract)
//|_7_|___6__|__5__|_4__|_3_|__2_|____1____|____0____|
// wall tank1 tank2 proj di1 di2



