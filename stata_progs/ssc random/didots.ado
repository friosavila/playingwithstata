*v1 Random programs. Display a dot. Either continuously, or in a new line.
program didots, rclass
	syntax, [maxlength(int 50) counter(string)]
	local cc = mod(`counter',`maxlength')
	if `cc'<`maxlength' 	display "." _cont 
	if `cc'==0 {
		display "`counter'" 
	}
end
