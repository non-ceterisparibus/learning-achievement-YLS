/*-----------------------------------------------------------------------------*
								IRT PPVT TEST SCORES  YC 
------------------------------------------------------------------------------*/
cd "D:/1.RESEARK/9.THESIS materials/thesis/data"
* ROUND 2

use "vn_r2_childlevel5yrold",clear
keep CHILDID SEX HHSIZE TYPESITE REGION score_ppvt rscorelang_ppvt PPVT*

gen round=2

tempfile ppvtr2
save `ppvtr2'


* ROUND 3
use "vn_r3yc_childlevel.dta",clear
 keep CHILDID ppvt rppvt_co PPVT*

gen round=3

append using `ppvtr2'
order CHILDID round ppvt rppvt_co rscorelang_ppvt score_ppvt SEX HHSIZE TYPESITE


* ROUND 4

use "vn_r4_yccog_youngerchildtest.dta",clear
gen childid="VN"+string(CHILDCODE, "%06.0f")
gen round=4
merge 1:1 childid round using "yc_panel.dta"
keep if _merge==3
drop _merge
************************************
***			 1 PARAMETER
************************************
***** Gender
irt 2pl correct1ppvt- correct76ppvt , notable group(chsex)
estimates store constrainedsex
irt hybrid (1pl correct1ppvt - correct25ppvt correct50ppvt-correct76ppvt) (1:1pl correct26ppvt-correct49ppvt ) (2:1pl correct26ppvt-correct49ppvt) ,notable group(chsex)
// estat greport
estimates store diff1
lrtest constrainedsex diff1
/*
Likelihood-ratio test                                 LR chi2(49) =   1577.21
(Assumption: diff1 nested in constrainedc~e)          Prob > chi2 =    0.0000
*/

***** Caregiver
irt 1pl correct1ppvt- correct76ppvt , notable group(carehedu)
estimates store constrainedcare

irt hybrid (1pl correct1ppvt - correct25ppvt correct50ppvt-correct76ppvt) (0:1pl correct26ppvt-correct49ppvt ) (1:1pl correct26ppvt-correct49ppvt), noheader group(carehedu)
// estat greport
estimates store diff2
lrtest constrainedcare diff2

***** Majority
irt 1pl correct1ppvt- correct76ppvt , notable group(majorethnic)
estimates store constrainedmajor
irt hybrid (1pl correct1ppvt - correct25ppvt correct50ppvt-correct76ppvt) (0:1pl correct26ppvt-correct49ppvt ) (1:1pl correct26ppvt-correct49ppvt), noheader group(majorethnic)
// estat greport
estimates store diff3
lrtest constrainedmajor diff3

***** Typesite
irt 1pl correct1ppvt- correct76ppvt , notable group(typesite)
estimates store constrainedsite

irt hybrid (1pl correct1ppvt - correct25ppvt correct50ppvt-correct76ppvt) (1:1pl correct26ppvt-correct49ppvt ) (2:1pl correct26ppvt-correct49ppvt), noheader group(typesite)
estat greport
estimates store diff4
lrtest constrainedsite diff4
***** Stunting early
irt 1pl correct1ppvt- correct76ppvt , notable group(stuntearly)
estimates store constrainedstunt
irt hybrid (1pl correct1ppvt - correct25ppvt correct50ppvt-correct76ppvt) (0:1pl correct26ppvt-correct49ppvt ) (1:1pl correct26ppvt-correct49ppvt), noheader group(stuntearly)
// estat greport
estimates store diff5
lrtest constrainedstunt diff5


***** More able
irt 1pl correct1ppvt- correct76ppvt , notable group(moreable)
estimates store constrainedable

irt hybrid (1pl correct1ppvt - correct25ppvt correct50ppvt-correct76ppvt) (0:1pl correct26ppvt-correct49ppvt ) (1:1pl correct26ppvt-correct49ppvt), noheader group(moreable)
// estat greport
estimates store diff6
lrtest constrainedable diff6

Likelihood-ratio test                                 LR chi2(26) =     36.32
(Assumption: constraineda~e nested in diff6)          Prob > chi2 =    0.0860

************************************
***			 2 PARAMETER
************************************
irt 2pl correct1ppvt- correct76ppvt , notable group(carehedu)
estimates store constrainedcare

irt hybrid (2pl correct1ppvt -  correct11ppvt correct13ppvt - correct40ppvt correct42ppvt-correct76ppvt) (0:2pl correct12ppvt correct41ppvt) (1:2pl correct12ppvt correct41ppvt) , noheader group(carehedu)
estat greport
estimates store diff1
/*
----------------------------------------
   Parameter | 0.carehedu   1.carehedu  
-------------+--------------------------
-------------+--------------------------
correct12p~t |
     Discrim |  .78192597    .30895243  
        Diff |  -.0035637   -.47024496  
-------------+--------------------------
correct41p~t |
     Discrim |  1.0056094    .20460735  
        Diff |  .13502296   -4.8132639  
-------------+--------------------------
  mean(Theta)|          0    .59044749  
   var(Theta)|          1    .67723889  

Likelihood-ratio test                                 LR chi2(4)  =     18.65
(Assumption: constrainedc~e nested in diff1)          Prob > chi2 =    0.0009

*/
lrtest constrainedcare diff1


