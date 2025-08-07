module XOR_GATE(a,b,y);
  input a,b;
  output reg y;
  
  always@(a or b)
    begin 
      if(a==0 && b==0) begin
        y=0;
      end
      else if(a==1 && b==1)begin
        y=0;
      end
      else begin
        y=1;
      end
    end
endmodule