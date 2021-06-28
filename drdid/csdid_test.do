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

cscript
use rif_example, clear
csdid_stats group, 

cscript 
use https://friosavila.github.io/playingwithstata/drdid/mpdta.dta, clear

csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat) method(dripw) agg(simple)
estat pretrend
estat simple 
estat calendar
estat group
estat event

csdid  lemp lpop , ivar(countyreal) time(year) gvar(first_treat) method(dripw) agg(group) saverif(rif_example) wboot replace 

cscript
use rif_example, clear
 csdid_stats simple , wboot
csdid_stats calendar, wboot 
csdid_stats group , wboot
csdid_stats event , wboot
