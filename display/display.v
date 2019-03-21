module display
	(
		clock,						//	On Board 50 MHz
		// Your inputs and outputs here
        // KEY,
		mode,
		position,
		address,
		done,
		x,
		y,
		colour
	);
	input [3:0] mode;
	input [7:0] position;
	input [7:0] address;
	input clock;
	output reg done;
	output reg [3:0] x, y;
	wire resetn;
	wire [7:0] q;
	
	// Create the colour and writeEn wires that are inputs to the controller.
	output reg [2:0] colour;
	wire [3:0] row, col;
	wire writeEn;
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
	 
	 // Tank Address is 8 bits binary; first 4 bits the column, last 4 bits the row.
	 assign row = address[3:0];
	 assign col = address[7:4];
	 /*
	 always @(posedge clock)
	begin
		begin
		// assign tank1 a color
			if (mode == 0001)
				colour <= 3'b001;
		// assign tank2 a color
			else if (mode == 0101)
				colour <= 3'b010;
		// assign projectile1 a color
			else if (mode == 0011)
				colour <= 3'b100;
		// assign projectile2 a color
			else if (mode == 0111)
				colour <= 3'b110;
		end
	end
	*/
	
	wire [3:0] start_x, start_y, gun_x, gun_y;
	
	assign start_x = (col << 4) + 3 - col;
	assign start_y = (row << 4) + 4 - row;
	assign gun_x = (col << 4) + 11 - col;
	assign gun_y = (row << 4) + 7 - row;
	
	reg clear_b;
	reg Enable;
	
	always @(address)
	begin
		clear_b <= 1'b0;
		Enable <= 1'b1;
	end
// mode(according to storage.v):
//* tank1 address: 0001
//* tank1 : 0010
//* tank1 projectile address: 0011
//* tank1 projectile direction: 0100
//* tank2 address: 0101
//* tank2 direction: 0110
//* tank2 projectile address: 0111
//* tank2 projectile direction: 1000
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
		 // when it finish drawing
			if (q == 6'd67)
				done <= 1'b1;
			// draw the gun
			else if (q == 7'd65)
			begin
				colour <= 3'b111;
				x <= gun_x;
				y <= gun_y;
				done <= 1'b0;
			end
			else if (q == 7'd66)
			begin
				colour <= 3'b111;
				x <= gun_x + 1;
				y <= gun_y;
				done <= 1'b0;
				end
			else
			// draw the tank
			begin
				colour <= 3'b101;
				x <= start_x + q[3:0];
				y <= start_y + q[7:4];
				done <= 1'b0;
			end
		end
		// if it is projectile
		else if (position == 8'b00010000)
		begin
			// when finish frawing projectile
		   if (q == 7'd8)
			done <= 1'b1;
			else
			begin
				colour <= 3'b110;
				x <= start_x + q;
				y <= start_y + 3;
				done <= 1'b0;	
			end
		end
//* Tank Direction is 8 bits binary (according to storage.v):
//*     up: 00000000
//*   down: 00000001
//*   left: 00000011
//*  right: 00000111		
//		// check if projectile can penetrate the next block			
//			begin
//			// if the projectile is going up
//				if (direction == 8'00000000)
//				begin
//					
//				// if the projectile is going down
//				else if (direction == 8'00000001)
//				begin
//				// if the projectile is going left
//				else if (direction == 8'00000011)
//				begin
//				// if the projectile is going right
//				else if (direction == 8'00000111)
//				begin
//			// if projectile encounter the wall or another tank, then stop
//				if (position ==8'b01000000 || position == 8'b00100000 || position == 8'10000000)
//				done <= 1'b1;
//			// if neither, draw the projectile
//				else
				
			
		
	end
	

	counter c(.q(q), .clear_b(clear_b), .clock(clock), .Enable(Enable));

		
    
endmodule

module counter(q, clear_b, clock, Enable);


	output reg [7:0] q; // declare q
	input clear_b, clock, Enable;
	
	always @(posedge clock, negedge clear_b) // triggered every time clock rises
		begin
		if (clear_b == 1'b0) // when Clear_b is 0...
			q <= 0; // set q to 0
		else if (q == 8'b11111111) // ...otherwise if q is the maximum counter value
			q <= 6'b0; // reset q to 0
		else if (Enable == 1'b1) // ...otherwise update q (only when Enable is 1)
			q <= q + 1'b1; // increment q
			// q <= q - 1'b1; // alternatively, decrement q
	end
	
endmodule
