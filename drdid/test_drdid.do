cscript
use lalonde, clear
global xvar age educ black married nodegree hisp re74

drdid re $xvar if treated==0 | sample==2,   time(year) tr( experimental ) drimp

set seed 1
drdid re $xvar if treated==0 | sample==2,   time(year) tr( experimental ) drimp wboot

drdid re $xvar if treated==0 | sample==2,   time(year) tr( experimental ) drimp wboot seed(1)
