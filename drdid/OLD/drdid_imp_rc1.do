adopath + C:\Users\Fernando\Documents\GitHub\csdid_drdid\code
adopath + C:\Users\Fernando\Documents\GitHub\csdid_drdid\data	
clear all
sysuse sim_rc, clear

ml model lf drdid_logit (d=x1 x2 x3 x4), maximize
predict double pxb, xb
matrix psb = e(b)
matrix psv = e(V)
gen wgt=1
gen trt=d
gen tmt=post
gen touse=1 
gen double w0 = (1-trt)*logistic(pxb)/(1-logistic(pxb))
 
reg y x1 x2 x3 x4 if trt==0 & tmt ==0  [w=w0]
predict double y00
reg y x1 x2 x3 x4 if trt==0 & tmt ==1 [w=w0]
predict double y01
reg y x1 x2 x3 x4 if trt==1 & tmt ==0
predict double y10
reg y x1 x2 x3 x4 if trt==1 & tmt ==1
predict double y11

mata:

void drdid_imp_rc1(string scalar y_, yy_, xvar_ , tmt_, trt_, psv_, pxb_, wgt_ ,  touse, rif,b,V){
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
	
	real matrix w10, w11, w00, w01, 
				eta_treat_pre, eta_treat_post, eta_cont_pre, eta_cont_post,
				att_treat_pre, att_treat_post, att_cont_pre, att_cont_post
				
    w10 			= wgt :* trt :* (1 :- tmt)
    w11 			= wgt :* trt :* tmt
    w00 			= wgt :* psc:* (1 :- trt) :* (1 :- tmt):/(1 :-  psc)
	w01 			= wgt :* psc:* (1 :- trt) :* tmt:/(1 :- psc)
    
	eta_treat_pre 	= w10 :* (y :- y0):/mean(w10)
    eta_treat_post 	= w11 :* (y :- y0):/mean(w11)
    eta_cont_pre 	= w00 :* (y :- y0):/mean(w00)
    eta_cont_post 	= w01 :* (y :- y0):/mean(w01)
    
	att_treat_pre 	= mean(eta_treat_pre)
    att_treat_post 	= mean(eta_treat_post)
    att_cont_pre 	= mean(eta_cont_pre)
    att_cont_post 	= mean(eta_cont_post)
    
	real matrix trtr_att, inf_treat, inf_cont, att_inf_func
	trtr_att 		= (att_treat_post :- att_treat_pre) :- (att_cont_post :-  att_cont_pre)
    inf_treat 		= (eta_treat_post :- w11 :* att_treat_post:/mean(w11) ):- (eta_treat_pre :- w10 :* att_treat_pre:/mean(w10))
    inf_cont 		= (eta_cont_post :- w01 :* att_cont_post:/mean(w01)) :- ( eta_cont_pre :- w00 :* att_cont_pre:/mean(w00))
    att_inf_func 	= trtr_att :+ inf_treat :- inf_cont
	
	// Wrapping up
	st_matrix(b,mean(att_inf_func))
	st_matrix(V,variance(att_inf_func)/nn)
	st_store(.,rif,touse,att_inf_func)
//  -3.683728719	
//	 3.114495585
}
end	

gen __att__=.
mata:drdid_imp_rc1("y","y00 y01 y10 y11","x1 x2 x3 x4","tmt","trt","psv","pxb","wgt","touse","__att__","b","V")
matrix colname b =__att__
matrix colname V =__att__
matrix rowname V =__att__
adde post b V
ereturn display