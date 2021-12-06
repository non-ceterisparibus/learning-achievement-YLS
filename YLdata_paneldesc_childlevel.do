************************************************************
************************************************************
***            YC - TEST SCORE DATA                      ***
***     2: Preparing the data for analysis               ***
***		            NOV 2011                             *** 	   
************************************************************
************************************************************
* Data: YL data - young cohort
* We start with file "yc_constructed.dta"

*************************************
** Preliminaries    *****************
*************************************
clear 
set more off

* Load data
cd "D:\1.RESEARK\9.THESIS materials\thesis\data"
// ssc install estout, replace

*****************************************************************
***     	   		   ADD SCHOOL INPUT 		             ****
*****************************************************************
/*

  Child is |
 currently |               Round of survey
  enrolled |         2          3          4          5 |     Total
-----------+--------------------------------------------+----------
        no |       324         36         61        369 |       790 
       yes |     1,587      1,875      1,852      1,544 |     6,858 
-----------+--------------------------------------------+----------
     Total |     1,911      1,911      1,913      1,913 |     7,648 

*/
use "yc_constructed.dta",clear
order childid urban round enrol hschool hstudy hsleep hplay timesch careladder hq_new sv_new cd_new hrsexc hhsize ttmalesib ttsib 

 
tab caredu enrol if round==3,m
tab typesite enrol if round==3,m
/*
   Area of |
 residence |
(urban/rur |   Child is currently enrolled
       al) |        no        yes          . |     Total
-----------+---------------------------------+----------
     urban |         3        384         29 |       416 0.72%
     rural |        33      1,491         21 |     1,545 2%
         . |         0          0         39 |        39 
-----------+---------------------------------+----------
     Total |        36      1,875         89 |     2,000 

 
  Caregiver's level of |   Child is currently enrolled
            education |        no        yes          . |     Total
----------------------+---------------------------------+----------
                 None |        23        171          6 |       200 
              Grade 1 |         2         50          1 |        53 
              Grade 2 |         0         83          1 |        84 
              Grade 3 |         3        106          0 |       109 
              Grade 4 |         2        111          4 |       117 
              Grade 5 |         3        267          3 |       273 
              Grade 6 |         0        192          3 |       195 
              Grade 7 |         0        198          3 |       201 
              Grade 8 |         0        102          0 |       102 
              Grade 9 |         1        318          9 |       328 
             Grade 10 |         0         26          0 |        26 
             Grade 11 |         1         14          0 |        15 
             Grade 12 |         1        128         12 |       141 
Post-secondary, vocat |         0         75          4 |        79 
           University |         0          8          1 |         9 
   Masters, doctorate |         0          3          0 |         3 
       Adult literacy |         0          2          0 |         2 
                    . |         0         21         42 |        63 
----------------------+---------------------------------+----------
                Total |        36      1,875         89 |     2,000 

*/
 tab caredu enrol if round==5,m
  /*
  Caregiver's level of |   Child is currently enrolled
            education |        no        yes          . |     Total
----------------------+---------------------------------+----------
                 None |        66         87          1 |       154 
              Grade 1 |        19         28          0 |        47 
              Grade 2 |        19         46          0 |        65 
              Grade 3 |        30         58          1 |        89 
              Grade 4 |        33         70          3 |       106 
              Grade 5 |        63        168          4 |       235 
              Grade 6 |        31        141          0 |       172 
              Grade 7 |        33        161          3 |       197 
              Grade 8 |        13         85          0 |        98 
              Grade 9 |        41        369          5 |       415 
             Grade 10 |         3         26          0 |        29 
             Grade 11 |         1         20          1 |        22 
             Grade 12 |        10        136          6 |       152 
Post-secondary, vocat |         1         29          2 |        32 
           University |         3        104          2 |       109 
   Masters, doctorate |         0          6          0 |         6 
       Adult literacy |         2          5          0 |         7 
                    . |         1          5         59 |        65 
----------------------+---------------------------------+----------
                Total |       369      1,544         87 |     2,000
  */
 
********* PRE-SCHOOL *********
merge 1:1 childid round using "presch_input.dta"
gen sample= (_merge==3|_merge==4|_merge==5)
drop _merge
drop preid agepresc prescvis


********* PRIMARY*********
* At childlevel
merge 1:1 childid round using "primarylchild.dta", update
replace sample= (_merge==3|_merge==4|_merge==5) if sample==0
drop _merge


********* SECONDARY *********
* At childlevel
merge 1:1 childid round using "secylchild_schinput.dta",update
replace sample= (_merge==3|_merge==4|_merge==5) if sample==0
drop _merge

      
* If child didnot enrol then schoolinput==0 (primary & secondary levels) // contempora specification
replace enrol=1 if !missing(facidx) &(round==3|round==5)

