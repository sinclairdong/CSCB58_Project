module counter_3_bits(q, clear_b, clock, Enable);


	output reg [2:0] q; // declare q
	input clear_b, clock, Enable;
	
	always @(posedge clock, negedge clear_b) // triggered every time clock rises
		begin
		if (clear_b == 1'b0) // when Clear_b is 0...
			q <= 0; // set q to 0
		else if (q == 3'b111) // ...otherwise if q is the maximum counter value
			q <= 3'b0; // reset q to 0
		else if (Enable == 1'b1) // ...otherwise update q (only when Enable is 1)
			q <= q + 1'b1; // increment q
			// q <= q - 1'b1; // alternatively, decrement q
	end
	
endmodule

module counter_8_bits(q, clear_b, clock, Enable);


	output reg [7:0] q; // declare q
	input clear_b, clock, Enable;
	
	always @(posedge clock, negedge clear_b) // triggered every time clock rises
		begin
		if (clear_b == 1'b0) // when Clear_b is 0...
			q <= 0; // set q to 0
		else if (q == 8'b11000000) // ...otherwise if q is the maximum counter value
			q <= 8'b0; // reset q to 0
		else if (Enable == 1'b1) // ...otherwise update q (only when Enable is 1)
			q <= q + 1'b1; // increment q
			// q <= q - 1'b1; // alternatively, decrement q
	end
	
endmodule

module counter_28_bits(q, clear_b, clock, Enable);


	output reg [27:0] q; // declare q
	input clear_b, clock, Enable;
	
	always @(posedge clock, negedge clear_b) // triggered every time clock rises
		begin
		if (clear_b == 1'b0) // when Clear_b is 0...
			q <= 0; // set q to 0
		else if (q == 28'b00001111111111111111111111) // ...otherwise if q is the maximum counter value
			q <= 28'b0; // reset q to 0
		else if (Enable == 1'b1) // ...otherwise update q (only when Enable is 1)
			q <= q + 1'b1; // increment q
			// q <= q - 1'b1; // alternatively, decrement q
	end
	
endmodule
