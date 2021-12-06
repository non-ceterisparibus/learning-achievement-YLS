************************************************************
************************************************************
***            YC - FIXED EFFECT			             ***
***     2: FE Contemporaneous and value added            ***
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

set seed 17838276                          //Set seed to replicate bootstrap

* Load data
cd  "D:\1.RESEARK\9.THESIS materials\thesis\data"    //Adapt this path!
use "yc35_panel.dta", clear


***** Declare data to be panel data *****
encode childid,gen(id)
xtset id round

//        panel variable:  id (strongly balanced)
//         time variable:  round, 3 to 5, but with gaps
//                 delta:  1 unit


***************************************************************
********    Some description of the data          *************
***************************************************************

*** Dependent and central independent variable
tab urban round, summarize(ppvt_perco)
/*
           |   Round of survey
     urban |         3          5 |     Total
-----------+----------------------+----------
         0 | 44.620973  77.827169 | 61.149618
           | 12.746694  13.535942 | 21.179615
           |       448        444 |       892
-----------+----------------------+----------
         1 | 48.783588  78.516334 | 64.180903
           | 10.951078  12.791263 | 19.078704
           |        54         58 |       112
-----------+----------------------+----------
     Total | 45.068745  77.906794 | 61.487769
           | 12.622167  13.441507 | 20.968554
           |       502        502 |      1004
*/

tab urban round, summarize(maths_perco)
/*
           |   Round of survey
     urban |         3          5 |     Total
-----------+----------------------+----------
         0 | 68.266328  41.265687 |  55.00341
           | 17.448117  20.132135 | 23.151276
           |       434        419 |       853
-----------+----------------------+----------
         1 | 77.813924  47.859238 | 62.559223
           | 16.461257  20.276385 | 23.780548
           |        53         55 |       108
-----------+----------------------+----------
     Total | 69.305389  42.030761 | 55.852555
           | 17.580926  20.238086 |  23.33272
           |       487        474 |       961
*/
*** describe the 40 patterns most frequently observed in the sample 
xtdes, pattern(40)

