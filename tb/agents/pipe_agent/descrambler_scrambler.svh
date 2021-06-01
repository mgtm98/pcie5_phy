

typedef struct
{
  bit [15:0] lfsr_1_2 [`NUM_OF_LANES];
  bit [22:0] lfsr_gen_3 [`NUM_OF_LANES];
} scrambler_s;


function void reset_lfsr (ref scrambler_s scrambler, gen_t current_gen);
  integer j,i;
  if (current_gen == GEN1 || current_gen == GEN2) begin
    foreach(scrambler.lfsr_1_2[i]) begin
      scrambler.lfsr_1_2[i] = 16'hFFFF;
    end
  end
  else if (current_gen == GEN3 || current_gen == GEN4 || current_gen == GEN5) begin
    foreach(scrambler.lfsr_gen_3[i]) begin
      j=i;
      if (i>7) begin
        j=j-8;
      end
      case (j)
        0 : scrambler.lfsr_gen_3[i] = 'h1DBFBC;
        1 : scrambler.lfsr_gen_3[i] = 'h0607BB;
        2 : scrambler.lfsr_gen_3[i] = 'h1EC760;
        3 : scrambler.lfsr_gen_3[i] = 'h18C0DB;
        4 : scrambler.lfsr_gen_3[i] = 'h010F12;
        5 : scrambler.lfsr_gen_3[i] = 'h19CFC9;
        6 : scrambler.lfsr_gen_3[i] = 'h0277CE;
        7 : scrambler.lfsr_gen_3[i] = 'h1BB807;
      endcase
    end
  end
endfunction

function bit [7:0] scramble(ref scrambler_s scrambler, bit [7:0] in_data, shortint unsigned lane_num, gen_t current_gen);
	if (current_gen == GEN1 || current_gen == GEN2)
		return scramble_gen_1_2 (scrambler, in_data,  lane_num);
	else if (current_gen == GEN3 || current_gen == GEN4 || current_gen == GEN5) 
		return scramble_gen_3_4_5 (scrambler, in_data, lane_num);
endfunction

function bit [7:0] descramble(ref scrambler_s scrambler, bit [7:0] in_data, shortint unsigned lane_num, gen_t current_gen);
  if (current_gen == GEN1 || current_gen == GEN2)
    return scramble_gen_1_2 (scrambler, in_data,  lane_num);
  else if (current_gen == GEN3 || current_gen == GEN4 || current_gen == GEN5) 
    return scramble_gen_3_4_5 (scrambler, in_data, lane_num);
endfunction

function bit [7:0] scramble_gen_1_2 (ref scrambler_s scrambler, bit [7:0] in_data, shortint unsigned lane_num);
  bit [15:0] lfsr_new;
  bit [7:0] scrambled_data;

  // LFSR value after 8 serial clocks
  for (int i = 0; i < 8; i++)
  begin
    lfsr_new[ 0] = scrambler.lfsr_1_2 [lane_num] [15];
    lfsr_new[ 1] = scrambler.lfsr_1_2 [lane_num] [ 0];
    lfsr_new[ 2] = scrambler.lfsr_1_2 [lane_num] [ 1];
    lfsr_new[ 3] = scrambler.lfsr_1_2 [lane_num] [ 2] ^ scrambler.lfsr_1_2 [lane_num] [15];
    lfsr_new[ 4] = scrambler.lfsr_1_2 [lane_num] [ 3] ^ scrambler.lfsr_1_2 [lane_num] [15];
    lfsr_new[ 5] = scrambler.lfsr_1_2 [lane_num] [ 4] ^ scrambler.lfsr_1_2 [lane_num] [15];
    lfsr_new[ 6] = scrambler.lfsr_1_2 [lane_num] [ 5];
    lfsr_new[ 7] = scrambler.lfsr_1_2 [lane_num] [ 6];
    lfsr_new[ 8] = scrambler.lfsr_1_2 [lane_num] [ 7];
    lfsr_new[ 9] = scrambler.lfsr_1_2 [lane_num] [ 8];
    lfsr_new[10] = scrambler.lfsr_1_2 [lane_num] [ 9];
    lfsr_new[11] = scrambler.lfsr_1_2 [lane_num] [10];
    lfsr_new[12] = scrambler.lfsr_1_2 [lane_num] [11];
    lfsr_new[13] = scrambler.lfsr_1_2 [lane_num] [12];
    lfsr_new[14] = scrambler.lfsr_1_2 [lane_num] [13];
    lfsr_new[15] = scrambler.lfsr_1_2 [lane_num] [14];       

    // Generation of Scrambled Data
    scrambled_data [i] = scrambler.lfsr_1_2 [lane_num] [15] ^ in_data [i];
    
    scrambler.lfsr_1_2 [lane_num] = lfsr_new;
  end
  return scrambled_data;
endfunction

function bit [7:0] scramble_gen_3_4_5 (ref scrambler_s scrambler, bit [7:0] unscrambled_data, shortint unsigned lane_num);
  bit [7:0] scrambled_data ;
  scrambled_data = scramble_data_gen_3(scrambler.lfsr_gen_3[lane_num],unscrambled_data);
  scrambler.lfsr_gen_3[lane_num] = advance_lfsr_gen_3(scrambler.lfsr_gen_3[lane_num]);
  return scrambled_data;
endfunction

