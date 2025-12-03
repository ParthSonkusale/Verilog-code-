
module t2a_dht(
    input clk_50M,
    input reset,
    inout sensor,
    output reg [7:0] T_integral,
    output reg [7:0] RH_integral,
    output reg [7:0] T_decimal,
    output reg [7:0] RH_decimal,
    output reg [7:0] Checksum,
    output reg data_valid
);

    initial begin
        T_integral = 0;
        RH_integral = 0;
        T_decimal = 0;
        RH_decimal = 0;
        Checksum = 0;
        data_valid = 0;
    end


reg [2:0] state;
reg [19:0] cnt;
reg [5:0] bit_index;
reg [39:0] data_buf;
reg sensor_out;
reg sensor_dir;

localparam SEND_START        = 0,
           RELEASE_LINE      = 1,
           WAIT_RESP_LOW     = 2,
           WAIT_RESP_HIGH    = 3,
           RECEIVE           = 4,
           PROCESS_DATA      = 5; 


localparam T_18MS   = 890_000;  // 18 ms @ 50 MHz
localparam T_40US   = 2_000;    // 40 µs
localparam T_80US   = 4_000;    // 80 µs
localparam T_70US   = 3_500;    // 70 µs

assign sensor = (sensor_dir) ? sensor_out : 1'bz;

always @(posedge clk_50M or negedge reset) begin
    if (!reset) begin
        state <= SEND_START;    
        cnt <= 0;
        bit_index <= 0;
        data_buf <= 0;
        data_valid <= 0;
        sensor_out <= 0;        
        sensor_dir <= 0;        
    end else begin
        case (state)


            SEND_START: begin
                data_valid <= 0;
                if (cnt < T_18MS) begin
                    cnt <= cnt + 1;
                end else begin
                    cnt <= 0;
                    sensor_out <= 1;  
                    state <= RELEASE_LINE;
                end
            end


            RELEASE_LINE: begin
                if (cnt < T_40US) begin
                    cnt <= cnt + 1;
                end else begin
                    cnt <= 0;
                    sensor_dir = 0; 
                    state <= WAIT_RESP_LOW;
                end
            end

            WAIT_RESP_LOW: begin
                if (!sensor) begin
                    if (cnt < T_80US) begin
                        cnt <= cnt + 1;
                    end else begin
                        cnt <= 0;
                        state <= WAIT_RESP_HIGH;
                    end
                end
            end

           
            WAIT_RESP_HIGH: begin
                if (sensor) begin
                    if (cnt < T_80US - 1) begin
                        cnt <= cnt + 1;
                    end else begin
                        cnt <= 0;
                        bit_index <= 0;
                        state <= RECEIVE;
                    end
                end else begin
                    cnt <= 0;
                    bit_index <= 0;
                end
            end
 
           RECEIVE: begin 
			  if (sensor) begin 
				  cnt <= cnt + 1;
			  end else begin 
				  if (cnt > 0) begin
						  data_buf[39 - bit_index] <= (cnt < T_70US ) ? 1'b0 : 1'b1;
						  bit_index <= bit_index + 1;
						  cnt <= 0; 
					  if (bit_index == 39 ) begin
						  bit_index <= 0; 
						  cnt <= 0;
						  state <= PROCESS_DATA;
					  end else begin
						  cnt <= 0;
						  state <= RECEIVE;
					  end
					  end
			     end
			  end

            PROCESS_DATA: begin
                cnt <= cnt + 1;
                if (cnt == 2) begin
                    cnt <= 0;
                RH_integral <= data_buf[39:32];
                RH_decimal  <= data_buf[31:24];
                T_integral  <= data_buf[23:16];
                T_decimal   <= data_buf[15:8];
                Checksum    <= data_buf[7:0];

                if (Checksum ==
                    (RH_integral + RH_decimal + T_integral + T_decimal))
                    data_valid <= 1;
                else
                    data_valid <= 0;
                state <= SEND_START;  
                end
            end
        endcase
    end
end

  
endmodule
