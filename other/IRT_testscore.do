
/*-----------------------------------------------------------------------------*
								IRT TEST SCORES  YC 
------------------------------------------------------------------------------*/
cd "D:/1.RESEARK/9.THESIS materials/thesis/data"


* ROUND 4
use "vn_r4_yccog_youngerchildtest.dta",clear
gen childid="VN"+string(CHILDCODE, "%06.0f")
	
drop if MATHTEST==0
keep childid correct*maths maths_raw
rename correct*maths correct*
rename correct0* correct*

forvalues num =1/34{
      replace correct`num' = 0 if correct`num'==.
   }

* To fit the Rasch model, we first have to reshape the data.
reshape long correct, i(childid) j(quest)
// use "r4maths.dta"

* We now have to generate the predictor variables for the thetas:
rename correct math
forvalues num =1/31{
      gen Th`num' = -(quest==`num')
   }
* set format to compress the output
format math quest Th* %4.0f
* sort within subj_id on the identifier item of the math problem.
sort childid quest 

tabulate quest math, row nofreq


* ROUND 5

use "vn_r5_yccog_youngerchild.dta",clear
gen childid="VN"+string(CHILDCODE, "%06.0f")
keep childid MATHTEST correct*maths maths_raw
rename correct*maths correct*
rename correct0* correct*

drop if MATHTEST==0
drop CHILDCODE MATHTEST

tabulate maths_raw
/*
  Raw score |
    in Math |
       Test |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |          8        0.42        0.42
          1 |          9        0.48        0.90
          2 |         11        0.58        1.48
          3 |         16        0.85        2.33
          4 |         29        1.54        3.87
          5 |         50        2.65        6.51
          6 |         73        3.87       10.38
          7 |        102        5.40       15.78
          8 |        111        5.88       21.66
          9 |        120        6.36       28.02
         10 |         99        5.24       33.26
         11 |        117        6.20       39.46
         12 |         93        4.93       44.39
         13 |         84        4.45       48.83
         14 |         96        5.08       53.92
         15 |         95        5.03       58.95
         16 |         74        3.92       62.87
         17 |         87        4.61       67.48
         18 |         69        3.65       71.13
         19 |         82        4.34       75.48
         20 |         66        3.50       78.97
         21 |         67        3.55       82.52
         22 |         67        3.55       86.07
         23 |         43        2.28       88.35
         24 |         60        3.18       91.53
         25 |         47        2.49       94.01
         26 |         43        2.28       96.29
         27 |         30        1.59       97.88
         28 |         22        1.17       99.05
         29 |         13        0.69       99.74
         30 |          5        0.26      100.00
------------+-----------------------------------
      Total |      1,888      100.00

*/. 
* To fit the Rasch model, we first have to reshape the data.
reshape long correct, i(childid) j(quest)

// use "r5maths.dta"

* We now have to generate the predictor variables for the thetas:
rename correct math
forvalues num =1/31{
      gen Th`num' = -(quest==`num')
   }
* set format to compress the output
format math quest Th* %4.0f
* sort within subj_id on the identifier item of the math problem.
sort childid quest 
* invoke list with options that improve readability.
list math quest Th* if sub==1, nodisplay noobs nolabel  

tabulate quest math, row nofreq
/*
           |         math
     quest | Incorrect    Correct |     Total
-----------+----------------------+----------
         1 |     30.53      69.47 |    100.00 
         2 |     49.95      50.05 |    100.00 
         3 |     38.54      61.46 |    100.00 
         4 |     77.77      22.23 |    100.00 
         5 |      8.61      91.39 |    100.00 
         6 |     21.25      78.75 |    100.00 
         7 |     22.93      77.07 |    100.00 
         8 |     28.76      71.24 |    100.00 
         9 |     40.33      59.67 |    100.00 
        10 |     47.83      52.17 |    100.00 
        11 |     50.26      49.74 |    100.00 
        12 |     25.78      74.22 |    100.00 
        13 |     28.17      71.83 |    100.00 
        14 |     60.13      39.87 |    100.00 
        15 |     82.06      17.94 |    100.00 
        16 |     56.89      43.11 |    100.00 
        17 |     64.13      35.87 |    100.00 
        18 |     46.12      53.88 |    100.00 
        19 |     83.83      16.17 |    100.00 
        20 |     30.20      69.80 |    100.00 
        21 |     48.52      51.48 |    100.00 
        22 |     54.10      45.90 |    100.00 
        23 |     46.53      53.47 |    100.00 
        24 |     53.90      46.10 |    100.00 
        25 |     83.43      16.57 |    100.00 
        26 |     29.27      70.73 |    100.00 
        27 |     50.42      49.58 |    100.00 
        28 |     72.22      27.78 |    100.00 
        29 |     56.13      43.87 |    100.00 
        30 |     85.71      14.29 |    100.00 
        31 |     77.84      22.16 |    100.00 
-----------+----------------------+----------
     Total |     49.08      50.92 |    100.00 
*/

