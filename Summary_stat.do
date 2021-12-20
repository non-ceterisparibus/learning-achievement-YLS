
*****************************************
****** SUMMARY STATISTICS *****************
*****************************************
*** PPVT***
cd "D:\YL\data""


use "yc_panel.dta",clear


*** Home Input***
* Primary level
estpost tabstat hq_new sv_new cd_new bsstutl advstutl hschool hrsexc hstudy hsleep hplay hchore htask hhsize ttmalesib if round==3, by(typesite) statistics(mean sd) nototal columns(statistics) listwise
 eststo typesite
 
 estpost tabstat hq_new sv_new cd_new bsstutl advstutl hschool hrsexc hstudy hsleep hplay hchore htask hhsize ttmalesib if round==3, by( majorethnic ) statistics(mean sd) nototal columns(statistics) listwise
eststo majorethnic

estpost tabstat hq_new sv_new cd_new bsstutl advstutl hschool hrsexc hstudy hsleep hplay hchore htask hhsize ttmalesib if round==3, by( carehedu ) statistics(mean sd) nototal columns(statistics) listwise
eststo carehedu

estpost tabstat hq_new sv_new cd_new bsstutl advstutl hschool hrsexc hstudy hsleep hplay hchore htask hhsize ttmalesib if round==3, by(moreable ) statistics(mean sd) nototal columns(statistics) listwise
eststo moreable

estpost tabstat hq_new sv_new cd_new bsstutl advstutl hschool hrsexc hstudy hsleep hplay hchore htask hhsize ttmalesib if round==3, by( stuntearly ) statistics(mean sd) nototal columns(statistics) listwise
eststo stuntearly

esttab typesite majorethnic carehedu moreable stuntearly, main(mean) aux(sd) nostar unstack noobs nonote nomtitle nonumber

 esttab typesite majorethnic carehedu moreable stuntearly using "./out/homeinput1.tex", replace cells(mean(fmt(2)) sd(par)) nostar unstack 	///
 nonumber compress nonote noobs label booktabs f collabels(none)
 
 * Secondary level
 
 estpost tabstat hq_new sv_new cd_new bsstutl advstutl hschool hrsexc hstudy hsleep hplay hwork hchore htask hhsize ttmalesib if round==5 , by(typesite) statistics(mean sd) nototal columns(statistics) listwise
 eststo typesite
 
 estpost tabstat hq_new sv_new cd_new bsstutl advstutl hschool hrsexc hstudy hsleep hplay hwork hchore htask hhsize ttmalesib if round==5, by( majorethnic ) statistics(mean sd) nototal columns(statistics) listwise
eststo majorethnic

estpost tabstat hq_new sv_new cd_new bsstutl advstutl hschool hrsexc hstudy hsleep hplay hwork hchore htask hhsize ttmalesib if round==5, by( carehedu ) statistics(mean sd) nototal columns(statistics) listwise
eststo carehedu

estpost tabstat hq_new sv_new cd_new bsstutl advstutl hschool hrsexc hstudy hsleep hplay hwork hchore htask hhsize ttmalesib if round==5, by(moreable ) statistics(mean sd) nototal columns(statistics) listwise
eststo moreable

estpost tabstat hq_new sv_new cd_new bsstutl advstutl hschool hrsexc hstudy hsleep hplay hwork hchore htask hhsize ttmalesib if round==5, by( stuntearly ) statistics(mean sd) nototal columns(statistics) listwise
eststo stuntearly

esttab typesite majorethnic carehedu moreable stuntearly, main(mean) aux(sd) nostar unstack noobs nonote nomtitle nonumber

 esttab typesite majorethnic carehedu moreable stuntearly using "./out/homeinput2.tex", replace cells(mean(fmt(2)) sd(par)) nostar unstack 	///
 nonumber compress nonote noobs label booktabs f collabels(none)
 
 *******************
 ***  Schol Input***
 *******************
 
 * Primary level
estpost tabstat facidx seridx device sagei studenr emstud timesch hschool tchuni enrol if round==3 & sample==1, by(typesite) statistics(mean sd) nototal columns(statistics) listwise
 eststo typesite

estpost tabstat facidx seridx device sagei studenr emstud timesch hschool tchuni enrol if round==3 & sample==1, by(majorethnic) statistics(mean sd) nototal columns(statistics) listwise
eststo majorethnic

 estpost tabstat facidx seridx device sagei studenr emstud timesch hschool tchuni enrol if round==3 & sample==1, by(carehedu) statistics(mean sd) nototal columns(statistics) listwise
