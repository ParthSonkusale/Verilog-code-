module NOT_GATE(a,y);
  input a;
  output reg y;
  
  always@(a)
    
    begin
      if(a==1)begin
        y=0;
      end
      else begin
        y=1;
      end 
    end
endmodule