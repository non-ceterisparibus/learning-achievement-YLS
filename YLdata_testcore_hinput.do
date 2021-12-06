************************************************************
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
// global pfad1 `""D:\1.RESEARK\9.THESIS materials\thesis\YLdata""'        //directory of original data 
// global pfad2 `""D:\1.RESEARK\9.THESIS materials\thesis\data""'       //working directory
cd "D:/1.RESEARK/9.THESIS materials/thesis/data"

/*-----------------------------------------------------------------------------*
					   CHILD MOBILITY
------------------------------------------------------------------------------*/

* Fixing child location with child mobility file in round 4 and 5
* we dont have information about child mobility in other rounds, so we will have to drop those observation
* ROUND 2 /3
use "vietnam_constructed.dta",clear
keep if round==3|round==2 & yc==1
keep childid round region typesite

tempfile chmobi23
save `chmobi23',replace

* ROUND 4 RSNMVR41
use "vn_r4_ychh_childmobility.dta", clear
rename *R4 *
rename *R41 *
gen round=4
tempfile chmobi4
save `chmobi4', replace

* ROUND 5
use "vn_r5_ycch_childmobility.dta", clear
rename *R5 *
rename *R51 *
gen round=5
gen MVEMEM=.
replace MVEMEM = cond(MVALNE==1,0, cond(MVFTHR==1, 1,cond(MVMTHR==1, 2, cond(MVSIBL==1, 4,cond(MVOTRL==1, 5, cond(MVNONH==1,90,.))))))
replace MVEMEM = cond(MVFTHR==1&MVMTHR==1&MVSIBL==1,80,cond(MVFTHR==1&MVMTHR==1,3, cond(MVSPSE==1| MVSPFM==1,6,MVEMEM)))

append using `chmobi4'
label define MVEMEM 0 "Moved alone" 1 "Father only" 2 "Mother only" 3 "Both parents" 4 "Siblings only" 5 "Another household member" //
77 "NK" 79 "Refused to answer" 80 "Moved with all household members" 88 "NA" 90 "Moved with non-household member(s)" 6 "With Spouse", replace
label values MVEMEM MVEMEM


* Edit new merged-file
mvdecode YRMOVE MSMOVE, mv(-77 -88 -99 -79=.)
mvdecode MVEMEM, mv(77 88 99 79=.)
gen childid="VN"+string(CHILDCODE, "%06.0f")
gen typesite=.
replace typesite=2 if LOCMVE==4 // Rural
replace typesite=1 if LOCMVE<4 | LOCMVE==5 //Urban
label define typesite 1 "Urban" 2 "Rural"
label values typesite typesite
sort childid YRMOVE
order childid typesite CHMVID YRMOVE MSMOVE RSNMV MVEMEM
gen mobi=1

append using `chmobi23'
recode mobi .=0

// bysort childid (round): replace mobi = sum(mobi)

tempfile chmobi
save `chmobi', replace
save "child_mobility.dta",replace


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
					HOUSEHOLD MEMBER - MALE SIBLINGS
------------------------------------------------------------------------------*/
* ROUND 1
use "vnsubsec2householdroster1.dta"								// In Round 1, there is no record for own YL child

gen sibling = (RELATE==5| RELATE ==10| RELATE==12 )
gen malesib = ((RELATE==5| RELATE ==10| RELATE==12 )& SEX==1)
*Total sibs
bysort CHILDID: gen ttsib = sum(sibling)
*Total male sibs						
bysort CHILDID: gen ttmalesib = sum(malesib)			
*keep only max number of siblings or male sibling for each YL child
bysort CHILDID (ttsib): keep if _n==_N	
keep CHILDID ttsib ttmalesib
gen round =1

tempfile  malesib1
save     `malesib1'
* ROUND 2
use "vnsubhouseholdmember5.dta",clear
gen sibling = (inrange(RELATE,6,13))
gen malesib = (inrange(RELATE,6,13)& MEMSEX==1)
*Total sibs
bysort CHILDID: gen ttsib = sum(sibling)
*Total male sibs						
bysort CHILDID: gen ttmalesib = sum(malesib)			
*keep only max number of siblings or male sibling for each YL child
bysort CHILDID (ttsib): keep if _n==_N
keep CHILDID ttsib ttmalesib
gen round =2

