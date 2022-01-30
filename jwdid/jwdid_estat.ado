program jwdid_estat, sortpreserve   
	version 14
    syntax anything, [*]
        if "`e(cmd)'" != "jwdid" {
                error 301
        }
        gettoken key rest : 0, parse(", ")
        if inlist("`key'","simple","group","calendar","event","all") {
			jwdid_`key'  `rest'
        }
		else {
			display in red "Option `key' not recognized"
				error 199
		}

end

program jwdid_simple, rclass
		syntax, [*]
		tempvar aux
		qui:bysort `e(ivar)':egen `aux'=min(`e(tvar)') if e(sample)
		margins if __tr__==1 & `aux'<`e(gvar)', dydx(__tr__)  `options'
end

program jwdid_group, rclass
		syntax, [*]
		tempvar aux
		qui:bysort `e(ivar)':egen `aux'=min(`e(tvar)') if e(sample)
		capture drop __group__
		qui:clonevar __group__ =  `e(gvar)' if __tr__==1 & `aux'<`e(gvar)'
		margins , dydx(__tr__) over(__group__) `options'
		
		capture drop __group__
end

program jwdid_calendar, rclass
syntax, [*]
		capture drop __calendar__
		tempvar aux
		qui:bysort `e(ivar)':egen `aux'=min(`e(tvar)') if e(sample)
		qui:clonevar __calendar__ =  `e(tvar)' if __tr__==1 & `aux'<`e(gvar)'
		margins , dydx(__tr__) over(__calendar__) `options'
		capture drop __calendar__
end

program jwdid_event, rclass
syntax, [*]
		capture drop __event__
		tempvar aux
		qui:bysort `e(ivar)':egen `aux'=min(`e(tvar)') if e(sample)
		
		qui:gen __event__ =  `e(tvar)'-`e(gvar)' if __tr__==1 & `aux'<`e(gvar)'
		margins , dydx(__tr__) over(__event__) `options'
		matrix rr=r(table)
		return matrix table = rr
		capture drop __event__
end