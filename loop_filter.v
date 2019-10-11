module loop_filter
(
	// filter coefficients have 4 integer bits and 12 fractional	
	input signed	[15:0] xin,
	input signed	[15:0] a0, a1, b1, b2, yinit,
	input 		clock, arst,
	output signed	[15:0] yout
);

	reg signed	[15:0] x1_reg;
	reg signed	[31:0] y1_reg, y2_reg; // 16 fractional 16 integer
	wire signed 	[31:0] y0;
	wire signed 	[32:0] axsum;
	wire signed 	[48:0] bysum;
	wire signed 	[32:0] partial_bysum;
	wire signed 	[33:0] sumsum;

	assign axsum = a0*xin + a1*x1_reg;
	assign bysum = b1*y1_reg + b2*y2_reg;
	assign partial_bysum = bysum[48:16]; // reduce to 12 fractional bits
	assign sumsum = axsum + partial_bysum;
	assign y0[3:0] = 4'b0;		     // need to add 4 fractional bits
	assign y0[30:4] = sumsum[26:0];
	assign y0[31] = 1'b0;
	assign yout = y1_reg;
	
	always @ (posedge clock or posedge arst) begin
    	if (arst) begin
			x1_reg <= {16{1'b0}};
			y1_reg[31:16] <= yinit;
			y1_reg[15:0] <= {16{1'b0}};
			y2_reg[31:16] <= yinit;
			y2_reg[15:0] <= {16{1'b0}};
		end
		else begin
			x1_reg <= xin;
			y1_reg <= y0;
			y2_reg <= y1_reg;
		end
	end
endmodule



