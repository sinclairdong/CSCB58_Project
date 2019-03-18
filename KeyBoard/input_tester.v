module test(
    output [7:0] LEDR,
    input CLOCK_50,
    input PS2_KBCLK,
    input PS2_KBDAT,
    input [0:0] KEY
);

    wire [7:0] instruction;
    
    input_kb(instruction, CLOCK_50, PS2_KBCLK, PS2_KBDAT, KEY[0]);
    
    assign LEDR[7:0] = instruction[7:0];
endmodule
