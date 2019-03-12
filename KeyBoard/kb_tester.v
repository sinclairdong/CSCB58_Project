// code from https://github.com/armitag8/ASIC_Notepad--
module kb_tester
    (
        output [6:0] HEX0,
        output [6:0] HEX1,
        output [0:0] LEDR,
        output [0:0] LEDG,
        input CLOCK_50,
        input PS2_KBCLK,
        input PS2_KBDAT,
        input [0:0] KEY
    );
    
    wire [7:0] kb_scan_code, ascii_code;
    wire kb_scan_ready, kb_upper_case_flag;
    
    // Instantiate keyboard input interface
    keyboard k0
        (
            .clk(CLOCK_50),
            .reset(KEY[0]),
            .ps2d(PS2_KBDAT),
            .ps2c(PS2_KBCLK),
            .scan_code(kb_scan_code),
            .scan_code_ready(kb_scan_ready),
            .letter_case_out(kb_upper_case_flag)            
        );
    
    assign LEDR[0] = kb_upper_case_flag;
    assign LEDG[0] = kb_scan_ready;
    
    translate_to_ASCII t0
        (
            .IN(kb_scan_code),
            .OUT(ascii_code)
        );
    
    hex_display h0
        (
            .IN(ascii_code[3:0]),
            .OUT(HEX0)
        );
    
    hex_display h1
        (
            .IN(ascii_code[7:4]),
            .OUT(HEX1)
        );
endmodule

module translate_to_ASCII(
	input [7:0] IN,
	output reg [6:0] OUT
);
	
	always @(*)
	begin
		case(IN[7:0])
			8'b00101001: OUT = 7'd32; // space
			8'b01000101: OUT = 7'd48; // '0'
			8'b00010110: OUT = 7'd49; // '1'
			8'b00011110: OUT = 7'd50; // '2'
			8'b00100110: OUT = 7'd51; // '3'
			8'b00100101: OUT = 7'd52; // '4'
			8'b00101110: OUT = 7'd53; // '5'
			8'b00110110: OUT = 7'd54; // '6'
			8'b00111101: OUT = 7'd55; // '7'
			8'b00111110: OUT = 7'd56; // '8'
			8'b01000110: OUT = 7'd57; // '9'
			8'b00011100: OUT = 7'd65; // 'A'
			8'b00110010: OUT = 7'd66; // 'B'
			8'b00100001: OUT = 7'd67; // 'C'
			8'b00100011: OUT = 7'd68; // 'D'
			8'b00100100: OUT = 7'd69; // 'E'
			8'b00101011: OUT = 7'd70; // 'F'
			8'b00110100: OUT = 7'd71; // 'G'
			8'b00110011: OUT = 7'd72; // 'H'
			8'b01000011: OUT = 7'd73; // 'I'
			8'b00111011: OUT = 7'd74; // 'J'
			8'b01000010: OUT = 7'd75; // 'K'
			8'b01001011: OUT = 7'd76; // 'L'
			8'b00111010: OUT = 7'd77; // 'M'
			8'b00110001: OUT = 7'd78; // 'N'
			8'b01000100: OUT = 7'd79; // 'O'
			8'b01001101: OUT = 7'd80; // 'P'
			8'b00010101: OUT = 7'd81; // 'Q'
			8'b00101101: OUT = 7'd82; // 'R'
			8'b00011011: OUT = 7'd83; // 'S'
			8'b00101100: OUT = 7'd84; // 'T'
			8'b00111100: OUT = 7'd85; // 'U'
			8'b00101010: OUT = 7'd86; // 'V'
			8'b00011101: OUT = 7'd87; // 'W'
			8'b00100010: OUT = 7'd88; // 'X'
			8'b00110101: OUT = 7'd89; // 'Y'
			8'b00011010: OUT = 7'd90; // 'Z'
    		default: OUT = 7'd32;
		endcase
	end
	
endmodule
