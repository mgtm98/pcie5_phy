function automatic int pipe_speed_change_without_equalization_seq::calc_gen(input logic[1:0] width, input logic[2:0] PCLKRate );
    

    real PCLkRate_value;
    case(PCLKRate)
        3'b000:PCLKRate_value=0.0625;
        3'b001:PCLKRate_value=0.125;
        3'b010:PCLKRate_value=0.25;
        3'b011:PCLKRate_value=0.5;
        3'b100:PCLKRate_value=1;
    endcase

    real width_value;
    case(width)
        2'b00:width_value=8;
        2'b01:width_value=16;
        2'b10:width_value=32;
    endcase
    real freq;
    freq=PCLKRate_value*width_value;
    int gen;
    case(freq)
        2:gen=1;
        4:gen=2;
        8:gen=3;
        16:gen=4;
        32:gen=5;
        default:gen=0;
    endcase
    return gen;
endfunction