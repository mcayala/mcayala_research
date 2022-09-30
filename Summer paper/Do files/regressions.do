 cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"
global log "/Users/camila/Documents/GitHub/mcayala_research/Summer paper/Log files"
global output "/Users/camila/Dropbox/PhD/Second year/Summer paper/Output"
*set scheme plotplainblind

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
 
* Globals for regressions
	global controls  "age postgrad_degree temporary  years_exp new_estatuto"
	global fe "year document_id muni_code"
	
	preserve
	
 	* Connected to public sector (JF)
		reghdfe std_score connected_ty $controls if always_connected_ty == 0, absorb($fe) cluster(document_id)
		
		gen sample = e(sample)
		bys document_id (year): gen count = _n if sample == 1
		count if sample == 1 & count == 1
		loc r2 = string(`e(r2)', "%04.3fc") 

		outreg2 using "${output}/results", tex replace keep(connected_ty) nocons nor2 bdec(5) sdec(5) ///
			addtext("Teachers", `r(N)', "Year FE", Yes, "Teacher FE",  Yes, "R-squared", "`r2'") 
		drop sample count
		
	* Connected to a council member 
		drop connected_ty 
		rename connected_council connected_ty
		reghdfe std_score connected_ty $controls if always_connected_council == 0, absorb($fe) cluster(document_id)
		
		gen sample = e(sample)
		bys document_id (year): gen count = _n if sample == 1
		count if sample == 1 & count == 1
		loc r2 = string(`e(r2)', "%04.3fc") 
		
		outreg2 using "${output}/results", tex keep(connected_ty)  nocons nor2 bdec(5) sdec(5)  ///
			addtext("Teachers", `r(N)', "Year FE", Yes, "Teacher FE",  Yes, "R-squared", "`r2'") 
		drop sample count
		
		
	* Connected to  admin staff in the school (including principal)
		drop connected_ty 
		rename connected_directivo connected_ty
		reghdfe std_score connected_ty $controls if always_connected_directivo == 0, absorb($fe) cluster(document_id)
		
		gen sample = e(sample)
		bys document_id (year): gen count = _n if sample == 1
		count if sample == 1 & count == 1
		loc r2 = string(`e(r2)', "%04.3fc") 
		
		outreg2 using "${output}/results", tex keep(connected_ty)  nocons nor2 bdec(5) sdec(5) ///
			addtext("Teachers", `r(N)', "Year FE", Yes, "Teacher FE",  Yes, "R-squared", "`r2'") 
		drop sample count
		
	* Connected to any other teacher in the school
		drop connected_ty 
		rename connected_teacher connected_ty
		reghdfe std_score connected_ty $controls if always_connected_teacher == 0, absorb($fe) cluster(document_id)
		
		gen sample = e(sample)
		bys document_id (year): gen count = _n if sample == 1
		count if sample == 1 & count == 1
		loc r2 = string(`e(r2)', "%04.3fc") 
		
		outreg2 using "${output}/results", tex keep(connected_ty)  nocons nor2 bdec(5) sdec(5)  ///
			addtext("Teachers", `r(N)', "Year FE", Yes, "Teacher FE",  Yes, "R-squared", "`r2'") 
		drop sample count
				
		
*-------------------*
* Robustness checks *
*-------------------*

* CONTINUOUS VAR

	* Connected to a council member 
		rename connected_council3 connected_ty3
		reghdfe std_score connected_ty3 $controls if always_connected_council == 0, absorb($fe) cluster(document_id)
		
		gen sample = e(sample)
		bys document_id (year): gen count = _n if sample == 1
		count if sample == 1 & count == 1
		loc r2 = string(`e(r2)', "%04.3fc") 
		
		outreg2 using "${output}/results_robustness", tex replace keep(connected_ty3) nocons nor2 bdec(5) sdec(5) ///
			addtext("Teachers", `r(N)', "Year FE", Yes, "Teacher FE",  Yes, "R-squared", "`r2'") 
		drop sample count
		
	* Connected to  admin staff in the school (including principal)
		drop connected_ty3 
		rename connected_directivo3 connected_ty3 
		reghdfe std_score connected_ty3 $controls if always_connected_directivo == 0, absorb($fe) cluster(document_id)
		
		gen sample = e(sample)
		bys document_id (year): gen count = _n if sample == 1
		count if sample == 1 & count == 1
		loc r2 = string(`e(r2)', "%04.3fc") 
		
		outreg2 using "${output}/results_robustness", tex keep(connected_ty3) nocons nor2 bdec(5) sdec(5) ///
			addtext("Teachers", `r(N)', "Year FE", Yes, "Teacher FE",  Yes, "R-squared", "`r2'") 
		drop sample count	
		
	* Connected to any other teacher in the school
		drop connected_ty3 
		rename connected_teacher3 connected_ty3
		reghdfe std_score connected_ty3 $controls if always_connected_teacher == 0, absorb($fe) cluster(document_id)
		
		gen sample = e(sample)
		bys document_id (year): gen count = _n if sample == 1
		count if sample == 1 & count == 1
		loc r2 = string(`e(r2)', "%04.3fc") 
		
		outreg2 using "${output}/results_robustness", tex keep(connected_ty3) nocons nor2 bdec(5) sdec(5) ///
			addtext("Teachers", `r(N)', "Year FE", Yes, "Teacher FE",  Yes, "R-squared", "`r2'") 
		drop sample count
		
	
		
* DROPPING COMMON LAST NAMES

	* Connected to a council member 
		rename connected_council2 connected_ty2
		reghdfe std_score connected_ty2 $controls if always_connected_council == 0, absorb($fe) cluster(document_id)
		
		gen sample = e(sample)
		bys document_id (year): gen count = _n if sample == 1
		count if sample == 1 & count == 1
		loc r2 = string(`e(r2)', "%04.3fc") 
		
		outreg2 using "${output}/results_robustness2", tex replace keep(connected_ty2) nocons nor2 bdec(5) sdec(5) ///
			addtext("Teachers", `r(N)', "Year FE", Yes, "Teacher FE",  Yes, "R-squared", "`r2'") 
		drop sample count		
				
	* Connected to  admin staff in the school (including principal)
		drop connected_ty2
		rename connected_directivo2 connected_ty2
		reghdfe std_score connected_ty2 $controls if always_connected_directivo == 0, absorb($fe) cluster(document_id)

		gen sample = e(sample)
		bys document_id (year): gen count = _n if sample == 1
		count if sample == 1 & count == 1
		loc r2 = string(`e(r2)', "%04.3fc") 
		
		outreg2 using "${output}/results_robustness2", tex keep(connected_ty2) nocons nor2 bdec(5) sdec(5) ///
			addtext("Teachers", `r(N)', "Year FE", Yes, "Teacher FE",  Yes, "R-squared", "`r2'") 
		drop sample count	
		
	* Connected to any other teacher in the school
		drop connected_ty2
		rename connected_teacher2 connected_ty2
		reghdfe std_score connected_ty2 $controls if always_connected_teacher == 0, absorb($fe) cluster(document_id)
		
		gen sample = e(sample)
		bys document_id (year): gen count = _n if sample == 1
		count if sample == 1 & count == 1
		loc r2 = string(`e(r2)', "%04.3fc") 
		
		outreg2 using "${output}/results_robustness2", tex keep(connected_ty2) nocons nor2 bdec(5) sdec(5) ///
			addtext("Teachers", `r(N)', "Year FE", Yes, "Teacher FE",  Yes, "R-squared", "`r2'") 
		drop sample count		
		

* USING ONLY THE SAMPLE THAT DOES NOT CHANGE OVER TIME
	restore
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
		/*	  
				  tot_y |      Freq.     Percent        Cum.
		------------+-----------------------------------
				  1 |          3        0.00        0.00
				  2 |     15,898       14.44       14.44
				  3 |     18,356       16.67       31.11
				  4 |     11,580       10.52       41.63
				  5 |     17,007       15.45       57.07
				  6 |     47,265       42.93      100.00 // 43% of individual are there for the six years
		------------+-----------------------------------
			  Total |    110,109      100.00
		*/
		
		
		
	* Connected to public sector (JF)
		reghdfe std_score connected_ty $controls if always_connected_ty == 0, absorb($fe) cluster(document_id)
		
		gen sample = e(sample)
		bys document_id (year): gen count = _n if sample == 1
		count if sample == 1 & count == 1
		loc r2 = string(`e(r2)', "%04.3fc") 

		outreg2 using "${output}/results_robust_sample", tex replace keep(connected_ty) nocons nor2 bdec(5) sdec(5) ///
			addtext("Teachers", `r(N)', "Year FE", Yes, "Teacher FE",  Yes, "R-squared", "`r2'") 
		drop sample count
		
	* Connected to a council member 
		drop connected_ty 
		rename connected_council connected_ty
		reghdfe std_score connected_ty $controls if always_connected_council == 0, absorb($fe) cluster(document_id)
		
		gen sample = e(sample)
		bys document_id (year): gen count = _n if sample == 1
		count if sample == 1 & count == 1
		loc r2 = string(`e(r2)', "%04.3fc") 
		
		outreg2 using "${output}/results_robust_sample", tex keep(connected_ty)  nocons nor2 bdec(5) sdec(5)  ///
			addtext("Teachers", `r(N)', "Year FE", Yes, "Teacher FE",  Yes, "R-squared", "`r2'") 
		drop sample count
		
		
	* Connected to  admin staff in the school (including principal)
		drop connected_ty 
		rename connected_directivo connected_ty
		reghdfe std_score connected_ty $controls if always_connected_directivo == 0, absorb($fe) cluster(document_id)
		
		gen sample = e(sample)
		bys document_id (year): gen count = _n if sample == 1
		count if sample == 1 & count == 1
		loc r2 = string(`e(r2)', "%04.3fc") 
		
		outreg2 using "${output}/results_robust_sample", tex keep(connected_ty)  nocons nor2 bdec(5) sdec(5) ///
			addtext("Teachers", `r(N)', "Year FE", Yes, "Teacher FE",  Yes, "R-squared", "`r2'") 
		drop sample count
		
	* Connected to any other teacher in the school
		drop connected_ty 
		rename connected_teacher connected_ty
		reghdfe std_score connected_ty $controls if always_connected_teacher == 0, absorb($fe) cluster(document_id)
		
		gen sample = e(sample)
		bys document_id (year): gen count = _n if sample == 1
		count if sample == 1 & count == 1
		loc r2 = string(`e(r2)', "%04.3fc") 
		
		outreg2 using "${output}/results_robust_sample", tex keep(connected_ty)  nocons nor2 bdec(5) sdec(5)  ///
			addtext("Teachers", `r(N)', "Year FE", Yes, "Teacher FE",  Yes, "R-squared", "`r2'") 
		drop sample count	
		