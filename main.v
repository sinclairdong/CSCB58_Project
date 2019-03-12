module main
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
   
    wire reset;

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
    
    
    //INSTANTIATE CONTROL
    
    
    //INSTANTITATE DATAPATH
