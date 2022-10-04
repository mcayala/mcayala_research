/* ssc install did_imputation, replace
 ssc install event_plot, replace
 ssc install did_multiplegt, replace
 ssc install eventstudyinteract, replace
 */
cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"
 
 
global controls  "age postgrad_degree temporary urban years_exp new_estatuto"
global fe "year document_id" 
global output "/Users/camila/Dropbox/PhD/Second year/Summer paper/output"

use "Data/merge_JF_teachers_secundaria.dta", clear

	lab var connected_ty "Connected to Non-elected Bureaucrat"
	lab var connected_tby "Top Connected (JF)"
	lab var connected_council "Connected to Council Member"
	lab var connected_council2 "Connected to Council Member (no common last names)"
	lab var connected_council3 "Connected to Council Member (continuous var)"
	lab var connected_principal "Connected to Principal"
	lab var connected_principal2 "Connected to Principal (no common last names)"
	lab var connected_principal3 "Connected to Principal (continuous var)"
	lab var connected_directivo "Connected to Admin Staff in the School"
	lab var connected_directivo2 "Connected to Admin Staff in the School (no common last names)"
	lab var connected_directivo3 "Connected to Admin Staff in the School (continuous var)"
	lab var connected_teacher "Connected to Any Teacher in the School"
	lab var connected_teacher2 "Connected to Any Teacher in the School (no common last names)"
	lab var connected_teacher3 "Connected to Any Teacher in the School (continuous var)"

drop connected_*3

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
  
* Define variables for event study
	br document_id year connected_ty
	sort document_id year
	 
	 foreach var of varlist connected_ty { // connected_council  connected_directivo connected_teacher 
		gen year_`var' = year if `var' == 1
		bys document_id: egen E_`var' = min(year_`var')
		replace E_`var' = . if  E_`var' == 2012
		gen K_`var' = year - E_`var' 
		tab K_`var'
		gen D_`var' = K_`var'>=0 & E_`var' != .
	 } 
 
	forvalues l = 0/3 {
			gen L`l'event = (K_connected_ty==`l')
		}
		forvalues l = 1/3 {
			gen F`l'event = (K_connected_ty==-`l')
		} 
		
	replace L3event = 1 if K_connected_ty > 3 & !mi(K_connected_ty)		
	replace F3event = 1 if K_connected_ty < -3 & !mi(K_connected_ty)
 
* Elegir los mpios con connected_ty
	bys muni_code: egen max = max(connected_ty)
	bys muni_code: gen count_muni = _n
 
 
 
 
 
 	reghdfe std_score o.F1event F3event F2event L*event $controls, a(document_id year) cluster(document_id)
 	event_plot, default_look stub_lag(L#event) stub_lead(F#event) together graph_opt(xtitle("Days since the event") ytitle("OLS coefficients") xlabel(-3(1)3) ///
		title("OLS") name(graph1, replace))
		
	reghdfe std_score o.F1event F3event F2event L*event $controls if always_connected_ty == 0, a(document_id year) cluster(document_id)
	event_plot, default_look stub_lag(L#event) stub_lead(F#event) together graph_opt(xtitle("Days since the event") ytitle("OLS coefficients") xlabel(-3(1)3) ///
		title("OLS") name(graph2, replace))
		
	reghdfe std_score o.F1event F2event F3event L*event $controls if switch_connected_ty == 1, a(document_id year) cluster(document_id)	
event_plot, default_look stub_lag(L#event) stub_lead(F#event) together graph_opt(xtitle("Days since the event") ytitle("OLS coefficients") xlabel(-3(1)3) ///
		title("OLS") name(graph3, replace) ylabel(-.2(.1).2))	
	
 -
 
 
* Estimation with did_imputation of Borusyak et al. (2021)
	*did_imputation std_score document_id year K_connected_ty, allhorizons pretrend(3) 
 
