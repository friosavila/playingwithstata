* ==============================================================================
* Date Created : 15 February 2020
* Date Last Modified : 15 February 2020
* Program : rename_eb_var_invalid
*
* Created By : AF
* Modified By : AF
* Last Modified By : AF
*
* Description: This ado file defines a program -rename_eb_var_invalid-, which 
* 				renaming variables stored in e(b) using namelist, if label names 
* 				from the deswired variable(s) are invalid and cannot be used as 
* 				column names (e.g. contains a comma, so matname crashes etc). 
*				The namelist then contains the names of the variable(s), which 
* 				the user must provide as arguments.
*
* database used: - 
*
* key variables: - 
*
* output: - rename_eb_var_invalid.ado
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

						* rename_eb_var_invalid
						* =====================
capture program drop rename_eb_var_invalid

* Define Program to Rename Variables in e(b)
program define rename_eb_var_invalid, eclass
	args est
	* renaming variables stored in e(b)
	est restore `est'
	macro shift 1
	matrix m = e(b)
	local names "`*'"
	matname m `names', col(.) explicit
	ereturn repost b = m, rename
	eststo `est'
end
