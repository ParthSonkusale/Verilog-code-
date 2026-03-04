
module frequency_scaling (
    input clk_50M,
    output reg clk_3125KHz
);

initial begin
    clk_3125KHz = 0;
end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

reg [3:0] count = 0;
reg flag = 0;


always @(posedge clk_50M) begin
	if (flag == 0) begin
		clk_3125KHz <= 1;
		count <= 0;
		flag <= 1;
	end else begin
			 if (count == 7) begin 
				 clk_3125KHz <= ~clk_3125KHz; 
				 count <= 0;
					
			 end else begin
				  count <= count + 1;
		 end
	end
end
//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

endmodule
