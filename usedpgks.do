***********************************************************************************************************
***												FUNCTIONS												***
***********************************************************************************************************
*Run command in log: run_log [logname] [command]
program define run_log, rclass
	*Start log
	cap drop `1'.log
	log using `1', replace text
	*Run code with capture
	cap `2'
	local rc = _rc
	*Close log
	log close
	*Return error code from running command
	return local rc = `rc'
end


*Find missing package information in log file: log_missing_pkg [logname]
program define log_missing_pkg, rclass
	local missing_command = ""
	*Read log file
	file open logname using `1'.log, read
	file read logname line
	while r(eof)==0 {
	*Find error message about missing command in log
		if strpos(`"`line'"', " is unrecognized")!=0 {
			//di `"`line'"'	//delete later
			local start = strpos(`"`line'"', "command ") + length("command ")
			local end = strpos(`"`line'"', " is unrecognized")
			local length = `end'-`start'
			local missing_command = substr(`"`line'"', `start', `length')
			//di "Missing package: `missing_command'"	//delete later
		}
		else if strpos(`"`line'"', " requires the ")!=0{
			//di `"`line'"'	//delete later
			local start = strpos(`"`line'"', "requires the ") + length("requires the ")
			local end = strpos(`"`line'"', " package")
			local length = `end'-`start'
			local missing_command = substr(`"`line'"', `start', `length')
			//di "Missing package: `missing_command'"	//delete later			
		}
		file read logname line
	}
	file close logname
	*Return missing package name
	return local missing_command `"`missing_command'"'
end


*Install package including dependencies: install_dep [package]
program define install_dep
	* Try to install from SSC
	cap ssc install `1'
	* Check if package works
	preserve
		sysuse auto
		run_log "installlog" "`1' price mpg"
	restore
	local rc_check_package = `r(rc)'
	* If error
	if `rc_check_package'!=0{
		* Find missing dependency in log
		log_missing_pkg "installlog"
		local missing_command = "`r(missing_command)'"
		//di "Missing package: `r(missing_command)'"		//delete later
		if "`missing_command'" != ""{
			file write file_ados "`missing_command', "
			ssc install "`missing_command'"
			local rc = _rc
		}
		else{
			local rc = 0
		}
	}
	* Drop log file
	erase installlog.log
end



***********************************************************************************************************
***												MAIN PROGRAM											***
***********************************************************************************************************


program define usedpkgs
	quietly{
		***STORE SETTINGS
		*Working directory
		local pwd_orig : pwd
		//di "`pwd_orig'"

		*Ado folder
		tempfile sysdir
		log using `sysdir', name(sysdir_log) text nomsg
			noisily sysdir
		log close sysdir_log

		file open sysdir_log using `sysdir', read
		file read sysdir_log line
		while r(eof)==0 {
			if strpos(`"`line'"', `"PLUS: "')!=0 {
				local adopath_orig = substr(`"`line'"', strpos(`"`line'"', "PLUS:  ")+6, .)
			}
			file read sysdir_log line
		}
		file close sysdir_log

		***CREATE NEW ADO FOLDER
		*Create new folder for ado files
		local adopath_new = "`pwd_orig'/ado_usedpkgs"
		cap erase "`adopath_new'"	//delete later
		cap mkdir "`adopath_new'"
		sysdir set PLUS "`adopath_new'"

		***CREATE FOLDER TO STORE LIST OF ADO-FILES
		file open file_ados using file_ados.txt, text write replace
		local logname = "temp_log"

		***RUN CODE
		local rc=199
		while `rc'==199{
			*Run command in log mode
			//di "Try to run the code"
			run_log "`logname'" "run `1'"
			local rc = `r(rc)'
			*Check for error type: if error, try to find missing package in log
			//di "Tried to run the code: error code `r(rc)'"
			if `rc'==199{
				*Find error message about missing command in log
				log_missing_pkg "`logname'"
				local missing_command = "`r(missing_command)'"
				//di "Step 1: Find missing package in log file: `missing_command'"		//delete later
				*Add missing command to list of ado files
				//di "Step 2: Write missing package to file"
				file write file_ados "`missing_command', "
				*Try to install missing command
				//di "Step 3: Install `missing_command'"
				install_dep `missing_command'		
			}
			else if `rc'==0{
				di "No missing ado files."
			}
			else{
				di "Some other error occured!"
				local rc = 0	//end the while loop
			}
		}
		
		*Close file
		file close file_ados

		***RESTORE SETTINGS
		sysdir set PLUS "`adopath_orig'"
		shell rd "`adopath_new'" /s /q
		cap erase `logname'.log
	}
end

usedpkgs "example_code_error.do"