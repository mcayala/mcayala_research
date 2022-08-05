
cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"

	use "Data/base_docentes_clean_2011_2017.dta", clear

	* We have two variables position and nombre_cargo
		tab1 position nombre_cargo // nombre_cargo = 6 is rector
		
	* Reshape to have dataset school-year-lastname
		reshape long apellido, i(school_code year document_id) j(no_apellido)
		br school_code year document_id apellido position nombre_cargo
		sort school_code year document_id 
		
	* gen indicator for Directivo docentes: coordinador, director de nucleo, director rural
		gen directivo = (position == 2)
		
	* Gen indicator for principal
		gen principal = (nombre_cargo == "6")
		
	* Drop duplicates in apellido
		drop if mi(apellido)
		
	* Get 10 common last names
		preserve
			gen n_lastname = 1
			collapse (count) n_lastname, by(apellido)
			sort n_lastname
			gen popular = 1 if n_lastname>=26500
			replace popular = 0 if mi(popular)
			tempfile common
			save	`common'
		restore		

	* Drop duplicates in apellido
		br school_code year apellido directivo principal
		sort school_code year apellido
		gen n_apellido = 1
		collapse (max) directivo principal (sum) n_apellido, by(school_code year apellido)
	merge m:1 apellido using `common', assert(3)
		
	* Make school_code numerical
		rename school_code school_code2
		destring school_code2, gen(double school_code) 
		format school_code %16.0g
		
	save "Data/principal&teachers_lastnames", replace	
