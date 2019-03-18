module test_storage(LEDR, SW, KEY);
    input [17:0] SW;
    input [3:0] KEY;
    output [17:0] LEDR;

    //not enough keys; create a mux to test current 4 cases.

    wire [3:0]mode1 = 4'b0001;
    wire [3:0]mode2 = 4'b0011;
    wire [3:0]mode3 = 4'b0101;
    wire [3:0]mode4 = 4'b0111;
    reg [3:0]mode;

    always@(*)
    begin
        case(SW[17:16])
            2'b00: mode <= mode1;
            2'b01: mode <= mode2;
            2'b10: mode <= mode3;
            2'b11: mode <= mode4;
        endcase
    end    
    

    storage(
        .updated_pos(LEDR[7:0]),
        .updated_dir(LEDR[15:8]),
        .clk(KEY[0]),
        .reset(KEY[1]),
        .mode(mode[3:0]), //choose tank/projectile
        .wren(KEY[2]),
        .load_out(KEY[3]),
        .address(SW[7:0]), //
        .data(SW[15:8]) //tank mvmt direction
    );

endmodule 