
module encoders (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        enc_a,
    input  wire        enc_b,
    input  wire [3:0]  move_ip,
    output reg  [11:0] enca_cnt,
	 output reg  [3:0]  move_op,
    output reg  [11:0] encb_cnt,
	 output reg busy_turn,
	 output reg busy,
	 output reg [3:0] x

);


initial begin
x =2;
end
    // Encoder Synchronization
    reg enc_a_d, enc_a_dd;
    reg enc_b_d, enc_b_dd;
	 
    wire enc_a_pulse = enc_a_dd & ~enc_a_d;
    wire enc_b_pulse = enc_b_dd & ~enc_b_d;	
	
    always @(posedge clk) begin
        enc_a_dd <= enc_a_d;
        enc_a_d  <= enc_a;
        enc_b_dd <= enc_b_d;
        enc_b_d  <= enc_b;
    end

	 
//	 reg [10:0] FORWARD_CNT = 11'd1125;
//    reg [9 :0] LEFT_CNT    = 11'd800;
//	 reg [9 :0] RIGHT_CNT   = 11'd770;
//	 reg [9 :0] U_CNT       = 11'd705;
//	 reg [9 :0] FWD_T_CNT   = 11'd720;

    reg [10:0] FORWARD_CNT = 11'd1140;
	 reg [10:0] REVERSE_CNT = 11'd450;
	 reg [10:0] REVERSE_LEFT_CNT = 11'd300;
	 reg [10:0] REVERSE_RIGHT_CNT = 11'd300;
    reg [9 :0] LEFT_CNT    = 11'd770;
	 reg [9 :0] RIGHT_CNT   = 11'd800;
	 reg [9 :0] U_CNT       = 11'd800;
	 reg [9 :0] FWD_T_CNT   = 11'd718;

	 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        move_op  <= 4'b0000;
        enca_cnt <= 0;
        encb_cnt <= 0;
		  busy_turn <= 0;
        busy     <= 1'b0;
    end else begin
        if (!busy) begin
            move_op <= 4'b0000;
            enca_cnt <= 0;
            encb_cnt <= 0;

            if (move_ip != 4'b0000) begin
                move_op <= move_ip;   //input move is assigned to output move
                busy    <= 1'b1;
					 
            end
        end
        else begin
		  x<=x;
            case (move_op)
                  
                //FORWARD
                4'b0001: begin
                    if (enc_a_pulse) enca_cnt <= enca_cnt + 1;
                    if (enc_b_pulse) encb_cnt <= encb_cnt + 1;

                    if (enca_cnt >= FORWARD_CNT &&
                        encb_cnt >= FORWARD_CNT) begin
                        busy    <= 1'b0;
								busy_turn <= 0;
                        move_op <= 4'b0000;
                    end
                end

                //LEFT
                4'b0010: begin
                   if (enc_a_pulse) enca_cnt <= enca_cnt + 1;
						 if (enc_b_pulse) encb_cnt <= encb_cnt + 1;
						     busy_turn <= 1;
							  //TURN PHASE
							  if (enca_cnt >= LEFT_CNT || encb_cnt >= LEFT_CNT) begin
							      busy_turn <= 0;
									move_op <= 4'b0101; // switch to forward
							  end
                end

                //RIGHT
                4'b0011: begin
                   if (enc_a_pulse) enca_cnt <= enca_cnt + 1;
						 if (enc_b_pulse) encb_cnt <= encb_cnt + 1;
                       busy_turn <= 1;
							  //TURN PHASE
							  if (enca_cnt >= RIGHT_CNT || encb_cnt >= RIGHT_CNT) begin
									busy_turn <= 0;
									move_op <= 4'b0101;  // switch to forward
							  end
						
                end

                //U-TURN
                4'b0100: begin
                   if (enc_a_pulse) enca_cnt <= enca_cnt + 1;
						 if (enc_b_pulse) encb_cnt <= encb_cnt + 1;
						 	  busy_turn <= 1;
							  //TURN PHASE
							  if (enca_cnt >= U_CNT && encb_cnt >= U_CNT) begin
									enca_cnt <= 0;
									encb_cnt <= 0;
									busy_turn <= 0;
									x <= x+1;
									move_op <= 4'b0101;  // switch to forward
							  end     
					 end
					 
					 4'b1000:begin // r-left
						 if (enc_a_pulse) enca_cnt <= enca_cnt + 1;
						 if (enc_b_pulse) encb_cnt <= encb_cnt + 1;
						 		busy_turn <= 1;
							  //TURN PHASE
							  if (enca_cnt >= REVERSE_LEFT_CNT || encb_cnt >= REVERSE_LEFT_CNT) begin
							      busy_turn <= 0;
									move_op <= 4'b0001; // switch to forward
							  end
					 end

					 
					 4'b0110:begin //r- right
						 if (enc_a_pulse) enca_cnt <= enca_cnt + 1;
						 if (enc_b_pulse) encb_cnt <= encb_cnt + 1;
						 		busy_turn <= 1;
							  //TURN PHASE
							  if (enca_cnt >= REVERSE_RIGHT_CNT || encb_cnt >= REVERSE_RIGHT_CNT) begin
							      busy_turn <= 0;
									move_op <= 4'b0001; // switch to forward
							  end
					 end
					 
					 4'b1001:begin //r- right - no fwd
						 if (enc_a_pulse) enca_cnt <= enca_cnt + 1;
						 if (enc_b_pulse) encb_cnt <= encb_cnt + 1;
						 		busy_turn <= 1;
							  //TURN PHASE
							  if (enca_cnt >= REVERSE_RIGHT_CNT || encb_cnt >= REVERSE_RIGHT_CNT) begin
							      busy_turn <= 0;
									busy    <= 1'b0;
									move_op <= 4'b0000; // switch to stop
							  end
					 end
					 
                //TURN + FORWARD
                4'b0101: begin
                    if (enc_a_pulse) enca_cnt <= enca_cnt + 1;
                    if (enc_b_pulse) encb_cnt <= encb_cnt + 1;
                        busy_turn <= 0;
                    if (enca_cnt >= FWD_T_CNT &&
                        encb_cnt >= FWD_T_CNT) begin
                        busy    <= 1'b0;
								busy_turn <= 0;
                        move_op <= 4'b0000;
                    end
                end

					 4'b0111: begin
                    if (enc_a_pulse) enca_cnt <= enca_cnt + 1;
                    if (enc_b_pulse) encb_cnt <= encb_cnt + 1;
						 	busy_turn <= 1;
                    if (enca_cnt >= REVERSE_CNT &&
                        encb_cnt >= REVERSE_CNT) begin
                        busy    <= 1'b0;
								busy_turn <= 0;
                        move_op <= 4'b0000;
                    end
                end
					 
                default: begin
                    busy    <= 1'b0;
                    move_op <= 4'b0000;
                end
            endcase
        end
    end
end

endmodule
