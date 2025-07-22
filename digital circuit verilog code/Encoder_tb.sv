module test;
  reg a,b,c,d;
  wire q1,q2;
  
  en_coder EN(.a(a), .b(b), .c(c), .d(d), .q1(q1), .q2(q2));
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, test);
    
    a=1;b=0;c=0;d=0; #10;
    a=0;b=1;c=0;d=0; #10;
    a=0;b=0;c=1;d=0; #10;
    a=0;b=0;c=0;d=1; #10;
    
  end
endmodule