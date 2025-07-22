module test;
  reg F,s1,s2;
  wire a,b,c,d;
  
  DE_MUX DM(.F(F),.s1(s1),.s2(s2),.a(a),.b(b),.c(c),.d(d));
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,test);
    
    s1=0; s2=0; F=1; #10;
    s1=0; s2=1; F=1; #10;
    s1=1; s2=0; F=1; #10;
    s1=1; s2=1; F=1; #10;
  end 
endmodule 