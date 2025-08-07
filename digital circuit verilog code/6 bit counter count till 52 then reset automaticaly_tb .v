module test;
  reg clk;
  wire [5:0] count;
  counter_6bit BC(.clk(clk), .count(count));
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,test);
    
    clk=0;
   
  end
endmodule