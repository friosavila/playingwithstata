cscript
use mpdta, clear
** este es un ejemplo para csdid. sin WB
csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw)   
 ** Igualmente si uno lo hace con todos los aggregadores
csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw)   agg(simple)
 csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw)   agg(calendar)
 csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw)   agg(group)
 csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw)   agg(event)

** NOT YET
** este es un ejemplo para csdid. sin WB
csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw)   notyet
 ** Igualmente si uno lo hace con todos los aggregadores
csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw)   agg(simple) notyet
 csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw)   agg(calendar) notyet
 csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw)   agg(group) notyet
 csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw)   agg(event)  notyet
 
 
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

csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw) wboot  notyet
matrix list e(cband)
** Igualmente si uno lo hace con todos los aggregadores
csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw) wboot agg(simple) notyet
matrix list e(cband)
csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw) wboot agg(calendar) notyet
matrix list e(cband)
csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw) wboot agg(group) notyet
matrix list e(cband)
csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw) wboot agg(event)  
matrix list e(cband)

** Ahora, Como te comente, uno puede hacer esto usando los RIF files
csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw)   saverif(rif) replace
** Y una vez que los tengas, puedes hacer las aggregaciones desde aca
cscript
use rif, clear
** Si uno hace el llamado por wboot, seria necesario tener los CI modificados
csdid_stats attgt,  
csdid_stats simple
csdid_stats calendar,  
csdid_stats group,  
csdid_stats event,  

csdid_stats attgt,  wboot
csdid_stats simple, wboot
csdid_stats calendar,   wboot
csdid_stats group,   wboot
csdid_stats event,   wboot
use mpdta, clear
csdid  lemp lpop   ,  time(year) gvar(first_treat) ivar(countyreal)  method(dripw)   saverif(rif) replace  
** Y una vez que los tengas, puedes hacer las aggregaciones desde aca
cscript
use rif, clear
csdid_stats group,  
csdid_plot, style(rbar)
** Si uno hace el llamado por wboot, seria necesario tener los CI modificados
csdid_stats attgt, wboot
csdid_stats simple, wboot
csdid_stats calendar, wboot
csdid_stats group, wboot
csdid_stats event, wboot

csdid_plot, title("Dynamic Effect")

set scheme s2color
two rspike  k5 k6 t if t<0, pstyle(p1) color(%50) lw(3) || scatter k1 t if t<0 , pstyle(p1) || rspike k5 k6 t if t>=0, color(%40) pstyle(p2) lw(3) || scatter k1 t if t>=0, pstyle(p2) , legend(order(1 "Pre-treatment" 3 "Pre-treatment"))




