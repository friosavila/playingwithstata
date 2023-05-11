** Visual Delta Method
clear
set obs 1000
gen p =((2*_n-1)/(2*_N))
gen theta = invnormal(p)*0.2 +1 
gen etheta = exp(theta)
gen petha = exp(1) + exp(1)*(invnormal(p)*0.2) 

gen theta2 = invnormal(p)*0.5 +1 
gen etheta2 = exp(theta2)
gen petha2 = exp(1) + exp(1)*(invnormal(p)*0.5) 

color_style tableau
line etheta theta , name(m1, replace) subtitle(Small Variation)
two kdensity etheta || kdensity petha , name(m2, replace) legend(order(1 "True Distribution" 2 "DM Approximation"))
line etheta2 theta2 , name(m3, replace) subtitle(Large Variation)
two kdensity etheta2 || kdensity petha2 , name(m4, replace) legend(order(1 "True Distribution" 2 "DM Approximation"))

graph combine m1 m2 m3 m4, imargin(0 0 0 0 )
graph export dm.png