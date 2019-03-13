/* 
    instruction 
    left 4 bit player 1
    right 4 bit player 2
    
    first bit fire
    last 3 bit movement
        000 stay still
        100 move left
        001 move right
        010 move up
        111 move down 
    
    11111111 reset
    11111110 pause
    
    example 00000000 no input
    example 10000000 player 1 fire
    exmaple 01000000 player 1 move left
    example 01110000 player 1 move down
    example 00000111 player 2 move down
    example 01001111 invalid

*/

module input
    (
        output reg instruction,
        input clk,
        input kbclk,
        input kbdat
        input reset
    );
    
    wire [7:0] kb_scan_code;
    wire kb_scan_ready;
    
    // Instantiate keyboard input interface
    keyboard k0
        (
            .clk(clk),
            .reset(~reset),
            .ps2d(kbdat),
            .ps2c(kbclk),
            .scan_code(kb_scan_code),
            .scan_code_ready(kb_scan_ready),
            .letter_case_out(kb_upper_case_flag)            
        );
    
    	 always @(*)
    	 
	 begin
		case(IN[7:0])
			8'b1110101: instruction = 8'b00000010;  // up    p2  arrow
			8'b1110010: instruction = 8'b00000111;  // down  p2  arrow
			8'b1101011: instruction = 8'b00000001;  // right p2  arrow
			8'b1110100: instruction = 8'b00000100;  // left  p2  arrow
			8'b1110000: instruction = 8'b00001000;  // fire  p2  key pad
			8'b0011101: instruction = 8'b00100000;  // up    p1  w
			8'b0011011: instruction = 8'b01110000;  // down  p1  s
			8'b0011100: instruction = 8'b01000000;  // left  p1  a
			8'b0100011: instruction = 8'b00010000;  // right p1  d
			8'b0101001: instruction = 8'b10000000;  // fire  p1  space
			8'b0101101: instruction = 8'b11111111;  // reset r
			8'b1001101: instruction = 8'b11111110;  // pause
			

			
			default: instruction = 8'b00000000;
		endcase

	end
    
    
endmodule
