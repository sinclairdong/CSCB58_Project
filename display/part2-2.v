// Part 2 skeleton

module testdisplay
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
		HEX3
	);

	input			CLOCK_50;				//	50 MHz
	input   [17:0]   SW;
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
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
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
			.colour(colour),
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
	datapath d0(
		    .position(q),
		    .col(q2),
		    .resetn(resetn),
		    .clock(CLOCK_50),
		    .x_out(x),
		    .y_out(y),
		    .col_out(colour));
    
    wire RateDivider, enable;
    counter_28_bits (RateDivider, resetn , CLOCK_50, SW[16], 28'b010111110101111000010000000);
	assign enable = (RateDivider == 28'b0) ? 1 : 0;
	
	wire [7:0] q;
	counter_8_bits pos (q, resetn, enable, SW[16]);
	wire [2:0] q2;
	counter_3_bits col (q2, resetn, enable, SW[16]);
	hex_display(q[3:0], HEX0);
	hex_display(q[7:4], HEX1);
	hex_display(q2[2:0], HEX3);
	
	// sw 16 start
	// sw 17 high to allow changes
    
endmodule




module datapath(
    input resetn, clock,
	input [2:0] col,
	input [7:0] position,
	output [7:0] x_out,
	output [6:0] y_out,
	output [2:0] col_out


);

	reg [7:0] x;
	reg [6:0] y;
	reg [3:0] counter;
	
	always @(posedge clock)
	begin
		if (!resetn)
			counter <= 4'b0000;
		else 
		begin
			if (counter == 4'b1111)
				counter <= 4'b0000;
			else
				counter <= counter + 1'b1;
		end
	end

	assign x_out = position[7:4] * 10 + counter[1:0];
	assign y_out = position[3:0] * 10 + counter[3:2];
	assign col_out = col;

endmodule


