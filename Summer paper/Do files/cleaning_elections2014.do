

global storage "/Users/camila/Dropbox/PhD/Second year/Summer paper/Data/Elecciones/2015"

*------------------------*
* RESULTS ELECTIONS 2015 *
*------------------------*

cd "${storage}"

import delimited "Elegidos/Elegidos.txt", clear

* Keep concejo
	keep if corporacion == "CONCEJO"

	isid departamento municipio nombre
	isid departamento municipio partido candidato
	rename (departamento municipio nombre) (desc_depto desc_mpio desc_candidato)
	
* Getting last names
	gen apellido2 = word(desc_candidato, -1) 
	gen apellido1 = word(desc_candidato, -2) 
	br desc_candidato apellido1 apellido2
	
* Some cleaning
	br desc_candidato apellido1 apellido2 if apellido1 == "DE"
	replace apellido2 = apellido1 + " " + apellido2 if apellido1 == "DE"
	replace apellido1 = word(desc_candidato, -3) if apellido1 == "DE"
	
	br desc_candidato apellido1 apellido2 if apellido1 == "DEL"
	replace apellido2 = apellido1 + " " + apellido2 if apellido1 == "DEL"
	replace apellido1 = word(desc_candidato, -3) if apellido1 == "DEL"
 	
	br desc_candidato apellido1 apellido2 if apellido1 == "LA"
	replace apellido2 = "DE "+ apellido1 + " " + apellido2 if apellido1 == "LA"
	replace apellido1 = word(desc_candidato, -4) if apellido1 == "LA"
	
save "winners_2015.dta", replace
	
*------------------------------------------------*
* Import data from excel to Stata and name files *
*------------------------------------------------*



	loc	files: dir "${storage}/Votaciones" files "*.txt"	//	The list of .csv files in the folder

	
	foreach dpto of local files {
		di "`dpto'"
		import delimited "${storage}/Votaciones/`dpto'", clear
		
		* Keep concejo
			keep if corporacion == "CONCEJO"
			
		* Collapse
			collapse (sum) votos (first) desc_candidato desc_partido, by(desc_depto desc_mpio partido candidato)
			
		* Save
			save "${storage}/Votaciones/`dpto'.dta", replace
	}
	
	
* Append data for all departments
	clear
	set obs 0

	loc	files: dir "${storage}/Votaciones/" files "*.dta"	//	The list of .csv files in the folder
	foreach dptofile of local files {
		append using "${storage}/Votaciones//`dptofile'"
	}	
	
* Merge winners 
	merge 1:1 desc_depto desc_mpio partido candidato using "winners.dta"
	- 
	save "${storage}/elecciones_2015.dta", replace
		
	
	-
	desc_depto desc_mpio desc_partido desc_candidato
	
	
	
	
	foreach mpiofile of local files {
		* Get name of deparment and municipality
			import excel "${storage}/`dptofolder'/`mpiofile'", sheet("Report") cellrange(A9:A9) clear
			replace A = subinstr(A, "[", "",.)
			replace A = subinstr(A, "]", "",.)
			replace A = subinstr(A, "Ñ", "N",.)
			replace A = subinstr(A, "Á", "A",.)
			replace A = subinstr(A, "É", "E",.)
			replace A = subinstr(A, "Í", "I",.)
			replace A = subinstr(A, "Ó", "O",.)
			replace A = subinstr(A, "Ú", "U",.)
			split A, parse(,)
			replace A1 = strtrim(A1)
			replace A2 = strtrim(A2)
			loc dpto = A1 in 1
			loc mpio = A2 in 1
			
		* Now get data to import and basic cleaning
			import excel "${storage}/`dptofolder'/`mpiofile'", sheet("Report") cellrange(A10) firstrow clear allstring
			rename (CÓDIGO DESCRIPCIÓN VOTOS PARTICIPACIÓN PARTIDOS) (codigo descripcion votos participacion partidos)
			drop if mi(votos)
			destring votos participacion, replace force
			gen dpto = "`dpto'"
			gen mpio = "`mpio'"
			order dpto mpio
			save "${storage}/`dptofolder'/`dpto' - `mpio'.dta", replace
		}

	* Create one dataset for each department
		clear
		set obs 0
		loc	files: dir "${storage}/`dptofolder'" files "*.dta"	//	The list of .csv files in the folder
		foreach mpiofile of local files {
			append using "${storage}/`dptofolder'/`mpiofile'"
		}
		save "${storage}/`dpto'.dta", replace
	}

* Append data for all departments
	clear
	set obs 0

	loc	files: dir "${storage}" files "*.dta"	//	The list of .csv files in the folder
	foreach dptofile of local files {
		append using "${storage}/`dptofile'"
	}	
	save "${storage}/elecciones_2014.dta", replace
	
	
	
	
