adopath + C:\Users\Fernando\Documents\GitHub\csdid_drdid\code
adopath + C:\Users\Fernando\Documents\GitHub\csdid_drdid\data	
clear all
sysuse sim_rc, clear

logit d x1 x2 x3 x4
predict double pxb, xb
matrix psb = e(b)
matrix psv = e(V)
gen wgt=1
gen trt=d
gen tmt=post
 
reg y x1 x2 x3 x4 if trt==0 & tmt ==0
predict double y00
reg y x1 x2 x3 x4 if trt==0 & tmt ==1
predict double y01
reg y x1 x2 x3 x4 if trt==1 & tmt ==0
predict double y10
reg y x1 x2 x3 x4 if trt==1 & tmt ==1
predict double y11


mata:
void drdid_rc1(string scalar y_, yy_, xvar_ , tmt_, trt_, psv_, pxb_, wgt_ ,  touse, rif,b,V){
    // main Loading variables
    real matrix y,  y00, y01, y10, y11,
				xvar, tmt, trt, psv, psc, wgt
				
	y    = st_data(.,y_, touse)
	yy   = st_data(.,yy_, touse)
	y00  = yy[,1]
	y01  = yy[,2]
	y10  = yy[,3]
	y11  = yy[,4]
	xvar = st_data(.,xvar_, touse), J(rows(y),1,1)
	tmt  = st_data(.,tmt_, touse)
	trt  = st_data(.,trt_, touse)
	psc  = logistic(st_data(.,pxb_, touse))
	wgt  = st_data(.,wgt_, touse)
	psv  = st_matrix(psv_)
	
	real matrix y0
	real scalar nn
	y0   = y00:*(-tmt:+1) + y01:*tmt
	nn = rows(y)
    
	real matrix w10, w11, w00, w01
    w10 		= wgt :* trt :* (1 :- tmt)
    w11 		= wgt :* trt :* tmt
    w00 		= wgt :* psc :* (1 :- trt) :* (1 :- tmt):/(1 :- psc)
    w01 		= wgt :* psc :* (1 :- trt) :* tmt:/(1 :- psc)
	
	w00 = w00:/mean(w00 )
	w01 = w01:/mean(w01 )
	w10 = w10:/mean(w10 )
	w11 = w11:/mean(w11 )
	
	real matrix eta_trt_pre, eta_trt_post, eta_cont_pre, eta_cont_post,
				att_trt_pre, att_trt_post, att_cont_pre, att_cont_post
				
    eta_trt_pre 	= w10 :* (y :- y0)
    eta_trt_post 	= w11 :* (y :- y0)
    eta_cont_pre 	= w00 :* (y :- y0)
    eta_cont_post 	= w01 :* (y :- y0)
    att_trt_pre 	= mean(eta_trt_pre)
    att_trt_post 	= mean(eta_trt_post)
    att_cont_pre 	= mean(eta_cont_pre)
    att_cont_post 	= mean(eta_cont_post)
	
	real matrix trtr_att, w_ols_pre, wols_eX_pre, lin_rep_ols_pre,
						  w_ols_post, wols_eX_post, lin_rep_ols_post
    trtr_att 		= (att_trt_post :- att_trt_pre) :- (att_cont_post :- att_cont_pre)
	
    w_ols_pre 		= wgt :* (1 :- trt) :* (1 :- tmt)
    wols_eX_pre 	= w_ols_pre :* (y :- y00) :* xvar
 
    lin_rep_ols_pre = wols_eX_pre * invsym(quadcross(xvar, w_ols_pre, xvar)):*nn
	
    w_ols_post  	= wgt :* (1 :- trt) :* tmt
    wols_eX_post 	= w_ols_post  :* (y :- y01) :* xvar
    lin_rep_ols_post = wols_eX_post * invsym(quadcross( xvar,w_ols_post, xvar)):*nn
	
	real matrix lin_rep_ps, inf_trt_pre, inf_trt_post, M1_post, M1_pre
    //score_ps 		= wgt :* (trt :- psc) :* xvar
    //Hessian_ps 		= psv :* nn
    lin_rep_ps 		= (wgt :* (trt :- psc) :* xvar) * (psv :* nn)
    inf_trt_pre 	= eta_trt_pre :- w10 :* att_trt_pre
    inf_trt_post 	= eta_trt_post :- w11 :* att_trt_post
	M1_post 		= -mean(w11 :* tmt :* xvar)
    M1_pre 			= -mean(w10 :* (1 :- tmt) :* xvar)
    
	real matrix inf_trt_or, inf_trt
    inf_trt_or 		= (lin_rep_ols_post * M1_post') :+ (lin_rep_ols_pre * M1_pre')
    inf_trt 		= inf_trt_post :- inf_trt_pre :+ inf_trt_or
    
	real matrix inf_cont_pre , inf_cont_post, M2_pre,  M2_post, inf_cont_ps, M3_post, M3_pre

	inf_cont_pre 	= eta_cont_pre :- w00 :* att_cont_pre
    inf_cont_post 	= eta_cont_post :- w01 :* att_cont_post
    M2_pre 			= mean(w00 :* (y :- y0 :- att_cont_pre) :* xvar)
    M2_post 		= mean(w01 :* (y :- y0 :- att_cont_post) :* xvar)
    inf_cont_ps 	= lin_rep_ps * (M2_post :- M2_pre)'
    M3_post 		= -mean(w01 :* tmt :* xvar)
    M3_pre 			= -mean(w00 :* (1 :- tmt) :* xvar)

	real matrix inf_cont_or, inf_cont, att_inf_func
    inf_cont_or 	= (lin_rep_ols_post * M3_post') :+ (lin_rep_ols_pre * M3_pre')
    inf_cont 		= inf_cont_post :- inf_cont_pre :+ inf_cont_ps :+ inf_cont_or
    att_inf_func 	= trtr_att :+ inf_trt :- inf_cont
	
	st_matrix(b,mean(att_inf_func))
	st_matrix(V,variance(att_inf_func)/nn)
	st_store(.,rif,touse,att_inf_func)
 // -3.633433441	
//3.107123089
}
end
	
gen __att__=.
gen touse=1
mata:drdid_rc1("y","y00 y01 y10 y11","x1 x2 x3 x4","tmt","trt","psv","pxb","wgt","touse","__att__","b","V")
matrix colname b =__att__
matrix colname V =__att__
matrix rowname V =__att__
adde post b V
ereturn display	