foreach v in facidx seridx device tchquali hschool tchuni timesch{ 
	replace `v'=0 if enrol==0 &(round==3|round==5)
}
* If child didnot enrol preschool then schoolinput==0 
// foreach v in facidx seridx device tchquali learningenv {
// 	replace `v'=0 if preprim==0 &(round==2)
// }

tab enrol round,m
/*
  Child is |
 currently |                    Round of survey
  enrolled |         1          2          3          4          5 |     Total
-----------+-------------------------------------------------------+----------
        no |         0        324         36         61        365 |       786 
       yes |         0      1,587      1,891      1,852      1,551 |     6,881 
         . |     2,000         89         73         87         84 |     2,333 
-----------+-------------------------------------------------------+----------
     Total |     2,000      2,000      2,000      2,000      2,000 |    10,000 
*/
******************************************************************
***       		Some Other Uselful Variables     	  		  ****
******************************************************************
* Top/Bottom wealth index
gen topwi=(wi_new>=0.9)
gen botwi=(wi_new<0.1)
xtile wiquant = wi_new , nq(10)
* More able student - Top Percentile of cognitive Rasch score
xtile cogquant = rcog_co , nq(10)
gen moreable=(cogquant>=9)
bysort childid (round): replace moreable=moreable[_n-1] if round>=3
* Major Ethnic Group
gen majorethnic=(chethnic==41)
* Caregiver with tertiary education
gen carehedu=(caredu>=12&caredu<=15)
* Edit caregiver edu, take the last record for all
bysort childid (round): replace carehedu=carehedu[_N]
// * Caregiver finish secondary education
// gen carehedu=(caredu>=10&caredu<=15)
* Stunting at early age
gen stuntearly=(stunting>0 & round==2)
bysort childid (round): replace stuntearly=stuntearly[_n-1] if round>=3


********************************************************************
****       Define the estimation sample                   		****
****   Who enrol school survey	n non-enrol(school input=0)	        ****
********************************************************************
* Sampple 1 - include both current enrol and none in data
* who are currently non-enrol, school input ==0 (for contemporaneous spec)
gen nonsamp=0
replace nonsamp=1 if enrol==0 &( round==3|round==5)
bysort childid (round): replace nonsamp = sum(nonsamp)		//for each person, flag all following person-years    


******************************************************************
**** 		  		Fixing Recode variables                  ****
******************************************************************

*** Define missings
* In the YLD, there are three missing codes:
// 77=Not known – this is where the respondent says they do not know
// 88=Not applicable – this is where the question is not applicable because of a
// response given to an earlier question
// 99=Missing – the question was missed during fieldwork or was not clearly recorded;
// 79=Refused to answer – the respondent did not want to answer the question.
// 7777= NK,
// 8888=N/A, 9999= Missing
mvdecode extcls hrsexc, mv(77 88 99 79=. \ -77 -88 -99 -79=. \7777 8888=.a)   
recode caredu 28=1 //adult literacy


************************************************
***       schooling for age index         ****
*****************************************************************
bysort childid (round): replace hghgrade=hghgrade[_n-1] if hghgrade==. & (round>=3&round<=5)
replace hghgrade=engrade-1 if ((hghgrade==.)|(hghgrade>engrade))&engrade>0

* The schooling for age index, denoted as SAGE (Ray and Lancaster 2005),
* For 6-year-old children, who are currently studying grade 1, 
* the index is replaced by 1. Hence, the values of SAGE range from 0 to 1 
* note: years in education will be controlled by sage (school for age idx) 
gen yrsold=round(agemon/12)
gen sage=hghgrade/(yrsold-6) if (round==3|round==5)	
gen sagei=hghgrade-(yrsold-6)

* Keep the index in range from 0 - 1
replace sage=1 if sage<1 & (round==5 & hghgrade==9)|(round==3 & hghgrade==2)
replace sage=1 if sage>1


* Lagged dependent variable
bysort childid (round): gen ppvt_perco_L1=ppvt_perco[_n-1] 
 
*******************************************************
*** Creating the central time-yarying variable    *****
*******************************************************
replace hrsexc=0 if extcls==0|missing(hrsexc)

*** Compute time using variables
* Squared term
foreach v in timesch hschool hstudy hsleep hplay hwork hrsexc {
	egen avg_`v' = mean(`v'), by(id)
	}
	
foreach v in timesch hschool hstudy hsleep hplay hwork hrsexc {
	gen dm_`v'2 = (avg_`v' - `v')^2
	}


