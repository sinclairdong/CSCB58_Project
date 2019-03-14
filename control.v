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


module control(
    output mode, // input to storage
    output tank_move_dir, //input to storage

    input clk,
    input resetn, // the input to reset the game
    input game_state, // 0 if not in game, 1 if in game. 
    input instruction, //keyboard input
    input game_over;

    output reg load_game,
    );

    //________________________GAME STATE________________________
    reg [2:0] current_state, next_state;        

    localparam S_PRE_GAME  = 2'b00,
               S_GAME      = 2'b01,
               S_POST_GAME = 2'b11;

    always@(*)
    begin
        case(current_state)
        
            S_PRE_GAME: next_state = game_state ? S_GAME : S_PRE_GAME; // Stay in pre-game state until game starts
            S_GAME: next_state = game_state ? S_GAME : S_POST_GAME; // Stay in game state until game ends
            S_POST_GAME: next_state = S_PRE_GAME; // go back to pre-game state and wait for new game to start
    end

    // reset to pre game state if either game over or reset pressed
    // otherwise move to next state
    always@(*)
    begin
        if (game_over || resetn)
            currrent_state <= S_PRE_GAME;
        else
            current_state <= next_state;
    end


    // update mode and move direction (for storage) based on keyboard input instruction
    always @(posedge clk)
    begin
        case (instruction)
            // ____________tank 2 movement______________
            8'b00000010: 
                begin
                mode = 4'b0101; // up    p2  arrow
                tank_move_dir = 8'b00000000;
                end

		8'b00000111: 
                begin
                mode = 4'b0101; 
                tank_move_dir = 8'b00000001;
                end   // down  p2  arrow

            8'b00000100: 
                begin
                mode = 4'b0101; 
                tank_move_dir = 8'b00000011;
                end    // left  p2  arrow

	    8'b00000001:
                begin
                mode = 4'b0101; 
                tank_move_dir = 8'b00000111;
                end   // right p2  arrow

			
            /*  _______tank 2 projecile_____________
			8'b00001000: 
                begin
                mode = 4'b0001; 
                tank_move_dir = 8'b00000000;
                end     // fire  p2  key pad
                */


            /*____________Tank 1 movement________________*/

	8'b00100000: 
                begin
                mode = 4'b0001; 
                tank_move_dir = 8'b00000000;
                end // up    p1  w
		
	8'b01110000:
                begin
                mode = 4'b0001; 
                tank_move_dir = 8'b00000001;
                end   // down  p1  s
		
	8'b01000000: 
                begin
                mode = 4'b0001; 
                tank_move_dir = 8'b00000011;
                end   // left  p1  a
		
	8'b00010000: 
                begin
                mode = 4'b0001; 
                tank_move_dir = 8'b00000111;
                end  // right p1  d
            
            //_____________Tank 1 projectile______________
            /*
			8'b10000000: 
                begin
                mode = 4'b; 
                tank_move_dir = 8'b00000011;
                end    // left  p2  arrow; // fire  p1  space
                */

	8'b11111111: resetn = 1'b1// reset r
	//8'b11111110:   // pause

endmodule



