module top_level_module
    (
        CLOCK_50,                       
        KEY,
        VGA_CLK,                           
        VGA_HS,                            
        VGA_VS,
        VGA_BLANK_N,                  
        VGA_SYNC_N,
        VGA_R,
        VGA_G,
        VGA_B,                     //
    );
    input            CLOCK_50;                //    50 MHz
    input   [3:0]   KEY;               // for start and reset

    output            VGA_CLK;                   //    VGA Clock
    output            VGA_HS;                    //    VGA H_SYNC
    output            VGA_VS;                    //    VGA V_SYNC
    output            VGA_BLANK_N;                //    VGA BLANK
    output            VGA_SYNC_N;                //    VGA SYNC
    output    [9:0]    VGA_R;                   //    VGA Red[9:0]
    output    [9:0]    VGA_G;                     //    VGA Green[9:0]
    output    [9:0]    VGA_B;                   //    VGA Blue[9:0]

    
    wire instruction;
    
    //_______INSTANTIATE KEYBOARD INPUT_________
    input i0
    (
        .instruction(instruction),
        .clk(CLOCK_50),
        .kbclk, //?
        .kbdat, //?
        .reset(KEY[0])
    );
     
    wire reg [7:0]updated_pos;
    wire reg [7:0]updated_dir;
    wire [7:0] mode;
    wire [7:0] data;

    
    //_______INSTANTIATE STORAGE AKA DATAPATH___________
    storage S0
    (
        .updated_pos(updated_pos),
        .updated_dir(updated_dir),
        .clk(CLOCK_50),
        .reset(KEY[0]),
        .mode(mode),
        .wren,
       // .load_out,
       // .address,
        .data(data) // tank movement direction
    );
    
    
    
    //_________INSTANTIATE CONTROL_______________
    
    module control(
        .mode(mode), // input to storage
        .tank_move_dir(data), //input to storage
        .clk(CLOCK_50),
        .resetn(KEY[0]), // the input to reset the game
        .game_state, // 0 if not in game, 1 if in game. 
        .instruction(instruction), //keyboard input

    );

    

    reg [2:0] colour;
    reg [6:0] x;
    reg [6:0] y;
    reg  writeEn;   

    // INSTANTIATE VGA
    vga_adapter VGA(
            .resetn(resetn),
            .clock(CLOCK_50),
            .colour(colour),
            .x(x),
            .y(y),
            .plot(writeEn),
            /* Signals for the DAC to drive the monitor. */
            .VGA_R(VGA_R),
            .VGA_G(VGA_G),
            .VGA_B(VGA_B),
            .VGA_HS(VGA_HS),
            .VGA_VS(VGA_VS),
            .VGA_BLANK(VGA_BLANK_N),
            .VGA_SYNC(VGA_SYNC_N),
            .VGA_CLK(VGA_CLK));
            
    defparam VGA.RESOLUTION = "160x120";
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BACKGROUND_IMAGE = "black.mif";
    
    
