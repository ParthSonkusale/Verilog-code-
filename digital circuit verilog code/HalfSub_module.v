module Half_sub(A,B,D,Bo);
  input A,B;
  output reg D,Bo;
  
  always@(A or B)
  begin
   D=A^B;
    Bo=~A&B;
  end
endmodule
      