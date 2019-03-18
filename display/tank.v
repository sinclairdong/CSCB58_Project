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
        VGA_B,                           //    VGA Blue[9:0]
    );
    input   CLOCK_50;                //    50 MHz
    input   [9:0]   SW;
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
    assign resetn = 1'b1 ;
   
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
    defparam VGA.RESOLUTION = "160x120";
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BACKGROUND_IMAGE = "black.mif";
	 
	 //-----------------------
	
    // Put your code here. Your code should produce signals x,y,colour and writeEn/plot
    // for the VGA controller, in addition to any other functionality your design may require.
	reg tank = 26'b00000011111111111111111111;
    wire ld_x, ld_y;
    wire [2:0] colour;
    wire [2:0] white = 3'b111;
    wire [6:0] x;
    r [6:0] y;
    reg  writeEn;
    wire [3:0] stateNum;
    reg [6:0] init_x = 7'b1111111;
    reg [6:0] init_y = 7'b1111111;
    wire [2:0] color;
    reg [25:0] ccc = 26'b0;
    // Instansiate datapath 
    datapath d(.clk(CLOCK_50), .ld_x(ld_x), .ld_y(ld_y), .in_x(init_x), .in_y(init_y), .reset_n(resetn), .x(signal_x), .y(signal_y), .colour(color), .write(writeEn), .stateNum(stateNum), .init_y(init_y), .color(white));
   
    // Instansiate FSM control
    control c(.clk(CLOCK_50), .move_r(~KEY[0]), .move_l(~KEY[3]), .move_d(~KEY[1]), .move_u(~KEY[2]), .reset_n(resetn), .ld_x(ld_x), .ld_y(ld_y), .stateNum(stateNum), .reset_game(reset_game), .cc(ccc), .speed(tank));
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

	RateDividerForCar rd(clk, now, reset_n, speed);
	 
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

module datapath(clk, ld_x, ld_y, in_x, in_y, reset_n, x, y, colour, stateNum, write, init_y, color);
    input clk;
    input [6:0] in_x, in_y;
    input [6:0] init_y;
    input [2:0] color;
    input ld_x, ld_y;
    input reset_n;
    output reg [2:0] colour;
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
            colour <= 3'b000;
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
                    colour <= 3'b000;
                    write <= 1'b1;
                end
               
            else if(stateNum == 4'b0100)   
                begin
               
                    x[6:0] <= x + 7'b000001;
                    colour <= color;
                    write <= 1'b1;
                end
               
            else if(stateNum == 4'b0010)   
                begin
               
                    x[6:0] <= x - 7'b000001;
                    colour <= color;
                    write <= 1'b1;
                end
               
            else if(stateNum == 4'b0011)
					 begin
							begin
							if (x != 7'b1110000)
								begin
								  y[6:0] <= y + 6'b000001;
								  colour <= color;
								  write <= 1'b1;
								end
							else
									write <= 1'b0;
							
							end
                end
               
            else if(stateNum == 4'b1001)
                begin
               
                    y[6:0] <= y - 6'b000001;
                    colour <= colour;
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

