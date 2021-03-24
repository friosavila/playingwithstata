* ==============================================================================
* Date Created : 17 March 2020
* Date Last Modified : 17 March 2020
* Program : est_mat_div
*
* Created By : AF
* Modified By : AF
* Last Modified By : AF
*
* Description: This ado file defines a program -est_mat_div-, which divides 
* 				coefficients from two estimates, and stores the results as a new 
* 				estimate, to be added as a separate column with -esttab- etc.
*
* database used: - 
*
* key variables: - 
*
* output: - est_mat_div.ado
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
capture program drop est_mat_div

* Define Program to Calculate Differences between Two Matrices and Add as a Separate Column
program define est_mat_div, eclass
	args est1 est2 est3
	tempname b tmp1 tmp2
	* dividing coefficients from two estimates, and storing the results as a new 
	* estimate, to be added as a separate column using -esttab-
	estimates restore `est2'
	matrix `tmp2' = e(b)
	estimates restore `est1'
	matrix `tmp1' = e(b)
	mata: st_matrix("`b'", st_matrix("`tmp1'") :/ st_matrix("`tmp2'"))
	ereturn repost b = `b'
	eststo `est3'
end