eststo carehedu

estpost tabstat facidx seridx device sagei studenr emstud timesch hschool tchuni enrol if round==3 & sample==1, by(moreable) statistics(mean sd) nototal columns(statistics) listwise
eststo moreable

 estpost tabstat facidx seridx device sagei studenr emstud timesch hschool tchuni enrol if round==3 & sample==1, by(stuntearly) statistics(mean sd) nototal columns(statistics) listwise
eststo stuntearly

 esttab typesite majorethnic carehedu moreable stuntearly using "./out/schoolinput11.tex", replace cells(mean(fmt(2)) sd(par)) nostar unstack nonumber compress nonote noobs label booktabs f collabels(none)
 
 
 ***
estpost tabstat tchuni avg_tchyrtot agegr1 enrol if round==3 , by(typesite) statistics(mean sd) nototal columns(statistics) listwise
 eststo typesite

estpost tabstat tchuni avg_tchyrtot agegr1 enrol if round==3, by(majorethnic) statistics(mean sd) nototal columns(statistics) listwise
eststo majorethnic

 estpost tabstat tchuni avg_tchyrtot agegr1 enrol if round==3, by(carehedu) statistics(mean sd) nototal columns(statistics) listwise
eststo carehedu

estpost tabstat tchuni avg_tchyrtot agegr1 enrol if round==3, by(moreable) statistics(mean sd) nototal columns(statistics) listwise
eststo moreable

 estpost tabstat tchuni avg_tchyrtot agegr1 enrol if round==3, by(stuntearly) statistics(mean sd) nototal columns(statistics) listwise
eststo stuntearly

 esttab typesite majorethnic carehedu moreable stuntearly using "./out/enrol1.tex", replace cells(mean(fmt(2)) sd(par)) nostar unstack nonumber compress nonote noobs label booktabs f collabels(none)
 
 * Secondary level
 estpost tabstat facidx seridx device sagei studenr emstud timesch hschool engchuni mathtchuni if round==5 & sample==1, by(typesite) statistics(mean sd) nototal columns(statistics) listwise
 eststo typesite

  estpost tabstat facidx seridx device sagei studenr emstud timesch hschool engchuni mathtchuni if round==5 & sample==1, by(majorethnic) statistics(mean sd) nototal columns(statistics) listwise
eststo majorethnic

  estpost tabstat facidx seridx device sagei studenr emstud timesch hschool engchuni mathtchuni  if round==5 & sample==1, by(carehedu) statistics(mean sd) nototal columns(statistics) listwise
eststo carehedu

  estpost tabstat facidx seridx device sagei studenr emstud timesch hschool engchuni mathtchuni  if round==5 & sample==1, by(moreable) statistics(mean sd) nototal columns(statistics) listwise
eststo moreable

  estpost tabstat facidx seridx device sagei studenr emstud timesch hschool engchuni mathtchuni if round==5 & sample==1, by(stuntearly) statistics(mean sd) nototal columns(statistics) listwise
eststo stuntearly

 esttab typesite majorethnic carehedu moreable stuntearly using "./out/schoolinput21.tex", replace cells(mean(fmt(2)) sd(par)) nostar unstack 	///
 nonumber compress nonote noobs label booktabs f collabels(none)

 ************
 estpost tabstat enrol avg_engtchyrtot avg_mathtchyrtot if round==5 , by(typesite) statistics(mean sd) nototal columns(statistics) listwise
 eststo typesite

  estpost tabstat enrol avg_engtchyrtot avg_mathtchyrtot if round==5 , by(majorethnic) statistics(mean sd) nototal columns(statistics) listwise
eststo majorethnic

  estpost tabstat enrol avg_engtchyrtot avg_mathtchyrtot if round==5 , by(carehedu) statistics(mean sd) nototal columns(statistics) listwise
eststo carehedu

  estpost tabstat enrol avg_engtchyrtot avg_mathtchyrtot if round==5 , by(moreable) statistics(mean sd) nototal columns(statistics) listwise
eststo moreable

  estpost tabstat enrol avg_engtchyrtot avg_mathtchyrtot if round==5 , by(stuntearly) statistics(mean sd) nototal columns(statistics) listwise
eststo stuntearly

 esttab typesite majorethnic carehedu moreable stuntearly using "./out/enrol2.tex", replace cells(mean(fmt(2)) sd(par)) nostar unstack  nonumber compress nonote noobs label booktabs f collabels(none)
