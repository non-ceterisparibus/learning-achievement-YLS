************************************************************
************************************************************
***            		Pool OLS				             ***
***		            NOV 2011                             *** 	   
************************************************************
************************************************************





********************************************************************************
********************************************************************************
***  		  			  Contemporaneous Specification				************
********************************************************************************
********************************************************************************

*** Comparing BE, POLS, RE, FE and FD *** 

* Pooled OLS
quietly reg ppvt_perco urban majorethnic female stuntearly moreable carehedu zhfa bsstutl advstutl pemstud hschool hstudy hplay htask hwork hrsexc hq_new sv_new cd_new facidx seridx device sagen, vce(cluster id)
est store POLS

* Random-Effects Regression
quietly xtreg  ppvt_perco urban majorethnic female stuntearly moreable carehedu zhfa bsstutl advstutl pemstud hschool hstudy hplay htask hwork hrsexc hq_new sv_new cd_new facidx seridx device sagen, re  vce(cluster id) theta
est store RE

* Panel-robust S.E.s (alternative: vce(robust))
quietly xtreg ppvt_perco urban majorethnic female stuntearly moreable carehedu zhfa bsstutl advstutl pemstud hschool hstudy hplay htask hwork hrsexc hq_new sv_new cd_new facidx seridx device sagen , fe vce(cluster id)
est store FE

* Table of estimation results
//  estimates table POLS RE FE , b(%7.2f) star stfmt(%6.0f) stats(N N_clust) 
 esttab POLS RE FE using "./out/cross_modelv1.tex", label p scalars(N F)
/*

-----------------------------------------------------------
    Variable |     POLS            RE             FE       
-------------+---------------------------------------------
       urban |     -4.52**        -4.52**    (omitted)     
 majorethnic |      3.81*          3.81*     (omitted)     
      female |     -1.45          -1.45      (omitted)     
  stuntearly |      1.25           1.25      (omitted)     
    moreable |      1.26           1.26      (omitted)     
    carehedu |     -0.35          -0.35      (omitted)     
        zhfa |      0.37           0.37           1.72     
     bsstutl |      0.02           0.02          -0.03     
    advstutl |      0.08***        0.08***        0.12***  
     hschool |     -0.01          -0.01          -1.13     
      hstudy |      0.81*          0.81*          0.49     
       hplay |     -0.34          -0.34          -0.64     
      hrsexc |      0.18*          0.18*          0.06     
      hq_new |      0.05           0.05           0.05     
      sv_new |      0.07**         0.07**         0.12*    
      cd_new |      0.06           0.06           0.16*    
      facidx |      0.03           0.03          -0.08     
      seridx |      0.05*          0.05*          0.02     
      device |      0.36***        0.36***        0.35***  
        sage |      0.76           0.76          15.12*    
       _cons |     22.83***       22.83***       29.29*    
-------------+---------------------------------------------
           N |       737            737            737     
     N_clust |       469            469            469     
-----------------------------------------------------------
                   legend: * p<0.05; ** p<0.01; *** p<0.001
*/
********************************************************************************
********************************************************************************
***   				   Value-added   Specification						  ******
********************************************************************************
********************************************************************************
use "yc35_panel_lagged.dta", clear
encode childid,gen(id)
xtset id round

* Pooled OLS
eststo POLS: quietly reg ppvt_perco ppvt_perco_L1 urban majorethnic female stuntearly moreable zhfa bsstutl advstutl pemstud hschool hstudy hplay htask hwork hrsexc hq_new sv_new cd_new facidx seridx device sagen, vce(cluster id)
*est store POLS

* Between Regression
eststo BE: quietly xtreg ppvt_perco ppvt_perco_L1 urban majorethnic female stuntearly moreable zhfa bsstutl advstutl pemstud hschool hstudy hplay htask hwork hrsexc hq_new sv_new cd_new facidx seridx device sagen, be
*est store BE

* Panel-robust S.E.s (alternative: vce(robust))
eststo FElagged: quietly xtreg ppvt_perco ppvt_perco_L1 zhfa bsstutl advstutl pemstud hschool hstudy hplay htask hwork hrsexc hq_new sv_new cd_new facidx seridx device sagen, fe vce(cluster id)
* est store FElagged

* Table of estimation results
 *estimates table POLS BE FElagged , b(%7.2f) star stfmt(%6.0f) stats(N N_clust) 
*  or
 esttab POLS BE FElagged using "./out/cross_modellaggedv1.tex",label p scalars(N F)

/*
-----------------------------------------------------
    Variable |    POLS          RE        FElagged   
-------------+---------------------------------------
ppvt_perco~1 |    0.38***      0.38***     -0.14     
       urban |   -3.48*       -3.48*                 
 majorethnic |    2.16         2.16                  
      female |   -0.87        -0.87                  
  stuntearly |    1.34         1.34                  
    moreable |   -1.03        -1.03                  
        zhfa |    0.44         0.44         1.79     
     bsstutl |    0.01         0.01        -0.02     
    advstutl |    0.03         0.03         0.13***  
     hschool |   -0.38        -0.38        -1.04     
      hstudy |    0.84*        0.84*        0.48     
       hplay |   -0.20        -0.20        -0.66     
      hrsexc |    0.12         0.12         0.06     
      hq_new |    0.03         0.03         0.06     
      sv_new |    0.05         0.05         0.13**   
      cd_new |    0.06*        0.06*        0.15*    
      facidx |    0.03         0.03        -0.11     
      seridx |    0.03         0.03         0.05     
      device |    0.27***      0.27***      0.38***  
        sage |    0.31         0.31        14.51*    
       _cons |   23.99***     23.99***     31.11**   
-------------+---------------------------------------
           N |     673          673          673     
     N_clust |     427          427          427     
-----------------------------------------------------
             legend: * p<0.05; ** p<0.01; *** p<0.001
*/
