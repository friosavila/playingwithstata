mata:
	mata drop reg_wldb()
	void reg_wldb( string scalar y,x,res,id, real scalar clt, obs, reps) {
	    real matrix yy, xx , rr

	    st_view(yy=.,.,y)
		st_view(xx=.,.,x)
		st_view(rr=.,.,res)
		st_view(cc=.,.,id)
		real matrix rnd, one
		one = J(obs,1,1)
		real matrix yn , beta0, betas
		real scalar j
		
		beta0 = (invsym(cross(xx,1,xx,1))*cross(xx,1,yy,0))'
		// Wild bootstrap:
		betas=J(reps,2,0)
		for(j=1;j<=reps;j++) {
			rnd = -2:*(runiform(clt,1):<0.5):+1
			one = rnd[cc]
			yn = yy-rr+one:*rr		
			
			//rnd = runiform(clt,1):<=((1+sqrt(5))/(2*sqrt(5)))
			//yn = 0.5*x+(0.5*(1+sqrt(5)):-sqrt(5)* (rnd#one)):*rr		
			betas[j,] = (invsym(cross(xx,1,xx,1))*cross(xx,1,yn,0))'
		}
		st_matrix("Vwb", beta0)
		//st_matrix("bwb",  mm_quantile(betas[,1],1,(0.025,0.975)))
		st_matrix("Vwb", variance(betas))
	}
end

		qui:gen byte `rnd'=(runiform()<((1+sqrt(5))/(2*sqrt(5))))
		qui:gen `typlist' `varlist'=`exp'-`err'+(0.5*(1+sqrt(5))-sqrt(5)*`rnd')*`err'
		
reg y x, cluster(id)
mata:reg_wldb("y","x","res","id",10,10,1000)
adde repost V=Vwb
ereturn display

global nclusters 20
global nobspc    10
global reps		 1000