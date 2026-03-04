// Copyright (C) 2020  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and any partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details, at
// https://fpgasoftware.intel.com/eula.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 20.1.0 Build 711 06/05/2020 SJ Lite Edition"
// CREATED		"Fri Jan 30 19:41:16 2026"

module task_4(
	rst,
	clk,
	echo_left,
	echo_mid,
	echo_right,
	enc_a,
	enc_b,
	start_bot,
	env_ind,
	trig_left,
	trig_mid,
	trig_right,
	op_right,
	op_left,
	SYNTHESIZED_WIRE_13,
	left_ir,
	servo_mov,
	right_ir,
	in_1,
	in_2,
	in_3,
	in_4,
	en_a,
	en_b,
	DIST_LEFT,
	DIST_MID,
	DIST_RIGHT,
	x,
	send_end,
	curr_x,
	curr_y,
	send_cord,
	auto_correct0,
	auto_correct1,
	auto_correct,
	rst_enc,
	move_enc
);


input wire	rst;
input wire	clk;
input wire	echo_left;
input wire	echo_mid;
input wire	echo_right;
input wire	enc_a;
input wire	enc_b;
input wire	start_bot;
input wire  env_ind;
input wire left_ir;
input wire right_ir;
input wire rst_enc;
input wire [3:0]servo_mov;
output wire	trig_left;
output wire	trig_mid;
output wire	trig_right;
output wire	in_1;
output wire	in_2;
output wire	in_3;
output wire	in_4;
output wire	en_a;
output wire	en_b;
output wire send_cord;
output wire	[15:0] DIST_LEFT;
output wire	[15:0] DIST_MID;
output wire	[15:0] DIST_RIGHT;
output wire [3:0] x;
output wire send_end;
output wire	op_right;
output wire	op_left;
output wire SYNTHESIZED_WIRE_13;
output wire auto_correct;
output wire auto_correct1;
output wire auto_correct0;
output wire	[3:0] move_enc;

output wire [3:0] curr_x, curr_y;

wire irmid;

wire	[15:0] SYNTHESIZED_WIRE_3;
wire	[15:0] SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_8;
wire	[15:0] SYNTHESIZED_WIRE_9;
wire	[3:0] SYNTHESIZED_WIRE_10;
wire busy_turn;

assign	DIST_LEFT = SYNTHESIZED_WIRE_3;
assign	DIST_MID = SYNTHESIZED_WIRE_9;
assign	DIST_RIGHT = SYNTHESIZED_WIRE_4;


md	b2v_inst1(
	.clk(clk),
	.rst(rst),
	.move(move_enc),
	.in_1(in_1),
	.in_2(in_2),
	.in_3(in_3),
	.in_4(in_4));


pid_wall_following	b2v_inst2(
	.clk(clk),
	.rst(rst),
	.right_present(op_right),
	.left_present(op_left),
	.dist_left(SYNTHESIZED_WIRE_3),
	.dist_right(SYNTHESIZED_WIRE_4),
	.busy(busy_turn),
	.en_a(en_a),
	.en_b(en_b));


t2c_maze_explorer	b2v_inst3(
	.clk(clk),
	.rst_n(rst),
	.mid(SYNTHESIZED_WIRE_13),
	.left(op_left),
	.right(op_right),
	.left_ir(left_ir),
	.right_ir(right_ir),
	.start_bot(start_bot),
	.busy(SYNTHESIZED_WIRE_8),
	.env_ind(env_ind),
	.dist_mid(SYNTHESIZED_WIRE_9),
	.dist_left(SYNTHESIZED_WIRE_3),
	.dist_right(SYNTHESIZED_WIRE_4),
	.send_end(send_end),
	.servo_mov(servo_mov),
	.move(SYNTHESIZED_WIRE_10),
	.curr_x(curr_x),
	.curr_y(curr_y),
	.send_cord(send_cord),
	.auto_correct(auto_correct),
	.auto_correct0(auto_correct0),
	.auto_correct1(auto_correct1));


ultrasonic_main	b2v_inst4(
	.clk_50M(clk),
	.reset_n(rst),
	.echo_left(echo_left),
	.echo_mid(echo_mid),
	.echo_right(echo_right),
	.trig_left(trig_left),
	.trig_mid(trig_mid),
	.trig_right(trig_right),
	.op_mid(SYNTHESIZED_WIRE_13),
	.op_left(op_left),
	.op_right(op_right),
	.dist_left(SYNTHESIZED_WIRE_3),
	.dist_mid(SYNTHESIZED_WIRE_9),
	.dist_right(SYNTHESIZED_WIRE_4));


encoders	b2v_inst5(
	.clk(clk),
	.rst_n(rst),
	.enc_a(enc_a),
	.enc_b(enc_b),
	.move_ip(SYNTHESIZED_WIRE_10),
	.busy_turn(busy_turn),
	.move_op(move_enc),
	.busy(SYNTHESIZED_WIRE_8),
	.x(x)
	);



endmodule
