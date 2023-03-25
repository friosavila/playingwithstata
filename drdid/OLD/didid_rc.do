** drdid_rc
clear all	
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
 
reg y x1 x2 x3 x4 if trt==0 & tmt ==0
predict double y00
reg y x1 x2 x3 x4 if trt==0 & tmt ==1
predict double y01
reg y x1 x2 x3 x4 if trt==1 & tmt ==0
predict double y10
reg y x1 x2 x3 x4 if trt==1 & tmt ==1
predict double y11
mata:
 void drdid_rc(string scalar y_, yy_, xvar_ , tmt_, trt_, psv_, pxb_, wgt_ ,  touse, rif,b,V){
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
	
	real matrix w10, w11, w00, w01, w1
    w10 = wgt :* trt :* (1 :- tmt)
    w11 = wgt :* trt :* tmt
    w00 = wgt :* psc :* (1 :- trt) :* (1 :- tmt):/(1 :- psc)
    w01 = wgt :* psc :* (1 :- trt) :* tmt:/(1 :- psc)
	w1  = wgt :* trt
	
	w00 = w00:/mean(w00 )
	w01 = w01:/mean(w01 )
	w10 = w10:/mean(w10 )
	w11 = w11:/mean(w11 )
	w1 = w1:/mean(w1 )
	
	real matrix att_treat_pre, att_treat_post,  att_cont_pre, att_cont_post,
				att_trt_post, att_trtt1_post, att_trt_pre, att_trtt0_pre,
				eta_treat_pre, eta_treat_post,  eta_cont_pre, eta_cont_post,
				eta_trt_post, eta_trtt1_post, eta_trt_pre, eta_trtt0_pre
				
    att_treat_pre 		= w10 :* (y :- y0)
    att_treat_post 		= w11 :* (y :- y0)
    att_cont_pre  		= w00 :* (y :- y0)
    att_cont_post  		= w01 :* (y :- y0)
	
    att_trt_post   		= w1  :* (y11 :- y01)
    att_trtt1_post 		= w11 :* (y11 :- y01)
    att_trt_pre   		= w1  :* (y10 :- y00)
    att_trtt0_pre 		= w10 :* (y10 :- y00)
	
    eta_treat_pre 		= mean(att_treat_pre)
    eta_treat_post 		= mean(att_treat_post)
    eta_cont_pre  		= mean(att_cont_pre)
    eta_cont_post  		= mean(att_cont_post)
    eta_trt_post   		= mean(att_trt_post)
    eta_trtt1_post 		= mean(att_trtt1_post)
    eta_trt_pre   		= mean(att_trt_pre)
    eta_trtt0_pre 		= mean(att_trtt0_pre)
	
	real matrix trtr_att
    trtr_att      		= (eta_treat_post :- eta_treat_pre) :- (eta_cont_post :- eta_cont_pre) :+ (eta_trt_post :- eta_trtt1_post) :- (eta_trt_pre :- eta_trtt0_pre)
	
	real matrix wgt_ols_pre, XpX_inv_pre, lin_ols_pre, 
				wgt_ols_post, XpX_inv_post, lin_ols_post,
				XpX_inv_pre_treat, lin_ols_pre_treat,
				XpX_inv_post_treat, lin_ols_post_treat
	wgt_ols_pre     	= wgt :* (1 :- trt) :* (1 :- tmt)
    //wols_x_pre          = wgt_ols_pre :* xvar
    //wols_eX_pre         = wgt_ols_pre :* (y :- y00) :* xvar
    XpX_inv_pre         = invsym(quadcross(xvar,wgt_ols_pre, xvar)):*nn
    lin_ols_pre 		= ( wgt_ols_pre :* (y :- y00) :* xvar) * XpX_inv_pre
    
	wgt_ols_post     	= wgt :* (1 :- trt) :* tmt
    //wols_x_post         = wgt_ols_post :* xvar
    //wols_eX_post        = wgt_ols_post :* (y :- y01) :* xvar
    XpX_inv_post 		= invsym(quadcross(xvar,wgt_ols_post, xvar)):*nn
	lin_ols_post 		= (wgt_ols_post :* (y :- y01) :* xvar) * XpX_inv_post
	    
    //wols_x_pre_treat 	= w10 :* xvar
    //wols_eX_pre_treat 	= w10 :* (y :- y10) :* xvar
    XpX_inv_pre_treat 	= invsym(quadcross(xvar, w10, xvar)):*nn
	lin_ols_pre_treat 	= ( w10 :* (y :- y10) :* xvar) * XpX_inv_pre_treat
	
	//wols_x_post_treat   = w11 :* xvar
    //wols_eX_post_treat  = w11 :* (y :- y11) :* xvar
    XpX_inv_post_treat  = invsym(quadcross(xvar, w11, xvar)):*nn
    lin_ols_post_treat 	= (w11 :* (y :- y11) :* xvar) * XpX_inv_post_treat
	
	real matrix lin_rep_ps, inf_treat_pre, inf_treat_post
    // check psv for probit
	//score_ps 			= wgt :* (trt :- psc) :* xvar
    //Hessian_ps 			= psv :* nn
    lin_rep_ps 			= (wgt :* (trt :- psc) :* xvar) * (psv :* nn)
    inf_treat_pre 		= att_treat_pre  :- w10 :* eta_treat_pre 
    inf_treat_post 		= att_treat_post :- w11 :* eta_treat_post
	
	real matrix M1_post, M1_pre, inf_treat_or_post, inf_treat_or_pre
	
    M1_post 			= -mean(w11 :* tmt :* xvar)
    M1_pre 				= -mean(w10 :* (1 :- tmt) :* xvar)
	inf_treat_or_post 	= lin_ols_post * M1_post'
    inf_treat_or_pre 	= lin_ols_pre * M1_pre'
	
	real matrix inf_treat_or, inf_treat, inf_cont_pre, inf_cont_post
	
    inf_treat_or 		= inf_treat_or_post :+ inf_treat_or_pre
    inf_treat 			= inf_treat_post :- inf_treat_pre :+ inf_treat_or
    inf_cont_pre 		= att_cont_pre  :- w00 :* eta_cont_pre 
    inf_cont_post 		= att_cont_post :- w01 :* eta_cont_post 
    
	real matrix M2_pre, M2_post, inf_cont_ps, M3_post, M3_pre, inf_cont_or_post, inf_cont_or_pre
	M2_pre 				= mean(w00 :* (y :- y0 :- eta_cont_pre) :* xvar)
    M2_post 			= mean(w01 :* (y :- y0 :- eta_cont_post) :* xvar)
    inf_cont_ps 		= lin_rep_ps * (M2_post :- M2_pre)'
	
    M3_post 			= -mean(w01 :* tmt :* xvar)
    M3_pre 				= -mean(w00 :* (1 :- tmt) :* xvar)
    inf_cont_or_post 	= lin_ols_post * M3_post'
    inf_cont_or_pre 	= lin_ols_pre  * M3_pre'
	
	real matrix inf_cont_or, inf_cont, trtr_eta_inf_func1
	
    inf_cont_or 		= inf_cont_or_post :+ inf_cont_or_pre
    inf_cont 			= inf_cont_post    :- inf_cont_pre :+ inf_cont_ps :+ inf_cont_or
    trtr_eta_inf_func1 	= inf_treat :- inf_cont
	
	real matrix inf_eff, mom_post, mom_pre, inf_or
    //inf_eff1 			= att_trt_post   :- w1  :* eta_trt_post   
    //inf_eff2 			= att_trtt1_post :- w11 :* eta_trtt1_post 
    //inf_eff3 			= att_trt_pre    :- w1  :* eta_trt_pre   
    //inf_eff4 			= att_trtt0_pre  :- w10 :* eta_trtt0_pre 
    inf_eff 			= ((att_trt_post   :- w1  :* eta_trt_post)    :- 
						   (att_trtt1_post :- w11 :* eta_trtt1_post)) :-
						  ((att_trt_pre    :- w1  :* eta_trt_pre)     :- 
						   (att_trtt0_pre :- w10 :* eta_trtt0_pre))
    mom_post 			= mean((w1 :- w11) :* xvar)
    mom_pre 			= mean((w1 :- w10) :* xvar)
	// check this
    //inf_or_post 		= ((lin_ols_post_treat :- lin_ols_post) * mom_post')
    //inf_or_pre 		= 
    inf_or 				= ((lin_ols_post_treat :- lin_ols_post) * mom_post') :- ((lin_ols_pre_treat :- lin_ols_pre) * mom_pre')
	
	att_inf_func	 	= trtr_att :+ trtr_eta_inf_func1 :+ inf_eff :+ inf_or
	
	st_matrix(b,mean(att_inf_func))
	st_matrix(V,variance(att_inf_func)/nn)
	st_store(.,rif,touse,att_inf_func)
//  -.1677954483	
// .2008991705	
 }

 end

gen __att__=.
gen touse=1
mata:drdid_rc("y","y00 y01 y10 y11","x1 x2 x3 x4","tmt","trt","psv","pxb","wgt","touse","__att__","b","V")
matrix colname b =__att__
matrix colname V =__att__
matrix rowname V =__att__
adde post b V
ereturn display		