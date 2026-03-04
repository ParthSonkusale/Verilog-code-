module data_packet(
    input  wire       clk,       // system clock
    input  wire       rst_n,     // active-low reset
    input  wire       tx_done,   // UART transmitter signals when one byte is sent
    input  wire [7:0] rx_msg,
    input             rx_complete,
    input  wire [3:0] x,curr_x,curr_y,
    input  wire [7:0] mois, temp, humi,
	 input             start_end,
	 input env_en,send_cord,
    output reg [7:0]  tx_data,   // data byte to send
    output wire       parity_type, // parity type: even(0)/odd(1)
	 output reg start_cmd_detected,
	 output reg tx_start

);

    // -------------------------------
    // ASCII Characters
    // -------------------------------
    localparam CHAR_M    = 8'h4D;
    localparam CHAR_P    = 8'h50;
    localparam CHAR_I    = 8'h49;
    localparam CHAR_T    = 8'h54;
    localparam CHAR_H    = 8'h48;
    localparam CHAR_DASH = 8'h2D;
    localparam CHAR_HASH = 8'h23;
    localparam CHAR_CR   = 8'h0D;
    localparam CHAR_LF   = 8'h0A;
    localparam CHAR_SP   = 8'h20;
	 localparam CHAR_D    = 8'h44;
	 localparam CHAR_N    = 8'h4E;
	 localparam CHAR_E    = 8'h45;
	 localparam CHAR_COMMA= 8'h2C;
	 

    // -------------------------------
    // State & ID
    // -------------------------------
    reg [7:0] id;
    reg [2:0] state;

    // -------------------------------
    // Decimal Split
    // -------------------------------
    wire [3:0] temp_tens  = temp / 10;
    wire [3:0] temp_units = temp % 10;
    wire [3:0] humi_tens  = humi / 10;
    wire [3:0] humi_units = humi % 10;

    // -------------------------------
    // Message Parameters
    // -------------------------------
    localparam MSG_LEN   = 11;
    localparam MSG_T_H   = 15;
	 localparam MSG_END   =  8;
	 localparam MSG_CORD  =  7;
	 localparam IDLE      = 3'd0;
    localparam SEND_MPMI = 3'd1;
    localparam SEND_MOIS = 3'd2;
    localparam SEND_T_H  = 3'd3;
	 localparam SEND_COORDINATES = 3'd4;
	 localparam SEND_END = 3'd5;
	 localparam END_DETECT= 32'd125_000_000;
    reg [10:0] msg     [0:MSG_LEN-1];
    reg [10:0] mois_MD [0:MSG_LEN-1];
    reg [14:0] T_H     [0:MSG_T_H-1];
	 reg [7 :0] End     [0:MSG_END-1];
	 reg [6 :0] COORDINATES [0:MSG_CORD-1];
	 
    assign parity_type = 1'b0;   // even parity

    reg [3:0] idx;
    reg       first_char_sent;
	 reg [31:0] cnt;
    // UART Transmit FSM

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            idx             <= 0;
				id              <= 0;

            tx_data         <= 8'h00;
            first_char_sent <= 1'b0;
            state           <= IDLE;
        end else begin		  
		      // ID Decoder
	
            if      (x==1) id = 8'h31;
            else if (x==2) id = 8'h32;
            else if (x==3) id = 8'h33;
				else if (x==4) id = 8'h34;
				else if (x==5) id = 8'h35;
				else if (x==6) id = 8'h36;
				else if (x==7) id = 8'h37;
				else if (x==8) id = 8'h38;
				else if (x==9) id = 8'h39;

		  
            // Message: " MMI-3-M-#\r\n"
            mois_MD[0]  = CHAR_SP;
            mois_MD[1]  = CHAR_M;
            mois_MD[2]  = CHAR_M;
            mois_MD[3]  = CHAR_DASH;
            mois_MD[4]  = id;
            mois_MD[5]  = CHAR_DASH;
            mois_MD[6]  = mois;
            mois_MD[7]  = CHAR_DASH;
            mois_MD[8]  = CHAR_HASH;
            mois_MD[9]  = CHAR_CR;
            mois_MD[10] = CHAR_LF;

            // Message: " TH-3-tt-hh-#\r\n"
            T_H[0]  = CHAR_SP;
            T_H[1]  = CHAR_T;
            T_H[2]  = CHAR_H;
            T_H[3]  = CHAR_DASH;
            T_H[4]  = id;
            T_H[5]  = CHAR_DASH;
            T_H[6]  = temp_tens  + 8'h30;
            T_H[7]  = temp_units + 8'h30;
            T_H[8]  = CHAR_DASH;
            T_H[9]  = humi_tens  + 8'h30;
            T_H[10] = humi_units + 8'h30;
            T_H[11] = CHAR_DASH;
            T_H[12] = CHAR_HASH;
            T_H[13] = CHAR_CR;
            T_H[14] = CHAR_LF;

            // Message: " MPMI-3-#\r\n"
            msg[0]  = CHAR_SP;
            msg[1]  = CHAR_M;
            msg[2]  = CHAR_P;
            msg[3]  = CHAR_I;
            msg[4]  = CHAR_M;
            msg[5]  = CHAR_DASH;
            msg[6]  = id;
            msg[7]  = CHAR_DASH;
            msg[8]  = CHAR_HASH;
            msg[9]  = CHAR_CR;
            msg[10] = CHAR_LF;
            
				// Message: "END-#\r\n"
				End[0]  = CHAR_SP;
				End[1]  = CHAR_E;
            End[2]  = CHAR_N;
            End[3]  = CHAR_D;
            End[4]  = CHAR_DASH;
            End[5]  = CHAR_HASH;
            End[6]  = CHAR_CR;
            End[7]  = CHAR_LF;
				
				COORDINATES[0] = CHAR_SP;
				COORDINATES[1] = curr_x + 8'h30;
				COORDINATES[2] = CHAR_COMMA;
				COORDINATES[3] = curr_y + 8'h30;
				COORDINATES[4] = CHAR_HASH;
				COORDINATES[5] = CHAR_CR;
				COORDINATES[6] = CHAR_LF;

				
            case (state)
					IDLE :begin
						tx_start <=0;
						idx <= 0;
						first_char_sent <= 0;
						cnt <=0;
						if (start_end && (x>=9))begin
							cnt <= cnt +1;
							if (cnt >= END_DETECT)begin
								state<= SEND_END;
							end
							else begin
								state <= IDLE;
							end
						end else if(env_en)begin
							state <= SEND_MPMI;
						end else if(send_cord)begin
							state <= SEND_COORDINATES;
						end else
							state <= IDLE;	
					 end
					 
					 
                SEND_MPMI: begin
                    if (!first_char_sent ) begin
								tx_start <=1;
                        tx_data <= msg[0];
                        idx <= 1;
                        first_char_sent <= 1;
                    end else if (idx < MSG_LEN && tx_done ) begin
                        tx_data <= msg[idx];
                        idx <= idx + 1;
                    end else if (idx >= MSG_LEN) begin
                        tx_start <=0;
								idx <= 0;
                        first_char_sent <= 0;
                        state <= SEND_MOIS;
                    end
                end

                SEND_MOIS: begin
                    if (!first_char_sent ) begin
								tx_start <=1;
                        tx_data <= mois_MD[0];
                        idx <= 1;
                        first_char_sent <= 1;
                    end else if (idx < MSG_LEN && tx_done ) begin
                        tx_data <= mois_MD[idx];
                        idx <= idx + 1;
                    end else if (idx >= MSG_LEN) begin
                        tx_start <=0;
								idx <= 0;
                        first_char_sent <= 0;
                        state <= SEND_T_H;
                    end
                end

                SEND_T_H: begin
                    if (!first_char_sent) begin
								tx_start <=1;
                        tx_data <= T_H[0];
                        idx <= 1;
                        first_char_sent <= 1;
                    end else if (idx < MSG_T_H && tx_done ) begin
                        tx_data <= T_H[idx];
                        idx <= idx + 1;
                    end else if (idx >= MSG_T_H) begin
                        tx_start <=0;
								idx <= 0;
                        first_char_sent <= 0;
                        state <= IDLE;
                    end
                end
					 
					 SEND_COORDINATES :begin
						  if (!first_char_sent) begin
								tx_start <=1;
								tx_data <= COORDINATES[0];
								idx <= 1;
								first_char_sent <= 1;
						  end else if (idx < MSG_CORD && tx_done ) begin
								tx_data <= COORDINATES[idx];
								idx <= idx + 1;
						  end else if (idx >= MSG_CORD) begin
								tx_start <=0;
								idx <= 0;
                        first_char_sent <= 0;
								state <= IDLE;
								
						  end						
					 end
					 
					 SEND_END: begin
						  if (!first_char_sent) begin
								tx_start <=1;
								tx_data <= End[0];
								idx <= 1;
								first_char_sent <= 1;
						  end else if (idx < MSG_END && tx_done ) begin
								tx_data <= End[idx];
								idx <= idx + 1;
						  end else if (idx >= MSG_END) begin
								tx_start <=0;								
						  end
					 end
					 

            endcase	
        end
    end
    // -------------------------------
    // UART Receiver Buffer
    // -------------------------------
reg [7:0] buffer [0:15];
reg [4:0] indx;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        indx               <= 0;
        start_cmd_detected <= 1'b0;
    end 
    else if (rx_complete) begin
        buffer[indx] <= rx_msg;

        if (indx < 15)
            indx <= indx + 1;

        // Detect "START-3-#"
        if (indx >= 8 &&
            buffer[indx-8] == 8'h53 && // S
            buffer[indx-7] == 8'h54 && // T
            buffer[indx-6] == 8'h41 && // A
            buffer[indx-5] == 8'h52 && // R
            buffer[indx-4] == 8'h54 && // T
            buffer[indx-3] == 8'h2D && // -
            buffer[indx-2] == 8'h35 && // 5
            buffer[indx-1] == 8'h2D && // -
            rx_msg         == 8'h23    // #
        ) begin
            start_cmd_detected <= 1'b1;
            indx <= 0;   // reset buffer after valid command
        end
		  else if (start_end)begin
				start_cmd_detected <= 1'b0;
		  end
        else begin
            start_cmd_detected <= 1'b0;
        end
    end
end

endmodule