mata:
y = st_data(.,"y")
x = st_data(.,"x1 x2 x3 x4"),J(rows(y),1,1) 
it = st_data(.,"it")
end

** Getting Betas and STD ERRORS

mata:
i1=(it:==1)
i2=(it:==2)
i3=(it:==3)
i4=(it:==4)
b1=invsym(cross(x,i1,x))*cross(x,i1,y)
b2=invsym(cross(x,i2,x))*cross(x,i2,y)
b3=invsym(cross(x,i3,x))*cross(x,i3,y)
b4=invsym(cross(x,i4,x))*cross(x,i4,y)
e1=(y-x*b1)
e2=(y-x*b2)
e3=(y-x*b3)
e4=(y-x*b4)
end

** Getting IF by group

mata:
if1=(x:*i1:*e1)*invsym(cross(x,i1,x))*mean(x,i4)'
if2=(x:*i2:*e2)*invsym(cross(x,i2,x))*mean(x,i4)' 
if3=(x:*i3:*e3)*invsym(cross(x,i3,x))*mean(x,i4)'
if4=(x:*i4:*e4)*invsym(cross(x,i4,x))*mean(x,i4)'

att=(if4:-if3):-(if2:-if1)
mata:mean(x,i3:+i4)*((b4:-b3):-(b2:-b1))
end

mata:cross(att,att):^.5 

** Classic bootstrap

program drop didb
program didb, eclass
capture drop i00 i01 i10 i11
reg y x1 x2 x3 x4 if it==1
predict i00
reg y x1 x2 x3 x4 if it==2
predict i01
reg y x1 x2 x3 x4 if it==3
predict i10
reg y x1 x2 x3 x4 if it==4
predict i11
capture drop did
gen did = i11-i10-i01+i00
sum did if it==4, meanonly
matrix b=r(mean)
ereturn post b
end

bootstrap, reps(100):didb
** variance in X?
