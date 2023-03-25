program _gcsgvar, sortpreserve
	version 14
	syntax newvarname =/exp [if/] [in] , ivar(varname) time(varname)  
	bysort `ivar' (`time'):egen  `typlist' `varlist'=max(`time'[_n]*(`exp'[_n]-`exp'[_n-1]))
end