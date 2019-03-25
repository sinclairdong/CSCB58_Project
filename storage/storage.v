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
*
*
* Tank Address is 8 bits binary; first 4 bits the column, last 4 bits the row.
*
* Tank Direction is 8 bits binary (Also use this assignment for input data to signal movement):
*     up: 00000000
*     down: 00000001
*     left: 00000010
*     right: 00000011
*
* Active high reset
*
* RAM: 8 bit ram
*
*|____7____|____6____|____5____|____4____|____3____|____2____|____1____|____0____|
*   wall      tank1     tank2     proj       di1       di2
*
*
*
* WHEN WRITING / READING FROM RAM:
* -output updated_pos will be the address to read from
* -output updateD_dir will be the value at the address
* 
*/
module storage(
    output reg [7:0] updated_pos,
    output reg [7:0] updated_dir,
    outptu reg [7:0] ram_out,
    input clk,
    input reset,
    input [3:0] mode,
    input load_out,
    input [7:0] address, // grid coordinates
    input [7:0] data,  // tank movement direction
    input has_wall, // 1 = true, 0 = false
    );


    //tanks address registers
    reg [7:0] tank_1, tank_2;

    //tank directions registers
    reg [7:0] tank_1_dir, tank_2_dir; 

    //projectile address register
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
    assign wren = mode == 4'b1111; // when writing to RAM
    //registers to set value in a given address in RAM
    wire has_tank_1;
    wire has_tank_2;
	 wire has_proj_1;
	 wire has_proj_2;
    wire has_proj;
	 wire [1:0]dir_t1;
	 wire [1:0]dir_t2;
    wire [1:0]dir;
    wire [7:0]ram_data;

    //Access RAM
    board_state (address[7:0], clk, ram_data[7:0], wren, ram_out[7:0]); 

    //Check if there is a tank in given address
    assign has_tank_1 = tank_1[7:0] == address[7:0];
    assign has_tank_2 = tank_2[7:0] == address[7:0];
	 //get the direction of the tank; if there is no tank
    assign dir_t1[1:0] = (has_tank_1 == 1'b1) ? tank_1_dir[1:0] : 0;
	 assign dir_t2[1:0] = (has_tank_2 == 1'b1) ? tank_2_dir[1:0] : 0;
	 assign dir[1:0] = dir_t1[1:0] + dir_t2[1:0];
	 //check if there is a projectile in given address
    assign has_proj_1 = (tank_1_proj[7:0] == address[7:0]) ? 1'b1 : 1'b0;
    assign has_proj_2 = (tank_2_proj[7:0] == address[7:0]) ? 1'b1 : 1'b0;
	 assign has_proj = has_proj_1 + has_proj_2;


    //concatenate all the data for ram.
    assign ram_data[7:0] = {has_wall, has_tank_1, has_tank_2, has_proj, dir[1:0], 2'b00};


    //ALU multiplexers
    always@(*)
    begin
        // update position of corresponding tank or projectile
        // along with pointers
        case(mode[3:0])
            4'b0001: begin
                //update tank1 position and direction
                target_address <= tank_1;
                target_direction <= tank_1_dir;

                target_address <= tank_1_proj;
                target_direction <= tank_1_proj_dir;
                end

            4'b0011: begin
                // fire tank1 projecile

                case(tank_1_dir[7:0])
                    // tank direction up
                    8'b00000000: begin
                        //access RAM in read mode
                        wren <= 4'b0000;

                        // collision with wall or tank2
                        if (ram_out[5:5] == 1'b1 || ram_out[7:7])

                        else

                            tank_1_dir -= 8'b00001000;
                            address <= tank_1_dir;
                            has_proj <= 1'b1;
                            wren <= 4'b1111;


                
                end
            4'b0101: begin
                //update tank2 position and direction
                target_address <= tank_2;
                target_direction <= tank_2_dir;

                target_address <= tank_2_proj;
                target_direction <= tank_2_proj_dir;
            end

            4'b0111: begin
                //fire tank2 projectile
                
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


    // ALU for tank movement
    always@(posedge clk) begin
        //signal to move up, and currently not in uppermost blocks
        if((data[7:0] == 8'b00000000) && (target_address[7:0] >= 8'b00010000)) begin
            alu_out[7:0] <= target_address[7:0] - 8'b00010000;
        //signal to move down, and currently not in lowermost blocks
        end else if((data[7:0] == 8'b00000001) && (target_address[7:0] <= 8'b11110000)) begin
            alu_out[7:0] <= target_address[7:0] + 8'b00010000;
        //signal to move left, and currently not in leftmost blocks
        end else if((data[7:0] == 8'b00000010) && ((target_address[7:0] % 8'b00010000) >= 8'b00000001)) begin
            alu_out[7:0] <= target_address[7:0] - 8'b00000001;
        //signal to move right, and currently not in rightmost blocks
        end else if((data[7:0] == 8'b00000011) && ((target_address[7:0] % 8'b00010000) <= 8'b00001110)) begin
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
				   if(mode[3:0] == 4'b0000) begin
					    updated_pos <= address[7:0];
						 updated_dir <= ram_out[7:0];
					end
					else if(mode[3:0] == 4'b1111)begin
					    updated_pos <= address[7:0];
						 updated_dir <= ram_out[7:0];
					end
					else begin
                   updated_pos <= alu_out[7:0];
                   updated_dir <= data[7:0];
					end
            end
            load_out <= b1'0;
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
        end else if((move_dir == 8'b00000010) && ((in_position[7:0] % 8'b00010000) >= 8'b00000001)) begin
            out_position[7:0] <= in_position[7:0] - 8'b00000001;
        //signal to move right, and currently not in rightmost blocks
        end else if((move_dir == 8'b00000011) && ((in_position[7:0] % 8'b00010000) <= 8'b00001110)) begin
            out_position[7:0] <= in_position[7:0] + 8'b00000001;
        end else begin
            out_position[7:0] <= in_position[7:0];
		  end
    end
    

endmodule
