module game_run (
    input clk,
    input reset,

    )



// player tank positions
reg [8:0] player_1;   
reg [8:0] player_2;

// projectile
reg [8:0] projectile_1;
reg[8:0] projectile_2;

//initialize player positions
initial begin

    player_1 <= 8'b0;   // top left corner
    player_2 <= 8'b11111111; //bottom right corner


// reset game
always @(posedge clk) begin
   if(reset)
    player_1 <= 8'b0;   // top left corner
    player_2 <= 8'b11111111; //bottom right corner
end

   