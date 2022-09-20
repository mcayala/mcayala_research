 cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"
global log "/Users/camila/Documents/GitHub/mcayala_research/Summer paper/Log files"
global output "/Users/camila/Dropbox/PhD/Second year/Summer paper/Output"
*set scheme plotplainblind

global date "2022-08-04"

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

*---------------------------------*
* Variation in family connections *
*---------------------------------*

*log using "${log}/results_saber11_familyconn_variation_$date.log", replace

use "Data/merge_JF_teachers_secundaria.dta", clear
 
sum connected_*

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
 
/* First keep teachers that are all the time
	sort document_id year	
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
	
	keep if tot_y == 6 */
 
 
* Globals for regressions
	global controls  "age postgrad_degree temporary urban years_exp new_estatuto"
	global fe "year document_id muni_code"

 	* Connected to public sector (JF)
		reghdfe std_score connected_ty $controls, absorb($fe)
		outreg2 using "${output}/results", tex replace keep(connected_ty) addtext("Year FE", Yes, "Teacher FE",  Yes) nocons

	* Connected to a council member 
		drop connected_ty 
		rename connected_council connected_ty
		reghdfe std_score connected_ty $controls, absorb($fe)
		outreg2 using "${output}/results", tex keep(connected_ty) addtext("Year FE", Yes, "Teacher FE",  Yes) nocons
		
	* Connected to  admin staff in the school (including principal)
		drop connected_ty 
		rename connected_directivo connected_ty
		reghdfe std_score connected_ty $controls, absorb($fe)
		outreg2 using "${output}/results", tex keep(connected_ty) 	addtext("Year FE", Yes, "Teacher FE",  Yes)	 nocons
		
	* Connected to any other teacher in the school
		drop connected_ty 
		rename connected_teacher connected_ty
		reghdfe std_score connected_ty $controls, absorb($fe)
		outreg2 using "${output}/results", tex keep(connected_ty)	addtext("Year FE", Yes, "Teacher FE",  Yes)	 nocons
				
		
* Robustness checks

	* CONTINUOUS VAR

	* Connected to a council member 
		rename connected_council3 connected_ty3
		reghdfe std_score connected_ty3 $controls, absorb($fe)
		outreg2 using "${output}/results_robustness", tex replace keep(connected_ty3) addtext("Year FE", Yes, "Teacher FE",  Yes) nocons
		
	* Connected to  admin staff in the school (including principal)
		drop connected_ty3 
		rename connected_directivo3 connected_ty3
		reghdfe std_score connected_ty3 $controls, absorb($fe)
		outreg2 using "${output}/results_robustness", tex keep(connected_ty3) 	addtext("Year FE", Yes, "Teacher FE",  Yes)	 nocons
		
	* Connected to any other teacher in the school
		drop connected_ty3 
		rename connected_teacher3 connected_ty3
		reghdfe std_score connected_ty3 $controls, absorb($fe)
		outreg2 using "${output}/results_robustness", tex keep(connected_ty3)	addtext("Year FE", Yes, "Teacher FE",  Yes)	 nocons
		
		
	* DROPPING COMMON LAST NAMES

	* Connected to a council member 
		rename connected_council2 connected_ty2
		reghdfe std_score connected_ty2 $controls, absorb($fe)
		outreg2 using "${output}/results_robustness2", tex replace keep(connected_ty2) addtext("Year FE", Yes, "Teacher FE",  Yes) nocons
		
	* Connected to  admin staff in the school (including principal)
		drop connected_ty2
		rename connected_directivo2 connected_ty2
		reghdfe std_score connected_ty2 $controls, absorb($fe)
		outreg2 using "${output}/results_robustness2", tex keep(connected_ty2) 	addtext("Year FE", Yes, "Teacher FE",  Yes)	 nocons
		
	* Connected to any other teacher in the school
		drop connected_ty
		rename connected_teacher2 connected_ty2
		reghdfe std_score connected_ty2 $controls, absorb($fe)
		outreg2 using "${output}/results_robustness2", tex keep(connected_ty2)	addtext("Year FE", Yes, "Teacher FE",  Yes)	 nocons
		
		
	-		*/			
		
		
estimates clear

	global fe "year document_id"

	* Connected to public sector (JF)
	reghdfe std_score connected_ty $controls, absorb($fe)
	est store mod1
	
	* Connected to a council member 
	reghdfe std_score connected_council $controls, absorb($fe)
	est store mod3
	
	* Connected to admin staff in the school (including principal)
	reghdfe std_score connected_directivo $controls, absorb($fe)
	est store mod5
	
	* Connected to any other teacher in the school
	reghdfe std_score connected_teacher $controls, absorb($fe)
	est store mod6
	
* Continuous var
	
	* Connected to a council member - without common last names
	drop connected_council 
	rename connected_council3 connected_council 
	reghdfe std_score connected_council $controls, absorb($fe)
	est store mod11
	
	
	* Connected to admin staff in the school (including principal)
	drop connected_directivo 
	rename connected_directivo3 connected_directivo
	reghdfe std_score connected_directivo $controls, absorb($fe)
	est store mod13
	
	* Connected to any other teacher in the school
	drop connected_teacher
	rename connected_teacher3 connected_teacher
	reghdfe std_score connected_teacher $controls, absorb($fe)
	est store mod14	
	
	mergemodels mod1  mod3  mod5 mod6 
	est sto allmodels
	mergemodels  mod11 mod13 mod14
	est sto allmodels3
	esttab allmodels allmodels3, keep(connected_*) $esttab_opt noconst label  $pvalues  mtitles("Basic" "Continuous measure")
	
* School variation


 use "Data/school_subject_with_testscores_dataset.dta", clear

* Declare globals 
	global controls1 "temporary female posgraduate"
	global fe "year school_code"
 
 	* Connected to public sector (JF)
		reghdfe std_score connected_ty $controls, absorb($fe)
		outreg2 using "${output}/results_school", tex replace keep(connected_ty) addtext("Year FE", Yes, "School FE",  Yes) nocons

	* Connected to a council member 
		drop connected_ty 
		rename connected_council connected_ty
		reghdfe std_score connected_ty $controls, absorb($fe)
		outreg2 using "${output}/results_school", tex keep(connected_ty) addtext("Year FE", Yes, "School FE",  Yes) nocons
		
	* Connected to  admin staff in the school (including principal)
		drop connected_ty 
		rename connected_directivo connected_ty
		reghdfe std_score connected_ty $controls, absorb($fe)
		outreg2 using "${output}/results_school", tex keep(connected_ty) 	addtext("Year FE", Yes, "School FE",  Yes)	 nocons
		
	* Connected to any other teacher in the school
		drop connected_ty 
		rename connected_teacher connected_ty
		reghdfe std_score connected_ty $controls, absorb($fe)
		outreg2 using "${output}/results_school", tex keep(connected_ty)	addtext("Year FE", Yes, "School FE",  Yes)	 nocons
				
	
*log c


*copy "${log}/results_saber11_familyconn_variation_$date.log" ///
*	"Log files/results_saber11_familyconn_variation_$date.log", replace
