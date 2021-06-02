mata:
y = st_data(.,"_g*")
c = st_data(.,"c")
end

mata:ord = order(c,1)
mata:_editmissing(y,0)
mata:y=y[ord,]
mata:c=c[ord,]
mata:info = panelsetup(c,1)
mata:info

mata:
xcros=J(12,12,0)
for(i=1;i<=rows(info);i++){
    sub=panelsubmatrix(y,i,info)
	s=cross(J(rows(sub),1,1),sub)
	xcros=xcros+cross(s,s)
}
end

mata:cross(y,y):-xcros
