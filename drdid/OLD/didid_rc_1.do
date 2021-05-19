    //*:* neetrt 4 regression with Regular wgt y00  y01 y10 y11
	//*:* combine y0=y00:+y01 antrt y1=y10:+y11
	//*:* chk my stantrtartrts for weight
	st_view(wgt = .,wgt_,touse_)
	psc = logistic(psxb)
	
    w10 = wgt :* trt :* (1 :- tmt)
    w11 = wgt :* trt :* tmt
    w00 = wgt :* psc :* (1 :- trt) :* (1 :- tmt):/(1 :- psc)
    w01 = wgt :* psc :* (1 :- trt) :* tmt:/(1 :- psc)
	w1  = wgt :* trt
	
    att_treat_pre 		= w10 :* (y :- y0):/mean(w10)
    att_treat_post 		= w11 :* (y :- y0):/mean(w11)
    att_cont_pre  		= w00 :* (y :- y0):/mean(w00)
    att_cont_post  		= w01 :* (y :- y0):/mean(w01)
	
    att_trt_post   		= w1  :* (y11 :- y01):/mean(w1)
    att_trtt1_post 		= w11 :* (y11 :- y01):/mean(w11)
    att_trt_pre   		= w1  :* (y10 :- y00):/mean(w1)
    att_trtt0_pre 		= w10 :* (y10 :- y00):/mean(w10)
	
    eta_treat_pre 		= mean(att_treat_pre)
    eta_treat_post 		= mean(att_treat_post)
    eta_cont_pre  		= mean(att_cont_pre)
    eta_cont_post  		= mean(att_cont_post)
    eta_trt_post   		= mean(att_trt_post)
    eta_trtt1_post 		= mean(att_trtt1_post)
    eta_trt_pre   		= mean(att_trt_pre)
    eta_trtt0_pre 		= mean(att_trtt0_pre)
	
    trtr_att      		= (eta_treat_post :- eta_treat_pre) :- (eta_cont_post :- eta_cont_pre) :+ (eta_trt_post :- eta_trtt1_post) :- (eta_trt_pre :- eta_trtt0_pre)
	
    wgt_ols_pre     	= wgt :* (1 :- trt) :* (1 :- tmt)
    wols_x_pre          = wgt_ols_pre :* xvar
    wols_eX_pre         = wgt_ols_pre :* (y :- y00) :* xvar
    XpX_inv_pre         = invsym(quadcross(wols_x_pre, xvar)):*nn
    lin_ols_pre 		= wols_eX_pre * XpX_inv_pre
    
	wgt_ols_post     	= wgt :* (1 :- trt) :* tmt
    wols_x_post         = wgt_ols_post :* xvar
    wols_eX_post        = wgt_ols_post :* (y :- y01) :* xvar
    XpX_inv_post 		= invsym(quadcross(wols_x_post, xvar)):*nn
	lin_ols_post 		= wols_eX_post * XpX_inv_post
	
    wgt_ols_pre_treat 	= wgt :* trt :* (1 :- tmt)
    wols_x_pre_treat 	= wgt_ols_pre_treat :* xvar
    wols_eX_pre_treat 	= wgt_ols_pre_treat :* (y :- y10) :* xvar
    XpX_inv_pre_treat 	= invsym(quadcross(wols_x_pre_treat, xvar)):*nn
	lin_ols_pre_treat 	= wols_eX_pre_treat * XpX_inv_pre_treat
		
    wgt_ols_post_treat  = wgt :* trt :* tmt
    wols_x_post_treat   = wgt_ols_post_treat :* xvar
    wols_eX_post_treat  = wgt_ols_post_treat :* (y :- y11) :* xvar
    XpX_inv_post_treat  = invsym(quadcross(wols_x_post_treat, xvar)):*nn
    lin_ols_post_treat 	= wols_eX_post_treat * XpX_inv_post_treat
    // check psv
	score_ps 			= wgt :* (trt :- psc) :* xvar
    Hessian_ps 			= psv :* nn
    lin_rep_ps 			= score_ps * Hessian_ps
    inf_treat_pre 		= att_treat_pre  :- w10 :* eta_treat_pre :/mean(w10)
    inf_treat_post 		= att_treat_post :- w11 :* eta_treat_post:/mean(w11)
	
    M1_post 			= -mean(w11 :* tmt :* xvar):/ mean(w11)
    M1_pre 				= -mean(w10 :* (1 :- tmt) :* xvar):/mean(w10)
	inf_treat_or_post 	= lin_ols_post * M1_post'
    inf_treat_or_pre 	= lin_ols_pre * M1_pre'
	
    inf_treat_or 		= inf_treat_or_post :+ inf_treat_or_pre
    inf_treat 			= inf_treat_post :- inf_treat_pre :+ inf_treat_or
    inf_cont_pre 		= att_cont_pre :- w00 :* eta_cont_pre :/mean(w00)
    inf_cont_post 		= att_cont_post :- w01 :* eta_cont_post :/mean(w01)
    
	M2_pre 				= mean(w00 :* (y :- y0 :- eta_cont_pre) :* xvar):/mean(w00)
    M2_post 			= mean(w01 :* (y :- y0 :- eta_cont_post) :* xvar):/mean(w01)
    inf_cont_ps 		= lin_rep_ps * (M2_post :- M2_pre)'
	
    M3_post 			= -mean(w01 :* tmt :* xvar):/mean(w01)
    M3_pre 				= -mean(w00 :* (1 :- tmt) :* xvar):/mean(w00)
    inf_cont_or_post 	= lin_ols_post * M3_post'
    inf_cont_or_pre 	= lin_ols_pre  * M3_pre'
	
    inf_cont_or 		= inf_cont_or_post :+ inf_cont_or_pre
    inf_cont 			= inf_cont_post    :- inf_cont_pre :+ inf_cont_ps :+ inf_cont_or
    trtr_eta_inf_func1 	= inf_treat :- inf_cont
	
    inf_eff1 			= att_trt_post   :- w1  :* eta_trt_post   :/ mean(w1)
    inf_eff2 			= att_trtt1_post :- w11 :* eta_trtt1_post :/ mean(w11)
    inf_eff3 			= att_trt_pre    :- w1  :* eta_trt_pre   :/ mean(w1)
    inf_eff4 			= att_trtt0_pre  :- w10 :* eta_trtt0_pre :/ mean(w10)
    inf_eff 			= (inf_eff1      :- inf_eff2) :- (inf_eff3   :- inf_eff4)
    mom_post 			= mean((w1:/mean(w1) :- w11:/mean(w11)) :* xvar)
    mom_pre 			= mean((w1:/mean(w1) :- w10:/mean(w10)) :* xvar)
	// check this
    inf_or_post 		= (lin_ols_post_treat :- lin_ols_post) * mom_post
    inf_or_pre 			= (lin_ols_pre_treat :- lin_ols_pre) * mom_pre
    inf_or 				= inf_or_post :- inf_or_pre
	
	trtr_eta_inf_func 	= trtr_att :+ trtr_eta_inf_func1 :+ inf_eff :+ inf_or
	