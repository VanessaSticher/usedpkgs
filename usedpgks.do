

***STORE SETTINGS
*Working directory
local pwd_orig : pwd
di "`pwd_orig'"

*Ado folder
tempfile sysdir
log using `sysdir', name(sysdir_log) text nomsg
	sysdir
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
di "`adopath_orig'"

***CREATE NEW ADO FOLDER
*Create new folder for ado files
local adopath_new = "`pwd_orig'/ado_usdpkgs"
//cap erase "`adopath_new'"
cap mkdir "`adopath_new'"
sysdir set PLUS "`adopath_new'"

***CREATE FOLDER TO STORE LIST OF ADO-FILES
file open file_ados using file_ados.txt, text write replace


***RUN CODE
local _rc=199
while `_rc'==199{
	*Start log
	tempfile run_log
	log using `run_log', replace text
		*Try to run code
		cap run some_test_code.do
		local _rc = _rc
		di "********** `rc' *******" 
	*Close log
	log close
	tempfile close
	*Check for error type
	if `_rc'==199{
		di "Adding missing ado files"
		*Find error message about missing command in log
		file open run_log using `run_log', read
		file read run_log line
		while r(eof)==0 {
			if strpos(`"`line'"', " is unrecognized")!=0 {
				di `"`line'"'
				local start = strpos(`"`line'"', "command ") + length("command ")
				local end = strpos(`"`line'"', " is unrecognized")
				local length = `end'-`start'
				local missing_command = substr(`"`line'"', `start', `length')
				di "`missing_command'"
			}
			file read run_log line
		}
		file close run_log
		*Add missing command to list of ado files
		file write file_ados "`missing_command'"
		*Try to install missing command -->returns error message if installation fails
		ssc install "`missing_command'"
	}
	else if `_rc'==0{
		di "No missing ado files."
	}
	else{
		di "Some other error occured!"
	}

}
	
di "No more missing ado files. Check file file_ados.txt for a list of all ado files."
	

STOP
*Close file
file close file_ados


***RESTORE SETTINGS
sysdir set PLUS "`adopath_orig'"
shell rd "`adopath_new'" /s /q

