module test;
  reg A,B;
  wire D,Bo;
  
  Half_sub HS(.A(A),.B(B),.D(D),.Bo(Bo));
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,test);
    A=0; B=0; #10;
    A=0; B=1; #10;
    A=1; B=0; #10;
    A=1; B=1; #10;
  end 
endmodule