module servo_controller(
    input  wire clk_50MHz,
    input  wire rst_n,
    input  wire op_left,
    input  wire ir_mid,
    input  wire op_right,
	 input  wire op_mid,
    output reg  servo_pwm,
	 output reg  env_ind,
    output reg env_en,
	 output reg [3:0] servo_mov
//	 output reg [3:0] x
);

// PWM PARAMETERS (3.125 MHz)
localparam PWM_PERIOD = 20'd1_000_000;   // 20 ms

localparam POS_ZERO   = 20'd110_600;    // ~0°
reg [30:0] POS_CENTER = 30'd68_000;    // ~90°

localparam STEP       = 20'd1600;      // motion smoothness

// PWM COUNTER

reg [20:0] pwm_cnt;
reg [30:0] delay_cnt;
reg [15:0] env_cnt;

always @(posedge clk_50MHz or negedge rst_n) begin
    if (!rst_n)
        pwm_cnt <= 0;
    else if (pwm_cnt == PWM_PERIOD - 1)
        pwm_cnt <= 0;
    else
        pwm_cnt <= pwm_cnt + 1;
end

localparam IDLE    = 3'd0,
           DOWN    = 3'd1,
           WAIT    = 3'd2,
           UP      = 3'd3,
			  MOVE_UT = 3'd4,
			  WAIT1   = 3'd5;

reg [2:0] state;
reg [24:0] servo_pos;

always @(posedge clk_50MHz or negedge rst_n) begin
    if (!rst_n) begin
        state     <= IDLE;
        servo_pos <= POS_CENTER;   // power-up reset
        delay_cnt <= 0;
		  servo_mov <= 0;
        env_en    <= 1'b0;
		  env_ind <= 0;
//		  x <= 0;
    end else begin
        case (state)

        IDLE: begin
            servo_pos <= POS_CENTER;
            delay_cnt <= 0;
				servo_mov <= 0;
            env_en    <= 1'b0;
				env_ind <= 0;
            if (op_left && op_mid && op_right)begin
				  if(!ir_mid) begin
							env_ind <= 1;
							state <= DOWN;
				  end		
				end
        end

        // 90° → 0° smoothly
        DOWN: begin
            if (pwm_cnt == PWM_PERIOD - 1) begin
                if (servo_pos < POS_ZERO)
                    servo_pos <= servo_pos + STEP;
                else
                    state <= WAIT;
            end
        end

        WAIT: begin
					if (delay_cnt == 28'd50_000_000) begin
						env_en <= 1'b1;
						delay_cnt <= 0;
						state <= UP;
					end else begin
						delay_cnt <= delay_cnt + 1;
						env_en <= 1'b0;
					end
        end

        // 0° → 90° smoothly
        UP: begin
            env_en <= 1'b0;
            if (pwm_cnt == PWM_PERIOD - 1) begin
                if (servo_pos > POS_CENTER)
                    servo_pos <= servo_pos - STEP;
                else
                    state <= MOVE_UT;
            end
        end
		  
		  MOVE_UT : begin
		     servo_mov <= 4'b0100;
   		  state <= WAIT1;    	  
		  end
		  
		   WAIT1:begin
				env_ind <= 0;
				if(delay_cnt == 28'd100_000_000)begin
					env_ind <= 0;
					delay_cnt <= 0;					
					state <= IDLE;
				end else begin
					delay_cnt <= delay_cnt + 1;
					servo_mov <= 0;
					env_ind <= 0;
				end
			end

        endcase
    end
end

// PWM OUTPUT
always @(posedge clk_50MHz or negedge rst_n) begin
    if (!rst_n)
        servo_pwm <= 1'b0;
    else
        servo_pwm <= (pwm_cnt < servo_pos);
end

endmodule