*** within variance on the independent variables?
* Personal characteristics
xtsum hhsize ttmalesib ttsib hq_new sv_new cd_new wi_new
/*
Variable         |      Mean   Std. Dev.       Min        Max |    Observations
-----------------+--------------------------------------------+----------------
                 |                                            |
hhsize   overall |  4.467871   1.333741          0         11 |     N =     996
         between |             1.161493          1       10.5 |     n =     498
         within  |             .6566245   1.467871   7.467871 |     T =       2
                 |                                            |
ttmale~b overall |  1.077309   1.080223          0          6 |     N =     996
         between |             1.057477          0        5.5 |     n =     498
         within  |             .2230443   .0773092   2.077309 |     T =       2
                 |                                            |
hq_new   overall |  77.05178   20.19306   2.380952        100 |     N =     993
         between |             17.19138   4.166667        100 |     n =     498
         within  |             10.57398   32.40892   121.6946 | T-bar = 1.99398
                 |                                            |
sv_new   overall |  58.36683   25.01953          0        100 |     N =     995
         between |             20.73832       12.5        100 |     n =     498
         within  |             14.00632   20.86683   95.86683 |     T = 1.99799
                 |                                            |
cd_new   overall |  57.18757   15.86528          0        100 |     N =     994
         between |             13.46055   5.555556   88.88889 |     n =     498
         within  |             8.392336   34.96535    79.4098 | T-bar = 1.99598

*/
* Health input
bysort typesite: xtsum zhfa cladder careladder
/*

Variable         |      Mean   Std. Dev.       Min        Max |    Observations
-----------------+--------------------------------------------+----------------
                 |                                            |
zhfa     overall | -.9730909   .9406773      -3.31       5.01 |     N =     550
         between |             .8632609      -2.88       1.86 |     n =     276
         within  |             .3738525  -4.268091   2.321909 | T-bar = 1.99275
                 |                                            |
cladder  overall |  6.188406   1.842435          1          9 |     N =     552
         between |             1.337845        2.5          9 |     n =     276
         within  |             1.268064   2.188406   10.18841 |     T =       2
                 |                                            |
carela~r overall |  4.830909   1.323237          1          9 |     N =     550
         between |             1.042577        1.5          8 |     n =     276
         within  |             .8137032   2.330909   7.330909 | T-bar = 1.99275
*/
* Home input
xtsum timesch hschool hstudy hsleep hplay hrsexc bsstutl advstutl 
/*
Variable         |      Mean   Std. Dev.       Min        Max |    Observations
-----------------+--------------------------------------------+----------------
timesch  overall |  14.94322   7.900208          1         60 |     N =     546
         between |             5.910769          5         45 |     n =     276
         within  |             5.237217  -5.056777   34.94322 | T-bar = 1.97826
hschool  overall |  5.504554   1.560366          0         11 |     N =     549
         between |             .9751457          0          9 |     n =     276
         within  |             1.248357   2.504554   8.504554 | T-bar = 1.98913
                 |                                            |
hstudy   overall |  3.186703   1.423931          0          7 |     N =     549
         between |             .9720548          0        5.5 |     n =     276
         within  |             1.049526   .6867031   5.686703 | T-bar = 1.98913
                 |                                            |
hsleep   overall |  9.037341   1.216511          1         13 |     N =     549
         between |             .7737218        4.5         11 |     n =     276
         within  |             .9396721   5.537341   12.53734 | T-bar = 1.98913
                 |                                            |
hplay    overall |  4.642259   1.838755          0         14 |     N =     549
         between |             1.234388          1         10 |     n =     276
         within  |             1.373186   .6422587   8.642259 | T-bar = 1.98913
                 |                                            |
hrsexc   overall |      9.28   4.908343          2         35 |     N =     400
         between |             4.195861          2         30 |     n =     241
         within  |             2.947111      -2.22      20.78 | T-bar = 1.65975
                 |                                            |
bsstutl	 overall |  85.49689   13.97818          0        100 |     N =     552
         between |             10.69569   39.28572        100 |     n =     276
         within  |             9.011065   35.49689   135.4969 |     T =       2
                 |                                            |
advstutl overall |  36.41304   34.19671          0        100 |     N =     552
         between |              21.1584          0        100 |     n =     276
         within  |             26.88029  -13.58696   86.41304 |     T =       2
*/
* School Inputs
xtsum facidx seridx device headuni tchuni sagei
/*
. xtsum facidx seridx device headuni tchuni sagei

Variable         |      Mean   Std. Dev.       Min        Max |    Observations
-----------------+--------------------------------------------+----------------
facidx   overall |  69.31644    40.6665          0        100 |     N =     992
         between |             29.04021          0        100 |     n =     498
         within  |             28.76096   19.31644   119.3164 |     T = 1.99197
                 |                                            |
seridx   overall |        50   33.10788          0        100 |     N =     992
         between |             25.43373          0   91.66666 |     n =     498
         within  |             21.38573   9.61e-07        100 |     T = 1.99197
                 |                                            |
device   overall |  20.67876     32.648          0        100 |     N =     992
         between |             19.26964          0         60 |     n =     498
         within  |             26.36603  -29.32124   70.67876 |     T = 1.99197
                 |                                            |
headuni  overall |  .7032086   .4571495          0          1 |     N =     748
         between |             .4216665          0          1 |     n =     473
         within  |             .2468001   .2032086   1.203209 |     T =  1.5814
                 |                                            |
tchuni   overall |  .7259036   .4462819          0          1 |     N =     996
         between |             .3053376          0          1 |     n =     498
         within  |             .3256227   .2259036   1.225904 |     T =       2
                 |                                            |
sagei    overall | -.5451807   1.417396        -10          0 |     N =     996
         between |             1.131436         -6          0 |     n =     498
         within  |             .8544886  -5.545181   4.454819 |     T =       2
*/



*************************************************************
**** Interation with school input - contemporaneous
*************************************************************

**** Urban/rural specific school input impact
gen X=urban
quietly xtreg ppvt_perco i.X#(c.facidx c.seridx c.device c.hschool c.sagen c.avg_tchyrtot) hrsexc hstudy hplay htask hwork hq_new sv_new cd_new bsstutl advstutl zhfa, fe  vce(cluster id)
est store FEurbanschl

**** Major ethnicity  school input impact
replace X=majorethnic
quietly xtreg ppvt_perco i.X#(c.facidx c.seridx c.device c.hschool c.sagen c.pemstud c.avg_tchyrtot) hrsexc hstudy hplay htask hwork hq_new sv_new cd_new bsstutl advstutl zhfa, fe  vce(cluster id)
est store FEethnicschl

**** More able specific school input impact
replace X=moreable
quietly xtreg ppvt_perco i.X#(c.facidx c.seridx c.device c.hschool c.sagen c.avg_tchyrtot) hrsexc hstudy hplay htask hwork hq_new sv_new cd_new bsstutl advstutl zhfa, fe  vce(cluster id)
est store FEableschl

**** Gender specific school input impact
replace X=female
quietly xtreg ppvt_perco i.X#(c.facidx c.seridx c.device c.hschool c.sagen c.avg_tchyrtot) hrsexc hstudy hplay htask hwork hq_new sv_new cd_new bsstutl advstutl zhfa, fe  vce(cluster id)
est store FEgenschl

