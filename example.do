*Load example data
sysuse auto
di "Hello"

*Run some code that requires packages
reg price mpg
reghdfe price mpg, noa

reg price mpg
outreg2 using testoutreg.doc

vincenty 38.9 -77.077 39 -77.077, v(vb) h(hb)

di "Do-file run successfully"
