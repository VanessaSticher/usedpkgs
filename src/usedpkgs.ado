*! 0.0.1 07October2021

* Program usedpkgs
program define usedpkgs
	version 16
	syntax anything [, filename(str) foldername(str) replace keepfolder] 
	preserve 
	qui {

		***CHECK IF DO-FILE EXISTS
		confirm file `anything'
		
		***OPTIONS
		* File name
		if missing("`filename'"){
			local filename = "packages_list"
		}

		* Forder name
		if missing("`foldername'"){
			local foldername = "adofolder"
		}
		
	
		***DEFINE LOCALS
		local logname = "temp_log"


		***STORE SETTINGS
		*Working directory
		local pwd_orig : pwd
		
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
		local adopath_new = "`pwd_orig'/`foldername'"
		cap erase "`adopath_new'"	//delete later
		cap mkdir "`adopath_new'"
		sysdir set PLUS "`adopath_new'"

		***CREATE FOLDER TO STORE LIST OF ADO-FILES
		file open file_ados using `filename'.txt, text write `replace'
	
		***RUN DO-FILE
		local rc=199
		while `rc'==199{
			*Run do-file in log mode
			run_log "`logname'" "run `anything'"
			local rc = `r(rc)'
			*Check for error type
			if `rc'==199{	// unrecognized command error
				*Find error message about missing command in log
				log_missing_pkg "`logname'"
				local missing_command = "`r(missing_command)'"
				*Add missing command to list of ado files
				file write file_ados "`missing_command', "
				*Try to install missing command
				install_dep `missing_command'		
			}
			else if `rc'==0{	//no error
				noisily di "No missing ado files."
			}
			else{	//some other error
				di as error "Some other error occured"
                        	error `rc'				
				local rc = 0	//end the while loop
			}
		}
	
		noisily di "No more missing ado files. Check file `filename'.txt for a list of all ado files."
	
		*Close file
		file close file_ados


		***RESTORE SETTINGS
		sysdir set PLUS "`adopath_orig'"
		cap erase `logname'.log
		*Remove ado folder
		if "`keepfolder'"==""{	//if option keepfolder not selected
			shell rmdir -r "`adopath_new'" /s /q
		}
	}
	restore	
end

* Run command and create log: run_log [logname] [command]
program define run_log, rclass
	args logname command
	*Start log
	cap drop `logname'.log
	log using `logname', replace text
	*Run code with capture
	cap `command'
	local rc = _rc
	*Close log
	log close
	*Return error code from running command
	return local rc = `rc'
end



* Find information about missing package in log file: log_missing_pkg [logname]
program define log_missing_pkg, rclass
	args logname
	*Read log file
	file open logname using `logname'.log, read
	file read logname line
	local missing_command = ""
	while r(eof)==0 {
		*Find error message including "[command] is unrecognized"
		if strpos(`"`line'"', " is unrecognized")!=0 {
			local start = strpos(`"`line'"', "command ") + length("command ")
			local end = strpos(`"`line'"', " is unrecognized")
			local length = `end'-`start'
			local missing_command = substr(`"`line'"', `start', `length')
		}
		* Find error message including " requires the [package] packge"
		else if strpos(`"`line'"', " requires the ")!=0{
			local start = strpos(`"`line'"', "requires the ") + length("requires the ")
			local end = strpos(`"`line'"', " package")
			local length = `end'-`start'
			local missing_command = substr(`"`line'"', `start', `length')	
		}
		file read logname line
	}
	file close logname
	*Return missing package name
	return local missing_command `"`missing_command'"'
end



*Install package including dependencies: install_dep [package]
program define install_dep
	args package
	* Try to install from SSC
	cap ssc install `package'
	* Check if package works
	preserve
		sysuse auto
		run_log "installlog" "`package' price mpg"
	restore
	local rc_check_package = `r(rc)'
	* If error when checking package
	if `rc_check_package'!=0{
		* Find missing dependency in log
		log_missing_pkg "installlog"
		local missing_command = "`r(missing_command)'"
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



