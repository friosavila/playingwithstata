cscript
use mpdta, clear
set seed 1
 csdid  lemp   ,  time(year) gvar(first_treat)  cluster(countyreal)
 csdid  lemp   ,  time(year) gvar(first_treat)  ivar(countyreal)
