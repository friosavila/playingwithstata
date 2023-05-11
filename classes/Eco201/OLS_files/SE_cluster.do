** SE 
frause oaxaca, clear
reg lnwage educ exper female, 
matrix t1= r(table)
reg lnwage educ exper female, robust
matrix t2= r(table)
reg lnwage educ exper female, vce(hc2)
matrix t3= r(table)
reg lnwage educ exper female, vce(hc3)
matrix t4= r(table)

two function y = normalden(x,`=t1[1,4]',`=t1[2,4]') , range(`=t1[1,4]-3*t1[2,4]' `=t1[1,4]+3*t1[2,4]') || ///
	function y = normalden(x,`=t2[1,4]',`=t2[2,4]') , range(`=t1[1,4]-3*t1[2,4]' `=t1[1,4]+3*t1[2,4]') 	|| ///
	function y = normalden(x,`=t3[1,4]',`=t3[2,4]') , range(`=t1[1,4]-3*t1[2,4]' `=t1[1,4]+3*t1[2,4]') || ///
	function y = normalden(x,`=t4[1,4]',`=t4[2,4]') , range(`=t1[1,4]-3*t1[2,4]' `=t1[1,4]+3*t1[2,4]') 


sort isco
mata
y = st_data(.,"lnwage")
x = st_data(.,"educ exper female"),J(1434,1,1)
cc= st_data(.,"isco")
ixx = invsym(cross(x,x))
b   = ixx * cross(x,y)
e   = y:-x*b
info= panelsetup(cc,1)
g=rows(info);n=rows(y)
k=cols(x)
end

mata:sigma_g = s_xg_e's_xg_e
mata cv0 = ixx*sigma_g*ixx
mata cv1 = (g/(g-1))*((n-1)/(n-k))*ixx*sigma_g*ixx

*** Mata CVE vs robust

mata:cc= sort(runiformint(1434,1,1,100),1)

mata:
sd0 = ixx*mean(e:^2);sd0 = sqrt(diagonal(sd0))'
sd1 = ixx*cross(x,e:^2,x)*ixx
sd1 = sqrt(diagonal(sd1))'
info= panelsetup(cc,1)
order = 1::1434
sdt = J(1000,4,.)
for(i=1;i<=1000;i++){
	ord1 = jumble(order)
	s_xg_e = panelsum(x[ord1,]:*e[ord1,],info)
	sdi = ixx*cross(s_xg_e,s_xg_e)*ixx
	sdt[i,]=sqrt(diagonal(sdi))'
}
sdt = sdt\sd0\sd1
end

getmata sdt*=sdt, force replace
set scheme white2
kdensity sdt1 in 1/1000, xline(`=sdt1[1001]' ,  lpattern(solid))  xline( `=sdt1[1002]', lpattern(dash))  title("Distribution of SE:Educ") xtitle("") name(m1, replace)
kdensity sdt2 in 1/1000, xline(`=sdt2[1001]' ,  lpattern(solid))  xline( `=sdt2[1002]', lpattern(dash))  title("Distribution of SE:Exper") xtitle("") name(m2, replace)
kdensity sdt3 in 1/1000, xline(`=sdt3[1001]' ,  lpattern(solid))  xline( `=sdt3[1002]', lpattern(dash)) title("Distribution of SE:Female") xtitle("") name(m3, replace)
kdensity sdt4 in 1/1000, xline(`=sdt4[1001]' ,  lpattern(solid))  xline( `=sdt4[1002]', lpattern(dash))  title("Distribution of SE:Const") xtitle("") name(m4, replace)

cd "G:\My Drive\Class\Class 2023-I\figures"
graph combine m1 m2 m3 m4, note("Solid: Simple SE; Dash: Robust")
graph export clse.png


clear
set seed 1
set obs 10000
gen u = rnormal()
gen y = rnormal() + u
gen x = rnormal() + u
gen bw  = 0

scatter y x, aspect(1) ylabel(-5 0 5) xlabel(-5 0 5) mlcolor(%0) msize(2) ///
			mcolor(black%10) name(m1, replace) subtitle(population) 
scatter y x in 1/200, aspect(1) ylabel(-5 0 5) xlabel(-5 0 5) msize(3) ///
			mcolor(navy%50) name(m2, replace) subtitle(sample) 

keep in 1/200			
bsample, w(bw)			
scatter y x in 1/200 [w=bw], aspect(1) ylabel(-5 0 5) xlabel(-5 0 5) msize(1) ///
			mcolor(red%50) name(m3, replace) subtitle(BSample-1)
bsample, w(bw)			
scatter y x in 1/200 [w=bw], aspect(1) ylabel(-5 0 5) xlabel(-5 0 5) msize(1) ///
			mcolor(red%50) name(m4, replace) subtitle(BSample-2) 

graph combine m1 m2 m3 m4, xsize(5) ysize(5)	imargin(0 0 0 0)	
graph export bss.png	 


