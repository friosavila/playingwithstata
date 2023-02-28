{smcl}
{* *! version 1 }{...}

{title:Title}

{phang}
{bf:jwdid post-estimation} {hline 2} JWDID Post Estimation 

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:estat}
[aggregation]
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt simple}} Estimates the ATT for all groups across all periods.{p_end}
{synopt:{opt group}}Estimates the ATT for each group or cohort, over all periods.{p_end}
{synopt:{opt calendar}}Estimates the ATT for each period, across all groups or cohorts.{p_end}
{synopt:{opt event}}Dynamic aggregation. When default option is used (not-yet treated)
this option only provides the post-treatment ATT aggregations.{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:jwdid} comes with a basic post-estimation command that estimates 4 types of aggregations: Simple, Calendar, group and event/dynamic ATTs. These are similar to the aggregations based on {cmd:csdid}.

{pstd}
All estimations are constructed using {help margins} turning on and off the "treatment" dummy __tr__. You can use many margins options, including "post" to store the output for further reporting.

{pstd}
When other estimation methods are used (probit/poisson) margins are calculated based on the default options in margins. 

{marker remarks}{...}
{title:Remarks}

{pstd}
This code shows how simple is to produce Aggregations for ATT's based on this approach. However, as experienced with the first round of CSDID, when you have too many periods and cohorts, the aggregations may take some time. At some point, I will attempt to write the Mata code to make aggregations as fast as with csdid.

{pstd}
Also, all errors are my own. And this code was not necessarily checked by Prof Wooldridge. So if something looks different from his, look into his work.

{marker examples}{...}
{title:Examples}

{phang} Setup: Estimation of ATTGTs without controls using not-yet treated groups

{phang}{stata "ssc install frause"}
{phang}{stata "frause mpdta.dta, clear"}

{phang}{stata "jwdid lemp, ivar(countyreal) tvar(year) gvar(first_treat)"}{p_end}

{phang} Aggregations:

{phang}{stata "estat simple"}{p_end}
{phang}{stata "estat calendar"}{p_end}
{phang}{stata "estat group"}{p_end}
{phang}{stata "estat event"}{p_end}

{phang} Using Never treated as controls

{phang}{stata "jwdid lemp, ivar(countyreal) tvar(year) gvar(first_treat) never"}{p_end}

{phang}{stata "estat simple"}{p_end}
{phang}{stata "estat calendar"}{p_end}
{phang}{stata "estat group"}{p_end}
{phang}{stata "estat event"}{p_end}

{phang} Using a single control variable 

{phang}{stata "jwdid lemp lpop, ivar(countyreal) tvar(year) gvar(first_treat) "}{p_end}

{phang}{stata "estat simple"}{p_end}
{phang}{stata "estat calendar"}{p_end}
{phang}{stata "estat group"}{p_end}
{phang}{stata "estat event"}{p_end}

{phang} Using a single control variable and poisson

{phang}{stata "gen emp = exp(lemp)"}{p_end}
{phang}{stata "jwdid emp lpop, ivar(countyreal) tvar(year) gvar(first_treat) method(poisson)"}{p_end}

{phang}{stata "estat simple"}{p_end}
{phang}{stata "estat calendar"}{p_end}
{phang}{stata "estat group"}{p_end}
{phang}{stata "estat event"}{p_end}

{phang} Using a different outcome

{phang}{stata "estat event, predict(xb)"}{p_end}

{marker authors}{...}
{title:Authors}

{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org

{marker references}{...}
{title:References}

{phang2}Wooldridge, Jeffrey. 2021.
Two-Way Fixed Effects, the Two-Way Mundlak Regression, and 
Differences-in-Differences 
estimators. Working paper.{p_end}

{phang2}Wooldridge, Jeffrey. 2022.
Simple Approaches to Nonlinear Difference-in-Differences 
with Panel Data. Working paper.{p_end}


{marker acknowledgement}{...}
{title:Acknowledgement}

{pstd}This command was put together just for fun, and 
as my last push of "productivity" before my 
baby girl was born! {p_end}

{title:Also see}

{p 7 14 2}
Help:  {help drdid}, {help csdid}, {help csdid_postestimation}, 
{help jwdid}, {help xtdidregress} {p_end}