* Scale 100
foreach v in facidx seridx device tchquali bsstutl advstutl {
	replace `v'=`v'*100
}

foreach v in hq_new sv_new cd_new wi_new {
	replace `v'=`v'*100
}

replace tchuni= (mathtchuni==1) if tchuni==.

* LABEL 
label variable stuntearly "Early stuntness"
 label variable carehedu "Caregiver education Grade 12 or more"
  label define majority 1 "Majority" 0 "Minority"
 label define carehedu 1 "Grade 12 or more" 0 "Lower than Grade 12"
 
 
 label values carehedu carehedu
 label values majorethnic majority


* Sample after adding school input by childlevel
sort childid round
save "yc_panel.dta", replace

/*****************************************************
		BALANCE PANEL CHILD LEVEL - ROUND 3 5 - No Laged
*/****************************************************
* Include sample with schoolinput and sample drop off/non-enrol (school input =0)
keep if sample==1|nonsamp>=1	
keep if round==3|round==5
tab typesite round,m
/*
   Area of |
 residence |
(urban/rur |    Round of survey
       al) |         3          5 |     Total
-----------+----------------------+----------
     urban |       222         99 |       321 
     rural |       952        597 |     1,549 
         . |         0          3 |         3 
-----------+----------------------+----------
     Total |     1,174        699 |     1,873 
*/

* This is a useful auxiliary variable	\\person-years numbered consecutively (within person)
*  !!! This variable has to be computed anew, if one drops person-years !!!
bysort childid (round): gen pynr = _n  

* Exclude person-years with missings on one or more variables 
gen help=0
replace help=1 if missing(ppvt_perco)|missing(typesite)|missing(facidx)
keep if help==0
drop help pynr
bysort childid (round): gen pynr = _n      

bysort childid:   gen pycount = _N //only those with 2 or more person-years are kept
keep if pycount > 1

* Balanced panel with some obs move from rural to urban
save "yc35_panelo.dta", replace

// * Drop obs move to urban 
gen help=1
bysort childid: replace help=0 if typesite==typesite[_N]
bysort childid (round): replace help = sum(help)
keep if help==0

***  Save the data set  
// drop help prescdur paypresc presccre dayspres hrspresc preprim monpresch oneyear quali
sort childid round
order childid round enrol typesite zhfa stunting chhprob chhealth hsleep hschool hstudy hwork careladder hhsize hq_new sv_new cd_new ppvt_perco cog_perco maths_perco hrsexc urban facidx seridx device tchquali


save "yc35_panel.dta", replace


********************************************************************
*** 	BALANCE PANEL CHILD LEVEL - ROUND 3 5 -	 W Lagged    *****
********************************************************************
* Include sample with schoolinput and sample drop off/non-enrol (school input =0)
use "yc35_panel.dta", clear
drop if ppvt_perco_L1==.
// keep if sample==1|nonsamp>=1	
// keep if round==3|round==5
tab typesite round,m
/*
   Area of |
 residence |
(urban/rur |    Round of survey
       al) |         3          5 |     Total
-----------+----------------------+----------
     urban |        41         51 |        92 
     rural |       407        432 |       839 
-----------+----------------------+----------
     Total |       448        483 |       931 

*/


* This is a useful auxiliary variable	\\person-years numbered consecutively (within person)
*  !!! This variable has to be computed anew, if one drops person-years !!!
bysort childid (round): gen pynr = _n  

* Exclude person-years with missings on one or more variables 
gen help=0
replace help=1 if missing(ppvt_perco)|missing(typesite)|missing(facidx)
keep if help==0
drop help pynr
bysort childid (round): gen pynr = _n      

bysort childid: gen pycount = _N //only those with 2 or more person-years are kept
keep if pycount > 1

* Balanced panel with some obs move from rural to urban
save "yc35_panelo_lagged.dta", replace


// * Drop obs move to urban 
gen help=1
bysort childid: replace help=0 if typesite==typesite[_N]
bysort childid (round): replace help = sum(help)
keep if help==0
*****************************************************************
***     			  Save the data set                      ****
*****************************************************************
drop help prescdur paypresc presccre dayspres hrspresc preprim monpresch oneyear quali
sort childid round
order childid round enrol typesite zhfa stunting chhprob chhealth hsleep hschool hstudy hwork careladder hhsize hq_new sv_new cd_new ppvt_perco cog_perco maths_perco hrsexc urban facidx seridx device tchquali

// * Edit caregiver edu, take the last record for all
// bysort childid (round): replace carehedu=carehedu[_N]


save "yc35_panel_lagged.dta", replace
