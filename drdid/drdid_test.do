cscript
 use lalonde, clear
gen trt=experimental==1
gen tmt=year==1978
keep if treated==0 | sample==2
global y re
global xvar age educ black married nodegree hisp re74
  timer on 1
 drdid re $xvar ,  time(year) tr( experimental ) drimp
 drdid re $xvar ,  time(year) tr( experimental ) dripw
 drdid re $xvar ,  time(year) tr( experimental ) reg
 drdid re $xvar ,  time(year) tr( experimental ) stdipw
 drdid re $xvar ,  time(year) tr( experimental ) ipw
 
 drdid re $xvar ,  cluster(id) time(year) tr( experimental ) drimp
 drdid re $xvar ,  cluster(id) time(year) tr( experimental ) dripw
 drdid re $xvar ,  cluster(id) time(year) tr( experimental ) reg
 drdid re $xvar ,  cluster(id) time(year) tr( experimental ) stdipw
 drdid re $xvar ,  cluster(id) time(year) tr( experimental ) ipw

 drdid re $xvar ,  ivar(id) time(year) tr( experimental ) drimp 
 drdid re $xvar ,  ivar(id) time(year) tr( experimental ) dripw
 drdid re $xvar ,  ivar(id) time(year) tr( experimental ) reg
 drdid re $xvar ,  ivar(id) time(year) tr( experimental ) stdipw
 drdid re $xvar ,  ivar(id) time(year) tr( experimental ) ipw
 timer off 1
 
 
 
 timer on 2
 drdid re $xvar ,  time(year) tr( experimental ) drimp
 drdid re $xvar ,  time(year) tr( experimental ) dripw
 drdid re $xvar ,  time(year) tr( experimental ) reg
 drdid re $xvar ,  time(year) tr( experimental ) stdipw
 drdid re $xvar ,  time(year) tr( experimental ) ipw
 
 drdid re $xvar ,  cluster(id) time(year) tr( experimental ) drimp
 drdid re $xvar ,  cluster(id) time(year) tr( experimental ) dripw
 drdid re $xvar ,  cluster(id) time(year) tr( experimental ) reg
 drdid re $xvar ,  cluster(id) time(year) tr( experimental ) stdipw
 drdid re $xvar ,  cluster(id) time(year) tr( experimental ) ipw

 drdid re $xvar ,  ivar(id) time(year) tr( experimental ) drimp 
 drdid re $xvar ,  ivar(id) time(year) tr( experimental ) dripw
 drdid re $xvar ,  ivar(id) time(year) tr( experimental ) reg
 drdid re $xvar ,  ivar(id) time(year) tr( experimental ) stdipw
 drdid re $xvar ,  ivar(id) time(year) tr( experimental ) ipw
 timer off 2
 
 
 
 drdid re $xvar ,  time(year) tr( experimental ) drimp wboot
 drdid re $xvar ,  time(year) tr( experimental ) dripw wboot
 drdid re $xvar ,  time(year) tr( experimental ) reg wboot
 drdid re $xvar ,  time(year) tr( experimental ) stdipw wboot
 drdid re $xvar ,  time(year) tr( experimental ) ipw wboot
 
 
 drdid re $xvar ,  cluster(id) time(year) tr( experimental ) drimp wboot
 drdid re $xvar ,  cluster(id) time(year) tr( experimental ) dripw wboot
 drdid re $xvar ,  cluster(id) time(year) tr( experimental ) reg wboot
 drdid re $xvar ,  cluster(id) time(year) tr( experimental ) stdipw wboot
 drdid re $xvar ,  cluster(id) time(year) tr( experimental ) ipw wboot

 drdid re $xvar ,  ivar(id) time(year) tr( experimental ) drimp wboot
 drdid re $xvar ,  ivar(id) time(year) tr( experimental ) dripw wboot
 drdid re $xvar ,  ivar(id) time(year) tr( experimental ) reg wboot
 drdid re $xvar ,  ivar(id) time(year) tr( experimental ) stdipw wboot
 drdid re $xvar ,  ivar(id) time(year) tr( experimental ) ipw wboot
 
 *** gmm
 drdid re $xvar ,  ivar(id) time(year) tr( experimental ) drimp gmm
 drdid re $xvar ,  ivar(id) time(year) tr( experimental ) dripw gmm
 drdid re $xvar ,  ivar(id) time(year) tr( experimental ) reg gmm
 drdid re $xvar ,  ivar(id) time(year) tr( experimental ) stdipw gmm
 drdid re $xvar ,  ivar(id) time(year) tr( experimental ) ipw gmm
 
 