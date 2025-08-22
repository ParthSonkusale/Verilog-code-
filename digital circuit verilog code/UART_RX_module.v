module uart_rx(
    input clk_3125,
    input rx,
    output reg [7:0] rx_msg,
    output reg rx_parity,
    output reg rx_complete  
    );


parameter CLKS_PER_BIT   = 14;

parameter IDLE           = 3'b000;
parameter RX_START_BIT   = 3'b001;
parameter RX_DATA_BITS   = 3'b010;
parameter RX_PARITY_BIT  = 3'b011;
parameter RX_STOP_BIT    = 3'b100;


reg [31:0] clk_count   = 0;
reg [31:0] bit_index   = 0;
reg [2:0] state       = IDLE;
reg [7:0] data_byte   = 0;
reg [7:0]parity_calc;
reg x=1'b1;
reg [4:0] counter;
reg [7:0]rec_parity;
 

initial begin
    rx_msg = 0;
    rx_parity     = 0;
    rx_complete   = 0;
   
	 
end


always @(posedge clk_3125) begin
    case (state)
	 

        IDLE: begin
            rx_complete = 0;
            clk_count   = 0;
            bit_index   = 0;
            rec_parity=0;
            if (rx == 0)  
                state = RX_START_BIT;
        end

        RX_START_BIT: begin
            if (clk_count == (CLKS_PER_BIT - 1)/2) begin
                if (rx == 0) begin  
                    clk_count = 0;
                    state     = RX_DATA_BITS;
                end else begin
                    state = IDLE;  
                end
            end else begin
                clk_count = clk_count + 1;
            end
        end

        RX_DATA_BITS: begin
            if (clk_count < CLKS_PER_BIT -1) begin
                
                clk_count = clk_count + 1;
           end else begin
			  data_byte[7-bit_index] <= rx;
                clk_count = 0;
                if (bit_index < 7)
                    bit_index = bit_index + 1;
                else begin
                    bit_index = 0;
						  
                    state     = RX_PARITY_BIT;
                end
            end
        end

       RX_PARITY_BIT: begin

    if (clk_count < CLKS_PER_BIT - 1)begin
        clk_count = clk_count + 1;
    end else begin
rec_parity=rx;
	     parity_calc=^data_byte;
		  
        
		  clk_count = 0;
        state = RX_STOP_BIT;
    end
end


        RX_STOP_BIT: begin
		 if(clk_count < CLKS_PER_BIT + 5 + x) begin
                clk_count = clk_count + 1;
            end else begin
rx_parity=(rec_parity==parity_calc)?(rec_parity):8'h3F;
                
                rx_msg=(rec_parity==parity_calc)?(data_byte):8'h3F;
					 clk_count   = 0;
                rx_complete = 1;
                x=0;
                

                state       = IDLE;
            end
        end

    endcase
end




endmodule