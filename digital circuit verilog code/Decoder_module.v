module DE_CODER(a,b,q1,q2,q3,q4);
  input a,b;
  output reg q1,q2,q3,q4;
  always@(a or b or q1 or q2 or q3 or q4)
    begin
      if(a==0 && b==0) begin
        q1=1; q2=0; q3=0; q4=0;
      end
      else if(a==0 && b==1) begin
        q1=0; q2=0; q3=0; q4=0;
      end
      else if(a==1 && b==0) begin
        q1=0; q2=0; q3=1; q4=0;
      end
      else begin
        q1=0; q2=0; q3=0; q4=1;
      end
    end
      endmodule