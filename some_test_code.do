

sysuse auto
di "Hello"

reg price mpg
reghdfe price mpg, noa
di "Yay the first part now runs"

reg price mpg
outreg2 using testoutreg.doc