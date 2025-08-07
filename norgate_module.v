module NOR_GATE(a,b,y);
  input a,b;
  output reg y;
  
  always@(a or b)
    
    begin
      if(a==0 && b==0) begin
        y=1;
      end
      else begin
        y=0;
      end
    end
endmodule