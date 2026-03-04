module t2c_maze_explorer (
    input clk,
    input rst_n,
    input mid, left, right,left_ir,right_ir,
    input [15:0] dist_mid,dist_left,dist_right,
    input start_bot,
    input busy,
	 input env_ind,
	 input [3:0] servo_mov,
    output reg [3:0] move,
	 output wire send_end,
	 output reg send_cord,
	 output reg [3:0] curr_x, curr_y,
	 output wire auto_correct,
	 output wire auto_correct1,
	 output wire auto_correct0
);

localparam STOP    = 4'b0000,
           FORWARD = 4'b0001,
           LEFT  = 4'b0010,
           RIGHT = 4'b0011,
           U_TURN  = 4'b0100,
			  REVERSE_L = 4'b1000,
			  REVERSE_R = 4'b0110,
			  REVERSE = 4'b0111,
			  REVERSE_R_NO_FWD = 4'b1001;

localparam COLLIDE_DIST = 16'd600;
localparam SAFE_DIST = 16'd6;
//localparam NO_FLAG_DIST = 16'd59;
localparam IDLE = 3'd0,
           SENSE = 3'd1,
           WAIT  = 3'd2,
			  AUTO_CORRECT = 3'd4,
			  UPDATE_COORDINATES = 3'd3;
			  
			  
reg [3:0]deadend_cnt; 
//localparam VALID_MOVE = 28'd2_000_000;

////reg [20:0] HS_THRESH = 21'd70;
//reg [27:0] cnt;
reg [2:0] state;
//reg [1:0] dir;
//reg [1:0] visited [0:8][0:8];
//reg [3:0] next_left_x, next_left_y;
//reg [3:0] next_mid_x, next_mid_y;
//reg [3:0] next_right_x, next_right_y;
//reg goal_reached;
//reg all_visited;
//reg mov_success;
//reg unvisited[0:8][0:8];
//integer i, j;
//wire junction = ((!left + !mid + !right) > 1);
assign send_end = (!left && !mid && !right)?1:0;
//reg mrk_un;
//
reg [27:0] DELAY = 28'd10_000_000;
reg [27:0] delay_cnt;
reg lfr_on;

assign auto_correct0  = ((!left_ir)|| (dist_mid >= COLLIDE_DIST) || (!right_ir)) ? 1:0;
assign auto_correct1  = ((deadend_cnt != 1 && deadend_cnt != 6 && deadend_cnt != 7) && (!left && !mid && !right)) ? 1:0;
assign auto_correct   = auto_correct0;
 wire auto_correct_fin;
