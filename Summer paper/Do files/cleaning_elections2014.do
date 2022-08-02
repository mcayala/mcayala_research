

global storage "/Users/camila/Dropbox/PhD/Second year/Summer paper/Data/Elecciones/2015"
global divipola "/Users/camila/Dropbox/PhD/Second year/Summer paper/Data/divipola.dta"

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
	
* Merge municode
	foreach var in desc_depto desc_mpio {
		replace `var' = subinstr(`var', "Ñ", "N",.)
		replace `var' = subinstr(`var', "Á", "A",.)
		replace `var' = subinstr(`var', "É", "E",.)
		replace `var' = subinstr(`var', "Í", "I",.)
		replace `var' = subinstr(`var', "Ó", "O",.)
		replace `var' = subinstr(`var', "Ú", "U",.)
	}
	
	* Fix some names	
	
		* Antioquia
		replace desc_mpio = "EL CARMEN DE VIBORAL" if desc_mpio == "CARMEN DE VIBORAL" & desc_depto == "ANTIOQUIA"
		replace desc_mpio = "SANTAFE DE ANTIOQUIA" if desc_mpio == "ANTIOQUIA" & desc_depto == "ANTIOQUIA"
		replace desc_mpio = "PUERTO NARE" if desc_mpio == "PUERTO NARE-LA MAGDALENA" & desc_depto == "ANTIOQUIA"
		replace desc_mpio = "SAN ANDRES DE CUERQUIA" if desc_mpio == "SAN ANDRES" & desc_depto == "ANTIOQUIA"
		replace desc_mpio = "EL SANTUARIO" if desc_mpio == "SANTUARIO"  & desc_depto == "ANTIOQUIA"
		replace desc_mpio = "YONDO" if desc_mpio == "YONDO-CASABE" & desc_depto == "ANTIOQUIA"
		replace desc_mpio = "CIUDAD BOLIVAR" if desc_mpio == "BOLIVAR" & desc_depto == "ANTIOQUIA"

		* Bogota
		replace desc_mpio = "BOGOTA D.C." if desc_mpio == "BOGOTA. D.C."
		
		* Bolivar
		replace desc_mpio = "ARROYOHONDO" if desc_mpio == "ARROYO HONDO" & desc_depto == "BOLIVAR"
		replace desc_mpio = "RIO VIEJO" if desc_mpio == "RIOVIEJO" & desc_depto == "BOLIVAR"
		replace desc_mpio = "TIQUISIO" if desc_mpio == "TIQUISIO (PTO. RICO)" & desc_depto == "BOLIVAR"
		replace desc_mpio = "YONDO" if desc_mpio == "YONDO-CASABE" & desc_depto == "BOLIVAR"
		replace desc_mpio = "SAN PABLO DE BORBUR" if desc_mpio == "SAN PABLO" & desc_depto == "BOLIVAR"
	
		* Boyaca
		replace desc_mpio = "AQUITANIA" if desc_mpio == "AQUITANIA (PUEBLOVIEJO)" & desc_depto == "BOYACA"
		replace desc_mpio = "VILLA DE LEYVA" if desc_mpio == "VILLA DE LEIVA" & desc_depto == "BOYACA"
		replace desc_mpio = "BUENA VISTA" if desc_mpio == "BUENAVISTA" & desc_depto == "BOYACA"

		* Casanare
		replace desc_mpio = "PAZ DE ARIPORO" if desc_mpio == "PAZ DE ARIPORO (MORENO)" & desc_depto == "CASANARE"

		* Cauca
		replace desc_mpio = "LOPEZ" if desc_mpio == "LOPEZ (MICAY)" & desc_depto == "CAUCA"
		replace desc_mpio = "PATIA" if desc_mpio == "PATIA (EL BORDO)" & desc_depto == "CAUCA"
		replace desc_mpio = "PURACE" if desc_mpio == "PURACE (COCONUCO)" & desc_depto == "CAUCA"
		replace desc_mpio = "SOTARA" if desc_mpio == "SOTARA (PAISPAMBA)" & desc_depto == "CAUCA"
		replace desc_mpio = "PAEZ" if desc_mpio == "PAEZ (BELALCAZAR)"  & desc_depto == "CAUCA"
		
		* Cesar
		replace desc_mpio = "MANAURE" if desc_mpio == "MANAURE BALCON DEL CESAR (MANA" & desc_depto == "CESAR"

		* Choco
		replace desc_mpio = "ALTO BAUDO" if desc_mpio == "ALTO BAUDO (PIE DE PATO)" & desc_depto == "CHOCO"
		replace desc_mpio = "ATRATO" if desc_mpio == "ATRATO (YUTO)" & desc_depto == "CHOCO"
		replace desc_mpio = "BAHIA SOLANO" if desc_mpio == "BAHIA SOLANO (MUTIS)" & desc_depto == "CHOCO"
		replace desc_mpio = "BAJO BAUDO" if desc_mpio == "BAJO BAUDO (PIZARRO)" & desc_depto == "CHOCO"
		replace desc_mpio = "BOJAYA" if desc_mpio == "BOJAYA (BELLAVISTA)" & desc_depto == "CHOCO"
		replace desc_mpio = "EL CANTON DEL SAN PABLO" if desc_mpio == "EL CANTON DEL SAN PABLO (MAN." & desc_depto == "CHOCO"
		replace desc_mpio = "MEDIO ATRATO" if desc_mpio == "MEDIO ATRATO (BETE)" & desc_depto == "CHOCO"
		replace desc_mpio = "MEDIO BAUDO" if desc_mpio == "MEDIO BAUDO (PUERTO MELUK)" & desc_depto == "CHOCO"
		replace desc_mpio = "RIO QUITO" if desc_mpio == "RIO QUITO (PAIMADO)" & desc_depto == "CHOCO"
		replace desc_mpio = "UNION PANAMERICANA" if desc_mpio == "UNION PANAMERICANA (LAS ANIMAS" & desc_depto == "CHOCO"
		replace desc_mpio = "EL CARMEN DE ATRATO" if desc_mpio == "EL CARMEN" & desc_depto == "CHOCO"
		
		* Cordoba
		replace desc_mpio = "COTORRA" if desc_mpio == "COTORRA (BONGO)" & desc_depto == "CORDOBA"
		replace desc_mpio = "LA APARTADA" if desc_mpio == "LA APARTADA (FRONTERA)" & desc_depto == "CORDOBA"
		replace desc_mpio = "SAN ANDRES SOTAVENTO" if desc_mpio == "SAN ANDRES DE SOTAVENTO" & desc_depto == "CORDOBA"
		
		* Cundinamarca
		replace desc_mpio = "PARATEBUENO" if desc_mpio == "PARATEBUENO (LA NAGUAYA)" & desc_depto == "CUNDINAMARCA"
		replace desc_mpio = "SAN JUAN DE RIO SECO" if desc_mpio == "SAN JUAN DE RIOSECO" & desc_depto == "CUNDINAMARCA"
		
		* Huila
		replace desc_mpio = "LA ARGENTINA" if desc_mpio == "LA ARGENTINA (PLATA VIEJA)" & desc_depto == "HUILA"
		replace desc_mpio = "TESALIA" if desc_mpio == "TESALIA (CARNICERIAS)" & desc_depto == "HUILA"
		
		* La Guajira
		replace desc_mpio = "DIBULA" if desc_mpio == "DIBULLA" & desc_depto == "LA GUAJIRA"

		* Magdalena
		replace desc_mpio = "ARIGUANI" if desc_mpio == "ARIGUANI (EL DIFICIL)" & desc_depto == "MAGDALENA"
		replace desc_mpio = "CERRO SAN ANTONIO" if desc_mpio == "CERRO DE SAN ANTONIO" & desc_depto == "MAGDALENA"
		replace desc_mpio = "PUEBLO VIEJO" if desc_mpio == "PUEBLOVIEJO"  & desc_depto == "MAGDALENA"
		replace desc_mpio = "ZONA BANANERA" if desc_mpio == "ZONA BANANERA (SEVILLA)"  & desc_depto == "MAGDALENA"
		
		* Meta
		replace desc_mpio = "SAN MARTIN" if desc_mpio == "SAN MARTIN DE LOS LLANOS" & desc_depto == "META"
		
		* Nariño
		replace desc_mpio = "ARBOLEDA" if desc_mpio == "ARBOLEDA (BERRUECOS)" & desc_depto == "NARINO"
		replace desc_mpio = "CUASPUD" if desc_mpio == "CUASPUD (CARLOSAMA)" & desc_depto == "NARINO"
		replace desc_mpio = "EL TABLON DE GOMEZ" if desc_mpio == "EL TABLON" & desc_depto == "NARINO"
		replace desc_mpio = "FRANCISCO PIZARRO" if desc_mpio == "FRANCISCO PIZARRO (SALAHONDA)" & desc_depto == "NARINO"
		replace desc_mpio = "LOS ANDES" if desc_mpio == "LOS ANDES (SOTOMAYOR)" & desc_depto == "NARINO"
		replace desc_mpio = "MAGUI" if desc_mpio == "MAGUI (PAYAN)" & desc_depto == "NARINO"
		replace desc_mpio = "MALLAMA" if desc_mpio == "MALLAMA (PIEDRANCHA)" & desc_depto == "NARINO"
		replace desc_mpio = "ROBERTO PAYAN" if desc_mpio == "ROBERTO PAYAN (SAN JOSE)" & desc_depto == "NARINO"
		replace desc_mpio = "SAN ANDRES DE TUMACO" if desc_mpio == "TUMACO" & desc_depto == "NARINO"
		replace desc_mpio = "SANTACRUZ" if desc_mpio == "SANTACRUZ (GUACHAVES)" & desc_depto == "NARINO"
		replace desc_mpio = "ALBAN" if desc_mpio == "ALBAN (SAN JOSE)" & desc_depto == "NARINO"
		replace desc_mpio = "COLON" if desc_mpio == "COLON (GENOVA)" & desc_depto == "NARINO"
		replace desc_mpio = "SANTA BARBARA" if desc_mpio == "SANTA BARBARA (ISCUANDE)" & desc_depto == "NARINO"
					
		* Putumayo
		replace desc_mpio = "LEGUIZAMO" if desc_mpio == "PUERTO LEGUIZAMO" & desc_depto == "PUTUMAYO"
		replace desc_mpio = "VALLE DE GUAMEZ" if desc_mpio == "VALLE DEL GUAMUEZ (LA HORMIGA)" & desc_depto == "PUTUMAYO"
		replace desc_mpio = "SANTACRUZ" if desc_mpio == "SANTACRUZ (GUACHAVES)" & desc_depto == "PUTUMAYO"
		replace desc_mpio = "VALLE DE GUAMEZ" if desc_mpio == "VALLE DE GUAMUEZ" & desc_depto == "PUTUMAYO"
		replace desc_mpio = "SAN MIGUEL" if desc_mpio == "SAN MIGUEL (LA DORADA)" & desc_depto == "PUTUMAYO"
		
		* Santander
		replace desc_mpio = "EL CARMEN DE CHUCURI" if desc_mpio == "EL CARMEN" & desc_depto == "SANTANDER"
		
		* Sucre
		replace desc_mpio = "COLOSO" if desc_mpio == "COLOSO (RICAURTE)" & desc_depto == "SUCRE"
		replace desc_mpio = "GALERAS" if desc_mpio == "GALERAS (NUEVA GRANADA)" & desc_depto == "SUCRE"
		replace desc_mpio = "SAN JUAN DE BETULIA" if desc_mpio == "SAN JUAN DE BETULIA (BETULIA)" & desc_depto == "SUCRE"
		replace desc_mpio = "SANTIAGO DE TOLU" if desc_mpio == "TOLU" & desc_depto == "SUCRE"
		replace desc_mpio = "TOLU VIEJO" if desc_mpio == "TOLUVIEJO" & desc_depto == "SUCRE"
		replace desc_mpio = "SAN LUIS DE SINCE" if desc_mpio == "SINCE" & desc_depto == "SUCRE"

		* Tolima
		replace desc_mpio = "ARMERO" if desc_mpio == "ARMERO (GUAYABAL)" & desc_depto == "TOLIMA"
		replace desc_mpio = "RIO BLANCO" if desc_mpio == "RIOBLANCO" & desc_depto == "TOLIMA"
		
		* Valle
		replace desc_depto = "VALLE DEL CAUCA" if desc_depto == "VALLE"
		replace desc_mpio = "GUADALAJARA DE BUGA" if desc_mpio == "BUGA" & desc_depto == "VALLE DEL CAUCA"
		replace desc_mpio = "CALIMA" if desc_mpio == "CALIMA (DARIEN)" & desc_depto == "VALLE DEL CAUCA"
		
	* Merge
	merge m:1 desc_depto desc_mpio using "${divipola}", assert(2 3)
	keep if _merge == 3
	drop _merge
	 
	 
	gen year = 2016
	 
save "winners_2015.dta", replace
-	 
	 
	 
* Reshape	
	bys muni_code: gen count = _n
	reshape long apellido, i(muni_code count) j(no_apellido)
	
* Drop duplicates in apellido
	drop if mi(apellido)
	duplicates drop muni_code apellido, force
	sort muni_code apellido
	isid muni_code apellido
	

	
save "winners_2015.dta", replace
	
	-
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
	
	
	
	
