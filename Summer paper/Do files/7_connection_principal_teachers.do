
cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"

	use "Data/base_docentes_clean_2011_2017.dta", clear

	* We have two variables position and nombre_cargo
		tab1 position nombre_cargo // nombre_cargo = 6 is rector
		
	* Reshape to have dataset school-year-lastname
		reshape long apellido, i(school_code year document_id) j(no_apellido)
		br school_code year document_id apellido position nombre_cargo
		sort school_code year document_id 
		duplicates drop school_code year document_id apellido, force // to not count people with the same two last names twice
		
	* gen indicator for Directivo docentes: coordinador, director de nucleo, director rural
		gen directivo = (position == 2)
		gen teacher = (position == 1)
		
	* Gen indicator for principal
		gen principal = (nombre_cargo == "6")
		
	* Drop duplicates in apellido
		drop if mi(apellido)
		
	* Drop duplicates in apellido
		br school_code year apellido directivo principal
		sort school_code year apellido
		gen n_apellido = 1
		gen n_apellido_teacher = teacher
		gen n_apellido_directivo = directivo
		gen n_apellido_principal = principal
		collapse (max) directivo principal teacher (sum) n_apellido n_apellido_directivo n_apellido_principal n_apellido_teacher, by(school_code year apellido)
	
	* Make school_code numerical
		rename school_code school_code2
		destring school_code2, gen(double school_code) 
		format school_code %16.0g
		
	save "Data/principal&teachers_lastnames", replace	

*-----------------------------------------------*
* Now create number of teachers characteristics *
*-----------------------------------------------*

cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"

	use "Data/base_docentes_clean_2011_2017.dta", clear

	* We have two variables position and nombre_cargo
		tab1 position nombre_cargo // nombre_cargo = 6 is rector
	
	* Keep only teachers
		keep if position == 1
	
	* Reshape to have dataset school-year-lastname
		reshape long apellido, i(school_code year document_id) j(no_apellido)
		
	* Same subject
		tab icfes_subject, gen(subject_)
		rename (subject_1 subject_2 subject_3 subject_4 subject_5) (subject_lec subject_math subject_ciencia subject_soc subject_ing)
		
	* years of exp
		gen exp_15 = 1 if  years_exp >= 15 &  !mi(years_exp)
		replace exp_15 = 0 if years_exp < 15
		
	duplicates drop school_code year document_id apellido, force // to not count people with the same two last names twice
		
	collapse (sum) subject_lec subject_math subject_ciencia subject_soc subject_ing new_estatuto exp_15, by(school_code year apellido)
	rename new_estatuto new_estatuto_tot
	
	* Make school_code numerical
		rename school_code school_code2
		destring school_code2, gen(double school_code) 
		format school_code %16.0g	
	
	save "Data/teachers_heterogeneous", replace	
	
	