**** Stunt specificschool input impact
replace X=stuntearly
quietly xtreg ppvt_perco i.X#(c.facidx c.seridx c.device c.hschool c.sagen c.avg_tchyrtot) hrsexc hstudy hplay htask hwork hq_new sv_new cd_new bsstutl advstutl zhfa, fe  vce(cluster id)
est store FEstuntschl

**** Caregiver school input impact
replace X=carehedu
quietly xtreg ppvt_perco i.X#(c.facidx c.seridx c.device c.hschool c.sagen c.avg_tchyrtot) hrsexc hstudy hplay htask hwork hq_new sv_new cd_new bsstutl advstutl zhfa, fe  vce(cluster id)
est store FEcareschl

* Table of estimation results
// estimates table FEurbanschl FEethnicschl FEableschl FEgenschl FEstuntschl FEcareschl, b(%9.4f) se(%9.4f) p(%9.4f)  
esttab FEurbanschl FEethnicschl FEableschl FEgenschl FEstuntschl FEcareschl using "./out/schoolimpact_nz.tex", drop(hrsexc hstudy hplay hq_new sv_new cd_new bsstutl advstutl zhfa) label p scalars(N F)

*************************************************************
**** Interation with specific home input 
*************************************************************
replace X=urban
quietly xtreg ppvt_perco i.X#(c.hq_new c.sv_new c.cd_new c.bsstutl c.advstutl c.hrsexc c.hstudy ) htask hwork pemstud hplay zhfa hschool facidx seridx device sagen, fe  vce(cluster id)
est store FEurbanhome

**** Major ethnicity specific home input impact
replace X=majorethnic
quietly xtreg ppvt_perco i.X#(c.hq_new c.sv_new c.cd_new c.bsstutl c.advstutl c.hrsexc c.hstudy ) htask hwork pemstud hplay zhfa hschool facidx seridx device sagen, fe  vce(cluster id)
est store FEethnichome

**** More able specific home input impact
replace X=moreable
quietly xtreg ppvt_perco i.X#(c.hq_new c.sv_new c.cd_new c.bsstutl c.advstutl c.hrsexc c.hstudy) htask hwork pemstud hplay zhfa hschool facidx seridx device sagen, fe  vce(cluster id)
est store FEablehome

**** Gender specific home input impact
replace X=female
quietly xtreg ppvt_perco i.X#(c.hq_new c.sv_new c.cd_new c.bsstutl c.advstutl c.hrsexc c.hstudy ) htask hwork pemstud hplay zhfa hschool facidx seridx device sagen, fe  vce(cluster id)
est store FEgenhome

**** Stunt specific home input impact
replace X=stuntearly
quietly xtreg ppvt_perco i.X#(c.hq_new c.sv_new c.cd_new c.bsstutl c.advstutl c.hrsexc c.hstudy ) htask hwork pemstud hplay zhfa hschool facidx seridx device sagen, fe  vce(cluster id)
est store FEstunthome

**** Caregiver school input impact
replace X=carehedu
quietly xtreg ppvt_perco i.X#(c.hq_new c.sv_new c.cd_new c.bsstutl c.advstutl c.hrsexc c.hstudy) htask hwork pemstud hplay zhfa hschool facidx seridx device sagen, fe  vce(cluster id)
est store FEcarehome

* Table of estimation results
// estimates table FEurbanhome FEethnichome FEablehome FEgenhome FEstunthome FEcarehome, b(%9.4f) se(%9.4f) p(%9.4f)  
esttab FEurbanhome FEethnichome FEablehome FEgenhome FEstunthome FEcarehome using "./out/homeimpact_nz.tex", drop(zhfa hschool facidx seridx device sagen) label p scalars(N F)


 
*************************************************************
**** Interation with school input 
*************************************************************
gen X=urban
**** Urban/rural specific school input impact
quietly xtreg ppvt_perco ppvt_perco_L1 i.X#(c.facidx c.seridx c.device c.hschool c.sagen c.avg_tchyrtot) hrsexc hstudy hplay htask hwork hq_new sv_new cd_new bsstutl advstutl zhfa, fe  vce(cluster id)
est store FElaggedurbanschl

**** Major ethnicity specific school input impact
replace X=majorethnic
quietly xtreg ppvt_perco ppvt_perco_L1 i.X#(c.facidx c.seridx c.device c.hschool c.sagen c.pemstud c.avg_tchyrtot) hrsexc hstudy hplay htask hwork hq_new sv_new cd_new bsstutl advstutl zhfa, fe  vce(cluster id)
est store FElaggedethnicschl