// Function to advance the LFSR value by 8 bits, given the current LFSR value
function int advance_lfsr_gen_3(int lfsr);
  automatic int next_lfsr = 0;
  `SB(next_lfsr,22, `GB(lfsr,14) ^ `GB(lfsr,16) ^ `GB(lfsr,18) ^ `GB(lfsr,20) ^ `GB(lfsr,21) ^ `GB(lfsr,22));
  `SB(next_lfsr,21, `GB(lfsr,13) ^ `GB(lfsr,15) ^ `GB(lfsr,17) ^ `GB(lfsr,19) ^ `GB(lfsr,20) ^ `GB(lfsr,21));
  `SB(next_lfsr,20, `GB(lfsr,12) ^ `GB(lfsr,19) ^ `GB(lfsr,21));
  `SB(next_lfsr,19, `GB(lfsr,11) ^ `GB(lfsr,18) ^ `GB(lfsr,20) ^ `GB(lfsr,22));
  `SB(next_lfsr,18, `GB(lfsr,10) ^ `GB(lfsr,17) ^ `GB(lfsr,19) ^ `GB(lfsr,21));
  `SB(next_lfsr,17, `GB(lfsr, 9) ^ `GB(lfsr,16) ^ `GB(lfsr,18) ^ `GB(lfsr,20) ^ `GB(lfsr,22));
  `SB(next_lfsr,16, `GB(lfsr, 8) ^ `GB(lfsr,15) ^ `GB(lfsr,17) ^ `GB(lfsr,19) ^ `GB(lfsr,21) ^ `GB(lfsr,22));
  `SB(next_lfsr,15, `GB(lfsr, 7) ^ `GB(lfsr,22));
  `SB(next_lfsr,14, `GB(lfsr, 6) ^ `GB(lfsr,21));
  `SB(next_lfsr,13, `GB(lfsr, 5) ^ `GB(lfsr,20) ^ `GB(lfsr,22));
  `SB(next_lfsr,12, `GB(lfsr, 4) ^ `GB(lfsr,19) ^ `GB(lfsr,21) ^ `GB(lfsr,22));
  `SB(next_lfsr,11, `GB(lfsr, 3) ^ `GB(lfsr,18) ^ `GB(lfsr,20) ^ `GB(lfsr,21) ^ `GB(lfsr,22));
  `SB(next_lfsr,10, `GB(lfsr, 2) ^ `GB(lfsr,17) ^ `GB(lfsr,19) ^ `GB(lfsr,20) ^ `GB(lfsr,21) ^ `GB(lfsr,22));
  `SB(next_lfsr, 9, `GB(lfsr, 1) ^ `GB(lfsr,16) ^ `GB(lfsr,18) ^ `GB(lfsr,19) ^ `GB(lfsr,20) ^ `GB(lfsr,21));
  `SB(next_lfsr, 8, `GB(lfsr, 0) ^ `GB(lfsr,15) ^ `GB(lfsr,17) ^ `GB(lfsr,18) ^ `GB(lfsr,19) ^ `GB(lfsr,20));
  `SB(next_lfsr, 7, `GB(lfsr,17) ^ `GB(lfsr,19) ^ `GB(lfsr,20) ^ `GB(lfsr,21));
  `SB(next_lfsr, 6, `GB(lfsr,16) ^ `GB(lfsr,18) ^ `GB(lfsr,19) ^ `GB(lfsr,20) ^ `GB(lfsr,22));
  `SB(next_lfsr, 5, `GB(lfsr,15) ^ `GB(lfsr,17) ^ `GB(lfsr,18) ^ `GB(lfsr,19) ^ `GB(lfsr,21) ^ `GB(lfsr,22));
  `SB(next_lfsr, 4, `GB(lfsr,17));
  `SB(next_lfsr, 3, `GB(lfsr,16));
  `SB(next_lfsr, 2, `GB(lfsr,15) ^ `GB(lfsr,22));
  `SB(next_lfsr, 1, `GB(lfsr,16) ^ `GB(lfsr,18) ^ `GB(lfsr,20) ^ `GB(lfsr,22));
  `SB(next_lfsr, 0, `GB(lfsr,15) ^ `GB(lfsr,17) ^ `GB(lfsr,19) ^ `GB(lfsr,21) ^ `GB(lfsr,22));
  return next_lfsr;
endfunction

// Function to scramble a byte, given the current LFSR value
function bit [7:0] scramble_data_gen_3(int lfsr, bit [7:0] data_in) ;
  automatic bit [7:0] data_out = 0; //leh static "compilation"
  `SB(data_out, 7, `GB(data_in,7) ^ `GB(lfsr,15) ^ `GB(lfsr,17) ^ `GB(lfsr,19) ^ `GB(lfsr,21) ^ `GB(lfsr,22));
  `SB(data_out, 6, `GB(data_in,6) ^ `GB(lfsr,16) ^ `GB(lfsr,18) ^ `GB(lfsr,20) ^ `GB(lfsr,22));
  `SB(data_out, 5, `GB(data_in,5) ^ `GB(lfsr,17) ^ `GB(lfsr,19) ^ `GB(lfsr,21));
  `SB(data_out, 4, `GB(data_in,4) ^ `GB(lfsr,18) ^ `GB(lfsr,20) ^ `GB(lfsr,22));
  `SB(data_out, 3, `GB(data_in,3) ^ `GB(lfsr,19) ^ `GB(lfsr,21));
  `SB(data_out, 2, `GB(data_in,2) ^ `GB(lfsr,20) ^ `GB(lfsr,22));
  `SB(data_out, 1, `GB(data_in,1) ^ `GB(lfsr,21));
  `SB(data_out, 0, `GB(data_in,0) ^ `GB(lfsr,22));
  return data_out;
endfunction

