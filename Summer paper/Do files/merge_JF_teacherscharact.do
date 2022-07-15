* Project: Summer Paper
* Written by: Camila Ayala (mc.ayala94@gmail.com)
* Purpose: This do file merges JF variable with other teachers' variables and test scores


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
	tab teaching_level icfes_subject, m row
	keep if teaching_level == 3 // secundaria
	keep if !mi(icfes_subject) // only the subjects that are relevant for Saber 11
	
*----------------*
* Merge Saber 11 *
*----------------*	

	rename school_code school_code2
	destring school_code2, gen(double school_code) 
	format school_code %16.0g
	preserve

* Merge Saber 11 test scores
	merge m:1 school_code year icfes_subject using "Data/SB11_2011_2017_school_level.dta"
	/*
	    Result                      Number of obs
    -----------------------------------------
    Not matched                       289,568
        from master                   104,016  (_merge==1)
        from using                    185,552  (_merge==2)

    Matched                           525,099  (_merge==3)
    -----------------------------------------
	*/
	keep if _merge == 3
	
* Save dataset
	save "Data/merge_JF_teachers_secundaria.dta", replace
	restore
	
*--------------------------------------------*
* Create dataset at the school-subject level *
*--------------------------------------------*	

	* Create contorls
		gen temporary = (type_contract == 1)
		gen posgraduate = (educ_level == 4)
		
	* Collapse
		br school_code year icfes_subject connected_ty connected_tby
		gen N_teachers = 1
		collapse (sum) connected_ty connected_tby N_teachers (mean) temporary female posgraduate, by(school_code year icfes_subject)
	
	* Gen shares
		gen share_connected_ty = connected_ty/N_teachers
		gen share_connected_tby = connected_tby/N_teachers

	* Merge Saber 11 test scores
		merge 1:1 school_code year icfes_subject using "Data/SB11_2011_2017_school_level.dta"	
		/*
			 Result                      Number of obs
			-----------------------------------------
			Not matched                       228,241
				from master                    42,689  (_merge==1)
				from using                    185,552  (_merge==2)

			Matched                           160,576  (_merge==3)
			-----------------------------------------
		*/
		keep if _merge == 3
	
	* Save dataset
		save "Data/school_subject_with_testscores_dataset.dta", replace
	
		
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
 