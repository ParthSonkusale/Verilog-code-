module Full_sub(A,B,C,D,Bo);
  input A,B,C;
  output reg D,Bo;
  
  always@(A or B or C)
  begin
    D=A^B^C;
    Bo=(B&C)+(~A&C)+(~A&B);
  end 
endmodule