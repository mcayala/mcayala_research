* Project: Summer Paper
* Written by: Camila Ayala (mc.ayala94@gmail.com)
* Purpose: This do file merges JF variable with other teachers' variables and test scores


cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"
*set scheme plotplainblind

* Open JF dataset with his variable
	use "Data/merge_JF_teachers.dta", clear

* Drop duplicates: when I sent him (JF) the dataset, it had still duplicates
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
	rename school_code school_code2
	destring school_code2, gen(double school_code) 
	format school_code %16.0g
	
* Count teachers, principals and directivos in each school-year
	br school_code year position nombre_cargo
	gen directivo = (position == 2)
	gen principal = (nombre_cargo == "6")
	gen teacher = 1
	bys school_code year: egen n_directivo = sum(directivo)
	bys school_code year: egen n_principal = sum(principal)
	bys school_code year: egen n_teacher = sum(teacher)
	drop directivo principal teacher
	
* Keep only secondary teachers
	tab teaching_level icfes_subject, m row
	keep if teaching_level == 3 // secundaria
	keep if !mi(icfes_subject) // only the subjects that are relevant for Saber 11
	
*-----------------*
* Merge Muni code *
*-----------------*	
	
* Merge muni_code
	merge m:1 school_code year icfes_subject using "Data/SB11_2011_2017_school_level.dta", keepus(muni_code) 
	keep if _merge == 3 // because if it does not merge I won't have test scores either way.
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
	
* Merge number of council members
	merge m:1 year muni_code using "Data/members_council"
	drop if _merge == 2
	drop _merge
	/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         1,095
        from master                     1,040  (_merge==1)
        from using                         55  (_merge==2)

    Matched                           523,812  (_merge==3)
    -----------------------------------------	
	*/
	
* Merge council names with apellido1
	rename apellido1 apellido
	merge m:1 year muni_code apellido using "Data/council_data_2012to2019"
	
	/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                       536,743
        from master                   439,349  (_merge==1)
        from using                     97,394  (_merge==2)

    Matched                            85,503  (_merge==3)
    -----------------------------------------
	*/
	
* Create connected variable
	drop if _merge == 2
	gen 	connected_council_ap1 = .
	replace connected_council_ap1 = 1 if _merge == 3
	replace connected_council_ap1 = 0 if _merge == 1
	drop _merge 
	rename apellido apellido1
	rename n_apellido_council n_council_ap1

* Merge council names with apellido2
	rename apellido2 apellido
	merge m:1 year muni_code apellido using "Data/council_data_2012to2019"
	drop if _merge == 2
	gen 	connected_council_ap2 = .
	replace connected_council_ap2 = 1 if _merge == 3	
	replace connected_council_ap2 = 0 if _merge == 1
	drop _merge
	rename apellido apellido2
	rename n_apellido_council n_council_ap2
	
	gen 	connected_council = .
	replace connected_council = 1 if connected_council_ap1 == 1
	replace connected_council = 1 if connected_council_ap2 == 1
	replace connected_council = 0 if mi(connected_council)
	
* Generate connection sending to missing the popular last names	
	gen connected_council2 = connected_council
	replace connected_council2 = . if popular_apellido1 == 1
	replace connected_council2 = . if popular_apellido2 == 1

* Now generate continuous variable of number of connections
	br apellido1 apellido2 prob_apellido1 prob_apellido2 members_council connected_council_ap1 n_council_ap1 connected_council_ap2 n_council_ap2
	
	* Number of members they should be connected with, based on their last names
		gen council_members_ap1 = members_council*prob_apellido1
		gen council_members_ap2 = members_council*prob_apellido2
		gen 	tot_potential_conn_council = council_members_ap1+council_members_ap2
		replace tot_potential_conn_council = council_members_ap1 if mi(apellido2)
		
	* Actual connections they have
		gen 	conn_council_ap1 = n_council_ap1 if connected_council_ap1 == 1
		replace conn_council_ap1 = 0 if mi(conn_council_ap1)
		gen 	conn_council_ap2 = n_council_ap2 if connected_council_ap2 == 1
		replace conn_council_ap2 = 0 if mi(conn_council_ap2)
		replace conn_council_ap2 = 0 if apellido1 == apellido2
		
		gen tot_conn_council = conn_council_ap1 + conn_council_ap2
		
	* Create continuous variables
		gen connected_council3 = tot_conn_council-tot_potential_conn_council
		drop council_members_ap* tot_potential_conn_council* conn_council_ap* tot_conn_council* n_council_ap*
	
*-------------------------------------*
* Merge principal/teachers last names *
*-------------------------------------*	
	
* Merge names with apellido1
	rename apellido1 apellido
	merge m:1 year school_code apellido using "Data/principal&teachers_lastnames", assert(2 3) keepus(directivo principal teacher n_apellido*)
	drop if _merge == 2

* Gen connection var
	br year school_code apellido directivo teacher _merge principal n_apellido*
	gen 	connected_teacher_ap1 = .
	replace connected_teacher_ap1 = 1 if _merge == 3 & n_apellido_teacher > 1 & teacher == 1
	replace connected_teacher_ap1 = 0 if mi(connected_teacher_ap1)
	
	gen 	connected_principal_ap1 = .
	replace connected_principal_ap1 = 1 if _merge == 3 & n_apellido > 1 & principal == 1
	replace connected_principal_ap1 = 0 if mi(connected_principal_ap1)
	
	gen 	connected_directivo_ap1 = .
	replace connected_directivo_ap1 = 1 if _merge == 3 & n_apellido > 1 & directivo == 1
	replace connected_directivo_ap1 = 0 if mi(connected_directivo_ap1)
	rename apellido apellido1
	rename (n_apellido_teacher n_apellido_directivo n_apellido_principal) (n_apellido_teacher1 n_apellido_directivo1 n_apellido_principal1)
	drop _merge directivo principal teacher  

