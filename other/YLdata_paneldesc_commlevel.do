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
use "yc_constructed.dta", clear
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

drop if round==1|round==4
order childid urban round enrol hschool hstudy hsleep hplay timesch careladder hhsize hq_new sv_new cd_new hrsexc ttmalesib ttsib 

********* PRE-SCHOOL *********
merge 1:1 childid round using "presch_input.dta"
drop _merge
drop preid agepresc prescvis


********* PRIMARY*********
* At community level
merge m:1 commid round using "comm_prischinput.dta", update
drop _merge


********* SECONDARY *********
*At community level
merge m:1 commid round typesite using "secondaryschinput_regiontypesite.dta", update
drop _merge


* If child didnot enrol then schoolinput==0 (primary & secondary levels)
foreach v in facidx seridx device tchquali learningenv {
	replace `v'=0 if enrol==0 &(round==3|round==5)
}
* If child didnot enrol preschool then schoolinput==0 
foreach v in facidx seridx device tchquali learningenv {
	replace `v'=0 if preprim==0 &(round==2)
}

sort childid round
order childid round facidx seridx device tchquali learningenv
drop negregion

save "yc_panel.dta", replace


******************************************************************
**** 		  				Recode variables                  ****
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
mvdecode extcls hrsexc, mv(77 88 99 79=. \ -77 -88 -99 -79=. \7777 8888=.a)   //code missing values

/*****************************************************
								PPVT
*/****************************************************
tab typesite round,m
/*
   Area of |
 residence |
(urban/rur |         Round of survey
       al) |         2          3          5 |     Total
-----------+---------------------------------+----------
     urban |       407        416        437 |     1,260 
     rural |     1,563      1,545      1,504 |     4,612 
         . |        30         39         59 |       128 
-----------+---------------------------------+----------
     Total |     2,000      2,000      2,000 |     6,000 
*/

* This is a useful auxiliary variable
*  !!! This variable has to be computed anew, if one drops person-years !!!
bysort childid (round): gen pynr = _n   //person-years numbered consecutively (within person)

* Tabulating the central variables (and getting N*T and N)
tab maths_perco, missing
tab maths_perco  if pynr==1, missing
tab ppvt_perco, missing
tab ppvt_perco if pynr==1, missing

*******************************************************************************
****       Define the estimation sample  Rural - Urban                     ****
****       And control sample with type  Rural - Rural                     ****
*******************************************************************************

* Exclude person-years with missings on one or more variables 
gen help=0
replace help=1 if missing(ppvt_perco,urban)
keep if help==0
drop help pynr
bysort childid (round): gen pynr = _n            //calculate anew after each case exclusion


* Firt Only persons that were in rural areas when first observed are kept
gen help=0
replace help=1 if urban==1 & pynr==1      // =1 for the childhood in urban
bysort childid (round): replace help = sum(help) // =1 for all observations of those urban
tab help
keep if help==0                            //all observations of those only in urban are dropped
drop help pynr
bysort childid (round): gen pynr = _n            //calculate anew after each case exclusion


* We remove obs who move back to rural area
gen help=0
replace help=1 if urban==1                		//flag person-years in urban
bysort childid (round): replace help=sum(help)  //for each person, flag following person-years
gen help1 = (help>0 & urban==0)            		//help1==1 if a person move back to rural
tab help1                                  		//obviously such errors are in the data
bysort childid (round): replace help1=sum(help1) 		//we flag all following person-years
tab help1
keep if help1==0                           		//and drop them
drop help help1 pynr
bysort childid (round): gen pynr = _n            		//calculate anew after each case exclusion

* A check
tab urban, missing
tab urban if pynr==1,missing

* Finally, exclude persons with less than two observations
bysort childid:   gen pycount = _N     //# of person-years (within person)
tab pycount if pynr==1
keep if pycount > 1               //only those with 2 or more person-years are kept


****   New variables needed below    **********
bysort childid: egen treat = max(urban)        //indicator for treatment group 


*****************************************************************
***     			  Save the data set                      ****
*****************************************************************

sort childid round
// compress

tempfile ppvt_yc_constructed
save `ppvt_yc_constructed'
save "ppvt_yc_constructed.dta", replace