****========================================================================================
irt 2pl correct1ppvt- correct76ppvt , notable group(chsex)
estimates store constrainedchsex

irt hybrid (2pl correct1ppvt -  correct11ppvt correct13ppvt - correct40ppvt correct42ppvt-correct76ppvt) (1:2pl correct12ppvt correct41ppvt) (2:2pl correct12ppvt correct41ppvt) , noheader group(chsex)
estat greport
estimates store diff2
/*
----------------------------------------
   Parameter |    male        female    
-------------+--------------------------
-------------+--------------------------
correct12p~t |
     Discrim |  .66797675    .87466552  
        Diff | -.13128131    .04214742  
-------------+--------------------------
correct41p~t |
     Discrim |  .96105576    1.0442836  
        Diff | -.12307379    .23781416  
-------------+--------------------------
  mean(Theta)|          0   -.01779259  
   var(Theta)|          1     .9999981  
----------------------------------------
*/									
lrtest constrainedchsex diff2
/*
Likelihood-ratio test                                 LR chi2(4)  =     17.61
(Assumption: constrainedc~x nested in diff2)          Prob > chi2 =    0.0015
*/

****========================================================================================
irt 2pl correct1ppvt- correct76ppvt , notable group(majorethnic)
estimates store constrainedeth

irt hybrid (2pl correct1ppvt -  correct11ppvt correct13ppvt - correct40ppvt correct42ppvt-correct76ppvt) (0:2pl correct12ppvt correct41ppvt) (1:2pl correct12ppvt correct41ppvt) , notable group(majorethnic)
estat greport
estimates store diff3
/*
----------------------------------------
   Parameter | 0.majore~c   1.majore~c  
-------------+--------------------------
-------------+--------------------------
correct12p~t |
     Discrim |   1.355376    1.0891661  
        Diff |  .52990814    .72826191  
-------------+--------------------------
correct41p~t |
     Discrim |  .64615243    1.0891661  
        Diff |  1.9409753     .7233408  
-------------+--------------------------
  mean(Theta)|          0    .84142086  
   var(Theta)|          1    .47311205  
----------------------------------------
*/
lrtest constrainedeth diff3
/*
Likelihood-ratio test                                 LR chi2(3)  =     16.33
(Assumption: constrainedeth nested in diff3)          Prob > chi2 =    0.0010
*/



****========================================================================================
irt 2pl correct1ppvt- correct76ppvt , notable group(stuntearly)
estimates store constrainestunt

irt hybrid (2pl correct1ppvt -  correct11ppvt correct13ppvt - correct40ppvt correct42ppvt-correct76ppvt) (0:2pl correct12ppvt correct41ppvt) (1:1pl correct12ppvt correct41ppvt) , notable group(stuntearly)
estat greport
estimates store diff4
/*

----------------------------------------
   Parameter | 0.stunte~y   1.stunte~y  
-------------+--------------------------
-------------+--------------------------
correct12p~t |
     Discrim |  .72076144    .89448378  
        Diff | -.06585288   -.20362064  
-------------+--------------------------
correct41p~t |
     Discrim |  .98645113    .89448378  
        Diff | -.01839092     .2503996  
-------------+--------------------------
  mean(Theta)|          0   -.35778953  
   var(Theta)|          1    1.1594903  

*/
lrtest constrainestunt diff4
/*

Likelihood-ratio test                                 LR chi2(3)  =      4.87
(Assumption: constrainest~t nested in diff4)          Prob > chi2 =    0.1815

We reject the null hypothesis that both discrimination and difficulty are equal across the two groups. At least one is different, but this test does not tell whether discrimination, difficulty, or both differ.
*/

****========================================================================================
irt 2pl correct1ppvt- correct76ppvt , notable group(typesite)
estimates store constrainesite

irt hybrid (2pl correct1ppvt -  correct11ppvt correct13ppvt - correct40ppvt correct42ppvt-correct76ppvt) (1:2pl correct12ppvt correct41ppvt) (2:1pl correct12ppvt correct41ppvt) , notable group(typesite)
estat greport
/*
----------------------------------------
   Parameter |   urban        rural     
-------------+--------------------------
-------------+--------------------------
correct12p~t |
     Discrim |  .46136837    .78609226  
        Diff |  .51221124   -.33792596  
-------------+--------------------------
correct41p~t |
     Discrim |  1.1881744    .78609226  
        Diff |  .11077753   -.17078217  
-------------+--------------------------
  mean(Theta)|          0   -.22994428  
   var(Theta)|          1    1.4403544  
----------------------------------------
*/
estimates store diff5
lrtest constrainesite diff5
/*
Likelihood-ratio test                                 LR chi2(3)  =     29.37
(Assumption: constrainesite nested in diff5)          Prob > chi2 =    0.0000
*/