/* Wrapper module for storage of data. Access ram/registers through the following modes:
* read ram: 0000
* edit ram: 1111
* tank1 address: 0001
* tank1 direction: 0010
* tank1 projectile address: 0011
* tank1 projectile direction: 0100
* tank2 address: 0101
* tank2 direction: 0110
* tank2 projectile address: 0111
* tank2 projectile direction: 1000
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
* RAM: 8 bit ram
*
*|____7____|____6____|____5____|____4____|____3____|____2____|____1____|____0____|
*   wall      tank1     tank2     proj       di1       di2
*
*/
module storage(
    output reg [7:0] updated_pos,
    output reg [7:0] updated_dir,
    input clk,
    input reset,
    input [3:0] mode,
    input load_out,
    input [7:0] address,
    input [7:0] data  // tank movement direction
    );


    //tanks address registers
    reg [7:0] tank_1, tank_2;

    //tank directions registers
    reg [7:0] tank_1_dir, tank_2_dir; 

    //projectile address registers
    reg [7:0] tank_1_proj, tank_2_proj;

    //projectile direction registers
    reg [7:0] tank_1_proj_dir, tank_2_proj_dir;

    //alu input muxes
    reg [7:0] target_address, target_direction;  //for tank. Address refers to position

    //alu output
    reg [7:0] alu_out;

    //wires for RAM operations
    wire wren;
    wire [7:0] ram_out;

    //ALU multiplexers
    always@(*)
    begin
        // update position of corresponding tank or projectile
        // along with pointers
        case(mode[3:0])
            4'b0001: begin
                //update pointers    
                target_address <= tank_1;
                target_direction <= tank_1_dir;
					 end
            4'b0011: begin
                //tank_1_proj <= q;
                target_address <= tank_1_proj;
                target_direction <= tank_1_proj_dir;
					 end
            4'b0101: begin
                target_address <= tank_2;
                target_direction <= tank_2_dir;
					 end
            4'b0111: begin
                //tank_2_proj <= q;
                target_address <= tank_2_proj;
                target_direction <= tank_2_proj_dir;
					 end
			endcase
    end

    // Registers for tanks, and projectiles, depending on mode.
    always@(posedge clk) begin
        if(~reset) begin		
            tank_1 <= 8'b00000000; //initial position of tank_1 top left corner
            tank_2 <= 8'b11111111; //initial position of tank_2 bottom right corner
            tank_1_dir <= 8'b00000001; // initial direction of tank_1 points down
            tank_2_dir <= 8'b00000000; // initial direction of tank_2 points up
            tank_1_proj <= 8'b00000000; //projectile stays in tank until fired.
            tank_1_proj_dir <= 8'b00000001; //initial projectile direction same as tank
            tank_2_proj <= 8'b11111111;
            tank_2_proj_dir <= 8'b00000000;
        end
		  
        else begin
            case(mode[3:0])
                4'b0001: begin //tank 1
                    //update position and direction
                    tank_1[7:0] <= updated_pos[7:0];
                    tank_1_dir[7:0] <= updated_dir[7:0];
                    end
                4'b0011: begin //tank 1 proj
                    tank_1_proj[7:0] <= updated_pos[7:0];
                    tank_1_proj_dir[7:0] <= updated_dir[7:0];
                    end
                4'b0101: begin //tank 2
                    tank_2[7:0] <= updated_pos[7:0];
                    tank_2_dir[7:0] <= updated_dir[7:0];
                    end
                4'b0111: begin //tank 2 proj
                    tank_2_proj[7:0] <= updated_pos[7:0];
                    tank_2_proj_dir[7:0] <= updated_dir[7:0];
                    end
            endcase
        end
    end
    assign wren = mode == 4'b0000;
    board_state (address[7:0], clk, data[7:0], wren, ram_out[7:0]); 
    // ALU
    always@(posedge clk) begin
        //signal to move up, and currently not in uppermost blocks
        if((data[7:0] == 8'b00000000) && (target_address[7:0] >= 8'b00010000)) begin
            alu_out[7:0] <= target_address[7:0] - 8'b00010000;
        //signal to move down, and currently not in lowermost blocks
        end else if((data[7:0] == 8'b00000001) && (target_address[7:0] <= 8'b11110000)) begin
            alu_out[7:0] <= target_address[7:0] + 8'b00010000;
        //signal to move left, and currently not in leftmost blocks
        end else if((data[7:0] == 8'b00000011) && ((target_address[7:0] % 8'b00010000) >= 8'b00000001)) begin
            alu_out[7:0] <= target_address[7:0] - 8'b00000001;
        //signal to move right, and currently not in rightmost blocks
        end else if((data[7:0] == 8'b00000111) && ((target_address[7:0] % 8'b00010000) <= 8'b00001110)) begin
            alu_out[7:0] <= target_address[7:0] + 8'b00000001;
        end else begin
            alu_out[7:0] <= target_address[7:0];
        end
    end
	 
    //Output result register		
    always@(posedge clk)
    begin
        if(~reset) begin
            updated_pos <= 8'b0;
            updated_dir <= 8'b0;
        end
        else begin
            if(load_out)begin
               updated_pos <= alu_out[7:0];
               updated_dir <= data[7:0];
            end
        end
    end
endmodule


module move_tank(
    output reg [7:0] out_position,
    output reg [7:0] out_dir,
    input clk,
    input [7:0] in_position,		
    input [7:0] move_dir
    );



    always@(posedge clk)
    begin
    
        //signal to move up, and currently not in uppermost blocks
        if((move_dir == 8'b00000000) && (in_position[7:0] >= 8'b00010000)) begin
            out_position[7:0] <= in_position[7:0] - 8'b00010000;
        //signal to move down, and currently not in lowermost blocks
        end else if((move_dir == 8'b00000001) && (in_position[7:0] <= 8'b11110000)) begin
            out_position[7:0] <= in_position[7:0] + 8'b00010000;
        //signal to move left, and currently not in leftmost blocks
        end else if((move_dir == 8'b00000011) && ((in_position[7:0] % 8'b00010000) >= 8'b00000001)) begin
            out_position[7:0] <= in_position[7:0] - 8'b00000001;
        //signal to move right, and currently not in rightmost blocks
        end else if((move_dir == 8'b00000111) && ((in_position[7:0] % 8'b00010000) <= 8'b00001110)) begin
            out_position[7:0] <= in_position[7:0] + 8'b00000001;
        end else begin
            out_position[7:0] <= in_position[7:0];
		  end
    end
    

endmodule
