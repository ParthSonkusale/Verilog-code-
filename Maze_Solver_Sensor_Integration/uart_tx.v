module uart_tx(
    input clk_50,
	 input rst,
    input parity_type,tx_start,
    input [7:0] data_received,
    output reg tx, tx_done
);

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////
localparam START  = 3'd0;
localparam DATA   = 3'd1;
localparam PARITY = 3'd2;
localparam STOP   = 3'd3;
localparam IDLE   = 3'd4;
localparam clk_bps = 416;

//reg       tx_start_d;
reg [8:0] clk_counter = 5'd0;
reg [2:0] state;
reg [2:0] bit_index;
reg [7:0] data = 8'b00000000;

//initial begin
//    tx = 1;
//    tx_done = 0;
//    state = IDLE;
//    bit_index = 0;
//end

always @(posedge clk_50 or negedge rst) begin
//  tx_start_d <= tx_start;
	if (!rst) begin
		clk_counter <=0;
		state <=IDLE;
		bit_index <=0;
		data <=0;
		tx <= 1;
      tx_done <= 0;
	end
	else begin
		 case (state)
		 
			 IDLE: begin
				  tx_done <= 0;
				  clk_counter <= 0;
				  bit_index <= 0;
				  tx <= 1;                    // Keep line idle high
				  if (tx_start) begin         // Only start transmission if tx_start is high
						data <= data_received;  // Load the input data
						tx <= 0;                // Start bit
						state <= START;
				  end else begin
						state <= IDLE;
				  end
			 end

			 START : begin
				  if(clk_counter < clk_bps - 1) begin
						clk_counter <= clk_counter + 1;
						tx <= 0;
				  end 
				  else begin
						clk_counter <= 0;
						state <= DATA;
				  end
			 end

			 DATA: begin
				  tx <= data[bit_index];                      // Transmit the current data bit directly

				  if (clk_counter < clk_bps) begin
						clk_counter <= clk_counter + 1;
				  end else begin
						clk_counter <= 0;
						if (bit_index == 7) begin
							 bit_index <= 0;
							 state <= PARITY;                    // Move to PARITY state after 8 bits
						end
						else bit_index <= bit_index + 1'b1;
				  end
			 end

			 PARITY: begin
				  if(clk_counter < clk_bps + 1) begin
						tx <= parity_type ? ~(^data) :^data;
						clk_counter <= clk_counter + 1;
				  end else begin
						clk_counter <= 0;
						state <= STOP;
						tx <= 1;
				  end
			 end

			 STOP: begin
				  tx <= 1;                                     // Ensure stop bit is 1
				  if (clk_counter < clk_bps - 1) begin
						clk_counter <= clk_counter + 1;
				  end else begin
						clk_counter <= 0;
						tx_done <= 1;
						state <= IDLE;
				  end
			 end   
		 endcase
	 end
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule