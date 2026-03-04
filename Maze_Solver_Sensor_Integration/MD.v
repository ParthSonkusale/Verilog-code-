module md(
    input  wire        clk,
	 input wire rst,
	 input [3:0] move,
    output reg  in_1,
    output reg  in_2,
    output reg  in_3,
    output reg  in_4 
);

    always @(*) begin
		if (!rst)begin
			in_1 = 0; in_2 = 0;
         in_3 = 0; in_4 = 0;
		end
		else begin
			  case (move)
					4'b0001, 4'b0101: begin // FORWARD
						 in_1 = 1; in_2 = 0;
						 in_3 = 1; in_4 = 0;
					end

					4'b0010: begin // LEFT
						 in_1 = 0; in_2 = 0;
						 in_3 = 1; in_4 = 0;
					end
					
					4'b1000: begin // r-LEFT
						 in_1 = 0; in_2 = 1;
						 in_3 = 0; in_4 = 0;
					end
					
					4'b0110,4'b1001: begin // r-RIGHT
						 in_1 = 0; in_2 = 0;
						 in_3 = 0; in_4 = 1;
					end

					4'b0011: begin // RIGHT
						 in_1 = 1; in_2 = 0;
						 in_3 = 0; in_4 = 0;
					end

					4'b0100: begin // U-TURN
						 in_1 = 0; in_2 = 1;
						 in_3 = 1; in_4 = 0;
					end
					
					4'b0101: begin
						 in_1 = 0; in_2 = 1;
						 in_3 = 0; in_4 = 0;
					end
					
					4'b0110: begin
						 in_1 = 0; in_2 = 0;
						 in_3 = 0; in_4 = 1;
					end
					
					4'b0111:begin
						 in_1 = 0; in_2 = 1;
						 in_3 = 0; in_4 = 1;
					end	 

					default: begin // STOP
						 in_1 = 0; in_2 = 0;
						 in_3 = 0; in_4 = 0;
					end
			  endcase
		  end
    end

endmodule