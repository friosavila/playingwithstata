** Ridge by hand
sysuse oaxaca, clear
keep if lnwage!=.
gen male = 1-female
mata
y = st_data(.,"lnwage")
x = st_data(.,"educ exper female male"),J(1434,1,1)
i0 = I(5);i0[5,5]=0
xx = (cross(x,x)) ; xy = (cross(x,y))
bb0 = invsym(xx)*xy 
bb1 = invsym(xx:+i0*1)*xy 
bb10 = invsym(xx:+i0*10)*xy 
bb100 = invsym(xx:+i0*100)*xy 
bb1000 = invsym(xx:+i0*1000)*xy 
bb0,bb1,bb10,bb100,bb1000
end 

frause oaxaca, clear
keep if lnwage!=.
reg lnwage i.age
predict p_ols
elasticnet linear lnwage i.age, selection(cv, alllambdas)  alpha(0)
coefpath, lineopts(lwidth(thick)) xunits(lnlambda) title("RIDGE") name(m1, replace)
lasso linear lnwage i.age, selection(cv, alllambdas)  
coefpath, lineopts(lwidth(thick)) xunits(lnlambda) title("LASSO") name(m2, replace)
elasticnet linear lnwage i.age, selection(cv, alllambdas)   
coefpath, lineopts(lwidth(thick)) xunits(lnlambda) title("Elastic") name(m3, replace)

two line p_* age if age>20, sort legend(order(1 "OLS" 2 "Ridge" 3 "Lasso" 4 "Elastic"))

graph combine m1 m2, xsize(10) ysize(6) imargin(0 0)
graph export lasso_ridge.png