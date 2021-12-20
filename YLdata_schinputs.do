************************************************************
************************************************************
***            YC - SCHOOL INPUT	                     ***
***     2: Preparing the data for analysis               ***
***		            NOV 2011                             *** 	   
************************************************************
************************************************************

* Set system memory and define working directories
clear 
set more off
// set mem 600m
cd "D:\YL\data"

/*-----------------------------------------------------------------------------*
					   COMMUNE - TYPESITE
------------------------------------------------------------------------------*/
use "vietnam_constructed.dta",clear
* Round 2 - Pre school
keep if round==2 & yc==1
keep  childid commid preprim agemon region typesite hsleep hcare hchore htask hwork hschool hstudy hplay

save "r2preschool_age.dta",replace

* Round 3 - Primary school
keep if round==3 & yc==1
keep commid region typesite
duplicates drop region commid typesite, force
save "r3region.dta",replace

* Round 5 - Secondary school (Upper)
keep if round==5 & yc==1
keep commid region typesite
duplicates drop region commid typesite, force
save "r5region.dta",replace

* Round 5 - Secondary YL child (Upper)
keep if round==5 & yc==1
keep childid childloc commid region typesite 
save "r5childid.dta",replace

/*-----------------------------------------------------------------------------*
					   SCHOOL LIST
------------------------------------------------------------------------------*/
use "vn_r5_comm_allschools.dta", clear

* SCHOOL LEVEL
gen SCHLEVEL=0
replace SCHLEVEL=1 if SCHLOW==1 & SCHHIGH<5
replace SCHLEVEL=2 if SCHLOW==6 & SCHHIGH<9
replace SCHLEVEL=3 if SCHLOW==10 & SCHHIGH==12
replace SCHLEVEL=23 if SCHLOW==6 & SCHHIGH==12
replace SCHLEVEL=33 if SCHLOW==1 & SCHHIGH>5
label define SCHLEVEL 0"Preschool" 1 "Primary" 2 "Lower-secondary" 3 "Upper-secondary" 23 "Mixed-secondary" 33"Mixed", replace
label var SCHLEVEL "School Level(pre primary secondary)"

/*-----------------------------------------------------------------------------*
*-------------------------------------------------------------------------------*
								PRE SCHOOL INPUTS
*-------------------------------------------------------------------------------*
------------------------------------------------------------------------------*/
use "vn_r2_vnsubpreschool5.dta",clear
mvdecode _all, mv(77 88 99 79=. \ -77 -88 -99 -79=. \7777 8888=.a)
rename *,lower
rename presctyp schtype
recode schtype 1=2 2=4 4=3 3=1 5=4
label define schtype 1 "Public" 2 "Private" 3 "People founded" 4 "Other"
label values schtype schtype

* Time in pre school
merge m:1 childid using "r2preschool_age.dta"
drop _merge
gen monpresch = agemon - agepresc + 1
bysort childid (preid): replace monpresch=sum(monpresch)

gen oneyear =cond(prescdur==3|(monpresch >=12&prescdur==4),1,cond(monpresch>0,0,.))
gen quali = cond(presccre==1,1,cond(presccre==2,0.8,cond(presccre==3,0.6,cond(presccre==4,0.4,cond(presccre==5,0.2,0)))))

foreach v in facidx seridx device tchquali{
	gen `v'=quali
}

* Fix time use by child - by median of community ID
replace preprim =cond((hrspresc>0)&(preprim==.),1,preprim)
replace hschool = cond((hschool==.)&(preprim==1),hrspresc,cond((hschool==.)&(preprim==0),0,hschool))

foreach v in hsleep hcare hchore htask hwork hstudy hplay {
	egen median = median(`v'), by(commid)
	replace `v'=median if `v'==.
	drop median
}

gen round=2
* LABELS
label var monpresch "Cumulative months in preschools"
label var oneyear "Attend preschool more or equal 1 year"

