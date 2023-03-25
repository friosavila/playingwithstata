** example for drdid sim data
clear
set obs 1000

gen u =rnormal()
gen trd=runiform()*0.5
gen trt=runiform()*0.5
gen d = runiformint(1,2)
gen t = runiformint(1,2)
gen byte id =1 if d==1 & t==1
replace  id =2 if d==1 & t==2
replace  id =3 if d==2 & t==1
replace  id =4 if d==2 & t==2
gen x1=rnormal(0.25*d,1-0.1*d)
gen x2=rnormal(0.25*d,1-0.1*d)
gen x3=rnormal(0.25*d,1-0.1*d)
gen x4=rnormal(0.25*d,1-0.1*d)

** treatment effect random and aditive?
gen y00=0.5+0.4*x1+0.7*x2+0.2*x3-0.4*x4+u
gen y10=1  +0.2*x1+0.5*x2-0.3*x3-0.4*x4+u
gen y01=y00+trd
gen y11=y10+trd+trt




 gen  y = (d==1 & t==1)*y00 + ///
                  (d==1 & t==2)*y01 + ///
                  (d==2 & t==1)*y10 + ///
                  (d==2 & t==2)*y11 


reg y x1 x2 x3 x4 if d==1 & t==1
predict yh00
reg y x1 x2 x3 x4 if d==1 & t==2
predict yh01
reg y x1 x2 x3 x4 if d==2 & t==1
predict yh10
reg y x1 x2 x3 x4 if d==2 & t==2
predict yh11

gen dd = (yh11-yh10) - (yh01-yh00)
sum dd


drdid y x1 x2 x3 x4 , time(t) treat(d) all

sum dd trt if d==2
sum dd trt if d==2 & t==1

gmm (eq1:(y-{b00:x1 x2 x3 x4 _cons})*(id==1)) ///
	(eq2:(y-{b01:x1 x2 x3 x4 _cons})*(id==2)) ///
	(eq3:(y-{b10:x1 x2 x3 x4 _cons})*(id==3)) ///
	(eq4:(y-{b11:x1 x2 x3 x4 _cons})*(id==4)) ///
	(att:({b11:}-{b10:}-({b01:}-{b00:}) - {attx})) , ///
	instruments(eq1: x1 x2 x3 x4) instruments(eq2: x1 x2 x3 x4)  ///
	instruments(eq3: x1 x2 x3 x4)  instruments(eq4: x1 x2 x3 x4)  ///
	onestep winit(identity)
margins , expression(xb(#4)-xb(#3)-(xb(#2)-xb(#1)))	
mata
y = st_data(.,"y")
x = st_data(.,"x1 x2 x3 x4"), J(1000,1,1)
id= st_data(.,"id")
end

mata:
xx1=cross(x,id:==1,x)
xx2=cross(x,id:==2,x)
xx3=cross(x,id:==3,x)
xx4=cross(x,id:==4,x)
ixx1=invsym(xx1)
ixx2=invsym(xx2)
ixx3=invsym(xx3)
ixx4=invsym(xx4)
b1=ixx1*cross(x,id:==1,y)
b2=ixx2*cross(x,id:==2,y)
b3=ixx3*cross(x,id:==3,y)
b4=ixx4*cross(x,id:==4,y)
re1=(y-x*b1):*(id:==1)
re2=(y-x*b2):*(id:==2)
re3=(y-x*b3):*(id:==3)
re4=(y-x*b4):*(id:==4)
iff1=(x:*re1)*ixx1
iff2=(x:*re2)*ixx1
iff3=(x:*re3)*ixx1
iff4=(x:*re4)*ixx1

mata:attrif=(iff4-iff3-iff2+iff1)*1000
mata:sd=mean(x,id:==1)*variance(attrif)*mean(x,id:==1)'
end
	
mata:(mean(x,id:==1)*cross(iff1,id:==1,iff1)*mean(x,id:==1)'):^.5
mata:(mean(x,id:==1)*b1)
mata:b1