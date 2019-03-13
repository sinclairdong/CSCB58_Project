module input_tester(
    output [7:0] LEDR,
    input CLOCK_50,
    input PS2_KBCLK,
    input PS2_KBDAT,
    input [0:0] KEY
)

    reg [7:0] instruction;
    
    input(instruction, CLOCK_50, PS2_KBCLK, PS2_KBDAT, KEY[0]);
    
    assign LEDR = instruction;
endmodule
