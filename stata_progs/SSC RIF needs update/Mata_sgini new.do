mata : 
void prank(string scalar weight, sortvar, byvar, touse) {
	real matrix wvar, svar, bvar, ord
	/// setup, get all data
	wvar=st_data(.,weight ,touse)
	svar=st_data(.,sortvar,touse)
	bvar=st_data(.,byvar  ,touse)
	// sort by  bvar and svar
	sord = order((bvar,svar,wvar), (1,2,3))
	iord = invorder(sord)
	// sort data.
	wvar = wvar[sord,]
	svar = svar[sord,]
	bvar = bvar[sord,]
	// may need two loops. One for sortvar. One for wvar. 
	// option 1. Do prank without by variable
	// spt1 Normalize
	wvar=wvar:/mean(wvar)
	// spt2 runing sum?
	wsum=runningsum(wvar)
	nobs=rows(wsum)
	
    info = panelsetup(wvar, 1 )
    nc   = rows(info)

	for(i=1;i<=nc;i++){
		//prank=0.5*(wsum-0.5*wvar)/nobs
		prank
	}
}
end

capture program drop _prank
program _prank, sortpreserve byable(recall)
	syntax newvarlist  [if] [in], sort(varname) [weight(varname) by(varname)]
	tempvar touse
	gen byte `touse' = 1
	replace `touse' = 0 `if' `in'
	markout `touse' `weight' `by' `sort'
	sort `touse' `by' `sort' `weight'
	tempvar sumwgt awgt NN
	by `touse' `by':gen double `sumwgt'=sum(`weight'/_N)
	by `touse' `by':gen double `awgt'  =`weight'/`sumwgt'[_N]
	by `touse' `by':replace    `sumwgt'=sum(`awgt')
	by `touse' `by':gen double `NN' =_N
	//adj prank
	by `touse' `by' `sort' `weight':gen double `varlist' = 0.5 * (`sumwgt'[_N] + `sumwgt'[1] - `awgt'[1])/`NN'
end


program define _sgini , rclass sortpreserve
  * v4.0.0, 2020-04-21 : faster calculation of ranks, add -replace- suboption to -genp-
  * v3.2.0, 2010-02-05 : add -genp- option for saving fractional rank , allow ts operators
  * v3.1.0, 2009-09-14 : normalize aw
  * v3.0.0, 2007-11-19 (based on v2.3.0, 2007-02-07)
  * -pvar()- option added. Receives rank variable directly -- only needed for speed gain in -sgini- (but not used currently).
  version 8.2
  syntax varname(ts) [if] [in]  [fweight aweight] [ , Param(real 2.0) Sortvar(varname ts) PVAR(varname) ABSolute AGgregate GENP(string)]
  marksample touse
  markout `touse' `sortvar'  `pvar'
  if ("`sortvar'"!="") & ("`pvar'"!="") {
    di as error "Options sortvar() and pvar() are mutually exclusive"
    exit 198
  }  
  if ("`sortvar'"=="") & ("`pvar'"=="") {
    loc sortvar "`varlist'"
  }
  
  _parse_genp `genp' 
  loc w "`weight'`exp'"
  gettoken eq wexp : exp , parse(=)
  if ("`wexp'"=="") loc wexp 1

  // normalize weights to 1 to avoid huge cumulations
  if ("`weight'"!="") {
    tempvar ww
    qui gen double `ww' = `wexp' if `touse'
    qui su `ww'  if `touse' , meanonly 
    qui replace `ww' = `ww'/r(mean)
    loc wexp `ww'
  }
  
  tempvar yvar svar wvar cusum padj 
  qui gen double `yvar' = `varlist'  // needed to handle ts opertors²
  quietly {
    if ("`pvar'"=="") {
	  qui gen double `wvar' = `wexp'  if `touse'  // it needs a variable
      gen double `svar' = `sortvar' if `touse'  
	  sort `touse' `svar' `wvar'
	  gen double `cusum' = sum(`wvar'*`touse') if `touse' 
	  loc N = `cusum'[_N]
      // NB: 1. use 'adjusted ranks' padj[i] = sum(w[1]::w[i]) - w[i]/2 
      // to ensure that expected adjusted rank = 0.5
      // see Lerman & Yitzhaki (J of Econometrics, 1989); Chokitapanich & Griffiths (RIW, 2001)
	  // 2. all obs with same income receive same rank
	  by `touse' `svar' : gen double `padj' = 0.5 * (`cusum'[_N] + `cusum'[1] - `wvar'[1])/`N'  if `touse'
    }
    else {
      gen double `padj' = `pvar' 
    } 
    if ("`genp'"!="") gen double `genp' = `padj'
	gen pd=`pdaj'
    // 3. use covariance formula to estimate index
    tempvar p 
    tempname X m
    gen double `p' = (1-`padj')^(`param'-1) if `touse'
    mat accum `X' = `yvar' `p' [`w'] if `touse' , dev noc means(`m')
    loc mu_ede = -`param' * (`X'[2,1]/(r(N))) 
    if ("`absolute'"!="") return scalar coeff = `mu_ede'   
    if ("`aggregate'"!="") return scalar coeff =  `m'[1,1] - `mu_ede'  
    if (("`absolute'"!="") + ("`aggregate'"!="") == 0) return scalar coeff = `mu_ede' / `m'[1,1]  
    return scalar N = r(N)
  }
end

sysuse auto,clear
gen r=1+(runiform()<.5)
expand r
sort price
sum weight
gen double w2=weight/r(mean)
capture drop sw
gen double ww2=sum(w2)
sort price weight
drop sw
by price weight:gen double sw=.5*(ww2[_N]+ww2[1]-w2[1])/115
ss
gen double sw=(sum(w2)-0.5*w2)/_N

sum price

gen cv=sum((price - r(mean))*(sw-.5))/_N
sort price weight
by weight:replace sw = 0.5*(
	  by `touse' `svar' : gen double `padj' = 0.5 * (`cusum'[_N] + `cusum'[1] - `wvar'[1])/`N'  if `touse'

sum sw [w=w2]
