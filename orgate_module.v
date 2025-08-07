module OR_GATE(a,b,y);
  input a,b;
  output y;
  reg y;
  
  always@(a or b)
    
    begin
      if(a==0 && b==0) begin
      y=0;
    end
  else begin
    y=1;
  end
  end
endmodule
