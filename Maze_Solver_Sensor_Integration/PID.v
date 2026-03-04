module pid_wall_following(
    input  wire        clk,
	 input wire rst,
    input  wire [15:0] dist_left,
    input  wire [15:0] dist_right,
	 input wire right_present,left_present,
	 input wire  busy,
    output wire en_a,
    output wire en_b
);
  assign pid_indicator = pid_enable;
  wire pid_enable;
  assign pid_enable = (busy)?0:1;
    // PWM GENERATOR
    reg [7:0] pwm_cnt = 8'd0;
    always @(posedge clk or negedge rst)begin
        if (!rst)
				pwm_cnt <= 0;
		  else
				pwm_cnt <= pwm_cnt + 1'b1;
	 end

    reg [7:0] BASE_DUTY_l = 8'd180;
    reg [7:0] BASE_DUTY_r = 8'd180;
//always@(*)begin
//    case({left_present,mid_present,right_present})
//			3'b100,3'b101, 3'b001: pid_enable = 1;
//			default: pid_enable = 0;
//	 endcase
//end
    // PID PARAMETERS

    reg signed [7:0] KP = 8'sd60;
    reg signed [7:0] KI = 8'sd0;
    reg signed [7:0] KD = 8'sd100;
	 
	 localparam TWICE_SETPOINT = 16'd18;
    reg[15:0] RIGHT_SETPOINT = 16'd9;
	 reg[15:0] LEFT_SETPOINT = 16'd7;

    reg signed [16:0] error;
    reg signed [16:0] prev_error;
    reg signed [17:0] derivative;
    reg signed [31:0] integral;
    reg signed [31:0] correction;
	 reg [31:0] cnt;
	 reg [31:0] cnt_1;
    
	 // PID CALCULATION 
    always @(posedge clk or negedge rst) begin
	  if (!rst) begin
			error       <= 0;
			prev_error  <= 0;
			derivative  <= 0;
			integral    <= 0;
			correction  <= 0;
		end else begin
			  if (pid_enable) begin
					if (right_present && (dist_right < TWICE_SETPOINT)) begin
						error <= $signed(dist_right) - $signed(RIGHT_SETPOINT);
					end else if (left_present && (dist_left < TWICE_SETPOINT))begin
						error <= $signed(dist_left) - $signed(LEFT_SETPOINT);
					end

					if ((integral + error) > 32'sd200000)
						 integral <= 32'sd200000;
					else if ((integral + error) < -32'sd200000)
						 integral <= -32'sd200000;
					else
						 integral <= integral + error;

					derivative <= error - prev_error;
					prev_error <= error;

					correction <= (KP * error) +
									  (KI * integral) +
									  (KD * derivative);
			  end
			  else begin
					error       <= 0;
					prev_error  <= 0;
					derivative  <= 0;
					integral    <= 0;
					correction  <= 0;
			  end
		  end
    end

    reg signed [15:0] corr_limited;

always @(*) begin
    corr_limited = 0;
    if (correction > 32'sd5 || correction < -32'sd5) begin
        if (correction > 32'sd80)
            corr_limited = 16'sd80;
        else if (correction < -32'sd80)
            corr_limited = -16'sd80;
        else
            corr_limited = correction;
    end
end


    // SPEED CONTROL
    reg signed [9:0] duty_l_s;
    reg signed [9:0] duty_r_s;

always @(*) begin
    duty_l_s = BASE_DUTY_l;
    duty_r_s = BASE_DUTY_r;
	 
	 if (!rst)begin
		cnt <=0;
		cnt_1 <=0;
	 end
	 else begin	
		 if (pid_enable) begin
				if (right_present && (dist_right < TWICE_SETPOINT))begin
					cnt <= cnt +1;
					if (cnt >= 25_000_000)begin
						if (corr_limited > 0)
								duty_r_s = BASE_DUTY_r - corr_limited;
						else if (corr_limited < 0)
								duty_l_s = BASE_DUTY_l + corr_limited;
					end
					else if (!right_present)begin
						cnt <=0;
					end
				end else if(left_present && (dist_left < TWICE_SETPOINT)) begin
						cnt_1 <= cnt_1 +1;
						 if (cnt_1 >= 25_000_000)begin
							  if (corr_limited > 0)
									duty_r_s = BASE_DUTY_r + corr_limited;
							  else if (corr_limited < 0)
									duty_l_s = BASE_DUTY_l - corr_limited;
						 end else if (!left_present)begin
							cnt_1 <=0;
						end			
				end
		 end
	end
end

    wire [7:0] duty_left = 
		  (duty_l_s < 0) ? 0:
        (duty_l_s > 255) ? 8'd255 :
                           duty_l_s[7:0];

    wire [7:0] duty_right =
	     (duty_r_s < 0) ? 0:
        (duty_r_s > 255) ? 8'd255 :
                           duty_r_s[7:0];

    // PWM OUTPUTS
    assign en_a = (pid_enable)?(pwm_cnt < duty_right):(pwm_cnt < BASE_DUTY_l);
    assign en_b = (pid_enable)?(pwm_cnt < duty_left):(pwm_cnt < BASE_DUTY_r);
	 
endmodule