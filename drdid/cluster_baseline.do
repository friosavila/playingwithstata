mata:
y = st_data(.,"_g*")
c = st_data(.,"countyreal")
end

mata:sqrt(mean(yy[,1]:^2)/500)
mata:ord = order(c,1)
mata:_editmissing(y,0)
mata:y=y[ord,]
mata:c=c[ord,]
mata:info = panelsetup(c,1)
mata:info
mata:yy=y:-mean(y)
mata:
xcros=J(12,12,0)
for(i=1;i<=rows(info);i++){
    sub=panelsubmatrix(yy,i,info)
	s=cross(J(rows(sub),1,1),sub)
	xcros=xcros+cross(s,s)
}
end

mata:cross(y,1,y,1)
mata:diagonal(cross(yy,yy)/(500^2)):^0.5

** where nn = Obs
** nc 
(nn-1)/nn*nc/(nc-1)
** asymptotic correction?
mata:vv=xcros/(2500^2)*500/499
mata:diagonal(vv):^0.5
 
 (nobs-1)/nn*(nc/(nc-ncone))
 
mata:diagonal(cross(yy,yy)/2500):^.5

/*

------------------------------------------------------------------
                 |               Robust
                 |       Mean   std. err.     [95% conf. interval]
-----------------+------------------------------------------------
_g2004_2003_2004 |  -.0105032   .0232865     -.0563129    .0353064
------------------------------------------------------------------

*/
mata:
mata drop rif_cluster()
void rif_cluster(string scalar rifs, clvar, vmat){
    /// estimates Clustered Standard errors
    real matrix iiff, cl, ord, xcros, ifp, info, vv
	//1st get the IFS and CL variable. 
	iiff = st_data(.,rifs)
	cl = st_data(.,clvar)
	// order and sort them, Make sure E(IF) is zero.
	ord = order(cl,1)
	iiff=iiff:-mean(iiff)
	iiff=iiff[ord,]
	cl=cl[ord,]
	// check how I cleaned data!
	info  = panelsetup(cl,1)
	// faster Cluster? Need to do this for mmqreg
	ifp   = panelsum(iiff,info)
	xcros = quadcross(ifp,ifp)
	real scalar nt, nc
	nt=rows(iiff)
	nc=rows(info)
	vv=	xcros/(nt^2)*nc/(nc-1)
	//*nc/(nc-1)
	diagonal(vv):^0.5

}
end

mata:rif_cluster("_g*","countyreal","ex")
mata:diagonal(vv):^0.5
