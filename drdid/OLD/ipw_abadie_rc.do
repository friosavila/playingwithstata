**ipw_abatrtie
mata mata clear
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
 void ipw_abadie_rc(string scalar y_, xvar_ , tmt_, trt_, psv_, pxb_, wgt_ ,  touse, rif,b,V){
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
    w10 				= wgt :* trt :* (1 :- tmt)
    w11 				= wgt :* trt :* tmt
    w00 				= wgt :* psc :* (1 :- trt) :* (1 :- tmt):/(1 :- psc)
    w01 				= wgt :* psc :* (1 :- trt) :* tmt:/(1 :- psc)
	
	real matrix pi_hat, lambda_hat, one_lambda_hat
	pi_hat       		= mean(wgt :* trt)
    lambda_hat 			= mean(wgt :* tmt)
    one_lambda_hat 		= mean(wgt :* (1 :- tmt))
	
	real matrix att_treat_pre, att_treat_post, att_cont_pre, att_cont_post,
				eta_treat_pre, eta_treat_post, eta_cont_pre, eta_cont_post
				
    att_treat_pre 		= w10 :* y:/(pi_hat :* one_lambda_hat)
    att_treat_post 		= w11 :* y:/(pi_hat :* lambda_hat)
    att_cont_pre 		= w00 :* y:/(pi_hat :* one_lambda_hat)
    att_cont_post 		= w01 :* y:/(pi_hat :* lambda_hat)
    eta_treat_pre 		= mean(att_treat_pre)
    eta_treat_post 		= mean(att_treat_post)
    eta_cont_pre 		= mean(att_cont_pre)
    eta_cont_post 		= mean(att_cont_post)
	
	real matrix ipw_att
    ipw_att 			= (eta_treat_post :- eta_treat_pre) :- (eta_cont_post :- eta_cont_pre)
	
	real matrix lin_rep_ps, inf_treat_post, inf_treat_pret, inf_cont_post, inf_cont_pret
    //score_ps 			= wgt :* (trt :- psc) :* xvar
    //Hessian_ps 			= psv :* nn
    lin_rep_ps 			= (wgt :* (trt :- psc) :* xvar) * (psv :* nn)
	
	inf_treat_post 		= att_treat_post :- eta_treat_post :+
						-(wgt :* trt :- pi_hat) :* eta_treat_post:/pi_hat :+
						-(wgt :* tmt :- lambda_hat) :* eta_treat_post:/lambda_hat
    ///inf_treat_post 		= inf_treat_post1 :+ inf_treat_post2 :+ inf_treat_post3
	
    inf_treat_pret 		= att_treat_pre :- eta_treat_pre :+
						 -(wgt :* trt :- pi_hat) :* eta_treat_pre:/pi_hat :+
						 -(wgt :* (1 :- tmt) :- one_lambda_hat) :* eta_treat_pre:/one_lambda_hat
    // inf_treat_pret 		= inf_treat_pre1 :+ inf_treat_pre2 :+ inf_treat_pre3
	
    inf_cont_post		= att_cont_post :- eta_cont_post :+
						  -(wgt :* trt :- pi_hat) :* eta_cont_post:/pi_hat :+
						  -(wgt :* tmt :- lambda_hat) :* eta_cont_post:/lambda_hat
    ///inf_cont_post = inf_cont_post1 :+ inf_cont_post2 :+ inf_cont_post3
    inf_cont_pret       = att_cont_pre :- eta_cont_pre :+
						  -(wgt :* trt :- pi_hat) :* eta_cont_pre:/pi_hat :+
						  -(wgt :* (1 :- tmt) :- one_lambda_hat) :* eta_cont_pre:/one_lambda_hat
     		
	//inf_cont_pret= inf_cont_pre1 :+ inf_cont_pre2 :+ inf_cont_pre3
	real matrix inf_logit, att_inf_func
    //mom_logit_pre 		= mean(-att_cont_pre :* xvar)
    //mom_logit_pre 		= mean(mom_logit_pre)
    //mom_logit_post 		= mean(-att_cont_post :* xvar)
    //mom_logit_post 		= mean(mom_logit_post)
    inf_logit 			= lin_rep_ps * (mean(-att_cont_post :* xvar) :- mean(-att_cont_pre :* xvar))'
	
    att_inf_func 		= ipw_att :+ (inf_treat_post :- inf_treat_pret) :- (inf_cont_post :- inf_cont_pret) :+ inf_logit
	
	st_matrix(b,mean(att_inf_func))
	st_matrix(V,variance(att_inf_func)/nn)
	st_store(.,rif,touse,att_inf_func)
//  -19.89330192
//  53.86822411
 }
 
end
	
gen __att__=.
gen touse=1
 
mata:ipw_abadie_rc("y","x1 x2 x3 x4","tmt","trt","psv","pxb","wgt","touse","__att__","b","V")
matrix colname b =__att__
matrix colname V =__att__
matrix rowname V =__att__
adde post b V
ereturn display		