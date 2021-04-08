
. two (function normal(x), range(-3.5 3.5)) ///
         (pci 0 `=invnormal(0.2)' 0.2 `=invnormal(0.2)')  ///
         (pci 0 `=invnormal(0.95)' 0.95 `=invnormal(0.95)') ///
		 (pcarrowi .4 -2 0 `=invnormal(0.2)' (12) "20th quantile " .4 -2 .2 -4, color(navy%30) ) ///
		 (pcarrowi .4  3 0 `=invnormal(0.95)' (12) "95th quantile " .4 3 .95 -4, color(navy%30) ) , ///
         xtitle("Q({&tau}) or F{superscript:-1}({&tau})") ytitle("{&tau} or F(y)") ///
		 legend(off) title(Cumulative Density Function CDF ) ylabel(0(.2)1 0.95)
graph export qr3_1.png