* Merge names with apellido2
	rename apellido2 apellido
	merge m:1 year school_code apellido using "Data/principal&teachers_lastnames", keepus(directivo principal teacher n_apellido*)
	drop if _merge == 2

* Gen connection var for apellido2
	br year school_code apellido directivo teacher _merge principal n_apellido*
	gen 	connected_teacher_ap2 = .
	replace connected_teacher_ap2 = 1 if _merge == 3 & n_apellido_teacher > 1  & teacher == 1
	replace connected_teacher_ap2 = 0 if mi(connected_teacher_ap2)
	
	gen 	connected_principal_ap2 = .
	replace connected_principal_ap2 = 1 if _merge == 3 & n_apellido > 1 & principal == 1
	replace connected_principal_ap2 = 0 if mi(connected_principal_ap2)
	
	gen 	connected_directivo_ap2 = .
	replace connected_directivo_ap2 = 1 if _merge == 3 & n_apellido > 1 & directivo == 1
	replace connected_directivo_ap2 = 0 if mi(connected_directivo_ap2)
	rename apellido apellido2
	rename (n_apellido_teacher n_apellido_directivo n_apellido_principal) (n_apellido_teacher2 n_apellido_directivo2 n_apellido_principal2)
	drop _merge directivo principal teacher 

* Gen connection var 
	gen 	connected_teacher = .
	replace connected_teacher = 1 if connected_teacher_ap1 == 1
	replace connected_teacher = 1 if connected_teacher_ap2 == 1
	replace connected_teacher = 0 if mi(connected_teacher)
	
	gen 	connected_principal = .
	replace connected_principal = 1 if connected_principal_ap1 == 1
	replace connected_principal = 1 if connected_principal_ap2 == 1
	replace connected_principal = 0 if mi(connected_principal)

	gen 	connected_directivo = .
	replace connected_directivo = 1 if connected_directivo_ap1 == 1
	replace connected_directivo = 1 if connected_directivo_ap2 == 1
	replace connected_directivo = 0 if mi(connected_directivo)

* Taking out popular last names
	gen 	connected_teacher2 = connected_teacher
	replace connected_teacher2 = . if popular_apellido1 == 1
	replace connected_teacher2 = . if popular_apellido2 == 1
	
	gen 	connected_principal2 = connected_principal
	replace connected_principal2 = . if popular_apellido1 == 1
	replace connected_principal2 = . if popular_apellido2 == 1
	
	gen 	connected_directivo2 = connected_directivo
	replace connected_directivo2 = . if popular_apellido1 == 1
	replace connected_directivo2 = . if popular_apellido2 == 1
	
* Now generate continuous variable of number of connections

	* For n_apellido1 and n_apellido2, we substract one because it's accounting for him/herself
		replace n_apellido_teacher1 = n_apellido_teacher1 - 1
		replace n_apellido_teacher2 = n_apellido_teacher2 - 1 
	
	foreach type in teacher directivo principal  {
		br apellido1 apellido2 prob_apellido1 prob_apellido2 n_`type' connected_`type'_ap1 n_apellido_`type'1 connected_`type'_ap2 n_apellido_`type'2
		* Number of members they should be connected with, based on their last names
			gen `type'_ap1 = n_`type'*prob_apellido1
			gen `type'_ap2 = n_`type'*prob_apellido2
			gen 	tot_potential_conn_`type' = `type'_ap1+`type'_ap2
			replace tot_potential_conn_`type' = `type'_ap1 if mi(apellido2)	
		
		* Actual connections they have
			gen 	conn_`type'_ap1 = n_apellido_`type'1 if connected_`type'_ap1 == 1
			replace conn_`type'_ap1 = 0 if mi(conn_`type'_ap1)
			gen 	conn_`type'_ap2 = n_apellido_`type'2 if connected_`type'_ap2 == 1
			replace conn_`type'_ap2 = 0 if mi(conn_`type'_ap2)	
			replace conn_`type'_ap2 = 0 if apellido1 == apellido2
	
			gen tot_conn_`type' = conn_`type'_ap1 + conn_`type'_ap2	

		* Create continuous variables
			gen connected_`type'3 = tot_conn_`type'-tot_potential_conn_`type'
			drop `type'_ap1 tot_potential_conn_`type'* conn_`type'_ap* tot_conn_`type'*	
			
	}	

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
	
*--------------------------*
* Create control variables *
*--------------------------*	
	
	* Education level
	tab educ_level, m
	gen 	postgrad_degree = 0 if inlist(educ_level, 0, 1, 2, 3)
	replace postgrad_degree = 1 if inlist(educ_level, 4)
	lab var postgrad_degree "Teacher hold a post grad degree"
	
	* Temporary position
	tab type_contract, m
	gen temporary = (type_contract == 2)
	replace temporary = . if mi(type_contract)
		
	
* Save dataset
	drop *_ap*
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
		collapse (mean) connected_* (sum) N_teachers (mean) temporary female posgraduate, by(school_code year icfes_subject)
	

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