*** We are now ready to request the CML estimates of the theta parameters of the Rasch model using the clogit command:
* clm-estimator for Rasch model (etas are fixed effects)
clogit math Th1-Th31, group(childid)
/*
note: Th31 omitted because of collinearity
note: multiple positive outcomes within groups encountered.
note: 9 groups (41 obs) dropped because of all positive or
      all negative outcomes.

Iteration 0:   log likelihood = -23196.644  
Iteration 1:   log likelihood = -23005.999  
Iteration 2:   log likelihood = -23005.798  
Iteration 3:   log likelihood = -23005.798  

Conditional (fixed-effects) logistic regression

                                                Number of obs     =     53,289
                                                LR chi2(30)       =   11377.39
                                                Prob > chi2       =     0.0000
Log likelihood = -23005.798                     Pseudo R2         =     0.1983

------------------------------------------------------------------------------
        math |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
         Th1 |  -2.641861   .0964868   -27.38   0.000    -2.830972    -2.45275
         Th2 |  -1.780717    .091961   -19.36   0.000    -1.960958   -1.600477
         Th3 |  -2.339847   .0932626   -25.09   0.000    -2.522638   -2.157056
         Th4 |  -.0849576   .1030674    -0.82   0.410     -.286966    .1170507
         Th5 |   -4.45662   .1161893   -38.36   0.000    -4.684347   -4.228893
         Th6 |  -3.295035   .0983037   -33.52   0.000    -3.487706   -3.102363
         Th7 |  -3.186334   .0977448   -32.60   0.000    -3.377911   -2.994758
         Th8 |  -2.882407   .0945019   -30.50   0.000    -3.067627   -2.697186
         Th9 |  -2.112255   .0948267   -22.27   0.000    -2.298112   -1.926398
        Th10 |  -1.884688       .092   -20.49   0.000    -2.065005   -1.704372
        Th11 |  -1.749898   .0925699   -18.90   0.000    -1.931331   -1.568464
        Th12 |  -3.046852   .0954372   -31.93   0.000    -3.233905   -2.859798
        Th13 |  -2.910488   .0945478   -30.78   0.000    -3.095798   -2.725177
        Th14 |  -1.219334   .0925202   -13.18   0.000     -1.40067   -1.037997
        Th15 |   .1596599   .1002767     1.59   0.111    -.0368788    .3561986
        Th16 |  -1.414227   .0919268   -15.38   0.000      -1.5944   -1.234053
        Th17 |  -1.024367   .0931056   -11.00   0.000     -1.20685   -.8418832
        Th18 |   -1.95078   .0919321   -21.22   0.000    -2.130963   -1.770596
        Th19 |   .3103905   .1021154     3.04   0.002      .110248    .5105331
        Th20 |  -2.788141   .0939997   -29.66   0.000    -2.972377   -2.603905
        Th21 |  -1.833343   .0919033   -19.95   0.000     -2.01347   -1.653215
        Th22 |  -1.564427   .0923473   -16.94   0.000    -1.745425    -1.38343
        Th23 |  -1.942028   .0921337   -21.08   0.000    -2.122606   -1.761449
        Th24 |  -1.565576   .0922978   -16.96   0.000    -1.746477   -1.384676
        Th25 |   .4038343   .1076904     3.75   0.000     .1927649    .6149036
        Th26 |  -2.834658   .0946294   -29.96   0.000    -3.020128   -2.649187
        Th27 |  -1.725348   .0922238   -18.71   0.000    -1.906103   -1.544592
        Th28 |  -.3427327   .1010518    -3.39   0.001    -.5407906   -.1446747
        Th29 |  -1.447854   .0929846   -15.57   0.000    -1.630101   -1.265608
        Th30 |   .6482718   .1140804     5.68   0.000     .4246782    .8718653
        Th31 |          0  (omitted)
------------------------------------------------------------------------------
*/

estimates store RASCH

clogit math Th2-Th30 if maths_raw<=16, group(childid)

estimates store LESS

