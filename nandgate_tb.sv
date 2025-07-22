module test;
  reg a,b;
  wire y;
  
  NAND_GATE NG(.a(a),.b(b),.y(y));
  
  initial begin
    
    $dumpfile("dump.vcd");
    $dumpvars(0, test);
    
    a=0;b=0; #10;
    a=1;b=0; #10;
    a=0;b=1; #10;
    a=1;b=1; #10;
  end 
endmodule