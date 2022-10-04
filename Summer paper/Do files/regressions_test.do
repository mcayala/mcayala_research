 
capt prog drop mergemodels
prog mergemodels, eclass
// assuming that last element in e(b)/e(V) is _cons
 version 8
 syntax namelist
 tempname b V tmp
 foreach name of local namelist {
   qui est restore `name'
   mat `b' = nullmat(`b') , e(b)
   mat `b' = `b'[1,1..colsof(`b')-1]
   mat `tmp' = e(V)
   mat `tmp' = `tmp'[1..rowsof(`tmp')-1,1..colsof(`tmp')-1]
   capt confirm matrix `V'
   if _rc {
     mat `V' = `tmp'
   }
   else {
     mat `V' = ///
      ( `V' , J(rowsof(`V'),colsof(`tmp'),0) ) \ ///
      ( J(rowsof(`tmp'),colsof(`V'),0) , `tmp' )
   }
 }
 local names: colfullnames `b'
 mat coln `V' = `names'
 mat rown `V' = `names'
 eret post `b' `V'
 eret local cmd "whatever"
end

 
 
cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"
global log "/Users/camila/Documents/GitHub/mcayala_research/Summer paper/Log files"
global output "/Users/camila/Dropbox/PhD/Second year/Summer paper/Output"



use "Data/merge_JF_teachers_secundaria.dta", clear
 *merge m:1 school_code using "Data/SB11_global.dta", gen(merge2)
 
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
 
* Define staggered treatment
	foreach var of varlist connected_ty connected_council  connected_directivo connected_teacher { //connected_council  connected_directivo connected_teacher {
		gen year_`var' = year if `var' == 1
		bys document_id: egen event_`var' = min(year_`var')
		gen ever_`var' = 0
		replace ever_`var' = 1 if year >= event_`var'
	  }	
	  
* Define always connected, ever connected and switchers con esta variable
	foreach var of varlist ever_connected_ty ever_connected_council  ever_connected_directivo ever_connected_teacher  {  // 
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

	global var connected_teacher
	
 	* Regresion normal
		reghdfe std_score $var $controls, absorb($fe) cluster(document_id)
		est store mod1
		
		* Dropping always treated 
		reghdfe std_score $var $controls if always_$var == 0, absorb($fe) cluster(document_id)
		est store mod2	
		
	* Con staggered treatment
		reghdfe std_score ever_$var $controls, absorb($fe) cluster(document_id)
		est store mod3
	
		* Dropping always treated 
		reghdfe std_score ever_$var $controls if always_ever_$var == 0, absorb($fe) cluster(document_id)
		est store mod4
	
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
	
 	* Regresion normal
		reghdfe std_score $var $controls if tot_y == 6, absorb($fe) cluster(document_id)
		est store mod5
		
		* Dropping always treated 
		reghdfe std_score $var $controls if always_$var == 0 & tot_y == 6, absorb($fe) cluster(document_id)
		est store mod6
		
	* Con staggered treatment
		reghdfe std_score ever_$var $controls if tot_y == 6, absorb($fe) cluster(document_id)
		est store mod7
	
		* Dropping always treated 
		reghdfe std_score ever_$var $controls if always_ever_$var == 0 & tot_y == 6, absorb($fe) cluster(document_id)
		est store mod8
		
* Teachers that do not change school
	sort document_id year 
	br document_id year school_code
	bys document_id: egen double max = max(school_code)
	bys document_id: egen double min = min(school_code)
	format max min %16.0g
	gen change_school = (max != min)
	drop max min	
		
 	* Regresion normal
		reghdfe std_score $var $controls if change_school == 0  , absorb($fe) cluster(document_id)
		est store mod9
		
		* Dropping always treated 
		reghdfe std_score $var $controls if always_$var == 0 & change_school == 0 , absorb($fe) cluster(document_id)
		est store mod10
		
	* Con staggered treatment
		reghdfe std_score ever_$var $controls if change_school == 0 , absorb($fe) cluster(document_id)
		est store mod11
	
		* Dropping always treated 
		reghdfe std_score ever_$var $controls if always_ever_$var == 0 & change_school == 0  , absorb($fe) cluster(document_id)
		est store mod12	
		
	
	mergemodels mod1 mod3
	est sto normal	
	mergemodels mod2 mod4
	est sto normal_always
	mergemodels mod5 mod7
	est sto panel
	mergemodels mod6 mod8
	est sto panel_always
	mergemodels mod9 mod11
	est sto school
	mergemodels mod10 mod12
	est sto school_always
	
	esttab normal normal_always panel panel_always school school_always, keep(connected_* ever_connected_*) $esttab_opt noconst label  $pvalues mtitles("Basic" "Basic - always connected" "Panel" "Panel - always connected" "Same school" "Same school - always connected")	
	
	did_multiplegt std_score document_id year connected_ty, robust_dynamic placebo(1) breps(50) cluster(document_id) controls($controls)	
	did_multiplegt std_score document_id year ever_connected_ty, robust_dynamic placebo(1) breps(50) cluster(document_id) controls($controls)	
	
	
	did_multiplegt std_score document_id year connected_ty if always_connected_ty == 0, robust_dynamic placebo(1) breps(50) cluster(document_id) controls($controls)	
	
