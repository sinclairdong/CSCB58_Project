/* Wrapper module for storage of data. Access ram/registers through the following modes:
* ram: 0000
* tank1 address: 0001
* tank1 direction: 0010
* tank1 projectile address: 0011
* tank2 address: 0100
* tank2 direction: 0101
* tank2 projectile address: 0110
*
* Tank Address is 8 bits binary; first 4 bits the column, last 4 bits the row.
*
* Tank Direction is 8 bits binary (Also use this assignment for input data to signal movement):
*     up: 00000000
*     down: 00000001
*     left: 00000011
*     right: 00000111
*
* Active high reset
*
*  
*/
module storage(
    output reg [7:0] q,
    input clk,
    input reset,
    input [3:0] mode,
    input wren,
    input load_out,
    input [7:0] address,
    input [7:0] data
    );

    

    //tanks address registers
    reg [7:0] tank_1, tank_2;
    //tank directions registers
    reg [7:0] tank_1_dir, tank_2_dir;
    //projectile address registers
    reg [7:0] tank_1_proj, tank_2_proj;

    //alu input mux
    reg [7:0] target_register;
    //alu output
    reg [7:0] reg_out;

    //ALU multiplexer
    always@(*)
    begin
        case(mode[3:0])
            4'b0001: target_register = tank_1;
            4'b0010: target_register = tank_1_dir;
            4'b0011: target_register = tank_1_proj;
            4'b0100: target_register = tank_2;
            4'b0101: target_register = tank_2_dir;
            4'b0110: target_register = tank_2_proj;
        endcase
    end


    always@(posedge clk) begin
        if(reset) begin
            tank_1 <= 8'b001001; //initial position of tank_1 top left corner
            tank_2 <= 8'b110110; //initial position of tank_2 bottom right corner
            tank_1_dir <= 8'b00000001; // initial direction of tank_1 points down
            tank_2_dir <= 8'b00000000; // initial direction of tank_2 points up
            tank_1_proj <= 8'b001001; //projectile stays in tank until fired.
            tank_2_proj <= 8'b110110;
        end
        else if(mode[3:0] == 4'b0000) begin //if trying to write to ram
            if(wren)begin
                board_state(address[7:0], clk, data[7:0], wren, reg_out[7:0]);
            end
        end
        else begin //if trying to write to some specific register that is not ram
            if(wren) begin
                move_tank(reg_out[7:0], clk, address[7:0], 
            end
        end
    end

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
    output reg [7:0] out_position,
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


module move_tank(
    output reg [7:0] out_position,
    input clk,
    input [7:0] in_position,
    input move_up,
    input move_down,
    input move_left,
    input move_right,
    );

    reg [6:0] to_move;

    always@(posedge clk)
    begin
    
        //signal to move up, and currently not in uppermost blocks
        if(move_up && in_position[6:0] >= 6'b001000) begin
            to_move[6:0] <= in_position[6:0] - 6'b001000;
        //signal to move down, and currently not in lowermost blocks
        end else if(move_down && in_position[6:0] <= 6'b111000) begin
            to_move[6:0] <= in_position[6:0] + 6'b001000;
        //signal to move left, and currently not in leftmost blocks
        end else if(move_left && (in_position[6:0] % 6'b001000) >= 6'b000001) begin
            to_move[6:0] <= in_position[6:0] - 6'b000001;
        //signal to move right, and currently not in rightmost blocks
        end else if(move_right && (in_position[6:0] % 6'b001000) <= 6'b000110) begin
            to_move[6:0] <= in_position[6:0] + 6'b000001;
        end else begin
            to_move[6:0] <= in_position[6:0];
    end

    assign out_position[6:0] = to_move[6:0];

endmodule