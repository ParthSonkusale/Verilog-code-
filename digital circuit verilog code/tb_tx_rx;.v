module tb_tx_rx;
    reg clk_3125;
    reg parity_type, tx_start;
    reg [7:0] data;
    wire rx;
    wire rx_parity;
    wire [7:0] rx_msg;
    wire rx_complete;
    wire tx, tx_done;

    
    assign rx = tx;

    
    uart_rxtx TR(
        .clk_3125(clk_3125),
        .parity_type(parity_type),
        .tx_start(tx_start),
        .data(data),
        .rx(rx),
        .rx_parity(rx_parity),
        .rx_msg(rx_msg),
        .rx_complete(rx_complete),
        .tx(tx),
        .tx_done(tx_done)
    );

    
    initial begin
        clk_3125 = 0;
        forever #160 clk_3125 = ~clk_3125; 
    end

    // Task to send data
    task trans_reci(input [7:0] d);
    begin
        @(posedge clk_3125);
        data = d;
        tx_start = 1;
        @(posedge clk_3125);
        tx_start = 0;
        wait(tx_done);   // wait for tx complete
    end
    endtask

    // Stimulus
    initial begin
        parity_type = 0;  
        tx_start = 0;
        data = 0;

        
        trans_reci(8'b01010000); // P
        trans_reci(8'b01100001); // a
        trans_reci(8'b01110010); // r
        trans_reci(8'b01110100); // t
        trans_reci(8'b01001000); // H

       
    end

    // Monitor
    always @(posedge clk_3125) begin
        if (rx_complete) begin
            $display("Time=%0t RX complete -> Data = %b (%c)", 
                     $time, rx_msg, rx_msg);
        end
    end

endmodule
