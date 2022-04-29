************************************************************
************************************************************
***     YC - FIXED EFFECT WITH QUADRATIC TERM            ***
***     2:  							                 ***
***		            NOV 2011                             *** 	   
************************************************************
************************************************************

* Data: YL data - young cohort

* We start with file "yc_panel.dta.dta"

*************************************
** Preliminaries    *****************
*************************************
clear 
set more off


* Load data
cd  "D:\1.RESEARK\9.THESIS materials\thesis\data"    //Adapt this path!
use "yc35_panel.dta", clear


***** Declare data to be panel data *****
encode childid,gen(id)
xtset id round

*******************************************************
*** Creating the central time-yarying variable    *****
*******************************************************

*** Compute time using variables
* Squared term
foreach v in timesch hschool hstudy hsleep hplay hwork hrsexc {
	egen avg_`v' = mean(`v'), by(id)
	}
	
foreach v in timesch hschool hstudy hsleep hplay hwork hrsexc {
	gen dm_`v'2 = (avg_`v' - `v')^2
	}

foreach v in hq_new sv_new cd_new {
	egen avg_`v' = mean(`v'), by(id)
	}
	
	
	
********************************************************************************
***  		  			  Contemporaneous Specification				************
********************************************************************************	
* Pooled OLS
quietly reg ppvt_perco urban majorethnic female stuntearly moreable carehedu zhfa bsstutl advstutl tchuni hschool hstudy hplay hrsexc hschool2 hstudy2 hplay2 hrsexc2 hq_new sv_new cd_new facidx seridx device sagei, vce(cluster id)
est store POLS

* Random-Effects Regression
quietly xtreg  ppvt_perco urban majorethnic female stuntearly moreable carehedu zhfa bsstutl advstutl tchuni hschool hstudy hplay hrsexc hschool2 hstudy2 hplay2 hrsexc2 hq_new sv_new cd_new facidx seridx device sagei, re vce(cluster id) theta
est store RE

* Panel-robust S.E.s (alternative: vce(robust))
quietly xtreg ppvt_perco zhfa bsstutl advstutl tchuni hschool hstudy hplay hrsexc hschool2 hstudy2 hplay2 hrsexc2 dm_hschool2 dm_hstudy2 dm_hplay2 dm_hrsexc2 hq_new sv_new cd_new facidx seridx device sagei, fe vce(cluster id)
est store FE

* Table of estimation results
//  estimates table POLS RE FE , b(%7.2f) star stfmt(%6.0f) stats(N N_clust) 
esttab POLS BE FE using "./out/cross_model2.tex", label p scalars(N F)

*************************************************************
**** Interation with school input - contemporaneous
*************************************************************

**** Urban/rural specific school input impact
gen X=urban
quietly xtreg ppvt_perco i.X#(c.facidx c.seridx c.device c.hschool c.sagei c.hschool2 c.dm_hschool2) ttmalesib hrsexc hstudy hplay hstudy2 hplay2 hrsexc2 dm_hstudy2 dm_hplay2 dm_hrsexc2 hq_new sv_new cd_new bsstutl advstutl zhfa, fe  vce(cluster id)
est store FEurbanschl

**** Major ethnicity  school input impact
replace X=majorethnic
quietly xtreg ppvt_perco i.X#(c.facidx c.seridx c.device c.hschool c.sagei c.hschool2 c.dm_hschool2 i.tchuni) hrsexc hstudy hplay hstudy2 hplay2 hrsexc2  dm_hstudy2 dm_hplay2 dm_hrsexc2 hq_new sv_new cd_new bsstutl advstutl zhfa, fe  vce(cluster id)
est store FEethnicschl

**** More able specific school input impact
replace X=moreable
quietly xtreg ppvt_perco i.X#(c.facidx c.seridx c.device c.hschool c.sagei c.hschool2 c.dm_hschool2) hrsexc hstudy hplay hstudy2 hplay2 hrsexc2  dm_hstudy2 dm_hplay2 dm_hrsexc2 hq_new sv_new cd_new bsstutl advstutl zhfa, fe  vce(cluster id)
est store FEableschl

**** Gender specific school input impact
replace X=female
quietly xtreg ppvt_perco i.X#(c.facidx c.seridx c.device c.hschool c.sagei c.hschool2 c.dm_hschool2) hrsexc hstudy hplay hstudy2 hplay2 hrsexc2  dm_hstudy2 dm_hplay2 dm_hrsexc2 hq_new sv_new cd_new bsstutl advstutl zhfa, fe  vce(cluster id)
est store FEgenschl

