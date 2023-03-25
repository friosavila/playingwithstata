* ==============================================================================
* Date Created : 15 February 2020
* Date Last Modified : 15 February 2020
* Program : estadd_sum_eb
*
* Created By : AF
* Modified By : AF
* Last Modified By : AF
*
* Description: This ado file defines a program -estadd_sum_eb-, which sums over 
* 				e(b) of te active estimation, and add the sum to the estimates 
* 				as a scalar using -estadd-.
*
* database used: - 
*
* key variables: - 
*
* output: - estadd_sum_eb.ado
*
* ==============================================================================

* Opening commands
set more off
version 14.1

if c(os) == "Windows" {
	global programs "C:/Users/Avinno Faruk/Documents/Projects/Stata Programs" //Change location to what you set your personal ado directory as.
}
else if c(os) == "MacOSX" {
	global programs "C:/Users/Avinno Faruk/Documents/Projects/Stata Programs"
}

* Define the directory
gl V14 "${programs}/Version 14"

							* estadd_sum_eb
							* =============
capture program drop estadd_sum_eb

* Define Program to sum over e(b) and add as a scalar using -estadd-
program estadd_sum_eb, eclass
	* summing over e(b) of the active estimation, and adding the sum to the 
	* estimation as a scalar using -estadd-
	version 14.1
	cap ssc install estadd
	tempname sum_eb
	mata: st_matrix("`sum_eb'", rowsum(st_matrix("e(b)")))
	ereturn scalar sum_eb = `sum_eb'[1,1]
end
