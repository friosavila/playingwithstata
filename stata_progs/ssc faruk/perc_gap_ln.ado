* ==============================================================================
* Date Created : 17 March 2020
* Date Last Modified : 17 March 2020
* Program : perc_gap_ln
*
* Created By : AF
* Modified By : AF
* Last Modified By : AF
*
* Description: This ado file defines a program -perc_gap_ln-, which calculates 
* 				the percentage gap from the difference between two lns (stored 
* 				as estimate)and stores it as a new estimate, to be added as a 
* 				separate column with -esttab- etc.
*
* database used: - 
*
* key variables: - 
*
* output: - perc_gap_ln.ado
*
* ==============================================================================

* Opening commands
set more off
version 14.0

if c(os) == "Windows" {
	global programs "C:/Users/Avinno Faruk/Documents/Projects/Stata Programs" //Change location to what you set your personal ado directory as.
}
else if c(os) == "MacOSX" {
	global programs "C:/Users/Avinno Faruk/Documents/Projects/Stata Programs"
}

* Define the directory
gl V14 "${programs}/Version 14"

								* differences
								* ===========
capture program drop perc_gap_ln

* Define Program to Calculate Differences between Two Matrices and Add as a Separate Column
program define perc_gap_ln, eclass
	args est1 est2
	tempname b tmp foo
	* calculating the percentage gap from the difference between two lns (stored 
	* as estimate) and storing it as a new estimate, to be added as a separate 
	* column using -esttab-
	estimates restore `est1'
	matrix `tmp' = e(b)
	mat `foo' = J(rowsof(`tmp'),colsof(`tmp'),1)
	mata: st_matrix("`b'", ((exp(st_matrix("`tmp'")) - st_matrix("`foo'")) * 100))
	ereturn repost b = `b'
	eststo `est2'
end

