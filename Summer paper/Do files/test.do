cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"

use "Data/merge_JF_teachers_secundaria.dta", clear

* First keep teachers that are all the time
	tab year, gen(y_)
	rename (y_1 y_2 y_3 y_4 y_5 y_6) (y_2012 y_2013 y_2014 y_2015 y_2016 y_2017)
	br document_id year y_*
	sort document_id year
	foreach y in 2012 2013 2014 2015 2016 2017 {
		bys document_id: egen year_`y' = max(y_`y')
	}
	egen tot_y = rowtotal(year_*)
	
	bys document_id (year): gen count = _n
	tab tot_y if count == 1 
	/*
	      tot_y |      Freq.     Percent        Cum.
	------------+-----------------------------------
			  1 |     22,959       17.25       17.25
			  2 |     15,898       11.95       29.20
			  3 |     18,356       13.79       43.00
			  4 |     11,580        8.70       51.70
			  5 |     17,007       12.78       64.48
			  6 |     47,265       35.52      100.00 // 35% of individual are there for the six years
	------------+-----------------------------------
		  Total |    133,065      100.00

	*/
	
	keep if tot_y == 6
	
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
	
	
	br document_id year c 
	
foreach var of varlist connected_ty connected_tby connected_council connected_teacher connected_principal connected_directivo {
	gen year_`var' = year if `var' == 1
	bys document_id: egen event_`var' = min(year_`var')
	gen t_`var' = year - event_`var' +1

	* Create binned variable
		tab t_`var'
		gen 	t_bin_`var' = t_`var'
		replace t_bin_`var' = 4 if t_`var' > 4 & t_`var' != .
		replace t_bin_`var' = -3 if t_`var' < -3
		tab t_`var' t_bin_`var'

	* Create event time dummies
		tab t_bin_`var', gen(D_time_`var')
		forvalues i = 1/8 {
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
	
	reghdfe std_score D_time_`var'_3 D_time_`var'_2 D_time_`var'0 D_time_`var'1 D_time_`var'2 D_time_`var'3 D_time_`var'4 D_time_`var'_1 $controls, absorb(year document_id)
	loc order_var "D_time_`var'_3 D_time_`var'_2 D_time_`var'_1 D_time_`var'0 D_time_`var'1 D_time_`var'2 D_time_`var'3 D_time_`var'4 "
	loc graph_opts "vertical keep(D_time*) omitted graphregion(color(white)) xtitle(Years before connection, size(small)) ytitle(Coefficients, size(small)) xsize(16) ysize(9) yline(0)  msize(small) ylabel(,labsize(vsmall)) xlabel(,labsize(vsmall))"
	coefplot, name(`var', replace) title("`title'", size(smalll)) order(`order_var') `graph_opts'
}
