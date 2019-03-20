// Tank

module tank
    (
        CLOCK_50,                        //    On Board 50 MHz
        // Your inputs and outputs here
        KEY,
        SW,
        // The ports below are for the VGA output.  Do not change.
        VGA_CLK,                           //    VGA Clock
        VGA_HS,                            //    VGA H_SYNC
        VGA_VS,                            //    VGA V_SYNC
        VGA_BLANK_N,                        //    VGA BLANK
        VGA_SYNC_N,                        //    VGA SYNC
        VGA_R,                           //    VGA Red[9:0]
        VGA_G,                             //    VGA Green[9:0]
        VGA_B,
		  SW

		  //    VGA Blue[9:0]
    );
    input   CLOCK_50;                //    50 MHz
    input   [17:0]   SW;
    input   [3:0]   KEY;
    // Declare your inputs and outputs here
    // Do not change the following outputs
    output            VGA_CLK;                   //    VGA Clock
    output            VGA_HS;                    //    VGA H_SYNC
    output            VGA_VS;                    //    VGA V_SYNC
    output            VGA_BLANK_N;                //    VGA BLANK
    output            VGA_SYNC_N;                //    VGA SYNC
    output    [9:0]    VGA_R;                   //    VGA Red[9:0]
    output    [9:0]    VGA_G;                     //    VGA Green[9:0]
    output    [9:0]    VGA_B;                   //    VGA Blue[9:0]
   
    wire resetn;
	 wire wipe;
    assign resetn = 1'b1 ;
	 assign SW17 = wipe;
   
    // Create an Instance of a VGA controller - there can be only one!
    // Define the number of colours as well as the initial background
    // image file (.MIF) for the controller.
    vga_adapter VGA(
            .resetn(resetn),
            .clock(CLOCK_50),
            .colour(color),
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
	 // cannot be changed due to the restriction of our vga adapter
    defparam VGA.RESOLUTION = "160x120"; 
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BACKGROUND_IMAGE = "black.mif";
	 
	 // instantiate to erase the backgroun
	 wire [6:0] x_out, y_out;
	 wire [2:0] col_out;
	 reset_background reset(.clock(CLOCK_50), .drawEn(wipe), .x_out(x_out), .y_out(y_out), .col_out(col_out));
	 // tank's x cooridinate
	 assign x = wipe ? x_out: w_x;
	 // tank's y coordinate
	 assign y = wipe ? y_out: w_y;
	 // if wipe is toggled, fill the monitor with black
	 // otherwise, tank color
	 assign color = wipe ? col_out: output_colour;
	 
	 //-----------------------
	
    // Put your code here. Your code should produce signals x,y,colour and writeEn/plot
    // for the VGA controller, in addition to any other functionality your design may require.
	reg tank = 26'b00000011111111111111111111;
    wire ld_x, ld_y;
	 wire write;
	 wire [6:0] w_x, w_y;
    wire [2:0] color;
    reg [2:0] white = 3'b111;
    wire [6:0] x;
    wire [6:0] y;
    wire  writeEn;
    wire [3:0] stateNum;
	 // take 6-bits input for the initial position for player1 and player2
    reg [5:0] init_x = 6'b111111;
    reg [5:0] init_y = 6'b000000;
	 // take the output to be the color
    wire [2:0] output_colour;
	 // counter input shu yao hua ji ge
    reg [25:0] ccc = 26'b0;
    // Instansiate datapath 
    datapath d(.clk(CLOCK_50), .ld_x(ld_x), .ld_y(ld_y), .in_x(init_x), .in_y(init_y), .reset_n(resetn), .x(w_x), .y(w_y), .output_colour(output_colour),
	 .write(writeEn), .stateNum(stateNum), .init_y(init_y), .color(white));
   
    // Instansiate FSM control
    control c(.clk(CLOCK_50), .move_r(~KEY[0]), .move_l(~KEY[3]), .move_d(~KEY[1]), .move_u(~KEY[2]), .reset_n(resetn), .ld_x(ld_x), .ld_y(ld_y), .stateNum(stateNum), .reset_game(reset_game), .cc(ccc), .speed(tank));
endmodule   


module reset_background(clock, drawEn, x_out, y_out, col_out);
	input drawEn, clock;
	output [6:0] x_out;
	output [6:0] y_out;
	output [2:0] col_out;
	reg [6:0] x;
	reg [6:0] y;
	// mei count 6 ge x de bits, y jai 1
	reg [11:0] counter;
	assign col_out = 3'b000;
	
	always @(posedge clock)
	begin
	// 
		if (!drawEn)
			counter <= 12'b000000000000;
		else if (drawEn)
		begin
		// ru guo dau di le
			if (counter == 12'b111111111111)
				counter <= 12'b000000000000;
			else
			// update the counter
				counter <= counter + 1'b1;
		end
	end

	assign x_out = x + counter[5:0];
	assign y_out = y + counter[11:6];
endmodule


module control(clk, move_r, move_l, move_d, move_u, reset_n, ld_x, ld_y, stateNum, reset_game, cc, speed);
    input [25:0] cc;
    input reset_game;
    input clk, move_r, move_l, move_d, move_u, reset_n;
    output reg ld_y, ld_x;
    reg [3:0] curr, next;
    output reg [3:0] stateNum;
    localparam S_CLEAR    = 4'b0000;
    localparam S_LOAD_X    = 4'b0001;
    localparam S_WAIT_Y    = 4'b0010;
    localparam S_LOAD_Y    = 4'b0011;
    localparam wait_input    = 4'b0100;
    localparam clear_all    = 4'b0101;
    localparam print_right    = 4'b0110;
    localparam print_left    = 4'b0111;
    localparam print_down    = 4'b1000;
    localparam print_up    = 4'b1001;
    localparam temp_selecting_state = 4'b1010;
    localparam after_drawing = 4'b1011;
    localparam cleanUp = 4'b1100;
    wire [26:0] now;
    wire result;
	input [25:0] speed;

	RateDivider rd(clk, now, reset_n, speed);
	 
    assign result = (now == cc) ? 1 : 0;
   
    always @(*)
    begin: state_table
        case (curr)
            S_CLEAR: next = S_LOAD_X ;
            S_LOAD_X: next = S_WAIT_Y;
            S_WAIT_Y: next = S_LOAD_Y;
            S_LOAD_Y: next = temp_selecting_state;
            temp_selecting_state: next = reset_game ? cleanUp : ( ((move_r || move_l || move_d || move_u) && result) ? clear_all : S_LOAD_Y );
            clear_all:
                begin
                    if(move_r) 
                        next <= print_right;
                    else if (move_l)
                        next <= print_left;
                    else if (move_d)
                        next <= print_down;
                    else if (move_u) 
                        next <= print_up;
                end
            cleanUp: next = S_CLEAR;
            print_right: next = reset_game ? S_LOAD_Y : after_drawing;
            print_left: next =  reset_game ? S_LOAD_Y : after_drawing;
            print_down: next = reset_game ? S_LOAD_Y : after_drawing;
            print_up: next = reset_game ? S_LOAD_Y : after_drawing;
            after_drawing: next= temp_selecting_state;
        default: next = S_CLEAR;
        endcase
    end

    always@(*)
    begin: enable_signals
        ld_x = 1'b0;
        ld_y = 1'b0;
        stateNum = 4'b0000;
        case (curr)
            S_LOAD_X:
            	begin
                ld_x = 1'b1;
                end

            S_LOAD_Y:
            	begin
                ld_y = 1'b1;
                end

            cleanUp:
            	begin
                stateNum = 4'b0001;
                ld_y = 1'b0;
                end

            clear_all:
            	begin
                stateNum = 4'b0001;
                ld_y = 1'b0;
                end
           
            print_right:
            	begin
                stateNum = 4'b0100;
                ld_y = 1'b0;
                end
           
            print_down:
            	begin
                stateNum = 4'b0011;
                ld_y = 1'b0;
                end
               
            print_left:
            	begin
                stateNum = 4'b0010;
                ld_y = 1'b0;
                end

            print_up:
            	begin
                stateNum = 4'b1001;
                ld_y = 1'b0;
                end      
            after_drawing:
            	begin
                stateNum = 4'b1000;
                end
           
        endcase
    end

    always @(posedge clk)
    begin: states
        if(!reset_n)
            curr <= S_LOAD_X;
        else
            curr <= next;
    end

endmodule

module datapath(clk, ld_x, ld_y, in_x, in_y, reset_n, x, y, output_colour, stateNum, write, init_y, color);
    input clk;
    input [6:0] in_x, in_y;
    input [6:0] init_y;
    input [2:0] color;
    input ld_x, ld_y;
    input reset_n;
    output reg [2:0] output_colour;
    output reg write;
    output reg [6:0] y;
    output reg [6:0] x;
    input [3:0] stateNum;

    always @(posedge clk)
    begin
        if(!reset_n)
        begin
            x <= 6'b000000;
            y <= 6'b000000;
            output_colour <= 3'b000;
        end
        else
        begin
            if(ld_x)
                begin
                    x[6:0] <= in_x;
                    y[6:0] <= in_y;
                    write <= 1'b0;
                end
            else if(ld_y)
                begin
                    write <= 1'b0;
                end
               
            else if(stateNum == 4'b0001)
                begin
                    output_colour <= 3'b000;
                    write <= 1'b1;
                end
               
            else if(stateNum == 4'b0100)   
                begin
               
                    x[6:0] <= x + 7'b000001;
                    output_colour <= color;
                    write <= 1'b1;
                end
               
            else if(stateNum == 4'b0010)   
                begin
               
                    x[6:0] <= x - 7'b000001;
                    output_colour <= color;
                    write <= 1'b1;
                end
               
            else if(stateNum == 4'b0011)
					 begin
							begin
							if (x != 7'b1110000)
								begin
								  y[6:0] <= y + 6'b000001;
								  output_colour <= color;
								  write <= 1'b1;
								end
							else
									write <= 1'b0;
							
							end
                end
               
            else if(stateNum == 4'b1001)
                begin
               
                    y[6:0] <= y - 6'b000001;
                    output_colour <= output_colour;
                    write <= 1'b1;
                end

            else if(stateNum == 4'b1000)
                begin
                    write <= 1'b0;
                end
			end
		end
endmodule
   
   
module RateDivider (clock, q, Clear_b, speed);
    input [0:0] clock;
    input [0:0] Clear_b;
	 input [25:0] speed;
    output reg [26:0] q;
    always@(posedge clock)
    begin
        if (q == speed)
            q <= 0;
        else if (clock == 1'b1)
            q <= q + 1'b1;
    end
endmodule
