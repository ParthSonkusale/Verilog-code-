module test;
  reg x,y;
  wire s,c;
  
  Half_Adder FA(.x(x), .y(y), .s(s), .c(c));
  
  initial begin
   $dumpfile("dump.vcd");
    $dumpvars(0, test);
    
 x=1;y=1; 
 x=0;y=0;
 x=1;y=0;
  
    x=0;y=1;
   
   
   
  end
 
endmodule