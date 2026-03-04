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
// CREATED		"Fri Jan 30 19:05:22 2026"

module task_5a(
	rx,
	clk,
	rst,
	ir_mid,
	op_left,
	op_right,
	op_mid,
	dout,
	tx,
	servo1,
	servo_mov,
	adc_cs_n,
	din,
	adc_sck,
	start_bot,
	env_ind,
	dht_out,
	xwire,
	start_end,
	curr_x,
	curr_y,
	send_cord
);


input wire	rx;
input wire	clk;
input wire	rst;
input wire	ir_mid;
input wire	dout;
input wire  [3:0] xwire;
input wire start_end,send_cord;
input wire op_left;
input wire op_right;
input wire op_mid;
input wire [3:0] curr_x,curr_y;
output wire	tx;
output wire	servo1;
output wire	adc_cs_n;
output wire	din;
output wire	adc_sck;
output wire	start_bot;
output wire env_ind;
output wire [3:0]servo_mov;
inout wire	dht_out;

wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_3;
wire	[7:0] SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_7;
wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_9;
wire	[7:0] SYNTHESIZED_WIRE_10;
wire	[7:0] SYNTHESIZED_WIRE_11;
wire	[7:0] SYNTHESIZED_WIRE_12;
wire	[7:0] SYNTHESIZED_WIRE_13;
wire tx_enable;




uart_rx	b2v_inst(
	.clk_50(clk),
	.rx(rx),
	.rst(rst),
	.rx_complete(SYNTHESIZED_WIRE_9),
	.rx_msg(SYNTHESIZED_WIRE_12));


uart_tx	b2v_inst1(
	.clk_50(clk),
	.rst(rst),
	.parity_type(SYNTHESIZED_WIRE_2),
	.tx_start(tx_enable),
	.data_received(SYNTHESIZED_WIRE_4),
	.tx(tx),
	.tx_done(SYNTHESIZED_WIRE_7));

moisture_sensor	b2v_inst3(
	.dout(dout),
	.clk50(clk),
	.adc_cs_n(adc_cs_n),
	.din(din),
	.adc_sck(adc_sck),
	.mois(SYNTHESIZED_WIRE_11));

servo_controller	b2v_inst4(
	.clk_50MHz(clk),
	.rst_n(rst),
	.op_left(op_left),
	.ir_mid(ir_mid),
	.op_right(op_right),
	.op_mid(op_mid),
	.servo_pwm(servo1),
	.env_ind(env_ind),
	.servo_mov(servo_mov),
	.env_en(SYNTHESIZED_WIRE_3));


data_packet	b2v_inst5(
	.clk(clk),
	.rst_n(rst),
	.tx_done(SYNTHESIZED_WIRE_7),
	.rx_complete(SYNTHESIZED_WIRE_9),
	.humi(SYNTHESIZED_WIRE_10),
	.mois(SYNTHESIZED_WIRE_11),
	.rx_msg(SYNTHESIZED_WIRE_12),
	.temp(SYNTHESIZED_WIRE_13),
	.parity_type(SYNTHESIZED_WIRE_2),
	.tx_data(SYNTHESIZED_WIRE_4),
	.start_cmd_detected(start_bot),
	.start_end(start_end),
	.env_en(SYNTHESIZED_WIRE_3),
	.tx_start(tx_enable),
	.x(xwire),
	.curr_x(curr_x),
	.curr_y(curr_y),
	.send_cord(send_cord));


t2a_dht	b2v_inst6(
	.clk_50M(clk),
	.rst_n(rst),
	.sensor(dht_out),
	.RH_integral(SYNTHESIZED_WIRE_10),
	.T_integral(SYNTHESIZED_WIRE_13));

endmodule
