module ultrasonic_RIGHT(
   input clock,
	input rst,
	output trig,
	input echo,
	output reg [15:0] distance,
	output reg op_r
);

reg [32:0] us_counter = 0;
reg _trig = 1'b0;

reg [9:0] one_us_cnt = 0;
wire one_us = (one_us_cnt == 0);

reg [9:0] ten_us_cnt = 0;
wire ten_us = (ten_us_cnt == 0);

reg [21:0] forty_ms_cnt = 0;
wire forty_ms = (forty_ms_cnt == 0);

assign trig = _trig;

localparam [5:0] ONE_US = 6'd50; 
localparam [9:0] TEN_US = 10'd500;
localparam [20:0] FORTY_US = 21'd2000000;
localparam [5:0] DIVISOR  = 6'd58;
reg [4:0] OP_THRESHOLD = 5'd25;
localparam [15:0] OP_DEADEND_THRESHOLD = 16'd600;


always @(posedge clock or negedge rst) begin
	if (!rst)begin
		us_counter <=0;
		_trig <=0;
		one_us_cnt <=0;
		ten_us_cnt <=0;
		forty_ms_cnt <=0;
	end 
	else begin
		one_us_cnt <= (one_us ? ONE_US : one_us_cnt) - 1;
		ten_us_cnt <= (ten_us ? TEN_US : ten_us_cnt) - 1;
		forty_ms_cnt <= (forty_ms ? FORTY_US : forty_ms_cnt) - 1;
		
		if (ten_us && _trig)
			_trig <= 1'b0;
		
		if (one_us) begin	
			if (echo)
				us_counter <= us_counter + 1;
			else if (us_counter) begin
				distance <= us_counter / DIVISOR;
				us_counter <= 0;
			end
		end
		
		if (forty_ms)
			_trig <= 1'b1;
	end
end
always@(posedge clock)begin
	if((distance) < OP_THRESHOLD)
		op_r <= 1;
	else begin 
		op_r <= 0;
	end
end
//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

endmodule