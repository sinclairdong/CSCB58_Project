/* RAM is used to store location of the walls; input is the address memory, and the data.
* Use the address to represent the location of the map to check. The data will store 1 or 0, which
* signifies the presence of a wall.
* With this in mind, assign each block (within the 8x8 map) an "address".
*
* There are 64 = 2^6 blocks; 6 bit binary to represent each block.
*
* Each address below will store 0 or 1 as data.
*   ------ ------ ------ ------ ------ ------ ------ ------
*  |000000|000001|000010|000011|000100|000101|000110|000111|
*   ------ ------ ------ ------ ------ ------ ------ ------
*  |001000|001001|001010|001011|001100|001101|001110|001111|
*   ------ ------ ------ ------ ------ ------ ------ ------
*  |010000|010001|010010|010011|010100|010101|010110|010111|
*   ------ ------ ------ ------ ------ ------ ------ ------
*  |011000|011001|011010|011011|011100|011101|011110|011111|
*   ------ ------ ------ ------ ------ ------ ------ ------
*  |100000|100001|100010|100011|100100|100101|100110|100111|
*   ------ ------ ------ ------ ------ ------ ------ ------ 
*  |101000|101001|101010|101011|101100|101101|101110|101111|
*   ------ ------ ------ ------ ------ ------ ------ ------ 
*  |110000|110001|110010|110011|110100|110101|110110|110111|
*   ------ ------ ------ ------ ------ ------ ------ ------ 
*  |111000|111001|111010|111011|111100|111101|111110|111111|
*   ------ ------ ------ ------ ------ ------ ------ ------ 
*
* Every movement from a tank will retrieve data from this table depending on which co-ordinate
* the tank is in; e.g. if tank is current at address 001001 (9) and a command to moves down is detected,
* it would check (9+8=17) for a wall.
*
*/


module tank(
    input 


module move_tank(
    output out_position,
    input clk,
    input in_position,
    input move_up,
    input move_down,
    input move_left,
    input move_right,
    );
    
    input [6:0] in_position; // current position of tank
    input move_up, move_down, move_left, move_right; // input keys for movement
    output [6:0] out_position; // new position of tank

    reg [6:0] to_move;

    always@(posedge clk)
    begin
        //signal to move up, and currently not in uppermost blocks
        if(move_up && in_position[6:0] >= 6'b001000) begin
            to_move[6:0] = in_position[6:0] - 6'b001000;
        //signal to move down, and currently not in lowermost blocks
        end else if(move_down && in_position[6:0] <= 6'b111000) begin
            to_move[6:0] = in_position[6:0] + 6'b001000;
        //signal to move left, and currently not in leftmost blocks
        end else if(move_left && (in_position[6:0] % 6'b001000) >= 6'b000001) begin
            to_move[6:0] = in_position[6:0] - 6'b000001;
        //signal to move right, and currently not in rightmost blocks
        end else if(move_right && (in_position[6:0] % 6'b001000) <= 6'b000110) begin
            to_move[6:0] = in_position[6:0] + 6'b000001;
        end
    end

    assign out_position[6:0] = to_move[6:0]

endmodule




