module test;
  reg a,b;
  wire q1,q2,q3,q4;
  
  DE_CODER DC(.a(a),.b(b),.q1(q1),.q2(q2),.q3(q3),.q4(q4));
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, test);
    
    a=0; b=0; #10;
    a=0; b=1; #10;
    a=1; b=0; #10;
    a=1; b=1; #10;
  end 
endmodule