clear all
cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"
global log "/Users/camila/Documents/GitHub/mcayala_research/Summer paper/Log files"
global output "/Users/camila/Dropbox/PhD/Second year/Summer paper/Output"
set scheme plotplainblind

*---------------------------------*
* Variation in family connections *
*---------------------------------*

*log using "${log}/results_saber11_familyconn_variation_$date.log", replace

use "Data/merge_JF_teachers_secundaria.dta", clear

* Numero de years en los que aparece
	bys document_id: gen n_years = _N
	
* Drop the ones I only observe once
	drop if n_years == 1
	sum connected_*

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
 
* Define variables for event study
	br document_id year connected_ty
	sort document_id year
	 
	 foreach var of varlist connected_ty  connected_council  connected_directivo connected_teacher connected_council2  connected_directivo2 connected_teacher2 { // 
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

* Run event studies and graphs
	loc p_connected_ty  "Panel A"
	loc p_connected_council  "Panel B"
	loc p_connected_directivo "Panel C"
	loc p_connected_teacher "Panel D"
	foreach var of varlist connected_ty   connected_directivo connected_teacher { // 
		
		reghdfe std_score o.F1event_`var' F3event_`var' F2event_`var' L*event_`var' $controls if E_`var' != 2012 & always_`var' == 0, a($fe) cluster(document_id)
		estimates store ols_`var'
		
		local title: variable label `var' 
		
		event_plot ols_`var', stub_lag(L#event_`var' L#event_`var') stub_lead(F#event_`var' F#event_`var')  ///
		plottype(scatter) ciplottype(rcap) ///
		together graph_opt(name(`var', replace) title("`p_`var'': `title'", size(small)) ///
			xtitle("Years since connection", size(small)) ytitle("Average effect", size(small)) xlabel(-3(1)3)  ///
			xline(0, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
			) ///
			lag_opt1(msymbol(Dh) color(navy)) lag_ci_opt1(color(navy)) 	
	}
 	
	foreach var of varlist   connected_council   { // 
		
		reghdfe std_score o.F1event_`var' F3event_`var' F2event_`var' L*event_`var' $controls if  always_`var' == 0, a($fe) cluster(document_id)
		estimates store ols_`var'
		
		local title: variable label `var' 
		
		event_plot ols_`var', stub_lag(L#event_`var' L#event_`var') stub_lead(F#event_`var' F#event_`var')  ///
		plottype(scatter) ciplottype(rcap) ///
		together graph_opt(name(`var', replace) title("`p_`var'': `title'", size(small)) ///
			xtitle("Years since connection", size(small)) ytitle("Average effect", size(small)) xlabel(-3(1)3)  ///
			xline(0, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
			) ///
			lag_opt1(msymbol(Dh) color(navy)) lag_ci_opt1(color(navy)) 	
	}
	
graph combine connected_ty  connected_council  connected_directivo connected_teacher

graph export "$output/event_study.png", replace
graph close _all

* Run event studies and graphs
	lab var connected_council2 "Connected to Council Member"
	lab var connected_directivo2 "Connected to Admin Staff in the School"
	lab var connected_teacher2 "Connected to Any Teacher in the School"
	
	loc p_connected_council2  "Panel A"
	loc p_connected_directivo2 "Panel B"
	loc p_connected_teacher2 "Panel C"
	loc always_connected_council2  "always_connected_council"
	loc always_connected_directivo2 "always_connected_directivo"
	loc always_connected_teacher2 "always_connected_teacher"
	foreach var of varlist   connected_directivo2 connected_teacher2 { // 
		
		reghdfe std_score o.F1event_`var' F3event_`var' F2event_`var' L*event_`var' $controls if E_`var' != 2012 & `always_`var'' == 0, a($fe) cluster(document_id)
		estimates store ols_`var'
		
		local title: variable label `var' 
		
		event_plot ols_`var', stub_lag(L#event_`var' L#event_`var') stub_lead(F#event_`var' F#event_`var')  ///
		plottype(scatter) ciplottype(rcap) ///
		together graph_opt(name(`var', replace) title("`p_`var'': `title'", size(small)) ///
			xtitle("Years since connection", size(small)) ytitle("Average effect", size(small)) xlabel(-3(1)3)  ///
			xline(0, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
			) ///
			lag_opt1(msymbol(Dh) color(navy)) lag_ci_opt1(color(navy)) 	
	}
 	
	foreach var of varlist   connected_council2  { // 
		
		reghdfe std_score o.F1event_`var' F3event_`var' F2event_`var' L*event_`var' $controls if `always_`var'' == 0, a($fe) cluster(document_id)
		estimates store ols_`var'
		
		local title: variable label `var' 
		
		event_plot ols_`var', stub_lag(L#event_`var' L#event_`var') stub_lead(F#event_`var' F#event_`var')  ///
		plottype(scatter) ciplottype(rcap) ///
		together graph_opt(name(`var', replace) title("`p_`var'': `title'", size(small)) ///
			xtitle("Years since connection", size(small)) ytitle("Average effect", size(small)) xlabel(-3(1)3)  ///
			xline(0, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
			) ///
			lag_opt1(msymbol(Dh) color(navy)) lag_ci_opt1(color(navy)) 	
	}
	
graph combine  connected_council2  connected_directivo2 connected_teacher2

graph export "$output/event_study_nocommon.png", replace
graph close _all


*-------------------------------*
* Connected with balanced panel *
*-------------------------------*

	* keep teachers that are all the time
		sort document_id year	
		tab year, gen(y_)
		rename (y_1 y_2 y_3 y_4 y_5 y_6) (y_2012 y_2013 y_2014 y_2015 y_2016 y_2017)
		br document_id year y_*
		sort document_id year
		foreach y in 2012 2013 2014 2015 2016 2017 {
			bys document_id: egen year_`y' = max(y_`y')
		}
		egen tot_y = rowtotal(year_2012 year_2013 year_2014 year_2015 year_2016 year_2017)
		
		bys document_id (year): gen count = _n
		tab tot_y if count == 1 
		drop count
		keep if tot_y == 6

	loc p_connected_ty  "Panel A"
	loc p_connected_council  "Panel B"
	loc p_connected_directivo "Panel C"
	loc p_connected_teacher "Panel D"
	foreach var of varlist connected_ty    connected_directivo connected_teacher { // 
		
		reghdfe std_score o.F1event_`var' F3event_`var' F2event_`var' L*event_`var' $controls if E_`var' != 2012 & always_`var' == 0, a($fe) cluster(document_id)
		estimates store ols_`var'
		
		local title: variable label `var' 
		
		event_plot ols_`var', stub_lag(L#event_`var' L#event_`var') stub_lead(F#event_`var' F#event_`var')  ///
		plottype(scatter) ciplottype(rcap) ///
		together graph_opt(name(`var', replace) title("`p_`var'': `title'", size(small)) ///
			xtitle("Years since connection", size(small)) ytitle("Average effect", size(small)) xlabel(-3(1)3)  ///
			xline(0, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
			) ///
			lag_opt1(msymbol(Dh) color(navy)) lag_ci_opt1(color(navy)) 	
	}
 
	foreach var of varlist   connected_council   { // 
		
		reghdfe std_score o.F1event_`var' F3event_`var' F2event_`var' L*event_`var' $controls if always_`var' == 0, a($fe) cluster(document_id)
		estimates store ols_`var'
		
		local title: variable label `var' 
		
		event_plot ols_`var', stub_lag(L#event_`var' L#event_`var') stub_lead(F#event_`var' F#event_`var')  ///
		plottype(scatter) ciplottype(rcap) ///
		together graph_opt(name(`var', replace) title("`p_`var'': `title'", size(small)) ///
			xtitle("Years since connection", size(small)) ytitle("Average effect", size(small)) xlabel(-3(1)3)  ///
			xline(0, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
			) ///
			lag_opt1(msymbol(Dh) color(navy)) lag_ci_opt1(color(navy)) 	
	}
	
graph combine connected_ty  connected_council  connected_directivo connected_teacher
graph export "$output/event_study_balancedpanel.png", replace
graph close _all








