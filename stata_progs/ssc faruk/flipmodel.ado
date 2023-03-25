capt prog drop flipmodel

*! version 1.0.0  14aug2007  Ben Jann
* From http://repec.org/bocode/e/estout/advanced.html#advanced907
* Using the Approach 2 under the heading: "Flip models and coefficients (place models in rows instead of in columns)
program flipmodel, eclass
     // using active equation of model
	 args est
     version 14.1
	 tempname b se C tmp
	 esttab `est', se nostar
	 mat list r(coefs)
	 matrix `C' = r(coefs)
	 local rnames : rownames `C'
	 local models : coleq `C'
	 local models : list uniq models
	 local i 0
	 foreach name of local rnames {
     local ++i
     local j 0
     capture matrix drop b
     capture matrix drop se
     foreach model of local models {
         local ++j
         matrix `tmp' = `C'[`i', 2*`j'-1]
         if `tmp'[1,1]<. {
             matrix colnames `tmp' = `model'
             matrix `b' = nullmat(`b'), `tmp'
             matrix `tmp'[1,1] = `C'[`i', 2*`j']
             matrix `se' = nullmat(`se'), `tmp'
         }
     }
     ereturn post `b'
     quietly estadd matrix `se'
     eststo `name'
}
end
