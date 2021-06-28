cscript
use mpdta, clear
csdid  lemp lpop  ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw)  saverif(rif1) replace
estat all
csdid  lemp lpop  ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw) wboot
estat all

csdid  lemp lpop  ,  time(year) gvar(first_treat) cluster(countyreal)  method(dripw)  saverif(rif2) replace
estat all
csdid  lemp lpop  ,  time(year) gvar(first_treat) cluster(countyreal)  method(dripw)  wboot
estat all