assign auto_correct_fin = ((deadend_cnt < 4'd9) &&(auto_correct0 || auto_correct1))?1:0;

//initial begin
//    curr_x <= 4;
//    curr_y <= 8;
//    dir <= 2'b00;
//    goal_reached <= 0;
//    all_visited <= 0;
//    mrk_un <= 0;
//    for (i = 0; i < 9; i = i + 1) begin
//            for (j = 0; j < 9; j = j + 1)
//                visited[i][j] = 0;
//    end
//end



//////////////// Tremaux //////////////////

//task next_move;
//if (!left && visited[next_left_x][next_left_y] == 0 && (next_left_x>=0 && next_left_y>=0 && next_left_x<9 && next_left_y<9)) begin
//    move <= LEFT;
//    dir  <= (dir == 2'b00) ? 2'b11 : dir - 1;
//    $display("%0d, %0d ", curr_x, curr_y);
//    $display("took unexplored left");
//end
//else if (!mid && visited[next_mid_x][next_mid_y] == 0 && (next_mid_x>=0 && next_mid_y>=0 && next_mid_x<9 && next_mid_y<9)) begin
//    move <= FORWARD;
//    $display("took unexplored forward");
//end
//else if (!right && visited[next_right_x][next_right_y] == 0 && (next_right_x>=0 && next_right_y>=0 && next_right_x<9 && next_right_y<9)) begin
//    move <= RIGHT;
//    dir  <= (dir == 2'b11) ? 2'b00 : dir + 1;
//    $display("took unexplored right");
//end
//else if (!left && visited[next_left_x][next_left_y] == 1 && (next_left_x>=0 && next_left_y>=0 && next_left_x<9 && next_left_y<9)) begin
//    move <= LEFT;
//    dir  <= (dir == 2'b00) ? 2'b11 : dir - 1;
//    $display("took explored left");
//end
//else if (!mid && visited[next_mid_x][next_mid_y] == 1 && (next_mid_x>=0 && next_mid_y>=0 && next_mid_x<9 && next_mid_y<9)) begin
//    move <= FORWARD;
//    $display("took explored forward");
//end
//else if (!right && visited[next_right_x][next_right_y] == 1 && (next_right_x>=0 && next_right_y>=0 && next_right_x<9 && next_right_y<9)) begin
//    move <= RIGHT;
//    dir  <= (dir == 2'b11) ? 2'b00 : dir + 1;
//    $display("took explored right");
//end
//else begin
//    move <= U_TURN;
//    dir  <= dir + 2'd2;
//    visited[curr_x][curr_y] <= 2;
//    $display("Backtracking to (%0d,%0d)", curr_x, curr_y);
//end
//endtask
//////////////////////////////////////////////////////

//task check_all_visited;
//    // integer a, b;
//    begin
//        all_visited = 1;
//        for (i = 0; i < 9; i = i + 1) begin
//            for (j = 0; j < 9; j = j + 1) begin
//                if (visited[i][j] == 0) begin
//                    unvisited[i][j] <= 1;
//                    all_visited = 0;
//                end
//            end
//        end
//    end
//endtask
//
//
//always @(*) begin
//    case (dir)
//        2'b00: begin // North
//            next_left_x  = curr_x - 1;
//            next_left_y  = curr_y;
//            next_mid_x   = curr_x;
//            next_mid_y   = curr_y - 1 ;
//            next_right_x = curr_x + 1;
//            next_right_y = curr_y;
//        end
//        2'b01: begin // East
//            next_left_x  = curr_x;
//            next_left_y  = curr_y - 1;
//            next_mid_x   = curr_x + 1;
//            next_mid_y   = curr_y;
//            next_right_x = curr_x;
//            next_right_y = curr_y + 1;
//        end
//        2'b10: begin // South
//            next_left_x  = curr_x + 1;
//            next_left_y  = curr_y;
//            next_mid_x   = curr_x;
//            next_mid_y   = curr_y + 1;
//            next_right_x = curr_x - 1;
//            next_right_y = curr_y;
//        end
//        2'b11: begin // West
//            next_left_x  = curr_x;
//            next_left_y  = curr_y + 1;
//            next_mid_x   = curr_x - 1;
//            next_mid_y   = curr_y;
//            next_right_x = curr_x;
//            next_right_y = curr_y - 1;
//        end
//        default: begin
//            next_left_x  = curr_x;
//            next_left_y  = curr_y;
//            next_mid_x   = curr_x;
//            next_mid_y   = curr_y;
//            next_right_x = curr_x;
//            next_right_y = curr_y;
//        end
//    endcase
//end


task move_lfr;
	case({left,mid,right})
		3'b000:move <= STOP;
		3'b001:move <= LEFT;
		3'b010:move <= LEFT;
		3'b011:move <= LEFT;
		3'b100:move <= FORWARD;
		3'b101:move <= FORWARD;
		3'b110:move <= RIGHT;
		3'b111:move <= U_TURN;
	endcase
endtask

task move_frl;
	case({left,mid,right})
		3'b000:move <= LEFT;
		3'b001:move <= FORWARD;
		3'b010:move <= RIGHT;
		3'b011:move <= LEFT;
		3'b100:move <= FORWARD;
		3'b101:move <= FORWARD;
		3'b110:move <= RIGHT;
		3'b111:move <= U_TURN;
	endcase
endtask

task move_rlf;
	case({left,mid,right})
		3'b000:move <= RIGHT;
		3'b001:move <= LEFT;
		3'b010:move <= RIGHT;
		3'b011:move <= LEFT;
		3'b100:move <= RIGHT;
		3'b101:move <= FORWARD;
		3'b110:move <= RIGHT;
		3'b111:move <= U_TURN;
	endcase
endtask

task move_flr;
	case({left,mid,right})
		3'b000:move <= FORWARD;
		3'b001:move <= FORWARD;
		3'b010:move <= LEFT;
		3'b011:move <= LEFT;
		3'b100:move <= FORWARD;
		3'b101:move <= FORWARD;
		3'b110:move <= RIGHT;
		3'b111:move <= U_TURN;
	endcase
endtask

task move_lrf;
	case({left,mid,right})
		3'b000:move <= STOP;
		3'b001:move <= LEFT;
		3'b010:move <= LEFT;
		3'b011:move <= LEFT;
		3'b100:move <= RIGHT;
		3'b101:move <= FORWARD;
		3'b110:move <= RIGHT;
		3'b111:move <= U_TURN;
	endcase
endtask

task move_rfl;
	case({left,mid,right})
		3'b000:move <= STOP;
		3'b001:move <= FORWARD;
		3'b010:move <= RIGHT;
		3'b011:move <= LEFT;
		3'b100:move <= RIGHT;
		3'b101:move <= FORWARD;
		3'b110:move <= RIGHT;
		3'b111:move <= U_TURN;
	endcase
endtask


always@(posedge clk or negedge rst_n)begin
	if (!rst_n)begin
		deadend_cnt<=1;
	end else begin
		if (move == U_TURN)begin
			deadend_cnt <= deadend_cnt+1;
		end else begin
			deadend_cnt <= deadend_cnt;
		end
	end
end

always@(posedge clk or negedge rst_n)begin
	if (!rst_n)begin
		move      <= STOP;
      state     <= IDLE;
		lfr_on    <= 0;
      delay_cnt <= 0;
	end else if (start_bot) begin
		if(env_ind) begin
			move <= servo_mov;					
		end else begin
		case(state)
			IDLE: begin
              move  <= STOP;
            if(auto_correct_fin)begin
					state <= AUTO_CORRECT;
				end else begin
					state <= SENSE;
				end
         end
			
			SENSE:begin
			   if(lfr_on) begin 
		   	   move_lfr();
				   lfr_on <= 0;
				   state <= WAIT;	 
				end else if (deadend_cnt < 4'd1)begin
					move_lfr();
					state <= WAIT;
				end else if (deadend_cnt < 4'd2)begin
					move_frl();
					state <= WAIT;
				end else if (deadend_cnt < 4'd4)begin
					move_rfl();
					state <= WAIT;
				end else if (deadend_cnt < 4'd5)begin
					move_flr();
					state <= WAIT;
				end else if (deadend_cnt < 4'd6)begin
					move_lfr();
					state <= WAIT;
				end else if (deadend_cnt < 4'd7)begin
					move_flr();
					state <= WAIT;
				end else if (deadend_cnt < 4'd8)begin
					move_rlf();
					state <= WAIT;
				end else if (deadend_cnt < 4'd9)begin
					move_lrf();
					state <= WAIT;
				end else if (deadend_cnt >= 4'd9)begin
					move_rfl();
					state <= WAIT;
				end
			end
			
			WAIT: begin		
				 if (!busy) begin
					  if (delay_cnt >= DELAY) begin
							delay_cnt <= 0;
			               state <= IDLE;												
					  end
					  else begin
							delay_cnt <= delay_cnt + 1;
							move <= STOP;
					  end
				 end else begin
					 delay_cnt <= 0;
				 end
			end
			
			AUTO_CORRECT : begin
			      lfr_on <= 1;
				if (!left_ir)begin
					move <= REVERSE_R;
					if (dist_left >= SAFE_DIST )begin
						state <= WAIT; 
					end
				end else if (dist_mid >= COLLIDE_DIST)begin
					move <= REVERSE;
					if (dist_mid >= SAFE_DIST )begin
						state <= WAIT; 
					end
				end else if (!right_ir)begin
					move <= REVERSE_L	;
					if (dist_right >= SAFE_DIST)begin
						state <= WAIT;
					end 	
				end 
				else begin
					move <= REVERSE_R_NO_FWD;
					if (dist_right >= SAFE_DIST )begin
						state <= WAIT;
					end
				end
			end
		endcase
		end
	end else begin
		move <= STOP;		
	end
end

//always@(posedge clk or negedge rst_n)begin
//	if (!rst_n)begin
//		mov_success <=0;
//	end else begin
//		if(busy)begin
//			if (auto_correct)begin
//				mov_success <=0;
//			end else begin
//				mov_success <=1;
//			end
//		end else if (state == UPDATE_COORDINATES)begin
//			mov_success <=0;
//		end
//	end
//end
	
//always @(posedge clk or negedge rst_n) begin
//    if (!rst_n) begin
//        move      <= STOP;
//        state     <= IDLE;
//        delay_cnt <= 0;
//		  send_cord <= 0;
//		  for (i = 0; i < 9; i = i + 1)
//            for (j = 0; j < 9; j = j + 1)
//                visited[i][j] = 0;
//    end
//    else if (start_bot)  begin
//		  send_cord <= 0;
//        case (state)
//
//            IDLE: begin
//                move  <= STOP;
//				 if(env_ind) begin
//							move <= servo_mov;					
//					if (servo_mov == 4'b0100)begin
//						dir  <= dir + 2'd2;
//						state <= WAIT;
//					end
//				 end
//              else if (auto_correct0 || auto_correct1)begin
//						state <= AUTO_CORRECT;
//					end else begin
//						state <= SENSE;
//					end
//            end
//
//            SENSE: begin
//
//                delay_cnt <= 0;
//					if (goal_reached == 1) check_all_visited();
//                if (curr_x == 4 && curr_y == 0) begin
//                    visited[curr_x][curr_y] <= 1;
//                    goal_reached <= 1;
//                    mrk_un <= 1;
//
//                    for (j = 0; j < 9; j = j + 1) begin
//                         for (i = 0; i < 9; i = i + 1) begin
//                             $write("%0d", visited[i] [j]);
//                         end
//                         $display("");
//                    end
//                    if (!all_visited) begin
//                        $display("Goal reached, but maze not fully explored — continuing exploration.");
//							if (!left && visited[next_left_x][next_left_y] == 0 && (next_left_x>=0 && next_left_y>=0 && next_left_x<9 && next_left_y<9)) begin
//								 move <= LEFT;
//								 dir  <= (dir == 2'b00) ? 2'b11 : dir - 1;
//								 $display("%0d, %0d ", curr_x, curr_y);
//								 $display("took unexplored left");
//							end
//							else if (!mid && visited[next_mid_x][next_mid_y] == 0 && (next_mid_x>=0 && next_mid_y>=0 && next_mid_x<9 && next_mid_y<9)) begin
//								 move <= FORWARD;
//								 $display("took unexplored forward");
//							end
//							else if (!right && visited[next_right_x][next_right_y] == 0 && (next_right_x>=0 && next_right_y>=0 && next_right_x<9 && next_right_y<9)) begin
//								 move <= RIGHT;
//								 dir  <= (dir == 2'b11) ? 2'b00 : dir + 1;
//								 $display("took unexplored right");
//							end
//							else if (!left && visited[next_left_x][next_left_y] == 1 && (next_left_x>=0 && next_left_y>=0 && next_left_x<9 && next_left_y<9)) begin
//								 move <= LEFT;
//								 dir  <= (dir == 2'b00) ? 2'b11 : dir - 1;
//								 $display("took explored left");
//							end
//							else if (!mid && visited[next_mid_x][next_mid_y] == 1 && (next_mid_x>=0 && next_mid_y>=0 && next_mid_x<9 && next_mid_y<9)) begin
//								 move <= FORWARD;
//								 $display("took explored forward");
//							end
//							else if (!right && visited[next_right_x][next_right_y] == 1 && (next_right_x>=0 && next_right_y>=0 && next_right_x<9 && next_right_y<9)) begin
//								 move <= RIGHT;
//								 dir  <= (dir == 2'b11) ? 2'b00 : dir + 1;
//								 $display("took explored right");
//							end
//							else begin
//								 move <= U_TURN;
//								 dir  <= dir + 2'd2;
//								 visited[curr_x][curr_y] <= 2;
//								 $display("Backtracking to (%0d,%0d)", curr_x, curr_y);
//							end                        
//							state <= WAIT;
//                    end
//                    else begin
//                        $display("Goal reached and maze fully explored — exiting maze.");
//                        move <= FORWARD;
//                    end
//                end
//                else begin
//                    if (junction) 
//                        visited[curr_x][curr_y] <= 1;
//                    else if (unvisited[curr_x][curr_y] == 1) begin
//                        if (visited[curr_x][curr_y] == 0)
//                            visited[curr_x][curr_y] <=1;
//                        else
//                            visited[curr_x][curr_y] <=2; 
//                    end
//                    else if (!mrk_un)begin
//                        if(visited[curr_x][curr_y] < 2)
//                            visited[curr_x][curr_y] <= visited[curr_x][curr_y] + 1;
//                        else
//                            visited[curr_x][curr_y] <= 2;
//                    end
//                    
//                    if (!left && visited[next_left_x][next_left_y] == 0 && (next_left_x>=0 && next_left_y>=0 && next_left_x<9 && next_left_y<9)) begin
//								 move <= LEFT;
//								 dir  <= (dir == 2'b00) ? 2'b11 : dir - 1;
//								 $display("%0d, %0d ", curr_x, curr_y);
//								 $display("took unexplored left");
//							end
//							else if (!mid && visited[next_mid_x][next_mid_y] == 0 && (next_mid_x>=0 && next_mid_y>=0 && next_mid_x<9 && next_mid_y<9)) begin
//								 move <= FORWARD;
//								 $display("took unexplored forward");
//							end
//							else if (!right && visited[next_right_x][next_right_y] == 0 && (next_right_x>=0 && next_right_y>=0 && next_right_x<9 && next_right_y<9)) begin
//								 move <= RIGHT;
//								 dir  <= (dir == 2'b11) ? 2'b00 : dir + 1;
//								 $display("took unexplored right");
//							end
//							else if (!left && visited[next_left_x][next_left_y] == 1 && (next_left_x>=0 && next_left_y>=0 && next_left_x<9 && next_left_y<9)) begin
//								 move <= LEFT;
//								 dir  <= (dir == 2'b00) ? 2'b11 : dir - 1;
//								 $display("took explored left");
//							end
//							else if (!mid && visited[next_mid_x][next_mid_y] == 1 && (next_mid_x>=0 && next_mid_y>=0 && next_mid_x<9 && next_mid_y<9)) begin
//								 move <= FORWARD;
//								 $display("took explored forward");
//							end
//							else if (!right && visited[next_right_x][next_right_y] == 1 && (next_right_x>=0 && next_right_y>=0 && next_right_x<9 && next_right_y<9)) begin
//								 move <= RIGHT;
//								 dir  <= (dir == 2'b11) ? 2'b00 : dir + 1;
//								 $display("took explored right");
//							end
//							else begin
//								 move <= U_TURN;
//								 dir  <= dir + 2'd2;
//								 visited[curr_x][curr_y] <= 2;
//								 $display("Backtracking to (%0d,%0d)", curr_x, curr_y);
//							end
//                    state <= WAIT;
//                end
//                delay_cnt <= 0;
//            end
//
//            WAIT: begin
//					 if (!busy) begin
//						  if (delay_cnt >= DELAY) begin
//								delay_cnt <= 0;
//								if (mov_success)begin
//									state <= UPDATE_COORDINATES;
//								end
//								else begin
//									state <= IDLE;
//								end
//						  end
//						  else begin
//								delay_cnt <= delay_cnt + 1;
//								move <= STOP;
//						  end
//					 end
//            end
//				
//				
//				
//				UPDATE_COORDINATES: begin
//                case (dir)
//                    2'b00: if (curr_y >=0) curr_y <= curr_y - 1;
//                    2'b01: if (curr_x < 9) curr_x <= curr_x + 1;
//                    2'b10: if (curr_y < 9) curr_y <= curr_y + 1;
//                    2'b11: if (curr_x >=0) curr_x <= curr_x - 1;
//                endcase
//                send_cord <= 1;
//                state <= IDLE;
//            end
//				
//				AUTO_CORRECT : begin
////		          curr_x <= curr_x;
////					 curr_y <= curr_y;
//					if (!left_ir)begin
//						move <= REVERSE;
//						if (dist_left >= SAFE_DIST )begin
//							state <= WAIT; 
//						end
//					end else if (dist_mid >= COLLIDE_DIST)begin
//						move <= REVERSE;
//						if (dist_mid >= SAFE_DIST )begin
//							state <= WAIT; 
//						end
//					end else if (!right_ir)begin
//						move <= REVERSE	;
//						if (dist_right >= SAFE_DIST)begin
//							state <= WAIT;
//						end 	
//					end 
//					else begin
//						move <= REVERSE_R_NO_FWD;
//						if (dist_right >= SAFE_DIST )begin
//							state <= WAIT;
//						end
//					end
//				end
//            default: begin
//                move  <= STOP;
//                state <= IDLE;
//            end
//        endcase		  
//    end  
//	 else begin
//	 
//	 move <= 3'b000;
//	 end
//
//end

endmodule