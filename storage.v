/* Wrapper module for storage of data. Access ram/registers through the following modes:
* ram: 0000
* tank1 address: 0001
* tank1 direction: 0010
* tank1 projectile address: 0011
* tank1 projectile direction: 0100
* tank2 address: 0101
* tank2 direction: 0110
* tank2 projectile address: 0111
* tank2 projectile direction: 1000
*
*
*
*
*/
module storage(
    output [7:0] q,
    input clk,
    input reset,
    input [3:0] mode,
    input wren,
    input [7:0] address,
    input reg [7:0] data
    );

    //tanks address registers
    reg [7:0] tank_1, tank_2;
    //tank directions registers
    reg [7:0] tank_1_dir, tank_2_dir;
    //projectile address registers
    reg [7:0] tank_1_proj_address, tank_2_proj_address;
    //projectile direction registers
    reg [7:0] tank_1_proj_dir, tank_2_proj_dir;

    

    tank tank_1(
        .out_position(q[7:0]),
        .clk(clk),
        .load_tank(wren),
        .in_position(address[7:0])
        );

    tank tank_2(
        .out_position(q[7:0]),
        .clk(clk),
        .load_tank(wren),
        .in_position(address[7:0])
        );

    always@(posedge clk)
    begin
        if(wren) begin

        end
    end
endmodule



//register for tank
module tank(
    output reg [6:0] out_position,
    input clk,
    input load_tank,
    input [7:0] in_position
    );

    always@(posedge clk)
    begin
        if(load_tank) begin
            out_position[7:0] <= in_position[7:0];
        end
    end
endmodule    