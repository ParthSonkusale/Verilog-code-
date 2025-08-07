module test;
 reg A0,A1,A2,A3,B0,B1,B2,B3,Cin;
  wire S0,S1,S2,S3,Cout;
  
  RCA_4bit rca(.A0(A0),.A1(A1),.A2(A2),.A3(A3),.B0(B0),.B1(B1),.B2(B2),.B3(B3),.Cin(Cin),.S0(S0),.S1(S1),.S2(S2),.S3(S3),.Cout(Cout));
  initial begin
  $dumpfile("dump.vcd");
  $dumpvars(0,test);
  //this is for add of 1111 and 0000
  {A0,A1,A2,A3}=4'b1111;
  {B0,B1,B2,B3}=4'b0000;
    Cin=1'b0; #10;
  end
endmodule