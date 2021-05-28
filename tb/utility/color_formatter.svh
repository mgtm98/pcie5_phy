class color_formatter extends uvm_report_catcher;
	// colors that are supported by the formatter
	typedef enum{BLACK, BROWN, GREEN, YELLOW, BLUE, MAGENTA, CYAN, GRAY, RED, WHITE}color_t;
	// escape characters for font color
	local string font_color_map [color_t]= {
		BLACK:"\033[30m%s\033[0m",
		BROWN:"\033[31m%s\033[0m", 
		GREEN:"\033[32m%s\033[0m", 
		YELLOW:"\033[33m%s\033[0m", 
		BLUE:"\033[34m%s\033[0m", 
		MAGENTA:"\033[35m%s\033[0m", 
		CYAN:"\033[36m%s\033[0m", 
		GRAY:"\033[37m%s\033[0m", 
		RED:"\033[38m%s\033[0m"
 };
 // escape characters for background color
 local string bg_color_map [color_t]= {
		BLACK:"\033[40m%s\033[0m", 
		BROWN:"\033[41m%s\033[0m", 
		GREEN:"\033[92m%s\033[0m", 
		YELLOW:"\033[43m%s\033[0m", 
		BLUE:"\033[44m%s\033[0m", 
		MAGENTA:"\033[45m%s\033[0m", 
		CYAN:"\033[46m%s\033[0m", 
		GRAY:"\033[47m%s\033[0m", 
		RED:"\x1B[31m%s\033[0m", 
		WHITE:"\033[49m%s\033[0m"
 	};

	 function new(string name = "color_formatter");
		super.new(name);
	endfunction : new

	function action_e catch();
		string msg = get_message();
		// $sformat(msg, bg_color_map[RED], msg);
		set_message(msg);
		return THROW;
	endfunction : catch

endclass : 	color_formatter
