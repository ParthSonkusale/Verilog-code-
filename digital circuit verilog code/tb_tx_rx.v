module tb_tx_rx;
wire rx_parity, rx_complete;
wire [7:0] rx_msg;
wire tx, tx_done;
reg [7:0] data;
reg clk_3125;
reg tx_start;
reg parity_type;

UART_TX part2(clk_3125, parity_type, tx_start, data, tx, tx_done);
UART_RX part1(clk_3125, tx, rx_msg, rx_parity, rx_complete);

initial clk_3125 = 0;
always #160 clk_3125 = ~clk_3125;
 
task transmitter(input [7:0] D);
begin
    data = D;
    tx_start = 1;
    parity_type = 0;
    @(posedge clk_3125);
    tx_start = 0;
    wait(tx_done);
end 
endtask

task send_data;
begin
    transmitter(8'b01010000); // P
#1000
    transmitter(8'b01000001); // A
#1000
    transmitter(8'b01010010); // R
#1000
    transmitter(8'b01110100); // t
#1000
    transmitter(8'b01101000); // h
end
endtask

task receiver();
begin

  @(posedge rx_complete);
    $display("Time=%0t | Received Data = %b (%c)", $time, rx_msg, rx_msg);
   @(negedge rx_complete);
end
endtask
	 
task receive_data;
begin
    repeat (5) receiver();
end
endtask


initial begin
    
    fork
        send_data();       
        receive_data();    
    join
    $stop; 
end
	 
endmodule
