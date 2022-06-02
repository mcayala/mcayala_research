* Project: Summer Paper
* Written by: Camila Ayala (mc.ayala94@gmail.com)
* Purpose: This do file merges JF variable with other teachers' variables


cd "/Volumes/Camila/Dropbox/PhD/Second year/Summer paper"
set scheme plotplainblind

* Open JF dataset with his variable

	use "Data/merge_JF_teachers.dta", clear

* Drop duplicates: when I sent him the dataset, it had still duplicates
	rename codigo_dane school_code
	duplicates tag document_id year school_code, gen(dup2)
	drop if dup2 == 1
	drop dup2
	isid document_id year school_code

* Merge teacher's characteristics
	merge 1:1 document_id year school_code using "Data/base_docentes_clean_2011_2017.dta", assert(3) nogen update
	lab var year "Year"
	lab var document_id "Teacher ID"
	lab var school_code "School code (codigo DANE)"

* Keep only secondary teachers
	tab teaching_level
	keep if teaching_level == 3 // secundaria

* Save dataset
	save "Data/merge_JF_teachers_secundaria.dta", replace

/*	
	
	collapse (sum) n (mean) connected_ty connected_tby, by(codigo_dane year subject)

	
hist connected_ty, by(year) name(conected_hist, replace)	 percent

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
 