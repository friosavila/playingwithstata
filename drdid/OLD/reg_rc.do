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
predict y00
reg y x1 x2 x3 x4 if trt==0 & tmt ==1
predict y01

mata:
 void reg_rc(string scalar y_, yy_, xvar_ , tmt_, trt_, wgt_ ,  touse, rif,b,V) {
    // main Loading variables
    real matrix y,  y00, y01,
				xvar, tmt, trt,   wgt
				
	y    = st_data(.,y_, touse)
	yy   = st_data(.,yy_, touse)
	y00  = yy[,1]
	y01  = yy[,2]

	xvar = st_data(.,xvar_, touse), J(rows(y),1,1)
	tmt  = st_data(.,tmt_, touse)
	trt  = st_data(.,trt_, touse)
	//psc  = logistic(st_data(.,pxb_, touse))
	//psv  = st_matrix(psv_)
	wgt  = st_data(.,wgt_, touse)
	
	real scalar nn
	nn = rows(y)
	
	real matrix w10, w11, w0
	
	w10 			= wgt :* trt :* (1 :- tmt)
    w11 			= wgt :* trt :* tmt
    w0 				= wgt :* trt
	
	w10				= w10:/mean(w10 )
	w11				= w11:/mean(w11 )
	w0				= w0:/mean(w0 )
	
	real matrix att_treat_pre, att_treat_post, att_cont,
				eta_treat_pre, eta_treat_post, eta_cont, reg_att
    att_treat_pre 	= w10 :* y
    att_treat_post 	= w11 :* y
    att_cont 		= w0 :* (y01 :- y00)
    eta_treat_pre 	= mean(att_treat_pre)
    eta_treat_post 	= mean(att_treat_post)
    eta_cont 		= mean(att_cont)
    reg_att 		= (eta_treat_post :- eta_treat_pre) :- eta_cont
	
	real matrix w_ols_pre, wols_eX_pre, XpX_inv_pre, lin_rep_ols_pre
    w_ols_pre 		= wgt :* (1 :- trt) :* (1 :- tmt)
    //wols_x_pre 	= w_ols_pre :* xvar
    wols_eX_pre 	= w_ols_pre :* (y :- y00) :* xvar
    XpX_inv_pre 	= invsym(quadcross(xvar,w_ols_pre, xvar)):*nn
    lin_rep_ols_pre = wols_eX_pre * XpX_inv_pre
	
	real matrix w_ols_post, wols_eX_post, XpX_inv_post, lin_rep_ols_post
    w_ols_post 		= wgt :* (1 :- trt) :* tmt
    //wols_x_post 	= w_ols_post :* xvar
    wols_eX_post 	= w_ols_post :* (y :- y01) :* xvar
    XpX_inv_post 	= invsym(quadcross(xvar, w_ols_post, xvar)):*nn
    lin_rep_ols_post = wols_eX_post * XpX_inv_post
    
	real matrix inf_treat, inf_cont_1, inf_cont_2_post, inf_cont_2_pre, inf_control
	//inf_treat_pre 	= (att_treat_pre :- w10 :* eta_treat_pre)
    //inf_treat_post 	= (att_treat_post :- w11 :* eta_treat_post)
    inf_treat 		= (att_treat_post :- w11 :* eta_treat_post) :- (att_treat_pre :- w10 :* eta_treat_pre)
    inf_cont_1 		= (att_cont :- w0 :* eta_cont)
    //M1 				= mean(w0 :* xvar)
    inf_cont_2_post = lin_rep_ols_post * mean(w0 :* xvar)'
    inf_cont_2_pre 	= lin_rep_ols_pre  * mean(w0 :* xvar)'
    inf_control 	= (inf_cont_1 :+ inf_cont_2_post :- inf_cont_2_pre)
    
	real matrix att_inf_func
	att_inf_func 	= reg_att :+ (inf_treat :- inf_control)
 	
	st_matrix(b,mean(att_inf_func))
	st_matrix(V,variance(att_inf_func)/nn)
	st_store(.,rif,touse,att_inf_func)
 }
//  -8.790976318
// 7.77847538	
end	

gen __att__=.
gen touse=1
 
mata:reg_rc("y","y00 y01","x1 x2 x3 x4","tmt","trt","wgt","touse","__att__","b","V")
matrix colname b =__att__
matrix colname V =__att__
matrix rowname V =__att__
adde post b V
ereturn display		