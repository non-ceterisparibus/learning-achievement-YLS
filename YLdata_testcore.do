***********************************************************
************************************************************
***          Vietnam Young Lives data                    ***
***		    		Thu Duong           	     		 *** 	   
***		            Oct 2021 	                         *** 	   
************************************************************
************************************************************

* Data: Vietnam YLD

*****************************************************
****************** Preliminaries    *****************
*****************************************************


/* number of observations 
tab yc round if inround==1
	
       Younger |
     cohort=1; |                    Round of survey
Older cohort=0 |         1          2          3          4          5 |     Total
---------------+-------------------------------------------------------+----------
  Older cohort |     1,000      1,000        976        887        910 |     4,773 
Younger cohort |     2,000      1,970      1,961      1,932      1,938 |     9,801 
---------------+-------------------------------------------------------+----------
         Total |     3,000      2,970      2,937      2,819      2,848 |    14,574 */
		 


/*-----------------------------------------------------------------------------*
								DATA SETS - YOUNGER COHORT
------------------------------------------------------------------------------*/

* Set system memory and define working directories
clear 
set more off
// set mem 600m


*  Directories
cd "D:\YL\data"

/*-----------------------------------------------------------------------------*
						 RAW TEST SCORES - EXTRA CLASSES YC 
------------------------------------------------------------------------------*/

***** PANEL INFORMATION *****
* ROUND 2
	use "vn_r2_childlevel5yrold.dta",clear
	keep CHILDID score_ppvt score_cog rscorelang_cog rscorelang_ppvt
	rename (CHILDID score_ppvt rscorelang_cog rscorelang_ppvt) (childid ppvt_raw rcog_co rppvt_co)
	gen ppvt_perco = (ppvt_raw*100)/204
	gen cog_perco = (score_cog*100)/15
	gen round=2
	tempfile r2
	save `r2'
* ROUND 3
	use "vn_r3yc_childlevel.dta", clear
	rename *, lower
	merge 1:1 childid using "vn_r3yc_householdlevel.dta", keep(master match) // take extra classes infor
	keep childid ppvt rppvt_co math math_co rmath_co egra egra_co regra_co extclsr3 hrsexcr3 mnyexr3 dffpygr3
	rename (ppvt math egra) (ppvt_raw maths_raw egra_raw)
	gen ppvt_perco = (ppvt_raw*100)/204
	gen maths_perco = (maths_raw*100)/29
	rename *r3 *
	gen round=3
	tempfile r3
	save `r3'
* ROUND 4
	use "vn_r4_yccog_youngerchildtest.dta"
	merge 1:1 CHILDCODE using "vn_r4_ychh_youngerhousehold.dta", keep(master match)// take extra classes infor
	drop _merge
	merge 1:1 CHILDCODE using `chmobi4', keep(master match) 							//merge with child mobility to use moving communities
	gen childid="VN"+string(CHILDCODE, "%06.0f")
	keep childid lang_raw lang_perco maths_raw maths_perco ppvt_raw ppvt_perco typecomm EXTCLSR4 HRSEXCR4 MNYEXR4 DFFPYGR4
	rename *R4 *
	rename *, lower
	gen round=4
	tempfile r4
	save `r4'

* ROUND 5
	use "vn_r5_yccog_youngerchild.dta"
	merge 1:1 CHILDCODE using "vn_r5_ychh_youngerchildanthroandppvt.dta", keep(master match)
	drop _merge
	merge 1:1 CHILDCODE using "vn_r5_ychh_youngerhousehold.dta", keep(master match)// take extra classes infor
	drop _merge
	merge 1:1 CHILDCODE using `chmobi5', keep(master match)						//merge with child mobility to use moving communities
	gen childid="VN"+string(CHILDCODE, "%06.0f")
	keep childid maths_raw maths_perco read_raw read_perco ppvt_raw ppvt_perco typecomm HRSEXCR5 MNYEXR5 EXTCLSR5 DFFPYGR5
	rename *R5 *
	rename *, lower
	gen round=5
	tempfile r5
	save `r5'

	
* APPEND
	use `r2', clear
	forvalues i=3/5 {
				qui append using `r`i''
				}	
// 	g panel2345=inr2==1 & inr3==1 & inr4==1 & inr5==1

tempfile  testscore
save     `testscore'

save "yc_testscore.dta", replace
/*-----------------------------------------------------------------------------*
					   EDUCATION HISTORY
------------------------------------------------------------------------------*/
* Primary
	use "vn_r4_ychh_educationhistoryindexchild.dta"
	rename *R4 *
	tempfile edu4
	save `edu4', replace
* Secondary
	use "vn_r5_ycch_educationhistoryindexchild.dta"
	rename *R5 *
	tempfile edu5
	save `edu5', replace

* APPEND
	use `edu4', clear
	append using `edu5', force
	
	recode EDCHST 1=13 2=14 3=15 4=16
	sort CHILDCODE EDCHST
	label define EDCHST 5 "2005-06" 6 "2006-07" 7 "2007-08" 8 "2008-09" 9 "2009-10" ///
	10 "2010-11" 11 "2011-12" 12 "2012-13" 13 "2013-14" 14 "2014-15" 15 "2015-16" 16 "2016-17", replace
	
	gen childid="VN"+string(CHILDCODE, "%06.0f")
	drop CHILDCODE
	
* LABELS
	label var childid		"Child ID"
	
* FIXING MISSING VALUE if SAME_SCHOOL == YES
foreach v of varlist TYSC PROV SITE SCHNME {
	replace `v'=`v'[_n-1] if missing(`v') & SAMESC==1 
}
	tempfile  eduhistory
	save     `eduhistory'

save "yc_eduhistory.dta", replace