tempfile  malesib2
save     `malesib2'
* ROUND 3
use "vn_yc_householdmemberlevel.dta", clear
gen sibling = (inrange(RELATE,6,13))
gen malesib = (inrange(RELATE,6,13)& MEMSEX==1)
*Total sibs
bysort CHILDID: gen ttsib = sum(sibling)
*Total male sibs						
bysort CHILDID: gen ttmalesib = sum(malesib)			
*keep only max number of siblings or male sibling for each YL child
bysort CHILDID (ttsib): keep if _n==_N						
keep CHILDID ttsib ttmalesib

gen round =3
tempfile  malesib3
save     `malesib3'
* ROUND 4
use "vn_r4_ychh_householdrosterr4.dta", clear 
gen sibling = (inrange(RELATER4,6,13))
gen malesib = (inrange(RELATER4,6,13)& MEMSEXR4==1)						
bysort CHILDCODE: gen ttsib = sum(sibling)						
bysort CHILDCODE: gen ttmalesib = sum(malesib)					

bysort CHILDCODE (ttsib): keep if _n==_N						
keep CHILDCODE ttsib ttmalesib
gen CHILDID="VN"+string(CHILDCODE, "%06.0f")
drop CHILDCODE
gen round =4

tempfile  malesib4
save     `malesib4'

* ROUND 5
use "vn_r5_ychh_householdrosterr5.dta", clear
gen sibling = (inrange(RELATER5,6,13))
gen malesib = (inrange(RELATER5,6,13)& MEMSEXR5==1)
*Total sibs
bysort CHILDID: gen ttsib = sum(sibling)
*Total male sibs						
bysort CHILDID: gen ttmalesib = sum(malesib)			
*keep only max number of siblings or male sibling for each YL child
bysort CHILDID (ttsib): keep if _n==_N					
keep CHILDCODE ttsib ttmalesib
gen CHILDID="VN"+string(CHILDCODE, "%06.0f")
drop CHILDCODE
gen round =5

tempfile  malesib5
save     `malesib5'

* APPEND
use `malesib1', clear
forvalues i=2/5 {
				qui append using `malesib`i''
				}
 
label var ttsib "Total siblings of YL child"
label var ttmalesib "Total male siblings of YL child"

sort CHILDID round
order CHILDID round ttmalesib ttsib
tempfile  malesiblings
save     `malesiblings'

save "yc_malesiblings.dta", replace

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

/*-----------------------------------------------------------------------------*
*-----------------------------------------------------------------------------*
					   SUMMARY
*-----------------------------------------------------------------------------*
------------------------------------------------------------------------------*/
use "vietnam_constructed.dta", clear
keep childid yc round inround commid typesite region chsex chlang chethnic agemon zhfa zwfl //
stunting chhprob chhealth cladder hhsize hsleep hcare hchore htask hwork hschool hstudy hplay ///
agegr1 hghgrade enrol engrade timesch careid caredu careage careldr4yrs careladder ///
momedu dadedu wi_new hq_new sv_new cd_new
*** First, keep only young cohort
keep if yc==1 			

merge 1:1 childid round using "yc_testscore.dta", keep(master match)
drop _merge
merge 1:1 childid round using "yc_malesiblings.dta", keep(master match)
drop _merge

*** Fixing location of child - ROUND 4|5
replace typesite=typecomm if (round==4| round==5) & missing(typesite)
	

* Generate some useful variables
gen female = chsex-1 		
gen urban = cond(typesite==1,1,cond(typesite==2,0,.))

* LABELS
label variable cog_perco "Percentage score in cognitive test"
label var maths_perco "Percentage score in maths"
label var ppvt_perco "Percentage score in PPVT"
	
* ADD SCHOOL INPUT - PRIMARY SCHOOLS
*1 FOR CHILDREN EXISTING IN SCHOOL SURVEY 

tempfile  yc_constructed
save     `yc_constructed'
save "yc_constructed.dta", replace

