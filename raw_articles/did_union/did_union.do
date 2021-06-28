 webuse nlswork, clear
 bysort id (year):replace union = union[_n-1] if union==.
 bysort id (year):replace union = 1 if union[_n-1]==1
 bysort id (year):egen flag = sum(!missing(union))
 drop if flag==0
 replace union =0 if union==.
 
 bysort id: egen aux = min(year) if union==1
 bysort id:egen gvar = max(aux)
 
 
 did_imputation ln_wage id year gvar, horizons(0/15) pretrend(10) autosample
 event_plot, default_look
 
 did_imputation wks_work id year gvar, horizons(0/15) pretrend(10) autosample
 event_plot, default_look 
 addplot:,title("Wks work per year") legend(off)
 
 did_imputation hours id year gvar, horizons(0/15) pretrend(10) autosample
 event_plot, default_look 
 addplot:,title("Hours work per week") legend(off)
 
 
 bysort id (year):egen everunion= max(union)
 drop if everunion==1
 ss
 ** falsification
 forvalues i = 1 / 4 {
 set seed `i'
 replace union = 0
 replace union =1 if runiform()<0.05 & year >= 70  
 bysort id (year):replace union = 1 if union[_n-1]==1
 drop aux2 gvar2	
 bysort id: egen aux2 = min(year) if union==1
 bysort id:egen gvar2 = max(aux2)
 
  did_imputation ln_wage id year gvar2, horizons(0/15) pretrend(10) autosample
 event_plot, default_look 
 graph export event_f`i'.png, replace
 }
 
 