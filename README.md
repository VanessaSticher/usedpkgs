# usedpkgs
This Stata package creates a list with all packages needed to run the provided do-file(s). Nested do-files are allowed. Note that the do-file(s) cannot contain the command `clear all` (but `clear` is allowed). 


## Installation
Install from github:
   ```stata
   net install usedpkgs, from("https://raw.githubusercontent.com/VanessaSticher/usedpkgs/main/src")
   ```    
<!-- DOESN'T WORK WITH SUBFOLDER src
Or install from github using the [github](https://github.com/haghish/github) package:
   ```stata
   github install VanessaSticher/usedpkgs
   ```  
-->

## Usage
### General
   ```stata
   usedpkgs [filename] [, filename(str) foldername(str) replace keepfolder]
   ```    
### Example
Create a list with all packages used to run the do-file example.do:
   ```stata
   usedpkgs example.do
   ```  


## Future Adjustments
- Include option to show version of packages (implementation: loop over output file and create new output file)
- Make more efficient: continue running code from where it had to install a package
