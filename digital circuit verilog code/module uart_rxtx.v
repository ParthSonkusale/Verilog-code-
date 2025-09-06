module uart_rxtx(
    input clk_3125,
    input parity_type, tx_start,
    input [7:0] data,
    input rx,
    output reg [7:0] rx_msg,
    output reg rx_parity,
    output reg rx_complete,
    output reg tx, tx_done
);

// ---------------- RX ----------------
parameter RX_IDLE        = 3'b000;
parameter RX_START_BIT   = 3'b001;
parameter RX_DATA_BITS   = 3'b010;
parameter RX_PARITY_BIT  = 3'b011;
parameter RX_STOP_BIT    = 3'b100;

reg [31:0] rx_clk_count = 0;
reg [2:0]  rx_bit_index = 0;
reg [2:0]  rx_state     = RX_IDLE;
reg [7:0]  data_byte    = 0;
reg        rx_parity_bit;
reg [7:0]  parity_calc;
reg [7:0]  rec_parity;
reg        rx_x = 1'b1;

// ---------------- TX ----------------
parameter CLKS_PER_BIT   = 14;
parameter TX_IDLE        = 3'd0;
parameter TX_START_BIT   = 3'd1;
parameter TX_DATA_BITS   = 3'd2;
parameter TX_PARITY_BIT  = 3'd3;
parameter TX_STOP_BIT    = 3'd4;

reg [2:0]  tx_state      = TX_IDLE;
reg [4:0]  tx_clk_count  = 0;
reg [2:0]  tx_bit_index  = 0;
reg        parity_bit    = 0;
reg [7:0]  tx_data       = 8'd0;

// ---------------- Init ----------------
initial begin
    tx          = 1;
    tx_done     = 0;
    rx_msg      = 0;
    rx_parity   = 0;
    rx_complete = 0;
end

// ---------------- TX FSM ----------------
always @(posedge clk_3125) begin
    case (tx_state)

    TX_IDLE: begin
        if (tx_clk_count == 0) begin
            tx <= 1;
            tx_done <= 0;
            tx_bit_index <= 7;
        end

        tx_clk_count <= 0;

        if (tx_start) begin
            tx_data <= data;
            parity_bit <= (^data) ^ parity_type;
            tx <= 0;
            tx_state <= TX_START_BIT;
        end
    end

    TX_START_BIT: begin
        if (tx_clk_count == 0) begin
            tx <= 0;
        end
        else if (tx_clk_count == CLKS_PER_BIT - 2) begin
            tx <= tx_data[7];
        end

        if (tx_clk_count == CLKS_PER_BIT) begin
            tx_clk_count <= 0;
            tx_state <= TX_DATA_BITS;
        end else begin
            tx_clk_count <= tx_clk_count + 1;
        end
    end

    TX_DATA_BITS: begin
        if (tx_clk_count == 0) begin
            tx <= tx_data[tx_bit_index];
        end
        else if (tx_clk_count == CLKS_PER_BIT - 2) begin
            if (tx_bit_index > 0)
                tx <= tx_data[tx_bit_index - 1];
            else
                tx <= parity_bit;
        end

        if (tx_clk_count == CLKS_PER_BIT - 1) begin
            tx_clk_count <= 0;
            if (tx_bit_index > 0)
                tx_bit_index <= tx_bit_index - 1;
            else begin
                tx_bit_index <= 0;
                tx_state <= TX_PARITY_BIT;
            end
        end else begin
            tx_clk_count <= tx_clk_count + 1;
        end
    end

    TX_PARITY_BIT: begin
        if (tx_clk_count == 0) begin
            tx <= parity_bit;
        end
        else if (tx_clk_count == CLKS_PER_BIT - 2) begin
            tx <= 1;
        end

        if (tx_clk_count == CLKS_PER_BIT - 1) begin
            tx_clk_count <= 0;
            tx_state <= TX_STOP_BIT;
        end else begin
            tx_clk_count <= tx_clk_count + 1;
        end
    end

    TX_STOP_BIT: begin
        if (tx_clk_count == 0) begin
            tx <= 1;
        end

        if (tx_clk_count == CLKS_PER_BIT - 3) begin
            tx_done <= 1;
        end

        if (tx_clk_count == CLKS_PER_BIT - 2) begin
            tx_clk_count <= 0;
            tx_done <= 0;
            tx <= 1;
            tx_state <= TX_IDLE;
        end else begin
            tx_clk_count <= tx_clk_count + 1;
        end
    end

    endcase
end

// ---------------- RX FSM ----------------
always @(posedge clk_3125) begin
    case (rx_state)

    RX_IDLE: begin
        rx_complete   <= 0;
        rx_clk_count  <= 0;
        rx_bit_index  <= 0;
        rec_parity    <= 0;
        if (rx == 0)
            rx_state <= RX_START_BIT;
    end

    RX_START_BIT: begin
        if (rx_clk_count == (CLKS_PER_BIT - 1)/2) begin
            if (rx == 0) begin
                rx_clk_count <= 0;
                rx_state <= RX_DATA_BITS;
            end else begin
                rx_state <= RX_IDLE;
            end
        end else begin
            rx_clk_count <= rx_clk_count + 1;
        end
    end

    RX_DATA_BITS: begin
        if (rx_clk_count < CLKS_PER_BIT - 1) begin
            rx_clk_count <= rx_clk_count + 1;
        end else begin
            data_byte[7-rx_bit_index] <= rx;
            rx_clk_count <= 0;
            if (rx_bit_index < 7)
                rx_bit_index <= rx_bit_index + 1;
            else begin
                rx_bit_index <= 0;
                rx_state <= RX_PARITY_BIT;
            end
        end
    end

    RX_PARITY_BIT: begin
        if (rx_clk_count < CLKS_PER_BIT - 1) begin
            rx_clk_count <= rx_clk_count + 1;
        end else begin
            rec_parity <= rx;
            parity_calc <= ^data_byte;
            rx_clk_count <= 0;
            rx_state <= RX_STOP_BIT;
        end
    end

    RX_STOP_BIT: begin
        if (rx_clk_count < CLKS_PER_BIT + 5 + rx_x) begin
            rx_clk_count <= rx_clk_count + 1;
        end else begin
            rx_parity   <= (rec_parity == parity_calc) ? rec_parity : 1'b0;
            rx_msg      <= (rec_parity == parity_calc) ? data_byte : 8'h3F;
            rx_clk_count <= 0;
            rx_complete <= 1;
            rx_x <= 0;
            rx_state <= RX_IDLE;
        end
    end

    endcase
end

endmodule
