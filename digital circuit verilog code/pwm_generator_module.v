module pwm_generator(
    input clk_1MHz,
    input [3:0] pulse_width,
    output reg clk_500Hz, pwm_signal
);

initial begin
    clk_500Hz = 1; pwm_signal = 1;
end



reg [10:0] count=11'd0;
reg [10:0] pwm_count = 11'd0;
parameter full_cycle = 11'd1999; 
parameter half_cycle=11'd999;
reg toggle_next = 1'b0;



wire [10:0] scaled_pulse_width;
assign scaled_pulse_width=pulse_width*11'd100;

always @(posedge clk_1MHz) begin

  if (count==half_cycle) begin
  toggle_next <= 1'b1;
        
        count<=11'd0;
    end else begin
        count<=count+11'd1;
    end
	 if (toggle_next) begin
       clk_500Hz<=~clk_500Hz;  
        toggle_next <= 1'b0;        
    end
	 
	   if (pwm_count == full_cycle) begin
        pwm_count <= 11'd0;
		  
    end else begin
        pwm_count <= pwm_count + 11'd1;
    end
	 

   if (pwm_count < scaled_pulse_width) begin
        pwm_signal <= 1;
    end else begin
        pwm_signal <= 0;
    end
end








endmodule