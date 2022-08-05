* Project: Summer Paper
* Written by: Camila Ayala (mc.ayala94@gmail.com)
* Purpose: This do file merges JF variable with other teachers' variables and test scores


cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"
*set scheme plotplainblind

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
	
*-----------------*
* Merge Muni code *
*-----------------*	

	rename school_code school_code2
	destring school_code2, gen(double school_code) 
	format school_code %16.0g
	
* Merge muni_code
	merge m:1 school_code year icfes_subject using "Data/SB11_2011_2017_school_level.dta", keepus(muni_code) 
	keep if _merge == 3
	drop _merge
	/*
		Result                      Number of obs
		-----------------------------------------
		Not matched                       168,000
			from master                   104,263  (_merge==1)
			from using                     63,737  (_merge==2)

		Matched                           524,852  (_merge==3)
		-----------------------------------------
	*/
	
*--------------------------*
* Merge council last names *
*--------------------------*		
	
* Merge council names with apellido1
	rename apellido1 apellido
	merge m:1 year muni_code apellido using "Data/council_data_2012to2019"
	/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                       575,501
        from master                   444,828  (_merge==1)
        from using                    130,673  (_merge==2)

    Matched                            80,024  (_merge==3)
    -----------------------------------------
	*/
	
* Create connected variable
	drop if _merge == 2
	gen 	connected_council = .
	replace connected_council = 1 if _merge == 3

	gen 	connected_council2 = .
	replace connected_council2 = 1 if _merge == 3 & popular == 0
	drop _merge popular
	rename apellido apellido1

* Merge council names with apellido2
	rename apellido2 apellido
	merge m:1 year muni_code apellido using "Data/council_data_2012to2019"
	drop if _merge == 2
	
	replace connected_council = 1 if _merge == 3 & mi(connected_council)
	replace connected_council = 0 if mi(connected_council)
	
	replace connected_council2 = 1 if _merge == 3 & popular == 0
	replace connected_council2 = 0 if mi(connected_council2)	
	drop _merge popular
	rename apellido apellido2
	
*-------------------------------------*
* Merge principal/teachers last names *
*-------------------------------------*	
	
* Merge names with apellido1
	rename apellido1 apellido
	merge m:1 year school_code apellido using "Data/principal&teachers_lastnames", assert(2 3) keepus(directivo principal n_apellido popular)
	drop if _merge == 2

* Gen connection var
	br year school_code apellido directivo principal n_apellido
	gen 	connected_teacher = .
	replace connected_teacher = 1 if _merge == 3 & n_apellido > 1
	
	gen 	connected_principal = .
	replace connected_principal = 1 if _merge == 3 & n_apellido > 1 & principal == 1
	
	gen 	connected_directivo = .
	replace connected_directivo = 1 if _merge == 3 & n_apellido > 1 & directivo == 1
	
* Taking out popular last names
	gen 	connected_teacher2 = connected_teacher
	replace connected_teacher2 = 0 if popular == 1
	
	gen 	connected_principal2 = connected_principal
	replace connected_principal2 = 0 if popular == 1
	
	gen 	connected_directivo2 = connected_directivo
	replace connected_directivo2 = 0 if popular == 1
	
	rename apellido apellido1	
	drop _merge directivo principal n_apellido popular

* Merge names with apellido1
	rename apellido2 apellido
	merge m:1 year school_code apellido using "Data/principal&teachers_lastnames", keepus(directivo principal n_apellido popular)
	drop if _merge == 2

* Gen connection var
	replace connected_teacher = 1 if _merge == 3 & n_apellido > 1
	replace connected_teacher = 0 if mi(connected_teacher)
	
	replace connected_principal = 1 if _merge == 3 & n_apellido > 1 & principal == 1
	replace connected_principal = 0 if mi(connected_principal)
	
	replace connected_directivo = 1 if _merge == 3 & n_apellido > 1 & directivo == 1
	replace connected_directivo = 0 if mi(connected_directivo)
	
* Taking out popular last names
	replace connected_teacher2 = 0 if popular == 1
	replace connected_teacher2 = 0 if mi(connected_teacher2)
	
	replace connected_principal2 = 0 if popular == 1
	replace connected_principal2 = 0 if mi(connected_principal2)
	
	replace connected_directivo2 = 0 if popular == 1	
	replace connected_directivo2 = 0 if mi(connected_directivo2)
	
	
	rename apellido apellido2
	drop _merge directivo principal n_apellido
	
	sum connected_*

*----------------------*
* Merge Saber11 scores *
*----------------------*

	preserve
* Merge Saber 11 test scores
	merge m:1 school_code year icfes_subject using "Data/SB11_2011_2017_school_level.dta"
	/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                        63,737
        from master                         0  (_merge==1)
        from using                     63,737  (_merge==2)

    Matched                           524,852  (_merge==3)
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
		collapse (sum) connected_* N_teachers (mean) temporary female posgraduate, by(school_code year icfes_subject)
	
	* Gen shares
		gen share_connected_ty = connected_ty/N_teachers
		gen share_connected_tby = connected_tby/N_teachers
		gen share_connected_council = connected_council/N_teachers
		gen share_connected_council2 = connected_council2/N_teachers
		gen share_connected_principal = connected_principal/N_teachers
		gen share_connected_principal2 = connected_principal2/N_teachers
		gen share_connected_directivo = connected_directivo/N_teachers
		gen share_connected_directivo2 = connected_directivo2/N_teachers
		gen share_connected_teachers = connected_teacher/N_teachers
		gen share_connected_teachers2 = connected_teacher2/N_teachers

	* Merge Saber 11 test scores
		merge 1:1 school_code year icfes_subject using "Data/SB11_2011_2017_school_level.dta"
		/*
			Result                      Number of obs
			-----------------------------------------
			Not matched                        63,737
				from master                         0  (_merge==1)
				from using                     63,737  (_merge==2)

			Matched                           160,495  (_merge==3)
			-----------------------------------------

		*/
		keep if _merge == 3
	
	* Save dataset
		save "Data/school_subject_with_testscores_dataset.dta", replace
