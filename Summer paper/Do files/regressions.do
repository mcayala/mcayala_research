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
* Variation within school-subject *
*---------------------------------*

*log using "${log}/results_saber11_schoolvariation_$date.log", replace

use "Data/school_subject_with_testscores_dataset.dta", clear


sum share*

* Declare globals 
	global controls1 "temporary female posgraduate"
	global fe "year school_code"
	global esttab_opt "b(3) se(3) r2(3) scalars(N) sfmt(0)"
	global pvalues "gaps star(* 0.10 ** 0.05 *** 0.01)"

* Labels
	lab var share_connected_ty "Connected (JF)"
	lab var share_connected_tby "Top Connected (JF)"
	lab var share_connected_council "Connected to Council Member"
	lab var share_connected_council2 "Connected to Council Member"
	lab var share_connected_principal "Connected to Principal"
	lab var share_connected_principal2 "Connected to Principal"
	lab var share_connected_directivo "Connected to Admin Staff in the School"
	lab var share_connected_directivo2 "Connected to Admin Staff in the School"
	lab var share_connected_teachers "Connected to Any Teacher in the School"
	lab var share_connected_teachers2 "Connected to Any Teacher in the School"
	
* School fixed effects
estimates clear

	* Connected to public sector (JF)
	reghdfe std_score share_connected_ty $controls1, absorb($fe)
	est store mod1
		
	* Connected to top bureaucrat (JF)	
	reghdfe std_score share_connected_tby $controls1, absorb($fe)
	est store mod2
	
	* Connected to a council member 
	reghdfe std_score share_connected_council $controls1, absorb($fe)
	est store mod3
	
	* Connected to the principal of the school
	reghdfe std_score share_connected_principal $controls1, absorb($fe)	
	est store mod4
	
	* Connected to admin staff in the school (including principal)
	reghdfe std_score share_connected_directivo $controls1, absorb($fe)
	est store mod5
	
	* Connected to any other teacher in the school
	reghdfe std_score share_connected_teachers $controls1, absorb($fe)	
	est store mod6	
	
	mergemodels mod1 mod2 mod3 mod4 mod5 mod6 
	est sto allmodels
	esttab allmodels, keep(share_connected_*) $esttab_opt noconst label  $pvalues 	

	* Connected to a council member - without common last names
	rename share_connected_council share_connected_council3
	rename share_connected_council2 share_connected_council 
	reghdfe std_score share_connected_council $controls1, absorb($fe)
	est store mod7
	
	* Connected to the principal of the school
	rename share_connected_principal share_connected_principal3
	rename share_connected_principal2 share_connected_principal
	reghdfe std_score share_connected_principal $controls1, absorb($fe)
	est store mod8
	
	* Connected to admin staff in the school (including principal)
	rename share_connected_directivo share_connected_directivo3
	rename share_connected_directivo2 share_connected_directivo
	reghdfe std_score share_connected_directivo $controls1, absorb($fe)
	est store mod9
	
	* Connected to any other teacher in the school
	rename share_connected_teachers share_connected_teachers3
	rename share_connected_teachers2 share_connected_teachers
	reghdfe std_score share_connected_teachers $controls1, absorb($fe)
	est store mod10
	
	mergemodels  mod7 mod8 mod9  mod10
	est sto allmodels2
	esttab allmodels allmodels2, keep(share_connected_*) $esttab_opt noconst label  $pvalues 	
	
*log c

*copy "${log}/results_saber11_schoolvariation_$date.log" ///
*	"Log files/results_saber11_schoolvariation_$date.log", replace

*---------------------------------*
* Variation in family connections *
*---------------------------------*

*log using "${log}/results_saber11_familyconn_variation_$date.log", replace

use "Data/merge_JF_teachers_secundaria.dta", clear
 
global controls  "age type_contract"
 
sum connected_*

* Labels
	lab var connected_ty "Connected (JF)"
	lab var connected_tby "Top Connected (JF)"
	lab var connected_council "Connected to Council Member"
	lab var connected_council2 "Connected to Council Member"
	lab var connected_principal "Connected to Principal"
	lab var connected_principal2 "Connected to Principal"
	lab var connected_directivo "Connected to Admin Staff in the School"
	lab var connected_directivo2 "Connected to Admin Staff in the School"
	lab var connected_teacher "Connected to Any Teacher in the School"
	lab var connected_teacher2 "Connected to Any Teacher in the School"
 
 * School fixed effects
estimates clear

	* Connected to public sector (JF)
	reghdfe std_score connected_ty $controls, absorb(year document_id)
	est store mod1
	
	* Connected to top bureaucrat (JF)	
	reghdfe std_score connected_tby $controls, absorb(year document_id)
	est store mod2
	
	* Connected to a council member 
	reghdfe std_score connected_council $controls, absorb(year document_id)
	est store mod3

	* Connected to the principal of the school
	reghdfe std_score connected_principal $controls, absorb(year document_id)
	est store mod4
	
	* Connected to admin staff in the school (including principal)
	reghdfe std_score connected_directivo $controls, absorb(year document_id)
	est store mod5
	
	* Connected to any other teacher in the school
	reghdfe std_score connected_teacher $controls, absorb(year document_id)
	est store mod6
	
	* Connected to a council member - without common last names
	rename connected_council connected_council3
	rename connected_council2 connected_council 
	reghdfe std_score connected_council $controls, absorb(year document_id)
	est store mod7

	* Connected to the principal of the school
	rename connected_principal connected_principal3
	rename connected_principal2 connected_principal
	reghdfe std_score connected_principal $controls, absorb(year document_id)
	est store mod8

	* Connected to admin staff in the school (including principal)
	rename connected_directivo connected_directivo3
	rename connected_directivo2 connected_directivo
	reghdfe std_score connected_directivo $controls, absorb(year document_id)
	est store mod9

	* Connected to any other teacher in the school
	rename connected_teacher connected_teacher3
	rename connected_teacher2 connected_teacher
	reghdfe std_score connected_teacher $controls, absorb(year document_id)
	est store mod10
	
	mergemodels mod1 mod2 mod3 mod4 mod5 mod6 
	est sto allmodels
	mergemodels  mod7 mod8 mod9  mod10
	est sto allmodels2
	esttab allmodels allmodels2, keep(connected_*) $esttab_opt noconst label  $pvalues 
	-
	
*log c


*copy "${log}/results_saber11_familyconn_variation_$date.log" ///
*	"Log files/results_saber11_familyconn_variation_$date.log", replace
