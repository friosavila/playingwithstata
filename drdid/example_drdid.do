foreach i in 2004 2005 2006 2007 {
display "group:2004 TY:`i'"
drdid  lemp lpop if inlist(first_treat,0,2004) & inlist(year,2003,`i'), ivar(countyreal)  time(year) tr(treat)
}