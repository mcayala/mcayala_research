cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"
*set scheme plotplainblind

global date "2022-08-01"

*log using "Log files/results_saber11_$date.smcl", replace
log using "Log files/results_saber11_$date.log", replace

*---------------------------------*
* Variation within school-subject *
*---------------------------------*

use "Data/school_subject_with_testscores_dataset.dta", clear

global controls1 "temporary female posgraduate"

sum share*

* School fixed effects
	reghdfe score share_connected_ty $controls1, absorb(year school_code)
	reghdfe score share_connected_tby $controls1, absorb(year school_code)
	reghdfe score share_connected_council $controls1, absorb(year school_code)
	
* School - subject fixed effects
	gen schoolxsubject = school_code*icfes_subject
	reghdfe score share_connected_ty $controls1, absorb(schoolxsubject)
	reghdfe score share_connected_tby $controls1, absorb(schoolxsubject)
	reghdfe score share_connected_council $controls1, absorb(schoolxsubject)


*---------------------------------*
* Variation in family connections *
*---------------------------------*

use "Data/merge_JF_teachers_secundaria.dta", clear
 
global controls  "age type_contract"
 
sum connected_*
 
reghdfe score connected_ty $controls, absorb(year document_id)
reghdfe score connected_tby $controls, absorb(year document_id)
reghdfe score connected_council $controls, absorb(year document_id)


log c

