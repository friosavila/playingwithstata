webuse dui, clear
gen i_fines=1/fines
gen ni_fines2=-1/fines^2
gen fines05=fines^.5
gen i_fines05=0.5*fines^-.5
gen fines_99=max((fines-9.9),0)
gen dfines_99=fines>9.9
qui:regress citations i_fines
sum ni_fines2, meanonly
lincom _b[i_fines]*`r(mean)'
qui:regress citations fines05
sum i_fines05, meanonly
lincom _b[fines05]*`r(mean)'
qui:regress citations fines fines_99
sum dfines_99, meanonly
lincom _b[fines]+_b[fines_99]*`r(mean)'

qui:nl (citations = {b0}+{b1}/fines), variable(fines)
margins, dydx(fines)

qui:nl (citations = {b0}+{b1}*fines^.5), variable(fines)
margins, dydx(fines)

qui:nl (citations = {b0}+{b1}*fines+{b2}*max((fines-9.9),0)), variable(fines)
margins, dydx(fines)

*** Numerical derivative for fines^.5
gen double h=1
gen double dydx1=((fines+h)^.5-(fines-h)^.5)/(2*h)
replace h=0.5
gen double dydx2=((fines+h)^.5-(fines-h)^.5)/(2*h)
replace h=0.25
gen double dydx3=((fines+h)^.5-(fines-h)^.5)/(2*h)
replace h=0.125
gen double dydx4=((fines+h)^.5-(fines-h)^.5)/(2*h)
replace h=1/(2^16)
gen double dydx5=((fines+h)^.5-(fines-h)^.5)/(2*h)
 
compare i_fines05 dydx1
compare i_fines05 dydx2
compare i_fines05 dydx3
compare i_fines05 dydx4
compare i_fines05 dydx5

webuse dui, clear
fgen fines2=max(fines-9,0)
describe fines2
frep fines2=max(fines-9.9,0)
describe fines2

qui:regress citations fines fines2
f_able, nlvar(fines2)
margins, dydx(fines) nochainrule

qui:nl (citations = {b0}+{b1}*fines+{b2}*max((fines-9.9),0)), variable(fines)
margins, dydx(fines)

npregress series citations fines, spline(1) knots(1)

qui:regress citations c.fines##c.fines##c.fines
margins, dydx(fines)

frep fines2=fines^2
fgen fines3=fines^3

qui:regress citations fines fines2 fines3
f_able, nlvar(fines2 fines3)
margins, dydx(fines) nochainrule

webuse dui, clear
npregress series citations fines i.csize, spline(2) knots(1)

fgen double fines2=fines^2
fgen double fines3=max(fines-9.9,0)^2
qui:regress citations c.(fines fines2 fines3)#i.csize i.csize
f_able, nlvar(fines2 fines3)
margins, nochain dydx(csize fines)


 webuse mksp2, clear
 
 fgen dos1=max(dosage-17.5,0)
 fgen dos2=max(dosage-36.5,0)
 fgen dos3=max(dosage-55.5,0)
 fgen dos4=max(dosage-81.5,0)
 
logit outcome dosage dos1 dos2 dos3 dos4 
f_able, nl(dos1 dos2 dos3 dos4)
margins ,   nochain numerical at(dosage=(0(2)100))
marginsplot, name(m1)
margins ,  dydx(dosage) nochain numerical at(dosage=(0(2)100))
marginsplot, name(m2)
graph combine m1 m2, xsize(8) scale(1.5)

 


