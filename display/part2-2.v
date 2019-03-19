// Part 2 skeleton

module lab6b
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
		VGA_B   						//	VGA Blue[9:0]
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
	wire ld_x, ld_y, ld_c, drawEn;
	
    // Instansiate datapath
	datapath d0(.ld_x(ld_x),
		    .ld_y(ld_y),
		    .ld_c(ld_c),
		    .drawEn(drawEn),
		    .position(SW[6:0]),
		    .col(SW[9:7]),
		    .resetn(resetn),
		    .clock(CLOCK_50),
		    .x_out(x),
		    .y_out(y),
		    .col_out(colour));

    // Instansiate FSM control
	control c0(.go(SW[16]),
		   .ld(SW[15]),
		   .resetn(resetn),
		   .clock(CLOCK_50),
		   .ld_x(ld_x),
		   .ld_y(ld_y),
		   .ld_c(ld_c),
		   .writeEn(writeEn),
		   .drawEn(drawEn));
    
endmodule

module datapath(ld_x, ld_y, ld_c, drawEn, position, col, resetn, clock, x_out, y_out, col_out);
	input ld_x, ld_y, ld_c, drawEn, resetn, clock;
	input [2:0] col;
	input [6:0] position;
	output [7:0] x_out;
	output [6:0] y_out;
	output [2:0] col_out;

	reg [7:0] x;
	reg [6:0] y;
	reg [2:0] c;
	reg [3:0] counter;
	
	always @(posedge clock)
	begin
		if (!resetn)
		begin
			x = 8'b00000000;
			y = 7'b0000000;
			c = 3'b000;
		end
		else
		begin
			if (ld_x)
				x <= {1'b0, position};
			else if (ld_y)
				y <= position;
			else if (ld_c)
				c <= col;
		end
	end
	
	always @(posedge clock)
	begin
		if (!resetn)
			counter <= 4'b0000;
		else if (drawEn)
		begin
			if (counter == 4'b1111)
				counter <= 4'b0000;
			else
				counter <= counter + 1'b1;
		end
	end

	assign x_out = x + counter[1:0];
	assign y_out = y + counter[3:2];
	assign col_out = c;

endmodule

module control(go, ld, resetn, clock, ld_x, ld_y, ld_c, writeEn, drawEn);

	input go, ld, resetn, clock;
	output reg ld_x, ld_y, ld_c, writeEn, drawEn;
	
	reg [2:0] curr_state, next_state;

	localparam      Load_x = 3'd0,
			Load_x_wait= 3'd1,
			Load_y = 3'd2,
			Load_y_wait = 3'd3,
			Load_c = 3'd4,	
			Load_c_wait = 3'd5,				
			Draw = 3'd6;

	always @(*)
	begin: state_table
		case (curr_state)
			Load_x: next_state = ld ? Load_x_wait : Load_x;
			Load_x_wait: next_state = ld ? Load_x_wait : Load_y;
			Load_y: next_state = ld ? Load_y_wait : Load_y;
			Load_y_wait: next_state = ld ? Load_y_wait : Load_c;
			Load_c: next_state = go ? Load_c_wait : Load_c;
			Load_c_wait: next_state = go ? Load_c_wait : Draw;
			Draw: next_state = ld ? Load_x : Draw;
			default: next_state = Load_x;
		endcase
	end
	
	always @(*)
	begin: part2_signals
		ld_x = 1'b0;
		ld_y = 1'b0;
		ld_c = 1'b0;
		writeEn = 1'b0;
		drawEn = 1'b0;
		case (curr_state)
			Load_x: begin
				ld_x = 1'b1;
				end
			Load_y: begin
				ld_y = 1'b1;
				end
			Load_c: begin
				ld_c = 1'b1;
				end
			Draw: begin
				writeEn = 1'b1;
				drawEn = 1'b1;
				end
		endcase
	end
	
	always@(posedge clock)
	begin: state_FFs
        if(!resetn)
            curr_state <= Load_x;
        else
            curr_state <= next_state;
    end
endmodule