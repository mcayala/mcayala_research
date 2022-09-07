import delimited "/Users/camila/Dropbox/PhD/Second year/Summer paper/Data/divipola.csv", clear 

		foreach var in departamento municipio {
			replace `var' = subinstr(`var', "ñ", "n",.)
			replace `var' = subinstr(`var', "á", "a",.)
			replace `var' = subinstr(`var', "é", "e",.)
			replace `var' = subinstr(`var', "í", "i",.)
			replace `var' = subinstr(`var', "ó", "o",.)
			replace `var' = subinstr(`var', "ú", "u",.)
			replace `var' = subinstr(`var', "ü", "u",.)
			replace `var' = upper(`var')
		}
		
		
replace códigodanedelmunicipio= códigodanedelmunicipio*1000		

rename (códigodanedeldepartamento departamento códigodanedelmunicipio municipio) (dpto_code desc_depto muni_code desc_mpio)

replace desc_depto = "SAN ANDRES" if desc_depto == "ARCHIPIELAGO DE SAN ANDRES, PROVIDENCIA Y SANTA CATALINA"
replace desc_mpio = "TOGUI" if desc_mpio == "TOGüI"
replace desc_mpio = "GUICAN" if desc_mpio == "GüICAN"
replace desc_mpio = "UTICA" if desc_mpio == "ÚTICA"
replace desc_mpio = "UBATE" if desc_mpio == "VILLA DE SAN DIEGO DE UBATE"
replace desc_mpio = "CHACHAGUI" if desc_mpio == "CHACHAGüI"
replace desc_mpio = "EL AGUILA" if desc_mpio == "EL ÁGUILA"

replace desc_mpio = "SAN LUIS DE PALENQUE" if muni_code == 85325
replace muni_code = 8001 if desc_mpio == "BARRANQUILLA"

save "/Users/camila/Dropbox/PhD/Second year/Summer paper/Data/divipola.dta", replace
