module frequency_scaler_tb;
  reg clk_50MHz;
  wire clk_1MHz;
  frequency_scaler uut (.clk_50MHz(clk_50MHz),.clk_1MHz(clk_1MHz));

    
    initial begin
        clk_50MHz=0;
        forever #10 clk_50MHz=~clk_50MHz;  
    end
  initial begin
        $dumpfile("frequency_scaler_tb.vcd"); 
        $dumpvars(0, frequency_scaler_tb);
    #2000;
       
    end

endmodule
