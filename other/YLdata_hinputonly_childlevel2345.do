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
tab enrol round,m
/*


  Child is |
 currently |                    Round of survey
  enrolled |         1          2          3          4          5 |     Total
-----------+-------------------------------------------------------+----------
        no |         0        324         36         61        369 |       790 
       yes |         0      1,587      1,875      1,852      1,544 |     6,858 
         . |     2,000         89         89         87         87 |     2,352 
-----------+-------------------------------------------------------+----------
     Total |     2,000      2,000      2,000      2,000      2,000 |    10,000 

*/
********************************************************************
****       Define the estimation sample                   		****
****   Who enrol school survey	n non-enrol(schlinput=0	        ****
********************************************************************
* Sampple 1 - include both current enrol and none in data
* who are currently non-enrol, school input ==0 (for contemporaneous spec)
gen nonsamp=0
replace nonsamp=1 if enrol==0 &( round==3|round==5)
bysort childid (round): replace nonsamp = sum(nonsamp)		//for each person, flag all following person-years    


* Sample after adding school input by childlevel
sort childid round
save "yc_panel.dta", replace


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

bysort childid (round): replace hghgrade=hghgrade[_n-1] if hghgrade==. & (round>=3|round<=5)	
replace hghgrade=engrade-1 if (hghgrade==.|(hghgrade>engrade))&engrade>0

/*****************************************************
		BALANCE PANEL CHILD LEVEL - ROUND 3 5
*/****************************************************

***       Creating the central time-yarying variable         ****

* The schooling for age index, denoted as SAGE (Ray and Lancaster 2005),
* For 6-year-old children, who are currently studying grade 1, 
* the index is replaced by 1. Hence, the values of SAGE range from 0 to 1 

gen yrsold=round(agemon/12)
gen sage=hghgrade/(yrsold-6) if (round>=3|round<=5)	//(round>=3|round<=5)(home input test)

replace sage=1 if sage<1 & (round==5 & hghgrade==9)|(round==3 & hghgrade==2)
replace sage=1 if sage>1
replace sage=1 if (engrade==1|engrade==2|engrade==50) & round==2
replace sage=1 if (hghgrade==1|hghgrade==2|hghgrade==50) & round==2

replace hrsexc=0 if extcls==0|missing(hrsexc)

*** Compute time using variables
* Squared term
foreach v in timesch hschool hstudy hsleep hplay hwork hrsexc agemon{
	gen `v'2 = `v'*`v'
	}

foreach v in facidx seridx device tchquali bsstutl advstutl {
	replace `v'=`v'*100
}

foreach v in hq_new sv_new cd_new wi_new {
	replace `v'=`v'*100
}

replace tchuni= (mathtchuni==1) if tchuni==.

tempfile fulldata2345hinput
save `fulldata2345hinput'

* This is a useful auxiliary variable	\\person-years numbered consecutively (within person)
*  !!! This variable has to be computed anew, if one drops person-years !!!
bysort childid (round): gen pynr = _n  

* Exclude person-years with missings on one or more variables 
gen help=0
replace help=1 if missing(ppvt_perco,typesite,hschool,hstudy,hsleep,hplay)
keep if help==0
drop help pynr
bysort childid (round): gen pynr = _n      

bysort childid:   gen pycount = _N //only those with 2 or more person-years are kept
keep if pycount > 1



*****************************************************************
***     			  Save the data set                      ****
*****************************************************************
drop help prescdur paypresc presccre dayspres hrspresc preprim monpresch oneyear quali
sort childid round
order childid round enrol typesite zhfa stunting chhprob chhealth hsleep hschool hstudy hwork careladder hhsize hq_new sv_new cd_new ppvt_perco cog_perco maths_perco hrsexc urban facidx seridx device tchquali


save "yc2345_panel.dta", replace


********************************************************
***   Panel-robust statistical inference	************
********************************************************


* Panel-robust S.E.s (alternative: vce(robust))
xtreg ppvt_perco zhfa hhsize hschool hstudy hplay hrsexc hschool2 hstudy2 hplay2 hrsexc2 hq_new sv_new cd_new sage, fe vce(cluster id)
/*

Fixed-effects (within) regression               Number of obs     =      7,158
Group variable: id                              Number of groups  =      1,962

R-sq:                                           Obs per group:
     within  = 0.5879                                         min =          1
     between = 0.3655                                         avg =        3.6
     overall = 0.3952                                         max =          4

                                                F(14,1961)        =     851.83
corr(u_i, Xb)  = -0.6929                        Prob > F          =     0.0000

                                 (Std. Err. adjusted for 1,962 clusters in id)
------------------------------------------------------------------------------
             |               Robust
  ppvt_perco |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        zhfa |   2.796005   .6304243     4.44   0.000     1.559633    4.032377
      hhsize |  -1.824829   .2912817    -6.26   0.000    -2.396083   -1.253575
     hschool |  -3.030916   .4533287    -6.69   0.000    -3.919973    -2.14186
      hstudy |   7.485843   .5905607    12.68   0.000     6.327651    8.644036
       hplay |   -4.76477   .4120399   -11.56   0.000    -5.572853   -3.956688
      hrsexc |   .5933407   .1030271     5.76   0.000     .3912865    .7953948
    hschool2 |   .1477305   .0441848     3.34   0.001     .0610763    .2343846
     hstudy2 |  -.8662394   .0965555    -8.97   0.000    -1.055602   -.6768773
      hplay2 |   .1689515   .0290594     5.81   0.000     .1119609     .225942
     hrsexc2 |  -.0100121   .0042316    -2.37   0.018     -.018311   -.0017131
      hq_new |    .192021   .0215531     8.91   0.000     .1497517    .2342903
      sv_new |   .4181875   .0161488    25.90   0.000     .3865169    .4498581
      cd_new |   .5663346   .0250457    22.61   0.000     .5172157    .6154535
        sage |     12.277   1.404932     8.74   0.000     9.521687    15.03232
       _cons |   6.275801   3.530087     1.78   0.076    -.6473162    13.19892
-------------+----------------------------------------------------------------
     sigma_u |  19.096119
     sigma_e |  18.831377
         rho |  .50697987   (fraction of variance due to u_i)
------------------------------------------------------------------------------
*/

**** Urban/rural specific home and school input impact
xtreg ppvt_perco i.typesite#(c.hq_new c.sv_new c.cd_new c.hrsexc ) hschool hstudy hplay sage zhfa agemon ttmalesib hhsize, fe  vce(cluster id)

/*
Fixed-effects (within) regression               Number of obs     =      7,158
Group variable: id                              Number of groups  =      1,962

R-sq:                                           Obs per group:
     within  = 0.8424                                         min =          1
     between = 0.4587                                         avg =        3.6
     overall = 0.7787                                         max =          4

                                                F(16,1961)        =    2620.72
corr(u_i, Xb)  = -0.0860                        Prob > F          =     0.0000

                                      (Std. Err. adjusted for 1,962 clusters in id)
-----------------------------------------------------------------------------------
                  |               Robust
       ppvt_perco |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
typesite#c.hq_new |
           urban  |   .0238581    .029803     0.80   0.424    -.0345907    .0823069
           rural  |   .0444999   .0123706     3.60   0.000     .0202389    .0687608
                  |
typesite#c.sv_new |
           urban  |   .0402959    .021995     1.83   0.067    -.0028402    .0834321
           rural  |  -.0490464   .0121136    -4.05   0.000    -.0728033   -.0252895
                  |
typesite#c.cd_new |
           urban  |   .1757185   .0312433     5.62   0.000      .114445    .2369921
           rural  |   .2210212    .015248    14.50   0.000     .1911172    .2509252
                  |
typesite#c.hrsexc |
           urban  |   .3801813   .0696064     5.46   0.000      .243671    .5166917
           rural  |   .3080902   .0488946     6.30   0.000     .2121993    .4039811
                  |
          hschool |   .3730729   .0963757     3.87   0.000     .1840634    .5620824
           hstudy |   1.461626   .1339729    10.91   0.000     1.198882     1.72437
            hplay |  -.1151219   .0952883    -1.21   0.227    -.3019988     .071755
             sage |   1.431781   .7895778     1.81   0.070    -.1167189    2.980281
             zhfa |    1.49656   .3493217     4.28   0.000     .8114795    2.181641
           agemon |   .4403594   .0049597    88.79   0.000     .4306325    .4500863
        ttmalesib |   3.631746   .4803364     7.56   0.000     2.689723     4.57377
           hhsize |  -.1659573   .1754131    -0.95   0.344     -.509973    .1780585
            _cons |   -20.8064   1.942034   -10.71   0.000    -24.61507   -16.99774
------------------+----------------------------------------------------------------
          sigma_u |  8.0139944
          sigma_e |  11.647965
              rho |  .32128247   (fraction of variance due to u_i)
-----------------------------------------------------------------------------------
*/
 xtreg ppvt_perco i.typesite#(c.hschool c.hschool2 c.sage c.timesch ) hstudy hstudy2 hplay hplay2 hq_new sv_new cd_new zhfa agemon ttmalesib, fe  vce(
> cluster id)
/*
Fixed-effects (within) regression               Number of obs     =      6,711
Group variable: id                              Number of groups  =      1,955

R-sq:                                           Obs per group:
     within  = 0.8523                                         min =          1
     between = 0.5649                                         avg =        3.4
     overall = 0.7882                                         max =          4

                                                F(18,1954)        =    2304.19
corr(u_i, Xb)  = -0.0716                        Prob > F          =     0.0000

                                        (Std. Err. adjusted for 1,955 clusters in id)
-------------------------------------------------------------------------------------
                    |               Robust
         ppvt_perco |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
--------------------+----------------------------------------------------------------
 typesite#c.hschool |
             urban  |   1.466161   .8448299     1.74   0.083    -.1907014    3.123024
             rural  |   .8224439   .5106996     1.61   0.107    -.1791293    1.824017
                    |
typesite#c.hschool2 |
             urban  |  -.1879976   .0638036    -2.95   0.003    -.3131279   -.0628673
             rural  |  -.1559708   .0411954    -3.79   0.000    -.2367624   -.0751791
                    |
    typesite#c.sage |
             urban  |   .1846637    1.81384     0.10   0.919    -3.372602    3.741929
             rural  |   .5829277   .9268089     0.63   0.529     -1.23471    2.400566
                    |
 typesite#c.timesch |
             urban  |  -.1687422   .0649711    -2.60   0.009    -.2961623   -.0413222
             rural  |  -.0164681   .0163706    -1.01   0.315    -.0485738    .0156375
                    |
             hstudy |   3.551013   .3839587     9.25   0.000     2.798001    4.304024
            hstudy2 |   -.492936   .0608498    -8.10   0.000    -.6122734   -.3735986
              hplay |   .3464578   .2889433     1.20   0.231    -.2202116    .9131272
             hplay2 |  -.0700741   .0220372    -3.18   0.001    -.1132929   -.0268553
             hq_new |    .037333   .0124702     2.99   0.003     .0128767    .0617893
             sv_new |  -.0289528   .0115167    -2.51   0.012    -.0515391   -.0063665
             cd_new |   .1889365   .0144158    13.11   0.000     .1606645    .2172086
               zhfa |   1.715797   .3669209     4.68   0.000     .9961992    2.435394
             agemon |   .4592525   .0058705    78.23   0.000     .4477393    .4707656
          ttmalesib |   3.620593   .4766371     7.60   0.000     2.685823    4.555364
              _cons |  -17.23503   2.393241    -7.20   0.000     -21.9286   -12.54145
--------------------+----------------------------------------------------------------
            sigma_u |  8.2777359
            sigma_e |  11.369617
                rho |  .34643423   (fraction of variance due to u_i)
-------------------------------------------------------------------------------------
*/
