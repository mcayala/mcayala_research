cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"
global log "/Users/camila/Documents/GitHub/mcayala_research/Summer paper/Log files"
global output "/Users/camila/Dropbox/PhD/Second year/Summer paper/Output"
 set scheme plotplainblind


*--------------------------*
* Por tipo de municipality *
*--------------------------*


use "Data/merge_JF_teachers_secundaria.dta", clear
 *merge m:1 school_code using "Data/SB11_global.dta", gen(merge2)
 
* merge municipality type
	merge m:1 muni_code using "Data/divipola.dta", keepus(sed_certificada) assert(2 3) keep(3) nogen
 
* Numero de years en los que aparece
	bys document_id: gen n_years = _N
	
* Drop the ones I only observe once
	drop if n_years == 1
	
* Labels
	lab var connected_ty "Connected to Non-elected Bureaucrat"
	lab var connected_tby "Top Connected (JF)"
	lab var connected_council "Connected to Council Member"
	lab var connected_council2 "Connected to Council Member (no common last names)"
	lab var connected_council2 "Connected to Council Member (continuous var)"
	lab var connected_principal "Connected to Principal"
	lab var connected_principal2 "Connected to Principal (no common last names)"
	lab var connected_principal3 "Connected to Principal (continuous var)"
	lab var connected_directivo "Connected to Admin Staff in the School"
	lab var connected_directivo2 "Connected to Admin Staff in the School (no common last names)"
	lab var connected_directivo3 "Connected to Admin Staff in the School (continuous var)"
	lab var connected_teacher "Connected to Any Teacher in the School"
	lab var connected_teacher2 "Connected to Any Teacher in the School (no common last names)"
	lab var connected_teacher3 "Connected to Any Teacher in the School (continuous var)" 
 
* Define always connected, never connected and switchers
	br document_id year connected_ty //connected_council  connected_directivo connected_teacher
	sort document_id year
	foreach var of varlist connected_ty connected_council  connected_directivo connected_teacher  {  // 
		bys document_id (year): egen max_`var' = max(`var')
		bys document_id (year): egen min_`var' = min(`var')
		gen diff_`var' = (max_`var' != min_`var')
		gen always_`var' = (max_`var' == 1 & min_`var' == 1)
		gen never_`var' = (max_`var' == 0 & min_`var' == 0)
		gen switch_`var' = (diff_`var' == 1)
		tab  always_`var' never_`var' if switch_`var' == 0, m
		tab  always_`var' never_`var' if switch_`var' == 1, m
		drop diff_`var' max_`var' min_`var'
	} 
 
 /*
 	* Connected to public sector (JF)
		reghdfe std_score connected_ty $controls if sed_certificada == 1, absorb($fe) cluster(document_id)
		reghdfe std_score connected_ty $controls if sed_certificada == 0, absorb($fe) cluster(document_id)

	* Connected to a council member 
		reghdfe std_score connected_council $controls if sed_certificada == 1, absorb($fe) cluster(document_id)
		reghdfe std_score connected_council $controls if sed_certificada == 0, absorb($fe) cluster(document_id)
		
	* Connected to  admin staff in the school (including principal)
		reghdfe std_score connected_directivo $controls if sed_certificada == 1, absorb($fe) cluster(document_id)
		reghdfe std_score connected_directivo $controls if sed_certificada == 0, absorb($fe) cluster(document_id)
		
	* Connected to any other teacher in the school
		reghdfe std_score connected_teacher $controls if sed_certificada == 1, absorb($fe) cluster(document_id)
		reghdfe std_score connected_teacher $controls if sed_certificada == 0, absorb($fe) cluster(document_id)
		*/
		
