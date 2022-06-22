*! 0.0.2 21June2022

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
		local counter = 0
		while `rc'==199{
			local counter = `counter' + 1
			*Run do-file in log mode
			run_log "`logname'" "run `anything'"
			local rc = `r(rc)'
			*Check for error type
			if `rc'==0{	//no error
				if `counter'==1{	//no error from the beginning
					local reason = "No missing ado files."
				}
				else{	//all errors solved
					local reason = "All packages installed successfully."
				}
			}
			else if `rc'==199 | `rc'==601{	// unrecognized command error; or sometimes r(601)
				*Find error message about missing command in log
				log_missing_pkg "`logname'"
				local missing_command = "`r(missing_command)'"
				*Try to install missing command
				install_dep `missing_command'
				local rc_installed = `r(rc_installed)'
				if `rc_installed'==0{
					noisily di as txt "Package {bf:`missing_command'} installed"
					*Add missing command to list of ado files
					file write file_ados "`missing_command', "
					local rc = 199	//treat as if it was an error 199
				}
				else{
					*Try common commands
					install_common `missing_command'
					local rc_installed = `r(rc_installed)'
					if `rc_installed'==0{
						local packagename = "`r(packagename)'"
						noisily di as txt "Package {bf:`packagename'} installed"
					}
					else{
						local rc_fail_reason = cond(`rc_installed'==601, "because not found on SSC", "")
						local reason = "Package {bf:`missing_command'} could not be installed"
						local rc = 0	//end the while loop
					}
				}	
			}
			else{	//some other error
				local reason = "Some other error occured"
				local rc = 0	//end the while loop
			}
		}
	
		if "`reason'" == "All packages installed successfully."{
			noisily di as txt "List of all used ado files created. Check file `filename'.txt."
		}
		else if "`reason'" == "No missing ado files."{
			noisily di as txt "`reason'"
		}
		else{
			noisily di as error "Error: `reason'"	
		}
	
		*Close file
		cap file close file_ados
		if _rc!=0{
			noisily di as error "Error: file got closed before saving. Make sure that the do-file does not contain the command {bf:clear all}."
		}


		*Remove empty file if no missing ado files were found
		if "`reason'" == "No missing ado files."{
			cap erase `filename'.txt
		}

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
	clear
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
		*Find error message including "must have [package] (...) installed"
		else if strpos(`"`line'"', " must have ")!=0 & strpos(`"`line'"', " installed")!=0{
			local start = strpos(`"`line'"', "must have ") + length("must have ")
			local length = strpos(substr(`"`line'"', `start', .), " ")-1
			local missing_command = substr(`"`line'"', `start', `length')	
		}

		file read logname line
	}
	file close logname
	*Return missing package name
	return local missing_command `"`missing_command'"'
end



*Install package including dependencies: install_dep [package]
program define install_dep, rclass
	args package
	* Try to install from SSC
	cap ssc install `package'
	local rc_installed = _rc
	return local rc_installed = `rc_installed'
	/* Check if package works
	preserve
		sysuse auto, clear
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
	*/
end


*Install common package: install_common [command]
program define install_common, rclass
	args command
	
	*gtools, ftools, estout
	foreach pkg in gtools ftools estout{
		local gtools_commands "fasterxtile" "gcollapse" "gcontract" "gdistinct" "gduplicates" "gegen" "gisid" "givregress" "glevelsof" "gpoisson" "gquantiles" "gregress" "greshape" "gstats" "gtop" "gtoplevelsof" "gunique" "hashsort"
		local ftools_commands "fegen" "fcollapse" "join" "fmerge" "fisid" "flevelsof" "fsort"
		local estout_commands "esttab" "estout" "eststo" "estadd" "estpost"
		local found = 0
		foreach com in "``pkg'_commands'" { 
			if "`command'" == "`com'" { 
				local found = 1 
				continue, break	//break out of loop once found
			}
		}
		
		if `found' == 1{
			ssc install `pkg'
			local rc_installed = _rc			
			if `rc_installed'==0{
				local packagename = "`pkg'"
				*Add missing command to list of ado files
				file write file_ados "`pkg', "
			}
			continue, break
		}
	}
	
	*Return error code
	return local rc_installed = `rc_installed'
	return local packagename = "`packagename'"

end




