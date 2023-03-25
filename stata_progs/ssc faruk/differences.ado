* ==============================================================================
* Date Created : 15 February 2020
* Date Last Modified : 15 February 2020
* Program : differences
*
* Created By : AF
* Modified By : AF
* Last Modified By : AF
*
* Description: This ado file defines a program -differences-, which calculates 
* 				differences between two matrices and stores it as estimates, to 
* 				add as a separate column with -esttab- etc.
*
* database used: - 
*
* key variables: - 
*
* output: - differences.ado
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
capture program drop differences

* Define Program to Calculate Differences between Two Matrices and Add as a Separate Column
program define differences, eclass
	args mat1 mat2 mat3 nocol
	* calculating differences between two matrices and storing as estimates to 
	* add as a separate column
	estimates restore `mat1'
	matrix `mat3' = e(b) - `mat2'
	if "`nocol'" == "" {
		matrix colnames `mat3' = `mat3'1 `mat3'2 `mat3'3 `mat3'4
	}
	ereturn repost b = `mat3', rename
	eststo `mat3'
end

