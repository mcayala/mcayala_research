cd "/Volumes/Camila/Dropbox/PhD/Second year/Summer paper"
set scheme plotplainblind


use "Data/merge_JF_teachers.dta", clear

	duplicates tag document_id year codigo_dane, gen(dup2)
	drop if dup2 == 1

isid document_id year codigo_dane


merge 1:1 document_id year codigo_dane using "Docentes 2008-2017/base_docentes_2022-05-18.dta", assert(3) nogen


* Generate area
	gen subject = .
	lab def subject_l 1 "Math" 2 "Language" 3 "Natural sciences" 4 "Social sciences" 5 "English"
	replace subject = 1 if inlist(area_ensenanza_nombrado, "15")
	replace subject = 2 if inlist(area_ensenanza_nombrado, "12")
	replace subject = 3 if inlist(area_ensenanza_nombrado, "3", "17", "18")
	replace subject = 4 if inlist(area_ensenanza_nombrado, "4")
	replace subject = 5 if inlist(area_ensenanza_nombrado, "14")
	lab values subject subject_l
	ta subject connected_ty, row
	ta subject connected_tby, row

* Collapse by subject
	drop if mi(subject)
	keep if nivel_ensenanza == "3" // secundaria
	gen n = 1
	
		save "Data/merge_JF_teachers_secundaria.dta", replace

	collapse (sum) n (mean) connected_ty connected_tby, by(codigo_dane year subject)

	
hist connected_ty, by(year) name(conected_hist, replace)	 percent
-
hist connected_ty if connected_ty>0, by(year) name(conected_hist2, replace)	percent
	
* Concurso docente * 
	
use "/Volumes/Camila/Dropbox/Maestría/Tesis/Servidor/Saber 11/Datasets/concurso_docentes.dta", clear
	
rename num_doc document_id
isid document_id
keep document_id prom aprobo

merge 1:m document_id using "Data/merge_JF_teachers_secundaria.dta"
drop if _merge == 1
tab year _merge
tab connected_ty _merge, r

	
binscatter
 