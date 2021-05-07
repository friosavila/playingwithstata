/** Command 
drdid: Doubly Robust  DID
Syntax
drdid outcome xvars if (conditions), ivar(panelidvar) time(timevar) tr(treatment group)
xvar: This are all controls for the oucome model and for the propensity score
ivar: must include the panel identifier
time: Variable identifying Time.
tr: Variable identify ever treated group
*/
** Example
drdid re age educ black married nodegree hisp re74 if treated==0 | sample==2 , ivar(id) time(year) tr( experimental )  
** need to think of doing this via Moptimize
