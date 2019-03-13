module color
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
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
		LEDG
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
	output [3:0] LEDG;

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
	assign resetn = KEY[0];
	assign LEDG[3] = ~KEY[3];
	assign LEDG[0] = KEY[0];
	assign LEDG[1] = KEY[1];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [6:0] x;
	wire [6:0] y;
	wire writeEn;
	wire ld_X, ld_Y, C_enable;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
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
	// datapath d0(...);
	datapath dd(
	.clk(CLOCK_50),
	.enable(C_enable),
	.resetn(resetn),
	.data_in(SW[6:0]),
	.ld_X(ld_X),
	.ld_Y(ld_Y),
	.color(SW[9:7]),
	.Xout(x),
	.Yout(y),
	.colorout(colour)
	);

    // Instansiate FSM control
    // control c0(...);
	 
    control cc(
	 .clk(CLOCK_50),
	 .resetn(resetn),
	 .go(KEY[1]),
	 .load(~KEY[3]),
	 .ld_X(ld_X),
	 .ld_Y(ld_Y),
	 .plot(writeEn),
	 .enable(C_enable)
	 );

	 
endmodule


module CounterFor4x4( clock, clear_b, enable, Q);
	input clock, clear_b, enable;
	output [3:0] Q;

	TFFF T0(
	.clear_b(clear_b),
	.clock(clock),
	.T(enable),
	.Q(Q[0])
	);
	
	TFFF T1(
	.clear_b(clear_b),
	.clock(clock),
	.T(Q[0] && enable),
	.Q(Q[1])
	);
	
	TFFF T2(
	.clear_b(clear_b),
	.clock(clock),
	.T(Q[0] && Q[1] && enable),
	.Q(Q[2])
	);
	
	TFFF T3(
	.clear_b(clear_b),
	.clock(clock),
	.T(Q[0] && Q[1] && Q[2] && enable),
	.Q(Q[3])
	);

	
endmodule