**** More able specific school input impact
replace X=moreable
quietly xtreg ppvt_perco ppvt_perco_L1 i.X#(c.facidx c.seridx c.device c.hschool c.sagen c.avg_tchyrtot) hrsexc hstudy hplay htask hwork hq_new sv_new cd_new bsstutl advstutl zhfa, fe  vce(cluster id)
est store FElaggedableschl

**** Gender specific school input impact
replace X=female
quietly xtreg ppvt_perco ppvt_perco_L1 i.X#(c.facidx c.seridx c.device c.hschool c.sagen c.avg_tchyrtot) hrsexc hstudy hplay htask hwork hq_new sv_new cd_new bsstutl advstutl zhfa, fe  vce(cluster id)
est store FElaggedgenschl

**** Stunt specific school input impact
replace X = stuntearly
quietly xtreg ppvt_perco ppvt_perco_L1 i.X#(c.facidx c.seridx c.device c.hschool c.sagen c.avg_tchyrtot) hrsexc hstudy hplay htask hwork hq_new sv_new cd_new bsstutl advstutl zhfa, fe  vce(cluster id)
est store FElaggedstuntschl

**** Caregiver school input impact
replace X = carehedu
quietly xtreg ppvt_perco ppvt_perco_L1 i.X#(c.facidx c.seridx c.device c.hschool c.sagen c.avg_tchyrtot) hrsexc hstudy hplay htask hwork hq_new sv_new cd_new bsstutl advstutl zhfa, fe  vce(cluster id)
est store FElaggedcareschl

* Table of estimation results
esttab FElaggedurbanschl FElaggedethnicschl FElaggedableschl FElaggedgenschl FElaggedstuntschl FElaggedcareschl using "./out/schoolimpact_laggedv1.tex",drop(hrsexc hstudy hplay hq_new sv_new cd_new bsstutl advstutl zhfa) label p scalars(N F)

*************************************************************
**** Interation with specific home input 
*************************************************************
replace X=urban
quietly  xtreg ppvt_perco ppvt_perco_L1 i.X#(c.hq_new c.sv_new c.cd_new c.bsstutl c.advstutl c.hrsexc c.hstudy ) pemstud htask hwork hplay zhfa hschool facidx seridx device sagen, fe  vce(cluster id)
est store FElaggedurbanhome

**** Major ethnicity specific home and school input impact
replace X=majorethnic
quietly  xtreg ppvt_perco ppvt_perco_L1 i.X#(c.hq_new c.sv_new c.cd_new c.bsstutl c.advstutl c.hrsexc c.hstudy ) htask hwork) pemstud hplay zhfa hschool facidx seridx device sagen, fe  vce(cluster id)
est store FElaggedethnichome

**** More able specific home and school input impact
replace X=moreable
quietly xtreg ppvt_perco ppvt_perco_L1 i.X#(c.hq_new c.sv_new c.cd_new c.bsstutl c.advstutl c.hrsexc c.hstudy) pemstud htask hwork hplay zhfa hschool facidx seridx device sagen, fe  vce(cluster id)
est store FElaggedablehome

**** Gender specific home and school input impact
replace X=female
quietly xtreg ppvt_perco ppvt_perco_L1 i.X#(c.hq_new c.sv_new c.cd_new c.bsstutl c.advstutl c.hrsexc c.hstudy) pemstud htask hwork hplay zhfa hschool facidx seridx device sagen, fe  vce(cluster id)
est store FElaggedgenhome

**** Stunt specific home and school input impact
replace X=stuntearly
quietly  xtreg ppvt_perco ppvt_perco_L1 i.X#(c.hq_new c.sv_new c.cd_new c.bsstutl c.advstutl c.hrsexc c.hstudy) pemstud htask hwork hplay zhfa hschool facidx seridx device sagen, fe  vce(cluster id)
est store FElaggedstunthome

**** Caregiver school input impact
replace X = carehedu
quietly xtreg ppvt_perco ppvt_perco_L1 i.X#(c.hq_new c.sv_new c.cd_new c.bsstutl c.advstutl c.hrsexc c.hstudy) pemstud htask hwork hplay zhfa hschool facidx seridx device sagen, fe  vce(cluster id)
est store FElaggedcarehome

* Table of estimation results
// estimates table FElaggedurbanhome FElaggedethniccluster FEppablecluster FEppgencluster FEppstuntcluster FElaggedcarehome, b(%9.4f) se(%9.4f) p(%9.4f)  
esttab FElaggedurbanhome FElaggedethnichome FElaggedablehome FElaggedgenhome FElaggedstunthome FElaggedcarehome using "./out/homeimpact_laggedv1.tex", drop(zhfa hschool facidx seridx device sagen) label p scalars(N F)
