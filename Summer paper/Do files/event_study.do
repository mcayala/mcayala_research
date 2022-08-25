 cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"

	global controls  "age type_contract"		
 
 
use "Data/merge_JF_teachers_secundaria.dta", clear
drop *_ap*

	lab var connected_ty "Connected (JF)"
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
	
	
foreach var of varlist connected_ty connected_tby connected_council connected_council2 connected_teacher connected_teacher2 connected_principal connected_principal2 connected_directivo connected_directivo2 {
	gen year_`var' = year if `var' == 1
	bys document_id: egen event_`var' = min(year_`var')
	gen t_`var' = year - event_`var' +1

	* Create binned variable
		*histogram enacted if t == 0
		tab t_`var'
		gen 	t_bin_`var' = t_`var'
		replace t_bin_`var' = 3 if t_`var' > 2 & t_`var' != .
		replace t_bin_`var' = -2 if t_`var' < -2
		tab t_`var' t_bin_`var'

	* Create event time dummies
		tab t_bin_`var', gen(D_time_`var')
		forvalues i = 1/6 {
			loc j = `i' - 3
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
	
	reghdfe std_score D_time_`var'_2 D_time_`var'0 D_time_`var'1 D_time_`var'2 D_time_`var'3 D_time_`var'_1 $controls, absorb(year document_id)
	loc order_var "D_time_`var'_2 D_time_`var'_1 D_time_`var'0 D_time_`var'1 D_time_`var'2 D_time_`var'3 "
	loc graph_opts "vertical keep(D_time*) omitted graphregion(color(white)) xtitle(Years before connection, size(small)) ytitle(Coefficients, size(small)) xsize(16) ysize(9) yline(0)  msize(small) ylabel(,labsize(vsmall)) xlabel(,labsize(vsmall))"
	coefplot, name(`var', replace) title("`title'", size(smalll)) order(`order_var') `graph_opts'
}