* keep latest record
bysort childid : keep if preid==preid[_N]
tempfile presch_input
save `presch_input'

save "presch_input.dta",replace

/*-----------------------------------------------------------------------------*
-------------------------------------------------------------------------------*
					PRIMARY SCHOOL INPUTS - CLASS LEVEL
-------------------------------------------------------------------------------*
-------------------------------------------------------------------------------*/
* Add data  and merge
use "vn_teacherlevelanonymous.dta",clear
merge m:1 schlid using "vn_schoollevelanonymous.dta"
drop _merge
merge m:1 prncid using "vn_principalleveldata.dta"
drop _merge
mvdecode _all, mv(77 88 99 79=. \ -77 -88 -99 -79=. \7777 8888=.a)
/*
    schlid: string variable ignored
     classid: string variable ignored
     teachID: string variable ignored
    tchistrn: 5 missing values generated
     mthwork: 2 missing values generated
     commune: string variable ignored
      siteid: string variable ignored
      prncid: string variable ignored
     feetrai: 6 missing values generated
*/
* Average year of teaching exp by school
. egen avg_tchyrtot = mean(tchyrtot), by(schlid)
(1 missing value generated)

. sort schlid

. order schlid classid avg_tchyrtot

**********************************************************************************************
******** Creat School Input index score (average of components) by region urban-rural  ********
***********************************************************************************************

*** Generate some useful variables for index ****
gen safewatr = (facwatr==1)
gen needrepair =(G5REPAIR==0)
gen fullday = (G5FDSC==1|G5FDSC==2|G5FDSC==0)
* Qualified headmaster with University degree
gen headuni=(prneduc==5) 					
* Qualified teacher with Uni and college degree	
gen tchuni=(tchedu==4|tchedu==5)				
* Learning environment in class
foreach v in prbatten prblate prbdisc prbpwom prblack prbinter{
	gen `v'1=cond(`v'==0,1,cond(`v'==1,0.5,cond(`v'==2,0,.)))
}

