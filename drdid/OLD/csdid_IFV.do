mata:attg=st_data(.,"_g2004_2003_2004 _g2006_2005_2006 _g2007_2006_2007")
mata:wgt =st_data(.,"w_2004           w_2006            w_2007")

mata:atte = sum(mean(attg):*mean(wgt)):/sum(mean(wgt))
mata:wgtw = (mean(wgt)) :/sum(mean(wgt))
mata:attw = (mean(attg)):/sum(mean(wgt))
mata:r1   = (wgtw:*(attg:-mean(attg)))
mata:r2   = (attw:*(wgt:-mean(wgt)))
mata:r3   = (wgt:-mean(wgt)) :*atte :/ (sum(mean(wgt)))
mata:x=rowsum(r1)+rowsum(r2)-rowsum(r3)
mata:sqrt(mean(x:^2)/500)
   
    
