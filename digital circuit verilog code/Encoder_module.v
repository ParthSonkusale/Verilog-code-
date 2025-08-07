module en_coder(a,b,c,d,q1,q2);
  input a,b,c,d;
  output reg q1,q2;
  
  always@(a or b or c or d)
    begin
      if(a==1 && b==0 && c==0 && d==0) begin
        q1=0;
        q2=0;
      end 
      else if(a==0 && b==1 && c==0 && d==0) begin
        q1=0;
        q2=1;
      end 
      else if(a==0 && b==0 && c==1 && d==0) begin
        q1=1;
        q2=0;
      end
      else begin
        q1=1;
        q2=1;
      end
    end
endmodule
