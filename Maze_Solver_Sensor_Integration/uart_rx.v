module uart_rx(
    input clk_50,
	 input rst,
    input rx,
    output reg [7:0] rx_msg,
    output reg rx_parity,
    output reg rx_complete
    );

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

localparam clk_per_bits = 448;
localparam IDLE = 3'b000;
localparam START = 3'b001;
localparam READ_BIT = 3'b010;
localparam PARTIY_BIT = 3'b011;
localparam STOP = 3'b100;

reg [2:0] state;      
reg [8:0] counter;      
reg [2:0] data_bit_recieved;
reg [7:0] r_rx_msg;
reg r_rx_parity = 0;

//initial begin
//    rx_msg = 0;
//	rx_parity = 0;
//    rx_complete = 0;
//    state = IDLE;
//    counter = 511;
//    data_bit_recieved = 0;
//end

always@(posedge clk_50 or negedge rst)begin
	 if (!rst) begin
		 rx_msg <= 0;
		 rx_parity <= 0;
		 rx_complete <= 0;
		 state <= IDLE;
		 counter <= 511;
		 data_bit_recieved <= 0;
	 end
	 else begin
		 case(state)
			  IDLE:begin
						 rx_complete <= 0; // Reset rx_complete on idle
						 //rx_parity <= 0;   // Reset parity check status
						 if(rx == 0) begin
							  state <= START;
						 end
						 else begin
							  state <= IDLE;//can remove
						 end
			  end
			  START:begin
						 if(counter == (clk_per_bits/2)-1)    begin // i.e ((28/2) -1)
							  if(rx == 0)     begin
									state <= READ_BIT;
									counter <= 0;
							  end
							  else    begin
									state <= IDLE;//it was a glich
									counter <= 0;
							  end
						 end
						 else    begin
							  counter <= counter + 1;
							  state <= START;//can remove
						 end
			  end
			  READ_BIT:begin
							  if(counter == clk_per_bits-1)   begin
									counter <= 0;
									r_rx_msg <= {rx, r_rx_msg[7:1]}; // LSB-first, right shift

									if(data_bit_recieved == 7)     begin
										 data_bit_recieved <= 0;
										 state <= PARTIY_BIT;
									end
									else    begin
										 data_bit_recieved <= data_bit_recieved + 1;
										 state <= READ_BIT;//can remove
									end
							  end
							  else    begin
									counter <= counter + 1;
							  end
			  end
			  PARTIY_BIT: begin
							  if(counter == clk_per_bits-1) begin
									counter <= 0;
			  
							  // Calculate the even parity (XOR all bits in r_rx_msg)
							  // If parity is correct, the XOR result should match the received parity bit
							  r_rx_parity <= rx;

							  if((r_rx_msg[0]^r_rx_msg[1]^r_rx_msg[2]^r_rx_msg[3]^r_rx_msg[4]^r_rx_msg[5]^r_rx_msg[6]^r_rx_msg[7]) == rx) begin
									// Parity matches, proceed with the next state or use the received message
									state <= STOP;
							  end
							  else begin
									r_rx_msg <= 8'h3F; // Set r_rx_msg to "?"(ASCII) in case of a parity mismatch 
									state <= STOP;
							  end
							  end
							  else begin
									counter <= counter + 1;
							  end
			  end
			  STOP:begin
					if(counter == (clk_per_bits-1)+3)   begin//(28-1)+7
						 counter <= 1;
						 //if(rx == 1)   begin //(not needed as its always stop bit 1)
						 rx_msg <= r_rx_msg;
						 state <= IDLE;
						 rx_complete <= 1;   // Indicate reception complete
						 rx_parity <= r_rx_parity;
						 //end
					end
					else counter <= counter + 1;
			  end


		 endcase
	end
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule