module Half_Adder(x,y,c,s);
  
  input x,y;
  output c,s;
  reg c,s;
  
  always@(x or y)
    
    begin
      if(x==1 && y==1) begin
      c=1;
  s=0;
      end
      else if(x==0 && y==0) begin
    c=0;
  s=0;
      end
      else begin
        c=0;
      s=1;
      end
      
  end
  
endmodule