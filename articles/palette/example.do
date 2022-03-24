program drop simdata
program simdata, rclass
	clear
	set obs 100
	gen t = _n
	forvalues i=1/`1' {
	gen x`i'=runiform()
	replace x`i'=abs(0.9*x`i'[_n-1]+rnormal()) if _n>1
	lpoly x`i' t, bw(2.5) kernel(gaussian) at(t) gen(f`i') nograph
	}
	gen ff0=0

	forvalues i=1/`1' {
	gen ff`i'=ff`=`i'-1'+f`i'
	}

	forvalues i=0/`1' {
		replace ff`i'=ff`i'-0.5*ff`1'
	}
	forvalues i=1/`1' {
		local j=`i'-1
		local ll `ll' (rarea ff`j' ff`i' t, fintensity(100))
	}
	return local ll `ll'
end

set graph off
foreach i in Austria Cassatt1 Cassatt2 Cross Degas Derain Egypt Gauguin Greek ///
Hiroshige Hokusai1 Hokusai2 Hokusai3 Homer1 Homer2 Ingres Isfahan1 Isfahan2 Juarez ///
Klimt Lakota Manet Monet Moreau Morgenstern Nattier Navajo NewKingdom Nizami ///
OKeeffe1 OKeeffe2 Peru1 Peru2 Pillement Pissaro Redon Renoir Robert Signac /// 
Stevens Tara Thomas Tiepolo Troy Tsimshian VanGogh1 VanGogh2 VanGogh3 Veronese Wissing Benedictus Demuth Java ///
Johnson Kandinsky Paquin Tam Archambault Starfish  Shuksan  Bay  Winter  Lake ///
Sunset  Shuksan2  Cascades Sailboat  Moth Spring  Mushroom  Sunset2  Anemone BottleRocket1 ///
BottleRocket2 Rushmore1  Rushmore Royal1  Royal2 Zissou1  Darjeeling1 Darjeeling2  Chevalier1 FantasticFox1 ///
Moonrise1 Moonrise2  Moonrise3 Cavalcanti1  GrandBudapest1 GrandBudapest2  IsleofDogs1 IsleofDogs2 FrenchDispatch {

	color_style `i', nograph    
	set seed `=r(n)'
	qui:simdata `=r(n)'
	two `r(ll)' , xlabel("") ylabel("") legend(off) xtitle("") title("`i'")
	graph export `i'_stack.png, replace
}

************
cd "C:\Users\Fernando\Dropbox\projects\00 Stata Projects\graph\palette"
set graph off
foreach i in Austria Cassatt1 Cassatt2 Cross Degas Derain Egypt Gauguin Greek ///
Hiroshige Hokusai1 Hokusai2 Hokusai3 Homer1 Homer2 Ingres Isfahan1 Isfahan2 Juarez ///
Klimt Lakota Manet Monet Moreau Morgenstern Nattier Navajo NewKingdom Nizami ///
OKeeffe1 OKeeffe2 Peru1 Peru2 Pillement Pissaro Redon Renoir Robert Signac /// 
Stevens Tara Thomas Tiepolo Troy Tsimshian VanGogh1 VanGogh2 VanGogh3 Veronese Wissing Benedictus Demuth Java ///
Johnson Kandinsky Paquin Tam Archambault Starfish  Shuksan  Bay  Winter  Lake ///
Sunset  Shuksan2  Cascades Sailboat  Moth Spring  Mushroom  Sunset2  Anemone BottleRocket1 ///
BottleRocket2 Rushmore1  Rushmore Royal1  Royal2 Zissou1  Darjeeling1 Darjeeling2  Chevalier1 FantasticFox1 ///
Moonrise1 Moonrise2  Moonrise3 Cavalcanti1  GrandBudapest1 GrandBudapest2  IsleofDogs1 IsleofDogs2 FrenchDispatch {
	clear
	color_style `i', nograph    
	set obs `=r(n)'
	set seed `=r(n)'
	gen id=_n
	gen x=0.5+2*runiform()^2
	color_style `i', nograph
	graph pie x, over(id) legend(off) pie(_all,explode) title("Pie: `i'")
	graph export `i'_pie.png, replace
}

**** violin
set graph off
foreach i in Austria Cassatt1 Cassatt2 Cross Degas Derain Egypt Gauguin Greek ///
Hiroshige Hokusai1 Hokusai2 Hokusai3 Homer1 Homer2 Ingres Isfahan1 Isfahan2 Juarez ///
Klimt Lakota Manet Monet Moreau Morgenstern Nattier Navajo NewKingdom Nizami ///
OKeeffe1 OKeeffe2 Peru1 Peru2 Pillement Pissaro Redon Renoir Robert Signac /// 
Stevens Tara Thomas Tiepolo Troy Tsimshian VanGogh1 VanGogh2 VanGogh3 Veronese Wissing Benedictus Demuth Java ///
Johnson Kandinsky Paquin Tam Archambault Starfish  Shuksan  Bay  Winter  Lake ///
Sunset  Shuksan2  Cascades Sailboat  Moth Spring  Mushroom  Sunset2  Anemone BottleRocket1 ///
BottleRocket2 Rushmore1  Rushmore Royal1  Royal2 Zissou1  Darjeeling1 Darjeeling2  Chevalier1 FantasticFox1 ///
Moonrise1 Moonrise2  Moonrise3 Cavalcanti1  GrandBudapest1 GrandBudapest2  IsleofDogs1 IsleofDogs2 FrenchDispatch {
	
	clear
	qui {
	color_style `i', nograph  
	set obs 50
	local nn `=r(n)'
	set seed `=r(n)'
	forvalues j=1/`nn' {
		local l=rnormal()
		gen r`j'=rnormal()+`l'
	}
	range x -6 6 50
	forvalues j=1/`nn' {
		kdensity r`j', kernel(gaussian) gen(f1`j') at(x) nograph
		replace f1`j'=0.5*f1`j'
		gen f0`j'=-f1`j'
		replace f1`j'=f1`j'+0.25+`j'*.5
		replace f0`j'=f0`j'+0.25+`j'*.5
	}
	local rar
	display in w "`nn'"
	forvalues j=1/`nn' {
		local rar `rar' (rarea f1`j' f0`j' x, horizontal )
	}
	two `rar', legend(off) xlabel("") ylabel("") xtitle("") ytitle("") title("Violin: `i'")
	}
	graph export `i'_vio.png, replace
}

 