// T-FF
module TFFF(clock, clear_b, T, Q);
	input clear_b, clock, T;
	output reg Q;

	
	always @(posedge clock, negedge clear_b)
	begin
		if (clear_b == 1'b0)
			Q <= 1'b0;
		else
			Q <= Q ^ T;
	end
endmodule



module control(
    input clk,
    input resetn,
    input go,
	 input load,
    output reg  ld_X, ld_Y, plot, enable
    );

    reg [4:0] current_state, next_state; 
    
    localparam  S_LOAD_Y        = 5'd0,
                S_LOAD_Y_WAIT   = 5'd1,
                S_LOAD_X        = 5'd2,
                S_LOAD_X_WAIT   = 5'd3,
                S_CYCLE_0       = 5'd4,
					 S_CYCLE_1       = 5'd5,
					 S_CYCLE_2       = 5'd6,
					 S_CYCLE_3       = 5'd7,
					 S_CYCLE_4       = 5'd8,
					 S_CYCLE_5       = 5'd9,
					 S_CYCLE_6       = 5'd10,
					 S_CYCLE_7       = 5'd11,
					 S_CYCLE_8       = 5'd12,
					 S_CYCLE_9       = 5'd13,
					 S_CYCLE_A       = 5'd14,
					 S_CYCLE_B       = 5'd15,
					 S_CYCLE_C       = 5'd16,
					 S_CYCLE_D       = 5'd17,
					 S_CYCLE_E       = 5'd18,
					 S_CYCLE_F       = 5'd19;
					 
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_LOAD_Y: next_state = go ? S_LOAD_Y_WAIT : S_LOAD_Y; // Loop in current state until value is input
                S_LOAD_Y_WAIT: next_state = go ? S_LOAD_Y_WAIT : S_LOAD_X; // Loop in current state until go signal goes low
                S_LOAD_X: next_state = load ? S_LOAD_X_WAIT : S_LOAD_X; // Loop in current state until value is input
                S_LOAD_X_WAIT: next_state = go ? S_LOAD_X_WAIT : S_CYCLE_0; // Loop in current state until go signal goes low
                S_CYCLE_0: next_state = S_CYCLE_1;
					 S_CYCLE_1: next_state = S_CYCLE_2;
					 S_CYCLE_2: next_state = S_CYCLE_3;
					 S_CYCLE_3: next_state = S_CYCLE_4;
					 S_CYCLE_4: next_state = S_CYCLE_5;
					 S_CYCLE_5: next_state = S_CYCLE_6;
					 S_CYCLE_6: next_state = S_CYCLE_7;
					 S_CYCLE_7: next_state = S_CYCLE_8;
					 S_CYCLE_8: next_state = S_CYCLE_9;
					 S_CYCLE_9: next_state = S_CYCLE_A;
					 S_CYCLE_A: next_state = S_CYCLE_B;
					 S_CYCLE_B: next_state = S_CYCLE_C;
					 S_CYCLE_C: next_state = S_CYCLE_D;
					 S_CYCLE_D: next_state = S_CYCLE_E;
					 S_CYCLE_E: next_state = S_CYCLE_F;
					 S_CYCLE_F: next_state = S_LOAD_Y; // we will be done, start over after
            default:     next_state = S_LOAD_Y;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_X = 1'b0;
        ld_Y = 1'b0;
		  enable = 1'b0;
		  plot = 1'b0;

        case (current_state)
            S_LOAD_X: begin
                ld_X = 1'b1;
					 ld_Y = 1'b0;
					 plot = 1'b0;
					 enable = 1'b0;
                end
            S_LOAD_Y: begin
                ld_Y = 1'b1;
					 ld_X = 1'b0;
					 plot = 1'b0;
					 enable = 1'b0;
                end
            S_CYCLE_0: begin // start counter 
					ld_X = 1'b0;
					ld_Y = 1'b0;
					plot = 1'b1;
					enable = 1'b1;
					end
				S_CYCLE_1: begin // start counter 
					ld_X = 1'b0;
					ld_Y = 1'b0;
					plot = 1'b1;
					enable = 1'b1;
					end
					
				S_CYCLE_2: begin // start counter 
					ld_X = 1'b0;
					ld_Y = 1'b0;
					plot = 1'b1;
					enable = 1'b1;
					end
					
				S_CYCLE_3: begin // start counter 
					ld_X = 1'b0;
					ld_Y = 1'b0;
					plot = 1'b1;
					enable = 1'b1;
					end
					
				S_CYCLE_4: begin // start counter 
					ld_X = 1'b0;
					ld_Y = 1'b0;
					plot = 1'b1;
					enable = 1'b1;
					end
					
				S_CYCLE_5: begin // start counter 
					ld_X = 1'b0;
					ld_Y = 1'b0;
					plot = 1'b1;
					enable = 1'b1;
					end
					
				S_CYCLE_6: begin // start counter 
					ld_X = 1'b0;
					ld_Y = 1'b0;
					plot = 1'b1;
					enable = 1'b1;
					end

				S_CYCLE_7: begin // start counter 
					ld_X = 1'b0;
					ld_Y = 1'b0;
					plot = 1'b1;
					enable = 1'b1;
					end

					
				S_CYCLE_8: begin // start counter 
					ld_X = 1'b0;
					ld_Y = 1'b0;
					plot = 1'b1;
					enable = 1'b1;
					end
					
				S_CYCLE_9: begin // start counter 
					ld_X = 1'b0;
					ld_Y = 1'b0;
					plot = 1'b1;
					enable = 1'b1;
					end
					
				S_CYCLE_A: begin // start counter 
					ld_X = 1'b0;
					ld_Y = 1'b0;
					plot = 1'b1;
					enable = 1'b1;
					end
					
				S_CYCLE_B: begin // start counter 
					ld_X = 1'b0;
					ld_Y = 1'b0;
					plot = 1'b1;
					enable = 1'b1;
					end
					
				S_CYCLE_C: begin // start counter 
					ld_X = 1'b0;
					ld_Y = 1'b0;
					plot = 1'b1;
					enable = 1'b1;
					end
					
				S_CYCLE_D: begin // start counter 
					ld_X = 1'b0;
					ld_Y = 1'b0;
					plot = 1'b1;
					enable = 1'b1;
					end
					
				S_CYCLE_E: begin // start counter 
					ld_X = 1'b0;
					ld_Y = 1'b0;
					plot = 1'b1;
					enable = 1'b1;
					end
				
				S_CYCLE_F: begin // start counter 
					ld_X = 1'b0;
					ld_Y = 1'b0;
					plot = 1'b1;
					enable = 1'b1;
					end
				

        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD_Y;
        else
				current_state <= next_state;
    end // FSM
endmodule

module datapath(
    input clk,
	 input enable,
    input resetn,
	 input [6:0] data_in,
    input ld_X,
	 input ld_Y,
    input [2:0] color,
    output [6:0] Xout,
	 output [6:0] Yout,
	 output [2:0] colorout
    );
	 
	 reg [8:0] Xo;
	 reg [7:0] Yo;
	 wire [3:0] cout;
	 wire [1:0] cl, cm;
    
    // Registers X, Y, with respective input logic
    always@(posedge clk) begin
        if(!resetn) begin
            Xo <= 8'b0; 
            Yo <= 7'b0;
        end
        else begin
		      if (ld_X)
                Xo <= {1'b0, data_in};
            if (ld_Y)
                Yo <= data_in;
        end
    end
	 
	 assign colorout = color;
	 
	 CounterFor4x4 cF(
	 .clock(clk),
	 .clear_b(resetn),
	 .enable(enable),
	 .Q(cout)
	 );
	 assign cl = {5'b0, cout[3:2]}; // least significant 2 bits
	 assign cm = {5'b0, cout[1:0]}; // most significant 2 bits
    assign Xout = Xo + cl;
    assign Yout = Yo + cm;

    
endmodule