**** Stunt specificschool input impact
replace X=stuntearly
quietly xtreg ppvt_perco i.X#(c.facidx c.seridx c.device c.hschool c.sagei c.hschool2 c.dm_hschool2) hrsexc hstudy hplay hstudy2 hplay2 hrsexc2  dm_hstudy2 dm_hplay2 dm_hrsexc2 hq_new sv_new cd_new bsstutl advstutl zhfa, fe  vce(cluster id)
est store FEstuntschl

**** Caregiver school input impact
replace X=carehedu
quietly xtreg ppvt_perco i.X#(c.facidx c.seridx c.device c.hschool c.sagei c.hschool2 c.dm_hschool2) hrsexc hstudy hplay hstudy2 hplay2 hrsexc2  dm_hstudy2 dm_hplay2 dm_hrsexc2 hq_new sv_new cd_new bsstutl advstutl zhfa, fe  vce(cluster id)
est store FEcareschl

* Table of estimation results
// estimates table FEurbanschl FEethnicschl FEableschl FEgenschl FEstuntschl FEcareschl, b(%9.4f) se(%9.4f) p(%9.4f)  
esttab FEurbanschl FEethnicschl FEableschl FEgenschl FEstuntschl FEcareschl using "./out/schoolimpact2.tex", drop(hrsexc hstudy hplay hq_new sv_new cd_new bsstutl advstutl zhfa) label p scalars(N F)

************************************************************
*******           Continuous Impact Function    ************
************************************************************

* This is the FE model with quadratic IF
replace X=carehedu
quietly xtreg ppvt_perco i.X#(c.facidx c.seridx c.device c.hschool c.sagei c.hschool2 c.dm_hschool2) hrsexc hstudy hplay hstudy2 hplay2 hrsexc2 dm_hstudy2 dm_hplay2 dm_hrsexc2 hq_new sv_new cd_new bsstutl advstutl zhfa, fe  vce(cluster id)
**************************************
* Caregiver school input impact
**************************************
* Nested effects specification
xtreg happy i.woman#(i.marry c.yrsmarried##c.yrsmarried) loghhinc age, fe vce(cluster id)

* Are the time paths significantly different?
test (1.marry                     # 0.woman = 1.marry                     # 1.woman) ///
     (c.yrsmarried                # 0.woman = c.yrsmarried                # 1.woman) ///
     (c.yrsmarried # c.yrsmarried # 0.woman = c.yrsmarried # c.yrsmarried # 1.woman)

* Plotting the marginal marriage effects by sex (Conditional Effect Plot)
* The plot with margins does not work??
/* margins, at(marry=(0 1) yrsmarried=(0(1)15)) contrast(atcontrast(r._at) lincom) over(woman)
marginsplot, recast(line) recastci(rline) yline(0, lcolor(black)) x(yrsmarried)  */

* Therefore, we use a plot "made by hand"
for new bm sesm bw sesw : generate X=.
forvalues y=0/20 {
	quietly lincom 1.marry#0.woman + c.yrsmarried#0.woman*`y' + c.yrsmarried#c.yrsmarried#0.woman*`y'*`y'
	quietly replace bm   = r(estimate)   if _n==`y'+1	
	quietly replace sesm = r(se)         if _n==`y'+1	
}
generate upperm=bm+1.96*sesm    // upper CI
generate lowerm=bm-1.96*sesm    // lower CI
forvalues y=0/20 {
	quietly lincom 1.marry#1.woman + c.yrsmarried#1.woman*`y' + c.yrsmarried#c.yrsmarried#1.woman*`y'*`y'
	quietly replace bw   = r(estimate)   if _n==`y'+1	
	quietly replace sesw = r(se)         if _n==`y'+1	
}
generate upperw=bw+1.96*sesw    // upper CI
generate lowerw=bw-1.96*sesw    // lower CI
generate md    = _n-1           // artificial time axis starting at 0 (for plotting)
line bw bm md if md<=15, sort           ///
        lpattern(solid solid)                   /// 
        lwidth(thick thick)             ///       
        lcolor(red blue)                          ///
        ylabel(-.3(.1).5, grid angle(0) labsize(medium) format(%3.1f))   /// 
		xlabel(0(1)15, labsize(medium))                                  ///
        yline(0, lcolor(black))                                          ///
        legend(pos(7) ring(0) row(2) order (1 2) lab(1 "Women")          ///
		     lab(2 "Men") size(medlarge))                                /// 
        xtitle("Years since marriage", size(large) margin(0 0 0 2))      ///
        ytitle("Effect of 'marriage' on happiness", size(large))         ///
        title("Conditional Effect Plot by Sex")
