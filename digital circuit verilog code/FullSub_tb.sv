module test;
  reg A,B,C;
  wire D,Bo;
  
  Full_sub FS(.A(A),.B(B),.C(C),.D(D),.Bo(Bo));
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,test);
    A=0; B=0; C=0; #10;
    A=0; B=0; C=1; #10;
    A=0; B=1; C=0; #10;
A=0; B=1; C=1; #10;
    A=1; B=0; C=0; #10;
    A=1; B=0; C=1; #10;
    A=1; B=1; C=0; #10;
    A=1; B=1; C=1; #10;
  end
endmodule