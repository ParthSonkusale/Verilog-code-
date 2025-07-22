module RCA_4bit(A0,A1,A2,A3,B0,B1,B2,B3,S0,S1,S2,S3,Cin,Cout);
  input A0,A1,A2,A3,B0,B1,B2,B3,Cin;
  output reg S0,S1,S2,S3,Cout;
  reg C0,C1,C2;

  always@(A0 or A1 or A2 or A3 or B0 or B1 or B2 or B3 or Cin)
    begin
     {C0,S0}=A0+B0+Cin;
   {C1,S1}=A1+B1+C0;
    {C2,S2}=A2+B2+C1;
      {Cout,S3}=A3+B3+C2;
            end
              endmodule
        