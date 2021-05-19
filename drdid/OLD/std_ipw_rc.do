*** code for RC estimators
adopath + C:\Users\Fernando\Documents\GitHub\csdid_drdid\code
adopath + C:\Users\Fernando\Documents\GitHub\csdid_drdid\data
sysuse sim_rc, clear

logit d x1 x2 x3 x4
predict double pxb, xb
matrix psb = e(b)
matrix psv = e(V)
gen wgt=1
gen trt=d
gen tmt=post
 

mata:
 void std_ipw_rc(string scalar y_, xvar_ , tmt_, trt_, psv_, pxb_, wgt_ ,  touse, rif,b,V){
    // main Loading variables
    real matrix y, 	xvar, tmt, trt, psv, psc, wgt
				
	y    = st_data(.,y_, touse)
	xvar = st_data(.,xvar_, touse), J(rows(y),1,1)
	tmt  = st_data(.,tmt_, touse)
	trt  = st_data(.,trt_, touse)
	psc  = logistic(st_data(.,pxb_, touse))
	wgt  = st_data(.,wgt_, touse)
	psv  = st_matrix(psv_)
	real scalar nn
 	nn = rows(y)
	
	real matrix w10, w11, w00, w01
	
    w10 = wgt :* trt :* (1 :- tmt)
    w11 = wgt :* trt :* tmt
    w00 = wgt :* psc :* (1 :- trt) :* (1 :- tmt):/(1 :- psc)
    w01 = wgt :* psc :* (1 :- trt) :* tmt:/(1 :- psc)
	
	w00 = w00:/mean(w00 )
	w01 = w01:/mean(w01 )
	w10 = w10:/mean(w10 )
	w11 = w11:/mean(w11 )
	
	real matrix att_treat_pre, att_treat_post, att_cont_pre, att_cont_post,
				eta_treat_pre, eta_treat_post, eta_cont_pre, eta_cont_post
	att_treat_pre  	= w10 :* y
    att_treat_post 	= w11 :* y
    att_cont_pre   	= w00 :* y
    att_cont_post  	= w01 :* y
    eta_treat_pre  	= mean(att_treat_pre)
    eta_treat_post 	= mean(att_treat_post)
    eta_cont_pre   	= mean(att_cont_pre)
    eta_cont_post  	= mean(att_cont_post)
	
	real matrix ipw_att, lin_rep_ps
    ipw_att 		= (eta_treat_post :- eta_treat_pre) :- (eta_cont_post :- eta_cont_pre)
    //score_ps 		= wgt :* (trt :- psc) :* xvar
    //Hessian_ps 		= psv :* nn
    lin_rep_ps 		= (wgt :* (trt :- psc) :* xvar) * (psv :* nn)
    
	real matrix inf_treat, inf_cont, M2_pre, M2_post, inf_cont_ps, att_inf_func
	
	inf_treat 		= (att_treat_post :- w11 :* eta_treat_post) :- (att_treat_pre :- w10 :* eta_treat_pre)
    inf_cont 		= (att_cont_post :- w01 :* eta_cont_post) :- (att_cont_pre :- w00 :* eta_cont_pre)
    M2_pre 			= mean(w00 :* (y :- eta_cont_pre) :* xvar)
    M2_post 		= mean(w01 :* (y :- eta_cont_post) :* xvar)
    inf_cont_ps 	= lin_rep_ps * (M2_post :- M2_pre)'
    inf_cont 		= inf_cont :+ inf_cont_ps
    
	att_inf_func 	= ipw_att :+ inf_treat :- inf_cont

	st_matrix(b,mean(att_inf_func))
	st_matrix(V,variance(att_inf_func)/nn)
	st_store(.,rif,touse,att_inf_func)
 //  -15.80330618	
 //  9.087929526
 }
end	

gen __att__=.
gen touse=1
 
mata:std_ipw_rc("y","x1 x2 x3 x4","tmt","trt","psv","pxb","wgt","touse","__att__","b","V")
matrix colname b =__att__
matrix colname V =__att__
matrix rowname V =__att__
adde post b V
ereturn display	
