
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
		collapse (max) directivo principal, by(school_code year apellido)
		
	save "Data/principal&teachers_lastnames", replace	
