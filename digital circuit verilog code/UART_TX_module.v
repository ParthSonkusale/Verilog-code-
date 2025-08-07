module uart_tx(
    input clk_3125,
    input parity_type,tx_start,
    input [7:0] data,
    output reg tx, tx_done
);

parameter CLKS_PER_BIT = 14;
parameter IDLE        = 3'd0;
parameter START_BIT   = 3'd1;
parameter DATA_BITS   = 3'd2;
parameter PARITY_BIT  = 3'd3;
parameter STOP_BIT    = 3'd4;

reg [2:0] current_state = IDLE;
reg [4:0] clk_count = 0;
reg [2:0] bit_index = 0;
reg parity_bit = 0;
reg [7:0] tx_data = 8'd0;

initial begin
    tx = 1;
    tx_done = 0;
end

always @(posedge clk_3125) begin
    case (current_state)

    IDLE: begin
        if (clk_count == 0) begin
            tx <= 1;
            tx_done <= 0;
            bit_index <= 7;  
        end

        clk_count <= 0;

        if (tx_start) begin
            tx_data <= data;
            parity_bit <= (^data) ^ parity_type;
            tx <= 0;  
            current_state <= START_BIT;
        end
    end

    START_BIT: begin
        if (clk_count == 0) begin
            tx <= 0;  
        end
        else if (clk_count == CLKS_PER_BIT - 2) begin
            tx <= tx_data[7];  
        end

        if (clk_count == CLKS_PER_BIT) begin
            clk_count <= 0;
            current_state <= DATA_BITS;
        end else begin
            clk_count <= clk_count + 1;
        end
    end

    DATA_BITS: begin
        if (clk_count == 0) begin
            tx <= tx_data[bit_index];  
        end
        else if (clk_count == CLKS_PER_BIT - 2) begin
            if (bit_index > 0)
                tx <= tx_data[bit_index - 1];  
            else
                tx <= parity_bit; 
        end

        if (clk_count == CLKS_PER_BIT - 1) begin
            clk_count <= 0;
            if (bit_index > 0)
                bit_index <= bit_index - 1;
            else begin
                bit_index <= 0;
                current_state <= PARITY_BIT;
            end
        end else begin
            clk_count <= clk_count + 1;
        end
    end

    PARITY_BIT: begin
        if (clk_count == 0) begin
            tx <= parity_bit;
        end
        else if (clk_count == CLKS_PER_BIT - 2) begin
            tx <= 1; 
        end

        if (clk_count == CLKS_PER_BIT - 1) begin
            clk_count <= 0;
            current_state <= STOP_BIT;
        end else begin
            clk_count <= clk_count + 1;
        end
    end

    STOP_BIT: begin
        if (clk_count == 0) begin
            tx <= 1;
        end

        if (clk_count == CLKS_PER_BIT - 3) begin
            tx_done <= 1;  
        end

        if (clk_count == CLKS_PER_BIT - 2) begin
            clk_count <= 0;
            tx_done <= 0;
            tx <= 1;
            current_state <= IDLE;
        end else begin
            clk_count <= clk_count + 1;
        end
    end

    endcase
end
endmodule