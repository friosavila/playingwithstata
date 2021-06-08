*adopath + C:\Users\Fernando\Documents\GitHub\csdid_drdid\code
*adopath + C:\Users\Fernando\Documents\GitHub\csdid_drdid\data
**#Example
cscript 
cls
use lalonde, clear
replace re = re/1000
local xvar age educ black married nodegree hisp re74
local ivaropts ivar(id) time(year) tr( experimental )
keep if treated==0 | sample==2
rcof "noi drdid re `xvar', `ivaropts' drimp wboot wboot(rseed(111))"==198  
drdid re `xvar', `ivaropts' drimp wboot
drdid re `xvar', `ivaropts' drimp wboot(rseed(111))
drdid re `xvar', `ivaropts' drimp wboot(rseed(111) bwtype(mammen))
drdid re `xvar', `ivaropts' drimp wboot(rseed(111) bwtype(rademacher))
rcof "noi drdid re `xvar', `ivaropts' drimp gmm wboot"==198
rcof "noi drdid re `xvar', `ivaropts' drimp wboot gmm"==198
rcof "noi drdid re `xvar', `ivaropts' drimp wboot vce(cluster id)"==198
xtset id year 
rcof "noi drdid re `xvar', `ivaropts' drimp vce(hac nwest 2)"==198
drdid re `xvar', `ivaropts' dripw gmm vce(hac nwest 2)
capture noisily drdid re `xvar', `ivaropts' drimp vce(cluster id)
tostring id, generate(sid)
capture noisily drdid re `xvar', `ivaropts' drimp vce(cluster sid)
drdid re `xvar', `ivaropts' drimp vce(if)
drdid re `xvar', `ivaropts' gmm dripw vce(cluster id)
capture noisily drdid re `xvar', `ivaropts' gmm dripw vce(cluster sid)
generate bli = "epg"
rcof "noi drdid re `xvar', `ivaropts' drimp vce(cluster bli)"==198
rcof "noi drdid re `xvar', `ivaropts' drimp vce(cluster ble)"==198
rcof "noi drdid re `xvar', `ivaropts' gmm dripw vce(if)"==198