
** https://pedrohcgs.github.io/DRDID/reference/drdid_panel.html

clear
mata: mata clear

cap cd "D:\Programs\Dropbox\Dropbox\STATA\DiD\DRDID-master\naqvi"
cap cd "C:\Users\asjad\Dropbox\STATA\DiD\DRDID-master\naqvi"


// get the data and clean it up.

insheet using nsw.csv
d

foreach x of varlist _all {
    cap replace `x' = "" if `x'=="NA"
	}

destring _all, replace
keep  if treated==0 | sample==2

gen deltaY = re78 - re75
gen w = 1



*logit dy age educ black married nodegree hisp re74, robust
*reg experimental age educ black married nodegree hisp re74 

glm experimental age educ black married nodegree hisp re74, family(binomial) 
*mat gamma = e(b)'
mat ps_vcov = e(V)
predict double ps_fit
replace ps_fit = 1 - 1e-16 if ps_fit > 1 - 1e-16


gen 	   temp = experimental - ps_fit
gen double temp2 = experimental - ps_fit
tabstat temp temp2, c(stat) stat(mean sum min max p25 p50 p75)


reg deltaY age educ black married nodegree hisp re74 if experimental==0 [aw = w]
mat reg_coeff = e(b)'


mata
gam 		= st_matrix("reg_coeff")
cov 		= st_data(.,("age", "educ", "black", "married", "nodegree", "hisp", "re74"))
cov 		= cov, J(rows(cov), 1, 1)  	// add the intercept. Stata stores intercepts in the last col
ps_vcov		= st_matrix("ps_vcov")
ps_fit 		= st_data(.,"ps_fit")
//thres 		=  1 - 1e-16
//ps_fit 		= ((ps_fit :<= thres) :* ps_fit) + ((ps_fit :> thres) :* thres)
w			= st_data(.,"w")
deltaY		= st_data(.,"deltaY")
D   		= st_data(.,"experimental")
num 		= rows(cov)	

out_delta 	= cross(gam,cov')
end


mata
// #-----------------------------------------------------------------------------
// # Compute Traditional Doubly Robust DID estimators

w_treat		= w :* D
w_cont		= w :* ps_fit :* ((1 :- D) :/ (1 :- ps_fit))
att_treat   = w_treat' :* (deltaY' :- out_delta)
att_cont    = w_cont' :* (deltaY' :- out_delta)

mean(att_cont')


eta_treat   = mean((att_treat' :/ w_treat))
eta_cont    = mean(att_cont') :/ mean(w_cont)
att 		= eta_treat :- eta_cont
att
end


//#-----------------------------------------------------------------------------
//# get the influence function to compute standard error
//#-------------------------------------------------------------------

mata
w_ols 	 = w :* (1 :- D)  // x
wols_x   = w_ols :*  cov  // x	
wols_eX  = w_ols :* (deltaY' :- out_delta)' :* cov  // x (decimal errors)
XpX_inv  = invsym((wols_x' * cov) :/ num) // x
lin_wols =  wols_eX * XpX_inv   // x


// # Asymptotic linear representation of logit's beta's

score_ps   = w :* (D' :- ps_fit')' :* cov
hessian_ps = ps_vcov :* num
lin_ps 	   =  score_ps * hessian_ps

// # Now, the influence function of the "treat" component. Leading term of the influence function: no estimation effect
inf_treat_1 = (att_treat :- (w_treat' :* eta_treat))

//# Estimation effect from beta hat. Derivative matrix (k x 1 vector)
M1 = mean(w_treat :* cov)

//# Now get the influence function related to the estimation effect related to beta's
inf_treat_2 = M1 * lin_wols'

//# Influence function for the treated component
inf_treat = (inf_treat_1 :- inf_treat_2) :/ mean(w_treat)

// #-----------------------------------------------------------------------------
// # Now, get the influence function of control component. Leading term of the influence function: no estimation effect
inf_cont_1 = att_cont' :- (w_cont :* eta_cont)

// # Estimation effect from gamma hat (pscore). Derivative matrix (k x 1 vector)
M2 = mean(w_cont :* (deltaY :- out_delta' :- eta_cont') :* cov)

//# Now the influence function related to estimation effect of pscores
inf_cont_2 = (M2 * lin_ps')'

// # Estimation Effect from beta hat (weighted OLS)
M3 =  mean(w_cont :* cov)

// # Now the influence function related to estimation effect of regressions
inf_cont_3 = (M3 * lin_wols')'

// # Influence function for the control component
inf_control = (inf_cont_1 :+ inf_cont_2 :- inf_cont_3) :/ mean(w_cont)

// #get the influence function of the DR estimator (put all pieces together)
att_inf_func = inf_treat' :- inf_control

att_se = sqrt(variance(att_inf_func)) :/ sqrt(num)
att_tval = att :/ att_se
att_pval = 2*ttail(num - length(gam), abs(att_tval))
uci = att + 1.96 * att_se
lci = att - 1.96 * att_se


printf("\n SZ (2020) DRDID IPW estimation: \n\n {space 4} ATT {space 3} Std. Error {space 3} t {space 6} p(>|t|) {space 5} 95%% Conf. Interval  \n {hline 70}\n %10.4f %10.4f %10.4f %10.4f {space 3} [%10.4f %10.4f]", att, att_se, att_tval, att_pval, lci, uci)


end

/*

// final set of outputs

mata
att
att_se
att_tval
att_pval
uci
lci
end


