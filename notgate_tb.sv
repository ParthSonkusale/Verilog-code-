module test;
  reg a;
  wire y;
  
  NOT_GATE NG(.a(a),.y(y));
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, test);
    a=0; #10;
    a=1; #10;
  end 
endmodule