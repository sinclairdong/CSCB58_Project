// code from https://github.com/armitag8/ASIC_Notepad--

module kb_tester
    (
        output [6:0] HEX0,
        output [6:0] HEX1,
        output [17:0] LEDR,
        output [0:0] LEDG,
        input CLOCK_50,
        input PS2_CLK,
        input PS2_KBDAT,
        input [0:0] KEY
    );
    
    wire [7:0] kb_scan_code;
    wire kb_scan_ready, kb_upper_case_flag;
    
    // Instantiate keyboard input interface
    keyboard k0
        (
            .clk(CLOCK_50),
            .reset(KEY[0]),
            .ps2d(PS2_KBDAT),
            .ps2c(PS2_CLK),
            .scan_code(kb_scan_code),
            .scan_code_ready(kb_scan_ready),
            .letter_case_out(kb_upper_case_flag)            
        );
    
    assign LEDR[17] = kb_upper_case_flag;
    assign LEDG[16] = kb_scan_ready;
    assign LEDR[7:0] = kb_scan_code;
    
    // TODO record the key we are going to use
    
endmodule