hausman LESS RASCH 
/*

                 ---- Coefficients ----
             |      (b)          (B)            (b-B)     sqrt(diag(V_b-V_B))
             |      LESS        RASCH        Difference          S.E.
-------------+----------------------------------------------------------------
         Th2 |   -.1132949    -.2508781        .1375832        .0577684
         Th3 |   -1.159823     -.806212       -.3536109        .0534029
         Th4 |    2.073125     1.422225        .6509009        .1537062
         Th5 |   -2.728835    -2.915804        .1869697        .0467791
         Th6 |   -1.652449    -1.756564        .1041154        .0495442
         Th7 |   -1.477275    -1.648626        .1713509         .049138
         Th8 |    -1.12293     -1.34566        .2227302         .048656
         Th9 |   -.2277775     -.582845        .3550674        .0620026
        Th10 |   -.2366111    -.3545173        .1179062        .0561347
        Th11 |   -.0555879    -.2218085        .1662207        .0595578
        Th12 |   -1.252526    -1.509618         .257092        .0476176
        Th13 |   -1.168709    -1.373881        .2051719        .0485692
        Th14 |    .4147846     .3049497        .1098349        .0662278
        Th15 |     1.11551     1.669603       -.5540929         .076845
        Th16 |    .3069116     .1124638        .1944478        .0634911
        Th17 |    .4035406     .4979791       -.0944384         .064984
        Th18 |   -.4916543    -.4201693       -.0714851        .0539799
        Th19 |      .76986     1.818274       -1.048414        .0609396
        Th20 |    -1.11227    -1.252327        .1400568        .0495236
        Th21 |   -.0791523    -.3038878        .2247355        .0582088
        Th22 |   -.1013948    -.0377682       -.0636266        .0580525
        Th23 |   -.2145749    -.4120936        .1975187        .0567624
        Th24 |    .1159473    -.0387826        .1547299        .0614732
        Th25 |    2.775197     1.903063        .8721342        .2227225
        Th26 |   -1.086362    -1.299267        .2129042        .0495031
        Th27 |    .0334386    -.1973224         .230761        .0606257
        Th28 |    1.305627     1.162282        .1433447         .116916
        Th29 |    -.047667     .0770955       -.1247624        .0594773
        Th30 |    2.957042     2.139458        .8175841        .2590065
------------------------------------------------------------------------------
                          b = consistent under Ho and Ha; obtained from clogit
           B = inconsistent under Ha, efficient under Ho; obtained from clogit

    Test:  Ho:  difference in coefficients not systematic

                 chi2(29) = (b-B)'[(V_b-V_B)^(-1)](b-B)
                          =     1226.29
                Prob>chi2 =      0.0000
*/

clogit math Th2-Th30 if maths_raw>=15, group(childid)

estimates store MORE

hausman MORE RASCH 
/*
                 ---- Coefficients ----
             |      (b)          (B)            (b-B)     sqrt(diag(V_b-V_B))
             |      MORE        RASCH        Difference          S.E.
-------------+----------------------------------------------------------------
         Th2 |   -.3333658    -.2508781       -.0824877        .0694665
         Th3 |    -.124964     -.806212         .681248        .0653495
         Th4 |    1.237673     1.422225       -.1845512        .0539761
         Th5 |     -3.7948    -2.915804       -.8789958        .2931897
         Th6 |   -1.858399    -1.756564       -.1018346        .1152369
         Th7 |   -1.946666    -1.648626       -.2980406        .1213595
         Th8 |   -1.915399     -1.34566        -.569739        .1219484
         Th9 |   -1.115196     -.582845       -.5323509        .0874784
        Th10 |   -.4126792    -.3545173       -.0581619        .0710165
        Th11 |   -.3849619    -.2218085       -.1631533        .0706416
        Th12 |   -2.356754    -1.509618       -.8471353        .1490678
        Th13 |   -1.839422    -1.373881       -.4655409         .117454
        Th14 |    .1831105     .3049497       -.1218392        .0616027
        Th15 |    1.994348     1.669603        .3247448        .0628194
        Th16 |   -.1006766     .1124638       -.2131404        .0654619
        Th17 |    .6171058     .4979791        .1191267         .059373
        Th18 |   -.2339003    -.4201693        .1862689        .0674799
        Th19 |    2.653714     1.818274        .8354392        .0811232
        Th20 |    -1.55203    -1.252327       -.2997027        .1035396
        Th21 |   -.5760579    -.3038878       -.2721701        .0739485
        Th22 |    .1010847    -.0377682        .1388529         .063936
        Th23 |   -.5962395    -.4120936       -.1841459        .0744529
        Th24 |   -.1751773    -.0387826       -.1363947        .0669035
        Th25 |    1.716089     1.903063        -.186974        .0491628
        Th26 |   -1.854163    -1.299267       -.5548962        .1182569
        Th27 |   -.4465777    -.1973224       -.2492552        .0710245
        Th28 |    1.036123     1.162282       -.1261593        .0527626
        Th29 |      .26499     .0770955        .1878945        .0626531
        Th30 |    1.974375     2.139458       -.1650835        .0494512
------------------------------------------------------------------------------
                          b = consistent under Ho and Ha; obtained from clogit
           B = inconsistent under Ha, efficient under Ho; obtained from clogit

    Test:  Ho:  difference in coefficients not systematic

                 chi2(29) = (b-B)'[(V_b-V_B)^(-1)](b-B)
                          =      688.44
                Prob>chi2 =      0.0000
*/

