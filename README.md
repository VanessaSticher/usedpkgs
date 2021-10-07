# usedpgks
This Stata ado-file creates a list with all packages used in the provided do-file(s).


## Installation
Install from github:
   ```stata
   net install ftools, from("https://raw.githubusercontent.com/VanessaSticher/usedprks/main/src/")
   ```    

Or install from github using the [github package](https://github.com/haghish/github):
   ```stata
   github install VanessaSticher/usedpgks
   ```  


## Usage
### General
...
### Example
...

## Future Adjustments
1. Improve installation of dependencies:
a. list of common packages and their dependencies (e.g. reghdfe required ftools)
b. reading error messages from errors occurring during installation
2. Choose to keep the ado folder
3. Assert that it works for do-files calling other do-files
