# usedpgks
This Stata package creates a list with all packages used in the provided do-file(s).


## Installation
Install from github:
   ```stata
   net install ftools, from("https://raw.githubusercontent.com/VanessaSticher/usedpkgs/main/src/")
   ```    

Or install from github using the [github package](https://github.com/haghish/github):
   ```stata
   github install VanessaSticher/usedpkgs
   ```  


## Usage
### General
...
### Example
...

## Future Adjustments
- Assert that it works for do-files calling other do-files
- Include option to show version of packages (implementation: loop over output file and create new output file)
- Make more efficient: continue running code from where it had to install a package
