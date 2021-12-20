************************************************************
************************************************************
***            YC - TEST SCORE DATA                      ***
***     2: Maths IRT constructed School Survey           ***
***		            NOV 2011                             *** 	   
************************************************************
************************************************************



*************************************
** Preliminaries    *****************
*************************************
clear 
set more off

cd  "D:\1.RESEARK\9.THESIS materials\thesis\data"    //Adapt this path!
*****************************************************************
***     	   		PRIMARY SCHOOL SURVEY 		             ****
*****************************************************************

*** MATHS TEST
* Round 1
use "vn_pupillevelanonymous.dta",clear

forvalues num =1/9{
      rename CMCORR0`num' CMCORR`num'
   }
  
forvalues num =1/9{
      rename CVCORR0`num' CVCORR`num'
   }
   
forvalues num =1/30{
      replace CMCORR`num'=0 if CMCORR`num'==.
	  recode CMCORR`num' 2=0
   }
   
forvalues num =1/30{
      replace CVCORR`num'=0 if CVCORR`num'==.
	  recode CVCORR`num' 2=0
   }
 
mvdecode CMCORR1 - CMCORR30 CVCORR1 - CVCORR30, mv(77 88 99 79=.)
egen mtraw = rowtotal(CMCORR1 - CMCORR30) if mathPresAbs==1
egen vtraw = rowtotal(CVCORR1 - CVCORR30) if vietPresAbs==1
gen uniqueid = schlid+ classid+ pupilid

raschtest CMCORR1 - CMCORR30,id(uniqueid) genlt(ltscore)
gen maths_irt = (50 + 10*ltscore)/10

keep schlid classid ethgrp pupilid ylchild uniqueid childid CMCORR* mtraw vtraw vtscore mtscore //CVCORR*
gen round=1

tempfile prischlr1
save `prischlr1',replace


* Retest
use "vn_rt_pupilleveldata.dta",clear

forvalues num =1/9{
      rename CMCRR20`num' CMCRR2`num'
   }
  
forvalues num =1/9{
      rename CVCRR20`num' CVCRR2`num'
   }
   
forvalues num =1/30{
      replace CMCRR2`num'=0 if CMCRR2`num'==.
	  recode CMCRR2`num' 2=0
   }
   
forvalues num =1/30{
      replace CVCRR2`num'=0 if CVCRR2`num'==.
	  recode CVCRR2`num' 2=0
   }
 
mvdecode CMCRR21 - CMCRR230 CVCRR21 - CVCRR230, mv(77 88 99 79=.)
egen mtraw = rowtotal(CMCRR21 - CMCRR230) if mathPresAbsR2==1
egen vtraw = rowtotal(CVCRR21 - CVCRR230) if vietPresAbs2==1

* rename column in retest to same name in the first wave
rename (CMCRR2* CVCRR2*) (CMCORR* CVCORR*)
keep schlid classid pupilid ylchild childid vtraw mtraw CMCORR* CVCORR* //CMCRR2* CVCRR2*
gen round=2
gen uniqueid = schlid+ classid+ pupilid

raschtest CMCORR1 - CMCORR30,id(uniqueid) genlt(ltscore)
gen maths_irt = (50 + 10*ltscore)/10

tempfile prischlr2
save `prischlr2',replace

append using `prischlr1'
// merge 1:1 uniqueid using `prischlr1',update
gen mtperco = mtraw/30*100
gen vtperco = vtraw/30*100
sort schlid classid pupilid round
gen school=1	// primary schools

save "prischlsv_testscore.dta",replace

twoway kdensity mtraw if round==1 || kdensity mtraw if round==2
twoway kdensity vtraw if round==1 || kdensity vtraw if round==2

*****************************************************************
***     	   	SECONDARY SCHOOL SURVEY 		             ****
*****************************************************************
* Round 1
use "vietnam_wave_1.dta",clear

keep UNIQUEID SCHOOLID CLASSID YLCHILDID STDYLCHD LOCALITY MATH_RAWSCORE ENG_RAWSCORE
gen round=1

gen mtscore = MATH_RAWSCORE/40*100
gen engscore = ENG_RAWSCORE/40*100

tempfile secschlr1
save `secschlr1',replace

* Retest

use "vietnam_wave_2.dta",clear

forvalues num =1/23{
      replace TS_ITEM`num'=0 if TS_ITEM`num'==.
   }

egen TS_RAW = rowtotal(TS_ITEM1-TS_ITEM23) if TS_TEST=="Yes"

keep UNIQUEID SCHOOLID CLASSID YLCHILDID STDYLCHD MATH_ITEM* MATH_RAWSCORE ENG_RAWSCORE TS_RAW
gen round=2
gen mtperco = MATH_RAWSCORE/40*100
gen engperco = ENG_RAWSCORE/40*100
gen tsperco= TS_RAW/46*100

// rename MATH_RAWSCORE mtraw

tempfile secschlr2
save `secschlr2',replace

append using `secschlr1'
sort UNIQUEID round

gen school=2 // secondary schools
label define school 1 "primary" 2 "secondary"
label values school school

save "secschlsv_testscore.dta",replace

twoway kdensity MATH_RAWSCORE if round==1 || kdensity MATH_RAWSCORE if round==2
twoway kdensity ENG_RAWSCORE if round==1 || kdensity ENG_RAWSCORE if round==2



****************************************************************************
save "schoolsurvey_test_merged.dta" // merge retest in 2 school survey
