global marginzero_  graphregion(margin(zero)  ) plotregion(margin(zero))
clear
webuse iris
set scheme s2color
seplen sepwid petlen petwid

two scatter seplen sepwid  if iris==1 ||  ///
	scatter seplen sepwid  if iris==2 ||  ///
	scatter seplen sepwid  if iris==3 , legend(off) $marginzero_ name(fig1, replace)
	
two scatter seplen petlen  if iris==1 ||  ///
	scatter seplen petlen  if iris==2 ||  ///
	scatter seplen petlen  if iris==3 , legend(off) $marginzero_ name(fig2, replace)
	
two scatter seplen petwid  if iris==1 ||  ///
	scatter seplen petwid  if iris==2 ||  ///
	scatter seplen petwid  if iris==3 , legend(off) $marginzero_ name(fig3, replace)
	
two scatter sepwid petlen  if iris==1 ||  ///
	scatter sepwid petlen  if iris==2 ||  ///
	scatter sepwid petlen  if iris==3 , legend(off) $marginzero_ name(fig4, replace)
two scatter sepwid petwid  if iris==1 ||  ///
	scatter sepwid petwid  if iris==2 ||  ///
	scatter sepwid petwid  if iris==3 , legend(off) $marginzero_ name(fig5, replace)
two scatter petlen petwid  if iris==1 ||  ///
	scatter petlen petwid  if iris==2 ||  ///
	scatter petlen petwid  if iris==3 , legend(off) $marginzero_ name(fig6, replace)
	
two scatter petlen petwid  if iris==0 ||  ///
	scatter petlen petwid  if iris==0 ||  ///
	scatter petlen petwid  if iris==0 , ///
	legend(order(1 "Sectosa"	2 "Versicolor" 3 "virginica")  symysize(20) margin(zero) ) 	fysize(10) ///
	graphregion(margin(zero)  ) plotregion(margin(zero)) ///
	yscale(off) xscale(off) name(flabels, replace)

graph combine fig1 fig2 fig3 fig4 fig5 fig6	, name(f16, replace)  holes(1 5 6 9 10 11 13 14 15)  

graph combine f16 flabels, col(1)
