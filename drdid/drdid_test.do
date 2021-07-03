cscript
 use lalonde, clear
gen trt=experimental==1
gen tmt=year==1978
keep if treated==0 | sample==2
global y re
global xvar age educ black married nodegree hisp re74
  timer on 1
 drdid_r re $xvar ,  time(year) tr( experimental ) drimp
 drdid_r re $xvar ,  time(year) tr( experimental ) dripw
 drdid_r re $xvar ,  time(year) tr( experimental ) reg
 drdid_r re $xvar ,  time(year) tr( experimental ) stdipw
 drdid_r re $xvar ,  time(year) tr( experimental ) ipw
 
 drdid_r re $xvar ,  cluster(id) time(year) tr( experimental ) drimp
 drdid_r re $xvar ,  cluster(id) time(year) tr( experimental ) dripw
 drdid_r re $xvar ,  cluster(id) time(year) tr( experimental ) reg
 drdid_r re $xvar ,  cluster(id) time(year) tr( experimental ) stdipw
 drdid_r re $xvar ,  cluster(id) time(year) tr( experimental ) ipw

 drdid_r re $xvar ,  ivar(id) time(year) tr( experimental ) drimp 
 drdid_r re $xvar ,  ivar(id) time(year) tr( experimental ) dripw
 drdid_r re $xvar ,  ivar(id) time(year) tr( experimental ) reg
 drdid_r re $xvar ,  ivar(id) time(year) tr( experimental ) stdipw
 drdid_r re $xvar ,  ivar(id) time(year) tr( experimental ) ipw
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
 
 
 
 drdid_r re $xvar ,  time(year) tr( experimental ) drimp wboot
 drdid_r re $xvar ,  time(year) tr( experimental ) dripw wboot
 drdid_r re $xvar ,  time(year) tr( experimental ) reg wboot
 drdid_r re $xvar ,  time(year) tr( experimental ) stdipw wboot
 drdid_r re $xvar ,  time(year) tr( experimental ) ipw wboot
 
 
 drdid_r re $xvar ,  cluster(id) time(year) tr( experimental ) drimp wboot
 drdid_r re $xvar ,  cluster(id) time(year) tr( experimental ) dripw wboot
 drdid_r re $xvar ,  cluster(id) time(year) tr( experimental ) reg wboot
 drdid_r re $xvar ,  cluster(id) time(year) tr( experimental ) stdipw wboot
 drdid_r re $xvar ,  cluster(id) time(year) tr( experimental ) ipw wboot

 drdid_r re $xvar ,  ivar(id) time(year) tr( experimental ) drimp wboot
 drdid_r re $xvar ,  ivar(id) time(year) tr( experimental ) dripw wboot
 drdid_r re $xvar ,  ivar(id) time(year) tr( experimental ) reg wboot
 drdid_r re $xvar ,  ivar(id) time(year) tr( experimental ) stdipw wboot
 drdid_r re $xvar ,  ivar(id) time(year) tr( experimental ) ipw wboot
 
 *** gmm
 drdid_r re $xvar ,  ivar(id) time(year) tr( experimental ) drimp gmm
 drdid_r re $xvar ,  ivar(id) time(year) tr( experimental ) dripw gmm
 drdid_r re $xvar ,  ivar(id) time(year) tr( experimental ) reg gmm
 drdid_r re $xvar ,  ivar(id) time(year) tr( experimental ) stdipw gmm
 drdid_r re $xvar ,  ivar(id) time(year) tr( experimental ) ipw gmm
 
 