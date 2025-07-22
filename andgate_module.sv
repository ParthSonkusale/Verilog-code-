module AND_GATE(a,b,y);
  input a,b;
  output y;
  reg y;
  
  always@(a or b)
    
    begin 
      if(a==1 && b==1) begin
        y=1;
      end
      else begin
        y=0;
      end
    end
endmodule
      