 cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"

	global controls  "age type_contract"		
 
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
	
foreach var of varlist connected_ty  connected_council  connected_directivo connected_teacher {
	gen year_`var' = year if `var' == 1
	bys document_id: egen event_`var' = min(year_`var')
	replace event_`var' = . if  event_`var' == 2012
	gen t_`var' = year - event_`var' 

	* Create binned variable
		tab t_`var'
		gen 	t_bin_`var' = t_`var'
		replace t_bin_`var' = 3 if t_`var' > 3 & t_`var' != .
		replace t_bin_`var' = -3 if t_`var' < -3
		tab t_`var' t_bin_`var'

	* Create event time dummies
		tab t_bin_`var', gen(D_time_`var')
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
		
	
	local title: variable label `var' 
	
	reghdfe std_score D_time_`var'_3 D_time_`var'_2 D_time_`var'0 D_time_`var'1 D_time_`var'2 D_time_`var'3 D_time_`var'_1 $controls, absorb(year document_id)
	
	loc order_var "D_time_`var'_3 D_time_`var'_2 D_time_`var'_1 D_time_`var'0 D_time_`var'1 D_time_`var'2 D_time_`var'3 "
	
	loc graph_opts "vertical keep(D_time*) omitted graphregion(color(white)) xtitle(Years before connection, size(small)) ytitle(Coefficients, size(small)) xsize(16) ysize(9) yline(0)  msize(small) ylabel(,labsize(vsmall)) xlabel(,labsize(vsmall))"
	coefplot, name(`var', replace) title("`title'", size(smalll)) order(`order_var') `graph_opts'
}

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
	
	reghdfe std_score D_lose_`var'_3 D_lose_`var'_2 D_lose_`var'0 D_lose_`var'1 D_lose_`var'2 D_lose_`var'3 D_lose_`var'_1 $controls, absorb(year document_id)
	loc order_var "D_lose_`var'_3 D_lose_`var'_2 D_lose_`var'_1 D_lose_`var'0 D_lose_`var'1 D_lose_`var'2 D_lose_`var'3 "
	
	loc graph_opts "vertical keep(D_lose_*) omitted graphregion(color(white)) xtitle(Years before losing connection, size(small)) ytitle(Coefficients, size(small)) xsize(16) ysize(9) yline(0)  msize(small) ylabel(,labsize(vsmall)) xlabel(,labsize(vsmall))"
	
	coefplot, name(lose_`var', replace) title("`title'", size(smalll)) order(`order_var') `graph_opts'
}	

	
graph combine lose_connected_ty  lose_connected_council  lose_connected_directivo lose_connected_teacher, name(losing_connection, replace)
graph export "$output/losing_connection.png", replace
graph close _all	
	-
	
	
	
	
	
	
	