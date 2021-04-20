
webuse iris, clear
scatter sepwid seplen 
graph export stata_sc_1.png

twoway  scatter sepwid seplen if iris==1 || ///
        scatter sepwid seplen if iris==2 || ///
        scatter sepwid seplen if iris==3

		
twoway  (scatter sepwid seplen if iris==1) ///
        (scatter sepwid seplen if iris==2) ///
        (scatter sepwid seplen if iris==3) 		
		
twoway  (scatter sepwid seplen if iris==1) ///
        (scatter sepwid seplen if iris==2) ///
        (scatter sepwid seplen if iris==3), ///
        legend(order(1 "Sectosa" 2 "Versicolor" 3 "Virginica")) 		
graph export stata_sc_2.png
		
		
twoway  (scatter sepwid seplen if iris==1, color(forest_green%10)) ///
        (scatter sepwid seplen if iris==2, color(forest_green%40)) ///
        (scatter sepwid seplen if iris==3, color(forest_green%80)), ///
        legend(order(1 "Sectosa" 2 "Versicolor" 3 "Virginica")) 				
graph export stata_sc_3.png
		
		
twoway  (scatter sepwid seplen if iris==1, color(gold) symbol(O)) ///
        (scatter sepwid seplen if iris==2, color(gold) symbol(T)) ///
        (scatter sepwid seplen if iris==3, color(gold) symbol(S)), ///
        legend(order(1 "Sectosa" 2 "Versicolor" 3 "Virginica")) 						

graph export stata_sc_4.png
		
twoway  (scatter sepwid seplen if iris==1, color(red) msize(small)) ///
        (scatter sepwid seplen if iris==2, color(red) msize(medium)) ///
        (scatter sepwid seplen if iris==3, color(red) msize(large)), ///
        legend(order(1 "Sectosa" 2 "Versicolor" 3 "Virginica"))

graph export stata_sc_5.png
		
		
twoway  (scatter sepwid seplen if iris==1, color("240 120 140") ) ///
        (scatter sepwid seplen if iris==2, color("100 190 150") ) ///
        (scatter sepwid seplen if iris==3, color("125 190 230") ), ///
        legend(order(1 "Sectosa" 2 "Versicolor" 3 "Virginica")) 			

graph export stata_sc_6.png
		
twoway  (scatter sepwid seplen if iris==1, color("72 27 109") symbol(O)) ///
        (scatter sepwid seplen if iris==2, color("33 144 140") symbol(T)) ///
        (scatter sepwid seplen if iris==3, color("253 231 37") symbol(s)), ///
        legend(order(1 "Sectosa" 2 "Versicolor" 3 "Virginica") col(3)) ///
		title(Sepal length vs Sepal width) subtitle(plot within different Iris Species)
		
graph export stata_sc_7.png
		
twoway  (scatter sepwid seplen if iris==1, color("72 27 109") symbol(O)) ///
        (scatter sepwid seplen if iris==2, color("33 144 140") symbol(T)) ///
        (scatter sepwid seplen if iris==3, color("253 231 37") symbol(s)) ///
		(  lfitci sepwid seplen if iris==1, clcolor("72 27 109") clwidth(0.5)  acolor(%50) ) ///
        (  lfitci sepwid seplen if iris==2, clcolor("33 144 140") clwidth(0.5)  acolor(%50) ) ///
        (  lfitci sepwid seplen if iris==3, clcolor("253 231 37") clwidth(0.5)  acolor(%50) ), ///
        legend(order(1 "Sectosa" 2 "Versicolor" 3 "Virginica") col(3)) ///
		title(Sepal length vs Sepal width) subtitle(plot within different Iris Species)		

graph export stata_sc_8.png
		
twoway  (scatter sepwid seplen if iris==1, color("72 27 109") symbol(O)) ///
        (scatter sepwid seplen if iris==2, color("33 144 140") symbol(T)) ///
        (scatter sepwid seplen if iris==3, color("253 231 37") symbol(s)) ///
		(  lpolyci sepwid seplen if iris==1, clcolor("72 27 109") clwidth(0.5)  acolor(%50) ) ///
        (  lpolyci sepwid seplen if iris==2, clcolor("33 144 140") clwidth(0.5)  acolor(%50) ) ///
        (  lpolyci sepwid seplen if iris==3, clcolor("253 231 37") clwidth(0.5)  acolor(%50) ), ///
        legend(order(1 "Sectosa" 2 "Versicolor" 3 "Virginica") col(3)) ///
		title(Sepal length vs Sepal width) subtitle(plot within different Iris Species)		

graph export stata_sc_9.png		