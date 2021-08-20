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
		margins if __tr__==1, dydx(__tr__) 
end

program jwdid_group, rclass
		capture drop __group__
		qui:clonevar __group__ =  `e(gvar)' if __tr__==1
		margins , dydx(__tr__) over(__group__)
		capture drop __group__
end

program jwdid_calendar, rclass
		capture drop __calendar__
		qui:clonevar __calendar__ =  `e(tvar)' if __tr__==1
		margins , dydx(__tr__) over(__calendar__)
		capture drop __calendar__
end

program jwdid_event, rclass
		capture drop __event__
		qui:gen __event__ =  `e(tvar)'-`e(gvar)' if __tr__==1
		margins , dydx(__tr__) over(__event__)
		capture drop __event__
end