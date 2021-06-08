class reporter extends uvm_report_server;
	uvm_report_global_server global_server;

	extern function new(string name = "report_server");
	extern function string compose_message(
		uvm_severity severity,
		string name,
		string id,
		string message,
		string filename,
		int line
	);
				
endclass : reporter

function reporter::new(string name = "report_server");
	super.new();
	set_name(name);
	global_server = new();
	global_server.set_server(this);
endfunction : new		

function string reporter::compose_message(uvm_severity severity,
	string name,
	string id,
	string message,
	string filename,
	int line
);
	string reporter_string;
	$swrite(reporter_string, "%t", 10);
	$swrite(reporter_string, "[%s:%0d]", filename, line);
	return {reporter_string, " [", id, "] ", message};
endfunction : compose_message