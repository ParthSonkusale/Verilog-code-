module t2a_dht (
    input wire clk_50M,
    input wire rst_n,
    inout wire sensor,
    output reg [7:0] T_integral,
    output reg [7:0] RH_integral,
    output reg [7:0] T_decimal,
    output reg [7:0] RH_decimal
);

    reg [39:0] data_reg;
    reg [5:0] bit_index;
    reg [19:0] cnt;
    reg [25:0] cnt_watchdog;
    reg sensor_prev;
    reg [2:0] state;
    reg drive_enable;
    reg sensor_sync;

    always @(posedge clk_50M or negedge rst_n) begin
        if (!rst_n) begin
            data_reg       <= 40'd0;
            bit_index      <= 6'd0;
            cnt            <= 20'd0;
            cnt_watchdog   <= 26'd0;
            sensor_prev    <= 1'b0;
            sensor_sync    <= 1'b0;
            state          <= 3'd0;
            drive_enable   <= 1'b0;

            T_integral     <= 8'd0;
            RH_integral    <= 8'd0;
            T_decimal      <= 8'd0;
            RH_decimal     <= 8'd0;
        end
        else begin
            if (cnt_watchdog > 50000000) begin
                state <= 0;
                bit_index <= 0;
                cnt <= 0;
                cnt_watchdog <= 0;
            end else begin
                cnt_watchdog <= cnt_watchdog + 1;
            end
            
            sensor_sync <= sensor;
            
            case(state)
                0: begin
                    drive_enable <= 0;
                    if (cnt > 901000) begin
                        cnt <= 0;
                        drive_enable <= 1;
                        state <= 1;
                    end else begin
                        cnt <= cnt + 1;
                    end
                end

                1: if (~sensor_sync) state <= 2;
                2: if (sensor_sync)  state <= 3;
                3: if (~sensor_sync) state <= 4;
                4: if (sensor_sync)  state <= 5;
                5: if (~sensor_sync) state <= 6;

                6: begin
                    if (bit_index < 40) begin
                        if (~sensor_sync && sensor_prev) begin
                            if (cnt > 2500)
                                data_reg[39-bit_index] <= 1'b1;
                            else
                                data_reg[39-bit_index] <= 1'b0;

                            cnt <= 0;
                            bit_index <= bit_index + 1;
                        end

                        if (sensor_sync)
                            cnt <= cnt + 1;
                    end else begin
                        RH_integral <= data_reg[39:32];
                        RH_decimal  <= data_reg[31:24];
                        T_integral  <= data_reg[23:16];
                        T_decimal   <= data_reg[15:8];

                        state <= 0;
                        bit_index <= 0;
                        cnt <= 0;
                        cnt_watchdog <= 0;
                    end

                    sensor_prev <= sensor_sync;
                end
            endcase
        end
    end

    assign sensor = (drive_enable) ? 1'bz : 1'b0;

endmodule