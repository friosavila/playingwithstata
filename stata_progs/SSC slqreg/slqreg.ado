*! v1.0 Fernando Rios Avila June 2020
* This estimate Scale location Quantile regression.
* It is based on the insights of Machado Silva 2019 and Canay 2011.
* for q reg:
* y=a0(t)+a1(t)*x1+a2(t)x2
* Can be broken down into scale and loc effects
* y=a0   +a1*x1   +a2*x2+
*   b0(t)+b1(t)*x1+b2(t)*x2
* This can only be identified using MM conditions. E(Seff)=0
* So, Q=a0+b0(t)
* this estimator does that
capture program drop slqreg
program slqreg, eclass
syntax anything [if] [in], [q(real 50) abs(varlist)]
	qui: {
	marksample touse
	markout `touse' `anything'
	gettoken y anything:anything   
	reghdfe `y' `anything', absorb(`abs') resid
	matrix bl=e(b)
    display "1"
	qreg _reghdfe_resid  `anything', q(`q')
	matrix bs=e(b)
	tempvar reshat
	predict `reshat', 
	local ff=e(f_r)
	local qq=e(q)
	}
	mata:x=st_data(.,"`anything'","`touse'")
	mata:x=x,J(rows(x),1,1)
	mata:ixx=invsym(cross(x,x))
	mata:res=st_data(.,"_reghdfe_resid","`touse'")
	mata:resqhat=st_data(.,"`reshat'","`touse'")
	mata:resqhatx=(-(res:<resqhat):+`q'):/`ff':-res
	mata:xr=x:*res
	mata:xw=x:*resqhat
	mata:cvc=(ixx,ixx)*quadcross((xr,xw),(xr,xw))*(ixx,ixx)'
	mata:st_matrix("cvc",cvc)
	matrix bq=bl+bs
	*matrix list bq
	*matrix list cvc
	local cn: colnames bq
	matrix colname cvc = `cn'
	matrix rowname cvc = `cn'
	ereturn post bq cvc
	ereturn display
end