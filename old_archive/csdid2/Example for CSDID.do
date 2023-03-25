cscript
use mpdta, clear
** este es un ejemplo para csdid. sin WB
csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw)   
 ** Igualmente si uno lo hace con todos los aggregadores
csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw)   agg(simple)
 csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw)   agg(calendar)
 csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw)   agg(group)
 csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw)   agg(event)
 
** ahora con bootstrap que necesaria los CI que sean con bootstrap. 

csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw) wboot
matrix list e(cband)
** Igualmente si uno lo hace con todos los aggregadores
csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw) wboot agg(simple)
matrix list e(cband)
csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw) wboot agg(calendar)
matrix list e(cband)
csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw) wboot agg(group)
matrix list e(cband)
csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw) wboot agg(event)
matrix list e(cband)

** Ahora, Como te comente, uno puede hacer esto usando los RIF files
csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw)   saverif(rif) replace
** Y una vez que los tengas, puedes hacer las aggregaciones desde aca
use rif, clear
** Si uno hace el llamado por wboot, seria necesario tener los CI modificados
csdid_stats attgt, wboot
csdid_stats simple, wboot
csdid_stats calendar, wboot
csdid_stats group, wboot
csdid_stats event, wboot