* Estimation with did_multiplegt of de Chaisemartin and D'Haultfoeuille (2020)
	did_multiplegt std_score document_id year D_connected_ty, robust_dynamic dynamic(3) placebo(3) breps(100) cluster(document_id) 
	event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
		title("de Chaisemartin and D'Haultfoeuille (2020)") xlabel(-3(1)3)) stub_lag(Effect_#) stub_lead(Placebo_#) together
	 

	matrix dcdh_b = e(estimates) // storing the estimates for later
	matrix dcdh_v = e(variances) 
	 
* Estimation with eventstudyinteract of Sun and Abraham (2020)
	sum E_connected_ty
	gen lastcohort = E_connected_ty==r(max) // dummy for the latest- or never-treated cohort
	replace E_connected_ty = 1 if mi(E_connected_ty)
	forvalues l = 0/3 {
		gen L`l'event = K==`l'
	}
	forvalues l = 1/3 {
		gen F`l'event = K==-`l'
	}
	*drop F1event // normalize K=-1 (and also K=-15) to zero
	eventstudyinteract std_score L*event F2event F3event, vce(cluster document_id) absorb(document_id year) cohort(E_connected_ty) control_cohort(lastcohort)
	event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-3(1)3) ///
		title("Sun and Abraham (2020)")) stub_lag(L#event) stub_lead(F#event) together

	matrix sa_b = e(b_iw) // storing the estimates for later
	matrix sa_v = e(V_iw)
	 
// TWFE OLS estimation (which is correct here because of treatment effect homogeneity). Some groups could be binned.
	replace L3event = (K_`var'>=3 & !mi(K_`var'))
    replace F3event = (K_`var'<=-3  & !mi(K_`var'))

 
	reghdfe std_score o.F1event F3event F2event L*event, a(document_id year) cluster(document_id)

	event_plot, default_look stub_lag(L#event) stub_lead(F#event) together graph_opt(xtitle("Days since the event") ytitle("OLS coefficients") xlabel(-3(1)3) ///
		title("OLS"))

	estimates store ols // saving the estimates for later 
 
 
event_plot dcdh_b#dcdh_v sa_b#sa_v ols, ///
	stub_lag(Effect_# L#event L#event) stub_lead(Placebo_# F#event F#event)	plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325)  noautolegend ///
	graph_opt(title("Event study estimators", size(medlarge)) ///
		xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-3(1)3)  ///
		legend(order(1 "de Chaisemartin-D'Haultfoeuille" ///
				2 "OLS" 3 "Sun-Abraham" ) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(Dh) color(navy)) lag_ci_opt1(color(navy)) ///
	lag_opt2(msymbol(Th) color(forest_green)) lag_ci_opt2(color(forest_green)) ///
	lag_opt3(msymbol(Sh) color(dkorange)) lag_ci_opt3(color(dkorange)) 
	
	
	-
	graph export "five_estimators_example.png", replace 
 
 
 
 
 
 
 
 
 
 
 
 
 
	
	* Create event time dummies
		* Lags
		forvalues l = 0/3 {
			gen L`l'event = (t_`var'==`l')
		}
		replace L3event = (t_`var'>=3 & !mi(t_`var'))
		
		* Leads
		forvalues l = 1/3 { 
                gen F`l'event = (t_`var'==-`l')
        }
        replace F3event = (t_`var'<=-3  & !mi(t_`var'))
		
	
	local title: variable label `var' 
	
	reghdfe std_score o.F1event F3event F2event L*event if event_`var' != 2012, absorb($fe) cluster(document_id)
	
	event_plot, default_look stub_lag(L#event) stub_lead(F#event) together plottype(scatter) ///
                graph_opt(xtitle("Years since the event")  name(`var', replace) title("`title'", size(smalll)) xlabel(-3(1)3))
				
	drop F*event L*event 
	
}
 
 graph combine connected_ty  connected_council  connected_directivo connected_teacher, name(gaining_connection, replace)

				-
			
 /*
 cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"
 
 
global controls  "age postgrad_degree temporary urban years_exp new_estatuto"
global fe "year document_id muni_code" 
 global output "/Users/camila/Dropbox/PhD/Second year/Summer paper/output"

 
 
use "Data/merge_JF_teachers_secundaria.dta", clear

	lab var connected_ty "Connected to Non-elected Bureaucrat"
	lab var connected_tby "Top Connected (JF)"
	lab var connected_council "Connected to Council Member"
	lab var connected_council2 "Connected to Council Member (no common last names)"
	lab var connected_council3 "Connected to Council Member (continuous var)"
	lab var connected_principal "Connected to Principal"
	lab var connected_principal2 "Connected to Principal (no common last names)"
	lab var connected_principal3 "Connected to Principal (continuous var)"
	lab var connected_directivo "Connected to Admin Staff in the School"
	lab var connected_directivo2 "Connected to Admin Staff in the School (no common last names)"
	lab var connected_directivo3 "Connected to Admin Staff in the School (continuous var)"
	lab var connected_teacher "Connected to Any Teacher in the School"
	lab var connected_teacher2 "Connected to Any Teacher in the School (no common last names)"
	lab var connected_teacher3 "Connected to Any Teacher in the School (continuous var)"

drop connected_*3


foreach var of varlist connected_ty  connected_council  connected_directivo connected_teacher {
	gen year_`var' = year if `var' == 1
	bys document_id: egen event_`var' = min(year_`var')
	gen t_`var' = year - event_`var' 
}


did_imputation std_score document_id t_connected_teacher event_connected_teacher, horizons(3) minn(0)


 
 did_multiplegt std_score document_id year connected_teacher,  breps(100)
 
 Y G T D 
 */
 
 
 
 
 set scheme plotplainblind

global controls  "age postgrad_degree temporary urban years_exp new_estatuto"
 
 global output "/Users/camila/Dropbox/PhD/Second year/Summer paper/output"

use "Data/merge_JF_teachers_secundaria.dta", clear

	lab var connected_ty "Connected to Non-elected Bureaucrat"
	lab var connected_tby "Top Connected (JF)"
	lab var connected_council "Connected to Council Member"
	lab var connected_council2 "Connected to Council Member (no common last names)"
	lab var connected_council3 "Connected to Council Member (continuous var)"
	lab var connected_principal "Connected to Principal"
	lab var connected_principal2 "Connected to Principal (no common last names)"
	lab var connected_principal3 "Connected to Principal (continuous var)"
	lab var connected_directivo "Connected to Admin Staff in the School"
	lab var connected_directivo2 "Connected to Admin Staff in the School (no common last names)"
	lab var connected_directivo3 "Connected to Admin Staff in the School (continuous var)"
	lab var connected_teacher "Connected to Any Teacher in the School"
	lab var connected_teacher2 "Connected to Any Teacher in the School (no common last names)"
	lab var connected_teacher3 "Connected to Any Teacher in the School (continuous var)"

drop connected_*3

*----------------------*
* Winning a connection *
*----------------------*	
	
foreach var of varlist connected_ty { //connected_council  connected_directivo connected_teacher {
	*gen year_`var' = year if `var' == 1
	*bys document_id: egen event_`var' = min(year_`var')
	*replace event_`var' = . if  event_`var' == 2012
	*gen t_`var' = year - event_`var' 

	* Create binned variable
		tab t_`var'
		gen 	t_bin_`var' = t_`var'
		replace t_bin_`var' = 3 if t_`var' > 3 & t_`var' != .
		replace t_bin_`var' = -3 if t_`var' < -3
		tab t_`var' t_bin_`var'

	* Create event time dummies
		tab t_bin_`var', gen(D_time_`var') missing
		forvalues i = 1/7 {
			loc j = `i' - 4
			lab var D_time_`var'`i' "`j'"
			if `j' < 0 {
				loc k = -`j'
				rename D_time_`var'`i' D_time_`var'_`k'
			}
			else {
			rename D_time_`var'`i' D_time_`var'`j'
			}
		}		
		
foreach var of varlist connected_ty { //connected_council  connected_directivo connected_teacher {
	
	local title: variable label `var' 
	
	reghdfe std_score D_time_`var'_3 D_time_`var'_2 D_time_`var'0 D_time_`var'1 D_time_`var'2 D_time_`var'3 D_time_`var'_1 $controls, absorb(year document_id muni_code)
	
	loc order_var "D_time_`var'_3 D_time_`var'_2 D_time_`var'_1 D_time_`var'0 D_time_`var'1 D_time_`var'2 D_time_`var'3 "
	
	loc graph_opts "vertical keep(D_time*) omitted graphregion(color(white)) xtitle(Years before connection, size(small)) ytitle(Coefficients, size(small)) xsize(16) ysize(9) yline(0)  msize(small) ylabel(,labsize(vsmall)) xlabel(,labsize(vsmall))"
	coefplot, name(`var', replace) title("`title'", size(smalll)) order(`order_var') `graph_opts'
}
-
graph combine connected_ty  connected_council  connected_directivo connected_teacher, name(gaining_connection, replace)
graph export "$output/gaining_connection.png", replace
graph close _all


*---------------------*
* Losing a connection *
*---------------------*	
	
	br document_id year connected_ty
	sort document_id year
	
foreach var of varlist connected_ty  connected_council  connected_directivo connected_teacher {
	bys document_id: egen event_lose_`var' = max(year_`var')
	replace event_lose_`var' = . if  event_lose_`var' == 2017
	gen t_lose_`var' = year - event_lose_`var' -1
	
	* Create binned variable
		tab t_lose_`var'
		gen 	t_bin_lose_`var' = t_lose_`var'
		replace t_bin_lose_`var' = 3 if t_lose_`var' > 3 & t_lose_`var' != .
		replace t_bin_lose_`var' = -3 if t_lose_`var' < -3
		tab t_lose_`var' t_bin_lose_`var'
	
	* Create event time dummies
		tab t_bin_lose_`var', gen(D_lose_`var')
		forvalues i = 1/7 {
			loc j = `i' - 4
			lab var D_lose_`var'`i' "`j'"
			if `j' < 0 {
				loc k = -`j'
				rename D_lose_`var'`i' D_lose_`var'_`k'
			}
			else {
			rename D_lose_`var'`i' D_lose_`var'`j'
			}
		}		
		
	local title: variable label `var' 
	
	reghdfe std_score D_lose_`var'_3 D_lose_`var'_2 D_lose_`var'0 D_lose_`var'1 D_lose_`var'2 D_lose_`var'3 D_lose_`var'_1 $controls, absorb(year document_id muni_code)
	loc order_var "D_lose_`var'_3 D_lose_`var'_2 D_lose_`var'_1 D_lose_`var'0 D_lose_`var'1 D_lose_`var'2 D_lose_`var'3 "
	
	loc graph_opts "vertical keep(D_lose_*) omitted graphregion(color(white)) xtitle(Years before losing connection, size(small)) ytitle(Coefficients, size(small)) xsize(16) ysize(9) yline(0)  msize(small) ylabel(,labsize(vsmall)) xlabel(,labsize(vsmall))"
	
	coefplot, name(lose_`var', replace) title("`title'", size(smalll)) order(`order_var') `graph_opts'
}	

	
graph combine lose_connected_ty  lose_connected_council  lose_connected_directivo lose_connected_teacher, name(losing_connection, replace)
graph export "$output/losing_connection.png", replace
graph close _all	
	-
	
	
	
	
	
	
	