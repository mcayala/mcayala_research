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

* Generate variable for secretaria certificada o no
	sort desc_mpio
	
	gen sed_certificada = .
	replace sed_certificada = 1 if inlist(desc_mpio, "APARTADO", "BARRANCABERMEJA", "BARRANQUILLA", "BELLO", "BOGOTA D.C.")
	replace sed_certificada = 1 if inlist(desc_mpio, "BUCARAMANGA", "BUENAVENTURA", "GUADALAJARA DE BUGA", "CALI", "CARTAGENA")
	replace sed_certificada = 1 if inlist(desc_mpio, "CARTAGO", "CHIA", "CUCUTA", "DUITAMA", "ENVIGADO")
	replace sed_certificada = 1 if inlist(desc_mpio, "FACATATIVA", "FUSAGASUGA", "GIRARDOT", "IBAGUE", "JAMUNDI")
	replace sed_certificada = 1 if inlist(desc_mpio, "ITAGUI", "MANIZALES", "MEDELLIN", "PALMIRA", "PASTO")
	replace sed_certificada = 1 if inlist(desc_mpio, "PEREIRA", "NEIVA", "RIOHACHA" , "PITALITO", "SOACHA")
	replace sed_certificada = 1 if inlist(desc_mpio, "POPAYAN", "PIEDECUESTA", "SOGAMOSO" , "SABANETA", "SANTA MARTA")
	replace sed_certificada = 1 if inlist(desc_mpio, "DOSQUEBRADAS", "FLORIDABLANCA", "GIRON" , "IPIALES", "LORICA")
	replace sed_certificada = 1 if inlist(desc_mpio, "MAGANGUE", "MAICAO", "MONTERIA" , "MALAMBO", "QUIBDO")
	replace sed_certificada = 1 if inlist(desc_mpio, "TULUA", "SAHAGUN", "SINCELEJO" , "SOLEDAD", "TUNJA")
	replace sed_certificada = 1 if inlist(desc_mpio, "TURBO", "URIBIA", "VALLEDUPAR" , "VILLAVICENCIO", "YOPAL")
	replace sed_certificada = 1 if inlist(desc_mpio, "YUMBO", "ZIPAQUIRA", "SAN ANDRES DE TUMACO")
	replace sed_certificada = 1 if desc_mpio == "ARMENIA" & desc_depto == "QUINDIO"
	replace sed_certificada = 1 if desc_mpio == "MOSQUERA" & desc_depto == "CUNDINAMARCA"
	replace sed_certificada = 1 if desc_mpio == "RIONEGRO" & desc_depto == "ANTIOQUIA"
	replace sed_certificada = 1 if desc_mpio == "CIENAGA" & desc_depto == "MAGDALENA"
	replace sed_certificada = 1 if desc_mpio == "FLORENCIA" & desc_depto == "CAQUETA"

	replace sed_certificada = 0 if mi(sed_certificada)
	
	
save "/Users/camila/Dropbox/PhD/Second year/Summer paper/Data/divipola.dta", replace
