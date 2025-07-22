module test;
  reg a,b,c,d,s1,s2;
  wire F;
  
  MULTI_PLEXER MUX(.a(a),.b(b),.c(c),.d(d),.s1(s1),.s2(s2),.F(F));
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,test);
    
      a=1;
      b=0;
      c=0;
      d=0;
    s1=0;
    s2=0; #10;
    
    a=0;
        b=1;
        c=0;
        d=0;
    s1=0;
    s2=1; #10;
    
      a=0;
        b=0;
        c=1;
        d=0;
   s1=1;
    s2=0; #10;
    
     a=0;
        b=0;
        c=0;
        d=1;
    s1=1;
    s2=1; #10;
    
  end
endmodule
    