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
        VGA_B,                    
    );
    input            CLOCK_50;               
    input   [3:0]   KEY;            // key0 is reset

    output            VGA_CLK;                   //    VGA Clock
    output            VGA_HS;                    //    VGA H_SYNC
    output            VGA_VS;                    //    VGA V_SYNC
    output            VGA_BLANK_N;                //    VGA BLANK
    output            VGA_SYNC_N;                //    VGA SYNC
    output    [9:0]    VGA_R;                   //    VGA Red[9:0]
    output    [9:0]    VGA_G;                     //    VGA Green[9:0]
    output    [9:0]    VGA_B;                   //    VGA Blue[9:0]


    wire reg [7:0] instruction; //keyboard -> control

    wire reg [7:0]updated_pos;
    wire reg [7:0]updated_dir;
    wire [7:0] mode; // control -> storage
    wire [7:0] data; // control -> storage 
    wire ld;
    
    wire [7:0] address; // storage -> display
    wire reg [0:0]has_wall;
    
    // display -> VGA
    reg [2:0] colour;
    reg [7:0] x;
    reg [7:0] y;
    reg  writeEn;   

    
    //_______INSTANTIATE KEYBOARD INPUT_________
    input i0
    (
        .instruction(instruction),
        .clk(CLOCK_50),
        .kbclk, //?
        .kbdat, //?
        .reset(KEY[0])
    );
     
    
    //_______INSTANTIATE STORAGE AKA DATAPATH___________
    storage s0
    (
        .updated_pos(updated_pos),
        .updated_dir(updated_dir),
        .clk(CLOCK_50),
        .reset(KEY[0]),
        .mode(mode),
        .load_out(ld),
        .address(address),
        .data(data) // tank movement direction
        .has_wall(has_wall)
    );
    

    // TEST - plot column of wall at y = 2

    assign address = b8'00100000;
    initial 
        begin 
        while( address < 00101111 ) 
            begin 
                has_wall = b1'1;
                address <= address + b8'00000001;
                //allow storage to make changes
                ld <= b1'1;
            end 
        end 
            
    
    //_________INSTANTIATE CONTROL_______________
    
    control c0(
        .mode(mode), // input to storage
        .tank_move_dir(data), //input to storage
        .load_out(ld), //input to storage
        .clk(CLOCK_50),
        .resetn(KEY[0]), // the input to reset the game
        .instruction(instruction) //keyboard input

    );
    
    
    //_______INSTANTIATE DISPLAY___________
    display_all d0
	(
        clock(CLOCK_50),				
        position(address),
        address(updated_pos),
        done(writeEn),
        x(x),
        y(y),
        colour(colour)
    );
    

    
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
    
    
