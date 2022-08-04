cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"
global log "/Users/camila/Documents/GitHub/mcayala_research/Summer paper/Log files"
*set scheme plotplainblind

global date "2022-08-04"


*---------------------------------*
* Variation within school-subject *
*---------------------------------*

log using "${log}/results_saber11_schoolvariation_$date.log", replace

use "Data/school_subject_with_testscores_dataset.dta", clear

global controls1 "temporary female posgraduate"

sum share*

global fe "year school_code icfes_subject"

* School fixed effects

	* Connected to public sector (JF)
	reghdfe std_score share_connected_ty $controls1, absorb(year school_code)
	reghdfe std_score share_connected_ty $controls1, absorb($fe)
	
	* Connected to top bureaucrat (JF)	
	reghdfe std_score share_connected_tby $controls1, absorb(year school_code)
	reghdfe std_score share_connected_tby $controls1, absorb($fe)
	
	* Connected to a council member 
	reghdfe std_score share_connected_council $controls1, absorb(year school_code)
	reghdfe std_score share_connected_council $controls1, absorb($fe)
	
	* Connected to a council member - without common last names
	reghdfe std_score share_connected_council2 $controls1, absorb(year school_code)
	reghdfe std_score share_connected_council2 $controls1, absorb($fe)
	
	* Connected to the principal of the school
	reghdfe std_score share_connected_principal $controls1, absorb(year school_code)
	reghdfe std_score share_connected_principal $controls1, absorb($fe)
	
	* Connected to admin staff in the school (including principal)
	reghdfe std_score share_connected_directivo $controls1, absorb(year school_code)
	reghdfe std_score share_connected_directivo $controls1, absorb($fe)
	
	* Connected to any other teacher in the school
	reghdfe std_score share_connected_teacher $controls1, absorb(year school_code)
	reghdfe std_score share_connected_teacher $controls1, absorb($fe)
	

log c

copy "${log}/results_saber11_schoolvariation_$date.log" ///
	"Log files/results_saber11_schoolvariation_$date.log", replace

*---------------------------------*
* Variation in family connections *
*---------------------------------*

log using "${log}/results_saber11_familyconn_variation_$date.log", replace

use "Data/merge_JF_teachers_secundaria.dta", clear
 
global controls  "age type_contract"
 
sum connected_*
 
	* Connected to public sector (JF)
	reghdfe std_score connected_ty $controls, absorb(year document_id)
	
	* Connected to top bureaucrat (JF)	
	reghdfe std_score connected_tby $controls, absorb(year document_id)
	
	* Connected to a council member 
	reghdfe std_score connected_council $controls, absorb(year document_id)

	* Connected to a council member - without common last names
	reghdfe std_score connected_council2 $controls, absorb(year document_id)

	* Connected to the principal of the school
	reghdfe std_score connected_principal $controls, absorb(year document_id)

	* Connected to admin staff in the school (including principal)
	reghdfe std_score connected_directivo $controls, absorb(year document_id)

	* Connected to any other teacher in the school
	reghdfe std_score connected_teacher $controls, absorb(year document_id)
	
	
log c


copy "${log}/results_saber11_familyconn_variation_$date.log" ///
	"Log files/results_saber11_familyconn_variation_$date.log", replace
