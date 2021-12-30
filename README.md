# usedpkgs
This Stata package creates a list with all packages used in the provided do-file(s).


## Installation
Install from github:
   ```stata
   net install usedpkgs, from("https://raw.githubusercontent.com/VanessaSticher/usedpkgs/main/src")
   ```    

Or install from github using the [github](https://github.com/haghish/github) package:
   ```stata
   github install VanessaSticher/usedpkgs
   ```  


## Usage
### General
usedpkgs [filename] [, filename(str) foldername(str) replace keepfolder]

### Example
usedpkgs example.do


## Future Adjustments
- Assert that it works for do-files calling other do-files
- Include option to show version of packages (implementation: loop over output file and create new output file)
- Make more efficient: continue running code from where it had to install a package
