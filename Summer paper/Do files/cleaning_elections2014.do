
*------------------------------------------------*
* Import data from excel to Stata and name files *
*------------------------------------------------*

	global storage "/Users/camila/Dropbox/PhD/Second year/Summer paper/Data/Elecciones/2014"

	loc	folder: dir "${storage}" dirs * // The list of dptos in folders
	 
	foreach dptofolder of local folder {

		 loc	files: dir "${storage}/`dptofolder'" files "*.xls"	//	The list of .csv files in the folder

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
	
	
	
	
