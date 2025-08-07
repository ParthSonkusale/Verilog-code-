

module tb_pwm_generator;
  reg clk_1MHz;
  reg [3:0] pulse_width;
  wire clk_500Hz;
  wire pwm_signal;
  pwm_generator uut (.clk_1MHz(clk_1MHz),.pulse_width(pulse_width),.clk_500Hz(clk_500Hz),.pwm_signal(pwm_signal));
  
  initial begin
    clk_1MHz = 0;
    forever #500 clk_1MHz = ~clk_1MHz; 
  end


  initial begin
    
    $dumpfile("pwm_generator_tb.vcd");
    $dumpvars(0, tb_pwm_generator);

    pulse_width = 4'd0;
   #2000;
    pulse_width = 4'd2; 
    #50000;
 pulse_width = 4'd8; 
    #50000;
pulse_width = 4'd14; 
    #50000;

    pulse_width = 4'd15;
    #50000;

    pulse_width = 4'd0;
    #50000;

   
  end

endmodule