* Classroom facilities
egen count = rownonmiss(seproom clboard clmap clcabin cltdesk cllight clfan)
egen a = rowtotal(seproom clboard clmap clcabin cltdesk cllight clfan),missing 
gen facidx = a/count
drop count a
*generate access to services (safewater toilet lib electric internet, availability of fullday schooling
egen count = rownonmiss(safewatr facsept faclib facintn facelec  fullday)
egen a= rowtotal(safewatr faclib facsept facintn facelec fullday),missing
gen seridx = a/count
drop count a		 
* Advanced learning devices
egen count = rownonmiss(cltv clvideo clradio clohp clcomp)
egen a = rowtotal(cltv clvideo clradio clohp clcomp),missing
gen device = a/count
drop count a					
* Include teacher and headmaster qualification and learning environment
egen count = rownonmiss(prbatten1 prblate1 prbdisc1 prbpwom1 prblack1 prbinter1)
egen a = rowtotal(prbatten1 prblate1 prbdisc1 prbpwom1 prblack1 prbinter1),missing
gen tchquali=a/count
drop count a				

*****************************************************************************************
*****************************************************************************************
* Now we fix missing value of school input in regions which dont appear in School Survey
* using average score of same typesite of same region or average score of same typesite of all region ( if region is Other 58)
* First, add typesite
rename commune commid
merge m:1 commid using "r3region.dta"
drop _merge

*** Graph ***
// histogram tchquali, by(typesite)
* ssc install meansdplot
meansdplot facidx typesite,median outer(2) ytitle(Facility Index) xlabel(1 "Urban" 2 "Rural") 
meansdplot seridx typesite,median outer(2) ytitle(Access to Service Index) xlabel(1 "Urban" 2 "Rural") 
meansdplot tchquali typesite,median outer(2) ytitle(Teaching Quali Index) xlabel(1 "Urban" 2 "Rural") 
meansdplot device typesite,median outer(2) ytitle(Class Devices Index) xlabel(1 "Urban" 2 "Rural")
// gr combine faci.gph serv.gph tquali.gph dev.gph lenv.gph, col(1) iscale(1)

* Calculate mean-median school input indexes by region-typesite
foreach v of varlist facidx seridx device tchquali{
	bysort region typesite: egen m`v'=mean(`v')	
	bysort region typesite: egen md`v'= median(`v')									
}

* Update rural - For other region - we take average of all regions
* In rural areas, we have data varying by region, so we will sort data by typesite and region
foreach v of varlist facidx seridx device tchquali {
	* For 5 YL sites
	bysort typesite region: replace `v'=md`v' if `v'==.
	* "Other" region (3 data points)
	egen median = median(`v'), by(typesite)
	replace `v'=median if m`v'==.
	drop median
}

*update urban - replace index of each missing-value commid by the median value of commid-region index
* Remember that we only have urban data in DaNang so we dont need to sort by region for urban
foreach v of varlist facidx seridx device tchquali {
	bysort typesite (m`v'): replace m`v'=m`v'[_n-1] if missing(m`v') & typesite==1
	bysort typesite (md`v'): replace md`v'=md`v'[_n-1] if missing(md`v') & typesite==1
	replace `v'=md`v' if missing(`v') & typesite==1
}

* LABELS
			label var facidx		"School facilities index "
			label var seridx		"Access to service index"
			label var device	 	"Teaching devices index "
			label var tchquali	 	"Teaching quality index"
			label var headuni	 	"Does the headmaster have Uni degree (qualified)"
			label var tchuni		"Does the teacher have college degree (qualified)"

// tempfile prischinput
// save `prischinput'


keep schlid classid schtype commid region typesite absent studenr emstud tchwork tchprivt headuni tchuni //
facidx seridx device tchquali mfacidx mseridx mdevice mtchquali mdfacidx mdseridx mddevice mdtchquali 

save "prischinput.dta",replace

* Now we first merge childid with original school input
* Drop NA value, keep class-level


*****************************************************************
***     	   		YLchild level input 		             ****
*****************************************************************
drop if missing(schtype)
merge 1:m schlid classid using "vn_pupillevelanonymous.dta"
drop _merge

********         Creat Home Input Index by ChildID  		  ********

egen count = rownonmiss(homestch homedesk homelamp OUVTBKV1 OUVTBKV2 ouvtdict OUMATH5 ouothmt ouscbag ouruler)
egen a = rowtotal(homestch homedesk homelamp OUVTBKV1 OUVTBKV2 ouvtdict OUMATH5 ouothmt ouscbag ouruler),missing
gen bsstutl = a/count
drop count a

egen count = rownonmiss(homecomp homeintn oucalc oucell)
egen a = rowtotal(homecomp homeintn oucalc oucell),missing
gen advstutl = a/count
drop count a

keep if ylchild==1
gen round = 3
keep childid vtscore mtscore round schlid classid schtype commid region typesite 	///
bsstutl advstutl absent studenr emstud tchwork tchprivt headuni tchuni facidx seridx device tchquali 	///
mfacidx mseridx mdevice mtchquali mdfacidx mdseridx mddevice mdtchquali

save "primarylchild.dta",replace 		// YL child with school input - 


* Now we then need (median) school input at commid-level or region-typesite 
*****************************************************************
***     	  Commid-region level input 		             ****
*****************************************************************
use "prischinput.dta",clear
drop schlid classid studenr emstud absent tchwork tchprivt
gen round=3

foreach v of varlist facidx seridx device tchquali {
	egen median = median(`v'), by(commid)
	replace m`v'=median if !missing(schtype)
	replace `v'=median if !missing(schtype)
	drop median					
}
duplicates drop region commid typesite, force

save "comm_prischinput.dta",replace

/*-----------------------------------------------------------------------------*
-------------------------------------------------------------------------------*
					SECONDARY SCHOOL INPUTS - CLASS LEVEL
------------------------------------------------------------------------------*
------------------------------------------------------------------------------*/
* Add data 
use "vietnam_wave_1.dta",clear
rename YLCHILDID childid

merge m:1 childid using "r5childid.dta"
drop _merge
drop if missing(SCHOOLID)
order SCHOOLID typesite region
sort typesite SCHOOLID region
sort SCHOOLID typesite
bysort SCHOOLID: replace typesite=typesite[_n-1] if missing(typesite)
bysort SCHOOLID: replace region=region[_n-1] if missing(region)
replace typesite=cond(LOCALITY==1,2,cond(LOCALITY==2,1,.)) if missing(typesite)
replace region = cond(PROVINCE==1,57,cond(PROVINCE==2, 54,cond(PROVINCE==3, 52, cond(PROVINCE==4, 51,cond(PROVINCE==5, 53,.))))) if missing(region)
// save "vietnam_wave_1_fixed.dta",replace

merge 1:1 UNIQUEID using "vietnam_wave_2.dta"
drop _merge
* recode missing values
// mvdecode _, mv(77 88 99 79=. \ -77 -88 -99 -79=.a)

egen avg_engtchyrtot = mean(ENG_TCYRTCH), by(SCHOOLID )
egen avg_mathtchyrtot = mean(MATH_TCYRTCH), by(SCHOOLID )

egen ncount = rownonmiss(avg_engtchyrtot avg_mathtchyrtot)
egen a = rowtotal(avg_engtchyrtot avg_mathtchyrtot), missing
gen avg_tchyrtot = a/ncount

***********************************************************************************************
******** Creat School Input index score (average of components) by region urban-rural  ********
***********************************************************************************************
* Generate some useful variables for index	
gen totalstud = HTENGR10 + HTENBY10 + HTENGR11 + HTENBY11 + HTENGR12 + HTENBY12
gen totalclass = HTNMCL10 + HTNMCL11 + HTNMCL12
replace totalstud = HTNMSTEN if totalstud==.	
gen studenr = (totalstud)/(HTNMCL10 + HTNMCL11 + HTNMCL12)				
gen safewatr = (SCHFAC12==1)
gen needrepair =(SCHFAC14==0)
gen wktoilet = (SCHFAC10>0)
gen wktoiletr = (SCHFAC10)/(totalclass*2)
replace wktoiletr=1 if wktoiletr>1
gen schlab= (SCHFAC01B>0)
gen schlabr= (SCHFAC01B)/totalclass
gen comp = (SCHFAC06>0)
gen compr = (SCHFAC06*2)/totalstud
replace compr=cond(comp==.,0,cond(compr>1,1,compr))

* Headmaster with University degree only
gen headuni=(HTLVLEDC==4|HTLVLEDC==5)					
* Teacher university degree only (Qualified standard for Upper secondary)										
gen engchuni=(ENG_TCLVLEDC==4|ENG_TCLVLEDC==5)													
gen mathtchuni=(MATH_TCLVLEDC==4|MATH_TCLVLEDC==5)
* Minor ethnic student group per class
gen emstud = HTNMETST / totalclass
gen eng_absent = ENG_TCDAYPRS + ENG_TCHABSC
gen math_absent = MATH_TCDAYPRS + MATH_TCHABSC
gen absent = (eng_absent + math_absent)/2
* Purpose of non-compulsory classes (if remedies for weaker student - equalize opportunites)
gen equalstudy = cond(HTNOCMCL==1|HTNOCMCL==3,1,cond(HTNOCMCL==0|HTNOCMCL==2,0,.))

* Learning environment in class
foreach v in ENG_TCPRATD ENG_TCLATENS ENG_TCDISCPL ENG_TCNOMAT ENG_TCLACKRS ENG_TCINTRRP{
	gen `v'1=cond(`v'==0,1,cond(`v'==1,0.5,cond(`v'==2,0,.)))
}

foreach v in MATH_TCPRATD MATH_TCLATENS MATH_TCDISCPL MATH_TCNOMAT MATH_TCLACKRS MATH_TCINTRRP{
	gen `v'1=cond(`v'==0,1,cond(`v'==1,0.5,cond(`v'==2,0,.)))
}

*generate school facilities index (class facilities school sport areas )
egen count = rownonmiss(SCHFAC02 SCAVLB1 SCAVLB2 SCAVLB3 SCAVLB4 SCAVLB6 SCAVLB7 SCAVLB8 SCHFAC07 )
egen a = rowtotal(SCHFAC02 SCAVLB1 SCAVLB2 SCAVLB3 SCAVLB4 SCAVLB6 SCAVLB7 SCAVLB8 SCHFAC07),missing
gen facidx = a/count
drop count a
*generate access to services (safewater toilet,electric, library, internet, non-compulsory classes
egen count = rownonmiss(safewatr SCHFAC11 SCHFAC03 SCHFAC04 SCHFAC05 HTNOCMCH)
egen a = rowtotal(safewatr SCHFAC11 SCHFAC03 SCHFAC04 SCHFAC05 HTNOCMCH),missing
gen seridx = a/count
drop count a
*other learning devices	(computer, lab/class, IT facilities) - take just yes or no as primary school
egen count = rownonmiss(comp schlab SCAVLB10)
egen a = rowtotal(comp schlab SCAVLB10),missing
gen device =a/count
drop count a
*learning environment
egen count = rownonmiss(MATH_TCPRATD1 MATH_TCLATENS1 MATH_TCDISCPL1 MATH_TCNOMAT1 MATH_TCLACKRS1 MATH_TCINTRRP1)
egen a = rowtotal(MATH_TCPRATD1 MATH_TCLATENS1 MATH_TCDISCPL1 MATH_TCNOMAT1 MATH_TCLACKRS1 MATH_TCINTRRP1),missing
gen tchquali  = a/count
drop count a				

* LABELS

rename (DISTRICTCODE SCHOOLID CLASSID HTTYPSCH MATH_TCEXTWRK MATH_TCHRTUTR ENG_TCEXTWRK ENG_TCHRTUTR MATH_RAWSCORE ENG_RAWSCORE)	///
(distid schlid classid schtype math_tchwork math_tchprivt eng_tchwork eng_tchprivt mtraw engraw)
					 
// label define region 51 "Northern Uplands" 52 "Red River Delta" 53 "Phu Yen" 54 "Da Nang" 55 "Highlands" 56 "South Eastern" 57 "Mekong River Delta"  58 "Other", modify
// label values region region
// label var region 		"Region of residence"
	
* Typesite code in Secondary School Survey are in the reverse of constructed file
// gen typesite=cond(LOCALITY==1,2,cond(LOCALITY==2,1,.))
// label define typesite 1 "Urban" 2 "Rural"
// label values typesite typesite
tostring schlid classid,replace

tempfile secschlinput_all
save `secschlinput_all'

save "secschlinput_all_fixed.dta",replace
*****************************************************************
***     	   		YLchild level input 		             ****
*****************************************************************
* Keep only YLchild
keep if STDYLCHD==1

****  Creat Home Input Index by ChildID *****

egen count = rownonmiss(STHVDESK STHVCHR STHVLAMP STITMOW1 STITMOW3 STITMOW5 STITMOW6)
egen a = rowtotal(STHVDESK STHVCHR STHVLAMP STITMOW1 STITMOW3 STITMOW5 STITMOW6),missing
gen bsstutl = a/count
drop count a

egen count = rownonmiss(STITMOW8 STHVINTR STHVCOMP STITMOW7)
egen a = rowtotal(STITMOW8 STHVINTR STHVCOMP STITMOW7),missing
gen advstutl = a/count
drop count a

mvdecode STRPTCL1 STRPTCL6 STRPTCL10, mv(77 88 99 79=. )
gen regrade = cond(STRPTCL1>0|STRPTCL6>0|STRPTCL10>0,1,.)

keep childid schlid distid classid schtype typesite region regrade bsstutl advstutl studenr compr schlabr wktoiletr emstud math_tchwork math_tchprivt eng_tchwork eng_tchprivt headuni mathtchuni engchuni facidx seridx device tchquali
gen round=5
* Save child-level school input - DETAIL CHILD-LEVEL INPUT
save "secylchild_schinput.dta",replace				


*****************************************************************
***     	   		CLASSSSS level input 		             ****
*****************************************************************
**********************************************************
* Remember that current dataset at student level of each class
* We only need data at class level to calculate median school input at class level by region-typesit
use "secschlinput_all_fixed.dta", clear

keep distid schlid classid schtype typesite region studenr emstud math_tchwork math_tchprivt eng_tchwork eng_tchprivt headuni mathtchuni engchuni facidx seridx device tchquali 
* Drop duplicate classes
duplicates drop schlid classid, force 
order schlid classid schtype typesite region

*** Graph ***
* ssc install meansdplot
meansdplot facidx typesite, median outer(2) ytitle(Facility Index) xlabel(1 "Urban" 2 "Rural")
meansdplot seridx typesite, median outer(2) ytitle(Access to Service Index) xlabel(1 "Urban" 2 "Rural") 
meansdplot tchquali typesite, median outer(2) ytitle(Teaching Quali Index) xlabel(1 "Urban" 2 "Rural") 
meansdplot device typesite, median outer(2) ytitle(Class Devices Index) xlabel(1 "Urban" 2 "Rural") 
// histogram tchquali, by(typesite)

tempfile secschinput						// ORIGINAL ALL CLASS LEVEL INPUT
save "secschinput.dta",replace
/*
tab region typesite
           |  ID School Location
    region |     Rural      Urban |     Total
-----------+----------------------+----------
Nord Uplan |        21         26 |        47 
Red River  |        22         10 |        32 
   Phu Yen |        30         28 |        58 
   Da Nang |         0         42 |        42 
	Mekong |        28         13 |        41 
-----------+----------------------+----------
     Total |       101        119 |       220 
*/

* CHECK MISSING VALUE IN ANY CLASS
 mdesc
/*
   
    Variable    |     Missing          Total     Percent Missing
----------------+-----------------------------------------------
         schlid |           0            220           0.00
        classid |           0            220           0.00
        schtype |           0            220           0.00
       typesite |           0            220           0.00
         region |           0            220           0.00
         distid |           0            220           0.00
    eng_tchwork |          10            220           4.55
   eng_tchprivt |          11            220           5.00
   math_tchwork |           2            220           0.91
   math_tchpr~t |           5            220           2.27
        studenr |           0            220           0.00
        headuni |           0            220           0.00
       engchuni |           0            220           0.00
     mathtchuni |           0            220           0.00
         emstud |           6            220           2.73
         facidx |           0            220           0.00
         seridx |           0            220           0.00
         device |           0            220           0.00
       tchquali |           0            220           0.00
----------------+-----------------------------------------------
*/

*****************************************************************
***     	   Fixing region not in schsurvey               ****
*****************************************************************
* Now we continue. As we see, there is no missing value of school input of any class in SC survey, so we dont need to fix these
* we only need to merge with r5region to fix region-level school input

foreach v of varlist facidx seridx device tchquali{
	bysort region typesite: egen m`v'=mean(`v')	
	bysort region typesite: egen md`v'= median(`v')									
}
sort region typesite 
keep typesite region mfacidx mdfacidx mseridx mdseridx mdevice mddevice mtchquali mdtchquali
* LABELS
			label var mdfacidx		"Facilities index(if schlid not in SchoolSurvey is median of region-typesite)"
			label var mdseridx		"Access to service index(if schlid not in SchoolSurvey is median of region-typesite)"
			label var mddevice	 	"Teaching devices index (if schlid not in SchoolSurvey is median of region-typesite)"
			label var mdtchquali	"Teaching quality index(if schlid not in SchoolSurvey is median of region-typesite)"


* KEEP Median data at region-site level
duplicates drop region typesite, force

* Then, we merge regions in YL survey (but not school survey)
merge 1:m region typesite using "r5region.dta"
drop if missing(commid)
drop _merge

/* 
tab region typesite
Number of classes in yc_constructed
                   |   Area of residence
         Region of |     (urban/rural)
         residence |     urban      rural |     Total
-------------------+----------------------+----------
  Northern Uplands |        16         19 |        35 
   Red River Delta |         6         18 |        24 
           Phu Yen |         9         16 |        25 
           Da Nang |        40          1 |        41 
         Highlands |         5          4 |         9 ~ Northern Uplands
     South Eastern |        16          6 |        22 ~ Mekong River Delta
Mekong River Delta |         9         25 |        34 
-------------------+----------------------+----------
             Total |       101         89 |       190 
*/


generate negregion = -region

*update missing value - URBAN 55 to 51
sort typesite region
foreach v in facidx seridx device tchquali{
	replace m`v'=m`v'[1] if region==55 & typesite==1
	replace md`v'=md`v'[1] if region==55 & typesite==1
}
* Fix 56 to 57 - rural
foreach v in facidx seridx device tchquali{
	replace m`v'=m`v'[_N] if region==56 & typesite==2
	replace md`v'=md`v'[_N] if region==56 & typesite==2
}

sort typesite negregion
*update missing value - rural 55 to 51
foreach v in facidx seridx device tchquali{
	replace m`v'=m`v'[_N] if region==55 & typesite==2
	replace md`v'=md`v'[_N] if region==55 & typesite==2
}

* Fix 56 to 57 - urban
foreach v in facidx seridx device tchquali{
	replace m`v'=m`v'[1] if region==56 & typesite==1
	replace md`v'=md`v'[1] if region==56 & typesite==1
}

* Copy indexes
foreach v in facidx seridx device tchquali{
	gen `v'=md`v'
}

* Fix Da Nang Rural with Red River Rural
foreach v in facidx seridx device tchquali{
	gen help= md`v'[region==52 & typesite==2]
	sort help
	replace help=help[_n-1] if help==.
	replace `v'=help if missing(`v')
	drop help
}

gen round=5
order region typesite commid facidx seridx device tchquali
sort region typesite
tempfile secondary_regiontypesite
save `secondary_regiontypesite',replace 
save "secondaryschinput_regiontypesite.dta", replace