************************************************************************************
************************************************************************************

raschtest correct1-correct31,id( childid)


************************************************************************************
************************************************************************************
irt 1pl correct01maths correct02maths correct03maths correct04maths correct05maths correct06maths correct08maths correct09maths correct10maths correct11maths //
correct12maths correct13maths correct14maths correct15maths correct16maths correct17maths correct18maths correct19maths correct20maths correct21maths correct22maths	//
 correct23maths correct24maths correct26maths correct27maths correct29maths correct07maths correct25maths correct28maths correct30maths correct31maths

estat report, sort(b, descending) byparm
 
 /*

One-parameter logistic model                    Number of obs     =      1,888
Log likelihood = -28925.233
--------------------------------------------------------------------------------
               |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
---------------+----------------------------------------------------------------
       Discrim |   1.114183   .0228372    48.79   0.000     1.069423    1.158943
---------------+----------------------------------------------------------------
Diff           |
correct30maths |   2.099707   .0893315    23.50   0.000      1.92462    2.274793
correct25maths |   1.889722    .080947    23.35   0.000     1.731069    2.048375
correct19maths |   1.828485   .0744084    24.57   0.000     1.682647    1.974323
correct15maths |    1.69465   .0712174    23.80   0.000     1.555067    1.834234
correct31maths |   1.524621   .0754341    20.21   0.000     1.376773    1.672469
correct04maths |   1.458597   .0723952    20.15   0.000     1.316705    1.600489
correct28maths |   1.218553   .0687633    17.72   0.000     1.083779    1.353326
correct17maths |    .648517   .0557262    11.64   0.000     .5392957    .7577384
correct14maths |   .4723427   .0542798     8.70   0.000     .3659562    .5787292
correct16maths |    .303408   .0529661     5.73   0.000     .1995963    .4072197
correct29maths |   .2717754   .0544449     4.99   0.000     .1650654    .3784853
correct22maths |   .1699705   .0533386     3.19   0.001     .0654287    .2745122
correct24maths |   .1672965   .0532777     3.14   0.002     .0628741     .271719
correct27maths |   .0220869   .0530855     0.42   0.677    -.0819588    .1261325
correct11maths |   .0040677   .0534705     0.08   0.939    -.1007326     .108868
correct02maths |  -.0165776   .0524846    -0.32   0.752    -.1194455    .0862903
correct21maths |  -.0726251   .0525724    -1.38   0.167     -.175665    .0304148
correct10maths |  -.1135402   .0526367    -2.16   0.031    -.2167062   -.0103742
correct23maths |  -.1686132   .0529547    -3.18   0.001    -.2724025   -.0648239
correct18maths |  -.1785203    .052659    -3.39   0.001    -.2817299   -.0753106
correct09maths |  -.3429832   .0570899    -6.01   0.000    -.4548775    -.231089
correct03maths |  -.5242389   .0550576    -9.52   0.000    -.6321499    -.416328
correct01maths |  -.8203515    .060852   -13.48   0.000    -.9396192   -.7010839
correct20maths |  -.9363581   .0579316   -16.16   0.000    -1.049902   -.8228143
correct26maths |  -.9799816   .0590528   -16.60   0.000    -1.095723   -.8642403
correct08maths |  -1.014683    .058813   -17.25   0.000    -1.129954   -.8994117
correct13maths |   -1.04631   .0592085   -17.67   0.000    -1.162356    -.930263
correct12maths |   -1.17215   .0611547   -19.17   0.000    -1.292011   -1.052289
correct07maths |  -1.304756   .0650509   -20.06   0.000    -1.432253   -1.177258
correct06maths |   -1.40606   .0664656   -21.15   0.000    -1.536331    -1.27579
correct05maths |  -2.472142   .0947504   -26.09   0.000     -2.65785   -2.286435
--------------------------------------------------------------------------------
 */

irtgraph icc correct30maths correct25maths correct19maths correct15maths correct05maths correct06maths correct07maths correct12maths, bcc
graph export "D:\1.RESEARK\9.THESIS materials\thesis\Graph.png", as(png) replace

irtgraph iif correct30maths
graph export "D:\1.RESEARK\9.THESIS materials\thesis\correct30maths.png", as(png) replace
