

sysuse auto
di "Hello"

reg price mpg
reghdfe price mpg, noa
di "Yay the first part now runs"

reg price mpg
outreg2 using testoutreg.doc

reghdfe price mpg

vincenty 38.9 -77.077 39 -77.077, v(vb) h(hb)