* Define variables for event study
	br document_id year connected_ty
	sort document_id year
	 
	 foreach var of varlist connected_ty connected_council  connected_directivo connected_teacher  { // 
		gen year_`var' = year if `var' == 1
		bys document_id: egen E_`var' = min(year_`var')
		*replace E_`var' = . if  E_`var' == 2012
		gen K_`var' = year - E_`var' 
		tab K_`var'
		gen D_`var' = K_`var'>=0 & E_`var' != .
	  
 
	forvalues l = 0/3 {
			gen L`l'event_`var' = (K_`var'==`l')
		}
		forvalues l = 1/3 {
			gen F`l'event_`var' = (K_`var'==-`l')
		} 
		
	replace L3event_`var' = 1 if K_`var' > 3 & !mi(K_`var')		
	replace F3event_`var' = 1 if K_`var' < -3 & !mi(K_`var')
	 }
	 

*-------------------------------------------*
* MUNICIPIOS CERTIFICADOS Y NO CERTIFICADOS *
*-------------------------------------------*	

* Globals for regressions
	global controls  "age postgrad_degree temporary  years_exp new_estatuto"
	global fe "year document_id muni_code" 
	
	loc p_connected_ty  "Panel A"
	loc p_connected_council  "Panel B"
	loc p_connected_directivo "Panel C"
	loc p_connected_teacher "Panel D"
	
	estimates drop _all
	foreach var of varlist connected_ty  connected_directivo connected_teacher  { // 
		
		reghdfe std_score o.F1event_`var' F3event_`var' F2event_`var' L*event_`var' $controls if sed_certificada == 1 & always_`var' == 0 & E_`var' != 2012, a($fe) cluster(document_id)
		estimates store cert_`var'
		
		reghdfe std_score o.F1event_`var' F3event_`var' F2event_`var' L*event_`var' $controls if sed_certificada == 0 & always_`var' == 0 & E_`var' != 2012, a($fe) cluster(document_id)
		estimates store  noncert_`var'
		
		*reghdfe std_score o.F1event_`var' F3event_`var' F2event_`var' L*event_`var' $controls if always_`var' == 0 & E_`var' != 2012, a($fe) cluster(document_id)
		*estimates store all_`var'

		
		local title: variable label `var' 
		
		*event_plot cert_`var' noncert_`var' all_`var', stub_lag(L#event_`var' L#event_`var' L#event_`var') stub_lead(F#event_`var' F#event_`var' F#event_`var')  //
		event_plot cert_`var' noncert_`var', stub_lag(L#event_`var' L#event_`var') stub_lead(F#event_`var' F#event_`var')  ///
		plottype(scatter) ciplottype(rcap) ///
		together perturb(-0.125(0.13)0.125)  noautolegend ///
		graph_opt(name(`var', replace) title("`p_`var'': `title'", size(small)) ///
			xtitle("Years since connection", size(small)) ytitle("Average effect", size(small)) xlabel(-3(1)3)  ///
			legend(order(1 "Municipal LEA" ///
					3 "Departmental LEA") position(6) col(2)) ///
			xline(0, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
			) ///
			lag_opt1(msymbol(Dh) color(navy)) lag_ci_opt1(color(navy)) ///
			lag_opt2(msymbol(Sh) color(dkorange)) lag_ci_opt2(color(dkorange)) //lag_opt3(msymbol(Sh) color(dkorange)) lag_ci_opt3(color(dkorange))
	
	}
	
	
	foreach var of varlist  connected_council  { // 
		reghdfe std_score o.F1event_`var' F3event_`var' F2event_`var' L*event_`var' $controls if sed_certificada == 1 & always_`var' == 0, a($fe) cluster(document_id)
		estimates store cert_`var'
		
		reghdfe std_score o.F1event_`var' F3event_`var' F2event_`var' L*event_`var' $controls if sed_certificada == 0 & always_`var' == 0, a($fe) cluster(document_id)
		estimates store  noncert_`var'

		*reghdfe std_score o.F1event_`var' F3event_`var' F2event_`var' L*event_`var' $controls if always_`var' == 0, a($fe) cluster(document_id)
		*estimates store all_`var'
		
		local title: variable label `var' 
		
		*event_plot cert_`var' noncert_`var' all_`var', stub_lag(L#event_`var' L#event_`var' L#event_`var') stub_lead(F#event_`var' F#event_`var' F#event_`var')  //
		event_plot cert_`var' noncert_`var', stub_lag(L#event_`var' L#event_`var') stub_lead(F#event_`var' F#event_`var')  ///
		plottype(scatter) ciplottype(rcap) ///
		together perturb(-0.125(0.13)0.125)  noautolegend ///
		graph_opt(name(`var', replace) title("`p_`var'': `title'", size(small)) ///
			xtitle("Years since connection", size(small)) ytitle("Average effect", size(small)) xlabel(-3(1)3)  ///
			legend(order(1 "Municipal LEA" ///
					3 "Departmental LEA") position(6) col(2)) ///
			xline(0, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
			) ///
			lag_opt1(msymbol(Dh) color(navy)) lag_ci_opt1(color(navy)) ///
			lag_opt2(msymbol(Sh) color(dkorange)) lag_ci_opt2(color(dkorange)) //lag_opt3(msymbol(Sh) color(dkorange)) lag_ci_opt3(color(dkorange))
	
	}	
	
graph combine connected_ty  connected_council  connected_directivo connected_teacher
graph export "$output/heteregoneus_LEA.png", replace
graph close _all

-

*--------------------*
* School test scores *
*--------------------*

* Merge average puesto en 2011
	merge m:1 school_code using "Data/score_avg_2011.dta", gen(mergepuesto) keep(1 3) 

	
	loc p_connected_ty  "Panel A"
	loc p_connected_council  "Panel B"
	loc p_connected_directivo "Panel C"
	loc p_connected_teacher "Panel D"
	
	foreach var of varlist connected_ty  connected_directivo connected_teacher  { // 
		reghdfe std_score o.F1event_`var' F3event_`var' F2event_`var' L*event_`var' $controls if above_median == 1 & always_`var' == 0 & E_`var' != 2012, a($fe) cluster(document_id)
		estimates store above_`var'
		
		reghdfe std_score o.F1event_`var' F3event_`var' F2event_`var' L*event_`var' $controls if above_median == 0 & always_`var' == 0 & E_`var' != 2012, a($fe) cluster(document_id)
		estimates store  below_`var'
	
		reghdfe std_score o.F1event_`var' F3event_`var' F2event_`var' L*event_`var' $controls if always_`var' == 0 & E_`var' != 2012, a($fe) cluster(document_id)
		estimates store  below_`var'
		
		local title: variable label `var' 
		
		event_plot above_`var' below_`var', stub_lag(L#event_`var' L#event_`var' L#event_`var') stub_lead(F#event_`var' F#event_`var' F#event_`var')  ///
		plottype(scatter) ciplottype(rcap) ///
		together perturb(-0.125(0.13)0.125)  noautolegend ///
		graph_opt(name(`var', replace) title("`p_`var'': `title'", size(small)) ///
			xtitle("Years since connection", size(small)) ytitle("Average effect", size(small)) xlabel(-3(1)3)  ///
			legend(order(1 "Schools above median" ///
					3 "Schools below median") position(6) col(2)) ///
			xline(0, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
			) ///
			lag_opt1(msymbol(Dh) color(navy)) lag_ci_opt1(color(navy)) ///
			lag_opt2(msymbol(Sh) color(forest_green)) lag_ci_opt2(color(forest_green)) ///
			lag_opt3(msymbol(Sh) color(dkorange)) lag_ci_opt3(color(dkorange))
	
	}
 	
	foreach var of varlist  connected_council { // 
		reghdfe std_score o.F1event_`var' F3event_`var' F2event_`var' L*event_`var' $controls if above_median == 1 & always_`var' == 0 , a($fe) cluster(document_id)
		estimates store above_`var'
		
		reghdfe std_score o.F1event_`var' F3event_`var' F2event_`var' L*event_`var' $controls if above_median == 0 & always_`var' == 0 , a($fe) cluster(document_id)
		estimates store  below_`var'
	
		reghdfe std_score o.F1event_`var' F3event_`var' F2event_`var' L*event_`var' $controls if always_`var' == 0 , a($fe) cluster(document_id)
		estimates store  below_`var'
		
		local title: variable label `var' 
		
		event_plot above_`var' below_`var', stub_lag(L#event_`var' L#event_`var' L#event_`var') stub_lead(F#event_`var' F#event_`var' F#event_`var')  ///
		plottype(scatter) ciplottype(rcap) ///
		together perturb(-0.125(0.13)0.125)  noautolegend ///
		graph_opt(name(`var', replace) title("`p_`var'': `title'", size(small)) ///
			xtitle("Years since connection", size(small)) ytitle("Average effect", size(small)) xlabel(-3(1)3)  ///
			legend(order(1 "Schools above median" ///
					3 "Schools below median") position(6) col(2)) ///
			xline(0, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
			) ///
			lag_opt1(msymbol(Dh) color(navy)) lag_ci_opt1(color(navy)) ///
			lag_opt2(msymbol(Sh) color(forest_green)) lag_ci_opt2(color(forest_green)) ///
			lag_opt3(msymbol(Sh) color(dkorange)) lag_ci_opt3(color(dkorange))
	
	}	
	
	
	graph combine connected_ty  connected_council  connected_directivo connected_teacher
graph export "$output/heteregoneus_school.png", replace
	graph close _all	


*--------------------------*
* Teachers characteristics *
*--------------------------*	
	
use "Data/merge_JF_teachers_secundaria.dta", clear

* Numero de years en los que aparece
	bys document_id: gen n_years = _N
	
* Drop the ones I only observe once
	drop if n_years == 1

* Define always connected, never connected and switchers
	br document_id year connected_ty //connected_council  connected_directivo connected_teacher
	sort document_id year
	foreach var of varlist connected_ty connected_council  connected_directivo connected_teacher  {  // 
		bys document_id (year): egen max_`var' = max(`var')
		bys document_id (year): egen min_`var' = min(`var')
		gen diff_`var' = (max_`var' != min_`var')
		gen always_`var' = (max_`var' == 1 & min_`var' == 1)
		gen never_`var' = (max_`var' == 0 & min_`var' == 0)
		gen switch_`var' = (diff_`var' == 1)
		tab  always_`var' never_`var' if switch_`var' == 0, m
		tab  always_`var' never_`var' if switch_`var' == 1, m
		drop diff_`var' max_`var' min_`var'
	} 
 
* Connected with apellido 1
	rename apellido1 apellido
	merge m:1 year school_code apellido using "Data/teachers_heterogeneous", gen(merge1) assert(2 3) keep(3)
	
* Create relevant vars
	br document_id apellido connected_teacher icfes_subject subject_lec subject_math subject_ciencia subject_soc subject_ing new_estatuto new_estatuto_tot years_exp exp_15
	
* generate variables

	* Connected to someone in the same subject
		sort document_id year
		br document_id apellido connected_teacher icfes_subject subject_lec subject_math subject_ciencia subject_soc subject_ing
		
		gen 	connected_subject = .
		replace connected_subject = 1 if connected_teacher == 1 & (icfes_subject == 1 & subject_lec>1)
		replace connected_subject = 1 if connected_teacher == 1 & (icfes_subject == 2 & subject_math>1)
		replace connected_subject = 1 if connected_teacher == 1 & (icfes_subject == 3 & subject_ciencia>1)
		replace connected_subject = 1 if connected_teacher == 1 & (icfes_subject == 4 & subject_soc>1)
		replace connected_subject = 1 if connected_teacher == 1 & (icfes_subject == 5 & subject_ing>1)
		replace connected_subject = 0 if connected_teacher == 1 & mi(connected_subject)
		
	* Connected to someone with the new estatuto
		br document_id apellido connected_teacher new_estatuto new_estatuto_tot 
		gen 	connected_estatuto = .
		replace connected_estatuto = 1 if connected_teacher == 1 & new_estatuto_tot > 1
		replace connected_estatuto = 0 if connected_teacher == 1 & mi(connected_estatuto)

	* Connected to someone with. more than 15 years of experience
		br document_id apellido connected_teacher years_exp exp_15
		gen 	connected_senior = .
		replace connected_senior = 1 if connected_teacher == 1 & exp_15 > 1
		replace connected_senior = 0 if connected_teacher == 1 & mi(connected_senior)
		
	* generate max for each teacher
		foreach var of varlist connected_subject connected_estatuto  connected_senior  { 
			tab `var', m
			rename `var' `var'_y
			bys document_id: egen `var' = max(`var'_y)
			tab `var', m
		 }

		lab var connected_senior "Connected to a teacher with more than 15 years of experience"
		lab var connected_subject "Connected to a teacher in the same subject"
		lab var connected_estatuto "Connected to a teacher in the new regulation"		 
		 
	* Gen vars for event study	
	 foreach var of varlist connected_teacher  { // 
		gen year_`var' = year if `var' == 1
		bys document_id: egen E_`var' = min(year_`var')
		*replace E_`var' = . if  E_`var' == 2012
		gen K_`var' = year - E_`var' 
		tab K_`var'
		gen D_`var' = K_`var'>=0 & E_`var' != .
	  
 
	forvalues l = 0/3 {
			gen L`l'event_`var' = (K_`var'==`l')
		}
		forvalues l = 1/3 {
			gen F`l'event_`var' = (K_`var'==-`l')
		} 
		
	replace L3event_`var' = 1 if K_`var' > 3 & !mi(K_`var')		
	replace F3event_`var' = 1 if K_`var' < -3 & !mi(K_`var')
	 }		
		
* Globals for regressions
	global controls  "age postgrad_degree temporary  years_exp new_estatuto"
	global fe "year document_id muni_code" 
	
	estimates drop _all		
		
	loc p_connected_subject "Panel A"
	loc p_connected_senior "Panel B"
		
	* Gen graphs	
	foreach var of varlist connected_subject  connected_senior  { // 
		reghdfe std_score o.F1event_connected_teacher F3event_connected_teacher F2event_connected_teacher L*event_connected_teacher $controls if `var' == 1 & always_connected_teacher == 0 & E_connected_teacher != 2012, a($fe) cluster(document_id)
		estimates store yes_`var'
		
		reghdfe std_score o.F1event_connected_teacher F3event_connected_teacher F2event_connected_teacher L*event_connected_teacher $controls if `var' == 0 & always_connected_teacher == 0 & E_connected_teacher != 2012, a($fe) cluster(document_id)
		estimates store  no_`var'

		
		local title: variable label `var' 
		
		event_plot yes_`var' no_`var', stub_lag(L#event_connected_teacher L#event_connected_teacher) stub_lead(F#event_connected_teacher F#event_connected_teacher)  ///
		plottype(scatter) ciplottype(rcap) ///
		together perturb(-0.125(0.13)0.125)  noautolegend ///
		graph_opt(name(`var', replace) title("`p_`var'': `title'", size(vsmall)) ///
			xtitle("Years since connection") ytitle("Average effect", size(small)) xlabel(-3(1)3)  ///
			legend(order(1 "Yes" ///
					3 "No") position(6) col(2)) ///
			xline(0, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
			) ///
			lag_opt1(msymbol(Dh) color(navy)) lag_ci_opt1(color(navy)) ///
			lag_opt2(msymbol(Sh) color(dkorange)) lag_ci_opt2(color(dkorange))
	
	}


graph combine connected_subject  connected_senior
graph export "$output/heteregoneus_teacher.png", replace
	graph close _all	




	

	