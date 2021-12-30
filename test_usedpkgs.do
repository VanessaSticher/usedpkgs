*Import functions from ado
local pwd_orig : pwd

*Ado folder
tempfile sysdir
sysdir set PLUS "`pwd_orig'"

usedpkgs example_code.do, replace
