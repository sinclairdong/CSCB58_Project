module display_all
	(
		clock,						//	On Board 50 MHz
		// Your inputs and outputs here
        // KEY,
		position,
		address,
		done,
		x,
		y,
		colour
	);
	input [7:0] position;
	input [7:0] address;
	input clock;
	output reg done;
	output reg [3:0] x, y;
	wire resetn;
	wire [5:0] q;
	// access the data from storage to read
	// Create the colour and writeEn wires that are inputs to the controller.
	output reg [2:0] colour;
	wire [3:0] row, col;
	wire writeEn;
	 
	// Tank Address is 8 bits binary; first 4 bits the column, last 4 bits the row.
//	 assign row = address[3:0];
//	 assign col = address[7:4];

/* Wrapper module for storage of data. Access ram/registers through the following modes:
* read ram: 0000 for display
* edit ram: 1111
*/
		//always @(address)
	//begin
		// x times 16 (2^4)
	assign start_x = (address[3:0] << 4);
		// y times 12 (2^4-2^2)
	assign start_y = (address[7:4] << 4) - (address[7:4] << 2);
		//assign clear_b = 1'b1;
	//end
	
	//assign col_out = col;
	
	wire [3:0] start_x, start_y;
	// wire gun_x, gun_y;
	// shift 4 to the left by timing 2^4,
//	assign start_x = (col << 4) + 3 - col;
//	assign start_y = (row << 4) + 4 - row;

	
	wire clear_b;
	wire Enable;
	/*
	always @(address)
	begin
		clear_b <= 1'b0;
		Enable <= 1'b1;
	end
	*/
	assign Enable = 1'b1;
	assign clear_b = 1'b1;

// position
//8 bit ram (according to ram contract)
//|_7_|___6__|__5__|_4__|_3_|__2_|____1____|____0____|
// wall tank1 tank2 proj di1 di2
	always @(posedge clock)
	begin
	// check the data given by the storage if it is tank or not
	// if it is tank1 or tank2
		if (position ==8'b01000000 || position == 8'b00100000)
		begin
        // assign the starting position of x, y
//  start_x <= ;
//  start_y <= ;
		 // when it finish drawing
			if (q == 6'd63)
				done <= 1'b1;
			else
			// draw the tank
			begin
            // assign a color for the tank
				colour <= 3'b101;
            // start drawing from (x+4,y+2) to (x+11, y+9)
				x <= start_x + q[2:0];
				y <= start_y + q[5:3];
				done <= 1'b0;
			end
		end
		// if it is left-right projectile 
		else if (position == 8'b00010000 && )
		begin
        // assisin the starting coordinate of x,y
//      assign start_x <= ;
//      assign start_y <= ;
            // draw a 2*16
			// when finish drawing projectile
		   if (q == 7'd31)
			done <= 1'b1;
			else
			begin
            // assign a color for the projectile
				colour <= 3'b110;
            // start drawing from (x,y+5) to (x+15, y+6)
                x <= start_x + q[3:0];
				y <= start_y + q[7:4];
				done <= 1'b0;	
			end
        // if it is up-down projectile 
		else if (position == 8'b00010000 && )
		begin
        // assisin the starting coordinate of x,y
//      assign start_x <= ;
//      assign start_y <= ;
			// draw a 12*2 
            // when finish drawing projectile
		   if (q == 6'd23)
			done <= 1'b1;
			else
			begin
            // assign a color for the projectile
				colour <= 3'b110;
                // start drawing from 
                x <= start_x + q[2:0];
				y <= start_y + q[5:3];
				done <= 1'b0;	
			end
        // if it is a wall
        else if (position == 8'1000000000)
        begin
            // when finish drawing wall
            if (k == 8'd255)
                done <= 1'b1;
            else
            begin
            // assign a color for the wall
                colour <= 3'b011;
                x <= start_x + k[3:0];
				y <= start_y + k[7:4];
                done <= 1'b0;
            end
		end
//* Tank Direction is 8 bits binary (according to storage.v):
//*     up: 00000000
//*   down: 00000001
//*   left: 00000011
//*  right: 00000111		

	end
	

	counter c(.q(q), .clear_b(clear_b), .clock(clock), .Enable(Enable));
    counter_8_bits k(.k(k), .clear_b(clear_b), .clock(clock), .Enable(Enable));
		
    
endmodule

module counter(q, clear_b, clock, Enable);


	output reg [5:0] q; // declare q
	input clear_b, clock, Enable;
	
	always @(posedge clock, negedge clear_b) // triggered every time clock rises
		begin
		if (clear_b == 1'b0) // when Clear_b is 0...
			q <= 0; // set q to 0
		else if (q == 6'b111111) // ...otherwise if q is the maximum counter value
			q <= 6'b0; // reset q to 0
		else if (Enable == 1'b1) // ...otherwise update q (only when Enable is 1)
			q <= q + 1'b1; // increment q
			// q <= q - 1'b1; // alternatively, decrement q
	end
	
endmodule

module counter_8_bits(k, clear_b, clock, Enable);


	output reg [7:0] k; // declare k
	input clear_b, clock, Enable;
	
	always @(posedge clock, negedge clear_b) // triggered every time clock rises
		begin
		if (clear_b == 1'b0) // when Clear_b is 0...
			k <= 0; // set k to 0
		else if (q == 8'b11000000) // ...otherwise if k is the maximum counter value
			k <= 8'b0; // reset k to 0
		else if (Enable == 1'b1) // ...otherwise update k (only when Enable is 1)
			k <= k + 1'b1; // increment k
			// k <= k - 1'b1; // alternatively, decrement k
	end
	
endmodule
